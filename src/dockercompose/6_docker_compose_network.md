# Network

---

- Networks are also easy concept, we are not going to learn new stuff here.
- We will just learn how to do same stuff, but more efficiently.
- But at the end you will create an app that talks with database.
- And most of all database values will be persisted.

## Setting Up Network

- If you were paying attention to logs when we run our services, you saw that `docker-compose` creates a `default` network for us.
- So all **services** defined on same file are already in same ( `default` ) network.

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-web
    ports:
      - 9090:8080
  myTester:                               # 1
    image: amantuladhar/network-tools     # 2
    command: sleep 50000                  # 3
  myDb:
    image: mysql:5.7
...
...
```

- `#1` Define one more service `myTester`
- `#2` Use the image `amantuladhar/network-tools`. Remember when we learned networks, we used this to test connection between two containers.
- `#3` Overriding default `command` for an image, as this image doesn't have long-running process. This is so that it runs for a long period of time, and we can go inside the **service** and test our network.
- I believe this is nothing new, we already did this before.
- Only difference is that, now we are using compose, and it's convenience.

## Testing Network

- Attach pseudo-tty of `myTester`.
```bash
docker-compose exec myTester sh
```

- Test the network like we did before.
- We have to use `service_name` to communicate with other container.
- `localhost` will not work. We will learn how we can achieve this later.

```bash
/ # curl myApp:8080/test | jq .
{
  "message": "Hello Fellas!!!",
  "host.address": "192.168.48.2",
  "app.version": "v1-web"
}
```

## Named Network

- While relying on `default` network works, you may want to name your network yourself.
- You may even want to create multiple networks.
- To achieve that we have **networks** root properties.
- If we use it as a **root** property, we can define any number custom networks we want.
- If used inside **services** property, it will make that particular **service** reside in the network.
```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-web
    ports:
      - 9090:8080
    networks:                              # 3     
      - myNet                              # 4    
  myTester:
    image: amantuladhar/network-tools
    command: sleep 50000
    networks:                              # 3    
      - myNet                              # 4    
  myDb:
    image: mysql:5.7
...
...
networks:                                  # 1
  myNet:                                   # 2
...
... 
```

- `#1` this is a root property. This includes list of custom network you want to create.
- `#2` name of network you want to create.
- `#3` this is used inside **services**. This defines which network particular **service** communicates with.
- `#4` Name of networks **service** will use. You can add multiple networks
- You can check if two containers can talk with each other like before.

## Using `network_mode`

- With help of `network_mode` property we can define the way container network are configured.
- Remember `--net=container:@name` syntax. `network_mode` can achieve something like this.
- `network_mode` supports
  - "bridge"
  - "host"
  - "none"
  - "service:@name"
  - "container:@id/@name"
- For now, we will use `serrvice:@name` mode. Which I think will often be used than others.

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-web
    ports:
      - 9090:8080
    networks:                                   
      - myNet                                 
  myTester:
    image: amantuladhar/network-tools
    command: sleep 50000
    network_mode: service:myApp           # 1
  myDb:
    image: mysql:5.7
...
...
...
```

- `#1` This defines that we want to use same network that is being used by **service** `myApp`.
- We are using `networks` properties for `**myApp**`, to define network for service.
- Notice we didn't even have to define `networks` properties for **`myTester`**.
- When defining a service you cannot use `ports` and `network_mode` properties at the same time.
- Testing using `localhost` in `myTester`

```bash
/ # curl localhost:8080/test
{
"message": "Hello Fellas!!!",
"host.address": "192.168.112.2",
"app.version": "v1-web"
}
```

## Web App With Database

- You now have knowledge of how `docker-compose` and its component works.
- Let's create a web app that connects with database.
- You can use `amantuladhar/docker-kubernetes:v1-db` image to get the app that tries to connect with database.
    - This tag expects three environment variable: `DB_URL`, `DB_USER`, `DB_PASS`.
- [Web App With Database Example](https://github.com/amantuladhar/DockerKubernetesFiles/tree/compose-db-initial) branch `compose-db-initial` if you want to build it yourself.
- Here's a compose file we are initially working with

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-db
    ports:
      - 9090:8080
  myDb:
    image: mysql:5.7
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=docker_kubernetes
    volumes:
      - "./volume/mysql-compose/:/var/lib/mysql/"
networks:
  myNet:
```

- First step is to add **network** on both the **services**. (Or you can use default network).

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-db
    ports:
      - 9090:8080
    networks:                                 # 1
      - myNet                                 # 1
  myDb:
    image: mysql:5.7
    networks:                                 # 1
      - myNet                                 # 1
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=docker_kubernetes
    volumes:
      - "./volume/mysql-compose/:/var/lib/mysql/"
networks:
  myNet:
```

- `#1` added network to our services.
- If you are using image above, it expected three stuff so that it can successfully connect with database.
    - `DB_URL` Connection URL
    - `DB_USER` Database User
    - `DB_PASS` Database User Password

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-db
    ports:
      - 9090:8080
    networks:
      - myNet
    environment:                                                       # 1
      - DB_URL=jdbc:mysql://myDb:3306/docker_kubernetes?useSSL=false   # 2
      - DB_USER=root                                                   # 2
      - DB_PASS=password                                               # 2   
  myDb:
    image: mysql:5.7
    networks:
      - myNet
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=docker_kubernetes
    volumes:
      - "./volume/mysql-compose/:/var/lib/mysql/"
networks:
  myNet:
```

- `#1` Using `environment` property to set our environment variable.
- `#2` Setting necessary environment variables.
- If you run the services now you should be able to start your app and run it.

## Managing service start order

- When using above compose file, it is not necessary that database starts first and web later.
- Docker compose doesn't know which service to start first.
- If our web app starts first and then database, clearly our app will fail.
- To minimize such issues `docker-compose` has `depends_on` property that we can use.
- We can add list of **services** particular service depends on and `docker-compose` will take care of starting them in order.

> `depends_on` does not wait for `mysql` to be **ready** before starting web only until they have been started.

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-db
...
...
    depends_on:            <-------------
      - myDb
  myDb:
    image: mysql:5.7
    networks:
      - myNet
...
...
networks:
  myNet:
```
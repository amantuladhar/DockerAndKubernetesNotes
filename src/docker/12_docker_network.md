# Docker Network

---

## Why do we need network?

- To see why we need inter network communication, let's run two container (in background).

```bash
➜ docker run \
         -p 9090:8080
         -d amantuladhar/doc-kub-ws:web-basic
```

- Let's try to access our app from different container

```bash
➜ docker run \
         -it amantuladhar/network-tools sh
```

> `network-tools` image have few tools like `curl`, `http`, `ping`, `nc`.

- From this container, let's call `http localhost:8080/test`.
- It won't work because there is no connection between those two containers.
- Consider scenario where our app needs to talk with container that is running **mysql**.

## **Listing network**

```bash
docker network list
```

- If you do `docker network list`, you will see three networks is already created
  - bridge
  - host
  - none
- These are networks created by different network drivers docker supports. (We have few more drivers).
- Default driver for network is `bridge`.

## Create a network

- To create a network you just issue `docker network create @name`.
```bash
docker network create myNet
```
- This will create network with name `myNet` with driver `bridge`.

&nbsp;

--- 

# Using network
## Define which network to connect to

- `--net=@network_name` syntax.
- To use the network we created we can use `--net` option.
```bash
➜ docker run \
         --name=myApp
         --net=myNet
         -p 9090:8080
         -d amantuladhar/doc-kub-ws:web-basic
```

- Notice I am naming my container myself using `--name` option. You will know in a bit why I am doing this.
- This will run our container in our network `myNet`.
- Now lets run `network-tools` image on same network.

```bash
➜ docker run \
         --name=myTester \
         --net=myNet
         -it amantuladhar/network-tools sh
```
- Try to execute `curl` on `localhost:8080/test`. or `localhost:9090/test`
- It won't work. Why? We explicitly ran both of your container on same network.

## Container Discovery
- To access the app running on same network, we cannot use localhost.
- I think this is obvious. From the application standpoint they are not running on same computer\*.
- If we can't use **localhost** what do we use?
- Turns out we have to use **container name** i.e `myApp` in our case.
- If you do `curl` on `myApp:8080/test` it will work.

> Docker has builtin DNS server that converts container name to its IP.

## Auto connect to specified container network

- `--net` has a syntax that supports auto network discovery i.e `--net=container:name`.
- If you use this syntax, docker will automatically connect network that is used by specified container.
- If you use this syntax, you will be able to use `localhost` instead of `container_name` .
- Run the image that has our app like before.

```bash
➜ docker run \
         --name=myApp
         --net=myNet
         -p 9090:8080
         -d amantuladhar/doc-kub-ws:web-basic
```
- Run the tester again with `container` syntax.
```bash
docker run \
     --name=myTester \
     --net=container:myApp \
     -it \
     amantuladhar/network-tools \
     sh 
```
- Test using localhost, and it just works.
```bash
/ # curl localhost:8080/test | jq .
{
  "message": "Hello Fellas!!!",
  "host.address": "172.23.0.3",
  "app.version": "v1-web"
}
```
> - As exercise, you can try to create application that stores some values in database.
> - You can use `amantuladhar/docker-kubernetes:v1-db` image.
> - Simple Web App at branch [initial-db](https://github.com/amantuladhar/DockerKubernetesFiles/tree/initial-db)
> - App expects that you will set `DB_URL`, `DB_USER` and `DB_PASS` environment variable, which is a full connection URL for mysql.
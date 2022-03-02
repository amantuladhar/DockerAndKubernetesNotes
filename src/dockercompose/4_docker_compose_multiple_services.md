# Multiple Services

---

## Defining Multiple Services

- Docker compose shine when you want to run multi-container app.
- Even if you want to run multiple container, you can run your app using single command.
- Let's add **mysql** service in our compose file.

> We will define `mysql` service but our app won't try to interact with database at the moment.

```yaml
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-web
    ports:
      - 9090:8080
  myDb:                                    #  1
    image: mysql:5.7                       #  2
    environment:                           #  3
      - MYSQL_ROOT_PASSWORD=password       #  4
      - MYSQL_DATABASE=docker_kubernetes   #  4
```
- `#1` name of new service.
- `#2` image you want to run. You can use `build` if you want to.
- `#3` Passing environment variables to image. Like we did with `-e` option.
- `#4` List of environment variables
- One new thing in this service is that we are setting environment variables in the file.
- Remember when you had to do this in command, those are old days now :).

## Listing the running services

- If you want to list the running services you can use `docker-compose ps`

## Attach `mysql` terminal

- `docker-compose exec @servicename @cmd`
- If you want to attach mysql pseudo tty to host, we can do that too.
- `docker-compose exec` by default attaches the pseudo tty so we don't need to add `-it` option.
- If you don't want to attach pseudo-tty you can use `-T` option.
- For now let's use `docker-compose exec myDb sh`
- Play around with the service, but remember data won't be persisted in next run
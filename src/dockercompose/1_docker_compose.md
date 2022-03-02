# Docker Compose

---

## What is docker compose?

- `docker compose` is tool for defining and running complex applications with Docker.
- With Compose, we define a **multi-container application** in a single file.
- It allows you to spin your application up in a single command.
- Orchestration between two containers are easy with docker compose.
- Default file name for docker-compose is is `docker-compose.yml`.

> Docker Compose works in the scope of a single host, where Kubernetes works on multi cluster environment.

## Simple compose file

- This is what a simple compose file looks like.
```yaml
version: '3'                                       # 1    
services:                                          # 2
  myApp:                                             # 3
    image: amantuladhar/docker-kubernetes:v1-web     # 4 
```
- `#1` specifies what version of compose API you want to use.
- `#2` is a root property. It includes list of all services (containers) compose will manage.
- `#3` is name of the service (container)
- `#4` specifies image you want to run.

> If you want to build you app yourself you can find the app in [Spring Simple Web](https://github.com/amantuladhar/DockerKubernetesFiles/tree/compose-initial) branch `compose-initial`.

- You noticed that in compose file containers are called **services**.
- Compose can manage multiple services, but for now we are dealing with only one.
- We defined the service called `myApp` which will run the image.

## Build your image

- If you want to build your own image instead of using one, you can do that easily too
```yaml
version: '3'
services:
  myApp:
    build:                     # 1  
      context: .               # 2
      dockerfile: Dockerfile   # 3
```
- `#1` build tag will let compose know that you want to build your image.
- `#2` context defines where your docker file are stored.
- `#3` Dockerfile takes the file name for `Dockerfile`. If the file name is `Dockerfile` you don't seed to specify the property.
- You use `docker-compose build` to build your image. (docker compose build in the latest version)
- If you make any changes to `Dockerfile` you need to explicitly build the image again.

> Any docker compose command can now be used without `-` i.e as part of docker command 

## Running services

- To run the services defined in compose file is super easy.
- You run any number of services defined inside compose file with single command.
- i.e `docker-compose up`. On latest docker for desktop installation you can just `docker compose up`.
- If you want to run it in background add `-d` option.
- If you run the app right now, it will run but it won't be accessible from our host yet.
- We need to publish ports first in order to access the app.

## Stopping services

- Starting the services were easy. How about stopping them?
- It is super easy as well. `docker-compose stop`. (`docker compose stop` in new version).
- It will stop all running services at once.
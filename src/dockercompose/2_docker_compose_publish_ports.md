# Docker Compose Publishing Ports

---

## Publishing Ports
- We made our app run with single command, but we were not able to access them.
- To access our app we needed to publish the ports.
- We know for `docker run` command we use `-p` option.
- On compose we use `ports` property

```yaml
version: '3'
services:
  myApp:
    image: amantuladhar/docker-kubernetes:v1-web
    ports:
      - 9090:8080
```
- You can publish any number of ports you want as you would with `-p` option.
- You may have a hint on what docker-compose is trying to achieve.
- If we publish ports with `docker run`, we need to specify that in every run.
- But with compose, you don't need it.
- We define the options in `yaml` file, and we simply use `docker-compose up`.
- If you run your application now, you will be able to access it from the host.
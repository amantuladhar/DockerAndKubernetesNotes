# Understand Docker Layer

&nbsp;

---

## Docker layers?
- Layer is basically a change on an image, or an intermediate image. 
- Every instructions you specify (FROM, RUN, COPY, etc.) in your Dockerfile causes the previous image to change, thus creating a new layer. 
- That image layer then becomes the parent for the layer created by the next instruction.
- Final image  and/or image that we use consists of a series of layers which are stacked, one on top of the another.
- You can think of it as staging changes when you're using git. You add a file's change, then another one, then another one.
- When you build your image before, you also created lots of images.
- `docker build . -t docker-kubernetes:dockerfile-basics`

```bash
                            +---------------------------------+
             +------------> |          6e384ad670e7           |
             |              | CMD ["java", "-jar", "app.jar"] |
             |              +---------------------------------+
             +------------> |          adfedcd08e78           |
             |              |COPY ["target/*.jar", "./app.jar"|
             |              +---------------------------------+
             +------------> |          aae885b8525e           |
Layer Id+----+              |   RUN apk add --no-cache curl   |
             |              +---------------------------------+
             +------------> |          14446213dae8           |
             |              |           EXPOSE 8080           |
             |              +---------------------------------+
             +------------> |          a40643187675           |
             |              |          WORKDIR /myApp         |
             |              +---------------------------------+
             +------------> |          1b46cc2ba839           |
                            |    FROM openjdk:8-jre-alpine    |
                            +---------------------------------+
```

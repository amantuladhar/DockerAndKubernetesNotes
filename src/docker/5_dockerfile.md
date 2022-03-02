# What is `Dockerfile`

- `Dockerfile` is just a plain text file.
- The plain text file contains series of instruction.
- Docker will read `Dockerfile` when you start the process of building an image.
- It executes the instruction one by one in orderly fashion.
- At the end final read-only image is created.
- **It's important to know that Docker uses images to run your code, not the** `Dockerfile`**.**
- `Dockerfile` is just a convenient way to build your docker images.
- Default file name for `Dockerfile` is `Dockerfile`.

&nbsp;

---    



## Building an image

### `docker build`

- Even if you have single instruction `FROM` you can build your image.
- We can simply execute `docker build -f @pathToDockerfile -t @name:@tag @contextPath`.
- `@contextPath` is the path where you want docker build context path.
- `-f` takes the path to Dockerfile. If your file exist within the `docker build` context path and your file name is `Dockerfile` you don't need to use `-f` flag.
- `-t` represents `tag`. This is so that you can name the image you are building.
- If you omit the `tag` part, docker will add by default **latest** tag.
- Notice when it builds an image, if you don't have the image that you used locally it will download it first.
    
```bash
➜ docker build -f docker/web-basic -t amantuladhar/doc-kub-ws:web-basic .
Sending build context to Docker daemon  17.02MB
Step 1/1 : FROM openjdk:8-jre-alpine
8-jre-alpine: Pulling from library/openjdk
6c40cc604d8e: Pull complete 
e78b80385239: Pull complete 
f41fe1b6eee3: Pull complete 
Digest: sha256:712abc7541d52998f14b43998227eeb17fd895cf10957ad5cf195217ab62153e
Status: Downloaded newer image for openjdk:8-jre-alpine
 ---> 1b46cc2ba839
Successfully built 1b46cc2ba839
Successfully tagged amantuladhar/docker-kubernetes:dockerfile-basics
```

- Run `docker image list` and you will see your image on the list
- (Psst!! You can go inside your image an play around with it)
    

## `FROM`

- `FROM` is the first instruction in `Dockerfile`.
- Sets the base image for every subsequent instruction.
- If you skip tag, docker will use latest tag.
- Latest tag may not be latest image.
- If we provide invalid tag, docker will complain.
    
```bash
FROM openjdk:8-jre-alpine
```

## WORKDIR

- Sets starting point from where you want to execute subsequent instructions.
- We can set both absolute / relative path
- We can have multiple `WORKDIR` in images
- If relative path is used, it will be relative to previous `WORKDIR`
- Think of this as changing the directory
    
```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
```

## COPY

- `COPY @source @destination`
- Copies files from source to container file system
- Source can be path or URL
- Path is relative to where build process was started.
- Both can contain wildcards like \* and ?
- Let's add our app executable inside docker image.
- Before that you need app.
- You can create one yourself or I have a simple [spring app here.](https://github.com/amantuladhar/DockerKubernetesFiles/blob/master/docker/web-basic)
- For this exercise lets switch to branch **dockerfile-initial**.
- Let's build `jar` for our app. `./mvnw clean install`
- Maven creates `jar` inside **/target** folder.


> **web-basic** is a Dockerfile has complete instructions.
```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
COPY ["onlyweb/target/*.jar", "./app.jar"]
```

- That's it. Build your image. Go inside an run the app
    
```bash
Sending build context to Docker daemon  17.03MB
Step 1/3 : FROM openjdk:8-jre-alpine
 ---> 1b46cc2ba839
Step 2/3 : WORKDIR /myApp
 ---> Running in 529b938e7bde
Removing intermediate container 529b938e7bde
 ---> a40643187675
Step 3/3 : COPY ["onlyweb/target/*.jar", "./app.jar"]
 ---> 63722ad415fe
Successfully built 63722ad415fe
Successfully tagged amantuladhar/doc-kub-ws:web-basic
```

&nbsp;

---

## Running your app

### `docker run -it amantuladhar/doc-kub-ws:web-basic`

```bash
➜ docker run -it amantuladhar/doc-kub-ws:web-basic
/myApp # ls
app.jar

/myApp # java -jar app.jar 

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.2.RELEASE)
...
...
2019-02-13 15:02:09.789  INFO 9 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
```
-   You still can't access the app from outside as you haven't asked docker to export the port the app is listening to.
    

## ADD

- ADD @source @destination
- Exactly as COPY
- Has few features like, archive extractions. (Like extracting achieve automatically)
- Best practice is to use `COPY` if you don’t need those additional features.
    

## EXPOSE

- `EXPOSE @port`
- `EXPOSE` tells Docker the running container listens on specific network ports.
- This acts as a kind of port mapping documentation that can then be used when **publishing the ports**.
- `EXPOSE` will **not allow** communication via the defined ports to containers outside of the same network or to the host machine.
- To allow this to happen you need to publish the ports using `-p` options when running container
    
```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
COPY ["onlyweb/target/*.jar", "./app.jar"]
```

## Port Publishing

- If you want to access your app from the host (outside the container), you need to publish the port where your app is expecting a connection.
- To do that we have `-p @hostPort:@containerPort` option.
- To access your app on **localhost:9090**

```bash
➜ docker run -it -p 9090:8080 amantuladhar/doc-kub-ws:web-basic

# Running your app inside the container
/myApp # java -jar app.jar 
....
....
2019-02-14 04:47:05.036  INFO 10 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2019-02-14 04:47:05.046  INFO 10 --- [           main] c.e.cloudnative.CloudNativeApplication   : Started CloudNativeApplication in 4.73 seconds (JVM running for 5.685)
```

- Here's a response that we get when we call `localhost:9090/test`
    
```bash
➜ http localhost:9090/test  
HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Date: Thu, 14 Feb 2019 04:49:07 GMT
Transfer-Encoding: chunked

{
    "app.version": "v1-web",
    "host.address": "172.17.0.2",
    "message": "Hello Fellas!!!"
}
```

## RUN

- `RUN @command`
- `RUN` is central executing instruction for `Dockerfile`.
- `RUN` command will execute a command or list of command in a new layer on top of current image
- Resulting image will be new base image for subsequent instruction
- To make your `Dockerfile` more readable and easier to maintain, you can split long or complex `RUN` statements on **multiple lines separating them with a backslash (** `\` **)**
- Lets install `curl` in our image. (We will need to use `curl` later)
- `RUN apk add --no-cache curl`

```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
RUN apk add --no-cache curl
COPY ["onlyweb/target/*.jar", "./app.jar"]
```

- If you build your app now, you will have `curl` command when you run the container.
- You can test if `curl` exist if you want.

```bash
➜ docker build -f docker/web-basic -t amantuladhar/doc-kub-ws:web-basic          
...
Step 4/5 : RUN apk add --no-cache curl
 ---> Running in 883ac8f78866
fetch http://dl-cdn.alpinelinux.org/alpine/v3.9/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.9/community/x86_64/APKINDEX.tar.gz
(1/4) Installing nghttp2-libs (1.35.1-r0)
(2/4) Installing libssh2 (1.8.0-r4)
(3/4) Installing libcurl (7.63.0-r0)
(4/4) Installing curl (7.63.0-r0)
...
```

## ENTRYPOINT

- The `ENTRYPOINT` specifies a command that will always be executed when the container starts.
- Docker has a default `ENTRYPOINT` which is `/bin/sh -c`
- `ENTRYPOINT ["executable", "param1", "param2"]` is the exec form, preferred and recommended.
- `ENTRYPOINT command param1 parm2` is a shell form.
- `ENTRYPOINT` is the runtime instruction, but `RUN`, `ADD` are build time instructions.
- We can use `--entrypoint` option to override when you run the container.

```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
RUN apk add --no-cache curl
COPY ["onlyweb/target/*.jar", "./app.jar"]
ENTRYPOINT ["java", "-jar", "app.jar"]
```
- Build the image and run the image, without `-it` option.
- `docker run -p 9090:8080 amantuladhar/doc-kub-ws:web-basic`
- You app will run, you didn't needed to go inside the container and execute the command yourself.
- `-p 9090:8080` was added so that you can access your app from host.

## CMD

- `CMD` also specifies a command that will execute when container starts.
- The `CMD` specifies the arguments that will be fed to the `ENTRYPOINT`.
- `CMD ["executable","parameter1","parameter2"]` this is a so called exec form. (Preferred)
- `CMD command parameter1 parameter2` this a shell form of the instruction.
- Like `ENTRYPOINT` `CMD` is a runtime instruction as well.
- You already know how to override the `CMD`, just pass it after the image name when you run the container.

```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
RUN apk add --no-cache curl
COPY ["onlyweb/target/*.jar", "./app.jar"]
ENTRYPOINT ["java", "-jar"]
CMD ["app.jar"]
```

- As you can see, `ENTRYPOINT` defines the command that gets executed when container starts.
- `CMD` is passing argument to `ENTRYPOINT`.
- Build and run the app. `docker run -p 9090:8080 amantuladhar/doc-kub-ws:web-basic`.

## **Overriding CMD**

- `docker run @image@command @arguments`.
- `docker run -p 9090:8080 amantuladhar/doc-kub-ws:web-basic test.jar`.
- Of course above command won't run because we don't have `test.jar` in our image.

```bash
➜ docker run -p 9090:8080 amantuladhar/doc-kub-ws:web-basic test.jar
Error: Unable to access jarfile test.jar
```

- How about we try to attach container terminal to host terminal using `-it`
- `docker run -it amantuladhar/doc-kub-ws:web-basic` won't work as this will run the app.
- `docker run -it amantuladhar/doc-kub-ws:web-basic sh` won't work as it internally run `java -jar sh`.
- If you really want to attach container terminal to host terminal you need to override the `ENTRYPOINT`.
- `docker run --entrypoint sh -it amantuladhar/doc-kub-ws:web-basic`

```bash
➜ docker run --entrypoint sh  -it amantuladhar/doc-kub-ws:web-basic        
/myApp #
```

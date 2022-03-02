# Maven Docker Plugin

---

## Docker with Maven Basics

- We learned `docker` and `docker-compose` basics.
- We can easily containerize our app, even if it needs database support.
- While creating images manually by yourself can be done, more human interaction leads to more errors.
- Delegating the image `build` process to maven gives you a lot of flexibility and also saves a lot of time.
- This can be especially useful, if you have continuous integration flow set up, using Jenkins for example.
- There are multiple maven plugins for docker. We will be working with
    - [fabric8io/docker-maven-plugin](https://github.com/fabric8io/docker-maven-plugin)
    - I like this one as this has lots of options and is highly configurable.
    - So much that you don’t even need a Dockerfile to build your own image when using this plugin.

> For this chapter we will use [Spring Simple Web App - `dockerfile-initial-complete`](https://github.com/amantuladhar/DockerKubernetesFiles/tree/dockerfile-initial-complete) branch. 

## New Maven Goals

- If we use [fabric8io/docker-maven-plugin](https://github.com/fabric8io/docker-maven-plugin), we get few new maven goals.
- Some important one that we will cover
    - `docker:build`: This will build the docker image from the configuration we add to `pom.xml`.
    - `docker:start/stop`: Run/Stop the image built from configuration.
    - `docker:remove`: This is for cleaning up the images and containers.
    - `docker:logs`: This prints out the output of the running containers.

## Using Plugin
- To use the plugin in you app, you need to add [fabric8io/docker-maven-plugin](https://github.com/fabric8io/docker-maven-plugin) to you `pom.xml`.
```xml
<build>
    <plugins>
        <plugin>
            <groupId>io.fabric8</groupId>
            <artifactId>docker-maven-plugin</artifactId>
            <version>0.28.0</version>
        </plugin>
    </plugins>
</build>
```
- This plugin supports lots of configuration, and we put the configuration inside `<configuration>` tag.

```xml
<build>
    <plugins>
        <plugin>
            <groupId>io.fabric8</groupId>
            <artifactId>docker-maven-plugin</artifactId>
            <version>0.28.0</version>
            <configuration>
                <verbose>true</verbose>
                <images>
                    <image>

                    </image>
                </images>
            </configuration>
        </plugin>
    </plugins>
</build>
```

- The important part in the plugin definition is the `<configuration>` element.
- It has `<images>` element which allows us to add multiple `<image>`.
- There are two main elements in the `<image>`:
    - A `<build>` configuration specifying how images are built.
    - A `<run>` configuration describing how containers should be created and started. Think of this as option that you pass on `docker run` command.
- If you are using the app from GitHub you should have a `Dockerfile`

```dockerfile
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
RUN apk add --no-cache curl
COPY ["target/*.jar", "./app.jar"]
CMD ["java", "-jar", "app.jar"]
```

## Using `Dockerfile`

- Let's add some configuration using `build` tag.

```xml
<image>
    <name>docker-kubernetes:${project.version}</name>
    <build>
        <dockerFileDir>${project.basedir}</dockerFileDir>
        <dockerFile>Dockerfile</dockerFile>
    </build>
</image>
```

- To build the dockerfile you just need to run `./mvnw clean package docker:build`. It will build your app.
- Default value for `<dockerFileDir>` is `/src/main/docker`.
- We have our `Dockerfile` inside project root directory, so we are overriding the value.

## Run using `docker:start`

- It is as simple as `./mvnw package docker:start`.
```bash
...
[INFO] --- docker-maven-plugin:0.28.0:start (default-cli) @ cloudnative ---
[INFO] DOCKER> [docker-kubernetes:v1-web]: Start container b9cbcab4c5a6
... 
```

- If you list the running container you can see that one container is running.
- Of course, we cannot access the app, we haven't published the port yet.

## Stop using `docker:stop`

- To stop the running container you can use `./mvnw package docker:stop`

```bash
...
[INFO] --- docker-maven-plugin:0.28.0:stop (default-cli) @ cloudnative ---
[INFO] DOCKER> [docker-kubernetes:v1-web]: Stop and removed container b9cbcab4c5a6 after 0 ms
...
```

## Port Publishing

- We can publish the port easily as well.
- For this plugin we add configuration inside `<run>` tag.
- Inside `<run>` tag we use `<ports>` tag to expose ports.
- Every port mapping are put inside `<port>` tag.
```xml
<image>
  <name>docker-kubernetes:${project.version}</name>
  <build>
    <dockerFileDir>${project.basedir}</dockerFileDir>
    <dockerFile>Dockerfile</dockerFile>
  </build>
  <run>
    <ports>
      <port>9090:8080</port>
    </ports>
  </run>
</image> 
```

- `build` and `run` you app again and you will be able to access it from the host this time.

## Logs

- If you want to see the logs just use `docker:logs` goal.

## Removing images

```bash
./mvnw clean package docker:remove
```

- This goal can be used to clean up images and containers.
- By default, all images with a build configuration are removed.

## Build image without `Dockerfile`

- The plugin we are using supports creating `Dockerfile` in memory.
- Inside the `<build>` tag, we can write `Dockerfile` like instructions.
```xml
<image>
  <name>docker-kubernetes:${project.version}</name>
  <build>
    <from>openjdk:8-jre-alpine</from>
    <assembly>
      <descriptorRef>artifact</descriptorRef>
    </assembly>
    <cmd>java -jar maven/${project.name}-${project.version}.jar</cmd>
  </build>
  <run>
    <ports>
      <port>9090:8080</port>
    </ports>
  </run>
</image> 
```

- `<from>` is same as `FROM` instruction.
- `<assembly>` defines how build artifacts and other files can enter the Docker image. Using this we don't need to use `COPY` to copy our build artifact.
- Inside `<assembly>` we are using `<descriptorRef>` which has some predefined ways to copy files to image.
    - `artifact-with-dependencies`: Attaches project’s artifact and all its dependencies.
    - `artifact`: Attaches only the project’s artifact but no dependencies.
    - `project`: Attaches the whole Maven project but without the target/ directory.
    - `rootWar`: Copies the artifact as ROOT.war to the exposed directory. I.e. Tomcat will then deploy the war under the root context.

- We are using `artifact` pre-defined descriptor in our configuration, because we want to copy our `jar` file only.
- `<cmd>` is same as `CMD` instruction.
- Build and run your app again. You will be able to access your app from the host.
# Network

---


## Maven Plugin Networks
> For this chapter we will use [Simple App With DB - from `plugin-db-initial`](https://github.com/amantuladhar/DockerKubernetesFiles/tree/plugin-db-initial) branch.

## Auto Create Network

- When dealing with network, we may need to create a network.
- If we create a custom network, we need to create it manually.
- Plugin that we are using can be configured so that custom network can be created automatically.
- Just set `<docker.autoCreateCustomNetworks>` value to true and you will be all set.

```xml
<properties>
    ...
    <docker.autoCreateCustomNetworks>true</docker.autoCreateCustomNetworks>
</properties>
```

## Create a network

- To create a network we use `<network>` tag.
- `<network>` has few children.
    - `mode`: The network mode, which can be one of the following values:
    - `name`: For mode container this is the container name, which is this image alias. For Mode custom this is the name of the custom network.
    - `alias`: One or more alias element can be provided which gives a way for a container to be discovered by alternate names by any other container within the scope of a particular network. This configuration only has effect for when the network mode is custom. More than one alias can be given by providing multiple entries.
```xml
<image>
    <name>docker-kubernetes:${project.version}</name>
    ...
    <run>
        <network>
            <mode>custom</mode>
            <name>mynet</name>
        </network>
        ...
        <env>
            <DB_URL>
                <![CDATA[ jdbc:mysql://mysql_db:3306/docker_kubernetes?useSSL=false]]>
            </DB_URL>
            <DB_USER>root</DB_USER>
            <DB_PASS>password</DB_PASS>
        </env>
    </run>
</image>
<image>
    <name>mydb:${project.version}</name>
    <alias>mydb</alias>
    ...
    <run>
        <network>
            <mode>custom</mode>
            <name>mynet</name>
            <alias>mysql_db</alias>
        </network>
        ...
        <ports>
            <port>4406:3306</port>
        </ports>
        <env>
            <MYSQL_ROOT_PASSWORD>password</MYSQL_ROOT_PASSWORD>
            <MYSQL_DATABASE>docker_kubernetes</MYSQL_DATABASE>
        </env>
    </run>
</image>
```

- To add your container in a network, you use `<network>` tag inside `<run>` tag.
- `<mode>` can accept multiple value
    - `bridge` : Bridged mode with the default Docker bridge (default)
    - `host` : Share the Docker host network interfaces
    - `container` : Connect to the network of the specified container. The name of the container is taken from the `<name>` element.
    - `custom` : Use a custom network, which must be created before by using docker network create.
    - `none` : No network will be setup.

- In our case we are using `custom`, because we want to create our own network.
- `<alias>` is where we give a way for a container to be discovered by alternate names by any other container within the scope of a particular network.
- **Notice:** we are using same network on both image configuration. But on **mysql** part we are giving alias.
- If you build and run the app, and your app will just work.

## mode `container`

- Using mode `container` you can access your network container using `localhost`.
- But remember you have one big limitation, you cannot combine this with `<ports>`.

```xml
<images>
    <image>
        <name>docker-kubernetes:${project.version}</name>
        <alias>my-app</alias>
        ...
        <run>
            <network>
                <mode>custom</mode>
                <name>mynet</name>
            </network>
            <ports>
                <port>9090:8080</port>
            </ports>
            <env>
                <DB_URL> <![CDATA[ jdbc:mysql://localhost:3306/docker_kubernetes?useSSL=false ]]> </DB_URL>
                ...
            </env>
        </run>
    </image>
    <image>
        <name>mydb:${project.version}</name>
        <alias>mydb</alias>
        <build>
            <from>mysql:5.7</from>
        </build>
        <run>
            <network>
                <mode>container</mode>
                <name>my-app</name>
            </network>
            ...
        </run>
    </image>
</images>
```
- We are still using `<network>` with `mode` **custom** on our web app side.
- On database side, we are using `mode` **container** but instead of network name we are using our web app **name**.
- We are using container **alias** here but you could have used **name** as well.

## `dependsOn`

- If you want to order which container start first you can use `depends_on`.
- With the plugin we have `<dependsOn>` tag.
```xml
<image>
    <name>docker-kubernetes:${project.version}</name>
    ...
    <run>
        ...
        <dependsOn>
            <container>mydb</container>
        </dependsOn>
    </run>
</image>
<image>
<name>mydb:${project.version}</name>
<alias>mydb</alias>
...
</image> 
```
# Multiple Container

---

## Maven Plugin Running Multiple Container

- With **fabric8/docker-maven-plugin** we can run multiple images.
- Let's run `mysql`, but we won't run the app that talk with this database (for now).

```xml
<images>
    <image>
        <name>docker-kubernetes:${project.version}</name>
        ...
    </image>
    <image>
        <name>myDb:${project.version}</name>
        <alias>myDb</alias>
        <build>
            <from>mysql:5.7</from>
        </build>
        <run>
            <env>
                <MYSQL_ROOT_PASSWORD>password</MYSQL_ROOT_PASSWORD>
                <MYSQL_DATABASE>docker_kubernetes</MYSQL_DATABASE>
            </env>
        </run>
    </image>
</images>
```

- You just need to add another `<image>` tag inside `<images>` tag.
- Here I am using `mysql:5.7` image.
- Remember `mysql` expects that you pass some environment variable.
- With `<env>` tag you can set the environment variable.
- If you `docker:start` now, you will run both containers.
# Health Check

---

## Run Command

- How to add `RUN` instruction when using `in-memory` Dockerfile.

```xml
<build>
    ...
    <runCmds>
        <run>apk add --no-cache curl</run>
    </runCmds>
    <cmd>java -jar maven/${project.name}-${project.version}.jar</cmd>
</build>
```
- `<runCmds>` can have multiple `<run>` tag.
- Here we are installing `curl`.

## Restart Policy

- If you want to restart policies for your images, you can use `<restartPolicy>` tag.
```xml
<run>
    <restartPolicy>
        <name>on-failure</name>
        <retry>3</retry>
    </restartPolicy>
    ...
</run> 
```
- `<restartPolicy>` can is added inside of `<run>` tag.
- It has `<name>` and `<retry>` children tag.
- `<name>` take the type of policy you want to enforce.
- `<retry>` how many times you want to restart your image, when `on-failure` policy is used.

## Health check

- We can add a health check in our image as well.
- We use `<healthCheck>` tag, which has few child tags.

```xml
<build>
    ...
    <healthCheck>
        <interval>10s</interval>
        <timeout>5s</timeout>
        <startPeriod>10s</startPeriod>
        <retries>3</retry>
        <cmd>curl --fail http://localhost:8080/test/status-5xx || exit 1</cmd>
    </healthCheck>
</build>
```

- We use `<healthCheck>` tag inside `<build>` tag.
- It has few children tags, which represents the option health check supports.
- `/test/status-5xx` will throw Internal Server Error after 6th request.
-  So for time being image will be healthy and after couple of minutes it will be tagged as unhealthy.
# Restart Policies

&nbsp;

---


- Restart policies is used to control whether the containers starts automatically when they exit, or even when Docker restarts.
- Restart policies tells Docker how to react when a container shuts down.
- A restart policy only takes effect after a container **starts successfully**.
- Starting successfully means that the container is **up for at least 10 seconds** and Docker has started monitoring it.
- This prevents a container which does not start at all from going into a restart loop.
- By using the `--restart` option with the docker run command you can specify a restart policy.
- Types of restart policies
  - `no`
  - `always`
  - `no-failure`
  - `unless-stopped`

## `no`

- The no policy is the default restart policy and simply will not restart a container under any case.

## `always`

- If we wanted the container to be restarted no matter what exit code the command has, we can use the `always` restart policy.
- The restart policy will always restart the container.
- Whenever the Docker service is restarted, containers using the always policy will also be restarted.

## `on-failure`

- Restart your container whenever it exits with a non-zero exit status and not restart otherwise.
- You can optionally provide a number of times for Docker to attempt to restart the container.
- `--restart=on-failure:@number`
- Docker uses a delay between restarting the container, to prevent flood-like protection.
- This is an increasing delay; it starts with the value of 100 milliseconds, then Docker will double the previous delay.
- If a container is successfully restarted, the delay is reset to the default value of 100 milliseconds

## `unless-stopped`

- Again, similar to always, if we want the container to be restarted regardless of the exit code, we can use `unless-stopped.`
- It will restart the container regardless of the exit status, but do not start it on daemon startup if the container has been put to a stopped state before.
- If you are using the app from [Simple Spring App](https://github.com/amantuladhar/DockerKubernetesFiles/tree/dockerfile-initial), make sure you are in `dockerfile-initial` branch.
- We have couple of REST endpoints in the app
    - `/test/` which kind of hello-world endpoint for us
    -   `/test/status-5xx` which will return status 200 for first 5 times, but after that it will throw exception. Our app will still be running.
    - `/test/exit-1` to exit the app with non-zero status code.
    - `/test/exit-0` to exit the app with zero status code.
    

## Restart Policies in Action

- Let's start our app using `on-failure`
- Here's a [Dockerfile](https://github.com/amantuladhar/DockerKubernetesFiles/blob/master/docker/web-basic) content
- Run the image with `--restart` option.
```bash
docker run -d -p 9090:8080 --restart\=on-failure amantuladhar/doc-kub-ws:web-basic
```
```bash
IMAGE                                 STATUS              
amantuladhar/doc-kub-ws:web-basic     Up About a minute
```

- Let's call `/test/exit-1`, which will end the process with non zero exit code.
```bash
IMAGE                                 STATUS                     
amantuladhar/doc-kub-ws:web-basic     Restarting (1) 1 second ago
```

- Now let's call `/test/exit-0`, which will end the process with zero exit code.
- If you list the running container, you won't see it now.

## Update restart policies of running container

- `docker update --restart=new-policies @id/@name`
- Where `@id/@name` is of container

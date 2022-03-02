# Health Check

&nbsp;

---

## What is HEALTHCHECK
- The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working. 
- There could be a scenario where our application process is still running, but may not respond to our request.
- HEALTHCHECK instruction helps us to identify this issue.
- We can have multiple HEALTHCHECK instruction in our Dockerfile but only last one will take an effect.
- When a container has a HEALTHCHECK specified, it has a health status in addition to its normal status. 

> Note: Kubernetes doesn't support this HEALTHCHECK instruction. Kubernetes has its own way to checking if containers are healthy.


## HEALTHCHECK
- The HEALTHCHECK instruction can be used in two forms.
  - HEALTHCHECK [OPTIONS] CMD command. Which checks container health by running a command inside the container.
  - HEALTHCHECK NONE. This will disable any health check inherited from the base image.
- If you are using the app from Simple Spring App, make sure you are in dockerfile-initial branch.
- We have couple of REST endpoints in the app
  - `/test/` which kind of hello-world endpoint for us 
  - `/test/status-5xx` which will return status 200 for first 5 times, but after that it will throw exception. Our app will still be running.
  - `/test/exit-1` to exit the app with non-zero status code.
  - `/test/exit-0` to exit the app with zero status code.
- Let's add HEALTHCHECK in our image.
- `HEALTHCHECK CMD curl --fail http://localhost:8080/test || exit 1`
- We are making a curl request to our app and if it fails we are exiting our app with status code 1.
```bash
FROM openjdk:8-jre-alpine
WORKDIR /myApp
EXPOSE 8080
RUN apk add --no-cache curl
COPY ["onlyweb/target/*.jar", "./app.jar"]
CMD ["java", "-jar", "app.jar"]
HEALTHCHECK CMD curl --fail http://localhost:8080/test || exit 1
```

- Let's build and run this image.
```bash
IMAGE                                 STATUS                    
amantuladhar/doc-kub-ws:web-basic     Up XX seconds (healthy)
```

- We will play around with HEALTHCHECK more, but first let's learn about different options HEALTHCHECK supports. 

## --interval
- --interval=@duration
- Default duration time is 30s
- This configures time HEALTHCHECK needs to wait before it runs next HEALTHCHECK CMD.

## --timeout
- --timeout=@duration
- Default timeout is 30s
- This configures the time it should take a HEALTHCHECK CMD to finish.
- If a single CMD run takes longer than timeout seconds then the check is considered to have failed.

## --retries
- --retries=@numberOfRetries
- Default value for retry is 3.
- This configures how many times HEALTHCHECK needs to fail before it determines out container is unhealthy.

## --start-period
- --start-period=@duration
- Default value for start period duration is 0s.
- With is option we can configure time it will take for app to run.
- If we run pre-mature HEALTHCHECK our app might not have initialized and it may result in our container be in unhealthy state.
- Basically it will run our first HEALTHCHECK CMD after time specified.

&nbsp;

---

## Playing with HEALTHCHECK
- Let's update our HEALTHCHECK instruction.
```bash
FROM openjdk:8-jre-alpine
WORKDIR myapp/
COPY ["onlyweb/target/*.jar", "app.jar"]
EXPOSE 8080
RUN apk add --no-cache curl
CMD ["java", "-jar", "app.jar"]
HEALTHCHECK  --start-period=10s \
             --interval=5s \
             --timeout=2s  \
             --retries=3 \
             CMD curl --fail http://localhost:8080/test/status-5xx || exit 1
```

- Build you image and run it. And keep an eye on health status.
- Remember status-5xx will return status 200 for first 5 calls
- So for a minute or so our container health will be healthy.
- But because the HEALTHCHECK is called frequently, and for our app at exactly 6th call it will start to fail.
- On a 6th call it won't flag our container as unhealthy as we defined retries.
- Docker makes sure that three consecutive failure happens before it flags the container as unhealthy.

```bash
IMAGE                                  CREATED             STATUS                          
amantuladhar/doc-kub-ws:web-basic      10 seconds ago      Up 10 seconds (health: starting)
```

```bash
IMAGE                                 CREATED             STATUS                 
amantuladhar/doc-kub-ws:web-basic     24 seconds ago      Up 24 seconds (healthy)
```
```bash
IMAGE                                 CREATED             STATUS                  
amantuladhar/doc-kub-ws:web-basic     2 minutes ago       Up 2 minutes (unhealthy)
```
> Complete dockerfile for with health check web-healthcheck [web-healthcheck](https://github.com/amantuladhar/DockerKubernetesFiles/blob/master/docker/web-healthcheck)

# Environment Variable

---

- Most of the apps that we develop nowadays depends on some kind of environment variables / configuration files.
- Using configuration files on containers are a bit tricky.
- If we push the configuration with container itself, we need to update / build the image every time we change the container.
- Often times some configuration properties are secret. We don't want some properties to be passed on carelessly.
- Containers normally use environment variables to get configuration.
- Kubernetes also supports passing environment variables to **containers**.

> Kubernetes doesn't allow Pod level environment. Environment variables are set on container level.

- We cannot modify the environment variable for a container once it is set.
- We can dispose the current container and re-create a new one.
- If you think about the solution above, it make sense right!
- Containers are supposed to be immutable, if you change configuration of one container other replicas may not have same configuration.
- At least until you make changes to all of them.

## Example
- Let's create a Deployment that sets environment variable to container.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # metadata
spec:
  # replica & matchLabel selector
  template:
    metadata:
      # metadata
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:environment   #1
          name: web
          env:                     #2
            - name: GREETING       #3
              value: Namaste       #4
            - name: NAME           #3
              value: Folks!!       #4
          # probe properties
```
- `#1` - We are using new image i.e docker-kubernetes:environment. I have modified the endpoint so that it changes the message based on environment variables.
    - **GREETING** - Default is Hello
    - **NAME** - Default is Fellas!!
- `#2` - We use `env` properties to set the environment variable to container.
- `#3` - Name of environment variable you want to set
- `#4` - Value of environment variable you want to set

## Calling Endpoint
```bash
➜ http $(minikube service web --url)/test
HTTP/1.1 200
Content-Type: application/json;charset=UTF-8
Date: Tue, 26 Feb 2019 05:47:37 GMT
Transfer-Encoding: chunked

{
    "app.version": "v1-web",
    "host.address": "172.17.0.7",
    "message": "Namaste Folks!!"
}
```

## Updating environment variable

- Note: To change the environment variable of container, either you need to restart the container
- You can update the environment variable easily with command below, but it will restart the container.

```bash
kubectl set env deployment web GREETING="Adios"
```
- `kubectl set env @resource @name @env_var=@env_value`
-   If you want to unset environment variable

```bash
kubectl set env deployment web GREETING-
```
- If you use environment variable and use dash `-` it will unset the environment variable.
# Liveness Probe

---

- We learned how to add health check and restart policies in docker.
- I also mentioned that Kubernetes as of now doesn't support these health check.
- It cannot read the status set by docker and take action upon it.
- For this reason, Kubernetes has concept of probes. Which is very simple but very powerful concept.
- We will look into `liveness` probes for now.
- Kubernetes can check if a container is still alive through `liveness` probes.
- You can specify a `liveness` probe for each container in the pod’s specification.
- Kubernetes will periodically execute the probe and restart the container if the probe fails.

## Types of `liveness probe`

- We can configure `liveness` probe for a container using one of the three method.
    - **HTTP GET probe**  
      - This performs HTTP GET request on the container’s IP address, a port and path you specify.
      - If the probe receives a response code of **2xx** or **3xx**, the probe is considered successful.
      - If the server returns an error response code or if it doesn’t respond at all, the probe is considered a failure.
      - Container whose `liveness` probe failed, will be restarted by Kubernetes.

    - **TCP Socket probe**
        - This configuration tries to open a TCP connection to the specified port of the container.
        - If the connection is established successfully, the probe is successful.
        - Otherwise, the container is restarted.
        
    - **Exec probe**   
        - This executes an arbitrary command inside the container and checks the command’s exit status code.
        - If the status code is 0, the probe is successful.
        - All other codes are considered failures.


## Adding Liveness Probe

- Let's see how we can add liveness probe in our app.
- We will use `httpGet` probe in our case.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: v1-web
  labels:
    version: v1
    env: prod
spec:
  containers:
    - image: amantuladhar/docker-kubernetes:v1-web
      name: v1-web
      livenessProbe:
        httpGet:
          path: /test
          port: 8080
      ports:
        - containerPort: 8080
```

## Liveness Probe in Action

- Let's create a resource using above configuration.
- If you list the pods you will see our pod in running status.

```bash
NAME     READY   STATUS    RESTARTS   AGE   VERSION   ENV
v1-web   1/1     Running   0          32s   v1        prod
```
- If you call `localhost:9090/test/exit-1` you will exit our app.
- Kubernetes when they run `liveness` probe doesn't respond, will tag pod status to `Error`.
```bash
NAME     READY   STATUS   RESTARTS   AGE   VERSION   ENV
v1-web   0/1     Error    0          21s   v1        prod
```
- Then it will restart your pod.
```bash
NAME     READY   STATUS    RESTARTS   AGE    VERSION   ENV
v1-web   1/1     Running   1          101s   v1        prod
```
- Notice `RESTARTS` column. The value indicates how many times your app restarted.

## Liveness Probe Options

- `initialDelaySeconds`: Number of seconds after the container has started before liveness probes are initiated.
- `periodSeconds`: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
- `timeoutSeconds`: Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1.
- `failureThreshold`: When a Pod starts and the probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the Pod. Defaults to 3. Minimum value is 1.
- `successThreshold`: (Mostly used in readiness probe) we will discuss this later.

```yaml
livenessProbe:
    httpGet:
      path: /test/
      port: 8080
    initialDelaySeconds: 10
    periodSeconds: 60
    timeoutSeconds: 5
    failureThreshold: 3
```
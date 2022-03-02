# Readiness Probe

---

## Why do we need `readiness probe`?

- We learned how to use `ReplicaSet`, with that we also learned how to increase number of running Pods.
- With `Service` we learned how to expose them, with single IP. `Service` allows us to access our Pods without knowing it's actual IP.
- But when does the `Service` starts to send a traffic to Pod when we scale up your app?

## Understanding the problem.

- Create a `ReplicaSet` that runs only 1 copy of our app at the moment.
- Run this command, this will call you app endpoint every second.

```bash
while true ; do curl http://192.168.99.106:30000/test ; echo "\\n" ; sleep 1 ; done;
```

- Instead of IP above, use your own IP.
- Now scale up your app. Run 3 replicas.
- You will start to get some failed request.

```bash
{"message":"Hello Fellas!!!","host.address":"172.17.0.5","app.version":"v1-web"}

curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused
curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused
curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused


{"message":"Hello Fellas!!!","host.address":"172.17.0.5","app.version":"v1-web"}
{"message":"Hello Fellas!!!","host.address":"172.17.0.5","app.version":"v1-web"}

curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused
curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused
curl: (7) Failed to connect to 192.168.99.106 port 30000: Connection refused


{"message":"Hello Fellas!!!","host.address":"172.17.0.7","app.version":"v1-web"}
{"message":"Hello Fellas!!!","host.address":"172.17.0.7","app.version":"v1-web"}
{"message":"Hello Fellas!!!","host.address":"172.17.0.6","app.version":"v1-web"}
{"message":"Hello Fellas!!!","host.address":"172.17.0.6","app.version":"v1-web"}
{"message":"Hello Fellas!!!","host.address":"172.17.0.5","app.version":"v1-web"}
```

- Why is this happening?
- What happens right now is that, `Service` starts to send the traffic to a Pod as soon as Pod is started.
- Kubernetes at the moment doesn't have any idea if our Pod is ready to accept connection.
- To help with this problem we use `readiness` probe.

## What is `readiness` probe?

- We learned the `liveness` probe before.
- With help of `liveness` probe we were able to restart the Pods that were unhealthy.
- With the help of `readiness` probe, Kubernetes will be able to know if Pods are ready to accept connection.
- Like `liveness`, `readiness` probe is also executed periodically.
- The result determines if Pods is ready or not.

## Types of `readiness` probe

- Like `liveness` probe, we have three ways
    - `Exec`
    - `HTTP GET`
    - `TCP Socket`


## Add `readiness` probe

- To add a `readiness` probe, we can add it using `readinessProbe` properties.
```yaml
# ReplicaSet Definition
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  ...
spec:
  replicas: 3
  ...
  spec:
    containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: v1-web-con
          readinessProbe:            # 1
            httpGet:                 # 2
              path: /test/           # 3
              port: 8080             # 4
            initialDelaySeconds: 10  # 5
          ... 
```
- `#1` we use `readinessProbe` property to add probe in our Pod template.
- `#2` we are using `httpGet` way of defining probe
- `#3` Which path to ping
- `#4` Which port to expose
- `#5` How many seconds do we delay before sending first probe request.

## `Readiness` probe options

- Like `liveness` probe we have few options we can configure
    - `initialDelaySeconds`: Number of seconds after the container has started before liveness probes are initiated.
    - `periodSeconds`: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
    - `timeoutSeconds`: Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1.
    - `failureThreshold`: When a Pod starts and the probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the Pod. Defaults to 3. Minimum value is 1.
    - `successThreshold`: Minimum consecutive successes for the probe to be considered successful after having failed

```yaml
readinessProbe:
    httpGet:
      path: /test/
      port: 8080
    initialDelaySeconds: 10
    successThreshold: 1
    periodSeconds: 60
    timeoutSeconds: 5
    failureThreshold: 3
```

## `Readiness` probe in action

- Create a `ReplicaSet` that runs only 1 copy of our app at the moment.
- Run this command, this will call you app endpoint every second.

```bash
while true ; do curl http://192.168.99.106:30000/test ; echo "\\n" ; sleep 1 ; done;
```
- Instead of IP above, use your own IP.
- Now scale up your app. Run 3 replicas.
- You will only see response from other Pod when they are ready.
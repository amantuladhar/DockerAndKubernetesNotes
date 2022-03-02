# Service

---

- Now we know how to manage Pods using `ReplicaSet`.
- You know that `ReplicaSet` make sure that desired number of Pods are always alive.
- One very important thing we should remember is that Pods are disposable, they should be easily replaceable.
- Another thing we need to remember is that, there can be multiple Pods that serves the same content.
- How do we keep tract of Pods IP. Pods can scale up / down, how to know new IP of pods when they are added.
- If Pods is unhealthy, they are replaced. They may or may not get the same IP.

## What is Service

- Service is a resource that makes a single, constant point of entry to a group of pods providing the same service.
- Each service is assigned a IP and port that never change while the service exists.
- Using service IP we can communicate with Pods that service manages.
- Service also manages Pods using label selector.

## Service Definition

- To create a Service, you create a resource with `kind: Service`
```yaml
apiVersion: v1
kind: Service            # 1
metadata:
  name: v1-web-svc       # 2
spec:
  type: NodePort         # 3
  ports:
    - port: 80           # 4
      targetPort: 8080   # 5
      nodePort: 30000    # 6
  selector:              # 7
    env: prod
    version: v1 
```
- `#1`: We are defining the type of resource to `Service`.
- `#3`: Type of Service. Default is `ClusterIP` but if we use `ClusterIP` it be visible only inside cluster.
    - `NodePort` will expose set of Pod it manages to external client.
- `#4`: Expose external endpoint to port 80. Type `NodePort` will ignore this properties.
- `#5`: `targetPort` is the port container serves the app.
- `#6`: `nodePort` will use this IP to expose the service to external client. It must be range from 30000-32767.
- `#7`: This is the label selector that is used by Service to select the Pods.
- `minikube` doesn't support `LoadBalancer` as of now.

## Create a Service

- You can create a service by using `kubectl create -f svc.yaml`.

```
                 +----------------------------------+
+--------+       |          +-----------+           |
|External+----------------->|  Service  |           |
| Client |       |          +-----+-----+           |
+--------+       |                |                 |
                 |    +------------------------+    |
                 |    |           |            |    |
                 |  +-v-+       +-v-+        +-v-+  |
                 |  |Pod|       |Pod|        |Pod|  |
                 |  +---+       +---+        +---+  |
                 +----------------------------------+
```

## List Service

- To list the services in cluster you use `kubectl get svc`, where `svc` is short form for service.

## Access the Pods externally

- Now that service is running, we can access our app from outside.
- If you try `localhost:30000/test` it will not work. Why?
- Remember Kubernetes is running inside minikube cluster, which is running inside Virtual Machine.
- We can use `minikube service @service_name` to easily access your services through your browser.
    - `minikube ip` echos the minikube IP.
    - `minikube service @service_name --url` echos the IP with port instead of opening browser.
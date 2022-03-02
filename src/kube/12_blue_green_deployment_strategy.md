# Blue Green Deployment

---


Blue Green Deployment

> Kubernetes doesn't have (as of now) `strategy: BlueGreen` like we had `RollingUpdate` and `Recreate`.

## How blue-green deployment strategy works?

- If we want to upgrade the instances of **V1 (Blue),** we create exactly the same number of instances of **V2 (Green)** alongside **V1 (Blue)**.
- Initially **Service** that we are using to expose our app will be pointing to **V1 (Blue)**.
- After testing that the **V2 (Green)** meets all the requirements the traffic is switched from **V1 (Blue)** to **V2 (Green).**
- This technique reduces downtime by running two version of app at the same time.
    - But only one version of app is live to user.
    - For our example, Blue is currently live, and Green is idle.
    - But after upgrade Green will be live, and Blue will be idle. (Later on Blue will be deleted)


### Advantages

- With this strategy we can have instant roll back, as we still have old version of app running in background.
- Unlike Rolling Update we don't run two version of app once.

### Disadvantages

- Blue Green deployment strategy might be expensive. When updating the app we use double resource.

## Blue Green Stages

### Initial State
```
                       +-------------+
                       |             |
               +-------+   Service   |
               |       |             |
               |       +-------------+
               |
               |
   |BLUE|      v
+---------------------------+
|   +-------------------+   |
|   |Pod_1||Pod_1||Pod_1|   |
|   --------------------+   |
| -------------+  +-------+ |
| |Deployment_1|  |Replica| |
| -------------+  | Set_1 | |
|                 +-------+ |
+---------------------------+
```

- Initially we will have V1 app running, for now let's say Blue.

### Rollout Update
```
                       +--------------+
                       |              |
               +-------+    Service   |
               |       |              |
               |       +--------------+
               |
               |
   |BLUE|      v                    |GREEN|
+---------------------------+     +---------------------------+
|   +-------------------+   |     |   +-------------------+   |
|   |Pod_1||Pod_1||Pod_1|   |     |   |Pod_2||Pod_2||Pod_2|   |
|   --------------------+   |     |   --------------------+   |
|                           |     |                           |
|                           |     |                           |
| -------------+  +-------+ |     | -------------+  +-------+ |
| |Deployment_1|  |Replica| |     | |Deployment_2|  |Replica| |
| -------------+  | Set_1 | |     | -------------+  | Set_2 | |
|                 +-------+ |     |                 +-------+ |
+---------------------------+     +---------------------------+

```
- When rollout starts we create our V2 (Green), ideally we will create same number of Pods replicas.
- Notice, we are creating totally new `Deployment` here.

### Switch to new version

```
                       +--------------+
                       |              |
                       |    Service   +------+
                       |              |      |
                       +--------------+      |
                                             |
                                             |
   |BLUE|                            |GREEN| v
+---------------------------+     +---------------------------+
|   +-------------------+   |     |   +-------------------+   |
|   |Pod_1||Pod_1||Pod_1|   |     |   |Pod_2||Pod_2||Pod_2|   |
|   --------------------+   |     |   --------------------+   |
|                           |     |                           |
|                           |     |                           |
| -------------+  +-------+ |     | -------------+  +-------+ |
| |Deployment_1|  |Replica| |     | |Deployment_2|  |Replica| |
| -------------+  | Set_1 | |     | -------------+  | Set_2 | |
|                 +-------+ |     |                 +-------+ |
+---------------------------+     +---------------------------+
```
- To make our new version of app **V2 Green** live, we will have to point `Service` to newly created Pod.
- For Kubernetes `Service` we just change the label selector.

## Clean up or roll back

- At this stage, we can either cleanup resources or we can roll back to our previous version.
- If we think new version of app is stable, we can delete the old Pods / Deployments
- But if we need to do a roll back, it is very easy. Just change the Service label selector again.

## Blue Green Deployment With Kubernetes

### Deploy the V1 App

- Create a `Deployment` with following configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v1
  labels:
    version: v1
    env: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      env: prod
      version: v1
  template:
    metadata:
      name: web-v1
      labels:
        version: v1
        env: prod
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: web-v1
          #probes

```
- Notice how I am appending `-v1` to Deployment, ReplicaSet and Pods name. This is important because we don't want to replace the existing `Deployment` resource.

### Create a Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30000
  selector:
    env: prod
    version: v1
```

- Service at the moment is selecting Pods with `version: v1` label.

### Update to V2 App

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v2
  labels:
    version: v2
    env: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      env: prod
      version: v2
  template:
    metadata:
      name: web-v2
      labels:
        version: v2
        env: prod
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v2-web
          name: web-v2
          #probes
```
- We create a new `Deployment` \***\-v2.**
- **ReplicaSet / Pods** labels are also suffixed with **-v2**
- At the moment the Pods created by our new Deployment is not live. Service is still pointing to old version of the app.
- After all the new version Pods are ready, we can switch the Service selector.

### Change the `Service` selector

- You can change the Service selector using multiple technique.
- I will use `kubectl patch`

```bash
kubectl patch service web --patch '{"spec": {"selector": {"version": "v2"}}}'
```

- After this you will see all the traffic are now redirected to new version.

### Cleanup / Rollback Update

- If you want to cleanup you can delete the old `Deployment`
- If you want to Rollback the update, you can use above command and change selector to `v1`

```bash
kubectl patch service web --patch '{"spec": {"selector": {"version": "v1"}}}'
```
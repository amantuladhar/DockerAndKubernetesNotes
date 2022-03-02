# Failed Deployment

---

- When upgrading you application to new version, Kubernetes might not be able to deploy the latest version of your application.
- This can happen due to multiple reasons
  - Insufficient resource
  - Readiness Probe failures
  - Image Pull Errors etc.
- Kubernetes can automatically detect if upgrade revision is bad

## `spec.minReadySeconds`
- `spec.minReadySeconds` is an optional field that specifies the minimum number of seconds for which a newly created Pod should be ready.
- Ready meaning any of its containers should not crash.
- This **defaults** to 0 i.e. the Pod will be considered available as soon as it is ready.
- If `Deployment` has only readiness probe, it will mark Pod as available as soon as its `readiness` probe succeeds.
- With `minReadySeconds` we can take our `readiness` probe one step further.
- If our `readiness` probe starts failing before `minReadySeconds` , the rollout of new version will be blocked.

## `spec.progressDeadlineSeconds`

- We can configure when Kubernetes marks Deployment as failed by property`spec.progressDeadlineSeconds`
- `spec.progressDeadlineSeconds` is an optional field that specifies the number of seconds you want to wait for your Deployment to progress before the system reports back that the Deployment has failed.
- If specified, this field needs to be greater than `spec.minReadySeconds`

> In the future, once automatic rollback will be implemented, the deployment controller will roll back a Deployment as soon as it observes such a condition.

## Rollout v1 app

- Let's start with this `Deployment` file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  #metadata
spec:
  minReadySeconds: 20
  progressDeadlineSeconds: 30
  strategy:
    type: RollingUpdate # Default
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  # replicas, selector
  template:
    #metadata
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: web
          readinessProbe:
            httpGet:
              path: /test/
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 1
          #liveness probe & ports
```
- `minReadySeconds` is set to 20 seconds.
    - That means even if our `readiness` probe succeeds before 20 seconds deployment is not considered successful.
    - Kubernetes will execute `readiness` probe multiple times within `minReadySecond` time frame.
    - If within that time period `readiness` probe fails deployment is considered unsuccessful.
    - Remember Pod **Ready** status will be updated by `readiness` probe but `Deployment` has its own status to check if deployment process was success or failure.
- `progressDeadlineSeconds` is set to 30 seconds.
    - Kubernetes will wait for 30 seconds before it sets the deployment process status.
- `maxSurge` is set to 1  
    - Relative to `replicas` number, Kubernetes will create only 1 extra Pod.
- `maxUnavailable` is set to 0.
    - Kubernetes will always have desired `replicas` running.
- Without setting `maxSurge` 1 and `maxUnavailable` 0, we are asking Kubernetes to create a new Pod and only delete existing Pod when new one is ready.
- `readinessProbe` to check if our Pod is ready. We are running our probe every second.

## Rollout v2

- To roll out v2, only thing we need to do is update the image the value.
- But for our test we will update `readiness` probe as well.
- We will point `readiness` probe to `/test/status-5xx` endpoint.
- This endpoint will return status **200** for first 5 calls, but after that **500**. (Trying to emulate situation where app run for a while and after some time it starts to crash).

```yaml
# other props
spec:
  # other props
  template:
    #other props
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v2-web
          name: web
          readinessProbe:
            httpGet:
              path: /test/status-5xx
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 1
          #other props
```

- Of course in real world we won't change `readiness` probe path, but for this test we are changing it.

## Rollout Status

- After we apply our update, Kubernetes will start deployment process.
- It will create a new Pod with new version of our app.

```bash
NAME                       READY   STATUS    RESTARTS   AGE
pod/web-5577ff7d67-fp6ht   0/1     Running   0          1m
pod/web-697456ff84-29tm8   1/1     Running   0          17m
pod/web-697456ff84-jhd2c   1/1     Running   0          17m
pod/web-697456ff84-vvtkd   1/1     Running   0          17m
```

- Initially it won't be **Ready.**
- But after your app starts for a brief period of moment, new Pod will have status Ready. (Remember for first 5 calls our endpoint works.)

```bash
NAME                       READY   STATUS    RESTARTS   AGE
pod/web-5577ff7d67-fp6ht   1/1     Running   0          2m
pod/web-697456ff84-29tm8   1/1     Running   0          23m
pod/web-697456ff84-jhd2c   1/1     Running   0          23m
pod/web-697456ff84-vvtkd   1/1     Running   0          23m
```

- If we don't define `minReadySeconds` at this point, Kubernetes will terminate one of the older Pod and create a new one.
- But because we did and time we defined on `minReadySeconds` has still not passed, readiness probes continues to check if probe is ready.
- Because of the way we configured our readiness probe, our probe will fail before the `minReadySeconds`
- After that Pod Ready status will be changed.
```bash
NAME                       READY   STATUS    RESTARTS   AGE
pod/web-5577ff7d67-fp6ht   0/1     Running   0          5m
pod/web-697456ff84-29tm8   1/1     Running   0          24m
pod/web-697456ff84-jhd2c   1/1     Running   0          24m
pod/web-697456ff84-vvtkd   1/1     Running   0          24m 
```

- After `progressDeadlineSeconds` is passed, Kubernetes will set the status of deployment. For our case it failed as Pod is not Ready.
- If we were running `kubectl rollout status deployment web` we will see following log.

```bash
➜ k rollout status deployment web
Waiting for deployment "web" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "web" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "web" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "web" rollout to finish: 1 out of 3 new replicas have been updated...
error: deployment "web" exceeded its progress deadline
```
# Rolling Update Deployment Strategy

---
- Rolling Deployment is a process of replacing currently running instances of our application with newer ones.
- When using this deployment process, there will be a point of time when two version of our app will be running.

```
                  +-------+      +-------+
                  |Replica|---+->+ Pod_1 |
     +----------->| Set_1 |   |  +-------+
     |            +-------+   |
     |                        |  +-------+
+----+-----+                  +->+ Pod_1 |
|Deployment|                  |  +-------+
+----------+                  |
                              |  +-------+
                              +->+ Pod_1 |
                                 +-------+

```
- This is the initial state for our `v1` app. Because we said we needed 3 replicas.
- After the update, Kubernetes will start you update with rolling update strategy.

## How Rolling Update is done?

```
                                 +-------+
                              +->+ Pod_1 |
                              |  +-------+
                              |
                  +-------+   |  +-------+
                  |Replica+----->+ Pod_1 |
     +----------->+ Set_1 |   |  +-------+
     |            +-------+   |
     |                        |  +-------+
+----+-----+                  +->+ Pod_1 |
|Deployment|                     +-------+
+----+-----+
     |            +-------+
     |            |Replica|      +-------+
     +----------->+ Set_2 +----->+ Pod_2 | |Running|!Ready|
                  +-------+      +-------+

```

- After we start update process, Kubernetes will create a second `ReplicaSet`.
- It will also spin up one new `Pod`. This can be configured, which we will discuss later.
- At the moment, there are 4 pods **running** but only three are in **ready** state. `Pod_2` was just created, and it takes time to be **ready**.
- After `Pod_2` is ready, it will terminate one of the `Pod_1` and create a new `Pod_2`

```
                                 +-------+
                              +->+ Pod_1 |
                              |  +-------+
                              |
                  +-------+   |  +-------+
                  |Replica+----->+ Pod_1 |
     +----------->+ Set_1 |   |  +-------+
     |            +-------+   |
     |                        |  +-------+
+----+-----+                  +->+ |---| |  |Terminating|
|Deployment|                     +-------+
+----+-----+
     |            +-------+
     |            |Replica|      +-------+
     +----------->+ Set_2 +---+->+ Pod_2 |  |Running|Ready|
                  +-------+   |  +-------+
                              |
                              |  +-------+
                              +->+ Pod_2 |  |Running|!Ready|
                                 +-------+

```

- After new `Pod_2` is ready, it will terminate another `Pod_1` and then continue like this until new `ReplicaSet` desired state is not met.

> When using Rolling Update strategy, user won't see any downtime.
> Also two version of the app will run during update process

```
                  +-------+
                  |Replica|
     +----------->+ Set_1 |
     |            +-------+
     |
+----+-----+                     +-------+
|Deployment|                  +->+ Pod_2 |
+----+-----+                  |  +-------+
     |            +-------+   |
     |            |Replica|   |  +-------+
     +----------->+ Set_2 +----->+ Pod_2 |
                  +-------+   |  +-------+
                              |
                              |  +-------+
                              +->+ Pod_2 |
                                 +-------+
```

- This will be the final state of our update process.
- From the diagram, you can see that `Deployment` doesn't delete the old `ReplicaSet`.
- But having old `ReplicaSets` may not be ideal.
- We can configure how many `ReplicaSet` to save using `revisionHistoryLimit` property on the Deployment resource.
- It **defaults** to two, so normally only the current and the previous revision are shown in the history and only the current and the previous ReplicaSet are preserved.
- Older ReplicaSets are deleted automatically.

## Status of update process

- We have a `kubectl rollout` command which has lots of helper function that helps us to interact with `Deployment` resource.
- One of them is to see the status of `Deployment` update process.
- `kubectl rollout status @resource_type @resource_name`

```bash
kubectl rollout status deployment web
```

- This will log the phases Kubernetes is going through when updating our app.

## Controlling Rollout Speed

- You can control the speed at which Pods are replaced using two Kubernetes properties.
- If you inspect the `Deployment` property you can see default value Kubernetes sets for these properties
```bash
➜ k describe deployments.apps web              
Name:                   web
Namespace:              default
Labels:                 env=prod
                        version=v1
Annotations:            deployment.kubernetes.io/revision: 5
...
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
... 
```
- You can see we have two property

## `maxUnavailable`

- Specifies the maximum number of Pods that can be unavailable during the update process.
- The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%).
- The absolute number is calculated from percentage by rounding down.
- The value cannot be 0 if `maxSurge` is 0.
- The default value is 25%.

## `maxSurge`

- Specifies the maximum number of Pods that can be created over the desired number of Pods.
- The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%).
- The value cannot be 0 if `maxUnavailable` is 0.
- The absolute number is calculated from the percentage by rounding up.
- The default value is 25%.

## Setting the values
- All of these properties are defined under `spec.strategy.rollingUpdates`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
# metadata
spec:
  strategy:
    type: RollingUpdate # Default
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  # other props
```



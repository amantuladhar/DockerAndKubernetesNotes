# Recreate Deployment Strategy

---

- Recreate strategy is a simple approach of Deployment.
- If we use this strategy, Kubernetes will delete all existing version of Pods, only then it will create a new one.
- For a brief period of time our server will not be able to handle request.

## Setting strategy

- Setting `Recreate` strategy in Kubernetes is easy.
- Just set `spec.strategy.type` to `Recreate`

## How Recreate strategy works

- When we deploy our first version, Kubernetes will make sure it matches our desired state.

```bash
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
+----------+
```

- When we start our upgrade process, Kubernetes will stop all our container.
- It will delete the Pods that are running old version of app.

```bash
                                 +-------+
                              +->+ |-----| |Terminating|
                              |  +-------+
                              |
                  +-------+   |  +-------+
                  |Replica+----->+ |---| | |Terminating|
     +----------->+ Set_1 |   |  +-------+
     |            +-------+   |
     |                        |  +-------+
+----+-----+                  +->+ |-----| |Terminating|
|Deployment|                     +-------+
+----------+

```

- After all old Pods are deleted, Kubernetes will start a new Pod with out v2 app.

```bash
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

- After this our deployment process is finished.

> Note: Kubernetes creates a new ReplicaSet for this deployment strategy as well. This is so that we can easily roll back to previous version.


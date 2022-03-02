# Understanding Kubernetes

---


## Why do we need Kubernetes?

- We learned `docker`, `docker-compose`. We know how to containerize our web app. Why do we need to learn yet another tool?
- Note that `docker` and `docker-compose` runs on single host.
- With help of Kubernetes we can run our app in multi-host environment.
- With Kubernetes, we can easily deploy and run your software components without having to know about the actual servers underneath.
- It doesn't matter if it has single host, or it has multiple-host or clusters.
- When deploying a multi-component application through Kubernetes, it selects a server for each component, deploys it.
- It also makes it easy to find and communicate with all the other components of your application.
- Kubernetes enables you to run your applications on thousands of computer nodes as if all those nodes were a single, enormous computer.
- It abstracts away the underlying infrastructure and, by doing so, simplifies development, deployment.
- Kubernetes can be thought of as an operating system for the cluster

## Kubernetes Architecture As Simple As Possible

- Kubernetes' architecture in its simplest form has two most important component.
  - **Kubernetes Master**
  - **Kubernetes Worker**

```
                     Cloud
                    +----------------------+
                    |   +----------------+ |
User+-----------------> |   Kubernetes   | |
                    |   |     Master     | |
                    |   +-------+--------+ |
                    |           |          |
                    |           |          |
                    |   +-------v--------+ |
                    |   |   Kubernetes   | |
                    |   |     Worker     | |
                    |   +----------------+ |
                    +----------------------+
```

## Kubernetes Master

- As a user we always communicate to `Kubernetes Master`. We will use `kubectl` tool to interact with `Kubernetes Master`.
- `Kubernetes Master` (Control Plane) has a subcomponents
    - `Kubernetes API Server`, which you and the other Control Plane components communicate with
    - `Scheduler`, which schedules your apps (assigns a worker node to each deployable component of your application)
    - `Controller Manager`, which performs cluster-level functions, such as replicating components, keeping track of worker nodes, handling node failures, and so on
    - `etcd`, a reliable distributed data store that persistently stores the cluster configuration.


```
+-------------------------------------+
|                   +--------------+  |
|                   |   Scheduler  |  |
|                   +--------------+  |
|                                     |
|  +-----------+    +--------------+  |
|  |   API     |    |   Controller |  |
|  |   Server  |    |   Manager    |  |
|  +-----------+    +--------------+  |
|                                     |
|                   +--------------+  |
|                   |   etcd       |  |
|                   +--------------+  |
+-------------------------------------+
```

## Kubernetes Worker

- `Kubernetes Worker` the run your containerized applications.
- The task of running, monitoring, and providing services to your applications is done `Workers`.
- `Kubernetes Worker` have different components.
    - `Container Runtime`: Docker, rkt, or another container runtime, which runs your containers.
    - `Kubelet`, which talks to the `API server` and manages containers on its node.
    - `Kubernetes Service Proxy (kube-proxy)`, which load-balances network traffic between application components.


```
+------------------------------------------------+
|   +------------+          +-----------------+  |
|   |   kublet   |          |    kube-proxy   |  |
|   +------------+          +-----------------+  |
|                                                |
|           +-----------------------+            |
|           |    Container Runtime  |            |
|           +-----------------------+            |
+------------------------------------------------+
```

## Nodes

- Within a cloud we can have lots of nodes, which may or may not be on same machine.
- It is a part of Kubernetes to abstract out these details.
- We always communicate with `Master` which may be on same node as `Worker` or may be on different.

```
Cloud
+------------------------------------+
|                    +----------+    |
|                    |  Worker  |    |
|                    |   Node   |    |
|                    +----------+    |
|                                    |
|  +-----------+     +----------+    |
|  |   Master  |     |  Worker  |    |
|  |    Node   |     |   Node   |    |
|  +-----------+     +----------+    |
|                                    |
|                    +----------+    |
|                    |  Worker  |    |
|                    |   Node   |    |
|                    +----------+    |
+------------------------------------+
```
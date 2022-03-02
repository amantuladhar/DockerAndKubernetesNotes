# Creating Deployment

---

- We learned few type of Kubernetes Resource
  - Service
  - Pod
  - ReplicaSet
- While Service is a higher-level concept we be creating in the future, Pods and ReplicaSet are considered lower-level concept.
- `Deployment` doesn't manage our app, but rather `Deployment` creates a ReplicaSet which in turns manages Pods.
- `Deployment` is a way to define the states of our application declaratively.
- With help of `Deployment` we can easily deploy our application, plus it is super easy to update them.
- `Deployment` shines when we are about to upgrade the app to new version.
- Out of the box it supports rolling updates, but other strategies are also easily achievable. We will discuss deployment strategies later.

```
+----------+          +----------+
|Deployment+--------->+ReplicaSet|
+----------+          +------+---+
                             |
                             |
  +------------+-------------+
  |            |             |
+-v-+        +-v-+         +-v-+
|Pod|        |Pod|         |Pod|
+---+        +---+         +---+

```

## Creating Deployment

- Creating `Deployment` is same as creating `ReplicaSet`
- If you have `ReplicaSet` config file from before, you can easily make it `Deployment` resource.
- Actually we can even delete some properties. We will delete it later, and explain why we can delete them.
- For now let's replace the property `kind: Service` to `kind: Deployment`.
- And there you have it. You just created your `Deployment` resource.

```yaml
apiVersion: apps/v1
kind: Deployment       # kind: ReplicaSet
metadata:
  name: web
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
      name: web
      labels:
        version: v1
        env: prod
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: web
          # Liveness & readiness probe
          ports:
            - containerPort: 8080
```

- If you create a resource using `kubectrl create -f deployment.yaml` you will create your resources.
- If you list the resources, you can see `Deployment` will create `ReplicaSet`, `Pods`.
- Number of Pods also match the `replicas: @number.`

## Deployment doesn't create `Service`

- If you listed the resources `kubectl get all` you may have noticed, we don't have our Service running.
- To access Pods we need to create a `Service`.

## Rolling out Update

## Upgrade the app (`V2`)

```yaml
containers:
  - image: amantuladhar/docker-kubernetes:v2-web
    name: web
```

- Now let's create update start the update process
- You can use `kubectl apply -f deployment.yaml`
- By default `Deployment` favors rolling update.

> Because Deployment is not tied to specific version of app, we can delete the label version label selector from our yaml file.
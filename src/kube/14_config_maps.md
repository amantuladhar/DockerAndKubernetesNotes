# Config Maps

---

- Setting environment variables to container template is one option to send configuration to container.
- But if configuration differ from environment to environment like DEV, QA, PROD then setting configuration value on `env` may not be a good idea.
- Kubernetes has a resource called ConfigMaps which treats configuration as a separate object.
- So each environment can have same objects, but different values.

## ConfigMaps YAML

- Let's create simple ConfigMaps that stores our GREETING and NAME environment variable value.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web
data:
  GREETING: Namaste
  NAME: Friends!!! 
```

- As you can see creating ConfigMap is simple.
- You set `kind` as `ConfigMap`.
- You set name of `ConfigMap` on `metadata` section.
- On `data` root node, you add your properties values.
- It is just a key value pair.
- Here we are setting **GREETING** as Namaste and NAME as Friends!!!

## Creating ConfigMap

- Creating a `ConfigMap` is simple too, you just use your handy `kubectl create` command.
```bash
kubectl create -f configmap.yaml
```

## 

Using ConfigMap with `env` property

- If you want to get specific environment variable value using ConfigMap you can use valueFrom property instead of value property.

```yaml
apiVersion: apps/v1
kind: Deployment
# metadata
spec:
  # replicas & selector
  template:
    # metadata
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:environment
          name: web
          env:
            - name: GREETING
              valueFrom:
                configMapKeyRef:
                  name: web # Name of ConfigMaps
                  key: GREETING
            - name: NAME
              valueFrom:
                configMapKeyRef:
                  name: web # Name of ConfigMaps
                  key: NAME
          # probes & ports
```
- In above file, you can see we are using `valueFrom` property instead of `value`.
- Using `configMapKeyRef` tells Kubernetes to search in `ConfigMap`.
- `configMapKeyRef.name` states the name of the `ConfigMap` resource.
- `configMapKeyRef.key` states which key to look for in defined resource.
- Run the app using above configuration and call your endpoint

```bash
➜  http $(minikube service web --url)/test
HTTP/1.1 200
Content-Type: application/json;charset=UTF-8
Date: Wed, 27 Feb 2019 02:00:50 GMT
Transfer-Encoding: chunked

{
    "app.version": "v1-web",
    "host.address": "172.17.0.6",
    "message": "Namaste Friends!!!"
}
```

- Now our message has **Namaste Friends!!!.**
- That's the value we have in our `ConfigMaps`

## Updating ConfigMap

> Note: Updating ConfigMap doesn't update the value a running container has.
> 
> If you change value of ConfigMap, two similar container might be in inconsistent state.

- You can update the `ConfigMap` values using `kubectl patch` command.

```bash
kubectl patch configmaps web --patch '{"data": {"GREETING": "Yo"}}'
```

## Import All values from ConfigMap

- While previous method gave us power to pull in value from ConfigMap.
- It was troublesome, if we have let's say 20 properties, we have to use `valueFrom` 20 times.
- Kubernetes has another property `envFrom` which allows you to import all values from `ConfigMaps`

```yaml
apiVersion: apps/v1
kind: Deployment
# metadata
spec:
  # replicas & selector
  template:
    # metadata:
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:environment
          name: web
          envFrom:
            - configMapRef:
                name: web
          # probe and port
```

- In above example, we are using `envFrom` instead of `env`.
- When we use `envFrom` property, we import all properties from that resource. (But there is limitation)
- We can also use `prefix` keyword if you want to prefix your configuration properties with something. `env.prefix`
- If any of your `ConfigMap` property has dash `-`. That won't be imported.
- Because environment variable with dash `-` are invalid.
- Kubernetes doesn't do any post-processing for you in this case.

> There one more way to load the ConfigMaps i.e. using volumes
>
> We don't know how to mount the volumes yet, so this will be skipped for now.
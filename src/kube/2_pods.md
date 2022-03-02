# Pods

---

- Pods are the central, most important, concept in Kubernetes.
- Pod represents the basic building block in Kubernetes and a place where containers are run.
- When using Kubernetes you always deploy and operate on a pod of containers instead of deploying containers individually.
- Pods can run more than one container, but it is good practice running one container per pod.

> - We need to remember that Kubernetes manages Pods not containers.
> - So Kubernetes cannot scale individual containers, instead, it scales whole pods.

## Points when running multiple container

- Pods with multiple containers, are always run on a **single worker node** — it never spans multiple worker nodes.
- A pod of containers allows you to run closely related processes together and provide them with (almost) the same environment as if they were all running in a single container, while keeping them somewhat isolated.
- One thing to stress here is that because containers in a pod run in the same Network namespace, they share the same IP address and port space.
- This means processes running in containers of the same pod need to take care not to bind to the same port numbers or they’ll run into port conflicts.

## 

Pods Configuration
- I am using this [kub-pod-initial](https://github.com/amantuladhar/DockerKubernetesFiles/tree/kub-pod-initial) branch for this chapter.
- We can create a Pods using command line but let's do it using `yaml` file.

```yaml
apiVersion: v1                                      # 1
kind: Pod                                           # 2
metadata:                                           # 3
  name: v1-web                                      # 4
spec:                                               # 5
  containers:                                       # 6
    - image: amantuladhar/docker-kubernetes:v1-web  # 7
      name: v1-web                                  # 8
      ports:                                        # 9
        - containerPort: 8080
```
- `#1` `apiVersion` conforms which version to Kubernetes API to use.
- `#2` `kind` describes what kind of Kubernetes Resources we want to define.
- `#3` `metadata` is a place where you put information about the pods
- `#4` `name` Setting name for pod.
- `#5` `spec` contains a pods specification. Specification like container template, volumes etc.
- `#6` `containers` list of container you want Pods to have
- `#7` `image` defines which image to use.
- `#8` `name` name of container.
- `#9` `ports` List of port container listens to.
- Specifying ports in the pod definition is purely informational.
- Omitting them has no effect on whether clients can connect to the pod through the port.
- But it makes sense to define the ports explicitly so that everyone using your cluster can quickly see what ports each pod exposes.

## Creating pods

- To create a pod we have a simple command.
- `kubectl create -f pods.xml`

```bash
kubectl create -f pods.yaml
pod/v1-web created
```

## List Pods

- To list the running pods, we can use
- `kubectl get pods` command.

```bash
➜ kubectl get pods           
NAME     READY   STATUS    RESTARTS   AGE
v1-web   1/1     Running   0          21m
```

## View logs

- Viewing logs is simple too `kubectl logs @pod_name`
- `kubectl logs v1-web`
- If your pod includes multiple containers, you have to explicitly specify the container name by including the `-c <container name>`.

## Access your app

- We ran our Pod, if you check the status it states it is running as well.
- But how do we access our app?
- Note: Pods are not meant to be accessed directly. We create some higher labels resources that abstracts these detail.
- For debugging purposes, Kubernetes lets us access our Pods directly using **port-forwarding** technique.
- `kubectl port-forwarding @pod_name @host_port:@container_pod`

```bash
➜ kubectl port-forward v1-web 9090:8080

Forwarding from 127.0.0.1:9090 -> 8080
Forwarding from [::1]:9090 -> 8080
```

- You need to keep this command running if you want to access your pod.
- If you visit `localhost:9090/test`, you will be able to access you app.

```bash
➜ http localhost:9090/test
HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Date: Sun, 17 Feb 2019 20:41:22 GMT
Transfer-Encoding: chunked

{
    "app.version": "v1-web",
    "host.address": "172.17.0.5",
    "message": "Hello Fellas!!!"
}
```

## Deleting the pods

- Deleting the pods is simple too.
- `kubectl delete pods @pod_name`

```bash
➜ kubectl delete pods v1-web           
pod "v1-web" deleted
```

## Pod Labels

- Labels are simply a tag given to pods which may help us identify the specific pods.
- As our application grows number of pods increases, we need to categorize them so that we can manage them efficiently.
- Labels are a simple, yet incredibly powerful feature in Kubernetes.
- Labels can be added to pods, but also for all other resources Kubernetes has.
- A label is an arbitrary key-value pair you attach to a resource.
- It can be utilized when selecting resources using label selectors.
- Resources are filtered based on whether they include the label specified in the selector.
- A resource can have more than one label, as long as the keys of those labels are unique within that resource.
- You usually attach labels to resources when you create them, but you can also add additional labels or even modify the values of existing labels later without having to recreate the resource.
- Let's see how we can add them in `yaml`
- Labels are added in `metadata` section using `labels` property.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: v1-web
  labels:
    version: v1
    env: dev
spec:
  containers:
    - image: amantuladhar/docker-kubernetes:v1-web
      name: v1-web
      ports:
        - containerPort: 8080
```

- You can create a resource using `kubectl create -f pods.yaml`.

## See Pods labels

- You can see pods labels in multiple ways

## `--show-labels`

- If you want to see all labels use `--show-labels` option when using `kubectl get pods`.
- `kubectl get pods --show-labels`.

```bash
➜ kubectl get pods --show-labels
NAME     READY   STATUS    RESTARTS   AGE     LABELS
v1-web   1/1     Running   0          2m38s   env=dev,version=v1
```

## using `-L` option

- While `--show-lables` options works fine.
- What if we have lots of labels. Not that I am saying you should add many labels.
- We can use `-L` options with the list of labels you want to see.
- `-L label_key1,label_key2`

```bash
➜ kubectl get pods -L version,env
NAME     READY   STATUS    RESTARTS   AGE    VERSION   ENV
v1-web   1/1     Running   0          6m2s   v1        dev
```

## Adding new label

- If you want to change/add the labels for pads you can do it by stopping the pod and creating again.
- But let's see how we can add new labels to running container
- We use `kubectl label @resource @resource_name @label_key=@label_value`
- For us `@resource` is **pods**.

```bash
➜ kubectl label pods v1-web value=new
pod/v1-web labeled
```

- List the pods with labels and see the new value.

```bash
➜ kubectl get pods --show-labels     
NAME     READY   STATUS    RESTARTS   AGE   LABELS
v1-web   1/1     Running   0          14m   env=prod,value=new,version=v1
```

## Updating labels

- If we want to override the existing label, we can use the same command like above but we need to append `--overwrite` option as well.
- We use `kubectl label @resource @resource_name @label_key=@label_value --overwrite`
- Let's change `env to dev` again.

```bash
➜ kubectl label pods v1-web env=dev --overwrite
pod/v1-web labeled
```
- List the labels

```bash
➜ kubectl get pods --show-labels               
NAME     READY   STATUS    RESTARTS   AGE   LABELS
v1-web   1/1     Running   0          16m   env=dev,value=new,version=v1
```

## List the pods using labels

- Listing pods using a label selector.
- We use `-l` to add label criteria when listing the pods.

## Selecting pods with specific label and specific value
```bash
➜ kubectl get pods -l env=dev    
NAME     READY   STATUS    RESTARTS   AGE
v1-web   1/1     Running   0          51m
```

## Selecting pods that have specific label

- We can also select pods that have specific label, ignoring value it has.
```bash
➜ kubectl get pods -l env    
NAME     READY   STATUS    RESTARTS   AGE
v1-web   1/1     Running   0          53m 
```

## Selecting pods that don't have specific label

```bash
➜ kubectl get pods -l '!env'
No resources found.
```

## Deleting pods using label selectors

- We already know how to delete a specific pod with name.
- If we want to mass delete pods, we can use label selector criteria `-l` option.

```bash
➜ kubectl delete pods -l env
pod "v1-web" deleted
```

## Deleting all pods at once

- We can delete all pods at once using `kubectl delete pods --all`

## Deleting all resource

- We haven't learned about other type of resources, but if we want to delete all resources at once we can use.
- `kubectl delete all --all`.
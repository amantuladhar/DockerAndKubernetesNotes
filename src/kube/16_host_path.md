# Host Path

---

- We learned how to deploy our Stateless app using Kubernetes.
- But we may need to deploy the app that has state, that accesses the database to save the records.
- Making a Stateful app run using Kubernetes is a bit tricky, solely because our app can run in different nodes.
- Kubernetes out of the box has different types of volumes, but based on cloud provider you use you will have way to save your data.

## Kubernetes Host Path Volume

- Kubernetes has a simple volume type called hostPath which gives you persistence storage.
- But hostPath has one big limitation i.e. hostPath volume mounts a file or directory from the host node’s filesystem into your Pod.
- The main point here is that, hostPath volume type mounts the volumes to node.
- Our cluster can have multiple nodes, and two nodes doesn't share a filesystem.
- Pods with identical configuration may behave differently on different nodes due to different files on the nodes
- Because we are developing our app locally we have to use hostPath, and it doesn't affect us. We are running only one node.

## Using Host Path
```yaml
apiVersion: apps/v1
kind: Deployment
# metadata
spec:
  #replicas & metadata
  template:
    # metadata
    spec:
      volumes:                #1
        - name: volume-name   #2
          hostPath:           #3
            path: /absolute/host/path   #4
      containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: web-co
          volumeMounts:                 #5
              - name: volume-name       #6
                mountPath: /containerPath/    #7
```

- `#1`In above Deployment definition, we are using `volumes` properties to define the volumes we want to use. (This is not a proper way to define volume, but let's go step by step)
- `#2` We are giving name to our volume so that we can use it later.
- `#3` `hostPath` property. This is the type of volume we are using. For local development we are using `hostPath` but this will be provider specific volume type.
- `#4` Child property of `hostPath`. This is an absolute path which points which folder from host to mount.
    - Remember for `minikube` host path is inside VM.
    - [Here's a `minikube` documentation](https://github.com/kubernetes/minikube/blob/master/docs/host_folder_mount.md) to mount your actual host path to `minikube` VM, then to mount that volume to Kubernetes.
    - TLDR; use `minikube mount actual/host/path:/minikube/vm/path`
- `#5` Using `volumeMounts` property we can specify which volumes our container needs to mount.
- `#6` Using `name` property we specify the name of the volume we want to mount.
    - For your purposes it needs to match `#2`
- `#7` `mountPath` take the path inside the container. This is the place where container will access external data.

> We are using `Deployment` here. If you just want to create a `Pod` you remember, everything below from `template` property is basically Pod definition.

- After you create a resource, we can go inside the Pod and play around with it.
- Let's create a file inside the container and see if that file is available on our host.
- And let's delete the Pod and see if new Pod can see that file.

```bash
kubectl create -f hostPath.yaml
```

- Creating file inside Pod

```bash
# Get inside Pod
➜ kubectl exec -it web-dep-89fd5db9-897dr sh

# Change directory to path where we mounted the volume
/myApp # cd /containerPath/

# Create a file with some text
/containerPath # echo "Very important data" >> file.txt

# Check if file exist (inside container)
/containerPath # ls
file.txt
```

- Check if file is visible in your host path. You will see the file if everything went well.
- Now, restart the container and see if file exist.
```bash
kubectl delete pod --all 
```
- This will delete all the Pods.
- But Deployment will spawn new Pod immediately.
- Go inside new Pod and see if file exist.

```bash
# Getting inside new Pod
➜ kubectl exec -it web-dep-89fd5db9-689sw sh

# Checking if file exist
/myApp # ls /containerPath/
file.txt

# Checking the content of file
/myApp # cat /containerPath/file.txt
Very important data
```

- We learned how we can easily mount volume to Kubernetes by using hostPath.
- Make sure if you use hostPath on production you know what you are doing.
- There may be a scenario where we need this, but for general purposes like database this is not a solution.
- Next we will learn how we can improve this example and what problems this solution has.
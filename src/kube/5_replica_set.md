# ReplicaSet

---

- We now know how to create pods, i.e. manually.
- But in real world we never want to create a pod manually.
- We always use higher level construct to manage pods.
- One of the higher level construct that we use to manage pods is `ReplicaSet`. (Although we will use one more higher
  level construct that manages `ReplicaSet` later).
- A `ReplicaSet` ensures the pods it manages are always kept running.
- If the pod disappears for any reason, `ReplicaSet` notices the missing pod and creates a replacement pod.

## How does `ReplicaSets` work?

- `ReplicaSet` constantly monitors the list of running pods.
- Label selector is used to filter the pods that `ReplicaSet` manages.
- `ReplicaSet` makes sure the actual number of pods it manages always matches the desired number.
- If too few such pods are running, it creates new replicas from a pod template.
- If too many such pods are running, it removes the excess replicas.

# Defining `ReplicaSet` `yaml` file

```yaml
apiVersion: apps/v1             # 1                           
kind: ReplicaSet                # 2                      
metadata: # 3               
  name: v1-web                  # 4                    
  labels: # 5               
    version: v1                 # 5                     
    env: prod                   # 5                   
spec: # 6           
  replicas: 3                   # 6                   
  selector: # 8                 
    matchLabels: # 9                   
      version: v1               # 10                      
      env: prod                 # 10                  
  template:
    # After this it just a Pod template we had before                                                                   
    metadata:
      name: v1-web
      labels: # 11                                                
        version: v1             # 12                                                      
        env: prod               # 12                                                    
    spec:
      containers:
        - image: amantuladhar/docker-kubernetes:v1-web
          name: v1-web
          livenessProbe:
            httpGet:
              path: /test/
              port: 8080
          ports:
            - containerPort: 8080
```

- `#1`: `ReplicaSet` are defined under `apiVersion` **apps/v1**.
- `#2`: We are setting our resource type to `ReplicaSet`.
- `#3`: Defines the metadata information for our resource.
- `#4`: We are setting the name for our `ReplicaSet`.
- `#5`: `labels` includes label added for a `ReplicaSet`.
- `#6`: `spec` includes the specification for our resource.
- `#7`: `replicas` tells ReplicaSet how many copies of pods we want. ReplicaSet make sure that specified number of pods
  are always running.
- `#8`: `selector` will have list of labels that `ReplicaSet` will target. These are the labels that determines which
  pods are managed by `ReplicaSet`. This selector must somehow match labels defined in `#12`, `#13`.
- `#9`: `matchLabels` indicate that we are trying to value label key with label value.
    - We also have `matchExpression` which is more expressive. (More on this later).
- `template` is the template for the pod our ReplicaSet manages. When starting the ReplicaSet or adding new Pods, it
  will use this template to start the Pod.
    - Notice: All properties below `template` is same as Pod `yaml` file we defined before.

## Create `ReplicaSet`

- To create a `ReplicaSet` we simply use `kubectl create -f replicaset.yaml`.

```bash
➜ kubectl create -f replicaset.yaml
replicaset.apps/v1-web created 
```

## List `ReplicaSet`.

- To list the `ReplicaSet` we use same command like before but different resource.
- `kubectl get replicaset` or `kubectl get rs`.
- `rs` is the short form for `replicaset`.

```bash
➜ kubectl get replicaset           
NAME     DESIRED   CURRENT   READY   AGE
v1-web   3         3         3       42s

➜ kubectl get rs        
NAME     DESIRED   CURRENT   READY   AGE
v1-web   3         3         3       44s
```

## List the pods

- If you list the running pods, you will see you have three pods running.

```bash
➜ kubectl get po
NAME           READY   STATUS    RESTARTS   AGE
v1-web-8s5zw   1/1     Running   0          3m36s
v1-web-r9pkw   1/1     Running   0          3m36s
v1-web-xk9sk   1/1     Running   0          3m36s
```

- `po` is short form for `pods`.

## Scaling our App

## Scale Up

- If we ever want to scale up our application, it will be very easy now.
- There are many ways you can scale your pods.
    - `kubectl patch`
    - `kubectl apply`
    - `kubectl edit`
    - `kubectl scale`

- We already know how to use first three options from previous section.
- Let's use fourth one

### `kubectl scale`

- `kubectl scale rs --replicas=@number @rs_name`
- Using this command you can quickly change the number of replicas you want to run.

```dockerfile
➜ kubectl scale rs --replicas=10 v1-web
```

- List the pod again, you will see number of running pods will increase.

```bash
➜ kubectl get po
NAME           READY   STATUS    RESTARTS   AGE
v1-web-8s5zw   1/1     Running   0          6m48s
v1-web-fdnwf   1/1     Running   0          8s
v1-web-l6dbh   1/1     Running   0          8s
v1-web-lxkp7   1/1     Running   0          8s
v1-web-n6rfh   1/1     Running   0          8s
v1-web-q9zdq   1/1     Running   0          8s
v1-web-r9pkw   1/1     Running   0          6m48s
v1-web-s455s   1/1     Running   0          8s
v1-web-xctpn   1/1     Running   0          8s
v1-web-xk9sk   1/1     Running   0          6m48s
```

## Scale Down

- Scaling down is super easy as well.
- Just update the replicas value. Set it to 3 for now.

```bash
➜ kubectl scale rs --replicas=3 v1-web
```

## ReplicaSet `matchExpression`

- We saw how `matchLabels` works in previous example.
- But `ReplicaSet` can have more expressive label selector than just matching key and value pairs.

```yaml
selector:
  matchExpressions:
    - key: @label_key
      operator: @operator_value
      values:
        - @label_value
        - @label_value 
```

- When we use `matchExpressions` we have few option that we can tweak.
- We can have multiple `matchExpression` as well.
- `key` will take a `label` key.
- `operator` will take one of the pre-defined operators
    - `In`: Label’s value must match one of the specified values.
    - `NotIn`: Label’s value must not match any of the specified values.
    - `Exists`: Pod must include a label with the specified key. When using this operator, you shouldn’t specify the
      values field.
    - `DoesNotExist`: Pod must not include a label with the specified key. The values property must not be specified.
- `values`: If we use `In` or `NotIn` list of values to look for.
- Let's generate the scenario where we can work on.
- First run the `ReplicaSet` yaml file you had before.
- You will end up with three Pods. Override one of Pod label **env=prod to env=dev**
- The Pod whose label was change is now no longer managed by our ReplicaSet.
- Now ReplicaSet will create a new Pod to match the desired state.
- If you list the running Pod you will see we have 4 pods. (3 managed by ReplicaSet, 1 not)

```bash
➜ kubectl get pods -L version,env                    
NAME           READY   STATUS    RESTARTS   AGE   VERSION   ENV
v1-web-8s5zw   1/1     Running   0          31m   v1        dev
v1-web-njbt9   1/1     Running   0          5s    v1        prod
v1-web-r9pkw   1/1     Running   0          31m   v1        prod
v1-web-xk9sk   1/1     Running   0          31m   v1        prod 
```

- How do we tell `ReplicaSet` to manage Pods with label env=dev and env=prod.
- How to not create extra Pod?

## Using Operator

- Let's update our `ReplicaSet` label selector to

```yaml
selector:
  matchExpressions:
    - key: env
      operator: In
      values:
        - dev
        - prod 
```

- Using `In` we can define that ReplicaSet can look for either value `dev` or `prod` for label `env`.
- If we update one of the pod label env to dev now, it won't create new Pod. As updated Pod is still managed
  by `ReplicaSet` and replicas count match the desired state.

```bash
➜ kubectl label po v1-web-6bcgx env=dev --overwrite
pod/v1-web-6bcgx labeled
```

- Now list the pods.

```bash
NAME           READY   STATUS    RESTARTS   AGE     VERSION   ENV
v1-web-6bcgx   1/1     Running   0          6m22s   v1        dev
v1-web-mkk79   1/1     Running   0          6m22s   v1        prod
v1-web-sxl59   1/1     Running   0          6m22s   v1        prod 
```
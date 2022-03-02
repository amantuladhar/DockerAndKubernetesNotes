# Updating Kubernetes Resource

---

## Using `kubectl edit`

You can also use `kubectl edit rs @rs_name` and edit the **yaml** template
```bash
kubectl edit rs v1-web
```

## Using `kubectl patch`

- We can use `kubectl patch` to update the template of running resource.
- You can pass either `JSON` or `YAML` when patching the resource.
- `kubectl patch @resource_type @resource_name --patch @template_subset`

```bash
k patch pods v1-web --patch '{"metadata": {"labels": {"version": "v2"}}}'
```

- In above command `--patch` takes a Kubernetes configuration file.
- We can pass `yaml` like structure to `--patch` but I don't think will look good on a command. Plus the spacing and tabs will be tricky.
- We are using `JSON` to send the patch.
- We define properties we want to override. Notice that it is a subset of a full Kubernetes config.
- When patching like this, we need to structure our data from **root** just like we do in config file.

## Using `kubectl apply`

- To update **Resource Template** for running resource as well.
- To update the template for running resource you use `kubectl apply`.
- Change you label `env to prod` at the moment.

```bash
➜ kubectl apply -f pods.yaml           
pod/v1-web configured
```

- List the labels again and you will see labels are changed.

```bash
➜ kubectl get pods -L version,env
NAME     READY   STATUS    RESTARTS   AGE     VERSION   ENV
v1-web   1/1     Running   0          8m51s   v1        prod
```
# Rolling Back Update

---

- From the previous section, you saw updating app with the new version was so easy.
- You just update the image you want to use and Kubernetes does most of the work for us.
- But what if the new version of app we just updated has some bug.
- What is bug turned out to be severe. We need to roll back the updates as fast as possible. We can't let user use unstable app.
- With Kubernetes, rolling back is just as easy.

## Using `kubectl rollout undo` to roll back update

- We can use `kubectl rollout undo @resource_type @resource_name` syntax to undo the update process.
- It is very easy to do so.

## History of `Deployment` rollout

- You can easily see history revision history
- `kubectl rollout history @resource_type @resource_name`
```bash
➜ kubectl rollout history deployment web                                    
deployment.extensions/web 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none> 
```

- If we do one little extra step, when creating / rolling out the update, we can see some values in `CHANGE-CAUSE` column.
- If when creating / updating we use `--record` option. It will record the command we used to make an update.
- The command is then visible in `CHANGE-CAUSE` column.
```bash
➜ kubectl rollout history deployment web                                             
deployment.extensions/web 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         kubectl set image deployment web web=amantuladhar/docker-kubernetes:v1-web --record=true 
```

## Getting more detail on history

- You can see more detail of particular revision by using `--revision=@revision_number` option.
```bash
➜ kubectl rollout history deployment web --revision 4
deployment.extensions/web with revision #4
Pod Template:
  Labels:       env=prod
        pod-template-hash=6445f5654d
        version=v1
  Annotations:  kubernetes.io/change-cause: kubectl set image deployment web web=amantuladhar/docker-kubernetes:v1-web --record=true
  Containers:
   web:
    Image:      amantuladhar/docker-kubernetes:v1-web
    Port:       8080/TCP
    Host Port:  0/TCP
    Liveness:   http-get http://:8080/test/ delay=10s timeout=1s period=30s #success=1 #failure=3
    Readiness:  http-get http://:8080/test/ delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none> 
```

## Rolling Back to specific revision

- We can control number of revision history to retain using `revisionHistoryLimit` property.
- If there are multiple revision we can jump back to particular revision as well
- `kubectl rollout undo @resource_type @resource_name --to-revision=@revision_number`

```bash
➜ kubectl rollout undo deployment web --to-revision=2
deployment.extensions/web rolled back
```
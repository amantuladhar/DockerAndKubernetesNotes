# Running additional command inside container

## Attach to running container terminal

### `-it` option

- `-it` option will attach container terminal to our host
- After that we can issue command directly to container.
- After that every command you issue will be inside the container.
- (Play around with some command)
- If you want to get out of the container you can **exit** the terminal.
- If default command in image is not **shell**, we can pass shell as `@argument`.
- `docker run -it busybox /bin/sh`
    

### `docker container exec`

- `docker container exec` is used to execute command inside running container.
- `docker container exec @id @command`
- But we can use same option here `-it` and pass in **shell** as command. (Which is default for `busybox`)
- So `docker container exec -it @id` will attach container terminal to host.
- If you run `ps aux` inside the container, you can see `sleep 5000` is a running process.

    
```bash
➜ docker container exec -it @id
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 sleep 5000
    9 root      0:00 /bin/sh
   16 root      0:00 ps aux

```
---

## Attach when starting `stopped` container

### `docker start -ia @name/@id`

- If you want to attach the terminal, the option is bit different i.e `-ia`

# Docker Volume

&nbsp;

---

- Volumes are directories (or files) that are outside of the default Union File System and exist as normal directories and files on the host filesystem.

## Why do we need volume?

- To understand why we need volumes lets go back to simple image `busybox`.
- `docker run -it busybox`
    - Create a directory and add a file. `touch test.txt`
    - Run new container with same image, list the files and you won't see the file you created.
    - Why not run same container? If we run same container we will still see that file.
    - Remember container are ephemeral and disposable.
    - We should not depend on starting same container.
    
- How do we persist changes, so that when we run new container we see that file?

## Named Volume

- The most direct way is declare a volume at run-time with the `-v @name:@path` flag.
- `@name` is name of the volume.
- `@path` is the path inside container.

## `-v @name:@path`

```bash
docker run -v myVolume:/my-volume --it busybox
```

- This will make the directory `/my-volume` inside the container live outside the UFS and directly accessible on the host.
- Any files that the image held inside the `/my-volume` directory will be copied into the volume.
- If the container path specified doesn't exist docker will create one for you.

## Where can I find the file in host system?

- We can see where docker is storing our file by inspecting the container.
- `docker inspect @container_id`
- If you see **"Mounts"** property, you will see properties like
    - **"Source"** is path in the host
    - **"Destination"** is path in the container
- If you try to navigate to path specified by **"Source"** in you computer, you won't find it. Why?
- For docker that host path is inside Virtual Machine.
- We can also see `docker volume list` to list all volumes.
- As you can see volume name is big hash at the moment

## Manually create a named volume

- To manually create a named volume, you can use `docker volume create` command.
```bash
docker volume create --name @volume\_name
```

## Reattaching same volume

- If you attach a same volume when running new container, you will find all previous files.
```bash
docker run -v myVolume:/my-volume -it busybox

# Create a file inside my-volume directory
> touch my-volume/test.txt

# List content of my-volume directory
> ls my-volume/
test.txt
```
- Running new container with same volume
```bash
docker run -v myVolume:/my-volume -it busybox
# List content of my-volume directory
> ls my-volume/
test.txt
```

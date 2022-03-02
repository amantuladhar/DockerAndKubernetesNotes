# Basic Commands

---

## Running container
### `docker run @image`
- Let's start with simple image hello-world.
- To run that image execute docker run hello-world.
- Here's a output you will get
``` bash
➜ docker run hello-world   
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete 
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
Status: Downloaded newer image for hello-world:latest
	
Hello from Docker!

This message shows that your installation appears to be working correctly.
...
...
```
- If you look at the output you will see that docker does few things for us.
- It will check if the image is available locally. 
- If not, it will be pulled down from the remote repository. 
- It initializes the image's name and resources containers needs like CPU, IP, Memory etc. 
- After that it will run the container.
- When container is started, it will execute a command.
- Command is defined in image itself. We will talk about this later.

## Listing local images
### `docker image list`
- Or docker images
- Lists the images that are available in your local system.
- You can use any version of command you like.
```bash
➜ docker image list                 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              fce289e99eb9        6 weeks ago         1.84kB
```

## Listing container
- When we ran the image with docker run it creates a container. Duh!! it is the definition of container.
- How can you see list of your container?

### `docker container list`
- Or docker ps
- Use any of the command above and you will see, list of running container.
```bash
➜ docker container list 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```

- I don't see our container here, why?
- Because hello-world is a simple image.
- It executes one command and exits, hence container is stopped.

### `--all`
- If you want to see container that are stopped you can use --all option.
- docker container list --all OR docker ps --all
```bash
➜ docker container list --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
bb11cd638c55        hello-world         "/hello"            9 minutes ago       Exited (0) 9 minutes ago                       stoic_shtern

```

- Now we are able to see our container in the list.

## Override default image command
- After docker run @image we can pass @command and @argument it accepts.
- Like docker run @image @command @arguments.
- For this we will use another simple image busybox.
- busybox has simple unix command which we can use.

### `docker run busybox sleep 5000`
- docker run busybox sleep 5000
- This will run a busybox and at the end it will execute the command sleep 5000. 
- This kind of emulates a long running process, as container will not stop unless command exits.
- If you list the container right now (in new terminal of course), you will see status is different.
- It is not Exited.
```bash
➜ docker container list      
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
d7acdce83ad6        busybox             "sleep 5000"        23 seconds ago      Up 21 seconds                           gallant_hodgkin

```

## Stopping running containers
### docker container stop @id / @name
- Or docker stop @id / @name
- To stop the container you can either use name or you can use name of the container.
- If you list the image again (don't forget --all) you will see updated status for the container.
- If you pass space separated @id / @name to stop more than one container.

--- 

## Running container in background
- When we ran docker run busybox sleep 5000, it blocked out terminal.
- If you don't want that to happen, we have an option to run the container in background mode.

### `-d option`
- If you pass -d option, when running the container it will run in background.
- docker run @options @image @command @arguments
- docker run -d busybox sleep 5000
- If you run above command, it will echo container id and resume it's process in background.

## Start the stopped container
### `docker start @name/@id`

- It will start the existing container instead of creating new one.
- Not recommended, as container are supposed to be disposable.

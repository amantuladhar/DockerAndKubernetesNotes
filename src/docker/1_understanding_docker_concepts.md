
# Understanding Docker Concepts

## Why Docker?
- To pack an application with all the dependencies it needs into a single, standardized unit for the deployment.
- Packaging all of this into a complete image guarantees that it is portable.
- It will always run in the same way, no matter what environment it is deployed in.
- Tool that helps in solving the common problems such as installing, distributing, and managing the software.

## Docker images
- Think of an image as a read-only template which is a base foundation for creating container.
- Docker images are executable packages that include everything needed to run an application.
- It includes  the code, a runtime, libraries, environment variables, and configuration files.
- It can also include an application server like Tomcat, Netty and/or application itself.
- Images are created using a series of commands, called instructions.
- Instructions are placed in the Dockerfile which we will learn later.

## Docker Containers
- A running instance of an image is called a container.
- Docker containers are a runtime instance of an image.
- What the image becomes in memory when executed.
- It is an image with state, or a user process.

```
+-----------------------+ +-----------------------+
|       Container       | |       Container       |
|   +---------------+   | |                       |
|   |  Application  |   | |                       |
|   +---------------+   | |                       |
|   +---------------+   | |   +---------------+   |
|   |     Java      |   | |   |     MySQL     |   |
|   +---------------+   | |   +---------------+   |
|   +---------------+   | |   +---------------+   |
|   |    Alpine     |   | |   |    Ubuntu     |   |
|   +---------------+   | |   +---------------+   |
|                       | |                       |
+-----------------------+ +-----------------------+
```

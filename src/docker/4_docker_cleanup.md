# Deleting Container

## Delete all stopped container

- To delete all stopped container, we can use above command.
- Note: it will not delete the container that is running.

## Deleting single container

- To delete the container we use `docker container rm @id/@name`
- If you were following the tutorial you might have one container still running in background. Let's stop and delete this container.


## Deleting Image

## Deleting all dangling images

- To delete all dangling images we can use `docker image prune`
- This will delete all dangling images.
- Dangling image = Images that doesn't have any containers.
    
## Delete single image

- To delete an image we can run `docker image rm @id`.

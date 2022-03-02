# Volume

---


## Maven Plugin Volumes

- To mount the volume we have `<volumes>` tag.
- `<volumes>` tag has children tag `<from>` and `<bind>`.
    - `<from>`: List of `<image>` elements which specify image names or aliases of containers whose volumes should be imported.
    - `<bind>`: List of `<volume>` that maps host folder to container path.


```xml
<images>
    <image>
        <name>docker-kubernetes:${project.version}</name>
        ...
    </image>
    <image>
        <name>mydb:${project.version}</name>
       ...
        <run>
            <volumes>
                <bind>
                    <volume>${project.basedir}/volume/mysql-plugin/:/var/lib/mysql/</volume>
                </bind>
            </volumes>
            ...
        </run>
    </image>
</images>
```

- I am saving mysql data in `${project.basedir}/volume/mysql-plugin/`.
- Start the container, attach pseudo-tty of myDb container and then insert some data to database.
- Stop and run the container again to see if data is saved.
# Union File System

&nbsp;

---

## How Union Filesystem works?
- By using the union filesystem, Docker combines all these layers into a single image entity.
- Filesystem structure of the top layer will merge with the structure of the layer beneath. 
- Files and directories which have the same path as in the previous layer will override those beneath.
```bash
        +-----------------+
        |    FILE_4.txt   |----+
        +-----------------+    |
                               |       +---------------+
                               |       |               |
        +-----------------+    |       |  FILE_1.txt   |
        |    FILE_2.txt   |--------->  |  FILE_2.txt   |
        |    FILE_3.txt   |    |       |  FILE_3.txt   |
        +-----------------+    |       |  FILE_4.txt   |
                               |       |               |
                               |       +---------------+
        +-----------------+    |
        |    FILE_1.txt   |----+
        |    FILE_2.txt   |
        +-----------------+
```
&nbsp;

---

## How are layers connected?
- To maintain the order of layers, Docker utilizes the concept of layer IDs and pointers.
- Each layer contains the ID and a pointer to its parent layer. 
- A layer without a pointer referencing the parent is the first layer in the stack, a base.
- Layers are reusable and cacheable. If same kind of layers are found, docker will reuse it.
- Reusable layers is also a reason why Docker is so lightweight in comparison to full virtual machines, which don't share anything. It is thanks to layers that when you pull an image, you eventually don't have to download all of its filesystem
```bash
            +---------------------------+
            |         Layer Id          |
            |                           |
            |         Parent Id         |
            +------------|--------------+
                         |
            +------------v--------------+
            |         Layer id          |
            |                           |
            |         Parent Id         |
            +------------|--------------+
                         |
            +------------v--------------+
            |         Layer id          |
            |                           |
            |         Parent Id         |
            +------------+--------------+
```

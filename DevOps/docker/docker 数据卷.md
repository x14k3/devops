#devops/docker

**docker的理念：将应用和环境打包成一个镜像**

**数据？如果数据都在容器中，那么删除容器，数据将会丢失！** // 需求：数据持久化
为了很好的实现数据保存和数据共享，Docker提出了Volume这个概念，简单的说就是绕过默认的联合文件系统，而以正常的文件或者目录的形式存在于宿主机上。又被称作数据卷。

*   **数据卷的特点**

1.  数据卷存在于宿主机的文件系统中，独立于容器，和容器的生命周期是分离的。

2.  数据卷可以是目录也可以是文件，容器可以利用数据卷与宿主机进行数据共享，实现了荣期间的数据共享和交换

3.  容器启动初始化时，如果容器使用的镜像包含了数据，这些数据会拷贝到数据卷中。

4.  容器对数据卷的修改是实时进行的。

5.  数据卷的变化不会影响镜像的更新。数据卷是独立于联合文件系统，镜像是基于联合文件系统。镜像与数据卷之间不会相互影响。

## Docker挂载容器数据卷

`bind mounts`、`Volumes`、和`tepfs mounts`三种方式，还有就是共享其他容器的数据卷，其中`tmpfs`是一种基于内存的临时文件系统。`tepfs mounts`数据不会存储在磁盘上。

![](assets/docker%20数据卷/image-20221127212013265.png)

### bind mount

> 将host机器的目录mount到container中。但是bind mount在不同的宿主机系统是不可移植的，比如Windows和Linux的目录结构是不一样的，bind mount所指向的host目录也不能一样。这也是为什么bind mount不能出现在Dockerfile中的原因，因为这样Dockerfile就不可移植了。

`docker run -d --name test -v /home/data(宿主机目录):/data(容器目录)  镜像id`

如果host机器上的目录不存在，docker会自动创建该目录。

如果container中的目录不存在，docker会自动创建该目录。

如果container中的目录已经有内容，那么docker会使用host上的目录将其覆盖掉。

### volume

> volume也是绕过container的文件系统，直接将数据写到host机器上，只是volume是被docker管理的，docker下所有的volume都在host机器上的指定目录下/var/lib/docker/volumes

```bash
Usage:  docker volume COMMAND

Manage volumes

Commands:
  create  [name]    #创建一个数据卷
  inspect [name]    #展示一个或多个数据卷的详细信息
  ls                #列出所有的数据卷
  prune             #移除未使用的数据卷
  rm      [name]    #移除一个或多个数据卷，不能移除被容器使用的数据卷
```

```bash
docker volume create test
docker run --name test2 -dit -v test:/data 3880
```

## Dockerfile中的VOLUME

在Dockerfile中，我们也可以使用VOLUME指令来申明contaienr中的某个目录需要映射到某个volume：

`#Dockerfile VOLUME /foo`

这表示，在docker运行时，docker会创建一个匿名的volume，并将此volume绑定到container的/foo目录中，如果container的/foo目录下已经有内容，则会将内容拷贝的volume中。也即，Dockerfile中的`VOLUME /foo`与`docker run -v /foo alpine`的效果一样。

Dockerfile中的VOLUME使每次运行一个新的container时，都会为其自动创建一个匿名的volume，如果需要在不同container之间共享数据，那么我们依然需要通过`docker run -it -v my-volume:/foo`的方式将/foo中数据存放于指定的my-volume中。

```bash
docker run -d --name test2 --volumes-from test1 mysql:5.7
```

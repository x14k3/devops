# docker 存储驱动

‍

## 1. 存储驱动的作用

Docker 将容器镜像做了分层存储，每个层相当于包含着一条 Dockerfile 的指令。而这些层在磁盘上的存储方式，以及在启动容器时，如何组织这些层，并提供可写层，便是存储驱动的主要作用了。

另外需要注意的是：不同的存储驱动实现不同，性能也有差异，同时使用不同的存储驱动也会导致占用的磁盘空间有所不同。

同时： **由于它们的实现不同，当你修改存储驱动后，可能会导致看不到原有的镜像，容器等，这是正常的，不必担心，切换回原先的驱动即可见。**

## 2. storage-driver

可以执行以下命令来查看 Docker 正在使用的存储驱动：

```bash
docker info --format '{{.Driver}}'
docker info 
```

可以在启动 docker daemon 的时候，通过 `--storage-driver`​ 参数进行指定，也可以在 `/etc/docker/daemon.json`​ 文件中通过 `storage-driver`​ 字段进行配置。

目前对于 Docker 最新版本而言，你有以下几种存储驱动可供选择：

* overlay2
* ​`fuse-overlayfs`​
* ​`btrfs`​
* ​`zfs`​
* ​`aufs`​
* ​`overlay`​
* ​`devicemapper`​
* ​`vfs`​

‍

## 3. backing filesystem

通过`docker info`​ 可以看到的我本机上使用的storage driver是`overlay2`​。此外，还有一个Backing Filesystem它只你本机的文件系统，我的是extfs，`overlay2`​是在extfs之上创建的。你能够使用的storage driver是与你主机上的Backing Filesystem有关的。比如，btrfs只能在backing filesystem为btrfs上的主机上使用。storage driver与Backing Filesystem的匹配关系如下表所示(表来自Docker官网Docker docs)：

```bash
|Storage driver   |Must match backing filesystem |
|-----------------------|---------------------------------------------|
|overlay                |No                                                  |
|aufs                     |No                                                  |
|btrfs                    |Yes                                                 |
|devicemapper   |No                                                  |
|vfs*                     |No                                                   |
|zfs                       |Yes                                                  |
```

‍

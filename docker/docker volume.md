
docker 镜像是以 layer 概念存在的，一层一层的叠加，最终成为我们需要的镜像。但该镜像的每一层都是`ReadOnly`只读的。只有在我们运行容器的时候才会创建读写层。文件系统的隔离使得：

- 容器不再运行时，数据将不会持续存在，数据很难从容器中取出。
- 无法在不同主机之间很好的进行数据迁移。
- 数据写入容器的读写层需要内核提供联合文件系统，这会额外的降低性能。

提供了三种不同的方式将数据挂载到容器中：volume、bind mount、`tmpfs`。

![[docker/assets/d4e5b59483741043a1eff0c84b56cb0d_MD5.png]]


### volume 方式

volume 方式是 docker 中数据持久化的最佳方式。

- docker 默认在主机上会有一个特定的区域（`/var/lib/docker/volumes/`Linux），该区域用来存放 volume。
- 非 docker 进程不应该去修改该区域。
- volume 可以通过`docker volume`进行管理，如创建、删除等操作。
- volume 在生成的时候如果不指定名称，便会随机生成。

```bash
ls /var/lib/docker/volumes
ff664768bfe64e1a8cae4369dd4a2e1929362e29580735480290684e38c8f140
ffa4846b581c1a50a01e7a12a6342ad2aaa442701a35ae56ef2f0e5d7888b22c
```

- volume 在容器停止或删除的时候会继续存在，如需删除需要显示声明。

```bash
docker rm -v <container_id>
docker volume rm <volume_name>
```

#### 相关用例

volume 方式应该是持久化数据的首选方式， 其推荐用例：

- 在多个容器之间共享数据，volume 在容器停止或删除的时候依然存在，如果需要删除需要显示（dockr rm -v…），多个容器可以加载相同的卷。
- 当主机不能保证有一个指定的目录或文件结构时。
- 当需要备份、还原或主机间的数据迁移时。停止容器，备份卷的目录（如`/var/lib/docker/volumes/<volume-name>`。

#### 使用方式

volume 在 docker 中被推荐为首选方式，它与 bind mount 相比，有以下优点：

- 与 bind mount 相比，volume 更容易备份或迁移。
- 可以使用 Docker CLI 命令或 Docker API 来管理。
- volume 在 Linux 和 Windows 容器上都能工作。
- volume 可以在多个容器之间更安全的共享。
- volume 驱动程序允许你在远程主机或云上提供存储、加密或其他功能。
- 新 volume 的内容可以由容器预填充。



**-v/-mount 标志** 
最初，`-v`和`-volume`用于独立的容器，`--mount`用于 swarm server。但 docker 17.06 之后，也可以使用`--mount`。两者的区别在于，`-v`将所有选项组合在一个字段中，`--mount`则将它们分开。

> 新用户应使用`--mount`语法，老用户推荐使用`--mount`。

- `-v/--volume`，由（`:`）分隔的三个字段组成，`<卷名>:<容器路径>:<选项列表>`。选项列表，如：`ro`只读。
- `--mount`，由多个键值对组成，由`,`分隔，每个由一个`<key=<value>>`元组组成。

- `type`，值可以为`bind`，`volume`，`tmpfs`。
- `source`，对于命名卷，是卷名。对于匿名卷，这个字段被省略。可能被指定为`source`或`src`。
- `destination`，文件或目录将被挂载到容器中的路径。可以指定为`destination`，`dst`或`target`。
- `volume-opt`可以多次指定。


**创建管理 volume**

```bash
# 创建一个卷
docker volume create my-vol

# 卷列表
docker volume ls

local               my-vol

# 卷信息
docker volume inspect my-vol
[
    {
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": {},
        "Scope": "local"
    }
]

# 删除卷
docker volume rm my-vol
```

**用卷启动容器** 
下例，将卷`myvol2`挂载到容器`/app/`。`-v`和`--mount`产生的效果相同，但下面命令不能同时执行，会冲突：

```bash
# --mount
# 使用  --mount source=myvol2,target/app,readonly 创建只读的
docker run -d \
  -it \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
  
# -v 
# 使用 -v myvol2:/app:ro 创建只读的
docker run -d \
  -it \
  --name devtest \
  -v myvol2:/app \
  nginx:latest
```

你可以执行`docker inspect devtest`验证卷是否创建并且挂载正确：

```yaml
"Mounts": [
    {
        "Type": "volume",
        "Name": "myvol2",
        "Source": "/var/lib/docker/volumes/myvol2/_data",
        "Destination": "/app",
        "Driver": "local",
        "Mode": "",
        "RW": true,
        "Propagation": ""
    }
],
```

该卷有正确的 Source 和 Destination，可读写。

停止容器和清理卷：

```bash
docker container stop devtest
docker container rm devtest
docker volume rm myvol2
```

> 当启动 service 的时候，如果`Driver`是`local`的时候，则任何容器都不能共享此数据。另外`service`只能使用`--mount`标志。


#### 使用 volume driver

当使用`docker volume create`创建卷或启动尚未创建卷的容器的时候，可以指定卷驱动程序。

下面这个例子，首先创建独立卷时使用 volume driver，然后在启动创建新卷的容器时使用 volume driver。

**初始设置** 
这个例子假定你有 2 个节点，第一个是 docker 主机，可以使用 SSH 连接到第二个节点。

在 docker 主机上安装`vieux/sshfx`插件：

```bash
docker plugin install --grant-all-permissions vieux/sshfs
```

**使用 volume driver 创建卷** 
下面指定了一个 SSH 密码，但如果 2 台主机共享密钥已配置，则可以省略密码。每个 volume driver 可以有多个配置选项，使用`-o`标志指定。

```bash
docker volume create --driver vieux/sshfs \
  -o sshcmd=test@node2:/home/test \
  -o password=testpassword \
  sshvolume
```

**创建容器时使用 volume driver** 
这里需要注意的是，如果需要在命令中使用选项，则必须使用`--mount`，而不是`-v`。

```bash
docker run -d \
  -it \
  --name sshfs-container \
  --volume-driver vieux/sshfs \
  --mount src=sshvolume,target=/app,volume-opt=sshcmd=test@node2:/home/test,volume-opt=password=testpassword \
  nginx:latest
```

### bind mount 方式

通过 bind mount 方式，你可以将你主机上的任何文件或目录（绝对路径）挂载到容器中。

- 挂载的文件或目录可以被任何进程修改，因此有时候容器中修改了该文件或目录将会影响其他进程。
- 如果挂载主机的文件或目录不存在将会自动创建。
- 使用该方式不能通过`docker volume`管理，推荐使用 volume 方式。


#### 相关用例

bind mounts，一般情况在如下方式使用：

- 从主机共享配置文件到容器。默认情况，docker 会绑定类似`/etc/resolv.conf`的文件用于 DNS 的解析。
- 主机与容器共享源代码或构建工具。如，你可以将 Maven`target/`挂载到容器中，并且每次主机上构建 Maven 项目时，容器都可以访问重建的构件。
- 主机的文件或目录结构与容器所需的一致时。


==如果将空文件或目录挂载到容器，容器中的该目录又有文件，那么，这些文件将会被复制到主机上的目录中。
如果将非空的文件或目录挂载到容器，容器中的该目录也有文件，那么，容器中的文件将会被隐藏。==

#### 使用方式

**-v/-mount 标志** 
最初，`-v`和`-volume`用于独立的容器，`--mount`用于 swarm server。但 docker 17.06 之后，也可以使用`--mount`。两者的区别在于，`-v`将所有选项组合在一个字段中，`--mount`则将它们分开。

> 新用户应使用`--mount`语法，老用户推荐使用`--mount`。

- `-v`或`--volume`：由（`:`）分隔的字段组成。这些字段是有顺序的。

- 第一个字段，主机上的文件或目录。
- 第二个字段，容器中的文件或目录。
- 第三个字段，可选，且用逗号分隔，如：`ro`，`consistent`，`delegated`，`cached`，`z`和`Z`。
- `--mount`：由多个键值对组成，由逗号分隔，每一个由`<key>=<value>`元祖组成。键值对没有顺序。

- `type`，可以是`bind`，`volume`，`tmpfs`。
- `source`，主机上的文件或目录的路径。可能用`src`，`source`指定。
- `destination`，容器中的文件或目录的路径。可能用`destination`，`dst`，`target`指定。
- `readonly`，如果存在，将更改 Propagation，可以是一个`rprivate`。
- `consistency`，如果存在，可以是`consistent`，`delegated`或`cached`，只在 Mac 版有效。
- `--mount`标志不支持`z`或`Z`修改 selinux。


**-v 和 –mount 的差异** 
使用`-v`和`--volume`绑定主机不存在的文件或目录，将会自动创建。始终创建的是一个目录。

使用`--mount`绑定主机上不存在的文件或目录，则不会自动创建，会产生一个错误。

**使用 bind mount 启动容器** 
主机上的目录`source/target`，容器的目录`/app/`。`$(pwd)`将使用当前目录：

```bash
# 只读方式：--mount type=bind,source="$(pwd)"/target,target=/app,readonly
docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app \
  nginx:latest

# 只读方式：-v "$(pwd)"/target:/app:ro
docker run -d \
  -it \
  --name devtest \
  -v "$(pwd)"/target:/app \
  nginx:latest
```

用`docker inspect devtest`可以查看相关信息，查看`Mounts`部分：

```yaml
"Mounts": [
    {
        "Type": "bind",
        "Source": "/tmp/source/target",
        "Destination": "/app",
        "Mode": "",
        "RW": true,
        "Propagation": "rprivate"
    }
],
```

这些信息表明了这是一个 bind 挂载，源路径和目的路径，并且是可读写的，且 Propagation 设置为`rprivate`。

停止容器：

```bash
docker container stop devtest
docker container rm devtest
```

**配置 Propagation** 
Propagation 的在 bind mount 和 volume 中默认为`rprivate`。它只能在 bind mount 配置，并且只能在 Linux 主机上配置。这是一个高级选项，许多用户不需要配置它。

Propagation 是指在给定的挂载卷或命名卷中创建的挂载是否可以传播到该挂载的副本。考虑一个挂载点`/mnt`，它被挂载在`/tmp`。传播设置控制是否挂载`/tmp/a`也可用`/mnt/a`.每个 Propagation 设置都有一个递归对应点。在递归的情况下，考虑`/tml/a`被挂载为`/foo`。传播设置控制是否`/mnt/a`或`/tmp/a`将存在。

| Propagation 设置 | 描述 |
| --- | --- |
| `shared` | 原始安装的子安装会暴露给副本安装，并且副本安装的子安装也会传播到原始安装。 |
| `slave` | 类似于共享的安装，但仅在一个方向上。如果原始安装显示一个子安装，副本安装可以看到它。但是，如果副本安装公开了子安装，则原始安装无法看到它。 |
| `private` | 这座山是私人的。其中的子安装不会暴露给副本安装，并且副安装的子安装不会暴露给原始安装。 |
| `rshared` | 与共享相同，但是传播也扩展到嵌套在任何原始或副本安装点内的挂载点。 |
| `rslave` | 与从属设备相同，但传播也延伸到嵌套在任何原始或副本安装点内的挂载点。 |
| `rprivate` | 默认。与私有相同，这意味着在原始或副本安装点内的任何位置都不会有安装点向任一方向传播。 |

在可以在安装点上设置绑定传播之前，主机文件系统需要已经支持绑定传播。有关绑定传播的更多信息，请参阅[共享子树](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)的[Linux内核文档](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)。

以下示例将`target/`目录装载到容器中两次，第二个装入设置`ro`选项和`rslave`绑定传播选项。

在`--mount`和`-v`实例有同样的结果。

```bash
docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app \
  --mount type=bind,source="$(pwd)"/target,target=/app2,readonly,bind-propagation=rslave \
  nginx:latest


docker run -d \
  -it \
  --name devtest \
  -v "$(pwd)"/target:/app \
  -v "$(pwd)"/target:/app2:ro,rslave \
  nginx:latest
```

现在如果你创建`/app/foo/`，`/app2/foo/`也将存在。

#### 配置selinux标签

如果使用的`selinux`话，可以添加`z`或者`Z`选项来修改正在装入容器的 **主机文件或目录** 的`selinux`标签。这会影响主机本身的文件或目录，并可能导致Docker范围之外的后果。

- 该`z`选项指示绑定安装内容在多个容器之间共享。
- 该`Z`选项指示绑定安装内容是私有的和非共享的。

使用 **极端** 谨慎使用这些选项。绑定一个系统目录，例如`/home`或者`/usr`用这个`Z`选项，将会使你的主机无法工作，你可能需要手工重新标记主机文件。

> `重要`：在使用绑定安装服务时，selinux标签（`:Z`和`:z`）以及`:ro`被忽略。有关详细信息，请参阅[moby/moby#32579](https://github.com/moby/moby/issues/32579)。


这个例子设置`z`选项来指定多个容器可以共享绑定挂载的内容：

使用`--mount`标志来修改selinux标签是不可能的。

```bash
docker run -d \
  -it \
  --name devtest \
  -v "$(pwd)"/target:/app:z \
  nginx:latest
```

#### 配置macOS的安装一致性

Docker for Mac用于`osxfs`将从 macOS 共享的目录和文件传播到 Linux VM。这种传播使这些目录和文件可用于在 Docker for Mac 上运行的 Docker 容器。

默认情况下，这些共享是完全一致的，这意味着每次在 macOS 主机上发生写入或通过容器中的挂载时，都会将更改刷新到磁盘，以便共享中的所有参与者都具有完全一致的视图。在某些情况下，完全一致可能会严重影响性能。Docker 17.05 和更高版本引入了选项来调整一个一个，每个容器的一致性设置。以下选项可用：

- `consistent`或者`default`：完全一致的默认设置，如上所述。
- `delegated`：容器运行时的挂载视图是权威的。在容器中进行的更新可能在主机上可见之前可能会有延迟。
- `cached`：macOS主机的挂载视图是权威的。在主机上进行的更新在容器中可见之前可能会有延迟。

这些选项在除 macOS 以外的所有主机操作系统上完全忽略。

在–mount和-v实例有同样的结果。

```bash
docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,destination=/app,consistency=cached \
  nginx:latest

docker run -d \
  -it \
  --name devtest \
  -v "$(pwd)"/target:/app:cached \
  nginx:latest
```

### `tmpfs`方式

`tmpfs`，仅存储在主机系统的内存中，不会写入主机的文件系统。

#### 相关用例

tmpfs，使用它的情况一般是，对安全比较重视以及不需要持久化数据。

#### 使用方式

`--tmpfs`和`--mount`的关系与前面两种方式的关系不用多说。那它们之间的差异是：

- `--tmpfs`不允许指定任何可配置选项。
- `--tmpfs`不能用语 swarm service，你必须使用`--mount`。

**tmpfs 容器的限制**

- `tmpfs`挂载不能在容器间共享。
- `tmpfs`职能在 Linux 容器上工作，不能在 windows 容器上工作。


**容器中使用 tmpfs**

```bash
docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app \
  nginx:latest

docker run -d \
  -it \
  --name tmptest \
  --tmpfs /app \
  nginx:latest
```

`tmpfs`通过运行`docker container inspect tmptest`并查找`Mounts`部分来验证安装是挂载：

```yaml
"Tmpfs": {
    "/app": ""
},
```

删除容器：

```bash
docker container stop tmptest
docker container rm tmptest
```

**指定 tmpfs 选项** 
`tmpfs`挂载允许两个配置选项，这两个都是不需要的。如果您需要指定这些选项，则必须使用该`--mount`标志，因为该`--tmpfs`标志不支持它们。

| 选项 | 描述 |
| --- | --- |
| tmpfs-size | tmpfs 的大小，以字节为单位。无限制默认。 |
| tmpfs-mode | tmpfs 的八进制文件模式。例如，`700`或者`0770`。默认为`1777`或世界可写。 |

以下示例将设置`tmpfs-mode`为`1770`，以便在容器内不可世界读取。

```bash
docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app,tmpfs-mode=1770 \
  nginx:latest
```


## 遇到的问题

`docker run redis` 没有声明`volume`为什么会自动创建容器卷

>当我们运行 `docker run redis` 时，Docker 会使用 Redis 官方镜像。查看 Redis 官方镜像的 Dockerfile（例如：https://github.com/docker-library/redis/blob/master/Dockerfile），我们可以发现其中定义了 VOLUME 指令。
>
>例如，在 Redis 的 Dockerfile 中，有：  `VOLUME /data`
>
>这意味着，在运行容器时，Docker 会自动为容器创建一个匿名卷，挂载到容器内的 /data 目录。这个匿名卷位于宿主机的某个位置（通常是 /var/lib/docker/volumes/ 下的一个随机目录）。
>
>这样做的目的是为了数据持久化，即使容器被删除，这个匿名卷仍然存在，除非手动删除。但请注意，如果使用匿名卷，那么当容器被删除后，这个卷可能会变成孤儿卷（没有容器引用的卷），占用磁盘空间。
>
>所以，即使我们在运行命令中没有声明 volume，由于镜像中定义了 VOLUME，Docker 也会自动创建匿名卷。
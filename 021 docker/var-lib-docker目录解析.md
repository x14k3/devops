# var-lib-docker目录解析

/var/lib/docker/ 是 Docker 引擎在 Linux 系统中默认存储 Docker 数据的目录，它包含了 Docker 引擎的运行时数据、容器镜像、容器卷等相关文件。

下面是 /var/lib/docker/ 目录中的一些重要子目录及其作用的简要解析：

## /var/lib/docker/containers/

* /var/lib/docker/containers 目录是 Docker 存储容器相关数据的默认位置。存储运行中的容器的数据，每个容器对应一个目录，包含容器的元数据、文件系统等信息。

  具体而言，/var/lib/docker/containers 目录下的每个子目录都对应一个 Docker 容器，子目录的名称通常是由容器的 ID 组成的一串字符，例如：

```
/var/lib/docker/containers/
├── 8a72c280f22b7465e5d26a532a8c14071c88f50d9e0c0498738e24c22181fd33
├── 234b05667f6c0487a7631263d9cde6b8cd23345b2e95640f61fd84d2a2a1aa34
├── ...
└── f82b3c649f56a94da26d3dcee058de1b7ad160773fc4a4e14e4fc477501c5b5d
```

这些子目录中包含了与相应容器相关的文件和目录，其中一些重要的文件和目录包括：

* config.v2.json：包含容器的配置信息，如容器的名称、镜像、挂载卷、环境变量等。
* hostname：包含容器的主机名。
* resolv.conf：包含容器的 DNS 配置信息。
* checkpoints：用于存储容器的检查点（Checkpoint）文件。
* logs：用于存储容器的日志文件。
* mounts：包含容器的挂载卷信息。
* state：包含容器的状态信息，如容器的运行状态、进程信息等。

## /var/lib/docker/image/

* 存储容器镜像的数据，每个容器镜像对应一个目录，包含容器镜像的元数据、图层等信息。
  /var/lib/docker/image/ 目录是 Docker 存储镜像相关数据的默认位置。在 Docker 中，镜像是用于创建容器的模板，包含了一个完整的应用程序和其所有依赖的文件系统快照。镜像的相关数据，例如镜像文件、元数据、缓存等，都会存储在 /var/lib/docker/image/ 目录下的对应目录中。

具体而言，/var/lib/docker/image/ 目录下包含了以下几个子目录：

* aufs：如果使用 AUFS 存储驱动（在旧版本的 Docker 中），则镜像的文件系统层会以 AUFS 格式存储在这个目录下的子目录中。每个子目录的名称都是由一个唯一的 ID 组成，对应着一个镜像的文件系统层。
* overlay2：如果使用 Overlay2 存储驱动（在较新版本的 Docker 中），则镜像的文件系统层会以 Overlay2 格式存储在这个目录下的子目录中。每个子目录的名称都是由一个唯一的 ID 组成，对应着一个镜像的文件系统层。
* overlay：如果使用 Overlay 存储驱动（在一些较旧的 Docker 版本中），则镜像的文件系统层会以 Overlay 格式存储在这个目录下的子目录中。每个子目录的名称都是由一个唯一的 ID 组成，对应着一个镜像的文件系统层。
* image.db：这是一个 SQLite 数据库文件，用于存储 Docker 镜像的元数据信息，例如镜像的名称、标签、大小、创建时间等。
* image/：这是一个软链接（symlink），指向存储镜像文件的实际目录（如 aufs、overlay2、overlay 中的其中一个）。这个软链接的目的是为了向后兼容，以支持不同的存储驱动。
  需要注意的是，/var/lib/docker/image/ 目录下的数据都是 Docker 引擎自动管理和维护的，对这些数据进行手动修改可能会导致镜像无法正常使用或数据丢失。因此，不推荐直接对 /var/lib/docker/image/ 目录下的文件和目录进行修改，除非你对 Docker 引擎和镜像的运行原理非常了解，并且有充分的备份和恢复措施。
* /var/lib/docker/volumes/：存储容器卷的数据，每个容器卷对应一个目录，包含容器卷的数据。
  /var/lib/docker/volumes/ 目录是 Docker 用于存储容器卷数据的默认位置。在 Docker 中，容器卷是一种用于持久化存储容器数据的机制，可以在容器之间共享和重用数据。/var/lib/docker/volumes/ 目录下包含了 Docker 卷相关的数据和元数据。

具体而言，/var/lib/docker/volumes/ 目录下可能包含以下一些文件和目录：

<volume-id>/：每个通过 Docker 创建的卷都会在这个目录下创建一个子目录，子目录的名称是由一个唯一的 ID 组成，对应着一个卷。这个子目录下包含了该卷的实际数据。例如，如果你在 Docker 中创建了一个名为 my_volume 的卷，那么在 /var/lib/docker/volumes/ 目录下会创建一个名为 <volume-id> 的子目录，里面存储了 my_volume 卷的实际数据。
vfs/：如果你在 Docker 中使用了 VFS 存储驱动（如在旧版 Docker 中使用的 "vfs" 驱动），那么这个目录下会存在与 VFS 相关的配置文件和状态信息。
需要注意的是，/var/lib/docker/volumes/ 目录下的数据都是 Docker 引擎自动管理和维护的，对这些数据进行手动修改可能会导致容器卷无法正常使用或数据丢失。因此，不推荐直接对 /var/lib/docker/volumes/ 目录下的文件和目录进行修改，除非你对 Docker 引擎和存储驱动的运行原理非常了解，并且有充分的备份和恢复措施。

## /var/lib/docker/network/

存储 Docker 网络的数据，包含 Docker 网络的配置和状态信息。
/var/lib/docker/network/ 目录是 Docker 存储网络相关数据的默认位置。在 Docker 中，网络是用于容器之间通信的关键组件，负责实现容器之间的通讯和连接。/var/lib/docker/network/ 目录下包含了 Docker 网络驱动所使用的配置文件、状态信息等。

具体而言，/var/lib/docker/network/ 目录下可能包含以下一些文件和目录：

* bridge/：如果使用 Docker 的默认网络驱动 "bridge"，则在这个目录下会存在与 "bridge" 网络相关的配置文件和状态信息。例如，每个通过 Docker 创建的 "bridge" 网络都会在这个目录下创建一个子目录，子目录的名称是由一个唯一的 ID 组成，对应着一个 "bridge" 网络。这个子目录下可能包含 config.v2.json 文件，用于存储 "bridge" 网络的配置信息，以及 networkSettings.json 文件，用于存储 "bridge" 网络的状态信息。
* overlay/：如果使用 Overlay 网络驱动，那么在这个目录下会存在与 Overlay 网络相关的配置文件和状态信息。类似于 "bridge" 网络，每个通过 Docker 创建的 Overlay 网络都会在这个目录下创建一个子目录，子目录的名称也是由一个唯一的 ID 组成，对应着一个 Overlay 网络。这个子目录下可能包含 config.v2.json 文件，用于存储 Overlay 网络的配置信息，以及 networkSettings.json 文件，用于存储 Overlay 网络的状态信息。
* plugins/：如果使用第三方的网络驱动插件，那么这个目录下可能会包含与这些插件相关的配置文件和状态信息。每个网络驱动插件都可能有自己的目录，用于存储其配置信息和状态信息。
  需要注意的是，/var/lib/docker/network/ 目录下的数据都是 Docker 引擎自动管理和维护的，对这些数据进行手动修改可能会导致网络无法正常使用或数据丢失。因此，不推荐直接对 /var/lib/docker/network/ 目录下的文件和目录进行修改，除非你对 Docker 引擎和网络驱动插件的运行原理非常了解，并且有充分的备份和恢复措施。

## /var/lib/docker/overlay2

/var/lib/docker/overlay2 目录是 Docker 存储驱动程序之一 Overlay2 的默认存储目录，用于保存 Docker 容器镜像和容器数据。Overlay2 是一个基于内核的图层存储驱动程序，可以通过将多个只读层叠加到单个可写层来创建 Docker 容器。Overlay2 驱动程序使用了基于 inode 的存储模型，它将不同的图层都挂载到相同的文件系统目录下，同时使用不同的命名空间来进行隔离。
在 /var/lib/docker/overlay2 目录下，每个容器都对应一个文件夹，文件夹的名称是由两个长随机字符串组成的，每个字符串对应一个不同的命名空间。其中一个字符串对应于 Overlay2 驱动程序的命名空间，它用于标识这个容器的图层；另一个字符串对应于挂载点的命名空间，用于在宿主机文件系统中创建一个目录，用于挂载这个容器的可写层。
每个容器的文件夹中包含多个子目录，其中最重要的是 diff 目录，它用于存储容器的可写层。当 Docker 容器需要修改文件时，Overlay2 驱动程序会将这些修改记录在 diff 目录下的文件中。除了 diff 目录，每个容器的文件夹中还包含 merged 目录、lowerdir 目录和 upperdir 目录，用于存储容器的只读层和可写层。
具体来说，当 Docker 运行容器时，它会在 /var/lib/docker/overlay2 目录下为容器创建一个唯一的文件夹，其中包含了容器的文件系统的层级结构。该文件夹的名称以 l 开头，后跟 64 个字符的十六进制字符串，这个字符串是该容器的唯一 ID，例如：

```
/var/lib/docker/overlay2/l4j4t4c3k3ck0ec13c4a5798d274b16523e86029292bfb9bb9c4a4a4c3d0e4b4
```

在这个目录中，Overlay2 存储了容器的所有文件系统层。当容器启动时，Docker 会将这些层级结构组合在一起，形成容器的完整文件系统，使其看起来像是一个完整的文件系统，而实际上是由多个层级结构组合而成的。
此外，该目录下还包含了一些元数据，用于管理这些层和容器。例如，该目录下的 diff 子目录存储了容器文件系统的写入层，而 merged 子目录是通过将不同层级的文件系统层级结构合并而成的，work 子目录用于 Overlay2 内部操作。

* /var/lib/docker/tmp/：存储 Docker 引擎的临时数据，如构建镜像时的临时文件等。
* /var/lib/docker/swarm/：存储 Docker Swarm 模式下的数据，包括 Swarm 集群的配置和状态信息。
* /var/lib/docker/trust/：存储 Docker 引擎的签名和证书数据，用于 Docker 镜像的安全性验证。

这只是 /var/lib/docker/ 目录中的一些常见子目录，实际上还可能包含其他目录和文件，具体的目录结构和文件内容可能因 Docker 版本、配置和使用方式而有所不同。在进行 Docker 相关操作时，需要小心处理这些目录和文件，以确保 Docker 数据的完整性和安全性。

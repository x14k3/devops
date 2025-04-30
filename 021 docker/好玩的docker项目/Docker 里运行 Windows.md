# Docker 里运行 Windows

转发：[https://soulteary.com/2024/03/11/install-windows-into-a-docker-container.html](https://soulteary.com/2024/03/11/install-windows-into-a-docker-container.html)

## 环境准备

我们依旧是先从环境准备开始。想要使用这个方案，我们需要准备的东西有三个：安装了 Docker 的操作系统（我使用 Ubuntu）、Windows 操作系统的安装光盘（从 WinXP ～ Win11 都行）、开源项目 [dockur/windows](https://github.com/dockur/windows) 的 Docker 镜像。

### 安装 Ubuntu 操作系统和 Docker

这套方案中采用了 KVM 加速，所以体验最好的方案是使用或者安装一个 Linux 环境，如果你本身就在使用 Ubuntu 之类的支持 KVM 非常方便的操作系统的话，那么只需要安装 Docker 就好啦。

如果你确实需要在容器中运行 Windows，想从零开始，可以参考之前的文章《[在笔记本上搭建高性价比的 Linux 学习环境：基础篇](https://soulteary.com/2022/06/21/building-a-cost-effective-linux-learning-environment-on-a-laptop-the-basics.html)》的方法来进行实践。安装 Ubuntu 的流程和以往并没有太大不同，依旧是老生常谈的三步曲：下载镜像、制作启动盘、安装系统。

如果你已经有了可以使用的 Linux 环境，可以参考上面文章中的 “更简单的 Docker 安装” 章节，完成基础环境的准备。

完成操作系统和 Docker 的准备后，我们还需要检查操作系统是否支持 KVM，需要先安装 `cpu-checker`​。

```bash
sudo apt install cpu-checker -y
```

然后，执行 `kvm-ok`​，顺利的话，将能够看到类似下面的日志输出：

```bash
# sudo kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

### 获取 WIndows 操作系统光盘

虽然开源项目 [dockur/windows](https://github.com/dockur/windows) 会根据用户指令，从 `dl.bobpony.com`​ 、`archive.org`​，以及微软官网自动下载合适的英文版系统镜像，但如果你想更快的完成系统的安装，或者想快速的启动多个 Windows Docker 容器，那么手动下载 Windows 光盘还是非常有必要的。

开源项目包含了一些自动安装的预设配置，不过，这需要使用英文版的操作系统，你可以从[这里下载](https://www.microsoft.com/en-us/software-download/windows11)。

当然，如果你需要使用中文版的操作系统，同样可以从[官方下载](https://www.microsoft.com/zh-cn/software-download/windows11)，在初始化操作系统的时候，相比英文操作系统你需要额外点一些“下一步”。

### 获取 Windows in Docker 容器镜像

获取在 Docker 中运行 Windows 的容器镜像很简单：

```bash
docker pull dockurr/windows
```

当然，如果不能够直接下载，也可以选择本地构建：

```bash
git clone https://github.com/dockur/windows.git
cd windows
docker build -t dockurr/windows .
```

这个镜像主要依赖了几项技术：

* [qemus/qemu-docker](https://github.com/qemus/qemu-docker)，在容器中使用 QEMU，能够提供接近本机速度的虚拟机的网络、IO 速度等。
* [christgau/wsdd](https://github.com/christgau/wsdd)，让容器中的 Windows 能够出现在局域网中的其他设备的共享设备中。（Windows 10 的 1511 版本后，默认开始禁用 SMBv1，NetBIOS 设备发现功能失效，导致其他设备不能对其进行服务发现）。
* [qemus/virtiso](https://github.com/qemus/virtiso)，精简到 27MB 的 KVM/QEMU Virtio 驱动程序，能够让 Windows 在 Docker 环境中正常使用。
* [krallin/tini](https://github.com/krallin/tini)，正确启动 Docker 中 QEMU，以及确保进程异常能够被正确处理，或正确的终止容器进程。

好了，准备工作就绪后，我们就可以开始使用这个有趣的技术方案啦。

## 基础使用

我们先聊聊最简单的使用方案，启动一个“无状态”的临时的 Windows 操作系统，容器会自动下载我们所需要的镜像：

```yaml
version: "3"
services:
  windows:
    image: dockurr/windows
    container_name: windows
    devices:
      - /dev/kvm
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    stop_grace_period: 2m
    restart: on-failure
```

将上面的配置保存为 `docker-compose.yml`​，然后使用 `docker compose up`​ 或 `docker compose -d`​ 启动服务。

因为我们没有指定本地的镜像，所以如果你的网络环境访问微软 CDN 不够快的话，启动过程需要等待一些时间。

```bash
# docker compose up   
[+] Running 2/1
 ✔ Network win_default  Created                                                                                                                                                     0.1s 
 ✔ Container windows    Created                                                                                                                                                     0.1s 
Attaching to windows
windows  | ❯ Starting Windows for Docker v2.04...
windows  | ❯ For support visit https://github.com/dockur/windows
windows  | 
windows  | 
windows  | ❯ Downloading Windows 11...
windows  | [i] Downloading Windows media from official Microsoft servers...
windows  | [i] Downloading Windows 11...
windows  | [+] Got latest ISO download link (valid for 24 hours): https://software.download.prss.microsoft.com/dbazure/Win11_23H2_English_x64v2.iso?t=c603adeb-c6d7-4bb9-b084-875f3beabfc2&P1=1710146067&P2=601&P3=2&P4=ynPQkgNxZoZxQkmfORJRE5yaf94m7ONuLVngMtHmDfsYTooFKSXiAdWXTKJ8dpoF2WuDkUZ4fkP1u%2bhwAh%2brAdghU%2f1ssngioKg2aLDe2UXOG3ESUAGTyRk1q515ONoXIvyJby2xPoKBVoj%2bsNp6ECqosBjx9HllmF3saRvQFPQox6v8kuhtMxyuNiXT%2fYgKppSZOifx34t6YQb0Hpo6gTkLjxlxiFBF42jLt%2blVhf1HW7ELEtvVUW7eAn9UGfs9HF6yC3p1ep7ouKYNrY0Ek0fo%2bn2v%2by3bTGbqg8lHfXjxb6bPHGE6HWP3sSZDZw4JmPt53hr1uQl%2fmjT50p504Q%3
windows  | #=#=#                                                                        
                                                                           windows  | #=#=#                                                                        
                                                                           0.0%
                                                                           0.1%
                                                                           0.2%
                                                                           0.3%
...
#######################################################################   99.7%
#######################################################################   99.8%
#######################################################################  100.0%
######################################################################## 100.0%

windows  | 
windows  | [+] Successfully downloaded Windows image!
windows  | 
windows  | ❯ Extracting Windows 11 image...
windows  | ❯ Adding XML file for automatic installation...
windows  | ❯ Building Windows 11 image...
windows  | ❯ Creating a 64G growable disk image in raw format...
windows  | ❯ Booting Windows using QEMU emulator version 8.2.1 ...
windows  | 
...
```

当一切就绪后，我们可以使用浏览器访问容器所在主机的 `IP地址:8006`​。

容器启动后，会自动下载、部署 Windows，稍等片刻，就能够在浏览器中正常使用它啦

## 加速使用 Windows 容器

![默认情况，每次启动都需要见到它](assets/network-asset-prepare-20241118215730-u7oo6l1.jpg)

默认情况，每次启动都需要见到它

当然，如果你的网络环境不是那么好，或者你不想每次启动容器都要等待很久，可以使用下面的方法。

让部署使用加速，主要和两个细节有关：是否进行了容器内容的持久化，是否提供了高性能的安装镜像下载方式。

比如，我们在上面的准备工作中，我们预先下载好 Windows 的安装镜像，然后将文件重命名为 `win11x64.iso`​，接着将文件放置在目录的 `./iso`​ 子目录中。那么，借助 Nginx，可以让整个安装部署过程变的飞快。

```yaml
version: "3"
services:
  windows:
    image: dockurr/windows
    container_name: windows
    devices:
      - /dev/kvm
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    stop_grace_period: 2m
    restart: on-failure
    environment:
      VERSION: "http://winiso/win11x64.iso"
      MANUAL: "N"
    volumes:
      - ./win:/storage
    depends_on:
      - winiso


  winiso:
    image: nginx:alpine
    container_name: winiso
    restart: on-failure
    volumes:
     - ./iso:/usr/share/nginx/html
```

在上面的配置中，我们增加了一个用来将本地的 Windows 安装文件转换为 `dockurr/windows`​ 快速可安装的在线地址的容器。

将配置文件保存为 `docker-compose.yml`​，然后使用 `docker compose up`​ 或者 `docker compose up -d`​ 启动配置，我们将看到类似下面的日志：

```bash
windows  | .
windows  | .
winiso   | 172.20.2.3 - - [11/Mar/2024:03:54:47 +0000] "GET /win11x64.iso HTTP/1.1" 200 6813366272 "-" "Wget/1.21.4" "-"
windows  | . 99% 1.59G 0s
windows  | 
windows  | 6651904K .
windows  |                         
windows  |         100% 1.95G
windows  | =3.7s
windows  | 
windows  | 
windows  | ❯ Extracting downloaded ISO image...
windows  | ❯ Detecting Windows version from ISO image...
windows  | ❯ Detected: Windows 11
windows  | ❯ Adding XML file for automatic installation...
windows  | ❯ Building Windows 11 image...
windows  | ❯ Creating a 64G growable disk image in raw format...
windows  | ❯ Booting Windows using QEMU emulator version 8.2.1 ...
```

下载镜像的速度马上从几MB、几十MB增加到了接近每秒 2GB，不到 4s 就能完成镜像的下载和处理。

因为在配置中增加了 `volumes`​ 卷的持久化（`- ./win:/storage`​），所以我们可以放心的停止或者重新启动容器，而不必担心每次都要重新初始化“一台”新的 Windows Docker 容器。

## 使用技巧

聊聊其他的使用技巧。

### 更换 Windows 版本（不提前准备镜像）

如果你的网络环境非常棒，不需要提前下载安装镜像，或者直接使用云主机进行项目部署，那么可以考虑直接调整配置文件中的内容为合适的数值：

```yaml
environment:
  VERSION: "win11"
```

支持我们调整使用的值包含：`win11`​、`win10`​、`ltsc10`​、`win81`​、`win7`​、`vista`​、`winxp`​、`2022`​、`2019`​、`2016`​、`2012`​、`2008`​。

### 调整 Windows 容器资源配置

默认情况下，这个 Windows 容器会使用 vCPU x2、4GB 内存、64G 的磁盘空间，来满足 Win11 的最低安装需求。我们可以根据自己的实际需求，来动态的调整容器的硬件资源限制。

```yaml
environment:
  RAM_SIZE: "8G"
  CPU_CORES: "4"
  DISK_SIZE: "256G"
```

比如，在上面的配置中，我们调整 CPU 核心数到 4，内存到 8GB，磁盘到 256GB。

### 为容器分配独立的 IP 地址

默认情况下，Docker 会共享宿主机的 IP，如果我们想要让容器拥有独立的 IP 地址，需要先创建一个 `macvlan`​ 网络：

```bash
docker network create -d macvlan \
    --subnet=192.168.0.0/24 \
    --gateway=192.168.0.1 \
    --ip-range=192.168.0.100/28 \
    -o parent=eth0 vlan
```

创建完网卡后，调整上面使用的容器配置，根据自己的需求指定容器 IP 即可：

```yaml
services:
  windows:
    container_name: windows
    ..<snip>..
    networks:
      vlan:
        ipv4_address: 192.168.0.100

networks:
  vlan:
    external: true
```

### 使用一整块磁盘

如果你的主机上有多块磁盘，或者想将某一块磁盘完整的分配给 Windows，可以采用下面的方法，其中 `DEVICE`​ 将作为你的主磁盘：

```yaml
environment:
  DEVICE: "/dev/sda"
  DEVICE2: "/dev/sdb"
devices:
  - /dev/sda
  - /dev/sdb
```

### 在 Docker 中的 Windows 使用 USB 设备

我们首先需要使用 `lsusb`​ 来获取 USB 设备的 `VendorID`​ 和 `ProductID`​ ，然后将这些信息添加到配置中：

```yaml
environment:
  ARGUMENTS: "-device usb-host,vendorid=0x1234,productid=0x1234"
devices:
  - /dev/bus/usb
```

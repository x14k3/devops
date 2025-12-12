
QEMU/KVM 是目前最流行的虚拟化技术，它基于 Linux 内核提供的 kvm 模块，结构精简，性能损失小，而且开源免费（对比收费的 vmware），因此成了大部分企业的首选虚拟化方案。

目前各大云厂商的虚拟化方案，新的服务器实例基本都是用的 KVM 技术。即使是起步最早，一直重度使用 Xen 的 AWS，从 EC2 C5 开始就改用了基于 KVM 定制的 Nitro 虚拟化技术。

但是 KVM 作为一个企业级的底层虚拟化技术，却没有对桌面使用做深入的优化，因此如果想把它当成桌面虚拟化软件来使用，替代掉 VirtualBox/VMware，有一定难度。

‍

## 一、安装 QUEU/KVM

QEMU/KVM 环境需要安装很多的组件，它们各司其职：

1. qemu: 模拟各类输入输出设备（网卡、磁盘、USB端口等）

    - qemu 底层使用 kvm 模拟 CPU 和 RAM，比软件模拟的方式快很多。
2. libvirt: 提供简单且统一的工具和 API，用于管理虚拟机，屏蔽了底层的复杂结构。（支持 qemu-kvm/virtualbox/vmware）
3. ovmf: 为虚拟机启用 UEFI 支持
4. virt-manager: 用于管理虚拟机的 GUI 界面（可以管理远程 kvm 主机）。
5. virt-viewer: 通过 GUI 界面直接与虚拟机交互（可以管理远程 kvm 主机）。
6. dnsmasq vde2 bridge-utils openbsd-netcat: 网络相关组件，提供了以太网虚拟化、网络桥接、NAT网络等虚拟网络功能。

    - dnsmasq 提供了 NAT 虚拟网络的 DHCP 及 DNS 解析功能。
    - vde2: 以太网虚拟化
    - bridge-utils: 顾名思义，提供网络桥接相关的工具。
    - openbsd-netcat: TCP/IP 的瑞士军刀，详见 [socat &amp; netcat](https://thiscute.world/posts/socat-netcat/)，这里不清楚是哪个网络组件会用到它。

安装命令：

```bash
# archlinux/manjaro
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat

# debian
sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon  bridge-utils libguestfs-tools libosinfo-bin  qemu-system virt-manager
sudo systemctl enable --now libvirtd

# centos
yum -y install kvm python-virtinst libvirt  bridge-utils virt-manager qemu-kvm-tools  virt-viewer  virt-v2v libguestfs-tools-c

# openSUSE
#sudo zypper up
sudo zypper install virt-*  libvirt  bridge-utils qemu-kvm  qemu-img  libvirt-client libvirt-devel
```

‍

### 1. libguestfs - 虚拟机磁盘映像处理工具

[libguestfs](https://libguestfs.org/) 是一个虚拟机磁盘映像处理工具，可用于直接修改/查看/虚拟机映像、转换映像格式等。

它提供的命令列表如下：

1. ​`virt-df centos.img`​: 查看硬盘使用情况
2. ​`virt-ls centos.img /`​: 列出目录文件
3. ​`virt-copy-out -d domain /etc/passwd /tmp`​：在虚拟映像中执行文件复制
4. ​`virt-list-filesystems /file/xx.img`​：查看文件系统信息
5. ​`virt-list-partitions /file/xx.img`​：查看分区信息
6. ​`guestmount -a /file/xx.qcow2(raw/qcow2都支持) -m /dev/VolGroup/lv_root --rw /mnt`​：直接将分区挂载到宿主机
7. ​`guestfish`​: 交互式 shell，可运行上述所有命令。
8. ​`virt-v2v`​: 将其他格式的虚拟机(比如 ova) 转换成 kvm 虚拟机。
9. ​`virt-p2v`​: 将一台物理机转换成虚拟机。

学习过程中可能会使用到上述命令，提前安装好总不会有错，安装命令如下：

```bash
# opensuse
sudo zypper install libguestfs

# archlinux/manjaro，目前缺少 virt-v2v/virt-p2v 组件
sudo pacman -S libguestfs

# ubuntu
sudo apt install libguestfs-tools

# centos
sudo yum install libguestfs-tools

```

### 2. 启动 QEMU/KVM

通过 systemd 启动 libvirtd 后台服务：

```shell
sudo systemctl enable libvirtd.service
sudo systemctl start  libvirtd.service
```

### 3. 让非 root 用户能正常使用 kvm

qumu/kvm 装好后，默认情况下需要 root 权限才能正常使用它。 为了方便使用，首先编辑文件 `/etc/libvirt/libvirtd.conf`​:

1. ​`unix_sock_group = "libvirt"`​，取消这一行的注释，使 `libvirt`​ 用户组能使用 unix 套接字。
2. ​`unix_sock_rw_perms = "0770"`​，取消这一行的注释，使用户能读写 unix 套接字。

然后新建 libvirt 用户组，将当前用户加入该组：

```shell
newgrp libvirt
sudo usermod -aG libvirt $USER 
```

最后重启 libvirtd 服务，应该就能正常使用了：

```shell
sudo systemctl restart libvirtd.service 
```

### 4. 启用嵌套虚拟化

如果你需要**在虚拟机中运行虚拟机**（比如在虚拟机里测试 katacontainers 等安全容器技术），那就需要启用内核模块 kvm_intel 实现嵌套虚拟化。

```shell
# 临时启用 kvm_intel 嵌套虚拟化
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
# 修改配置，永久启用嵌套虚拟化
echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf

```

验证嵌套虚拟化已经启用：

```shell
$ cat /sys/module/kvm_intel/parameters/nested 
Y
```

至此，KVM 的安装就大功告成啦，现在应该可以在系统中找到 virt-manager 的图标，进去就可以使用了。 virt-manager 的使用方法和 virtualbox/vmware workstation 大同小异，这里就不详细介绍了，自己摸索摸索应该就会了。

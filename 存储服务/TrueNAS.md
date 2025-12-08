
# 1 介绍

TrueNAS由原FreeNAS演变而来，**FreeNAS 和 TrueNAS 已经合并，统一使用 TrueNAS 这一名字**

TrueNAS（12.0 版前称为 FreeNAS，是一套基于 FreeBSD 操作系统核心的开放源代码的网络存储设备（英语：NAS）服务器系统，支持众多服务，用户访问权限管理，提供网页设置接口

FreeNAS主要由 iXsystems 领导开发,现在 iXsystems 宣布了一个基于 Debian Linux 的版本叫 TrueNAS SCALE 
TrueNAS SCALE是TrueNAS系列的最新成员，并提供包括Linux容器和VM在内的开源HyperConverged基础架构
TrueNAS SCALE包括集群系统和提供横向扩展存储的能力，容量最高可达数百PB

其中TrueNAS CORE 为开源版本，TrueNAS Enterprise 为商业版本
> FreeNAS 的几乎所有配置和功能都可通过 Web 用户界面管理
> FreeNAS安装可以在裸金属、虚拟机环境下进行安装，安装完成后可能有难度的部分在于对于管理IP地址的配置

另外不同于其他HCI超融合架构，TrueNAS允许安装在单一节点上

## 1.1 关于OpenZFS文件系统

FreeNAS的文件系统采用OpenZFS文件系统

OpenZFS是一个自由和开放源码的文件系统，是Solaris’ ZFS和FreeBSD以及Mac OS X上的ZFS之间的一个折衷版本。它集合了Solaris ZFS发行版的功能与FreeBSD发行版的稳定性，实现了柔性的平衡。OpenZFS允许开发者在几种不同的操作系统上实现和使用具有相同功能的文件系统，而且可以在所有平台上相互兼容。

OpenZFS被设计成一个灵活、健壮的文件系统，它为存储体系架构提供了基本的基础设施。它可以处理所有操作系统中可用的存储设备，不管它们是本地磁盘、 SAN、iSCSI、DRBD块设备或NAS设备。

OpenZFS的存储模型是面向对象的，所有的文件存储对象遵循类似的抽象数据模型。文件系统可根据不同的需求来存储不同的文件对象，文件可以存放到原始的、压缩的或加密的存储池之中。

OpenZFS还提供安全可靠的复制和容错性，它可以根据可用的磁盘数量和容量来创建实时副本，增强数据安全性和容错性。它还可以根据存储设备大小提供动态扩展能力，使用存储设备做动态扩容。

OpenZFS还提供许多其他令人满意的功能，比如预读、增量备份，可恢复到任何时刻任何版本的数据，把空中存储器、端到端安全性甚至虚拟化等等等。这些功能为存储系统的实施和管理提供了非常大的便利性


## 1.2 TrueNAS功能

TrueNAS 支持所有主流的网络文件共享和远程备份选项，甚至可以使用 FreeBSD 或 Linux 的应用程序进行扩展

支持的共享协议包括 NFS（v3,4），SMB（v1,2,3,4），AFP，FTP，WebDAV 和 rsync

TrueNAS 完全支持块共享（iSCSI，光纤通道），并且已通过认证，可与 vSphere，Citrix 和 Veeam 一起使用

ZFS 通过写时复制、校验和、清理和 2-Copy 元数据等功能保护您的数据

自动复制可确保您可以在远程存储位置中安全地保持数据的逐位相同副本，并且超快重新同步时间意味着如果磁盘发生故障，可以将备用磁盘快速集成到降级的数据存储池中

ZFS 使用高效的快照和克隆技术来最大化可用空间，以及内联数据压缩、精简配置和重复数据删除

TrueNAS 与所有主要备份供应商和虚拟机环境集成，并通过 Veeam Backup and Replication，Citrix 和 VMware 认证。它支持 VMware 快照，并具有 vCenter 插件。它还与 Microsoft CSV，ODX 和 VSS 集成

# 2 安装

## 2.1 在 kvm 中安装TrueNAS

```bash
## 下载
wget https://download.sys.truenas.net/TrueNAS-SCALE-Goldeye/25.10.0.1/TrueNAS-SCALE-25.10.0.1.iso


# 创建存储目录
mkdir -p /var/lib/libvirt/images/truenas

# 创建系统磁盘
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/system.qcow2 20G

# 创建数据磁盘（可选，用于模拟存储池）
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/data1.qcow2 50G
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/data2.qcow2 50G

# 使用 virt-install 创建虚拟机
sudo virt-install \
--name=truenas \
--description="TrueNAS SCALE VM" \
--os-type=generic \
--ram=8192 \
--vcpus=4 \
--cpu host-passthrough \
--disk path=/var/lib/libvirt/images/truenas/system.qcow2,size=20,format=qcow2 \
--disk path=/var/lib/libvirt/images/truenas/data1.qcow2,size=50,format=qcow2 \
--disk path=/var/lib/libvirt/images/truenas/data2.qcow2,size=50,format=qcow2 \
--cdrom=/path/to/TrueNAS-SCALE-22.12.0.iso \
--network bridge= br0 \
--graphics vnc,listen=0.0.0.0 \
--boot uefi \
--noautoconsole


```

## 2.2 虚拟机配置优化

```bash
# 编辑虚拟机配置：
virsh edit truenas

# 添加以下配置：
<!-- CPU 模式 -->
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='4' threads='1'/>
</cpu>

<!-- 内存气球驱动（可选） -->
<memtune>
  <hard_limit unit='KiB'>16777216</hard_limit>
</memtune>

<!-- 时钟同步 -->
<clock offset='utc'>
  <timer name='rtc' tickpolicy='catchup'/>
  <timer name='pit' tickpolicy='delay'/>
  <timer name='hpet' present='no'/>
</clock>

```

## 2.3 安装 TrueNAS SCALE

1. **启动虚拟机控制台**
```bash
	sudo virsh start truenas
	virt-viewer truenas
	# 或使用 VNC 连接：宿主机IP:5900
```
2. **安装过程**
    - 选择 "Install/Upgrade"
    - 选择系统磁盘（通常为第一个磁盘）
    - 设置 root 密码
    - 选择引导方式：UEFI
    - 确认安装
    - 安装完成后重启，**记得移除 ISO 启动介质**

3. **移除 CD-ROM 启动**
```bash
	virsh edit truenas
	# 删除或注释掉 <disk type='file' device='cdrom'> 部分
```


# 3 初始配置

1. **访问 TrueNAS Web 界面**
    - 虚拟机启动后查看控制台显示的 IP 地址
    - 浏览器访问：`http://[TrueNAS-IP]`
    - 用户名：root，密码：安装时设置的密码

2. **基本配置**
    - 网络配置（如果需要静态 IP）
    - 时区设置
    - 创建存储池

3. **创建存储池**
    - 进入 "Storage" → "Pools"
    - 点击 "Add Pool"
    - 选择数据磁盘（如 vdb, vdc）
    - 选择 RAID 类型（如 Mirror、RAIDZ1 等）
    - 创建数据集（Datasets）
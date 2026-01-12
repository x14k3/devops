
KVM虚拟机可以在线(运行时)添加磁盘、CDROM、USB设备，这对在线维护非常有用，可以不停机修改设备。

备注

案例使用的虚拟机名字`dev7`，添加的磁盘文件命名为`dev7-data.qcow2`

## 添加磁盘文

```bash
# 创建虚拟磁盘文件（qcow2类型）
cd /var/lib/libvirt/images
qemu-img create -f qcow2 dev7-data.qcow2 20G


# 方法一：
virsh attach-disk <虚拟机名称> /var/lib/libvirt/images/new_disk.qcow2 vdb --cache none --persistent --drive qemu --subdriver qcow2
# 警告
# 一定要明确使用`--driver qemu --subdriver qcow2`:
# `libvirtd`出于安全因素默认关闭了虚拟磁盘类型自动检测功能，并且默认使用的磁盘格式是`raw`，如果不指定磁盘驱动类型会导致被识别成`raw`格式，就会在虚拟机内部看到非常奇怪的极小的磁盘。

# --config     设置的同时更改虚拟机xml文件，这样就可以保证虚拟机重启后仍然生效
# --persistent 表示将更改写入虚拟机配置，这样重启后仍然有效。相当于–config --live
# --subdriver  声明镜像文件类型<qcow2|raw>
# --cache none 设置缓存模式，none表示不缓存（也可以根据需求设置其他模式）。


##----------------------------------------------------------------------------------------------

# 方法2：使用XML配置文件（推荐）
## 创建磁盘XML文件 `new_disk.xml`：
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2' cache='none'/>
  <source file='/var/lib/libvirt/images/new_disk.qcow2'/>
  <target dev='vdb' bus='virtio'/>
</disk>

## 附加磁盘：
virsh attach-device <虚拟机名称> new_disk.xml --persistent
# 分离磁盘
virsh detach-disk <虚拟机名称> vdb --persistent

# 查看当前磁盘列表（确认要卸载的磁盘的映射名称，例如 `vda`, `vdb`）
virsh domblklist <虚拟机名称>


```

## 添加iso文件

```bash
#方法一：使用virsh change-media

# 1. 查看虚拟机的当前光驱设备：
virsh domblklist win7

 Target   Source
-------------------------------------------------------------------------------------------
 vda      /data/qemu/images/win7.qcow2
 sda      /data/qemu/iso/cn_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677816.iso
 sdb      /data/qemu/iso/virtio-win-0.1.173.iso

# 注意：如果你的虚拟机没有光驱设备，那么可能没有类似sda这样的设备。
# 2. 如果已经有光驱设备（比如sda），那么我们可以使用change-media命令来改变介质：
virsh change-media <vm_name> sdb --eject  # 先弹出当前介质（如果有）
virsh change-media <vm_name> sdb /path/to/virtio-win.iso --insert

# 3. 如果没有光驱设备，那么我们需要先添加一个光驱设备。这可以通过virsh attach-device命令完成，需要准备一个XML文件。

# 方法二：使用virsh attach-device添加光驱设备并挂载ISO

# 1. 创建一个XML文件，例如cdrom.xml，内容如下：
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/path/to/virtio-win.iso'/>
  <target dev='sdb' bus='scsi'/>   <!-- 这里假设使用scsi总线，设备为sdb，也可以使用其他总线和设备名，如ide的hdb等 -->
  <readonly/>
  <address type='drive' controller='0' bus='0' target='0' unit='1'/>
</disk>
# 注意：address部分需要根据虚拟机的PCI控制器和总线情况来设置，如果不确定，可以查看虚拟机的当前XML配置来调整。
# 2. 执行挂载命令：
virsh attach-device <vm_name> cdrom.xml

#但是，请注意，热添加设备需要虚拟机总线支持，比如scsi总线。另外，如果虚拟机是Windows，可能需要安装驱动才能识别新的SCSI设备。
#由于我们要挂载的是virtio-win.iso，这个ISO通常用于为Windows虚拟机提供virtio驱动，所以可能是在Windows虚拟机中操作。
#考虑到兼容性，我们也可以使用ide总线，因为Windows默认支持ide光驱。但是，现代KVM虚拟机通常使用sata或scsi总线。
#另一种更简单的方法：使用virt-manager图形界面，在虚拟机运行时，添加硬件->存储，选择ISO文件，设备类型选择CDROM，然后完成。
```


## 调整磁盘空间

需要关闭虚拟机
```bash
#在物理主机(host主机)上使用使用 `qemu-img resize`​ 命令调整虚拟机磁盘大小:
qemu-img resize /data/test_01.qcow2 +30G
```

## CPU热添加

该虚拟机必须指定了最大cpu数量 –**vcpu**s 5,max**vcpu**s=10

```bash
# 临时
virsh setvcpus --domain centos8-3 6 --live

# 永久
virsh setvcpus --domain centos8-3 6 --live --config 
```

注意：CPU目前是不支持回收的。


## 网卡热调整

### 添加网卡

```bash
# 桥接
virsh attach-interface --domain centos8-3 --type bridge --source br0 --model virtio --config

# NAT
virsh attach-interface --type network --domain centos8-3 --source default --config

# 关于type  source不会写的可以参考xml文件
<interface type='network'>
      <mac address='52:54:00:30:38:55'/>
      <source network='default'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x09' slot='0x01' function='0x0'/>
    </interface>

#可以看到  type   ”source network“这两个字段吧
```

### 网卡剥离

剥离要指定剥离网卡的Mac地址
```bash
# 永久剥离
virsh detach-interface --domain centos8-3 --mac 52:54:00:43:b8:3c --type bridge --config

# 临时剥离
virsh detach-interface --domain centos8-3 --mac 52:54:00:95:b7:0e --type network
```


## 内存热调整

### **扩容内存**

```bash
# 内存热添加的基础是必须设置最大内存的容量，否则无法添加，最大扩展不能超过最大分配
virsh setmaxmem test1 8G --config
#将原来4G的内容扩容到8G
virsh setmem    test1 8G --config

#--size 目标容量
#--live 运行的机器
```

创建机器时可以指定

```
--memory memory=1024,currentMemory=512
```

### **缩小内存**

同样的方法，指定内存目标容量即可

```bash
virsh setmem  centos8-3  512M --live 
#永久
virsh setmem  centos8-3  512M --live --config
```


## 通过修改配置文件

**注意：** 增大虚拟机内存、增加虚拟机 CPU 个数需要首先关机虚拟机

### 1.关闭虚拟机

```bash
virsh shutdown ehs-jboss-01
```

### 2.编辑虚拟机配置文件

修改内存**memory 和 currentMemory 参数来调整内存大小；**

修改 CPU vcpu 参数来调整 CPU 个数(核数)；

```bash
[root@ehs-as-04 ~]# virsh edit ehs-jboss-01
......
  <name>ehs-jboss-01</name>
  <uuid>6c407a2d-e355-4dee-bf00-d13f2cba0c1f</uuid>
  <memory unit='KiB'>8388608</memory>
  <currentMemory unit='KiB'>8388608</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
......
```

### 3.从配置文件启动虚拟机

```bash
[root@ehs-as-04 ~]# virsh create /etc/libvirt/qemu/ehs-jboss-01.xml 
域 ehs-jboss-01 被创建（从 /etc/libvirt/qemu/ehs-jboss-01.xml）
```

### 4.查看当前内存大小

```bash
[root@ehs-as-04 ~]# virsh dominfo ehs-jboss-01
Id:             65
名称：       ehs-jboss-01
UUID:           6c407a2d-e355-4dee-bf00-d13f2cba0c1f
OS 类型：    hvm
状态：       running
CPU：          2
CPU 时间：   32.8s
最大内存： 8388608 KiB
使用的内存： 8388608 KiB
持久：       是
自动启动： 禁用
管理的保存： 否
安全性模式： none
安全性 DOI： 0
```

### 5.设置虚拟机内存大小为8G

```bash
[root@kvm01 ~]# virsh setmem ehs-jboss-01 8388608
```

### 6.验证

查看当前内存大小

```bash
[root@kvm01 ~]# virsh dominfo ehs-jboss-01 | grep memory
Max memory: 1048432 KiB
Used memory: 1048432 KiB
```

查看当前CPU个数

```bash
[root@kvm01 ~]# virsh dominfo ehs-jboss-01 | grep CPU
CPU(s): 2
CPU time: 15.0s
```

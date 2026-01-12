
KVM虚拟机可以在线(运行时)添加磁盘、CDROM、USB设备，这对在线维护非常有用，可以不停机修改设备。

备注

案例使用的虚拟机名字`dev7`，添加的磁盘文件命名为`dev7-data.qcow2`

## 添加磁盘文

- 创建虚拟磁盘文件（qcow2类型）
```bash
cd /var/lib/libvirt/images
qemu-img create -f qcow2 dev7-data.qcow2 20G
```

- 虚拟磁盘文件添加到虚拟机
`qemu`可以映射物理存储磁盘(例如`/dev/sdb`)，或者虚拟磁盘文件到KVM虚拟机的虚拟磁盘(`vdb`)

```bash

# 方法一：
virsh attach-disk <虚拟机名称> /var/lib/libvirt/images/new_disk.qcow2 vdb --cache none --persistent --drive qemu --subdriver qcow2
#--config     设置的同时更改虚拟机xml文件，这样就可以保证虚拟机重启后仍然生效
#--persistent 表示将更改写入虚拟机配置，这样重启后仍然有效。相当于–config --live
#--subdriver  声明镜像文件类型<qcow2|raw>
#--cache none 设置缓存模式，none表示不缓存（也可以根据需求设置其他模式）。


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
```

**警告**
一定要明确使用`--driver qemu --subdriver qcow2`:
`libvirtd`出于安全因素默认关闭了虚拟磁盘类型自动检测功能，并且默认使用的磁盘格式是`raw`，如果不指定磁盘驱动类型会导致被识别成`raw`格式，就会在虚拟机内部看到非常奇怪的极小的磁盘。

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

## 添加iso光盘

```
virsh attach-disk Centos7 /data_lij/iso/CentOS-6.4-x86_64-bin-DVD1.iso vdb
```

cdrom/floppy 不支持热插拔，所以和上面动态插入一个磁盘设备不同，如果直接使用以下命令插入设备( 虚拟机名字是`sles12-sp3`)映射:
```bash
virsh attach-disk sles12-sp3 SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso --target hdc --type cdrom --mode readonly
```

会提示错误:
```bash
error: Failed to attach disk
error: Operation not supported: cdrom/floppy device hotplug isn't supported
```

但是，如果虚拟机定义时候已经定义过cdrom设备，则使用`virsh dumpxml sles12-sp3`可以看到如下设备:
```xml
<disk type='file' device='cdrom'>
  <driver name='qemu'/>
  <target dev='sda' bus='sata'/>
  <readonly/>
  <alias name='sata0-0-0'/>
  <address type='drive' controller='0' bus='0' target='0' unit='0'/>
</disk>
```


则我们可以通过指定将iso文件插入到虚拟机中的`sda`CDROM中:
```bash
virsh attach-disk sles12-sp3 /var/lib/libvirt/images/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso sda --type cdrom --mode readonly
```

就会提示成功插入:
```
Disk attached successfully
```

再次使用`virsh dumpxml sles12-sp3`可以看到iso文件加载:
```xml
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/var/lib/libvirt/images/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso' index='3'/>
  <backingStore/>
  <target dev='sda' bus='sata'/>
  <readonly/>
  <alias name='sata0-0-0'/>
  <address type='drive' controller='0' bus='0' target='0' unit='0'/>
</disk>
```

如果要卸载这个iso文件，则创建一个相同结构的xml文件`detach_iso.xml`，但是保持`<source/>`行删除:
```xml
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <backingStore/>
  <target dev='sda' bus='sata'/>
  <readonly/>
  <alias name='sata0-0-0'/>
  <address type='drive' controller='0' bus='0' target='0' unit='0'/>
</disk>
```

然后执行设备更新:
```bash
virsh update-device sles12-sp3 detach_iso.xml
```

此时提示:
```
Device updated successfully
```

再检查虚拟机配置，就看到iso文件已经卸载了。


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

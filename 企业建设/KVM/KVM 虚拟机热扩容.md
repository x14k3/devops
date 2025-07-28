#kvm

## 一、磁盘热扩容

### 动态添加虚拟机磁盘

  ```bash
# 在宿主机创建磁盘镜像文件
qemu-img create -o preallocation=full -f qcow2 /var/lib/libvirt/images/new_disk.qcow2 10G 

# 动态附加磁盘到运行中的虚拟机

# 方法1:使用attach-disk命令
virsh attach-disk <虚拟机名称> /var/lib/libvirt/images/new_disk.qcow2 vdb --cache none --persistent
#--config     设置的同时更改虚拟机xml文件，这样就可以保证虚拟机重启后仍然生效
#--persistent 表示将更改写入虚拟机配置，这样重启后仍然有效。相当于–config --live
#--subdriver  声明镜像文件类型<qcow2|raw>
#--cache none 设置缓存模式，none表示不缓存（也可以根据需求设置其他模式）。


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


### 动态调整磁盘空间

```bash

```

### 调整磁盘空间，需要关闭虚拟机

```bash
#在物理主机(host主机)上使用使用 `qemu-img resize`​ 命令调整虚拟机磁盘大小:
qemu-img resize /data/test_01.qcow2 +30G
```



### 在线添加光盘

```
virsh attach-disk Centos7 /data_lij/iso/CentOS-6.4-x86_64-bin-DVD1.iso vdb
```

‍

## 二、网卡热添加

### 网卡添加

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

## 三、内存热添加

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

## 四、CPU热添加

### **添加CPU**

该虚拟机必须指定了最大cpu数量 –**vcpu**s 5,max**vcpu**s=10

```bash
# 临时
virsh setvcpus --domain centos8-3 6 --live

# 永久
virsh setvcpus --domain centos8-3 6 --live --config 
```

注意：CPU目前是不支持回收的。

## 五、通过修改配置文件

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

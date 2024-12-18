# KVM 虚拟机热扩容

## 一、磁盘热扩容

　　通过组合合适的VM文件系统功能（例如支持在线resize的XFS文件系统）和QEMU底层 `virsh qemu-monitor-command`​ 指令可以实现在线动态调整虚拟机磁盘容量，无需停机，对维护在线应用非常方便。不过，这里虚拟机磁盘扩容（resize）部分步骤需要在VM内部使用操作系统命令，所以适合自建自用的测试环境。

　　生产环境reize虚拟机磁盘系统，可采用 [libguestfs](http://libguestfs.org/) 来修改虚拟机磁盘镜像。 `libguestfs`​ 可以查看和编辑guest内部文件，脚本化修改VM，监控磁盘使用和空闲状态，以及创建虚拟机，P2V,V2V，以及备份，clone虚拟机，构建虚拟机，格式化磁盘，resize磁盘等等。

### 动态添加虚拟机磁盘

* 创建虚拟机磁盘文件

  ```bash
  #创建虚拟机磁盘(qcow2类型):
  cd /var/lib/libvirt/images
  qemu-img create -f qcow2 test_02_expand.qcow2 5G

  #可以看到qcow2格式化磁盘是zlib压缩，并且一闪而过完成。此时使用 `ls -lh` 检查可以看到磁盘仅仅占用数百K:
  -rw-r--r-- 1 root   root 193K Dec 27 17:12 sles12_data.qcow2
  ```

* 虚拟机支持磁盘文件动态添加，不需要停止虚拟机或者重启:

  ```bash
  virsh attach-disk test_02 --source /data/virthost/test_02_expand.qcow2 --config --target vdb --persistent --subdriver qcow2
  #--config: 设置的同时更改虚拟机xml文件，这样就可以保证虚拟机重启后仍然生效
  #--persistent: 重启生效，相当于–config --live
  #--source：代表磁盘的源，可以是一个磁盘文件或一个物理设备；
  #--target：代表磁盘在虚拟机中的目标设备名称，例如vda、vdb等。
  #--subdriver：这一项是必须的，如果不加的话，虚拟机不知道镜像文件的格式
  ```

* 在虚拟机 中格式化并挂载XFS文件系统:

  ```
  mkfs.xfs /dev/vdb
  mkdir /data
  echo "/dev/vdb /data xfs defaults 0 0" >> /etc/fstab
  mount /data
  ```

　　‍

　　此时，刚才5G空间的 `/dev/vdb`​ 已挂载到目录 `/data`​ 。所以，我们下一步开始在线扩容。

### 调整磁盘空间，需要关闭虚拟机

* 在物理主机(host主机)上使用使用 `qemu-img resize`​ 命令调整虚拟机磁盘大小:

  ```
  qemu-img resize /data/test_01.qcow2 +30G

  ```

### 动态调整磁盘空间

* ​`virsh blockresize`​ 命令支持在线调整虚拟镜像，实际是通过底层 [QEMU Monitor管理虚拟机](https://cloud-atlas.readthedocs.io/zh_CN/latest/kvm/qemu/qemu_monitor.html#qemu-monitor) 指令实现:

  ```
  virsh blockresize test_02 vdb --size 15G
  ```

* 此时在虚拟机 `test_02`​ 内部执行 `lsblk`​ 命令可以看到原先5G磁盘改成了15G:

  ```
  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  ...
  vdb    253:16   0   15G  0 disk /data

  ```

* 注意，此时文件系统显示挂载的磁盘还是5G空间:

  ```
  Filesystem      Size  Used Avail Use% Mounted on
  ...
  /dev/vdb        5.0G  3.7G  1.4G  73% /data

  ```

　　备注：对于最新的Guest内核， `virtio-blk`​ 设备大小是自动更新的，所以会马上看到容量改变。对于旧内核需要重启guest系统。对于SCSI设备，需要在guest操作系统中触发一次扫描:

```
echo > /sys/class/scsi_device/0:0:0:0/device/rescan

```

* XFS文件系统支持在线调整:

  ```bash
  xfs_growfs /data
  ```

　　‍

### 在线添加光盘

　　在线添加光盘命令比较简单，直接使用下面命令即可，注意`vdd`​应当没有被使用

```
virsh attach-disk Centos7 /data_lij/iso/CentOS-6.4-x86_64-bin-DVD1.iso vdb
```

　　‍

## 二、网卡热添加

- 网卡添加

```
#桥接
[root@zutuanxue ~]# virsh attach-interface --domain centos8-3 --type bridge --source br0 --model virtio --config
成功附加接口

#NAT
[root@zutuanxue ~]# virsh attach-interface --type network --domain centos8-3 --source default --config
成功附加接口



关于type  source不会写的可以参考xml文件
<interface type='network'>
      <mac address='52:54:00:30:38:55'/>
      <source network='default'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x09' slot='0x01' function='0x0'/>
    </interface>

可以看到  type   ”source network“这两个字段吧
```

- 网卡剥离

　　剥离要指定剥离网卡的Mac地址

```
永久剥离
[root@zutuanxue ~]# virsh detach-interface --domain centos8-3 --mac 52:54:00:43:b8:3c --type bridge --config
成功分离接口

临时剥离
[root@zutuanxue ~]# virsh detach-interface --domain centos8-3 --mac 52:54:00:95:b7:0e --type network
成功分离接口
```

## 三、内存热添加

　　**扩容内存**

```bash
内存热添加的基础是必须设置最大内存的容量，否则无法添加，最大扩展不能超过最大分配
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

　　**缩小内存**

　　同样的方法，指定内存目标容量即可

```bash
virsh setmem  centos8-3  512M --live 
#永久
virsh setmem  centos8-3  512M --live --config
```

## 四、CPU热添加

　　**添加CPU**

　　该虚拟机必须指定了最大cpu数量 –**vcpu**s 5,max**vcpu**s=10

```
临时
[root@zutuanxue ~]# virsh setvcpus --domain centos8-3 6 --live

永久
[root@zutuanxue ~]# virsh setvcpus --domain centos8-3 6 --live --config 
```

　　注意：CPU目前是不支持回收的。

## 五、通过修改配置文件

　　**注意：** 增大虚拟机内存、增加虚拟机 CPU 个数需要首先关机虚拟机

### 1.关闭虚拟机

```
virsh shutdown ehs-jboss-01
```

### 2.编辑虚拟机配置文件

　　修改内存**memory 和 currentMemory 参数来调整内存大小；**

　　修改 CPU vcpu 参数来调整 CPU 个数(核数)；

```
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

```
[root@ehs-as-04 ~]# virsh create /etc/libvirt/qemu/ehs-jboss-01.xml 
域 ehs-jboss-01 被创建（从 /etc/libvirt/qemu/ehs-jboss-01.xml）
```

### 4.查看当前内存大小

```
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

```
[root@kvm01 ~]# virsh setmem ehs-jboss-01 8388608
```

### 6.验证

　　查看当前内存大小

```
[root@kvm01 ~]# virsh dominfo ehs-jboss-01 | grep memory
Max memory: 1048432 KiB
Used memory: 1048432 KiB
```

　　查看当前CPU个数

```
[root@kvm01 ~]# virsh dominfo ehs-jboss-01 | grep CPU
CPU(s): 2
CPU time: 15.0s
```

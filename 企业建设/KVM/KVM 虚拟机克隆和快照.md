#kvm 

## 虚拟机克隆

注意事项：被克隆的机器最好先做成模板机，否者很多唯一性的东西还得手动删除，就是制作模板机的那些删除数据。

```bash
### 自动克隆
virt-clone -o Rocky9_template -n k8s-master1 -f /data/qemu/images/k8s-master1.qcow2

### 手动克隆
# 1. 复制一个磁盘镜像文件
cp /data/qemu/images/Rocky9_template.qcow2   /data/qemu/images/k8s-master2.qcow2
# 2. 复制一个虚拟机的xml文件
virsh dumpxml --domain Rocky9_template > /etc/libvirt/qemu/k8s-master2.xml
# 3. 修改xml文件 将原始机器的唯一性配置删除
   # - 修改虚拟机名字
   # - 删除UUID
   # - 删除mac地址
   # - 修改磁盘路径
# 4. 导入虚拟机
virsh define --file /etc/libvirt/qemu/k8s-master2.xml 



```


## 虚拟机快照

KVM 快照的定义：快照就是将虚机在某一个时间点上的磁盘、内存和设备状态保存一下，以备将来之用。它包括以下几类：

### 磁盘快照

在一个运行着的系统上，一个磁盘快照很可能只是崩溃一致的（crash-consistent）  而不是完整一致（clean）的，也是说它所保存的磁盘状态可能相当于机器突然掉电时硬盘数据的状态，机器重启后需要通过 fsck  或者别的工具来恢复到完整一致的状态（类似于 Windows 机器在断电后会执行文件检查）。(注：命令 qemu-img check -f  qcow2 --output=qcow2 -r all filename-img.qcow2 可以对 qcow2 和 vid  格式的镜像做一致性检查。)
对一个非运行中的虚机来说，如果上次虚机关闭的时候磁盘是完整一致的，那么其被快照的磁盘快照也将是完整一致的。

磁盘快照有两种：
- 内部快照 - 使用单个的 qcow2 的文件来保存快照和快照之后的改动。这种快照是 libvirt 的默认行为，现在的支持很完善（创建、回滚和删除），但是只能针对 qcow2 格式的磁盘镜像文件，而且其过程较慢等。
- 外部快照 -  快照是一个只读文件，快照之后的修改是另一个 qcow2 文件中。外置快照可以针对各种格式的磁盘镜像文件。外置快照的结果是形成一个 qcow2  文件链：original <- snap1 <- snap2 <- snap3

1. 创建快照备份

    ```bash
    virsh snapshot-create    <虚拟机名称>
    virsh snapshot-create-as <虚拟机名称> <快照名称> "<快照描述>"
    virsh snapshot-delete    <虚拟机名称> <快照名称> # 删除快照
    virsh snapshot-list      <虚拟机名称>
    virsh snapshot-info      <虚拟机名称> <快照名称>
	virsh snapshot-revert    <虚拟机名称> <快照名称> # 恢复快照
    ```

2. 查看虚拟机快照

    ```bash
    root@localhost:~ # virsh snapshot-list rac01
     Name         Creation Time               State
    ---------------------------------------------------
     1708328988   2024-02-19 15:49:48 +0800   shutoff


    # 快照配置文件在/var/lib/libvirt/qemu/snapshot/虚拟机名称/下
    ```

3. 恢复虚拟机快照

    3.1 恢复虚拟机快照必须关闭虚拟机。

    ```bash
    root@localhost:~ # virsh list --all
     Id   Name              State
    ----------------------------------
     -    CentOS7.9_templ   shut off
     -    rac-storage       shut off
     -    rac01             shut off
     -    rac02             shut off

    root@localhost:~ # 
    ```

    3.2 确认需要恢复的快照时间，然后确定恢复到1708328988

    ```bash
    virsh snapshot-revert rac01 1708328988
    ```

### 内存快照

只是保持内存和虚机使用的其它资源的状态。如果虚机状态快照在做和恢复之间磁盘没有被修改，那么虚机将保持一个持续的状态；如果被修改了，那么很可能导致数据corruption。
系统还原点（system checkpoint）：虚机的所有磁盘的快照和内存状态快照的集合，可用于恢复完整的系统状态（类似于系统休眠）。

创建内存快照
```bash
virsh save --bypass-cache CentOS7  /opt/backup/vm1_save --running
```

内存数据被保存到 raw 格式的文件中。要恢复的时候，可以运行 `vish restore /opt/backup/vm1_save`​命令从保存的文件上恢复。

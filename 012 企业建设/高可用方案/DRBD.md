# DRBD

## DRBD介绍

　　DRBD（Distributed ReplicatedBlock  Device）是一种基于软件的，无共享，分布式块设备复制的存储解决方案，在服务器之间的对块设备（硬盘，分区，逻辑卷等）进行镜像。也就是说当某一个应用程序完成写操作后，它提交的数据不仅仅会保存在本地块设备上，DRBD也会将这份数据复制一份，通过网络传输到另一个节点的块设备上，这样，两个节点上的块设备上的数据将会保存一致，这就是镜像功能。

　　DRBD是由内核模块和相关脚本而构成，用以构建高可用性的集群，其实现方式是通过网络来镜像整个设备。它允许用户在远程机器上建立一个本地块设备的实时镜像，与心跳连接结合使用，可以把它看作是一种网络RAID，它允许用户在远程机器上建立一个本地块设备的实时镜像。

　　DRBD工作在内核当中，类似于一种驱动模块。DRBD工作的位置在文件系统的buffer  cache和磁盘调度器之间，通过tcp/ip发给另外一台主机到对方的tcp/ip最终发送给对方的drbd，再由对方的drbd存储在本地对应磁盘  上，类似于一个网络RAID-1功能。在高可用(HA)中使用DRBD功能，可以代替使用一个共享盘阵。本地(主节点)与远程主机(备节点)的数据可以保 证实时同步。当本地系统出现故障时,远程主机上还会保留有一份相同的数据,可以继续使用。

### DRBD工作原理

　　DRBD是一种块设备,可以被用于高可用(HA)之中.它类似于一个网络RAID-1功能.当你将数据写入本地  文件系统时,数据还将会被发送到网络中另一台主机上.以相同的形式记录在一个文件系统中。  本地(主节点)与远程主机(备节点)的数据可以保证实时同步.当本地系统出现故障时,远程主机上还会  保留有一份相同的数据,可以继续使用.在高可用(HA)中使用DRBD功能,可以代替使用一个共享盘阵.因为数据同时存在于本地主机和远程主机上,切换时,远程主机只要使用它上面的那份备份数据,就可以继续进行服务了。

　　DRBD是如何工作的（工作机制）

　　(DRBD Primary)负责接收数据，把数据写到本地磁盘并发送给另一台主机(DRBD  Secondary)，另一个主机再将数据存到自己的磁盘中。目前，DRBD每次只允许对一个节点进行读写访问，但这对于通常的故障切换高可用集群来说已经足够用了。以后的版本将支持两个节点进行读写存取。

### DRBD的复制模式

1. protocol A: 异步写入，只要本地磁盘写入完成，另外一份拷贝的数据包在发送队列中，则认为一个写操作过程完成。
2. protocol B: 半同步写入，只要本地磁盘写入完成，另外一份拷贝的数据包已经到达远程节点，则认为一个写操作过程完成。
3. protocol C: 同步写入，只有本地和远程节点的磁盘都已经确认了写操作完成，则认为一个写操作过程完成。

### DRBD与HA的关系

　　一个DRBD系统由两个节点构成，与HA集群类似，也有主节点和备用节点之分，在带有主要设备的节点上，应用程序和操作系统可以运行和访问DRBD设备（/dev/drbd\*）。在主节点写入的数据通过DRBD设备存储到主节点的磁盘设备中，同时，这个数据也会自动发送到备用节点对应的DRBD设备，最终写入备用节点的磁盘设备上，在备用节点上，DRBD只是将数据从DRBD设备写入到备用节点的磁盘中。现在大部分的高可用性集群都会使用共享存储，而DRBD也可以作为一个共享存储设备，使用DRBD不需要太多的硬件的投资。因为它在TCP/IP网络中运行，所以，利用DRBD作为共享存储设备，要节约很多成本，因为价格要比专用的存储网络便宜很多；其性能与稳定性方面也不错

## centos7 部署DRBD

　　step1（两节点都要执行）：配置hosts文件，配置免密

```bash
# step1（两节点都要执行）: 配置hosts文件，配置免密
cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.190.135 node1
192.168.190.136 node2
#--------------------------------------------

ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub node2
```

　　step2（两节点都要执行）：关闭防火墙，SELINUX，同步系统时间

```bash
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
#------------------------------------------
vi /etc/selinux/config
# 将SELINUX=enforcing改为SELINUX=disabled
# 同步系统时间
```

　　step3（两节点都要执行）：安装和配置DRBD

```bash
# step3（两节点都要执行）：安装和配置DRBD
[root@node1 ~]# yum install -y epel-release
[root@node1 ~]# yum install -y drbd
[root@node1 drbd.d]# mv /etc/drbd.d/global_common.conf /etc/drbd.d/global_common.conf.orig
[root@node1 drbd.d]# vi /etc/drbd.d/global_common.conf
[root@node1 drbd.d]# cat /etc/drbd.d/global_common.conf
global {
 usage-count  yes;
}
common {
 net {
  protocol C;
 }
}
[root@node1 drbd.d]# vi /etc/drbd.d/test.res
[root@node1 drbd.d]# cat /etc/drbd.d/test.res
resource test {
        on node1 {
                device /dev/drbd0;
                disk /dev/sdb1;
                        meta-disk internal;
                        address 192.168.190.135:7789;
        }
        on node2  {
                device /dev/drbd0;
                        disk /dev/sdb1;
                        meta-disk internal;
                        address 192.168.190.136:7789;
        }
}
[root@node1 ~]# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0xa63a1d3c.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): 
Using default response p
Partition number (1-4, default 1): 
First sector (2048-6291455, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-6291455, default 6291455): 
Using default value 6291455
Partition 1 of type Linux and of size 3 GiB is set

Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes, 6291456 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xa63a1d3c

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     6291455     3144704   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@node1 ~]# partx /dev/sdb
NR START     END SECTORS SIZE NAME UUID
 1  2048 6291455 6289408   3G    
[root@node1 ~]# drbdadm create-md test
modinfo: ERROR: Module drbd not found.
modinfo: ERROR: Module drbd not found.
initializing activity log
initializing bitmap (96 KB) to all zero
Writing meta data...
New drbd meta data block successfully created.
[root@node1 ~]# drbdadm up test
modinfo: ERROR: Module drbd not found.
modinfo: ERROR: Module drbd not found.
modprobe: FATAL: Module drbd not found.
Failed to modprobe drbd (No such file or directory)
Command 'drbdsetup new-resource test 1' terminated with exit code 20
[root@node1 ~]# lsmod | grep drbd
[root@node1 ~]# modprobe drbd
modprobe: FATAL: Module drbd not found.
```

　　上面报错是因为内核中没有drbd模块，可通过升级内核版本解决，升级完后需要重启。升级内核的步骤参考：

```bash
[root@node1 ~]# uname -a
Linux node1 5.19.8-1.el7.elrepo.x86_64 #1 SMP PREEMPT_DYNAMIC Tue Sep 6 15:12:14 EDT 2022 x86_64 x86_64 x86_64 GNU/Linux
[root@node1 ~]# modprobe drbd
[root@node1 ~]# lsmod |grep drbd
drbd                  389120  0 
lru_cache              16384  1 drbd
libcrc32c              16384  2 xfs,drbd
[root@node1 ~]# drbdadm up test
No valid meta data found
[root@node1 ~]# drbdadm create-md test
You want me to create a v08 style flexible-size internal meta data block.
There appears to be a v09 flexible-size internal meta data block
already in place on /dev/sdb1 at byte offset 3220172800

Valid v09 meta-data found, convert to v08?
[need to type 'yes' to confirm] yes

Writing meta data...
New drbd meta data block successfully created.
success
[root@node1 ~]# drbdadm up test
[root@node1 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdb               8:16   0    3G  0 disk 
└─sdb1            8:17   0    3G  0 part 
  └─drbd0       147:0    0    3G  1 disk 
sr0              11:0    1 1024M  0 rom  
sda               8:0    0   20G  0 disk 
├─sda2            8:2    0   19G  0 part 
│ ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
│ └─centos-root 253:0    0   17G  0 lvm  /
└─sda1            8:1    0    1G  0 part /boot
[root@node1 ~]# drbdadm status test
test role:Secondary
  disk:Inconsistent
  peer role:Secondary
    replication:Established peer-disk:Inconsistent

[root@node1 ~]# drbdsetup status test --verbose --statistics
test role:Secondary suspended:no
    write-ordering:flush
  volume:0 minor:0 disk:Inconsistent
      size:3144572 read:0 written:0 al-writes:8 bm-writes:0 upper-pending:0 lower-pending:0 al-suspended:no blocked:no
  peer connection:Connected role:Secondary congested:no
    volume:0 replication:Established peer-disk:Inconsistent resync-suspended:no
        received:0 sent:0 out-of-sync:3144572 pending:0 unacked:0
```

> 因为还未配置主节点，不知道数据该从哪里往哪里同步，所以现在还未同步，两边数据不一致。

## 使用DRBD

> 之前的部署步骤都是两个节点都需要执行的，下面的步骤都是单节点执行

```bash
[root@node1 ~]# drbdadm primary --force test
[root@node1 ~]# drbdadm status test
test role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:SyncSource peer-disk:Inconsistent done:0.34
# 现在两节点正在同步，完成0.34%，数据仍然不一致。等待一段时间，完成98.96%
[root@node1 ~]# drbdadm status test
test role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:SyncSource peer-disk:Inconsistent done:98.96
# 再等待一段时间，完成同步
[root@node1 ~]# drbdadm status test
test role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:Established peer-disk:UpToDate
```

　　‍

```bash
[root@node1 ~]# mkfs -t ext4 /dev/drbd0
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
196608 inodes, 786143 blocks
39307 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=805306368
24 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done                          
Writing inode tables: done                          
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

[root@node1 ~]# mkdir -p /mnt/DRDB_PRI/
[root@node1 ~]# mount /dev/drbd0 /mnt/DRDB_PRI/
[root@node1 ~]# cd /mnt/DRDB_PRI/
[root@node1 DRDB_PRI]# ls
lost+found
[root@node1 DRDB_PRI]# touch a b c
[root@node1 DRDB_PRI]# mkdir d e f
[root@node1 DRDB_PRI]# ls
a  b  c  d  e  f  lost+found
[root@node1 DRDB_PRI]# cd 
[root@node1 ~]# umount /mnt/DRDB_PRI/
[root@node1 ~]# drbdadm secondary test
```

　　上面在node1为主设备的时候，创建了一些文件和文件夹。现在切换成node2为主设备，发现数据都同步过来了。

```javascript
[root@node2 ~]# drbdadm primary test
[root@node2 ~]# mkdir -p /mnt/DRDB_SEC/
[root@node2 ~]# mount /dev/drbd0 /mnt/DRDB_SEC/
[root@node2 ~]# cd /mnt/DRDB_SEC/
[root@node2 DRDB_SEC]# ls
a  b  c  d  e  f  lost+found
```

## DRBD的应用：云主机的高可用存储方案

　　[云主机](https://cloud.tencent.com/product/cvm?from_column=20065&from=20065)的系统盘是放在本地存储上的（用的是所在节点的硬盘），一旦云主机所在节点硬盘故障了，可以通过nova的疏散命令，将云主机疏散至DRBD的备份从节点上，从而实现云主机的高可用。

　　例如：两个计算节点compute313或compute314，compute313的多块硬盘其中一块为主设备，compute314的多块硬盘其中一块为从设备，组成一对设备。compute313节点的硬盘坏了，且宕机且系统无法恢复。

　　将需要恢复的云主机的目录（目录名是云主机的uuid），cp 6fceaf2f-e201-4165-ba3a-f5d9c78160ab /var/lib/nova/instances/，多个云主机就复制多个目录。然后执行疏散命令 nova evacuate [instance uuid] [目的计算节点] –on-shared-storage 。

　　将上面的步骤写成程序就是云主机的高可用组件比如Openstack Masakari等。

> 过去[分布式存储](https://cloud.tencent.com/product/cos?from_column=20065&from=20065)方案还不成熟，DRBD还有一定的市场，现在处了少量老的需要维护的云计算中心还在使用，DRBD技术方案已经淘汰了。

## 附

　　本篇部署DRBD的步骤中的`step2（两节点都要执行）：关闭防火墙，SELINUX`​，的方式是采用最便捷的方式：直接关闭。实际中还需要使用防火墙和selinux服务，可以通过下面的方式加入drbd的配置：

```javascript
# 两个节点都执行
semanage permissive -a drbd_t

# node1执行
firewall-cmd --permanent --add-rich-rule='rule family="ipv4"  source address="192.168.190.136" port port="7789" protocol="tcp" accept'
firewall-cmd --reload

# node2执行
firewall-cmd --permanent --add-rich-rule='rule family="ipv4"  source address="192.168.190.135" port port="7789" protocol="tcp" accept'
firewall-cmd --reload
```

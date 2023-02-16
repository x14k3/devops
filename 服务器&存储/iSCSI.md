#server/storage

## iSCSI简介：

_SCSI_ 是小型计算机系统接口（Small Computer System Interface）的简称，于1979首次提出，是为小型机研制的一种接口技术，现在已完全普及到了小型机，高低端服务器以及普通PC上。
_iSCSI_（互联网小型计算机系统接口）是一种在TCP/IP上进行数据块传输的标准。它是由Cisco和IBM两家发起的，并且得到了各大存储厂商的大力支持。iSCSI可以实现在IP网络上运行SCSI协议，使其能够在诸如高速千兆以太网上进行快速的数据存取备份操作

## Linux下ISCSI服务搭建
_target端即磁盘阵列或其他装有磁盘的主机。通过iscsitarget工具将磁盘空间映射到网络上，initiator端就可以寻找发现并使用该磁盘。
注意，一个target主机上可以映射多个target到网络上，即可以映射多个块设备到网络上。_
服务器(Target)&ensp;&ensp;:10.0.0.9
客户端(Initiator)   :10.0.0.10

### 配置 target 服务端
```bash
# 关闭防火墙和selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl stop firewalld && systemctl disable firewalld

# 在服务端添加一块硬盘作为共享硬盘
lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0    5G  0 disk # 此处就是新添加的硬盘
sr0              11:0    1  4.4G  0 rom  

# 或者创建 RAID 磁盘阵列作为共享硬盘
lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   20G  0 disk 
sdc               8:32   0   20G  0 disk 
sdd               8:48   0   20G  0 disk 
sde               8:64   0   20G  0 disk 
sr0              11:0    1 1024M  0 rom 

mdadm -Cv /dev/md0 -n 3 -l 5 -x 1 /dev/sdb /dev/sdc /dev/sdd /dev/sde
# -Cv:参数为创建阵列并显示过程
# /dev/md0：为生成的阵列组名称
# -n 3：参数为创建RAID 5 磁盘阵列所需的硬盘个数
# -l 5：参数为RAID磁盘阵列的级别
# -x 1：参数为磁盘阵列的备份盘个数

# 查看raid组 并将 UUID 写入fstab
mdadm -D /dev/md0


# 安装服务及依赖包
yum -y install targetd targetcli
# 注意查看服务端进程发现,没有正常启动但并不影响他的共享功能
systemctl start targetd ; systemctl enable targetd

# targetcli 是用于管理 iSCSI 服务端存储资源的专用配置命令，它能够提供类似于 fdisk 命令的交互式配置功能，
# 将 iSCSI 象成“目录”的形式，我们只需将各类配置信息填入到相应的“目录”中即可。
```

==配置iSCSI 服务端共享资源==

把刚刚创建的 RAID 5 磁盘阵列 md0 文件加入到配置共享设备的“资源池”中，并将该文件重新命名为 disk0.
```bash
[root@localhost ~]# targetcli
Warning: Could not load preferences file /root/.targetcli/prefs.bin.
targetcli shell version 2.1.fb46
Copyright 2011-2013 by Datera, Inc and others.
For help on commands, type 'help'.

/> cd /backstores/block 
/backstores/block> create disk0 /dev/sdb # 或者create disk0 /dev/md0
/backstores/block> 
Created block storage object disk0 using /dev/sdb.
```

 ==创建 iSCSI target 名称及配置共享资源==
 
iSCSI target 名称是由系统自动生成的，这是一串用于描述共享资源的唯一字符串。系统在生成这个 target 名称后，还会在/iscsi 参数目录中创建一个与其字符串同名的新“目录”用来存放共享资源。我们需要把前面加入到 iSCSI 共享资源池中的硬盘设备添加到这个新目录中，这样用户在登录 iSCSI 服务端后，即可默认使用这硬盘设备提供的共享存储资源了。

```bash
/backstores/block> cd /iscsi 
/iscsi> create
Created target iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
```


==设置acl、luns、portals==

```bash

# iSCSI 协议是通过客户端名称进行验证的，也就是说，用户在访问存储共享资源时不需要输入密码，
# 只要 iSCSI 客户端的名称与服务端中设置的访问控制列表中某一名称条目一致即可，
# 因此需要在 iSCSI 服务端的配置文件中写入一串能够验证用户信息的名称。
# acls 参数目录用于存放能够访问 iSCSI 服务端共享存储资源的客户端名称。
/iscsi> cd /iscsi/iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e/
/iscsi/iqn.20....594f9eedc5d9> cd tpg1/acls/
/iscsi/iqn.20...5d9/tpg1/acls> create iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e
Created Node ACL for iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e
Created mapped LUN 0.
/iscsi/iqn.20...82e/tpg1/acls> cd ../luns 
/iscsi/iqn.20...82e/tpg1/luns> create /backstores/block/disk0 
Created LUN 0.
Created LUN 0->0 mapping in node ACL iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e
/iscsi/iqn.20...82e/tpg1/luns>

# 位于生产环境中的服务器上可能有多块网卡，那么到底是由哪个网卡或 IP 地址对外提供共享存储资源呢？  
# 这就需要我们在配置文件中手动定义 iSCSI 服务端的信息，即在 portals 参数目录中写上服务器的 IP 地址。
/iscsi/iqn.20...82e/tpg1/luns> cd ../portals/
/iscsi/iqn.20.../tpg1/portals> create 10.0.0.9
Using default IP port 3260
Could not create NetworkPortal in configFS
/iscsi/iqn.20.../tpg1/portals> delete 0.0.0.0
Missing required parameter ip_port
/iscsi/iqn.20.../tpg1/portals> delete 0.0.0.0 3260
Deleted network portal 0.0.0.0:3260
/iscsi/iqn.20.../tpg1/portals> create 10.0.0.9
Using default IP port 3260
Created network portal 10.0.0.9:3260.
/iscsi/iqn.20.../tpg1/portals> 
```


==配置妥当后检查配置信息，重启 iSCSI 服务端程序==

```bash
/iscsi/iqn.20.../tpg1/portals> cd /
/> ls
o- / ......................................................................................................... [...]
  o- backstores .............................................................................................. [...]
  | o- block .................................................................................. [Storage Objects: 1]
  | | o- disk0 ............................................................ [/dev/sdb (5.0GiB) write-thru activated]
  | |   o- alua ................................................................................... [ALUA Groups: 1]
  | |     o- default_tg_pt_gp ....................................................... [ALUA state: Active/optimized]
  | o- fileio ................................................................................. [Storage Objects: 0]
  | o- pscsi .................................................................................. [Storage Objects: 0]
  | o- ramdisk ................................................................................ [Storage Objects: 0]
  o- iscsi ............................................................................................ [Targets: 1]
  | o- iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e .......................................... [TPGs: 1]
  |   o- tpg1 ............................................................................... [no-gen-acls, no-auth]
  |     o- acls .......................................................................................... [ACLs: 1]
  |     | o- iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e ............................. [Mapped LUNs: 1]
  |     |   o- mapped_lun0 ................................................................. [lun0 block/disk0 (rw)]
  |     o- luns .......................................................................................... [LUNs: 1]
  |     | o- lun0 ...................................................... [block/disk0 (/dev/sdb) (default_tg_pt_gp)]
  |     o- portals .................................................................................... [Portals: 1]
  |       o- 10.0.0.9:3260 .................................................................................... [OK]
  o- loopback ......................................................................................... [Targets: 0]
/> 
/> 
/> saveconfig
Configuration saved to /etc/target/saveconfig.json
/> exit
Global pref auto_save_on_exit=true
Last 10 configs saved in /etc/target/backup/.
Configuration saved to /etc/target/saveconfig.json
root@devops ~ $ 

systemctl restart targetd
```
&emsp;
### 配置 initiator 客户端
在RHEL 7系统中，已经默认安装了iSCSI客户端服务程序initiator。如果您的系统没有安装的话，可以使用Yum软件仓库手动安装。

```bash
# 安装客户端
yum -y install iscsi-initiator-utils

# 修改配置文件
vim /etc/iscsi/initiatorname.iscsi 
----------------------------------------------------------------
InitiatorName=iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e

----------------------------------------------------------------

# 启动initiator
systemctl restart iscsid ; systemctl status iscsid ; systemctl enable iscsid

# iscsi访问并使用共享存储资源
# iscsiadm 是用于管理、查询、插入、更新或删除 iSCSI数据库配置文件的命令行工具

# iscsiadm的命令汇总 
# 1.发现iscsi存储: iscsiadm -m discovery -t st -p ISCSI_IP
# 2.查看iscsi发现记录 iscsiadm -m node
# 3.删除iscsi发现记录 iscsiadm -m node -o delete -T LUN_NAME -p ISCSI_IP
# 4.登录iscsi存储 iscsiadm -m node -T LUN_NAME -p ISCSI_IP -l
# 5.登出iscsi存储 iscsiadm -m node -T LUN_NAME -p ISCSI_IP -u
# 6 显示会话情况  iscsiadm -m session

# 发现iscsi存储
[root@test ~]# iscsiadm -m discovery -t st -p 10.0.0.9
10.0.0.9:3260,1 iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e
[root@test ~]# 
# 发现了远程服务器上可用的存储资源后，接下来准备登录 iSCSI 服务端
[root@test ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e -p 10.0.0.9 --login
Logging in to [iface: default, target: iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e, portal: 10.0.0.9,3260] (multiple)
Login to [iface: default, target: iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e, portal: 10.0.0.9,3260] successful.
[root@test ~]# 
# 登录成功之后，会在客户端主机上多出一个dev/sdb
[root@test ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   35G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0    5G  0 disk 
sr0              11:0    1 1024M  0 rom  
[root@test ~]#
# 可以对该磁盘进行格式化
[root@test ~]# mkfs.xfs /dev/sdb
meta-data=/dev/sdb               isize=512    agcount=4, agsize=327680 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=1310720, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@test ~]# 
# 挂在到目录
[root@test ~]# mkdir /iscsi ; mount /dev/sdb /iscsi/
# 查询UUID，永久挂载
[root@test iscsi]# blkid | grep /dev/sdb
/dev/sdb: UUID="e45e7884-8204-413e-b45d-00b91da83f55" TYPE="xfs" 
[root@test iscsi]# vim /etc/fstab
------------------------------------------------------------------------
UID=e45e7884-8204-413e-b45d-00b91da83f55 /iscsi xfs defaults,_netdev 0 0
------------------------------------------------------------------------
# 由于/dev/sdb 是一块网络存储设备，而 iSCSI 协议是基于TCP/IP 网络传输数据的，
# 因此必须在/etc/fstab 配置文件中添加上_netdev 参数，表示当系统联网后再进行挂载操作，以免系统开机时间过长或开机失败

# 如果不使用iscsi共享设备，可以用 iscsiadm 命令的-u 参数将其设备卸载：  
[root@test iscsi]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.test.x8664:sn.e181f5b7782e -u
```
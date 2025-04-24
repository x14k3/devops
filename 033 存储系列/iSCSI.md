# iSCSI

# ISCSI服务简介

iscsi 结构基于客户/服务器模型，其主要功能是在TCP/IP网络上的主机系统（启动器initlator）和存储设备（目标  target） 之间进行大量的数据封装和可靠传输过程，此外，iscsi 提供了在IP网络封装SCSI命令，且运行在TCP上。

ISCSI 这个架构主要将存储装置与使用的主机分别为两部分，分别是：

* ISCSI  target ：就是存储设备端，存放磁盘或RAID的设备，目前也能够将Linux主机仿真成ISCSI  target了，目的在提供其他主机使用的磁盘。
* ISCSI  inITiator： 就是能够使用target的客户端，通常是服务器，只有装有iscsi initiator的相关功能后才能使用ISCSI  target 提供的磁盘。

**服务器取得磁盘或者文件系统的方式**

1. 直接存取：在本机上的磁盘，就是直接存取设备
2. 透过存储局域网络（SAN），来自区网内的其他设备提供的磁盘。
3. 网络文件系统NAS（：来自NAS提供的文件系统）只能立即使用，不能进行格式化。

‍

# Linux下ISCSI服务搭建

iSCSI技术在工作形式上分为服务端（target）与客户端（initiator）。iSCSI服务端即用于存放硬盘存储资源的服务器，它作为前面创建的RAID磁盘阵列的存储端，能够为用户提供可用的存储资源。iSCSI客户端则是用户使用的软件，用于访问远程服务端的存储资源。

1. iscsi server被称为target  server，模拟scsi设备，后端存储设备可以使用文件/LVM/磁盘/RAID等不同类型的设备；启动设备（initiator）：发起I/O请求的设备，需要提供iscsi服务，比如PC机安装iscsi-initiator-utils软件实现，或者通过网卡自带的PXE启动。esp+ip+scsi
2. iscsi再传输数据的时候考虑了安全性，可以通过IPSEC  对流量加密，并且iscsi提供CHAP认证机制以及ACL访问控制，但是在访问iscsi-target的时候需要IQN（iscsi完全名称，区分唯一的initiator和target设备），格式iqn.年月.域名后缀(反着写)：[target服务器的名称或IP地址]
3. iscsi使用TCP端口3260提供服务

## 配置 target 服务端

### **第一步：安装服务端程序target**，**添加要一块磁盘分区**

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
--------------------------------------------------------------
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
# -Cv:创建阵列并显示过程
# /dev/md0：为生成的阵列组名称
# -n 3：参数为创建RAID 5 磁盘阵列所需的硬盘个数
# -l 5：参数为RAID磁盘阵列的级别
# -x 1：参数为磁盘阵列的备份盘个数

# 查看raid组 并将 UUID 写入fstab
mdadm -D /dev/md0
-------------------------------------------------------------------------

# 安装服务及依赖包
yum -y install targetd targetcli

# CRITICAL:root:password not set in /etc/target/targetd.yaml 该报错不影响
systemctl start targetd ; systemctl enable targetd

# targetcli 是用于管理 iSCSI 服务端存储资源的专用配置命令，它能够提供类似于 fdisk 命令的交互式配置功能，
# 将 iSCSI 想象成“目录”的形式，我们只需将各类配置信息填入到相应的“目录”中即可。
```

### **第二步：配置iSCSI服务端共享资源**

targetcli是用于管理iSCSI服务端存储资源的专用配置命令，它能够提供类似于fdisk命令的交互式配置功能，将iSCSI共享资源的配置内容抽象成“目录”的形式，我们只需将各类配置信息填入到相应的“目录”中即可。这里的难点主要在于认识每个“参数目录”的作用。当把配置参数正确地填写到“目录”中后，iSCSI服务端也可以提供共享资源服务了。

在执行targetcli命令后就能看到交互式的配置界面了。在该界面中可以使用很多Linux命令，比如利用ls查看目录参数的结构，使用cd切换到不同的目录中。 **​`/backstores/block`​****是iSCSI服务端配置共享设备的位置**。我们需要把刚刚创建的磁盘分区文件加入到配置共享设备的“资源池”中，并将该文件重新命名为block1，这样用户就不会知道是由服务器中的哪块硬盘来提供共享存储资源，而只会看到一个名为block1的存储设备。

```bash
[root@localhost ~]# targetcli 
targetcli shell version 2.1.fb41
Copyright 2011-2013 by Datera, Inc and others.
For help on commands, type 'help'.

/> 
/> ls
o- / ...................................................... [...]
  o- backstores ........................................... [...]
  | o- block ............................... [Storage Objects: 0]
  | o- fileio .............................. [Storage Objects: 0]
  | o- pscsi ............................... [Storage Objects: 0]
  | o- ramdisk ............................. [Storage Objects: 0]
  o- iscsi ......................................... [Targets: 0]
  o- loopback ...................................... [Targets: 0]

/> cd /backstores/block 
/backstores/block> create block1 /dev/sdb # 或者create block1 /dev/md0
Created block storage object block1 using /dev/sdb.
```

### **第三步：创建iSCSI target名称及配置共享资源**

iSCSI   target名称是由系统自动生成的，这是一串用于描述共享资源的唯一字符串。稍后用户在扫描iSCSI服务端时即可看到这个字符串，因此我们不需要记住它。系统在生成这个target名称后，还会在/iscsi参数目录中创建一个与其字符串同名的新“目录”用来存放共享资源。我们需要把前面加入到iSCSI共享资源池中的硬盘设备添加到这个新目录中，这样用户在登录iSCSI服务端后，即可默认使用这硬盘设备提供的共享存储资源了。

```bash
/backstores/block> cd /iscsi 
#命名格式：iqn.yyyy-mm.<主机名（域名）反写>:自定义名称。自定义名称内不能有下划线
/iscsi> create iqn.2024-01.storage.oracle:rac
Created target iqn.2024-01.storage.oracle:rac.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.


/iscsi> ls
o- iscsi ....................................................... [Targets: 1]
  o- iqn.2024-01.storage.oracle:rac ............................... [TPGs: 1]
    o- tpg1 .......................................... [no-gen-acls, no-auth]
      o- acls ..................................................... [ACLs: 0]
      o- luns ..................................................... [LUNs: 0]
      o- portals ............................................... [Portals: 1]
        o- 0.0.0.0:3260 ................................................ [OK]
/iscsi> 


#创建需要共享的设备
/iscsi> cd iqn.2024-01.storage.oracle:rac/tpg1/luns 
/iscsi/iqn.20...rac/tpg1/luns>  
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-ocr-1
Created LUN 0.
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-ocr-2
Created LUN 1.
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-ocr-3
Created LUN 2.
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-data-1 
Created LUN 3.
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-data-2
Created LUN 4.
/iscsi/iqn.20...rac/tpg1/luns> create /backstores/block/ora-arch 
Created LUN 5.
/iscsi/iqn.20...rac/tpg1/luns> 

```

### <span id="20231110105237-zy2sps4" style="display: none;"></span>**第四步：设置访问控制列表（ACL）**

iSCSI协议是通过客户端名称进行验证的，也就是说，用户在访问存储共享资源时不需要输入密码，只要iSCSI客户端的名称与服务端中设置的访问控制列表中某一名称条目一致即可，因此需要在iSCSI服务端的配置文件中写入一串能够验证用户信息的名称。acls参数目录用于存放能够访问iSCSI服务端共享存储资源的客户端名称。推荐在刚刚系统生成的iSCSI  target后面追加上类似于:client的参数，这样既能保证客户端的名称具有唯一性，又非常便于管理和阅读。

```bash
/iscsi/iqn.20...rac/tpg1/luns> cd ../acls
/iscsi/iqn.20...rac/tpg1/acls> create iqn.2024-02.storage.oracle:client
Created Node ACL for iqn.2024-01.storage.oracle:client
Created mapped LUN 5.
Created mapped LUN 4.
Created mapped LUN 3.
Created mapped LUN 2.
Created mapped LUN 1.
Created mapped LUN 0.
/iscsi/iqn.20...rac/tpg1/acls> 

```

### **第五步：设置iSCSI服务端的监听IP地址和端口号。**

位于生产环境中的服务器上可能有多块网卡，那么到底是由哪个网卡或IP地址对外提供共享存储资源呢？这就需要我们在配置文件中手动定义iSCSI服务端的信息，即在portals参数目录中写上服务器的IP地址。接下来将由系统自动开启服务器192.168.245.128的3260端口将向外提供iSCSI共享存储资源服务：

```bash
/iscsi/iqn.20...rac/tpg1/acls> cd ../portals/
/iscsi/iqn.20.../tpg1/portals> ls
o- portals ..................................................... [Portals: 1]
  o- 0.0.0.0:3260 ...................................................... [OK]
/iscsi/iqn.20.../tpg1/portals> 

# 如果要修改监听ip或端口 执行以下操作
/iscsi/iqn.20.../tpg1/portals> create 10.10.0.203 ip_port=3260
Using default IP port 3260
Could not create NetworkPortal in configFS
```

### **第六步：配置妥当后检查配置信息，重启iSCSI服务端程序并配置防火墙策略**

在参数文件配置妥当后，可以浏览刚刚配置的信息，确保与下面的信息基本一致。**在确认信息无误后输入exit 命令来退出配置**。注意，千万不要习惯性地按Ctrl  +  C组合键结束进程，这样不会保存配置文件，我们的工作也就白费了。最后重启iSCSI服务端程序，再设置firewalld防火墙策略，使其放行3260/tcp端口号的流量。

```bash
/iscsi/iqn.20.../tpg1/portals> cd /
/> ls
o- / .................................................................. [...]
  o- backstores ....................................................... [...]
  | o- block ........................................... [Storage Objects: 6]
  | | o- ora-arch ................. [/dev/vdg (20.0GiB) write-thru activated]
  | | | o- alua ............................................ [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | | o- ora-data-1 ............... [/dev/vde (20.0GiB) write-thru activated]
  | | | o- alua ............................................ [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | | o- ora-data-2 ............... [/dev/vdf (20.0GiB) write-thru activated]
  | | | o- alua ............................................ [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | | o- ora-ocr-1 ................ [/dev/vdb (10.0GiB) write-thru activated]
  | | | o- alua ............................................ [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | | o- ora-ocr-2 ................ [/dev/vdc (10.0GiB) write-thru activated]
  | | | o- alua ............................................ [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | | o- ora-ocr-3 ................ [/dev/vdd (10.0GiB) write-thru activated]
  | |   o- alua ............................................ [ALUA Groups: 1]
  | |     o- default_tg_pt_gp ................ [ALUA state: Active/optimized]
  | o- fileio .......................................... [Storage Objects: 0]
  | o- pscsi ........................................... [Storage Objects: 0]
  | o- ramdisk ......................................... [Storage Objects: 0]
  o- iscsi ..................................................... [Targets: 1]
  | o- iqn.2024-01.storage.oracle:rac ............................. [TPGs: 1]
  |   o- tpg1 ........................................ [no-gen-acls, no-auth]
  |     o- acls ................................................... [ACLs: 1]
  |     | o- iqn.2024-01.storage.oracle:client ............. [Mapped LUNs: 6]
  |     |   o- mapped_lun0 ...................... [lun0 block/ora-ocr-1 (rw)]
  |     |   o- mapped_lun1 ...................... [lun1 block/ora-ocr-2 (rw)]
  |     |   o- mapped_lun2 ...................... [lun2 block/ora-ocr-3 (rw)]
  |     |   o- mapped_lun3 ..................... [lun3 block/ora-data-1 (rw)]
  |     |   o- mapped_lun4 ..................... [lun4 block/ora-data-2 (rw)]
  |     |   o- mapped_lun5 ....................... [lun5 block/ora-arch (rw)]
  |     o- luns ................................................... [LUNs: 6]
  |     | o- lun0 ........... [block/ora-ocr-1 (/dev/vdb) (default_tg_pt_gp)]
  |     | o- lun1 ........... [block/ora-ocr-2 (/dev/vdc) (default_tg_pt_gp)]
  |     | o- lun2 ........... [block/ora-ocr-3 (/dev/vdd) (default_tg_pt_gp)]
  |     | o- lun3 .......... [block/ora-data-1 (/dev/vde) (default_tg_pt_gp)]
  |     | o- lun4 .......... [block/ora-data-2 (/dev/vdf) (default_tg_pt_gp)]
  |     | o- lun5 ............ [block/ora-arch (/dev/vdg) (default_tg_pt_gp)]
  |     o- portals ............................................. [Portals: 1]
  |       o- 0.0.0.0:3260 .............................................. [OK]
  o- loopback .................................................. [Targets: 0]
/> 
/> 
/> saveconfig 
Configuration saved to /etc/target/saveconfig.json
/> 
/> exit
Global pref auto_save_on_exit=true
Last 10 configs saved in /etc/target/backup/.
Configuration saved to /etc/target/saveconfig.json
[root@ora19c-rac1 ~]# 

```

```bash
systemctl restart targetd
netstat -tunl | grep 3260
```

‍

## 配置 initiator 客户端

在RHEL 7系统中，已经默认安装了iSCSI客户端服务程序initiator。如果您的系统没有安装的话，可以使用Yum软件仓库手动安装。

```bash
yum -y install iscsi-initiator-utils
```

iSCSI协议是通过客户端的名称来进行验证，而该名称也是iSCSI客户端的唯一标识，而且必须与服务端配置文件中访问控制列表中的信息一致，否则客户端在尝试访问存储共享设备时，系统会弹出验证失败的保存信息。

下面我们编辑iSCSI客户端中的initiator名称文件，把服务端的访问控制列表名称填写进来，然后重启客户端iscsid服务程序并将其加入到开机启动项中：

```bash
[root@localhost ~]# vim /etc/iscsi/initiatorname.iscsi 
InitiatorName=iqn.2024-02.storage.oracle:client
[root@localhost ~]# systemctl restart iscsid
[root@localhost ~]# systemctl enable iscsid
```

iscsiadm是用于管理、查询、插入、更新或删除iSCSI数据库配置文件的命令行工具，用户需要先使用这个工具扫描发现远程iSCSI服务端，然后查看找到的服务端上有哪些可用的共享存储资源。其中，-m  discovery参数的目的是扫描并发现可用的存储资源，-t  st参数为执行扫描操作的类型，-p  192.168.245.128参数为iSCSI服务端的IP地址.可通过 `man iscsiadm | grep \\-mode`​ 来查看帮助。

```bash
# 发现iscsi存储
[root@test ~]# iscsiadm -m discovery -t st -p 10.10.0.203
10.10.0.203:3260,1 iqn.2024-01.storage.oracle:rac


# 发现了远程服务器上可用的存储资源后，接下来准备登录 iSCSI 服务端   
[root@test ~]# iscsiadm -m node -T iqn.2024-02.storage.oracle:rac -p 10.10.0.203 --login
Logging in to [iface: default, target: iqn.2024-02.storage.oracle:rac, portal: 10.10.0.203,3260] (multiple)
Login to [iface: default, target: iqn.2024-02.storage.oracle:rac, portal: 10.10.0.203,3260] successful.


[root@ora19c-rac1 grid]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk 
sdb      8:16   0   10G  0 disk 
sdc      8:32   0   10G  0 disk 
sdd      8:48   0   20G  0 disk 
sde      8:64   0   20G  0 disk 
sdf      8:80   0   20G  0 disk 
sr0     11:0    1 1024M  0 rom  
vda    253:0    0   60G  0 disk 
├─vda1 253:1    0    1G  0 part /boot
├─vda2 253:2    0    6G  0 part [SWAP]
├─vda3 253:3    0 35.6G  0 part /
├─vda4 253:4    0    1K  0 part 
└─vda5 253:5    0 17.4G  0 part /home
[root@ora19c-rac1 grid]# 


## ======================================================================# 
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

# iscsiadm 命令详解

```bash
#iscsiadm常用命令：
# 发现iSCSI存储
iscsiadm -m discovery -t st -p IP:port   
# 删除iSCSI发现记录
iscsiadm -m node -o delete -T TARGET -p IP:port
# 查看iSCSI发现记录
iscsiadm -m node
# 查看会话情况
iscsiadm -m session
# 登录iSCSI存储
iscsiadm -m node -T TARGET -p IP:port -l
# 登出iSCSI存储
iscsiadm -m node -T TARGET -p IP:port -u
```

‍

# 常见错误

1. 终端不断弹出以下警告：

```bash
[169409.608301]  connection1:0: detected conn error (1020)
[169413.613802]  connection1:0: detected conn error (1020)
[169417.617623]  connection1:0: detected conn error (1020)
[169421.624137]  connection1:0: detected conn error (1020)
[169425.630723]  connection1:0: detected conn error (1020)
[169429.636222]  connection1:0: detected conn error (1020)
[169433.641769]  connection1:0: detected conn error (1020)
[169437.648450]  connection1:0: detected conn error (1020)
[root@test ~]# tail -f /var/log/messages
Feb 13 10:30:30 test iscsid: iscsid: Kernel reported iSCSI connection 1:0 error (1020 - ISCSI_ERR_TCP_CONN_CLOSE: TCP connection closed) state (3)
Feb 13 10:30:32 test iscsid: iscsid: connection1:0 is operational after recovery (1 attempts)
Feb 13 10:30:34 test kernel: connection1:0: detected conn error (1020)
Feb 13 10:30:34 test iscsid: iscsid: Kernel reported iSCSI connection 1:0 error (1020 - ISCSI_ERR_TCP_CONN_CLOSE: TCP connection closed) state (3)
Feb 13 10:30:36 test iscsid: iscsid: connection1:0 is operational after recovery (1 attempts)
Feb 13 10:30:38 test kernel: connection1:0: detected conn error (1020)
Feb 13 10:30:38 test iscsid: iscsid: Kernel reported iSCSI connection 1:0 error (1020 - ISCSI_ERR_TCP_CONN_CLOSE: TCP connection closed) state (3)
Feb 13 10:30:40 test iscsid: iscsid: connection1:0 is operational after recovery (1 attempts)
```

经过排查发现是oracle-rac1和oracle-rac2节点共同使用同一个ACL-LUN-NAME导致，

参考[第四步：设置访问控制列表（ACL）](#20231110105237-zy2sps4)增加一个ACL，使得oracle-rac1和oracle-rac2使用不同的ACL即可

```bash
  o- iscsi  [Targets: 1]
  | o- iqn.2024-01.storage.oracle:rac  [TPGs: 1]
  |   o- tpg1  [no-gen-acls, no-auth]
  |     o- acls  [ACLs: 2]
  |     | o- iqn.2024-01.storage.oracle:client  [Mapped LUNs: 6]
  |     | | o- mapped_lun0  [lun0 block/ora-ocr-1 (rw)]
  |     | | o- mapped_lun1  [lun1 block/ora-ocr-2 (rw)]
  |     | | o- mapped_lun2  [lun2 block/ora-ocr-3 (rw)]
  |     | | o- mapped_lun3  [lun3 block/ora-data-1 (rw)]
  |     | | o- mapped_lun4  [lun4 block/ora-data-2 (rw)]
  |     | | o- mapped_lun5  [lun5 block/ora-arch (rw)]
  |     | o- iqn.2024-01.storage.oracle:client2  [Mapped LUNs: 6]
  |     |   o- mapped_lun0  [lun0 block/ora-ocr-1 (rw)]
  |     |   o- mapped_lun1  [lun1 block/ora-ocr-2 (rw)]
  |     |   o- mapped_lun2  [lun2 block/ora-ocr-3 (rw)]
  |     |   o- mapped_lun3  [lun3 block/ora-data-1 (rw)]
  |     |   o- mapped_lun4  [lun4 block/ora-data-2 (rw)]
  |     |   o- mapped_lun5  [lun5 block/ora-arch (rw)]
  |     o- luns  [LUNs: 6]
  |     | o- lun0  [block/ora-ocr-1 (/dev/vdb) (default_tg_pt_gp)]
  |     | o- lun1  [block/ora-ocr-2 (/dev/vdc) (default_tg_pt_gp)]
  |     | o- lun2  [block/ora-ocr-3 (/dev/vdd) (default_tg_pt_gp)]
  |     | o- lun3  [block/ora-data-1 (/dev/vde) (default_tg_pt_gp)]
  |     | o- lun4  [block/ora-data-2 (/dev/vdf) (default_tg_pt_gp)]
  |     | o- lun5  [block/ora-arch (/dev/vdg) (default_tg_pt_gp)]
  |     o- portals  [Portals: 1]
  |       o- 0.0.0.0:3260  [OK]
  o- loopback  [Targets: 0]

```

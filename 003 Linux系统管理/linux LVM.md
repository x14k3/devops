# linux LVM

在分区的时候，每个分区应该分多大是令人头疼的，而且随着长时间的运行，分区不管你分多大，都会被数据给占满。当遇到某个分区不够用时管理员可能甚至要备份整个系统、清除硬盘、重新对硬盘分区，然后恢复数据到新分区。

虽然现在有很多动态调整磁盘的工具可以使用，但是它并不能完全解决问题，因为某个分区可能会再次被耗尽；另外一个方面这需要重新引导系统才能实现，对于很多关键的服务器，停机是不可接受的，而且对于添加新硬盘，希望一个能跨越多个硬盘驱动器的文件系统时，分区调整程序就不能解决问题。

因此完美的解决方法应该是在零停机前提下可以自如对文件系统的大小进行调整，可以方便实现文件系统跨越不同磁盘和分区。那么我们可以通过逻辑盘卷管理（LVM，Logical Volume Manager）的方式来非常完美的实现这一功能。

解决思路：将所有可用存储汇集成池，当池中某个分区空间不够时就会从池中继续划分空间给分区，池中空间不够就可以通过加硬盘的方式来解决。

# 一、逻辑卷介绍

逻辑卷（LVM）：它是Linux环境下对磁盘分区进行管理的一种机制，它是建立在**物理存储设备**之上的一个抽象层，优点在于**灵活**管理。
**特点：**
1、动态在线扩容
2、离线裁剪
3、数据条带化
4、数据镜像

# 二、名词解释

LVM 中的基本概念：

- 物理存储设备(Physical Media)：指系统的存储设备文件，比如 /dev/sda、/dev/sdb 等。
- PV(物理卷 Physical Volume)：指硬盘分区或者从逻辑上看起来和硬盘分区类似的设备(比如 RAID 设备)。
- VG(卷组 Volume Group)：类似于非 LVM 系统中的物理硬盘，一个 LVM 卷组由一个或者多个 PV(物理卷)组成。
- LV(逻辑卷 Logical Volume)：类似于非 LVM 系统上的磁盘分区，LV 建立在 VG 上，可以在 LV 上建立文件系统。
- PE(Physical Extent)：PV(物理卷)中可以分配的最小存储单元称为 PE，PE 的大小是可以指定的。
- LE(Logical Extent)：LV(逻辑卷)中可以分配的最小存储单元称为 LE，在同一个卷组中，LE 的大小和 PE 的大小是一样的，并且一一对应。

# 三、逻辑卷常用命令

## 3.1 物理卷管理

### 3.1.1物理卷的创建:pvcreate命令

```bash
pvcreate    [命令选项]    [参数]
将物理分区转换为物理卷

命令选项
-f：强制创建物理卷，不需要用户确认；
-u：指定设备的UUID；
-y：所有的问题都回答“yes”；
-Z：是否利用前4个扇区。
```

### 3.1.2物理卷的移除:pvremove命令

```
pvremove    [命令选项]    [参数]
将物理卷转换为普通linux分区

命令选项
-d  调试模式
-f  强制删除
-y  对提问回答“yes”
```

### 3.1.3物理卷查看命令:pvscan

```
pvs     显示PV简况
pvdisplay   显示PV详细信息
```

### 3.1.4物理卷扫描命令:pvscan

```
pvscan 扫描pv设备
```

### 3.1.5删除物理卷: pvremove

```
# 删除PV sdb1 sdc1
[root@zutuanxue ~]# pvremove /dev/sdb1 /dev/sdc1
```

## 3.2 卷组管理

将多个物理卷组成一个卷组，形成一个存储池

### 3.2.1卷组创建：vgcreate命令

```
# 将pv sdb1 sdc1创建成卷组VG1000  PE大小为32M
[root@zutuanxue ~]# vgcreate -s 32 vg1000 /dev/sdb1 /dev/sdc1
```

### 3.2.2删除卷组中的PV：vgreduce命令

```
# 将vg1000卷组中的PV sdb1删除
[root@zutuanxue ~]# vgreduce /dev/vg1000 /dev/sdb1
```

### 3.2.3扩容卷组：vgextend命令

```
# 将pv sdb1 加入卷组vg1000
[root@zutuanxue ~]# vgextend /dev/vg1000 /dev/sdb1
```

### 3.2.4删除卷组：vgremove命令

```
# 删除vg1000卷组
[root@zutuanxue ~]# vgremove /dev/vg1000/
```

## 3.3 逻辑卷管理

### 3.3.1逻辑卷创建:lvcreate命令

```
# 从卷组vg1000上创建一个lv99的逻辑卷，容量为3G。
[root@zutuanxue ~]# lvcreate -n lv99 -L 3G /dev/vg1000
```

### 3.3.2逻辑卷扩容: lvextend命令

```
# 注意扩容顺序，不能颠倒
# a、扩容逻辑卷
[root@zutuanxue ~]# lvextend -L 3.5G /dev/vg1000/lv99
# b、扩容文件系统
[root@zutuanxue ~]# resize2fs /dev/vg1000/lv99
```

### 3.3.3逻辑卷缩小：lvreduce命令

```
# 注意扩容顺序，不能颠倒
# a、扫描逻辑卷文件系统，清晰该逻辑卷的使用情况，注意只能缩未使用的空间
[root@zutuanxue ~]# e2fsck -f /dev/vg1000/lv99
# b、缩小文件系统
[root@zutuanxue ~]# resize2fs /dev/vg1000/lv99 2G
# c、缩小逻辑卷
[root@zutuanxue ~]# lvreduce -L 2G /dev/vg1000/lv99 (lvresize)
```

### 3.3.4逻辑卷移除

```
#remove LVM
# 卸载分区
[root@zutuanxue ~]# umount /dev/vg1000/lv99
# 删除逻辑卷
[root@zutuanxue ~]# lvremove /dev/vg1000/lv99
```

# 四、逻辑卷应用

案例思路：

1. 物理的设备
2. 将物理设备做成物理卷
3. 创建卷组并将物理卷加入其中
4. 创建逻辑卷
5. 格式化逻辑卷
6. 挂载使用

案例实现

```bash
# 步骤：
# 1. 物理设备
[root@zutuanxue ~]# lsblk /dev/sdb
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sdb      8:16   0  20G  0 disk 
├─sdb1   8:17   0   2G  0 part /disk1
├─sdb2   8:18   0   2G  0 part 
├─sdb3   8:19   0   2G  0 part 
├─sdb4   8:20   0   2G  0 part 
└─sdb5   8:21   0   2G  0 part 


# 2. 创建物理卷
[root@zutuanxue ~]# pvcreate /dev/sdb{1,2}
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdb2" successfully created.
查看物理卷：
[root@zutuanxue ~]# pvs
  PV         VG Fmt  Attr PSize   PFree
  /dev/sda2  cl lvm2 a--  <19.00g    0 
  /dev/sdb1     lvm2 ---    2.00g 2.00g
  /dev/sdb2     lvm2 ---    2.00g 2.00g
[root@zutuanxue ~]# pvscan 
  PV /dev/sda2   VG cl              lvm2 [<19.00 GiB / 0    free]
  PV /dev/sdb1                      lvm2 [2.00 GiB]
  PV /dev/sdb2                      lvm2 [2.00 GiB]
  Total: 3 [<23.00 GiB] / in use: 1 [<19.00 GiB] / in no VG: 2 [4.00 GiB]

[root@zutuanxue ~]# pvdisplay /dev/sdb1 
  "/dev/sdb1" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1		#物理卷名称
  VG Name               						#卷组名称
  PV Size               2.00 GiB		#大小
  Allocatable           NO					#是否已分配出去
  PE Size               0   				#PE大小
  Total PE              0						#PE总数
  Free PE               0						#空闲PE
  Allocated PE          0						#可分配PE
  PV UUID               3M4...lT		#UUID


# 3. 创建卷组并将物理卷加入其中
[root@zutuanxue ~]# vgcreate vg1 /dev/sdb{1,2}
  Volume group "vg1" successfully created
查看卷组信息：
[root@zutuanxue ~]# vgs vg1
  VG  #PV #LV #SN Attr   VSize VFree
  vg1   2   0   0 wz--n- 3.99g 3.99g
  
[root@zutuanxue ~]# vgscan	#扫描系统中有哪些卷组
  Reading all physical volumes.  This may take a while...
  Found volume group "vg1" using metadata type lvm2
  Found volume group "cl" using metadata type lvm2
  
 [root@zutuanxue ~]# vgdisplay vg1
  --- Volume group ---
  VG Name               vg1
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               3.99 GiB		#卷组大小
  PE Size               4.00 MiB		#PE大小
  Total PE              1022				#PE数量
  Alloc PE / Size       0/0   		#已分配的PE/容量
  Free  PE / Size       1022/3.99 GiB	#可分配的PE/容量
  VG UUID               CQ6p...K9I

# 4. 创建逻辑卷
[root@zutuanxue ~]# lvcreate -n lv1 -L 2.5G vg1 
  Logical volume "lv1" created.
在操作系统层面映射两个地方：
[root@zutuanxue ~]# ll /dev/mapper/vg1-lv1 
lrwxrwxrwx 1 root root 7 12月 10 05:47 /dev/mapper/vg1-lv1 -> ../dm-2
[root@zutuanxue ~]# ll /dev/vg1/lv1 
lrwxrwxrwx 1 root root 7 12月 10 05:47 /dev/vg1/lv1 -> ../dm-2
[root@zutuanxue ~]# ll /dev/dm-2 
brw-rw---- 1 root disk 253, 2 12月 10 05:47 /dev/dm-2

lvcreate参数
-n：指定逻辑卷的名字
-L：指定逻辑卷的大小
-l：指定逻辑卷的大小
举例：
-l 100			100个PE，每个PE大小默认4M，故逻辑卷大小为400M
-l 50%free		卷组剩余空间的50%
[root@zutuanxue ~]# vgs vg1 
  VG  #PV #LV #SN Attr   VSize VFree
  vg1   2   1   0 wz--n- 3.99g 1.49g
 
创建大小为200M的逻辑卷lv02;每个PE为4M，-l 50指定50个PE,大小为200M
[root@zutuanxue ~]# lvcreate -n lv2 -l 50 vg1
  Logical volume "lv2" created.
[root@zutuanxue ~]# vgs vg1 
  VG  #PV #LV #SN Attr   VSize VFree 
  vg1   2   2   0 wz--n- 3.99g <1.30g

[root@manage01 ~]# lvs /dev/vg01/lv02
  LV   VG   Attr       LSize   Pool Origin Data%  Move Log Cpy%Sync Convert
  lv02 vg01 -wi-a----- 200.00m  
  
创建大小为剩余卷组vg01空间的50%的逻辑卷lv03
[root@zutuanxue ~]# lvcreate -n lv3 -l 50%free vg1
  Logical volume "lv3" created.
[root@zutuanxue ~]# vgs vg1 
  VG  #PV #LV #SN Attr   VSize VFree  
  vg1   2   3   0 wz--n- 3.99g 664.00m

查看逻辑卷的信息：
[root@zutuanxue ~]# lvs /dev/vg1/lv1 
  LV   VG  Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-a----- 2.50g                                                    
[root@zutuanxue ~]# lvs /dev/vg1/lv2
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv2  vg1 -wi-a----- 200.00m                                                    
[root@zutuanxue ~]# lvs /dev/vg1/lv3
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv3  vg1 -wi-a----- 664.00m                                                    
[root@zutuanxue ~]# lvdisplay /dev/vg1/lv1 
  --- Logical volume ---
  LV Path                /dev/vg1/lv1
  LV Name                lv1
  VG Name                vg1
  LV UUID                jj9Sj1-zHuo-qpBZ-Dkk1-LVYB-HyUH-LQ6edW
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2019-12-10 05:46:59 -0500
  LV Status              available
  # open                 0
  LV Size                2.50 GiB
  Current LE             640
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

 
# 5. 格式化逻辑卷
[root@zutuanxue ~]# mkfs.ext4 /dev/vg1/lv1 

# 6. 挂载使用
# 1）创建一个空的挂载点
[root@zutuanxue /]# mkdir /lv1
# 2）挂载使用
[root@zutuanxue /]# mount /dev/vg1/lv1 /lv1/
```

# 五、逻辑卷扩容

将/lv1目录动态扩容到3G

案例思路

1. 查看/lv1目录所对应的逻辑卷是哪一个 /dev/mapper/vg1-lv1
2. 查看当前逻辑卷所在的卷组vg1剩余空间是否足够
3. 如果vg1空间不够，得先扩容卷组，再扩容逻辑卷
4. 如果vg1空间足够，直接扩容逻辑卷

案例实现

```bash
#步骤：
# 1. 查看/lv1目录属于哪个卷组
df -h
#文件系统             容量  已用  可用 已用% 挂载点
#/dev/mapper/vg1-lv1  2.4G  7.5M  2.3G    1% /lv1
lvs

# 2. 卷组的剩余空间
[root@zutuanxue /]# vgs
  VG  #PV #LV #SN Attr   VSize   VFree  
  cl    1   2   0 wz--n- <19.00g      0 
  vg1   2   4   0 wz--n-   3.99g 664.00m
结果：当前卷组空间不足我扩容

# 3. 扩容逻辑卷所在的卷组
# 1）首先得有物理设备 /dev/sdb3
# 2) 将物理设备做成物理卷
pvcreate /dev/sdb3 
pvs
# 3）将物理卷加入到卷组中（卷组扩容）
vgextend vg1 /dev/sdb3 
pvs
vgs

# 4. 扩容逻辑卷
lvextend -L 3G /dev/vg1/lv1    # -L 3G最终的大小
#或者
lvextend -L +1.5G /dev/vg1/lv1
# lvextend  -l  +100%free /dev/doshell-vg/root
# 5. 查看结果
lvs
df -h
# 6. 同步文件系统
resize2fs /dev/vg1/lv1    #该命令适用于ext分区
xfs_growfs /dev/vg1/lv1   #该命令适用于xfs分区
# 7. 再次查看验证
df -h
```

# 六、逻辑卷剪裁

将lv1逻辑卷由原来的3G缩小为2G

案例思路

1、卸载逻辑卷
2、扫描逻辑卷
3、裁剪率lv1文件系统
4、裁剪逻辑卷lv1
5、挂载使用

## 6.1 ext分区逻辑卷裁剪

```bash
umount /lv1
e2fsck -f /dev/vg1/lv1		    # 检验文件系统
resize2fs /dev/vg1/lv1    2G	# 裁剪文件系统到2G
lvreduce  /dev/vg1/lv1 -L 2G	# 裁剪逻辑卷
mount     /dev/vg1/lv1    /lv1/	# 挂载使用

```

## 6.2 xfs分区逻辑卷裁剪

1、将lv2的文件系统格式化为xfs
2、将/dev/vg1/lv2挂载到/lv2
3、在/lv2中建立一个文件，写入内容
4、备份数据
5、卸载分区并裁剪逻辑卷
6、格式化裁剪后的逻辑卷
7、导入数据

```bash
# 1)备份数据命令
xfsdump
# 2）备份数据
[root@zutuanxue /]# xfsdump -f /root/lv2.img /lv2
#挂载点目录后面不要加"/"
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.8 (dump format 3.0) - type ^C for status and control

 ============================= dump label dialog ==============================

please enter label for this dump session (timeout in 300 sec)
 -> lv2
session label entered: "lv2"

 --------------------------------- end dialog ---------------------------------

xfsdump: level 0 dump of localhost.localdomain:/lv2
xfsdump: dump date: Tue Dec 10 06:33:44 2019
xfsdump: session id: 15936371-b967-4c2c-8995-49eb702792fe
xfsdump: session label: "lv2"
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 20800 bytes

 ============================= media label dialog =============================

please enter label for media in drive 0 (timeout in 300 sec)
 -> lv2
media label entered: "lv2"

 --------------------------------- end dialog ---------------------------------

xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsdump: dumping non-directory files
xfsdump: ending media file
xfsdump: media file size 21016 bytes
xfsdump: dump size (non-dir files) : 0 bytes
xfsdump: dump complete: 14 seconds elapsed
xfsdump: Dump Summary:
xfsdump:   stream 0 /root/lv2.img OK (success)
xfsdump: Dump Status: SUCCESS


# 3)裁剪
[root@zutuanxue ~]# umount /lv2
[root@zutuanxue ~]# lvreduce /dev/vg1/lv2 -L 100M
  WARNING: Reducing active logical volume to 2.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce vg01/lv01? [y/n]: y
  Size of logical volume vg01/lv01 changed from 7.00 GiB (1792 extents) to 2.00 GiB (512 extents).
  Logical volume vg01/lv01 successfully resized.

# 4）格式化
[root@zutuanxue ~]# mkfs.xfs -f /dev/vg1/lv2
[root@zutuanxue ~]# mount /dev/vg1/lv2 /lv2

# 5）恢复数据 -f source
[root@zutuanxue ~]# xfsrestore -f /root/lv2.img /lv2
.
.
.
xfsrestore: Restore Status: SUCCESS


root@zutuanxue ~]# df -h
文件系统             容量  已用  可用 已用% 挂载点
/dev/mapper/vg1-lv2   95M  6.0M   89M    7% /lv2

[root@zutuanxue ~]# cat /lv2/filea 
hahaha
```

# 七、swap分区

swap分区在系统的运行内存不够用的时候，把运行内存中的一部分空间释放出来，以供当前运行的程序使用。那些被释放的空间可能来自一些很长时间没有什么操作的程序，这些被释放的空间被临时保存到swap分区中，等到那些程序要运行时，再从Swap分区中恢复保存的数据到内存中。可以缓解物理内存不足的压力，如果物理内存不足，还没有swap空间，会宕机

扩容swap空间

方法1： 增加一个设备（硬盘，分区，逻辑卷）来扩容swap空间

```
查看swap空间大小：
[root@zutuanxue ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           3918        1309        2002          15         606        2358
Swap:          2047           0        2047

[root@zutuanxue ~]# swapon -s
文件名				类型					大小			已用	权限
/dev/dm-1   partition		2097148			0		-2
[root@zutuanxue ~]# mkswap /dev/sdb4
正在设置交换空间版本 1，大小 = 2 GiB (2147479552  个字节)
无标签，UUID=8235e59a-1043-4251-8694-ba619cb36f1c

[root@zutuanxue ~]# blkid /dev/sdb4
/dev/sdb4: UUID="8...c" TYPE="swap" PARTUUID="b...e"

//激活swap分区。swap空间不能手动挂载
[root@zutuanxue ~]# swapon /dev/sdb4
[root@zutuanxue ~]# swapon -s
文件名						类型				大小		已用	权限
/dev/dm-1       partition	2097148		0		-2
/dev/sdb4       partition	2097148		0		-3


[root@zutuanxue ~]# free -m
      total  used  free shared buff/cache available
Swap:  4095   0    4095

LVM形式
[root@zutuanxue ~]# mkswap /dev/vg1/swap		#创建swap
[root@zutuanxue ~]# swapon /dev/vg1/swap		#开启swap
[root@zutuanxue ~]# lvextend -L 4G	/dev/vg1/swap	#放大LVM形式的swap
[root@zutuanxue ~]# swapoff /dev/vg1/swap		#关闭lvm形式的swap
[root@zutuanxue /]# mkswap /dev/vg1/lv-swap	#重新制作swap
[root@zutuanxue ~]# swapon /dev/vg1/swap		#开启lvm形式的swap
[root@zutuanxue ~]# free -m	#确认swap分区是否放大
```

方法2： 使用dd命令模拟大文件来扩容swap

```
[root@zutuanxue ~]# dd if=/dev/zero of=/tmp/swapfile bs=1M count=2048

if=源文件,in file指定从哪里读入数据
of=目标文件，out file指定将数据写入什么位置
bs=复制数据的大小，block size
count=复制的个数

注意：
1. 一般可以使用dd命令做块设备文件的备份
2. /dev/zero 特殊设备，一般用来模拟一个大文件，源源不断的二进制的数据流;
/dev/null  空设备，类似黑洞

步骤：
1. 使用dd命令模拟大文件
# dd if=/dev/zero of=/tmp/swapfile bs=1M count=2048
2. 格式化大文件
[root@zutuanxue ~]# mkswap /tmp/swapfile 
mkswap: /tmp/swapfile：不安全的权限 0644，建议使用 0600。
正在设置交换空间版本 1，大小 = 2 GiB (2147479552  个字节)
无标签，UUID=3d855316-c97c-42ca-9c52-9df26a4517a0 
[root@zutuanxue ~]# ll /tmp/swapfile 
-rw-r--r-- 1 root root 2147483648 12月 10 21:02 /tmp/swapfile
[root@zutuanxue ~]# chmod 600 /tmp/swapfile 

3.激活大文件
[root@zutuanxue ~]# swapon -p1 /tmp/swapfile
-p：指定优先级，数字越大优先级越高，-1~32767

4. 查看
[root@zutuanxue ~]# swapon -s
文件名							类型				大小			已用	权限
/dev/dm-1         partition	2097148		 268	-2
/dev/sdb4         partition	2097148		 0		-3
/tmp/swapfile     file    	2097148		 0		 1
[root@zutuanxue ~]# free -m
      total used  free  shared  buff/cache available
Swap:  6143  0    6143



如果开机自动挂载，需要修改文件：/etc/fstab
[root@zutuanxue ~]# vim /etc/fstab 
/dev/sda4  			swap    swap     defaults       0 0
/tmp/swapfile   swap    swap     dfaults,pri=1  0 0
[root@zutuanxue ~]# swapon -a

关闭swap
[root@zutuanxue ~]# swapoff /dev/sdb4
[root@zutuanxue ~]# swapoff /tmp/swapfile
或者
#关闭所有swap****慎用*****
[root@zutuanxue ~]# swapoff -a	
```

# 八、其他常见操作

## 8.1 LVM中有PV出现了坏道

```
#LVM中有PV出现了坏道
#数据拷贝 将/dev/sdc1拷贝到/dev/sdd1
[root@zutuanxue ~]#lvchange -an /dev/baism/abc

[root@zutuanxue ~]# pvmove /dev/sdc1 /dev/sdd1
  /dev/sdc1: Moved: 2.7%
  /dev/sdc1: Moved: 100.0%

[root@zutuanxue ~]# vgchange -a n /dev/baism
  0 logical volume(s) in volume group "baism" now active

[root@zutuanxue ~]# vgreduce baism /dev/sdc1
  Removed "/dev/sdc1" from volume group "baism"

[root@zutuanxue ~]# vgchange -a y /dev/baism
  1 logical volume(s) in volume group "baism" now active

[root@zutuanxue ~]#lvchange -ay /dev/baism/abc

#卷组迁移
#导出卷组 old machine
[root@zutuanxue ~]# vgexport /dev/baism
  Volume group "baism" successfully exported

#导入卷组  new machine
[root@zutuanxue ~]# pvscan
[root@zutuanxue ~]# vgimport /dev/baism
  Volume group "baism" successfully imported

[root@zutuanxue ~]# vgchange -a y /dev/baism
  1 logical volume(s) in volume group "baism" now active

[root@zutuanxue ~]#lvchange -ay /dev/baism/abc
```

## 8.2 volume merged lv合并

```
root@zutuanxue lvm]# vgcreate baism1 /dev/sdc1
  Volume group "baism1" successfully created
[root@zutuanxue lvm]# vgcreate baism2 /dev/sdd1
  Volume group "baism2" successfully created
[root@zutuanxue lvm]# vgmerge -v baism1 baism2
    Checking for volume group "baism1"
    Checking for volume group "baism2"
    Archiving volume group "baism2" metadata (seqno 1).
    Archiving volume group "baism1" metadata (seqno 1).
    Writing out updated volume group
    Creating volume group backup "/etc/lvm/backup/baism1" (seqno 2).
  Volume group "baism2" successfully merged into "baism1"
```

## 8.3 volume spilt lv分割

```
[root@zutuanxue ~]# vgsplit baism1 baism2 /dev/sdd1
  New volume group "baism2" successfully split from "baism1"

baism1  Old volume
baism2  New volume  /dev/sdd1
```

## 8.4 逻辑卷从旧机器迁移到新机器

```
#########Backing Up Volume Group Metadata:

当创建vg的时候，系统默认会自动备份Metadata。/etc/lvm/backup下面存放的是metadata的备份信息，而/etc/lvm/archive下面存放的是metadata的archive信息。


[root@zutuanxue backup]# pwd
/etc/lvm/backup

[root@zutuanxue backup]# strings baism2
# Generated by LVM2 version 2.02.87(2)-rhel7 (2011-10-12): Mon Jan 14 22:27:02 2013
contents = "Text Format Volume Group"
version = 1

description = "Created *after* executing 'vgsplit baism1 baism2 /dev/sdd1'"   #warn

creation_host = "rhel7" # Linux rhel7 2.6.32-220.el6.x86_64 #1 SMP Wed Nov 9 08:03:13 EST 2011 x86_64
creation_time = 1358173622      # Mon Jan 14 22:27:02 2013
baism2 {
        id = "Ft0eD7-oVca-mwY6-6FeK-TwW2-hTrj-aYxYbq"
        seqno = 2
        status = ["RESIZEABLE", "READ", "WRITE"]
        flags = []
        extent_size = 8192              # 4 Megabytes
        max_lv = 0
        max_pv = 0
        metadata_copies = 0
        physical_volumes {
                pv0 {
                        id = "m7aKrr-D0r9-jOJ2-aK51-ec25-4rwH-4ccbbh"
                        device = "/dev/sdd1"    # Hint only
                        status = ["ALLOCATABLE"]
                        flags = []
                        dev_size = 4192902      # 1.99933 Gigabytes
                        pe_start = 2048
                        pe_count = 511  # 1.99609 Gigabytes
```

# 九、创建高可用逻辑卷

## 9.1 逻辑卷条带化

把保存到逻辑卷的数据分成n等分，分别写到不同的物理卷，可以提高数据的读写效率；如果任何一个涉及到的物理卷出现故障，数据都会无法恢复。

```
创建物理卷
[root@manage01 ~]# pvcreate /dev/sdb[12]

查看物理卷
[root@manage01 ~]# pvs
/dev/sdb1            lvm2 a--   2.01g  2.01g
/dev/sdb2            lvm2 a--   2.01g  2.01g


创建卷组：
[root@manage01 ~]# vgcreate vg01 /dev/sdb[12]

[root@manage01 ~]# pvs /dev/sdb[12]
  PV         VG   Fmt  Attr PSize PFree
 /dev/sdb1  vg01      lvm2 a--   2.00g  2.00g
 /dev/sdb2  vg01      lvm2 a--   2.00g  2.00g


创建实现条带化的逻辑卷：
[root@zutuanxue ~]# lvcreate -n lv1 -L 1G vg01 -i 2 /dev/sdb{1,2}

-i 参数：给出条带化的数量
[root@zutuanxue ~]# lvs /dev/vg01/lv01


格式化挂载使用：
[root@zutuanxue ~]# mkfs.ext4 /dev/vg1/lv1
[root@zutuanxue ~]# mount /dev/vg1/lv1 /lv1


测试：
[root@zutuanxue ~]# dnf install sysstat -y
[root@zutuanxue ~]# iostat -m -d /dev/sdb[12] 2 
-d 查看磁盘
-m 以什么速度显示，每秒M
 2 每隔2s显示一次 
   如果后面还有数字则代表总共显示多少次
   
[root@zutuanxue ~]# dd if=/dev/zero of=/lv1/test bs=1M count=1000    模拟写数据
[root@zutuanxue ~]# iostat -m -d /dev/sdb[12] 1
.
.
.
Device tps  		MB_read/s  MB_wrtn/s MB_read MB_wrtn
sdb1   4015.00  0.01       364.38    0       364
sdb2   4005.00  0.00       364.33    0       364
```

## 9.2 逻辑卷实现镜像

镜像是一种文件存储形式，是冗余的一种类型，一个磁盘上的数据在另一个磁盘上存在一个完全相同的副本即为镜像。对某个逻辑卷的数据做镜像，起到数据备份的作用。

```
当前环境：
[root@zutuanxue ~]# lsblk
├─sdb3        8:19   0    2G  0 part 
├─sdb4        8:20   0    2G  0 part 


创建物理卷：
[root@zutuanxue ~]# pvcreate /dev/sdb[34]
[root@zutuanxue ~]# pvs
  PV         VG  Fmt  Attr PSize   PFree 
  /dev/sdb3      lvm2 ---    2.00g  2.00g
  /dev/sdb4      lvm2 ---    2.00g  2.00g

  
 将物理卷加入到vg1卷组：
[root@zutuanxue ~]# vgextend vg1 /dev/sdb[34]
  Volume group "vg1" successfully extended
[root@zutuanxue ~]# vgs
  VG  #PV #LV #SN Attr   VSize   VFree
  vg1   4   1   0 wz--n-   7.98g 6.98g


创建实现镜像的逻辑卷：
[root@zutuanxue ~]# lvcreate -n lv2 -L 1G vg1 -m 1 /dev/sdb[34]
  Logical volume "lv2" created.

-m参数：给出镜像的个数；1表示1个镜像

[root@zutuanxue ~]# lvs -a -o +devices
[root@zutuanxue ~]# lvs -a -o +devices
  LV             VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices                        
  root           cl  -wi-ao---- <17.00g                                                     /dev/sda2(512)                 
  swap           cl  -wi-ao----   2.00g                                                     /dev/sda2(0)                   
  lv1            vg1 -wi-ao----   1.00g                                                     /dev/sdb1(0),/dev/sdb2(0)      
  lv2            vg1 rwi-a-r---   1.00g                                    100.00           lv2_rimage_0(0),lv2_rimage_1(0)
  [lv2_rimage_0] vg1 iwi-aor---   1.00g                                                     /dev/sdb3(1)                   
  [lv2_rimage_1] vg1 iwi-aor---   1.00g                                                     /dev/sdb4(1)                   
  [lv2_rmeta_0]  vg1 ewi-aor---   4.00m                                                     /dev/sdb3(0)                   
  [lv2_rmeta_1]  vg1 ewi-aor---   4.00m                                                     /dev/sdb4(0)         

说明： Cpy%Sync 18.77该值是100%说明复制ok 


格式化逻辑卷：
[root@zutuanxue ~]# mkfs.ext4 /dev/vg1/lv2
挂载使用
[root@zutuanxue ~]# mount /dev/vg1/lv2 /lv2/

[root@zutuanxue ~]# touch /lv2/file{1..10}
[root@zutuanxue ~]# mkdir /lv2/dir{1..10}

 
测试验证：
思路：损坏一个磁盘，测试数据是否在第二个物理卷中
1. 使用dd命令破坏一个物理卷
[root@zutuanxue ~]# dd if=/dev/zero of=/dev/sdb3 bs=1M count=100

2. 再次查看物理卷发现有一个unknown Device    pvs命令
 [unknown]  vg1 lvm2 a-m   <2.00g 1016.00m

3. 将损坏的盘从卷组中移除
[root@zutuanxue ~]# vgreduce vg1 --removemissing --force

4. 再次查看挂载点/lv2数据依然存在

自己也可以再次测试：
1. 再拿刚刚人为损坏的盘做成物理卷再次加入到vg1卷组中
[root@zutuanxue /]# pvcreate /dev/sdb3 
 
[root@zutuanxue /]# vgextend vg1 /dev/sdb3


2. 修复
[root@zutuanxue /]# lvconvert --repair /dev/vg1/lv2 /dev/sdb[34]
```

## 9.3 逻辑卷快照

快照的作用：保存做快照那一刻数据的状态，方便用户实现数据回滚，避免重要数据被覆盖。

快照的大小：快照需要占用卷组空间，快照的大小决定了允许有多少数据发生改变，如果制作快照时分配的容量与对应的逻辑卷相同，那么就允许逻辑卷中所有的数据发生改变。

COW：copy on write 当系统检测到做快照的逻辑卷当中的数据发生了改变，会在改变前将逻辑卷中的PE的数据复制到快照中的PE，然后再写入新的数据

```
1. 创建快照 (EXT4)
[root@zutuanxue /]# lvcreate -L 200M -s -n lv1-snap /dev/vg1/lv1	给lv1逻辑卷创建快照
[root@zutuanxue /]# mount -o ro /dev/vg1/lv1-snap /lv1-snap/	挂载快照

[root@zutuanxue /]# lvscan 
  ACTIVE   Original '/dev/vg1/lv1' [2.00 GiB] inherit
  ACTIVE   Snapshot '/dev/vg1/lv1-snap' [200.00 MiB] inherit


[root@zutuanxue /] dmsetup ls --tree
vg1-lv2--snap (252:5)
 ├─vg1-lv1--snap-cow (253:4)		保存原卷改变前的数据
 │  └─ (8:17)
 └─vg1-lv1-real (253:3)				真实的逻辑卷（原卷）
    ├─ (8:17)
    └─ (8:18)
vg1-lv1 (253:2)
 └─vg1-lv1-real (253:3)
    ├─ (8:17)
    └─ (8:18)
    
2. 修改原卷的数据
[root@zutuanxue /]# dd if=/dev/zero of=/lv1/test bs=1M count=30

3. 观察Snapshot
[root@zutuanxue /]# lvs /dev/vg1/lv1-snap 
  LV       VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1-snap vg1 swi-aos--- 200.00m      lv1    0.02                                   
[root@zutuanxue /]# lvs /dev/vg1/lv1-snap 
  LV       VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1-snap vg1 swi-aos--- 200.00m      lv1    15.10                                  
  

XFS：
[root@node1 ~]# mount -o nouuid,ro /dev/vg1/lv1-snap /lv1-snap
挂载快照，尽量使用ro的方式，将不会破坏快照卷中的数据


快照实现自动扩容：
/etc/lvm/lvm.conf 
snapshot_autoextend_threshold = 80
snapshot_autoextend_percent = 20
//当快照使用到80%时，自动扩容20%；当snapshot_autoextend_threshold = 100表示关闭自动扩容

修改完成后建议重启
```

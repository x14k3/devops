# RAID

​​磁盘阵列（Redundant Arrays of Independent Disks，RAID）​，有“独立磁盘构成的具有冗余能力的阵列”之意。简单地说， RAID 是由多个独立的高性能磁盘驱动器组成的磁盘子系统，从而提供比单个磁盘更高的存储性能和数据冗余的技术。

RAID 的初衷是为大型服务器提供高端的存储功能和冗余的数据安全。在整个系统中，` RAID`​ 被看作是由两个或更多磁盘组成的存储空间，通过并发地在多个磁盘上读写数据来提高存储系统的 `I/O`​ 性能。大多数 RAID 等级具有完备的数据校验、纠正措施，从而提高系统的容错性，甚至镜像方式，大大增强系统的可靠性， Redundant 也由此而来。

​

`RAID0`​<span data-type="text" style="color: var(--b3-font-color11);"> 具有低成本、高读写性能、 100% 的高存储空间利用率等优点，但是它不提供数据冗余保护，一旦数据损坏，将无法恢复。</span>

​​​![f8274d1379754ded97c7609b3d65e85d~tplv-k3u1fbpfcp-zoom-in-crop-mark 1512 0 0 0](assets/f8274d1379754ded97c7609b3d65e85dtplv-k3u1fbpfcp-zoom-in-crop-mark%201512%200%200%200-20231109153914-xwa2ir5.webp)

​`RAID1`​​<span data-type="text" style="color: var(--b3-font-color12);"> 称为镜像，它将数据完全一致地分别写到工作磁盘和镜像磁盘，它的磁盘空间利用率为 50% 。</span>

​​​![ce99960c430944e4a7c3a1d480d75898~tplv-k3u1fbpfcp-zoom-in-crop-mark 1512 0 0 0](assets/ce99960c430944e4a7c3a1d480d75898tplv-k3u1fbpfcp-zoom-in-crop-mark%201512%200%200%200-20231109153920-kbijtdy.webp)

`RAID5 `​<span data-type="text" style="color: var(--b3-font-color2);">应该是目前最常见的 RAID 等级 ,RAID5 兼顾存储性能、数据安全和存储成本等各方面因素，它可以理解为 RAID0 和 RAID1 的折中方案，是目前综合性能最佳的数据保护解决方案。 RAID5 基本上可以满足大部分的存储应用需求，数据中心大多采用它作为应用数据的保护方案。</span>

![f244711c5e104fcd82c0397185e7e957~tplv-k3u1fbpfcp-zoom-in-crop-mark 1512 0 0 0](assets/f244711c5e104fcd82c0397185e7e957tplv-k3u1fbpfcp-zoom-in-crop-mark%201512%200%200%200-20231109153936-xom8haq.webp)

`RAID6 `​<span data-type="text" style="color: var(--b3-font-color4);">等级是在 RAID5 的基础上为了进一步增强数据保护而设计的一种 RAID 方式，它可以看作是一种扩展的 RAID5 等级。RAID6 具有快速的读取性能、更高的容错能力。但是，它的成本要高于 RAID5 许多，写性能也较差，并有设计和实施非常复杂。因此， RAID6 很少得到实际应用，主要用于对数据安全等级要求非常高的场合。它一般是替代 RAID10 方案的经济性选择。</span>

![dea4ecdf05de4b13b63b33c9b2fc9c88~tplv-k3u1fbpfcp-zoom-in-crop-mark 1512 0 0 0](assets/dea4ecdf05de4b13b63b33c9b2fc9c88tplv-k3u1fbpfcp-zoom-in-crop-mark%201512%200%200%200-20231109154010-6wlc7u5.webp)

## 软 RAID

​`软 RAID `​没有专用的控制芯片和 I/O 芯片，完全由操作系统和 CPU 来实现所的 RAID 的功能。现代操作系统基本上都提供软 RAID 支持，通过在磁盘设备驱动程序上添加一个软件层，提供一个物理驱动器与逻辑驱动器之间的抽象层。目前，操作系统支持的最常见的 RAID 等级有 `RAID0 `​、 `RAID1`​ 、 `RAID10`​ 、 `RAID01`​ 和 `RAID5`​ 等。比如， Windows Server 支持 RAID0 、 RAID1 和 RAID5 三种等级， Linux 支持 RAID0 、 RAID1 、 RAID4 、 RAID5 、 RAID6 等， Mac OS X Server 、 FreeBSD 、 NetBSD 、 OpenBSD 、 Solaris 等操作系统也都支持相应的 RAID 等级。

软 RAID 的配置管理和数据恢复都比较简单，但是 RAID 所有任务的处理完全由 CPU 来完成，如计算校验值，所以执行效率比较低下，这种方式需要消耗大量的运算资源，支持 RAID 模式 较少，很难广泛应用。

软 RAID 由操作系统来实现，因此系统所在分区不能作为 RAID 的逻辑成员磁盘，软 RAID 不能保护系统盘 D 。对于部分操作系统而言， RAID 的配置信息保存在系统信息中，而不是单独以文件形式保存在磁盘上。这样当系统意外崩溃而需要重新安装时， RAID 信息就会丢失。另外，磁盘的容错技术并不等于完全支持在线更换、热插拔或热交换，能否支持错误磁盘的热交换与操作系统实现相关，有的操作系统热交换。

## 硬 RAID

​`硬 RAID`​ 拥有自己的 RAID 控制处理与 I/O 处理芯片，甚至还有阵列缓冲，对 CPU 的占用率和整体性能是三类实现中最优的，但实现成本也最高的。硬 RAID 通常都支持热交换技术，在系统运行下更换故障磁盘。

硬 RAID 包含 RAID 卡和主板上集成的 RAID 芯片， 服务器平台多采用 RAID 卡。 RAID 卡由 RAID 核心处理芯片（ RAID 卡上的 CPU ）、端口、缓存和电池 4 部分组成。其中，端口是指 RAID 卡支持的磁盘接口类型，如 `IDE/ATA `​、`SCSI`​ 、`SATA`​ 、`SAS`​ 、`FC `​等接口。

## 软硬混合 RAID

软 RAID 性能欠佳，而且不能保护系统分区，因此很难应用于桌面系统。而硬 RAID 成本非常昂贵，不同 RAID 相互独立，不具互操作性。因此，人们采取软件与硬件结合的方式来实现 RAID ，从而获得在性能和成本上的一个折中，即较高的性价比。

这种 RAID 虽然采用了处理控制芯片，但是为了节省成本，芯片往往比较廉价且处理能力较弱， RAID 的任务处理大部分还是通过固件驱动程序由 CPU 来完成。

## Linux配置RAID

Linux 内核中有一个`md(multiple devices)`​模块在底层管理 RAID 设备，它会在应用层给我们提供一个应用程序的工具 `mdadm`​ ，mdadm 是 linux 下用于创建和管理软件 RAID 的命令。mdadm 命令常见参数解释：

```bash
mdadm [模式] <RAID设备名称> [选项] [成员设备名称]
选项说明：
【创建模式】
-C：创建(create a new array)
-l：指定raid级别(Set RAID level,0,1,5,10)
-c：指定chunk大小(Specify chunk size of kibibytes，default 512KB)
-a：检测设备名称(--auto=yes)，yes表示自动创建设备文件/dev/mdN
-n：指定设备数量(--raid-devices:Specify the number of active devices in the array)
-x：指定备用设备数量(--spare-devices:Specify the number of spare (eXtra) devices in the initial array)
-v：显示过程
-f：强制行为
-r：移除设备(remove listed devices)
-S：停止阵列(--stop:deactivate array, releasing all resources)
-A：装配阵列，将停止状态的阵列重新启动起来

【监控模式】
-Q：查看摘要信息(query)
-D：查看详细信息(Print details of one or more md devices)
    mdadm -D --scan >/etc/mdadm.conf，以后可以直接mdadm -A进行装配这些阵列

【管理模式】
mdadm --manage /dev/md[0-9] [--add 设备名] [--remove 设备名] [--fail 设备名]
--manage ：mdadm使用manage模式，此模式下可以做--add/--remove/--fail/--replace动作
-add     ：将后面列出的设备加入到这个md
--remove ：将后面列出的设备从md中移除，相当于硬件raid的拔出动作
--fail   ：将后面列出的设备设定为错误状态，即人为损坏，损坏后该设备放在raid中已经是无意义状态的
```

### 实现RAID10

 **(1).准备磁盘或分区，以分区为例。**

/dev/sd{b,c,d,e}1这四个分区都是200M大小。

 **(2).使用mdadm命令创建RAID10,名称为&quot;/dev/md0&quot;。**

用-C参数代表创建一个RAID阵列卡，-v参数来显示出创建的过程，同时在后面追加一个设备名称，-a  yes参数代表自动创建设备文件，-n 4参数代表使用4块硬盘(分区)来制作这个RAID组，而-l  10参数则代表RAID10，最后再加上4块设备的名称就可以了。

```bash
[root@xuexi ~]# mdadm -C /dev/md0 -n 4 -l 10 -a yes /dev/sd{b,c,d,e}1
mdadm: /dev/sdb1 appears to contain an ext2fs file system
       size=10485760K  mtime=Thu Jan  1 08:00:00 1970
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

查看RAID设备信息。

```bash
[root@xuexi ~]# mdadm -D /dev/md0

/dev/md0:
        Version : 1.2
  Creation Time : Fri Jun  9 21:44:59 2017
     Raid Level : raid10
     Array Size : 387072 (378.06 MiB 396.36 MB)  # 总共能使用的空间，因为是raid10，所以总可用空间为400M左右，除去元数据，大于370M左右
  Used Dev Size : 193536 (189.03 MiB 198.18 MB)  # 每颗raid组或设备上的可用空间，也即每个RAID1组可用大小为190M左右
   Raid Devices : 4     # raid中设备的个数
  Total Devices : 4     # 总设备个数，包括raid中设备个数，备用设备个数等
    Persistence : Superblock is persistent

    Update Time : Fri Jun  9 21:45:02 2017
          State : clean    # 当前raid状态，有clean/degraded(降级)/recovering/resyncing
 Active Devices : 4
Working Devices : 4
 Failed Devices : 0
  Spare Devices : 0

         Layout : near=2  # RAID10数据分布方式，有near/far/offset，默认为near，即数据的副本存储在相邻设备的相同偏移上。near=2表示要备份2份数据
     Chunk Size : 512K

           Name : xuexi.longshuai.com:0  (local to host xuexi.longshuai.com)
           UUID : ff2b7d7c:381a4c47:c31e7edd:7cdef01e
         Events : 17
       
    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync set-A   /dev/sdb1      # 第一个raid1组A成员
       1       8       33        1      active sync set-B   /dev/sdc1      # 第一个raid1组B成员
       2       8       49        2      active sync set-A   /dev/sdd1      # 第二个raid1组A成员
       3       8       65        3      active sync set-B   /dev/sde1      # 第二个raid1组B成员
```

raid创建好后，它的运行状态信息放在/proc/mdstat中。

```bash
[root@xuexi ~]# cat /proc/mdstat
Personalities : [raid10]
md0 : active raid10 sde1[3] sdd1[2] sdc1[1] sdb1[0]
      387072 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
   
unused devices: <none>
```

其中"md0 : active raid10 sde1[3] sdd1[2] sdc1[1]  sdb1[0]"表示md0是raid10级别的raid，且是激活状态，sdX[N]表示该设备在raid组中的位置是N，如果有备用设备，则表示方式为sdX[N][S]，S就表示spare的意思。

其中"387072 blocks super 1.2 512K chunks 2 near-copies [4/4]   [UUUU]"表示该raid可用总空间为387072个block，每个block为1K，所以为378M，chunks的大小512K，[m/n]表示此raid10阵列需要m个设备，且n个设备正在正常运行，[UUUU]表示分别表示m个的每一个运行状态，这里表示这4个设备都是正常工作的，如果是不正常的，则以"_"显示。

再看看lsblk的结果。

```bash
[root@xuexi ~]# lsblk -f

NAME      FSTYPE            LABEL                 UUID                                 MOUNTPOINT
loop0     iso9660           CentOS_6.6_Final                                           /mnt
sda                                                                                
├─sda1  ext4                                    77b5f0da-b0f9-4054-9902-c6cdacf29f5e /boot
├─sda2  ext4                                    f199fcb4-fb06-4bf5-a1b7-a15af0f7cb47 /
└─sda3  swap                                    6ae3975c-1a2a-46e3-87f3-d5bd3f1eff48 [SWAP]
sr0                                                                               
sdb                                                                               
└─sdb1  linux_raid_member xuexi.longshuai.com:0 ff2b7d7c-381a-4c47-c31e-7edd7cdef01e
  └─md0                                                                            
sdc                                                                                
└─sdc1  linux_raid_member xuexi.longshuai.com:0 ff2b7d7c-381a-4c47-c31e-7edd7cdef01e
  └─md0                                                                            
sdd                                                                                
└─sdd1  linux_raid_member xuexi.longshuai.com:0 ff2b7d7c-381a-4c47-c31e-7edd7cdef01e
  └─md0                                                                            
sde                                                                                
└─sde1  linux_raid_member xuexi.longshuai.com:0 ff2b7d7c-381a-4c47-c31e-7edd7cdef01e
  └─md0
```

 **(3).将制作好的RAID组格式化创建文件系统。**

以创建ext4文件系统为例。

```bash
[root@xuexi ~]# mke2fs -t ext4 /dev/md0
```

 **(4).挂载raid设备，挂载成功后可看到可用空间为359M，因为RAID在创建文件系统时也消耗了一部分空间存储文件系统的元数据。**

```
[root@xuexi ~]# mount /dev/md0 /mydata

[root@xuexi ~]# df -hT
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sda2      ext4    18G  2.7G   14G  16% /
tmpfs          tmpfs  491M     0  491M   0% /dev/shm
/dev/sda1      ext4   239M   28M  199M  13% /boot
/dev/md0       ext4   359M  2.1M  338M   1% /mydata
```

### 损坏磁盘阵列及修复

通过manage模式可以模拟阵列中的设备损坏。

```
mdadm --manage /dev/md[0-9] [--add 设备名] [--remove 设备名] [--fail 设备名]

选项说明：
manage   ：mdadm使用manage模式，此模式下可以做--add/--remove/--fail/--replace动作
--add    ：将后面列出的设备加入到这个md
--remove ：将后面列出的设备从md中移除
--fail   ：将后面列出的设备设定为错误状态，即人为损坏
```

模拟/dev/sdc1损坏。

```
[root@xuexi mydata]# mdadm --manage /dev/md0 --fail /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md0
```

再查看raid状态。

```
[root@xuexi mydata]# mdadm -D /dev/md0

/dev/md0:
        Version : 1.2
  Creation Time : Fri Jun  9 21:44:59 2017
     Raid Level : raid10
     Array Size : 387072 (378.06 MiB 396.36 MB)
  Used Dev Size : 193536 (189.03 MiB 198.18 MB)
   Raid Devices : 4
  Total Devices : 4
    Persistence : Superblock is persistent

    Update Time : Fri Jun  9 22:22:29 2017
          State : clean, degraded
 Active Devices : 3
Working Devices : 3
 Failed Devices : 1
  Spare Devices : 0

         Layout : near=2
     Chunk Size : 512K

           Name : xuexi.longshuai.com:0  (local to host xuexi.longshuai.com)
           UUID : ff2b7d7c:381a4c47:c31e7edd:7cdef01e
         Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync set-A   /dev/sdb1
       2       0        0        2      removed
       2       8       49        2      active sync set-A   /dev/sdd1
       3       8       65        3      active sync set-B   /dev/sde1

       1       8       33        -      faulty   /dev/sdc1
```

由于4块磁盘组成的raid10允许损坏一块盘，且还允许坏第二块非对称盘。所以这里损坏了一块盘后raid10是可以正常工作的。

现在可以将损坏的磁盘拔出，然后向raid中加入新的磁盘即可。

```
mdadm --manage /dev/md0 --remove /dev/sdc1
```

再修复时，可以将新磁盘加入到raid中。

```
mdadm --manage /dev/mn0 --add /dev/sdc1
```

### raid备份盘

使用mdadm的"-x"选项可以指定备份盘的数量，备份盘的作用是自动顶替raid组中坏掉的盘。

### 停止和装配raid

```
shell> umount /dev/md0
shell> mdadm --stop /dev/md0
```

关闭raid阵列后，该raid组/dev/md0就停止工作了。

如果下次想继续启动它，直接使用-A来装配/dev/md0是不可以的，需要再次指定该raid中的设备成员，且和关闭前的成员一样，不能有任何不同。

```
mdadm -A /dev/md0 /dev/sd{b,c,d,e}1
```

这样做不太保险，其实可以在停止raid前，扫描raid，将扫描的结果保存到配置文件中，下次启动的时候直接读取配置文件即可。

```
mdadm -D --scan >> /etc/mdadm.conf   # 这是默认配置文件
```

下次直接使用-A就可以装置配置文件中的raid组。

```
mdadm -A /dev/md0
```

如果不放在默认配置文件中，则装配的时候使用"-c"或"--config"选项指定配置文件即可。

```
shell> mdadm -D --scan >> /tmp/mdadm.conf 
shell> mdadm -A /dev/md0 -c /tmp/mdadm.conf
```

### 彻底移除raid设备

当已经确定一个磁盘不需要再做为raid的一部分，可以将它移除掉。彻底移除一个raid设备并非那么简单，因为raid控制器已经标记了一个设备，即使将它"mdadm --remove"也无法彻底消除raid的信息。

以移除/dev/md127中的/dev/sdb1为例。

首先，卸载、停止、移除：

```
umount /dev/sdb1
mdadm --stop /dev/md127
mdadm --manage /dev/md127 --remove /dev/sdb1
```

虽然从raid中移除了，但是江湖上还有它的传说：删除分区、创建分区、格式化，格式化的时候将被保护

```
$ parted /dev/sdb rm 1
$ parted /dev/sdb mkpart p 1 20G
$ mke2fs -t ext4 /dev/sdb1
/dev/sdb1 is apparently in use by the system; will not make a filesystem here!
```

然后再去扫描raid设备，发现它又出现在raid组中：

```
$ mdadm -D -s
ARRAY /dev/md/xuexi.longshuai.com:0 metadata=1.2 ............
```

```
$ lsblk -f
NAME      FSTYPE    LABEL    UUID                                MOUNTPOINT
sda                                                                               
├─sda1    xfs             367d6a77-033b-4037-bbcb-416705ead095 /boot
├─sda2    xfs             b2a70faf-aea4-4d8e-8be8-c7109ac9c8b8 /
└─sda3    swap            d505113c-daa6-4c17-8b03-b3551ced2305 [SWAP]
sdb                                                                                
└─sdb1    linux_raid_member xue........
  └─md127 ext4              2fed1dcc-b9a2-477f-8c8f-7131bbd4e919
```

换句话说，只要这个设备曾经是raid的一份子，你就没法再直接使用它。就算你分区了，也不让你格式化。

所以，要彻底移除一个raid设备，需要清空控制器可以读取的raid签名，只需将这个raid设备(可能是一个分区)的raid superblock用0去覆盖掉就行了：

```
$ umount /dev/sdb1
$ mdadm --stop /dev/md127
$ mdadm --manage /dev/md127 --remove /dev/sdb1
$ mdadm --zero-superblock --force /dev/sdb1    # 这条命令是关键
```

然后，这个设备就和raid控制器完全say goodbye了：

```
$ lsblk -f
NAME   FSTYPE LABEL UUID      MOUNTPOINT
sda                        
...........
sdb                        
└─sdb1
```

现在格式化也可以正常进行了：

```
mke2fs -t ext4 /dev/sdb1
```

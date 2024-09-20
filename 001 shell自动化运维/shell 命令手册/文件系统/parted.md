# parted

## 前言

　　在 Linux 中，为磁盘分区通常使用 fdisk 和 parted 命令。通常情况下，使用 fdisk 可以满足日常的使用，但是它仅仅支持 2 TB 以下磁盘的分区，超出 2 TB 部分无法识别。而随着科技的进步，大容量硬盘已经步入我们的生活，10 TB 的 HDD 和 30 TB 的 SSD 也已面世，无论是家用还是商用领域 SSD 的容量和价格都更加充满吸引力。仅仅能识别 2 TB 的 fdisk 很明显无法满足需求了，于是乎 parted & GPT 磁盘成为了绝佳的搭配。本文主要介绍使用 parted 为 MBR 以及 GPT 磁盘分区的方法，也算是作为备忘。

> 使用parted解决大于2T的磁盘分区

---

## 磁盘分区信息存储的两种形式

　　常见磁盘分区存储形式类型有两种：MBR(MSDOS) 和 GPT

### 什么是 MBR

　　MBR(Master Boot Record，主引导记录）。
MBR 是存在于驱动器最开始部分的一个特殊的启动扇区，一般叫它 0 扇区。它由 446B 的启动加载器（Windows 和 Linux 的不同），64B 的分区表，和 2B 用来存放区域的有效性标识 55AA，共 512B。

> MBR 分区最大只支持 2T

　　分区表每 16B 标识一个分区，包括分区的活动状态标志、文件系统标识、起止柱面号、磁头号、扇区号、隐含扇区数目 (4 个字节)、分区总扇区数目(4 个字节) 等信息。
分区总扇区数目决定了这一分区的大小，一个扇区一般 512B，所以 4 个字节，32 位所能表示的最大扇区数为 2 的 32 次方，也就决定了一个分区的大小最大为 2T（ 2\*\*32 \* 512 / 1024 / 1024 / 1024 /1024）。

> MBR 只支持最多 4 个主分区

　　16B 标识一个分区，64B 就一共只能有 4 个分区，所以主分区最多只能有 4 个。一块磁盘如果要分多于 4 个分区，必须要分一个扩展分区，然后在扩展分区中再去划分逻辑分区。

### 什么是 GPT

　　GPT(GUID Partition Table)，这是最近几年逐渐流行起来的一种分区形式，如果要将使用 GPT 分区格式的磁盘作为系统盘，需要 UEFI BIOS 的支持，它才可以引导系统启动。UEFI 一种称为 Unified Extensible Firmware Interface(统一的可扩展的固件接口，它最终是为了取代 BIOS，目前市面上的 BIOS 大多已支持 UEFI。GPT 也是为了最终取代 MBR 的。
GPT 相比 MBR 的优点：

* 分区容量可以大于 2T
* 可以支持无限个主分区
* 更为健壮。MBR 中分区信息和启动信息保存在一起而且只有一份，GPT 在整个磁盘上保存多份这个信息，并为它们提供 CRC 检验，当有数据损坏时，它能够进行恢复。

## 小于 2T 的分区的管理

　　因为传统的 MBR 分区，支持的最大分区为 2T，也可以一定程度上等同于磁盘大小，必定 2T 以上的硬盘不是非常普及。在 CentOS 中可以使用fdisk指令进行管理。详细过程不在赘述。

　　LVM 逻辑卷管理配置小结 - [https://wsgzao.github.io/post/lvm/](https://wsgzao.github.io/post/lvm/)

## 超过 2T 的分区的管理

　　当 CentOS 中识别到有磁盘容量超过 2T 时，如果试图使用fdisk指令对其分区会有相应的警告提示，大致如下：

```
WARNING: GPT (GUID Partition Table) detected on '/dev/sdb'! The util fdisk doesn't support GPT. Use GNU Parted.
```

　　明确提示需要使用parted进行管理，如果系统中没有这一指令，使用`yum install -y parted`​进行安装即可。

　　查看磁盘的分区情况`parted -l`​ 会打印出系统识别到的所有磁盘的分区情况

　　指定分区类型 `parted /dev/sdb`​ 先进入那块超过 2T 的磁盘的管理界面中。
`mklabel gpt`​ parted 指令支持的分区类型选项：{aix|amiga|bsd|dvh|gpt|loop|mac|msdos|pc98|sun}，这里需要选择 gpt，msdos 即为传统的 MBR 分区方式。

　　创建分区
`mkpart {primary|extended|logical| [fs-type] start end`​ GPT 分区没有主分区数的限制，这里一般选择 primary 这一类型。GPT 支持的 fs-type 没有 fdisk 那么多，它支持的有：ext2、ext3、ext4、fat16、fat32、NTFSReiserFS、JFS、XFS、UFS、HFS、swap 这些文件系统格式。

## 使用 parted

```bash
# 使用lsblk,fdisk,df等命令查看当前分区信息
lsblk
fdisk -l
df -TH

# 使用 /dev/sdb1 为例
parted /dev/sdb1
parted (GNU parted) 3.1
Welcome to GNU Parted! Type 'help' to view a list of commands.

# 使用help查看帮助
(parted) help
  check NUMBER                             do a simple check on the file system
  cp [FROM-DEVICE] FROM-NUMBER TO-NUMBER   copy file system to another partition
  help [COMMAND]                           prints general help, or help on COMMAND
  mklabel,mktable LABEL-TYPE               create a new disklabel (partition table)
  mkfs NUMBER FS-TYPE                      make a FS-TYPE file system on partititon NUMBER
  mkpart PART-TYPE [FS-TYPE] START END     make a partition
  mkpartfs PART-TYPE FS-TYPE START END     make a partition with a file system
  move NUMBER START END                    move partition NUMBER
  name NUMBER NAME                         name partition NUMBER as NAME
  print [free|NUMBER|all]                  display the partition table, a partition, or all devices
  quit                                     exit program
  rescue START END                         rescue a lost partition near START and END
  resize NUMBER START END                  resize partition NUMBER and its file system
  rm NUMBER                                delete partition NUMBER
  select DEVICE                            choose the device to edit
  set NUMBER FLAG STATE                    change the FLAG on partition NUMBER
  toggle [NUMBER [FLAG]]                   toggle the state of FLAG on partition NUMBER
  unit UNIT                                set the default unit to UNIT
  version                                  displays the current version of GNU Parted and copyright information

# 建立磁盘标签
(parted) mklabel GPT
# 如果没有任何分区，它查看磁盘可用空间，当分区后，它会打印出分区情况
(parted) print
# 创建主分区，n 为要分的分区占整个磁盘的百分比
(parted) mkpart primary 0% 100%
#  分区完后，直接 quit 即可，不像 fdisk 分区的时候，还需要保存一下，这个不用
(parted) quit

# 让内核知道添加新分区
partprobe

# 格式化
mkfs.ext4 /dev/sdb1

# 挂载分区
mkdir /data
mount /dev/sdb1 /data

# 设置开机自动挂载磁盘
vim /etc/fstab
/dev/sdb1    /data    ext4    defaults    0    0

# fdisk命令无法使用可以用parted
fdisk -l
parted -l

# parted有2种模式，使用命令行模式方便自动化
命令行模式: parted [option] device [command]
交互模式: parted [option] device
```

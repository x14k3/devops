# fdisk

　　**fdisk命令** 用于观察硬盘实体使用情况，也可对硬盘分区。它采用传统的问答式界面，而非类似DOS fdisk的cfdisk互动式操作界面，因此在使用上较为不便，但功能却丝毫不打折扣。

### 语法

```
fdisk [选项] <磁盘>           更改分区表
fdisk [选项] -l [<磁盘>...]   列出分区表
```

### 选项

```

选项：
 -b, --sectors-size <大小>     显示扇区计数和大小
 -B, --protect-boot            创建新标签时不要擦除 bootbits
 -c, --compatibility[=<模式>]  模式，为“dos”或“nondos”(默认)
 -L, --color[=<时机>]          彩色输出（auto, always 或 never）默认启用颜色
 -l, --list                    显示分区并退出
 -x, --list-details            类似 --list 但提供更多细节
 -n, --noauto-pt               不要在空设备上创建默认分区表
 -o, --output <列表>           输出列
 -t, --type <类型>             只识别指定的分区表类型
 -u, --units[=<单位>]          显示单位，“cylinders”柱面或“sectors”扇区(默认)
 -s, --getsz                   以 512-字节扇区显示设备大小[已废弃]
      -b, --bytes                   以字节为单位而非易读的格式来打印 SIZE
      --lock[=<模式>]           使用独占设备锁（yes、no 或 nonblock）
 -w, --wipe <模式>             擦除签名（auto, always 或 never）
 -W, --wipe-partitions <模式>  擦除新分区的签名(auto, always 或 never)

 -C, --cylinders <数字>        指定柱面数
 -H, --heads <数字>            指定磁头数
 -S, --sectors <数字>          指定每条磁道的扇区数

 -h, --help                    显示此帮助
 -V, --version                 显示版本
```

### 参数

　　设备文件：指定要进行分区或者显示分区的硬盘设备文件。

### 实例

　　首先选择要进行操作的磁盘：

```
[root@localhost ~]# fdisk /dev/sdb
```

　　输入`m`​列出可以执行的命令：

```
command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)
```

　　输入`p`​列出磁盘目前的分区情况：

```
Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes
255 heads, 63 sectors/track, 391 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1           1        8001   8e  Linux LVM
/dev/sdb2               2          26      200812+  83  Linux
```

　　输入`d`​然后选择分区，删除现有分区：

```
Command (m for help): d
Partition number (1-4): 1

Command (m for help): d
Selected partition 2
```

　　查看分区情况，确认分区已经删除：

```
Command (m for help): print

Disk /dev/sdb: 3221 MB, 3221225472 bytes
255 heads, 63 sectors/track, 391 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System

Command (m for help):
```

　　输入`n`​建立新的磁盘分区，首先建立两个主磁盘分区：

```
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p    //建立主分区
Partition number (1-4): 1  //分区号
First cylinder (1-391, default 1):  //分区起始位置
Using default value 1
last cylinder or +size or +sizeM or +sizeK (1-391, default 391): 100  //分区结束位置，单位为扇区

Command (m for help): n  //再建立一个分区
Command action
   e   extended
   p   primary partition (1-4)
p 
Partition number (1-4): 2  //分区号为2
First cylinder (101-391, default 101):
Using default value 101
Last cylinder or +size or +sizeM or +sizeK (101-391, default 391): +200M  //分区结束位置，单位为M
```

　　确认分区建立成功：

```
Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes
255 heads, 63 sectors/track, 391 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         100      803218+  83  Linux
/dev/sdb2             101         125      200812+  83  Linux
```

　　再建立一个逻辑分区：

```
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
e  //选择扩展分区
Partition number (1-4): 3
First cylinder (126-391, default 126):
Using default value 126
Last cylinder or +size or +sizeM or +sizeK (126-391, default 391):
Using default value 391
```

　　确认扩展分区建立成功：

```
Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes
255 heads, 63 sectors/track, 391 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         100      803218+  83  Linux
/dev/sdb2             101         125      200812+  83  Linux
/dev/sdb3             126         391     2136645    5  Extended
```

　　在扩展分区上建立两个逻辑分区：

```
Command (m for help): n
Command action
   l   logical (5 or over)
   p   primary partition (1-4)
l //选择逻辑分区
First cylinder (126-391, default 126):
Using default value 126
Last cylinder or +size or +sizeM or +sizeK (126-391, default 391): +400M  

Command (m for help): n
Command action
   l   logical (5 or over)
   p   primary partition (1-4)
l
First cylinder (176-391, default 176):
Using default value 176
Last cylinder or +size or +sizeM or +sizeK (176-391, default 391):
Using default value 391
```

　　确认逻辑分区建立成功：

```
Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes
255 heads, 63 sectors/track, 391 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         100      803218+  83  Linux
/dev/sdb2             101         125      200812+  83  Linux
/dev/sdb3             126         391     2136645    5  Extended
/dev/sdb5             126         175      401593+  83  Linux
/dev/sdb6             176         391     1734988+  83  Linux

Command (m for help):
```

　　从上面的结果我们可以看到，在硬盘sdb我们建立了2个主分区（sdb1，sdb2），1个扩展分区（sdb3），2个逻辑分区（sdb5，sdb6）

　　注意：主分区和扩展分区的磁盘号位1-4，也就是说最多有4个主分区或者扩展分区，逻辑分区开始的磁盘号为5，因此在这个实验中试没有sdb4的。

　　最后对分区操作进行保存：

```
Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

　　建立好分区之后我们还需要对分区进行格式化才能在系统中使用磁盘。

　　在sdb1上建立ext2分区：

```
[root@localhost ~]# mkfs.ext2 /dev/sdb1
mke2fs 1.39 (29-May-2006)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
100576 inodes, 200804 blocks
10040 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=209715200
7 block groups
32768 blocks per group, 32768 fragments per group
14368 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840

Writing inode tables: done                       
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 32 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
```

　　在sdb6上建立ext3分区：

```
[root@localhost ~]# mkfs.ext3 /dev/sdb6
mke2fs 1.39 (29-May-2006)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
217280 inodes, 433747 blocks
21687 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=444596224
14 block groups
32768 blocks per group, 32768 fragments per group
15520 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Writing inode tables: done                       
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 32 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
[root@localhost ~]#
```

　　建立两个目录`/oracle`​和`/web`​，将新建好的两个分区挂载到系统：

```
[root@localhost ~]# mkdir /oracle
[root@localhost ~]# mkdir /web
[root@localhost ~]# mount /dev/sdb1 /oracle
[root@localhost ~]# mount /dev/sdb6 /web
```

　　查看分区挂载情况：

```
[root@localhost ~]# df -h
文件系统              容量  已用 可用 已用% 挂载点
/dev/mapper/VolGroup00-LogVol00
                      6.7G  2.8G  3.6G  44% /
/dev/sda1              99M   12M   82M  13% /boot
tmpfs                 125M     0  125M   0% /dev/shm
/dev/sdb1             773M  808K  733M   1% /oracle
/dev/sdb6             1.7G   35M  1.6G   3% /web
```

　　如果需要每次开机自动挂载则需要修改`/etc/fstab`​文件，加入两行配置：

```
[root@localhost ~]# vim /etc/fstab

/dev/VolGroup00/LogVol00 /                       ext3    defaults        1 1
LABEL=/boot             /boot                   ext3    defaults        1 2
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
/dev/VolGroup00/LogVol01 swap                    swap    defaults        0 0
/dev/sdb1               /oracle                 ext2    defaults        0 0
/dev/sdb6               /web                    ext3    defaults        0 0
```

　　‍

　　‍

## 总结

```bash

[root@localhost ~]# fdisk /dev/sdb
欢迎使用 fdisk (util-linux 2.23.2)。

更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。

Device does not contain a recognized partition table
使用磁盘标识符 0x97caae38 创建新的 DOS 磁盘标签。

命令(输入 m 获取帮助)：p

磁盘 /dev/sdb：107.4 GB, 107374182400 字节，209715200 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x97caae38

   设备 Boot      Start         End      Blocks   Id  System

命令(输入 m 获取帮助)：n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
分区号 (1-4，默认 1)：
起始 扇区 (2048-209715199，默认为 2048)：
将使用默认值 2048
Last 扇区, +扇区 or +size{K,M,G} (2048-209715199，默认为 209715199)：
将使用默认值 209715199
分区 1 已设置为 Linux 类型，大小设为 100 GiB

命令(输入 m 获取帮助)：w
The partition table has been altered!

Calling ioctl() to re-read partition table.
正在同步磁盘。
[root@localhost ~]# mkfs.ext4 /dev/sdb1
mke2fs 1.42.9 (28-Dec-2013)
文件系统标签=
OS type: Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
6553600 inodes, 26214144 blocks
1310707 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=2174746624
800 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: 完成                        
正在写入inode表: 完成                        
Creating journal (32768 blocks): 完成
Writing superblocks and filesystem accounting information: 完成   

[root@localhost ~]# partprobe 
Warning: 无法以读写方式打开 /dev/sr0 (只读文件系统)。/dev/sr0 已按照只读方式打开。
[root@localhost ~]# mkdir /data
[root@localhost ~]# mount /dev/sdb1 /data
[root@localhost ~]# mount -a


echo "/dev/sdb1 /data  ext4  defaults  0 0" >> /etc/fstab
```

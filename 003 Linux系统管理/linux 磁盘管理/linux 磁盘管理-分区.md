# linux 磁盘管理-分区

## fdisk

一般fdisk用来管理linux的磁盘，进行分区，格式化等操作。

fdisk工具只能给小于2TB的磁盘划分分区。若超过2TB，就要使用parted分区工具进行分区。

### 对磁盘进行分区

```bash
#1. 增加硬盘
#增加完硬盘记得重启系统
# lsblk	查看硬盘是否添加成功
...
sdb           8:16   0   20G  0 disk 
[root@zutuanxue ~]# fdisk -l /dev/sdb
Disk /dev/sdb：20 GiB，21474836480 字节，41943040 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

#2. 使用fdisk命令分区
[root@zutuanxue ~]# fdisk /dev/sdb

欢迎使用 fdisk (util-linux 2.32.1)。
更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。

设备不包含可识别的分区表。
创建了一个磁盘标识符为 0x0c7799c3 的新 DOS 磁盘标签。

命令(输入 m 获取帮助)：p
Disk /dev/sdb：20 GiB，21474836480 字节，41943040 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x0c7799c3

命令(输入 m 获取帮助)：n
分区类型
   p   主分区 (0个主分区，0个扩展分区，4空闲)
   e   扩展分区 (逻辑分区容器)
选择 (默认 p)：p
分区号 (1-4, 默认  1): 
第一个扇区 (2048-41943039, 默认 2048): 
上个扇区，+sectors 或 +size{K,M,G,T,P} (2048-41943039, 默认 41943039): +1G

创建了一个新分区 1，类型为“Linux”，大小为 1 GiB。

命令(输入 m 获取帮助)：p
Disk /dev/sdb：20 GiB，21474836480 字节，41943040 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x80e196f2

设备       启动  起点    末尾    扇区 大小 Id 类型
/dev/sdb1        2048 2099199 2097152   1G 83 Linux

命令(输入 m 获取帮助)：n
分区类型
   p   主分区 (1个主分区，0个扩展分区，3空闲)
   e   扩展分区 (逻辑分区容器)
选择 (默认 p)：p
分区号 (2-4, 默认  2): 2
第一个扇区 (2099200-41943039, 默认 2099200): 
上个扇区，+sectors 或 +size{K,M,G,T,P} (2099200-41943039, 默认 41943039): +1G

创建了一个新分区 2，类型为“Linux”，大小为 1 GiB。

命令(输入 m 获取帮助)：p
Disk /dev/sdb：20 GiB，21474836480 字节，41943040 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x80e196f2

设备       启动    起点    末尾    扇区 大小 Id 类型
/dev/sdb1          2048 2099199 2097152   1G 83 Linux
/dev/sdb2       2099200 4196351 2097152   1G 83 Linux

命令(输入 m 获取帮助)：w
分区表已调整。
将调用 ioctl() 来重新读分区表。
正在同步磁盘。



#3. 再次查看分区情况
# lsblk
sdb                       8:16   0   20G  0 disk 
├─sdb1                    8:17   0    1G  0 part 
└─sdb2                    8:18   0    1G  0 part 

#4. 刷新分区表信息
[root@zutuanxue ~]# partprobe /dev/sdb


#5. 格式化分区#文件系统的格式，如ext2、ext3、xfs等
[root@zutuanxue ~]# mkfs.xfs /dev/sdb1
[root@zutuanxue ~]# mkfs.vfat /dev/sdb2

#6. 创建新的挂载点
[root@zutuanxue ~]# mkdir /u01
[root@zutuanxue ~]# mkdir /u02

#7. 挂载使用
[root@zutuanxue ~]# mount /dev/sdb1 /u01
[root@zutuanxue ~]# mount /dev/sdb2 /u02

# 自动挂载
echo '/dev/sdb1 /data xfs defaults 0 0' >> /etc/fstab
mount -a 
```

### fstab参数说明

```txt
# 第一列
## 磁盘设备文件或者该设备的Label或者UUID

# 第二列
## 设备的挂载点

# 第三列
## 磁盘文件系统的格式，包括ext2、ext3、xfs、nfs、vfat等

# 第四列
## 文件系统的参数
### async/sync     设置是否为I/O同步方式运行，默认为async
### auto/noauto    此文件系统是否被主动挂载。默认为auto
### rw/ro               是否以以只读或者读写模式挂载
### exec/noexec   允许执行此分区的二进制文件
### user/nouser    允许任意用户来挂载这一设备
### suid/nosuid     允许suid操作和设定sgid
### defaults           默认的挂载设置（即 rw, suid, dev, exec, auto, nouser, async,acl）

# 第五列
## 设置是否让备份程序dump备份文件系统，0为忽略，1为备份

# 第六列
## 是否检验扇区,0为不要检验
```

### swap扩容

*通过一个大文件扩容swap*

```bash
# 建立一个新的swap文件。
dd if=/dev/zero of=/swap bs=2M count=1024
# 格式化为swap文件
mkswap /swap
# 修改权限
chmod 0600 /swap
# 挂载扩容
swapon /swap
# 永久挂载
echo '/swap swap swap defaults 0 0' >> /etc/fstab
mount -a

```

## parted

​传​​统的MBR分区表格式，仅支持最大四个主分区，而且不可以格式化2TB以上的磁盘，因此，大磁盘更适合使用parted工具进行GPT的分区格式。

parted用于对磁盘（或RAID磁盘）进行分区及管理，与fdisk分区工具相比，支持2TB以上的磁盘分区，并且允许调整分区的大小

### 对磁盘进行分区

```bash
$ parted /dev/sdb
# 对/dev/sdb进行分区或管理操作
 
GNU Parted 3.1
使用 /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
 
(parted) mklabel gpt
# 定义分区表格式（常用的有msdos和gpt分区表格式，msdos不支持2TB以上容量的磁盘，所以大于2TB的磁盘选gpt分区表格式）
 
警告: The existing disk label on /dev/sdb will be destroyed and all data on this disk will be lost. Do you want to continue?
# /dev/sdb上现有的磁盘标签将被销毁，该磁盘上的所有数据将丢失。你想要继续
是/Yes/否/No? yes                                                     
 
(parted) mkpart p1
# 创建第一个分区，名称为p1（p1只是第一个分区的名称，用别的名称也可以，如part1）
 
文件系统类型？  [ext2]? xfs    
# 定义分区格式（不支持ext4，想分ext4格式的分区，可以通过mkfs.ext4格式化成ext4格式）
                                   
起始点？ 1   
# 定义分区的起始位置（单位支持K,M,G,T）
                                                     
结束点？ 100%   
# 定义分区的结束位置（单位支持K,M,G,T）  
                                                  
(parted) print   # 查看当前分区情况
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
 
Number  Start   End    Size   File system  Name  标志
 1      1049kB  107GB  107GB  xfs          p1

##
#3. 再次查看分区情况
# lsblk
vdb             252:16   0   15G  0 disk 
└─vdb1          252:17   0   15G  0 part 

#4. 刷新分区表信息
[root@zutuanxue ~]# partprobe /dev/vdb


#5. 格式化分区#文件系统的格式，如ext2、ext3、xfs等
[root@zutuanxue ~]# mkfs.xfs /dev/vdb1

#6. 创建新的挂载点
[root@zutuanxue ~]# mkdir /data

#7. 自动挂载
echo '/dev/sdb1 /data xfs defaults 0 0' >> /etc/fstab
mount -a 

```

#### 1. 定义分区类型

```bash
$ parted -s /dev/sdb mklabel gpt
# -s表示不输出提示信息
# 如果不是用脚本执行分区操作，不建议忽略提示信息
```

#### 2. 查看磁盘分区信息

```bash
$ parted /dev/sdb print
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
 
Number  Start  End  Size  File system  Name  标志
```

#### 3. 创建与删除分区

```bash
#parted 磁盘 mkpart 分区类型 [文件系统类型] 开始  结束
```

把整个磁盘/dev/sdb创建为一个主分区  

```bash
$ parted /dev/sdb mkpart primary xfs 0% 100%
```

把磁盘/dev/sdb创建为多个主分区

```bash
$ parted /dev/sdb mkpart primary xfs 1G 10G
$ parted /dev/sdb mkpart primary xfs 10G 50%
$ parted /dev/sdb mkpart primary xfs  50% 100%
$ parted /dev/sdb print       # 查看
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
 
Number  Start   End     Size    File system  Name     标志
 1      1000MB  10.0GB  9000MB               primary
 2      10.0GB  53.7GB  43.7GB               primary
 3      53.7GB  107GB   53.7GB               primary
```

删除分区

```bash
## 删除分区号为 1 的分区
$ parted /dev/sdb rm 1

$ parted /dev/sdb print
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     标志
 2      10.0GB  53.7GB  43.7GB               primary

 3      53.7GB  107GB   53.7GB               primary
```

格式化并挂载

```bash
$ mkfs.xfs /dev/sdb2
$ mkdir /data
$ mount /dev/sdb2 /data
$ df -hT /data
文件系统                类型      容量  已用  可用 已用% 挂载点
/dev/sdb2               xfs        41G   33M   41G    1% /data
```

‍

## fdisk，parted使用非交互式方式对磁盘进行分区操作

磁盘分区的时候，平常都是使用交互式的方式进行，但是交互式有时候对一些批量的，或者脚本式的，就不那么友好了

### 1. fdisk 分区

直接进入正题，关于两种分区方式的选型等问题，这里不做讨论。

创建如下交互文本：

```
$ cat fdisk.txt
n




w
```

​`注意：`​文件内容就两步，一个 `n`​，一个 `w`​，但是注意中间有 4 个换行，表示分区过程选项保持默认，如此分配整个磁盘为一个分区。

```
fdisk /dev/vdb < ./fdisk.txt
fdisk /dev/vdc < ./fdisk.txt
```

接下来就是格式化，挂载的事情了，比较常规，下边会给出例子，这里不多赘述。

### 2. parted 风格

debian 系统默认没有 parted 命令，需要先安装：

```
apt-get update
apt-get -y install parted
```

然后创建如下交互文本：

```
$cat parted.txt
mklabel gpt
yes
mkpart
1
ext4
0
100%
Ignore
q
```

文本内也都是格式化过程中需要的步骤，同样是将整块磁盘分给一个分区。

然后进行分区：

```
parted /dev/vdd < ./parted.txt
```

然后对如上分区进行格式化：

```
mkfs.ext4 /dev/vdb1
```

接着创建需要挂载的目录：

```
cd /
mkdir data
```

然后将自动挂载写入配置：

```
echo "/dev/vdb1 /data ext4  defaults 0 0" >> /etc/fstab
```

执行加载命令，查看是否正常。

记录两个常用分区命令的非交互方式，方便日常的操作。

### 3. 插曲

过程中还遇到过一个插曲，`vdc`​磁盘应该按照 fdisk 风格来分区即可，因为这个磁盘并没有超过 2T，可以直接分区，但是当时搞错了分区名称，于是误把此分区给搞成了 gpt 风格的，这个时候想要改回 mbr 分区类型，发现并不太容易。

```
parted /dev/vdc
(parted)mktable
New disk label type? msdos
Warning: The existing disk label on /dev/vdc will be destroyed and all data on
this disk will be lost. Do you want to continue?
Yes/No?Yes
```

​`注意：`​这个地方在重新定义分区类型的时候，并不能写 mbr，或者形如其他分区写成 dos，如果写成这些，命令行将会一直报错，正确的应该是 `msdos`​，然后在保存退出，这个时候此分区就变回所谓的 mbr 分区了。

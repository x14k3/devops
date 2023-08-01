# linux 磁盘概述

## 一、磁盘介绍

磁盘：计算机中的外部存储设备，负责存储计算机数据，并且断电后也能保持数据不丢失。

**磁盘分类：**

按照物理结构：

- 机械磁盘
- 固态磁盘

按照接口:

- IDE
- SCSI
- SATA
- SAS
- mSATA
- M.2
- NVME
- PCIe

按照尺寸：

- 机械硬盘：1.8寸 2.5寸 3.5寸
- 固态硬盘：SATA: 2.5寸
- M.2： 2242、2260、2280

## 二、熟悉磁盘的工作原理

**机械磁盘的读写数据依靠电机带动盘片转动来完成数据读写的。**

#### 机械磁盘剖析图

![机械硬盘结构.jpeg](https://www.zutuanxue.com:8000/static/media/images/2020/10/18/1602986110096.jpeg)

```
为了使磁盘内部清洁，磁盘是在真空特殊环境中制作的，不能随意拆卸，拆开后基本报废了
```

机械磁盘工作是依靠马达带动盘片转动，通过磁头来读取磁盘上的数据。

### 磁盘术语

##### 磁盘

硬盘中一般会有多个盘片组成，每个盘片包含两个面，每个盘面都对应地有一个读/写磁头。受到硬盘整体体积和生产成本的限制，盘片数量都受到限制，一般都在5片以内。盘片的编号自下向上从0开始，如最下边的盘片有0面和1面，再上一个盘片就编号为2面和3面。

##### 磁头

负责读取盘面数据的设备

##### 磁道

从盘片的最内侧向外有很多同心圆圈，我们称为磁道

##### 扇区

从圆心向外画直线，可以将磁道划分为若干个弧段，称之为扇区，一个扇区通常为**512B**

![disk2.png](https://www.zutuanxue.com:8000/static/media/images/2020/10/18/1602986039811.png)

##### 磁柱

硬盘通常由重叠的一组盘片构成，每个盘面都被划分为数目相等的磁道，并从外缘的“0”开始编号，具有相同编号的磁道形成一个圆柱，称之为磁盘的柱面。磁盘的柱面数与一个盘面上的磁道数是相等的。由于每个盘面都有自己的磁头，因此，盘面数等于总的磁头数。

![disk3.png](https://www.zutuanxue.com:8000/static/media/images/2020/10/18/1602986025858.png)

## 三、磁盘的性能指标

#### 影响磁盘性能的指标

**寻道时间（seek time）**【和 转速 相关】：Tseek，是指将读写磁头移动至正确的磁道上所需要的时间。寻道时间越短，I/O操作越快，目前磁盘的平均寻道时间一般在3-15ms

**旋转延迟**：Trotation，是指盘片旋转将请求数据所在的扇区移动到读写磁头下方所需要的时间。旋转延迟取决于磁盘转速，通常用磁盘旋转一周所需时间的1/2表示。比如：7200rpm的磁盘平均旋转延迟大约为60*1000/7200/2 = 4.17ms，而转速为15000rpm的磁盘其平均旋转延迟为2ms。

**数据传输时间**：Ttransfer，是指完成传输所请求的数据所需要的时间

#### 衡量磁盘性能的指标

**IOPS**：IOPS（Input/Output Per Second）即每秒的输入输出量（或读写次数），即指每秒内系统能处理的I/O请求数量。随机读写频繁的应用，如小文件存储等，关注随机读写性能，IOPS是关键衡量指标。可以推算出磁盘的IOPS = 1000ms / (Tseek + Trotation + Transfer)，如果忽略数据传输时间，理论上可以计算出随机读写最大的IOPS。常见磁盘的随机读写最大IOPS为：

- 7200rpm的磁盘 IOPS = 76 IOPS
- 10000rpm的磁盘IOPS = 111 IOPS
- 15000rpm的磁盘IOPS = 166 IOPS

**throughput ：** 吞吐量指单位时间内可以成功传输的数据数量。 单位为（m/s G/s）

![3.png](https://www.zutuanxue.com:8000/static/media/images/2020/10/18/1602986155314.png)

**文件系统：**是告知操作系统使用何种方法和数据结构在存储设备或分区上读写数据的；是分区数据管家，负责如何将数据写入磁盘或者从磁盘读出

NTFS EXT3 EXT4 XFS ISO9660

具体有多少 man mount -t

```
 adfs,  affs,  autofs,  cifs,  coda,  coherent, cramfs,debugfs, devpts, efs, ext, ext2, ext3, ext4, hfs, hfsplus, hpfs,iso9660,  jfs, minix, msdos, ncpfs, nfs, nfs4, ntfs, proc, qnx4,ramfs, reiserfs, romfs, squashfs,  smbfs,  sysv,  tmpfs,  ubifs,udf,  ufs,  umsdos,  usbfs,  vfat, xenix, xfs, xiafs.
```

**文件系统可以根据应用场景去选择使用哪一款，如果不会选择，推荐ext4或者XFS**

**page cache**

其实就是内存上空闲的部分 用来缓存数据，比如buffer cache

作用：对IO读写做优化

测试缓存对读写的影响

```
写
[root@zutuanxue ~]# echo 3 > /proc/sys/vm/drop_caches
[root@zutuanxue ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1980          95        1807           9          77        1754
Swap:          2047           0        2047
[root@zutuanxue ~]# dd if=/dev/zero of=/tmp/big bs=1M count=1000
记录了1000+0 的读入
记录了1000+0 的写出
1048576000字节(1.0 GB)已复制，10.2412 秒，102 MB/秒
[root@zutuanxue ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1980          95         779           9        1105        1698
Swap:          2047           0        2047
[root@zutuanxue ~]# dd if=/dev/zero of=/tmp/big1 bs=1M count=1000
记录了1000+0 的读入
记录了1000+0 的写出
1048576000字节(1.0 GB)已复制，7.89978 秒，133 MB/秒

读
[root@zutuanxue ~]# echo 3 > /proc/sys/vm/drop_caches 
[root@zutuanxue ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1980          95        1805           9          79        1753
Swap:          2047           0        2047
[root@zutuanxue ~]# dd if=/tmp/big of=/dev/null 
记录了2048000+0 的读入
记录了2048000+0 的写出
1048576000字节(1.0 GB)已复制，2.23965 秒，468 MB/秒
[root@zutuanxue ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1980          95         800           9        1084        1710
Swap:          2047           0        2047
[root@zutuanxue ~]# dd if=/tmp/big of=/dev/null 
记录了2048000+0 的读入
记录了2048000+0 的写出
1048576000字节(1.0 GB)已复制，1.92811 秒，544 MB/秒
```

## 四、linux磁盘的使用方法

### 4.1、磁盘初始化

**一块新的磁盘使用必须初始化为MBR或者GPT分区。**

- **MBR &lt;2TB fdisk** **4个主分区或者3个主分区+1个扩展分区（N个逻辑分区）**

MBR(Master Boot Record)的缩写，由三部分组成，即：

1. Bootloader（主引导程序）=

   446字节

   - 引导操作系统的主程序
2. DPT分区表（Disk Partition Table）=

   64字节

   - 分区表保存了硬盘的分区信息，操作系统通过读取分区表内的信息，就能够获得该硬盘的分区信息
   - 每个分区需要占用16个字节大小，保存有文件系统标识、起止柱面号、磁头号、扇区号、起始扇区位置（4个字节）、分区总扇区数目（4个字节）等内容
   - 分区表中保存的分区信息都是主分区与扩展分区的分区信息，扩展分区不能直接使用，需要在扩展分区内划分一个或多个逻辑分区后才能使用
   - 逻辑分区的分区信息保存在扩展分区内而不是保存在MBR分区表内，这样，就可以突破MBR分区表只能保存4个分区的限制
3. 硬盘有效标志（校验位）=2个字节

- **GPT &gt;2TB gdisk(parted) 128个主分区**

注意：从MBR转到GPT，或从GPT转换到MBR会导致**数据全部丢失**！

### 4.2、分区

**将磁盘合理分区，能使计算机或者使用者更快的存取数据**

MBR 主分区+扩展分区<=4

GPT 主分区<=128

### 4.3、格式化

**装载文件系统(相当于库管，负责数据的写入和读出)。**

常见的文件系统:NTFS EXT EXT2 EXT3 EXT4 XFS vfat

### 4.4、挂载

**linux中设备不能直接使用，需要挂载到文件夹才可以。**

#### 手动挂载

mount挂载命令

```
mount - mount a filesystem

命令语法
mount device dir

命令选项
-a   挂载所有文件系统，参考文件 /etc/fstab
-l   显示当前挂载
-t   文件系统类型
-o   指定挂载权限

##用法说明
mount   [options]     需要挂载的设备     挂载点
特点：系统重启后需要重新挂载；手动卸载后需要手动挂载

-o:挂载选项	ro,sync,rw,remount
-t:文件系统类型
mount -t nfs=mount.nfs
mount -t cifs=mount.cifs
```

挂载分区演示

```
#案列1：以只读的方式重新挂载/u02分区
[root@zutuanxue ~]# mount -o remount,ro /u02		//可以是挂载点也可以是设备
remount:重新挂载一个正在挂载的设备

# mount -o remount,ro /dev/sdb1		
# mount -o remount,ro /u01
注意：后面可以根挂载点也可以跟设备本身


#案例2: 如果希望将本机的某个文件夹挂到另一个文件夹
mount -o bind /etc /opt/data3
```

设备表示方法：

- 设备文件
- 设备UUID
- 设备的卷标

```
#设备文件：
/dev/sdb
/dev/sdb1

#通过UUID表示设备
[root@zutuanxue ~]# blkid /dev/sdb1				//查看设备的UUID和文件系统类型
/dev/sdb1: UUID="96b67b7b..." TYPE="xfs" PARTUUID="80e196f2-01"
[root@zutuanxue ~]# blkid /dev/sdb2
/dev/sdb2: UUID="6821-049E" TYPE="vfat" PARTUUID="80e196f2-02"


#通过卷标表示设备
#不同类型分区卷标管理与查看
ext*设置&查看卷标
[root@zutuanxue ~]# e2label /dev/sdb1 DISK1			ext*设置卷标
[root@zutuanxue ~]# e2label /dev/sdb1						ext*查看卷标

xfs设置&查看卷标
[root@zutuanxue ~]# xfs_admin -L DISK1 /dev/sdb1	xfs设置卷标
[root@zutuanxue ~]# xfs_admin -l /dev/sdb1				xfs查看卷标
label = "DISK1"

vfat设置&查看卷标
[root@zutuanxue ~]# dosfslabel /dev/sdb2 hello
[root@zutuanxue ~]# dosfslabel /dev/sdb2

也可以使用blkid查看卷标
[root@zutuanxue ~]# blkid /dev/sdb1
/dev/sdb1: LABEL="DISK1" UUID="96.." TYPE="xfs" PARTUUID="80..-01"
[root@zutuanxue ~]# blkid /dev/sdb2
/dev/sdb2: LABEL="disk2" UUID="6..." TYPE="vfat" PARTUUID="8e.2-02"
```

umount设备卸载命令
命令详解

```
umount - 卸载文件系统

umount 设备挂载点|设备源

-l  懒惰卸载
```

命令用法演示

```
卸载设备：umount
[root@zutuanxue ~]# umount /u01
[root@zutuanxue ~]# umount /dev/sdb2
```

#### 开机自动挂载

自动挂载 /etc/fstab文件
特点：系统开机或重启会自动挂载；手动卸载后，使用mount -a自动挂载

```
文件内容格式：
要挂载的资源路径	挂载点	文件系统类型	挂载选项	dump备份支持  文件系统检测
UUID=289370eb-9459-42a8-8cee-7006507f1477   /      ext4    defaults        1 1

#字段说明
1段：挂载的设备（磁盘设备的文件名或设备的卷标或者是设备的UUID）
2段：挂载点（建议用一个空目录），建议不要将多个设备挂载到同一个挂载点上
3段：文件系统类型（ext3、ext4、vfat、ntfs（安装软件包）、swap等等）
4段：挂载选项
dev/nodev		被挂载的设备上的设备文件，是否被识别为设备文件
async/sync  异步/同步 同步利于数据保存 异步利于提高性能
auto/noauto     自动/非自动：
rw/ro   读写/只读：
exec/noexec     被挂载设备中的可执行文件是否可执行
remount     重新挂在一个已经挂载的文件系统，常用于修改挂载参数
user/nouser     允许/不允许其他普通用户挂载：
suid/nosuid     具有/不具有suid权限：该文件系统是否允许SUID的存在。
usrquota    这个是在启动文件系统的时候，让其支持磁盘配额，这个是针对用户的。
grpquota    支持用户组的磁盘配额。
....
defaults 同时具有rw, dev, exec,  async,nouser等参数。
更多挂载选项可以通过 man mount  -o 命令选项可以找到详细信息

5段：是否支持dump备份。//dump是一个用来备份的命令，0代表不要做dump备份，1代表要每天进行dump的动作，2也代表其他不定日期的dump备份。通常这个数值不是0就是1。数字越小优先级越高。

6段：是否用 fsck 检验扇区。//开机的过程中，系统默认会用fsck检验文件系统是否完整。0是不要检验，1表示最先检验(一般只有根目录会设定为1)，2也是要检验，只是1是最先，2是其次才进行检验。

# fsck -f /dev/sdb2		强制检验/dev/sdb2上文件系统

说明：
要挂载的资源路径可以是文件系统的UUID，设备路径，文件系统的标签 ，光盘镜像文件（iso），亦或是来自网络的共享资源等
```

#### 自动挂载 Automount

特点：挂载是由访问产生；卸载是由超时产生；依赖于后台的autofs服务

思路：

1. 所有的监控都是由一个程序完成 autofs
2. 服务启动后才会监控挂载的设备
3. 修改配置文件来指定需要监控的设备

案例演示
需求：让系统自动挂载/dev/sdb2设备，如果2分钟没有被用自动卸载

```
步骤：
1）安装autofs软件
[root@zutuanxue ~]# rpm -q autofs
package autofs is not installed
[root@zutuanxue ~]# dnf install autofs

[root@zutuanxue ~]# rpm -q autofs
autofs-5.1.4-29.el8.x86_64
2）修改配置文件（指定需要监控的设备和挂载的目录）
vim /etc/auto.master		//定义一级挂载点/u01和子配置文件
/u01    /etc/auto.test	-t 120 或者 --timeout 120  单位秒   （设置超时时间去卸载）

vim /etc/auto.test			//子配置文件自己创建，定义二级挂载点和需要挂载的设备
test  -fstype=ext4,ro   :/dev/sdb2


3）重启服务
[root@zutuanxue ~]# systemctl restart autofs

4）测试验证
[root@zutuanxue ~]# ls /u01/test
[root@zutuanxue ~]# df -h


后续补充：
如果想要将/dev/sdb2挂载到/u01下，怎么做？
vim /etc/auto.master
/-		/etc/auto.test

vim /etc/auto.test
/u01	-fstype=ext4 :/dev/sdb2
```

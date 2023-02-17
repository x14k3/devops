#server/storage

**磁盘阵列**（Redundant Arrays of Independent Disks，RAID），全称独立磁盘冗余阵列。

磁盘阵列是由很多**廉价**的磁盘，组合成一个**容量巨大**的磁盘组，利用个别磁盘提供数据所产生加成效果提升整个磁盘系统效能。利用这项技术，将数据切割成许多区段，分别存放在各个硬盘上。

![](assets/RAID%20说明/image-20221127190731183.png)

**条带(strip)：** 硬盘中单个或者多个连续的扇区构成一个条带，它是一块硬盘上数据读写的最小单元、是组成分条的元素。
**分条(stipe)：** 同一硬盘阵列中的多个硬盘驱动器上的相同“位置”（或者说是相同编号）的条带。
**分条宽度：** 指在一个分条中数据成员盘的个数。
**分条深度：** 指一个条带的容量大小。

# 一、RAID 级别

RAID方案常见的可以分为：RAID0，RAID1，RAID5，RAID10 。下面来分别介绍一下。

## 1.RAID0

RAID 0，中文称之为**条带化存储**，它代表了所有RAID级别中**最高的存储性能**。

原理：
是把连续的数据分散到多个磁盘上存取，系统有数据请求就可以被多个磁盘并行的执行，每个磁盘执行属于它自己的那部分数据请求。这种数据上的并行操作可以充分利用总线的**带宽**，显著提高磁盘整体存取性能。

![](assets/RAID%20说明/image-20221127191030998.png)

优点
- 充分利用I/O总线性能使其带宽翻倍，读/写速度翻倍
- 充分利用磁盘空间，利用率为100%

缺点
- 不提供数据冗余
- 无数据检验，不能保证数据的正确性
- 存在单点故障

应用场景：对数据完整性要求不高的场景，如：日志存储，个人娱乐 要求读写效率高，安全性能要求不高，如图像工作站


---

## 2.RAID1

RAID 1 中文称之为**镜像存储**。RAID 1是磁盘阵列中单位**成本最高**的，磁盘**利用率最低**，但提供了**很高的数据安全性和可用性**。

原理：
将一个两块硬盘所构成RAID磁盘阵列，其容量仅等于一块硬盘的容量，因为另一块只是当作数据“镜像”通过镜像实现**数据冗余**，成对的独立磁盘上产生互为备份的数据。当原始数据繁忙时，可直接从镜像拷贝中读取数据，因此RAID 1可以**提高读取性能**。当一个磁盘失效时，系统可以自动切换到镜像磁盘上读写，而不需要重组失效的数据。最大允许互为镜像内的单个磁盘故障，如果出现互为镜像的两块磁盘故障则数据丢失。

![](assets/RAID%20说明/image-20221127191838518.png)

优点
- 提供数据冗余，数据双倍存储。
- 提供良好的读性能

缺点：
- 无数据校验
- 磁盘利用率低，成本高

应用场景：存放重要数据，如数据存储领域

---

## 3.RAID5

**奇偶校验（XOR）**，RAID 0和RAID 1的折中方案。

原理：

数据以块分段**条带化存储**。校验信息交叉地存储在所有的数据盘上。数据和相对应的奇偶校验信息存储到组成RAID5的各个磁盘上，并且**奇偶校验信息和相对应的数据分别存储于不同的磁盘上**，其中任意N-1块磁盘上都存储完整的数据

![](assets/RAID%20说明/image-20221127192023784.png)

优点：
- 读写性能高
- 有校验机制
- 磁盘空间利用率高

缺点：磁盘越多安全性能越差

应用场景：安全性高，如金融、数据库、存储等。


## 4.RAID01

RAID 0和RAID 1的**组合形式**

原理：

先做RAID 0再将RAID 0组合成RAID 1，**拥有两种RAID的特性**。

![](assets/RAID%20说明/image-20221127192653048.png)

优点：
- 较高的IO性能
- 有数据冗余
- 无单点故障

缺点：
- 成本稍高
- 安全性比RAID 10 差

应用场景：特别适用于既有大量数据需要存取，同时又对数据安全性要求严格的领域，如银行、金融、商业超市、仓储库房、各种档案管理等。


## 5.RAID10

RAID 0和RAID 1的**组合形式**

**原理：**

先做RAID 1再将RAID 1组合成RAID 0，**拥有两种RAID的特性**，**安全性能高**。

![](assets/RAID%20说明/image-20221127193305072.png)

优点：
- RAID10的读性能将优于RAID01
- 较高的IO性能
- 有数据冗余
- 无单点故障
- 安全性能高

缺点：成本稍高

应用场景：特别适用于既有大量数据需要存取，同时又对数据安全性要求严格的领域，如银行、金融、商业超市、仓储库房、各种档案管理等。


## 6.RAID50

RAID50也被称为**镜象阵列条带**

**原理：**

先做RAID 5再将RAID 5组合成RAID 0，拥有**两种RAID的特性**。

需要的磁盘数 ≥ 6


# 二、硬RAID与软RAID

## 1.硬RAID

硬件raid就是采用专门的硬件raid控制器链接硬盘和电脑，硬件raid外设将所有链接的硬盘组成一个硬盘卷，对于系统而言只能直接识别一整个raid硬盘卷，而无法识别到整个raid卷里的单个成员盘。

硬件raid全面具备了自己的计算单元与I/O芯片，甚至还有数据缓冲，对于CPU的占用比较小。

## 2.软RAID

软件raid就是不使用硬件raid设备，仅仅通过操作系统或硬件bios底层来实现raid，这其中所有的功能都由CPU来实现，对CPU的负担也是最重的，软件raid的各个成员盘对于操作系统都是见的，但是只以一整个raid分卷使用。


# mdadm

mdadm命令，其功能是用于管理RAID磁盘阵列组。作为Linux系统下软RAID设备的管理神器，mdadm命令可以进行创建、调整、监控、删除等全套管理操作。

**1. 安装**

`yum install -y mdadm`

**2. 分区**

对两块数据盘进行分区，并设置分区类型为raid

```bash
[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   30G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   29G  0 part 
  ├─centos-root 253:0    0   26G  0 lvm  /
  └─centos-swap 253:1    0    3G  0 lvm  [SWAP]
sdb               8:16   0   20G  0 disk 
sdc               8:32   0   20G  0 disk 
sr0              11:0    1  9.5G  0 rom

[root@localhost ~]# fdisk /dev/sdb
欢迎使用 fdisk (util-linux 2.23.2)。

更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。


命令(输入 m 获取帮助)：n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
分区号 (1-4，默认 1)：1
起始 扇区 (2048-41943039，默认为 2048)：
将使用默认值 2048
Last 扇区, +扇区 or +size{K,M,G} (2048-41943039，默认为 41943039)：
将使用默认值 41943039
分区 1 已设置为 Linux 类型，大小设为 20 GiB

命令(输入 m 获取帮助)：t
已选择分区 1
Hex 代码(输入 L 列出所有代码)：fd

已将分区“Linux”的类型更改为“Linux raid autodetect”

命令(输入 m 获取帮助)：w
The partition table has been altered!

Calling ioctl() to re-read partition table.
正在同步磁盘。

[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   30G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   29G  0 part 
  ├─centos-root 253:0    0   26G  0 lvm  /
  └─centos-swap 253:1    0    3G  0 lvm  [SWAP]
sdb               8:16   0   20G  0 disk 
└─sdb1            8:17   0   20G  0 part 
sdc               8:32   0   20G  0 disk 
└─sdc1            8:33   0   20G  0 part 
sr0              11:0    1  9.5G  0 rom  
[root@localhost ~]# 

```

**3. 创建raid1**

1.创建raid1阵列

```bash
mdadm -C /dev/md0 -ayes -l1 -n2 /dev/sd[b,c]1
# 命令说明：
-C       # 创建阵列;
-a       # 同意创建设备，如不加此参数时必须先使用mknod 命令来创建一个RAID设备，不过推荐使用-a yes参数一次性创建;
-l       # 阵列模式;
-n       # 阵列中活动磁盘的数目，该数目加上备用磁盘的数目应该等于阵列中总的磁盘数目;
/dev/md0 # 阵列的设备名称，如果还有其他阵列组可以以此类推；

```

2.查看阵列状态

```bash
# 使用mdadm -D /dev/md0查看阵列组的状态
mdadm -D /dev/md0
# 使用cat /proc/mdstat查看阵列状态
cat /proc/mdstat

```

**4. 创建md0的配置文件**

mdadm 配置文件并不存在，需要手工建立。我们使用以下命令建立 /etc/mdadm.conf 配置文件

```bash
# #建立/etc/mdadm.conf配置立件，并把组成RAID的分区的设备文件名写入
# #比如组成RAID10，就既要把分区的设备文件名放入此文件中，也要把组成RAID0的RAID1设备文件名放入
echo DEVICE /dev/sd{b,c}1 >> /etc/mdadm.conf
# 查询和扫描RAID信息，并追加进/etc/mdadm.conf文件
mdadm -Ds >> /etc/mdadm.conf
# mdadm -Evs >> /etc/mdadm.conf

```

**5. 格式化与挂载RAID**

RAID1 已经创建，但是要想正常使用，也需要格式化和挂载

```bash
mkfs.xfs /dev/md0
mkdir /raid
mount /dev/md0 /raid/

```

**6. 启动或停止RAID**

RAID 设备生效后，不用手工启动或停止。但是，如果需要卸载 RAID 设备，就必须手工停止 RAID

```bash
# 停止/dev/md0设备
mdadm -S /dev/md0

```

**7. 模拟磁盘损坏**

```bash
 # 选项f是用于模拟磁盘损坏
mdadm /dev/md0 -f /dev/sdb1
# 查看状态
mdadm -D /dev/md0
# 重启
reboot
# 添加磁盘
mdadm /dev/md0 -a /dev/sdb1
mdadm -D /dev/md10

```

## mdadm相关命令
mdadm是multiple devices admin的简称，它是Linux下的一款标准的软件 RAID 管理工具

基本语法 : `mdadm [模式] [RAID设备文件名] [选项]`

| mode模块   | 主要功能                   |   |
| -------- | ---------------------- | - |
| Create   | 创建一个阵列，每个设备都具有超级块；     |   |
| Build    | 创建一个没有超级块的阵列；          |   |
| Manage   | 管理阵列，如添加设备和删除损坏设备；     |   |
| Assemble | 加入一个已经存在的阵列；           |   |
| Misc     | 允许单独对阵列中的设备进行操作，如停止阵列； |   |
| Monitor  | 监控RAID状态；              |   |
| Grow     | 改变RAID的容量或阵列中的数目；      |   |

**options:**

```bash
-s,-scan               # 扫描配置文件或/proc/mdstat文件，发现丟失的信息；
-D,-detail             # 查看磁盘阵列详细信息；
-C,-create             # 建立新的磁盘阵列，也就是调用 Create模式；
-a,-auto=yes           # 采用标准格式建立磁阵列
-n,-raicklevices=数字  # 使用几块硬盘或分区组成RAID
-l,-level=级别         # 创建RAID的级别，可以是0,1,5
-x,-spare-devices=数字 # 使用几块硬盘或分区组成备份设备
-a,-add 设备文件名      # 在已经存在的RAID中加入设备
-r,-remove 设备文件名名 # 在已经存在的RAID中移除设备
-f,-fail设备文件名      # 把某个组成RAID的设备设置为错误状态
-S,-stop               # 停止RAID设备
-A,-assemble           # 按照配置文件加载RAID
```


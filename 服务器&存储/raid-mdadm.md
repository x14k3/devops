#server/storage

## 1.安装mdadm

`yum install -y mdadm`

## 2.分区

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

## 3.创建raid1

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

## 4.创建md0的配置文件

mdadm 配置文件并不存在，需要手工建立。我们使用以下命令建立 /etc/mdadm.conf 配置文件

```bash
# #建立/etc/mdadm.conf配置立件，并把组成RAID的分区的设备文件名写入
# #比如组成RAID10，就既要把分区的设备文件名放入此文件中，也要把组成RAID0的RAID1设备文件名放入
echo DEVICE /dev/sd{b,c}1 >> /etc/mdadm.conf
# 查询和扫描RAID信息，并追加进/etc/mdadm.conf文件
mdadm -Ds >> /etc/mdadm.conf
# mdadm -Evs >> /etc/mdadm.conf

```

## 5.格式化与挂载RAID

RAID1 已经创建，但是要想正常使用，也需要格式化和挂载

```bash
mkfs.xfs /dev/md0
mkdir /raid
mount /dev/md0 /raid/

```

## 6.启动或停止RAID

RAID 设备生效后，不用手工启动或停止。但是，如果需要卸载 RAID 设备，就必须手工停止 RAID

```bash
# 停止/dev/md0设备
mdadm -S /dev/md0

```

## 7.模拟磁盘损坏

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

## 8.mdadm命令
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

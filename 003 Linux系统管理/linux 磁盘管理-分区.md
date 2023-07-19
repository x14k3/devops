# linux 磁盘管理-分区

# fdisk

一般fdisk用来管理linux的磁盘，进行分区，格式化等操作。

fdisk工具只能给小于2TB的磁盘划分分区。若超过2TB，就要使用parted分区工具进行分区。

### 添加硬盘扩容

1. 增加一块硬盘
2. 使用fdisk命令进行分区
3. 格式化指定分区
4. 创建一个空的目录作为挂载点
5. 挂载使用

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

# parted

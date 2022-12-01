#server/storage


一般fdisk用来管理linux的磁盘，进行分区，格式化等操作。

fdisk工具只能给小于2TB的磁盘划分分区。若超过2TB，就要使用parted分区工具进行分区。

### 添加硬盘扩容

```bash
# 查看硬盘分区情况
fdisk -l

# 设置分区
fdisk /dev/sdb 
# n - 创建分区;p - 打印分区表;d - 删除一个分区;q - 不保存更改退出;w - 保存更改并退出

# 格式化新分区
#文件系统的格式，如ext2、ext3、xfs等
mkfs.xfs /dev/sdb1

# 挂载新分区
mkdir  /data2
mount /dev/sdb1 /data2

# 卸载
umount -v /dev/sdb1    # 通过设备名卸载
umount -v /data2       # 通过挂载点卸载


# 自动挂载
echo '/dev/sdb1 /data2 xfs defaults 0 0' >> /etc/fstab
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

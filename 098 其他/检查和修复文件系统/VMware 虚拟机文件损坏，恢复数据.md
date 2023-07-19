# VMware 虚拟机文件损坏，恢复数据

宿主机宕机，导致VMware 虚拟机文件损坏，无法启动，尝试恢复原虚拟机中的数据库

1. 新建虚拟机，安装配置过程中使用一块新虚拟硬盘，同时添加原虚拟机的磁盘文件(*.vmdk)
2. 分区时将操作系统安装到新虚拟硬盘，不要选择[添加的原虚拟机的磁盘文件]
3. 安装完成后重启虚拟机
4. lsblk 查看原虚拟机磁盘，mount 挂载到指定目录
5. 最后通过ftp或其他方式将原虚拟机磁盘的文件拷贝至宿主机

**VMware 下 lvm格式磁盘文件异机挂载过程**

参考 [xfs_repair 恢复文件](xfs_repair%20恢复文件.md)

```bash
[root@localhost ~]# lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda             8:0    0   10G  0 disk 
├─sda1          8:1    0    1G  0 part /boot
└─sda2          8:2    0    9G  0 part 
  ├─cl00-root 253:0    0    8G  0 lvm  /
  └─cl00-swap 253:1    0    1G  0 lvm  [SWAP]
sdb             8:16   0  100G  0 disk 
├─sdb1          8:17   0    1G  0 part 
└─sdb2          8:18   0   99G  0 part 
  ├─cl-swap   253:2    0  7.9G  0 lvm  
  └─cl-home   253:3    0 29.9G  0 lvm  
sdc             8:32   0   60G  0 disk 
└─sdc1          8:33   0   60G  0 part 
sr0            11:0    1  9.3G  0 rom

# pv /dev/sdc1 丢失
[root@localhost ~]# pvs
  WARNING: ignoring metadata seqno 6 on /dev/sdc1 for seqno 7 on /dev/sdb2 for VG cl.
  WARNING: Inconsistent metadata found for VG cl.
  See vgck --updatemetadata to correct inconsistency.
  WARNING: VG cl was previously updated while PV /dev/sdc1 was missing.
  WARNING: VG cl was missing PV /dev/sdc1 MsnB5y-egfZ-xqnP-yrj5-aQtw-eDxY-X5A10G.
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda2  cl00 lvm2 a--   <9.00g    0 
  /dev/sdb2  cl   lvm2 a--  <99.00g    0 
  /dev/sdc1  cl   lvm2 a-m  <60.00g    0

[root@localhost ~]# lvscan 
  WARNING: ignoring metadata seqno 6 on /dev/sdc1 for seqno 7 on /dev/sdb2 for VG cl.
  WARNING: Inconsistent metadata found for VG cl.
  See vgck --updatemetadata to correct inconsistency.
  WARNING: VG cl was previously updated while PV /dev/sdc1 was missing.
  WARNING: VG cl was missing PV /dev/sdc1 MsnB5y-egfZ-xqnP-yrj5-aQtw-eDxY-X5A10G.
  ACTIVE            '/dev/cl/swap' [<7.88 GiB] inherit
  ACTIVE            '/dev/cl/home' [29.89 GiB] inherit
  inactive          '/dev/cl/root' [121.22 GiB] inherit
  ACTIVE            '/dev/cl00/swap' [1.00 GiB] inherit
  ACTIVE            '/dev/cl00/root' [<8.00 GiB] inherit
# 
[root@localhost ~]# vgchange -a y cl
  WARNING: ignoring metadata seqno 6 on /dev/sdc1 for seqno 7 on /dev/sdb2 for VG cl.
  WARNING: Inconsistent metadata found for VG cl.
  See vgck --updatemetadata to correct inconsistency.
  WARNING: VG cl was previously updated while PV /dev/sdc1 was missing.
  WARNING: VG cl was missing PV /dev/sdc1 MsnB5y-egfZ-xqnP-yrj5-aQtw-eDxY-X5A10G.
  Refusing activation of partial LV cl/root.  Use '--activationmode partial' to override.
  2 logical volume(s) in volume group "cl" now active

[root@localhost ~]# vgextend --restoremissing cl /dev/sdc1
  WARNING: ignoring metadata seqno 6 on /dev/sdc1 for seqno 7 on /dev/sdb2 for VG cl.
  WARNING: Inconsistent metadata found for VG cl.
  See vgck --updatemetadata to correct inconsistency.
  WARNING: VG cl was previously updated while PV /dev/sdc1 was missing.
  WARNING: VG cl was missing PV /dev/sdc1 MsnB5y-egfZ-xqnP-yrj5-aQtw-eDxY-X5A10G.
  WARNING: VG cl was previously updated while PV /dev/sdc1 was missing.
  WARNING: updating old metadata to 8 on /dev/sdc1 for VG cl.
  Volume group "cl" successfully extended
[root@localhost ~]# pvs
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda2  cl00 lvm2 a--   <9.00g    0 
  /dev/sdb2  cl   lvm2 a--  <99.00g    0 
  /dev/sdc1  cl   lvm2 a--  <60.00g    0 

[root@localhost ~]# vgchange -a y cl
  3 logical volume(s) in volume group "cl" now active
[root@localhost ~]# ll
总用量 8
-rw-------. 1 root root 1084 12月 23 20:53 anaconda-ks.cfg
-rw-r--r--. 1 root root 2495 12月 23 21:17 CentOS-Base.repo

# 此刻恢复正常
[root@localhost ~]# lsblk
NAME          MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda             8:0    0    10G  0 disk 
├─sda1          8:1    0     1G  0 part /boot
└─sda2          8:2    0     9G  0 part 
  ├─cl00-root 253:0    0     8G  0 lvm  /
  └─cl00-swap 253:1    0     1G  0 lvm  [SWAP]
sdb             8:16   0   100G  0 disk 
├─sdb1          8:17   0     1G  0 part 
└─sdb2          8:18   0    99G  0 part 
  ├─cl-swap   253:2    0   7.9G  0 lvm  
  ├─cl-home   253:3    0  29.9G  0 lvm  
  └─cl-root   253:4    0 121.2G  0 lvm  
sdc             8:32   0    60G  0 disk 
└─sdc1          8:33   0    60G  0 part 
  └─cl-root   253:4    0 121.2G  0 lvm  
sr0            11:0    1   9.3G  0 rom

# 尝试挂载
[root@localhost /]# mount -o loop  /dev/cl/root /data/
mount: /test: mount(2) system call failed: 结构需要清理.

# 尝试修复
[root@localhost ~]# xfs_repair /dev/mapper/cl-root 
Phase 1 - find and verify superblock...
Phase 2 - using internal log
        - zero log...
ERROR: The filesystem has valuable metadata changes in a log which needs to
be replayed.  Mount the filesystem to replay the log, and unmount it before
re-running xfs_repair.  If you are unable to mount the filesystem, then use
the -L option to destroy the log and attempt a repair.
Note that destroying the log may cause corruption -- please attempt a mount
of the filesystem before doing this.

[root@localhost ~]# xfs_repair /dev/mapper/cl-root -L

# 修复完成后在把磁盘挂上，即可生效
[root@webc ~]# mount /dev/mapper/cl-root /data/

# 此刻文件系统已修复完毕  

# 注意：  
  # 修复其他文件系统使用fsck命令进行修复  
  # ext4文件系统，使用命令 fsck.ext4 /dev/sda1 修复，  
  # 如果是xfs文件系统，使用命令 xfs_repair -L /dev/sda1 修复，
```

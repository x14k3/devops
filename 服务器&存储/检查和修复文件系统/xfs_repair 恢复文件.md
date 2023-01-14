## 1.现状 

目前网上出现大量的主机输入输出错误，原因是由于主机文件系统损坏。一线人员大部分采用的是umont 和 mount的方式恢复，这种恢复方式不能真正修复已经损坏的文件系统，在后续使用过程中，仍然会再次出现主机端输入输出错误。 

## 2.需要修复的场景 

<1>.主机侧发现存在文件系统不可读写的情况，也可以通过查看主机端日志来确认是否有文件系统异常发生： xfs\_force\_shutdown 、I/O error   
<2>.出现异常停电，供电恢复正常，主机和阵列系统重起之后   
<3>.存储介质故障：出现LUN失效、RAID失效、以及IO超时或者出现慢盘，对慢盘进行更换，系统恢复正常之后   
<4>.传输介质故障：如光纤、网线等损坏等，数据传输链路断开后又恢复正常之后

## 3.检查文件系统 

注：检查文件系统必须保证将文件系统umount成功。   
在根目录下输入“xfs\_check /dev/sdd（盘符）；echo $?”（注意：在执行 此命令之前，必须将文件系统umount，否则会出现警告信 “xfs\_check: /dev/sdd contains a mounted and writable filesystem ”）敲回车键，查看命令执行返回值：0表示正常，其他为不正常，说明文件系统 损坏，需要修复。

## 4.修复过程

注：修复时需要暂停主机侧的业务，umount 和 mount 无法修复文件系统 。   
1) 先umount要修复的文件系统的分区   
3) 然后输入 “xfs\_repair /dev/sdd（盘符）”执行修复命令。   
xfs\_check /dev/sdd; echo $?   
  A）如果为0 >成功修复。   
  B)   如果不为0 >没有成功：请执行xfs\_repair –L /dev/sdd命令，再执 行xfs\_repair（反复多修复几次）

## 5.xfs常用命令 

```bash
xfs_admin: 调整 xfs 文件系统的各种参数   
xfs_copy: 拷贝 xfs 文件系统的内容到一个或多个目标系统（并行方式）   
xfs_db: 调试或检测 xfs 文件系统（查看文件系统碎片等）   
xfs_check: 检测 xfs 文件系统的完整性   
xfs_bmap: 查看一个文件的块映射   
xfs_repair: 尝试修复受损的 xfs 文件系统   
xfs_fsr: 碎片整理   
xfs_quota: 管理 xfs 文件系统的磁盘配额   
xfs_metadump: 将 xfs 文件系统的元数据 (metadata) 拷贝到一个文件中   
xfs_mdrestore: 从一个文件中将元数据 (metadata) 恢复到 xfs 文件系统   
xfs_growfs: 调整一个 xfs 文件系统大小（只能扩展）   
xfs_logprint: print the log of an XFS filesystem   
xfs_mkfile: create an XFS file   
xfs_info: expand an XFS filesystem   
xfs_ncheck: generate pathnames from i-numbers for XFS   
xfs_rtcp: XFS realtime copy command   
xfs_freeze: suspend access to an XFS filesystem   
xfs_io: debug the I/O path of an XFS filesystem
```


## 6.具体应用

```bash
# 查看文件块状况: 
xfs_bmap -v sarubackup.tar.bz2
# 查看磁盘碎片状况: 
xfs_db -c frag -r /dev/sda1
# 文件碎片整理: 
xfs_fsr sarubackup.tar.bz2
# 磁盘碎片整理: 
xfs_fsr /dev/sda1

```

首先尝试mount和umount文件系统，以便重放日志，修复文件系统，如果不行，再进行如下操作。


## 1、检查文件系统：

先确保umount  
xfs\_check /dev/sdd(盘符); echo $?   
返回0表示正常

检查文件系统是否损坏，如何损坏会列出将要执行的操作  
如果幸运的话，会发现没有问题，你可以跳过后续的操作。  
该命令将表明会做出什么修改，一般情况下速度很快，即便数据量很大，没理由跳过。

## 3、执行xfs\_repair修复文件系统

xfs\_repair /dev/sdd (ext系列工具为fsck)

## 4、最后方法

损失部分数据的修复方法

根据打印消息，修复失败时：  
先执行xfs\_repair -L /dev/sdd(清空日志，会丢失文件)，再执行xfs\_repair /dev/sdd，再执行xfs\_check /dev/sdd 检查文件系统是否修复成功。

说明：-L是修复xfs文件系统的最后手段，慎重选择，它会清空日志，会丢失用户数据和文件。

## 备注：

在执行xfs\_repair操作前，最好使用xfs\_metadump工具保存元数据，一旦修复失败，最起码可以恢复到修复之前的状态。  
xfs\_metadump为调试工具，可以不管，跳过。
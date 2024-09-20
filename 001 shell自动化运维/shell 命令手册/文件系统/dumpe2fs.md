# dumpe2fs

　　‍

　　了解文件系统之后，我们可以使用 dumpe2fs 命令来查看文件系统的详细信息，此命令的基本格式如下：

```bash
[root@www ~]# dumpe2fs [-h] 文件名
```

　　-h 选项的含义是仅列出 superblock（超级块）的数据信息；

　　例如，通过 df 命令找到根目录硬盘的文件名，然后使用 dump2fs 命令观察文件系统的详细信息，执行命令如下：

```bash
[root@localhost ~]# df   <==这个命令可以叫出目前挂载的装置
Filesystem    1K-blocks      Used Available Use% Mounted on
/dev/hdc2       9920624   3822848   5585708  41% /
/dev/hdc3       4956316    141376   4559108   4% /home
/dev/hdc1        101086     11126     84741  12% /boot
tmpfs            371332         0    371332   0% /dev/shm

[root@localhost ~]# dumpe2fs /dev/hdc2
dumpe2fs 1.39 (29-May-2006)
Filesystem volume name:   /1             <==这个是文件系统的名称(Label)
Filesystem features:      has_journal ext_attr resize_inode dir_index
  filetype needs_recovery sparse_super large_file
Default mount options:    user_xattr acl <==默认挂载的参数
Filesystem state:         clean          <==这个文件系统是没问题的(clean)
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              2560864        <==inode的总数
Block count:              2560359        <==block的总数
Free blocks:              1524760        <==还有多少个 block 可用
Free inodes:              2411225        <==还有多少个 inode 可用
First block:              0
Block size:               4096           <==每个 block 的大小啦！
Filesystem created:       Fri Sep  5 01:49:20 2008
Last mount time:          Mon Sep 22 12:09:30 2008
Last write time:          Mon Sep 22 12:09:30 2008
Last checked:             Fri Sep  5 01:49:20 2008
First inode:              11
Inode size:               128            <==每个 inode 的大小
Journal inode:            8              <==底下这三个与下一小节有关
Journal backup:           inode blocks
Journal size:             128M

Group 0: (Blocks 0-32767) <==第一个 data group 内容, 包含 block 的启始/结束号码
  Primary superblock at 0, Group descriptors at 1-1  <==超级区块在 0 号 block
  Reserved GDT blocks at 2-626
  Block bitmap at 627 (+627), Inode bitmap at 628 (+628)
  Inode table at 629-1641 (+629)                     <==inode table 所在的 block
  0 free blocks, 32405 free inodes, 2 directories    <==所有 block 都用完了！
  Free blocks:
  Free inodes: 12-32416                              <==剩余未使用的 inode 号码
Group 1: (Blocks 32768-65535)
#由于数据量非常的庞大，这里省略了一部分输出信息
```

　　可以看到，使用 dumpe2fs 命令可以查询到非常多的信息，以上信息大致可分为 2  部分。前半部分显示的是超级块的信息，包括文件系统名称、已使用以及未使用的 inode 和 block 的数量、每个 block 和 inode  的大小，文件系统的挂载时间等。

　　另外，Linux 文件系统（EXT 系列）在格式化的时候，会分为多个区块群组（block group），每 个区块群组都有独立的  inode/block/superblock 系统。此命令输出结果的后半部分，就是每个区块群组的详细信息（如 Group0、Group1）。

# parted

**parted命令** 是由GNU组织开发的一款功能强大的磁盘分区和分区大小调整工具，与fdisk不同，它支持调整分区的大小。作为一种设计用于Linux的工具，它没有构建成处理与fdisk关联的多种分区类型，但是，它可以处理最常见的分区格式，包括：ext2、ext3、fat16、fat32、NTFS、ReiserFS、JFS、XFS、UFS、HFS以及Linux交换分区。

‍

MBR支持的磁盘最大容量为2 TiB，GPT最大支持的磁盘容量为18 EiB，因此当您初始化容量大于2 TiB的磁盘时，分区形式请采用GPT。

fdisk分区工具只适用于MBR分区，parted工具适用于MBR分区和GPT分区。

### 语法

```
parted(选项)(参数)

### 选项
-h  显示帮助信息；
-i  交互式模式；
-s  脚本模式，不提示用户；
-v  显示版本号。
```

‍

## 实战

1. 执行以下命令，查看新增数据盘。

    ```
    root@ecs-test-0001 ~]# lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    vda    253:0    0   40G  0 disk
    └─vda1 253:1    0   40G  0 part /
    vdb    253:16   0  100G  0 disk
    ```

    表示当前的弹性云服务器有两块磁盘，“/dev/vda”是系统盘，“/dev/vdb”是新增数据盘。
2. 执行以下命令，进入parted分区工具，开始对新增数据盘执行分区操作。

    ```
    [root@ecs-test-0001 ~]# parted /dev/vdb
    GNU Parted 3.1
    Using /dev/vdb
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) 
    ```
3. 输入“p”，按“Enter”，查看当前磁盘分区形式。

    ```
    (parted) p
    Error: /dev/vdb: unrecognised disk label
    Model: Virtio Block Device (virtblk)
    Disk /dev/vdb: 107GiB
    Sector size (logical/physical): 512B/512B
    Partition Table: unknown
    Disk Flags:
    (parted) 
    ```

    “Partition Table”为“unknown”表示磁盘分区形式未知，新的数据盘还未设置分区形式。
4. 输入以下命令，设置磁盘分区形式。

    **mklabel** *磁盘分区形式*

    分区表类型：MBR分区表(msdos)和GPT分区表(gpt)

    ```bash
    (parted) mklabel gpt
    ```

    ​须知：

    MBR支持的云硬盘最大容量为2 TiB，GPT最大支持的云硬盘容量为18 EiB，当前数据盘支持的最大容量为32 TiB，如果您需要使用大于2 TiB的云硬盘容量，分区形式请采用GPT。
5. 输入“p”，按“Enter”，设置分区形式后，再次查看磁盘分区形式。

    回显类似如下信息：

    ```
    (parted) mklabel gpt
    (parted) p
    Model: Virtio Block Device (virtblk)
    Disk /dev/vdb: 107GiB
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags:

    Number  Start  End  Size  File system  Name  Flags

    (parted) 
    ```

    “Partition Table”为“gpt”表示磁盘分区形式已设置为GPT。
6. 输入“unit s”，按“Enter”，设置磁盘的计量单位为磁柱。
7. 以整个磁盘创建一个分区为例，执行以下命令，按“Enter”。

    ```bash
    # mkpart 磁盘分区名称 起始磁柱值 截止磁柱_值
    (parted) mkpart backup 2048s 100%
    (parted)
    ```
8. 输入“p”，按“Enter”，查看新建分区的详细信息。

    ```
    (parted) p
    Model: Virtio Block Device (virtblk)
    Disk /dev/vdb: 209715200s
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags:

    Number  Start  End         Size        File system  Name  Flags
     1      2048s  209713151s  209711104s               backup

    (parted) 
    ```
9. 输入“q”，按“Enter”，退出parted分区工具。

    ```
    (parted) q
    Information: You may need to update /etc/fstab.
    ```

    “/etc/fstab”文件控制磁盘开机自动挂载，请先参考以下步骤为磁盘分区设置文件系统和挂载目录后，再根据文档指导更新“/etc/fstab”文件。
10. 执行以下命令，查看磁盘分区信息。

     ```bash
     [root@ecs-test-0001 ~]# lsblk
     NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
     vda    253:0    0   40G  0 disk
     └─vda1 253:1    0   40G  0 part /
     vdb    253:16   0  100G  0 disk
     └─vdb1 253:17   0  100G  0 part
     ```

    此时可以查看到新建分区“/dev/vdb1”

11. 执行以下命令，将新建分区文件系统设为系统所需格式。

     ```bash
     [root@ecs-test-0001 ~]# mkfs -t ext4 /dev/vdb1
     mke2fs 1.42.9 (28-Dec-2013)
     Filesystem label=
     OS type: Linux
     Block size=4096 (log=2)
     Fragment size=4096 (log=2)
     Stride=0 blocks, Stripe width=0 blocks
     6553600 inodes, 26213888 blocks
     1310694 blocks (5.00%) reserved for the super user
     First data block=0
     Maximum filesystem blocks=2174746624
     800 block groups
     32768 blocks per group, 32768 fragments per group
     8192 inodes per group
     Superblock backups stored on blocks:
             32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
             4096000, 7962624, 11239424, 20480000, 23887872

     Allocating group tables: done
     Writing inode tables: done
     Creating journal (32768 blocks): done
     Writing superblocks and filesystem accounting information: done
     ```

    格式化需要等待一段时间，请观察系统运行状态，不要退出。

12. 执行以下命令，将新建分区挂载到目录下

     ```bash
     #以挂载新建分区“/dev/vdb1”至“/mnt/sdc”为例
     mount /dev/vdb1 /mnt/sdc
     ```

13. 执行以下命令，查看挂载结果。

     ```bash
     [root@ecs-test-0001 ~]# df -TH
     Filesystem     Type      Size  Used Avail Use% Mounted on
     /dev/vda1      ext4       43G  1.9G   39G   5% /
     devtmpfs       devtmpfs  2.0G     0  2.0G   0% /dev
     tmpfs          tmpfs     2.0G     0  2.0G   0% /dev/shm
     tmpfs          tmpfs     2.0G  9.0M  2.0G   1% /run
     tmpfs          tmpfs     2.0G     0  2.0G   0% /sys/fs/cgroup
     tmpfs          tmpfs     398M     0  398M   0% /run/user/0
     /dev/vdb1      ext4      106G   63M  101G   1% /mnt/sdc
     ```

# meminfo

## 内存基础信息

### 1. 通过 cat /proc/meminfo查看

```
[root@localhost ~]# cat /proc/meminfo 
MemTotal:       32656556 kB        // 可供系统支配的内存 （即物理内存减去一些预留位和内核的二进制代码大小）
MemFree:        13060828 kB        // LowFree与HighFree的总和，系统中未使用的内存
MemAvailable:   27306600 kB        // 应用程序可用内存，MemAvailable≈MemFree+Buffers+Cached，它与MemFree的关键区别点在于，MemFree是说的系统层面，MemAvailable是说的应用程序层面
Buffers:            2080 kB        // 缓冲区内存数，对原始磁盘块的临时存储，也就是用来缓存磁盘的数据，通常不会特别大 （20MB 左右）
Cached:         15397548 kB        // 缓存区内存数
SwapCached:            0 kB        // 交换文件中的已经被交换出来的内存。与 I/O 相关
Active:          9556388 kB        // 经常（最近）被使用的内存
Inactive:        8106580 kB        // 最近不常使用的内存。这很容易被系统移做他用
Active(anon):    3351300 kB        // 活跃的匿名内存（进程中堆上分配的内存,是用malloc分配的内存）
Inactive(anon):   823400 kB        // 不活跃的匿名内存
Active(file):    6205088 kB        // 活跃的与文件关联的内存（比如程序文件、数据文件所对应的内存页）
Inactive(file):  7283180 kB        // 不活跃的与文件关联的内存
Unevictable:           0 kB        // 不能被释放的内存页
Mlocked:               0 kB        // mlock()系统调用锁定的内存大小
SwapTotal:      16450556 kB        // 交换空间总大小
SwapFree:       16450556 kB        // 空闲的交换空间大小
Dirty:                12 kB        // 等待被写回到磁盘的大小
Writeback:             0 kB        // 正在被写回的大小
AnonPages:       2263468 kB        // 未映射页的大小
Mapped:           343264 kB        // 设备和文件映射大小
Shmem:           1911344 kB        // 已经被分配的共享内存大小
Slab:            1472540 kB        // 内核数据结构缓存大小
SReclaimable:    1189988 kB        // 可收回Slab的大小
SUnreclaim:       282552 kB        // 不可收回的Slab的大小
KernelStack:       17312 kB        // kernel消耗的内存
PageTables:        34020 kB        // 管理内存分页的索引表的大小
NFS_Unstable:          0 kB        // 不稳定页表的大小
Bounce:                0 kB        // 在低端内存中分配一个临时buffer作为跳转，把位于高端内存的缓存数据复制到此处消耗的内存
WritebackTmp:          0 kB        // 用于临时写回缓冲区的内存
CommitLimit:    32778832 kB        // 系统实际可分配内存总量
Committed_AS:    9836288 kB        // 当前已分配的内存总量
VmallocTotal:   34359738367 kB     // 虚拟内存大小
VmallocUsed:      392428 kB        // 已经被使用的虚拟内存大小
VmallocChunk:   34342156284 kB     // 在 vmalloc 区域中可用的最大的连续内存块的大小
HardwareCorrupted:     0 kB        // 删除掉的内存页的总大小(当系统检测到内存的硬件故障时)
AnonHugePages:   1552384 kB        // 匿名 HugePages 数量
CmaTotal:              0 kB        // 连续可用内存总数
CmaFree:               0 kB        // 空闲的连续可用内存
HugePages_Total:       0           // 预留HugePages的总个数
HugePages_Free:        0           // 尚未分配的 HugePages 数量
HugePages_Rsvd:        0           // 已经被应用程序分配但尚未使用的 HugePages 数量
HugePages_Surp:        0           // 这个值得意思是当开始配置了20个大页，现在修改配置为16，那么这个参数就会显示为4，一般不修改配置，这个值都是0
Hugepagesize:       2048 kB        // 每个大页的大小
DirectMap4k:      320240 kB        // 映射TLB为4kB的内存数量
DirectMap2M:     7972864 kB        // 映射TLB为2M的内存数量
DirectMap1G:    27262976 kB        // 映射TLB为1G的内存数量
```

　　**buffers和cached解析**

* 缓存（cached）：缓存区，高速缓存，是位于CPU与主内存间的一种容量较小但速度很高的存储器。是把读取过的数据保存起来，重新读取时若缓存中存在就不会重新去读硬盘了。其中的数据会根据读取频率进行排序，把最频繁读取的内容放在最容易找到的位置，把不再读的内容不断往后排。
* 缓冲（buffers）：缓冲区，一个用于存储速度不同步的设备或优先级不同的设备之间传输数据的区域。是根据磁盘的读写设计的，把分散的写操作集中进行，减少磁盘碎片和硬盘的反复寻道，从而提高系统性能。linux有一个守护进程定期清空缓冲内容（即写入磁盘），也可以通过sync命令手动清空缓冲。

　　**buffers和cached区别**：

* cache是高速缓存，用于CPU和内存之间的缓冲；
* buffer是I/O缓存，用于内存和硬盘的缓冲；

### 2. 查看显示内存状态：free [option] [-s <间隔秒数>]

> * -b 　以Byte为单位显示内存使用情况。
> * -k 　以KB为单位显示内存使用情况。
> * -m 　以MB为单位显示内存使用情况。
> * -h 　以合适的单位显示内存使用情况，最大为三位数，自动计算对应的单位值。单位有：（B = bytes、K = kilos、M = megas、G = gigas、T = teras）
> * -o 　不显示缓冲区调节列。
> * -s 　持续观察内存使用状况。
> * -t 　显示内存总和列。

```
// centos7.4为例（centos7与centos6输出结果有所不同）
[root@izwz91quxhnlkan8kjak5hz ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           1.8G        332M        113M         17M        1.4G        1.3G
Swap:          1.0G          0B        1.0G

// 字段解析：
// Mem行：表示物理内存统计
    // 1.  total 表示物理内存总量；
    // 2.  used表示总计分配给缓存（包含buffers 与cache ）使用的数量，但其中可能部分缓存并未实际使用
    // 3.  free表示未被分配的内存
    // 4.  shared表示共享内存，一般系统不会用到
    // 5.  buff/cache表示系统分配但未被使用的缓存大小
    // 6.  available对应着/prco/meminfo 中的MemAvailable
// Swap行：表示硬盘上交换分区的使用情况
    // 1. total表示交换分区上的内存总量
    // 2. used表示已经使用的交换空间容量
    // 3. free表示可用的交换空间容量
```

### 3. 查看虚拟内存使用状态：vmstat [option]

> 命令：  
> vmstat [-a] [-n] [-S unit] [delay [ count]]  
> vmstat [-s] [-n] [-S unit]  
> vmstat [-m] [-n] [delay [ count]]  
> vmstat [-d] [-n] [delay [ count]]  
> vmstat [-p disk partition] [-n] [delay [ count]]  
> vmstat [-f]  
> vmstat [-V]  
> option：
>
> * -a：显示活跃和非活跃内存
> * -f：显示从系统启动至今的fork数量 。
> * -m：显示slabinfo
> * -n：只在开始时显示一次各字段名称。
> * -s：显示内存相关统计信息及多种系统活动数量。
> * delay：刷新时间间隔。如果不指定，只显示一条结果。
> * count：刷新次数。如果不指定刷新次数，但指定了刷新时间间隔，这时刷新次数为无穷。
> * -d：显示磁盘相关统计信息。
> * -p：显示指定磁盘分区统计信息
> * -S：使用指定单位显示。参数有 k 、K 、m 、M ，分别代表1000、1024、1000000、1048576字节（byte）。默认单位为K（1024 bytes）
> * -V：显示vmstat版本信息。

### 4. 清理缓存

> 以下三种方法为临时清理缓存，另外，可以使用`sync`​命令来清理文件系统缓存，还会清理僵尸(zombie)对象和它们占用的内存。  
> 要想永久释放缓存，需要在/etc/sysctl.conf文件中配置：`vm.drop_caches=1/2/3`​，然后执行`sysctl -p`​生效即可

```
// 临时释放缓存
// 清理pagecache（页面缓存）
[root@backup ~]# echo 1 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=1

// 清理dentries（目录缓存）和inodes
[root@backup ~]# echo 2 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=2

// 清理pagecache、dentries和inodes
[root@backup ~]# echo 3 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=3
```

　　此时如果在执行这些操作时正在写数据，那么这些数据在写入磁盘之前就会从文件缓存中清除。  
 解决这个问题，可以通过编辑`/proc/sys/vm/vfs_cache_pressure`​这个文件的默认值来实现。  
​`/proc/sys/vm/vfs_cache_pressure`​文件，告诉内核，当清理`inoe/dentry`​缓存时应该用什么样的优先级。默认值100，用于控制回收cache频率，值越小则越倾向于保留cache，0表示从不回收cache容易导致out-of-memory

> 注：cache用于缓存inode/dentry，而buffer用于缓存data

```
[root@izwz91quxhnlkan8kjak5hz ~]# cat /proc/sys/vm/vfs_cache_pressure
100
```

　　‍

　　‍

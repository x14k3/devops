# Oracle 内存管理

# 一、PGA与SGA

　　Oracle使用两种类型的内存结构，一种为共享的，而另一种为进程专有的。**SGA（系统全局区）**  是所有服务器进程（包括后台进程）可共享的内存部分；进程专有的内存部分称为**PGA（程序全局区）** 。

　　当启动Oracle数据库时，系统会先在内存内规划一个固定区域，主要包括共享池、数据缓冲区、日志缓冲区三类。我们称此区域为系统全局区(System Global Area)，简称SGA。SGA是Oracle实例中最重要的内存部件。SGA的目的是提高查询性能，允许大量的并发数据库活动。

　　pga在用户登录时候直接绑定各类会话、权限等信息，而且当排序时候也是在这个区域中进行的，但是当排序尺寸超出pga区域范围，就会占用临时表空间的大小。

　　调整SGA并不总是很容易。在Oracle 11g中，用户可以使用自动内存管理（Automatic Memory Management）来将共享内存管理问题完全自动化。*使用AMM，Oracle将根据变化的数据库负荷为SGA和PGA自动分配内存或回收内存，重新分配，*  Oracle使用内部视图和统计数据来决定为SGA组件中分配内存的最好办法。

# 二、自动内存管理

　　自动内存管理是指**Oracle自动的对SGA和PGA进行管理**。如果我们要启动自动内存管理，只需设置MEMORY_TARGET和MEMORY_MAX_TARGET即可。

　　MEMORY_TARGET：设置目标内存大小，Oracle会尝试将内存稳定在该值。不需要重启服务。
MEMORY_MAX_TARGET ：设置最大允许的内存大小，Oracle以此来限制内存使用的最大值。需要重启数据库。

　　**什么情况下使用自动内存管理**
Oracle官方推荐**SGA+PGA的内存总大小**如果**小于**或等于**4GB**，建议使用自动内存管理。如果你的SGA+PGA大于4G也使用了自动内存管理，那么建议最好设置SGA_TARGET和PGA_AGGREGATE_TARGET的值。那么这些值将作为SGA和PGA的最小值。该设置主要是为了避免过大的内存抖动。

### 启用自动内存管理

```sql
-- 1.查看当前SGA_TARGET和PGA_AGGREGATE_TARGET参数
show parameter target;
-- 2.修改相关参数，把sga和pga参数改为0,只需设置MEMORY_TARGET和MEMORY_MAX_TARGET即可
alter system set memory_max_target    = 8192m scope=spfile;
alter system set memory_target        = 8192m scope=spfile;
alter system set sga_target           = 0      scope=spfile;
alter system set pga_aggregate_target = 0     scope=spfile;
-- 3.重启数据库实例
shutdown immediate;
startup;
show parameter target;

```

### /dev/shm对自动内存管理的影响

　　若使用自动内存管理，必须要确保** *(/dev/shm)大于MEMORY_MAX_TARGET 和MEMORY_TARGET的值***。

```sql
# 修改/dev/shm (默认大小为内存一半)
vim /etc/fstab
---------------------------------------------
tmpfs /dev/shm swap defaults,size=10241m 0 0
---------------------------------------------
mount -o remount /dev/shm
# /dev/shm使用的是内存空间
```

# 三、自动共享内存管理

　　当启用自动共享内存管理时，Oracle会自动的调整SGA的各个组件的值。MEMORY_TARGET和MEMORY_MAX_TARGET设置为0，将SGA_TARGET和SGA_MAX_SIZE设置为非0值。
SGA_TARGET用于设置共享内存目标大小，Oracle会努力维持共享内存在此目标值，如果你修改了该参数，你并不需要重启数据库。
SGA_MAX_SIZE用于设置最大允许的共享内存大小，Oracle以此来限制共享内存的最大值，如果你修改了该参数，你需要重启数据库。

　　**什么情况下使用自动共享内存管理**

　　Oracle官方推荐SGA+PGA的总大小大于4GB，建议使用自动共享内存管理。如果我们启用了自动共享内存管理，Oracle会自动的调整SGA各组件大小，一般我们并不需要干预。但如果我们知道各组件高峰期时这些值的使用量，那么我们也可以为这些组件设置指定值，这些值将作为组件的最小值。从而避免高峰期时不必要的内存调整

　　在Oracle 10g 中引入了一个非常重要的参数：SGA_TARGET，这也是Oracle 10g的一个新特性。自动共享内存管理（Automatic Shared Memory Management ASMM），控制这一特性的，就仅仅是这个参数SGA_TARGE。设置这个参数后，你就不需要为每个内存区来指定大小了。

　　ASMM只能自动调整5个内存池的大小，它们是：shared pool、buffer cache、large pool、java

### 启用自动共享内存管理

```sql
ALTER SYSTEM SET SGA_TARGET        = 8192M  SCOPE = SPFILE;
ALTER SYSTEM SET SGA_MAX_SIZE      = 8192M  SCOPE = SPFILE;
ALTER SYSTEM SET MEMORY_MAX_TARGET = 0      SCOPE = SPFILE;
ALTER SYSTEM SET MEMORY_TARGET     = 0      SCOPE = SPFILE;
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 2048m SCOPE = SPFILE;  # pga自动管理
-- 3.重启数据库实例
shutdown immediate;
startup;
show parameter target;
==========================================================
# 在上述命令中：
# SCOPE指的是修改范围，一共有三个值分别是SPFILE，BOTH和MEMORY
--SPFILE：指修改服务器参数文件中的数据。
--MEMORY：指修改内存中的数据，对于要重启数据库才生效的参数，该值不可用
--BOTH：指同时修改服务器参数文件和内存中的数据。
```

### shmXX对自动共享内存的影响

　　**kernel.shmmax：单个共享内存段**的最大值，单位字节，shmmax 设置应该足够大，最好**能在一个共享内存段下容纳下整个的SGA** ,这个设置的比SGA_MAX_SIZE大比较好,设置的过低可能会导致需要创建多个共享内存段，这样可能导致系统性能的下降
32G内存的服务期推荐16G的共享内存段=17179869184

　　**Kernel.shmall：**  ​**共享内存总量**,shmall 是全部允许使用的共享内存大小，shmmax 是单个段允许使用的大小。这两个可以设置为内存的 90%。32G内存的服务期推荐的共享内存总量为2\*shmmax\*90%/4k=7549740

　　**kernel.shmmni：**  ​**共享内存段的最大数量**，shmmni 缺省值 4096 ，一般肯定是够用了。

　　`vim /etc/sysctl.conf`

```sql
kernel.shmall = 4194304      # 共享内存总量 16G (16*1024*1024/4)
kernel.shmmax = 8589934592   # 单个共享内存段的最大值 8G (8*1024*1024*1024)
kernel.shmmni = 4096
```

# 四、自动PGA内存管理

　　当使用自动PGA内存管理时，Oracle会自动的管理实例PGA的内存总量。我们可以通过设置初始化参数PGA_AGGREGATE_TARGET为非0值来开启自动PGA内存管理。Oracle会尝试确保分配给所有数据库服务器进程和后台进程的PGA内存总量不会超过这个目标，但实际使用时可能超过该设置。当我们使用自动PGA内存管理时，SQL工作区的大小是自动的，并且会忽略所有*_AREA_SIZE初始化参数

　　注意：Oracle推荐使用自动PGA内存管理

```sql
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 2048m SCOPE = SPFILE;  # pga自动管理
```

# 五、手动共享内存管理

　　要手动管理共享内存，首先必须禁用自动内存管理和自动共享内存管理。因此MEMORY_TARGET和SGA_TARGET都必须设置为0。同时需要手工设置其他组件的值

　　注意：Oracle推荐使用手动共享内存管理

```bash
DB_CACHE          # 缓冲区缓存，主要用于缓存数据，较大的缓存通常会减少磁盘的读写数量， 因此缓冲区缓存的大小对性能影响较为明显，因此设置一个合理的缓冲区缓存尤为重要。
SHARED_POOL_SIZE  # 共享池，存储多种类型的数据，例如解析后的SQL，PL/SQL代码，数据字典，查询的结果集缓存等数据。因此在多用户环境下，较大的共享池对于性能提升也是非常有帮助的。
LARGE_POOL_SIZE   # 大池是一个可选组件。一般用于备份进程，并行执行等。
JAVA_POOL_SIZE      # JAVA池，JAVA代码所需要的内存将从此分配。
STREAMS_POOL_SIZE # 流池，存储缓冲队列消息的内存池。
```

# 六、手动PGA内存管理

　　当自动内存管理被禁用并且PGA_AGGREGATE_TARGET被设置为0时，将启用手动PGA内存管理。使用手动PGA内存管理时，意味着你需要手工设置*_AREA_SIZE初始化参数。

　　**注意：Oracle不推荐使用手动PGA内存管理**

```sql
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 0 SCOPE = SPFILE;  # 禁用pga自动管理
```

# 六、如何分配内存

　　不管是采用自动内存管理还是自动共享内存管理+自动PGA内存管理。在分配内存时，普遍的做法是分配机器总内存的50%~75%。

　　例如：机器内存是128G,SGA+PGA合计会分配64G~96G。需要注意的是50%~75%只是一个普遍值，但不是个绝对值。机器内存只有4G的情况下，分配50%是很有必要的，但是如果机器内存有512G，对于只部署数据库的机器来说分配75%仍然有大量的内存未使用。

　　一般可以先确定PGA大小，然后剩余内存都分配给SGA。如果你的系统有大量的并发访问，那么PGA分配就需要比较多，而如果你的系统并发访问人数非常少。那么几百MB的PGA就可满足了。而剩下的内存则都可以分配给SGA。

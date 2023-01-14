#database/oracle

# 一、概念

## 1.redo日志

Oracle数据库有联机重做日志（redolog），这个日志是记录对数据库所做的修改，比如插入，删除，更新数据等，对这些操作都会记录在联机重做日志里，这样做是为了数据安全。归档就是由oracle数据库后台进程ARCn进程将redo日志文件中的内容复制到归档文件中。一般数据库至少要有2个联机重做日志组。当一个联机重做日志组被写满的时候，就会发生日志切换，这时联机重做日志组2成为当前使用的日志，当联机重做日志组2写满的时候，又会发生日志切换，去写联机重做日志组1，就这样反复进行。

Redo Log 是InnoDB引擎特有的，用来**保证事务的原子性和持久性**。Redo Log 主要记录的是物理日志，也就是对磁盘上的数据进行修改的记录。

Redo Log 主要包含两部分：一部分是内存中的日志缓冲，称作 Redo Log Buffer, 这部分日志比较容易丢失；另一部分是存在磁盘上的重做日志文件，称作 Redo Log File, 这部分日志是持久化到磁盘上的，不容易丢失。
重做日志文件以组（Group）的形式组织，一个**重做日志组**包含一个或者多个日志文件，一个重做日志组中的日志文件完全相同，互为镜像。

## 2.undo日志

为了保证读一致性，在更新数据到提交之前，Oracle会先**把旧数据写入到undo log中**，以便回滚，且其他用户读取的数据也是和undo log中的数据一致，直到提交事务才更改数据，undo log是为了撤销所作更改。数据放在undo表空间中。
**结论：为了并发时读一致性成功，那么DML操作，肯定先写UNDO段。**

**注意：**

1. redo是一种“文件file”，没有表空间；
2. undo是一种“数据文件datafile”，具有表空间；
3. 数据库在DML事务时，先创建undo；
4. 读一致性与一致性(scn相同）的区别；
5. undo与rollback的区别：在undo（撤销还原流程）中会使用rollback（回滚）这个动作。

## 3.redo日志状态

查看Redolog 位置的状态.
`select g.member, v.status from v$log v , v$logfile g where v.GROUP#=g.GROUP#;`

*   CURRENT
    redo日志为当前活跃的日志，就是LGWR进程写的日志文件，处于该状态下的日志为数据库当前正在写入的日志组。活跃中的日志组无法进行删除。删除前需要将日志组切换到 INACTIVE状态。

*   ACTIVE
    是指活动的非当前日志，在进行实例恢复时会被用到。Active状态意味着Checkpoint尚未完成，脏数据未写入到硬盘，因此该日志文件不能被覆盖。

*   INACTIVE
    是非活动日志，在实例恢复时不再需要，但在介质恢复时可能需要。

*   UNUSED
    通常指从未被使用的日志组，即新添加的日志组。

# 二、日志组

日志切换处于这个点上：数据库停止写一个日志文件，而开始写另外一个日志文件，称日志切换。
一般情况下，当前日志文件满了之后，就开始写下一个日志文件；但是你也可以手工进行日志切换，强迫日志切换，即当前日志文件还没有满的时候强迫进行日志切换。

```sql
-- 查看Redolog 的文件的位置所在（默认datafile目录下）
select member from v$logfile;

-- 查看Redolog 位置\大小\状态.
select g.member, v.bytes/1024/1024, v.status from v$log v , v$logfile g where v.GROUP#=g.GROUP#;

-- 1、创建4个新的日志组
ALTER DATABASE ADD LOGFILE GROUP 7 ('/data/oradata/FMSDB/redo07.log') SIZE 200m;
ALTER DATABASE ADD LOGFILE GROUP 8 ('/data/oradata/FMSDB/redo08.log') SIZE 200m;
ALTER DATABASE ADD LOGFILE GROUP 9 ('/data/oradata/FMSDB/redo09.log') SIZE 200m;
-- 2、归档当前联机重做日志并切换到新的联机重做日志组
alter system archive log current;
alter system switch logfile;

-- 3、删除旧的日志组
-- 通过select * from v$log;
-- 查看group 1/2/3/4 上的redo状态为inactive后，方可执行如下命令。

alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;

-- 查看日志组的状态看一下哪个是当前组，哪个是inactive状态的，删除掉inactive的那个组；如果状态为current和active 在删除的时候会报错。

-- 4、操作系统下删除原日志组1、2、3中的文件
-- 注意：每一步删除drop操作，都需手工删除操作系统中的实体文件。

-- 5、重建日志组1、2、3、4
ALTER DATABASE ADD LOGFILE GROUP 1 ('/data/oradata/jzdb/redo01.log') SIZE 1G;
ALTER DATABASE ADD LOGFILE GROUP 2 ('/data/oradata/jzdb/redo02.log') SIZE 1G;
ALTER DATABASE ADD LOGFILE GROUP 4 ('/data/oradata/jzdb/redo04.log') SIZE 1G;

-- 6、切换日志组
-- 多执行几次如下命令，同时通过select * from gv$log来观察5/6/7/8下的redo日志状态是不是为inactive；
-- 查看日志组的状态看一下哪个是当前组，哪个是inactive状态的，删除掉inactive的那个组。如果状态为current和active 在删除的时候会报错。

alter system switch logfile;

-- 7、删除中间过渡用的日志组5、6、7、8
alter database drop logfile group 5;
alter database drop logfile group 6;
alter database drop logfile group 7;
alter database drop logfile group 8;

-- 到操作系统下删除原日志组4、5、6中的文件

-- 9、备份当前的最新的控制文件
-- 因日志组发生变化，建议备份一次controlfile文件。
SQL> alter database backup controlfile to trace resetlogs;

```


# 三、redo日志归档

重做日志redo log file是LGWR进程从Oracle实例中的redo log buffer写入的，是循环利用的。就是说一个redo log file(group) 写满后，才写下一个。  
归档日志archive log是当数据库运行在归档模式下时，一个redo log file(group)写满后，由ARCn进程将重做日志的内容备份到归档日志文件下，然后这个redo log file(group)才能被下一次使用。

不管数据库是否是归档模式，重做日志是肯定要写的。而只有数据库在归档模式下，重做日志才会备份，形成归档日志。  
一般来说，归档日志结合全备份，用于数据库出现问题后的恢复使用

```sql
-- 查看是否开启归档模式
SQL> archive log list;
-- 设置归档文件格式   
SQL> alter system set log_archive_format='%t_%s_%r.dbf' scope=spfile;
-- 设置归档文件保存路径,路径中最好包含实例名，确保目录存在，且拥有者为oracle用户
SQL> alter system set log_archive_dest_1 ='location=/data/arch/fmsdb' scope=spfile;
-- 重启数据库至mount模式
SQL> shutdown immediate
SQL> startup mount
-- 开启归档
SQL> alter database archivelog;
-- 打开数据库
SQL> alter database open;
-- 手动归档
SQL> alter system archive log current;
```

**配置参数详解**

log\_archive\_dest       # 设置归档日志路径，这个参数已不推荐

```bash
# 使用log_archive_dest参数最多可设置2个归档路径，
# 通过log_archive_dest设置一个主归档路径，
# 通过LOG_ARCHIVE_DUPLEX_DEST 参数设置一个从归档路径。
# 所有的路径必须是本地的，该参数的设置格式如下：

LOG_ARCHIVE_DEST = '/disk1/archive'
LOG_ARCHIVE_DUPLEX_DEST = '/disk2/archive'

```

log\_archive\_dest\_n   # 设置归档日志路径

```bash
LOG_ARCHIVE_DEST_n   # 参数可以设置最多10个不同的归档路径，通过设置关键词location或service，该参数指向的路径可以是本地或远程的。
LOG_ARCHIVE_DEST_1 = 'LOCATION = /disk1/archive' 
LOG_ARCHIVE_DEST_2 = 'LOCATION = /disk2/archive' 
LOG_ARCHIVE_DEST_3 = 'LOCATION = /disk3/archive' 
# 如果要归档到远程的standby数据库，可以设置service：
LOG_ARCHIVE_DEST_4 = 'SERVICE = standby1'
```

scope（范围）说明：

```bash
# Oracle 里面有个叫做spfile的东西，就是动态参数文件，里面设置了Oracle 的各种参数。
# 所谓的动态，就是说你可以在不关闭数据库的情况下，更改数据库参数，记录在spfile里面。
scope=spfile  # 仅仅更改spfile里面的记载，不更改内存，也就是不立即生效，而是等下次数据库启动生效。有一些参数只允许用这种方法更改
scope=memory  # 仅仅更改内存，不改spfile。也就是下次启动就失效了
scope=both    # 内存和spfile都更改
不指定scope参数 # 等同于scope=both.

```


# 四、数据库闪回

📌**开启闪回功能必须是在归档模式下，请参考上面的操作**

当启用闪回就必须使用**log\_archive\_dest\_n**参数来指定归档日志目录。

Oracle的闪回技术提供了一组功能，可以访问过去某一时间的数据并从人为错误中恢复。闪回技术是Oracle 数据库独有的，支持任何级别的恢复，包括行、事务、表和数据库范围。使用闪回特性，可以查询以前的数据版本，还可以执行更改分析和自助式修复，以便在保持数据库联机的同时从逻辑损坏中恢复。

Flashback技术是以Undo Segment中的内容为基础的， 因此受限于`UNDO_RETENTON`参数。要使用flashback 的特性，必须启用自动撤销管理表空间。闪回参数如下：

```sql
SQL> show parameter undo;

NAME                     TYPE     VALUE
------------------------------------ ----------- ------------------------------
undo_management        string     AUTO        # undo_management参数值是否为AUTO，如果是“MANUAL”手动，需要修改为“AUTO”
undo_retention         integer    7200        # 1d是1440 即24*60,7200是5d
undo_tablespace        string     UNDO1

```

**单实例：**

```sql
# 设置闪回恢复区
SQL> show parameter recover;
SQL> alter system set db_recovery_file_dest_size=10g scope=spfile;
# 设置闪回区位置，路径中不用指定实例名，会自动生成，确保目录存在，且拥有者为oracle用户
SQL> alter system set db_recovery_file_dest='/data/arch' scope=spfile;
# 设置闪回目标为5天，以分钟为单位，每天为1440分钟，默认为1天
SQL> alter system set db_flashback_retention_target=2880 scope=spfile;
# 保存一致性,先关闭数据库
SQL> shutdown immediate;
# 启动到mount阶段
SQL> startup mount;
# 启动闪回功能
SQL> alter database flashback on; 
# 也可启用表空间闪回
SQL> alter tablespace abc flashback on;     -- 开启表空间闪回
SQL> alter tablespace abc flashback off;    -- 关闭表空间闪回
# 切换到open阶段
SQL> alter database open;
```

**RAC：**

```bash
```

**闪回区和归档目录**

```bash
# 使用闪回区需先设置其大小和路径：
alter system set db_recovery_file_dest_size=5G scope=both;
alter system set db_recovery_file_dest='/archivelog' scope=spfile;

# 设置归档路径和闪回区同时保留归档日志：
alter system set log_archive_dest_1='location=/data/arch' scope=spfile;
alter system set log_archive_dest_10='LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=spfile;

# 设置归档路径保留归档日志，闪回区不保留：
alter system set log_archive_dest_1='location=/data/arch' scope=spfile;
alter system set log_archive_dest_10='' scope=spfile;

# 设置归档路径不保留归档日志，闪回区保留：
alter system set log_archive_dest_1='' scope=spfile;
alter system set log_archive_dest_10='LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=spfile;

```

# 五、知识点

## crash Recovery 过程

当数据库突然崩溃，而还没有来得及将buffer cache里的脏数据块刷新到数据文件里，同时在实例崩溃时正在运行着的事务被突然中断，则事务为中间状态，也就是既没有提交也没有回滚。这时数据文件里的内容不能体现实例崩溃时的状态。这样关闭的数据库是不一致的。
下次**启动实例**时，Oracle会由SMON进程自动进行实例恢复。实例启动时，SMON进程会去检查**控制文件**中所记录的、每个在线的、可读写的数据文件的END SCN号。
数据库正常运行过程中，该END SCN号始终为NULL，而当数据库正常关闭时，会进行完全检查点，并将检查点SCN号更新该字段。而崩溃时，Oracle还来不及更新该字段，则该字段仍然为NULL。当SMON进程发现该字段为空时，就知道实例在上次没有正常关闭，于是由SMON进程就开始进行实例恢复了。

SMON进程进行实例恢复时，会从控制文件中获得**检查点**位置。于是，SMON进程到**redo log文件**中，找到该检查点位置，然后从该检查点位置开始往下，应用所有的重做条目，从而在**buffer cache里又恢复了实例崩溃那个时间点的状态**。这个过程叫做**前滚**，前滚完毕以后，buffer cache里既有崩溃时已经提交还没有写入数据文件的脏数据块，也还有事务被突然终止，而导致的既没有提交又没有回滚的事务所弄脏的数据块。
前滚一旦完毕，SMON进程立即打开数据库。但是，这时的数据库中还含有那些中间状态的、既没有提交又没有回滚的脏块，这种脏块是不能存在于数据库中的，因为它们并没有被提交，必须被回滚。打开数据库以后，SMON进程会在后台进行**回滚**。
有时，数据库打开以后，SMON进程还没来得及回滚这些中间状态的数据块时，就有用户进程发出读取这些数据块的请求。这时，服务器进程在将这些块返回给用户之前，由服务器进程负责进行回滚，回滚完毕后，将数据块的内容返回给用户。

总之，Crash Recovery时，数据库打开会占用比正常关闭更长的时间。

## 恢复机制分类
崩溃恢复 Crash recovery
媒介恢复 Media recovery 参考[RMAN 异机恢复](RMAN%20异机恢复.md)
这两种的区别是：
1）Crash Recovery 是在启动时DB 自动完成，而MediaRecovery 需要DBA 手工的完成。
2）Crash Recovery 使用online redo log，Media Recovery 使用archived log 和 online redo log。
3）Media Recovery 可能还需要从备份中Restore datafile。



## 启动实例过程
oracle数据库的启动涉及一系列的文件读取和数据一致性检查等操作，但首先启动数据库实例（lnstance），在这个过程数据库获取一些内存空间(PGA+SGA)，并启动必需的后台监控进程。启动流程涉及3个状态。
1）NOMOUNT状态：打开数据库实例（lnstance），读取**参数文件**（一些缓冲大小、内存等参数）
2）MOUNT状态：根据**参数文件**找到**控制文件**位置，读取控制文件中的参数（数据文件、日志文件位置等）
3）OPEN状态：打开数据文件 并 进行一系列检查工作，这些检查工作用于数据恢复

## 控制文件
oracle数据库控制文件是一个重要的二进制文件，记录了数据库的**重做日志和数据文件的名字和位置、归档重做日志**的历史等。控制文件在数据库启动到MOUNT状态时被读取。由于其重要性建议多重存储到不同磁盘（3个以上实现冗余可用性）

## 检查点
检查点（checkpoint) 是数据库的一个内部事件，检查点激活时会触发数据库写进程(DBWR)，**将数据缓冲区里的脏数据块写到数据文件中**。checkpoint主要2个作用：&#x20;
1）保证数据库的一致性，这是指将脏数据写出到硬盘，保证内存和硬盘上的数据是一样的。&#x20;
2）缩短实例恢复的时间，实例恢复要把实例异常关闭前没有写到硬盘的脏数据通过日志进行恢复。如果脏块过多，实例恢复的时间也会过长，检查点的发生可以减少脏块的数量，从而减少实例恢复的时间。

## 脏数据
脏数据就是已经写入到内存里，但是还没有写入到硬盘上的数据。 一般当事物没有提交的时候会产生，当事物提交以后，脏数据就会被写进硬盘的数据块，这时他就不叫脏数据了。

## PMON进程
pmon（Process Monitor process）用于**监控其他后台进程。** 负责在连接出现异常中止后进行清理工作。例如，一个专用服务器进程崩溃或者出于某种原因被结束掉，就要由PMON进程负责善后（恢复或者撤销工作），并释放资源。PMON会回滚未提交的工作，释放锁，并释放之前为失败进程分配的SGA资源。PMON还负责监视其他Oracle后台进程，并在必要时重启这些后台进程。

## DBWR进程
DBWR进程执行将数据块缓冲区写入数据文件的工作，是负责缓冲存储管理的一个Oracle后台进程。
尽管有一个数据库写进程（ DBW0 ）适用于大多数系统，但数据库管理员可以配置额 外的进程（DBW0-DBW9，最多10 个进程），以提高写入性能，通过设置初始化参数 DB\_WRITER\_PROCESSES 来完成。如果你的系统修改数据严重，这些额外的DBWn 进 程在单处理器系统不是非常有用。;
当数据库高速缓冲区的块被修改，它被标记为脏缓冲区并添加到以SCN（System Change Number，系统更改号，这里可以看做“时间”）为顺序的LRUW（LRUWriter）列表。 同时，**这个顺序与重做日志缓冲区的顺序一致**。

##LGWR进程
LGWR进程负责将SGA中重做日志缓冲区（redo log buffer）的内容刷新输出到磁盘上的联机日志文件。。LGWR是顺序写（sequential write），比离散写效率高。
当运行DML 或DDL 语句时，服务器进程首先要将事务的变化记载到重做日志缓冲区， 然后才会写入数据高速缓冲区，并且重做日志缓冲区的内容将会被写入联机重做日志文件， 以避免系统出现意外带来的数据损失（如果操作系统断电，内存中的重做日志缓冲区的内容 会丢失，而存在磁盘上的联机日志文件则不会丢失），这项任务由LGWR 来完成。 重做日志缓冲区是一个循环结构，LGWR 将重做日志缓冲区中的重做记录写入联机重 做日志文件后，相应的缓冲区内容将被清空，保证Oracle 有空闲的重做日志缓冲区可以写 入。

## CKPT进程
CKPT 检查点进程的作用是执行一个“检查点”，同步数据库的所有数据文件、控制文 件和重做日志文件。当执行检查点时，系统促使DBWn 将数据缓冲区中数据的变化写入数 据文件，同时完成对数据文件和控制文件的更新，记录下当前数据库的结构和状态。在执行 一个检查点之后，数据库处于一个完整状态。在数据库发生崩溃后，可以将数据库恢复到上 一个检查点。
Oracle 数据库在执行涉及数据变化的语句时，会针对任何修改生成一个顺序递增SCN （System Change Number）值，并且会将SCN 值连同事务的变化一起记载到重做日志缓 冲区。在数据文件、控制文件头部以及重做日志文件中都记载有该值。Oracle 通过比较各 种文件的SCN 值，确定文件是否损坏、系统是否异常，最终确定系统是需要进行实例恢复 还是介质恢复。在发出检查点时，数据文件、控制文件和重做日志的SCN 值完全一致。

## SMON进程
系统监控后台进程，SMON负责在数据库启动时清理临时表空间中的临时段，或者一些异常操作过程遗留下来的临时段。如有必要， 在实例启动时执行实例恢复。在实例恢复期间，SMON进程到**redo log文件**中，找到该检查点位置，然后从该检查点位置开始往下，应用所有的重做条目，从而在**buffer cache里又恢复了实例崩溃那个时间点的状态**。

## 如何确保已经提交的事务不会丢失？
解决这个问题比较简单，Oracle 有一个机制，叫做Log-Force-at-Commit，就是说，在事务提交的时候，和这个事务相关的REDO LOG 数据，包括COMMIT 记录，都必须从LOG BUFFER 中写入REDO LOG 文件，此时事务提交成功的信号才能发送给用户进程。通过这个机制，可以确保哪怕这个已经提交的事务中的部分BUFFER CACHE 还没有被写入数据文件，就发生了实例故障，在做实例恢复的时候，也可以通过REDO LOG 的信息，将不一致的数据前滚。

## 如何在数据库性能和实例恢复所需要的时间上做出平衡？
既确保数据库性能不会下降，又保证实例恢复的快速，解决这个问题，oracle是通过**checkpoint 机制**来实现的。
Oracle 数据库中，对BUFFER CAHCE 的修改操作是前台进程完成的，但是前台进程只负责将数据块从数据文件中读到BUFFER CACHE 中，不负责BUFFER CACHE 写入数据文件。BUFFER CACHE 写入数据文件的操作是由后台进程DBWR 来完成的。DBWR 可以根据系统的负载情况以及数据块是否被其他进程使用来将一部分数据块回写到数据文件中。这种机制下，某个数据块被写回文件的时间可能具有一定的随机性的，有些先修改的数据块可能比较晚才被写入数据文件。
而CHECKPOINT 机制就是对这个机制的一个有效的补充，CHECKPOINT 发生的时候，CKPT 进程会要求DBWR 进程将某个SCN 以前的所有被修改的块都被写回数据文件。这样一旦这次CHECKPOINT 完成后，这个SCN 前的所有数据变更都已经存盘，如果之后发生了实例故障，那么做实例恢复的时候，只需要从这次CHECKPOINT 已经完成后的变化量开始就行了，CHECKPOINT 之前的变化就不需要再去考虑了。

## 有没有可能数据文件中的变化已经写盘，但是REDO LOG 信息还在LOG BUFFER 中，没有写入REDO LOG 呢?

这里引入一个名词：Write-Ahead-Log，就是日志写入优先。日志写入优先包含两方面的算法:
第一个方面是，当某个BUFFER CACHE 的修改的变化矢量还没有写入REDO LOG 文件之前，这个修改后的BUFFER CACHE 的数据不允许被写入数据文件，这样就确保了再数据文件中不可能包含未在REDO LOG 文件中记录的变化；
第二个方面是，当对某个数据的UNDO 信息的变化矢量没有被写入REDOLOG 之前，这个BUFFERCACHE的修改不能被写入数据文件。


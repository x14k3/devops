

![44bee3978f964c6490e5bc14457bff0a~tplv-k3u1fbpfcp-zoom-in-crop-mark 1512 0 0 0](44bee3978f964c6490e5bc14457bff0atplv-k3u1fbpfcp-zoom-in-crop-mark%201512%200%200%200-20240315210356-e4zku13.webp)

buffer cache ：数据库缓存区缓存
log buffer      ：日志缓存区
redo log file  ：联机重做日志

## 一个事务的简单流程分析

1. 事务开始；
2. 在buffer cache中找到需要的数据块，如果没有找到，则从数据文件中载入buffer cache中；
3. 事务修改buffer cache的数据块，该数据被标识为“脏数据”，并被写入log buffer中；
4. 事务提交，LGWR进程将log buffer中的“脏数据”写入redo log file中；
5. 当发生checkpoint，CKPT进程更新所有数据文件的文件头中的信息，DBWn进程则负责将Buffer Cache中的脏数据写入到数据文件中

    附:checkpoint由ckpt进程触发oracle进行checkpoint动作,将data buffer中的脏块(已经写在redo里记录但是没有写到datafile里的)的内容写入到data file里并释放站用的空间,由dbw后台进程完成,并修改controlfile和datafile的scn.
    一般手工执行(alter system checkpoint)是由于要删除某个日志但是该日志里还有没有同步到data file里的内容,就需要手工check point来同步数据,然后就可以drop logfile group n.

## 一个事务的完整详细流程分析

oracle服务进程如何处理用户进程的请求
服务器进程在完成用户进程的请求过程中，主要完成如下7个任务：

0.sql语句的解析
1.数据块的读入db buffer
2.记日志
3.为事务建立回滚段
4.本事务修改数据块
5.放入dirty list
6.用户commit或rollback

### sql语句的解析

下面要讲oracle服务器进程如可处理用户进程的请求，当一用户进程提交一个sql时：`update temp set a=a*2`​；

首先*oracle服务器进程从用户进程把信息接收到后，在PGA中就要此进程分配所需内存，存储相关的信息，如在会话内存存储相关的登录信息等；服务器进程把这个sql语句的字符转化为ASCII等效数字码，接着这个ASCII码被传递给一个HASH函数，并返回一个hash值，

然后服务器进程将到`shared pool`​中的`library cache`​中去查找是否存在相同的hash值，如果存在，服务器进程将使用这条语句已高速缓存在`SHARED POOL`​的`library cache`​中的已分析过的版本来执行，如果不存在，服务器进程将在PGA中，配合UGA内容对sql，进行语法分析，首先检查语法的正确性，接着对语句中涉及的表，索引，视图等对象进行解析，并对照数据字典检查这些对象的名称以及相关结构，并根据ORACLE选用的优化模式以及数据字典中是否存在相应对象的统计数据和是否使用了存储大纲来生成一个执行计划或从存储大纲中选用一个执行计划，然后再用数据字典核对此用户对相应对象的执行权限，最后生成一个编译代码。ORACLE将这条sql语句的本身实际文本、HASH值、编译代码、与此语名相关联的任何统计数据和该语句的执行计划缓存在`SHARED POOL`​的`library cache`​中。服务器进程通过`SHARED POOL`​ 锁存器`（shared pool latch）`​来申请可以向哪些共享PL/SQL区中缓存这此内容，也就是说被`SHARED POOL`​锁存器锁定的PL/SQL区中的块不可被覆盖，因为这些块可能被其它进程所使用。在SQL分析阶段将用到`LIBRARY CACHE`​，从数据字典中核对表、视图等结构的时候，需要将数据字典从磁盘读入`LIBRARY CACHE`​，因此，在读入之前也要使用`LIBRARY CACHE`​锁存器`（library cache pin，library cache lock）`​来申请用于缓存数据字典。

到现在为止，这个sql语句已经被编译成可执行的代码了，但还不知道要操作哪些数据，所以服务器进程还要为这个sql准备预处理数据。

### 数据块的读入db buffer

Oracle处理数据，都需要把数据读取到内存中（即`db buffer`​中），首先服务器进程要判断所需数据是否在`db buffer`​存在，如果存在且可用，则直接获取该数据，同时根据`LRU`​算法增加其访问计数；如果`db buffer`​不存在所需数据，则要从数据文件上读取。首先服务器进程将在表头部请求`TM锁`​（保证此事务执行过程其他用户不能修改表的结构），如果成功加TM锁，再请求一些行级锁`（TX锁）`​，如果TM、TX锁都成功加锁，那么才开始从数据文件读数据，在读数据之前，要先为读取的文件准备好buffer空间。服务器进程需要扫面`LRU list`​寻找`free db buffer`​，扫描的过程中，服务器进程会把发现的所有已经被修改过的`db buffer`​注册到`dirty list`​中，

这些`dirty buffer`​会通过`dbwr`​的触发条件，随后会被写出到数据文件，找到了足够的空闲buffer，就可以把请求的数据行所在的数据块放入到`db buffer`​的空闲区域或者覆盖已经被挤出`LRU list`​的非脏数据块缓冲区，并排列在LRU list的头部，也就是在数据块放入DB BUFFER之前也是要先申请db buffer中的锁存器，成功加锁后，才能读数据到db buffer。

### 记日志

现在数据已经被读入到db buffer了，现在服务器进程将该语句所影响的并被读入db buffer中的这些行数据的`rowid`​及要更新的原值和新值及`scn`​等信息从`PGA`​逐条的写入`redo log buffer`​中。在写入`redo log buffer`​之前也要事先请求`redo log buffer的锁存器`​，成功加锁后才开始写入，当写入达到`redo log buffer大小的三分之一`​或`写入量达到1M`​或`超过三秒后`​或`发生检查点时`​或者`dbwr之前发生`​，都会触发lgwr进程把redo log buffer的数据写入磁盘上的redo file文件中（这个时候会产生log file sync等待事件），已经被写入redo file的redo log buffer所持有的锁存器会被释放，并可被后来的写入信息覆盖，redo log buffer是循环使用的。Redo file也是循环使用的，当一个redo file 写满后，lgwr进程会自动切换到下一redo file（这个时候可能出现log file switch（checkpoint complete）等待事件）。如果是归档模式，归档进程还要将前一个写满的redo file文件的内容写到归档日志文件中（这个时候可能出现log file switch（archiving needed））。

### 为事务建立回滚段

在完成本事务所有相关的redo log buffer之后，服务器进程开始改写这个db buffer的块头部事务列表并写入scn，然后copy包含这个块的头部事务列表及scn信息的数据副本放入回滚段中，将这时回滚段中的信息称为数据块的“前映像“，这个”前映像“用于以后的回滚、恢复和一致性读。（回滚段可以存储在专门的回滚表空间中，这个表空间由一个或多个物理文件组成，并专用于回滚表空间，回滚段也可在其它表空间中的数据文件中开辟。）

### 本事务修改数据块

准备工作都已经做好了，现在可以改写db buffer块的数据内容了，并在块的头部写入回滚段的地址。

### 放入dirty list

如果一个行数据多次update而未commit，则在回滚段中将会有多个“前映像“，除了第一个”前映像“含有scn信息外，其他每个“前映像“的头部都有scn信息和“前前映像”回滚段地址。一个update只对应一个scn，然后服务器进程将在dirty list中建立一条指向此db buffer块的指针（方便dbwr进程可以找到dirty list的db buffer数据块并写入数据文件中）。

接着服务器进程会从数据文件中继续读入第二个数据块，重复前一数据块的动作，数据块的读入、记日志、建立回滚段、修改数据块、放入dirty list。当dirty queue的长度达到阀值（一般是25%），服务器进程将通知dbwr把脏数据写出，就是释放db buffer上的锁存器，腾出更多的free db buffer。前面一直都是在说明oracle一次读一个数据块，其实oracle可以一次读入多个数据块（db\_file\_multiblock\_read\_count来设置一次读入块的个数）

**说明：** 
在预处理的数据已经缓存在db buffer或刚刚被从数据文件读入到db buffer中，就要根据sql语句的类型来决定接下来如何操作。

1. 如果是`select`​语句，则要查看db buffer块的头部是否有事务，如果有事务，则从回滚段中读取数据；如果没有事务，则比较select的scn和db buffer块头部的scn，如果前者小于后者，仍然要从回滚段中读取数据；如果前者大于后者，说明这是一非脏缓存，可以直接读取这个db buffer块的中内容。
2. 如果是`DML`​操作，则即使在db buffer中找到一个没有事务，而且SCN比自己小的非脏缓存数据块，服务器进程仍然要到表的头部对这条记录申请加锁，加锁成功才能进行后续动作，如果不成功，则要等待前面的进程解锁后才能进行动作（这个时候阻塞是tx锁阻塞）。

### 用户commit或rollback

到现在为止，数据已经在db buffer或数据文件中修改完成，但是否要永久写到数文件中，要由用户来决定commit（保存更改到数据文件）和rollback（撤销数据的更改），下面来看看在commit和rollback时，oracle都在做什么。

<span data-type="text" style="background-color: var(--b3-card-success-background); color: var(--b3-card-success-color);">用户执行commit命令</span>

只有当sql语句所影响的所有行所在的最后一个块被读入db buffer并且重做信息被写入redo log buffer（仅指日志缓冲区，而不包括日志文件）之后，用户才可以发去`commit`​命令，commit触发lgwr进程，但不强制立即dbwr来释放所有相应db buffer块的锁（也就是`no-force-at-commit`​,即提交不强制写），也就是说有可能虽然已经commit了，但在随后的一段时间内dbwr还在写这条sql语句所涉及的数据块。表头部的行锁并不在commit之后立即释放，而是要等dbwr进程完成之后才释放，这就可能会出现一个用户请求另一用户已经commit的资源不成功的现象。

- 情景1：从Commit和dbwr进程结束之间的时间很短，如果恰巧在commit之后，dbwr未结束之前断电，因为commit之后的数据已经属于
  数据文件的内容，但这部分文件没有完全写入到数据文件中。所以需要前滚。由于commit已经触发lgwr，这些所有未来得及写入数据文件的更改会在实例重启后，由smon进程根据重做日志文件来前滚，完成之前commit未完成的工作（即把更改写入数据文件）。
- 情景2：如果未commit就断电了，因为数据已经在db buffer更改了，没有commit，说明这部分数据不属于数据文件，由于dbwr之前触发lgwr（也就是只要数据更改，肯定要先有log），所有DBWR在数据文件上的修改都会被先一步记入重做日志文件，实例重启后，SMON进程再根据重做日志文件来回滚。

其实`smon`​的前滚回滚是根据检查点来完成的，当一个全部检查点发生的时候，首先让LGWR进程将redo log buffer中的所有缓冲（包含未提交的重做信息）写入重做日志文件，然后让dbwr进程将db buffer已提交的缓冲写入数据文件（不强制写未提交的）。然后更新控制文件和数据文件头部的SCN，表明当前数据库是一致的，在相邻的两个检查点之间有很多事务，有提交和未提交的。像前面的前滚回滚比较完整的说法是如下的说明：

- 情景1：发生检查点之前断电，并且当时有一个未提交的改变正在进行，实例重启之后，SMON进程将从上一个检查点开始核对这个检查点之后记录在重做日志文件中已提交的和未提交改变，因为dbwr之前会触发lgwr，所以dbwr对数据文件的修改一定会被先记录在重做日志文件中。因此，断电前被DBWN写进数据文件的改变将通过重做日志文件中的记录进行还原，叫做回滚，
- 情景2：如果断电时有一个已提交，但dbwr动作还没有完全完成的改变存在，因为已经提交，提交会触发lgwr进程，所以不管dbwr动作是否已完成，该语句将要影响的行及其产生的结果一定已经记录在重做日志文件中了，则实例重启后，SMON进程根据重做日志文件进行前滚;

实例失败后用于恢复的时间由两个检查点之间的间隔大小来决定，可以通个四个参数设置检查点执行的频率：
`Log_checkpoint_interval`​:决定两个检查点之间写入重做日志文件的系统物理块(redo blocks)的大小，默认值是0，无限制
`log_checkpoint_timeout`​: 决定了两个检查点之间的时间长度（秒），默认值是1800s
`fast_start_io_target`​：决定了用于恢复时需要处理的块的多少，默认值是0，无限制
`fast_start_mttr_target`​：直接决定了用于恢复的时间的长短，默认值是0，无限制

​`SMON`​进程执行的前滚和回滚与用户的回滚是不同的，SMON是根据重做日志文件进行前滚或回滚，而用户的回滚一定是根据回滚段的内容进行回滚的。在这里要说一下回滚段存储的数据，假如是delete操作，则回滚段将会记录整个行的数据，假如是update,则回滚段只记录被修改了的字段的变化前的数据（前映像），也就是没有被修改的字段是不会被记录的，假如是insert，则回滚段只记录插入记录的rowid。这样假如事务提交，那回滚段中简单标记该事务已经提交；假如是回退，则如果操作是delete,回退的时候把回滚段中数据重新写回数据块，操作如果是update，则把变化前数据修改回去，操作如果是insert，则根据记录的rowid 把该记录删除。

<span data-type="text" style="background-color: var(--b3-card-success-background); color: var(--b3-card-success-color);">用户执行rollback</span>

如果用户`rollback`​，则服务器进程会根据数据文件块和DB BUFFER中块的头部的事务列表和SCN以及回滚段地址找到回滚段中相应的修改前的副本，并且用这些原值来还原当前数据文件中已修改但未提交的改变。如果有多个“前映像”，服务器进程会在一个“前映像”的头部找到“前前映像”的回滚段地址，一直找到同一事务下的最早的一个“前映像”为止。一旦发出了COMMIT，用户就不能rollback，这使得COMMIT后DBWR进程还没有全部完成的后续动作得到了保障。

到现在为例一个事务已经结束了。

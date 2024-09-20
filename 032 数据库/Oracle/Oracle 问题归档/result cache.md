# result cache

　　result  cache是用来存储查询sql得到的结果，给之后的重复查询来使用。通过缓存这些结果，oracle能避免那些重复的实际消耗，并且节省了大量的数据库操作，比如排序、合并、物理io和表关联等。result   cache是内存里的一块单独区域，要么是SGA里或者客户端应用程序内存里。存放在里面的缓存结果在不同的sql语句或者不同的会话之间是可以共享的，除非缓存结果本身失效了。结果缓存对于应用程序来说是完全透明的，它不需要人为介入，而是直接由oracle内部来进行自动管理和维护。

　　对于不同的应用系统来说，result  cache所带来的收益是不一样的，对于OLAP这种大数据量的分析统计系统来说效果最明显。缓存的最佳选择是查询了大量的数据，但最后却只返回少量的数据，例如数据仓库。除此之外，对于只读或者数据较少变化的SQL来说效果也会更好，因为当数据进行了变化后，相对于的缓存也会失效，而需要重新维护生成新的。

## 数据库相关配置

　　oracle与result cache相关的一些初始化参数如下

```bash
select name, value, isdefault
from v$parameter
where name like 'result_cache%';

NAME                                               VALUE           ISDEFAULT
-------------------------------------------------- --------------- ---------------------------
result_cache_mode                                  MANUAL          TRUE
result_cache_max_size                              42958848        TRUE
result_cache_max_result                            5               TRUE
result_cache_remote_expiration                     0               TRUE
```

* **result_cache_mode**  
  决定了哪些查询是可以存储在result cache里的，如果查询有资格放到缓存，则应用会去检查result cache里是否已经存在，如果存在则直接从里面获取数据，如果不存在数据库则会执行查询语句，并返回结果同时将结果放到result cache当中。

  * Manual  
    只有带查询hint和表标注的查询结果才会进行缓存，这是默认值
  * Force  
    所有的查询都会强制缓存到result cache，但是可以在sql中指定/*+ NO_RESULT_CACHE */来排除当前sql
* **result_cache_max_size**  
  设定result cache的大小，这部分内存是直接从shared pool中分配但是是单独维护，刷新shared pool并不会刷新result cache
* **result_cache_max_result**  
  指定对于单个结果来说所占用的内存大小不能超过总result cache大小的百分比，默认值是5，这个参数可以在system或者session级别进行修改
* **result_cache_remote_expiration**  
  指定那些依赖远端数据库对象的结果集超期时间（分钟），默认是0表示使用远端数据库对象的结果不会被缓存。如果指定的非0值，则对远端数据库对象进行的DML操作并不会使缓存结果失效。

　　清空结果缓存

```bash
exec DBMS_RESULT_CACHE.FLUSH;
```

## 手动result cache

　　默认缓存模式为手动表示数据库并不会自动缓存结果，除非使用RESULT_CACHE hint。

```bash
create table t
as
select mod(level,10) id,level*2 amount from dual
connect by level <=50000;

set timing on
set autotrace traceonly

select /*+ result_cache */
id, sum(amount) amount
from t
group by id;

Elapsed: 00:00:00.03

Execution Plan
----------------------------------------------------------
Plan hash value: 47235625

--------------------------------------------------------------------------------------------------
| Id  | Operation           | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |                            |    10 |    80 |    30   (7)| 00:00:01 |
|   1 |  RESULT CACHE       | 0jqwkxxdxwwby3nq2zva97pa1n |       |       |            |          |
|   2 |   HASH GROUP BY     |                            |    10 |    80 |    30   (7)| 00:00:01 |
|   3 |    TABLE ACCESS FULL| T                          | 50000 |   390K|    28   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------

Result Cache Information (identified by operation id):
------------------------------------------------------

   1 - column-count=2; dependencies=(XB.T); name="select /*+ result_cache */
id, sum(amount) amount
from t
group by id"



Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
         92  consistent gets
         84  physical reads
          0  redo size
        554  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
         10  rows processed
```

　　通过上面的这个结果得到了如下信息：

* 首先在执行计划中看到了一个新的operation，ID=1的“RESULT CACHE”。这是执行计划在执行过程中的最后一步，它告诉我们oracle会缓存之前步骤执行后得到的结果。
* 在Name那一列，operation为“RESULT  CACHE”的那一行多了一个系统生成的标识值，这是一个内部key供系统来在result  cache中查询和匹配sql语句,看起来是通过sql文本hash值得到的，因为刷新了cache以后这个key不会变。
* 执行计划报告中多了一个新的“Result Cache Information”，包含了这个sql所依赖的对象，和生成这个结果的sql文本开头的一部分。

　　这里总共扫描了5W行数据，92个一致性读，84个物理读，最终获取了10行数据。

　　对这个已经缓存到内存的sql重新执行 ，比较下两者之间的结果有何不同。

```bash
--------------------------------------------------------------------------------------------------
| Id  | Operation           | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |                            |    10 |    80 |    30   (7)| 00:00:01 |
|   1 |  RESULT CACHE       | 0jqwkxxdxwwby3nq2zva97pa1n |       |       |            |          |
|   2 |   HASH GROUP BY     |                            |    10 |    80 |    30   (7)| 00:00:01 |
|   3 |    TABLE ACCESS FULL| T                          | 50000 |   390K|    28   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------

Result Cache Information (identified by operation id):
------------------------------------------------------

   1 - column-count=2; dependencies=(XB.T); name="select /*+ result_cache */
id, sum(amount) amount
from t
group by id"



Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          0  consistent gets
          0  physical reads
          0  redo size
        554  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
         10  rows processed
```

　　执行计划并没有什么区别，重点看最后的Statistics部分。可以看到在这些执行中oracle本身只做了非常少的工作，逻辑读和物理读都是0。oracle已经意识到这个查询是可以直接从result  cache当中获取结果的，所以就直接很容易的返回了预先计算好的答案。

```bash
col name for a40
col cache_id for a40
select name,type,cache_id,row_count 
from v$result_cache_objects
order by creation_timestamp;

NAME                                     TYPE                           CACHE_ID                                  ROW_COUNT
---------------------------------------- ------------------------------ ---------------------------------------- ----------
select /*+ result_cache */               Result                         0jqwkxxdxwwby3nq2zva97pa1n                       10
id, sum(amount) amount
from t
group by id

XB.T                                     Dependency                     XB.T                      
```

　　通过`v$result_cache_objects`​视图可以看到有两个不同的类型，`dependency`​和`result`​，result类型清晰的表示了之前执行的sql。

　　同样也可以通过`v$result_cache_statistics`​视图来查到与result cache相关的更加详细的统计信息

```bash
SQL> select * from v$result_cache_statistics;

        ID NAME                                     VALUE                    CON_ID
---------- ---------------------------------------- -------------------- ----------
         1 Block Size (Bytes)                       1024                          0
         2 Block Count Maximum                      41952                         0
         3 Block Count Current                      256                           0
         4 Result Size Maximum (Blocks)             2097                          0
    	 5 Create Count Success                     1                             0
         6 Create Count Failure                     0                             0
         7 Find Count                               1                             0
         8 Invalidation Count                       0                             0
         9 Delete Count Invalid                     0                             0
        10 Delete Count Valid                       0                             0
        11 Hash Chain Length                        0-1                           0
        12 Find Copy Count                          1                             0
        13 Latch (Share)                            0                             0
```

　　这个视图可以看到一些基本信息，缓存的条目和命中。目前block大小为1k，最多有41952个块也就是41952k，与show  parameter看到的结果一致。当前使用了256k，单个结果最多能使用2097k，成功创建一个结果（Create Count  Success），并且命中过一次缓存（Find Count）。

## result cache依赖性

　　每个查询的结果都依赖一个或多个表，通过`V$RESULT_CACHE_DEPENDENCY`​视图可以查到result cache当中每一个条目所依赖的对象。

```bash
SELECT a.id, a.name, listagg(c.object_name) within group (order by 1) AS object_names
  FROM v$result_cache_objects a
  LEFT OUTER JOIN v$result_cache_dependency b
    ON (a.id = b.result_id)
  LEFT OUTER JOIN dba_objects c
    ON (b.object_no = c.object_id)
 WHERE a.type = 'Result'
 GROUP BY a.id, a.name;
 
         ID NAME                                                                   OBJECT_NAMES
---------- ---------------------------------------------------------------------- ------------------------------
       100 select /*+ result_cache */                                             T
           id, sum(amount) amount
           from t
           group by id
```

　　依赖性主要是为了保持缓存中数据的完整性，如果所依赖的表被修改了，oracle会修改缓存的条目为失效状态，在原sql重新执行以后则会生成一个新的条目出来。这个特性无法关闭，即使你能容忍数据的不一致。

　　所以想要使result cache里的条目失效非常简单，只要简单做个更新然后commit即可。

```bash
update t
set id=id
where rownum=1;

commit;
```

　　这时重新执行之前的sql

```bash
set autotrace traceonly

select /*+ result_cache */
id, sum(amount) amount
from t
group by id;

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         92  consistent gets
          0  physical reads
          0  redo size
        554  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
         10  rows processed
```

　　oracle并不会判断你的语句是否造成了数据的变更，可以通过上面的结果看到又重新产生了一致性读，表示这次执行oracle并没有直接采用result cache里存放的结果，而是重新执行了一遍语句，通过`v$result_cache_objects`​查看更详细的信息。

```bash
col name for a40
select name,type,status,cache_id,row_count 
from v$result_cache_objects
order by creation_timestamp;

NAME                                     TYPE                           STATUS                      CACHE_ID                                  ROW_COUNT
---------------------------------------- ------------------------------ --------------------------- ---------------------------------------- ----------
XB.T                                     Dependency                     Published                   XB.T                                              0
select /*+ result_cache */               Result                         Invalid                     0jqwkxxdxwwby3nq2zva97pa1n                       10
id, sum(amount) amount
from t
group by id

select /*+ result_cache */               Result                         Published                   0jqwkxxdxwwby3nq2zva97pa1n                       10
id, sum(amount) amount
from t
group by id
```

　　这里`STATUS`​列很清楚的表示了之前的那个条目变成了失效状态，而之后生成了一个cache_id一样的新条目，状态是published状态，也就是当前可用的状态。

## 缓存使用计数

　　缓存了结果以后，可以通过`V$RESULT_CACHE_STATISTICS`​视图来查看缓存具体被使用的次数，但是这里显示的数据都代表的result cache的整体统计信息，无法获取单个条目的情况。

　　这个视图的结果可以给我们用来验证一些实验，通过PL/SQL循环调用sql，查看缓存使用了多少次

```bash
select value from v$result_cache_statistics
where name='Find Count';

VALUE
--------------------
106

declare
	n int;
begin
	for i in 1..100 loop
		select /*+ result_cache */ count(1) into n from t;
	end loop;
end;
/

PL/SQL procedure successfully completed.
```

　　重新检查find count的计数

```bash
select value from v$result_cache_statistics
where name='Find Count';

VALUE
--------------------
205
```

　　计数增加了99，这是因为第一次是创建新的缓存条目，而剩下的99次都是直接使用这个缓存条目的结果。

```bash
col name for a40
select name,type,status,cache_id,row_count 
from v$result_cache_objects
order by creation_timestamp;

NAME                                     TYPE                           STATUS                      CACHE_ID                                  ROW_COUNT
---------------------------------------- ------------------------------ --------------------------- ---------------------------------------- ----------
XB.T                                     Dependency                     Published                   XB.T                                              0
select /*+ result_cache */               Result                         Invalid                     0jqwkxxdxwwby3nq2zva97pa1n                       10
id, sum(amount) amount
from t
group by id

select /*+ result_cache */               Result                         Published                   0jqwkxxdxwwby3nq2zva97pa1n                       10
id, sum(amount) amount
from t
group by id

SELECT /*+ result_cache */ COUNT(1) FROM Result                         Published                   6khry4nkgn7r918q26w75v28td                        1
 T
```

## 性能比较

　　在前面提到oracle建议是那些读取大量数据但是返回少量数据的情况最适合result cache，接下来会通过几个例子来量化性能的提升到底有多少，对于不同的场景来说提升的幅度有多大。

　　**简单数据求和**

```bash
SQL> exec DBMS_RESULT_CACHE.FLUSH;

PL/SQL procedure successfully completed.

SQL> exec runstats_pkg.rs_start;

PL/SQL procedure successfully completed.

SQL> declare
  2  n int;
  3  begin
  4  for i in 1..100 loop
  5  select
  6  sum(amount) amount into n
  7  from t;
  8  end loop;
  9  end;
 10  /

PL/SQL procedure successfully completed.

SQL> exec runstats_pkg.rs_middle;

PL/SQL procedure successfully completed.

SQL> declare
  2  n int;
  3  begin
  4  for i in 1..100 loop
  5  select /*+ result_cache */
  6  sum(amount) amount into n
  7  from t;
  8  end loop;
  9  end;
 10  /

PL/SQL procedure successfully completed.

SQL> exec runstats_pkg.rs_stop(1000);
===============================================================================================
RunStats report : 24-AUG-2020 16:35:16
===============================================================================================
-----------------------------------------------------------------------------------------------
1. Summary timings
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
TIMER cpu time (hsecs)                                             18            0          -18
TIMER elapsed time (hsecs)                                        862          795          -67
Comments:
1) Run2 was 7.8% quicker than Run1
2) Run2 used 7.8% less CPU time than Run1
-----------------------------------------------------------------------------------------------
2. Statistics report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
STAT  no work - consistent read gets                            8,900           89       -8,811
STAT  table scan blocks gotten                                  8,900           89       -8,811
STAT  consistent gets                                           9,200           92       -9,108
STAT  consistent gets from cache                                9,200           92       -9,108
STAT  consistent gets pin                                       9,200           92       -9,108
STAT  consistent gets pin (fastpath)                            9,200           92       -9,108
STAT  session logical reads                                     9,200           92       -9,108
LATCH cache buffers chains                                     18,401          351      -18,050
STAT  session uga memory                                            0    1,178,784    1,178,784
STAT  table scan disk non-IMC rows gotten                   5,000,000       50,000   -4,950,000
STAT  table scan rows gotten                                5,000,000       50,000   -4,950,000
STAT  session pga memory                                   -4,718,592    1,179,648    5,898,240
STAT  logical read bytes from cache                        75,366,400      753,664  -74,612,736
-----------------------------------------------------------------------------------------------
3. Latching report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
LATCH total latches used                                       28,549       10,743      -17,806
Comments:
1) Run2 used 62.4% fewer latches than Run1
-----------------------------------------------------------------------------------------------
4. Time model report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
TIME  PL/SQL execution elapsed time                             6,330        6,263          -67
TIME  parse time elapsed                                          350          234         -116
TIME  sql execute elapsed time                                255,629       40,530     -215,099
TIME  DB time                                                 256,752       41,251     -215,501
TIME  DB CPU                                                  257,054       41,508     -215,546
```

　　都是重复了100次，第一次没有使用result  cache，而第二次进行了缓存，从总的时间上来看第二次快了7.8%，消耗了更少的cpu。在statistics报告里面，一些一致性读的部分大量减少，RUN1出现了很多CBC  latch争用，总latch数量RUN2会少了62.4%，总的来说对于这种简单语句，效果并没有预想的那么明显。

　　**复杂语句**

　　创建两张测试表，每张表大概50W数据

```bash
create table t1 as select * from dba_objects;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
commit;

create table t2 as select * from t1;
```

　　循环执行sql

```bash
SQL> set serveroutput on
SQL> exec DBMS_RESULT_CACHE.FLUSH;

PL/SQL procedure successfully completed.

SQL>
SQL> exec runstats_pkg.rs_start;

PL/SQL procedure successfully completed.

SQL> declare
  2  n int;
  3  begin
  4  for i in 1..100 loop
  5  select  count(1) into n from t1,t2 where t1.object_name=t2.object_name;
  6  end loop;
  7  end;
  8  /

PL/SQL procedure successfully completed.

SQL> exec runstats_pkg.rs_middle;

PL/SQL procedure successfully completed.

SQL> declare
  2  n int;
  3  begin
  4  for i in 1..100 loop
  5  select /*+ result_cache */ count(1) into n from t1,t2 where t1.object_name=t2.object_name;
  6  end loop;
  7  end;
  8  /

PL/SQL procedure successfully completed.

SQL> exec runstats_pkg.rs_stop(1000);
===============================================================================================
RunStats report : 25-AUG-2020 10:49:54
===============================================================================================
-----------------------------------------------------------------------------------------------
1. Summary timings
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
TIMER cpu time (hsecs)                                          8,617           88       -8,529
TIMER elapsed time (hsecs)                                    122,975        1,281     -121,694
Comments:
1) Run2 was 99% quicker than Run1
2) Run2 used 99% less CPU time than Run1
-----------------------------------------------------------------------------------------------
2. Statistics report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
LATCH object queue header operation                             1,753          732       -1,021
LATCH query server process                                      1,059           12       -1,047
LATCH session allocation                                        1,185           20       -1,165
LATCH interrupt manipulation                                    1,235           26       -1,209
LATCH cp srv type state latch                                   1,231           16       -1,215
STAT  process last non-idle time                                1,230           13       -1,217
LATCH service drain list                                        1,230           13       -1,217
LATCH Consistent RBA                                            1,266           13       -1,253
LATCH OS process                                                1,300            5       -1,295
LATCH channel operations parent latch                           1,404           31       -1,373
LATCH client/application info                                   1,894           37       -1,857
LATCH process queue                                             2,107           45       -2,062
LATCH query server freelists                                    2,202           47       -2,155
LATCH lgwr LWN SCN                                              2,449           20       -2,429
STAT  calls to kcmgcs                                           2,704           31       -2,673
LATCH post/wait queue                                           2,791           34       -2,757
LATCH OS process allocation                                     3,050           24       -3,026
LATCH parallel query alloc buffer                               3,385           73       -3,312
LATCH session idle bit                                          4,097           81       -4,016
STAT  scheduler wait time                                       4,310           22       -4,288
STAT  non-idle wait time                                        4,370           23       -4,347
LATCH redo writing                                              5,174          269       -4,905
LATCH SGA Logging Log Latch                                     5,811           57       -5,754
LATCH JS Sh mem access                                          6,149           65       -6,084
LATCH redo allocation                                           6,168           54       -6,114
STAT  CPU used by this session                                  8,620           92       -8,528
STAT  recursive cpu usage                                       8,620           91       -8,529
STAT  CPU used when call started                                8,625           92       -8,533
LATCH archive destination                                       9,407          457       -8,950
LATCH Real-time descriptor latch                               10,709            0      -10,709
LATCH checkpoint queue latch                                   22,123        5,154      -16,969
LATCH SQL memory manager workarea list latch                   27,954          275      -27,679
STAT  non-idle wait count                                      32,206          357      -31,849
LATCH messages                                                 34,303          803      -33,500
LATCH shared pool                                              45,485          607      -44,878
LATCH process queue reference                                  81,350        1,411      -79,939
LATCH simulator hash latch                                    144,019        1,787     -142,232
LATCH active service list                                     157,454        1,654     -155,800
LATCH JS queue state obj latch                                332,004        3,456     -328,548
LATCH enqueue hash chains                                     708,314        7,930     -700,384
STAT  no work - consistent read gets                        2,275,500       22,755   -2,252,745
STAT  table scan blocks gotten                              2,275,500       22,755   -2,252,745
STAT  consistent gets                                       2,278,200       22,782   -2,255,418
STAT  consistent gets from cache                            2,278,200       22,782   -2,255,418
STAT  consistent gets pin                                   2,278,200       22,782   -2,255,418
STAT  consistent gets pin (fastpath)                        2,278,200       22,782   -2,255,418
STAT  session logical reads                                 2,278,200       22,782   -2,255,418
STAT  session pga memory                                   -3,145,728    1,114,112    4,259,840
LATCH cache buffers chains                                  4,619,781       47,490   -4,572,291
STAT  session pga memory max                               61,407,232    1,114,112  -60,293,120
STAT  session uga memory max                               62,780,264    1,056,048  -61,724,216
STAT  table scan disk non-IMC rows gotten                 116,846,400    1,168,464 -115,677,936
STAT  table scan rows gotten                              116,846,400    1,168,464 -115,677,936
STAT  logical read bytes from cache                      ############  186,630,144 ############
-----------------------------------------------------------------------------------------------
3. Latching report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
LATCH total latches used                                    6,274,587       74,319   -6,200,268
Comments:
1) Run2 used 98.8% fewer latches than Run1
-----------------------------------------------------------------------------------------------
4. Time model report
-----------------------------------------------------------------------------------------------
Type  Name                                                       Run1         Run2         Diff
----- -------------------------------------------------- ------------ ------------ ------------
TIME  PL/SQL compilation elapsed time                           2,332            0       -2,332
TIME  PL/SQL execution elapsed time                             7,196        4,566       -2,630
TIME  hard parse elapsed time                                   2,824            0       -2,824
TIME  parse time elapsed                                        5,084          342       -4,742
TIME  DB CPU                                               86,246,712      923,657  -85,323,055
TIME  sql execute elapsed time                            129,287,077    1,145,411 -128,141,666
TIME  DB time                                             129,291,774    1,146,272 -128,145,502
-----------------------------------------------------------------------------------------------
```

　　可以看到对于这种访问大数据最后返回数据量又小的情况，性能提升的效果就非常明显。未使用result  cache的情况花费了120s，而使用result  cache的情况则使用了1s多，CPU的消耗也减少了99%，而在一些具体的统计指标比如latch事件的等待、一致性读的构造和内存分配等情况下耗费的资源都少的多。

　　总的来说最大的性能提升方面在于避免了大量重复的数据库工作，直接从结果中获取数据，然而对于源表经常要进行修改的情况可能也会导致更负面的效果。

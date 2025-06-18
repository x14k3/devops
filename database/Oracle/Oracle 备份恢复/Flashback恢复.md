

rman 粒度最细只到表空间级别，单纯恢复表级别数据可以用闪回技术。

闪回flashback取决于undo retention,undo表空间要置为自动管理。

闪回分为：

- flashback database
- flashback drop
- flashback query
- flashback table

Flashback Query和Flashback Table都是利用undo实现回退功能，当需要闪回到过去某一时刻时，先利用Flashback Query查询，确认闪回的SCN或Timestamp，然后再利用Flashback Table真正实现闪回.

## 1.闪回查询(flashback query)

闪回查询可以通过时间戳timestamp或SCN号来查询前一段时间的数据。

具体用法：

```bash
select * from xxx as of timestamp to_timestamp('20170120 090000','yyyymmdd hh24miss');
select * from xxx as of scn xxx;
# 查看当前SCN号:
select current_scn from v$database;
# 查看SCN和时间戳的对应关系
select scn,to_char(time_dp,'yyyy-mm-dd hh24:mi:ss')from sys.smon_scn_time;
# 恢复误操作的数据：
insert into xxx select \* from xxx as of timestamp to\_timestamp('20170120 090000','yyyymmdd hh24miss');
```

‍

## 2.闪回表(flashback table)

根据Flashback Query的演变历史，就可以确定需要回退的时间点，然后再利用Flashback table恢复

flashback查询的最早时间点受限于初始化参数undo\_retention。

使用flashback table语句可以将表恢复到先前时间点

通过使用该特征，可以避免执行基于时间点的不完全恢复，注意如果要在某个表上使用flashback table特征，则要求必须具有以下条件：

a.用户必须具有flashback any table系统权限或flashback对象权限

b.用户必修在表上具有select insert delete和alter权限

c.必须合理设置初始化参数undo\_retention，以确保UNDO信息保留足够时间

d.必须激活行移动特征：alter table table\_name enable row movement；

使用flashback table恢复表数据到先前时间点

```bash
flashback table xxx to timestamp to_timestamp('2017-01-20 09:00:00','YYYY-MM-DD HH24:MI:SS');
```

## 3.闪回删除(flashback drop)

回收数据库表，用于表误drop后恢复。类似Windows的回收站。

数据库回收站是oracle10g新引入的概念，当执行drop table删除表时，数据库不会立即释放与表相关的空间，该表实际被改名，并且与其相关的对象存放在数据库回收站里，因此使用flashback table可以恢复回收站的对象，注意，数据库回收站具有以下限制：

（1）回收站只适用于非system的局部管理表空间

（2）oracle没有为回收站分配固定的预留空间，因此不能保证数据库对象在回收站中的保留时间，当被删除对象所在表空间没有足够空间时，oracle会使用FIFO（先进先出）机制清除回收站的相应对象

（3）使用select语句可以查询回收站对象的数据，但不能再回收站对象上执行DML和DDL操作

（4）使用drop table xxx purge 不会放入回收站

查看回收站中被删除的表：

​`Show recyclebin;`​

恢复被删除表:

​`flashback table "xxx" to before drop;`​

## 4.闪回数据库(flashback database)

闪回数据库和RMAN类似，都是将数据库进行不完全恢复。闪回数据库通过flashback log来恢复，更加高效。

区别是闪回数据库不能解决介质损坏。如删除了物理文件或者通过shrink技术对数据文件进行压缩，则不能用闪回数据库进行恢复。

闪回恢复区主要通过3个初始化参数来设置和管理:

- db\_recovery\_file\_dest：指定闪回恢复区的位置
- db\_recovery\_file\_dest\_size：指定闪回恢复区的可用空间大小
- db\_flashback\_retention\_target：指定数据库可以回退的时间，单位为分钟，默认1440分钟，也就是一天。当然，实际上可回退的时间还决定于闪回恢复区的大小，因为里面保存了回退所需要的flash log。所以这个参数要和db\_recovery\_file\_dest\_size配合修改。flash recovery area 的大小至少是数据库所占容量的20%。

‍

开启闪回数据库需要配置如下参数：

```bash

SQL> alter system set db_recovery_file_dest_size=2G scope=both;
SQL> alter system set db_recovery_file_dest='/oradatab/flashback' scope=both;
SQL> shutdown immediate
SQL> startup mount
SQL> alter database archivelog;
SQL> alter database flashback on;
SQL> select name,flashback_on from v$database;
SQL> alter system set db_flashback_retention_target=1440 scope=both;
SQL> alter database open;
```

‍

## Flashback Database 操作示例

1）模拟数据丢失：

```sql

SQL> create table test as select * from dba_objects;

Table created.

SQL> select count(*) from test;

  COUNT(*)

----------

     10318

SQL> truncate table test;

Table truncated.

SQL> select count(*) from test;

  COUNT(*)

----------

         0
```

2）确认能恢复的时间点

能回退的最早时间，取决于保留的Flashback database log的多少，可以从v$flashback\_database\_log查看：

```sql
SQL> select to_char(OLDEST_FLASHBACK_TIME,'yyyy-mm-dd hh24:mi:ss') from v$flashback_database_log;

TO_CHAR(OLDEST_FLAS

-------------------

2011-12-15 02:41:48
```

3）恢复数据到指定时间点

```sql
SQL> shutdown immediate;
SQL> startup mount;
SQL> flashback database to timestamp to_timestamp('2011-12-15 02:43:00','yyyy-mm-dd hh24:mi:ss');

Flashback complete.
```

4）打开数据库

恢复成功后，以resetlog方式打开数据库并检查数据是否已经恢复：

```sql
SQL> alter database open read only;

Database altered.

SQL> select count(*) from test;

  COUNT(*)

----------

     10318
```

5）确认恢复后，关闭数据库，并以resetlog方式打开数据库

```sql

SQL> shutdown immediate;

SQL> startup mount

SQL> alter database open resetlogs;
```

用resetlog方式打开数据库后，闪回时间点后的所有数据将会丢失。

如果要保证损失降到最低，可以先用read-only模式打开数据库，将误操作的表通过数据泵导出，

然后执行recover database，通过redo重新生成丢失的数据。再将误操作的数据导入即可。

‍

‍

**关于闪回日志过大的清除问题**

开启闪回数据库后，将由rvwr进程取用undo表空间中的before image，写入flashback log中。

闪回恢复区能存放的闪回日志大小由db\_recovery\_file\_dest\_size参数控制，闪回日志的保留时间由

db\_flashback\_retention\_target参数控制，该参数和undo\_retention类似，并不是一个精确的保留时间，

往往和库繁忙程度有关。若闪回恢复区闪回日志占用空间过大，可能导致归档日志，RMAN备份无法写入。

清除闪回日志目前没有便捷的方法，一般采用重启数据库，关闭闪回数据库，再重新开启。这样闪回日志将会被清理。

手动删除闪回恢复目录下的闪回日志是无效的，库中依然会显示空间被占用。

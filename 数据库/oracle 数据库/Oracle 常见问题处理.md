# Oracle 常见问题处理

## 报错日志目录

```bash
ADR Base             /u01/app/oracle
ADR Home           /u01/app/oracle/diag/rdbms/orcl/ORCL
Diag Trace            /u01/app/oracle/diag/rdbms/orcl/ORCL/trace
Diag Alert             /u01/app/oracle/diag/rdbms/orcl/ORCL/alert
Diag Incident        /u01/app/oracle/diag/rdbms/orcl/ORCL/incident
Diag Cdump         /u01/app/oracle/diag/rdbms/orcl/ORCL/cdump
Health Monitor     /u01/app/oracle/diag/rdbms/orcl/ORCL/hm
Default Trace File  /u01/app/oracle/diag/rdbms/orcl/ORCL/trace/ORCL_ora_19445.trc
ORACLE_HOME     /u01/app/oracle/product/19c/dbhome_1

Alert      # 警报日志，
Trace      # 跟踪日志(用户和进程)， 
redo       # 重做日志
```

## ora-01652:无法通过128(在表空间space中)扩展temp段解决办法

这种情况一看是当前用户所在的表空间达到32G大小上限，需要增加一个新的表空间

```sql
–-01.为用户追加第1个表空间
alter tablespace jy2web0726 add datafile '/data/oradata/orcl/jy2web0726_extend1.dbf'
size 1000m autoextend on next 500m maxsize unlimited;

–-02. 关联新表空间
alter tablespace jy2web0726 online;

–-3. 检查表空间数据文件
select name from v$datafile;
```

## archivelog日志占用空间大

```sql
-- 1.手动删除archivelog日志

-- 2.手动将当前在线日志归档
sqlplus / as sysdba
alter system archive log current;

-- 3.检查日志归档文件和实际物理文件的差别
rman target /
crosscheck archivelog all;

-- 4.执行rman逻辑上删除过期日志
delete noprompt expired archivelog all;
```

## undo表空间文件过大，占用磁盘空间

```sql
-- 以dba登录数据库
sqlplus / as sysdba
-- 查询实例名，确实实例
show parameter instance_name;
-- 查询undo表空间
show parameter undo_tablespace;
-- 查看undo表空间和文件的对应关系
select file_name, tablespace_name, online_status from dba_data_files where tablespace_name='UNDOTBS1';
-- 查询当前回退表空间状态
select tablespace_name, status from dba_rollback_segs;
-- undo_tablespace 是一个必须一直存在的表空间，
-- 要想删除当前的，我们必须设置一个临时空间供undo_tablespace 使用；
create undo tablespace UNDOTBS2 datafile '/data/oradata/orcl/undotbs02.dbf' size 100M;
alter system set undo_tablespace=UNDOTBS2;
-- 再查询当前回退表空间状态
select tablespace_name, status from dba_rollback_segs;
-- 删除回退表空间UNDOTBS1
drop tablespace UNDOTBS1 including contents and datafiles;
-- 重启oracle实例
shutdown immediate;
startup;
```

# oracle恢复redo

# Oracle性能变慢

1. 查看日志：/data/u01/app/oracle/diag/rdbms/jzdb/jzdb/trace/alert.log
2. 查看ora_进程pid > pid的top
3. 查看磁盘IO iostat -x 1
4. 查看数据库中过去一天内排在前10位的等待事件及其总等待时间

```sql
SELECT *
  FROM (SELECT EVENT,
               TOTAL_WAIT_TM,
               ROUND(TOTAL_WAIT_TM / SUM(TOTAL_WAIT_TM) OVER(ORDER BY 1), 4) * 100 || '%' ZB
          FROM (SELECT NVL(EVENT, 'ON CPU') EVENT, COUNT(*) TOTAL_WAIT_TM
                  FROM V$ACTIVE_SESSION_HISTORY
                 WHERE SAMPLE_TIME > TRUNC(SYSDATE) -- 15 / (24 * 60)
                 GROUP BY EVENT
                 ORDER BY 2 DESC))
 WHERE ROWNUM <= 10;
 --------------------------------------------------------------------
```

**enq: TM - contention：**
一般是执行DML期间，为防止对与DML相关的对象进行修改，执行DML的进程必须对该表获得TM锁。
下面修改参数，从而增加更多的dml锁尝试解决问题。

```sql
# 查看锁
select * from v$lock;
# 查看被锁对象
select * from v$locked_object;
alter system set dml_locks=4000 scope=spfile;


```

## checkpoint not complete

假设我们只有两个redo log group：group 1和group 2，并且buffer cache中总是有大量的dirty block需要写入datafile，当redo log从group 1 switch to group 2的时候，会触发checkpoint, checkpoint要求DBWr把buffer cache中的dirty block写入datafile。然而，当我们再次用完group 2里面的空间，需要再次switch to group 1并重用group 1的时候，如果我们发现redo log group 1所保护的那些dirty block还没有完全写入到datafile，整个数据库必须等待DBWr把所有的dirty block写入到datafile之后才能做其他的事情，这就是我们遇到的"checkpoint not complete"问题。

解决办法包括增加redo日志组合增大online redo log文件大小，为DBRr争取充裕的时间。

```sql

--1.查看当前日志组成员
SELECT MEMBER FROM V$LOGFILE;
--2.查看当前日志组状态
SELECT GROUP#,MEMBERS,BYTES/1024/1024,STATUS FROM V$LOG;
--手工全局检查点
--alter system checkpoint;

--3.增加日志组
ALTER DATABASE ADD LOGFILE GROUP 4 ('/data/oradata/jzdb/redo04.log') SIZE 1G;
ALTER DATABASE ADD LOGFILE GROUP 5 ('/data/oradata/jzdb/redo05.log') SIZE 1G;
ALTER DATABASE ADD LOGFILE GROUP 6 ('/data/oradata/jzdb/redo06.log') SIZE 1G;
--4.切换到新增的日志组上
ALTER SYSTEM SWITCH LOGFILE;--(可多次执行,直到CURRENT指向新建的日志组)
--5.查看当前日志组状态
SELECT GROUP#,MEMBERS,BYTES/1024/1024,STATUS FROM V$LOG;
SELECT * FROM V$LOG;
各种状态含义:
A.CURRENT指当前的日志文件,在进行实例恢复时是必须的；
B.ACTIVE是指活动的非当前日志,在进行实例恢复时会被用到。ACTIVE状态意味着,CHECKPOINT尚未完成,因此该日志文件不能被覆盖。这时也不能DROP掉,应该执行ALTER SYSTEM CHECKPOINT; --强制执行检查点;然后在操作。
C.INACTIVE是非活动日志,在实例恢复时不再需要,但在介质恢复时可能需要。
D.UNUSED表示该日志从未被写入,可能是刚添加的,或RESETLOGS后被重置。

# 7、删除日志组1、2、3
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;



```

## redo log 一直处于active 状态

如果日志都处于active状态，那么显然DBWR的写已经无法跟上log switch触发的检查点。

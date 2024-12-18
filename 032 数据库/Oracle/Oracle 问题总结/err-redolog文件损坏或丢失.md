# err-redolog文件损坏或丢失

　　​`sqlplus`​登录报错

　　ORA-01034: ORACLE不可用
ORA-27101: shared memory realm does not exist

　　可能原因：

* 联机在线日志文件损坏或丢失
* ​`listener.ora `​文件中的SID要注意大小写

　　‍

## 1 inactive日志组损坏

　　假如日志组4损坏，状态inactive。解决很简单，重建日志组即可
clear意味着重建group4的文件

```sql
alter database clear logfile group 4;
```

　　‍

## 2 current日志组丢失

　　本例日志组1状态是CURRENT状态的，现在模拟当前日志组损坏

```sql
SQL> select  v.group#, v.status,g.member from v$log v , v$logfile g where v.GROUP#=g.GROUP#;

    GROUP#    STATUS         MEMBER
--------------------------------------------------------------------------------
	 3     INACTIVE			/data/oradata/ORCL/redo03.log
	 2     INACTIVE			/data/oradata/ORCL/redo02.log
	 1     CURRENT			/data/oradata/ORCL/redo01.log

SQL> !rm redo01.log                --删除当前current日志文件
SQL> alter system switch logfile;  --切换几次，触动它一下。
```

　　告警日志会记录有关信息

```sql
2024-10-16T15:19:44.729052+08:00
Errors in file /data/u01/app/oracle/diag/rdbms/orcl/orcl/trace/orcl_arc2_6882.trc:
ORA-00313: 无法打开日志组 1 (用于线程 1) 的成员
ORA-00312: 联机日志 1 线程 1: '/data/oradata/ORCL/redo01.log'
ORA-27041: 无法打开文件
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
2024-10-16T15:19:44.729324+08:00

```

　　暂时好像没有什么问题发生，继续切换，当current 又转会到group1时，session死！
当前日志损坏的问题比较复杂，见上图可以分以下几种情况讨论

### 1）数据库没有崩溃

　　第一步，可以做一个完全检查点，将db buffer中的所有dirty buffer全部刷新到磁盘上。

```sql
SQL> alter system checkpoint;
```

　　第二步，尝试数据库在打开状态下进行不做归档的强制清除。

```sql
SQL> alter database clear unarchived logfile group n;
```

　　数据库此时为打开状态，这步若能成功，一定要做一个新的数据库全备，因为当前日志无法归档，归档日志sequence已无法保持连续性。全备的目的就是甩掉之前的归档日志。

### 2）数据库已经崩溃，只能做传统的基于日志的不完全恢复或使用闪回数据库。

```sql
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup ;
ORACLE instance started.

Total System Global Area 2365586088 bytes
Fixed Size		    8899240 bytes
Variable Size		  520093696 bytes
Database Buffers	 1828716544 bytes
Redo Buffers		    7876608 bytes
Database mounted.
ORA-03113: end-of-file on communication channel
Process ID: 10961
Session ID: 18 Serial number: 29920

```

```sql
RAMN> recover database until cancel;
RAMN> alter database open resetlogs;
```

　　具体参考：基于RMAN的不完全恢复 二、基于日志序列号的恢复举例

　　‍

### 3）如果之前没有可用的备份，或问题严重到任何方法都不能resetlogs打开数据库，为了抢救数据，考虑最后一招使用Oracle的隐含参数：\_allow\_resetlogs\_corruption=TRUE

　　Oracle不推荐使用这个隐含参数
该参数的含义是：允许数据库在不致性的情况下强制打开数据库。
在不一致状态下强行打开了数据库后，建议做一个逻辑全备。

```
--查询隐含参数
col ksppinm for a50
col ksppstvl for a50
col ksppdesc for a50
SELECT ksppinm, ksppstvl, ksppdesc
FROM x$ksppi x, x$ksppcv y
WHERE x.indx = y.indx AND ksppinm like '%_optimizer_ansi_rearchitecture%';
```

## 3 active日志组损坏

　　做检查点切换，如成功，按照inactive损坏处理。否则，按current损坏处理。

　　‍

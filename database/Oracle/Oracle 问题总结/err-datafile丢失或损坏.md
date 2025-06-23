#oracle

startup 启动数据库实例报错：数据库文件丢失或损坏

```bash
ORA-01157: cannot identify/lock data file 5 - see DBWR trace file
ORA-01110: data file 5: '/data/oradata/ORCL/datafile/o1_mf_hess_mjh71w5r_.dbf'

###########################################################################################


```

**解决方法：** 

1.不要重启数据库实例  
2.`ps -ef | grep dbw0`​ 查看ora\_dbw0\_实例 进程id  
3.cd /proc/进程id/fd    可以看到 261 -\> /u01/app/oracle/oradata/orcl/users01.dbf (deleted)标识删除  
4.cp /proc/进程id/fd/261  /u01/app/oracle/oradata/orcl/users01.dbf 将删除的数据文件拷贝回去  
5.`alter database datafile 数据文件编号 offline`​  
6.`recover datafile 数据文件编号；`​  
7.`alter database datafile 数据文件编号 online；`​

‍

如果关闭了数据库实例，则使用Catalog命令来注册备份集。该命令允许将RMAN备份集信息记录到控制文件或目录数据库

```sql
[oracle@oracle backupset]$ rman target /

RMAN> catalog start with '/data/orabackup/ORCL/backupset/';

RMAN> restore database;

--RMAN> recover database until time "to_date('2022-10-27 00:10:00','yyyy-mm-dd hh24:mi:ss')"; --基于时间点恢复
RMAN> recover database;
--在进行recover database的过程中由于缺少日志执行进行不完全恢复，只能基于时间点进行恢复
--RMAN> recover database until scn 20152861;

--打开数据库
[oracle@oracle backupset]$ sqlplus / as sysdba
SQL> alter database open;
Database altered.

```

‍

‍

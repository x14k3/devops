

- ORA-00205: 标识控制文件出错，有关详情，请检查警告日志​
- `sqlplus`​登录报错 ERROR: ORA-01033: ORACLE 正在初始化或关闭 Process

数据库实例无法startup，一般为控制文件丢失或损坏

### **检查如下**<span data-type="text" style="color: var(--b3-font-color7);">:</span>

```bash
[oracle@oracle ~]$ 
[oracle@oracle ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Oct 15 11:01:29 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup;
ORACLE instance started.

Total System Global Area 3221222464 bytes
Fixed Size		    8901696 bytes
Variable Size		  654311424 bytes
Database Buffers	 2550136832 bytes
Redo Buffers		    7872512 bytes
ORA-00205: error in identifying control file, check alert log for more info

###########################################################################################
[oracle@oracle ~]$ lsnrctl  status 

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 15-OCT-2024 11:07:55

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.10.0.11)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                10-OCT-2024 16:29:41
Uptime                    4 days 18 hr. 38 min. 24 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /data/u01/app/oracle/product/19.3.0/db_1/network/admin/listener.ora
Listener Log File         /data/u01/app/oracle/diag/tnslsnr/oracle/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.10.0.11)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=extproc)))
Services Summary...
Service "orcl" has 2 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
  Instance "orcl", status BLOCKED, has 1 handler(s) for this service...
The command completed successfully


###########################################################################################
[oracle@oracle ~]$ sqlplus hess/"xxxxxxxxxxxx"

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Oct 15 11:08:07 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

ERROR:
ORA-01033: ORACLE ????????
Process ID: 0
Session ID: 0 Serial number: 0


###########################################################################################
[oracle@oracle datafile]$ tail -20f /data/u01/app/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log
2024-10-15T13:56:28.683039+08:00
ALTER DATABASE   MOUNT
2024-10-15T13:56:28.716399+08:00
ORA-00210: ???????????
ORA-00202: ????: ''/data/oradata/ORCL/control02.ctl''
ORA-27037: ????????
Linux-x86_64 Error: 2: No such file or directory
Additional information: 7
ORA-00210: ???????????
ORA-00202: ????: ''/data/oradata/ORCL/control01.ctl''
ORA-27037: ????????
Linux-x86_64 Error: 2: No such file or directory
Additional information: 



```

注意：上面81行显示`/data/oradata/ORCL/control01.ctl`​这个控制文件丢失

### **解决方法1：从备份恢复控制文件**

```sql
--开启数据库到nomount状态
SQL> startup nomount
ORACLE instance started.

Total System Global Area 3221222464 bytes
Fixed Size		    8901696 bytes
Variable Size		  654311424 bytes
Database Buffers	 2550136832 bytes
Redo Buffers		    7872512 bytes
SQL>
--查看控制文件路径和内容
SQL> show parameter control_files

--rman恢复控制文件
[oracle@oracle ~]$ rman target /
RMAN> restore controlfile from "/data/orabackup/ORCL/autobackup/2024_10_15/o1_mf_s_1182384653_mjtjnhtm_.bkp";

Starting restore at 15-OCT-24
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=22 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
output file name=/data/oradata/ORCL/control01.ctl
output file name=/data/oradata/ORCL/control02.ctl
Finished restore at 15-OCT-24

RMAN> 

--开启数据库到mount状态
[oracle@oracle 2024_10_15]$ sqlplus / as sysdba
SQL> alter database mount;
Database altered.

--恢复数据库
[oracle@oracle ~]$ rman target /
RMAN> recover database;

Starting recover at 15-OCT-24
Starting implicit crosscheck backup at 15-OCT-24
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=257 device type=DISK
allocated channel: ORA_DISK_2
channel ORA_DISK_2: SID=24 device type=DISK
Crosschecked 13 objects
Crosschecked 9 objects
Finished implicit crosscheck backup at 15-OCT-24

Starting implicit crosscheck copy at 15-OCT-24
using channel ORA_DISK_1
using channel ORA_DISK_2
Finished implicit crosscheck copy at 15-OCT-24

searching for all files in the recovery area
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /data/orabackup/ORCL/autobackup/2024_10_15/o1_mf_s_1182384653_mjtjnhtm_.bkp

using channel ORA_DISK_1
using channel ORA_DISK_2

starting media recovery

archived log for thread 1 with sequence 19 is already on disk as file /data/oradata/ORCL/redo01.log
archived log file name=/data/oradata/ORCL/redo01.log thread=1 sequence=19
media recovery complete, elapsed time: 00:00:01
Finished recover at 15-OCT-24

RMAN> 

--通过resetlogs方式打开数据库
[oracle@oracle 2024_10_15]$ sqlplus / as sysdba
SQL> alter database open resetlogs;

Database altered.


```

### **解决方法2：手动重建控制文件**

```sql

--通过spfile或者pfile文件获取信息

--1.db_name
[oracle@oracle pfile]$ pwd
/data/u01/app/oracle/product/19.3.0/db_1/dbs
[oracle@oracle pfile]$ grep "db_name" init.ora
db_name="orcl"


--2.字符集
[oracle@oracle ~]$ grep "NLS_LANG" .bash_profile
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
#----------------------------------------------------------------------------
SQL> select * from v$version;

BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
PL/SQL Release 11.2.0.4.0 - Production
CORE    11.2.0.4.0      Production
TNS for Linux: Version 11.2.0.4.0 - Production
NLSRTL Version 11.2.0.4.0 - Production

# 在同版本可正常打开的数据库中执行
select distinct dbms_rowid.rowid_relative_fno(rowid) file#,
       dbms_rowid.rowid_block_number(rowid) block#
  from props$;

     FILE#     BLOCK#
---------- ----------
         1        801

# 使用dd工具dump
dd if=/u01/app/oracle/oradata/orcl/system01.dbf of=/tmp/props bs=8192 skip=801 count=1

strings /tmp/props
#------------------------------
......
NLS_CHARACTERSET
ZHS16GBK
Character set,
......
#------------------------------


#----------------------------------------------------------------------------

--3.获取数据文件和日志文件名称
[oracle@oracle ORCL]$ pwd
/data/oradata/ORCL
[oracle@oracle ORCL]$ ll
总用量 2831088
-rw-r----- 1 oracle oinstall  10600448 10月 15 11:37 control01.ctl
-rw-r----- 1 oracle oinstall  10600448 10月 15 11:37 control02.ctl
drwxr-x--- 2 oracle oinstall        38 10月 10 17:19 datafile
-rw-r----- 1 oracle oinstall 209715712 10月 15 11:37 redo01.log
-rw-r----- 1 oracle oinstall 209715712 10月 15 11:35 redo02.log
-rw-r----- 1 oracle oinstall 209715712 10月 15 11:35 redo03.log
-rw-r----- 1 oracle oinstall 807411712 10月 15 11:35 sysaux01.dbf
-rw-r----- 1 oracle oinstall 964698112 10月 15 11:35 system01.dbf
-rw-r----- 1 oracle oinstall 136323072 10月 14 22:00 temp01.dbf     -- 这个不用添加，启动实例后手动启用
-rw-r----- 1 oracle oinstall 346038272 10月 15 11:35 undotbs01.dbf
-rw-r----- 1 oracle oinstall   5251072 10月 15 11:35 users01.dbf
[oracle@oracle ORCL]$ 

--重建控制文件（这里不需要加临时文件，开启数据库之后需要reuse）
--开启数据库到nomount
SQL> STARTUP NOMOUNT;
--创建控制文件
SQL> CREATE CONTROLFILE REUSE DATABASE "ORCL" NORESETLOGS ARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 '/data/oradata/ORCL/redo01.log'  SIZE 200M BLOCKSIZE 512,
  GROUP 2 '/data/oradata/ORCL/redo02.log'  SIZE 200M BLOCKSIZE 512,
  GROUP 3 '/data/oradata/ORCL/redo03.log'  SIZE 200M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/data/oradata/ORCL/system01.dbf',
  '/data/oradata/ORCL/sysaux01.dbf',
  '/data/oradata/ORCL/undotbs01.dbf',
  '/data/oradata/ORCL/users01.dbf',
  '/data/oradata/ORCL/datafile/o1_mf_hess_mjh71w5r_.dbf'
CHARACTER SET AL32UTF8
;
--恢复数据库
SQL> recover database;
Media recovery complete.
SQL>

SQL> ALTER DATABASE OPEN;

Database altered.

--这里需要将临时文件重用
SQL> ALTER TABLESPACE TEMP ADD TEMPFILE '/data/oradata/ORCL/temp01.dbf' REUSE;

Tablespace altered.
```

> （1） MAXDATAFILES       决定数据库可以拥有的数据文件数量。使用 Oracle Real Application Clusters，数据库往往比独占安装的数据库拥有更多的数据文件和日志文件。
>
> （2） MAXINSTANCES      限制可以并发访问数据库的实例数量。在 z/OS 下，此选项的默认值为 15。将 MAXINSTANCES 设置为大于您预期并发运行的最大实例数的值。
>
> （3）MAXLOGFILES          指定可以为数据库创建的最大重做日志组数。
>
> （4）MAXLOGMEMBERS  指定每个组的最大成员数或副本数。
>
> （5）MAXLOGHISTORY    指定控制文件的日志历史记录中可以记录的最大重做日志文件数。日志历史记录用于 Oracle Real Application Clusters 的自动介质恢复。对于 Oracle Real Application Clusters，请将 MAXLOGHISTORY 设置为较大的值，例如 100。然后，控制文件可以存储有关此重做日志文件数的信息。当日志历史记录超过此限制时，Oracle 服务器将覆盖日志历史记录中最旧的条目。MAXLOGHISTORY 的默认值为 0（零），这将禁用日志历史记录。

‍

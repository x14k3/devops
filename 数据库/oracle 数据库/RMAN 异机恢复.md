#database/oracle 

## 1. 准备源数据库rman备份文件
分别需要备份数据库、控制文件以及参数文件，如果源数据库启用了控制文件自动备份，则可以用控制文件中获取参数文件。

```bash
# 备份完成后将备份传送至目标端
-rw-r--r-- 1 root root           5120 11月 14 20:57 arch_108_20221114.bak
-rw-r--r-- 1 root root     1130496 11月 14 20:57 ctl_c-1440834294-20221114-0b.bak
-rw-r--r-- 1 root root 319004672 11月 14 20:57 data_FMSDB_20221114_1120769806.bak
[root@test bak]# pwd
/opt/bak
```
如果有pfile文件，则可以直接跳到第四步：
[4. 生成pfile文件并并重新启动到nomount状态](RMAN%20异机恢复.md#4.%20生成pfile文件并并重新启动到nomount状态)

## 2. 目标端启动到nomount状态

注：在rman下即使没有参数文件，默认也会启动一个DUMMY实例，以便能够恢复参数文件

```sql
[oracle@orcl backup]$ rman target /
Recovery Manager: Release 11.2.0.4.0 - Production on Mon Jan 14 11:27:37 2019
Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
connected to target database (not started)

RMAN> startup nomount

startup failed: ORA-01078: failure in processing system parameters
LRM-00109: could not open parameter file '/u01/app/oracle/product/11.2.0/db_1/dbs/initorcl.ora'

starting Oracle instance without parameter file for retrieval of spfile
Oracle instance started
Total System Global Area    1068937216 bytes
Fixed Size                                  2260088 bytes
Variable Size                         281019272 bytes
Database Buffers                  780140544 bytes
Redo Buffers                            5517312 bytes 
```


## 3. 从备份中恢复spfile参数文件

```sql
RMAN>  restore spfile from '/opt/bak/ctl_c-1440834294-20221114-0b.bak';

Starting restore at 14-NOV-22
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=21 device type=DISK

channel ORA_DISK_1: restoring spfile from AUTOBACKUP /opt/bak/ctl_c-1440834294-20221114-0b.bak
channel ORA_DISK_1: SPFILE restore from AUTOBACKUP complete
Finished restore at 14-NOV-22

RMAN> 
```


## 4. 生成pfile文件并并重新启动到nomount状态


如果要修改数据目录可以修改pfile后再启动到nomount状态

```sql
RMAN> sql "create pfile=''/tmp/pfile.bak'' from spfile";

vim /tmp/pfile.bak
----------------------------------------------
fmsdb.__data_transfer_cache_size=0
fmsdb.__db_cache_size=2415919104
fmsdb.__inmemory_ext_roarea=0
fmsdb.__inmemory_ext_rwarea=0
fmsdb.__java_pool_size=0
fmsdb.__large_pool_size=16777216
fmsdb.__oracle_base='/data/u01/app/oracle'#ORACLE_BASE set from environment
fmsdb.__pga_aggregate_target=1073741824
fmsdb.__sga_target=3221225472
fmsdb.__shared_io_pool_size=134217728
fmsdb.__shared_pool_size=637534208
fmsdb.__streams_pool_size=0
fmsdb.__unified_pga_pool_size=0
*.audit_file_dest='/data/u01/app/oracle/admin/fmsdb/adump'
*.audit_trail='db'
*.compatible='19.0.0'
*.control_files='/data/oradata/FMSDB/control01.ctl','/data/oradata/FMSDB/control02.ctl'
*.db_block_size=8192
*.db_name='fmsdb'
*.diagnostic_dest='/data/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=fmsdbXDB)'
*.log_archive_dest_1='location=/data/arch/fmsdb'
*.log_archive_format='%t_%s_%r.dbf'
*.nls_language='SIMPLIFIED CHINESE'
*.nls_territory='CHINA'
*.open_cursors=300
*.pga_aggregate_target=1024m
*.processes=300
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=3072m
*.undo_tablespace='UNDOTBS1'
----------------------------------------------------

-- 由于只安装了数据库软件未创建实例所以需要创建对应文件夹，可以根据spfile备份文件创建相关目录
-- 根据pfile文件创建相关目录
mkdir -p /data/oradata/FMSDB                   # 数据目录
mkdir -p /data/arch/fmsdb                          # 日志归档目录
mkdir -p /data/u01/app/oracle/fast_recovery_area/fmsdb
mkdir -p /data/u01/app/oracle/admin/fmsdb/adump
chown -R oracle.oinstall /data/u01 /data/oradata /data/arch

-------------------------------------------------------

[oracle@dbdb ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Sun Nov 6 18:15:03 2022

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

Connected to an idle instance.
-- 如果有pfile文件，则可以直接跳到这里：
SQL> startup nomount pfile='/tmp/pfile.bak' force;
ORACLE instance started.

Total System Global Area 3221222464 bytes
Fixed Size                  8901696 bytes
Variable Size             654311424 bytes
Database Buffers         2550136832 bytes
Redo Buffers                7872512 bytes

SQL> create spfile from pfile='/tmp/pfile.bak';
-- spfile 文件会生成在 $ORACLE_HOME/dbs/下
File created.

```


## 5. 恢复控制文件并启动到mount状态


恢复控制文件

```sql
[oracle@fmsrvdb ~]$ rman target /

Recovery Manager: Release 19.0.0.0.0 - Production on Mon Nov 14 22:43:47 2022
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: FMSDB (not mounted)

RMAN> restore controlfile from '/opt/bak/ctl_c-1440834294-20221114-0b.bak';

Starting restore at 14-NOV-22
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=22 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
output file name=/data/oradata/FMSDB/control01.ctl
output file name=/data/oradata/FMSDB/control02.ctl
Finished restore at 14-NOV-22

RMAN> 
```

启动到mount状态

```sql
RMAN> alter database mount;

database mounted
released channel: ORA_DISK_1
```

## 6. 注册备份信息到控制⽂件

```sql
RMAN> catalog start with '/opt/bak/';

searching for all files that match the pattern /opt/bak/

List of Files Unknown to the Database
=====================================
File Name: /opt/bak/data_FMSDB_20221114_1120769806.bak
File Name: /opt/bak/ctl_c-1440834294-20221114-0b.bak
File Name: /opt/bak/arch_108_20221114.bak

Do you really want to catalog the above files (enter YES or NO)? yes
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /opt/bak/data_FMSDB_20221114_1120769806.bak
File Name: /opt/bak/ctl_c-1440834294-20221114-0b.bak
File Name: /opt/bak/arch_108_20221114.bak

RMAN> 
```

## 7. 转储数据库⽂件恢复并基于时间点恢复

```sql

RMAN> restore database;
RMAN> recover database until time "to_date('2022-10-27 00:10:00','yyyy-mm-dd hh24:mi:ss')"; --基于时间点恢复

RMAN> recover database;
--在进行recover database的过程中由于缺少日志执行进行不完全恢复，只能基于时间点进行恢复
RMAN> recover database until scn 20152861;

--以resetlogs方式打开数据库
RMAN> alter database open resetlogs;
```


## 8. 验证数据库是否恢复完毕

```sql
[oracle@fmsrvdb ~]$ sqlplus / as sysdba

SQL> select name,open_mode from v$database;

NAME      OPEN_MODE
--------- --------------------
FMSDB     READ WRITE

SQL> 
```


## 总结

```sql
RMAN> startup nomount
RMAN> restore spfile from '/opt/bak/ctl_c-1440834294-20221114-0b.bak';
RMAN> sql "create pfile=''/tmp/pfile.bak'' from spfile";

-- 如果有pfile文件，则可以直接跳到这里：
SQL> startup nomount pfile='/tmp/pfile.bak' force;
SQL> create spfile from pfile='/tmp/pfile.bak';

RMAN> restore controlfile from '/opt/bak/ctl_c-1440834294-20221114-0b.bak';
RMAN> alter database mount;
RMAN> catalog start with '/opt/bak/';
RMAN> restore database;
RMAN> recover database;
--在进行recover database的过程中由于缺少日志执行进行不完全恢复，只能基于时间点进行恢复
RMAN> recover database until scn 20152861;

--以resetlogs方式打开数据库
RMAN> alter database open resetlogs;
```
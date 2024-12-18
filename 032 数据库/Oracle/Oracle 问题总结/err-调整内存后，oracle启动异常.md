# err-调整内存后，oracle启动异常

　　ORA-00845: MEMORY\_TARGET not supported on this system

```bash
[oracle@oracle ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Oct 21 11:54:54 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup
ORA-27104: system-defined limits for shared memory was misconfigured
SQL>
```

　　原因：原机器8G内存，正常关机后由8G减少到4G，开机后数据库无法startup

　　原配为 自动共享内存管理

　　解决如下：

```bash
# 1.备份现有spfile
[oracle@oracle dbs]$ find /data/ -name "*init.ora*"
/data/u01/app/oracle/product/19.3.0/db_1/dbs/init.ora
/data/u01/app/oracle/product/19.3.0/db_1/srvm/admin/init.ora
/data/u01/app/oracle/admin/orcl/pfile/init.ora.9212024111825
[oracle@oracle dbs]$ cd /data/u01/app/oracle/admin/orcl/pfile/
[oracle@oracle pfile]$ ll
总用量 4
-rw-r----- 1 oracle oinstall 2046 10月 21 11:05 init.ora.9212024111825
[oracle@oracle pfile]$
[oracle@oracle pfile]$ cp init.ora.9212024111825 init.ora.9212024111825.bak


# 2.使用spfile创建pfile（spfile为二进制文本，不可直接修改），修改pfile后，重新生成spfile
[oracle@oracle pfile]$ sqlplus / as sysdba

SQL> create pfile='/tmp/pfile.bak' from spfile;
File created.
SQL> 

#3. 修改pfile参数*.memory_target=104857600(此处的值小于 操作系统的空闲内存，小于/dev/shm的大小)
vim /tmp/pfile.bak
-----------------------------------
*.pga_aggregate_target=1024m
*.sga_target=2048m

# 4. 启动
SQL> create spfile from pfile='/tmp/pfile.bak';
File created.

SQL> startup;
ORACLE instance started.

Total System Global Area 2147481656 bytes
Fixed Size		    8898616 bytes
Variable Size		  486539264 bytes
Database Buffers	 1644167168 bytes
Redo Buffers		    7876608 bytes
Database mounted.
Database opened.
SQL>
```

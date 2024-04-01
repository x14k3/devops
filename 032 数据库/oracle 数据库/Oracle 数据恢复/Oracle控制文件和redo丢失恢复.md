# Oracle控制文件和redo丢失恢复

**0.**  **ENV**

Centos7.9/ Oracle 19.0.0.0 单机文件系统

当数据库无备份时，模拟删除控制文件和redo log，对数据库进行不完全恢复。

‍

## **1.**  **手动备份控制文件**

```sql
SYS@rundba> alter database backup controlfile to trace as '/home/oracle/ctl_bak.sql';
```

## **2.**  **模拟文件丢失**

### **1) 关闭数据库**

```sql
SYS@rundba> shut immediate;
```

### **2) 删除所有控制文件和redo**

```sql
[oracle@db ~]$ cd oradata/rundba
[oracle@db rundba]$ rm -f control0\*.ctl redo0\*.log
```

### **3) 启动报错**

```sql
SYS@rundba> startup
ORACLE instance started.
Total System Global Area  780140544 bytes
Fixed Size         8625560 bytes
Variable Size      650117736 bytes
Database Buffers   113246208 bytes
Redo Buffers       8151040 bytes

ORA-00205: error in identifying control file, check alert log for more info
```

## **3.**  **不完全恢复数据库**

### **1) 重建控制文件**

摘取ctl\_bak.sql中的resetlogs语句进行控制文件重建，redo丢失，重建参数文件加resetlogs选项

```sql
--STARTUP NOMOUNT;
CREATE CONTROLFILE REUSE DATABASE "RUNDBA" RESETLOGS  ARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 '/oradata/rundba/redo01.log'  SIZE 200M BLOCKSIZE 512,
  GROUP 2 '/oradata/rundba/redo02.log'  SIZE 200M BLOCKSIZE 512,
  GROUP 3 '/oradata/rundba/redo03.log'  SIZE 200M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/oradata/rundba/system01.dbf',
  '/oradata/rundba/dsi01.dbf',
  '/oradata/rundba/sysaux01.dbf',
  '/oradata/rundba/undotbs01.dbf',
  '/oradata/rundba/rundba01.dbf',
  '/oradata/rundba/users01.dbf'
CHARACTER SET AL32UTF8
;
```

### **2) 恢复数据库[ctl_bak.ctl]**

```sql
SYS@rundba> RECOVER DATABASE USING BACKUP CONTROLFILE UNTIL CANCEL;
ORA-00279: change 1648791 generated at 03/30/2021 22:01:55 needed for thread 1
ORA-00289: suggestion : arch/rundba/1_2_1068396297.arch
ORA-00280: change 1648791 for thread 1 is in sequence #2
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}
cancel #cancel
Media recovery cancelled.
```

### **3) 打开数据库[ctl_bak.ctl]**

```sql
SYS@rundba> ALTER DATABASE OPEN RESETLOGS;
Database altered.
```

### **4) 重建临时文件[ctl_bak.ctl]**

```sql
ALTER TABLESPACE TEMP ADD TEMPFILE '/oradata/rundba/temp01.dbf' SIZE 33554432  REUSE AUTOEXTEND OFF;
```

### **5) 对恢复后的数据库进行备份**

(略)

‍

## **4.**  **结论**

当数据库无备份时，同时意外删除控制文件和redo log，使用重建控制文件对数据库进行不完全恢复，保障数据最小化丢失，不失为一种解决方法。

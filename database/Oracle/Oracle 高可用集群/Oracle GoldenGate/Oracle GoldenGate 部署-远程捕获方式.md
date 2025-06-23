#oracle

## 一、 概要信息

### 1.1 文档简介

Oracle GoldenGate 是一个全面的软件包，用于在异构数据环境中复制数据。该产品集支持高可用性解决方案、实时数据集成、事务性变更数据捕获、数据复制、转换以及运营和分析企业系统之间的验证。

Oracle GoldenGata 19C 远程部署方式（单台 、非侵入式 ），最佳抽取

参考文档：[OGG 19C 远程部署（单独部署）安装配置详细过程.pdf](assets/OGG%2019C%20远程部署（单独部署）安装配置详细过程-20250109160006-fz2ooaz.pdf)

### 1.2 安装环境

||源数据库|目标数据库|OGG主机|
| --------------| -----------------------------| -----------------------------| ----------------|
|操作系统版本|CentOS7.9.2009|CentOS7.9.2009|CentOS7.9.2009|
|数据库版本|Linux.X64_19300_db_home.zip|Linux.X64_19300_db_home.zip|OGG-19.1.0.0|
|主机名|test_01|test_02|test_03|
|IP地址|192.168.3.201|192.168.3.202|192.168.3.203|

‍

源端数据库和目标数据库参照：[Oracle19c](../../Oracle%20安装部署/静默安装%20Oracle19c.md) 进行单机安装

下载Oracle GoldenGate ：[https://edelivery.oracle.com/](https://edelivery.oracle.com/)

下载 instantclient-basic-linux.x64：[https://www.oracle.com/hk/database/technologies/instant-client/linux-x86-64-downloads.html](https://www.oracle.com/hk/database/technologies/instant-client/linux-x86-64-downloads.html)

## 二、数据库配置

### 2.1 源端开启归档

```sql
SQL> alter database archivelog;
```

ps:源端数据库没有开归档要开启归档,已经打开可以忽略 。

### 2.2 源端开启强制日志

```sql
SQL> alter database force logging;

Database altered.
```

### 2.3 源端开启数据库最小附加日志

```sql
SQL> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

Database altered.

SQL> SELECT supplemental_log_data_min, force_logging FROM v$database;

SUPPLEME FORCE_LOGGING
-------- ---------------------------------------
YES      YES

SQL> 
```

### 2.4 源和目标端打开复制参数

```sql
--源和目标执行
SQL> alter system set enable_goldengate_replication=true;
```

note: 11.2.0.4以上需要配置

‍

### 2.5 源和目标端创建 OGG 用户

```sql
---表 空 间
create tablespace ggtbs datafile '+DATA' size 1g autoextend on;--create tablespace GGTBS;
---用 户
create user ggadmin identified by ggadmin default tablespace ggtbs quota unlimited on ggtbs;
---授 权
grant connect,resource to ggadmin;
grant alter session to ggadmin;
grant select any dictionary to ggadmin;
grant select any transaction to ggadmin;
grant select any table to ggadmin;
grant flashback any table to ggadmin;
grant alter any table to ggadmin;
exec dbms_goldengate_auth.grant_admin_privilege('GGADMIN','*',TRUE)
```

note: 除了必要权限 , 其他权限可以根据实际情况而定 。

‍

目标端的OGG 用户 , 还需要下列 权 限 :

```sql
grant create session to ggadmin;
grant resource to ggadmin;
grant execute any type to ggadmin;
grant create any table,create any sequence to ggadmin ;
grant insert any table to ggadmin;
grant update any table to ggadmin;
grant delete any table to ggadmin;
grant create any index to ggadmin;
grant unlimited tablespace to ggadmin ;
grant execute on dbms_flashback to ggadmin;
grant comment any table to ggadmin;
```

‍

## 三、 OGG 软件安装

以下步骤都是在 OGG 单独部署机器上操作

### 3.1 创建用户和目录

```bash
--创建组和用户
groupadd oinstall
useradd -g oinstall oracle
passwd oracle

--创建目录
mkdir /ogg/oraclient -p
mkdir /ogg/ogg191
mkdir /ogg/oraInventory
chown oracle:oinstall -R /ogg
chmod 775 -R /ogg
```

### 3.2 配置环境变量

```bash
su - oracle
vim /home/oracle/.bash_profile
#--------------------------------------
export ORACLE_HOME=/ogg/oraclient/instantclient_19_25
export GG_HOME=/ogg/ogg191
export LD_LIBRARY_PATH=$ORACLE_HOME:$GG_HOME
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=$ORACLE_HOME:$GG_HOME:$PATH
alias ggsci='cd $GG_HOME; ggsci'
#---------------------------------------
source /home/oracle/.bash_profile
```

‍

### 3.3 Oracle客户端静默安装

最基础客户端包即可,主要是ggsci命令需要他里面的依赖库

```bash
unzip -d /ogg/oraclient instantclient-basic-linux.x64-11.2.0.4.0
```

‍

‍

### 3.4 OGG 静默安装

解压

```bash
su - oracle
unzip 191004_fbo_ggs_Linux_x64_shiphome.zip
cd fbo_ggs_Linux_x64_shiphome/Disk1/
```

编辑响应文件

​`vi /home/oracle/fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore.rsp`​

```bash
INSTALL_OPTION=ORA19c
SOFTWARE_LOCATION=/ogg/ogg191
START_MANAGER=
MANAGER_PORT=
DATABASE_LOCATION=
INVENTORY_LOCATION=/ogg/oraInventory
UNIX_GROUP_NAME=oinstall
```

静默安装

```bash
[oracle@test Disk1]$ ./runInstaller -silent -showProgress -responseFile /home/oracle/fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore.rsp
Starting Oracle Universal Installer...

Checking Temp space: must be greater than 120 MB.   Actual 34387 MB    Passed
Checking swap space: must be greater than 150 MB.   Actual 6143 MB    Passed
Preparing to launch Oracle Universal Installer from /tmp/OraInstall2025-01-08_05-57-44PM. Please wait ...[oracle@test Disk1]$ You can find the log of this install session at:
 /ogg/oraInventory/logs/installActions2025-01-08_05-57-44PM.log

Prepare in progress.
..................................................   10% Done.

Prepare successful.

Copy files in progress.
..................................................   36% Done.
..................................................   54% Done.
..................................................   77% Done.
..................................................   82% Done.
..................................................   88% Done.
....................
Copy files successful.

Link binaries in progress.
..........
Link binaries successful.

Setup files in progress.
..................................................   93% Done.
..................................................   95% Done.
..................................................   96% Done.
..................................................   98% Done.
..................................................   99% Done.

Setup files successful.

Setup Inventory in progress.

Setup Inventory successful.
..................................................   95% Done.
..................................................   100% Done.

Finish Setup successful.
The installation of Oracle GoldenGate Core was successful.
Please check '/ogg/oraInventory/logs/silentInstall2025-01-08_05-57-44PM.log' for more details.

As a root user, execute the following script(s):
        1. /ogg/oraInventory/orainstRoot.sh

Successfully Setup Software.
```

以root用户执行以下脚本

```bash
[root@test ~]# cd /ogg/oraInventory/
[root@test oraInventory]# ll
总用量 8
drwxrwx--- 2 oracle oinstall   60 1月   8 17:58 ContentsXML
drwxrwx--- 2 oracle oinstall  185 1月   8 17:58 logs
-rw-rw---- 1 oracle oinstall   52 1月   8 17:58 oraInst.loc
-rwxrwx--- 1 oracle oinstall 1581 1月   8 17:58 orainstRoot.sh
drwxrwx--- 2 oracle oinstall   22 1月   8 17:57 oui
[root@test oraInventory]# ./orainstRoot.sh 
Changing permissions of /ogg/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /ogg/oraInventory to oinstall.
The execution of the script is complete.
[root@test oraInventory]# 
```

‍

‍

## 四、 OGG 配置

note: 以下配 置均为远程捕获和交付的方式 , 无需在数据库本地安装部署 。

### 4.1 配置 TNSNAMES

创建目录

```bash
su - oracle
mkdir -p /ogg/oraclient/instantclient_19_25/network/admin
```

配置 tnsnames.ora

```bash
cd /ogg/oraclient/instantclient_19_25/network/admin
vi tnsnames.ora
#-------------------------------------------------------------
source =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.3.201)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
      (SERVER = DEDICATED)
    )
  )


target =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.3.202)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
      (SERVER = DEDICATED)
    )
  )
```

### 4.2 创建 ogg 目录

```bash
#----登录 ogg交互工具
ggsci

#---创建目录
GGSCI (oggmc) 1> create subdirs
Creating subdirectories under current directory /ogg/ogg191

Parameter file                 /ogg/ogg191/dirprm: created.
Report file                    /ogg/ogg191/dirrpt: created.
Checkpoint file                /ogg/ogg191/dirchk: created.
Process status files           /ogg/ogg191/dirpcs: created.
SQL script files               /ogg/ogg191/dirsql: created.
Database definitions files     /ogg/ogg191/dirdef: created.
Extract data files             /ogg/ogg191/dirdat: created.
Temporary files                /ogg/ogg191/dirtmp: created.
Credential store files         /ogg/ogg191/dircrd: created.
Masterkey wallet files         /ogg/ogg191/dirwlt: created.
Dump files                     /ogg/ogg191/dirdmp: created.

# 执行命令 create subdirs 初始化 OGG 目录, 各目录作用如下
# 1、dirchk:存放由extract抽取进程和replicat复制进程创建的checkpoint(检查点)文件；
# 2、dirdat:存放extract进程创建的抽取文件，等待被复制；
# 3、dirdef:存放生成的源端或目标端数据定义文件；
# 4、dirrpt:进程报告文件，进程挂查断时，可以查看此文件，找出错误报告，也可在./ggsci下，用view report查看错误日志；
# 5、dirprm:存放配置参数的文件，修改参数时，可以直接修改本文件，也可以在./ggsci下，用edit param 修改；
# 6、dirtmp:临时文件目录，用于长事务处理；
```

‍

### 4.3 配置 MGR 进程

编辑参数

```sql
GGSCI (oggmc) 2> edit param mgr

PORT 7809
DYNAMICPORTLIST 7810-7899
ACCESSRULE,PROG *,IPADDR 192.168.*.*,ALLOW
AUTORESTART ER *,RETRIES 5,WAITMINUTES 3
PURGEOLDEXTRACTS ./dirdat/*,usecheckpoints, minkeepdays 7
LAGREPORTHOURS 1
LAGINFOMINUTES 30
LAGCRITICALMINUTES 45
```

校验mgr 参数

```bash
[oracle@test ogg191]$ ./checkprm /ogg/ogg191/dirprm/mgr.prm -C mgr -V

Parameter file validation context:

component(s): MGR
mode(s)     : N/A
platform(s) : Linux
database(s) : Oracle 19c


/ogg/ogg191/dirprm/mgr.prm

port                                 : 7809
dynamicportlist                      : 7810-7899
accessrule                           : <enabled>
  prog                               : *
  ipaddr                             : 192.168.*.*
  allow                              : <enabled>
autorestart                          : <enabled>
  er                                 : *
  retries                            : 5
  waitminutes                        : 3
purgeoldextracts                     : ./dirdat/*
  usecheckpoints                     : <enabled>
  minkeepdays                        : 7
lagreporthours                       : 1
laginfominutes                       : 30
lagcriticalminutes                   : 45


2025-01-09 11:38:49  INFO    OGG-10183  Parameter file /ogg/ogg191/dirprm/mgr.prm:  Validity check: PASS.

Runtime parameter validation is not reflected in the above check.

```

启动

```bash
[oracle@test ogg191]$ ./ggsci 

Oracle GoldenGate Command Interpreter for Oracle
Version 19.1.0.0.4 OGGCORE_19.1.0.0.0_PLATFORMS_191017.1054_FBO
Linux, x64, 64bit (optimized), Oracle 19c on Oct 17 2019 21:16:29
Operating system character set identified as UTF-8.

Copyright (C) 1995, 2019, Oracle and/or its affiliates. All rights reserved.

GGSCI (test) 1> start mgr
Manager started.

GGSCI (test) 2> info all
Program     Status      Group       Lag at Chkpt  Time Since Chkpt
MANAGER     RUNNING                                       

GGSCI (test) 3> 
```

‍

‍

### 4.4 配置用户凭证

配置

```sql
GGSCI (test) 3> add credentialstore

Credential store created.

GGSCI (test) 4> alter credentialstore add user ggadmin@source, password ggadmin alias sdb

Credential store altered.
GGSCI (test) 5> alter credentialstore add user ggadmin@target, password ggadmin alias tdb

Credential store altered.
```

验证

```bash
GGSCI (test) 6> info credentialstore

Reading from credential store:

Default domain: OracleGoldenGate

  Alias: sdb
  Userid: ggadmin@source

  Alias: tdb
  Userid: ggadmin@target

GGSCI (test) 7> 
```

‍

### 4.5 配置 extract 进程

#### 4.5.1 经典模式(可选)

添加附加日志

```sql
--在配置OGG时，需要给同步的表添加补充日志，在ggsci命令行执行 [add trandata user.table]
--注意，要确保该用户user下存在表，否则会报错
GGSCI (test) 8> dblogin useridalias sdb
Successfully logged into database.

GGSCI (test as ggadmin@orcl) 9> add trandata jy2web.*  

2025-01-09 14:56:05  INFO    OGG-15132  Logging of supplemental redo data enabled for table JY2WEB.T_COUSE.

2025-01-09 14:56:05  INFO    OGG-15133  TRANDATA for scheduling columns has been added on table JY2WEB.T_COUSE.

2025-01-09 14:56:05  INFO    OGG-15135  TRANDATA for instantiation CSN has been added on table JY2WEB.T_COUSE.

2025-01-09 14:56:05  INFO    OGG-10471  ***** Oracle Goldengate support information on table JY2WEB.T_COUSE ***** 
Oracle Goldengate support native capture on table JY2WEB.T_COUSE.
Oracle Goldengate marked following column as key columns on table JY2WEB.T_COUSE: COUSEID.
```

配置参数

```bash
GGSCI (test as ggadmin@orcl) 10> edit param extcsa

EXTRACT extcsa
SETENV (NLS_LANG=AMERICAN_AMERICA.ZHS16GBK)
USERIDALIAS sdb
TRANLOGOPTIONS dblogreader
LOGALLSUPCOLS
GETTRUNCATES
EXTTRAIL ./dirdat/wl
DISCARDFILE ./dirrpt/extcsa.dsc, APPEND, MEGABYTES 1024
WARNLONGTRANS 1H, CHECKINTERVAL 5M
CACHEMGR CACHESIZE 1024MB, CACHEDIRECTORY ./dirtmp
REPORTCOUNT EVERY 60 SECONDS, RATE
table jy2web.t_couse;
```

Note:dblogreader 最低支持版本为11.2.0.4,通过数据字典的方式获取日志信息 , 需要 select any transaction 权限

‍

校验extract参数

```sql
[oracle@test ogg191]$ ./checkprm /ogg/ogg191/dirprm/extcsa.prm -C extract -V

2025-01-09 15:07:43  INFO    OGG-02095  Successfully set environment variable NLS_LANG=AMERICAN_AMERICA.ZHS16GBK.

Parameter file validation context:

component(s): EXTRACT
mode(s)     : N/A
platform(s) : Linux
database(s) : Oracle 19c


/ogg/ogg191/dirprm/extcsa.prm

extract                              : extcsa
setenv                               : (NLS_LANG=AMERICAN_AMERICA.ZHS16GBK)
useridalias                          : sdb
tranlogoptions                       : <enabled>
  dblogreader                        : <enabled>
logallsupcols                        : <enabled>
gettruncates                         : <enabled>
exttrail                             : ./dirdat/wl
discardfile                          : ./dirrpt/extcsa.dsc
  append                             : <enabled>
  megabytes                          : 1024
warnlongtrans                        : 1 hour(s)
  checkinterval                      : 5 minute(s)
cachemgr                             : <enabled>
  cachesize                          : 1024 mb
  cachedirectory                     : ./dirtmp
reportcount                          : <enabled>
  every                              : 60 second(s)
  rate                               : <enabled>
table                                : jy2web.t_couse


2025-01-09 15:07:43  INFO    OGG-10183  Parameter file /ogg/ogg191/dirprm/extcsa.prm:  Validity check: PASS.

Runtime parameter validation is not reflected in the above check.
```

添加进程

```bash
GGSCI (test) 1> add extract extcsa, tranlog, begin now,threads 1    --节点数
EXTRACT added.

GGSCI (test) 2> add exttrail ./dirdat/wl, extract extcsa, MEGABYTES 1024
EXTTRAIL added.
```

启动

```bash
---启动
GGSCI (oggmc) 7> start extcsa
Sending START request to MANAGER ...
EXTRACT EXTCSA starting

---查看
GGSCI (oggmc) 8> info all
Program Status Group Lag at Chkpt Time Since Chkpt
MANAGER RUNNING
EXTRACT RUNNING EXTCSA 00:00:00 00:00:25
```

‍

‍

#### 4.5.2 集成模式(可选)

note: 推  成模式,性能更好,原理是整合 logminer, 多租户环境只能用集成模式

数据库 stream 参数调整 , 一个进程建议1.25g

```bash
alter system set streams_pool_size=10g;
```

添加附加日志

```sql
GGSCI (test) 8> dblogin useridalias sdb
GGSCI (test) 8> add trandata jy2web.*
```

添加进程

```bash
GGSCI (test) 8> ADD EXTRACT ie_e INTEGRATED TRANLOG BEGIN NOW
GGSCI (test) 8> ADD EXTTRAIL ./dirdat/ie EXTRACT ie_e MEGABYTES 1024
```

注册进程

```sql
GGSCI (test) 8> dblogin useridalias sdb
GGSCI (test) 8> REGISTER EXTRACT ie_e DATABASE
```

编辑参数

```sql
GGSCI (test) 8> edit param ie_e

EXTRACT ie_e
USERIDALIAS sdb
LOGALLSUPCOLS
NOCOMPRESSUPDATES
UPDATERECORDFORMAT FULL
DBOPTIONS ALLOWUNUSEDCOLUMN
FETCHOPTIONS NOUSESNAPSHOT
GETTRUNCATES
EXTTRAIL ./dirdat/ie
DISCARDFILE ./dirrpt/ie_e.dsc, PURGE, MEGABYTES 1024
WARNLONGTRANS 1H, CHECKINTERVAL 5M
CACHEMGR CACHESIZE 1024MB, CACHEDIRECTORY ./dirtmp
REPORTCOUNT EVERY 60 SECONDS, RATE
table jy2web.t_couse;
```

Note : 因为通过 logminer 挖掘日志 , 日志参数无需指定 , 可以利用参数配置 logminer 的并发数和内存大小

启动

```sql
GGSCI (test) 8> start ie_e
--查看
GGSCI (test) 8> info all
```

‍

### 4.6 配置 pump 进程

如果OGG 的 replicat 进程和抽取进程都在同一台 ,可以不需要配置这个pump进程

编 辑 参 数

```sql
GGSCI (test) 8> edit param dpecs

EXTRACT dpecs
DISCARDFILE ./dirrpt/dpecs.dsc, APPEND, MEGABYTES 1024
RMTHOST 192.168.3.132, MGRPORT 7809
RMTTRAIL /ogg/ogg191/dirdat/rt
PASSTHRU
table jy2web.t_couse;
```

添加进程

```bash
GGSCI (test) 8> add extract dpecs EXTTRAILSOURCE ./dirdat/wl
GGSCI (test) 8> add rmttrail /ogg/ogg191/dirdat/rt extract dpecs MEGABYTES 1024
```

启动

```bash
GGSCI (test) 8> start dpecs
--查看
GGSCI (test) 8> info all
```

### 4.7 配置 replicat 进程

添加数据库检查点表

```sql
GGSCI (oggmc) 1> dblogin useridalias tdb
Successfully logged into database.
GGSCI (oggmc as ggadmin@ora19c) 2> add checkpointtable ggadmin.check
point
Successfully created checkpoint table ggadmin.checkpoint.
```

编辑参数

```sql
GGSCI (oggmc) 1> edit param repcs

REPLICAT repcs
USERIDALIAS tdb
--REPERROR (DEFAULT, ABEND)
DISCARDFILE ./dirrpt/repcs.dsc, PURGE, MEGABYTES 1024
GETTRUNCATES
ALLOWNOOPUPDATES
REPORTCOUNT EVERY 60 SECONDS, RATE
DBOPTIONS ENABLE_INSTANTIATION_FILTERING
DBOPTIONS SUPPRESSTRIGGERS
MAP jy2web.t_couse, TARGET jy2web.t_couse;

```

添加进程

```bash
GGSCI (oggmc) 1> ADD REPLICAT repcs EXTTRAIL /ogg/ogg191/dirdat/wl checkpointtable gg
GGSCI (oggmc) 1> admin.checkpoint
```

查看

```bash
GGSCI (oggmc as ggadmin@ora11g) 5> info all

Program Status Group Lag at Chkpt Time Since Chkpt
MANAGER RUNNING
EXTRACT RUNNING EXTCSA 00:00:01 00:00:07
REPLICAT STOPPED REPCS 00:00:00 00:00:05

```

‍

## 五、OGG 同步设置

### 5.1 数据导出导入

源库创建数据泵目录

```sql

$ sqlplus / as sysdba
SQL> create or replace directory expogg as '/backup/expdir';
SQL> grant read,write on directory expogg to public;
col owner for a15
col directory_name for a15
col directory_path for a25
select * from dba_directories where directory_name='EXPOGG';
OWNER DIRECTORY_NAME DIRECTORY_PATH
--------------- --------------- -------------------------
SYS EXPOGG /backup/expdir
```

源库获取数据库当前 SCN

```sql
--查看数据中的交易
select s.sid,t.start_time,osuser o, username u,sa.sql_text
from v$session s, v$transaction t, dba_rollback_segs r, v$sqlarea sa
where s.taddr=t.addr and t.xidusn=r.segment_id(+)
and s.sql_address=sa.address(+);

--在使用 DATAPUMP 工具导出前,需要在生产库确保 GoldenGate 抽取进程启动的时间点前的事务已经结束。确认长事务情况,可通过下述命令实现:
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
col event for a30
col OSUSER for a10
col USERNAME for a10
col PROGRAM for a35
SELECT s.sid,s.serial#,s.status,s.username,t.start_time,s.WAIT_TIME, s.osuser, s.sql_id, s.program,START_DATE FROM gv$session s,gv$transaction t WHERE s.INST_ID=t.INST_ID and s.saddr=t.ses_addr order by t.start_time desc;
--确保数据库中事物启动时间晚于 capture 进程启动时间
select start_time from gv$transaction where to_date(start_time, 'yyyy-mm-dd hh24:mi:ss')<to_date('抽取进程启动时间', 'yyyy-mm-dd hh24:mi:ss');

--确认没有事务后(返回无记录),立即查找 scn:
SQL>col GET_SYSTEM_CHANGE_NUMBER for 999999999999999
SQL>select dbms_flashback.get_system_change_number from dual;
GET_SYSTEM_CHANGE_NUMBER
------------------------
123231017915
```

源库基于 SCN 号导出数据

```sql
--如果不需要 procedure,trigger,ref_constraint,job,statistics,package 这些可以
进行排除
expdp \"/ as sysdba\" directory=expogg dumpfile=spa%U.dmp parallel=4
filesize=10G flashback_scn=123231017915 logfile=expspa.log tables=wyy.lab_channel,wyy.qrtz_cron_triggers,wyy.qrtz_fired_triggers,wyy.qr
tz_scheduler_state,wyy.qrtz_triggers,wyy.lab_bank_record job_name=expspa exclude=procedure,trigger,ref_constraint,job,statistics,package
--在本地通过 dblink 去导出远程数据库
--本地库创建连接远程的 dblink
create public database link expnt connect to sysch identified by zhirongsu using
'bocpay';
select count(*) from dual@expnt;
COUNT(*)
----------
1
1 row selected.
$ expdp \"/ as sysdba\" directory=expogg dumpfile=bocpay%U.dmp job_name=expboc
logfile=expboc.log network_link=expnt tables=wyy.lab_channel,wyy.qrtz_cron_triggers,wyy.qrtz_fired_triggers,wyy.qr
tz_scheduler_state,wyy.qrtz_triggers,wyy.lab_bank_record compression=all
parallel=4 exclude=statistics,TRIGGER,REF_CONSTRAINT,QUEUE,package,procedure
```

### 5.2 目标库创建数据泵目录

```sql
SQL> create or replace directory impogg as '/backup/expdir ';
SQL> grant read,write on directory impogg to public;
col owner for a15
col directory_name for a15
col directory_path for a25
select * from dba_directories where directory_name='IMPOGG';
```

### 5.3 目标库导入数据

```sql
----一定要注意加 remap_schema,指定要导入的 schemas
impdp \"/ as sysdba\" directory=impogg dumpfile=bocpay%U.dmp logfile=impogg.log parallel=4 job_name=impogg cluster=N
```

### 5.4 收集统计信息

```sql

[oracle@racdb1 backup]$ cat tjxjogg.sh
#!/bin/sh
export ORACLE_SID=ora11g
export ORACLE_BASE=/u01/app/oracle/
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF > /backup/tjxjogg.log
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;
begin
dbms_stats.gather_schema_stats(ownname=> '"WYY"' ,
cascade=> TRUE,
estimate_percent=> null,
degree=> 4,
no_invalidate=> DBMS_STATS.AUTO_INVALIDATE,
granularity=> 'AUTO',
method_opt=> 'FOR ALL COLUMNS SIZE AUTO',
options=> 'GATHER');
end;
/
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;
exit;
EOF
```

目标库匹配导入导出数据行数

```bash
[oracle@ expdp]$ grep " rows" expogg0908.log |sort -n| awk '{print $4,$7,$8}'|awk -F "." '{print $2}'> /tmp/exp.a
[oracle@expdp]$ grep " rows" impogg0908.log |sort -n| awk '{print $4,$7,$8}'|awk -F "." '{print $2}'> /tmp/imp.b
[oracle@racdb1 expdp]$ diff /tmp/exp.a /tmp/imp.b
#此时没有结果输出说明导入导出数据行数一致
```

禁用目标库约束

```bash
#参数 owner_list 里面的用户名请根据实际情况修改
#禁用约束脚本如下:
racdb1:/home/oracle/ogg$cat disable_cascade.sql
set serveroutput on size 1000000
spool /home/oracle/disable_cascade.log
define owner_list=" in ('WYY','OGGWMS') "
declare 
  cursor c is SELECT A.OWNER, A.TABLE_NAME,A.CONSTRAINT_NAME, C.COLUMN_NAME,
A.STATUS,A.DELETE_RULE,B.TABLE_NAME REFER_TABLE
FROM dba_CONSTRAINTS A,dba_CONSTRAINTS B,dba_CONS_COLUMNS C
WHERE A.R_CONSTRAINT_NAME=B.CONSTRAINT_NAME
AND A.CONSTRAINT_NAME=C.CONSTRAINT_NAME
AND A.status ='ENABLED'
AND A.delete_rule like '%CASCADE%'
and A.owner &owner_list;
temp varchar2(512);
begin
  dbms_output.put_line('-- BEGIN ALTER TABLE DISABBLE CASCADE --');
  dbms_output.put_line('-- WAIT FOR A MONENT --');
  dbms_output.put_line('--...................--');
for x in c loop
  temp := 'ALTER TABLE "' || x.OWNER || '"."' || x.TABLE_NAME || '" DISABLE
CONSTRAINT "'|| x.CONSTRAINT_NAME||'"';
  execute immediate temp;
  dbms_output.put_line('--DISABLE
 CONSTRAINT'||
x.OWNER||'.'||x.CONSTRAINT_NAME||' SUCCESSFUL--') ;
end loop;
  dbms_output.put_line('-- END ALTER TABLE DISABBLE CASCADE --');
end;
/
spool off
```

禁用目标库触发器

```bash
#参数 owner_list 里面的用户名请根据实际情况修改
#禁用触发器脚本如下:
racdb1:/home/oracle/ogg$cat disable_trigger.sql
set serveroutput on size 1000000
spool /home/oracle/disable_trigger.log
define owner_list=" in ('WYY','OGGWMS')"
declare
cursor c is SELECT OWNER,TRIGGER_NAME FROM dba_triggers WHERE status ='ENABLED'
and owner &owner_list;
temp varchar2(512);
begin
dbms_output.put_line('-- BEGIN DISABBLE TRIGGERS --');
dbms_output.put_line('-- WAIT FOR A MONENT --');
dbms_output.put_line('--...................--');
for x in c loop
temp := 'ALTER TRIGGER "'||x.OWNER||'"."'||x.TRIGGER_NAME||'" DISABLE';
execute immediate temp;
dbms_output.put_line('--DISABLE
TRIGGER'||x.OWNER||'.'||x.TRIGGER_NAME||' SUCCESSFUL--') ;
end loop;
dbms_output.put_line('-- END ALTER TABLE DISABBLE TRIGGERS --');
end;
/
spool off
```

禁用 job

```sql
conn oggspa/spaora
spool disable_job.sql
set pagesize 999;
select 'execute DBMS_IJOB.BROKEN('||job||',TRUE); commit;'
from dba_jobs where BROKEN='N';
spool off
'EXECUTEDBMS_SCHEDULER.STOP_JOB('||JOB_NAME||');COMMIT;'
------------------------------------------------------------------------
execute DBMS_SCHEDULER.stop_job(QUEST_PPCM_JOB_PM_1); commit;
execute DBMS_SCHEDULER.stop_job(JOB_PLANDT_AUTOADD); commit;



--关闭 job
set echo off
set verify off
set feedback off
set pagesize 10000
set heading off
set lines 100
spool disable_job.sql
set pagesize 999;
set linesize 200;
set heading off;
select 'execute DBMS_IJOB.BROKEN('||job||',TRUE); commit;'
from dba_jobs where BROKEN='N';
spool off

--关闭触发器
spool disable_triggers.sql
select 'alter trigger '||owner||'.'||trigger_name||' disable;'
from dba_triggers where owner in ('WYY') and status='ENABLED'
order by status,owner;
spool off

--禁用约束
spool disable_constraints1.sql
select
 'alter
 table
 '||owner||'.'||table_name||'
 disable
 constraint
'||constraint_name||';'
from dba_constraints
where constraint_type in ('R') and owner='WYY'
order by status,owner;
spool off
```

## 5.5 开启同步

```sql
GGSCI (racdb1) 16>start repcs,aftercsn 123231017915
Sending START request to MANAGER ...
REPLICAT RPEE starting
```

‍

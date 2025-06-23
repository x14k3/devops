#oracle

## exp/imp与expdp/impdp的区别

- ​exp和imp是客户端工具程序，它们既可以在客户端使用，也可以在服务端使用。
- EXPDP和IMPDP是服务端的工具程序,他们只能在ORACLE服务端使用,不能在客户端使用。
- IMP只适用于EXP导出文件,不适用于EXPDP导出文件;IMPDP只适用于EXPDP导出文件,而不适用于EXP导出文件。
- EXPDP/IMPDP 在备份和恢复时间上要比EXP/IMP有着优势.并且EXPDP/IMPDP 管理灵活。
- 对于10g以上的服务器，使用exp通常不能导出0行数据的空表，而此时必须使用expdp导出。

‍

## expdp/impdp

```bash
# 登录数据库
sqlplus sys/ as sysdba
# 查看逻辑目录
select DIRECTORY_NAME,DIRECTORY_PATH from dba_directories; 
#默认/data/app/oracle/admin/SID/dpdump/

## 创建逻辑目录
## create directory data_dir as '/u01/app/oracle/admin/orcl/dpdump/jy2';

## 授权读写逻辑目录
## grant read,write on directory DATA_PUMP_DIR to jy2web;

#################### 导出 #################
# 导出整个数据库(所有数据库)，执行用户需要dba权限
expdp system/passwd DIRECTORY=data_pump_dir DUMPFILE=expdp.dmpdp full=y           			   logfile=expdp.log
# 按表空间导出
expdp user/passwd   DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp tablespaces=user 			   logfile=expdp.log
# 按模式(用户)导出   
expdp user/passwd   DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp schemas=user    			   logfile=expdp.log
# 按表名导出
expdp user/passwd   DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp tables=tableName1,tableName2  logfile=expdp.log
# 导出视图（oracle11g）
expdp user/passwd   DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp include=view:"in('xxx')"      logfile=expdp.log
# 导出视图（oracle12c以上）
expdp user/passwd   DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp views_as_tables=xxxx          logfile=expdp.log

#################### 导入 #################
#导入到原先用户(与导出的用户名相同)
impdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp schemas=user logfile=user.log;
#导入到其他用户(与导出的用户名不同)
impdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp remap_schema=user1:user2 remap_tablespace=user1:user2;

* remap_schema      # 当你从A用户导出的数据，想要导入到B用户中去，就使用这个：remap_schema=A:B
* remap_tablespace  # 转移对象到其他表空间 ，将所有tbs_a中的对象都会建在tbs_b表空间中。
* version=11.2      # 当从高版本导出，并导入到低版本数据库时，需要在导出时指定version=低版本号
* TRANSFORM=segment_attributes:n # 去掉存储和表空间相关参数（参数会导致remap_tablespace参数失效）impdp报ORA-39112
* transform=oid:n   # Imp的时候，新创建的表或者type会赋予同样的OID，如果是位于同一个数据库上的不同schema，那就会造成OID冲突的问题
* table_exists_action 参数值有四种，解释如下：
1. skip       # 默认操作
2. replace    # 先drop表，然后创建表，最后插入数据
3. append     # 在原来数据的基础上增加数据
4. truncate   # 清空了表后导入数据
```

并行导出：使用一个以上的线程来显著地加速作业

```sql
expdp xxx/xxx directory=DATA_PUMP_DIR dumpfile=xxxx_%U.dmpdp parallel=3
impdp xxx/xxx directory=DATA_PUMP_DIR dumpfile=xxxx_01.dmpdp,xxxx_02.dmpdp,xxxx_03.dmpdp
```

### expdp参数

```bash
C:\Users\Alfred>expdp help=y

Export: Release 11.2.0.1.0 - Production on 星期五 10月 10 12:25:21 2014

Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.


数据泵导出实用程序提供了一种用于在 Oracle 数据库之间传输
数据对象的机制。该实用程序可以使用以下命令进行调用:

   示例: expdp scott/tiger DIRECTORY=dmpdir DUMPFILE=scott.dmp

您可以控制导出的运行方式。具体方法是: 在 'expdp' 命令后输入
各种参数。要指定各参数, 请使用关键字:

   格式:  expdp KEYWORD=value 或 KEYWORD=(value1,value2,...,valueN)
   示例: expdp scott/tiger DUMPFILE=scott.dmp DIRECTORY=dmpdir SCHEMAS=scott
               或 TABLES=(T1:P1,T1:P2), 如果 T1 是分区表

USERID 必须是命令行中的第一个参数。

------------------------------------------------------------------------------

以下是可用关键字和它们的说明。方括号中列出的是默认值。

ATTACH
连接到现有作业。
例如, ATTACH=job_name。

COMPRESSION
减少转储文件大小。
有效的关键字值为: ALL, DATA_ONLY, [METADATA_ONLY] 和 NONE。

CONTENT
指定要卸载的数据。
有效的关键字值为: [ALL], DATA_ONLY 和 METADATA_ONLY。

DATA_OPTIONS
数据层选项标记。
有效的关键字值为: XML_CLOBS。

DIRECTORY
用于转储文件和日志文件的目录对象。

DUMPFILE
指定目标转储文件名的列表 [expdat.dmp]。
例如, DUMPFILE=scott1.dmp, scott2.dmp, dmpdir:scott3.dmp。

ENCRYPTION
加密某个转储文件的一部分或全部。
有效的关键字值为: ALL, DATA_ONLY, ENCRYPTED_COLUMNS_ONLY, METADATA_ONLY 和 NONE
。

ENCRYPTION_ALGORITHM
指定加密的方式。
有效的关键字值为: [AES128], AES192 和 AES256。

ENCRYPTION_MODE
生成加密密钥的方法。
有效的关键字值为: DUAL, PASSWORD 和 [TRANSPARENT]。

ENCRYPTION_PASSWORD
用于在转储文件中创建加密数据的口令密钥。

ESTIMATE
计算作业估计值。
有效的关键字值为: [BLOCKS] 和 STATISTICS。

ESTIMATE_ONLY
计算作业估计值而不执行导出。

EXCLUDE
排除特定对象类型。
例如, EXCLUDE=SCHEMA:"='HR'"。

FILESIZE
以字节为单位指定每个转储文件的大小。

FLASHBACK_SCN
用于重置会话快照的 SCN。

FLASHBACK_TIME
用于查找最接近的相应 SCN 值的时间。

FULL
导出整个数据库 [N]。

HELP
显示帮助消息 [N]。

INCLUDE
包括特定对象类型。
例如, INCLUDE=TABLE_DATA。

JOB_NAME
要创建的导出作业的名称。

LOGFILE
指定日志文件名 [export.log]。

NETWORK_LINK
源系统的远程数据库链接的名称。

NOLOGFILE
不写入日志文件 [N]。

PARALLEL
更改当前作业的活动 worker 的数量。

PARFILE
指定参数文件名。

QUERY
用于导出表的子集的谓词子句。
例如, QUERY=employees:"WHERE department_id > 10"。

REMAP_DATA
指定数据转换函数。
例如, REMAP_DATA=EMP.EMPNO:REMAPPKG.EMPNO。

REUSE_DUMPFILES
覆盖目标转储文件 (如果文件存在) [N]。

SAMPLE
要导出的数据的百分比。

SCHEMAS
要导出的方案的列表 [登录方案]。

SOURCE_EDITION
用于提取元数据的版本。

STATUS
监视作业状态的频率, 其中
默认值 [0] 表示只要有新状态可用, 就立即显示新状态。

TABLES
标识要导出的表的列表。
例如, TABLES=HR.EMPLOYEES,SH.SALES:SALES_1995。

TABLESPACES
标识要导出的表空间的列表。

TRANSPORTABLE
指定是否可以使用可传输方法。
有效的关键字值为: ALWAYS 和 [NEVER]。

TRANSPORT_FULL_CHECK
验证所有表的存储段 [N]。

TRANSPORT_TABLESPACES
要从中卸载元数据的表空间的列表。

VERSION
要导出的对象版本。
有效的关键字值为: [COMPATIBLE], LATEST 或任何有效的数据库版本。

------------------------------------------------------------------------------

下列命令在交互模式下有效。
注: 允许使用缩写。

ADD_FILE
将转储文件添加到转储文件集。

CONTINUE_CLIENT
返回到事件记录模式。如果处于空闲状态, 将重新启动作业。

EXIT_CLIENT
退出客户机会话并使作业保持运行状态。

FILESIZE
用于后续 ADD_FILE 命令的默认文件大小 (字节)。

HELP
汇总交互命令。

KILL_JOB
分离并删除作业。

PARALLEL
更改当前作业的活动 worker 的数量。

REUSE_DUMPFILES
覆盖目标转储文件 (如果文件存在) [N]。

START_JOB
启动或恢复当前作业。
有效的关键字值为: SKIP_CURRENT。

STATUS
监视作业状态的频率, 其中
默认值 [0] 表示只要有新状态可用, 就立即显示新状态。

STOP_JOB
按顺序关闭作业执行并退出客户机。
有效的关键字值为: IMMEDIATE。
```

‍

### impdp参数

```bash
C:\Users\Alfred>impdp help=y

Import: Release 11.2.0.1.0 - Production on 星期五 10月 10 23:44:16 2014

Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.


数据泵导入实用程序提供了一种用于在 Oracle 数据库之间传输
数据对象的机制。该实用程序可以使用以下命令进行调用:

     示例: impdp scott/tiger DIRECTORY=dmpdir DUMPFILE=scott.dmp

您可以控制导入的运行方式。具体方法是: 在 'impdp' 命令后输入
各种参数。要指定各参数, 请使用关键字:

     格式:  impdp KEYWORD=value 或 KEYWORD=(value1,value2,...,valueN)
     示例: impdp scott/tiger DIRECTORY=dmpdir DUMPFILE=scott.dmp

USERID 必须是命令行中的第一个参数。

------------------------------------------------------------------------------

以下是可用关键字和它们的说明。方括号中列出的是默认值。

ATTACH
连接到现有作业。
例如, ATTACH=job_name。

CONTENT
指定要加载的数据。
有效的关键字为: [ALL], DATA_ONLY 和 METADATA_ONLY。

DATA_OPTIONS
数据层选项标记。
有效的关键字为: SKIP_CONSTRAINT_ERRORS。

DIRECTORY
用于转储文件, 日志文件和 SQL 文件的目录对象。

DUMPFILE
要从中导入的转储文件的列表 [expdat.dmp]。
例如, DUMPFILE=scott1.dmp, scott2.dmp, dmpdir:scott3.dmp。

ENCRYPTION_PASSWORD
用于访问转储文件中的加密数据的口令密钥。
对于网络导入作业无效。

ESTIMATE
计算作业估计值。
有效的关键字为: [BLOCKS] 和 STATISTICS。

EXCLUDE
排除特定对象类型。
例如, EXCLUDE=SCHEMA:"='HR'"。

FLASHBACK_SCN
用于重置会话快照的 SCN。

FLASHBACK_TIME
用于查找最接近的相应 SCN 值的时间。

FULL
导入源中的所有对象 [Y]。

HELP
显示帮助消息 [N]。

INCLUDE
包括特定对象类型。
例如, INCLUDE=TABLE_DATA。

JOB_NAME
要创建的导入作业的名称。

LOGFILE
日志文件名 [import.log]。

NETWORK_LINK
源系统的远程数据库链接的名称。

NOLOGFILE
不写入日志文件 [N]。

PARALLEL
更改当前作业的活动 worker 的数量。

PARFILE
指定参数文件。

PARTITION_OPTIONS
指定应如何转换分区。
有效的关键字为: DEPARTITION, MERGE 和 [NONE]。

QUERY
用于导入表的子集的谓词子句。
例如, QUERY=employees:"WHERE department_id > 10"。

REMAP_DATA
指定数据转换函数。
例如, REMAP_DATA=EMP.EMPNO:REMAPPKG.EMPNO。

REMAP_DATAFILE
在所有 DDL 语句中重新定义数据文件引用。

REMAP_SCHEMA
将一个方案中的对象加载到另一个方案。

REMAP_TABLE
将表名重新映射到另一个表。
例如, REMAP_TABLE=EMP.EMPNO:REMAPPKG.EMPNO。

REMAP_TABLESPACE
将表空间对象重新映射到另一个表空间。

REUSE_DATAFILES
如果表空间已存在, 则将其初始化 [N]。

SCHEMAS
要导入的方案的列表。

SKIP_UNUSABLE_INDEXES
跳过设置为“索引不可用”状态的索引。

SOURCE_EDITION
用于提取元数据的版本。

SQLFILE
将所有的 SQL DDL 写入指定的文件。

STATUS
监视作业状态的频率, 其中
默认值 [0] 表示只要有新状态可用, 就立即显示新状态。

STREAMS_CONFIGURATION
启用流元数据的加载

TABLE_EXISTS_ACTION
导入对象已存在时执行的操作。
有效的关键字为: APPEND, REPLACE, [SKIP] 和 TRUNCATE。

TABLES
标识要导入的表的列表。
例如, TABLES=HR.EMPLOYEES,SH.SALES:SALES_1995。

TABLESPACES
标识要导入的表空间的列表。

TARGET_EDITION
用于加载元数据的版本。

TRANSFORM
要应用于适用对象的元数据转换。
有效的关键字为: OID, PCTSPACE, SEGMENT_ATTRIBUTES 和 STORAGE。

TRANSPORTABLE
用于选择可传输数据移动的选项。
有效的关键字为: ALWAYS 和 [NEVER]。
仅在 NETWORK_LINK 模式导入操作中有效。

TRANSPORT_DATAFILES
按可传输模式导入的数据文件的列表。

TRANSPORT_FULL_CHECK
验证所有表的存储段 [N]。

TRANSPORT_TABLESPACES
要从中加载元数据的表空间的列表。
仅在 NETWORK_LINK 模式导入操作中有效。

VERSION
要导入的对象的版本。
有效的关键字为: [COMPATIBLE], LATEST 或任何有效的数据库版本。
仅对 NETWORK_LINK 和 SQLFILE 有效。

------------------------------------------------------------------------------

下列命令在交互模式下有效。
注: 允许使用缩写。

CONTINUE_CLIENT
返回到事件记录模式。如果处于空闲状态, 将重新启动作业。

EXIT_CLIENT
退出客户机会话并使作业保持运行状态。

HELP
汇总交互命令。

KILL_JOB
分离并删除作业。

PARALLEL
更改当前作业的活动 worker 的数量。

START_JOB
启动或恢复当前作业。
有效的关键字为: SKIP_CURRENT。

STATUS
监视作业状态的频率, 其中
默认值 [0] 表示只要有新状态可用, 就立即显示新状态。

STOP_JOB
按顺序关闭作业执行并退出客户机。
有效的关键字为: IMMEDIATE。
```

‍

## exp/imp

```bash
# 导出用户全部数据(所有数据库),执行用户需要有dba权限
exp system/Ninestar2022 file=/tmp/all_20220510.dmp  full=y  log=/tmp/imp.log
# 导出指定用户的数据
exp jy2web/Ninestar2022 file=/tmp/all_20220510.dmp log=/tmp/imp.log
exp system/Ninestar2022 file=/tmp/jy2web_20220510.dmp owner=jy2web log=/tmp/imp.log
exp jy2web/Ninestar2022 file=/tmp/jy2web_20220510.dmp direct=y log=/tmp/imp.log
#####  其他参数
# direct    定义了导出是使用直接路径方式(DIRECT=Y),提示导出效率
# fromuser  从哪一个用户导出的
# touser    导入到哪个用户
# ignore=y buffer=100000000; 修改缓冲区大小，有时sql语句过长，会造成缓冲区空间不足
```

**exp客户端远程导出oracle数据库**

```bash
# 下载4个rpm工具包
https://www.oracle.com/cn/database/technologies/instant-client/linux-x86-64-downloads.html
rpm -ivh oracle-instantclient19.15-basic-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-sqlplus-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-devel-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-tools-19.15.0.0.0-1.x86_64.rpm

# 配置环境变量
export ORACLE_HOME=/usr/lib/oracle/19.15/client64
export LD_LIBRARY_PATH=:$ORACLE_HOME/lib:/usr/local/lib:$LD_LIBRARY_PATH:.
export TNS_ADMIN=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME/bin:
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
export LANG=zh_CN.UTF-8

# oracle11g 可能需要以下操作
yum -y install glibc libaio
## 从oracle服务端拷贝exp imp 到客户端 ORACLE_HOME/bin 目录下
## 从oracle服务端拷贝expus.msb impus.msb 到客户端 ORACLE_HOME/rdbms/mesg/ 目录下(需要创建目录)
# 远程登录
sqlplus jy2web/Ninestar2022@192.168.10.150:1521/orcl
# 远程导出
exp jy2web/Ninestar2022@192.168.10.150:1521/orcl file=/tmp/jy2web_20220510.dmp

```

‍

‍

# 19c-GD

# 1. 环境准备

## 1.1 环境规划

实验基于单机DB+单实例DG。

注：备库中的实例名SID是参数设置的，SID可以和主库相同。

||主库(主机1)|备库(主机2)|
| ----------------| -----------------------------------------| -----------------------------------------|
|DB 类型|单机|单机|
|OS|Centos 7.8|Centos 7.8|
|Hostname|Klaus|Klausdg|
|IP|192.168.2.2|192.168.2.3|
|DB_Version|12.1.0.2|12.1.0.2|
|ORACLE_BASE|/u01/app/oracle|/u01/app/oracle|
|ORACLE_HOME|/u01/app/oracle/product/12.1.0/dbhome_1|/u01/app/oracle/product/12.1.0/dbhome_1|
|DB_NAME|orcl|orcl|
|ORACLE_SID|orcl|orcldg|
|DB_Unique_Name|orcl|orcldg|
|Instance_Name|orcl|orcldg|
|service_names|orcl|orcldg|
|TNS_Name|ORCL|ORCLDG|
|闪回区|开启|开启|
|归档|开启|开启|

## 1.2 数据库安装(略)

* 在主库上安装数据库软件，并建监听和实例。
* 在备库上安装数据库软件，并建监听，但不创建实例，安装时选择只安装软件即可。

‍

---

# 2. 主库配置

## 2.1 CDB和Non CDB环境下

* 如果实例处于多租户架构中，设置操作和Non-CDB方法相同，都在CDB下完成；
* 实验中有两个PDB1和PDB2，在创建备库后，默认两个PDB都会同步到备库，也可以通过参数指定只同步某个PDB；
* 也可以设置完同步的备库后，主库中再添加的PDB3也会同步到备库中。

```sql
-- CDB环境下的实验配置中的主库实例也是orcl,备库是orcldg，需要设置主备不同的 DB_UNIQUE_NAME
-- 同样可以通过name参数查看
SQL> show parameter name
NAME                                 TYPE        VALUE
------------------------------------ ----------- --------
cdb_cluster_name                     string
cell_offloadgroup_name               string
db_file_name_convert                 string
db_name                              string      orcl
db_unique_name                       string      orcl
global_names                         boolean     FALSE
instance_name                        string      orcl
lock_name_space                      string
log_file_name_convert                string
pdb_file_name_convert                string
processor_group_name                 string
service_names                        string      orcl
```

涉及的CDB简单操作

```sql
#-- 查看当前处于的那个容器
SQL> show con_name
CON_NAME
------------------
CDB$ROOT

-- 如果处于CDB，可以查看所有PDB
SQL> show pdbs
CON_IDCON_NAME                 OPEN MODE  RESTRICTED
------ ------------------------ ---------- ----------
   2 PDB$SEED                 READ ONLY  NO
   3 PDB1                     READ WRITE NO
   4 PDB2                     READ WRITE NO

-- 切换到PDB1
SQL> alter session set container=PDB1;
Session altered.

-- 再次查看处于PDB1
SQL> show pdbs
CON_IDCON_NAME                 OPEN MODE  RESTRICTED
------ ------------------------ ---------- ----------
   3 PDB1                     READ WRITE NO

-- 再次查看处于PDB1
SQL> show con_name
CON_NAME
----------
PDB1

-- 切回CDB
SQL> alter session set container=CDB$ROOT;
Session altered.
```

## 2.2 开启归档和闪回

```sql
-- 如果是CDB环境，先检查处于CDB根容器中，PDB下是不允许的
SQL> show con_name
CON_NAME
------------------
CDB$ROOT

-- 查看归档是否Enable
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     4
Next log sequence to archive   6
Current log sequence           6
-- 这里的归档路径是默认的 USE_DB_RECOVERY_FILE_DEST

-- 如果没有开启，开启的步骤
ALTER SYSTEM SET DB_CREATE_ONLINE_LOG_DEST_1 = '/data/oradata' scope=spfile;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 100G scope=spfile;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/data/orabackup' scope=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 = 'LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=spfile;
shutdown immediate;
startup mount;
alter database archivelog;
alter database flashback on;
alter database open;
SQL> alter system switch logfile;
```

‍

## 2.3 *开启所有PDB

如果是CDB环境，开启所有PDB。

```sql
SQL> select name,open_mode from v$pdbs;
NAME                           OPEN_MODE
------------------------------ --------------
PDB$SEED                       READ ONLY
PDB1                           MOUNTED
PDB2                           MOUNTED
#-- 开启 PDB
SQL> alter pluggable database all open;
Pluggable database altered.
-- 查看
SQL> select name,open_mode from v$pdbs;
NAME       OPEN_MODE
---------- ----------
PDB$SEED   READ ONLY
PDB1       READ WRITE
PDB2       READ WRITE
```

## 2.4 设置数据库强制归档

有一些DDL语句可以通过指定`NOLOGGING`​子句的方式避免写REDO(目的是提高速度，某些时候确实有效)。指定数据库为`Force Logging`​模式后，数据库将会记录除临时表空间或临时回滚段外所有的操作，而忽略类似`NOLOGGING`​之类的指定参数。如果在执行`Force Logging`​时有`NOLOGGING`​之类的语句在执行，那么`Force Logging`​会等待，直到这类语句全部执行。

​`Force Logging`​是作为固定参数保存在控制文件中，因此其不受重启之类操作的影响(只执行一次即可)，如果想取消，可以通过`ALTER DATABASE NO FORCE LOGGING`​语句关闭强制记录。

```sql
#-- 如果是CDB环境，先检查处于CDB根容器中，PDB下是不允许的
-- 查看
SQL> SELECT NAME, OPEN_MODE, FORCE_LOGGING FROM V$DATABASE;
NAME       OPEN_MODE            FORCE_LOGGING
---------- -------------------- -----------------
ORCL       READ WRITE           NO
-- 开启强制归档
SQL> alter database force logging;
```

* **LOGGING：**  当创建一个数据库对象时将记录日志信息到联机重做日志文件。LOGGING实际上是对象的一个属性，用来表示在创建对象时是否记录REDO日志，包括在做DML时是否记录REDO日志。
* **FORCE LOGGING：**  简言之，强制记录日志，即对数据库中的所有操作都产生日志信息，并将该信息写入到联机重做日志文件。
* **NOLOGGING：**  正好与LOGGING、FORCE LOGGING 相反，尽可能的记录最少日志信息到联机日志文件。一般表上不建议使用NOLOGGING,在创建索引或做大量数据导入时，可以使用NOLOGGING

## 2.5 添加Standby redo log

说明

为主库添加`standby redo log`​后，备库自动同步，所以备库不用再创建`standby redo log`​ 。

Data Guard在最大保护和最高可用性模式下，Standby数据库必须配置`standby redo log`​。

作用

实际上就是与主库接收到的重做日志相对应，也就是说备库调用`RFS`​进程将主库接收到的重做日志按顺序导入到`standby logfile`​ ，在主库创建`Standby logfile`​是便于发生角色转换后备用。

创建原则

* 确保`Standby redo log`​的大小与主库`online redo log`​的大小一致;
* 如果主库为单实例数据库：`Standby redo log`​组数=主库日志总数+1;
* 如果主库是`RAC`​数据库：`Standby redo log`​组数=(每线程的日志数+1)*最大线程数;
* 不建议复用`Standby redo log`​，避免增加额外的`I/O`​以及延缓重做传输。

```sql
-- 如果是CDB环境，先检查处于CDB根容器中，PDB下是不允许的；
-- 在Oracle 12c的架构里，online redo log 和控制文件是保存在CDB中的，PDB中只有运行需要的数据文件；  
-- 所以如果是CDB下，就在CDB中加 Standby redo log。

-- 1、查看组数
SQL> show parameter remote_login_passwordfile

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
remote_login_passwordfile            string      EXCLUSIVE
SQL> select count(group#),thread# from v$log group by thread#;

COUNT(GROUP#)    THREAD#
------------- ----------
            3          1

-- 2、大小
SQL> select group#,bytes/1024/1024 from v$log;

    GROUP# BYTES/1024/1024
---------- ---------------
         1              50
         2              50
         3              50


-- 3、创建standby logfile(3+1组、每组50M)
--注意路径大小写，本文部署CDB环境时，SID是大写的ORCL
SQL> select * from v$standby_log;
alter database add standby logfile group 4 ('/u01/app/oracle/oradata/orcl/stantby_redo04.log') size 50m;
alter database add standby logfile group 5 ('/u01/app/oracle/oradata/orcl/stantby_redo05.log') size 50m;
alter database add standby logfile group 6 ('/u01/app/oracle/oradata/orcl/stantby_redo06.log') size 50m;
alter database add standby logfile group 7 ('/u01/app/oracle/oradata/orcl/stantby_redo07.log') size 50m;

-- 4、验证查看
SQL> select * from v$standby_log;

SQL> select group#,status,type,member from v$logfile;
GROUP#STATUSTYPEMEMBER
----- -------------- ----------------------------------
3     ONLINE/u01/app/oracle/oradata/orcl/redo03.log
2     ONLINE /u01/app/oracle/oradata/orcl/redo02.log
1     ONLINE /u01/app/oracle/oradata/orcl/redo01.log
4     STANDBY /u01/app/oracle/oradata/orcl/stantby_redo04.log
5     STANDBY /u01/app/oracle/oradata/orcl/stantby_redo05.log
6     STANDBY /u01/app/oracle/oradata/orcl/stantby_redo06.log
7     STANDBY /u01/app/oracle/oradata/orcl/stantby_redo07.log
```

## 2.6 修改参数文件

### 2.6.1 设置DB唯一名称

```sql
-- 通常主库的DB名和唯一名相同,show参数查看
alter system set db_unique_name='orcl' scope=spfile;
#-- 其中dg_config填写的是主备库的db_unique_name
alter system set log_archive_config='DG_CONFIG=(orcl,orcldg)' scope=spfile;
```

‍

### 2.6.2 设置归档日志的路径

```sql
-- =前后不能有空格，本地的archive路径没有修改，使用默认
alter system set log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST valid_for=(all_logfiles,all_roles) db_unique_name=orcl' scope=spfile;
alter system set log_archive_dest_2='SERVICE=ORCLDG ASYNC valid_for=(ONLINE_LOGFILES,PRIMARY_ROLE) db_unique_name=orcldg' scope=spfile;
-- 第一个ORCLDG是备库tnsname.ora的连接名(最开头名称)
-- 第二个orcldg是DB_UNIQUE_NAME
```

### 2.6.3 启用设置的日志路径

```sql
alter system set log_archive_dest_state_1=enable scope=spfile;
alter system set log_archive_dest_state_2=enable scope=spfile;
```

### 2.6.4 设置归档日志进程的最大数量

```sql
--（视实际情况调整）
alter system set log_archive_max_processes=30 scope=both;
```

### 2.6.5 设置备库从哪个数据库获取归档日志

```sql
-- 只对standby库有效，在主库上设置是为了在故障切换后，主库可以成为备库使用，值就是TNSNAME
-- fal表示fetch archive log
-- fal_client用于发送日志，fal_server用于接受日志。也即无论是主库或备库，fal_server=对方，fal_client=自己
alter system set fal_server=orcldg;
alter system set fal_client=orcl;
```

### 2.6.6 设置文件管理模式

```sql
-- 表示如果Primary数据库数据文件发生修改（如新建、重命名等）则按照本参数的设置在Standby数据库中作相应修改。
-- 设为AUTO表示自动管理。设为MANUAL表示需要手工管理
-- 此项设置为自动，不然在主库创建数据文件后，备库不会自动创建
alter system set standby_file_management=auto scope=spfile;
```

### 2.6.7 主备文件路径

如果主备库文件的存放路径不同，还需要设置以下两个参数（需要重启数据库生效）。

```sql
-- 小写的orcl
alter system set db_file_name_convert='/u01/app/oracle/oradata/orcldg','/u01/app/oracle/oradata/orcl' scope=spfile;
alter system set log_file_name_convert='/u01/app/oracle/oradata/orcldg','/u01/app/oracle/oradata/orcl' scope=spfile;
-- 大写的ORCL
alter system set db_file_name_convert='/u01/app/oracle/oradata/ORCLDG','/u01/app/oracle/oradata/ORCL' scope=spfile;
alter system set log_file_name_convert='/u01/app/oracle/oradata/ORCLDG','/u01/app/oracle/oradata/ORCL' scope=spfile;
```

### 2.6.8 设置数据库口令文件的使用模式

```sql
SQL> show parameter remote_login_passwordfile

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
remote_login_passwordfile            string      EXCLUSIVE

-- 默认也是EXCLUSIVE
alter system set remote_login_passwordfile=EXCLUSIVE scope=spfile;
```

### 2.6.9 *设置默认监听

此处直接让监听为空即可保持后面创建的默认静态监听，否则备库无法从参数文件启动，者如果想要设置监听值，也可以：

```sql
SQL >alter system set local_listener='(DESCRIPTION =(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.2.2)(PORT=1521)))';
SQL> show parameter local_listener;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
local_listener                       string      LISTENER_ORCL

SQL> alter system set local_listener='';
SQL> show parameter local_listener;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
local_listener                       string
```

‍

---

# 3. 备库配置

## 3.1 *变量环境

参考：Oracle19c 静默安装

```
[oracle@klausdg ~]$ cat .bash_profile 
# .bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
# User specific environment and startup programs
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH
export EDITOR=vi
export ORACLE_SID=orcldg
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
export PATH=/u01/app/oracle/product/12.1.0/dbhome_1/bin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/X11R6/bin
export PATH=$ORACLE_HOME/bin:$PATH
# 使变量生效
source ~/.bash_profile
```

## 3.2 主备库密码文件

```bash
# Data Guard环境中，数据库的sys用户名密码要相同，可直接将主库复制密码文件复制到备库
# 拷贝后备库的密码文件格式：ora+sid，Windows下格式为：PWD[sid].ora
scp $ORACLE_HOME/dbs/orapworcl oracle@192.168.2.3:$ORACLE_HOME/dbs/orapworcldg
```

## 3.3 修改参数文件

### 3.3.1 复制主库参数文件

备库的参数文件根据主库参数进行修改 ，主库上创建`pfile`​，然后拷贝给备库

```bash
SQL> create pfile from spfile;
# 拷贝后的静态参数文件格式：init+sid.ora
$ scp $ORACLE_HOME/dbs/initorcl.ora oracle@192.168.2.3:$ORACLE_HOME/dbs/initorcldg.ora
```

### 3.3.2 修改initorcldg.ora内容

```bash
orcl.__data_transfer_cache_size=0
orcl.__db_cache_size=1761607680
orcl.__java_pool_size=16777216
orcl.__large_pool_size=33554432
orcl.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
orcl.__pga_aggregate_target=822083584
orcl.__sga_target=2466250752
orcl.__shared_io_pool_size=117440512
orcl.__shared_pool_size=520093696
orcl.__streams_pool_size=0
##### 修改为备库的orcldg
*.audit_file_dest='/u01/app/oracle/admin/orcldg/adump'
*.audit_trail='db'
*.compatible='12.1.0.2.0'
*.control_file_record_keep_time=19
##### 修改为备库的orcldg
*.control_files='/u01/app/oracle/oradata/orcldg/control01.ctl' #Restore Controlfile
*.db_block_size=8192
*.db_domain=''
##### 修改顺序主备路径和主库的相反
*.db_file_name_convert='/u01/app/oracle/oradata/orcl','/u01/app/oracle/oradata/orcldg'
##### DB名相同
*.db_name='orcl'
##### 修改实例唯一名,没有则添加
*.db_unique_name='orcldg'
*.db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
*.db_recovery_file_dest_size=4560m
*.diagnostic_dest='/u01/app/oracle'
##### 修改orcldgXDB
*.dispatchers='(PROTOCOL=TCP) (SERVICE=orcldgXDB)'
##### 和主库配置顺序相反
*.fal_client='ORCLDG'
*.fal_server='ORCL'
##### 使用默认监听
*.local_listener=''
##### 和主库配置相同
*.log_archive_config='DG_CONFIG=(orcl,orcldg)'
##### 修改为本库(备库)的唯一名
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST valid_for=(all_logfiles,all_roles) db_unique_name=ocrldg'
##### 服务名修改为连接主库TNS的ORCL，DB唯一名修改为主库的orcl
*.log_archive_dest_2='SERVICE=ORCL LGWR ASYNC valid_for=(ONLINE_LOGFILES,PRIMARY_ROLE) db_unique_name=orcl'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.log_archive_max_processes=30
##### 和主库配置相反
*.log_file_name_convert='/u01/app/oracle/oradata/orcl','/u01/app/oracle/oradata/orcldg'
*.nls_date_format='yyyy-mm-dd hh24:mi:ss'
*.open_cursors=300
*.pga_aggregate_target=780m
*.processes=300
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=2341m
*.standby_file_management='AUTO'
*.undo_tablespace='UNDOTBS1'
*.utl_file_dir='/home/oracle/logmnr'
```

## 3.4 备库创建spfile

```
SQL> create spfile from pfile;
File created.
SQL> 
```

## 3.5 创建备库所需路径

Oracle建议一般控制文件至少三个，放在不同的地方，本文主库没有设置。如果主库修改相关文件目录，拷贝过来的参数文件修改后也需要在备库中创建相关目录。

```
# 每个人的环境不同，根据备库参数文件创建所需目录
mkdir -p /u01/app/oracle/admin/orcldg/adump
mkdir -p /u01/app/oracle/oradata/orcldg#根据情况是否大写mkdir -p /u01/app/oracle/oradata/ORCLDG
mkdir -p /u01/app/oracle/fast_recovery_area
```

---

# 4. 主备库监听

## 4.1 开机自启动监听

设置主备库自动开启监听。 不建议备库设置自动开启数据库，因为DG开关有先后顺序，要手动开启。

```bash
## 修改/etc/rc.d/rc.local文件
su - root
# 增加一行(/etc/rc.local是/etc/rc.d/rc.local的软连接)
cat >> /etc/rc.d/rc.local << EOF 
su - oracle -c 'lsnrctl start'
EOF

## 授权rc.local文件可执行权限
chmod +x /etc/rc.d/rc.local
```

## 4.2 主库注册静态监听

```bash
# 静态注册的参数概念：
GLOBAL_DBNAME: #数据库服务名，默认和SID_NAME保持一致。在本例中这里需要填写PDB的服务名。
ORACLE_HOME:   #实例运行的ORACLE_HOME目录，如果是集群环境这里也填写ORACLE的ORACLE_HOME目录。
SID_NAME:      #数据库实例名。和数据库参数INSTANCE_NAME一致。
```

使用`Net Manager`​创建监听不容易出错，添加 `Database Services`​，客户端如果没有添加hosts信息或DNS建议写IP。
如果是CDB环境，监听也是相同静态配置即可，无需配置PDB监听或TNS

```
[oracle@klaus admin]$ cat listener.ora 
# listener.ora Network Configuration File: /u01/app/oracle/product/12.1.0/dbhome_1/network/admin/listener.ora
# Generated by Oracle configuration tools.

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcl)
      (ORACLE_HOME = /u01/app/oracle/product/12.1.0/dbhome_1)
      (SID_NAME = orcl)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.2)(PORT = 1521))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle
```

## 4.3 备库注册静态监听

```
[oracle@klausdg admin]$ cat listener.ora
# listener.ora Network Configuration File: /u01/app/oracle/product/12.1.0/dbhome_1/network/admin/listener.ora
# Generated by Oracle configuration tools.

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcldg)
      (ORACLE_HOME = /u01/app/oracle/product/12.1.0/dbhome_1)
      (SID_NAME = orcldg)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.3)(PORT = 1521))
    )
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle
```

## 4.4 主备库TNS监听相同

```
[oracle@klausdg admin]$ cat tnsnames.ora
# tnsnames.ora Network Configuration File: /u01/app/oracle/product/12.1.0/dbhome_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

ORCLDG =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.3)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcldg)
    )
  )

ORCL =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.2)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
```

## 4.5 主备连接测试

```bash
# 主备库监听重启
lsnrctl stop
lsnrctl start

# 主备测试
tnsping orcl
tnsping orcldg

# 测试登录
# 主库登陆 在密码文件拷贝后才可以登陆
sqlplus sys/Manager2023@orcl as sysdba
sqlplus sys/Manager2023@orcldg as sysdba

# 备库登录
```

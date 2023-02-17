

# 数据库备份

## 备份的分类

==物理备份==

物理备份是通过备份集的方式将数据文件中有效的数据也拷贝至备份集中，再通过备份集进行恢复还原
**热备（联机备份）**：数据库在做热备时，需要开启了归档模式，联机模式下备份的时间节点是在备份开始的时候，而备份开始~备份结束之间所产生的事务将写到归档日志中，所以在热备时，归档日志也要备份至备份集中；  
**冷备（脱机备份）**：数据库冷备因为时在脱机模式下，所以不会产生事务，备份开始与结束时间节点的数据一致，所以不需要开启归档模式

==逻辑备份==
逻辑备份与还原是通过$DM\_HOME/bin目录下的dexp/dimp 进行逻辑导出和导入；  
逻辑备份是将指定对象（数据库级、用户级、模式级、表级）的数据导出到 文件的备份方式。逻辑备份针对的是数据内容，并不关心这些数据物理存储在什么位置；

## 1. 物理备份
### 热备（联机备份）
需要开启归档模式,归档配置有两种方式：
联机归档配置，数据库实例启动情况下，使用 SQL 语句完成配置；
手动配置归档，数据库实例未启动的情况下，修改`dm.ini`和 `dmarch.ini` 配置文件。
`dmarch.ini` 中与备份还原相关的配置参数及其介绍见下表。

| 配置项 | 配置含义 |
| --- | --- |
| ARCH_NAME | REDO 日志归档名 |
| ARCH_TYPE | REDO 日志归档类型，LOCAL 表示本地归档，REMOTE 表示远程 |
| ARCH_DEST | REDO 日志归档目标，LOCAL 对应归档文件存放路径；REMOTE 对应远程目标节点实例名 |
| ARCH_FILE_SIZE | 单个 REDO 日志归档文件大小，取值范围（64 MB~2048 MB），缺省 1024 MB，即 1 GB |
| ARCH_SPACE_LIMIT | REDO 日志归档空间限制，当所有本地归档文件达到限制值时，系统自动删除最老的归档文件。0 表示无空间限制，取值范围（1024 MB~4294967294 MB），缺省为 0 |
| ARCH_INCOMING_PATH | 仅 REMOTE 归档有效，对应远程归档存放在本节点的实际路径 |
**联机归档配置**
```sql
-- 1.  修改数据库为 Mount 状态
SQL> ALTER DATABASE MOUNT;
-- 2.  配置本地归档
SQL> ALTER DATABASE ADD ARCHIVELOG 'DEST =/data/dmarch , TYPE = local';
-- 3.  开启归档模式
SQL> ALTER DATABASE ARCHIVELOG;
-- 4.  修改数据库为 Open 状态
SQL> ALTER DATABASE OPEN;
-- 5.查看是否开启归档模式
SQL> select arch_mode from v$database;
```


**手动归档配置**
```bash
# 1.  关闭数据库
# 2.  在 dm.ini 所在目录，创建 dmarch.ini 文件。dmarch.ini 文件内容如下：
[ARCHIVE_LOCAL1] 
ARCH_TYPE = LOCAL 
ARCH_DEST = /data/dmarch 
ARCH_FILE_SIZE = 1024 
ARCH_SPACE_LIMIT = 2048

# 3.  编辑 dm.ini 文件，设置参数 ARCH_INI=1
# 4.  启动数据库实例，数据库已运行于归档模式。
```

==数据库备份==
在 disql 工具执行以下命令：
```sql
-- 1.创建备份目录
mkdir /data/dmback
chown dmdba.dinstall /data/dmback

-- 2.执行BACKUP 语句
SQL> BACKUP DATABASE FULL BACKUPSET '/data/dmback/fmsdb/db_full_bak_01';    --指定备份集路径
-- BACKUP DATABASE FULL BACKUPSET '/data/dmback/fmsdb/db_full_bak_01' COMPRESSED LEVEL 5 PARALLEL 2;
-- BACKUPSET：                  指定备份目录
-- COMPRESSED LEVEL 5 ：指定压缩等级
-- PARALLEL 2：                  指定并行数（根据cpu核数）
--WITHOUT LOG：              联机数据库备份是否备份日志。如果使用，则表示不备份，否则表示备份


-- [-718]:收集到的归档日志不连续.
SQL> alter system switch logfile;
SQL> select checkpoint(100);

-- 基于 /data/dmback/fmsdb/db_full_bak_01 全量备份的 `增量备份`，执行以下命令：
SQL> BACKUP DATABASE INCREMENT WITH BACKUPDIR '/data/dmback/fmsdb/db_full_bak_01' BACKUPSET '/data/dmback/fmsdb/db_increment_bak_02';
```


==表空间备份==
完全备份单个表空间，执行以下命令：
```sql
BACKUP TABLESPACE jy2web FULL BACKUPSET '/data/dmbak/ts_full_bak_01';
```

==还原与恢复==
热备份的还原恢复同样需脱机
```sql
SQL> delete jy2web.emp;
/data/dmapp/bin/DmServicefmsdb stop
dmrman
-- restore 是还原，文件级的恢复。就是物理文件还原。
RMAN> restore database '/data/dmdata/fmsdb/dm.ini' from backupset '/data/dmback/fmsdb/db_full_bak_01';
-- recover 是恢复，数据级的恢复。逻辑上恢复，比如应用归档日志、重做日志，全部同步，保持一致。
RMAN> recover database '/data/dmdata/fmsdb/dm.ini' from backupset '/data/dmback/fmsdb/db_full_bak_01';
-- 更新数据库魔数
RMAN> recover database '/data/dmdata/fmsdb/dm.ini' update db_magic;
-- 验证
/data/dmapp/bin/DmServicefmsdb start
disql SYSDBA/Ninestar123
SQL> select * from jy2web.emp;
```


### 冷备（脱机备份）

DMRMAN（DM RECOVERY MANAGER）是 DM 的脱机备份还原管理工具，由它来统一负责库级脱机备份、脱机还原、脱机恢复等相关操作，该工具支持命令行指定参数方式和控制台交互方式执行，降低了用户的操作难度。
```sql
-- 停止数据库
/data/dmapp/bin/DmServicefmsdb stop
/data/dmapp/bin/DmServicefmsdb status

-- 备份
dmrman
BACKUP DATABASE BACKUPSET '/data/dmback/db_bak_01';   --指定备份集路径
-- BACKUP DATABASE FULL BACKUPSET '/data/dmback/fmsdb/db_full_bak_01' COMPRESSED LEVEL 5 PARALLEL 2; -- BACKUPSET： 指定备份目录 -- COMPRESSED LEVEL 5 ：指定压缩等级 -- PARALLEL 2： 指定并行数（根据cpu核数） --WITHOUT LOG： 联机数据库备份是否备份日志。如果使用，则表示不备份，否则表示备份

-- 还原测试
-- 启动数据库
/data/dmapp/bin/DmServicefmsdb start
disql SYSDBA/Ninestar123
-- 删除数据
SQL> select * from jy2web.emp;
SQL> delete jy2web.emp;
SQL> scommit;
/data/dmapp/bin/DmServicefmsdb stop

dmrman
restore database '/data/dmdata/fmsdb/dm.ini' from backupset '/data/dmdata/fmsdb/bak/DB_fmsdb_FULL_20221024_204635_383496';
-- 更新数据库魔数
recover database '/data/dmdata/fmsdb/dm.ini' update db_magic;
-- 验证
/data/dmapp/bin/DmServicefmsdb start
disql SYSDBA/Ninestar123
SQL> sselect * from jy2web.emp;
```



## 2. 逻辑备份

dexp 工具可以对本地或者远程数据库进行数据库级、用户级、模式级和表级的逻辑备份。备份的内容非常灵活，可以选择是否备份索引、数据行和权限，是否忽略各种约束（外键约束、非空约束、唯一约束等），在备份前还可以选择生成日志文件，记录备份的过程以供查看。

==**四种级别的导出方式**==
```bash

# FULL 方式导出数据库的所有对象
dexp sysdba/Ninestar123 file=full_db.dmp log=exp_all_db.log full=y directory=/tmp

# OWNER 方式导出一个或多个用户拥有的所有对象
dexp jy2web/Ninestar2022 file=exp_own_jy2web.dmp log=exp_own_jy2web.log owner=jy2web directory=/tmp

# SCHEMAS 方式的导出一个或多个模式下的所有对象
dexp jy2web/Ninestar2022 file=exp_schemas_jy2web.dmp log=exp_schemas_jy2web.log schemas=jy2web directory=/tmp

# TABLES 方式导出和导入一个或多个指定的表或表分区。
dexp jy2web/Ninestar2022 file=exp_ts_jy2web.dmp log=exp_ts_jy2web.log table=table1,table2  directory=/tmp
```

使用dm管理工具图形方式导出数据库
在数据库对象处，右键，选择导出  


dimp 逻辑导入工具利用 dexp 工具生成的备份文件对本地或远程的数据库进行联机逻辑还原。dimp 导入是 dexp 导出的相反过程。还原的方式可以灵活选择，如是否忽略对象存在而导致的创建错误、是否导入约束、是否导入索引、导入时是否需要编译、是否生成日志等。

==**四种级别的导入方式**==
```bash

# FULL 方式导入整个数据库**
dimp SYSDBA/Ninestar123 file=full_db.dmp log=imp_all_db.log  full=y directory=/tmp

# OWNER 方式导入一个或多个用户拥有的所有对象**
dimp jy2web/Ninestar2022 file=/tmp/exp_owner_jy2web.dmp log=imp_owner_jy2web.log owner=jy2web  directory=/tmp

# SCHEMAS 方式的导入一个或多个模式下的所有对象。
dimp jy2web/Ninestar2022 file=/tmp/exp_owner_jy2web.dmp log=imp_owner_jy2web.log schemas=jy2web directory=/tmp
dimp jy2gm/Ninestar2022 file=/tmp/exp_owner_jy2web.dmp log=imp_owner_jy2web.log remap_schema=jy2web:jy2gm remap_tablespace=jy2web:jy2gm  directory=/tmp

# TABLES 方式导入一个或多个指定的表或表分区。导入所有数据行、约束、索引等信息**
dimp jy2web/Ninestar123 file=/opt/exp_ts_jy2web.dmp log=imp_ts_jy2web.log TABLES=table1,table2 directory=/tmp
```



# 备份管理

管理备份一个重要的目的是删除不再需要的备份。DMRMAN 工具提供 SHOW、CHECK、REMOVE、LOAD 等命令分别用来查看、校验、删除和导出备份集。
```bash
dmrman

# 删除指定备份集
REMOVE BACKUPSET '<备份集目录>'

# 删除指定时间之前的备份集
REMOVE BACKUPSETS WITH BACKUPDIR '/data/dmback/fmsdb' UNTIL TIME '2022-10-26 00:00:00';

# 删除距离当前时间前 n_day 天产生的备份集
REMOVE BACKUPSETS WITH BACKUPDIR '/data/dmback/fmsdb' BEFORE 7;
```

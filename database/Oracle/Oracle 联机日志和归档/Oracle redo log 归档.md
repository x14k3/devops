#oracle

我们知道，Oracle 数据库需要至少两组联机日志，每当一组 联机日志写满后会发生日志切换，继续向下一组联机日志写入。  
如果是归档模式，日志切换会触发归档进程 （ARCn）进行归档，生成归档日志。Oracle 保证归档完成前，联机日志不会被覆盖，如果是非归档模式， 则不会触发归档动作。

不管数据库是否是归档模式，重做日志是肯定要写的。而只有数据库在归档模式下，重做日志才会备份，形成归档日志。
一般来说，归档日志结合全备份，用于数据库出现问题后的恢复使用

### 开启归档模式

```sql
-- 查看是否开启归档模式
archive log list;

-- 设置归档文件格式   
alter system set log_archive_format='arc_%t_%s_%r.dbf' scope=spfile;

-- 设置归档文件保存路径,路径中最好包含实例名，确保目录存在，且拥有者为oracle用户
alter system set log_archive_dest_1 ='location=/data/arch/fmsdb' scope=spfile;

-- 重启数据库至mount模式
shutdown immediate
startup mount

-- 打开归档、强制、最小附加日志
alter database archivelog;
--alter database force logging;
--alter database add supplemental log data;

-- 打开数据库
alter database open;

-- 手动归档
alter system archive log current;

-- 运行带有SWITCH LOGFILE子句的ALTER SYSTEM语句。
alter system switch logfile;
```

说明

```h3c
'%t_%s_%r.arc' 是新的格式，表示：

 %t：线程号
 %s：序列号
 %r：重做日志组号
```

‍

### 配置参数详解

log\_archive\_dest\_n   # 设置归档日志路径

```bash
LOG_ARCHIVE_DEST_n   # 参数可以设置最多10个不同的归档路径，通过设置关键词location或service，该参数指向的路径可以是本地或远程的。
LOG_ARCHIVE_DEST_1 = 'LOCATION = /disk1/archive' 
LOG_ARCHIVE_DEST_2 = 'LOCATION = /disk2/archive' 
LOG_ARCHIVE_DEST_3 = 'LOCATION = /disk3/archive' 
# 如果要归档到远程的standby数据库，可以设置service：
LOG_ARCHIVE_DEST_4 = 'SERVICE = standby1'
```

scope（范围）说明：

```bash
# Oracle 里面有个叫做spfile的东西，就是动态参数文件，里面设置了Oracle 的各种参数。
# 所谓的动态，就是说你可以在不关闭数据库的情况下，更改数据库参数，记录在spfile里面。
scope=spfile  # 仅仅更改spfile里面的记载，不更改内存，也就是不立即生效，而是等下次数据库启动生效。有一些参数只允许用这种方法更改
scope=memory  # 仅仅更改内存，不改spfile。也就是下次启动就失效了
scope=both    # 内存和spfile都更改
不指定scope参数 # 等同于scope=both.

```

‍


### 启用最小补充日志

**检查当前数据库的补充日志设置:**

```sql
SELECT supplemental_log_data_min, supplemental_log_data_pk, supplemental_log_data_ui FROM v$database;
```
如果 `supplemental_log_data_min` 为 `YES`，则表示已开启最小补充日志。同样，`supplemental_log_data_pk` 和 `supplemental_log_data_ui` 分别表示主键和唯一键的补充日志是否开启。


如果需要启用最小补充日志，可以执行以下命令：
```sql
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
```


**启用其他类型的补充日志:**

除了最小补充日志，还可以启用主键、唯一键和外键的补充日志。例如，要启用主键的补充日志，可以执行：
```sql
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
```

同样，可以分别使用 `(UNIQUE)` 和 `(FOREIGN KEY)` 启用唯一键和外键的补充日志。  
如果要启用所有列的补充日志，可以使用 `(ALL)`:﻿
```sql
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
```

**重启数据库**
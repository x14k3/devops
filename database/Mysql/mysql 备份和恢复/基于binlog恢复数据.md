

## 1.准备工作(测试机为centos)

###### (1)首先确保MySQL已开启binlog

```sql
show variables like 'log_%';
```

如果没有开启,则修改etc/my.cnf文件,添加以下内容:

```bash
#保存日志的路径
log_bin = /opt/mysql/mysql-bin
#保存日志格式,此处使用row便于恢复数据
binlog_format = ROW
#清除过期日志的时间,默认0不清除
expire-logs-days = 7
#变量设置为大于1GB或小于4096字节,默认值是1GB,如果使用大事务,会超出该值
max-binlog-size = 500M
#某些版本报错,需要加这个
server-id=1
```

binlog\_format的选择,以下是摘自网上内容:

```bash
binlog有三种格式：Statement、Row以及Mixed。

–基于SQL语句的复制(statement-based replication,SBR)， 
–基于行的复制(row-based replication,RBR)， 
–混合模式复制(mixed-based replication,MBR)。

2.1 Statement 
每一条会修改数据的sql都会记录在binlog中。

优点：不需要记录每一行的变化，减少了binlog日志量，节约了IO，提高性能。

缺点：由于记录的只是执行语句，为了这些语句能在slave上正确运行，因此还必须记录每条语句在执行的时候的一些相关信息，以保证所有语句能在slave得到和在master端执行时候相同 的结果。另外mysql 的复制,像一些特定函数功能，slave可与master上要保持一致会有很多相关问题。

ps：相比row能节约多少性能与日志量，这个取决于应用的SQL情况，正常同一条记录修改或者插入row格式所产生的日志量还小于Statement产生的日志量，但是考虑到如果带条件的update操作，以及整表删除，alter表等操作，ROW格式会产生大量日志，因此在考虑是否使用ROW格式日志时应该跟据应用的实际情况，其所产生的日志量会增加多少，以及带来的IO性能问题。

2.2 Row

5.1.5版本的MySQL才开始支持row level的复制,它不记录sql语句上下文相关信息，仅保存哪条记录被修改。

优点： binlog中可以不记录执行的sql语句的上下文相关的信息，仅需要记录那一条记录被修改成什么了。所以rowlevel的日志内容会非常清楚的记录下每一行数据修改的细节。而且不会出现某些特定情况下的存储过程，或function，以及trigger的调用和触发无法被正确复制的问题.

缺点:所有的执行的语句当记录到日志中的时候，都将以每行记录的修改来记录，这样可能会产生大量的日志内容。

ps:新版本的MySQL中对row level模式也被做了优化，并不是所有的修改都会以row level来记录，像遇到表结构变更的时候就会以statement模式来记录，如果sql语句确实就是update或者delete等修改数据的语句，那么还是会记录所有行的变更。

2.3 Mixed

从5.1.8版本开始，MySQL提供了Mixed格式，实际上就是Statement与Row的结合。

在Mixed模式下，一般的语句修改使用statment格式保存binlog，如一些函数，statement无法完成主从复制的操作，则采用row格式保存binlog，MySQL会根据执行的每一条具体的sql语句来区分对待记录的日志形式，也就是在Statement和Row之间选择一种。
```

出现无法启动问题,查看日志,可以看到是binlog路径没有权限导致,赋予mysql权限;

```bash
#查看日志位置
cat /etc/my.cnf|grep log-error
log-error=/var/log/mysqld.log
```

```bash
2021-12-08T02:35:17.480859Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2021-12-08T02:35:17.482708Z 0 [Note] /usr/sbin/mysqld (mysqld 5.7.36-log) starting as process 17857 ...
mysqld: File '/opt/mysql/mysql-bin.index' not found (Errcode: 13 - Permission denied)
2021-12-08T02:35:17.484286Z 0 [ERROR] Aborting
```

## 2.解析binlog

###### (1)使用mysqlbinlog查看binlog

mysql查看binlog信息命令:

```bash
 #查看binlog文件列表
 show binary logs;
 #查看第一个binlog文件的内容
 show binlog events;
 #查看指定binlog文件的内容
 show binlog events in 'mysql-bin.000001';
 #可以刷新binlog,产生一个新的文件
 flush logs;
```

mysqlbinlog命令:

```bash
--base64-output=decode-rows -v 可解析完整sql语句
--no-defaults                  告诉 mysql 客户端不要处理 my.ini 和 my.cnf 文件
--database                     指定数据库
--start-datetime               开始时间'yyyy-mm-dd HH:MM:ss'
--stop-datetime                结束时间
--start-position               开始坐标,仅可以解析一个文件时候使用
--stop-position                结束坐标
```

我这里先用 flush logs刷新,然后解析新文件,并新增一条数据:

```bash
#此处可以使用通配符,解析多个文件
mysqlbinlog --no-defaults --database=binlog_test --base64-output=decode-rows -v  /opt/mysql/*
```

```bash
#以下为显示内容
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#211208 11:03:10 server id 1  end_log_pos 123 CRC32 0x3e9c880c 	Start: binlog v 4, server v 5.7.36-log created 211208 11:03:10
# Warning: this binlog is either in use or was not closed properly.
# at 123
#211208 11:03:10 server id 1  end_log_pos 154 CRC32 0x83050418 	Previous-GTIDs
# [empty]
# at 154
#211208 11:03:28 server id 1  end_log_pos 219 CRC32 0x91d04316 	Anonymous_GTID	last_committed=0	sequence_number=1	rbr_only=yes
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 219
#211208 11:03:28 server id 1  end_log_pos 306 CRC32 0x8251779e 	Query	thread_id=3	exec_time=0	error_code=0
SET TIMESTAMP=1638932608/*!*/;
SET @@session.pseudo_thread_id=3/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=1436549152/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C utf8mb4 *//*!*/;
SET @@session.character_set_client=45,@@session.collation_connection=45,@@session.collation_server=8/*!*/;
SET @@session.time_zone='SYSTEM'/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 306
#211208 11:03:28 server id 1  end_log_pos 378 CRC32 0x84c85f3a 	Table_map: `binlog_test`.`wf_icon` mapped to number 99
# at 378
#211208 11:03:28 server id 1  end_log_pos 459 CRC32 0xa99c14d6 	Write_rows: table id 99 flags: STMT_END_F
### INSERT INTO `binlog_test`.`wf_icon`
### SET
###   @1=30
###   @2='11222222'
###   @3='12222222222222'
###   @4=NULL
###   @5=0
###   @6=NULL
###   @7='2021-12-08 11:03:28'
###   @8=1
###   @9=1
# at 459
#211208 11:03:28 server id 1  end_log_pos 490 CRC32 0xa71e250b 	Xid = 76
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
```

然后我修改一条数据:

```bash
### UPDATE `binlog_test`.`wf_icon`
### WHERE
###   @1=30
###   @2='11222222'
###   @3='12222222222222'
###   @4=NULL
###   @5=0
###   @6=NULL
###   @7='2021-12-08 11:03:28'
###   @8=1
###   @9=1
### SET
###   @1=30
###   @2='11222222'
###   @3='333333333333'
###   @4=NULL
###   @5=0
###   @6=NULL
###   @7='2021-12-08 11:07:23'
###   @8=1
###   @9=1
# at 840
```

删除一条数据

```bash
### DELETE FROM `binlog_test`.`wf_icon`
### WHERE
###   @1=30
###   @2='11222222'
###   @3='333333333333'
###   @4=NULL
###   @5=0
###   @6=NULL
###   @7='2021-12-08 11:07:23'
###   @8=1
###   @9=1
# at 1166
```

可以看到日志很完整的记录了数据的变化过程,所以我们能够依靠数据来还原被误操作的数据;

###### (3)演示还原数据

1.我先模拟误删除所有数据,可以看到日志:

```bash
BEGIN
/*!*/;
# at 1341
#211208 11:18:10 server id 1  end_log_pos 1413 CRC32 0xcd9fcd95 	Table_map: `binlog_test`.`wf_icon` mapped to number 99
# at 1413
#211208 11:18:10 server id 1  end_log_pos 2523 CRC32 0xb0e73647 	Delete_rows: table id 99 flags: STMT_END_F
### DELETE FROM `binlog_test`.`wf_icon`
### WHERE
###   @1=1
###   @2='大语文'
###   @3='IndexIcon/cf6eca90d0374db3a6a9a1862e27d545.png'
###   @4=32
###   @5=1
###   @6='2019-04-30 18:17:14'
###   @7='2021-02-25 13:51:01'
###   @8=1
###   @9=1
#多余的不展示了~~~~~~~~~~~~~~~~~~~~~~~~
# at 2523
#211208 11:18:10 server id 1  end_log_pos 2554 CRC32 0x06ea7152 	Xid = 95
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;

```

2.恢复数据

首先看到删除的开始坐标在1341;

```bash
#mysql-bin.000001的完整日志和mysql-bin.000002坐标1341前得日志还原,此处不要解析转码;
mysqlbinlog --no-defaults --database=binlog_test  mysql-bin.000001 >>1.sql
mysqlbinlog --no-defaults --database=binlog_test  --stop-position=1341  mysql-bin.000002 >>1.sql
#然后读取sql 
mysql->source /opt/mysql/1.sql

#或者直接导入到mysql
mysqlbinlog --no-defaults --database=binlog_test  mysql-bin.000001|mysql
mysqlbinlog --no-defaults --database=binlog_test  --stop-position=1341  mysql-bin.000002 |mysql
```

3.总结

使用mysql自带工具mysqlbinlog来还原数据,相当于是将历史操作日志进行修改(排除误操作的行为日志)后,'重放'来达到还原数据的目的;

所有如果出现了勿操作导致数据出问题,则要保证用来还原的历史数据存在,否则无法完全恢复;

例如以下问题,则无法进行完整的还原:

```
1.使用delete命令误删除了全部数据;
2.并且binlog只保留了最近几天的数据;
```

‍

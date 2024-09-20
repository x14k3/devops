# Oracle之闪回区

　　**开启闪回功能必须是在归档模式下，请参考上面的操作**Oracle之重做日志（Redo Log）归档

　　当启用闪回就必须使用**logarchivedestn**参数来指定归档日志目录。

　　Oracle的闪回技术提供了一组功能，可以访问过去某一时间的数据并从人为错误中恢复。闪回技术是Oracle 数据库独有的，支持任何级别的恢复，包括行、事务、表和数据库范围。使用闪回特性，可以查询以前的数据版本，还可以执行更改分析和自助式修复，以便在保持数据库联机的同时从逻辑损坏中恢复。

　　Flashback技术是以Undo Segment中的内容为基础的， 因此受限于`UNDO_RETENTON`​参数。要使用flashback 的特性，必须启用自动撤销管理表空间。闪回参数如下：

```sql
SQL> show parameter undo;

NAME                     TYPE     VALUE
------------------------------------ ----------- ------------------------------
undo_management        string     AUTO        # undo_management参数值是否为AUTO，如果是“MANUAL”手动，需要修改为“AUTO”
undo_retention         integer    7200        # 1d是1440 即24*60,7200是5d
undo_tablespace        string     UNDO1

```

　　**单实例：**

```sql
# 设置闪回恢复区
SQL> show parameter recover;
SQL> alter system set db_recovery_file_dest_size=10g scope=spfile;
# 设置闪回区位置，路径中不用指定实例名，会自动生成，确保目录存在，且拥有者为oracle用户
SQL> alter system set db_recovery_file_dest='/data/arch' scope=spfile;
# 设置闪回目标为5天，以分钟为单位，每天为1440分钟，默认为1天
SQL> alter system set db_flashback_retention_target=2880 scope=spfile;
# 保存一致性,先关闭数据库
SQL> shutdown immediate;
# 启动到mount阶段
SQL> startup mount;
# 启动闪回功能
SQL> alter database flashback on; 
# 也可启用表空间闪回
SQL> alter tablespace abc flashback on;     -- 开启表空间闪回
SQL> alter tablespace abc flashback off;    -- 关闭表空间闪回
# 切换到open阶段
SQL> alter database open;
```

　　**RAC：**

```bash

```

　　**闪回区和归档目录**

```bash
# 使用闪回区需先设置其大小和路径：
alter system set db_recovery_file_dest_size=5G scope=both;
alter system set db_recovery_file_dest='/archivelog' scope=spfile;

# 设置归档路径和闪回区同时保留归档日志：
alter system set log_archive_dest_1='location=/data/arch' scope=spfile;
alter system set log_archive_dest_10='LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=spfile;

# 设置归档路径保留归档日志，闪回区不保留：
alter system set log_archive_dest_1='location=/data/arch' scope=spfile;
alter system set log_archive_dest_10='' scope=spfile;

# 设置归档路径不保留归档日志，闪回区保留：
alter system set log_archive_dest_1='' scope=spfile;
alter system set log_archive_dest_10='LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=spfile;

```

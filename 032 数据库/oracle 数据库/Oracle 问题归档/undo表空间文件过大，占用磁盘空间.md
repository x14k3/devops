# undo表空间文件过大，占用磁盘空间

```bash
-- 以dba登录数据库
sqlplus / as sysdba
-- 查询实例名，确实实例
show parameter instance_name;
-- 查询undo表空间
show parameter undo_tablespace;
-- 查看undo表空间和文件的对应关系
select file_name, tablespace_name, online_status from dba_data_files where tablespace_name='UNDOTBS1';
-- 查询当前回退表空间状态
select tablespace_name, status from dba_rollback_segs;
-- undo_tablespace 是一个必须一直存在的表空间，
-- 要想删除当前的，我们必须设置一个临时空间供undo_tablespace 使用；
create undo tablespace UNDOTBS2 datafile '/data/oradata/orcl/undotbs02.dbf' size 100M;
alter system set undo_tablespace=UNDOTBS2;
-- 再查询当前回退表空间状态
select tablespace_name, status from dba_rollback_segs;
-- 删除回退表空间UNDOTBS1
drop tablespace UNDOTBS1 including contents and datafiles;
-- 重启oracle实例
shutdown immediate;
startup;
```

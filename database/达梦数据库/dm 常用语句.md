
## 0.数据库启停

```bash
# 服务注册成功后，启动数据库，如下所示：
systemctl start DmServiceDmFMSServer.service
# service DmServiceDmFMSServer start
# /etc/init.d/DmServiceDmFMSServer start

# 可前台启动，进入 DM 安装目录下的 bin 目录下，命令如下： 
./dmserver /dm/data/DAMENG/dm.ini 
# 该启动方式为前台启动，若想关闭数据库，则输入 exit 即可。

# 也可进入 DM 安装目录下的 bin 目录下，启动/停止/重启数据库，如下所示： 
./DmServiceDMSERVER start/stop/restart/status
```

## 1.链接数据库

```bash
su - dmdba
disql SYSDBA/Ninestar123@192.168.130.136:5236

#disql连接到实例后，有两种方式执行sql脚本（start命令和`字符)：
SQL> `/home/dmdba/test.sql
SQL> start /home/dmdba/test.sql

#------------------------------------------------------------------
disql SYSDBA/Ninestar123@192.168.130.136:5236 -E "SELECT TOP 1 * FROM LLL.TABLE_1;"
disql SYSDBA/Ninestar123@192.168.130.136:5236 \`/opt/dm/test.sql

```

## 2.创建表空间

达梦数据库中表空间的数据文件的初始大小必须是数据库实例页大小的4096倍,比如创建的数据库实例是32K，那么数据文件的最小限制为4096\*32k/1024=128M，也就是说创建表空间的起始值要≥128M，默认单位M。

```bash
#创建表空间
create tablespace JY2WEB datafile '/data/dmdata/FMSDB/JY2WEB01.DBF' size 1024 autoextend on next 1024 maxsize unlimited;
create tablespace JY2GM datafile '/data/dmdata/FMSDB/JY2GM01.DBF' size 1024 autoextend on next 1024 maxsize unlimited;

#datafile:表空间文件路径
#size:表空间初始大小
#autoextend:是否启用自动扩展空间
#next:表示数据文件满了以后,扩展的大小
#maxsize:表示数据文件的最大大小,UNLIMITED 表示无限的表空间

# 建议索引、表数据用不同的表空间
# 创建索引表空间
create tablespace JY2WEB_IDX datafile '/data/dm8/data/DMDB/JY2WEN_IDX01.DBF' size 128 autoextend on next 128 maxsize unlimited;

# 查看表空间
select * from v$tablespace;
```

|表空间的基本操作|命令|
| ------------------------| ------------------------------------------------------------------------------------------------------------------------------|
|创建表空间|create tablespace XXX datafile ‘xxx/xxx/xxx.dbf’ size xx;|
|删除表空间|drop tablespace XXX；|
|修改表空间名|alter tablespace XXX rename to YYY;|
|修改表空间脱机状态|alter tablespace XXX offline;|
|修改表空间联机状态|alter tablespace XXX online;|
|查询所有表空间的信息|select * from v$tablespace;|
|修改表空间数据文件大小|alter tablespace XXX resize datafile ‘xxx/xxx/xxx.dbf’ to aa;（注意：不能将数据文件的大小变小，例如：256M.dbf==>128M.dbf）|
|修改表空间数据文件路径|alter tablespace XXX rename datafile ‘xxx/xxx/xxx.dbf’ to ‘yyy/yyy/yyy.dbf’;|

‍

‍

## 3.创建用户

```bash
#创建用户JY2WEB并指定默认的表空间及默认的索引表空间。
CREATE USER JY2WEB IDENTIFIED by Ninestar2022 DEFAULT TABLESPACE JY2WEB;
CREATE USER JY2GM  IDENTIFIED by Ninestar2022 DEFAULT TABLESPACE JY2GM;
# 授权
GRANT DBA TO JY2WEB;
GRANT DBA TO JY2GM;
```

## 4.查看数据库相关信息

```sql
--查看正在执行的语句：
select * from v$sessions where state = 'ACTIVE';

--终止正在执行的语句：
--sess_id是上面查询出的结果列
call sp_close_session(sess_id);


--查看实例信息
select name inst_name from v$instance;
--查询数据库当前状态
select status$ from v$instance;
--查询DB_MAGIC
select db_magic from v$rlog;
--查询是否归档
select arch_mode from v$database;
--查询授权截止有效期
select EXPIRED_DATE  from v$license;
--查看数据库配置端口
select para_name,para_value from v$dm_ini where para_name like '%PORT%';
--查询数据库最大连接数
select SF_GET_PARA_VALUE(2,'MAX_SESSIONS');
--查询数据库字符集[注释：0 表示 GB18030，1 表示 UTF-8，2 表示 EUC-KR]
select SF_GET_UNICODE_FLAG();
--查询归档信息
select * from v$dm_arch_ini;
--查看控制文件
select para_value name from v$dm_ini where para_name='CTL_PATH';
--查询日志文件
select GROUP_ID ,FILE_ID,PATH,CLIENT_PATH from v$rlogfile;
--查询数据库占用空间
select sum(bytes/1024/1024)|| 'M' from dba_data_files;
--查询数据文件位置
select GROUP_ID , ID ,path,STATUS$ from v$datafile;
--查询表空间大小
select FILE_NAME,FILE_ID,TABLESPACE_NAME,BYTES/1024/1024||'M'  from dba_data_files;

--查询数据库有哪些用户
select username from dba_users;
--查询数据库用户信息
select username,user_id,default_tablespace,profile from dba_users;
--查看数据库对象
select t2.name owner,t1.subtype$ object_type,t1.valid status,count(1) count# from sysobjects t1,sysobjects t2 where t1.schid=t2.id and t1.schid!=0 group by t2.name,t1.subtype$,t1.valid;
--查询当前用户所有表
select table_name,tablespace_name from user_tables;
--
```

# DM8 常用语句

## 1.链接数据库

```bash
su - dmdba
disql SYSDBA/Ninestar123@192.168.130.136:5236
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

```

## 3.创建用户

```bash
#创建用户JY2WEB并指定默认的表空间及默认的索引表空间。
CREATE USER JY2WEB IDENTIFIED by Ninestar2022 DEFAULT TABLESPACE JY2WEB;
CREATE USER JY2GM  IDENTIFIED by Ninestar2022 DEFAULT TABLESPACE JY2GM;
# 授权
GRANT DBA TO JY2WEB;
GRANT DBA TO JY2GM;
```

## 4.数据库启停

```bash
#服务注册成功后，启动数据库，如下所示：
systemctl start DmServiceDmFMSServer.service
#查看数据库服务状态，如下所示：
systemctl status DmServiceDmFMSServer.service
#停止数据库，如下所示：
systemctl stop DmServiceDmFMSServer.service
#重启数据库，如下所示：
systemctl restart DmServiceDmFMSServer.service
```

## 5.查看当前执行的查询

```sql
--查看正在执行的语句：
select * from v$sessions where state = 'ACTIVE';

--终止正在执行的语句：
--sess_id是上面查询出的结果列
call sp_close_session(sess_id);
```

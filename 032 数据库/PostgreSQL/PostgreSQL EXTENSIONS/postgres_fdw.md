# postgres_fdw

postgres fdw是一种外部访问接口，它可以被用来访问存储在外部的数据，这些数据可以是外部的pg数据库，也可以oracle、mysql等数据库，甚至可以是文件。  
  
 使用postgres_fdw产要有以下步骤：

* 创建扩展
* 创建服务
* 创建用户映射
* 创建与访问表对应的外表

到此就可以使用SELECT从外部表中访问存储在其底层远程表中的数据。同时可以 UPDATE,INSERT,DELETE远程表数据库，前提是在用户映射中指定的远程用户必须具有执行这些操作的权限。

‍

# 1.安装使用

这里创建2个数据库db01,db02,2个用户user01,user02分别用来作为本地和远端的数据库和用户。

## 1.1 初始化数据

```pgsql
--在数据库1 创建数据库和用户
psql -p 5432
create user user01 superuser  password 'user01';  
create database db01 owner=user01 TEMPLATE=template0 LC_CTYPE='zh_CN.UTF-8';

--在数据库2 创建数据库和用户
psql -p 5433
create user user02 superuser password 'user02';
create database db02 with owner=user02 TEMPLATE=template0 LC_CTYPE='zh_CN.UTF-8';

--在db02下创建表
psql -U user02 -d db02 -p 5433
create table table1 (id int, crt_Time timestamp, info text, c1 int);
create table table2 (id int, crt_Time timestamp, info text, c1 int); 

insert into table1 select generate_series(1,1000000), clock_timestamp(), md5(random()::text), random()*1000;  
insert into table2 select generate_series(1,1000000), clock_timestamp(), md5(random()::text), random()*1000;  

```

## 1.2 安装fdw

### 1.2.1安装

```pgsql
postgres@s2ahumysqlpg01-> psql
db01=# create extension postgres_fdw;
CREATE EXTENSION
```

### 1.2.2 查看系统表

 通过下列系统表可以查看数据库外部表信息。

|系统表|简命令操作|含义|
| ------------------------| ------------| --------------------|
|pg_extension|\dx|插件|
|pg_foreign_data_wrappe|\dew|支持外部数据库接口|
|pg_foreign_server|\des|外部服务器|
|pg_user_mappings|\deu|用户管理|
|pg_foreign_table|\det|外部表|

```pgsql
-- 示例：
postgres=# \deu
List of user mappings
 Server | User name 
--------+-----------
(0 rows)

postgres=# \det
 List of foreign tables
 Schema | Table | Server 
--------+-------+--------
(0 rows)
```

## 1.3 创建服务

```pgsql
db01=# create server db02 foreign data wrapper postgres_fdw options (host '192.168.2.132',port '5433', dbname 'db02');
CREATE SERVER
db01=#  
db01=# select * from pg_foreign_server ; 
   oid  | srvname | srvowner | srvfdw | srvtype | srvversion | srvacl |                srvoptions           
-------+---------+----------+--------+---------+------------+--------+-------------------------------------------
 42887 | db02    |    42860 |  42885 |         |            |        |{host=192.168.2.13,port=5433,dbname=db02}
(1 row)

--删除server
drop server db02 cascade;
```

## 1.4 创建用户映射

```pgsql
-- 创建用户 user01 与远端用户 user02 的映射 
db01=# create user mapping for user01 server db02 options (user 'user02', password 'user02');
CREATE USER MAPPING

db01=# select * from pg_user_mappings ;
 umid  | srvid | srvname | umuser | usename  |           umoptions     
-------+-------+---------+--------+----------+-------------------------------
  42892 | 42887 | db02    |  42860 | user01   | {user=user02,password=user02}
(1 row)

```

## 1.5 创建外键表

```pgsql
-- 方法一：批量导入，这种比较常见，可以一次导入一个模式下的所有表
db01=# import foreign schema public from server db02 into public;
IMPORT FOREIGN SCHEMA

db01=# \d
                 关联列表
 架构模式 |  名称  |     类型     | 拥有者 
----------+--------+--------------+--------
 public   | table1 | 所引用的外表 | user01
 public   | table2 | 所引用的外表 | user01
(2 行记录)

db01=# \det
         引用表列表
 架构模式 | 数据表 | 服务器 
----------+--------+--------
 public   | table1 | db02
 public   | table2 | db02
(2 行记录)

-- 或者指定表导入
 IMPORT FOREIGN SCHEMA  public  limit to (table1，table2) from server db02 into public;

-- 方法二：创建单个键表 
--先删除外键表
db01=# DROP FOREIGN TABLE  table1,table2 ;
DROP FOREIGN TABLE

--单个表映射
db01=# create foreign table table1(id int, crt_Time timestamp, info text, c1 int) server db02 options(schema_name 'public',table_name 'table1');
CREATE FOREIGN TABLE

db01=# create foreign table table2(id int, crt_Time timestamp, info text, c1 int) server db02 options(schema_name 'public',table_name 'table2');
CREATE FOREIGN TABLE

db01=# \d
                 关联列表
 架构模式 |  名称  |     类型     | 拥有者 
----------+--------+--------------+--------
 public   | table1 | 所引用的外表 | user01
 public   | table2 | 所引用的外表 | user01
(2 行记录)

db01=# \det
         引用表列表
 架构模式 | 数据表 | 服务器 
----------+--------+--------
 public   | table1 | db02
 public   | table2 | db02
(2 行记录)

```

## 1.6 fdw 维护

**查看数据库已经创建的外部数据表**

```pgsql
select * from pg_foreign_table;
select * from pg_user_mapping;
select * from pg_user_mappings;
select * from pg_foreign_server;
select * from pg_foreign_table;
--删除server
drop server db02 cascade;
--删除外键表
DROP FOREIGN TABLE  table2;

--元命令查询
\des  --查看外部服务器
\det  --查看创建的外部表
```

‍

‍

# 2.使用示例

## 2.1 查询操作

```pgsql
db01=# select count(*)  from table1 ;
  count  
---------
 1000000
(1 row)
 
db01=#  select  *  from table1 where id < 5 ;
 id |          crt_time          |               info               | c1  
----+----------------------------+----------------------------------+-----
  1 | 2023-07-05 14:09:30.783795 | 607a3998e35fd50ff31b1cd8c0ca0aac | 745
  2 | 2023-07-05 14:09:30.783999 | c63bec754c9c9ce3043378b94abbf0cb | 395
  3 | 2023-07-05 14:09:30.784008 | c7405a7671dd979c3979e5304557ca8c | 289
  4 | 2023-07-05 14:09:30.784012 | 6933cb7875b2818aa981dd8924a2f8b9 | 963
(4 行记录)

-- 和外部表关联查询。
db01=# SELECT t1.id, t2.crt_time FROM table1 t1 INNER JOIN table2 t2 ON t1.id = t2.id WHERE t1.id < 10;
 id |          crt_time        
----+----------------------------
  1 | 2023-07-05 14:09:38.538899
  2 | 2023-07-05 14:09:38.539144
  3 | 2023-07-05 14:09:38.539154
  4 | 2023-07-05 14:09:38.539158
  5 | 2023-07-05 14:09:38.53916
  6 | 2023-07-05 14:09:38.539163
  7 | 2023-07-05 14:09:38.539166
  8 | 2023-07-05 14:09:38.539168
  9 | 2023-07-05 14:09:38.539171
(9 行记录)

```

## 2.2 写操作

postgres_fdw 外部表一开始只支持读，PostgreSQL9.3 版本开始支持可写。  
写操作需要保证：1. 映射的用户对有表由写权限；2. 版本需要9.3 以上

```pgsql
--# 删除示例
db01=# select count(*)  from table1 ;
  count  
---------
 1000000
(1 row)
db01=# delete from  table1 where  id <= 10;
DELETE 10
db01=# select count(*)  from table1 ;
 count  
--------
 999990
(1 row)

--# 插入
db01=# insert into table1 select generate_series(1,5), clock_timestamp(), md5(random()::text), random()*1000;  
INSERT 0 5
db01=# select count(*)  from table1 ;
  count  
---------
 1000005
(1 行记录)


--# 更改
db01=# select * from table1 where  id =5 ;
 id |          crt_time          |               info               | c1  
----+----------------------------+----------------------------------+-----
  5 | 2023-07-05 14:09:30.784015 | 881e934cafd96ae68422017003f7e57d | 347
  5 | 2023-07-05 16:31:01.498914 | 4ea24281248022ebf86f68653d5edad4 | 203
(2 行记录)

db01=# update table1 set info='ahser.hu' where  id =5 ;
UPDATE 2
db01=# select * from table1 where  id =5 ;
 id |          crt_time          |   info   | c1  
----+----------------------------+----------+-----
  5 | 2023-07-05 14:09:30.784015 | ahser.hu | 347
  5 | 2023-07-05 16:31:01.498914 | ahser.hu | 203
(2 行记录)

```

‍

# 3.补充

## 3.1支持聚合下推

PostgreSQL10 增强了postgres_fdw  扩展模块的特性，可以将聚合、关联操作下推到远程PostgreSQL数据库进行，而之前的版本是将外部表相应的远程数据全部取到本地再做聚合，10版本这个心特性大幅度减少了从远程传输到本地库的数据量。提升了postgres_fdw外部表上聚合查询的性能。

```pgsql
db01=# EXPLAIN(ANALYZE on,VERBOSE on) select id,count(*) from table1  where id < 100 group by id;
                                              QUERY PLAN                                          
------------------------------------------------------------------------------------------------------
 Foreign Scan  (cost=109.75..198.89 rows=200 width=12) (actual time=148.884..148.969 rows=94 loops=1)
   Output: id, (count(*))
   Relations: Aggregate on (public.table1)
   Remote SQL: SELECT id, count(*) FROM public.table1 WHERE ((id < 100)) GROUP BY 1
 Planning Time: 0.136 ms
 Execution Time: 149.688 ms
(6 rows)

#其中 remote sql: 表示远程库上执行的SQL，此SQL为聚合查询的SQL。聚合是在远程上执行的。

```

## 3.2 FDW在PG14的新功能

1.批入导入性能提升  
 INSERT SELECT 语句将 100 万行从另一个表插入到该表所用的时间如下。postgres_fdw OPTIONS的  batch_size 参数设置为 100。这意味着一次最多向外部服务器发送 100 行：

* 没有 FDW 的本地表：6.1 秒
* 带 FDW 的远程表（改进前）：125.3 秒
* 带 FDW 的远程表（改进后）：11.1 秒

2.FDW 外部表接口支持 truncate [only|cascade] ，可能通过truncatable 参数选项控制默认为true  
 3.远程更新参数控制 ，默认情况下，所有使用的外部表postgres_fdw都假定是可更新的 。可能通过updatable参数选项控制默认为true  
 4.支持并行/异步 外部扫描，充许一个查询引用多个外部表，并行执行外部表扫描。选项async_capable，它允许并行计划和执行外部表扫描。  
 5.LIMIT TO 子分区,如果指定IMPORT FOREIGN SCHEMA … LIMIT  TO，则允许postgres_fdw导入表分区。默认情况下postgres_fdw不允许导入表分区，因为可以使用根分区访问数据。如果用户想要导入分区表分区，PostgreSQL  14添加了一个新的选项LIMIT TO指定子分区导入。  
 6.保持连接，添加了一个新选项keep_connections，以保持连接处于活动状态，以便后续查询可以重用它们。默认情况下，此选项处于on状态，但如果off，则在事务结束时将丢弃连接。

* 如果在关闭这个选项，可以使用  ALTER SERVER youserrvername  OPTIONS (keep_connections ‘off’);
* 打开使用ALTER SERVER youserrvername   options (set keep_connections ‘on’);

7.活动和有效的连接列表，添加postgres_fdw_get_connections函数以报告打开的外部服务连接。该函数将打开的连接名本地会话返回到postgres_fdw的外部服务。它还输出连接的有效性。

* 查询从本地会话到外部服务器建立的所有打开连接的外部服务器名称: SELECT * FROM postgres_fdw_get_connections() ORDER BY 1;
* 丢弃从本地会话到外部服务器建立的所有打开连接： select postgres_fdw_disconnect_all();

‍

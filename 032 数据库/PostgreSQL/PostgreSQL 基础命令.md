# PostgreSQL 基础命令

# 登录命令

参考[PostgreSQL 内置命令](PostgreSQL%20内置命令.md)

```pgsql
--日常登录本机
psql
--登录完整方式
psql -h localhost -p 5432 -d dataname -U username
-- 我们也可以用 URI 的方式连接数据库：
psql postgresql://jy2web@127.0.0.1:5432/jy2db

-- 登录后常用命令
\q                   -- 退出控制台
\l                   -- 列出所有数据库
\c [database_name]   -- 连接其他数据库
\c - [user_name]     -- 切换用户
\d                   -- 列出数据库中所有表
\dt                  -- 列出数据库中所有表
\d [table_name]      -- 显示指定表的结构
\df                  -- 显示所有存储过程
\di                  -- 列出连接数据库中所有index
\dv                  -- 列出连接数据库中所有view
\du                  -- 显示所有用户
\dn                  -- 显示所有的schema
\dp		     -- 显示表的权限分配情况
\s                   -- 查看历史命令
\password            -- 设置密码
\h                   -- 查看SQL命令的解释，比如\h select
\?                   -- 查看psql命令列表
\conninfo            -- 列出当前数据库和连接的信息
\du                  -- 列出所有用户
\e                   -- 打开文本编辑器
\x                   -- 已列的形式展示
```

‍

# 用户管理

```pgsql
-- 创建用户
CREATE USER/ROLE name [ [ WITH ] option [ ... ] ] 
-- 创建用户（user）和创建角色（role）唯一的区别是用户默认可以登录，而创建的角色默认不能登录。创建用户和角色的各个参数选项是一样的。

option:
    | SUPERUSER | NOSUPERUSER      --超级权限，拥有所有权限，默认nosuperuser。
    | CREATEDB | NOCREATEDB        --建库权限，默认nocreatedb。
    | CREATEROLE | NOCREATEROLE    --建角色权限，拥有创建、修改、删除角色，默认nocreaterole。
    | INHERIT | NOINHERIT          --继承权限，可以把除superuser权限继承给其他用户/角色，默认inherit。
    | LOGIN | NOLOGIN              --登录权限，作为连接的用户，默认nologin，除非是create user（默认登录）。
    | REPLICATION | NOREPLICATION  --复制权限，用于物理或则逻辑复制（复制和删除slots），默认是noreplication。
    | BYPASSRLS | NOBYPASSRLS      --安全策略RLS权限，默认nobypassrls。
    | CONNECTION LIMIT connlimit   --限制用户并发数，默认-1，不限制。正常连接会受限制，后台连接和prepared事务不受限制。
    | PASSWORD 'password' | PASSWORD NULL --设置密码，密码仅用于有login属性的用户，不使用密码身份验证，则可以省略此选项。可以选择将空密码显式写为PASSWORD NULL。
    | VALID UNTIL 'timestamp'      --密码有效期时间，不设置则永不失效。
    | IN ROLE role_name [, ...]    --新角色将立即添加为新成员。
    | IN GROUP role_name [, ...]   --同上
    | ROLE role_name [, ...]       --ROLE子句列出一个或多个现有角色，这些角色自动添加为新角色的成员。 （这实际上使新角色成为“组”）。
    | ADMIN role_name [, ...]      --与ROLE类似，但命名角色将添加到新角色WITH ADMIN OPTION，使他们有权将此角色的成员资格授予其他人。
    | USER role_name [, ...]       --同上
```

bash命令行方式创建用户

```bash
createuser [ connection-option ...] [ option ...] [ username ]

username # 指定要创建的 PostgreSQL 用户的名称。该名称必须不同于该 PostgreSQL 安装中的所有现有角色。

[option]:
	-c number  # 设置新用户的最大连接数。默认设置为无限制.
	-d  # 新用户将被允许创建数据库。-D 不允许新用户创建数据库。这是默认值.
	-e  # 回显 createuser 生成并发送到服务器的命令.
	-g  # 指示将作为新成员立即添加到的角色。可以通过编写多个-g开关来指定要将此角色作为成员添加到的多个角色.
	-i  # 新角色将自动继承其所属角色的特权。这是默认值.
	-L  # 将不允许新用户登录。-l  新用户将被允许登录,这是默认值.
	-P  # 如果提供，createuser 将提示 Importing 新用户的密码。如果您不打算使用密码身份验证，则没有必要.
	-r  # 将允许新用户创建新角色(即，该用户将具有CREATEROLE特权)。 -R 不允许新用户创建新角色。这是默认值.
	-s  # 新用户将是超级用户.
	--replication   # 新用户将拥有REPLICATION特权，有关CREATE ROLE的文档中对此进行了更详细的描述。

[ connection-option ...]:
	-h host       # 指定运行服务器的计算机的主机名。如果该值以斜杠开头，则将其用作 Unix 域套接字的目录。
	-p port       # 指定服务器正在侦听连接的 TCP 端口或本地 Unix 域套接字文件 extensions。
  	-U username   # 连接的用户名(不是要创建的用户名)。
	-w            # 切勿发出密码提示。
	-W            # 强制 createuser 提示 Importing 密码(用于连接到服务器，而不 Importing 新用户的密码)。

```

‍

# 权限管理

```pgsql
GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON { [ TABLE ] table_name [, ...]
         | ALL TABLES IN SCHEMA schema_name [, ...] }
    TO role_specification [, ...] [ WITH GRANT OPTION ]

-- 权限可以是:
-----------------------------------------------------------------------------
SELECT     -- 允许从指定表，视图或序列的任何列或列出的特定列进行SELECT。也允许使用COPY TO。在UPDATE或DELETE中引用现有列值也需要此权限。对于序列，此权限还允许使用currval函数。对于大对象，此权限允许读取对象。
INSERT     -- 允许将新行INSERT到指定的表中。如果列出了特定列，则只能在INSERT命令中为这些列分配（因此其他列将接收默认值）。也允许COPY FROM。
UPDATE     -- 允许更新指定表的任何列或列出的特定列，需要SELECT权限。
DELETE     -- 允许删除指定表中的行，需要SELECT权限。
TRUNCATE   -- 允许在指定的表上创建触发器。
REFERENCES -- 允许创建引用指定表或表的指定列的外键约束。
TRIGGER    -- 允许在指定的表上创建触发器。 
CREATE     -- 对于数据库，允许在数据库中创建新的schema、table、index。
CONNECT    -- 允许用户连接到指定的数据库。在连接启动时检查此权限。
TEMPORARY\TEMP -- 允许在使用指定数据库时创建临时表。
EXECUTE    -- 允许使用指定的函数或过程以及在函数。
USAGE      -- 对于schema，允许访问指定模式中包含的对象；对于sequence，允许使用currval和nextval函数。对于类型和域，允许在创建表，函数和其他模式对象时使用类型或域。
ALL PRIVILEGES -- 一次授予所有可用权限。
------------------------------------------------

ON -- 授权对象：table， view，sequence。

TO -- role_specification 可以是 [username | rolename | SESSION_USER]

WITH GRANT OPTION   -- 表示该用户可以将自己拥有的权限授权给别人

--单表授权：授权zjy账号可以访问schema为zjy的zjy表
grant select,insert,update,delete on zjy.zjy to zjy;
```

撤销权限

```pgsql
REVOKE  { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON { [ TABLE ] table_name [, ...]
         | ALL TABLES IN SCHEMA schema_name [, ...] }
    FROM { [ GROUP ] role_name | PUBLIC } [, ...]


 --##移除用户zjy在schema zjy上所有表的select权限
 revoke select on all tables in schema zjy from zjy;
```

修改owner

```pgsql
 alter database test owner to rcb
 alter table test owner to rcb  
```

# 模式 Schema

一个数据库包含一个或多个已命名的模式，模式又包含表。模式还可以包含其它对象， 包括数据`类型`​、`函数`​、`操作符`​等。同一个对象名可以在不同的模式里使用而不会导致冲突； 比如，`herschema`​和`myschema`​都可以包含一个名为`mytable`​的表。 和数据库不同，模式不是严格分离的：只要有权限，一个用户可以访问他所连接的数据库中的任意模式中的对象。

我们需要模式的原因有好多：

- 允许多个用户使用一个数据库而不会干扰其它用户。
- 把数据库对象组织成逻辑组，让它们更便于管理。
- 第三方的应用可以放在不同的模式中，这样它们就不会和其它对象的名字冲突。

模式类似于操作系统层次的目录，只不过模式不能嵌套。

‍

我们可以使用 CREATE SCHEMA 语句来创建模式，语法格式如下：

```pgsql
-- 自定义创建模式（schema）
-- 注意：如果不创建scheme，并且语句中不写scheme，则默认scheme使用内置的public。
create schema 模式名称;

-- 创建和当前用户同名模式（schema）
-- 注意：用户名与 schema 同名，且用户具有访问改 schema 的权限，用户连入数据库时，默认即为当前 schema。
create schema AUTHORIZATION CURRENT_USER;

-- 显示当前的模式
show search_path

-- 查看数据库下的所有（schema）
select * from information_schema.schemata;

--切换模式
set search_path to for_db02;
```

# 数据库管理

```pgsql
--查询所有数据库
select datname from pg_database;
--创建数据库
create database 数据库名 owner 所属用户 encoding UTF8;

--注意：创建完数据库，需要切换到数据库下，创建和当前用户同名的scheme，删除数据库后schema也会一并删除：
-- 重新登陆到新数据库下，执行如下语句
create schema AUTHORIZATION CURRENT_USER;

-- 删除数据库
drop database 数据库名;
```

关闭数据库所有会话，

注意：删库前需要关闭所有会话，不然会提示：

```pgsql
ERROR:  database "mydb" is being accessed by other users
DETAIL:  There are 8 other sessions using the database.

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname='mydb' AND pid<>pg_backend_pid();

-- pg_terminate_backend  用来终止与数据库的连接的进程id的函数。
-- pg_stat_activity      是一个系统表，用于存储服务进程的属性和状态。
-- pg_backend_pid()      是一个系统函数，获取附加到当前会话的服务器进程的ID。

-- 执行这个语句后就可以使用drop database 删除数据库了。
```

‍

# 表管理

```pgsql
-- 建表模板语句
create table "t_user" (
 "id" bigserial not null,
 "username" varchar (64) not null,
 "password" varchar (64) not null,
 "create_time" timestamp not null default current_timestamp,
 "update_time" timestamp not null default current_timestamp,
 constraint t_user_pk primary key (id)
);

comment on column "t_user"."id" is '主键';
comment on column "t_user"."username" is '用户名';
comment on column "t_user"."password" is '密码';
comment on column "t_user"."create_time" is '创建时间';
comment on column "t_user"."update_time" is '更新时间';

------------------------------------------------------------

--## 查询schema中所有表
select table_name from information_schema.tables where table_schema = 'public';

--## 根据已有表结构创建表
create table if not exists 新表 (like 旧表 including indexes including comments including defaults);

--## 删除表
drop table if exists "t_template" cascade;

--## 清空表数据-postgresql的自增字段是通过序列sequence实现的，所以清空表后还需要还原序列
truncate table table_name restart identity; --alter sequence seq_name start 1;

--## 查询注释
SELECT
a.attname as "字段名",
col_description(a.attrelid,a.attnum) as "注释",
concat_ws('',t.typname,SUBSTRING(format_type(a.atttypid,a.atttypmod) from '(.*)')) as "字段类型"
FROM
pg_class as c,
pg_attribute as a,
pg_type as t
WHERE
c.relname = 't_batch_task'
and a.atttypid = t.oid
and a.attrelid = c.oid
and a.attnum>0;
```

# 索引管理

```pgsql
--## 创建索引
drop index if exists t_user_username;
create index t_user_username on t_user (username);

--## 创建唯一索引
drop index if exists t_user_username;
create index t_user_username on t_user (username);

--## 查看索引
\d t_user
```

# 查询SQL

注意：PostgreSQL中的字段大小写敏感，而且只认小写字母，查询时需注意。其他与基本sql大致相同。

```pgsql
--## to_timestamp() 字符串转时间
select * from t_user
where create_time >= to_timestamp('2023-01-01 00:00:00', 'yyyy-mm-dd hh24:MI:SS');

--## to_char 时间转字符串
select to_char(create_time, 'yyyy-mm-dd hh24:MI:SS') from t_user;

--## 时间加减
-- 当前时间加一天
SELECT NOW()::TIMESTAMP + '1 day';
SELECT NOW() + INTERVAL '1 DAY';
SELECT now()::timestamp + ('1' || ' day')::interval
-- 当前时间减一天
SELECT NOW()::TIMESTAMP + '-1 day';
SELECT NOW() - INTERVAL '1 DAY';
SELECT now()::timestamp - ('1' || ' day')::interval
-- 加1年1月1天1时1分1秒
select NOW()::timestamp + '1 year 1 month 1 day 1 hour 1 min 1 sec';


--## like 模糊查询
SELECT * FROM 表名 WHERE 字段 LIKE ('%关键字%');


--## substring字符串截取
--从第一个位置开始截取，截取4个字符,返回结果:Post
SELECT SUBSTRING ('PostgreSQL', 1, 4);
-- 从第8个位置开始截取，截取到最后一个字符，返回结果:SQL
SELECT SUBSTRING ('PostgreSQL', 8);
--正则表达式截取，截取'gre'字符串
SELECT SUBSTRING ('PostgreSQL', 'gre');
```

‍

# 执行sql脚本

方式一：先登录再执行

```
\i testdb.sql
```

方式二：通过psql执行

```
psql -d testdb -U postgres -f /pathA/xxx.sql
```

# JDBC 连接串常用参数

- PostgreSQL JDBC 官方驱动下载地址：https://jdbc.postgresql.org/download/
- PostgreSQL JDBC 官方参数说明文档：https://jdbc.postgresql.org/documentation/use/
- 驱动类：`driver-class-name=org.postgresql.Driver`​

## 单机 PostgreSQL 连接串

```
url: jdbc:postgresql://10.20.1.231:5432/postgres?
binaryTransfer=false&forceBinary=false&reWriteBatchedInserts=true
```

- ​`binaryTransfer=false`​：控制是否使用二进制协议传输数据，`false`​ 表示不适用，默认为 `true`​
- ​`forceBinary=false`​：控制是否将非 ASCII 字符串强制转换为二进制格式，`false`​ 表示不强制转换，默认为 `true`​
- ​`reWriteBatchedInserts=true`​：控制是否将批量插入语句转换成更高效的形式，`true`​ 表示转换，默认为 `false`​

‍

## 集群PostgreSQL 连接串

集群PostgreSQL，连接串如下：

```
url: jdbc:postgresql://10.20.1.231:5432/postgres?
binaryTransfer=false&forceBinary=false&reWriteBatchedInserts=true&targetServerType=master&loadBalanceHosts=true
```

- 单机 PostgreSQL 连接串的所有参数。
- ​`targetServerType=master`​：只允许连接到具有所需状态的服务器，可选值有：

  - ​`any`​：默认，表示连接到任何一个可用的数据库服务器，不区分主从数据库；
  - ​`master`​：表示连接到主数据库，可读写；
  - ​`slave`​：表示连接到从数据库，可读，不可写；
  - 其他不常用值：primary, master, slave, secondary, preferSlave, preferSecondary and preferPrimary。
- ​`loadBalanceHosts=true`​：控制是否启用主从模式下的负载均衡，`true`​ 表示启用，开启后依序选择一个 ip1:port 进行连接，默认为 `false`​。

# Oracle 常用语句

### 数据库（启动、实例、监听、登录）

```sql
  --监听启停
lsnrctl stop
lsnrctl start 
--登录数据库dba
sqlplus / as sysdba  
SQL> shutdown [ normal  transactional  immediate  abort ]
SQL> startup
NORMAL              ：不允许新的连接、等待会话结束、等待事务结束、做一个检查点并关闭数据文件。启动时不需要实例恢复。 
TRANSACTIONAL：不允许新的连接、不等待会话结束、等待事务结束、做一个检查点并关闭数据文件。启动时不需要实例恢复。 
IMMEDIATE          ：不允许新的连接、不等待会话结束、不等待事务结束、做一个检查点并关闭数据文件。没有结束的事务是自动rollback的。启动时不需要实例恢复。 
ABORT                  ：不允许新的连接、不等待会话结束、不等待事务结束、不做检查点且没有关闭数据文件。启动时自动进行实例恢复。
```

### 导入sql脚本

```sql
--进入到sql文件目录下，登录需要导入文件的用户
sqlplus username/password
@/opt/test.sql; 
commit;

-- 该方式有可能导致中文乱码问题
-- 正确操作：打开plsql，新建 >命令窗口 >编辑器 >粘贴sql语句 >执行 >commit
```

### 查询相关

```sql
--查看所有用户名
select * from all_users;
--查看当前用户
select * from user_users;  
--查看当前用户权限:
select * from session_privs;
select * from user_role_privs;

--查看某个用户所拥有的角色
select * from dba_role_privs where grantee='JY2WEB';
--查看某个角色所拥有的权限
select * from dba_sys_privs where grantee='CONNECT';
--Oracle 的角色存放在表 dba_roles 中，某角色包含的系统权限存放在  dba_sys_privs 中，包含的对象权限存放在 dba_tab_privs 中。

--查看所有表空间
select * from v$tablespace;
--查询数据库名：
show parameter db_name;
--查询实例名：
show parameter instance_name;
--查询db_unique_name;
show parameter db_unique_name;
--查询数据库域名： 
show parameter domain;
--查询数据库服务器
show parameter service;
show parameter names;
--数据库服务名：
--此参数是数据库标识类参数，用service_name表示。数据库如果有域，则数据库服务名就是全局数据库名；如果没有，则数据库服务名就是数据库名。
show parameter service_name;

--查询当前用户下的表
select * from user_tables;
select * from all_tables where owner = 'JY2WEB';
--查询用户的表,视图等
select * from user_tab_comments;
select * from all_tab_comments where owner='JY2WEB';

--查询表空间中的所有表
select table_name from all_tables where TABLESPACE_NAME='表空间';    --表空间名字一定要大写
--查询表所在的表空间
select * from user_tables where table_name='表名';                  --表名一定要大写

--查询表空间大小
select tablespace_name, sum(bytes)/1024/1024 as MB from dba_data_files group by tablespace_name;
select tablespace_name, sum(bytes)/1024/1024/1024 as GB from dba_data_files group by tablespace_name;

--查询数据库文件目录
select * from dba_data_files;
select name from v$datafile;


--查询逻辑目录
select * from dba_directories;
select * from dba_directories where DIRECTORY_NAME='DATA_PUMP_DIR';

--查询数据库字符集
select userenv('language') from dual;

--查看归档日志信息
select name,sequence# from v$archived_log;


--查询内存配置
show parameter memory;

-- 查看表空间使用情况
select * from (  
Select a.tablespace_name,  
to_char(a.bytes/1024/1024,'999,999.999') total_bytes,  
to_char(b.bytes/1024/1024,'999,999.999') free_bytes,  
to_char(a.bytes/1024/1024 - b.bytes/1024/1024,'999,999.999') use_bytes,  
to_char((1 - b.bytes/a.bytes)*100,'99.99') || '%'use  
from (select tablespace_name,  
sum(bytes) bytes  
from dba_data_files  
group by tablespace_name) a,  
(select tablespace_name,  
sum(bytes) bytes  
from dba_free_space  
group by tablespace_name) b  
where a.tablespace_name = b.tablespace_name  
union all  
select c.tablespace_name,  
to_char(c.bytes/1024/1024,'999,999.999') total_bytes,  
to_char( (c.bytes-d.bytes_used)/1024/1024,'999,999.999') free_bytes,  
to_char(d.bytes_used/1024/1024,'999,999.999') use_bytes,  
to_char(d.bytes_used*100/c.bytes,'99.99') || '%'use  
from  
(select tablespace_name,sum(bytes) bytes  
from dba_temp_files group by tablespace_name) c,  
(select tablespace_name,sum(bytes_cached) bytes_used  
from v$temp_extent_pool group by tablespace_name) d  
where c.tablespace_name = d.tablespace_name  
) order by tablespace_name;
```

### 创建表空间

```sql
#创建表空间
create tablespace JY2WEB datafile '/data/oradata/ORCL/jy2web01.dbf' size 200m autoextend on next 100m maxsize unlimited;
--datafile:表空间文件路径
--size:表空间初始大小
--autoextend:是否启用自动扩展空间
--next:表示数据文件满了以后,扩展的大小
--maxsize:表示数据文件的最大大小,UNLIMITED 表示无限的表空间.   
------删除表空间下所有数据
--删除空的表空间，但是不包含物理文件
drop tablespace tablespace_name;
--删除非空表空间，但是不包含物理文件
drop tablespace tablespace_name including contents;
--删除空表空间，包含物理文件
drop tablespace tablespace_name including datafiles;
--删除非空表空间，包含物理文件
drop tablespace tablespace_name including contents and datafiles;
--如果其他表空间中的表有外键等约束关联到了本表空间中的表的字段，就要加上CASCADE CONSTRAINTS
drop tablespace tablespace_name including contents and datafiles CASCADE CONSTRAINTS;

--通过删除用户删除所有数据
drop user user_name cascade;
-- select sid,serial# from v$session where username='JY2WEB';
-- alter system kill session '150,9019';

```

### 创建用户

```sql
--创建新用户：
--语法：create user 用户名 identified by 密码;
create user userName identified by xxxxx;
alter user username default tablespace tablespaceName;
create user JY2WEB identified by Ninestar123 default tablespace jy2web;

--修改用户名密码
alter user username identified by newxxxxx;

--为刚创建的用户解锁语法：
--语法：alter user 用户名 account unlock;
--指令：alter user root account unlock; //用户解锁
--指令：alter user root account lock; //用户锁住
alter user  root account unlock;
--授予新登陆的用户创建权限:
--语法：grant create session to 用户名 ;
grant create session to root;
grant connect,resource,dba to sccweb;

--删除用户和表空间及文件
drop user jy2app cascade;
```

### 授权

```sql
--管理员登录，通过授权实现
GRANT CREATE SEQUENCE TO ‘YOUR_USER_NAME’;   #序列权限
--授予新登陆的用户创建权限:
--语法：grant create session to 用户名 ;
grant create session sysbackup to root;
grant connect,resource,dba to sccweb;
```

‍

### PDB/CDB相关

```sql
-- 查询该容器是CDB 还是非CDB
select name,cdb,open_mode,con_id from v$database;
-- 查看当前容器
show con_name;
-- 查看所创建的PDB
show pdbs;
-- 切换到PDB
alter session set container=PDBNAME;
-- 切回到CDB
alter session set container=CDB$ROOT;
-- 打开名称为pdboaec的pdb服务
alter pluggable database pdboaec open;
```

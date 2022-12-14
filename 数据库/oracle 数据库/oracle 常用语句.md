#database/oracle

### 连接数据库

```sql
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".ZHS16GBK
--本地连接
--sys用户必须以sysdba身份登录
sqlplus / as sysdba  #以操作系统权限认证的oracle sys管理员登陆，必须切换到linux的oracle用户下。
sqlplus sys/passwd as sysdba  #使用sys密码登录，安装过程可在

--远程连接
sqlplus jy2web/Ninestar2021@10.60.104.6:1521/jydbcms
-- expdp impdp 服务端工具导出导入
expdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp  schemas=user logfile=user.log
impdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp schemas=user logfile=user.log;

-- exp imp 客户端工具远程导入导出
exp jy2web/Ninestar2022@192.168.10.150:1521/orcl file=/tmp/jy2web_20220510.dmp full=y
imp jy2web/Ninestar2022@192.168.10.150:1521/orcl file=/tmp/jy2web_20220510.dmp log=/tmp/imp_jy2web.log full=y

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
select username from all_users;
--查看所有表空间
select name from v$tablespace;
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

--查询表空间大小
select tablespace_name, sum(bytes)/1024/1024 as MB from dba_data_files group by tablespace_name;
select tablespace_name, sum(bytes)/1024/1024/1024 as GB from dba_data_files group by tablespace_name;

-- 查询所有表

--查询逻辑目录
select * from dba_directories;

--查询数据库字符集
select userenv('language') from dual;
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


```sql
SELECT a.tablespace_name "表空间名称",   
  
total / (1024 * 1024) "表空间大小(M)",   
  
free / (1024 * 1024) "表空间剩余大小(M)",   
  
(total - free) / (1024 * 1024 ) "表空间使用大小(M)",   
  
total / (1024 * 1024 * 1024) "表空间大小(G)",   
  
free / (1024 * 1024 * 1024) "表空间剩余大小(G)",   
  
(total - free) / (1024 * 1024 * 1024) "表空间使用大小(G)",   
  
round((total - free) / total, 4) * 100 "使用率 %"   
  
FROM (SELECT tablespace_name, SUM(bytes) free   
  
FROM dba_free_space   
  
GROUP BY tablespace_name) a,   
  
(SELECT tablespace_name, SUM(bytes) total   
  
FROM dba_data_files   
  
GROUP BY tablespace_name) b   
  
WHERE a.tablespace_name = b.tablespace_name
```

### 创建用户

```sql
--创建新用户：
--语法：create user 用户名 identified by 密码;
create user userName identified by xxxxx;
alter user username default tablespace tablespaceName;
create user userName identified by Ninestar123 default tablespace tablespaceName;

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

### 数据库启动关闭

```sql
su - oracle   # 切换oracle
lsnrctl stop  # 关闭实例监听
sqlplus sys/ as sysdba  # 登录数据库dba
SQL> shutdown immediate # 关闭数据库

------------------------------
su - oracle
sqlplus sys/ as sysdba
SQL> startup
lsnrctl start 

```




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

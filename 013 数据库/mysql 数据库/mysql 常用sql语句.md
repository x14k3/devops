# mysql 常用sql语句

## 数据库信息查看

```sql
-- 查看字符集
show variables like 'character_set_%';
-- 查看数据库时区
show variables like '%time_zone';

```

## 数据库创建

```sql
-- 创建数据库
create database jy2web character set utf8mb4;
-- 删除数据库
drop database jy2web;
-- 删除库中的所有表
SELECT concat('DROP TABLE IF EXISTS ', table_name, ';')
FROM information_schema.tables
WHERE table_schema = 'jy2web';
```

## 用户相关

```sql
CREATE USER 'jy2web'@'localhost' IDENTIFIED BY '123456';   #仅限本机登录
CREATE USER 'jy2web'@'192.168.1.1' IDENDIFIED BY '123456'; #指定ip远程登录
CREATE USER 'jy2web'@'%' IDENTIFIED BY '123456';           #所有电脑可远程登录
-- mysql 8.0
CREATE USER 'jy2web'@'%' IDENTIFIED with mysql_native_password by 'Ninestar@2021';

------------------- 删除用户 -------------------
DROP USER 'jy2bpc'@'localhost';

------------------- 修改用户密码 -------------------
--- 5.7版本
update mysql.user set password='newpassword' where user='root';
--- 8.0以上版本 需要指定密码认证方式
alter user 'root'@'%' identified with mysql_native_password by 'Ninestar@2021';
flush privileges;

------------------- 跳过密码验证 -------------------
--1.关闭数据库，修改配置文件 vim /etc/my.cnf
--2.添加：跳过权限验证 skip-grant-tables
--3.重启数据库，空密码即可登录
--4.修改密码
--5.还原my.cnf
--6.重启数据库

------------------- root远程登陆 -------------------
mysql -uroot -p
update mysql.user set host='%', plugin='mysql_native_password' where user='root'; # 不要更换plugin，否则以前的密码会失效
flush privileges;
select host, user, plugin from mysql.user;


```

mysql 8.0+ 首次更改密码报错解决  You must reset your password using ALTER USER statement before

```bash
#修改密码
mysql> alter user 'root'@'localhost' identified by 'Ninestar@123';
mysql>flush privileges；
```

‍

‍

## 权限相关

```bash
#权限1,权限2,...权限n代表
#select,insert,update,delete,create,drop,index,alter,grant,references,reload,shutdown,process,file等14个权限
grant all privileges on jy2web.* to jy2web@'%';
grant all privileges on jy2web.* to jy2web@'%' identified by 'Ninestar@2021';
# 刷新权限
flush privileges;
# 删除权限
REVOKE SELECT ON databasename.tablename FROM 'jy2gm'@'%';
# 查看权限
SHOW GRANTS FOR 'jy2gm'@'%';
# 更新视图的definer：
update views set definer='jy2web' where table_name='xxxxx';

```

## 函数相关

```Bash
drop procedure  # 删除存储过程
drop function   # 删除存储函数

select name from mysql.proc where db = 'xx' and type = 'PROCEDURE'   # 存储过程
select name from mysql.proc where db = 'xx' and type = 'FUNCTION'    # 函数

```

## 视图相关

```sql
-- 查看所有视图的定义者
select TABLE_SCHEMA,TABLE_NAME,DEFINER from information_schema.VIEWS;

-- 修改视图定义者
select concat("alter DEFINER=`jy2gm`@`%` SQL SECURITY DEFINER VIEW `",TABLE_SCHEMA,"`.",TABLE_NAME," as ",VIEW_DEFINITION,";") from information_schema.VIEWS where DEFINER = '@%';
```

## 存储过程相关

```bash

```

‍

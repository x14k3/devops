

### 忘记root密码

```bash
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
```

### 允许root远程连接

```bash
#注释掉绑定IP
vim /etc/mysql/mysql.conf.d/mysqld.cnf
#bind-address = 127.0.0.1


mysql -u root -p

use mysql;
select user, host, plugin, authentication_string from user;

#修改root用户允许所有主机访问
CREATE USER 'root'@'%' IDENTIFIED BY 'yourpassword';
ALTER  USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY  'yourpassword';


#赋予root用户所有权限
GRANT ALL ON *.* TO `root`@`%` WITH GRANT OPTION;

flush privileges;
```

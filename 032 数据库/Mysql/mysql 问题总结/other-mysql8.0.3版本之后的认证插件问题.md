# other-mysql8.0.3版本之后的认证插件问题

　　‍

　　从MySQL 8.0开始，默认身份验证插件已从`mysql_native_password`​更改为`caching_sha2_password`​。如果你使用的是较旧的MySQL客户端，它可能无法连接到数据库服务器，并显示错误提示_“无法加载身份验证插件’caching\_sha2\_password’”。

```bash
[root@kvm-test ~]# mysql -utest -p8ql6yhy -h 10.10.0.11
ERROR 2059 (HY000): Authentication plugin 'caching_sha2_password' cannot be loaded: /usr/lib64/mysql/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory
[root@kvm-test ~]# 
```

### 方案一：升级客户端版本

　　这个比较简单，不用展开。

　　‍

### 方案二：设置使用旧的 `mysql_native_password`​ 方式

```bash
#进入MySQL
mysql -uroot -p

#修改账户密码加密规则并更新用户密码：
# 修改加密规则，密码永不过期
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password' PASSWORD EXPIRE NEVER;
# 更新一下用户的密码
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

#刷新权限并重置密码
flush privileges;

#重置密码
alter user 'root'@'localhost' identified by 'dgdggdgdg';
```

　　‍

　　‍

　　附：

```bash
------------------- 修改用户密码 -------------------
# 5.7版本
update mysql.user set password='newpassword' where user='root';
# 8.0以上版本 需要指定密码认证方式
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

　　‍

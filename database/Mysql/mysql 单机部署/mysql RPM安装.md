

[https://downloads.mysql.com/archives/community/](https://downloads.mysql.com/archives/community/)

```bash
# 下载mysql rpm安装包 [mysql-8.0.26-1.el7.x86_64.rpm-bundle.tar]
# https://downloads.mysql.com/archives/community/

# 关闭防火墙和 selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
systemctl stop firewalld && systemctl disable firewalld

# 修改系统字符
cp /etc/locale.conf{,.bak}
echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf
source /etc/locale.conf

# 卸载自带的mariadb数据库
rpm -qa | grep -i mariadb 
yum -y remove mariadb*
# 修改主机名
hostnamectl set-hostname test01
# 解压 安装
tar -xvf mysql-8.0.26-1.el7.x86_64.rpm-bundle.tar 
yum -y install ./mysql-community-*.rpm

# 修改my.cnf配置文件
vim /etc/my.cnf
-------------------------------------------------
[client]
# 连接端口号，默认 3306
port=3306
# 用于本地连接的 socket 套接字
socket=/var/lib/mysql/mysql.sock

[mysql]
# 设置默认字符编码
default_character-set=utf8mb4

[mysqld]
# 数据存放目录
datadir=/var/lib/mysql
# sock文件（）
socket=/var/lib/mysql/mysql.sock
# 错误日志路径
log-error=/var/log/mysqld.log
# pid文件目镜
pid-file=/var/run/mysqld/mysqld.pid
# 默认字符集
character-set-server=utf8
# 最大连接数
max_connections=2000
# 是否支持符号链接:否
symbolic-links=0

# 因为二进制日志的一个重要功能是用于主从复制，而存储函数有可能导致主从的数据不一致。
# 所以当开启二进制日志后，参数log_bin_trust_function_creators就会生效，限制存储函数的创建、修改、调用。
# 设置为1，则不会限制。
log_bin_trust_function_creators=1
# 大小写敏感（mysql 8.0版本，mysql初始化后就不支持修改lower_case_table_names参数了）
lower_case_table_names=1
default_authentication_plugin=mysql_native_password
-------------------------------------------------

# 启动数据库
systemctl start mysqld
grep 'password' /var/log/mysqld.log

# 运行安全配置向导
mysql_secure_installation 

# 设置root远程登录并修改认证方式
mysql -uroot -p
sql> CREATE USER 'root'@'%' IDENTIFIED BY 'your_password';
sql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
sql> FLUSH PRIVILEGES;
sql> select host, user, plugin from mysql.user;
```

‍

数据库数据目录迁移步骤

该操作一定要在刚部署完数据库软件后进行。

```bash
# 停止数据库服务
systemctl stop mysqld

# 创建数据库目录
mkdir -p /data/mysql ; chown -R mysql.mysql /data/mysql

# 修改my.cnf配置文件
vim /etc/my.cnf
-------------------------------------------------
[client]
# 连接端口号，默认 3306
port=3306
# 用于本地连接的 socket 套接字
socket=/data/mysql/mysql.sock

[mysql]
# 设置默认字符编码
default_character_set=utf8mb4

[mysqld]
# 数据存放目录
datadir=/data/mysql
# sock文件目录
socket=/data/mysql/mysql.sock
# 错误日志路径
log-error=/data/mysql/mysqld.log
# pid文件目镜
pid-file=/data/mysql/mysqld.pid
# 默认字符集
character_set_server=utf8
# 最大连接数
max_connections=2000
# 是否支持符号链接:否
symbolic-links=0
# 控制是否可以信任存储函数创建者
log_bin_trust_function_creators=1
# 大小写敏感
lower_case_table_names=1
default_authentication_plugin=mysql_native_password
-------------------------------------------------

# 重启数据库
systemctl restart mysqld

# 删除原来的数据库目录
mv /var/lib/mysql /tmp/
# rm -rf /var/lib/mysql /tmp/
```

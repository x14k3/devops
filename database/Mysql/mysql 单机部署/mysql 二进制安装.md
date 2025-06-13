
- RPM、Yum（Red Hat Enterprise Linux/Oracle Linux）：安装方便，安装速度快，无法定制；
- 二进制（Linux Generic）：不需要安装，解压即可使用，不能定制功能；
- 编译安装/源码安装（Source Code）：安装过程复杂，需要各种依赖库，可定制  ；  
  5.5版本之前：./configure , make , make install
  5.5版本之后：cmake , gmake  
  **注意：MySQL apl、beta、RC版本都不要选，一定要选择GA版（稳定版）**   
  下载地址：[https://dev.mysql.com/downloads/mysql/](https://dev.mysql.com/downloads/mysql/)

‍


通用二进制版本： 本文档采用此方式安装

https://downloads.mysql.com/archives/community/

选择版本，再选择Operating System: Linux - Generic

![img](http://jpg.fxkjnj.com/picgo/202212051359315.png)​

‍

### 下载、环境准备

```bash
# 查看是否存在MariaDB
rpm -qa|grep mariadb
# 卸载mariadb
yum remove mariadb*
# 下载、解压
wget https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.33-linux-glibc2.12-x86_64.tar.xz
mkdir -p /data ; tar xf mysql-8.0.33-linux-glibc2.12-x86_64.tar.xz -C /data
mv mysql-8.0.33-linux-glibc2.12-x86_64/ mysql
# 建立mysql用户和组(如果有可忽略)
useradd -s /sbin/nologin mysql -M

# 创建mysql 数据目录，日志目录；并修改权限
mkdir -p /data/mysql/data ;mkdir -p /data/mysql/logs
chown -Rf mysql.mysql /data/mysql

# 修改环境变量
cat << EOF >>/etc/profile  
export PATH=$PATH:/data/mysql/bin
EOF
source /etc/profile
```

### 准备my.cnf 配置文件

​`vim /etc/my.cnf`​

```bash
[mysqld]
user=mysql
port=3306
mysqlx_port=33060
basedir=/data/mysql
datadir=/data/mysql/data
socket=/data/mysql/mysql.sock
mysqlx_socket=/data/mysql/mysqlx.sock
log-error=/data/mysql/logs/mysqld.log
pid-file=/data/mysql/mysql.pid

default-storage-engine=INNODB
character-set-server=utf8mb4
collation_server = utf8mb4_general_ci
 
[client]
default-character-set = utf8mb4
```

### 初始化数据

初始化数据，初始化管理员的密码为空

**如果已经初始化过了，就需要把数据目录数据情况，再次初始化 rm -rf  /data/mysql/data/***

```bash
mysqld --defaults-file=/etc/my.cnf --initialize-insecure    #--initialize-insecure初始化后root密码为空
#可能会提示报错
[root@kvm-test mysql]# mysqld --defaults-file=/etc/my.cnf --initialize-insecure
mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory
[root@kvm-test mysql]# yum install libaio*


ls -l /data/mysql/data/

总用量 610376
-rw-r----- 1 mysql mysql        56  3月 12 13:23 auto.cnf
-rw------- 1 mysql mysql      1676  3月 12 13:23 ca-key.pem
-rw-r--r-- 1 mysql mysql      1112  3月 12 13:23 ca.pem
-rw-r--r-- 1 mysql mysql      1112  3月 12 13:23 client-cert.pem
-rw------- 1 mysql mysql      1676  3月 12 13:23 client-key.pem
-rw-r----- 1 mysql mysql       436  3月 12 13:23 ib_buffer_pool
-rw-r----- 1 mysql mysql 524288000  3月 12 13:23 ibdata1
-rw-r----- 1 mysql mysql  50331648  3月 12 13:23 ib_logfile0
-rw-r----- 1 mysql mysql  50331648  3月 12 13:23 ib_logfile1
drwxr-x--- 2 mysql mysql      4096  3月 12 13:23 mysql
-rw-r----- 1 mysql mysql       177  3月 12 13:23 mysql-bin.000001
-rw-r----- 1 mysql mysql        19  3月 12 13:23 mysql-bin.index
drwxr-x--- 2 mysql mysql      4096  3月 12 13:23 performance_schema
-rw------- 1 mysql mysql      1680  3月 12 13:23 private_key.pem
-rw-r--r-- 1 mysql mysql       452  3月 12 13:23 public_key.pem
-rw-r--r-- 1 mysql mysql      1112  3月 12 13:23 server-cert.pem
-rw------- 1 mysql mysql      1676  3月 12 13:23 server-key.pem
drwxr-x--- 2 mysql mysql     12288  3月 12 13:23 sys
[root@openeuler mysql]# 


```

‍

### 使用systemd管理mysql

`vim /etc/systemd/system/mysqld.service`​

```bash

[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
 
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/data/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE = 5000

```

```bash
#reload从新加载下systemd
systemctl  daemon-reload
systemctl  start  mysqld
```

### 创建root用户密码，并管理用户

```bash
mysqladmin -uroot -p password XXX新密码

#创建数据库
mysql> CREATE DATABASE zabbix DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.00 sec)

#创建用户
mysql> CREATE USER 'zabbix'@'%' IDENTIFIED BY 'zabbix';
Query OK, 0 rows affected (0.01 sec)

#授权用户
mysql> GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
Query OK, 0 rows affected (0.01 sec)

#刷新权限
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)


```

### 可能遇到的问题

mysql登录报错

mysql: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory

解决方法：

```bash
#找到libtinfo.so.6.3
find /usr/ -name 'libtinfo*'

ln -s /usr/lib64/libtinfo.so.6.3 /usr/lib64/libtinfo.so.5
```

‍

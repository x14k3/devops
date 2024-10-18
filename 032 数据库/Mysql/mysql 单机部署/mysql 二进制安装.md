# mysql 二进制安装

　　‍

　　通用二进制版本： 本文档采用此方式安装

　　https://downloads.mysql.com/archives/community/

　　选择版本，再选择Operating System: Linux - Generic

​![img](http://jpg.fxkjnj.com/picgo/202212051359315.png)​

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
basedir=/data/mysql
datadir=/data/mysql/data
default-storage-engine=INNODB
character-set-server=utf8mb4
collation_server = utf8mb4_general_ci
 
#只能用IP地址检查客户端的登录，不用主机名,跳过域名解析
skip-name-resolve=1
#忽略大小写检查
lower_case_table_names=1
 
#日志时间
log_timestamps=SYSTEM
default-time-zone = '+8:00'
 
 
#慢日志
long_query_time=3
slow_query_log=ON
slow_query_log_file=/data/mysql/logs/slow_query.log
#不记录未使用索引的查询到慢查询日志中
log_queries_not_using_indexes = 0
#管理员执行的慢查询语句记录到慢查询日志中
log_slow_admin_statements = 1
#将从服务器执行的慢查询语句记录到慢查询日志中
log_slow_replica_statements = ON
#当未使用索引的查询数量达到10次时，开始将这些查询记录到慢查询日志中
log_throttle_queries_not_using_indexes = 10
 
 
#通用日志
#general_log=1
#general_log_file=/data/mysql/logs/mysql_general.log
 
#错误日志
log-error=/data/mysql/logs/mysqld.log
 
#innodb配置
innodb_file_per_table = 1
innodb_data_file_path = ibdata1:500M:autoextend:max:10G
innodb_temp_data_file_path = ibtmp1:500M:autoextend:max:20G
 
 
 
#binlog配置
server_id=1
log-bin=mysql-bin
max_binlog_size = 100M
binlog_format=row
log_replica_updates
#二进制日志(binlog)的过期时间-3天
#binlog_expire_logs_seconds=604800
expire_logs_days = 3
 
 
# disable_ssl
tls_version=''
port=3306
socket=/tmp/mysql.sock
max_connections=1000
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
max_allowed_packet=512M
 
[mysql]
socket=/tmp/mysql.sock
default-character-set = utf8mb4
 
 
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

### 启动mysql

```bash
vim support-files/mysql.server
----------------------------------------
basedir=/data/mysql
datadir=/data/mysql/data
------------------------------------------

./support-files/mysql.server  start
./support-files/mysql.server  status
```

#### 或使用systemd管理mysql

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

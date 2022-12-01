#database/mysql

# 基于binlog主从模式

==原理：==

1）master服务器将数据的改变记录二进制binlog日志，当master上的数据发生改变时，则将其改变写入二进制日志中；
2）slave服务器会在一定时间间隔内对master二进制日志进行探测其是否发生改变，如果发生改变，则开始一个I/OThread请求master二进制事件
3）同时主节点为每个I/O线程启动一个dump线程，用于向其发送二进制事件，并保存至从节点本地的中继日志中，从节点将启动SQL线程从中继日志中读取二进制日志，在本地重放，使得其数据和主节点的保持一致，最后I/OThread和SQLThread将进入睡眠状态，等待下一次被唤醒。

也就是说：

- 从库会生成两个线程,一个I/O线程,一个SQL线程;
- I/O线程会去请求主库的binlog,并将得到的binlog写到本地的relay-log(中继日志)文件中;
- 主库会生成一个log dump线程,用来给从库I/O线程传binlog;
- SQL线程,会读取relay log文件中的日志,并解析成sql语句逐一执行;

主从同步事件binlog模式有3种形式：statement、row、mixed。

- statement： 会将对数据库操作的 sql 语句写入到 binlog 中。
- row： 会将每一条数据的变化写入到 binlog 中。
- mixed： statement 与 row 的混合。MySQL 决定什么时候写 statement 格式的，什么时候写 row 格式的 binlog。

主备双机安装相同版本mysql，参考[[mysql 部署]]

1. 主库配置

```bash
# 配置数据库master
## 修改my.cnf配置文件添加
[mysqld]
server-id=1
log-bin=mysql-bin
max_binlog_size=500M
expire_logs_days=15
-----------------------------------
# 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server 

# 创建用于同步的数据库用户
# 用户名：replication 密码：Ninestar@2022 slave服务器ip：10.0.0.10
create user replication@'172.19.23.56' identified with mysql_native_password by 'Ninestar@2022';
grant replication slave on *.* to replication@'172.19.23.56';
flush privileges;

# 查看主服务器当前二进制日志名和偏移量
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      156 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
# 
```

2. 从库配置

```properties
# 配置数据库slave
## 修改my.cnf配置文件添加
[mysqld]
server-id=2
relay_log=mysql-relay-bin
max_relay_log_size=500M
relay_log_purge=1
slave-net-timeout=120
-----------------------------------
## 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server restart

```

3. 从库执行同步命令

```sql                       
-- 用于同步的主服务器上的用户和密码
change master to master_user='replication',
master_password='Ninestar@2022',
-- 主服务器ip
master_host='172.19.23.26',
-- 主服务器二进制日志名
master_log_file='mysql-bin.000002',
-- 主服务器bin-log日志偏移量
master_log_pos=1924,
-- 当重新建立主从连接时，如果连接建立失败，间隔多久后重试。
master_connect_retry=30,
-- slave最大尝试的次数。超过这个值后就不尝试重连了，并将Slave_IO_Running设置为No，默认为86400次
master_retry_count=10;

flush privileges;
-- 启动slave进程
start slave;
-- 查看是否启动
show slave status\G;
--Slave_IO_Running: Yes
--Slave_SQL_Running: Yes
-- 停止slave
stop  slave;
```


# 基于GTID主从模式

从 MySQL 5.6.5 版本新增了一种主从复制方式：`GTID`，其全称是`Global Transaction Identifier`，即全局事务标识。通过`GTID`保证每个主库提交的事务在集群中都有唯一的一个`事务ID`。强化了数据库主从的一致性和故障恢复数据的容错能力。在主库宕机发生主从切换的情况下。`GTID`方式可以让其他从库自动找到新主库复制的位置，而且`GTID`可以忽略已经执行过的事务，减少了数据发生错误的概率。

**`在传统的主从复制slave端，binlog是不用开启的，但是在GTID中slave端的binlog是必须开启的,`** 目的是记录执行过的GTID（强制）。GTID用来代替classic的复制方法，不在使用binlog+pos开启复制。而是使用master_auto_postion=1的方式自动匹配GTID断点进行复制。

mysql的主从复制是十分经典的一个应用，但是主从之间总会有数据一致性（data consistency ）的问题，一般情况从库会落后主库几个小时，而且在传统一主多从(mysql5.6之前)的模型中当master down掉后，我们不只是需要将一个slave提成master就可以，还要将其他slave的同步目的地从以前的master改成现在master，而且bin-log的序号和偏移量也要去查看，这是十分不方便和耗时的，但mysql5.6引入gtid之后解决了这个问题。

==GTID 工作原理==

-   主库 master 提交一个事务时会产生 GTID，并且记录在 binlog 日志中
-   从库 salve I/O 线程读取 master 的 binlog 日志文件，并存储在 slave 的 relay log 中。slave 将 master 的 GTID 这个值，设置到 gtid_next 中，即下一个要读取的 GTID 值。
-   slave 读取这个 gtid_next，然后对比 slave 自己的 binlog 日志中是否有这个 GTID
-   如果有这个记录，说明这个 GTID 的事务已经执行过了，可以忽略掉
-   如果没有这个记录，slave 就会执行该 GTID 事务，并记录到 slave 自己的 binlog 日志中。在读取执行事务前会先检查其他 session 持有该 GTID，确保不被重复执行。
-   在解析过程中会判断是否有主键，如果没有就用二级索引，如果没有就用全部扫描。



准备：主备双机安装相同版本mysql，参考[[mysql 部署]]
mysql版本：mysql-5.7.34-linux-glibc2.12

1. 修改（主）mysql配置文件，然后重启下服务

```bash
##master

·······
# gitd
server-id=200
gtid-mode=on
enforce-gtid-consistency=on

# binlog
log-bin = mysql-bin
binlog_format=Row
log-slave-updates=1
log_bin_trust_function_creators=1

# 不同步的数据库
binlog-ignore-db=mysql,sys,performance_schema,information_schema
·······

-----------------------------------
## 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server restart
```

2. 修改（从）mysql配置文件,只有server-id不一样，然后重启下服务

```bash
##slave

·······
# gitd
server-id=201
gtid-mode=on
enforce-gtid-consistency=on

# binlog
log-bin = mysql-bin
binlog_format=Row
log-slave-updates=1
log_bin_trust_function_creators=1

# 并行复制
relay_log_recovery=ON
relay_log_info_repository=TABLE
master_info_repository=TABLE
sync_master_info=1
slave_parallel_workers=2
slave_parallel_type=logical_clock

# 不复制的数据库
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=performance_schema.%
replicate_wild_ignore_table=information_schema.%
·······

-----------------------------------
## 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server restart
```

3. 登录（主）mysql，创建用于同步的用户

```bash
##master
mysql> grant replication slave on *.* to 'master'@'%' identified by "1q2w3e4r";
```

4. 登录（从）mysql，配置用户连接到主mysql

```bash
##slave

mysql> stop slave;
mysql> change master to master_host='192.168.16.200' ,master_user='master',master_password='1q2w3e4r',master_auto_position=1;
mysql> start slave;
```



# 基于GTID主主模式

Mysql5.7基于GTID部署数据库主主模式，并配置nginx负载均衡转发访问

准备：主备双机安装相同版本mysql，参考[[mysql 部署]]
mysql版本：mysql-5.7.34-linux-glibc2.12

1. 修改（第一台）mysql配置文件，然后重启下服务

```bash
##第一台

·······
# gtid
gtid-mode=on
enforce-gtid-consistency=on
log-slave-updates=1
server-id=200

auto_increment_offset = 1
auto_increment_increment = 2
relay_log_recovery=ON
relay_log_info_repository=TABLE
master_info_repository=TABLE
sync_master_info=1
master_verify_checksum=1
slave_sql_verify_checksum=1
slave_parallel_workers=2
slave_parallel_type=logical_clock

#binlog
log-bin = master-bin
log-slave-updates=1
binlog_format=Row
log_bin_trust_function_creators=1

# 不同步的数据库
binlog-ignore-db=mysql,sys,performance_schema,information_schema

# 不复制的数据库
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=performance_schema.%
replicate_wild_ignore_table=information_schema.%
·······

-----------------------------------
## 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server restart
```

2. 修改（第二台）mysql配置文件,然后重启下服务

```bash
##第二台

·······
# gtid
gtid-mode=on
enforce-gtid-consistency=on
log-slave-updates=1
server-id=201

auto_increment_offset = 2
auto_increment_increment = 2
relay_log_recovery=ON
relay_log_info_repository=TABLE
master_info_repository=TABLE
sync_master_info=1
master_verify_checksum=1
slave_sql_verify_checksum=1
slave_parallel_workers=2
slave_parallel_type=logical_clock

#binlog
log-bin = master-bin
log-slave-updates=1
binlog_format=Row
log_bin_trust_function_creators=1

# 不同步的数据库
binlog-ignore-db=mysql,sys,performance_schema,information_schema

# 不复制的数据库
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=performance_schema.%
replicate_wild_ignore_table=information_schema.%
.%
·······

-----------------------------------
## 重启数据库
systemctl restart mysqld  #/data/mysql/support-files/mysql.server restart
```

3. 登录2台mysql，创建用于同步的用户

```bash
##第一台
mysql> grant replication slave on *.* to 'master'@'%' identified by "1q2w3e4r";

##第二台
mysql> grant replication slave on *.* to 'master'@'%' identified by "1q2w3e4r";
```

4. 登录2台mysql，分别配置同步用户连接到对方mysql

```bash
##第一台

mysql> stop slave;
mysql> change master to master_host='192.168.16.201' ,master_user='master',master_password='1q2w3e4r',master_auto_position=1;
mysql> start slave;
mysql> show slave status \G;

##第二台
mysql> stop slave;
mysql> change master to master_host='192.168.16.200' ,master_user='master',master_password='1q2w3e4r',master_auto_position=1;
mysql> start slave;
mysql> show slave status \G;
```

5. 配置nginx mysql的tcp转发

```nginx
## 修改nginx配置文件，在http段外面加上
······
stream{
    upstream mysql {
       # 负载方法自定义
       hash $remote_addr consistent;
       server 192.168.16.200:3306 weight=5 max_fails=3 fail_timeout=30s;
       server 192.168.16.201:3306 weight=5 max_fails=3 fail_timeout=30s;
    }
    server {
       listen 3333;
       proxy_connect_timeout 1s;
       proxy_timeout 900s;
       proxy_pass mysql;
    }
}

http{
  ······
}
```

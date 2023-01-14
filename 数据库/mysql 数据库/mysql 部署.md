#database/mysql

安装方式：

（1）RPM、Yum（Red Hat Enterprise Linux/Oracle Linux）：安装方便，安装速度快，无法定制；
（2）二进制（Linux Generic）：不需要安装，解压即可使用，不能定制功能；
（3）编译安装/源码安装（Source Code）：安装过程复杂，需要各种依赖库，可定制  ；
    5.5版本之前：./configure , make , make install  
    5.5版本之后：cmake , gmake
**注意：MySQL apl、beta、RC版本都不要选，一定要选择GA版（稳定版）**


下载地址：https://dev.mysql.com/downloads/mysql/

# RPM安装

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
# 连接客户端字符编码
default-character-set=utf8mb4

[mysql]
# 设置默认字符编码
default-character-set=utf8mb4

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
lower-case-table-names=1
default_authentication_plugin=mysql_native_password
-------------------------------------------------

# 启动数据库
systemctl start mysqld
grep 'password' /var/log/mysqld.log

# 运行安全配置向导
mysql_secure_installation 

# 设置root远程登录并修改认证方式
mysql -uroot -p
sql> update mysql.user set host='%', plugin='mysql_native_password' where user='root';
sql> flush privileges;
sql> select host, user, plugin from mysql.user;

```

##  数据库数据目录迁移

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
# 连接客户端字符编码
default-character-set=utf8mb4

[mysql]
# 设置默认字符编码
default-character-set=utf8mb4

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
character-set-server=utf8
# 最大连接数
max_connections=2000
# 是否支持符号链接:否
symbolic-links=0
# 控制是否可以信任存储函数创建者
log_bin_trust_function_creators=1
# 大小写敏感
lower-case-table-names=1
default_authentication_plugin=mysql_native_password
-------------------------------------------------

# 重启数据库
systemctl restart mysqld

# 删除原来的数据库目录
mv /var/lib/mysql /tmp/
# rm -rf /var/lib/mysql /tmp/
```


# 二进制安装

```bash
# 下载mysql 二进制通用安装包 [mysql-8.0.26-linux-glibc2.12-x86_64.tar.xz]
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

# 上传软件包到服务器后进行解压缩
mkdir -p /data/
tar -xvf mysql-8.0.26-linux-glibc2.12-x86_64.tar.xz -C /data/
# 修改目录名称
cd /data/
mv mysql-8.0.26-linux-glibc2.12-x86_64/ mysql

# 检查并创建用户和用户组
groupadd mysql ; useradd -r -g mysql mysql

# 给目录和用户授予权限，很重要的一步
chown -R mysql:mysql /data/mysql/ 


# 初始化数据目录 --defaults-file=放在第一个参数位置
/data/mysql/bin/mysqld  --initialize --user=mysql --basedir=/data/mysql/ --datadir=/data/mysql/data --log-error=/data/mysql/error.log --pid-file=/data/mysql/mysql.pid

# 大小写敏感（mysql 8.0版本，mysql初始化后就不支持修改lower_case_table_names参数了！！所以需要在初始化时指定该参数）
#/data/mysql/bin/mysqld  --initialize --user=mysql --basedir=/data/mysql/ --datadir=/data/mysql/data --log-error=/data/mysql/error.log --pid-file=/data/mysql/mysql.pid lower-case-table-names=1

# 创建 my.cnf 配置文件
vim /etc/my.cnf
-------------------------------------------------
[client]
# 连接端口号，默认 3306
port=3306
# 用于本地连接的 socket 套接字
socket=/data/mysql/data/mysql.sock
# 连接客户端字符编码
default-character-set=utf8mb4

[mysql]
# 设置默认字符编码
default-character-set=utf8mb4

[mysqld]
# 数据库软件目录
basedir=/data/mysql
# 数据存放目录
datadir=/data/mysql/data
# sock文件目录
socket=/data/mysql/mysql.sock
# 错误日志路径
log-error=/data/mysql/error.log
# pid文件目镜
pid-file=/data/mysql/mysqld.pid
# 默认字符集
character-set-server=utf8mb4
# 最大连接数
max_connections=2000
# 是否支持符号链接:否
symbolic-links=0
# 控制是否可以信任存储函数创建者
log_bin_trust_function_creators=1

default_authentication_plugin=mysql_native_password
-------------------------------------------------
# 配置环境变量
vim /etc/profile
-----------------------------------------
# 添加如下：
export PATH=$PATH:/data/mysql/bin
-----------------------------------------
source /etc/profile


# 启动数据库
# 修改启动脚本
vim /data/mysql/support-files/mysql.server
----------------------------------------------------
basedir=/data/mysql
datadir=/data/mysql/data
mysqld_pid_file_path=/data/mysql/mysqld.pid
---------------------------------------------------------
# sed -i 's#^basedir=#basedir=/data/mysql#1' /data/mysql/support-files/mysql.server
# sed -i 's#^datadir=#datadir=/data/mysql/data#1' /data/mysql/support-files/mysql.server
# sed -i 's#^mysqld_pid_file_path=#mysqld_pid_file_path=/data/mysql/mysqld.pid#1' /data/mysql/support-files/mysql.server
/data/mysql/support-files/mysql.server start

# 查看默认密码
cat /data/mysql/error.log

# 初始化
/data/mysql/bin/mysql_secure_installation 

# 复制启动脚本到资源目录
cp /data/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld
# 给mysqld服务控制脚本加执行权限
chmod +x /etc/rc.d/init.d/mysqld

# 将mysqld服务添加到开机自启系统服务
chkconfig --add mysqld

# 将mysql命令添加软连接至/usr/bin系统命令中
ln -s /data/mysql/bin/mysql /usr/bin

# 启动mysql服务
systemctl daemon-reload
systemctl restart mysqld

# 设置root远程登录并修改认证方式
mysql -uroot -p
sql> update mysql.user set host='%', plugin='mysql_native_password' where user='root';
sql> flush privileges;
sql> select host, user, plugin from mysql.user;

# 到此表示MySQL5.7.28二进制安装在redhat7.6上已完成。
```




# my.cnf 配置说明
```properties
[mysqld]
# MySQL 的安装路径
basedir = /software/servers/5-mysql-8.0.16
#mysql数据目录
datadir = /data/mysql/data
#mysql端口号
port = 20005
#可以通过socket文件来快速的登录mysql对应不同端口下的实例
socket = /tmp/mysql.sock
#临时文件目录
tmpdir=/data/mysql/tmp
#控制了general log、error log、slow query log日志中时间戳的显示，默认使用的UTC
log_timestamps=system
#服务器安装时指定的默认编码格式，这个变量建议由系统自己管理，不要人为定义。
character-set-server = utf8mb4
#默认排序规则
collation-server = utf8mb4_unicode_ci
#用户登录到数据库上之后，在执行第一次查询之前执行 里面的内容的
init_connect='SET NAMES utf8mb4'
character-set-client-handshake = FALSE
#设置数据库时间区域
default-time_zone='+8:00'
#禁止域名解析
skip-name-resolve
#事务隔离级别
transaction_isolation = READ-COMMITTED
#最大连接数
max_connections=2000
#阻止过多尝试失败的客户端以防止暴力破解密码
max_connect_errors=30
#服务器关闭非交互连接之前等待活动的秒数
wait_timeout=600
#服务器关闭交互式连接前等待活动的秒数
interactive_timeout=3600
#单个记录大小限制
max_allowed_packet=100M
#密码认证方式
default_authentication_plugin=mysql_native_password
#default_authentication_plugin=caching_sha2_password
#default_authentication_plugin=sha2_password
#缓冲池字节大小,配置为系统内存的50%至75%，默认为128M
innodb_buffer_pool_size=1024M
#指定innodb tablespace文件（ ibdata1就是默认表空间文件，文件大小为1G。因为有autoextend，若空间不够用，该文件可以自动增长）
innodb_data_file_path = ibdata1:1G:autoextend

#=================================================  主从配置相关 =================================================#
#开启gtid
#可简化MySQL的主从切换以及Failover。
#GTID用于在binlog中唯一标识一个事务。当事务提交时，MySQL Server在写binlog的时候，会先写一个特殊的Binlog Event，类型为GTID_Event，指定下一个事务的GTID，然后再写事务的Binlog。
#主从同步时GTID_Event和事务的Binlog都会传递到从库，从库在执行的时候也是用同样的GTID写binlog，这样主从同步以后，就可通过GTID确定从库同步到的位置了。
#也就是说，无论是级联情况，还是一主多从情况，都可以通过GTID自动找点儿，而无需像之前那样通过File_name和File_position找点儿了
gtid_mode = ON
enforce_gtid_consistency = ON
log_slave_updates = ON
server_id = 161
#binlog日志文件存储路径
log_bin = /data/mysql/binlog

#将从服务器 从 主服务器 收到的更新记入到 从服务器 自己的二进制日志文件中                 
log-slave-updates

#这个参数一般用在主主同步中，用来错开自增值, 防止键值冲突
auto_increment_offset = 1           
#这个参数一般用在主主同步中，用来错开自增值, 防止键值冲突
auto_increment_increment = 1    


#二进制日志自动删除的天数，默认值为0,表示“没有自动删除”，启动时和二进制日志循环时可能删除  
expire_logs_days = 7                    


#二进制日志文件并不是每次写的时候同步到磁盘。因此当数据库所在操作系统发生宕机时，可能会有最后一部分数据没有写入二进制日志文件中，这给恢复和复制带来了问题。
#参数sync_binlog=[N]表示每写缓冲多次就同步到磁盘。
#默认，sync_binlog=0，表示MySQL不控制binlog的刷新，由文件系统自己控制它的缓存的刷新。这时候的性能是最好的，但是风险也是最大的。因为一旦系统Crash，在binlog_cache中的所有binlog信息都会被丢失。
#最安全的就是sync_binlog=1了，表示每次事务提交，MySQL都会把binlog刷下去，是最安全但是性能损耗最大的设置。
sync_binlog=1

#表示slave在slave_net_timeout时间之内没有收到master的任何数据(包括binlog，heartbeat)，slave认为连接断开，会进行重连。
slave_net_timeout = 120

#====================================================================================================================#

# 如果的值sync_master_info大于0，则副本在每个sync_master_info事件后都会更新其连接元数据存储库表 。如果为0，则表永远不会更新。
master_info_repository = TABLE

#此变量的设置确定副本服务器是否将其在中继日志中的位置记录到系统数据库中的 InnoDB表 mysql或数据目录中的文件中。

#用来决定slave同步的位置信息记录在哪里。 
#如果relay_log_info_repository=file，就会创建一个realy-log.info，
#如果relay_log_info_repository=table，就会创建mysql.slave_relay_info表来记录同步的位置信息。
relay_log_info_repository = TABLE


#校验binlog，默认为crc32
binlog_checksum = NONE


#它控制是否可以信任存储函数创建者，不会创建写入二进制日志引起不安全事件的存储函数。如果设置为0（默认值），用户不得创建或修改存储函数，除非它们具有除CREATE ROUTINE或ALTER ROUTINE特权之外的SUPER权限。 设置为0还强制使用DETERMINISTIC特性或READS SQL DATA或NO SQL特性声明函数的限制。 如果变量设置为1，MySQL不会对创建存储函数实施这些限制。 此变量也适用于触发器的创建，设置为1，可将函数复制到slave  
log_bin_trust_function_creators = 1
#开启慢查询日志   
slow_query_log = ON

#定义慢查询时间，超过2秒的sql才会被记录到slow.log
long_query_time = 2
#慢日志存放路径
slow_query_log_file = /data/mysql/logs/slow.log

#binlog失效日期单位秒
binlog_expire_logs_seconds = 1296000

#binlog模式（ROW行模式，Level默认，mixed自动模式）
binlog_format = ROW

#为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存。
binlog_cache_size       = 4M    

#用户可以创建的内存表(memory table)的大小.这个值用来计算内存表的最大行数值
max_heap_table_size     = 64M

#内部内存临时表的最大值
tmp_table_size          = 64M

#指定索引缓冲区的大小，它决定索引处理的速度，尤其是索引读的速度。
key_buffer_size         = 32M

#MySQL读入缓冲区大小
read_buffer_size        = 2M

#read_rnd_buffer_size值的适当调大，对提高ORDER BY操作的性能有一定的效果
read_rnd_buffer_size    = 2M
# 用来缓存批量插入数据的时候临时缓存写入数据
bulk_insert_buffer_size = 64M

#在每个connection第一次需要使用这个buffer的时候，一次性分配设置的内存
sort_buffer_size        = 2M

#用来控制Join Buffer的大小，调大后可以避免多次的内表扫描，从而提高性能。
join_buffer_size        = 2M

#指示服务器对于每个事务，它必须收集写集并使用XXHASH64散列算法将其编码为 散列
transaction_write_set_extraction = XXHASH64

#命名格式，每个实例必须完全相同
loose-group_replication_group_name = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'

#插件在服务器启动时不自动启动操作
loose-group_replication_start_on_boot = off


#指定本机地址及端口，是通信端口，不是实例端口
loose-group_replication_local_address = '172.16.1.161:33061'

#设置组成员的主机名和端口，端口使用的是通信端口，不是实例端口
loose-group_replication_group_seeds = '172.16.1.161:33061,172.16.1.162:33061,172.16.1.163:33061,172.16.1.164:33061,172.16.1.228:33061'


#引导是否开启，选择关闭，手动引导
loose-group_replication_bootstrap_group = off

#关闭单主模式的参数
loose-group_replication_single_primary_mode = on

#关闭强制检查
loose-group_replication_enforce_update_everywhere_checks = false

#mysqldump指令
[mysqldump]
#支持较大的数据库转储，导出非常巨大的表时需要此项 。
quick
quote-names
max_allowed_packet      = 16M

#客户端连接服务器端是读取的参数
[client]
port                    = 3306
default-character-set   = utf8
socket                  = /data/mysql/mysql.sock

#客户端连接服务器端是读取的参数（只作用于mysql客户端）
[mysql]
port                    = 3306
default-character-set   = utf8
socket                  = /data/mysql/mysql.sock

[isamchk]
key_buffer          = 128M
sort_buffer_size    = 4M
read_buffer         = 2M
write_buffer        = 2M

[myisamchk]
key_buffer          = 128M
sort_buffer_size    = 4M
read_buffer         = 2M
write_buffer        = 2M

```


## 通用模板

```properties
[mysqld]
basedir         = /data/
datadir         = /data/mysql
pid-file        = /data/mysql/mysqld.pid
socket          = /data/mysql/mysql.sock
port            = 3306
user            = mysql

log-error               = /data/mysql/mysql-error.log
slow-query-log-file     = /data/mysql/mysql-slow.log
log-bin                 = /data/mysql/mysql-bin.log
relay-log               = /data/mysql/mysql-relay-bin

server-id               = 1
#read_only      = 1
innodb_buffer_pool_size = 512M
innodb_log_buffer_size  = 16M
key_buffer_size        = 64M
query_cache_size       = 128M
tmp_table_size          = 128M
tmpdir                  = /data/mysql/tmp

lower_case_table_names  = 1
log-bin-trust-function-creators = 1
binlog_format           = mixed
#binlog_format           = statement
skip-external-locking
skip-name-resolve
character-set-server    = utf8
collation-server        = utf8_bin
#collation-server        = utf8_general_ci
max_allowed_packet      = 16M
thread_cache_size       = 256
table_open_cache        = 4096
back_log                = 1024
max_connect_errors      = 100000
#wait_timeout            = 864000

interactive_timeout     =  1800
wait_timeout            = 1800

max_connections         = 2048
sort_buffer_size        = 16M
join_buffer_size        = 4M
read_buffer_size        = 4M
#read_rnd_buffer_size    = 8M
read_rnd_buffer_size    = 16M
binlog_cache_size       = 2M
thread_stack            = 192K

max_heap_table_size     = 128M
myisam_sort_buffer_size = 128M
bulk_insert_buffer_size = 256M
open_files_limit        = 65535
query_cache_limit       = 2M
slow-query-log
long_query_time         = 2

expire_logs_days        = 3
max_binlog_size         = 1000M
slave_parallel_workers  = 4
log-slave-updates
#slave-skip-errors  =1062,1053,1146,1032

binlog_ignore_db        = mysql
replicate_wild_ignore_table = mysql.%
sync_binlog = 1

innodb_file_per_table   = 1
innodb_flush_method     = O_DIRECT
innodb_buffer_pool_instances = 4
innodb_log_file_size    = 512M
innodb_log_files_in_group = 3
innodb_open_files       = 4000
innodb_read_io_threads  = 8
innodb_write_io_threads = 8
innodb_thread_concurrency = 8
innodb_io_capacity      = 2000
innodb_io_capacity_max  = 6000
innodb_lru_scan_depth   = 2000
innodb_max_dirty_pages_pct = 85
innodb_flush_log_at_trx_commit = 2
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES


[mysqldump]
quick
quote-names
max_allowed_packet      = 16M

[client]
port                    = 3306
default-character-set   = utf8
socket                  = /data/mysql/mysql.sock

[mysql]
port                    = 3306
default-character-set   = utf8

[isamchk]
key_buffer          = 128M
sort_buffer_size    = 4M
read_buffer         = 2M
write_buffer        = 2M

[myisamchk]
key_buffer          = 128M
sort_buffer_size    = 4M
read_buffer         = 2M
write_buffer        = 2M
```

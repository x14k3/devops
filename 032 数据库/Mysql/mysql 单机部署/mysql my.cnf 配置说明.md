# mysql my.cnf 配置说明

‍

```bash

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
server_id = 161
#binlog日志文件存储路径
log_bin = /data/mysql/binlog
# binlog 日志大小限制
max_binlog_size=500M
# 二进制日志自动删除的天数，默认值为0,表示“没有自动删除”，启动时和二进制日志循环时可能删除  
expire_logs_days=15
#MySQL8.0 使用 binlog_expire_logs_seconds 来控制，其效果和名字的变化一样，精确度由天变成了秒
#将从服务器 从 主服务器 收到的更新记入到 从服务器 自己的二进制日志文件中,这样从服务器也可以作为其他服务器的主服务器。
log-slave-updates=1

# 启动中继日志
relay_log=slave-relay-bin
# 中继日志索引文件的路径名称
relay-log-index = slave-relay-bin.index

max_relay_log_size=500M
# 自动删除从库的relaylog，但是在MHA架构下该配置不会自动删除
relay_log_purge=1
# 从库超时时间
slave-net-timeout=120

#这个参数一般用在主主同步中，用来错开自增值, 防止键值冲突
auto_increment_offset = 1     
#这个参数一般用在主主同步中，用来错开自增值, 防止键值冲突
auto_increment_increment = 1  


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

#binlog模式（
#-   ROW记录包括了是EVENT TYPE，且是基于每行的,即你执行了一个DML操作，binlog中记录的并不是具体的这个sql，而是针对该语句的每一行或者多行记录各自生成记录，这样能有效避免主从下针对同一条sql而产生不同的结果，这种方式无疑是最安全的，但是效率和空间上消耗是最大的。
#-   STATAMENT 是基于sql执行语句的（显示记录），相对于row占用的存储空间要少。用于数据同步的话还是要谨慎，需要保证主从机器之间的一致性（variables参数，Binlog日志格式参数，表引擎，数据，索引等等），如果不能保证，用于恢复数据的情景还是要慎用（可以参考下面`update where limit`语句的例子）
#-   MIXED格式是自动判断并自动切换行和语句的策略，既然是自动，就不能保证完全符合每个业务场景，除非Server层面能做到绝对安全。。
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

```bash
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
default-time_zone = '+8:00'
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

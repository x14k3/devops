# mysql 优化配置

## 查看mysql的所有配置

​`mysql> show globalvariables;`​

‍

‍

## 缓冲池

innodb_buffer_pool_size

用于缓存索引和数据的内存大小，这个当然是越多越好， 数据读写在内存中非常快， 减少了对磁盘的读写。当数据提交或满足检查点条件后才一次性将内存数据刷新到磁盘中。然而内存还有操作系统或数据库其他进程使用， 根据经验，推荐设置innodb-buffer-pool-size为服务器总可用内存的75%。 若设置不当， 内存使用可能浪费或者使用过多。 对于繁忙的服务器， buffer pool 将划分为多个实例以提高系统并发性， 减少线程间读写缓存的争用。buffer pool 的大小首先受 innodb_buffer_pool_instances 影响， 当然影响较小。

‍

## 重做日志

innodb_log_file_size 是仅次于innodb_buffer_pool_size的第二重要的参数。调整它能带来写入性能优化。

innodb_log_file_size这个选项是设置 redo 日志（重做日志）的大小。这个值的默认为5M，是远远不够的，在安装完mysql时需要尽快的修改这个值。如果对 Innodb 数据表有大量的写入操作，那么选择合适的 innodb_log_file_size 值对提升MySQL性能很重要。然而设置太大了，就会增加恢复的时间，因此在MySQL崩溃或者突然断电等情况会令MySQL服务器花很长时间来恢复。

* 小日志文件使写入速度更慢，崩溃恢复速度更快

由于事务日志相当于一个写缓冲，而小日志文件会很快的被写满，这时候就需要频繁地刷新到硬盘，速度就慢了。如果产生大量的写操作，MySQL可能就不能足够快地刷新数据，那么写性能将会降低。

* 大日志文件使写入更快，崩溃恢复速度更慢

大的日志文件，另一方面，在刷新操作发生之前给你足够的空间来使用。反过来允许InnoDB填充更多的页面。对于崩溃恢复 – 大的重做日志意味着在服务器启动前更多的数据需要读取，更多的更改需要重做，这就是为什么崩溃恢复慢了。

如果不配的后果：默认是5M，这是肯定不够的。

### 估算 innodb_log_file_size

最后，让我们来谈谈如何找出重做日志的正确大小。  
 幸运的是，你不需要费力算出正确的大小，这里有一个经验法则：在服务器繁忙期间，检查重做日志的总大小是否够写入1-2小时。你如何知道InnoDB写入多少，使用下面方法可以统计60秒内地增量数据大小：

mysql> show engine innodb status\G select sleep(60); show engine innodb status\G  
 Log sequence number 4631632062  
 ...  
 Log sequence number 4803805448

mysql> select (4803805448-4631632062)*60/1024/1024; +--------------------------------------+ | (4803805448-4631632062)* 60/1024/1024 |  
 +--------------------------------------+  
 |                        9851.84017181 |  
 +--------------------------------------+  
 1 row in set (0.00 sec)

在这个60s的采样情况下，InnoDB每小时写入9.8GB数据。所以如果innodb_log_files_in_group没有更改(默认是2，是InnoDB重复日志的最小数字)，然后设置innodb_log_file_size为10G，那么你实际上两个日志文件加起来有20GB，够你写两小时数据了。

‍

## 主从复制延时分析

MySQL 的主从复制都是单线程的操作，主库对所有  DDL 和 DML 产生的日志写进 binlog，由于 binlog 是顺序写，所以效率很高，slave 的 SQL thread 线程将主库的  DDL 和 DML 操作事件在 slave 中重放。DML 和 DDL 的 IO 操作是随机的，不是顺序，所以成本要高很多，另一方面，由于  SQL thread 也是单线程的，当主库的并发较高时，产生的 DML 数量超过 slave 的 SQL thread 所能处理的速度，或者当  slave 中有大型 query 语句产生了锁等待，那么延时就产生了。

**解决方案**：

* 业务的持久层实现采用分库架构，mysql 服务可以水平扩展，分散压力；
* 单个库读写分离，一主多从，主写从读，分散压力；这样从库压力可能会比主库高，保护主库。
* 服务的基础架构在业务系统和mysql之间加入memcache或者redis 的cache层，降低mysql读压力。
* 不同业务的mysql物理上放在不同的机器，分散压力。
* 使用比主库更好的硬件设备作为slave，mysql压力小，延迟自然会变小。
* 使用更加强劲的硬件设备。

## 32GB内存的mysql配置参数

```bash
# 缓冲池字节大小,配置为系统内存的50%至75%，默认为128M,
innodb_buffer_pool_size=16G

# 设置 redo 日志（重做日志）的大小。
#小日志文件使写入速度更慢，崩溃恢复速度更快
# 由于事务日志相当于一个写缓冲，而小日志文件会很快的被写满，这时候就需要频繁地刷新到硬盘，速度就慢了。如果产生大量的写操作，MySQL可能就不能足够快地刷新数据，那么写性能将会降低。

#大日志文件使写入更快，崩溃恢复速度更慢
# 大的日志文件，另一方面，在刷新操作发生之前给你足够的空间来使用。反过来允许InnoDB填充更多的页面。对于崩溃恢复 – 大的重做日志意味着在服务器启动前更多的数据需要读取，更多的更改需要重做，这就是为什么崩溃恢复慢了。
innodb_log_file_size = 2G

innodb_log_buffer_size=16M

key_buffer_size = 256M
max_allowed_packet = 32M
table_open_cache = 16384
sort_buffer_size = 32M
net_buffer_length = 16384
read_buffer_size= 16M
read_rnd_buffer_size = 32M
myisam_sort_buffer_size = 128M
thread_cache_size = 64
tmp_table_size = 128M
max_connections = 100000
open_files_limit = 500000

```

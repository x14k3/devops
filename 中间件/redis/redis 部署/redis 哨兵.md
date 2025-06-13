

哨兵结构由两部分组成，哨兵节点和数据节点：

- 哨兵节点：哨兵系统由一个或多个哨兵节点组成，哨兵节点是特殊的redis节点，不存储数据。
- 数据节点：主节点和从节点都是数据节点。

哨兵的启动依赖于主从模式，所以须把主从模式安装好的情况下再去做哨兵模式，所有节点上都需要部署哨兵模式，哨兵模式会监控所有的 Redis 工作节点是否正常，当 Master 出现问题的时候，因为其他节点与主节点失去联系，因此会投票，投票过半就认为这个 Master 的确出现问题，然后会通知哨兵间，然后从 Slaves 中选取一个作为新的 Master。

需要特别注意的是，客观下线是主节点才有的概念；如果从节点和哨兵节点发生故障，被哨兵主观下线后，不会再有后续的客观下线和故障转移操作。

==哨兵模式的作用==

**监控**：哨兵会不断地检查主节点和从节点是否运作正常。  
**自动故障转移**：当主节点不能正常工作时，哨兵会开始自动故障转移操作，它会将其中一个从节点升级为新的主节点，并让其他从节点改为复制新的主节点。  
**通知（提醒**）：哨兵可以将故障转移的结果发送给客户端。

![](image-20221127213605003-20230610173812-xnczp25.png)

### 1. 部署主从

参考 [一、主从模式](#一、主从模式) 部署一主两从架构

### 2. 配置哨兵

修改所有节点(包括主从节点) redis 上的 sentinel.conf

```bash
# 修改 Redis 配置文件（所有服务节点）sentinel.conf
vim /data/redis/sentinel.conf 
---------------------------------------------
protected -mode no                   # 关闭保护模式
port 26379                           # Redis哨兵默认的监听端口
daemonize yes                        # 指定sentinel为后台启动
logfile "/data/redis/sentinel.log"   # 指定日志存放路径
dir "/data/redis"                    # 指定数据库存放路径

sentinel monitor mymaster 192.168.0.200 6379 2  # 指定该哨兵节点监控20.0.0.20:6379这个主节点，该主节点的名称是mymaster，最后的2的含义与主节点的故障判定有关：至少需要2个哨兵节点同意，才能判定主节点故障并进行故障转移
sentinel auth-pass mymaster Ninestar123         # 如果redis-master有密码
sentinel down-after-milliseconds mymaster 30000 # 判定服务器down掉的时间周期，默认30000毫秒（30秒）
sentinel failover-timeout mymaster 180000       # 故障节点的最大超时时间为180000（180秒）
sentinel parallel-syncs mymaster 1              # 指在故障转移时，最多有多少个从节点对新的主节点进行同步。
```

### 3. 启动哨兵进程

```bash
# 启动顺序：master > slave1 > slave2 > sentinel 1 > sentinel 3 > sentinel 3
/data/redis/bin/redis-server /data/redis/redis.conf
/data/redis/bin/redis-sentinel /data/redis/sentinel.conf
```

### 4. 模拟验证

```bash
# 关闭master redis
./bin/redis-cli -a Ninestar123 shutdown
# 关闭master上面的 sentinel
 pkill redis


[root@192 redis]# ./bin/redis-cli -a Ninestar123 info replication
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
# Replication
role:slave
master_host:192.168.0.204
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:368818
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:2f6fa97f7311dee6325b92a22b0de392db5ddd47
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:368818
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:367245
repl_backlog_histlen:1574
[root@192 redis]# 
```

#middleware/redis 


- **主从复制**：主从复制是高可用redis的基础，主从复制主要实现了数据的多机备份，以及对于读操作的负载均衡和简单的故障恢复。哨兵和集群都是在主从复制基础上实现高可用的。缺点：故障恢复无法自动化，写操作无法负载均衡，存储能力受到单机的限制。

- **哨兵**：在主从复制的基础上，哨兵实现了自动化的故障恢复。缺点：写操作无法负载均衡，存储能力受到单机的限制，哨兵无法对从节点进行自动故障转移，在读写分离的场景下，从节点故障会导致读服务不可用，需要对从节点做额外的监控切换操作。

- **集群**：通过集群，redis解决了写操作无法负载均衡，以及存储能力受到单机限制的问题，实现了较为完善的高可用方案。


## 一、主从模式

主从复制，是指将一台Redis服务器的数据，复制到其他的Redis服务器。前者称为主节点(Master)，后者称为从节点(Slave)；数据的复制是单向的，只能由主节点到从节点。  
默认情况下，每台Redis服务器都是主节点；且一个主节点可以有多个从节点(或没有从节点)，但一个从节点只能有一个主节点。

==Redis 主从复制过程==
a）Slave与Master建立连接，发送sync同步命令
b）Master会启动一个后台进程，将数据库快照保存到文件中，同时Master主进程会开始收集新的写命令并缓存。
c）后台完成保存后，就将此文件发送给Slave
d）Slave将此文件保存到硬盘上

==Redis主从复制的作用==
a）数据冗余：主从复制实现了数据的热备份，是持久化之外的一种数据冗余方式。  
b）故障恢复：当主节点出现问题时，可以由从节点提供服务，实现快速的故障恢复；实际上是一种服务的冗余。  
c）负载均衡：在主从复制的基础上，配合读写分离，可以由主节点提供写服务，由从节点提供读服务（即写Redis数据时应用连接主节点，读Redis数据时应用连接从节点），分担服务器负载；尤其是在写少读多的场景下，通过多个从节点分担读负载，可以大大提高Redis服务器的并发量。  
d）高可用基石：除了上述作用以外，主从复制还是哨兵和集群能够实施的基础，因此说主从复制是Redis高可用的基础

### 1. 主服务器配置

```bash
# 必须设置密码
vim /data/redis/etc/redis.conf
------------------------------------------------
bind 192.168.0.200                            
requirepass Ninestar123                   # 密码
daemonize yes                                  # 开启守护进程
logfile /data/redis/redis.log              # 指定日志文件目录
dir /data/redis                                  # 指定工作目录
appendonly yes                                # 开启AOF持久化功能
# masterauth Ninestar123               # 当主节点挂掉后，从新启动会变成从节点，这里就需要配置新主节点密码

# 启动redis
/data/redis/bin/redis-server  /data/redis/etc/redis.conf

# 查看状态,两个从节点部署完查看
reids-cli > info replication
```

### 2. 从服务器配置

两个从节点都配置

```bash
vim /data/redis/etc/redis.conf
------------------------------------------------
replicaof 192.168.10.1 6379      # 主服务器的 IP 和端口
masterauth Ninestar123           # 主服务器redis密码
bind 192.168.0.xx                      # 修改bind 项，集群模式不用用0.0.0.0
requirepass Ninestar123           # 密码
daemonize yes                          # 开启守护进程
logfile /data/redis/redis.log      # 指定日志文件目录
dir /data/redis                           # 指定工作目录


# 启动redis
/data/redis/bin/redis-server  /data/redis/etc/redis.conf
```

### 3. 主从手动切换

系统运行时，如果 master 挂掉了，可以在一个从库（如 slave1）上手动执行命令`slaveof no one`，将 slave1 变成新的 master；在 slave2 和 slave3 上分别执行`slaveof 192.168.1.11 6379` 将这两个机器的主节点指向的这个新的 master；同时，挂掉的原 master 启动后作为新的 slave 也指向新的 master 上。
执行命令`slaveof no one`命令，可以关闭从服务器的复制功能。同时原来同步的所得的数据集都不会被丢弃。


## 二、哨兵模式

哨兵结构由两部分组成，哨兵节点和数据节点：

-   哨兵节点：哨兵系统由一个或多个哨兵节点组成，哨兵节点是特殊的redis节点，不存储数据。
-   数据节点：主节点和从节点都是数据节点。

哨兵的启动依赖于主从模式，所以须把主从模式安装好的情况下再去做哨兵模式，所有节点上都需要部署哨兵模式，哨兵模式会监控所有的 Redis 工作节点是否正常，当 Master 出现问题的时候，因为其他节点与主节点失去联系，因此会投票，投票过半就认为这个 Master 的确出现问题，然后会通知哨兵间，然后从 Slaves 中选取一个作为新的 Master。

需要特别注意的是，客观下线是主节点才有的概念；如果从节点和哨兵节点发生故障，被哨兵主观下线后，不会再有后续的客观下线和故障转移操作。

==哨兵模式的作用==
监控：哨兵会不断地检查主节点和从节点是否运作正常。
自动故障转移：当主节点不能正常工作时，哨兵会开始自动故障转移操作，它会将失效主节点的其中一个从节点升级为新的主节点，并让其他从节点改为复制新的主节点。
通知（提醒）：哨兵可以将故障转移的结果发送给客户端。

![](assets/redis%20高可用部署/image-20221127213605003.png)



### 1. 部署主从

参考 [一、主从模式](#一、主从模式) 部署一主两从架构

### 2. 配置哨兵

修改所有节点(包括主从节点) redis 上的 sentinel.conf 

```bash
# 修改 Redis 配置文件（所有服务节点）sentinel.conf
vim /data/redis/sentinel.conf 
---------------------------------------------
protected -mode no                      # 关闭保护模式
port 26379                                    # Redis哨兵默认的监听端口
daemonize yes                              # 指定sentinel为后台启动
logfile "/data/redis/sentinel.log"   # 指定日志存放路径
dir "/data/redis"                            # 指定数据库存放路径

sentinel monitor mymaster 192.168.0.200 6379 2  # 指定该哨兵节点监控20.0.0.20:6379这个主节点，该主节点的名称是mymaster，最后的2的含义与主节点的故障判定有关：至少需要2个哨兵节点同意，才能判定主节点故障并进行故障转移
sentinel auth-pass mymaster Ninestar123              # 如果redis-master有密码
sentinel down-after-milliseconds mymaster 30000 # 判定服务器down掉的时间周期，默认30000毫秒（30秒）
sentinel failover-timeout mymaster 180000            # 故障节点的最大超时时间为180000（180秒）
sentinel parallel-syncs mymaster 1                          # 指在故障转移时，最多有多少个从节点对新的主节点进行同步。
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



## 三、集群模式

Redis 的哨兵模式基本已经可以实现高可用，读写分离 ，但是在这种模式下每台 Redis 服务器都存储相同的数据，很浪费内存，所以在 redis3.0 上加入了 Cluster 集群模式，实现了 Redis 的分布式存储，对数据进行分片，也就是说每台 Redis 节点上存储不同的内容；

![](assets/redis%20高可用部署/image-20221127213612182.png)


根据官方推荐，集群部署至少要 3 台以上的 master 节点，最好使用 3 主 3 从六个节点的模式。测试时，也可以在一台机器上部署这六个实例，通过端口区分出来。

| 机器名称 | IP    | 端口 |
| -------- | ------------- | ---- |
| master 1 | 192.168.0.200 | 6379 |
| master 2 | 192.168.0.201 | 6379 |
| master 3 | 192.168.0.202 | 6379 |
| slave 1  | 192.168.0.203 | 6379 |
| slave 2  | 192.168.0.204 | 6379 |
| slave 3  | 192.168.0.205 | 6379 |


### 1. 配置集群

6台服务器都进行以下配置，修改redis.conf 

```bash
vim redis.conf
-------------------------------------------
bind 0.0.0.0
requirepass Ninestar123
daemonize yes
logfile "/data/redis/redis.log"
dir /data/redis
appendonly yes
# 非保护模式
protected-mode no
# 启用集群模式
cluster-enabled yes 
# 根据你启用的节点来命名，最好和端口保持一致，这个是用来保存其他节点的名称，状态等信息的
cluster-config-file nodes-6379.conf
# 超时时间
cluster-node-timeout 5000
```

挨个启动所有 redis 节点

```bash
/data/redis/bin/redis-server /data/redis/redis.conf
```

### 2. 启动集群

```bash
# 执行命令
# --cluster-replicas 1 命令的意思是创建master的时候同时创建一个slave
redis-cli -a Ninestar123 --cluster create 192.168.0.200:6379  192.168.0.202:6379 192.168.0.203:6379 192.168.0.204:6379 192.168.0.205:6379 192.168.0.206:6379  --cluster-replicas 1

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.0.205:6379 to 192.168.0.200:6379
Adding replica 192.168.0.206:6379 to 192.168.0.202:6379
Adding replica 192.168.0.204:6379 to 192.168.0.203:6379
M: 60a67fd9812a900a4ad05027fe07c37341b7e61b 192.168.0.200:6379
   slots:[0-5460] (5461 slots) master
M: 439dd0d98dd3f4839fb2bb055853817ba817cbec 192.168.0.202:6379
   slots:[5461-10922] (5462 slots) master
M: 6597f9b7ba96304993f60da8b382e32d9aa832ce 192.168.0.203:6379
   slots:[10923-16383] (5461 slots) master
S: dce912a633db16ce0f0039032fa6f1b57b7d998a 192.168.0.204:6379
   replicates 6597f9b7ba96304993f60da8b382e32d9aa832ce
S: b620bbec131d17a24ea3c194bca1a8caa643c41d 192.168.0.205:6379
   replicates 60a67fd9812a900a4ad05027fe07c37341b7e61b
S: 53ef3e917557064b8b73b1e689ceb1d4719d7633 192.168.0.206:6379
   replicates 439dd0d98dd3f4839fb2bb055853817ba817cbec
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node 192.168.0.200:6379)
M: 60a67fd9812a900a4ad05027fe07c37341b7e61b 192.168.0.200:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 53ef3e917557064b8b73b1e689ceb1d4719d7633 192.168.0.206:6379
   slots: (0 slots) slave
   replicates 439dd0d98dd3f4839fb2bb055853817ba817cbec
S: b620bbec131d17a24ea3c194bca1a8caa643c41d 192.168.0.205:6379
   slots: (0 slots) slave
   replicates 60a67fd9812a900a4ad05027fe07c37341b7e61b
M: 439dd0d98dd3f4839fb2bb055853817ba817cbec 192.168.0.202:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 6597f9b7ba96304993f60da8b382e32d9aa832ce 192.168.0.203:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: dce912a633db16ce0f0039032fa6f1b57b7d998a 192.168.0.204:6379
   slots: (0 slots) slave
   replicates 6597f9b7ba96304993f60da8b382e32d9aa832ce
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

```

### 3. 数据验证

```bash
# 注意 集群模式下要带参数 -c，表示集群，否则不能正常存取数据！！！
redis-cli -a Ninestar123 -p 6379 -c

# 设置 k1 v1
127.0.0.1:6379> 
127.0.0.1:6379> set k1 v1
# # 这可以看到集群的特点:把数据存到计算得出的 slot，这里还自动跳到了192.168.0.203
-> Redirected to slot [12706] located at 192.168.0.203:6379
OK
192.168.0.203:6379> 

# 我们还回到 192.168.0.200  获取 k1 试试
redis-cli -a Ninestar123 -p 6379 -c
127.0.0.1:6379> get k1
-> Redirected to slot [12706] located at 192.168.0.203:6379
"v1"
192.168.0.203:6379> 
# 我们可以看到重定向的过程
```

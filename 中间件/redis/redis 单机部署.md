#middleware/redis

下载地址：https://redis.io/download/

## 一、单机部署

```bash
# 安装依赖
yum -y install gcc gcc-c++
# 下载安装
wget http://download.redis.io/releases/redis-5.0.14.tar.gz
# 解压
mkdir /data
tar -zxvf redis-5.0.14.tar.gz -C /data
mv /data/redis-5.0.14 /data/redis
# 编译 安装
cd /data/redis
make && make install PERFIX=/data/redis

# 修改配置文件
vim /data/redis/redis.conf
--------------------------------------------------
# 监听的网卡
bind 0.0.0.0
# redis日志路径
logfile /data/redis/redis.log
# redis密码
requirepass Ninestar123
# 作为后台服务运行
daemonize yes
# 
--------------------------------------------------
# 启动服务
/data/redis/bin/redis-server /data/redis/redis.conf

# 客户端连接测试
/data/redis/bin/redis-cli
-h   # 连接指定的 redis 服务器
-p   # 指定 redis 服务器的端口
-a   # redis密码
-n   # 指定连接哪个数据库
--raw  # redis 支持存储中文

# redis 日志切割
vim /etc/logrotate.d/redislog.conf
-------------------------------------------------
/data/redis/redis.log {
    missingok
    daily
    create 0600 root root
    rotate 7
	dateext
	compress
}
-------------------------------------------------
# 如果时间不符合要求，logrotate 也不会真正执行时，如果想要立即执行，查看结果，就使用到了强制执行模式。
logrotate -f /etc/logrotate.d/redislog.conf

```



## 二、数据持久化

Redis 持久化的两种方式

### AOF持久化

采用日志的形式来记录每个写操作，追加到AOF文件的末尾，类似于mysql的binlog，Redis默认情况是不开启AOF的。
redis执行完命令后才记录日志，所以会存在两个风险：

	更执行完命令还没记录日志时，宕机了会导致数据丢失
	AOF不会阻塞当前命令，但是可能会阻塞下一个操作。
 
解决上述的两个风险有三种写回策略：

	always：  同步写回，每个子命令执行完，都立即将日志写回磁盘。
	everysec：每个命令执行完，只是先把日志写到AOF内存缓冲区，每隔一秒同步到磁盘。
	no：      只是先把日志写到AOF内存缓冲区，有操作系统去决定何时写入磁盘。

接受的命令越来越多，AOF文件也会越来越大，文件过大还是会带来性能问题，所以redis有一种AOF重写机制，随着时间推移，AOF文件会有一些冗余的命令如：无效命令、过期数据的命令等等，AOF重写机制就是把它们合并为一个命令（类似批处理命令），从而达到精简压缩空间的目的

	优点：数据的一致性和完整性更高，秒级数据丢失。
	缺点：相同的数据集，AOF文件体积大于RDB文件。数据恢复也比较慢。

AOF配置方式

```bash
# 开启AOF持久化
appendonly yes

# AOF持久化策略
appendfsync [ always | everysec  | no ] 
# always      每次操作都会立即写入aof文件中 
# everysec   每秒持久化一次(默认配置) 
# no            由操作系统自动调度刷磁盘，性能是最好的
```

### RDB持久化

RDB，就是把内存数据以快照的形式保存到磁盘上。和AOF相比，它记录的是某一时刻的数据。**它是Redis默认的持久化方式**，RDB持久化，是指在指定的时间间隔内，执行指定次数的写操作，将内存中的数据集快照写入磁盘中，执行完操作后，在指定目录下会生成一个dump.rdb文件，Redis 重启的时候，通过加载dump.rdb文件来恢复数据
**RDB触发机制：**
分为手动触发和自动触发，手动触发分为两种，第一种是同步的，输入save命令，会阻塞当前redis服务器，第二种是bgsave命令，是异步的，会fork一个子进程，然后该子进程会负责创建RDB文件，而服务器进程会继续处理命令请求，另一种是手动触发，如下图所示：
![](assets/redis%20单机部署/image-20221127213552552.png)

	优点：与AOF相比，恢复大数据集的时候会更快，它适合大规模的数据恢复场景，如备份，全量复制等
	缺点：没办法做到实时持久化/秒级持久化

RDB配置方式
```bash
# 900秒内，如果超过1000个key被修改，则发起快照保存
save 900 1000
# 同时配置 rdb和aof 表示同时启用。关闭rdb，只需注释该行即可
```

Redis4.0开始支持RDB和AOF的混合持久化，就是内存快照以一定频率执行，两次快照之间，再使用AOF记录这期间的所有命令操作

	1.如果数据不能丢失，RDB和AOF混用
	2.如果只作为缓存使用，可以承受几分钟的数据丢失的话，可以只使用RDB。
	3.如果只使用AOF，优先使用everysec的写回策略。



## 三、redis 相关命令
```bash
/data/redis/bin/redis-server  /data/redis/etc/redis.conf   & # 后台启动redis
redis -a password  shutdown  # 关闭reids
redis -a password            # 登录redis
> flushall        # 清空缓存
> key  *          # 查看所有key值
```


## 四、优化

### 1. 内核参数 overcommit_memory

```bash
20374:M 26 Nov 2022 14:38:52.160 # Server initialized
20374:M 26 Nov 2022 14:38:52.160 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
20374:M 26 Nov 2022 14:38:52.160 * Ready to accept connections

# 以上告警说明
#### 内核参数 overcommit_memory
0， 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。  
1， 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。  
2， 表示内核允许分配超过所有物理内存和交换空间总和的内存

vim /etc/sysctl.conf 
vm.overcommit_memory=1
--------------------------------------
sysctl -p   # 使配置文件生效
```

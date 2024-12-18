# redis 单例部署

　　下载地址：[https://redis.io/download/](https://redis.io/download/)

　　https://github.com/redis/redis

# 单节 Redis Standalone

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
make PREFIX=/data/redis install

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

## 优化项

　　==1.1 内核参数 overcommit_memory==

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

## redis配置详解

```bash
# bind配置成2个IP地址，一般默认配置为127.0.0.1
bind 20.200.34.145 127.0.0.1
# 开启保护模式
protected-mode yes
# 修改端口号
port 6379
# 定义redis服务启用pid输出文件位置
pidfile "/data/redis/redis_6379.pid"
# 定义redis服务启用log日志输出位置
logfile "/data/redis/redis_6379.log"
# 启用持久化（执行数据备份）
dbfilename "redis_6379.rdb"
# redis工作目录
dir "/data/redis"
# 启用后台进程redis实例
daemonize yes
# /redis密码认证
masterauth 123456
# redis客户端登陆密码认证
requirepass 123456
# 启用集群模式
cluster-enabled yes 
# 集群中实例配置文件
cluster-config-file cluster_6379.conf
```

　　‍

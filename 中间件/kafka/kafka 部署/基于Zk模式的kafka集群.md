
## 一、Zookeeper集群搭建

参考：[zookeeper 部署](../../zookeeper/zookeeper%20部署.md)

zookeeper 是一个分布式的协调组件，早期版本的kafka用zk做meta信息存储，consumer的消费状态，group  的管理以及 offset 的值。考虑到 zookeeper 本身的一些因素以及整个架构较大概率存在单点问题，新版本中逐渐弱化了  zookeeper 的作用。新的 consumer 使用了 kafka 内部的 group coordination 协议，也减少了对  zookeeper 的依赖，

但是 broker 依然依赖于 zookeeper，zookeeper 在kafka中还用来选举 controller 和检测 broker 是否存活等等。

## 二、Kafka 搭建

### 2.1 下载解压

Kafka 安装包官方下载地址：[http://kafka.apache.org/downloads](http://kafka.apache.org/downloads) ，本用例下载的版本为 `3.8.0`​，下载命令：

```bash
# 下载
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz
# 解压
tar xf kafka_2.12-3.8.0.tgz
mkdir -p /data
mv kafka_2.12-3.8.0 /data/kafka

```

> 这里解释一下 kafka 安装包的命名规则：以 `kafka_2.12-3.8.0.tgz`​ 为例，前面的 2.12 代表 Scala 的版本号（Kafka 采用 Scala 语言进行开发），后面的 3.8.0 则代表 Kafka 的版本号。

### 2.2 拷贝配置文件

进入解压目录的 `config`​ 目录下 ，拷贝三份配置文件：

```bash
cp server.properties server-1.properties
cp server.properties server-2.properties
cp server.properties server-3.properties
```

### 2.3 修改配置

分别修改三份配置文件中的部分配置，如下：

server-1.properties：

```ini
# The id of the broker. 集群中每个节点的唯一标识
broker.id=0
# 监听地址
listeners=PLAINTEXT://hadoop001:9092
#listeners=PLAINTEXT://172.16.150.154:9092  #修改为本机地址
# 数据的存储位置
log.dirs=/data/kafka-1/data
# Zookeeper连接地址
zookeeper.connect=hadoop001:2181,hadoop001:2182,hadoop001:2183
```

server-2.properties：

```ini
broker.id=1
listeners=PLAINTEXT://hadoop001:9093
log.dirs=/data/kafka-2/data
zookeeper.connect=hadoop001:2181,hadoop001:2182,hadoop001:2183
```

server-3.properties：

```ini
broker.id=2
listeners=PLAINTEXT://hadoop001:9094
log.dirs=/data/kafka-3/data
zookeeper.connect=hadoop001:2181,hadoop001:2182,hadoop001:2183
```

这里需要说明的是 `log.dirs`​ 指的是数据日志的存储位置，确切的说，就是分区数据的存储位置，而不是程序运行日志的位置。程序运行日志的位置是通过同一目录下的 `log4j.properties`​ 进行配置的。

### 2.4 启动集群

分别指定不同配置文件，启动三个 Kafka 节点。启动后可以使用 jps 查看进程，此时应该有三个 zookeeper 进程和三个 kafka 进程。

```bash
bin/kafka-server-start.sh config/server-1.properties
bin/kafka-server-start.sh config/server-2.properties
bin/kafka-server-start.sh config/server-3.properties

#后台常驻方式，带上参数 -daemon，如：
#/data/kafka/bin/zookeeper-server-start.sh -daemon /data/kafka/config/zookeeper.properties
#/data/kafka/bin/kafka-server-start.sh     -daemon /data/kafka/config/server.properties 

#指定 JMX port 端口启动，指定 jmx，可以方便监控 Kafka 集群
#JMX_PORT=9991 /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

```

‍

‍

# Kafka 部署

## 一、Zookeeper集群搭建 zookeeper 部署

　　**Zookeeper的作用：依赖Zookeeper的一致性选举**

　　Kafka集群有多个节点组成，在管理集群级别的任务和数据时，必须有一个主来充当指挥者，Kafka内将这个主节点命名为Controller。在集群第一次启动或是Controller宕机时，集群内每个节点都会去争取当选Controller，在复杂网络环境下，要形成一个一致性的选举结果，目前这个任务是交由Zookeeper来完成的，各个节点在Zookeeper上抢占一个临时节点来当选，Kafka集群内部并未实现一致性协议。类似的主节点选举还包括每个分区的主副本(leader replica)。

## 二、Kafka 搭建

### 2.1 下载解压

　　Kafka 安装包官方下载地址：[http://kafka.apache.org/downloads](http://kafka.apache.org/downloads) ，本用例下载的版本为 `2.2.0`​，下载命令：

```shell
# 下载
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz
# 解压
tar -xzf kafka_2.12-2.2.0.tgz
```

> 这里解释一下 kafka 安装包的命名规则：以 `kafka_2.12-2.2.0.tgz`​ 为例，前面的 2.12 代表 Scala 的版本号（Kafka 采用 Scala 语言进行开发），后面的 2.2.0 则代表 Kafka 的版本号。

### 2.2 拷贝配置文件

　　进入解压目录的 `config`​ 目录下 ，拷贝三份配置文件：

```shell
# cp server.properties server-1.properties
# cp server.properties server-2.properties
# cp server.properties server-3.properties
```

### 2.3 修改配置

　　分别修改三份配置文件中的部分配置，如下：

　　server-1.properties：

```ini
# The id of the broker. 集群中每个节点的唯一标识
broker.id=0
# 监听地址
listeners=PLAINTEXT://hadoop001:9092
# 数据的存储位置
log.dirs=/usr/local/kafka-logs/00
# Zookeeper连接地址
zookeeper.connect=hadoop001:2181,hadoop001:2182,hadoop001:2183
```

　　server-2.properties：

```ini
broker.id=1
listeners=PLAINTEXT://hadoop001:9093
log.dirs=/usr/local/kafka-logs/01
zookeeper.connect=hadoop001:2181,hadoop001:2182,hadoop001:2183
```

　　server-3.properties：

```ini
broker.id=2
listeners=PLAINTEXT://hadoop001:9094
log.dirs=/usr/local/kafka-logs/02
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
#/opt/kafka/bin/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties
#/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties 

#指定 JMX port 端口启动，指定 jmx，可以方便监控 Kafka 集群
#JMX_PORT=9991 /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

```

　　‍

## 三、**常用命令**

### **创建topic**

```bash
./kafka-topics.sh --create --zookeeper 172.168.0.12:2181 --replication-factor 1 --partitions 1      --topic test-topic
./kafka-topics.sh --create --zookeeper 192.168.160.11:2181,192.168.190.12:2181,192.168.190.13:2181  --topic test-topic --partitions 3 --replication-factor 3
# 新版本方式
./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic quanyu-topic --replication-factor 1 --partitions 2
-------------------------------------------------------------------------
#   --zookeeper 192.168.160.11:2181,192.168.190.12:2181,192.168.190.13:2181：创建zookeeper主机ip，
#   --create：执行的动作
#   --topic test-topic：topic名字
#   --partitions 3：创建三个分区，在该topic下创建三个分区
#   --replication-factor 3：生成3个副本
```

### **查看topic列表**

```bash
./kafka-topics.sh --bootstrap-server 172.168.0.12:9092 --list

#   PartitionCount：1表示该主题的分区数。
#   ReplicationFactor：1表示每个分区的副本数，为1的话，表示该分区只有一个分区，即该分区就是leader。
#   Partition：0表示的是该主题的第几个分区，该标识符从0开始逐次加1递增。
#   Leader：表示的是领导者分区的位置，即是brokeid的取值（leader 是在给出的所有partitons中负责读写的节点，每个节点都有可能成为leader）。
#   Repicas：表示的是所有副本（包含主分区）的位置集合，可用逗号分隔开。

#   Isr：位于同步队列的副本（包含主分区）的集合。
```

### **查看topic相关详细信息**

```bash
./kafka-topics.sh --bootstrap-server 172.168.0.12:9092  --describe
```

### **建立生产者**

```bash
./kafka-console-producer.sh --broker-list 172.168.0.12:9092 --topic quanyu-topic
>123
>222
>333

# 以上命令执行完成之后会开始等待输入，每次输入完成后敲入回车便会发送一条消息，如以下截图，共发送了三条消息：111，222，333
# 如要停止该生产者，则输入Ctrl+Z即可退出。
```

### **建立消费者**

```bash
./kafka-console-consumer.sh --bootstrap-server 172.168.0.12:9092 --topic quanyu-topic --from-beginning --consumer.config ../config/consumer.properties
```

### **删除Topic**

```bash
./kafka-topics.sh --bootstrap-server 172.168.0.12:9092 --delete --topic quanyu-topic
```

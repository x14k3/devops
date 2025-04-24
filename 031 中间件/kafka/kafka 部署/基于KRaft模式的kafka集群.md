# 基于KRaft模式的kafka集群

## 1.集群规划

一般模式下，元数据在 zookeeper 中，运行时动态选举 controller，由controller 进行 Kafka 集群管理。kraft 模式架构（实验性）下，不再依赖 zookeeper 集群，而是用三台 controller 节点代替 zookeeper，元数据保存在 controller 中，由 controller 直接进行 Kafka 集群管理。

好处有以下几个：

* Kafka 不再依赖外部框架，而是能够独立运行
* controller 管理集群时，不再需要从 zookeeper 中先读取数据，集群性能上升
* 由于不依赖 zookeeper，集群扩展时不再受到 zookeeper 读写能力限制
* controller 不再动态选举，而是由配置文件规定。可以有针对性的加强controller 节点的配置，而不是像以前一样对随机 controller 节点的高负载束手无策。

‍

|名称|ip地址|<br />|
| :------: | :--------------: | ----|
|kafka1|192.168.58.130||
|kafka2|192.168.58.131||
|kafka3|192.168.58.132||

## 2.集群部署

### 1.下载kafka二进制包

[https://kafka.apache.org/downloads](https://kafka.apache.org/downloads)

```bash
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz
```

### 2.解压

```shell
mkdir /usr/kafka 
tar -zxvf /home/kafka_2.13-3.6.1.tgz -C /usr/kafka/
```

### 3.修改配置文件(以192.168.58.130上节点的配置为例)

```shell
cd /usr/kafka/kafka_2.13-3.6.1/config/kraft 
vi server.properties
```

​`注：Kraft模式的配置文件在config目录的kraft子目录下`​

```properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This configuration file is intended for use in KRaft mode, where
# Apache ZooKeeper is not present.
#

############################# Server Basics #############################

# 此服务器的角色。设置此项将进入KRaft模式(controller 相当于主机、broker 节点相当于从机,主机类似 zk 功能)
process.roles=broker,controller

# 节点 ID
node.id=2

# 全 Controller 列表
controller.quorum.voters=2@192.168.58.130:9093,3@192.168.58.131:9093,4@192.168.58.132:9093

############################# Socket Server Settings #############################

# 套接字服务器侦听的地址.
# 组合节点（即具有`process.roles=broker,controller`的节点）必须至少在此处列出控制器侦听器
# 如果没有定义代理侦听器，那么默认侦听器将使用一个等于java.net.InetAddress.getCanonicalHostName()值的主机名,
# 带有PLAINTEXT侦听器名称和端口9092
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
#不同服务器绑定的端口
listeners=PLAINTEXT://192.168.58.130:9092,CONTROLLER://192.168.58.130:9093

# 用于代理之间通信的侦听器的名称(broker 服务协议别名)
inter.broker.listener.name=PLAINTEXT

# 侦听器名称、主机名和代理将向客户端公布的端口.(broker 对外暴露的地址)
# 如果未设置，则使用"listeners"的值.
advertised.listeners=PLAINTEXT://192.168.58.130:9092

# controller 服务协议别名
# 控制器使用的侦听器名称的逗号分隔列表
# 如果`listener.security.protocol.map`中未设置显式映射，则默认使用PLAINTEXT协议
# 如果在KRaft模式下运行，这是必需的。
controller.listener.names=CONTROLLER

# 将侦听器名称映射到安全协议，默认情况下它们是相同的。(协议别名到安全协议的映射)有关更多详细信息，请参阅配置文档.
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

# 服务器用于从网络接收请求并向网络发送响应的线程数
num.network.threads=3

# 服务器用于处理请求的线程数，其中可能包括磁盘I/O
num.io.threads=8

# 套接字服务器使用的发送缓冲区（SO_SNDBUF）
socket.send.buffer.bytes=102400

# 套接字服务器使用的接收缓冲区（SO_RCVBUF）
socket.receive.buffer.bytes=102400

# 套接字服务器将接受的请求的最大大小（防止OOM）
socket.request.max.bytes=104857600


############################# Log Basics #############################

# 存储日志文件的目录的逗号分隔列表(kafka 数据存储目录)
log.dirs=/usr/kafka/kafka_2.13-3.6.1/datas

# 每个主题的默认日志分区数。更多的分区允许更大的并行性以供使用，但这也会导致代理之间有更多的文件。
num.partitions=1

# 启动时用于日志恢复和关闭时用于刷新的每个数据目录的线程数。
# 对于数据目录位于RAID阵列中的安装，建议增加此值。
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings  #############################
# 组元数据内部主题"__consumer_offsets"和"__transaction_state"的复制因子
# 对于除开发测试以外的任何测试，建议使用大于1的值来确保可用性，例如3.
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

############################# Log Flush Policy #############################

# 消息会立即写入文件系统，但默认情况下，我们只使用fsync()进行同步
# 操作系统缓存延迟。以下配置控制将数据刷新到磁盘.
# 这里有一些重要的权衡:
#    1. Durability(持久性): 如果不使用复制，未清理的数据可能会丢失
#    2. Latency(延迟): 当刷新发生时，非常大的刷新间隔可能会导致延迟峰值，因为将有大量数据要刷新.
#    3. Throughput(吞吐量): 刷新通常是最昂贵的操作，较小的刷新间隔可能导致过多的寻道.
# 下面的设置允许配置刷新策略，以便在一段时间后或每N条消息（或两者兼有）刷新数据。这可以全局完成，并在每个主题的基础上覆盖

# 强制将数据刷新到磁盘之前要接受的消息数
#log.flush.interval.messages=10000

# 在我们强制刷新之前，消息可以在日志中停留的最长时间
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################

# 以下配置控制日志段的处理。可以将该策略设置为在一段时间后删除分段，或者在累积了给定大小之后删除分段。
# 只要满足这些条件中的任意一个，segment就会被删除。删除总是从日志的末尾开始

# 日志文件因使用年限而有资格删除的最短使用年限
log.retention.hours=168

# 基于大小的日志保留策略。除非剩余的段低于log.retention.bytes，否则将从日志中删除段。独立于log.retention.hours的函数。
#log.retention.bytes=1073741824

# 日志segment文件的最大大小。当达到此大小时，将创建一个新的日志segment
log.segment.bytes=1073741824

# 检查日志segments以查看是否可以根据保留策略删除它们的间隔
log.retention.check.interval.ms=300000
```

### 4.在其他节点上修改配置文件

在 192.168.58.131 和 192.168.58.132 上修改配置文件`server.properties`​中

#### 1.`node.id`​

注：node.id 不得重复，整个集群中唯一，且值需要和controller.quorum.voters 对应。

#### 2.`dvertised.Listeners`​地址

根据各自的主机名称，修改相应的 dvertised.Listeners 地址

#### 3.`listeners`​地址

根据各自的主机IP修改

```properties
# 节点 ID
node.id=3

#不同服务器绑定的端口
listeners=PLAINTEXT://192.168.58.131:9092,CONTROLLER://192.168.58.131:9093

# 侦听器名称、主机名和代理将向客户端公布的端口.(broker 对外暴露的地址)
# 如果未设置，则使用"listeners"的值.
advertised.listeners=PLAINTEXT://192.168.58.131:9092
```

```properties
# 节点 ID
node.id=4

#不同服务器绑定的端口
listeners=PLAINTEXT://192.168.58.132:9092,CONTROLLER://192.168.58.132:9093

# 侦听器名称、主机名和代理将向客户端公布的端口.(broker 对外暴露的地址)
# 如果未设置，则使用"listeners"的值.
advertised.listeners=PLAINTEXT://192.168.58.132:9092
```

### 5.初始化集群数据目录

#### 1.首先生成存储目录唯一 ID。

```shell
bin/kafka-storage.sh random-uuid
```

输出ID：`7TraW-eCQXCx-HYoNY5VKw`​

#### 2.用该 ID 格式化 kafka 存储目录（每个节点都需要执行）

```shell
bin/kafka-storage.sh format -t 7TraW-eCQXCx-HYoNY5VKw -c /usr/kafka/kafka_2.13-3.6.1/config/kraft/server.properties
```

### 6.配置环境变量

在/etc/profile.d中配置

#### 1.新建kafka.sh

```shell
vi /etc/profile.d/kafka.sh
```

```sh
# KAFKA_HOME
export KAFKA_HOME=/usr/kafka/kafka_2.13-3.6.1
export PATH=$PATH:$KAFKA_HOME/bin
```

#### 2.授予文件执行权限

```shell
chmod u+x /etc/profile.d/kafka.sh
```

#### 3.刷新环境变量

```shell
source /etc/profile
```

### 7.启动集群

#### 1.在节点上依次启动 Kafka

```shell
bin/kafka-server-start.sh -daemon /usr/kafka/kafka_2.13-3.6.1/config/kraft/server.properties
```

#### 2.kafka一键启停脚本

##### 1.创建脚本

```shell
vi /usr/bin/kafka
```

```sh
#! /bin/bash

if [ $# -lt 1 ]; then
	echo "No Args Input..."
	exit
fi

case $1 in
"start") {
	for i in 192.168.58.130 192.168.58.131 192.168.58.132; do
		echo " --------启动 $i Kafka-------"
		ssh $i "source /etc/profile;/usr/kafka/kafka_2.13-3.6.1/bin/kafka-server-start.sh -daemon /usr/kafka/kafka_2.13-3.6.1/config/kraft/server.properties"
	done
} ;;
"stop") {
	for i in 192.168.58.130 192.168.58.131 192.168.58.132; do
		echo " --------停止 $i Kafka-------"
		ssh $i "source /etc/profile;/usr/kafka/kafka_2.13-3.6.1/bin/kafka-server-stop.sh"
	done
} ;;
*)
	echo "Input Args Error..."
	;;
esac
```

##### 2.添加执行权限

```shell
chmod +x /usr/bin/kafka
```

##### 3.使用

```shell
kafka start/stop
```

### 8.关闭集群

```shell
/usr/kafka/kafka_2.13-3.6.1/bin/kafka-server-stop.sh
```

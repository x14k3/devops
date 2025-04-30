# kafka 常用命令

## 1.Topic(主题)命令行操作

​`bin/kafka-topics.sh`​

以下展示为最常使用的

|参数|描述|
| -------------------------------------------------------| --------------------------------------|
|\--bootstrap-server <String: server toconnect to>|连接的 Kafka Broker 主机名称和端口号|
|\--topic <String: topic>|操作的 topic 名称|
|\--create|创建Topic(主题)|
|\--delete|删除Topic(主题)|
|\--alter|修改Topic(主题)|
|\--list|查看所有Topic(主题)|
|\--describe|查看Topic(主题)详细描述|
|\--partitions <Integer: # of partitions>|设置分区数|
|\--replication-factor<Integer: replication factor>|设置分区副本|
|\--config <String: name=value>|更新系统默认的配置|

### 查看当前服务器中的所有 topic

```bash
./bin/kafka-topics.sh --list --bootstrap-server 192.168.133.11:9092
# and
./bin/kafka-topics.sh --list --zookeeper        192.168.133.11:2181
```

### 创建 first topic

```bash
./bin/kafka-topics.sh --create --bootstrap-server 192.168.133.11:9092 --partitions 1 --replication-factor 1 --topic testTopic1
# 或者
./bin/kafka-topics.sh --create --zookeeper        127.0.0.1:2181      --partitions 1 --replication-factor 2 --topic testTopic2
# 选项说明
#--topic              定义 topic 名
#--replication-factor 定义副本数
#--partitions         定义分区数
```

### 查看 first 主题的详情

```shell
./bin/kafka-topics.sh --describe --bootstrap-server 192.168.133.11:9092 --topic first
# 
./bin/kafka-topics.sh --describe --zookeeper 127.0.0.1:2181             --topic first
```

### 修改分区数（注意：分区数只能增加，不能减少）

```shell
./bin/kafka-topics.sh --bootstrap-server 192.168.133.11:9092 --alter --topic first --partitions 3
```

### 删除 topic

```shell
./bin/kafka-topics.sh --bootstrap-server 192.168.133.11:9092 --delete --topic first
```

## 2.producer(生产者)命令行操作

​`bin/kafka-console-producer.sh`​

以下展示为最常使用的

|参数|描述|
| ------------------------------------------------------| --------------------------------------|
|\--bootstrap-server <String: server toconnect to>|连接的 Kafka Broker 主机名称和端口号|
|\--topic <String: topic>|操作的 topic 名称|

### 发送消息

```shell
./bin/kafka-console-producer.sh --bootstrap-server 192.168.133.11:9092 --topic first
```

## 3.consumer(消费者)命令行操作

​`bin/kafka-console-consumer.sh`​

以下展示为最常使用的

|参数|描述|
| ------------------------------------------------------| --------------------------------------|
|\--bootstrap-server <String: server toconnect to>|连接的 Kafka Broker 主机名称和端口号|
|\--topic <String: topic>|操作的 topic 名称|
|\--from-beginning|从头开始消费|
|\--group <String: consumer group id>|指定消费者组名称|

### 消费 first 主题中的数据

```shell
./bin/kafka-console-consumer.sh --bootstrap-server 192.168.133.11:9092  --topic first
```

### 把主题中所有的数据都读取出来（包括历史数据）

```shell
./bin/kafka-console-consumer.sh --bootstrap-server 192.168.133.11:9092  --from-beginning --topic first
```

‍

## 附：脚本

‍

```bash
#!/bin/bash

KafkaBin="/data/kafka/bin"
Cluster="192.168.133.11:9092,192.168.133.12:9092,192.168.133.13:9092"
# Generate random data
generData() {
for((i=1;i<=20;i++))
do
    topicName=topic-${i}
    partNum=$(($RANDOM%2+1))
    repNum=$(($RANDOM%2+1))
 	# Create topic
	${KafkaBin}/kafka-topics.sh --bootstrap-server ${Cluster} --create --topic ${topicName} --partitions ${partNum} --replication-factor ${repNum}
	# gener producer
	for((j=1;j<=5;j++))
	do
		${KafkaBin}/kafka-console-producer.sh --bootstrap-server ${Cluster} --topic ${topicName} <<<  "Message-$(date +%s%N)"
	done
done
}

deletData() {
for topicName in $(${KafkaBin}/kafka-topics.sh --bootstrap-server ${Cluster} --list)
do
	${KafkaBin}/kafka-topics.sh --bootstrap-server ${Cluster} --delete --topic ${topicName} 
done 

}

selecData() {
${KafkaBin}/kafka-topics.sh --bootstrap-server ${Cluster} --describe


}

case $1 in 
	add)
		generData
	;;
	delete)
		deletData
	;;
	select)
		selecData
	;;
	*)
		echo "kafka_tools.sh [ add | delete | select ]"
	;;
esac

```

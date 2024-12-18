# kafka_topic批量提取导入脚本

　　1.列出所有topic

```bash
[root@localhost opt]# /opt/kafka1/bin/kafka-topics.sh  --zookeeper  127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 --describe 
Topic: test1	PartitionCount: 1	ReplicationFactor: 1	Configs: 
	Topic: test1	Partition: 0	Leader: 2	Replicas: 2	Isr: 2
Topic: test2	PartitionCount: 2	ReplicationFactor: 2	Configs: 
	Topic: test2	Partition: 0	Leader: 0	Replicas: 0,1	Isr: 0,1
	Topic: test2	Partition: 1	Leader: 1	Replicas: 1,2	Isr: 1,2
[root@localhost opt]# /opt/kafka1/bin/kafka-topics.sh  --zookeeper  127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 --describe | grep Configs 
Topic: test1	PartitionCount: 1	ReplicationFactor: 1	Configs: 
Topic: test2	PartitionCount: 2	ReplicationFactor: 2	Configs: 

```

　　2.使用awk截取 topic名 ，Partitions ，replication-factor

```bash
[root@localhost opt]# /opt/kafka1/bin/kafka-topics.sh  --zookeeper  127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 --describe | grep Configs | awk '{print $2,$4,$6}'
test1 1 1
test2 2 2
[root@localhost opt]#
```

　　3.生成topic create脚本

```bash
#!/bin/bash

while read line
do
    topicName=$(echo "${line}" |awk '{print $1}')
    partNum=$(echo "${line}" |awk '{print $2}')
    repNum=$(echo "${line}" |awk '{print $3}')

# echo '/opt/kafka1/bin/kafka-topics.sh --zookeeper 127.0.0.1:2181 --create --topic '${topicName}' --partitions '${partNum}' --replication-factor '${repNum}''
/opt/kafka1/bin/kafka-topics.sh --zookeeper 127.0.0.1:2181 --create --topic ${topicName} --partitions ${partNum} --replication-factor ${repNum}

done < /opt/2.txt
```

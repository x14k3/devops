# kafka 历史数据清理策略以及配置

## 关于 Kafka 的日志

日志的英语是“log”，但 Kafka 的数据文件也被称为 log，所以很多时候会造成一定的歧义。在 Kafka 中，日志分为两种：

- 数据日志
- 操作日志

数据日志是指 Kafka 的 topic 中存储的数据，这种日志的路径是在`$KAFKA_HOME/config/server.properties`​文件中配置，配置项为 log.dirs。如果此项没有被配置，默认会使用配置项 log.dir（请仔细观察，两个配置项最后差了一个 s）。log.dir  的默认路径为/tmp/kafka-logs，大家知道，/tmp  路径下的文件在计算机重启的时候是会被删除的，因此，强烈推荐将文件目录设置在其他可以永久保存的路径。另一种日志是操作日志，类似于我们在自己开发的程序中输出的 log 日志（log4j），这种日志的路径是在启动 Kafka 的路径下。比如一般我们在 KAFKA\_HOME 路径下启动 Kafka  服务，那么操作日志的路径为 KAFKA\_HOME/logs。

### 数据日志清理

数据日志有两种类型的清理方式，一种是按照日志被发布的时间来删除，另一种是按照日志文件的 size 来删除。有专门的配置项可以配置这个删除策略：

#### 按时间删除

Kafka 提供了配置项让我们可以按照日志被发布的时间来删除。它们分别是：

- log.retention.ms
- log.retention.minutes
- log.retention.hours

根据配置项的名称很容易理解它们的含义。log.retention.ms 表示日志会被保留多少毫秒，如果为 null，则 Kafka 会使用使用 log.retention.minutes  配置项。log.retention.minutes 表示日志会保留多少分钟，如果为 null，则 Kafka 会使用  log.retention.hours 选项。默认情况下，log.retention.ms 和 log.retention.minutes 均为 null，log.retention.hours 为 168，即 Kafka 的数据日志默认会被保留 7 天。如果想修改 Kafka  中数据日志被保留的时间长度，可以通过修改这三个选项来实现。

#### 按 size 删除

Kafka 除了提供了按时间删除的配置项外，也提供了按照日志文件的 size 来删除的配置项：

- log.retention.bytes

即日志文件到达多少 byte 后再删除日志文件。默认为-1，即无限制。需要注意的是，这个选项的值如果小于 segment 文件大小的话是不起作用的。segment 文件的大小取决于 log.segment.bytes 配置项，默认为 1G。 另外，Kafka 的日志删除策略并不是非常严格的（比如如果 log.retention.bytes 设置了 10G 的话，并不是超过 10G  的部分就会立刻删除，只是被标记为待删除，Kafka 会在恰当的时候再真正删除），所以请预留足够的磁盘空间。当磁盘空间剩余量为 0 时，Kafka 服务会被 kill 掉。

### 操作日志清理

目前 Kafka 的操作日志暂时不提供自动清理的机制，需要运维人员手动干预，比如使用 shell 和 crontab 命令进行定时备份、清理等。

链接：https://www.jianshu.com/p/d4c19fed4742

### 实际操作

查看某个 topic 的保留时长：

```go
./kafka-topics.sh --bootstrap-server 10.3.1.173:9092 --describe --topic diamond-ds-207-binlog-sale-repl
Topic:diamond-ds-207-binlog-sale-repl	PartitionCount:8	ReplicationFactor:2	Configs:compression.type=snappy,flush.ms=10000,segment.bytes=1073741824,retention.ms=1296000000,flush.messages=20000,max.message.bytes=30000000,index.interval.bytes=4096,segment.index.bytes=10485760
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 0	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 1	Leader: 24	Replicas: 24,25	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 2	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 3	Leader: 24	Replicas: 24,25	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 4	Leader: 25	Replicas: 25,24	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 5	Leader: 24	Replicas: 24,25	Isr: 25,24
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 6	Leader: 25	Replicas: 25,24	Isr: 24,25
	Topic: diamond-ds-207-binlog-sale-repl	Partition: 7	Leader: 24	Replicas: 24,25	Isr: 24,25
```

其中的 `retention.ms=1296000000`​换算一下就是 15 天。

其他参数讲解：

- Topic：对应 topic 名字
- PartitionCount：分区数
- ReplicationFactor：副本数
- compression.type：压缩类型，压缩的速度上 lz4\=snappy\<gzip。还可以设置'uncompressed',就是不压缩；设置为'producer'这意味着保留生产者设置的原始压缩编解码。
- flush.ms：此设置允许我们强制 fsync 写入日志的数据的时间间隔。例如，如果这设置为 1000，那么在 1000ms 过去之后，我们将 fsync。 一般，我们建议不要设置它，并使用复制来保持持久性，并允许操作系统的后台刷新功能，因为它更有效率
- segment.bytes：此配置控制日志的段文件大小。一次保留和清理一个文件，因此较大的段大小意味着较少的文件，但对保留率的粒度控制较少。
- retention.ms：如果我们使用“删除”保留策略，则此配置控制我们将保留日志的最长时间，然后我们将丢弃旧的日志段以释放空间。这代表 SLA 消费者必须读取数据的时间长度。
- flush.messages：此设置允许指定我们强制 fsync 写入日志的数据的间隔。例如，如果这被设置为 1，我们将在每个消息之后 fsync; 如果是 5，我们将在每五个消息之后  fsync。一般，我们建议不要设置它，使用复制特性来保持持久性，并允许操作系统的后台刷新功能更高效。可以在每个 topic 的基础上覆盖此设置。
- max.message.bytes：kafka 允许的最大的消息批次大小。如果增加此值，并且消费者的版本比 0.10.2 老，那么消费者的提取的大小也必须增加，以便他们可以获取大的消息批次。 在最新的消息格式版本中，消息总是分组批量来提高效率。在之前的消息格式版本中，未压缩的记录不会分组批量，并且此限制仅适用于该情况下的单个消息。
- index.interval.bytes：此设置控制 Kafka 向其 offset 索引添加索引条目的频率。默认设置确保我们大致每 4096 个字节索引消息。 更多的索引允许读取更接近日志中的确切位置，但使索引更大。你不需要改变这个值。
- segment.index.bytes：此配置控制 offset 映射到文件位置的索引的大小。我们预先分配此索引文件，并在日志滚动后收缩它。通常不需要更改此设置。

上边是生产的环境，下边到一个测试环境来进行一波操作。

最开始的初始情况如下：

```go
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```

同时也可以用如下命令查看是否又进行过单独配置：

```go
./kafka-configs.sh --describe --zookeeper localhost:2181 --entity-type topics  --entity-name liql-test1
Configs for topic 'liql-test1' are
```

返回如上信息说明此 topic 使用的是默认配置，并没有进行任何配置。

现在来配置一下这个 topic 保留时长，现在不能使用 `./kafka-topics.sh`​命令来调整了，否则会报错如下：

```go
$./kafka-topics.sh  --zookeeper localhost:2181  --topic liql-test1 --alert --config retention.ms=2678400000
Exception in thread "main" joptsimple.UnrecognizedOptionException: alert is not a recognized option
	at joptsimple.OptionException.unrecognizedOption(OptionException.java:108)
	at joptsimple.OptionParser.handleLongOptionToken(OptionParser.java:510)
	at joptsimple.OptionParserState$2.handleArgument(OptionParserState.java:56)
	at joptsimple.OptionParser.parse(OptionParser.java:396)
	at kafka.admin.TopicCommand$TopicCommandOptions.<init>(TopicCommand.scala:358)
	at kafka.admin.TopicCommand$.main(TopicCommand.scala:44)
	at kafka.admin.TopicCommand.main(TopicCommand.scala)
```

而应该使用如下命令：

```go
$./kafka-configs.sh --zookeeper localhost:2181 --alter --entity-name liql-test1 --entity-type topics --add-config retention.ms=1296000000
Completed Updating config for entity: topic 'liql-test1'.
```

再查看一下相关信息：

```go
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:retention.ms=1296000000
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```

如果需要调整，则可以进行如下操作：

```go
$./kafka-configs.sh --zookeeper localhost:2181 --alter --entity-name liql-test1 --entity-type topics --add-config retention.ms=432000000
Completed Updating config for entity: topic 'liql-test1'.
```

然后就把保留时间更改为 5 天了：

```go
$./kafka-topics.sh  --zookeeper localhost:2181 --describe --topic liql-test1
Topic:liql-test1	PartitionCount:5	ReplicationFactor:1	Configs:retention.ms=432000000
	Topic: liql-test1	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 2	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 3	Leader: 0	Replicas: 0	Isr: 0
	Topic: liql-test1	Partition: 4	Leader: 0	Replicas: 0	Isr: 0
```

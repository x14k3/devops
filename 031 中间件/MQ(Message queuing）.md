# MQ(Message queuing）

　　Message Queue 的需求由来已久，在 19 世纪 80 年代金融交易中，美国高盛等公司采用Teknekron 公司的产品，当时的  Message queuing 软件叫做(the information  bus（TIB），后来TIB被电信和通讯等公司采用，然后路透社收购了Teknekron  公司，再然后IBM公司开发了MQSeries，并且微软也开发了 Microsoft Message Queue（MSMQ），但是这些商业 MQ  供应商的问题是厂商锁定及使用价格高昂， 于是 2001 年，Java Message queuing  试图解决锁定和交互性的问题，但对应用来说反而更加麻烦了，于是 2004 年，摩根大通和 iMatrix 开始着手 Advanced  Message Queuing Protocol （AMQP）开放标准的开发，2006 年，AMQP 规范发布，2007 年，Rabbit  技术公司基于 AMQP 标准开发的 RabbitMQ 1.0 发布。

　　**MQ 定义**

　　消息队列的目的是为了实现各个 APP 之间的通讯，APP 基于 MQ 实现消息的发送和接收实现应用程序之间的通讯，这样多个应用程序可以运行在不同的主机上， 通过 MQ 就可以实现夸网络通信，因此 MQ 实现了业务的解耦和异步机制

　　**MQ使用场合**

　　消息队列作为高并发系统的核心组件之一，能够帮助业务系统结构提升开发效率和系统稳定性，消息队列主要具有以下特点

```bash
削峰填谷（主要解决瞬时写压力大于应用服务能力导致消息丢失、系统奔溃等问题）
系统解耦（解决不同重要程度、不同能力级别系统之间依赖导致一死全死）
提升性能（当存在一对多调用时，可以发一条消息给消息系统，让消息系统通知相关系统）
蓄流压测（线上有些链路不好压测，可以通过堆积一定量消息再放开来压测）
```

　　**MQ 分类**

　　目前主流的消息队列软件有 RabbitMQ、kafka、ActiveMQ、RocketMQ 等，还有小众的消息队列软件如 ZeroMQ、Apache Qpid等。

　　‍

* 📑 [ActiveMQ](siyuan://blocks/20231110105237-8sq0y3z)

  * 📄 [activemq 优化](siyuan://blocks/20231110105237-br404dd)
  * 📑 [activemq 部署](siyuan://blocks/20231110105237-w2d9iw3)

    * 📄 [Broker-Cluster模式](siyuan://blocks/20240507140430-cn74j01)
    * 📄 [Master-slave模式](siyuan://blocks/20240507140248-ehmmmug)
    * 📄 [单例模式](siyuan://blocks/20240507135745-15h5hxl)
  * 📄 [activemq+ssl](siyuan://blocks/20231110105237-8co62y1)
* 📑 [Kafka](siyuan://blocks/20231110105237-886v0bv)

  * 📄 [Kafka 为什么 Kafka 依赖 ZooKeeper？](siyuan://blocks/20240812180749-cxv2f0w)
  * 📄 [Kafka 可视化测试工具](siyuan://blocks/20240829162804-zek8n9s)
  * 📄 [Kafka 数据日志、副本机制和消费策略](siyuan://blocks/20240829162356-cky4t9r)
  * 📄 [Kafka 部署](siyuan://blocks/20231110105237-1dmh9kh)
  * 📄 [zookeeper 部署](siyuan://blocks/20231110105237-xah50sz)
* 📑 [RabbitMQ](siyuan://blocks/20240812174824-l8v7z3w)

  * 📄 [1. RabbitMQ 简介](siyuan://blocks/20240812174849-1l657ex)
  * 📄 [2. RabbitMQ 单机部署](siyuan://blocks/20240812174920-pdx6uoh)
  * 📄 [3. RabbitMQ 集群部署](siyuan://blocks/20240812175849-xfd1h3i)

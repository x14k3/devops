#middleware/zookeeper

# zookeeper 作用

**ZooKeeper是一个开放源码的分布式应用程序协调服务，是Google的Chubby一个开源的实现，是Hadoop和Hbase的重要组件。它是一个为分布式应用提供一致性服务的软件，提供的功能包括：配置维护、域名服务、分布式同步、组服务等。**

> 数据发布/订阅

数据发布/订阅（Publish/Subscribe）系统，即所谓的配置中心，顾明思义就是发布者将数据发布到zookeeper的一个或一系列的节点上，供订阅者进行数据订阅，进而达到动态获取数据的目的，实现配置信息的集中式管理和数据的动态更新。

> 负载均衡

每台服务端在启动时都会去zookeeper的servers节点下注册临时节点（注册临时节点是因为，当服务不可用时，这个临时节点会消失，客户端也就不会请求这个服务端），每台客户端在启动时都会去servers节点下取得所有可用的工作服务器列表，并通过一定的负载均衡算法计算得出应该将请求发到哪个服务器上

> 命名服务

命名服务是分布式系统中比较常见的一类场景。在分布式系统中，被命名的实体通常可以是集群中的机器，提供的服务地址或远程对象等-这些我们都可以统称他们为名字，其中较为常见的就是一些分布式服务框架（如RPC，RMI）中的服务地址列表，通过命名服务，客户端应用能够根据指定名字来获取资源的实体，服务地址和提供者的信息等。

> Master选举

Master选举是一个在分布式系统中非常常见的应用场景。在分布式系统中，Master往往用来协调系统中的其他系统单元，具有对分布式系统状态变更的决定权。例如，在一些读写分离的应用场景用，客户端的写请求往往是由Master来处理的，而在另一些场景中， Master则常常负负责处理一下复杂的逻辑，并将处理结果同步给集群中其他系统单元。Master选举可以说是zookeeper最典型的应用场景了

> 分布式锁

在同一个JVM中，为了保证对一个资源的有序访问，如往文件中写数据，可以用synchronized或者ReentrantLock来实现对资源的互斥访问，如果2个程序在不同的JVM中，并且都要往同一个文件中写数据，如何保证互斥访问呢？这时就需要用到分布式锁了

> 分布式队列

如上图，创建/queue作为一个队列，然后每创建一个顺序节点，视为一条消息(节点存储的数据即为消息内容)，生产者每次创建一个新节点，做为消息发送，消费者监听queue的子节点变化（或定时轮询)，每次取最小节点当做消费消息，处理完后，删除该节点。相当于实现了一个FIFO(先进先出)的队列。 注：zookeeper强调的是CP（一致性)，而非专为高并发、高性能场景设计的，如果在高并发，qps很高的情况下，分布式队列需酌情考虑。

![](assets/zookeeper%20部署/image-20221127215408692.png)




# zookeeper的特性

- 全局数据一致： 每个server保存一份相同的数据副本，client无论连接到那个server，展示的数据都是一致的。  
- 可靠性：  如果消息被其中一台服务器接收，那么将被所有的服务器接受。  
- 顺序性：  包括全局有序和偏序两种：全局有序是指如果在一台服务器上消息 a 在消息 b 前发布，则在所有 Server 上消息 a 都将在消息 b 前被发布；偏序是指如果一个消息 b 在消息 a 后被同一个发送者发布， a 必将排在 b 前面。  
- 数据更新原子性：  一次数据更新要么成功，要么失败，不存在中间状态。  
- 实时性：  zookeeper客户端将在一个时间间隔范围内获得服务器的更新信息，或者服务器失效的信息。

# zookeeper集群环境搭建

## 1. 环境说明

```
centos7.9
zookeeper-3.8.0
jdk1.8.0_333
```

## 2. 配置主机名称

三台机器均需要配置

```
[root@dn1 /root]# vi /etc/hosts
192.168.0.10 zk1
192.168.0.20 zk2
192.168.0.30 zk3
```

## 3. 配置jdk环境

3台服务器都安装jdk：[[jdk 安装](../jdk/jdk%20安装.md)]

## 4. 安装zookeeper

创建软连接，配置zookeeper的环境变量，三台机器均需要配置

```bash
tar -zxf apache-zookeeper-3.8.0-bin.tar.gz 
mv apache-zookeeper-3.8.0 zookeeper
export ZK_HOME=/data/zookeeper
export PATH=$PATH:$ZK_HOME/bin
```

## 5. 修改zoo.cfg配置文件

首先需要创建zoo.cfg，创建zookeeper数据目录zkdatas，再对zoo.cfg文件进行修改，三台机器均要配置

```bash
cd $ZK_HOME/conf
cp zoo_sample.cfg zoo.cfg

vim zoo.cfg
---------------------------------------------------------
# zookeeper客户端与服务器之间的心跳时间就是一个tickTime单位。默认值为2000毫秒，即2秒
tickTime=2000
# Follower连接到Leader并同步数据的最大时间，如果zookeeper数据比较大，可以考虑调大这个值来避免报错
initLimit=10
# Follower同步Leader的最大时间
syncLimit=5
# 主要用来配置zookeeper server数据的存放路径
dataDir=/data/zookeeper/data
# 主要定义客户端连接zookeeper server的端口，默认情况下为2181
clientPort=2181

#主要用来设置集群中某台server的参数，格式[hostname]:n:n[:observer]，
#zookeeper server启动的时候，会根据dataDirxia的myid文件确定当前节点的id。
#该参数里，第一个port是follower连接leader同步数据和转发请求用，
#第二个端口是leader选举用的
server.1=192.168.0.10:2888:3888
server.2=192.168.0.10:2888:3888
server.3=192.168.0.10:2888:3888

#其他配置
#这个参数指定了清理频率，单位是小时
#autopurge.purgeInterval=5
#这个参数指定了需要保留的文件数目。默认是保留3个。
#autopurge.snapRetainCount=5
#adminServer 端口
#admin.serverPort=8180
------------------------------------------------------


#创建数据目录
mkdir -p /data/zookeeper/data

```

## 6. 添加myid配置文件

在$ZK\_HOME/data路径下创建myid文件，第一台机器内容为1，第二台为2，第三台为3

```bash
# 第一台
echo "1" > /data/zookeeper/data/myid
# 第二台
echo "2" > /data/zookeeper/data/myid
# 第三台
echo "3" > /data/zookeeper/data/myid
```

## 7. 启动zookeeper

```bash
# 三台机器启动zookeeper服务
/data/zookeeper/bin/zkServer.sh start
/data/zookeeper/bin/zkServer.sh status
# 查看启动的Java进程
jcmd
```

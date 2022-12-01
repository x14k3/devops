#middleware/activemq 

下载地址：https://activemq.apache.org/components/classic/download/

# 单机部署
```bash

tar -zxvf apache-activemq-5.14.3-bin.tar.gz
cd apache-activemq-5.14.3

# activemq.xml配置文件，可以修改端口
vim conf/activemq.xml
----------------------------------------------------------
<transportConnector 
    name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
</transportConnectors>
------------------------------------------------------------

# 修改jetty.xml配置文件，可以修改控制台端口
vim activemq/conf/jetty.xml
---------------------------------------------------------------
<bean id="jettyPort" class="org.apache.activemq.web.WebConsolePort" init-method="start">
    <!-- 修改port，端口自定义 -->
    <property name="host" value="0.0.0.0"/>
    <property name="port" value="8161"/>
</bean>
---------------------------------------------------------------

# 修改jetty-realm.properties配置文件，可以修改控制台登录用户名和密码
vim activemq/conf/jetty-realm.properties
---------------------------------------------------------------
# Defines users that can access the web (console, demo, etc.)
# username: password [,rolename ...]
#用户名:密码,用户组
admin: admin, admin
---------------------------------------------------------------

# 启动activemq
~/bin/activemq start

# 打开web管理页面    # 默认用户名密码 admin/admin
http://IP:8161/admin

```


# 高可用模式部署
集群模式主要是为了解决ActiveMQ系统架构中的两个关键问题：高可用和高性能。  
针对上述两种需求，AActiveMQ主要有如下两种集群模式分别对应：

- Master-slave模式：多服务热备的高可用
- Broker-Cluster模式：负载均衡和分布式

## 一、Master-slave模式
Master-Slave集群由至少3个节点组成，一个Master节点，其他为Slave节点。只有Master节点对外提供服务，Slave节点处于等待状态。当主节点宕机后，从节点会推举出一个节点出来成为新的Master节点，继续提供服务。
**优点是可以解决多服务热备的高可用问题，缺点是无法解决负载均衡和分布式的问题。**

![](assets/activemq%20部署/image-20221127213133868.png)

Master-Slave模式常用持久化方式：

| 主从类型                                        | 必备条件                       | 优点                                                  | 缺点                                |
| ----------------------------------------------- | ------------------------------ | ----------------------------------------------------- | ----------------------------------- |
| Shared File System Master Slave（共享文件系统） | 需要一个共享文件系统 例如：SAN | 可按需运行多个从节点，并能从故障中自动恢复            | 需要一个SAN                         |
| JDBC Master Slave                               | 需要个共享的数据库             | 可按需运行多个从节点， 并能从故障中自动恢复           | 需要一个共享数据库。 性能急剧下降。 |
| Replicated LevelDB Store（复制的leveldb存储）   | 需要一个ZooKeeper服务          | 可按需运行多个从节点， 并能从故障中自动恢复。非常的快 | 需要一个zookeeper服务               | 


### 1.shared filesystem Master-Slave

如果集群搭建在一台机器上需要改端口；如果搭建在多台服务器上，那么共享目录需要通过磁盘挂载的方式挂载到主从机器上。

`vim conf/activemq.xml`

```xml
<persistenceAdapter>
<kahaDB directory="${activemq.data}/kahadb"/>
</persistenceAdapter>
```

在启动时，master会获取broker file directory的独占文件锁 - 所有其他的brokers都是slave，并且处于等待独占锁的pause状态。
**确保KahaDB正确使用**。不要在CIFS / SMB上运行共享存储，也不要将其保存在任何类型的基于NTFS的文件系统上。通过使用iSCSI协议和GFS2之类的多用户文件系统，可以获得最佳吞吐量。

客户端使用 failover 作为连接串

```java
ConnectionFactory connectionFactory = new ActiveMQConnectionFactory(
																	ActiveMQConnection.DEFAULT_USER, 
																	ActiveMQConnection.DEFAULT_PASSWORD, 
																	"failover:(tcp://192.168.0.200:61616,tcp://192.168.0.201:61616)");
```

### 2.shared database Master-Slave

该方式与共享文件系统方式类似，只是共享的存储介质由文件系统改成了数据库。

配置文件的Beans标签中添加：

```xml
<!-- persistent=true-->  
<broker brokerName="localhost" persistent="true" xmlns="http://activemq.apache.org/schema/core">  
    <persistenceAdapter>  
       <!--配置数据源-->
       <!--注意：需要添加mysql-connector-java相关的jar包到avtivemq的lib包下-->
        <jdbcPersistenceAdapter dataSource="#mysql-ds" useDatabaseLock="false" transactionIsolation="4"/>  
    </persistenceAdapter>  
      ........  
</broker>  
<!-- MySql DataSource Sample Setup  根据需要，把数据库驱动放到activemq目录下 lib/extra-->  
<bean id="mysql-ds" class="org.apache.commons.dbcp2.BasicDataSource" destroy-method="close">  
    <property name="driverClassName" value="com.mysql.jdbc.Driver"/>  
    <property name="url" value="jdbc:mysql://192.168.0.200:3306/test_activemq?relaxAutoCommit=true"/>  
    <property name="username" value="activemq"/>  
    <property name="password" value="test123456"/>  
    <property name="poolPreparedStatements" value="true"/>  
</bean>

```

在每个ActiveMQ的lib目录下加入mysql的驱动包和数据库连接池Druid包。


### 3.ZooKeeper+Replicated LevelDB Store

这种主备方式是ActiveMQ5.9以后才新增的特性，使用ZooKeeper协调选择一个node作为master。被选择的master broker node开启并接受客户端连接，类似于redis的哨兵模式。

![](assets/activemq%20部署/image-20221129175501864.png)

==原理说明：==
1）使用Zookeeper集群注册所有的ActiveMQ Broker，但只有其中一个Broker可以提供服务，它将被视为Master,其他的Broker处于待机状态被视为Slave。如果Master因故障而不能提供服务，Zookeeper会从Slave中选举出一个Broker充当Master。
2）Slave连接Master并同步他们的存储状态，Slave不接受客户端连接。所有的存储操作都将被复制到连接至Maste的Slaves。  
3）如果Master宕机得到了最新更新的Slave会变成Master。故障节点在恢复后会重新加入到集群中并连接Master进入Slave模式。  
4）所有需要同步的消息操作都将等待存储状态被复制到其他法定节点的操作完成才能完成。所以，如给你配置了replicas=3，name法定大小是（3/2）+1 = 2。Master将会存储更新然后等待（2-1）=1个Slave存储和更新完成，才汇报success。有一个node要作为观察者存在。当一个新的Master被选中，你需要至少保障一个法定mode在线

| 主机ip        | zookeeper集群端口 | AMQ集群bind端口 | AMQ 消息tcp端口 | AMQ 控制台端口 |
| ------------- | ----------------- | --------------- | --------------- | -------------- |
| 192.168.0.10 | 2181              | 0.0.0.0:63631  | 61616 默认          | 8161 默认           |
| 192.168.0.20 | 2181              | 0.0.0.0:63632  | 61616 默认         | 8161 默认           |
| 192.168.0.30 | 2181              | 0.0.0.0:63633  | 61616 默认        | 8161 默认           |   

#### 1. zookeeper集群

参考：[4、zookeeper集群环境搭建](../zookeeper/zookeeper%20部署.md#4、zookeeper集群环境搭建)

#### 2. activemq集群

主要修改 conf/activemq.xml 文件，持久化配置，三台activemq都修改
注意：每个 ActiveMQ 的 BrokerName 必須相同，否則不能加入集群

```xml
<broker xmlns="http://activemq.apache.org/schema/core" brokerName="zookeeper" dataDirectory="${activemq.data}">
<persistenceAdapter>
   <!-- <kahaDB directory="${activemq.data}/kahadb"/> -->
   <replicatedLevelDB
        directory="${activemq.data}/leveldb"
        replicas="3"
        bind="tcp://0.0.0.0:63631"
        zkAddress="192.168.0.10:2181,192.168.0.20:2181,192.168.0.30:2181"
        hostname="192.168.0.10"
        zkPath="/activemq/leveldb-stores"
        sync="local_disk"
        />
</persistenceAdapter>

<!-- 配置参数说明 
## **下列参数，所有节点必须一致**：
directory： 存储数据的路径
replicas：集群中的节点数
zkAddress：是zk集群的地址，即每个zk的IP：port 使用逗号分隔
zkPassword：当连接到ZooKeeper服务器时用的密码，没有密码则不配置。
zkPah：zookeeper上存储主从信息的目录，启动服务后actimvemq会到zookeeper上注册生成此路径
securityToken：安全token，所有节点必须一致，用于互相访问
zkSessionTimeout：默认2s，zookeeper多长时间会认为一个节点失效，5.11之后加入
sync：在消息被消费完成前，同步信息所存贮的策略。如果有多种策略用逗号隔开，ActiveMQ会选择较强的策略。
而如果有local_mem, local_disk这两种策略的话，那么ActiveMQ则优先选择local_disk策略，存储在本地硬盘。

## **下面的配置是每个节点特殊的配置**
bind：当该节点成为主节点时，绑定的地址和端口，用于服务复制协议。还支持使用动态端口，只需配置tcp:/ / 0.0.0.0:0
hostname： ActiveMQ所在主机的IP
weight：权重 具有最高权重的最新更新的从节点将成为主节点。
-->

```

主要修改 conf/jetty.xml 文件，修改控制台host，三台activemq都修改

```bash
        <property name="host" value="0.0.0.0"/>
        <property name="port" value="8161"/>
```

#### 3. 启动集群

先启动zookeeper集群再启动activemq集群

```bash
# 三台机器启动zookeeper服务
/data/zookeeper/bin/zkServer.sh start
/data/zookeeper/bin/zkServer.sh status

# 三台机器启动activemq服务
/data/activemq/bin/activemq start
```


#### 4. 查看集群状态

登陆zookeeper

```bash
/data/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181

[zk: 127.0.0.1:2181(CONNECTED) 6] ls /
[activemq, zookeeper]
[zk: 127.0.0.1:2181(CONNECTED) 7] ls /activemq
[leveldb-stores]
[zk: 127.0.0.1:2181(CONNECTED) 8] ls /activemq/leveldb-stores 
[00000000000, 00000000001, 00000000002]
[zk: 127.0.0.1:2181(CONNECTED) 9] ls /zookeeper 
[config, quota]
[zk: 127.0.0.1:2181(CONNECTED) 10] ls /zookeeper/config 
[]
[zk: 127.0.0.1:2181(CONNECTED) 11] ls /zookeeper/quota 
[]
[zk: 127.0.0.1:2181(CONNECTED) 12] ls /activemq/leveldb-stores/0000000000
00000000000   00000000001   00000000002   
[zk: 127.0.0.1:2181(CONNECTED) 12] get /activemq/leveldb-stores/00000000000
{"id":"zookeeper","container":null,"address":"tcp://192.168.0.10:63631","position":-1,"weight":1,"elected":"0000000000"}
[zk: 127.0.0.1:2181(CONNECTED) 13] get /activemq/leveldb-stores/00000000001
{"id":"zookeeper","container":null,"address":null,"position":-1,"weight":1,"elected":null}
[zk: 127.0.0.1:2181(CONNECTED) 14] get /activemq/leveldb-stores/00000000002
{"id":"zookeeper","container":null,"address":null,"position":-1,"weight":1,"elected":null}
[zk: 127.0.0.1:2181(CONNECTED) 15] 
```


#### 5. 测试故障切换

```bash
/data/activemq/bin/activemq stop

[zk: 127.0.0.1:2181(CONNECTED) 0] ls /
[activemq, zookeeper]
[zk: 127.0.0.1:2181(CONNECTED) 1] ls /activemq 
[leveldb-stores]
[zk: 127.0.0.1:2181(CONNECTED) 2] ls /activemq/leveldb-stores 
[00000000001, 00000000002]
[zk: 127.0.0.1:2181(CONNECTED) 3] ls /activemq/leveldb-stores/0000000000
00000000001   00000000002   
[zk: 127.0.0.1:2181(CONNECTED) 3] get /activemq/leveldb-stores/00000000001
{"id":"zookeeper","container":null,"address":"tcp://192.168.0.20:63632","position":-1,"weight":1,"elected":"0000000001"}
[zk: 127.0.0.1:2181(CONNECTED) 4] 
```

#### 6. client配置

```bash
# 在application.properties配置连接信息如下：
spring.activemq.broker-url=failover:(tcp://192.168.0.10:61616,tcp://192.168.0.20:61616,tcp://192.168.0.30:61616)

spring.activemq.user=admin
spring.activemq.password=admin
spring.activemq.pool.enabled=true
spring.activemq.pool.max-connections=50
```


## 二、Broker-Cluster模式

Broker-Cluster部署方式中，各个broker通过网络互相连接，并共享queue。当broker-A上面指定的queue-A中接收到一个message处于pending状态，而此时没有consumer连接broker-A时。如果cluster中的broker-B上面有一个consumer在消费queue-A的消息，那么broker-B会先通过内部网络获取到broker-A上面的message，并通知自己的consumer来消费。
**优点是可以解决负载均衡和分布式的问题。但不支持高可用。**

![](assets/activemq%20部署/image-20221130145157307.png)

### 1.static Broker-Cluster

static 方式就是在broker的配置中，静态指定要连接到其它broker的地址，格式：

<networkConnector uri="static:(tcp://host1:61616,tcp://host2:61616)"/>

1. 修改192.168.0.10上的 ~/activemq/conf/activemq.xml，在`<broker></broker>`标签中添加以下代码

```xml
 <broker xmlns="http://activemq.apache.org/schema/core" brokerName="activemq-cluster" dataDirectory="${activemq.data}">
		<networkConnectors>
		       <networkConnector name="group1" uri="static:(tcp://192.168.0.20:61616)"/>   
		</networkConnectors>

		<destinationPolicy>

<!-- Master-Slave与Broker-Cluster结合部署时，每组的broker要用name属性区分-->
```

2. 修改192.168.0.20上的 ~/activemq/conf/activemq.xml，在`<broker></broker>`标签中添加以下代码

```xml
 <broker xmlns="http://activemq.apache.org/schema/core" brokerName="activemq-cluster" dataDirectory="${activemq.data}">
		<networkConnectors>
		       <networkConnector name="group1" uri="static:(tcp://192.168.0.10:61616)"/>   
		</networkConnectors>

		<destinationPolicy>
```

### 2.Dynamic Broker-Cluster

ActiveMQ 通过组播方式将自己的信息发送出去，接收到的信息的机器再来连接这个发送源。默认情况下，ActiveMQ 发送的是机器名，可以通过配置修改成发送IP地址。**注意机器间的网络**。

1.  修改每台机器上的 ~/activemq/conf/activemq.xml，在<broker></broker>标签中添加以下代码

```xml
    <networkConnectors>  
        <networkConnector uri="multicast://default"/>  
    </networkConnectors>
```

    
2.  修改transportConnector，增加discoveryUri属性，并添加publishedAddressPolicy

```xml
    <transportConnector name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600" discoveryUri="multicast://default">  
     <publishedAddressPolicy>  
         <publishedAddressPolicy publishedHostStrategy="IPADDRESS"></publishedAddressPolicy>  
     </publishedAddressPolicy>  
    </transportConnector>
```


### 3. broker-cluster 配置属性

| 属性名称                            | 默认值 | 属性意义                                                                                                                 |
| ----------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| name                                | bridge | 名称                                                                                                                     |
| dynamicOnly                         | false  | 如果为true, 持久订阅被激活时才创建对应的网路持久订阅。                                                                   |
| decreaseNetworkConsumerPriority     | false  | 如果为true，网络的消费者优先级降低为-5。如果为false，则默认跟本地消费者一样为0.                                          |
| excludedDestinations                | empty  | 不通过网络转发的destination                                                                                              |
| dynamicallyIncludedDestinations     | empty  | 通过网络转发的destinations，注意空列表代表所有的都转发。                                                                 |
| staticallyIncludedDestinations      | empty  | 匹配的都将通过网络转发-即使没有对应的消费者，如果为默认的“empty”，那么说明所有都要被转发                                 |
| prefetchSize                        | 1000   | 设置网络消费者的prefetch size参数。如果设置成0，那么就像之前文章介绍过的那样：消费者会自己轮询消息。显然这是不被允许的。 |
| suppressDuplicateQueueSubscriptions | false  | 如果为true, 重复的订阅关系一产生即被阻止（V5.3+ 的版本中可以使用）。                                                     |
| bridgeTempDestinations              | true   | 是否广播advisory messages来创建临时destination。                                                                         |
| alwaysSyncSend                      | false  | 如果为true，非持久化消息也将使用request/reply方式代替oneway方式发送到远程broker（V5.6+ 的版本中可以使用）。              |
| staticBridge                        | false  | 如果为true，只有staticallyIncludedDestinations中配置的destination可以被处理（V5.6+ 的版本中可以使用）。                  | 

以下这些属性，**只能在静态Network Connectors模式下使用**

| 属性名称              | 默认值 | 属性意义                                                             |
| --------------------- | ------ | -------------------------------------------------------------------- |
| initialReconnectDelay | 1000   | 重连之前的等待的时间(ms) (如果useExponentialBackOff为false)          |
| useExponentialBackOff | true   | 如果该属性为true，那么在每次重连失败到下次重连之前，都会增大等待时间 |
| maxReconnectDelay     | 30000  | 重连之前等待的最大时间(ms)                                           |
| backOffMultiplier     | 2      | 增大等待时间的系数                                                   | 



## 三、Master-Slave与Broker-Cluster结合部署

这里使用ZK搭建两组MASTER SLAVE，然后使用BROKER CLUSTER把两个“组”合并在一起

1. 搭建两组[3.ZooKeeper+Replicated LevelDB Store](#3.ZooKeeper+Replicated%20LevelDB%20Store)
2. 将两组结合[1.static Broker-Cluster](#1.static%20Broker-Cluster)，注意：每组的name属性不一样，同组的要一样。
	```xml
	<networkConnector name="group1" uri="static:(tcp://host1:61616,tcp://host2:61616)"/>
	<networkConnector name="group2" uri="static:(tcp://host1:61616,tcp://host2:61616)"/>
	```

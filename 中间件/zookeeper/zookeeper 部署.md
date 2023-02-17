#middleware/zookeeper

### 1、zookeeper概述

`zookeeper是一个分布式协调服务的开源框架`。主要用来解决分布式集群中应用系统的一致性问题，例如避免同时操作同一数据造成脏读的问题。

`zookeeper本质上是一个分布式的小文件存储系统`。提供类似于文件系统的目录树方式的数据存储，并可以对树中的节点进行有效管理。从而用来维护和监控存储的数据的状态变化。通过监控这些数据状态的变化，从而可以达到基于数据的集群管理。

### 2、zookeeper架构图

![](assets/zookeeper%20部署/image-20221127215408692.png)


**Leader：**  
zookeeper集群工作的核心，事务请求（写操作）的唯一调度和处理者，保证集群事务处理的顺序性，集群内部各个服务器的调度者。  
对于create，setData，delete等有写操作的请求，则需要统一装发给leader处理，leader需要决定编号、执行操作，这个过程称为一个事务。

**Follower：**  
处理客户端非事务（读操作）请求，转发事务请求给Leader，参与集群Leader选举投票。

**Observer：**  
观察者角色，观察zookeeper集群的最新状态变化并将这些状态同步过来，其对于非事务请求可以进行独立处理，对于事务请求，则会转发给Leader服务器进行处理。  
不会参与任何形式的投票只提供非事务服务。实际上就是增加并发的读请求。

### 3、zookeeper的特性

`全局数据一致`：每个server保存一份相同的数据副本，client无论连接到那个server，展示的数据都是一致的。  
`可靠性`：如果消息被其中一台服务器接收，那么将被所有的服务器接受。  
`顺序性`：包括全局有序和偏序两种：全局有序是指如果在一台服务器上消息 a 在消息 b 前发布，则在所有 Server 上消息 a 都将在消息 b 前被发布；偏序是指如果一个消息 b 在消息 a 后被同一个发送者发布， a 必将排在 b 前面。  
`数据更新原子性`：一次数据更新要么成功，要么失败，不存在中间状态。  
`实时性`：zookeeper客户端将在一个时间间隔范围内获得服务器的更新信息，或者服务器失效的信息。

### 4、zookeeper集群环境搭建

##### 4.1、环境说明

```
centos7.9
zookeeper-3.8.0
jdk1.8.0_333
```

##### 4.2、配置主机名称

三台机器均需要配置

```
[root@dn1 /root]# vi /etc/hosts
192.168.0.10 zk1
192.168.0.20 zk2
192.168.0.30 zk3
```

##### 4.3、配置jdk环境

3台服务器都安装jdk：[[jdk 安装](../jdk/jdk%20安装.md)]

##### 4.4、安装zookeeper

创建软连接，配置zookeeper的环境变量，三台机器均需要配置

```bash
tar -zxf apache-zookeeper-3.8.0-bin.tar.gz 
mv apache-zookeeper-3.8.0 zookeeper
export ZK_HOME=/data/zookeeper
export PATH=$PATH:$ZK_HOME/bin
```

##### 4.5、修改zoo.cfg配置文件

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

##### 4.6、添加myid配置文件

在$ZK\_HOME/data路径下创建myid文件，第一台机器内容为1，第二台为2，第三台为3

```bash
# 第一台
echo "1" > /data/zookeeper/data/myid
# 第二台
echo "2" > /data/zookeeper/data/myid
# 第三台
echo "3" > /data/zookeeper/data/myid
```

##### 4.7、启动zookeeper

```bash
# 三台机器启动zookeeper服务
/data/zookeeper/bin/zkServer.sh start
/data/zookeeper/bin/zkServer.sh status
# 查看启动的Java进程
jcmd
```



### 5、zookeeper的shell操作

##### 5.1、客户端连接

运行zkCli.sh进入命令行工具输入help，输出zh shell提示

```bash
sh /data/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 0] help
ZooKeeper -server host:port cmd args
    stat path [watch]
    set path data [version]
    ls path [watch]
    delquota [-n|-b] path
    ls2 path [watch]
    setAcl path acl
    setquota -n|-b val path
    history
    redo cmdno
    printwatches on|off
    delete path [version]
    sync path
    listquota path
    rmr path
    get path [watch]
    create [-s] [-e] path data acl
    addauth scheme auth
    quit
    getAcl path
    close
    connect host:port
```

##### 5.2、shell操作

**创建节点**  
`create [-s][-e] path data acl`  
其中，-s表示创建顺序节点，-e表示创建临时节点（临时节点表示只在当前会话中显示，退出当前会话即删除），若不指定，则表示创建永久节点，acl用来进行权限控制。

```
-- 创建顺序节点
[zk: localhost:2181(CONNECTED) 2] create -s /caosw helloworld
Created /caosw0000000002
[zk: localhost:2181(CONNECTED) 3] ls /
[test0000000000, zookeeper, test, caosw0000000002]
-- 创建临时节点
[zk: localhost:2181(CONNECTED) 5] ls /
[test0000000000, caosw_temp, zookeeper, test, caosw0000000002]
-- 创建永久节点
[zk: localhost:2181(CONNECTED) 6] create /caosw_2 helloworld_2
Created /caosw_2
[zk: localhost:2181(CONNECTED) 7] ls /
[caosw_2, test0000000000, caosw_temp, zookeeper, test, caosw0000000002]
```

**读取节点**  
`ls path`  
`get path`  
与读取命令相关的ls命令和get命令，ls命令可以列出zookeeper指定节点下的所有子节点，只能查看指定节点下的第一级的所有子节点；get命令可以获取zookeeper指定节点的数据内容和属性信息

```
-- 列出根节点下的所有子节点
[zk: localhost:2181(CONNECTED) 8] ls /
[caosw_2, test0000000000, caosw_temp, zookeeper, test, caosw0000000002]
-- 查看节点caosw_2的数据内容和属性信息
[zk: localhost:2181(CONNECTED) 9] get /caosw_2
helloworld_2
cZxid = 0x20000000e
ctime = Sat Aug 31 00:00:37 CST 2019
mZxid = 0x20000000e
mtime = Sat Aug 31 00:00:37 CST 2019
pZxid = 0x20000000e
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 12
numChildren = 0
```

**更新节点**  
`set path data [version]`  
data就是要更新的新内容，version表示数据版本（可选参数）

```
[zk: localhost:2181(CONNECTED) 11] set /caosw_2 helloworld_update 0
cZxid = 0x20000000e
ctime = Sat Aug 31 00:00:37 CST 2019
mZxid = 0x200000010
mtime = Sat Aug 31 00:08:12 CST 2019
pZxid = 0x20000000e
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 17
numChildren = 0
```

dataVersion已经变为1了，表示进行了更新。

**删除节点**  
`delete path [version]`  
若删除节点存在子节点，那么无法删除该节点，必须先删除子节点，再删除父节点

```
[zk: localhost:2181(CONNECTED) 14] delete /caosw_2
[zk: localhost:2181(CONNECTED) 15] ls /
[test0000000000, caosw_temp, zookeeper, test, caosw0000000002] `rmr path 可以实现递归删除`
```

### 6、zookeeper的数据模型

zookeeper的数据模型在结构上和标准文件系统类似，拥有一个层次的命名空间，采用树形层次结构，zookeeper树中的每个节点被称为一个znode。和文件系统的目录树一样，zookeeper树中的每个节点都可以拥有子节点。  
**不同之处：**

-   znode兼具文件和目录两种特点。既像文件一样维护者数据、元信息、ACL、时间戳等数据结构，又像目录一样可以作为路径标识的一部分，并可以具有子znode。
-   znode具有原子性操作，读操作将获取与节点相关的所有数据，写操作也将替换掉节点的所有数据。
-   znode存储数据大小有限制，zookeeper用来管理调度数据，比如分布式应用中的配置文件信息、状态信息、汇集位置等等。这些数据的共同特性就是它们都是很小的数据，通常以KB为大小单位。zookeeper的服务器和客户端都被设计为严格检查并限制每个znode的数据大小至多1M。
-   znode通过路径引用。路径必须是绝对的，因此必须由斜杠字符开头。

`znode有两种类型：临时节点和永久节点`

-   临时节点：该节点的生命周期依赖于创建它们的会话。一旦会话结束，临时节点将被自动删除，当然也可以手动删除，临时节点不允许拥有子节点。
-   永久节点：该节点的生命周期不依赖于会话，并且只有在客户端显示执行删除操作的时候，它们才会被删除。

`znode还有序列化的特性。因此znode分为4种：`

-   PERSISTENT：永久节点
-   EPHEMERAL：临时节点
-   PERSISTENT\_SEQUENTIAL：永久序列化节点
-   EPHEMERAL\_SEQUENTIAL：临时序列化节点

### 7、zookeeper的watch机制

zookeeper提供了分布式数据发布和订阅的功能，zookeeper中引入了watch机制来实现这种分布式的通知功能。  
zookeeper允许客户端向服务端注册一个watch监听，当服务端的一些事件触发了这个watch，那么就会向指定客户端发送一个事件通知来实现分布式的通知功能。  
触发事件种类很多，如：节点创建、节点删除、节点改变、子节点改变等。  
watch分为三个过程：`客户端向服务端注册watch、服务端事件触发watch、客户端回调watch得到触发事件情况`。

##### 7.1、watch机制特点

**一次性触发**  
事件触发监听，一个watch event就会被发送到设置监听的客户端，这种效果是一次性的，后续再次发生同样的事件，不会再次触发。  
**事件封装**  
zookeeper使用watchedEvent对象来封装服务端事件并传递。watchedEvent包含了每一个事件的三个基本属性：通知状态（keeperState）、事件类型（EventType）、节点路径（path）。  
**event异步发送**  
watch的通知事件从服务端发送到客户端是异步的。  
**先注册再触发**  
zookeeper中的watch机制，必须客户端先从服务端注册监听，这样事件发送才会被触发监听，通知给客户端。

##### 7.2、通知状态和事件类型

<table><tbody><tr><td>KeeperState</td><td>EventType</td><td>触发条件</td><td>说明</td></tr><tr><td colspan="1" rowspan="5">SyncConnected(3)</td><td>None(-1)</td><td>客户端与服务器成功建立会话</td><td colspan="1" rowspan="5">此时客户端和服务<br>端处于连接状态</td></tr><tr><td>NodeCreated(1)</td><td>Watcher监听的对应数据节点被创建</td></tr><tr><td>NodeDeleted(2)</td><td>Watcher监听的对应数据节点被删除</td></tr><tr><td>NodeDataChanged(3)</td><td>Watcher监听的对应数据节点的数据内容发生变更</td></tr><tr><td>NodeChildrenChanged(4)</td><td>Watcher监听的对应数据节点的子节点列表发生变更</td></tr><tr><td>Disconnected(0)</td><td>None(-1)</td><td>客户端与服务器断开连接</td><td>此时客户端和服务端处于断开连接状态</td></tr><tr><td>Expired(-112)</td><td>None(-1)</td><td>会话超时</td><td>此时客户端会话失效，通常同时也会收到SessionExpiredException异常</td></tr><tr><td>AuthFailed(4)</td><td>None(-1)</td><td>通常有两种情况：使用错误的scheme进行权限检查，SASL权限检查失败</td><td>通常也会收到AuthFailedException异常</td></tr></tbody></table>

##### 7.3、shell客户端设置watch机制

设置节点数据变动监听

```
[zk: localhost:2181(CONNECTED) 17] get /test watch
hello
cZxid = 0x200000004
ctime = Fri Aug 30 17:11:15 CST 2019
mZxid = 0x200000004
mtime = Fri Aug 30 17:11:15 CST 2019
pZxid = 0x200000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 5
numChildren = 0
```

通过另一个客户端更改节点数据

```
[zk: localhost:2181(CONNECTED) 1] set /test hello_test
```

此时设置监听的节点收到通知

```
[zk: localhost:2181(CONNECTED) 18]
WATCHER::


WatchedEvent state:SyncConnected type:NodeDataChanged path:/test
```

### 8、Java操作zookeeper

##### 8.1、创建maven工程，导入jar包

```
<dependencies>
     <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-framework</artifactId>
            <version>2.12.0</version>
    </dependency>
    <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-recipes</artifactId>
            <version>2.12.0</version>
    </dependency>
    <dependency>
            <groupId>com.google.collections</groupId>
            <artifactId>google-collections</artifactId>
            <version>1.0</version>
    </dependency>
</dependencies>
```

##### 8.2、节点测试操作

**创建永久节点**

```
/**
 * 创建永久节点
 * @throws Exception
 */
@Test
public void createNode() throws Exception {
    RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 1);
    // 获取客户端对象
    CuratorFramework client =  CuratorFrameworkFactory.newClient("192.168.206.202:2181,192.168.206.203:2181,192.168.206.204:2181", 1000, 1000, retryPolicy);
    // 调用start开启客户端操作
    client.start();
    // 通过create来进行创建节点，并且需要指定节点类型
    client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/java");
    // 关闭客户端
    client.close();
}
```

在服务端进行通过zkCli.sh进行查看

```
[zk: localhost:2181(CONNECTED) 0] ls /
[test0000000000, java, zookeeper, test, caosw0000000002]
```

**创建临时节点**

```
/**
 * 创建永久节点
 * @throws Exception
 */
@Test
public void createNode2() throws Exception {
    RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 1);
    CuratorFramework client =  CuratorFrameworkFactory.newClient("192.168.206.202:2181,192.168.206.203:2181,192.168.206.204:2181", 1000, 1000, retryPolicy);
    client.start();
    client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/java_temp");
    Thread.sleep(5000);
    client.close();
}
```

**修改节点信息**

```
/**
 * 修改数据节点信息
 * @throws Exception
 */
@Test
public void nodeData() throws Exception {
    RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 1);
    CuratorFramework client =  CuratorFrameworkFactory.newClient("192.168.206.202:2181,192.168.206.203:2181,192.168.206.204:2181", 1000, 1000, retryPolicy);
    client.start();
    client.setData().forPath("/java", "caosw".getBytes());
    client.close();
}
```

在服务端进行通过zkCli.sh进行查看

```
[zk: localhost:2181(CONNECTED) 6] get /java
caosw
cZxid = 0x200000016
ctime = Sat Aug 31 01:00:22 CST 2019
mZxid = 0x200000024
mtime = Sat Aug 31 01:08:15 CST 2019
pZxid = 0x200000016
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 5
numChildren = 0
```

**节点数据查询**

```
/**
 * 节点数据查询
 * @throws Exception
 */
@Test
public void findnodeData() throws Exception {
    RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 1);
    CuratorFramework client =  CuratorFrameworkFactory.newClient("192.168.206.202:2181,192.168.206.203:2181,192.168.206.204:2181", 1000, 1000, retryPolicy);
    client.start();
    byte[] data = client.getData().forPath("/java");
    System.out.println(new String(data));
    client.close();
}
```

**节点watch机制**

```
/**
 * zookeeper的watch机制
 * @throws Exception
 */
@Test
public void watchNode() throws Exception {
    RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 1);
    CuratorFramework client =  CuratorFrameworkFactory.newClient("192.168.206.202:2181,192.168.206.203:2181,192.168.206.204:2181", 1000, 1000, retryPolicy);
    client.start();
    // 设置节点的cache
    TreeCache treeCache = new TreeCache(client, "/java");
    treeCache.getListenable().addListener(new TreeCacheListener() {
                
            @Override
            public void childEvent(CuratorFramework client,  TreeCacheEvent event) throws Exception {
                ChildData data = event.getData();
                if(data != null) {
                    switch(event.getType()) {
                    case NODE_ADDED:
                        System.out.println("NODE_ADDED : "+  data.getPath() +"  数据:"+ new String(data.getData()));
                        break;
                    case NODE_REMOVED:
                        System.out.println("NODE_REMOVED : "+  data.getPath() +"  数据:"+ new String(data.getData()));  
                        break;
                    case NODE_UPDATED:  
                        System.out.println("NODE_UPDATED : "+ data.getPath() +"   数据:"+ new String(data.getData()));  
                        break;  
                    default:
                        break;
                    }
                } else {
                    System.out.println( "data is null : "+  event.getType());  
                }
            }
         });
    // 开始监听
    treeCache.start();
    Thread.sleep(50000000);
    client.close();
}
```


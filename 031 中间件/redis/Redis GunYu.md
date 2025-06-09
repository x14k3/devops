# Redis GunYu

![CI](https://github.com/mgtv-tech/redis-GunYu/workflows/goci/badge.svg)[https://github.com/mgtv-tech/redis-GunYu/actions/workflows/goci.yml](https://github.com/mgtv-tech/redis-GunYu/actions/workflows/goci.yml)  
​![LICENSE](https://img.shields.io/badge/License-Apache%202.0-blue.svg)[https://github.com/mgtv-tech/redis-GunYu/blob/master/LICENSE](https://github.com/mgtv-tech/redis-GunYu/blob/master/LICENSE)  
​![release](https://img.shields.io/github/release/mgtv-tech/redis-GunYu)[https://github.com/mgtv-tech/redis-GunYu/releases](https://github.com/mgtv-tech/redis-GunYu/releases)

## 简介

​`redis-GunYu`​是一款redis数据治理工具，可以进行数据实时同步，数据迁移，备份、校验恢复，数据分析等等。

## 特性

### 数据实时同步

​`Redis-GunYu`​的实时同步功能矩阵

|功能点|是否支持|
| :-----------------------------------| :---------|
|断点续传|支持|
|源和目标集群slot不一致|支持|
|源或目标集群拓扑变化(扩容、迁移等)|支持|
|工具高可用|支持|
|数据过滤|支持|
|数据一致性|最终/弱|

​`redis-GunYu`​还有一些其他优势，如下

- 对稳定性影响更小

  - 复制优先级：可用指定优先从从库进行复制或主库复制
  - 本地缓存 + 断点续传：最大程度减少对源端redis的影响
  - 对RDB中的大key进行拆分同步
  - 更低的复制延迟：在保证一致性的前提下，并发地进行数据回放，参考[复制延迟指标](docs/deployment_zh.md#监控)
- 数据安全性与高可用

  - 本地缓存支持数据校验
  - 工具高可用 ： 支持主从模式，以最新记录进行自主选举，自动和手动failover；工具本身P2P架构，将宕机影响降低到最小
- 对redis限制更少

  - 支持源和目标端不同的redis部署方式，如cluster或单实例
  - 兼容源和目的redis不同版本，支持从redis4.0到redis7.2，参考[测试](docs/test_zh.md#版本兼容测试)
- 数据一致性策略更加灵活，自动切换

  - 当源端和目标端分片信息一致时，采用伪事务方式批量写入，实时更新偏移，最大可能保证一致性
  - 当源端和目标端分片不一致时，采用定期更新偏移
- 运维更加友好

  - API：可以通过http API进行运维操作，如强制全量复制，同步状态，暂停同步等等
  - 监控：监控指标更丰富，如时间与空间维度的复制延迟指标
  - 数据过滤：可以对某些正则key，db，命令等进行过滤
  - 拓扑变化监控 ： 实时监听源和目标端redis拓扑变更（如加减节点，主从切换等等），以更改一致性策略和调整其他功能策略

### RDB导入到redis

此功能是解析RDB文件，然后将数据回放到正在运行的redis中，可以对RDB文件进行过滤。

### 其他

其他功能，仍在开发中。

## 产品比较

从产品需求上，对redis-GunYu和几个主流工具的实时同步功能进行比较

|功能点|redis-shake/v2|DTS|xpipe|redis-GunYu|
| ----------------| ----------------| -----| -------| -----------------------------|
|断点续传|Y(无本地缓存)|Y|Y|Y|
|支持分片不对称|N|Y|N|Y|
|拓扑变化|N|N|N|Y|
|高可用|N|N|Y|Y|
|数据一致性|最终|弱|弱|最终(分片对称) + 弱(不对称)|

## 实现

​`redis-GunYu`​同步功能的技术实现如图所示，具体技术原理请见[技术实现](docs/tech_zh.md)

![架构图](https://github.com/mgtv-tech/redis-GunYu/raw/master/docs/imgs/sync.png)

## 快速开始

### 安装

可以自行编译，也可以直接运行容器

- 下载二进制

- 编译源码

  先确保已经安装Go语言，配置好环境变量

  ```
  git clone https://github.com/mgtv-tech/redis-gunyu.git
  cd redis-GunYu

  ## 如果需要，添加代理
  export GOPROXY=https://goproxy.cn,direct

  make
  ```

  在本地生成`redisGunYu`​二进制文件。

### 使用

​`redisGunYu`​不同的功能以子命令的方式来启动，子命令有

- ​`sync`​ : 实时同步功能
- ​`rdb`​ : rdb相关功能

我们以使用同步功能为例

**配置文件的方式启动**

```
./redisGunYu -conf ./config.yaml -cmd=sync
```

​`-cmd=sync`​ 可忽略

**命令行传递参数的方式启动**

```
./redisGunYu --sync.input.redis.addresses=127.0.0.1:6379 --sync.output.redis.addresses=127.0.0.1:16379
```

**以容器方式运行**

```
docker run mgtvtech/redisgunyu:latest --sync.input.redis.addresses=172.10.10.10:6379 --sync.output.redis.addresses=172.10.10.11:6379


# 如果本机测试，则可以以host网络模式启动容器`--network=host`，使redisGunYu能够和redis进行网络通信
docker run --network=host mgtvtech/redisgunyu:latest --sync.input.redis.addresses=127.0.0.1:6700 --sync.output.redis.addresses=127.0.0.1:6710
```

### 运行demo

**启动demo服务**

```
docker run --rm -p 16379:16379 -p 26379:26379 -p 18001:18001 mgtvtech/redisgunyudemo:latest
```

- 源redis ： 端口16379
- 目标redis ： 端口26379
- 同步工具： 端口 18001

**目的redis**

```
redis-cli -p 26379
127.0.0.1:26379> monitor
```

在目的redis-cli中输入monitor

**源redis**

连接到源redis，写入一个key，同步工具会将命令同步到目的redis，查看redis-cli连接到的源redis输出

```
redis-cli -p 16300
127.0.0.1:16379> set a 1
```

**检查状态**

```
curl http://localhost:18001/syncer/status
```

‍

---

# 同步的配置

​`redisGunYu`​支持以配置文件启动，或者以命令参数方式启动。

## 配置文件

配置文件分为以下几个配置组：

- input ：输入端redis（源端）的配置
- output ： 输出端redis（目标端）的配置
- channel ： 本地缓存配置
- cluster ： 集群模式配置
- log ： 日志配置
- server ： 服务器相关配置
- filter ： 过滤策略配置

### redis配置

redis配置

- addresses ： redis地址， 数组。如果redis是cluster部署的，则`addresses`​最好配置多于1个节点的IP地址，避免1个节点故障而无法联系redis集群。
- userName ： redis用户名
- password ： redis密码
- type ： redis类型

  - standalone ： 根据addresses里的地址来同步
  - cluster ：
- clusterOptions

  - replayTransaction ： 是否尝试使用事务（伪事务，不是基于multi/exec，而是将redis命令打包一次性发送到redis端执行）进行同步，默认开启
- keepAlive : 每个redis节点的最大连接数
- aliveTime : 保持连接超时时间

### 输入端

input配置如下

- redis ： redis配置
- rdbParallel ： 同一时刻进行rdb的限制数，默认没有限制
- mode ：

  - static ： 仅同步redis配置里的节点
  - dynamic ：如果redis是cluster，则同步redis cluster所有节点
- syncFrom ：

  - prefer_slave ： 优先从从库同步，如果从库不可用，则使用主库同步
  - master ： 使用主库同步
  - slave ： 使用从库同步

### 输出端

output配置如下：

- redis ： redis配置
- replay: 回放配置，参考[回放](#replay配置)
- filter: 过滤器配置，参考[过滤](#filter配置)

> 同步延迟主要取决于`batchCmdCount`​和`batchTicker`​，工具会将命令打包发送到目标端，只要两个配置中的一个满足则即可

#### replay配置

- replay:

  - resumeFromBreakPoint ： 是否开启断点续传，默认开启
  - keyExists ： output中key存在，如何处理

    - replace ： 替换，默认值
    - ignore ： 忽略
    - error ： 报错，停止同步
  - keyExistsLog ： 配合keyExists使用，默认关闭

    - true ： 如果keyExists是replace，则替换key时，打印info日志；如果keyiExists是ignore，则替换key时，打印warning日志
    - false ： 关闭keyExists日志
  - functionExists ： 如何回放函数字段，参考`FUNCTION RESTORE`​命令参数

    - flush ：
    - replace ：
  - maxProtoBulkLen ： 协议最大的缓存区大小，参考redis配置`proto-max-bulk-len`​，默认是512MiB
  - targetDb ： 选择同步到output的db，默认-1，表示根据input的db进行对应同步
  - batchCmdCount ： 批量同步命令的数量，将batchCmdCount数量的命令打包同步，默认100
  - batchTicker ： 批量同步命令的等待时间，最多等待batchTicker再进行打包同步，默认10ms
  - batchBufferSize ： 批量同步命令的缓冲大小，当打包缓冲区的大小超过batchBufferSize，则进行同步，默认64KB。batchCmdCount、batchTicker、batchBufferSize三者是或关系，只要满足一个，就进行同步。
  - replayRdbParallel ： 用几个线程来回放RDB，默认为CPU数量 * 4
  - updateCheckpointTicker ： 默认1秒
  - keepaliveTicker ： 默认3秒，保持心跳时间间隔

#### filter配置

- filter:

  - commandBlacklist :  命令黑名单，数组结构，忽略掉这些命令
  - keyFilter: 对key进行过滤

    - prefixKeyBlacklist : 前缀key黑名单
    - prefixKeyWhitelist : 前缀key白名单
  - slotFilter: 对slot进行过滤

    - keySlotBlacklist : slot黑名单
    - keySlotWhitelist : slot白名单

**filter配置示例**  
如下配置，不同步del命令，也不同步redisGunYu开头的key

```
filter:
  commandBlacklist:
    - del
  keyFilter:
    prefixKeyBlacklist: 
      - redisGunYu
  slotFilter:
    keySlotWhitelist: 
      - [0,1000]
      - [1002] 
```

### 缓存区

配置

- storer ： rdb和aof存储区

  - dirPath ： 存储目录，默认使用`/tmp/redis-gunyu`​
  - maxSize ： 存储最大空间，单位字节，默认50GiB
  - logSize ： 每个aof文件大小，默认100MiB
  - flush ： 同步aof文件到磁盘的策略，默认是auto

    - duration ： 每个多久刷新一次
    - everyWrite ： 每次写入命令到aof后，进行同步
    - dirtySize ： 当写入aof文件数据超过dirtySize，则进行同步
    - auto ： 由操作系统自己决定
- verifyCrc : 默认false
- staleCheckpointDuration ： 多久以前的快照视为过期快照，默认12小时

### 集群

集群模式配置

- groupName ： 集群名，此名字在etcd集群中作为集群名使用，所以请确保唯一性
- metaEtcd ： etcd配置 [可选]，如果没有配置etcd地址，则会使用源redis作为锁和注册中心

  - endpoints ： etcd节点地址
  - username ： 用户名
  - password ： 密码
- leaseTimeout ： leader租期时间，如果在leaseTimeout时间内，leader没有续租，则表示leader过期了，会重新发起选举；默认10秒，值范围为[3s, 600s]
- leaseRenewInterval ： leader发起租期时间间隔，默认3.33秒，一般选为leaseTimeout的1/3，值范围为[1s, 200s]

如下配置：

```
cluster:
  groupName: redisA
  leaseTimeout: 9s
  metaEtcd: 
    endpoints:
      - 127.0.0.1:2379
```

或

```
cluster:
  groupName: redisA
  leaseTimeout: 9s
```

### 日志

日志配置

- level ： 级别，默认info，级别有debug, info, warn, error, panic, fatal
- handler ：

  - file ： 日志输出到文件

    - fileName ： 文件名
    - maxSize ： 文件大小，单位为MiB
    - maxBackups ： 最大日志文件数量
    - maxAge ： 日志保留天数
  - stdout ： 默认输出到标准输出
- withCaller : bool值，日志是否包含源码文件名，默认false
- withFunc : bool值，日志是否包含函数调用者，默认false
- withModuleName : bool值，日志是否包含模块名，默认true

### 服务器

服务器配置

- listen : 监听地址，默认"127.0.0.1:18001"
- listenPeer: 和其他`redis-GunYu`​进程通信用途，IP:Port，默认和listen一样。注意不要写成127.0.0.1
- metricRoutePath : prometheus的http路径，默认是 "/prometheus"
- checkRedisTypologyTicker ： 检查redis cluster拓扑的时间周期，默认30秒，可以用1s, 1h，1ms等字符串
- gracefullStopTimeout ： 优雅退出超时时间，默认5秒

## 配置文件示例

### 最小配置文件

```
input:
  redis:
    addresses: [127.0.0.1:10001, 127.0.0.1:10002]   
    type: cluster
output:
  redis:
    addresses: [127.0.0.1:20001]
    type: standalone
```

### 较完善配置

```
server:
  listen: 0.0.0.0:18001 
  listenPeer: 10.220.14.15:18001  # 局域网地址
input:
  redis:
    addresses: [127.0.0.1:6300]
    type: cluster
  mode: dynamic
  syncFrom: prefer_slave
channel:
  storer:
    dirPath: /tmp/redisgunyu-cluster
    maxSize: 209715200
    logSize: 20971520
  staleCheckpointDuration: 30m
output:
  redis:
    addresses: [127.0.0.1:6310]
    type: cluster
  filter:
    resumeFromBreakPoint: true
log:
  level: info
  handler:
    stdout: true
  withModuleName: false

# 集群模式需要配置下面cluster配置，如果没有此配置，则是单实例模式
cluster:
  groupName: redis1
  leaseTimeout: 3s
```

## 命令行参数

我们可以使用命令行参数的方式启动redisGunYu

```
redisGunYu --sync.input.redis.addresses=127.0.0.1:6379 --sync.output.redis.addresses=127.0.0.1:16379
```

参数名都以`--sync.`​作为前缀名，后面则以配置的字段名，用`.`​连接起来；数组以`,`​进行分隔符。

如源端redis地址，配置文件如下，

```
input:
  redis:
    addresses: [127.0.0.1:6379, 127.0.0.2:6379]
```

则命令行名为`--sync.input.redis.addresses=127.0.0.1:6379,127.0.0.2:6379`​

如槽位白名单，配置文件如下，

```
output:
  filter:
    slotFilter:
      keySlotWhitelist: 
        - [0,1000]
        - [1002] 
```

则命令行名为`--sync.output.filter.slotFilter.keySlotWhitelist=[0,1000],[1002]`​

可以通过`redisGunYu -h`​来查看都有哪些参数。

‍

---

‍

# RDB 命令

## RDB命令

此功能是解析RDB文件，然后将数据回放到正在运行的redis中，可以对RDB文件进行过滤。

通过配置文件运行，可以参考config/rdb_load.yaml配置文件。
将`/tmp/test.rdb`​文件导入到`127.0.0.1:6379,127.0.0.1:6479`​的redis集群中，且忽略掉DB 1，忽略test_ignore前缀的keys。

```
./redisGunYu -cmd=rdb -conf=config/rdb_load.yaml
```

通过命令行参数运行

```
./redisGunYu -cmd=rdb -rdb.action=load -rdb.rdbPath=/tmp/test.rdb -rdb.load.redis.addresses=127.0.0.1:6379,127.0.0.1:6479 -rdb.load.redis.type=cluster -rdb.load.filter.dbBlacklist=1 -rdb.load.filter.keyFilter.prefixKeyBlacklist=test_ignore
```

## 配置

配置文件分为：

- action : 执行的子命令
- rdbPath : RDB文件路径
- load : RDB文件导入相关配置

  - redis : redis相关配置，可以参考[同步配置redis配置](sync_configuration_zh.md#redis配置)
  - replay : 回放相关配置，可以参考[同步配置replay配置](sync_configuration_zh.md#replay配置)
  - filter : 过滤相关配置

以下是一个简单的演示配置文件

```
action: load
rdbPath: /tmp/test.rdb
load:
  redis:
    addresses: [127.0.0.1:6379,127.0.0.1:6479]
    type: cluster
  filter:
    dbBlacklist: 1
    keyFilter:
      prefixKeyBlacklist: test_ignore
```

# kafka 集群监控

　　集群监控有不少方案，这里介绍一种国人研发的，经常看到有人推荐的一个方案，`Kafka Eagle`​。

　　当我们把 kafka 集群部署完成之后，就可以部署`Kafka Eagle`​监控系统了。

　　github 上的 releases 中事实上还是源码，而源码可能不容易编译成功，因此可以直接通过官网的下载地址下载作者已经提供的编译好的包进行部署。

### 下载包

```sh
$ wget https://codeload.github.com/smartloli/kafka-eagle-bin/tar.gz/v1.3.3
```

### 解压包

```sh
[root@localhost opt]$ tar xf v1.3.3
l[root@localhost opt]$ ls
kafka-eagle-bin-1.3.3  v1.3.3
[root@localhost opt]$ cd kafka-eagle-bin-1.3.3/
[root@localhost kafka-eagle-bin-1.3.3]$ ls
kafka-eagle-web-1.3.3-bin.tar.gz
[root@localhost kafka-eagle-bin-1.3.3]$ tar xf kafka-eagle-web-1.3.3-bin.tar.gz
l[root@localhost kafka-eagle-bin-1.3.3]$ ls
kafka-eagle-web-1.3.3  kafka-eagle-web-1.3.3-bin.tar.gz
[root@localhost kafka-eagle-bin-1.3.3]$ mv kafka-eagle-web-1.3.3 /opt/kafka-eagle
```

### 配置环境变量

```sh
cat >> /etc/profile << EOF
export JAVA_HOME=/usr/local/jdk1.8.0_192
export KE_HOME=/opt/kafka-eagle
export PATH=$PATH:$JAVA_HOME/bin:$KE_HOME
EOF
source /etc/profile
```

### 配置 system-config.properties 文件

```sh
######################################
# 配置多个Kafka集群所对应的Zookeeper
######################################
kafka.eagle.zk.cluster.alias=cluster1
cluster1.zk.list=192.168.106.7:2181,192.168.106.8:2181,192.168.106.9:2181
#cluster2.zk.list=xdn10:2181,xdn11:2181,xdn12:2181
######################################
# 设置Zookeeper线程数
######################################
kafka.zk.limit.size=25
######################################
# 设置Kafka Eagle浏览器访问端口
######################################
kafka.eagle.webui.port=8048
######################################
# 如果你的offsets存储在Kafka中，这里就配置
# 属性值为kafka，如果是在Zookeeper中，可以
# 注释该属性。一般情况下，Offsets的也和你消
# 费者API有关系，如果你使用的Kafka版本为0.10.x
# 以后的版本，但是，你的消费API使用的是0.8.2.x
# 时的API，此时消费者依然是在Zookeeper中
######################################
cluster1.kafka.eagle.offset.storage=kafka
#cluster2.kafka.eagle.offset.storage=zk
######################################
# 是否启动监控图表，默认是不启动的
######################################
kafka.eagle.metrics.charts=true
######################################
# 在使用Kafka SQL查询主题时，如果遇到错误，
# 可以尝试开启这个属性，默认情况下，不开启
######################################
kafka.eagle.sql.fix.error=true
######################################
# kafka sql topic records max
######################################
kafka.eagle.sql.topic.records.max=5000
######################################
# 邮件服务器设置，用来告警
######################################
kafka.eagle.mail.enable=false
kafka.eagle.mail.sa=alert_sa@163.com
kafka.eagle.mail.username=alert_sa@163.com
kafka.eagle.mail.password=mqslimczkdqabbbh
kafka.eagle.mail.server.host=smtp.163.com
kafka.eagle.mail.server.port=25
######################################
# alarm im configure
######################################
#kafka.eagle.im.dingding.enable=true
#kafka.eagle.im.dingding.url=https://oapi.dingtalk.com/robot/send?access_token=
#kafka.eagle.im.wechat.enable=true
#kafka.eagle.im.wechat.token=https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=xxx&corpsecret=xxx
#kafka.eagle.im.wechat.url=https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=
#kafka.eagle.im.wechat.touser=
#kafka.eagle.im.wechat.toparty=
#kafka.eagle.im.wechat.totag=
#kafka.eagle.im.wechat.agentid=
######################################
# 超级管理员删除主题的Token
######################################
kafka.eagle.topic.token=keadmin
######################################
# 如果启动Kafka SASL协议，开启该属性
######################################
cluster1.kafka.eagle.sasl.enable=false
cluster1.kafka.eagle.sasl.protocol=SASL_PLAINTEXT
cluster1.kafka.eagle.sasl.mechanism=PLAIN
cluster2.kafka.eagle.sasl.enable=false
cluster2.kafka.eagle.sasl.protocol=SASL_PLAINTEXT
cluster2.kafka.eagle.sasl.mechanism=PLAIN
######################################
# Kafka Eagle默认存储在Sqlite中，如果要使用
# MySQL可以替换驱动、用户名、密码、连接地址
######################################
kafka.eagle.driver=org.sqlite.JDBC
kafka.eagle.url=jdbc:sqlite:/opt/kafka-eagle/db/ke.db
kafka.eagle.username=root
kafka.eagle.password=smartloli
```

### 启动 Kafka Eagle

　　配置完成后，可以执行 Kafka Eagle 脚本 ke.sh。如果首次执行，需要给该脚本赋予执行权限，命令如下：

```text
chmod +x $KE_HOME/bin/ke.sh
```

　　在 ke.sh 脚本中，支持以下命令：

|命令|说明|
| ------------------------| ------------------------------------------|
|ke.sh start|启动 Kafka Eagle 系统|
|ke.sh stop|停止 Kafka Eagle 系统|
|ke.sh restart|重启 Kafka Eagle 系统|
|ke.sh status|查看 Kafka Eagle 系统运行状态|
|ke.sh stats|统计 Kafka Eagle 系统占用 Linux 资源情况|
|ke.sh find [ClassName]|查看 Kafka Eagle 系统中的类是否存在|

```sh
[root@localhost kafka-eagle]$./bin/ke.sh start
[2019-07-07 17:21:03] INFO: Starting  kafka eagle environment check ...
  created: META-INF/
 inflated: META-INF/MANIFEST.MF
  created: WEB-INF/
 。
 。中间输出省略
 。
  created: META-INF/maven/org.smartloli.kafka.eagle/
  created: META-INF/maven/org.smartloli.kafka.eagle/kafka-eagle-web/
 inflated: META-INF/maven/org.smartloli.kafka.eagle/kafka-eagle-web/pom.xml
 inflated: META-INF/maven/org.smartloli.kafka.eagle/kafka-eagle-web/pom.properties
*******************************************************************
* Kafka Eagle system monitor port successful...
*******************************************************************
[2019-07-07 17:21:03] INFO: Status Code[0]
[2019-07-07 17:21:03] INFO: [Job done!]
Welcome to
    __ __    ___     ____    __ __    ___            ______    ___    ______    __     ______
   / //_/   /   |   / __/   / //_/   /   |          / ____/   /   |  / ____/   / /    / ____/
  / ,<     / /| |  / /_    / ,<     / /| |         / __/     / /| | / / __    / /    / __/
 / /| |   / ___ | / __/   / /| |   / ___ |        / /___    / ___ |/ /_/ /   / /___ / /___
/_/ |_|  /_/  |_|/_/     /_/ |_|  /_/  |_|       /_____/   /_/  |_|\____/   /_____//_____/
Version 1.3.3
*******************************************************************
* Kafka Eagle Service has started success.
* Welcome, Now you can visit 'http://<your_host_or_ip>:port/ke'
* Account:admin ,Password:123456
*******************************************************************
* <Usage> ke.sh [start|status|stop|restart|stats] </Usage>
* <Usage> https://www.kafka-eagle.org/ </Usage>
*******************************************************************
```

### 访问

　　接着就可以通过`http://<your_host_or_ip>:port/ke`​进行访问了。

　　用户名密码是 `Account:admin ,Password:123456`​。

　　‍

### 监控趋势图

　　Kafka 系统默认是没有开启 JMX 端口的，所以 Kafka Eagle 的监控趋势图默认采用不启用的方式，即`kafka.eagle.metrics.charts=false`​。

　　如果需要查看监控趋势图，需要开启 Kafka 系统的 JMX 端口，设置该端口在 \$KAFKA\_HOME/bin/kafka-server-start.sh 脚本中，设置内容如下：

```sh
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"
    export JMX_PORT="9999"
    #export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi
```

　　然后将集群的 kafka 重启，在重启 kafka eagle，就能看到相关的监控了。

# skywalking 部署

# 链路追踪介绍

对于一个大型的几十个，几百个微服务构成的微服务架构系统，通常会遇到下面的一系列问题。

- 如何串联整个调用链路，快速定位问题？
- 如何澄清各个微服务之间的依赖关系？
- 如何进行各个微服务接口的性能分析？
- 如何追踪各个业务流程的调用处理顺序？

# Skywalking介绍

Skywalking是一个国产的开源框架，2015年有吴晟个人开源，2017年加入Apache孵化器，国人开源的产品，主要开发人员来自于华为，2019年4月17日Apache董事会批准SkyWalking成为顶级项目，支持Java、.Net、NodeJs等探针，数据存储支持Mysql、Elasticsearch等，跟Pinpoint一样采用字节码注入的方式实现代码的无侵入，探针采集数据粒度粗，但性能表现优秀，且对云原生支持，目前增长势头强劲，社区活跃。
Skywalking是分布式系统的应用程序性能监视工具，专为微服务，云原生架构和基于容器（Docker，K8S,Mesos）架构而设计，它是一款优秀的APM（Application Performance Management）工具，包括了分布式追踪，性能指标分析和服务依赖分析等。

# skywalking部署

1.下载地址：[https://archive.apache.org/dist/skywalking/](https://links.jianshu.com/go?to=https://archive.apache.org/dist/skywalking/ "https://archive.apache.org/dist/skywalking/")

2.下载好了之后，上传到服务器

3.解压 `tar -zxvf apache-skywalking-apm-8.8.1.tar.gz`

4.安装elasticsearch存储，参考 [elk 7.17 部署](../ELK/elk%207.17%20部署.md)

5.配置skywalking

`vim /data/apache-skywalking-apm-bin/config/application.yml `

```bash
# 定位到storage部分，将默认的H2存储库改为elasticsearch，并按照以下配置。
storage:
  selector: ${SW_STORAGE:elasticsearch}
  elasticsearch:
    namespace: ${SW_NAMESPACE:"skywalking"}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.10.142:9200}
    protocol: ${SW_STORAGE_ES_HTTP_PROTOCOL:"http"}
    connectTimeout: ${SW_STORAGE_ES_CONNECT_TIMEOUT:500}
    socketTimeout: ${SW_STORAGE_ES_SOCKET_TIMEOUT:30000}
    numHttpClientThread: ${SW_STORAGE_ES_NUM_HTTP_CLIENT_THREAD:0}
    user: ${SW_ES_USER:""}
    password: ${SW_ES_PASSWORD:""}
    trustStorePath: ${SW_STORAGE_ES_SSL_JKS_PATH:""}
    trustStorePass: ${SW_STORAGE_ES_SSL_JKS_PASS:""}
=================================================================
selector      # 存储选择器,设置elasticsearch
namespace     # elasticsearch中索引名字
clusterNodes  # 指定Elasticsearch实例的访问地址
user          # Elasticsearch实例的访问用户名，默认为elastic。
password      # 对应用户的密码。elastic用户的密码在创建实例时指定
```

6.安装jdk1.8

```bash
tar -zxf jdk-8u301-linux-x64.tar.gz -C /usr/local
cp -a /etc/profile{,.bak}
cat <<EOF >> /etc/profile 
export JAVA_HOME=/usr/local/jdk1.8.0_301
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile
```

7.启动服务

`sh /data/apache-skywalking-apm-bin/bin/startup.sh ;tail -f /data/apache-skywalking-apm-bin/logs/oap.log`

# skywalking-agent部署

1.下载地址：[https://archive.apache.org/dist/skywalking/](https://links.jianshu.com/go?to=https://archive.apache.org/dist/skywalking/ "https://archive.apache.org/dist/skywalking/")

2.下载好了之后，上传到java应用程序所在服务器

3.解压 `tar -zxvf apache-skywalking-java-agent-8.8.0.tgz`

4.安装jdk1.8

```bash
tar -zxf jdk-8u301-linux-x64.tar.gz -C /usr/local
cp -a /etc/profile{,.bak}
cat <<EOF >> /etc/profile 
export JAVA_HOME=/usr/local/jdk1.8.0_301
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile
```

5.修改探针默认配置&#x20;

`vim /data/skywalking-agent/config/agent.config`

```bash
# skywalking 服务端ip
collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:192.168.10.142:11800}
# 设置每 3 秒可收集的链路数据的数量
agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:-1}
```

6.通过设置启动参数的方式检测系统，没有代码侵入

```bash
 nohup java -javaagent:/data/skywalking-agent/skywalking-agent.jar \
 -Dskywalking.agent.service_name=tss -Dskywalking.collector.backend_service=192.168.10.142:11800 \
 -Dspring.cloud.nacos.config.server-addr=192.168.10.146:8101 \
 -Dspring.cloud.nacos.config.namespace=jy2v -Dspring.cloud.nacos.config.enabled=true \
 -jar /data/microService/application/$APP_NAME 2>&1 |/usr/local/sbin/cronolog \
 /data/microService/data/log/tss/tss.%Y-%m-%d.out &
```

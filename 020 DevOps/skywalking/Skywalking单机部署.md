# Skywalking单机部署

## 下载 Skywalking 安装包

```bash
wget https://www.apache.org/dyn/closer.cgi/skywalking/8.6.0/apache-skywalking-apm-8.6.0.tar.gz
```

## 解压缩并执行命令安装

```bash
# 解压缩
tar -zxvf apache-skywalking-apm-8.6.0.tar.gz
# 移动到 /usr/local 目录
mv apache-skywalking-apm-8.6.0 /usr/local/
```

## 修改配置文件

　　修改 /usr/local/apache-skywalking-apm-8.6.0/config/application.ym

```bash

# 如果不需要告警模块, 则注释掉即可, 建议注释掉
#alarm:
#  selector: ${SW_ALARM:default}
#  default:
storage:
  selector: ${SW_STORAGE:elasticsearch}
  # 如果使用的是 ES6 则配置这个模块
  elasticsearch:
    # 命名空间
    nameSpace: ${SW_NAMESPACE:""}
    # ES 集群地址
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.159.51.44:9200}
    # 协议
    protocol: ${SW_STORAGE_ES_HTTP_PROTOCOL:"http"}
    trustStorePath: ${SW_STORAGE_ES_SSL_JKS_PATH:""}
    trustStorePass: ${SW_STORAGE_ES_SSL_JKS_PASS:""}
    # 用户名密码
    user: ${SW_ES_USER:""}
    password: ${SW_ES_PASSWORD:""}
    secretsManagementFile: ${SW_ES_SECRETS_MANAGEMENT_FILE:""}
    # 按天分割 ES 索引
    dayStep: ${SW_STORAGE_DAY_STEP:1}
    indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:1}
    superDatasetIndexShardsFactor: ${SW_STORAGE_ES_SUPER_DATASET_INDEX_SHARDS_FACTOR:5}
    indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:0}
    # 一次执行 1000 次条语句
    bulkActions: ${SW_STORAGE_ES_BULK_ACTIONS:1000} # Execute the bulk every 1000 requests
    # 索引每10s刷新一次
    flushInterval: ${SW_STORAGE_ES_FLUSH_INTERVAL:10}
    # 并发请求数
    concurrentRequests: ${SW_STORAGE_ES_CONCURRENT_REQUESTS:2}
    resultWindowMaxSize: ${SW_STORAGE_ES_QUERY_MAX_WINDOW_SIZE:10000}
    metadataQueryMaxSize: ${SW_STORAGE_ES_QUERY_MAX_SIZE:5000}
    segmentQueryMaxSize: ${SW_STORAGE_ES_QUERY_SEGMENT_SIZE:200}
    profileTaskQueryMaxSize: ${SW_STORAGE_ES_QUERY_PROFILE_TASK_SIZE:200}
    advanced: ${SW_STORAGE_ES_ADVANCED:""}
  # 如果使用的是 ES7 则配置这个模块
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:""}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:localhost:9200}
    protocol: ${SW_STORAGE_ES_HTTP_PROTOCOL:"http"}
    trustStorePath: ${SW_STORAGE_ES_SSL_JKS_PATH:""}
    trustStorePass: ${SW_STORAGE_ES_SSL_JKS_PASS:""}
    dayStep: ${SW_STORAGE_DAY_STEP:1}
    user: ${SW_ES_USER:""}
    password: ${SW_ES_PASSWORD:""}
    secretsManagementFile: ${SW_ES_SECRETS_MANAGEMENT_FILE:""}
    indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:1}
    superDatasetIndexShardsFactor: ${SW_STORAGE_ES_SUPER_DATASET_INDEX_SHARDS_FACTOR:5}
    indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:0}
    bulkActions: ${SW_STORAGE_ES_BULK_ACTIONS:1000}
    flushInterval: ${SW_STORAGE_ES_FLUSH_INTERVAL:10}
    concurrentRequests: ${SW_STORAGE_ES_CONCURRENT_REQUESTS:2}
    resultWindowMaxSize: ${SW_STORAGE_ES_QUERY_MAX_WINDOW_SIZE:10000}
    metadataQueryMaxSize: ${SW_STORAGE_ES_QUERY_MAX_SIZE:5000}
    segmentQueryMaxSize: ${SW_STORAGE_ES_QUERY_SEGMENT_SIZE:200}
    profileTaskQueryMaxSize: ${SW_STORAGE_ES_QUERY_PROFILE_TASK_SIZE:200}
    advanced: ${SW_STORAGE_ES_ADVANCED:""}
  # 如果使用mysql作为数据存储，则配置下面这块
  mysql:
    properties:
      jdbcUrl: ${SW_JDBC_URL:"jdbc:mysql://localhost:3306/swtest"}
      dataSource.user: ${SW_DATA_SOURCE_USER:root}
      dataSource.password: ${SW_DATA_SOURCE_PASSWORD:root@1234}
      dataSource.cachePrepStmts: ${SW_DATA_SOURCE_CACHE_PREP_STMTS:true}
      dataSource.prepStmtCacheSize: ${SW_DATA_SOURCE_PREP_STMT_CACHE_SQL_SIZE:250}
      dataSource.prepStmtCacheSqlLimit: ${SW_DATA_SOURCE_PREP_STMT_CACHE_SQL_LIMIT:2048}
      dataSource.useServerPrepStmts: ${SW_DATA_SOURCE_USE_SERVER_PREP_STMTS:true}
    metadataQueryMaxSize: ${SW_STORAGE_MYSQL_QUERY_MAX_SIZE:5000}
```

　　修改 /usr/local/apache-skywalking-apm-8.6.0/bin/oapService.sh

```bash

#!/usr/bin/env sh

PRG="$0"
PRGDIR=`dirname "$PRG"`
[ -z "$OAP_HOME" ] && OAP_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

OAP_LOG_DIR="${OAP_LOG_DIR:-${OAP_HOME}/logs}"
# 主要修改此处, 配置 JVM 内存使用大小
JAVA_OPTS=" -Xms6144M -Xmx6144M"

if [ ! -d "${OAP_LOG_DIR}" ]; then
    mkdir -p "${OAP_LOG_DIR}"
fi

_RUNJAVA=${JAVA_HOME}/bin/java
[ -z "$JAVA_HOME" ] && _RUNJAVA=java

CLASSPATH="$OAP_HOME/config:$CLASSPATH"
for i in "$OAP_HOME"/oap-libs/*.jar
do
    CLASSPATH="$i:$CLASSPATH"
done

OAP_OPTIONS=" -Doap.logDir=${OAP_LOG_DIR}"

eval exec "\"$_RUNJAVA\" ${JAVA_OPTS} ${OAP_OPTIONS} -classpath $CLASSPATH org.apache.skywalking.oap.server.starter.OAPServerStartUp \
        2>${OAP_LOG_DIR}/oap.log 1> /dev/null &"

if [ $? -eq 0 ]; then
    sleep 1
	echo "SkyWalking OAP started successfully!"
else
	echo "SkyWalking OAP started failure!"
	exit 1
fi
```

## 修改操作系统内核参数

```bash
vim /etc/sysctl.conf

# 添加以下配置项

* soft  core   unlimit
* hard  core   unlimit
* soft  fsize  unlimited
* hard  fsize  unlimited
* soft  data   unlimited
* hard  data   unlimited
* soft  nproc  65535
* hard  nproc  63535
* soft  stack  unlimited
* hard  stack  unlimited
* soft  nofile  409600
* hard  nofile  409600
```

## 启动 Skywalking

```bash
/usr/local/apache-skywalking-apm-8.6.0/bin/startup.sh
```

## 配置日志自动清理

　　编写shell脚本, /data/skywalking/log_rotate.sh

```bash
#!/bin/bash
# 初始化
LOGS_PATH=/usr/local/apache-skywalking-apm-8.6.0/logs

for file in $LOGS_PATH/*
do
    if test -f $file
    then
        echo $file
        #find $file -mtime +15 -name '*[0-9]*-[0-9]*-[0-9]*' | xargs rm -f
    else
        find $file -mtime +15 -name '*[0-9]*-[0-9]*-[0-9]*' | xargs rm -f
    fi
done

exit 0
```

　　添加脚本到 crontab 中, 每晚 00:00 自动执行, 清理 15 天之前的日志记录

```bash
# 执行
crontab -e
# 输入
1 0 * * * /data/skywalking/log_rotate.sh
```

## 使用方法

　　spring boot程序接入, 参考 [Spring Boot应用部署文档](./Spring%20Boot应用部署文档.md)

```bash
# 启动springboot程序时指定 -javaagent 即可
nohup java -javaagent:/application/skywalking-agent/skywalking-agent.jar -Dskywalking.trace.ignore_path=/actuator/** -Dskywalking.agent.service_name=bjgyol-gateway -Dskywalking.collector.backend_service=192.159.51.13:11800 -jar -Dspring.profiles.active=prod /application/bjgyol-gateway.jar
```

　　tomcat 程序接入

```bash

# 第一步: 进入 tomcat/bin 目录, 修改 catalina.sh 启动脚本, 添加一行启动配置

CATALINA_OPTS="$CATALINA_OPTS -javaagent:/application/skywalking-agent/skywalking-agent.jar"

# 第二步: 进入 /application/skywalking-agent/config 目录，修改 agent.config 文件，修改以下几个配置项

# 1、默认 
agent.service_name=${SW_AGENT_NAME:""}
# 修改为
# agent.service_name=${SW_AGENT_NAME:"bjgyol-gateway"}
# 2、 默认 
# collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:""}
# 修改为 Skywalking 地址
# collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:192.159.51.13:11800}

# 第三步启动tomcat即可
```

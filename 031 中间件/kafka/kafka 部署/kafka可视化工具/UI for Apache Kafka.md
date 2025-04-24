# UI for Apache Kafka

## java环境运行

### 安装 jdk

首先安装[jdk 部署](031%20中间件/jdk.md#20231110105237-94a9b5j) 17版本

### 安装 kafka-ui

其实 kafka-ui 是没有安装过程的，在 github 上已经打包成了 jar 包，当前最新版本为 0.7,下载地址如下：

[https://github.com/provectus/kafka-ui/releases](https://github.com/provectus/kafka-ui/releases)

```bash
wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar
```

我们下载最新的 jar 后，放到服务器上

创建一个 application.yml 文件:

```yaml
kafka:
  clusters:
    - name: kafka3_cluster
      bootstrapServers: 192.168.111.128:9092,192.168.111.129:9092,192.168.111.130:9092
      metrics:
        port: 9094
        type: JMX

    - name: OTHER_KAFKA_CLUSTER_NAME
      bootstrapServers: 10.10.10.10:9092
      metrics:
        port: 9094
        type: JMX

spring:
  jmx:
    enabled: true
  security:
    user:
      name: maggot
      password: maggot

auth:
  type: LOGIN_FORM #LOGIN_FORM # DISABLED

server:
  port: 10300

logging:
  level:
    root: INFO
    com.provectus: INFO
    reactor.netty.http.server.AccessLog: INFO

management:
  endpoint:
    info:
      enabled: true
    health:
      enabled: true
  endpoints:
    web:
      exposure:
        include: "info,health"
```

#### clusters

 在 `kafka`​ 中配置相关的 kafka 集群，每一个 `clusters`​ 为一个集群，需要配置：

* name

   设置一个集群名

* bootstrapServers

   brokers 连接，针对 kraft 架构，就很方便，不用再配置 zookeeper 相关配置。

* metrics

   配置该集群的 JMX 相关配置，如果没有可省略。（在启动 kafka 时，启动命令行前面添加 `JMX_PORT=9094`​ ）

#### 登陆配置

* auth.type

   使用 `LOGIN_FORM`​ 开启；或者 `DISABLED`​ 关闭认证。如果开启了，需要 `spring.security.user`​ 中配置用户名与密码。

* spring.security.user

   配置的登陆账号密码。

#### kafka-ui http 端口

* server.port

   kafka-ui http 端口。

#### 启动

```java
java -jar "./kafka-ui-api-v0.7.2.jar" --spring.config.additional-location="./application.yml"
```

‍

‍

## docker环境运行

kafka-ui 不允许在运行时更改其配置。当应用程序启动时，它会从系统环境、配置文件（例如 application.yaml）和 JVM  参数（由-D）读取配置。一旦配置被读取，它就被视为不可变，即使配置源（例如文件）发生更改也不会刷新。从 0.6  版本开始，我们添加了在运行时更改集群配置的功能。默认情况下禁用此选项，应隐式启用。要启用它，您应该设置DYNAMIC\_CONFIG\_ENABLEDenv 属性true或将dynamic.config.enabled: true属性添加到 yaml 配置文件。示例 docker compose  配置

```dockerfile
services:
  kafka-ui:
    container_name: kafka-ui
    image: provectuslabs/kafka-ui:latest
    ports:
      - 8080:8080
    environment:
      DYNAMIC_CONFIG_ENABLED: 'true'
    volumes:
      - ~/kui/config.yml:/etc/kafkaui/dynamic_config.yaml
```

```bash
mkdir ~/kui/  && touch ~/kui/config.yml && chmod 777 ~/kui/config.yml
sudo docker-compose -f docker-compose.yml up -d
```

‍

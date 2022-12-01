

## 版本信息

```txt
mysql    : 5.7.37
nginx    : 1.20.2
redis    : 6.2.5
jdk      : 1.8.333
tomcat   : 8.5.73
nacos    : 1.4.4
activemq : 5.16.3
fastdfs  : 5.12
BPServer : 1.3.45
```

# mysql镜像

**创建编辑Dockerfile文件**

```dockerfile
FROM mysql:5.7.37
MAINTAINER sundongsheng@nstc.com.cn
LABEL version="5.7.37"
RUN echo 'character_set_server = utf8 \n\
lower_case_table_names = 1 \n\
max_connections = 2000 \n\
log_bin_trust_function_creators = 1 \n\
[client] \n\
default-character-set = utf8' \
>> /etc/mysql/mysql.conf.d/mysqld.cnf
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

```

**通过**​**制作镜像**

```bash
# 使用docker build 构建镜像
docker build -t 192.168.10.31/jinzay/mysql:5.7.37 ./

```

**通过**​**启动镜像**

```sql
docker run -d --name mysql -v /data/mysql:/var/lib/mysql \
-p 3306:3306 -e MYSQL_ROOT_PASSWORD=Ninestar@2022 192.168.10.31/jinzay/mysql:5.7.37;

# 查看启动日志
docker logs -f mysql
```

**导入数据**

```bash
# 建议在宿主机安装mysql客户端
yum -y install mysql
# 查看mysql容器ip地址
docker inspect mysql|grep IPAddress
# 登录mysql数据库
mysql -uroot -h172.17.0.2 -P3306 -p
```

# nginx 镜像

```docker
FROM nginx
MAINTAINER sundongsheng@nstc.com.cn
ENV version=1.20.2
COPY init.sh /etc/nginx/
COPY nginx.conf /etc/nginx/
ENV SERVER_NAME 192.168.10.31
ENV UPSTREAM 192.168.10.31
ENV APP_IP 192.168.10.31
ENV ERP_IP 192.168.10.31
RUN mkdir -p /data/logs
CMD ["bash","-c","/etc/nginx/init.sh ; nginx"]
```

```sql
docker build -t 192.168.10.31/jinzay/nginx ./

docker run -d --name nginx -v /data/docker/web:/data -p 8001:8001 -p 8002:8002 192.168.10.31/jinzay/nginx
```

# redis镜像

```docker
FROM redis:5.0.10
COPY redis.conf /data/
CMD ["redis-server","/data/redis.conf"]

```

```sql
docker build -t 192.168.10.31/jinzay/redis ./
docker run -d --name redis -p 6379:6379 192.168.10.31/jinzay/redis

```

# nacos镜像

```docker
# 直接拉去镜像
docker pull nacos/nacos-server:1.4.1

# 启动容器
docker run --env MODE=standalone --name nacos -d -p 8101:8848 nacos/nacos-server:1.4.1
# 访问url
http://192.168.10.31:8101/nacos/index.html
```

# activemq镜像

&#x20;alpine作为基础镜像，部署activemq需要glibc依赖

[glibc-2.34-r0.apk](file/glibc-2.34-r0_IcmpmlMULr.apk)

[sgerrand.rsa.pub](file/sgerrand.rsa_9rbpvJaQAv.pub)

```docker
FROM 192.168.10.31/jinzay/alpine-glibc
MAINTAINER sundongsheng@nstc.com.cn
LABEL version="1.0"
ADD jdk-8u301-linux-x64.tar.gz /usr/local/
ADD apache-activemq-5.16.3-bin.tar.gz /usr/local/
RUN sed -i '/<storeUsage limit=/s/100/50/1' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '/<tempUsage limit=/s/50/10/1' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '114,117d' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '/<transportConnector name=/s/openwire/webamq/1; s/1000/100000/1' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '/<persistenceAdapter/{n;d}' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '/<persistenceAdapter/a\
                <kahaDB directory="${activemq.data}/kahadb" \n \
                ignoreMissingJournalfiles="true" \n \
                checkForCorruptJournalFiles="true" \n \
                checksumJournalFiles="true"/>' /usr/local/apache-activemq-5.16.3/conf/activemq.xml \
&& sed -i '119s/127.0.0.1/0.0.0.0/1' /usr/local/apache-activemq-5.16.3/conf/jetty.xml \
&& sed -i '20,21d' /usr/local/apache-activemq-5.16.3/conf/jetty-realm.properties \
&& sed -i '$asystem: manager, admin' /usr/local/apache-activemq-5.16.3/conf/jetty-realm.properties \
&& sed -i '/ACTIVEMQ_OPTS_MEMORY=/s/-Xms64M -Xmx1G/-Xms1G -Xmx5G/1' /usr/local/apache-activemq-5.16.3/bin/env
ENV JAVA_HOME /usr/local/jdk1.8.0_301
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$ACTIVEMQ_HOME:$PATH
CMD ["sh","-c","/usr/local/apache-activemq-5.16.3/bin/activemq console"]
--------------------------------------------------------------------
docker build -t 192.168.10.31/jinzay/activemq ./

docker run -d --name activemq -p 10098:61616 -p 10097:8161 192.168.10.31/jinzay/activemq

```

# fastdfs镜像

```docker
docker pull season/fastdfs

Run as a tracker
docker run -d -it --name tracker -v /data/dockr-tracker:/fastdfs/tracker/data \
-p 8102:22122 season/fastdfs tracker

Run as a Storage
docker run -d -it --name storage -v /data/docker-storage:/fastdfs/storage/data \
-v /data/docker-storage_path:/fastdfs/store_path  \
-e TRACKER_SERVER:192.168.10.31:8101 season/fastdfs storage
```

# jdk镜像
> 建议将固定的配置写进bootstrap.properties（例如：FILE_EXT=properties\FILE_EXT=yaml）

```docker
FROM alpine
MAINTAINER sundongsheng@nstc.com.cn
LABEL version="1.0"
ADD jdk-8u301-linux-x64.tar.gz /usr/local/
RUN apk update && apk add --no-cache tzdata  \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata \
&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&& wget https://github.com.cnpmjs.org/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk \
&& apk add --no-cache glibc-2.34-r0.apk \
&& rm -rf glibc-2.34-r0.apk
ENV NACOS_IP 192.168.10.31
ENV NACOS_PORT 8101
ENV NACOS_NAMESPACE jy2v
ENV JAR_NAME client
ENV JAVA_HOME /usr/local/jdk1.8.0_301
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$ACTIVEMQ_HOME:$PATH
CMD ["sh","-c","java -Djava.security.egd=file:/dev/./urandom -Dspring.cloud.nacos.config.enabled=true -Dspring.cloud.nacos.config.server-addr=${NACOS_IP}:${NACOS_PORT} -Dspring.cloud.nacos.config.namespace=${NACOS_NAMESPACE} -jar /data/${JAR_NAME}.jar"]

```

```docker
docker build -t 192.168.10.31/jinzay/jdk ./
===========================================
docker run -d --name tss        -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=tss        -p 8897:8897 192.168.10.31/jinzay/jdk && docker logs -f tss

docker run -d --name gateway    -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=gateway    -p 8896:8896 192.168.10.31/jinzay/jdk && docker logs -f gateway

docker run -d --name listeners  -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=listeners  -p 8895:8895 192.168.10.31/jinzay/jdk && docker logs -f listeners

docker run -d --name payService -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=payService -p 8090:8090 192.168.10.31/jinzay/jdk && docker logs -f payService

docker run -d --name appService -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=appService -p 6051:6051 192.168.10.31/jinzay/jdk && docker logs -f appService

docker run -d --name gds        -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=gds        -p 8900:8900 192.168.10.31/jinzay/jdk && docker logs -f gds

docker run -d --name bank       -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=bank       -p 8898:8898 192.168.10.31/jinzay/jdk && docker logs -f bank

docker run -d --name client     -v /data/docker/application:/data -e NACOS_IP=192.168.10.31 -e JAR_NAME=client     -p 8899:8899 192.168.10.31/jinzay/jdk && docker logs -f client


```

# BPServer 镜像

[init.sh](file/init_v9DHBC0WsY.sh)

```sql
FROM 192.168.10.31/jinzay/alpine-glibc
MAINTAINER sundongsheng@nstc.com.cn
LABEL version="1.3.39" dbtype="mysql"
ADD jdk-8u301-linux-x64.tar.gz /usr/local
ADD apache-tomcat-8.5.73.tar.gz /usr/local
COPY init.sh /usr/local/
ENV DB_IP 192.168.10.31
ENV DB_PASSWORD Ninestar@2022
ENV DB_NAME jy2bps
ENV DB_PORT 3306
ENV BPC_IP 192.168.10.31
ENV BPC_PORT 10091
ENV MQ_IP 192.168.10.31
ENV MQ_PORT 10098
RUN rm -rf /usr/local/apache-tomcat-8.5.73/webapps/* \
&& rm -rf /usr/local/apache-tomcat-8.5.73/work/* \
&& mkdir -p /data/bps/data/
ADD bp-server.tar.gz /usr/local/apache-tomcat-8.5.73/webapps/
ENV JAVA_HOME /usr/local/jdk1.8.0_301
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$PATH
CMD ["sh","-c","/usr/local/init.sh ;/usr/local/apache-tomcat-8.5.73/bin/catalina.sh run"]
```

```bash
docker build -t 192.168.10.31/jinzay/bps ./

docker run -d --name bps \
-p 9081:8080 \
-v /data/docker/bps:/data \
192.168.10.31/jinzay/bps


```

# BPConsole 镜像

[init.sh](file/init_kGe36MJEsH.sh)

```docker
FROM 192.168.10.31/jinzay/alpine-glibc
MAINTAINER sundongsheng@nstc.com.cn
LABEL dbtype="mysql"
ADD jdk-8u301-linux-x64.tar.gz /usr/local/
COPY init.sh /usr/local/
RUN mkdir -p /data
ADD bpc_mysql.tar.gz /data/
ENV DB_IP 192.168.10.31
ENV DB_PASSWORD Ninestar@2022
ENV DB_NAME jy2bpc
ENV DB_PORT 3306
ENV MQ_IP 192.168.10.31
ENV MQ_PORT 10098
ENV JAVA_HOME /usr/local/jdk1.8.0_301
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$PATH
CMD ["sh","-c","/usr/local/init.sh ;/data/bpc/tomcat/bin/catalina.sh run"]
```

```docker
docker build -t 192.168.10.31/jinzay/bpc ./

docker run -d --name bpc -p 10091:10091 192.168.10.31/jinzay/bpc ; docker logs -f bpc
```

# alpine-glibc 基础镜像

使用alpine作为基础镜像，并使用中国标准时间，安装glibc依赖。github不稳定，故制作次镜像。

```sql
FROM alpine
MAINTAINER sundongsheng@nstc.com.cn
LABEL version="1.0"
RUN apk update && apk add --no-cache tzdata  \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata \
&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&& wget https://github.com.cnpmjs.org/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk \
&& apk add --no-cache glibc-2.34-r0.apk \
&& rm -rf glibc-2.34-r0.apk
--------------------------------------------------------
docker build -t 192.168.10.31/jinzay/alpine-glibc ./
```

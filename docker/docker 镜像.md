

# 制作docker镜像

## 1. docker commit

```bash
# 1.下载底层操作系统docker镜像
docker pull hub.c.163.com/public/centos:7.2-tools

# 2.运行该镜像
docker run --name mydocker -h mydocker -d b2ab0ed558bb

# 3.将源码包复制到docker中
docker cp pgdg-redhat-repo-latest.noarch.rpm 容器id:/data/

# 4.安装nginx

# 5.将容器封装为新的镜像
docker commit postgres postgres:1.0
------------------------------------------------------------------
# docker commit [选项] <容器ID或容器名> [<仓库名>[:<标签>]]
# -a:提交镜像的作者
# -c:使用DockerFile指令来创建镜像
# -m:提交时的说明
# -p:在commit时，将容器暂停
```

## 2. dockerfile

dockerfile 是一个用来构建镜像的文本文件，文本内容包含了一条条构建镜像所需的指令和说明。

dockerfile 分为四部分：**基础镜像信息、维护者信息、镜像操作指令、容器启动执行指令**。一开始必须要指明所基于的镜像名称，接下来一般会说明维护者信息；后面则是镜像操作指令，例如 RUN 指令。每执行一条RUN 指令，镜像添加新的一层，并提交；最后是 CMD 指令，来指明运行容器时的操作命令。

### 2.1 dockerfile文件详解

```bash
FROM         # 指定创建镜像的基础镜像
MAINTAINER   # Dockerfile作者信息，一般写的是联系方式
RUN          # 将在当前镜像顶部的新层中执行所有命令，并提交结果。生成的提交镜像将用于 Dockerfile 中的下一步
CMD          # 指定容器启动时执行的命令；启动容器中的服务
LABEL        # 指定生成镜像的源数据标签
EXPOSE       # EXPOSE 指令是声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务。
             # 在 Dockerfile 中写入这样的声明有两个好处，一个是帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射；
             # 另一个用处则是在运行时使用随机端口映射时，也就是 docker run -P时，会自动随机映射 EXPOSE 的端口
ADD          # 对压缩文件进行解压缩；将数据移动到指定的目录
COPY         # 复制宿主机数据到镜像内部使用
WORKDIR      # 切换到镜像容器中的指定目录中
VOLUME       # 挂载数据卷到镜像容器中
USER         # 指定运行容器的用户
ARG          # 在 build 的时候存在的, 可以在 Dockerfile 中当做变量来使用
ENV          # env 是容器构建好之后的环境变量, 不能在 Dockerfile 中当参数使用
ONBUILD      # 创建镜像，作为其他镜像的基础镜像运行操作指令
ENTRYPOINT   # 指定运行容器启动过程执行命令，覆盖CMD参数
```

### 2.2 docker build

`docker build`命令用于从Dockerfile构建映像。

```bash
# 在Dockerfile 文件所在目录执行：
docker build -t 192.168.10.31/jinzay/jdk ./
#docker build  -t ImageName:TagName dir

-t          # 给镜像加一个Tag,一般写dockerhub+镜像名
-f          # 指定Dockerfile文件

```


## 3. 构建基础镜像的建议

- 选择合适的基础像: 选择一个最小、官方维护且适合你需求的镜像作为基础。
- 使用多阶段构建: 在一个阶段（`builder`）中使用包含编译工具的大型镜像进行构建，在另一个阶段只将编译好的二进制文件或依赖复制到一个小型运行时镜像中。
- 利用缓存: 将不经常变化的指令放在Dockerfile的靠前位置，以充分利用Docker的构建缓存。
- 串联指令: 合并 RUN 指令，以减少镜像层数。 

[[docker 实用指南/Docker 精简镜像的几个方法|Docker 精简镜像的几个方法]]

# 使用镜像

[[docker 命令#docker run | docker run]]


**容器启动失败**

执行失败是因为docker容器默认会把容器内部第一个进程，也就是pid=1的程序作为docker容器是否正在运行的依据，如果docker容器里pid=1的进程结束了，那么docker容器便会直接退出。
docker run的时候把command为容器内部命令，如果使用nginx，那么nginx程序将后台运行，这个时候nginx并不是pid为1的程序，而是执行bash，这个bash执行了nginx指令后就结束了，所以容器也就退出，端口没有进行映射。
所以就需要加-g 'daemon off;'的启动参数。daemon的作用是否让nginx运行后台；默认为on，调试时可以设置为off，使得nginx运行在前台，所有信息直接输出控制台。

# 示例

## 1. alpine-glibc 镜像

`Alpine` 操作系统是一个面向安全的轻型 `Linux` 发行版。它不同于通常 `Linux` 发行版，`Alpine` 采用了 `musl libc` 和 `busybox` 以减小系统的体积和运行时资源消耗，但功能上比 `busybox` 又完善的多，因此得到开源社区越来越多的青睐。在保持瘦身的同时，`Alpine` 还提供了自己的包管理工具 `apk`

前面我们提到了Alpine使用的不是正统的glibc，对于一些强依赖glibc的系统建议不要使用Alpine，比如使用了Oracle JDK的系统，建议在Alpine换成OpenJDK。强行安装只会违背Alpine的设计初。所以对于java程序来说使用CentOS等操作系统会更好一下。

那么强行安装Oracle JDK会怎样呢，下面我们来讨论一下

https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-bin-2.35-r0.apk
https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-i18n-2.35-r0.apk

```sql
FROM alpine:3.15
MAINTAINER doshell
ARG APK_GLIBC_VERSION=2.35-r0
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_LANG_FILE="glibc-i18n-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"
RUN apk update && apk add --no-cache tzdata \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& apk del tzdata \
&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&& wget --no-check-certificate "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}" \
&& apk add --no-cache "${APK_GLIBC_FILE}" \
&& wget --no-check-certificate  "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}" \
&& apk add --no-cache "${APK_GLIBC_BIN_FILE}" \
&& wget --no-check-certificate  "${APK_GLIBC_BASE_URL}/${APK_GLIBC_LANG_FILE}" \
&& apk add --no-cache "${APK_GLIBC_LANG_FILE}" \
&& rm -rf glibc-*.apk \
&& ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
--------------------------------------------------------
docker build -t 192.168.10.31/jinzay/alpine-glibc ./
```

## 2. jdk 镜像

```docker
FROM centos:centos7.9.2009
MAINTAINER doshell
ARG JDK_VERSION="1.8.0_333"
ARG LANG="en_US.UTF-8"
ADD jdk-8u333-linux-x64.tar.gz /usr/local/
ENV JAVA_HOME /usr/local/jdk${JDK_VERSION}
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$ACTIVEMQ_HOME:$PATH
RUN sed -i "\$aexport LANG=${LANG}" /etc/profile \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

---------------------------------------------------------------------
FROM alpine-glibc
MAINTAINER doshell
ARG JDK_VERSION="1.8.0_333"
ADD jdk-8u333-linux-x64.tar.gz /usr/local/
ENV NACOS_IP 192.168.10.31
ENV NACOS_PORT 8101
ENV NACOS_NAMESPACE jy2v
ENV JAR_NAME client
ENV JAVA_HOME /usr/local/jdk${JDK_VERSION}
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
ENV PATH $JAVA_HOME/bin:$ACTIVEMQ_HOME:$PATH
CMD ["sh","-c","java -Djava.security.egd=file:/dev/./urandom -Dspring.cloud.nacos.config.enabled=true -Dspring.cloud.nacos.config.server-addr=${NACOS_IP}:${NACOS_PORT} -Dspring.cloud.nacos.config.namespace=${NACOS_NAMESPACE} -jar /data/${JAR_NAME}.jar"]

```

## 3. mysql镜像

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
#--------------------------------------------------------------------------
# 使用docker build 构建镜像
docker build -t 192.168.10.31/jinzay/mysql:5.7.37 ./
# 使用镜像启动容器
docker run -d --name mysql -v /data/mysql:/var/lib/mysql \
-p 3306:3306 -e MYSQL_ROOT_PASSWORD=Ninestar@2022 192.168.10.31/jinzay/mysql:5.7.37;

# 查看启动日志
docker logs -f mysql
```

## 4. activemq镜像

alpine作为基础镜像，部署activemq需要glibc依赖

```bash
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
#--------------------------------------------------------------------
docker build -t 192.168.10.31/jinzay/activemq ./
#--------------------------------------------------------------------
docker run -d --name activemq -p 10098:61616 -p 10097:8161 192.168.10.31/jinzay/activemq

```

## 5. nginx镜像

```bash
docker run \
-p 8080:80 \
--name nginx \
-v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /home/nginx/conf/conf.d:/etc/nginx/conf.d \
-v /home/nginx/log:/var/log/nginx \
-v /home/nginx/html:/usr/share/nginx/html \
-d nginx:latest
```

## 6. minio 镜像

```bash
docker run  -p 9000:9000 --name minio \
 -d --restart=always \
 -e MINIO_ACCESS_KEY=minio \
 -e MINIO_SECRET_KEY=minio@123 \
 -v /usr/local/minio/data:/data \
 -v /usr/local/minio/config:/root/.minio \
  minio/minio server /data  --console-address ":9000" --address ":9090"
```

‍

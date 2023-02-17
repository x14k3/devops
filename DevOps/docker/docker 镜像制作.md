#devops/docker

## 一、docker commit
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




## 二、DockerFile

Dockerfile 是一个用来构建镜像的文本文件，文本内容包含了一条条构建镜像所需的指令和说明。

`docker build`命令用于从Dockerfile构建映像。可以使用`-f`标志指向Dockerfile文件。

### 1.dockerfile文件详解

```bash
FROM         # 指定创建镜像的基础镜像
MAINTAINER   # Dockerfile作者信息，一般写的是联系方式
RUN          # 将在当前镜像顶部的新层中执行所有命令，并提交结果。生成的提交镜像将用于 Dockerfile 中的下一步
CMD          # 指定容器启动时执行的命令；启动容器中的服务
LABEL        # 指定生成镜像的源数据标签
EXPOSE       # EXPOSE 指令是声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务。
             # 在 Dockerfile 中写入这样的声明有两个好处，一个是帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射；
             # 另一个用处则是在运行时使用随机端口映射时，也就是 docker run -P时，会自动随机映射 EXPOSE 的端口
ENV          # 使用环境变量
ADD          # 对压缩文件进行解压缩；将数据移动到指定的目录
COPY         # 复制宿主机数据到镜像内部使用
WORKDIR      # 切换到镜像容器中的指定目录中
VOLUME       # 挂载数据卷到镜像容器中
USER         # 指定运行容器的用户
ARG          # 指定镜像的版本号信息
ONBUILD      # 创建镜像，作为其他镜像的基础镜像运行操作指令
ENTRYPOINT   # 指定运行容器启动过程执行命令，覆盖CMD参数
```

```bash
#使用的基础镜像
FROM centos
#创建目录
RUN mkdir -p /docker_home/local
#把当前目录下的jdk文件夹添加到镜像
ADD tomcat9 /docker_home/local/tomcat9
ADD jdk18 /docker_home/local/jdk18
ENV JAVA_HOME /docker_home/local/jdk18/
ENV CATALINA_HOME /docker_home/local/tomcat9
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin
#暴露8082端口
EXPOSE 8082
#启动时运行tomcat
CMD ["/docker_home/local/tomcat9/bin/catalina.sh","run"]
```

Dockerfile 分为四部分：**基础镜像信息、维护者信息、镜像操作指令、容器启动执行指令**。一开始必须要指明所基于的镜像名称，接下来一般会说明维护者信息；后面则是镜像操作指令，例如 RUN 指令。每执行一条RUN 指令，镜像添加新的一层，并提交；最后是 CMD 指令，来指明运行容器时的操作命令。

### 2.构建镜像

```bash
# 在Dockerfile 文件所在目录执行：
docker build -t centos:7 ./
```

**典型用法**
```docker
    docker build  -t ImageName:TagName dir
    # 选项 
    - t          #  给镜像加一个Tag
    - ImageName  #  给镜像起的名称
    - TagName    #  给镜像的Tag名
    - Dir        #  Dockerfile所在目录
```


**容器启动失败**

执行失败是因为docker容器默认会把容器内部第一个进程，也就是pid=1的程序作为docker容器是否正在运行的依据，如果docker容器里pid=1的进程结束了，那么docker容器便会直接退出。
docker run的时候把command为容器内部命令，如果使用nginx，那么nginx程序将后台运行，这个时候nginx并不是pid为1的程序，而是执行bash，这个bash执行了nginx指令后就结束了，所以容器也就退出，端口没有进行映射。
所以就需要加-g 'daemon off;'的启动参数。daemon的作用是否让nginx运行后台；默认为on，调试时可以设置为off，使得nginx运行在前台，所有信息直接输出控制台。

## 1. 使用更精简的镜像

常用的Linux系统镜像一般有 Debian、Ubuntu、CentOS和Alpine，其中Alpine是面向安全的轻量级Linux发行版本。Docker的Alpine镜像仅有不到5M的大小，非常适合作为基础镜像。

Alpine使用ash这个轻量级的shell，而上述其他Linux发行版默认使用bash作为其shell。另外，Aline使用apk作为其包管理工具，软件安装包的名字可能与其他发行版不同，可以在https://pkgs.alpinelinux.org/packages搜索确定安装包的名字。



## 2. 压缩RUN语句&清理不必要的文件和程序

### 压缩RUN语句

Docker镜像是分层的，Dockerfile中的每一条RUN语句都会增加一层镜像，导致镜像非常臃肿。多个RUN命令应尽量用一条RUN命令完成，用“&&”和“\”串联每一条命令。

比如下面的两条RUN命令

```bash
RUN apt-get update
RUN apt-get install -y git
```

可以压缩成一条

```bash
RUN apt-get update && \
    apt-get install -y git
```

### 清理不必要的程序和文件

另外，在用apt安装软件包时，我们可以使用--no-install-recommends参数来 **避免安装非必须的文件** ，从而减小镜像的体积；安装完成之后rm -rf /var/lib/apt/lists/* ， **清理** apt **缓存** ，进一步缩小镜像。

```bash
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*
```

使用apk安装软件包时，我们可以使用--no-cache参数达到同样的目的，或者在安装完软件包后使用rm -rf /var/cache/apk/*。

```bash
RUN apk -U --no-cache add git
或者
RUN apk -U add git && \
    rm -rf /var/cache/apk/*
```

要注意的是，安装软件包和清理缓存需要在同一条RUN语句中执行，因为每一条RUN语句都会增加一层，这样把apt-get和rm -rf /var/lib/apt/lists/*分开的话，就不能清理apt-get产生的缓存；apk也是同理。

```bash
# 正确
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*
# 错误
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
RUN rm -rf /var/lib/apt/lists/*
```

在构建镜像的时候，我们在编译阶段可能会下载一些依赖的头文件和用于编译的程序，或者其他相关程序（比如git），这些在程序运行时完全不需要，可以删除掉。

```bash
RUN apt-get update && \
  apt-get install -y git make gcc libssl-dev && \
……
# 编译完成后，清理编译环境和跟程序运行无关的软件
  apt-get purge -y git make gcc libssl-dev
……
```


## 3. 多段构建

从Docker 17.05开始，一个Dockerfile文件可以使用多条FROM语句，每条FROM语句可以使用不同的镜像。这样我们可以把Docker的构建阶段分层多个阶段，以两个FROM语句为例，我们可以使用一个镜像编译我们的程序；另一个镜像使用更精简的镜像，拷贝上一阶段的编译的结果。

在使用FROM语句时，我们可以用AS为不同的镜像起别名，方便后续操作。用COPY命令从其他镜像拷贝文件时，我们可以用--from=alias src dst从别的阶段复制文件；如果没有为镜像起别名，第一个镜像的ID为0，第二个为1，我们可以用ID从别的阶段拷贝文件，--from=0 src dst

```dockerfile
FROM golang:1.9-alpine as builder
RUN apk --no-cache add git
WORKDIR /go/src/github.com/go/helloworld/
RUN go get -d -v github.com/go-sql-driver/mysql
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest as prod
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/go/helloworld/app .
CMD ["./app"]
```


## 4. 压缩镜像

### 使用docker export和docker import[

docker export是用来保存一个容器的，所以我们需要有一个正在运行的容器才能使用此命令。

```bash
docker export <CONTAINER ID> > export.tar
```

docker import用来加载保存的容器，但是 **不能恢复成一个容器，而是变成一个镜像**

```bash
docker import export.tar <IMAGE NAME>:[TAG]
```

可以用一条命令实现

```bash
docker export <容器ID> | docker import - <镜像名>[:标签]
```

使用export和import后得到的镜像不会保存镜像的历史，所以镜像会变小。

> `docker save`是用来保存一个镜像的，`dockersave<IMAGE ID>>save.tar`；然后可以用`docker load`加载我们保存的镜像，`docker load < save.tar`。使用`docker save`和`load`恢复后的镜像依然会保存镜像的历史。


test镜像未经过压缩的，test/import镜像是经过压缩的镜像，可以看到已经变小了一些
![[docker/docker 实用指南/assets/4fc2a31e5bbd30ac86269908afb56ae0_MD5.png|675]]

### 使用docker-squash

github地址：https://github.com/jwilder/docker-squash

```bash
docker save <image id> | sudo docker-squash -t newtag | docker load
```

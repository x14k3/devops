# docker 命令

## docker run

`docker run [OPTIONS] IMAGE`  根据镜像新建并启动容器。IMAGE是镜像ID或镜像名

`docker run --name nginx -p 80:80 --restart=always -dit 4cdc /bin/bash`

```bash
#OPTIONS说明：
-d           #容器后台运行
-i           #打开STDIN，用于控制台交互
-t           #分配tty设备，支持终端登录
-u           #指定容器用户
-w           #指定容器的工作目录
-c           #设置cpu权重
-e           #指定环境变量
-m           #指定容器内存上限
-p           #映射主机端口:容器端口
-v           #挂载主机目录:容器目录
--volumes-from=[]  #挂载其他容器的某个目录到容器
--dns        #指定容器的dns服务器
--expose     #指定容器暴露的端口
--name       #指定容器的name
--net        #容器网络设置
--restart=[
          no         #容器退出时，不重启容器；
          on-failure #只有在非0状态退出时才从新启动容器；
          always     #无论退出状态是如何，都重启容器；
]
--privileged=true  # 使docker中的root获得真正的root权限
#小技巧：docker必须有进程存在才能保存运行
#所以启动docker时，避免自动stop，可使用下面的命令
docker run -dit imageID /bin/bash
```

## 容器管理

```bash
docker start             #开启一个容器并使其在后台运行
docker stop             #停止一个容器
docker restart        #重启一个容器
docker kill                #杀掉一个容器进程
docker rm                #删除容器
docker prune          #删除所有终止的容器
docker pause          #暂停容器
docker unpause      #恢复暂停容器
docker create           #从镜像中创建一个容器
docker exec -it         #在运行的容器中执行命令[docker exec -it alpine /bin/sh ]
    -i :展示容器输入信息STDIN
    -t :命令行交互模式
  
docker ps                 #列出容器
docker logs              #获取docker日志
docker inspect         #获取容器或镜像的元数据
docker top               #查看正在运行中的容器进程信息
docker attach          #链接正在运行的容器,_注意：_ 如果从这个 stdin 中 exit，会导致容器的停止。
docker events          #从docker服务器获取事件
docker wait              #让一个容器进入等待，使其进入阻塞状态

docker port              #列出一个容器的端口映射情况
docker container    #管理已经运行的容器的
docker deploy         #部署新的堆栈或更新已有堆栈的
docker update         #更新容器
docker rename       #重命名容器
docker volume        #卷管理
docker commit       #提交一个容器的文件系统，使之生成一个新的镜像
docker cp                 #向一个正在运行的容器复制文件，或将容器中的文件复制出来
docker diff               #检查一个容器文件系统更改情况

docker export          #将容器打包为tar格式的镜像   [docker export hass -o hass.tar ]
docker import          #加载通过docker export打包的容器镜像 [ docker import hass.tar ]
```

## 镜像管理

```bash
docker images         #列出镜像
docker rmi                #删除镜像
docker tag                #修改本地某一镜像的标记，使其镜像属于某一仓库 [docker tag alpine:3.15 192.168.0.100:8081/images/alpine:3.15]
docker build             #通过指定Dockerfile文件编译镜像
docker history          #查看镜像历史
docker checkpoint   #设置checkpoint，类似于恢复点，可以让镜像撤销到曾经设置的某一个checkpoint上
docker manifest       #docker镜像清单管理
docker trust              #docker可信镜像管理
docker save               #将镜像保存成tar文件 [docker save -o alpine.tar  alpine:3.15]
docker load               #从tar中恢复镜像 [docker load < alpine.tar]
```

**总结一下docker save和docker export的区别：**

- docker save   保存的是镜像；docker load   用来载入镜像包，
- docker export 保存的是容器；docker import 用来载入容器包，但两者都会恢复为镜像。

> docker save的应用场景是：
> 如果你的应用是使用docker-compose.yml编排的多个镜像组合，但你要部署的客户服务器并不能连外网。这时，你可以使用docker save将用到的镜像打个包，然后拷贝到客户服务器上使用docker load载入。

> docker export的应用场景：
> 主要用来制作基础镜像，比如你从一个ubuntu镜像启动一个容器，然后安装一些软件和进行一些设置后，使用docker export保存为一个基础镜像。然后，把这个镜像分发给其他人使用，比如作为基础的开发环境。

## 数据卷管理

[docker 数据卷](docker%20数据卷.md)

## 网络管理

[docker 网络](docker%20网络.md)

## 仓库管理

```bash
login          #docker登入 [docker login 192.168.0.100:8081]
logout       #docker登出
pull            #拉取镜像         [docker pull 192.168.0.100:8081/images/alpine:3.15]
push          #推送镜像至服务器 [docker push 192.168.0.100:8081/images/alpine:3.15]
search       #在docker hub上查询镜像
```

## 其他命令

```bash
docker info                      #查询docker信息
docker version               #查询docker版本
docker system                #docker系统管理
docker system df           #查看docker自身的内存占用
docker system prune    #于清理磁盘，删除关闭的容器、无用的数据卷和网络，以及dangling镜像(即无tag的镜像)。
docker stats                    #docker容器资源使用统计
docker config                 #管理docker配置
docker network             #docker网络管理
docker plugin                 #docker插件管理
docker secret                 #docker敏感信息管理
docker service               #docker服务管理
```

## docker容器端口映射

### 1.在创建容器的时候指定

`docker run --name mytomcat -d -p 8888:8080 tomcat`

### 2.修改hostconfig.json和config.v2.json配置文件

```bash
docker stop 容器id
systemctl stop docker
cd /var/lib/docker/container/容器id
vim hostconfig.json
vim config.v2.json
systemctl start docker
docker start 容器id
```

### 3.iptable转发端口

```bash
docker inspect 容器id | grep IPAddress

# 将宿主机的8888端口映射到IP为192.168.1.15容器的8080端口
iptables -t nat -A DOCKER -p tcp --dport 8888 -j DNAT --to-destination 192.168.1.15:8080
```

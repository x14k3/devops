#devops/docker

## 容器生命周期管理

```bash
run         #创建一个新容器并运行
start       #开启一个容器并使其在后台运行
stop        #停止一个容器
restart     #重启一个容器
kill        #杀掉一个容器进程
rm          #删除容器
pause       #暂停容器
unpause     #恢复暂停容器
create      #从镜像中创建一个容器
exec        #在运行的容器中执行命令[OPTIONS]
    -d :分离模式: 在后台运行
    -i :展示容器输入信息STDIN
    -t :命令行交互模式
```

## 容器操作

```bash
ps           #列出容器
inspect      #获取容器或镜像的元数据
top          #查看正在运行中的容器进程信息
attach       #链接正在运行的容器
events       #从docker服务器获取事件
logs         #获取docker日志
wait         #让一个容器进入等待，使其进入阻塞状态
export       #讲一个容器的文件系统打包至tar
port         #列出一个容器的端口映射情况
container    #管理已经运行的容器的
deploy       #部署新的堆栈或更新已有堆栈的
update       #更新容器
rename       #重命名容器
volume       #卷管理

```

## 容器文件系统操作

```bash
commit      #提交一个容器的文件系统，使之生成一个新的镜像
cp          #向一个正在运行的容器复制文件，或将容器中的文件复制出来
diff        #检查一个容器文件系统更改情况
```

## 镜像仓库操作

```bash
login       #docker登入
logout      #docker登出
pull        #拉取镜像
push        #推送镜像至服务器
search      #在docker hub上查询镜像
```

## 镜像管理

```bash
images       #列出镜像
rmi          #删除镜像
tag          #修改本地某一镜像的标记，使其镜像属于某一仓库
build        #通过指定Dockerfile文件编译镜像
history      #查看镜像历史
save         #将制定镜像保存成tar文件
load         #从tar中恢复镜像
import       #从tar中创建一个新镜像
checkpoint   #设置checkpoint，类似于恢复点，可以让镜像撤销到曾经设置的某一个checkpoint上
image        #docker镜像管理
manifest     #docker镜像清单管理
trust        #docker可信镜像管理
```

## 集群管理

```bash
swarm        #docker集群管理工具
node         #docker集群节点控制
stack        #docker集群堆栈管理
```

## 其他命令

```bash
info         #查询docker信息
version      #查询docker版本
system       #docker系统管理
stats        #docker容器资源使用统计
config       #管理docker配置
network      #docker网络管理
plugin       #docker插件管理
secret       #docker敏感信息管理
service      #docker服务管理
```

### docker run 详解

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
-p           #指定容器暴露的端口hostPort:containerPort
-h           #指定容器主机名
-v           #挂载宿主机某个目录到容器的某个目录
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

### docker容器端口映射

==方法一：在创建容器的时候指定==

`docker run --name mytomcat -d -p 8888:8080 tomcat`

==方法二：修改hostconfig.json和config.v2.json配置文件==
```bash
docker stop 容器id
systemctl stop docker
cd /var/lib/docker/container/容器id
vim hostconfig.json
vim config.v2.json
systemctl start docker
docker start 容器id
```



==方法三：iptable转发端口==
```bash
docker inspect 容器id | grep IPAddress

# 将宿主机的8888端口映射到IP为192.168.1.15容器的8080端口
iptables -t nat -A DOCKER -p tcp --dport 8888 -j DNAT --to-destination 192.168.1.15:8080
```

### docker镜像/容器导入与导出
```bash
##################  镜像  ##################
# 导出语法
docker save [OPTIONS] IMAGE [IMAGE...]
# 例子，如果需要跨操作系统，请使用 -o 方式
docker save -o my_ubuntu_v3.tar runoob/ubuntu:v3
docker save runoob/ubuntu:v3 > my_ubuntu_v3.tar

# 导入语法
docker load [OPTIONS]
# 例子，如果需要跨操作系统，请使用 -i 方式
docker load -i ubuntu.tar
docker load < ubuntu.tar



##################  容器  ##################
# 导出语法
docker export [OPTIONS] CONTAINER
# 例子
docker export -o mysql-`date +%Y%m%d`.tar a404c6c174a2

# 导入语法
docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]
# 例子
docker import  my_ubuntu_v3.tar runoob/ubuntu:v4

### 总结一下docker save和docker export的区别：###

# docker save   保存的是镜像；docker load   用来载入镜像包，
# docker export 保存的是容器；docker import 用来载入容器包，但两者都会恢复为镜像。

# docker save的应用场景是：
# 如果你的应用是使用docker-compose.yml编排的多个镜像组合，但你要部署的客户服务器并不能连外网。这时，你可以使用docker save将用到的镜像打个包，然后拷贝到客户服务器上使用docker load载入。

# docker export的应用场景：
# 主要用来制作基础镜像，比如你从一个ubuntu镜像启动一个容器，然后安装一些软件和进行一些设置后，使用docker export保存为一个基础镜像。然后，把这个镜像分发给其他人使用，比如作为基础的开发环境。

```




# docker compose

我们知道使用一个 `Dockerfile` 模板文件，可以让用户很方便的定义一个单独的应用容器。然而，在日常工作中，经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个 Web 项目，除了 Web 服务容器本身，往往还需要再加上后端的数据库服务容器，甚至还包括负载均衡容器等。

`Compose` 恰好满足了这样的需求。它允许用户通过一个单独的 `docker-compose.yml` 模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。

**`Compose`**​**​ 中有两个重要的概念：**

- 服务 (`service`)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
- 项目 (`project`)：由一组关联的应用容器组成的一个完整业务单元，在 `docker-compose.yml` 文件中定义。

`Compose` 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理。
`Compose` 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。因此，只要所操作的平台支持 Docker API，就可以在其上利用 `Compose` 来进行编排管理。

**Compose v2**

目前 Docker 官方用 GO 语言 重写了 Docker Compose，并将其作为了 docker cli 的子命令，称为 `Compose V2`。你可以参照官方文档安装，然后将熟悉的 `docker-compose` 命令替换为 `docker compose`，即可使用 Docker Compose。

# 部署 docker-compose

`Compose` 支持 Linux、macOS、Windows 10 三大平台。
`Compose` 可以通过 Python 的包管理工具 `pip` 进行安装，也可以直接下载编译好的二进制文件使用，甚至能够直接在 Docker 容器中运行。
`Docker Desktop for Mac/Windows` 自带 `docker-compose` 二进制文件，安装 Docker 之后可以直接使用。

```bash
docker-compose --version
docker-compose version 1.27.4, build 40524192
```

Linux 系统请使用以下介绍的方法安装。
从 官方 GitHub Release(https://github.com/docker/compose/releases) 处直接下载编译好的二进制文件即可。

```bash
curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
# bash 补全命令
curl -L https://raw.githubusercontent.com/docker/compose/1.27.4/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
```

# 使用 docker compose 部署 nginx

```bash
mkdir -p /usr/local/docker-nginx ; cd /usr/local/docker-nginx 
vim docker-compose.yml
----------------------------------------------------------
# 描述Compose版本信息
version: "3.8"
  # 定义服务
services:
  nginx: # 服务名称
    image: nginx
    container_name: mynginx
    ports:
      - "7878:80" # 主机端口：容器端口
    networks:
      - nginx-net

networks:
  nginx-net:
    name: nginx-net
    driver: bridge
---------------------------------------------------------------

# 使用docker compose创建并后台启动容器
docker compose up -d
```

# docker compose 命令

```bash
#`docker-compose` 命令的基本的使用格式是
docker-compose [-f=<arg>...] [options] [COMMAND] [ARGS...]
-f # 指定使用的 Compose 模板文件，默认为 `docker-compose.yml`，可以多次指定。
-p # 指定项目名称，默认将使用所在目录名称作为项目名。
--verbose  # 输出更多调试信息。
-v # 打印版本并退出。

# options：

# 默认使用docker-compose.yml构建镜像
docker compose build
docker compose build --no-cache # 不带缓存的构建

# 指定不同yml文件模板用于构建镜像
docker compose build -f docker-compose1.yml

# 列出Compose文件构建的镜像
docker compose images                          

# 该命令十分强大，它将尝试自动完成包括构建镜像，（重新）创建服务，启动服务，并关联服务相关容器的一系列操作。
docker compose up -d

# 查看正在运行中的容器
docker compose ps 

# 查看所有编排容器，包括已停止的容器
$ docker compose ps -a

# 进入指定容器执行命令
$ docker compose exec nginx bash 
$ docker compose exec web python manage.py migrate --noinput

# 查看web容器的实时日志
$ docker compose logs -f web

# 停止所有up命令启动的容器
$ docker compose down 

# 停止所有up命令启动的容器,并移除数据卷
$ docker compose down -v

# 重新启动停止服务的容器
$ docker compose restart web

# 暂停web容器
$ docker compose pause web

# 恢复web容器
$ docker compose unpause web

# 删除web容器，删除前必需停止stop web容器服务
$ docker compose rm web  

# 查看各个服务容器内运行的进程 
$ docker compose top         

```

# docker-compose.yml模板文件

Docker-Compose允许用户通过一个docker-compose.yml模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。
Compose模板文件是一个定义服务、网络和卷的YAML文件。Compose模板文件默认路径是当前目录下的docker-compose.yml，可以使用.yml或.yaml作为文件扩展名。
Docker-Compose标准模板文件应该包含version、services、networks三大部分，最关键的是**services和networks**两个部分。

参考[docker-compose.yml](docker%20harbor.md#docker-compose.yml)

## version

Compose目前有三个版本分别为Version 1，Version 2，Version 3，Compose区分Version 1和Version 2（Compose 1.6.0+，Docker Engine 1.10.0+）。Version 2支持更多的指令。Version 1将来会被弃用。

## image

image是指定服务的镜像名称或镜像ID。如果镜像在本地不存在，Compose将会尝试拉取镜像。

```
services:
  web:
    image: dockercloud/hello-world
```

## build

服务除了可以基于指定的镜像，还可以基于一份Dockerfile，在使用up启动时执行构建任务，构建标签是build，可以指定Dockerfile所在文件夹的路径。Compose将会利用Dockerfile自动构建镜像，然后使用镜像启动服务容器。

```
build: /path/to/build/dir
```

也可以是相对路径，只要上下文确定就可以读取到Dockerfile。

```
build: ./dir
```

设定上下文根目录，然后以该目录为准指定Dockerfile。

```
build:
	context: ../
	dockerfile: path/of/Dockerfile
```

build都是一个目录，如果要指定Dockerfile文件需要在build标签的子级标签中使用dockerfile标签指定。**如果同时指定image和build两个标签，那么Compose会构建镜像并且把镜像命名为image值指定的名字。**

## context

context选项可以是Dockerfile的文件路径，也可以是到链接到git仓库的url，当提供的值是相对路径时，被解析为相对于撰写文件的路径，此目录也是发送到Docker守护进程的context

```
build:
	context: ./dir
```

## dockerfile

使用dockerfile文件来构建，必须指定构建路径

```
build:
context: .
	dockerfile: Dockerfile-alternate
```

## volumes

挂载一个目录或者一个已存在的数据卷容器，可以直接使用\[HOST:CONTAINER\]格式，或者使用\[HOST:CONTAINER:ro\]格式，后者对于容器来说，数据卷是只读的，可以有效保护宿主机的文件系统。Compose的数据卷指定路径可以是相对路径，使用.或者…来指定相对目录。

数据卷的格式可以是下面多种形式

```
volumes:
  // 只是指定一个路径，Docker 会自动在创建一个数据卷（这个路径是容器内部的）。
  - /var/lib/mysql
  // 使用绝对路径挂载数据卷
  - /opt/data:/var/lib/mysql
  // 以相对路径作为数据卷挂载到容器。ro表示只读、z表示使用selinux
  - ./cache:/tmp/cache:z
  // 已经存在的命名的数据卷。
  - datavolume:/var/lib/mysql
  // 绑定配置文件
  - type: bind
	source: ./common/config/log/logrotate.conf
	target: /etc/logrotate.d/logrotate.conf
```

如果不使用宿主机的路径，可以指定一个volume_driver。

```
volume_driver: mydriver
```

## volumes_from

从另一个服务或容器挂载其数据卷：

```
volumes_from:
   - service_name   
     - container_name
```

## ports

ports用于映射端口的标签。

使用HOST:CONTAINER格式或者只是指定容器的端口，宿主机会随机映射端口。

```
ports:
 - "3000"
 - "8000:8000"
 - "49100:22"
 - "127.0.0.1:8001:8001"
```

当使用HOST:CONTAINER格式来映射端口时，如果使用的容器端口小于60可能会得到错误得结果，因为YAML将会解析xx:yy这种数字格式为60进制。所以建议采用字符串格式。

## command

使用command可以覆盖容器启动后默认执行的命令。

```
command: bundle exec thin -p 3000
```

## container_name

Compose的容器名称格式是：<项目名称><服务名称><序号>

可以自定义项目名称、服务名称，但如果想完全控制容器的命名，可以使用标签指定：

```
container_name: app
```

## depends_on

在使用Compose时，最大的好处就是少打启动命令，但一般项目容器启动的顺序是有要求的，如果直接从上到下启动容器，必然会因为容器依赖问题而启动失败。例如在没启动数据库容器的时候启动应用容器，应用容器会因为找不到数据库而退出。depends\_on标签用于解决容器的依赖、启动先后的问题：

```
version: '2'
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: postgres
```

上述YAML文件定义的容器会先启动redis和db两个服务，最后才启动web服务。

## PID

```
pid: "host"
```

将PID模式设置为主机PID模式，跟主机系统共享进程命名空间。容器使用pid标签将能够访问和操纵其他容器和宿主机的名称空间。

## extra_hosts

添加主机名的标签，会在/etc/hosts文件中添加一些记录。

```
extra_hosts:
 - "somehost:162.242.195.82"
 - "otherhost:50.31.209.229"
```

启动后查看容器内部hosts：

```
162.242.195.82  somehost
50.31.209.229   otherhost
```

## dns

自定义DNS服务器。可以是一个值，也可以是一个列表。

```
dns：8.8.8.8
dns：
    - 8.8.8.8   
    - 9.9.9.9
```

## expose

暴露端口，但不映射到宿主机，只允许能被连接的服务访问。仅可以指定内部端口为参数，如下所示：

```
expose:
    - "3000"
    - "8000"
```

## links

链接到其它服务中的容器。使用服务名称（同时作为别名），或者“服务名称:服务别名”

```
links:
    - db
    - db:database
    - redis
```

## net

设置网络模式。

```
net: "bridge"
net: "none"
net: "host"
```

## cap_add，cap_drop

添加或删除容器拥有的宿主机的内核功能。
详情参考 [capabilities](#capabilities)

```
cap_add:
  - ALL # 开启全部权限

cap_drop:
  - SYS_PTRACE # 关闭 ptrace权限
```

## cgroup_parent

为容器指定父cgroup组，意味着将继承该组的资源限制。

```
cgroup_parent: m-executor-abcd
```

## dns_search

自定义DNS搜索域。可以是单个值或列表。

```
dns_search: example.com

dns_search:
  - dc1.example.com
  - dc2.example.com
```

## entrypoint

覆盖容器默认的 entrypoint。

```
entrypoint: /code/entrypoint.sh
```

也可以是以下格式：

```
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```

## env_file

从文件添加环境变量。可以是单个值或列表的多个值。

```
env_file: .env
```

也可以是列表格式：

```
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

## environment

添加环境变量。您可以使用数组或字典、任何布尔值，布尔值需要用引号引起来，以确保 YML 解析器不会将其转换为 True 或 False。

```
environment:
  RACK_ENV: development
  SHOW: 'true'
```

## healthcheck

用于检测docker服务是否健康运行。

```
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"] # 设置检测程序
  interval: 1m30s # 设置检测间隔
  timeout: 10s # 设置检测超时时间
  retries: 3 # 设置重试次数
  start_period: 40s # 启动后，多少秒开始启动检测程序
```

## logging

服务的日志记录配置。

driver：指定服务容器的日志记录驱动程序，默认值为json-file。有以下三个选项

```
driver: "json-file"
driver: "syslog"
driver: "none"
```

仅在json-file驱动程序下，可以使用以下参数，限制日志得数量和大小。

```
logging:
  driver: json-file
  options:
    max-size: "200k" # 单个文件大小为200k
    max-file: "10" # 最多10个文件
```

当达到文件限制上限，会自动删除旧得文件。

syslog驱动程序下，可以使用syslog-address指定日志接收地址。

```
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

## networks

配置容器连接的网络，引用顶级networks下的条目 。

```
services:
  some-service:
    networks:
      some-network:
        aliases:
         - alias1
      other-network:
        aliases:
         - alias2
networks:
  some-network:
    # Use a custom driver
    driver: custom-driver-1
  other-network:
    # Use a custom driver which takes special options
    driver: custom-driver-2
```

aliases：同一网络上的其他容器可以使用服务名称或此别名来连接到对应容器的服务。

## restart

- no：是默认的重启策略，在任何情况下都不会重启容器。
- always：容器总是重新启动。
- on-failure：在容器非正常退出时（退出状态非0），才会重启容器。
- unless-stopped：在容器退出时总是重启容器，但是不考虑在Docker守护进程启动时就已经停止了的容器

```
restart: "no"
restart: always
restart: on-failure
restart: unless-stopped
```

注：swarm集群模式，请改用restart\_policy。

## secrets

存储敏感数据，例如密码：

```
version: "3.1"
services:

mysql:
  image: mysql
  environment:
    MYSQL_ROOT_PASSWORD_FILE: /run/secrets/my_secret
  secrets:
    - my_secret

secrets:
  my_secret:
    file: ./my_secret.txt
```

## security_opt

修改容器默认的schema标签。

```
security-opt：
  - label:user:USER   # 设置容器的用户标签
  - label:role:ROLE   # 设置容器的角色标签
  - label:type:TYPE   # 设置容器的安全策略标签
  - label:level:LEVEL  # 设置容器的安全等级标签
```

## stop_grace_period

指定在容器无法处理SIGTERM (或者任何 stop_signal 的信号)，等待多久后发送SIGKILL信号关闭容器。

```
stop_grace_period: 1s # 等待 1 秒
stop_grace_period: 1m30s # 等待 1 分 30 秒 
```

默认的等待时间是10秒。

## stop_signal

设置停止容器的替代信号。默认情况下使用SIGTERM 。

以下示例，使用SIGUSR1替代信号SIGTERM来停止容器。

```
stop_signal: SIGUSR1
```

## sysctls

设置容器中的内核参数，可以使用数组或字典格式。

```
sysctls:
  net.core.somaxconn: 1024
  net.ipv4.tcp_syncookies: 0

sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0
```

## tmpfs

在容器内安装一个临时文件系统。可以是单个值或列表的多个值。

```
tmpfs: /run

tmpfs:
  - /run
  - /tmp
```

## ulimits

覆盖容器默认的ulimit。

```
ulimits:
  nproc: 65535
  nofile:
    soft: 20000
    hard: 40000
```

## devices

指定设备映射列表。

```
devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"
```

## tty

为容器分配一个伪终端，就相当于 `docke run -t`, 就是把 `/bin/bash` 当做前台进程。

```
tty: true
```

# capabilities

Capabilities的主要思想在于分割root用户的特权，即将root的特权分割成不同的能力，每种能力代表一定的特权操作。 例如：能力CAP_SYS_MODULE表示用户能够加载(或卸载)内核模块的特权操作，而CAP_SETUID表示用户能够修改进程用户身份的特权操作。在Capbilities中系统将根据进程拥有的能力来进行特权操作的访问控制。

```bash
CHOWN             # 修改文件属主的权限
DAC_OVERRIDE     # 忽略文件的DAC访问限制
DAC_READ_SEARCH  # 忽略文件读及目录搜索的DAC访问限制
FOWNER           # 忽略文件属主ID必须和进程用户ID相匹配的限制
FSETID           # 允许设置文件的setuid位
KILL             # 允许对不属于自己的进程发送信号
SETGID           # 允许改变进程的组ID
SETUID           # 允许改变进程的用户ID
SETPCAP          # 允许向其他进程转移能力以及删除其他进程的能力
LINUX_IMMUTABLE  # 允许修改文件的IMMUTABLE和APPEND属性标志
NET_BIND_SERVICE # 允许绑定到小于1024的端口
NET_BROADCAST    # 允许网络广播和多播访问
NET_ADMIN        # 允许执行网络管理任务
NET_RAW          # 允许使用原始套接字
IPC_LOCK         # 允许锁定共享内存片段
IPC_OWNER        # 忽略IPC所有权检查
SYS_MODULE       # 允许插入和删除内核模块
SYS_RAWIO        # 允许直接访问/devport,/dev/mem,/dev/kmem及原始块设备
SYS_CHROOT       # 允许使用chroot()系统调用
SYS_PTRACE       # 允许跟踪任何进程
SYS_PACCT        # 允许执行进程的BSD式审计
SYS_ADMIN        # 允许执行系统管理任务，如加载或卸载文件系统、设置磁盘配额等
SYS_BOOT         # 允许重新启动系统
SYS_NICE         # 允许提升优先级及设置其他进程的优先级
SYS_RESOURCE     # 忽略资源限制
SYS_TIME         # 允许改变系统时钟
SYS_TTY_CONFIG   # 允许配置TTY设备
MKNOD            # 允许使用mknod()系统调用
LEASE            # 允许修改文件锁的FL_LEASE标志
```

# 使用 docker compose 部署redis集群

1.编写redis配置文件

参考[三、集群模式](../中间件/redis/redis%20部署.md#三、集群模式)

```bash
# 在server上创建一个目录用于存放redis集群部署文件。这里我放的路径为/root/redis-cluster

# 在/opt/docker/redis-cluster目录下创建redis-1,redis-2,redis-3,redis-4,redis-5,redis-6文件夹

mkdir -p /opt/docker/redis-cluster/{redis-1,redis-2,redis-3,redis-4,redis-5,redis-6}

# 创建持久化目录

mkdir -p /opt/docker/redis-cluster/redis-1/data
mkdir -p /opt/docker/redis-cluster/redis-2/data
mkdir -p /opt/docker/redis-cluster/redis-3/data
mkdir -p /opt/docker/redis-cluster/redis-4/data
mkdir -p /opt/docker/redis-cluster/redis-5/data
mkdir -p /opt/docker/redis-cluster/redis-6/data

# 在每个redis-*文件夹下创建redis.conf文件，并写入如下内容:
# 注意：port值不能都为6379，根据上面redis列表设置的端口号，依次给redis-1 ~ redis-6设置6379~6384端口号
----------------------------------------------
bind 0.0.0.0
port 6379
masterauth passwd123
requirepass passwd123
daemonize no
appendonly yes
protected-mode no
cluster-enabled yes 
cluster-config-file nodes.conf
cluster-node-timeout 5000
-----------------------------------------------

# 在/root/redis-cluster文件夹下创建docker-compose.yml文件
vim docker-compose.yml
-----------------------------------------------
version: '3.1'
services:
  # redis1配置
  redis1:
    image: redis
    container_name: redis-1
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-1/data:/data
      - /opt/docker/redis-cluster/redis-1/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
  # redis2配置
  redis2:
    image: redis
    container_name: redis-2
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-2/data:/data
      - /opt/docker/redis-cluster/redis-2/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
  # redis3配置
  redis3:
    image: redis
    container_name: redis-3
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-3/data:/data
      - /opt/docker/redis-cluster/redis-3/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
  # redis4配置
  redis4:
    image: redis
    container_name: redis-4
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-4/data:/data
      - /opt/docker/redis-cluster/redis-4/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
  # redis5配置
  redis5:
    image: redis
    container_name: redis-5
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-5/data:/data
      - /opt/docker/redis-cluster/redis-5/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
  # redis6配置
  redis6:
    image: redis
    container_name: redis-6
    restart: always
    network_mode: "host"
    volumes:
      - /opt/docker/redis-cluster/redis-6/data:/data
      - /opt/docker/redis-cluster/redis-6/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
---------------------------------------------------------------------------
#启动容器

docker-compose -f docker-compose.yml up -d

# 开启集群,随便找一个容器进入，这里我选择redis-1进入。
docker exec -it redis-1 /bin/bash
# 在进入容器后，输入如下命令开启集群 .
redis-cli -a passwd123 --cluster create 192.168.0.100:6379 \
192.168.0.100:6380 \
192.168.0.100:6381 \
192.168.0.100:6382 \
192.168.0.100:6383 \
192.168.0.100:6384 \
--cluster-replicas 1


# 测试
root@doshell:/data# redis-cli -a passwd123
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> cluster nodes
e75f93d2823da513bfdd4b03cb6460be81c499ee 192.168.0.100:6383@16383 slave fc72a4564078437c79f89872fdef446e6ab6f1a9 0 1677158403619 1 connected
e5b5d0a4af25be7a403493eecb5c8e3d2edabfe6 192.168.0.100:6381@16381 master - 0 1677158403000 3 connected 10923-16383
fc72a4564078437c79f89872fdef446e6ab6f1a9 192.168.0.100:6379@16379 myself,master - 0 1677158403000 1 connected 0-5460
3940aa367229a3ae76cd6afac946dcfdb07b33c6 192.168.0.100:6382@16382 slave e5b5d0a4af25be7a403493eecb5c8e3d2edabfe6 0 1677158403116 3 connected
ef2a2b489e05b3fcfb0ba22f39fa4849e2ca3819 192.168.0.100:6384@16384 slave 34f9514dfae83d8881cd578e1bd331efff2e2986 0 1677158404120 2 connected
34f9514dfae83d8881cd578e1bd331efff2e2986 192.168.0.100:6380@16380 master - 0 1677158403000 2 connected 5461-10922
127.0.0.1:6379> 

# 删除环境
cd /opt/docker/redis-cluster
docker compose down
```

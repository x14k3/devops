

Docker-Compose允许用户通过一个docker-compose.yml模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。
Compose模板文件是一个定义服务、网络和卷的YAML文件。Compose模板文件默认路径是当前目录下的docker-compose.yml，可以使用.yml或.yaml作为文件扩展名。
Docker-Compose标准模板文件应该包含version、services、networks三大部分，最关键的是**services和networks**两个部分。

```yaml
version: '3.5'
services:
  nacos1:
    restart: always
    image: nacos/nacos-server:${NACOS_VERSION}
    container_name: nacos1
    privileged: true
    ports:
     - "8001:8001"
     - "8011:9555"
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 1024M 
    env_file: 
     - ./nacos.env 
    environment:
        NACOS_SERVER_IP: ${NACOS_SERVER_IP_1}
        NACOS_APPLICATION_PORT: 8001
        NACOS_SERVERS: ${NACOS_SERVERS}   
    volumes:
     - ./logs_01/:/home/nacos/logs/
     - ./data_01/:/home/nacos/data/
     - ./config/:/home/nacos/config/
    networks:
      - ha-network-overlay
  nacos2:
    restart: always
    image: nacos/nacos-server:${NACOS_VERSION}
    container_name: nacos2
    privileged: true
    ports:
     - "8002:8002"
     - "8012:9555"
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 1024M  
    env_file: 
     - ./nacos.env   
    environment:
        NACOS_SERVER_IP: ${NACOS_SERVER_IP_2}
        NACOS_APPLICATION_PORT: 8002
        NACOS_SERVERS: ${NACOS_SERVERS}
    volumes:
     - ./logs_02/:/home/nacos/logs/
     - ./data_02/:/home/nacos/data/
     - ./config/:/home/nacos/config/
    networks:
      - ha-network-overlay
  nacos3:
    restart: always
    image: nacos/nacos-server:${NACOS_VERSION}
    container_name: nacos3
    privileged: true
    ports:
     - "8003:8003"
     - "8013:9555"
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 1024M  
    env_file: 
     - ./nacos.env 
    environment:
        NACOS_SERVER_IP: ${NACOS_SERVER_IP_3}
        NACOS_APPLICATION_PORT: 8003
        NACOS_SERVERS: ${NACOS_SERVERS}       
    volumes:
     - ./logs_03/:/home/nacos/logs/
     - ./data_03/:/home/nacos/data/
     - ./config/:/home/nacos/config/
    networks:
      - ha-network-overlay
networks:
   ha-network-overlay:
     external: true


```

### version

Compose目前有三个版本分别为Version 1，Version 2，Version 3，Compose区分Version 1和Version 2（Compose 1.6.0+，Docker Engine 1.10.0+）。Version 2支持更多的指令。Version 1将来会被弃用。

### image

image是指定服务的镜像名称或镜像ID。如果镜像在本地不存在，Compose将会尝试拉取镜像。

```yaml
services:
  web:
    image: dockercloud/hello-world
```

### build

服务除了可以基于指定的镜像，还可以基于一份Dockerfile，在使用up启动时执行构建任务，构建标签是build，可以指定Dockerfile所在文件夹的路径。Compose将会利用Dockerfile自动构建镜像，然后使用镜像启动服务容器。

```yaml
build: /path/to/build/dir
```

也可以是相对路径，只要上下文确定就可以读取到Dockerfile。

```yaml
build: ./dir
```

设定上下文根目录，然后以该目录为准指定Dockerfile。

```yaml
build:
	context: ../
	dockerfile: path/of/Dockerfile
```

build都是一个目录，如果要指定Dockerfile文件需要在build标签的子级标签中使用dockerfile标签指定。**如果同时指定image和build两个标签，那么Compose会构建镜像并且把镜像命名为image值指定的名字。**

### context

context选项可以是Dockerfile的文件路径，也可以是到链接到git仓库的url，当提供的值是相对路径时，被解析为相对于撰写文件的路径，此目录也是发送到Docker守护进程的context

```yaml
build:
	context: ./dir
```

### dockerfile

使用dockerfile文件来构建，必须指定构建路径

```yaml
build:
context: .
	dockerfile: Dockerfile-alternate
```

### volumes

挂载一个目录或者一个已存在的数据卷容器，可以直接使用\[HOST:CONTAINER\]格式，或者使用\[HOST:CONTAINER:ro\]格式，后者对于容器来说，数据卷是只读的，可以有效保护宿主机的文件系统。Compose的数据卷指定路径可以是相对路径，使用.或者…来指定相对目录。

数据卷的格式可以是下面多种形式

```yaml
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

```yaml
volume_driver: mydriver
```

### volumes_from

从另一个服务或容器挂载其数据卷：

```yaml
volumes_from:
   - service_name   
     - container_name
```

### ports

ports用于映射端口的标签。

使用HOST:CONTAINER格式或者只是指定容器的端口，宿主机会随机映射端口。

```yaml
ports:
 - "3000"
 - "8000:8000"
 - "49100:22"
 - "127.0.0.1:8001:8001"
```

当使用HOST:CONTAINER格式来映射端口时，如果使用的容器端口小于60可能会得到错误得结果，因为YAML将会解析xx:yy这种数字格式为60进制。所以建议采用字符串格式。

### command

使用command可以覆盖容器启动后默认执行的命令。

```yaml
command: bundle exec thin -p 3000
```

### container_name

Compose的容器名称格式是：<项目名称><服务名称><序号>

可以自定义项目名称、服务名称，但如果想完全控制容器的命名，可以使用标签指定：

```yaml
container_name: app
```

### depends_on

在使用Compose时，最大的好处就是少打启动命令，但一般项目容器启动的顺序是有要求的，如果直接从上到下启动容器，必然会因为容器依赖问题而启动失败。例如在没启动数据库容器的时候启动应用容器，应用容器会因为找不到数据库而退出。depends\_on标签用于解决容器的依赖、启动先后的问题：

```yaml
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

### deploy

部署相关的配置都在这个节点下，例：

```yaml
deploy:
  mode: replicated
  replicas: 2
  restart_policy:
    condition: on-failure
    max_attempts: 3
  update_config:
    delay: 5s
    order: start-first # 默认为 stop-first，推荐设置先启动新服务再终止旧的
  resources:
    limits:
      cpus: "0.50"
      memory: 1g
deploy:
  mode: global # 不推荐全局模式（仅个人意见）。
  placement:
    constraints: [node.role == manager]
```

### PID

```yaml
pid: "host"
```

将PID模式设置为主机PID模式，跟主机系统共享进程命名空间。容器使用pid标签将能够访问和操纵其他容器和宿主机的名称空间。

### extra_hosts

添加主机名的标签，会在/etc/hosts文件中添加一些记录。

```yaml
extra_hosts:
 - "somehost:162.242.195.82"
 - "otherhost:50.31.209.229"
```

启动后查看容器内部hosts：

```yaml
162.242.195.82  somehost
50.31.209.229   otherhost
```

### dns

自定义DNS服务器。可以是一个值，也可以是一个列表。

```yaml
dns：8.8.8.8
dns：
    - 8.8.8.8   
    - 9.9.9.9
```

### expose

暴露端口，但不映射到宿主机，只允许能被连接的服务访问。仅可以指定内部端口为参数，如下所示：

```yaml
expose:
    - "3000"
    - "8000"
```

### links

链接到其它服务中的容器。使用服务名称（同时作为别名），或者“服务名称:服务别名”

```yaml
links:
    - db
    - db:database
    - redis
```

### net

设置网络模式。

```yaml
net: "bridge"
net: "none"
net: "host"
```

### cap_add，cap_drop

添加或删除容器拥有的宿主机的内核功能。
详情参考 [capabilities](#capabilities)

```yaml
cap_add:
  - ALL # 开启全部权限

cap_drop:
  - SYS_PTRACE # 关闭 ptrace权限
```

### cgroup_parent

为容器指定父cgroup组，意味着将继承该组的资源限制。

```yaml
cgroup_parent: m-executor-abcd
```

### dns_search

自定义DNS搜索域。可以是单个值或列表。

```yaml
dns_search: example.com

dns_search:
  - dc1.example.com
  - dc2.example.com
```

### entrypoint

覆盖容器默认的 entrypoint。

```yaml
entrypoint: /code/entrypoint.sh
```

也可以是以下格式：

```yaml
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```

### env_file

从文件添加环境变量。可以是单个值或列表的多个值。

```yaml
env_file: .env
```

也可以是列表格式：

```yaml
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

### environment

添加环境变量。您可以使用数组或字典、任何布尔值，布尔值需要用引号引起来，以确保 YML 解析器不会将其转换为 True 或 False。

```yaml
environment:
  RACK_ENV: development
  SHOW: 'true'
```

### healthcheck

用于检测docker服务是否健康运行。

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"] # 设置检测程序
  interval: 1m30s # 设置检测间隔
  timeout: 10s # 设置检测超时时间
  retries: 3 # 设置重试次数
  start_period: 40s # 启动后，多少秒开始启动检测程序
```

### logging

服务的日志记录配置。

driver：指定服务容器的日志记录驱动程序，默认值为json-file。有以下三个选项

```yaml
driver: "json-file"
driver: "syslog"
driver: "none"
```

仅在json-file驱动程序下，可以使用以下参数，限制日志得数量和大小。

```yaml
logging:
  driver: json-file
  options:
    max-size: "200k" # 单个文件大小为200k
    max-file: "10" # 最多10个文件
```

当达到文件限制上限，会自动删除旧得文件。

syslog驱动程序下，可以使用syslog-address指定日志接收地址。

```yaml
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

### networks

配置容器连接的网络，引用顶级networks下的条目 。

```yaml
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

### restart

- no：是默认的重启策略，在任何情况下都不会重启容器。
- always：容器总是重新启动。
- on-failure：在容器非正常退出时（退出状态非0），才会重启容器。
- unless-stopped：在容器退出时总是重启容器，但是不考虑在Docker守护进程启动时就已经停止了的容器

```yaml
restart: "no"
restart: always
restart: on-failure
restart: unless-stopped
```

注：swarm集群模式，请改用restart\_policy。

### secrets

存储敏感数据，例如密码：

```yaml
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

### security_opt

修改容器默认的schema标签。

```yaml
security-opt：
  - label:user:USER   # 设置容器的用户标签
  - label:role:ROLE   # 设置容器的角色标签
  - label:type:TYPE   # 设置容器的安全策略标签
  - label:level:LEVEL  # 设置容器的安全等级标签
```

### stop_grace_period

指定在容器无法处理SIGTERM (或者任何 stop_signal 的信号)，等待多久后发送SIGKILL信号关闭容器。

```yaml
stop_grace_period: 1s # 等待 1 秒
stop_grace_period: 1m30s # 等待 1 分 30 秒 
```

默认的等待时间是10秒。

### stop_signal

设置停止容器的替代信号。默认情况下使用SIGTERM 。

以下示例，使用SIGUSR1替代信号SIGTERM来停止容器。

```yaml
stop_signal: SIGUSR1
```

### sysctls

设置容器中的内核参数，可以使用数组或字典格式。

```yaml
sysctls:
  net.core.somaxconn: 1024
  net.ipv4.tcp_syncookies: 0

sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0
```

### tmpfs

在容器内安装一个临时文件系统。可以是单个值或列表的多个值。

```yaml
tmpfs: /run

tmpfs:
  - /run
  - /tmp
```

### ulimits

覆盖容器默认的ulimit。

```yaml
ulimits:
  nproc: 65535
  nofile:
    soft: 20000
    hard: 40000
```

### devices

指定设备映射列表。

```yaml
devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"
```

### tty

为容器分配一个伪终端，就相当于 `docke run -t`, 就是把 `/bin/bash` 当做前台进程。

```yaml
tty: true
```

### capabilities

Capabilities的主要思想在于分割root用户的特权，即将root的特权分割成不同的能力，每种能力代表一定的特权操作。 例如：能力CAP_SYS_MODULE表示用户能够加载(或卸载)内核模块的特权操作，而CAP_SETUID表示用户能够修改进程用户身份的特权操作。在Capbilities中系统将根据进程拥有的能力来进行特权操作的访问控制。

```bash
CHOWN            # 修改文件属主的权限
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

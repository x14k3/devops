# ZooKeeper中bin目录4个脚本执行文件详解

　　ZooKeeper中bin目录中有如下4个可执行脚本：

```shell
[root@poc01 ~]# cd /opt/module/zookeeper-3.4.6/bin/
[root@poc01 bin]# ls
zkCleanup.sh  zkCli.sh  zkEnv.sh  zkServer.sh
```

　　这些脚本是 ZooKeeper 的一部分，用于管理和操作 ZooKeeper 实例。

1. zkCleanup.sh：

    * 用途：这个脚本主要用于清理 ZooKeeper 数据目录中的快照和事务日志文件，以便进行数据清理和维护。
    * 使用方法：通常在需要清理 ZooKeeper 数据目录时运行此脚本，它将删除旧的快照和日志文件，帮助释放磁盘空间和维护 ZooKeeper 数据。
2. zkCli.sh：

    * 用途：zkCli.sh 是 ZooKeeper 自带的客户端命令行工具，用于连接到 ZooKeeper 实例并执行各种操作，比如创建节点、读取节点数据、监控节点变化等。
    * 使用方法：运行 zkCli.sh 脚本，指定连接参数（例如 ZooKeeper 实例的地址），然后在命令行界面中输入各种 ZooKeeper 客户端命令来与 ZooKeeper 交互。
3. zkEnv.sh：

    * 用途：zkEnv.sh 脚本用于设置 ZooKeeper 的环境变量和配置，它可以设置 Java 环境、内存配置、JVM 参数等环境变量。
    * 使用方法：通常在启动 ZooKeeper 实例之前，可以使用 zkEnv.sh 来设置 ZooKeeper 运行时的环境参数和配置。
4. zkServer.sh：

    * 用途：zkServer.sh 脚本用于启动、停止和管理 ZooKeeper 服务实例。
    * 使用方法：通过运行 zkServer.sh 脚本并指定启动、停止等参数，可以对 ZooKeeper 服务进行管理。例如，`zkServer.sh start`​ 用于启动 ZooKeeper 服务，`zkServer.sh stop`​ 用于停止服务。

　　下文将逐个详细介绍4个 ZooKeeper 相关脚本的使用、参数、场景和注意事项

### 1\. zkCli.sh

#### 1-1. zkCli-使用示例

* 连接到 ZooKeeper：`./zkCli.sh -server localhost:2181`​
* 创建节点：`create /path value`​
* 读取节点数据：`get /path`​
* 参数介绍：`zkCli.sh`​ 接受连接参数，如 ZooKeeper 服务器地址。
* 场景：用于与 ZooKeeper 交互、创建、读取、更新、删除节点等。

　　​`zkCli.sh`​ 脚本是 ZooKeeper 提供的命令行客户端工具，用于连接到 ZooKeeper 服务器并执行相关操作。它允许用户交互式地操作 ZooKeeper 数据，例如创建节点、设置节点数据、获取节点信息等。以下是关于 `zkCli.sh`​ 脚本的使用方法和一些常用命令示例：

#### 1-2. zkCli-连接方式

```bash
zkCli.sh -server server:port 
# 例如：zkCli.sh -server 192.168.22.22:2181
```

> ​`-server server:port`​：指定连接的 ZooKeeper 服务器地址和端口号，默认端口是 2181。

#### 1-3. zkCli-基础常用命令

```bash
# 创建节点
create /path "data"

# 获取节点数据
get /path

# 设置更新节点数据
set /path "new data"

# 列出节点信息
ls /path

# 删除节点
delete /path

# 查看帮助
help
```

#### 1-4. zkCli-注意事项

* 连接成功后，会进入交互式命令行模式，可以直接输入命令执行操作。
* 退出交互可以通过 `quit`​ 或者 `Ctrl + C`​ 退出 `zkCli`​ 客户端。
* 在执行删除节点等涉及数据变更的操作时，请谨慎操作，数据删除不可逆。
* 使用 `zkCli.sh`​ 可以方便地连接到 ZooKeeper 服务器进行数据操作和管理，但在进行重要操作时请务必小心谨慎，以免意外删除数据或影响 ZooKeeper 的稳定运行。

#### 1-5. zkCli-高级使用方法

　　​`zkCli.sh`​ 是 ZooKeeper 提供的基本命令行客户端工具，用于与 ZooKeeper 服务器交互执行各种操作。虽然它是一个命令行工具，但仍然提供了一些较为复杂和高级的功能，可以用于节点监控、权限管理、Watcher 监听等。

* **监控节点状态变化**

  使用 `stat`​ 命令可以监控节点状态的变化，实时查看节点的详细信息，例如版本、数据长度、创建时间等：

  ```bash
  [zk: poc01:2181(CONNECTED) 22] stat /data
  cZxid = 0x200000006
  ctime = Tue Dec 12 10:39:20 CST 2023
  mZxid = 0x20000000a
  mtime = Tue Dec 12 10:39:41 CST 2023
  pZxid = 0x200000006
  cversion = 0
  dataVersion = 4
  aclVersion = 0
  ephemeralOwner = 0x0
  dataLength = 4
  numChildren = 0

  ```

- 设置 Watcher使用

  1. 在对节点进行操作时，可以设置 Watcher，以便在节点状态发生变化时得到通知。
  2. 当节点的状态发生变化时，比如节点被创建、被删除、数据被修改等情况，Watcher 就会被触发
  3. 一旦 Watcher 被触发，客户端可以在收到通知后执行相应的逻辑处理，比如重新获取节点数据、更新缓存等

      窗口1中操作：

      ```bash
      # 第一个窗口中创建节点
      [zk: poc01:2181(CONNECTED) 2] create /example_node "initial_data"
      Created /example_node
      # 使用watch方式进行通知监控
      [zk: poc01:2181(CONNECTED) 3] get /example_node watch
      "initial_data"
      cZxid = 0x20000000f
      ctime = Tue Dec 12 14:38:56 CST 2023
      mZxid = 0x20000000f
      mtime = Tue Dec 12 14:38:56 CST 2023
      pZxid = 0x20000000f
      cversion = 0
      dataVersion = 0
      aclVersion = 0
      ephemeralOwner = 0x0
      dataLength = 14
      numChildren = 0
      ```

      窗口2中操作：

      ```shell
      # 在新的窗口中去更新节点数据
      [zk: poc01:2181(CONNECTED) 27] set /example_node "new_data"
      cZxid = 0x20000000f
      ctime = Tue Dec 12 14:38:56 CST 2023
      mZxid = 0x200000010
      mtime = Tue Dec 12 14:39:27 CST 2023
      pZxid = 0x20000000f
      cversion = 0
      dataVersion = 1
      aclVersion = 0
      ephemeralOwner = 0x0
      dataLength = 10
      numChildren = 0
      ```

      回到窗口1中观察是否有监控信息通知

      ```shell
      # 此时发现窗口1中的watch监控生效，提示有状态变化的消息
      [zk: poc01:2181(CONNECTED) 4] 
      WATCHER::
      WatchedEvent state:SyncConnected type:NodeDataChanged path:/example_node
      ```

      注意事项：

      1. 一次性触发： Watcher 是一次性的，一旦触发，就会失效。需要在处理完 Watcher 事件后重新设置 Watcher。
      2. 事件通知顺序： Watcher 不保证事件通知的严格顺序，只能保证 FIFO（先进先出）的顺序。
      3. Watch 太多： 如果客户端设置了大量的 Watcher，可能会增加服务器端的负载。合理使用 Watcher 非常重要。

* **ZooKeeper 权限管理**

  ZooKeeper 支持 ACL（访问控制列表）来管理节点的权限，可以使用 `addauth`​ 和 `setAcl`​ 命令来添加认证信息和设置节点权限

  ​`addauth`​ 用于在会话中添加认证信息，而 `setAcl`​ 则用于设置节点的 ACL，以便控制节点的访问权限。在实际使用中，需要根据具体情况选择合适的认证方式和权限设置
* ​`addauth`​ 命令用于在 ZooKeeper 中添加认证信息

  ```shell
  # 格式
  addauth scheme auth
  # 示例
  addauth digest wangting:123456
  ```

  * ​`scheme`​：认证方案，例如 `digest`​、`ip`​ 等
  * ​`auth`​：认证信息，根据认证方案不同可以是用户名和密码或者 IP 地址等
  * 使用 `addauth`​ 命令添加的认证信息是针对当前会话有效的，且在会话结束后自动失效，因此不需要专门的命令来删除这些信息。

    一旦会话结束（例如客户端断开连接），`addauth`​ 命令添加的认证信息也随之失效，不再生效。如果需要重新认证，可以在新的会话中再次使用 `addauth`​ 命令添加认证信息。
* `setAcl`​ 命令则用于设置节点的访问控制列表（ACL）

  ```shell
  # 格式
  setAcl /path acl
  # 示例
  create /example_node "data" # 创建节点
  setAcl /example_node digest:wangting:123456:crwda
  ```

  * ​`/path`​：要设置 ACL 的节点路径。
  * ​`acl`​：ACL 信息，包括权限和认证信息。
  * 如果设置了 ACL 的节点不再需要，可以直接删除节点，节点删除后 ACL 设置也会一并删除：`delete /example_node`​
  * 通过重新设置节点的 ACL，可以改变节点的权限设置。可以使用 `setAcl`​ 命令修改节点的 ACL：`setAcl /example_node acl`​
  * ​`crwda`​ 权限（`create`​、`read`​、`update`​、`delete`​）
  * ZooKeeper 的 ACL 权限管理较为复杂，需要小心谨慎操作，以免影响节点的访问权限

　　‍

### 2\. zkServer.sh

#### 2-1. zkServer-使用示例

* 启动 ZooKeeper：`./zkServer.sh start`​
* 停止 ZooKeeper：`./zkServer.sh stop`​
* 参数介绍：接受启动、停止等命令。
* 场景：用于管理 ZooKeeper 服务的启动和停止。

　　​`zkServer.sh`​ 脚本是 ZooKeeper 提供的用于启动、停止和管理 ZooKeeper 服务器的脚本。它提供了一系列的命令用于管理 ZooKeeper 服务器的运行状态，例如启动、停止、重启等。

#### 2-2. zkServer-使用方法

```bash
zkServer.sh {start|stop|restart|status|upgrade|print-cmd}

```

　　参数说明：

* ​`start`​：启动 ZooKeeper 服务器。`zkServer.sh start`​
* ​`stop`​：停止 ZooKeeper 服务器。`zkServer.sh stop`​
* ​`restart`​：重启 ZooKeeper 服务器。`zkServer.sh restart`​
* ​`status`​：查看 ZooKeeper 服务器的运行状态。`zkServer.sh status`​
* ​`upgrade`​：升级 ZooKeeper 服务器。
* ​`print-cmd`​：打印 ZooKeeper 服务器的命令。

#### 2-3. zkServer-注意事项

* 在执行这些命令时，需要在命令前加上 `zkServer.sh`​ 并在后面指定具体的操作。
* 在执行 ZooKeeper 相关操作前，请确保已经配置了正确的环境变量，例如使用了 `zkEnv.sh`​ 脚本设置了环境。
* 对于 `start`​、`stop`​、`restart`​ 操作，可能需要具有相应的权限才能执行。

　　使用 `zkServer.sh`​ 脚本可以方便地管理 ZooKeeper 服务器的启动、停止和重启，同时也可以通过 `status`​ 命令查看 ZooKeeper 服务器的运行状态，以确保服务正常运行。

　　​`zkServer.sh`​ 脚本是 ZooKeeper 提供的用于管理 ZooKeeper 服务器的脚本，包括启动、停止、重启和状态查询等功能。虽然这个脚本本身功能较为基础，但可以结合其他高级用法来提高 ZooKeeper 的运维效率和管理。

#### 2-4. zkServer-高级使用方法

* 使用 JMX 监控

  启动 ZooKeeper 时，可以配置 JMX 监控参数，以便通过 JMX 管理和监控 ZooKeeper 服务器的运行状态

  ```bash
  ./zkServer.sh start -jvmflags "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1234 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
  ```

* 同主机多实例部署

  通过复制 [ZooKeeper 安装](https://so.csdn.net/so/search?q=ZooKeeper%20%E5%AE%89%E8%A3%85&spm=1001.2101.3001.7020)目录，配置不同的数据目录和端口号，可以启动多个 ZooKeeper 实例来提高系统的可用性和扩展性

  ```bash
  ./zkServer.sh start /path/to/zkConfig1
  ./zkServer.sh start /path/to/zkConfig2
  ./zkServer.sh start /path/to/zkConfig3
  ```

* 定制日志和输出

  配置 ZooKeeper 的日志级别和输出路径，以便更好地监控和调试 ZooKeeper 的运行状态

  ```bash
  ./zkServer.sh start 2>&1 > /path/to/zk.log &
  ```

* 使用 systemd 或其他工具进行管理

  将 ZooKeeper 的启动、停止等命令结合 systemd进程管理工具进行管理，以便更好地监控和管理 ZooKeeper 服务。

  ```bash
  # 服务启停则可以用如下方式 
  systemctl start zookeeper 
  systemctl stop zookeeper
  ```

　　实现方法：

　　在 `/lib/systemd/system/`​ 目录下创建 `zookeeper.service`​文件

```shell
[root@poc01 bin]# vim /lib/systemd/system/zookeeper.service
[Unit]
Description=Apache ZooKeeper Distributed Coordination Service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/opt/module/zookeeper-3.4.6
ExecStart=/opt/module/zookeeper-3.4.6/bin/zkServer.sh start
ExecStop=/opt/module/zookeeper-3.4.6/bin/zkServer.sh stop
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# 重新加载配置信息
[root@poc01 ~]# systemctl daemon-reload

# 启动服务
[root@poc01 ~]# systemctl start zookeeper
# 查看状态
[root@poc01 ~]# systemctl status zookeeper

# 添加至开机自启
[root@poc01 ~]# systemctl enable zookeeper.service
# 关闭开机自启
[root@poc01 ~]# systemctl disable zookeeper.service
```

> 注意修改对应路径

### 3\. zkEnv.sh

#### 3-1. zkEnv-使用示例

* ​`source zkEnv.sh`​，加载配置到当前 Shell 环境
* 参数介绍：该脚本通常不需要额外参数
* 场景：在启动 ZooKeeper 实例之前，可以设置 Java 环境、内存配置、JVM 参数等

#### 3-2. zkEnv-使用方式

　　​`source zkEnv.sh`​

```bash
[root@poc01 ~]# source /opt/module/zookeeper-3.4.6/bin/zkEnv.sh 
```

* 设置 ZooKeeper 的运行环境，包括 JAVA\_HOME、ZooKeeper 的安装路径等
* 配置 ZooKeeper 的一些基本参数，例如内存大小、日志文件路径等

#### 3-3. zkEnv-注意事项

* 在运行 ZooKeeper 相关命令之前，默认会执行 `source zkEnv.sh`​ 以配置环境变量，确保 ZooKeeper 能够正确运行。

　　在zkServer.sh中可以看到如下代码：

```shell
if [ -e "$ZOOBIN/../libexec/zkEnv.sh" ]; then
  . "$ZOOBINDIR/../libexec/zkEnv.sh"
else
  . "$ZOOBINDIR/zkEnv.sh"
fi
```

　　​`zkEnv.sh`​ 脚本主要用于配置 ZooKeeper 运行时的环境变量，确保 ZooKeeper 的运行所需的环境设置正确，进而保证 ZooKeeper 服务的正常运行。

#### 3-4. zkEnv-高级使用方法

* 配置 JVM 参数

　　通过 `zkEnv.sh`​ 设置 JVM 相关的参数，比如内存大小、GC 策略等，可以提高 ZooKeeper 的性能和稳定性。

```bash
export SERVER_JVMFLAGS="-Xmx2G -XX:+UseG1GC"
```

* 定制 ZooKeeper 日志

　　设置 ZooKeeper 的日志级别、输出路径等，以便更好地监控和调试 ZooKeeper 的运行状态。

```bash
export ZOO_LOG4J_PROP="INFO,ROLLINGFILE" 
export ZOO_LOG_DIR="/path/to/zookeeper/logs"
```

* 设置认证信息

　　对于需要安全认证的情况，可以配置 ZooKeeper 的认证信息，使用用户名和密码进行访问控制。

```bash
export ZOOKEEPER_SERVER_OPTS="$ZOOKEEPER_SERVER_OPTS -Dzookeeper.DigestAuthenticationProvider.superDigest=super:user:password"
```

* 配置网络参数

　　调整网络相关的参数，例如端口号、连接超时等，以适应特定的网络环境。

```bash
export ZOOKEEPER_CLIENT_PORT=2181 
export ZOOKEEPER_TICK_TIME=2000
```

### 4\. zkCleanup.sh

#### 4-1. zkCleanup-使用示例

* ​`./zkCleanup.sh /path/to/zookeeper/data/version-2 -n 5`​，这将保留最近 5 个快照和事务日志文件。
* 参数介绍：`zkCleanup.sh`​ 接受数据目录路径和要保留的文件数作为参数。
* 场景：当 ZooKeeper 数据目录中的日志文件和快照文件太多时，用于清理旧文件，释放磁盘空间。

　　​`zkCleanup.sh`​ 脚本主要用于清理 ZooKeeper 数据目录中的快照（snapshot）和事务日志（transaction logs），以减少磁盘占用并保持 ZooKeeper 数据的健康状态。这个脚本允许你限制保留的快照和事务日志的数量，以及清理指定路径下的数据。该脚本一般用于维护 ZooKeeper 的数据目录，清除旧的数据文件，防止数据过于庞大影响性能。

#### 4-2. zkCleanup-使用方式

```bash
zkCleanup.sh [dataDir] [-n count] [-d days] [-t hours] [-r] [-h]
```

* ​`dataDir`​：ZooKeeper 数据目录的路径，默认情况下是 `./data`​。
* ​`-n count`​：保留的快照和日志文件的数量，默认是 3。
* ​`-d days`​：删除超过指定天数的快照和日志文件。
* ​`-t hours`​：删除超过指定小时数的快照和日志文件。
* ​`-r`​：指定后会递归删除指定目录下的数据。
* ​`-h`​：显示帮助信息。

```shell
# 默认情况下保留 3 个快照和日志文件
zkCleanup.sh /path/to/zookeeper/data

# 保留 2 个快照和日志文件，删除超过 5 天的数据文件
zkCleanup.sh /path/to/zookeeper/data -n 2 -d 5

# 删除超过 12 小时的数据文件
zkCleanup.sh /path/to/zookeeper/data -t 12

# 递归删除指定目录下的数据
zkCleanup.sh /path/to/zookeeper/data -r
```

#### 4-3. zkCleanup-注意事项

* 在运行 `zkCleanup.sh`​ 脚本时，请确保 ZooKeeper 服务已经停止，以免影响 ZooKeeper 的正常运行
* 脚本会删除过期的快照和事务日志文件，确保在清理之前备份重要数据。
* 对于 `-d`​ 和 `-t`​ 参数，如果同时指定，会同时按照天数和小时数进行清理。
* 可以结合操作系统的定时任务或者其他脚本，定期执行 `zkCleanup.sh`​ 脚本来自动清理 ZooKeeper 的数据文件，以便保持 ZooKeeper 数据目录的健康状态

#### 4-4. zkCleanup-使用示例

```shell
# 停止 ZooKeeper 服务
[root@poc01 ~]# zkServer.sh stop
[root@poc02 ~]# zkServer.sh stop
[root@poc03 ~]# zkServer.sh stop

# 找到 ZooKeeper 的数据目录，其中包括事务日志文件（version-2 目录下的文件）和快照文件
[root@poc01 ~]# ll /opt/module/zookeeper-3.4.6/zkData/version-2/
total 68
-rw-r--r-- 1 root root        1 Dec 12 16:56 acceptedEpoch
-rw-r--r-- 1 root root        1 Dec 12 16:56 currentEpoch
-rw-r--r-- 1 root root 67108880 Dec 12 10:24 log.100000001
-rw-r--r-- 1 root root 67108880 Dec 12 15:56 log.200000001
-rw-r--r-- 1 root root 67108880 Dec 12 16:49 log.200000026
-rw-r--r-- 1 root root 67108880 Dec 12 16:55 log.300000001
-rw-r--r-- 1 root root 67108880 Dec 12 16:56 log.400000001
-rw-r--r-- 1 root root      296 Dec 11 17:25 snapshot.0
-rw-r--r-- 1 root root      788 Dec 12 10:31 snapshot.100000006
-rw-r--r-- 1 root root     1425 Dec 12 16:43 snapshot.200000025
-rw-r--r-- 1 root root     1895 Dec 12 16:50 snapshot.20000002e
-rw-r--r-- 1 root root     1895 Dec 12 16:56 snapshot.300000002

# 清理操作
[root@poc01 ~]# zkCleanup.sh /opt/module/zookeeper-3.4.6/zkData/version-2 -n 3
[root@poc02 ~]# zkCleanup.sh /opt/module/zookeeper-3.4.6/zkData/version-2 -n 3
[root@poc03 ~]# zkCleanup.sh /opt/module/zookeeper-3.4.6/zkData/version-2 -n 3

# 启动 ZooKeeper 服务
[root@poc01 ~]# zkServer.sh start
[root@poc02 ~]# zkServer.sh start
[root@poc03 ~]# zkServer.sh start
```

### 前言

历史上，Linux 的启动一直采用init进程。 Systemd 设计目标是，为系统的启动和管理提供一套完整的解决方案。

Systemd 是一系列工具的集合，其作用也远远不仅是启动操作系统，它还接管了后台服务、结束、状态查询，以及日志归档、设备管理、电源管理、定时任务等许多职责，并支持通过特定事件（如插入特定 USB 设备）和特定端口数据触发的 On-demand（按需）任务。

Systemd 的后台服务还有一个特殊的身份——它是系统中 PID 值为 1 的进程。

### 特点

- 更少的进程
    Systemd 提供了 服务按需启动 的能力，使得特定的服务只有在真定被请求时才启动。
    
- 允许更多的进程并行启动
    在 SysV-init 时代，将每个服务项目编号依次执行启动脚本。Ubuntu 的 Upstart 解决了没有直接依赖的启动之间的并行启动。而 Systemd 通过 Socket 缓存、DBus 缓存和建立临时挂载点等方法进一步解决了启动进程之间的依赖，做到了所有系统服务并发启动。对于用户自定义的服务，Systemd 允许配置其启动依赖项目，从而确保服务按必要的顺序运行。
    
- 使用 CGroup 跟踪和管理进程的生命周期
    在 Systemd 之间的主流应用管理服务都是使用 进程树 来跟踪应用的继承关系的，而进程的父子关系很容易通过 两次 fork 的方法脱离。
    而 Systemd 则提供通过 CGroup 跟踪进程关系，引补了这个缺漏。通过 CGroup 不仅能够实现服务之间访问隔离，限制特定应用程序对系统资源的访问配额，还能更精确地管理服务的生命周期。
    
- 统一管理服务日志
    Systemd 是一系列工具的集合， 包括了一个专用的系统日志管理服务：Journald。这个服务的设计初衷是克服现有 Syslog 服务的日志内容易伪造和日志格式不统一等缺点，Journald 用 二进制格式 保存所有的日志信息，因而日志内容很难被手工伪造。Journald 还提供了一个 journalctl 命令来查看日志信息，这样就使得不同服务输出的日志具有相同的排版格式， 便于数据的二次处理。
    

### Unit 和 Target

Unit 是 Systemd 管理系统资源的基本单元，可以认为每个系统资源就是一个 Unit，并使用一个 Unit 文件定义。在 Unit 文件中需要包含相应服务的描述、属性以及需要运行的命令。

Target 是 Systemd 中用于指定系统资源启动组的方式，相当于 SysV-init 中的运行级别。

简单说，Target 就是一个 Unit 组，包含许多相关的 Unit 。启动某个 Target 的时候，Systemd 就会启动里面所有的 Unit。从这个意义上说，Target 这个概念类似于”状态点”，启动某个 Target 就好比启动到某种状态。

### Systemd 目录

Unit 文件按照 Systemd 约定，应该被放置指定的三个系统目录之一中。这三个目录是有优先级的，如下所示，越靠上的优先级越高。因此，在三个目录中有同名文件的时候，只有优先级最高的目录里的那个文件会被使用。

- /etc/systemd/system：系统或用户自定义的配置文件
- /run/systemd/system：软件运行时生成的配置文件
- /usr/lib/systemd/system：系统或第三方软件安装时添加的配置文件。

Systemd 默认从目录 /etc/systemd/system/ 读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录 /usr/lib/systemd/system/，真正的配置文件存放在那个目录。

# Unit

Systemd 可以管理所有系统资源：将系统资源划分为12类。将每个系统资源称为一个 Unit。

Unit 是 Systemd 管理系统资源的基本单位。使用一个 Unit File 作为 Unit 的单元文件，Systemd 通过单元文件控制 Unit 的启动。

例如，MySQL服务被 Systemd 视为一个 Unit，使用一个 mysql.service 作为启动配置文件

### Unit File

Systemd 将系统资源划分为12类，对应12种类型的单元文件

|系统资源类型|单元文件扩展名|单元文件描述|备注|
|---|---|---|---|
|Service|.service|封装守护进程的启动、停止、重启和重载操作，是最常见的一种 Unit 文件|系统服务|
|Target|.target|定义 target 信息及依赖关系，一般仅包含 Unit 段|多个 Unit 构成的一个组|
|Device|.device|对于 `/dev` 目录下的硬件设备，主要用于定义设备之间的依赖关系|硬件设备|
|Mount|.mount|定义文件系统的挂载点，可以替代过去的 `/etc/fstab` 配置文件|文件系统的挂载点|
|Automount|.automount|用于控制自动挂载文件系统，相当于 SysV-init 的 autofs 服务|自动挂载点|
|Path|.path|用于监控指定目录或文件的变化，并触发其它 Unit 运行|文件或路径|
|Scope|.scope|这种 Unit 文件不是用户创建的，而是 Systemd 运行时产生的，描述一些系统服务的分组信息|不是由 Systemd 启动的外部进程|
|Slice|.slice|用于表示一个 CGroup 的树|进程组|
|Snapshot|.snapshot|用于表示一个由 systemctl snapshot 命令创建的 Systemd Units 运行状态快照，可以切回某个快照|Systemd 快照，可以切回某个快照|
|Socket|.socket|监控来自于系统或网络的数据消息|进程间通信的 socket|
|Swap|.swap|定义一个用户做虚拟内存的交换分区|swap 文件|
|Timer|.timer|用于配置在特定时间触发的任务，替代了 Crontab 的功能|定时器|

对于操作单元文件的命令，如果缺省扩展名，则默认`.service`扩展名

### 语法

先看一个示例
```bash
[Unit]  
Description=Hello World  
After=docker.service  
Requires=docker.service  
[Service]  
TimeoutStartSec=0  
ExecStartPre=-/usr/bin/docker kill busybox1  
ExecStartPre=-/usr/bin/docker rm busybox1  
ExecStartPre=/usr/bin/docker pull busybox  
ExecStart=/usr/bin/docker run --name busybox1 busybox /bin/ sh -c "while true; do echo Hello World; sleep 1; done"  
ExecStop="/usr/bin/docker stop busybox1"  
ExecStopPost="/usr/bin/docker rm busybox1"  
[Install]  
WantedBy=multi-user.target
```

Unit 文件可以分为三个配置区段：
- Unit 段：所有 Unit 文件通用，用来定义 Unit 的元数据，以及配置与其他 Unit 的关系
- Service 段：服务（Service）类型的 Unit 文件（后缀为 .service）特有的，用于定义服务的具体管理和执行动作
- Install 段：所有 Unit 文件通用，用来定义如何启动，以及是否开机启动

Unit 和 Install 段：所有 Unit 文件通用，用于配置服务（或其它系统资源）的描述、依赖和随系统启动的方式
Service 段：服务（Service）类型的 Unit 文件（后缀为 .service）特有的，用于定义服务的具体管理和操作方法

单元文件中的区段名和字段名大小写敏感, 每个区段内都是一些等号连接的键值对（键值对的等号两侧不能有空格）

### Unit 段

Unit 通常是配置文件的第一个区块，用来定义 Unit 的元数据，以及配置与其他 Unit 的关系。

- `Description`：当前服务的简单描述
- `Documentation`：文档地址，可以是一个或多个文档的 URL 路径
- `Requires`：与其它 Unit 的强依赖关系，如果其中任意一个 Unit 启动失败或异常退出，当前 Unit 也会被退出
- `Wants`：与其它 Unit 的弱依赖关系，如果其中任意一个 Unit 启动失败或异常退出，不影响当前 Unit 继续执行
- `After`：该字段指定的 Unit 全部启动完成以后，才会启动当前 Unit
- `Before`：该字段指定的 Unit 必须在当前 Unit 启动完成之后再启动
- `Binds To`：与 Requires 相似，该字段指定的 Unit 如果退出，会导致当前 Unit 停止运行
- `Part Of`：一个 Bind To 作用的子集，仅在列出的 Unit 失败或重启时，终止或重启当前 Unit，而不会随列出Unit 的启动而启动
- `OnFailure`：当这个模板启动失败时，就会自动启动列出的每个模块
- `Conflicts`：与这个模块有冲突的模块，如果列出的模块中有已经在运行的，这个服务就不能启动，反之亦然

### Install段

Install通常是配置文件的最后一个区块，用来定义如何启动，以及是否开机启动。

- `WantedBy`：它的值是一个或多个 target，执行enable命令时，符号链接会放入`/etc/systemd/system`目录下以 target 名 + `.wants`后缀构成的子目录中
- `RequiredBy`：它的值是一个或多个 target，执行enable命令时，符号链接会放入`/etc/systemd/system`目录下以 target 名 + `.required`后缀构成的子目录中
- `Alias`：当前 Unit 可用于启动的别名
- `Also`：当前 Unit 被 enable/disable 时，会被同时操作的其他 Unit

### Service段

Service 用来 Service 的配置，只有 Service 类型的 Unit 才有这个区块。
##### 启动类型

- Type：定义启动时的进程行为。它有以下几种值。
    
    **Type=simple**：默认值，ExecStart字段启动的进程为主进程  
    服务进程不会 fork，如果该服务要启动其他服务，不要使用此类型启动，除非该服务是 socket 激活型
    
    **Type=forking**：ExecStart字段将以fork()方式从父进程创建子进程启动，创建后父进程会立即退出，子进程成为主进程。  
    通常需要指定PIDFile字段，以便 Systemd 能够跟踪服务的主进程
    
    对于常规的守护进程（daemon），除非你确定此启动方式无法满足需求，使用此类型启动即可
    
    **Type=oneshot**：只执行一次，Systemd 会等当前服务退出，再继续往下执行, 适用于只执行一项任务、随后立即退出的服务  
    通常需要指定RemainAfterExit=yes字段，使得 Systemd 在服务进程退出之后仍然认为服务处于激活状态
    
    **Type=dbus**：当前服务通过 D-Bus 信号启动。当指定的 BusName 出现在 DBus 系统总线上时，Systemd认为服务就绪
    
    **Type=notify**：当前服务启动完毕会发出通知信号，通知 Systemd，然后 Systemd 再启动其他服务
    
    **Type=idle**：Systemd 会等到其他任务都执行完，才会启动该服务。一种使用场合是：让该服务的输出，不与其他服务的输出相混合
    

##### 启动行为

- `ExecStart`：启动当前服务的命令
    ```bash
    ExecStart=/bin/echo execstart1  
	ExecStart=  
	ExecStart=/bin/echo execstart2
```
    顺序执行设定的命令，把字段置空，表示清除之前的值
- `ExecStartPre`：启动当前服务之前执行的命令
- `ExecStartPost`：启动当前服务之后执行的命令
- `ExecReload`：重启当前服务时执行的命令
- `ExecStop`：停止当前服务时执行的命令
- `ExecStopPost`：停止当前服务之后执行的命令
- `RemainAfterExit`：当前服务的所有进程都退出的时候，Systemd 仍认为该服务是激活状态, 这个配置主要是提供给一些并非常驻内存，而是启动注册后立即退出，然后等待消息按需启动的特殊类型服务使用的
- `TimeoutSec`：定义 Systemd 停止当前服务之前等待的秒数

##### 重启行为

- `RestartSec`：Systemd 重启当前服务间隔的秒数
- `KillMode`：定义 Systemd 如何停止服务，可能的值包括：  
    control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉  
    process：只杀主进程（sshd 服务，推荐值）  
    mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号  
    none：没有进程会被杀掉，只是执行服务的 stop 命令。
- `Restart`：定义何种情况 Systemd 会自动重启当前服务，可能的值包括：  
    no（默认值）：退出后不会重启  
    on-success：只有正常退出时（退出状态码为0），才会重启  
    on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启（守护进程，推荐值）  
    on-abnormal：只有被信号终止和超时，才会重启（对于允许发生错误退出的服务，推荐值）  
    on-abort：只有在收到没有捕捉到的信号终止时，才会重启  
    on-watchdog：超时退出，才会重启  
    always：不管是什么退出原因，总是重启


##### 上下文

- `PIDFile`：指向当前服务 PID file 的绝对路径。
- `User`：指定运行服务的用户
- `Group`：指定运行服务的用户组
- `EnvironmentFile`：指定当前服务的环境参数文件。该文件内部的`key=value`键值对，可以用`$key`的形式，在当前配置文件中获取
    启动`sshd`，执行的命令是`/usr/sbin/sshd -D $OPTIONS`，其中的变量`$OPTIONS`就来自`EnvironmentFile`字段指定的环境参数文件。

### 占位符

在 Unit 文件中，有时会需要使用到一些与运行环境有关的信息，例如节点 ID、运行服务的用户等。这些信息可以使用占位符来表示，然后在实际运行中动态地替换为实际的值。

- %n：完整的 Unit 文件名字，包括 .service 后缀名
- %p：Unit 模板文件名中 @ 符号之前的部分，不包括 @ 符号
- %i：Unit 模板文件名中 @ 符号之后的部分，不包括 @ 符号和 .service 后缀名
- %t：存放系统运行文件的目录，通常是 “run”
- %u：运行服务的用户，如果 Unit 文件中没有指定，则默认为 root
- %U：运行服务的用户 ID
- %h：运行服务的用户 Home 目录，即 %{HOME} 环境变量的值
- %s：运行服务的用户默认 Shell 类型，即 %{SHELL} 环境变量的值
- %m：实际运行节点的 Machine ID，对于运行位置每个的服务比较有用
- %b：Boot ID，这是一个随机数，每个节点各不相同，并且每次节点重启时都会改变
- %H：实际运行节点的主机名
- %v：内核版本，即 “uname -r” 命令输出的内容
- %\%：在 Unit 模板文件中表示一个普通的百分号

### 模板

在现实中，往往有一些应用需要被复制多份运行，就会用到模板文件

模板文件的写法与普通单元文件基本相同，只是模板文件名是以 @ 符号结尾。例如：apache@.service

通过模板文件启动服务实例时，需要在其文件名的 @ 字符后面附加一个用于区分服务实例的参数字符串，通常这个参数是用于监控的端口号或控制台 TTY 编译号
```bash
systemctl start apache@8080.service
```
Systemd 在运行服务时，首先寻找跟单元名完全匹配的单元文件，如果没有找到，才会尝试选择匹配模板

例如上面的命令，System 首先会在约定的目录下寻找名为 [apache@8080.service](mailto:apache@8080.service) 的单元文件，如果没有找到，而文件名中包含 @ 字符，它就会尝试去掉后缀参数匹配模板文件。对于 [apache@8080.service](mailto:apache@8080.service)，Systemd 会找到 apache@.service 模板文件，并通过这个模板文件将服务实例化。

# Target

Target 就是一个 Unit 组，包含许多相关的 Unit 。启动某个 Target 的时候，Systemd 就会启动里面所有的 Unit。从这个意义上说，Target 这个概念类似于”状态点”，启动某个 Target 就好比启动到某种状态。

在传统的 SysV-init 启动模式里面，有 RunLevel 的概念，跟 Target 的作用很类似。不同的是，RunLevel 是互斥的，不可能多个 RunLevel 同时启动，但是多个 Target 可以同时启动。

### target vs sysv-init

- 默认的 RunLevel（在 /etc/inittab 文件设置）现在被默认的 Target 取代，位置是 /etc/systemd/system/default.target，通常符号链接到graphical.target（图形界面）或者multi-user.target（多用户命令行）。
- 启动脚本的位置，以前是 /etc/init.d 目录，符号链接到不同的 RunLevel 目录 （比如 /etc/rc3.d、/etc/rc5.d 等），现在则存放在 /lib/systemd/system 和 /etc/systemd/system 目录。
- 配置文件的位置，以前 init 进程的配置文件是 /etc/inittab，各种服务的配置文件存放在 /etc/sysconfig 目录。现在的配置文件主要存放在 /lib/systemd 目录，在 /etc/systemd 目录里面的修改可以覆盖原始设置。

runlevel是 SysV init 初始化系统中的概念，在Systemd初始化系统中使用的是 Target，他们之间的映射关系是

|Runlevel|Target|说明|
|---|---|---|
|0|poweroff.target|关闭系统|
|1|rescue.target|维护模式|
|2,3,4|multi-user.target|多用户，无图形系统（命令行界面）|
|5|graphical.target|多用户，图形化系统（图形用户界面）|
|6|reboot.target|重启系统|

### target vs unit

如果一个target只包含一个Unit，那么该 target，没有对应的目录，指的就是这个 Unit, 例如 `hibernate.target`只包含 `systemd-hibernate.service`一个Unit.

如果一个target包含多个Unit，那么该target，有对应的 xxx.target.wants 目录，指的是目录里面所有的Unit, 例如`multi-user.target` 包含位于`/etc/systemd/system/multi-user.target.wants`目录下的多个 Unit.

### target 命令

```bash
# 查看当前系统的所有 Target  
$ systemctl list-unit-files --type=target  
  
# 查看一个 Target 包含的所有 Unit  
$ systemctl list-dependencies multi-user.target  
  
# 查看启动时的默认 Target  
$ systemctl get-default  
  
# 设置启动时的默认 Target  
$ sudo systemctl set-default multi-user.target  
  
# 切换 Target 时，默认不关闭前一个 Target 启动的进程，systemctl isolate 命令改变这种行为，关闭前一个 Target 里面所有不属于后一个 Target 的进程  
$ sudo systemctl isolate multi-user.target
```

### 启动过程

1. 读入 `/boot` 目录下的内核文件
2. 内核文件加载完之后，开始执行第一个程序`/sbin/init` 初始化进程，由 Systemd 初始化系统引导，完成相关的初始化工作
3. Systemd 执行`default.target` ，获知设定的启动 target (查看默认 target: `systemctl get-default)`
4. Systemd 执行启动 target 对应的单元文件。根据单元文件中定义的[依赖关系]([https://www.freedesktop.org/software/systemd/man/bootup.html#System](https://www.freedesktop.org/software/systemd/man/bootup.html#System) Manager Bootup)，传递控制权，依次执行其他 target 单元文件，同时启动每个 target 包含的单元

# 命令

### 系统管理命令

`systemctl`是 Systemd 的主命令，用于管理系统。
```bash
# 重启系统  
$ sudo systemctl reboot  
  
# 关闭系统，切断电源  
$ sudo systemctl poweroff  
  
# CPU停止工作  
$ sudo systemctl halt  
  
# 暂停系统  
$ sudo systemctl suspend  
  
# 让系统进入冬眠状态  
$ sudo systemctl hibernate  
  
# 让系统进入交互式休眠状态  
$ sudo systemctl hybrid-sleep  
  
# 启动进入救援状态（单用户状态）  
$ sudo systemctl rescue
```

`systemd-analyze`命令用于查看启动耗时。

```bash
# 查看启动耗时  
$ systemd-analyze                                                                                         
  
# 查看每个服务的启动耗时  
$ systemd-analyze blame  
  
# 显示瀑布状的启动过程流  
$ systemd-analyze critical-chain  
  
# 显示指定服务的启动流  
$ systemd-analyze critical-chain atd.service
```
### 查看配置文件

```bash
# 列出所有配置文件  
# 这个列表显示每个配置文件的状态，一共有四种。  
# enabled：已建立启动链接  
# disabled：没建立启动链接  
# static：该配置文件没有[Install]部分（无法执行），只能作为其他配置文件的依赖  
# masked：该配置文件被禁止建立启动链接  
$ systemctl list-unit-files  
  
# 列出指定类型的配置文件  
$ systemctl list-unit-files --type=service  
  
# 查看当前系统的所有 Target  
$ systemctl list-unit-files --type=target
```

### 查看系统Unit

```bash
# 列出正在运行的 Unit  
$ systemctl list-units  
  
# 列出所有Unit，包括没有找到配置文件的或者启动失败的  
$ systemctl list-units --all  
  
# 列出所有没有运行的 Unit  
$ systemctl list-units --all --state=inactive  
  
# 列出所有加载失败的 Unit  
$ systemctl list-units --failed  
  
# 列出所有正在运行的、类型为 service 的 Unit  
$ systemctl list-units --type=service  
  
# 查看 Unit 配置文件的内容  
$ systemctl cat docker.service
```


### 查看 Unit 的状态

```bash
# 显示系统状态  
$ systemctl status  
  
# 显示单个 Unit 的状态  
$ systemctl status bluetooth.service  
  
# 显示远程主机的某个 Unit 的状态  
$ systemctl -H root@levonfly.example.com status httpd.service  
  
# 显示某个 Unit 是否正在运行  
$ systemctl is-active application.service  
  
# 显示某个 Unit 是否处于启动失败状态  
$ systemctl is-failed application.service  
  
# 显示某个 Unit 服务是否建立了启动链接  
$ systemctl is-enabled application.service
```


### Unit 的管理

```bash
# 立即启动一个服务  
$ sudo systemctl start apache.service  
  
# 立即停止一个服务  
$ sudo systemctl stop apache.service  
  
# 重启一个服务  
$ sudo systemctl restart apache.service  
  
# 杀死一个服务的所有子进程  
$ sudo systemctl kill apache.service  
  
# 重新加载一个服务的配置文件  
$ sudo systemctl reload apache.service  
  
# 重载所有修改过的配置文件  
$ sudo systemctl daemon-reload  
  
# 显示某个 Unit 的所有底层参数  
$ systemctl show httpd.service  
  
# 显示某个 Unit 的指定属性的值  
$ systemctl show -p CPUShares httpd.service  
  
# 设置某个 Unit 的指定属性  
$ sudo systemctl set-property httpd.service CPUShares=500
```

### 查看 Unit 的依赖关系

```bash
# 列出一个 Unit 的所有依赖，默认不会列出 target 类型  
$ systemctl list-dependencies nginx.service  
  
# 列出一个 Unit 的所有依赖，包括 target 类型  
$ systemctl list-dependencies --all nginx.service
```

### 服务的生命周期

当一个新的 Unit 文件被放入 /etc/systemd/system/ 或 /usr/lib/systemd/system/ 目录中时，它是不会被自识识别的。

**服务的激活**

- systemctl enable：在 /etc/systemd/system/ 建立服务的符号链接，指向 /usr/lib/systemd/system/ 中
- systemctl start：依次启动定义在 Unit 文件中的 ExecStartPre、ExecStart 和 ExecStartPost 命令

**服务的启动和停止**

- systemctl start：依次启动定义在 Unit 文件中的 ExecStartPre、ExecStart 和 ExecStartPost 命令
- systemctl stop：依次停止定义在 Unit 文件中的 ExecStopPre、ExecStop 和 ExecStopPost 命令
- systemctl restart：重启服务
- systemctl kill：立即杀死服务

**服务的开机启动和取消**

- systemctl enable：除了激活服务以外，也可以置服务为开机启动
- systemctl disable：取消服务的开机启动

**服务的修改和移除**

- systemctl daemon-reload：Systemd 会将 Unit 文件的内容写到缓存中，因此当 Unit 文件被更新时，需要告诉 Systemd 重新读取所有的 Unit 文件
    
- systemctl reset-failed：移除标记为丢失的 Unit 文件。在删除 Unit 文件后，由于缓存的关系，即使通过 daemon-reload 更新了缓存，在 list-units 中依然会显示标记为 not-found 的 Unit。
    

### systemctl 与 service 命令的区别

1. systemctl 融合了 service 和 chkconfig 的功能
2. 在 Ubuntu18.04 中没有自带 chkconfig 命令；service 命令实际上重定向到 systemctl 命令

|动作|SysV Init 指令|Systemd 指令|
|---|---|---|
|启动某服务|service httpd start|systemctl start httpd|
|停止某服务|service httpd stop|systemctl stop httpd|
|重启某服务|service httpd restart|systemctl restart httpd|
|检查服务状态|service httpd status|systemctl status httpd|
|删除某服务|chkconfig –del httpd|停掉应用，删除其配置文件|
|使服务开机自启动|chkconfig –level 5 httpd on|systemctl enable httpd|
|使服务开机不自启动|chkconfig –level 5 httpd off|systemctl disable httpd|
|查询服务是否开机自启|chkconfig –list \| grep httpd|systemctl is-enabled httpd|
|加入自定义服务|chkconfig –add test|systemctl load test|
|显示所有已启动的服务|chkconfig –list|systemctl list-unit-files \| grep enabled|

# system 工具集

- systemctl：用于检查和控制各种系统服务和资源的状态
- bootctl：用于查看和管理系统启动分区
- hostnamectl：用于查看和修改系统的主机名和主机信息
```bash
# 显示当前主机的信息
$ hostnamectl
# 设置主机名
$ sudo hostnamectl set-hostname levonfly
```
- journalctl：用于查看系统日志和各类应用服务日志
- localectl：用于查看和管理系统的地区信息
```bash
**# 查看本地化设置
$ localectl  
# 设置本地化参数
$ sudo localectl set-locale LANG=en_GB.utf8  
$ sudo localectl set-keymap en_GB**
```
- loginctl：用于管理系统已登录用户和 Session 的信息
```bash
# 列出当前session
$ loginctl list-sessions 
# 列出当前登录用户
$ loginctl list-users
# 列出显示指定用户的信息
$ loginctl show-user ruanyf
```
- machinectl：用于操作 Systemd 容器
- timedatectl：用于查看和管理系统的时间和时区信息
```bash
# 查看当前时区设置
$ timedatectl  
# 显示所有可用的时区
$ timedatectl list-timezones 
# 设置当前时区
$ sudo timedatectl set-timezone America/New_York  
$ sudo timedatectl set-time YYYY-MM-DD  
$ sudo timedatectl set-time HH:MM:SS
```
- systemd-analyze 显示此次系统启动时运行每个服务所消耗的时间，可以用于分析系统启动过程中的性能瓶颈
- systemd-ask-password：辅助性工具，用星号屏蔽用户的任意输入，然后返回实际输入的内容
- systemd-cat：用于将其他命令的输出重定向到系统日志
- systemd-cgls：递归地显示指定 CGroup 的继承链
- systemd-cgtop：显示系统当前最耗资源的 CGroup 单元
- systemd-escape：辅助性工具，用于去除指定字符串中不能作为 Unit 文件名的字符
- systemd-hwdb：Systemd 的内部工具，用于更新硬件数据库
- systemd-delta：对比当前系统配置与默认系统配置的差异
- systemd-detect-virt：显示主机的虚拟化类型
- systemd-inhibit：用于强制延迟或禁止系统的关闭、睡眠和待机事件
- systemd-machine-id-setup：Systemd 的内部工具，用于给 Systemd 容器生成 ID
- systemd-notify：Systemd 的内部工具，用于通知服务的状态变化
- systemd-nspawn：用于创建 Systemd 容器
- systemd-path：Systemd 的内部工具，用于显示系统上下文中的各种路径配置
- systemd-run：用于将任意指定的命令包装成一个临时的后台服务运行
- systemd-stdio- bridge：Systemd 的内部 工具，用于将程序的标准输入输出重定向到系统总线
- systemd-tmpfiles：Systemd 的内部工具，用于创建和管理临时文件目录
- systemd-tty-ask-password-agent：用于响应后台服务进程发出的输入密码请求


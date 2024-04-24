# Systemd-命令篇

## 系统管理

Systemd 并不是一个命令，而是一组命令，涉及到系统管理的方方面面。

### 3.1 systemctl

​`systemctl`​是 Systemd 的主命令，用于管理系统。

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

### 3.2 systemd-analyze

​`systemd-analyze`​命令用于查看启动耗时。

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

### 3.3 hostnamectl

​`hostnamectl`​命令用于查看当前主机的信息。

```bash
# 显示当前主机的信息
$ hostnamectl

# 设置主机名。
$ sudo hostnamectl set-hostname rhel7
```

### 3.4 localectl

​`localectl`​命令用于查看本地化设置。

```bash
# 查看本地化设置
$ localectl

# 设置本地化参数。
$ sudo localectl set-locale LANG=en_GB.utf8
$ sudo localectl set-keymap en_GB
```

### 3.5 timedatectl

​`timedatectl`​命令用于查看当前时区设置。

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

### 3.6 loginctl

​`loginctl`​命令用于查看当前登录的用户。

```bash
# 列出当前session
$ loginctl list-sessions

# 列出当前登录用户
$ loginctl list-users

# 列出显示指定用户的信息
$ loginctl show-user ruanyf
```

## 四、Unit

### 4.1 含义

Systemd 可以管理所有系统资源。不同的资源统称为 Unit（单位）。

Unit 一共分成12种。

```bash

Service unit：系统服务
Target unit：多个 Unit 构成的一个组
Device Unit：硬件设备
Mount Unit：文件系统的挂载点
Automount Unit：自动挂载点
Path Unit：文件或路径
Scope Unit：不是由 Systemd 启动的外部进程
Slice Unit：进程组
Snapshot Unit：Systemd 快照，可以切回某个快照
Socket Unit：进程间通信的 socket
Swap Unit：swap 文件
Timer Unit：定时器
```

​`systemctl list-units`​命令可以查看当前系统的所有 Unit 。

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

```

### 4.2 Unit 的状态

​`systemctl status`​命令用于查看系统状态和单个 Unit 的状态。

```bash
# 显示系统状态
$ systemctl status

# 显示单个 Unit 的状态
$ sysystemctl status bluetooth.service

# 显示远程主机的某个 Unit 的状态
$ systemctl -H root@rhel7.example.com status httpd.service
```

除了`status`​命令，`systemctl`​还提供了三个查询状态的简单方法，主要供脚本内部的判断语句使用。

```bash
# 显示某个 Unit 是否正在运行
$ systemctl is-active application.service

# 显示某个 Unit 是否处于启动失败状态
$ systemctl is-failed application.service

# 显示某个 Unit 服务是否建立了启动链接
$ systemctl is-enabled application.service
```

### 4.3 Unit 管理

对于用户来说，最常用的是下面这些命令，用于启动和停止 Unit（主要是 service）。

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

### 4.4 依赖关系

Unit 之间存在依赖关系：A 依赖于 B，就意味着 Systemd 在启动 A 的时候，同时会去启动 B。

​`systemctl list-dependencies`​命令列出一个 Unit 的所有依赖。

```bash
$ systemctl list-dependencies nginx.service
```

上面命令的输出结果之中，有些依赖是 Target 类型（详见下文），默认不会展开显示。如果要展开 Target，就需要使用`--all`​参数。

```bash
$ systemctl list-dependencies --all nginx.service
```

## 五、Unit 的配置文件

### 5.1 概述

每一个 Unit 都有一个配置文件，告诉 Systemd 怎么启动这个 Unit 。

Systemd 默认从目录`/etc/systemd/system/`​读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/usr/lib/systemd/system/`​，真正的配置文件存放在那个目录。

​`systemctl enable`​命令用于在上面两个目录之间，建立符号链接关系。

```bash
$ sudo systemctl enable clamd@scan.service
# 等同于
$ sudo ln -s '/usr/lib/systemd/system/clamd@scan.service' '/etc/systemd/system/multi-user.target.wants/clamd@scan.service'
```

如果配置文件里面设置了开机启动，`systemctl enable`​命令相当于激活开机启动。

与之对应的，`systemctl disable`​命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。

```bash
$ sudo systemctl disable clamd@scan.service
```

配置文件的后缀名，就是该 Unit 的种类，比如`sshd.socket`​。如果省略，Systemd 默认后缀名为`.service`​，所以`sshd`​会被理解成`sshd.service`​。

### 5.2 配置文件的状态

​`systemctl list-unit-files`​命令用于列出所有配置文件。

```bash
# 列出所有配置文件
systemctl list-unit-files

# 列出指定类型的配置文件
systemctl list-unit-files --type=service
systemctl list-unit-files --state=enabled
```

这个列表显示每个配置文件的状态，一共有四种。

> * enabled：已建立启动链接
> * disabled：没建立启动链接
> * static：该配置文件没有`[Install]`​部分（无法执行），只能作为其他配置文件的依赖
> * masked：该配置文件被禁止建立启动链接

注意，从配置文件的状态无法看出，该 Unit 是否正在运行。这必须执行前面提到的`systemctl status`​命令。

```bash
$ systemctl status bluetooth.service
```

一旦修改配置文件，就要让 SystemD 重新加载配置文件，然后重新启动，否则修改不会生效。

```bash

$ sudo systemctl daemon-reload
$ sudo systemctl restart httpd.service
```

### 5.3 配置文件的格式

配置文件就是普通的文本文件，可以用文本编辑器打开。

​`systemctl cat`​命令可以查看配置文件的内容。

```bash

$ systemctl cat atd.service

[Unit]
Description=ATD daemon

[Service]
Type=forking
ExecStart=/usr/bin/atd

[Install]
WantedBy=multi-user.target
```

从上面的输出可以看到，配置文件分成几个区块。每个区块的第一行，是用方括号表示的区别名，比如`[Unit]`​。注意，配置文件的区块名和字段名，都是大小写敏感的。

每个区块内部是一些等号连接的键值对。

```bash

[Section]
Directive1=value
Directive2=value

. . .
```

注意，键值对的等号两侧不能有空格。

### 5.4 配置文件的区块

#### [Unit]

​`[Unit]`​区块通常是配置文件的第一个区块，用来定义 Unit 的元数据，以及配置与其他 Unit 的关系。它的主要字段如下。

* Description：描述这个 Unit 文件的信息
* Documentation：指定服务的文档，可以是一个或多个文档的 URL 路径
* Requires：依赖的其它 Unit 列表，列在其中的 Unit 模板会在这个服务启动时的同时被启动。并且，如果其中任意一个服务启动失败，这个服务也会被终止
* Wants：与 Requires 相似，但只是在被配置的这个 Unit 启动时，触发启动列出的每个 Unit 模块，而不去考虑这些模板启动是否成功
* After：与 Requires 相似，但是在后面列出的所有模块全部启动完成以后，才会启动当前的服务
* Before：与 After 相反，在启动指定的任务一个模块之间，都会首先确证当前服务已经运行
* Binds To：与 Requires 相似，失败时失败，成功时成功，但是在这些模板中有任意一个出现意外结束或重启时，这个服务也会跟着终止或重启
* Part Of：一个 Bind To 作用的子集，仅在列出的任务模块失败或重启时，终止或重启当前服务，而不会随列出模板的启动而启动
* OnFailure：当这个模板启动失败时，就会自动启动列出的每个模块
* Conflicts：与这个模块有冲突的模块，如果列出的模块中有已经在运行的，这个服务就不能启动，反之亦然

#### [Install]

这部分配置的目标模块通常是特定运行目标的 .target 文件，用来使得服务在系统启动时自动运行。这个区段可以包含三种启动约束：

* WantedBy：和 Unit 段的 Wants  作用相似，只有后面列出的不是服务所依赖的模块，而是依赖当前服务的模块。它的值是一个或多个 Target，当前 Unit  激活时（enable）符号链接会放入 /etc/systemd/system 目录下面以 <Target 名> + .wants  后缀构成的子目录中，如 “/etc/systemd/system/multi-user.target.wants/“

  ```bash

  # find /etc/systemd/system/* -type d
  /etc/systemd/system/default.target.wants
  /etc/systemd/system/getty.target.wants
  /etc/systemd/system/graphical.target.wants
  /etc/systemd/system/multi-user.target.wants
  /etc/systemd/system/network-online.target.wants
  /etc/systemd/system/paths.target.wants
  /etc/systemd/system/shutdown.target.wants
  /etc/systemd/system/sockets.target.wants
  /etc/systemd/system/sysinit.target.wants
  /etc/systemd/system/timers.target.wants
  ```

* RequiredBy：和 Unit 段的 Wants  作用相似，只有后面列出的不是服务所依赖的模块，而是依赖当前服务的模块。它的值是一个或多个 Target，当前 Unit 激活时，符号链接会放入  /etc/systemd/system 目录下面以 <Target 名> + .required 后缀构成的子目录中
* Also：当前 Unit enable/disable 时，同时 enable/disable 的其他 Unit
* Alias：当前 Unit 可用于启动的别名

‍

#### [Service]

用来 Service 的配置，只有 Service 类型的 Unit 才有这个区块。它的主要字段分为服务生命周期和服务上下文配置两个方面。

1. 服务生命周期控制相关

* Type：定义启动时的进程行为，它有以下几种值：

  * Type=simple：默认值，执行ExecStart指定的命令，启动主进程
  * Type=forking：以 fork 方式从父进程创建子进程，创建后父进程会立即退出
  * Type=oneshot：一次性进程，Systemd 会等当前服务退出，再继续往下执行
  * Type=dbus：当前服务通过D-Bus启动
  * Type=notify：当前服务启动完毕，会通知Systemd，再继续往下执行
  * Type=idle：若有其他任务执行完毕，当前服务才会运行
* RemainAfterExit：值为 true 或 false（默认）。当配置为 true 时，Systemd  只会负责启动服务进程，之后即便服务进程退出了，Systemd  也仍然会认为这个服务还在运行中。这个配置主要是提供给一些并非常驻内存，而是启动注册后立即退出，然后等待消息按需启动的特殊类型服务使用的。
* ExecStart：启动当前服务的命令
* ExecStartPre：启动当前服务之前执行的命令
* ExecStartPos：启动当前服务之后执行的命令
* ExecReload：重启当前服务时执行的命令
* ExecStop：停止当前服务时执行的命令
* ExecStopPost：停止当其服务之后执行的命令
* RestartSec：自动重启当前服务间隔的秒数
* Restart：定义何种情况 Systemd 会自动重启当前服务，可能的值包括 always（总是重启）、on-success、on-failure、on-abnormal、on-abort、on-watchdog
* TimeoutStartSec：启动服务时等待的秒数，这一配置对于使用 Docker 容器而言显得尤为重要，因其第一次运行时可能需要下载镜像，严重延时会容易被 Systemd 误判为启动失败杀死。通常，对于这种服务，将此值指定为 0，从而关闭超时检测
* TimeoutStopSec：停止服务时的等待秒数，如果超过这个时间仍然没有停止，Systemd 会使用 SIGKILL 信号强行杀死服务的进程

2. 服务上下文配置相关

* Environment：为服务指定环境变量
* EnvironmentFile：指定加载一个包含服务所需的环境变量的列表的文件，文件中的每一行都是一个环境变量的定义
* Nice：服务的进程优先级，值越小优先级越高，默认为 0。其中 -20 为最高优先级，19 为最低优先级
* WorkingDirectory：指定服务的工作目录
* RootDirectory：指定服务进程的根目录（/ 目录）。如果配置了这个参数，服务将无法访问指定目录以外的任何文件
* User：指定运行服务的用户
* Group：指定运行服务的用户组
* MountFlags：服务的 Mount Namespace  配置，会影响进程上下文中挂载点的信息，即服务是否会继承主机上已有挂载点，以及如果服务运行执行了挂载或卸载设备的操作，是否会真实地在主机上产生效果。可选值为  shared、slaved 或 private

  * shared：服务与主机共用一个 Mount Namespace，继承主机挂载点，且服务挂载或卸载设备会真实地反映到主机上
  * slave：服务使用独立的 Mount Namespace，它会继承主机挂载点，但服务对挂载点的操作只有在自己的 Namespace 内生效，不会反映到主机上
  * private：服务使用独立的 Mount Namespace，它在启动时没有任何任何挂载点，服务对挂载点的操作也不会反映到主机上
* LimitCPU / LimitSTACK / LimitNOFILE / LimitNPROC 等：限制特定服务的系统资源量，例如 CPU、程序堆栈、文件句柄数量、子进程数量等

> 注意：如果在 ExecStart、ExecStop 等属性中使用了 Linux 命令，则必须要写出完整的绝对路径。对于 ExecStartPre  和 ExecStartPost 辅助命令，若前面有个 “-” 符号，表示忽略这些命令的出错。因为有些 “辅助”  命令本来就不一定成功，比如尝试清空一个文件，但文件可能不存在。

## 六、Target

启动计算机的时候，需要启动大量的 Unit。如果每一次启动，都要一一写明本次启动需要哪些 Unit，显然非常不方便。Systemd 的解决方案就是 Target。

简单说，Target 就是一个 Unit 组，包含许多相关的 Unit 。启动某个 Target 的时候，Systemd 就会启动里面所有的 Unit。从这个意义上说，Target 这个概念类似于"状态点"，启动某个 Target 就好比启动到某种状态。

传统的`init`​启动模式里面，有 RunLevel 的概念，跟 Target 的作用很类似。不同的是，RunLevel 是互斥的，不可能多个 RunLevel 同时启动，但是多个 Target 可以同时启动。

```bash
# 查看当前系统的所有 Target
$ systemctl list-unit-files --type=target

# 查看一个 Target 包含的所有 Unit
$ systemctl list-dependencies multi-user.target

# 查看启动时的默认 Target
$ systemctl get-default

# 设置启动时的默认 Target
$ sudo systemctl set-default multi-user.target

# 切换 Target 时，默认不关闭前一个 Target 启动的进程，
# systemctl isolate 命令改变这种行为，
# 关闭前一个 Target 里面所有不属于后一个 Target 的进程
$ sudo systemctl isolate multi-user.target
```

Target 与 传统 RunLevel 的对应关系如下。

```bash
Traditional runlevel      New target name     Symbolically linked to...

Runlevel 0           |    runlevel0.target -> poweroff.target
Runlevel 1           |    runlevel1.target -> rescue.target
Runlevel 2           |    runlevel2.target -> multi-user.target
Runlevel 3           |    runlevel3.target -> multi-user.target
Runlevel 4           |    runlevel4.target -> multi-user.target
Runlevel 5           |    runlevel5.target -> graphical.target
Runlevel 6           |    runlevel6.target -> reboot.target

```

它与`init`​进程的主要差别如下。

>  **（1）默认的 RunLevel**（在`/etc/inittab`​文件设置）现在被默认的 Target 取代，位置是`/etc/systemd/system/default.target`​，通常符号链接到`graphical.target`​（图形界面）或者`multi-user.target`​（多用户命令行）。
>
>  **（2）启动脚本的位置**，以前是`/etc/init.d`​目录，符号链接到不同的 RunLevel 目录 （比如`/etc/rc3.d`​、`/etc/rc5.d`​等），现在则存放在`/lib/systemd/system`​和`/etc/systemd/system`​目录。
>
>  **（3）配置文件的位置**，以前`init`​进程的配置文件是`/etc/inittab`​，各种服务的配置文件存放在`/etc/sysconfig`​目录。现在的配置文件主要存放在`/lib/systemd`​目录，在`/etc/systemd`​目录里面的修改可以覆盖原始设置。

## 七、日志管理

Systemd 统一管理所有 Unit 的启动日志。带来的好处就是，可以只用`journalctl`​一个命令，查看所有日志（内核日志和应用日志）。日志的配置文件是`/etc/systemd/journald.conf`​。

​`journalctl`​功能强大，用法非常多。

```bash
# 查看所有日志（默认情况下 ，只保存本次启动的日志）
$ sudo journalctl

# 查看内核日志（不显示应用日志）
$ sudo journalctl -k

# 查看系统本次启动的日志
$ sudo journalctl -b
$ sudo journalctl -b -0

# 查看上一次启动的日志（需更改设置）
$ sudo journalctl -b -1

# 查看指定时间的日志
$ sudo journalctl --since="2012-10-30 18:17:16"
$ sudo journalctl --since "20 min ago"
$ sudo journalctl --since yesterday
$ sudo journalctl --since "2015-01-10" --until "2015-01-11 03:00"
$ sudo journalctl --since 09:00 --until "1 hour ago"

# 显示尾部的最新10行日志
$ sudo journalctl -n

# 显示尾部指定行数的日志
$ sudo journalctl -n 20

# 实时滚动显示最新日志
$ sudo journalctl -f

# 查看指定服务的日志
$ sudo journalctl /usr/lib/systemd/systemd

# 查看指定进程的日志
$ sudo journalctl _PID=1

# 查看某个路径的脚本的日志
$ sudo journalctl /usr/bin/bash

# 查看指定用户的日志
$ sudo journalctl _UID=33 --since today

# 查看某个 Unit 的日志
$ sudo journalctl -u nginx.service
$ sudo journalctl -u nginx.service --since today

# 实时滚动显示某个 Unit 的最新日志
$ sudo journalctl -u nginx.service -f

# 合并显示多个 Unit 的日志
$ journalctl -u nginx.service -u php-fpm.service --since today

# 查看指定优先级（及其以上级别）的日志，共有8级
# 0: emerg
# 1: alert
# 2: crit
# 3: err
# 4: warning
# 5: notice
# 6: info
# 7: debug
$ sudo journalctl -p err -b

# 日志默认分页输出，--no-pager 改为正常的标准输出
$ sudo journalctl --no-pager

# 以 JSON 格式（单行）输出
$ sudo journalctl -b -u nginx.service -o json

# 以 JSON 格式（多行）输出，可读性更好
$ sudo journalctl -b -u nginx.serviceqq
 -o json-pretty

# 显示日志占据的硬盘空间
$ sudo journalctl --disk-usage

# 指定日志文件占据的最大空间
$ sudo journalctl --vacuum-size=1G

# 指定日志文件保存多久
$ sudo journalctl --vacuum-time=1years
```

（完）

‍

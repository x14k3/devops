# linux systemd

* 📄 [Systemd 定时器](siyuan://blocks/20240403215034-mgi9u5o)
* 📄 [Systemd 开机自动挂载硬盘](siyuan://blocks/20240403215120-kex3dr0)
* 📄 [Systemd 开机自启脚本](siyuan://blocks/20240403215142-0ckpbbb)
* 📄 [Systemd 进程管理工具](siyuan://blocks/20240403214843-ssr0urc)

‍

#### Unit 模板

在现实中，往往有一些应用需要被复制多份运行。例如，用于同一个负载均衡器分流的多个服务实例，或者为每个 SSH 连接建立一个独立的 sshd 服务进程。

Unit 模板文件的写法与普通的服务 Unit 文件基本相同，不过 Unit 模板的文件名是以 @ 符号结尾的。通过模板启动服务实例时，需要在其文件名的 @ 字符后面附加一个参数字符串。

示例：apache@.service

```bash
[Unit]
Description=My Advanced Service Template
After=etcd.service docker.service
[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill apache%i
ExecStartPre=-/usr/bin/docker rm apache%i
ExecStartPre=/usr/bin/docker pull coreos/apache
ExecStart=/usr/bin/docker run --name apache%i -p %i:80 coreos/apache /usr/sbin/apache2ctl -D FOREGROUND
ExecStartPost=/usr/bin/etcdctl set /domains/example.com/%H:%i running
ExecStop=/usr/bin/docker stop apache1
ExecStopPost=/usr/bin/docker rm apache1
ExecStopPost=/usr/bin/etcdctl rm /domains/example.com/%H:%i
[Install]
WantedBy=multi-user.target
```

启动 Unit 模板的服务实例

​`systemctl start apache@8080.service`​

Systemd 在运行服务时，总是会先尝试找到一个完整匹配的 Unit 文件，如果没有找到，才会尝试选择匹配模板。例如上面的命令，System  首先会在约定的目录下寻找名为 apache@8080.service 的文件，如果没有找到，而文件名中包含 @  字符，它就会尝试去掉后缀参数匹配模板文件。对于 apache@8080.service，systemd 会找到 apache@.service  模板文件，并通过这个模板文件将服务实例化。

‍

## Systemd 的资源管理

### Systemctl 命令

```bash
systemctl [OPTIONS...] {COMMAND} ...

Query or send control commands to the systemd manager.

  -h --help           Show this help
     --version        Show package version
     --system         Connect to system manager
  -H --host=[USER@]HOST
                      Operate on remote host
  -M --machine=CONTAINER
                      Operate on local container
  -t --type=TYPE      List units of a particular type
     --state=STATE    List units with particular LOAD or SUB or ACTIV
  -p --property=NAME  Show only properties by this name
  -a --all            Show all loaded units/properties, including dea
                      ones. To list all units installed on the system
                      the 'list-unit-files' command instead.
  -l --full           Don't ellipsize unit names on output
  -r --recursive      Show unit list of host and local containers
     --reverse        Show reverse dependencies with 'list-dependenci
     --job-mode=MODE  Specify how to deal with already queued jobs, w
                      queueing a new job
     --show-types     When showing sockets, explicitly show their typ
  -i --ignore-inhibitors
                      When shutting down or sleeping, ignore inhibito
     --kill-who=WHO   Who to send signal to
  -s --signal=SIGNAL  Which signal to send
     --now            Start or stop unit in addition to enabling or d
  -q --quiet          Suppress output
     --no-block       Do not wait until operation finished
     --no-wall        Don't send wall message before halt/power-off/r
     --no-reload      Don't reload daemon after en-/dis-abling unit f
     --no-legend      Do not print a legend (column headers and hints
     --no-pager       Do not pipe output into a pager
     --no-ask-password
                      Do not ask for system passwords
     --global         Enable/disable unit files globally
     --runtime        Enable unit files only temporarily until next r
  -f --force          When enabling unit files, override existing sym
                      When shutting down, execute action immediately
     --preset-mode=   Apply only enable, only disable, or all presets
     --root=PATH      Enable unit files in the specified root directo
  -n --lines=INTEGER  Number of journal entries to show
  -o --output=STRING  Change journal output mode (short, short-iso,
                              short-precise, short-monotonic, verbose
                              export, json, json-pretty, json-sse, ca
     --plain          Print unit dependencies as a list instead of a 

Unit Commands:
  list-units [PATTERN...]         List loaded units
  list-sockets [PATTERN...]       List loaded sockets ordered by addr
  list-timers [PATTERN...]        List loaded timers ordered by next 
  start NAME...                   Start (activate) one or more units
  stop NAME...                    Stop (deactivate) one or more units
  reload NAME...                  Reload one or more units
  restart NAME...                 Start or restart one or more units
  try-restart NAME...             Restart one or more units if active
  reload-or-restart NAME...       Reload one or more units if possibl
                                  otherwise start or restart
  reload-or-try-restart NAME...   Reload one or more units if possibl
                                  otherwise restart if active
  isolate NAME                    Start one unit and stop all others
  kill NAME...                    Send signal to processes of a unit
  is-active PATTERN...            Check whether units are active
  is-failed PATTERN...            Check whether units are failed
  status [PATTERN...|PID...]      Show runtime status of one or more 
  show [PATTERN...|JOB...]        Show properties of one or more
                                  units/jobs or the manager
  cat PATTERN...                  Show files and drop-ins of one or m
  set-property NAME ASSIGNMENT... Sets one or more properties of a un
  help PATTERN...|PID...          Show manual for one or more units
  reset-failed [PATTERN...]       Reset failed state for all, one, or
                                  units
  list-dependencies [NAME]        Recursively show units which are re
                                  or wanted by this unit or by which 
                                  unit is required or wanted

Unit File Commands:
  list-unit-files [PATTERN...]    List installed unit files
  enable NAME...                  Enable one or more unit files
  disable NAME...                 Disable one or more unit files
  reenable NAME...                Reenable one or more unit files
  preset NAME...                  Enable/disable one or more unit fil
                                  based on preset configuration
  preset-all                      Enable/disable all unit files based
                                  preset configuration
  is-enabled NAME...              Check whether unit files are enable
  mask NAME...                    Mask one or more units
  unmask NAME...                  Unmask one or more units
  link PATH...                    Link one or more units files into
                                  the search path
  add-wants TARGET NAME...        Add 'Wants' dependency for the targ
                                  on specified one or more units
  add-requires TARGET NAME...     Add 'Requires' dependency for the t
                                  on specified one or more units
  edit NAME...                    Edit one or more unit files
  get-default                     Get the name of the default target
  set-default NAME                Set the default target

Machine Commands:
  list-machines [PATTERN...]      List local containers and host

Job Commands:
  list-jobs [PATTERN...]          List jobs
  cancel [JOB...]                 Cancel all, one, or more jobs

Snapshot Commands:
  snapshot [NAME]                 Create a snapshot
  delete NAME...                  Remove one or more snapshots

Environment Commands:
  show-environment                Dump environment
  set-environment NAME=VALUE...   Set one or more environment variabl
  unset-environment NAME...       Unset one or more environment varia
  import-environment [NAME...]    Import all or some environment vari

Manager Lifecycle Commands:
  daemon-reload                   Reload systemd manager configuratio
  daemon-reexec                   Reexecute systemd manager

System Commands:
  is-system-running               Check whether system is fully runni
  default                         Enter system default mode
  rescue                          Enter system rescue mode
  emergency                       Enter system emergency mode
  halt                            Shut down and halt the system
  poweroff                        Shut down and power-off the system
  reboot [ARG]                    Shut down and reboot the system
  kexec                           Shut down and reboot the system wit
  exit                            Request user instance exit
  switch-root ROOT [INIT]         Change to a different root file sys
  suspend                         Suspend the system
  hibernate                       Hibernate the system
  hybrid-sleep                    Hibernate and suspend the system
lines 87-134/134 (END)
  is-enabled NAME...              Check whether unit files are enabled
  mask NAME...                    Mask one or more units
  unmask NAME...                  Unmask one or more units
  link PATH...                    Link one or more units files into
                                  the search path
  add-wants TARGET NAME...        Add 'Wants' dependency for the target
                                  on specified one or more units
  add-requires TARGET NAME...     Add 'Requires' dependency for the target
                                  on specified one or more units
  edit NAME...                    Edit one or more unit files
  get-default                     Get the name of the default target
  set-default NAME                Set the default target

Machine Commands:
  list-machines [PATTERN...]      List local containers and host

Job Commands:
  list-jobs [PATTERN...]          List jobs
  cancel [JOB...]                 Cancel all, one, or more jobs

Snapshot Commands:
  snapshot [NAME]                 Create a snapshot
  delete NAME...                  Remove one or more snapshots

Environment Commands:
  show-environment                Dump environment
  set-environment NAME=VALUE...   Set one or more environment variables
  unset-environment NAME...       Unset one or more environment variables
  import-environment [NAME...]    Import all or some environment variables

Manager Lifecycle Commands:
  daemon-reload                   Reload systemd manager configuration
  daemon-reexec                   Reexecute systemd manager

System Commands:
  is-system-running               Check whether system is fully running
  default                         Enter system default mode
  rescue                          Enter system rescue mode
  emergency                       Enter system emergency mode
  halt                            Shut down and halt the system
  poweroff                        Shut down and power-off the system
  reboot [ARG]                    Shut down and reboot the system
  kexec                           Shut down and reboot the system with kexec
  exit                            Request user instance exit
  switch-root ROOT [INIT]         Change to a different root file system
  suspend                         Suspend the system
  hibernate                       Hibernate the system
  hybrid-sleep                    Hibernate and suspend the system
```

‍

‍

### Unit 管理

1. 查看当前系统的所有 Unit

    ```bash
    # 列出正在运行的 Unit
    systemctl list-units
    systemctl list-unit-files --state=enabled
    # 列出所有Unit，包括没有找到配置文件的或者启动失败的
    systemctl list-units --all
    # 列出所有没有运行的 Unit
    systemctl list-units --all --state=inactive
    # 列出所有加载失败的 Unit
    systemctl list-units --failed
    # 列出所有正在运行的、类型为 service 的 Unit
    systemctl list-units --type=service
    # 查看 Unit 配置文件的内容
    systemctl cat docker.service
    ```

2. 查看 Unit 的状态

* enabled：已建立启动链接
* disabled：没建立启动链接
* static：该配置文件没有 [Install] 部分（无法执行），只能作为其他配置文件的依赖
* masked：该配置文件被禁止建立启动链接

‍

3. Unit 的管理

    ```bash
    # 立即启动一个服务
    sudo systemctl start apache.service
    # 立即停止一个服务
    sudo systemctl stop apache.service
    # 重启一个服务
    sudo systemctl restart apache.service
    # 杀死一个服务的所有子进程
    sudo systemctl kill apache.service
    # 重新加载一个服务的配置文件
    sudo systemctl reload apache.service
    # 重载所有修改过的配置文件
    sudo systemctl daemon-reload
    # 显示某个 Unit 的所有底层参数
    systemctl show httpd.service
    # 显示某个 Unit 的指定属性的值
    systemctl show -p CPUShares httpd.service
    # 设置某个 Unit 的指定属性
    sudo systemctl set-property httpd.service CPUShares=500
    ```

‍

4. 查看 Unit 的依赖关系

    ```bash
    # 列出一个 Unit 的所有依赖，默认不会列出 target 类型
    systemctl list-dependencies nginx.service
    # 列出一个 Unit 的所有依赖，包括 target 类型
    systemctl list-dependencies --all nginx.service
    ```

### 服务的生命周期

当一个新的 Unit 文件被放入 /etc/systemd/system/ 或 /usr/lib/systemd/system/ 目录中时，它是不会被自识识别的。

1. 服务的激活

* systemctl enable：在 /etc/systemd/system/ 建立服务的符号链接，指向 /usr/lib/systemd/system/ 中
* systemctl start：依次启动定义在 Unit 文件中的 ExecStartPre、ExecStart 和 ExecStartPost 命令

2. 服务的启动和停止

* systemctl start：依次启动定义在 Unit 文件中的 ExecStartPre、ExecStart 和 ExecStartPost 命令
* systemctl stop：依次停止定义在 Unit 文件中的 ExecStopPre、ExecStop 和 ExecStopPost 命令
* systemctl restart：重启服务
* systemctl kill：立即杀死服务

3. 服务的开机启动和取消

* systemctl enable：除了激活服务以外，也可以置服务为开机启动
* systemctl disable：取消服务的开机启动

4. 服务的修改和移除

* systemctl daemon-reload：Systemd 会将 Unit 文件的内容写到缓存中，因此当 Unit 文件被更新时，需要告诉 Systemd 重新读取所有的 Unit 文件
* systemctl reset-failed：移除标记为丢失的 Unit 文件。在删除 Unit 文件后，由于缓存的关系，即使通过 daemon-reload 更新了缓存，在 list-units 中依然会显示标记为 not-found 的 Unit。

‍

### Target 管理

Target 就是一个 Unit 组，包含许多相关的 Unit 。启动某个 Target 的时候，Systemd 就会启动里面所有的 Unit。

在传统的 SysV-init 启动模式里面，有 RunLevel 的概念，跟 Target 的作用很类似。不同的是，RunLevel 是互斥的，不可能多个 RunLevel 同时启动，但是多个 Target 可以同时启动。

```bash
# 查看当前系统的所有 Target
systemctl list-unit-files --type=target
# 查看一个 Target 包含的所有 Unit
systemctl list-dependencies multi-user.target
# 查看启动时的默认 Target
systemctl get-default
# 设置启动时的默认 Target
sudo systemctl set-default multi-user.target
# 切换 Target 时，默认不关闭前一个 Target 启动的进程，systemctl isolate 命令改变这种行为，关闭前一个 Target 里面所有不属于后一个 Target 的进程
sudo systemctl isolate multi-user.target
```

1. Target 与 SysV-init 进程的主要区别：

* 默认的 RunLevel（在 /etc/inittab 文件设置）现在被默认的 Target 取代，位置是  /etc/systemd/system/default.target，通常符号链接到graphical.target（图形界面）或者multi-user.target（多用户命令行）。
* 启动脚本的位置，以前是 /etc/init.d 目录，符号链接到不同的 RunLevel 目录 （比如  /etc/rc3.d、/etc/rc5.d 等），现在则存放在 /lib/systemd/system 和  /etc/systemd/system 目录。
* 配置文件的位置，以前 init 进程的配置文件是 /etc/inittab，各种服务的配置文件存放在 /etc/sysconfig  目录。现在的配置文件主要存放在 /lib/systemd 目录，在 /etc/systemd 目录里面的修改可以覆盖原始设置。

‍

### 日志管理

Systemd 通过其标准日志服务 Journald 提供的配套程序 journalctl 将其管理的所有后台进程打印到 std:out（即控制台）的输出重定向到了日志文件。

Systemd 的日志文件是二进制格式的，必须使用 Journald 提供的 journalctl 来查看，默认不带任何参数时会输出系统和所有后台进程的混合日志。

默认日志最大限制为所在文件系统容量的 10%，可以修改 /etc/systemd/journald.conf 中的 SystemMaxUse 来指定该最大限制。

```bash
# 查看所有日志（默认情况下 ，只保存本次启动的日志）
journalctl

# 查看内核日志（不显示应用日志）：--dmesg 或 -k
journalctl -k

# 查看系统本次启动的日志（其中包括了内核日志和各类系统服务的控制台输出）：--system 或 -b
journalctl -b
journalctl -b -0

# 查看上一次启动的日志（需更改设置）
journalctl -b -1

# 查看指定服务的日志：--unit 或 -u
journalctl -u docker.servcie

# 查看指定服务的日志
journalctl /usr/lib/systemd/systemd

# 实时滚动显示最新日志
journalctl -f
journalctl -u prometheus -f

# 查看指定时间的日志
journalctl --since="2012-10-30 18:17:16"
journalctl --since "20 min ago"
journalctl --since yesterday
journalctl --since "2015-01-10" --until "2015-01-11 03:00"
journalctl --since 09:00 --until "1 hour ago"

# 显示尾部的最新 10 行日志：--lines 或 -n
journalctl -n

# 显示尾部指定行数的日志
journalctl -n 20

# 将最新的日志显示在前面
journalctl -r -u docker.service

# 改变输出的格式：--output 或 -o
journalctl -r -u docker.service -o json-pretty

# 查看指定进程的日志
journalctl _PID=1

# 查看某个路径的脚本的日志
journalctl /usr/bin/bash

# 查看指定用户的日志
journalctl _UID=33 --since today

# 查看某个 Unit 的日志
journalctl -u nginx.service
journalctl -u nginx.service --since today

# 实时滚动显示某个 Unit 的最新日志
journalctl -u nginx.service -f

# 合并显示多个 Unit 的日志
journalctl -u nginx.service -u php-fpm.service --since today

# 查看指定优先级（及其以上级别）的日志，共有 8 级
# 0: emerg
# 1: alert
# 2: crit
# 3: err
# 4: warning
# 5: notice
# 6: info
# 7: debug
journalctl -p err -b

# 日志默认分页输出，--no-pager 改为正常的标准输出
journalctl --no-pager

# 以 JSON 格式（单行）输出
journalctl -b -u nginx.service -o json

# 以 JSON 格式（多行）输出，可读性更好
journalctl -b -u nginx.service -o json-pretty

# 显示日志占据的硬盘空间
journalctl --disk-usage

# 指定日志文件占据的最大空间
journalctl --vacuum-size=1G

# 指定日志文件保存多久
journalctl --vacuum-time=1years
```

## Systemd 工具集

* systemctl：用于检查和控制各种系统服务和资源的状态
* bootctl：用于查看和管理系统启动分区
* hostnamectl：用于查看和修改系统的主机名和主机信息

  ```bash
  # 显示当前主机的信息
  $ hostnamectl
  # 设置主机名
  $ sudo hostnamectl set-hostname rhel7
  ```
* journalctl：用于查看系统日志和各类应用服务日志

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
* localectl：用于查看和管理系统的地区信息
* loginctl：用于管理系统已登录用户和 Session 的信息

  ```bash
  # 列出当前 session
  $ loginctl list-sessions

  # 列出当前登录用户
  $ loginctl list-users

  # 列出显示指定用户的信息
  $ loginctl show-user ruanyf
  ```
* machinectl：用于操作 Systemd 容器
* timedatectl：用于查看和管理系统的时间和时区信息

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
* systemd-analyze 显示此次系统启动时运行每个服务所消耗的时间，可以用于分析系统启动过程中的性能瓶颈

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
* systemd-ask-password：辅助性工具，用星号屏蔽用户的任意输入，然后返回实际输入的内容

  ```bash
  [root@test_01 grafana]# PASSWORD=$(systemd-ask-password "Input Your Passowrd:")
  Input Your Passowrd: ***********
  [root@test_01 grafana]# echo $PASSWORD
  ```
* systemd-cat：用于将其他命令的输出重定向到系统日志
* systemd-cgls：递归地显示指定 CGroup 的继承链
* systemd-cgtop：显示系统当前最耗资源的 CGroup 单元
* systemd-escape：辅助性工具，用于去除指定字符串中不能作为 Unit 文件名的字符
* systemd-hwdb：Systemd 的内部工具，用于更新硬件数据库
* systemd-delta：对比当前系统配置与默认系统配置的差异
* systemd-detect-virt：显示主机的虚拟化类型
* systemd-inhibit：用于强制延迟或禁止系统的关闭、睡眠和待机事件
* systemd-machine-id-setup：Systemd 的内部工具，用于给 Systemd 容器生成 ID
* systemd-notify：Systemd 的内部工具，用于通知服务的状态变化
* systemd-nspawn：用于创建 Systemd 容器
* systemd-path：Systemd 的内部工具，用于显示系统上下文中的各种路径配置
* systemd-run：用于将任意指定的命令包装成一个临时的后台服务运行  

  systemd-run 可以将一个指定的操作变成后台运行的服务。它的效果似乎与直接在命令后加上表示后台运行的 & 符号很相似。然而，它让命令成为服务还意味着，它的生命周期将由 Systemd 控制。具体来说，包括以下好处：

  * 服务的生命击期由 Systemd 接管，不会随着启动它的控制台关闭而结束
  * 可以通过 systemctl 工具管理服务的状态
  * 可以通过 journalctl 工具查看和管理服务的日志信息
  * 可以通过 Systemd 提供的方法限制服务的 CPU、内存、磁盘 IO 等系统资源的使用情况。
* systemd-stdio- bridge：Systemd 的内部 工具，用于将程序的标准输入输出重定向到系统总线
* systemd-tmpfiles：Systemd 的内部工具，用于创建和管理临时文件目录
* systemd-tty-ask-password-agent：用于响应后台服务进程发出的输入密码请求

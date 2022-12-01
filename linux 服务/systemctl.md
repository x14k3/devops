#system/systemctl


_service命令_：可以启动、停止、重新启动和关闭系统服务，还可以显示所有系统服务的当前状态。
_chkconfig命令_：是管理系统服务(service)的命令行工具。所谓系统服务(service)，就是随系统启动而启动，随系统关闭而关闭的程序
_systemctl命令_ ：是系统服务管理器指令，它实际上将 service 和 chkconfig 这两个命令组合到一起。

# systemctl
**systemctl是RHEL 7 的服务管理工具中主要的工具，它融合之前service和chkconfig的功能于一体。可以使用它永久性或只在当前会话中启用/禁用服务。**

**所以systemctl命令是service命令和chkconfig命令的集合和代替**
## systemctl 命令
```bash
#启动
systemctl start name.service
#停止
systemctl stop name.service
#重启
systemctl restart name.service
#查看状态
systemctl status name.service
#禁止自动和手动启动
systemctl mask name.service
#取消禁止
systemctl unmask name.service
#查看某服务当前激活与否的状态：
systemctl is-active name.service
#查看所有已经激活的服务：
systemctl list-units --type|-t service
#查看所有服务：
systemctl list-units --type service --all|-a
#设定某服务开机自启，相当于chkconfig name on
systemctl enable name.service
#设定某服务开机禁止启动：相当于chkconfig name off
systemctl disable name.service
#查看所有服务的开机自启状态，相当于chkconfig --list
systemctl list-unit-files --type service
#用来列出该服务在哪些运行级别下启用和禁用：chkconfig –list name
ls /etc/systemd/system/*.wants/name.service
#查看服务是否开机自启：
systemctl is-enabled name.service
#列出失败的服务
systemctl --failed --type=service
#开机并立即启动或停止
systemctl enable --now postfix
systemctl disable  --now postfix
#查看服务的依赖关系：
systemctl list-dependencies name.service
#杀掉进程：
systemctl kill unitname
#重新加载配置文件
systemctl daemon-reload
#关机
systemctl poweroff
#重启：
systemctl reboot
#挂起：
systemctl suspend
#休眠：
systemctl hibernate
#休眠并挂起：
systemctl hybrid-sleep

```

## 配置文件详解

配置文件主要放在`/usr/lib/systemd/system`目录

```bash
systemctl cat sshd.service

[Unit]
Description=OpenSSH server daemon           # 简单描述服务
Documentation=man:sshd(8) man:sshd_config(5)    
After=network.target sshd-keygen.service    # 描述服务类别，表示本服务需要在network服务启动后在启动
Wants=sshd-keygen.service                   #

[Service]
EnvironmentFile=/etc/sysconfig/sshd    # 指定环境配置文件
ExecStart=/usr/sbin/sshd -D $OPTIONS   # 启动服务时执行的命令
ExecReload=/bin/kill -HUP $MAINPID     # 重启服务时执行的命令
Type=simple                            # 运行模式
KillMode=process                       # 定义systemd如何停止服务
Restart=on-failure                     # 定义服务进程退出后，systemd的重启方式，默认是不重启
RestartSec=42s                         # 重启服务之前，需要等待的秒数

[Install]
WantedBy=multi-user.target

```

配置文件说明

```txt
# Type的类型有：
    simple  # 以ExecStart字段启动的进程为主进程(默认)
    forking # ExecStart字段以fork()方式启动，此时父进程将退出，子进程将成为主进程（后台运行）。一般都设置为forking
    oneshot # 类似于simple，但只执行一次，systemd会等它执行完，才启动其他服务
    dbus    # 类似于simple, 但会等待D-Bus信号后启动
    notify  # 类似于simple, 启动结束后会发出通知信号，然后systemd再启动其他服务
    idle    # 类似于simple，但是要等到其他任务都执行完，才会启动该服务。
    
# EnvironmentFile:
    指定配置文件，和连词号组合使用，可以避免配置文件不存在的异常。

# Environment:
    后面接多个不同的shell变量。
    例如：
    Environment=DATA_DIR=/data/elk
    Environment=LOG_DIR=/var/log/elasticsearch
    Environment=PID_DIR=/var/run/elasticsearch
    EnvironmentFile=-/etc/sysconfig/elasticsearch
    
连词号（-）：在所有启动设置之前，添加的变量字段，都可以加上连词号
    表示抑制错误，即发生错误时，不影响其他命令的执行。
    比如`EnviromentFile=-/etc/sysconfig/xxx` 表示即使文件不存在，也不会抛异常
    
KillMode的类型：
    control-group(默认)：# 当前控制组里的所有子进程，都会被杀掉
    process: # 只杀主进程
    mixed:   # 主进程将收到SIGTERM信号，子进程收到SIGKILL信号
    none:    # 没有进程会被杀掉，只是执行服务的stop命令
Restart的类型：
    no(默认值)： # 退出后无操作
    on-success:  # 只有正常退出时（退出状态码为0）,才会重启
    on-failure:  # 非正常退出时，重启，包括被信号终止和超时等
    on-abnormal: # 只有被信号终止或超时，才会重启
    on-abort:    # 只有在收到没有捕捉到的信号终止时，才会重启
    on-watchdog: # 超时退出时，才会重启
    always:      # 不管什么退出原因，都会重启
    # 对于守护进程，推荐用on-failure
RestartSec字段：
    表示systemd重启服务之前，需要等待的秒数：RestartSec: 30 
    
各种Exec*字段：
    # Exec* 后面接的命令，仅接受“指令 参数 参数..”格式，不能接受<>|&等特殊字符，很多bash语法也不支持。如果想支持bash语法，需要设置Tyep=oneshot
    ExecStart：    # 启动服务时执行的命令
    ExecReload：   # 重启服务时执行的命令 
    ExecStop：     # 停止服务时执行的命令 
    ExecStartPre： # 启动服务前执行的命令 
    ExecStartPost：# 启动服务后执行的命令 
    ExecStopPost： # 停止服务后执行的命令

    
# WantedBy字段：
    multi-user.target: # 表示多用户命令行状态，这个设置很重要
    graphical.target:  # 表示图形用户状体，它依赖于multi-user.target
```

修改配置文件以后，需要重新加载配置文件，然后重新启动相关服务。


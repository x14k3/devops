# systemd 服务管理

## 系统管理

　　Systemd 并不是一个命令，而是一组命令，涉及到系统管理的方方面面。

### systemctl

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

### systemd-analyze

　　用于查看启动耗时

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

### hostnamectl

```bash
# 显示当前主机的信息
$ hostnamectl
# 设置主机名。
$ sudo hostnamectl set-hostname rhel7

```

### localectl

```bash
# 查看本地化设置
$ localectl
# 设置本地化参数。
$ sudo localectl set-locale LANG=en_GB.utf8
$ sudo localectl set-keymap en_GB
```

### timedatectl

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

### loginctl

```bash
# 列出当前session
$ loginctl list-sessions
# 列出当前登录用户
$ loginctl list-users
# 列出显示指定用户的信息
$ loginctl show-user ruanyf
```

## Unit

　　Systemd 可以管理所有系统资源。不同的资源统称为 Unit（单位）。

　　Unit 一共分成12种。

> * Service unit：系统服务
> * Target unit：多个 Unit 构成的一个组
> * Device Unit：硬件设备
> * Mount Unit：文件系统的挂载点
> * Automount Unit：自动挂载点
> * Path Unit：文件或路径
> * Scope Unit：不是由 Systemd 启动的外部进程
> * Slice Unit：进程组
> * Snapshot Unit：Systemd 快照，可以切回某个快照
> * Socket Unit：进程间通信的 socket
> * Swap Unit：swap 文件
> * Timer Unit：定时器

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

### Unit 的状态

```bash
# 显示系统状态
systemctl status
# 显示单个 Unit 的状态
sysystemctl status bluetooth.service
# 显示远程主机的某个 Unit 的状态
systemctl -H root@rhel7.example.com status httpd.service
# 要查看所有服务的状态
systemctl list-units --type=service
# 列出所有active状态（运行或退出）的服务
systemctl list-units --type=service --state=active
# 列出所有正在运行的服务
systemctl list-units --type=service --state=running
# 列出所有enabled状态的服务
systemctl list-unit-files --state=enabled
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

### Unit 管理

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

　　‍

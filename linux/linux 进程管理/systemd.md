## 服务 Unit

### 配置文件目录


1. 系统配置文件目录`/etc/systemd/system/`的优先级最高, **建议放在这** .
2. 其次为`/usr/lib/systemd/system/`. 例如我用 apt 安装 nginx后, 它的配置就放在这里.
3. `/usr/lib/systemd/user/`存放用户的配置, **但是一般不用!!! 因为必须 usnm m,. er session 处于活动状态**



可以参考[Where do I put my systemd unit file?](https://unix.stackexchange.com/questions/224992/where-do-i-put-my-systemd-unit-file), 以及文档[systemd.unit-freedesktop](https://www.freedesktop.org/software/systemd/man/systemd.unit.html),[systemd.unit(5)-arch](https://man.archlinux.org/man/systemd.unit.5)

`systemctl enable supervisor`配置开机自启, 会在对应`target`的`wants`目录下, 添加一个软链接.

```bash
# 启用supervisor
systemctl enable supervisor --now
Created symlink /etc/systemd/system/multi-user.target.wants/supervisor.service → /lib/systemd/system/supervisor.service

# 我们看一下这个目录下的内容, 都是类似的符号链接
/etc/systemd/system/multi-user.target.wants# ll
drwxr-xr-x  2 root root 4096 Jul 29 22:10 ./
drwxr-xr-x 16 root root 4096 Jul 27 00:03 ../
...
lrwxrwxrwx  1 root root   34 Apr 19 14:41 aliyun.service -> /etc/systemd/system/aliyun.service
lrwxrwxrwx  1 root root   38 Jul 29 22:10 supervisor.service -> /lib/systemd/system/supervisor.service
...
```

为什么是`multi-user.target`这个`target`呢? 可以跳到下面看[配置文件中的Install](https://kentxxq.com/posts/%E7%AC%94%E8%AE%B0/Systemd%E6%95%99%E7%A8%8B/#Install).

### 配置示例 - 复制使用

配置文件主要有 3 部分.
- `Unit`: 启动顺序与依赖关系
- `Service`: 启动行为
- `Install`给`systemctl`用的, 其实与`守护进程systemd`无关.

```ini
[Unit]
Description=测试服务
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3


[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

WorkingDirectory=/root/myApp/TestServer
ExecStart=/root/myApp/TestServer/TestServer
# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 资源限制 K,M,G,T
# MemoryMax=500M
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity


[Install]
WantedBy=multi-user.target
# Alias=testserver.service
# Alias常见用法还有 ftp别名ftpd ssh别名sshd
```

> 配置文件的默认值在`/etc/systemd/system.conf`中.

### 配置详情

#### Unit
```ini
[Unit]
# 简短描述
Description=我的服务
# 文档地址
Documentation=https://ken.kentxxq.com

# 依赖a-Unit和b-Unit,a或b任意一个没运行,启动失败
Requires=a.service b.service
# 需要a-Unit,a没运行,不影响我
Wants=a.service
# a-Unit退出,我就停止运行
BindsTo=a.service
# a-Unit在我之后启动
Before=a.service
# a-Unit在我之前启动
After=a.service
# a-Unit不能与我同时运行
Conflicts=a.service

# Condition开头 必须满足所有条件我才会运行
# 下面是路径存在就运行
ConditionPathExists=/usr/bin/myprogram
# 文件不是空的才运行
ConditionFileNotEmpty=/etc/keepalived/keepalived.conf
# Assert开头 必须满足所有条件,否则会报错启动失败
AssertPathExists=/usr/bin/myprogram
# 这个文件有运行权限
AssertFileIsExecutable=/xxxx

# 启动时间区间,单位秒.
StartLimitIntervalSec=30
# 在StartLimitIntervalSec时间内,只会尝试启动3次
StartLimitBurst=3
```

#### Service

```ini
[Service]
# 默认值,ExecStart就是主进程
Type=simple
# 主进程创建子进程,父进程立即退出
Type=forking
# 代替rc.local,执行开机启动. 搭配RemainAfterExit=yes,让systemd显示状态active,让你知道已经执行过了.必须成功退出
Type=oneshot
# 和上面的区别是只要执行了就行,不一定要成功
Type=exec
# 服务启动以后,通过sd_notify(3)发送通知给systemd,才算启动成功.containerd有用到
Type=notify

# 运行用户和组,默认root用户/root组
User=kentxxq
Group=kentxxq

# 运行目录
WorkingDirectory=/path
# 启动前执行,失败不会执行ExecStart
# 启动前加载overlay内核模块, -减号 代表失败了也不影响ExecStart
# ExecStartPre=-/sbin/modprobe overlay
ExecStartPre=ls
# 启动命令.可以存在多个,然后会顺序执行.可能是为了调试方便?
ExecStart=
ExecStart=/usr/bin/xxx \
  --aaa=xxx \
  --bbb=xxx
# 启动后执行
ExecStartPost=ls
# systemctl reload执行
ExecReload=nginx -s reload
# 停止服务前执行命令,做一些清理工作
ExecStop=nginx -s stop
# 停止前等待多少秒
TimeoutStopSec=10
# 停止以后执行的命令,例如检查nginx端口是否还在监听?
ExecStopPost=ls

# 重启间隔时间 s/min/h/d
RestartSec=30s
# 重启的配置, 会受到Unit单元的StartLimit影响!!!
# always,on-success、on-failure、on-abnormal、on-abort、on-watchdog. 
Restart=always

# 资源限制 K,M,G,T
MemoryMax=500M

# 杀死模式
# 默认control-group
# control-group执行ExecStop后,向cgroup中所有进程先term后发送kill
# mixed会在cgroup的子进程全部先term,再kill后,才开始term,再kill主进程
# process仅主进程发送term后发送kill(containerd只杀主进程)
# none只是执行ExecStop命令
KillMode=mixed
# 确认只处理term信号,不需要发送kill命令,可以不发送.
# 配合TimeoutStopSec=infinity 使用,一直等待term信号处理完成
SendSIGKILL=no
# 修改杀死信号,默认是SIGTERM
RestartKillSignal=SIGHUP

# 环境变量 $MY_ENV1 $MY_ENV2
Environment=MY_ENV1=value1
Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
EnvironmentFile=/path/to/environment/file1

# 日志文件
# 标准输出路径
StandardOutput=append:/tmp/my-service.log
# 标准输出路径
StandardError=append:/tmp/my-service.log
# 定义一个名字
SyslogIdentifier=my-service

# 其他
# 保护/proc文件系统,其他进程无法修改,保证安全性. minio有用到
ProtectProc=invisible
# 可以打开的文件数/文件描述符=无限 默认是system.conf:#DefaultLimitNOFILE=1024:524288
LimitNOFILE=infinity
# 允许核心转储文件无限大,containerd有用到
LimitCORE=infinity
# 最大进程数无限
LimitNPROC=infinity
# 最大线程数=无限,默认4915. TasksMax比LimitNPROC更常用,参考回答https://unix.stackexchange.com/questions/452284/managing-nproc-in-systemd
TasksMax=infinity
# 开启后将其cgroup下资源控制交给进程自己管理,containerd有用到.
Delegate=yes
# -1000到1000,-999代表优先级很高.发生oom的时候,内核尽量先杀其他进程,保留这个. containerd有用到
OOMScoreAdjust=-999
# 私有的临时文件目录.systemd自动清理,通过隔离保证安全性.nginx有用到
PrivateTmp=true
```

#### Install

- 守护进程`systemd`完全不会处理这部分. 这部分是让`systemctl enable`用的.
- `systemctl get-default`得到启动时默认的`target`.

- 服务器先启动到`multi-user`,然后再`graphical.target`. 而通常服务器没有 UI.
- 常用 **多用户命令行** `multi-user`.
- **图形** `graphical.target`,图形用于开机启动 qq, 钉钉.
- `systemctl set-default multi-user.target`可以调整默认`target`.

```ini
[Install]
# 放到.wants下面,到了通常用这个
WantedBy=multi-user.target
# 放到.required下面, 如果依赖没成功,就抛出错误,不尝试启动
RequiredBy=b.service
# 启动别名,必须要enable后才能使用哦!
Alias=a.service
```

## Systemd 相关组件

### systemctl 命令

#### 启停配置

```bash
# 系统
# 重启系统
systemctl reboot
# 关闭系统,切断电源
systemctl poweroff

# 服务状态
systemctl status nginx
# 服务开启
systemctl start nginx
# 服务配置重新加载
systemctl daemon-reload
# 服务重启
# 发送term信号,然后xx秒后,kill命令.然后重新拉起
systemctl restart nginx
# 服务重启
systemctl stop nginx
```

#### 查询详情

```bash
# 查询所有的target状态,简介
systemctl list-units --type target
# 查询所有的service状态,简介
systemctl list-units --type service

# 查看服务的完整参数
systemctl show nginx

# 查看所有unit文件是否可以运行,是否开机启动
# enabled,disabled 是否建立启动连接. 
# static 没有[Install],只能被依赖
# masked 禁止建立启动链接
systemctl list-unit-files
```

#### 依赖关系

```bash
# 查询target下的service
systemctl list-dependencies multi-user.target

systemctl list-dependencies nginx.service

systemctl list-dependencies --all nginx.service
```

#### 服务状态确认

```bash
# 帮助确认状态
# 显示某个 Unit 是否正在运行
systemctl is-active nginx.service
# 显示某个 Unit 是否处于启动失败状态
systemctl is-failed nginx.service
# 显示某个 Unit 服务是否建立了启动链接
systemctl is-enabled nginx.service
```

### journal 日志

`journald`的配置文件路径`/etc/systemd/journald.conf`, **建议设置比较小, 因为会影响 systemctl 的速度**

```ini
[Journal]
# 最大保存200M,默认最大4G.或者存储空间的10%
SystemMaxUse=200M
# 最多保留1天.默认为0.
MaxRetentionSec=1day

# 重启生效
systemctl status systemd-journald
```

常用命令如下:

```bash
# 滚动查看日志
journalctl -u nginx.service -f

# 日志空间占用
journalctl --disk-usage
# 自动清理,默认是4G /etc/systemd/journald.conf
SystemMaxUse=10G
systemctl restart systemd-journald

# 手动清理
# 通常日志会存放在这样的目录里
/var/log/journal/2195e6a94ece4443abc39350bd0f8b5f
# 进入以后,手动清空所有日志
:>system.journal

# 保留1秒, 2d 保留2天 1w 保留一周
journalctl --vacuum-time=1s
# 保留500m
journalctl --vacuum-size=500M
```

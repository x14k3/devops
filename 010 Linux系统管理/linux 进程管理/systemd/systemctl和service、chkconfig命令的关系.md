# systemctl和service、chkconfig命令的关系

　　‍

# systemctl和service、chkconfig命令的关系

* systemctl命令：是一个systemd工具，主要负责控制systemd系统和服务管理器。
* service命令：可以启动、停止、重新启动和关闭系统服务，还可以显示所有系统服务的当前状态。
* chkconfig命令：是管理系统服务(service)的命令行工具。所谓系统服务(service)，就是随系统启动而启动，随系统关闭而关闭的程序。

　　**systemctl命令是系统服务管理器指令，它实际上将 service 和 chkconfig 这两个命令组合到一起。**

　　**systemctl是RHEL 7 的服务管理工具中主要的工具，它融合之前service和chkconfig的功能于一体。可以使用它永久性或只在当前会话中启用/禁用服务。**

　　**所以systemctl命令是service命令和chkconfig命令的集合和代替。**

　　例如：使用service启动服务实际上也是调用systemctl命令。

```
[root@localhost ~]# service httpd start
Redirecting to /bin/systemctl start  httpd.service
```

# systemctl命令的用法

## Systemctl命令简介

　　Systemctl是一个systemd工具，主要负责控制systemd系统和服务管理器。

　　Systemd是一个系统管理守护进程、工具和库的集合，用于取代System V初始进程。Systemd的功能是用于集中管理和配置类UNIX系统。

　　systemd即为system daemon,是linux下的一种init软件。

## Systemctl命令常见用法

```bash
#列出所有可用单元
systemctl list-unit-files 
#列出所有可用单元
systemctl list-units
#列出所有失败单元
systemctl --failed 
#检查某个单元是否启动
systemctl is-enabled httpd.service 
#检查某个服务的运行状态
systemctl status httpd.service   
#列出所有服务
systemctl list-unit-files --type=service
#启动，停止，重启服务等
systemctl restart httpd.service
#查询服务是否激活，和配置是否开机启动
systemctl is-active httpd
#使用systemctl命令杀死服务
systemctl kill httpd
#列出系统的各项服务，挂载，设备等
systemctl list-unit-files --type 
#获得系统默认启动级别和设置默认启动级别
systemctl get-default
#启动运行等级
systemctl isolate multiuser.target
#重启、停止，挂起、休眠系统等
systemctl reboot
systemctl halt
systemctl suspend
systemctl hibernate
systemctl hybrid-sleep

```

# Service命令用法

　　service命令可以启动、停止、重新启动和关闭系统服务，还可以显示所有系统服务的当前状态。

　　service命令的作用是去/etc/init.d目录下寻找相应的服务，进行开启和关闭等操作。

```bash
#开启关闭一个服务
service httpd start/stop
#查看系统服务的状态
service –status-all
```

# chkconfig命令用法

　　chkconfig是管理系统服务(service)的命令行工具。所谓系统服务(service)，就是随系统启动而启动，随系统关闭而关闭的程序。

　　chkconfig可以更新(启动或停止)和查询系统服务(service)运行级信息。更简单一点，chkconfig是一个用于维护/etc/rc[0-6].d目录的命令行工具。

```bash
[root@localhost ~]# chkconfig  --help
chkconfig 版本 1.7.2 - 版权 (C) 1997-2000 红帽公司
在 GNU 公共许可条款下，本软件可以自由重发行。

用法：   chkconfig [--list] [--type <类型>] [名称]

chkconfig  --add       <名称>
chkconfig  --del       <名称>
chkconfig  --override  <名称>
chkconfig  [--level    <级别>]   [--type <类型>]   <名称>   <on|off|reset|resetpriorities>
```

　　1）设置service开机是否启动

```bash
chkconfig name on/off/reset

- on、off、reset用于改变service的启动信息。
- on表示开启，off表示关闭，reset表示重置。
- 默认情况下，on和off开关只对运行级2，3，4，5有效，reset可以对所有运行级有效。

[root@localhost ~]# chkconfig httpd on
注意：正在将请求转发到“systemctl enable httpd.service”。
```

> 在Redhat7上，运行chkconfig命令，都会被转到systemcle命令上。

　　2）设置service运行级别

```bash
chkconfig --level levels
该命令可以用来指定服务的运行级别，即指定运行级别2,3,4,5等。

    等级0表示：表示关机
    等级1表示：单用户模式
    等级2表示：无网络连接的多用户命令行模式
    等级3表示：有网络连接的多用户命令行模式
    等级4表示：不可用
    等级5表示：带图形界面的多用户模式
    等级6表示：重新启动

[root@localhost ~]# chkconfig --level 5 httpd on
注意：正在将请求转发到“systemctl enable httpd.service”
```

　　3）列出service启动信息

```bash
 chkconfig --list [name]

如果不指定name，会列出所有services的信息。
每个service每个运行级别都会有一个启动和停止脚本；当切换运行级别时，init不会重启已经启动的service，也不会重新停止已经停止的service。
```

　　‍

# update-rc.d命令用法

　　update-rc.d 是一个 Ubuntu 和 Debian 下的工具程序，用来添加和移除 System-V 类型的启动脚本。
这些脚本都叫做「System-V init script」，且以实际文件而不是链接文件的方式存储在 /etc/init.d 目录下。（之所以强调实际文件后文会解释原因）
其他的 Linux 发行版（例如红帽）使用 chkconfig 这个命令。
update-rc.d 就是通过管理 /etc/init.d 目录下的脚本文件来管理系统启动时的计划任务的，例如 ssh 服务、Apache 服务、MySQL 服务等。

　　因此 /etc/init.d 目录就是系统的启动脚本所在的目录，其中的每一个文件都是一个启动脚本，都代表了某一类应用程序服务。除非我们要手动编写启动脚本，否则我们不需要修改这个目录下的文件，在安装一些需要开机启动的应用程序的时候对应的脚本会自动被添加进去。

　　而系统还有另外一类目录叫 /etc/rcX.d，X 代表了 Linux 系统的运行级别。总共有 7 种运行级别，因此就有 7 个 /etc/rcX.d 目录（例如 /etc/rc5.d、/etc/rc0.d）。

　　/etc/rcX.d 目录下都是一些符号链接文件，这些链接文件都指向 /etc/init.d 目录下的脚本文件，命名规则为 K+NN+服务名或 S+NN+服务名，其中 NN 为两位数字。系统会根据指定的运行级别进入对应的 /etc/rcX.d 目录，并按照文件名顺序检索目录下的链接文件。
– 对于以 K 开头的文件，系统将终止对应的服务
– 对于以 S 开头的文件，系统将启动对应的服务

　　所以，到这而 Linux 启动项的内部实现就大致明晰了：

　　如果在某一运行级别下，对应的 /etc/rcX.d 下的链接文件决定了启动时系统对于这些脚本所采取的行动。换句话说，修改 /etc/rcX.d 下的文件可完成系统启动项的配置。但是这样的方法过于繁琐，所以才有了 update-rc.d 命令，它通过直接检索脚本名称和相应的参数来快速管理这些启动脚本。

　　总结起来就是：

1. /etc/init.d 目录下存放系统启动时执行的脚本
2. /etc/rcX.d 目录下存放脚本在不同运行级别下的链接文件
3. 通过修改 /etc/rcX.d 目录可完成 Linux 下启动脚本的配置
4. 通过 update-rc.d 命令快速实现上一条描述的情况

　　**update-rc.d 命令的脚本管理**

　　使用 update-rc.d 命令需要指定脚本名称和一些参数，它的格式看起来是这样的（需要在 root 权限下）：

```
update-rc.d [-n] [-f] <basename> remove
update-rc.d [-n] <basename> defaults
update-rc.d [-n] <basename> disable|enable [S|2|3|4|5]
update-rc.d <basename> start|stop <NN> <runlevels>
-n: not really
-f: force
```

　　其中：
disable|enable 代表脚本还在 /etc/init.d 中，并设置当前状态是手动启动还是自动启动。
start|stop 代表脚本还在 /etc/init.d 中，开机，并设置当前状态是开始运行还是停止运行。（启用后可配置开始运行与否）
NN 是一个决定启动顺序的两位数字值。（例如 90 大于 80，因此 80 对应的脚本先启动或先停止）
runlevels 则指定了运行级别。

　　例如，添加一个新的启动脚本 sample_init_script，并且指定为默认启动顺序、默认运行级别(要有实际的文件存在于 /etc/init.d，即若文件 /etc/init.d/sample_init_script 不存在，则该命令不会执行):

```
$ update-rc.d sample_init_script defaults
# 上一条命令等效于（中间是一个英文句点符号）：

$ update-rc.d sample_init_script start 20 2 3 4 5 . stop 20 0 1 6
```

　　安装一个启动脚本 sample_init_script，指定默认运行级别，但启动顺序为 50：

```
$ update-rc.d sample_init_script defaults 50
```

　　安装两个启动脚本 A、B，让 A 先于 B 启动，后于 B 停止：

```
$ update-rc.d A 10 40
$ update-rc.d B 20 30
```

　　删除一个启动脚本 sample_init_script，如果脚本不存在则直接跳过：

```
$ update-rc.d -f sample_init_script remove
```

　　这一条命令实际上做的就是一一删除所有位于 /etc/rcX.d 目录下指向 /etc/init.d 中 sample_init_script 的链接（可能存在多个链接文件），update-rc.d 只不过简化了这一步骤。

　　Update: 如果只是需要使用 service <basename> start/stop/status, 只需要将 basename 的 init script 放到 /etc/init.d 下即可, 不需要通过update-rc.d注册

　　Update 2017-11-13: 对于通过mysql官方deb包安装的mysql5.7, 使用update-rc.d mysql remove无效, 可以使用 sudo systemctl disable mysql 来禁止mysql开机自启动

　　‍

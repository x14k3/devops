# systemd 运行级别

　　在CentOS 6及之前的版本中有运行级别的概念，Systemd系统内没有直接定义运行级别的概念，但是通过Target Unit兼容模拟了运行级别。

　　可以查看/usr/lib/systemd/system/下的一些target文件。为了节省篇幅，下面我列出了部分target：

```bash
$ ls -l /usr/lib/systemd/system/*.target | grep -o '/.*' 

# /usr/lib/systemd/system/下定义的默认运行级别：graphical
/usr/lib/systemd/system/default.target -> graphical.target

# 运行级别0-6，注意多用户模式为multi-user.target
/usr/lib/systemd/system/runlevel0.target -> poweroff.target
/usr/lib/systemd/system/runlevel1.target -> rescue.target
/usr/lib/systemd/system/runlevel2.target -> multi-user.target
/usr/lib/systemd/system/runlevel3.target -> multi-user.target
/usr/lib/systemd/system/runlevel4.target -> multi-user.target
/usr/lib/systemd/system/runlevel5.target -> graphical.target
/usr/lib/systemd/system/runlevel6.target -> reboot.target

# 紧急模式、救援模式、多用户模式和图形界面模式
/usr/lib/systemd/system/emergency.target
/usr/lib/systemd/system/rescue.target
/usr/lib/systemd/system/multi-user.target
/usr/lib/systemd/system/graphical.target

# 关机和重启相关操作
/usr/lib/systemd/system/halt.target
/usr/lib/systemd/system/poweroff.target
/usr/lib/systemd/system/shutdown.target
/usr/lib/systemd/system/reboot.target
/usr/lib/systemd/system/ctrl-alt-del.target -> reboot.target

```

　　注意上面有一个`/usr/lib/systemd/system/default.target`​指向graphical.target，但它不 一定就是默认运行级别，因为有可能/etc/systemd/system下也有一个default.target。

```bash
$readlink/etc/systemd/system/default.target
/lib/systemd/system/multi-user.target
```

　　因为/etc/systemd/system下的unit都是开机时加载的，所以『优先级』更高。这意味着上面的示例表示默认运行级别为multi-user.target，而非graphical.target。

　　target是如何模拟运行级别的呢？理解了运行级别的本质含义后，就很容易理解了。所谓运行级别，无非是定义几种系统的运行模式，在不同运行模式下，启动不同服务或执行不同程序。比如图形界面下会运行图形界面服务。

　　而target的主要作用是对服务进行分组、归类。所以，只需要定义几个代表不同运行级别的target，并在不同的target中放入不同的服务程序即可(除了服务程序还可以包含其它的Unit)。

　　target又是如何对服务进行分组、归类的呢？作为初步了解，可在/etc/systemd/system中寻找答案。在此目录下，有一些`*.target.wants`​目录，该目录定义了该target中包含了哪些Unit，systemd会在处理到对应target时会寻找wants后缀的目录，并加载启动该目录下的所有Unit，这就是target对服务(及其它Unit)分组的方式。

　　例如：

```bash
$ ls -1F /etc/systemd/system/
basic.target.wants/
default.target@
default.target.wants/
getty.target.wants/
local-fs.target.wants/
multi-user.target.wants/
nginx.service.d/
remote-fs.target.wants/
sockets.target.wants/
sysinit.target.wants/
system-update.target.wants/

# 系统环境初始化相关服务
$ ls -1 /etc/systemd/system/sysinit.target.wants/
cgconfig.service
lvm2-lvmetad.socket
lvm2-lvmpolld.socket
lvm2-monitor.service
rhel-autorelabel-mark.service
rhel-autorelabel.service
rhel-domainname.service
rhel-import-state.service
rhel-loadmodules.service

# 多用户模式下开机自启动的服务
$ ls -1 /etc/systemd/system/multi-user.target.wants/
auditd.service
crond.service
irqbalance.service
mysqld.service
nfs-client.target
postfix.service
remote-fs.target
rhel-configure.service
rpcbind.service
rsyslog.service
sshd.service
tuned.service

```

　　之所以有这些wants目录，并且其中有一些Unit文件，是因为在Service配置文件(或其它Unit)中的`[Install]`​段落使用了`WantedBy`​指令。例如：

```bash
$ cat /usr/lib/systemd/system/sshd.service
[Unit]
......

[Service]
......

[Install]
WantedBy=multi-user.target

```

　　当使用`systemctl enable Unit_Name`​让Unit_Name开机自启动时，会寻找该`[Install]`​中的WantedBy和RequiredBy，并在对应的`/etc/systemd/system/xxx.target.wants`​或`/etc/systemd/system/xxx.target.requires`​目录下创建软链接。

　　如果Service配置文件中没有定义WantedBy和RequiredBy，则`systemctl enable`​操作不会有任何效果。

　　此外，可以在target配置文件内部使用`Wants、Requires`​等表示依赖含义的指令来定义该target依赖哪些Unit。

　　例如：

```bash
$ cat /usr/lib/systemd/system/sysinit.target
[Unit]
Description=System Initialization
Documentation=man:systemd.special(7)
Conflicts=emergency.service emergency.target
Wants=local-fs.target swap.target   # 看此行

```

　　​`.target`​文件中`Wants`​指令定义的更符合依赖的含义，而`.target.wants`​目录更倾向于表明该target中归类了哪些要运行的服务。

　　比如负责系统环境初始化的sysinit.target，其中的Wants指令定义了必须先运行且成功运行文件系统相关任务(local-fs.target和swap.target)后才运行sysinit.target，也就是开始启动`.target.wants`​目录下的Unit。

　　执行`systemctl list-units --type target`​可以查看系统当前已经加载的所有target，包括那些开机自启动过程中启动的。

```bash
$ systemctl list-units --type target
UNIT                  LOAD   ACTIVE SUB    DESCRIPTION
basic.target          loaded active active Basic System
cryptsetup.target     loaded active active Local Encrypted Volumes
getty.target          loaded active active Login Prompts
local-fs-pre.target   loaded active active Local File Systems (Pre)
local-fs.target       loaded active active Local File Systems
multi-user.target     loaded active active Multi-User System
network-online.target loaded active active Network is Online
network-pre.target    loaded active active Network (Pre)
network.target        loaded active active Network
paths.target          loaded active active Paths
remote-fs.target      loaded active active Remote File Systems
slices.target         loaded active active Slices
sockets.target        loaded active active Sockets
swap.target           loaded active active Swap
sysinit.target        loaded active active System Initialization
timers.target         loaded active active Timers

```

　　除了上面展示的target，在/usr/lib/systemd/system目录下还有很多target。而且，只要用户想要对一类Unit进行分组归类，那么也可以自己定义target。

　　但需要明确的是，**target可分为两类**：

* 可直接切换的target(模拟运行级别)
* 不可直接切换的target

　　切换是什么意思？比如从当前的运行级别3切换到运行级别5，将会启动运行级别5上的所有程序以及依赖程序，并停止当前已启动但运行级别5不需要的服务程序。这就是运行级别的切换，只是停止一些服务(或程序)、并启动另外一些服务而已。

　　切换target也一样，比如切换到graphical.target时，会启动目标graphical.target需要的所有服务，并停止当前已运行但目标target不需要的服务。

　　切换target的方式如下：

```bash
# 切换到对应的target
systemctl isolate Target_Name
# 如：
systemctl isolate default.target  # 切换到默认运行级别
systemctl isolate rescue.target   # 切换到救援模式

# 还支持如下命令
systemctl default
systemctl resuce
systemctl emergency
systemctl halt
systemctl poweroff
systemctl reboot

```

　　可查看或设置默认的运行级别：

```bash
systemctl get-default
systemctl set-default Target_Name

```

　　设置默认运行级别，实际上是创建/etc/systemd/system/default.target指向对应target配置文件的软链接。

　　比如：

```bash
$ systemctl set-default multi-user.target
Removed symlink /etc/systemd/system/default.target.
Created symlink from /etc/systemd/system/default.target to /usr/lib/systemd/system/multi-user.target.

```

　　target是否可直接切换，取决于target配置文件中是否定义了`AllowIsolate=yes`​指令。比如multi-user.target是模拟运行级别的target，肯定允许直接切换，而network.target定义的是网络启动任务，肯定不可以直接切换。

```bash
# 等价于cat /usr/lib/systemd/system/multi-user.target
$ systemctl cat multi-user.target 
# /lib/systemd/system/multi-user.target

[Unit]
Description=Multi-User System
Documentation=man:systemd.special(7)
Requires=basic.target
Conflicts=rescue.service rescue.target
After=basic.target rescue.service rescue.target
AllowIsolate=yes

# 查看Unit的属性值
$ systemctl show -p AllowIsolate network.target
AllowIsolate=no

```

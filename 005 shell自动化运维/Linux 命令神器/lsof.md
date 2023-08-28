# lsof

lsof(list open files)是一个列出当前系统打开文件的工具。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。所以如传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符，无论这个文件的本质如何，该文件描述符为应用程序与基础操作系统之间的交互提供了通用接口。因为应用程序打开文件的描述符列表提供了大量关于这个应用程序本身的信息，因此通过lsof工具能够查看这个列表对系统监测以及排错将是很有帮助的。

## 1. **输出信息含义**

在终端下输入lsof即可显示系统打开的文件，因为 lsof 需要访问核心内存和各种文件，所以必须以 root 用户的身份运行它才能够充分地发挥其功能。

直接输入lsof部分输出为:

```bash
COMMAND     PID        USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
init          1        root  cwd       DIR                8,1     4096          2 /
init          1        root  rtd       DIR                8,1     4096          2 /
init          1        root  txt       REG                8,1   150584     654127 /sbin/init
udevd       415        root    0u      CHR                1,3      0t0       6254 /dev/null
udevd       415        root    1u      CHR                1,3      0t0       6254 /dev/null
udevd       415        root    2u      CHR                1,3      0t0       6254 /dev/null
udevd       690        root  mem       REG                8,1    51736     302589 /lib/x86_64-linux-gnu/libnss_files-2.13.so
syslogd    1246      syslog    2w      REG                8,1    10187     245418 /var/log/auth.log
syslogd    1246      syslog    3w      REG                8,1    10118     245342 /var/log/syslog
dd         1271        root    0r      REG                0,3        0 4026532038 /proc/kmsg
dd         1271        root    1w     FIFO               0,15      0t0        409 /run/klogd/kmsg
dd         1271        root    2u      CHR                1,3      0t0       6254 /dev/null
```

每行显示一个打开的文件，若不指定条件默认将显示所有进程打开的所有文件。

lsof输出各列信息的意义如下：

* COMMAND：进程的名称 PID：进程标识符
* USER：进程所有者
* FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等 TYPE：文件类型，如DIR、REG等
* DEVICE：指定磁盘的名称
* SIZE：文件的大小
* NODE：索引节点（文件在磁盘上的标识）
* NAME：打开文件的确切名称

FD 列中的文件描述符

* cwd：值表示应用程序的当前工作目录，这是该应用程序启动的目录，除非它本身对这个目录进行更改
* txt：类型的文件是程序代码，如应用程序二进制文件本身或共享库，如上列表中显示的 /sbin/init 程序
* mem：内存映射文件
* rtd：进程的根目录
* N(u/w/r)：指示该文件为进程打开的第N个文件描述符，u为可读可写模式，w为可写模式，r为可读模式

TYPE 列有以下常见取值

* ​​REG：一般文件
* DIR：目录
* CHR：字符设备
* BLK：块设备
* FIFO：​命名管道
* PIPE：管道
* IPV4：ipv4套接字
* unix：unix域套接字

## 2. **常用参数**

lsof语法格式是：`lsof ［options］ filename`​

```
lsof -a <文件>    列出打开文件的进程
lsof -c <进程名>  列出指定进程所打开的文件
lsof -g          列出GID号进程详情
lsof -d <文件号>  列出占用该文件号的进程
lsof +d <目录>    列出目录下被打开的文件
lsof +D <目录>    递归列出目录下被打开的文件
lsof -n          不将IP转换为hostname，缺省是不加上-n参数
lsof -p <进程号>  列出指定进程号所打开的文件
lsof -u          列出UID号进程详情
lsof -h          显示帮助信息
lsof -v          显示版本信息
lsof -i          用以显示符合条件的进程情况
lsof -i[46] [protocol][@hostname|hostaddr][:service|port]
  46 --> IPv4 or IPv6
  protocol --> TCP or UDP
  hostname --> Internet host name
  hostaddr --> IPv4地址
  service --> /etc/service中的 service name (可以不止一个)
  port --> 端口号 (可以不止一个)
```

‍

## 3. 使用操作

### 3.1 **查询某个文件被哪些进程打开**

```bash
root@OptiPlex-3000:/data/virthost# lsof /var/log/syslog
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
rsyslogd 820 syslog    7w   REG  253,0  2585793 5242990 /var/log/syslog
root@OptiPlex-3000:/data/virthost# 
```

要删除文件时要先中止进程，而不是直接删除这个文件。

在umount文件系统时，如果文件系统中有打开的文件，那么umount操作会失败，报“device is busy”。这时可使用”lsof /dev/sdaX”显示sdaX文件系统中被打开的所有文件，再关闭所列文件。

进程的当前工作目录影响文件系统的卸载，这也是为什么在编写后台进程时需要将其工作目录设置为根目录的原因，

### 3.2 **恢复删除文件**

某文件被删除，但从lsof能查到该文件仍被某进程打开，这时我们可以恢复被删文件。

```bash
root@OptiPlex-3000:/data/virthost# lsof /var/log/syslog
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
rsyslogd 820 syslog   7w   REG  253,0  2585793 5242990 /var/log/syslog
root@OptiPlex-3000:/data/virthost# rm -rf /var/log/syslog
root@OptiPlex-3000:/data/virthost# lsof |grep /var/log/syslog
rsyslogd     820                           syslog    7w      REG              253,0    2586044    5242990 /var/log/syslog (deleted)
rsyslogd     820    877 in:imuxso          syslog    7w      REG              253,0    2586044    5242990 /var/log/syslog (deleted)
rsyslogd     820    878 in:imklog          syslog    7w      REG              253,0    2586044    5242990 /var/log/syslog (deleted)
rsyslogd     820    879 rs:main            syslog    7w      REG              253,0    2586044    5242990 /var/log/syslog (deleted)
```

从上面的信息可以看到 PID 820（syslogd）打开文件的文件描述符为  7。同时还可以看到`/var/log/syslog`​已经标记被删除了。因此我们可以在 `/proc/820/fd/7`​  （fd下的每个以数字命名的文件表示进程对应的文件描述符）中查看相应的信息，如下：

```bash
root@OptiPlex-3000:/data/virthost# head -n 10 /proc/820/fd/7
Aug 13 00:00:07 OptiPlex-3000 systemd[1]: rsyslog.service: Sent signal SIGHUP to main process 820 (rsyslogd) on client request.
Aug 13 00:00:07 OptiPlex-3000 systemd[1]: logrotate.service: Deactivated successfully.
Aug 13 00:00:07 OptiPlex-3000 systemd[1]: Finished Rotate log files.
Aug 13 00:05:18 OptiPlex-3000 systemd[1]: Starting Message of the Day...
Aug 13 00:05:18 OptiPlex-3000 systemd[1]: motd-news.service: Deactivated successfully.
Aug 13 00:05:18 OptiPlex-3000 systemd[1]: Finished Message of the Day.
Aug 13 00:06:58 OptiPlex-3000 tailscaled[8190]: control: NetInfo: NetInfo{varies=false hairpin=false ipv6=false ipv6os=true udp=true icmpv4=false derp=#7 portmap=active- link=""}
Aug 13 00:07:29 OptiPlex-3000 tailscaled[8190]: control: NetInfo: NetInfo{varies=false hairpin=false ipv6=false ipv6os=true udp=true icmpv4=false derp=#7 portmap=active-U link=""}
Aug 13 00:10:21 OptiPlex-3000 tailscaled[8190]: Received error: PollNetMap: unexpected EOF
Aug 13 00:10:32 OptiPlex-3000 tailscaled[8190]: health("overall"): error: not in map poll
root@OptiPlex-3000:/data/virthost# 
```

从上面的信息可以看出，查看 `/proc/820/fd/7`​ 就可以得到所要恢复的数据。如果可以通过文件描述符查看相应的数据，那么就可以使用 I/O 重定向将其复制到文件中，如:

```bash
root@OptiPlex-3000:/data/virthost# cat /proc/820/fd/7 > /var/log/syslog
root@OptiPlex-3000:/data/virthost# systemctl restart syslog
```

### 3.3 文件删除空间却未释放

在Linux或者Unix系统中，通过rm或者文件管理器删除文件将会从文件系统的目录结构上解除链接(unlink)，然而如果文件是被打开的（有一个进程正在使用），那么进程将仍然可以读取该文件，磁盘空间也一直被占用，这样就会导致我们明明删除了文件，但是磁盘空间却未被释放

1. 首先获得一个已经被删除但是仍然被应用程序占用的文件列表

    ```bash
    root@OptiPlex-3000:/var/log# lsof | grep deleted
    unattende    955                             root    3w      REG              253,0        113    5374127 /var/log/unattended-upgrades/unattended-upgrades-shutdown.log.1 (deleted)
    unattende    955   1041 gmain                root    3w      REG              253,0        113    5374127 /var/log/unattended-upgrades/unattended-upgrades-shutdown.log.1 (deleted)
    pipewire    1892                              sds  txt       REG              253,0      14720    1311608 /usr/bin/pipewire (deleted)
    pipewire    1892                              sds   25u      REG                0,1       2312       7171 /memfd:pipewire-memfd (deleted)
    pipewire    1892                              sds   28u      REG                0,1       2312       7172 /memfd:pipewire-memfd (deleted)
    pipewire    1892   2012 pipewire              sds  txt       REG              253,0      14720    1311608 /usr/bin/pipewire (deleted)
    pipewire    1892   2012 pipewire              sds   25u      REG                0,1       2312       7171 /memfd:pipewire-memfd (deleted)
    pipewire    1892   2012 pipewire              sds   28u      REG                0,1       2312       7172 /memfd:pipewire-memfd (deleted)
    pipewire-   1893                              sds  txt       REG              253,0     408320    1311609 /usr/bin/pipewire-media-session (deleted)
    pipewire-   1893   1989 pipewire-             sds  txt       REG              253,0     408320    1311609 /usr/bin/pipewire-media-session (deleted)
    root@OptiPlex-3000:/var/log# 
    ```

2. 如何让进程释放文件，进而释放磁盘空间：

    kill掉相应的进程，或者停掉使用这个文件的应用，让os自动回收磁盘空间 `systemctl restart syslogd`​

‍

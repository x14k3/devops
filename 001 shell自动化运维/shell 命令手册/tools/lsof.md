# lsof

　　在 CentOS/Fedora/RHEL 版本的 Linux 中则使用下面的命令进行安装。

```bash
yum install lsof
```

　　​`lsof`​也是有着最多选项的 Linux/Unix 命令之一。`lsof`​可以查看打开的文件是：

* 普通文件
* 目录
* 网络文件系统的文件
* 字符或设备文件
* (函数) 共享库
* 管道、命名管道
* 符号链接
* 网络文件（例如：NFS file、网络 socket，unix 域名 socket）
* 还有其它类型的文件，等等

　　虽然`lsof`​命令有着 N 多的选项，但是常用的只有以下几个：

* ​`-a`​：使用 AND 逻辑，合并选项输出内容
* ​`-c`​：列出名称以指定名称开头的进程打开的文件
* ​`-d`​：列出打开指定文件描述的进程
* ​`+d`​：列出目录下被打开的文件
* ​`+D`​：递归列出目录下被打开的文件
* ​`-n`​：列出使用 NFS 的文件
* ​`-u`​：列出指定用户打开的文件
* ​`-p`​：列出指定进程号所打开的文件
* ​`-i`​：列出打开的套接字

　　​​

　　总的说来，`lsof`​命令还是一个比较复杂的命令，那么多选项，用起来还是蛮累的，但是这不能否定它是一个出色的工具，一个我们不得不学习的命令。下面就来说一些`lsof`​的惯用用法。 – 命令：

　　​`lsof`​

　　输出：

```
COMMAND     PID   TID    USER   FD      TYPE             DEVICE   SIZE/OFF       NODE NAME
systemd       1          root  cwd       DIR              253,1       4096          2 /
systemd       1          root  rtd       DIR              253,1       4096          2 /
systemd       1          root  txt       REG              253,1    1523568    1053845 /usr/lib/systemd/systemd
systemd       1          root  mem       REG              253,1      20040    1050452 /usr/lib64/libuuid.so.1.3.0
systemd       1          root  mem       REG              253,1     261336    1051899 /usr/lib64/libblkid.so.1.1.0
systemd       1          root  mem       REG              253,1      90664    1050435 /usr/lib64/libz.so.1.2.7
systemd       1          root  mem       REG              253,1     157424    1050447 /usr/lib64/liblzma.so.5.2.2
systemd       1          root  mem       REG              253,1      23968    1050682 /usr/lib64/libcap-ng.so.0.0.0
systemd       1          root  mem       REG              253,1      19888    1050666 /usr/lib64/libattr.so.1.1.0
```

　　输出内容详解：

* ​`COMMAND`​：进程的名称
* ​`PID`​：进程标识符
* ​`TID`​：线程标识符
* ​`USER`​：进程所有者
* ​`FD`​：文件描述符，应用程序通过文件描述符识别该文件，一般有以下取值：

  * ​`cwd`​：表示 current work dirctory，即：应用程序的当前工作目录，这是该应用程序启动的目录
  * ​`txt`​：该类型的文件是程序代码，如应用程序二进制文件本身或共享库
  * ​`lnn`​：library references (AIX)
  * ​`er`​：FD information error (see NAME column)
  * ​`jld`​：jail directory (FreeBSD)
  * ​`ltx`​：shared library text (code and data)
  * ​`mxx`​：hex memory-mapped type number xx
  * ​`m86`​：DOS Merge mapped file
  * ​`mem`​：memory-mapped file
  * ​`mmap`​：memory-mapped device
  * ​`pd`​：parent directory
  * ​`rtd`​：root directory
  * ​`tr`​：kernel trace file (OpenBSD)
  * ​`v86`​：VP/ix mapped file
  * ​`0`​：表示标准输出
  * ​`1`​：表示标准输入
  * ​`2`​：表示标准错误
* ​`TYPE`​：文件类型，常见的文件类型有以下几种：

  * ​`DIR`​：表示目录
  * ​`CHR`​：表示字符类型
  * ​`BLK`​：块设备类型
  * ​`UNIX`​：UNIX 域套接字
  * ​`FIFO`​：先进先出 (FIFO) 队列
  * ​`IPv4`​：网际协议 (IP) 套接字
* ​`DEVICE`​：指定磁盘的名称
* ​`SIZE/OFF`​：文件的大小
* ​`NODE`​：索引节点（文件在磁盘上的标识）
* ​`NAME`​：打开文件的确切名称

  * 命令：`lsof abc.txt`​ 说明：显示开启文件 abc.txt 的进程
  * 命令：`lsof -i :80`​​ 说明：列出 80 端口目前打开的文件列表

  * 命令：`lsof -i tcp`​ 说明：列出所有的 TCP 网络连接信息
  * 命令：`lsof -i udp`​ 说明：列出所有的 UDP 网络连接信息
  * 命令：`lsof -i tcp:80`​ 说明：列出 80 端口 TCP 协议的所有连接信息
  * 命令：`lsof -i udp:25`​ 说明：列出 25 端口 UDP 协议的所有连接信息
  * 命令：`lsof -c ngin`​ 说明：列出以 ngin 开头的进程打开的文件列表
  * 命令：`lsof -p 20711`​ 说明：列出指定进程打开的文件列表
  * 命令：`lsof -u uasp`​ 说明：列出指定用户打开的文件列表
  * 命令：`lsof -u uasp -i tcp`​ 说明：将所有的 TCP 网络连接信息和指定用户打开的文件列表信息一起输出
  * 命令：`lsof -a -u uasp -i tcp`​ 说明：将指定用户打开的文件列表信息，同时是 TCP 网络连接信息的一起输出；注意和上一条命令进行对比
  * 命令：`lsof +d /usr/local/`​ 说明：列出目录下被进程打开的文件列表
  * 命令：`lsof +D /usr/local/`​ 说明：递归搜索目录下被进程打开的文件列表
  * 命令：`lsof -i @peida.linux:20,21,22,25,53,80 -r 3`​ 说明：列出目前连接到主机 peida.linux 上端口为 20，21，22，25，53，80 相关的所有文件信息，且每隔 3 秒不断的执行`lsof`​指令

　　‍

## 使用操作

### 1. **查询某个文件被哪些进程打开**

```bash
root@OptiPlex-3000:/data/virthost# lsof /var/log/syslog
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
rsyslogd 820 syslog    7w   REG  253,0  2585793 5242990 /var/log/syslog
root@OptiPlex-3000:/data/virthost# 
```

　　要删除文件时要先中止进程，而不是直接删除这个文件。

　　在umount文件系统时，如果文件系统中有打开的文件，那么umount操作会失败，报“device is busy”。这时可使用”lsof /dev/sdaX”显示sdaX文件系统中被打开的所有文件，再关闭所列文件。

　　进程的当前工作目录影响文件系统的卸载，这也是为什么在编写后台进程时需要将其工作目录设置为根目录的原因，

### 2. **恢复删除文件**

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

### 3. 文件删除空间却未释放

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

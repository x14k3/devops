
kill 从字面来看，就是用来杀死进程的命令，但事实上，这个或多或少带有一定的误导性。从本质上讲，kill 命令只是用来向进程发送一个信号，至于这个信号是什么，是用户指定的。

也就是说，kill 命令的执行原理是这样的，kill 命令会向操作系统内核发送一个信号（多是终止信号）和目标进程的 PID，然后系统内核根据收到的信号类型，对指定进程进行相应的操作。

kill 命令的基本格式如下：

```bash
[root@localhost ~]# kill [信号] PID
```

kill 命令是按照 PID 来确定进程的，所以 kill 命令只能识别 PID，而不能识别进程名。Linux 定义了几十种不同类型的信号，读者可以使用 kill -l 命令查看所有信号及其编号，这里仅列出几个常用的信号，如表 1 所示。

|信号编号|信号名|含义|
| ----------| --------| ----------------------------------------------------------------------------------------|
|0|EXIT|程序退出时收到该信息。|
|1|HUP|挂掉电话线或终端连接的挂起信号，这个信号也会造成某些进程在没有终止的情况下重新初始化。|
|2|INT|表示结束进程，但并不是强制性的，常用的 "Ctrl+C" 组合键发出就是一个 kill -2 的信号。|
|3|QUIT|退出。|
|9|KILL|杀死进程，即强制结束进程。|
|11|SEGV|段错误。|
|15|TERM|正常结束进程，是 kill 命令的默认信号。|

需要注意的是，表中省略了各个信号名称的前缀 SIG，也就是说，SIGTERM 和 TERM 这两种写法都对，kill 命令都可以理解。

下面，我们举几个例子来说明一下 kill 命令。

【例 1】 标准 kill 命令。

```bash
[root@localhost ~】# service httpd start
#启动RPM包默认安装的apache服务
[root@localhost ~]# pstree -p 丨 grep httpd | grep -v "grep"
#查看 httpd 的进程树及 PID。grep 命令査看 httpd 也会生成包含"httpd"关键字的进程，所以使用“-v”反向选择包含“grep”关键字的进程，这里使用 pstree 命令来查询进程，当然也可以使用 ps 和 top 命令
|-httpd(2246)-+-httpd(2247)
|    |-httpd(2248)
|    |-httpd(2249)
|    |-httpd(2250)
|    |-httpd(2251)
[root@localhost ~]# kill 2248
#杀死PID是2248的httpd进程，默认信号是15，正常停止
#如果默认信号15不能杀死进程，则可以尝试-9信号，强制杀死进程
[root@localhost ~]# pstree -p | grep httpd | grep -v "grep"
|-httpd(2246>-+-httpd(2247)
|    |-httpd(2249)
|    |-httpd(2250)
|    |-httpd(2251)
#PID是2248的httpd进程消失了
```

【例 2】使用“-1”信号，让进程重启。

```bash
[root@localhost ~]# kill -1 2246
使用“-1 (数字1)”信号，让httpd的主进程重新启动
[root@localhost ~]# pstree -p | grep httpd | grep -v "grep"
|-httpd(2246)-+-httpd(2270)
|    |-httpd(2271)
|    |-httpd(2272)
|    |-httpd(2273)
|    |-httpd(2274)
#子httpd进程的PID都更换了，说明httpd进程已经重启了一次
```

【例 3】 使用“-19”信号，让进程暂停。

```bash
[root@localhost ~]# vi test.sh #使用vi命令编辑一个文件，不要退出
[root@localhost ~]# ps aux | grep "vi" | grep -v "grep"
root 2313 0.0 0.2 7116 1544 pts/1 S+ 19:2.0 0:00 vi test.sh
#换一个不同的终端，查看一下这个进程的状态。进程状态是S（休眠）和+（位于后台），因为是在另一个终端运行的命令
[root@localhost ~]# kill -19 2313
#使用-19信号，让PID为2313的进程暂停。相当于在vi界面按 Ctrl+Z 快捷键
[root@localhost ~]# ps aux | grep "vi" | grep -v "grep"
root 2313 0.0 0.2 7116 1580 pts/1 T 19:20 0:00 vi test.sh
#注意2313进程的状态，变成了 T（暂停）状态。这时切换回vi的终端,发现vi命令已经暂停，又回到了命令提示符，不过2313进程就会卡在后台。如果想要恢复，可以使用"kill -9 2313”命令强制中止进程，也可以利用后续章节将要学习的工作管理来进行恢复
```

## Linux常用信号（进程间通信）及其含义

进程的管理主要是指进程的关闭与重启。我们一般关闭或重启软件，都是关闭或重启它的程序，而不是直接操作进程的。比如，要重启 apache 服务，一般使用命令"service httpd restart"重启 apache的程序。

那么，可以通过直接管理进程来关闭或重启 apache 吗？答案是肯定的，这时就要依赖进程的信号（Signal）了。我们需要给予该进程号，告诉进程我们想要让它做什么。

系统中可以识别的信号较多，我们可以使用命令"kill -l"或"man 7 signal"来查询。命令如下：

```bash
[root@localhost ~]#kill -l
1) SIGHUP 2) SIGINT 3) SIGQUIT 4) SIGILL 5) SIGTRAP
6) SIGABRT 7) SIGBUS 8) SIGFPE 9) SIGKILL 10) SIGUSR1
11)SIGSEGV 12) SIGUSR2 13) SIGPIPE 14) SIGALRM 15)SIGTERM 16) SIGSTKFLT 17) SIGCHLD 18) SIGCONT 19) SIGSTOP 20) SIGTSTP 21) SIGTTIN 22) SIGTTOU 23) SIGURG
24) SIGXCPU 25) SIGXFSZ 26) SIGVTALRM 27) SIGPROF 28) SIGWINCH 29) SIGIO 30) SIGPWR 31) SIGSYS 34) SIGRTMIN 35) SIGRTMIN+1 36) SIGRTMIN+2 37) SIGRTMIN+3 38) SIGRTMIN +4 39) SIGRTMIN +5 40) SIGRTMIN+6 41)SIGRTMIN+7 42) SIGRTMIN+8 43) SIGRTMIN +9 44) SIGRTMIN +10 45) SIGRTMIN+11 46) SIGRTMIN+1247) SIGRTMIN+13 48) SIGRTMIN +14 49) SIGRTMIN +15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12 53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9 56) SIGRTMAX-8 57) SIGRTMAX-7 58) SIGRTMAX-6 59) SIGRTMAX-5 60) SIGRTMAX-4 61) SIGRTMAX-3 62) SIGRTMAX-2 63) SIGRTMAX-1 64) SIGRTMAX
```

这里介绍一下常见的进程信号，如表 1 所示。

|信号代号|信号名称|说 明|
| ----------| ----------| -------------------------------------------------------------------------------------------------------------------------------------------------|
|1|SIGHUP|该信号让进程立即关闭.然后重新读取配置文件之后重启|
|2|SIGINT|程序中止信号，用于中止前台进程。相当于输出 Ctrl+C 快捷键|
|8|SIGFPE|在发生致命的算术运算错误时发出。不仅包括浮点运算错误，还包括溢出及除数为 0 等其他所有的算术运算错误|
|9|SIGKILL|用来立即结束程序的运行。本信号不能被阻塞、处理和忽略。般用于强制中止进程|
|14|SIGALRM|时钟定时信号，计算的是实际的时间或时钟时间。alarm 函数使用该信号|
|15|SIGTERM|正常结束进程的信号，kill 命令的默认信号。如果进程已经发生了问题，那么这 个信号是无法正常中止进程的，这时我们才会尝试 SIGKILL 信号，也就是信号 9|
|18|SIGCONT|该信号可以让暂停的进程恢复执行。本信号不能被阻断|
|19|SIGSTOP|该信号可以暂停前台进程，相当于输入 Ctrl+Z 快捷键。本信号不能被阻断|

‍

‍

## killall命令

killall 命令的基本格式如下：

```
 [root@localhost ~]# killall [选项] [信号] 进程名
```

 注意，此命令的信号类型同 kill 命令一样，因此这里不再赘述，此命令常用的选项有如下 2 个： *  -i：交互式，询问是否要杀死某个进程；

- -I：忽略进程名的大小写；

 接下来，给大家举几个例子。

【例 1】杀死 httpd 进程。

```bash
[root@localhost ~]# service httpd start
#启动RPM包默认安装的apache服务
[root@localhost ~]# ps aux | grep "httpd" | grep -v "grep"
root 1600 0.0 0.2 4520 1696? Ss 19:42 0:00 /usr/local/apache2/bin/httpd -k start
daemon 1601 0.0 0.1 4520 1188? S 19:42 0:00 /usr/local/apache2/bin/httpd -k start
daemon 1602 0.0 0.1 4520 1188? S 19:42 0:00 /usr/local/apache2/bin/httpd -k start
daemon 1603 0.0 0.1 4520 1188? S 19:42 0:00 /usr/local/apache2/bin/httpd -k start
daemon 1604 0.0 0.1 4520 1188? S 19:42 0:00 /usr/local/apache2/bin/httpd -k start
daemon 1605 0.0 0.1 4520 1188? S 19:42 0:00 /usr/local/apache2/bin/httpd -k start
#查看httpd进程
[root@localhost ~]# killall httpd
#杀死所有进程名是httpd的进程
[root@localhost ~]# ps aux | grep "httpd" | grep -v "grep"
#查询发现所有的httpd进程都消失了
```

【例 2】交互式杀死 sshd 进程。

```bash
[root@localhost ~]# ps aux | grep "sshd" | grep -v "grep"
root 1733 0.0 0.1 8508 1008? Ss 19:47 0:00/usr/sbin/sshd
root 1735 0.1 0.5 11452 3296? Ss 19:47 0:00 sshd: root@pts/0
root 1758 0.1 0.5 11452 3296? Ss 19:47 0:00 sshd: root@pts/1
#查询系统中有3个sshd进程。1733是sshd服务的进程，1735和1758是两个远程连接的进程
[root@localhost ~]# killall -i sshd
#交互式杀死sshd进程
杀死sshd(1733)?(y/N)n
#这个进程是sshd的服务进程，如果杀死，那么所有的sshd连接都不能登陆
杀死 sshd(1735)?(y/N)n
#这是当前登录终端，不能杀死我自己吧
杀死 sshd(1758)?(y/N)y
#杀死另一个sshd登陆终端
```

‍

## pkill 命令

当作于管理进程时，pkill 命令和 killall 命令的用法相同，都是通过进程名杀死一类进程，该命令的基本格式如下：

```bash
[root@localhost ~]# pkill [信号] 进程名
```

|信号编号|信号名|含义|
| ----------| --------| ----------------------------------------------------------------------------------------|
|0|EXIT|程序退出时收到该信息。|
|1|HUP|挂掉电话线或终端连接的挂起信号，这个信号也会造成某些进程在没有终止的情况下重新初始化。|
|2|INT|表示结束进程，但并不是强制性的，常用的 "Ctrl+C" 组合键发出就是一个 kill -2 的信号。|
|3|QUIT|退出。|
|9|KILL|杀死进程，即强制结束进程。|
|11|SEGV|段错误。|
|15|TERM|正常结束进程，是 kill 命令的默认信号。|

【例 1】

```bash
[root@localhost ~]# pkill -9 httpd    <--按名称强制杀死 httpd 进程
[root@localhost ~]# pstree -p | grep httpd    <-- 查看 apache 进程，发现没有了
[root@localhost ~]# service httpd start     <--重新启动 apache 进程
Starting httpd: httpd: Could not reliably determine the server’s fully qualified domain me, using 127.0.0.1 for ServerName
[OK]
[root@localhost ~]# pstree -p | grep httpd  <-- 再次查看，apache 进程重新启动
        - httpd (11157) -+-httpd(11159)
        |                           |-httpd(11160)
        |                           |-httpd(11161)
        |                           |-httpd(11162)
        |                           |-httpd(11163)
        |                           |-httpd(11164)
        |                           |-httpd(11165)
        |                           |-httpd(11166)
```

### pkill命令踢出登陆用户

除此之外，pkill 还有一个更重要的功能，即按照终端号来踢出用户登录，此时的 pkill 命令的基本格式如下：

```bash
[root@localhost ~]# pkill [-t 终端号] 进程名
```

[-t 终端号] 选项用于按照终端号踢出用户；

学习 killall 命令时，不知道大家发现没有，通过 killall 命令杀死 sshd 进程的方式来踢出用户，非常容易误杀死进程，要么会把 sshd 服务杀死，要么会把自己的登录终端杀死。

所以，不管是使用 kill 命令按照 PID 杀死登录进程，还是使用 killall 命令按照进程名杀死登录进程，都是非常容易误杀死进程的，而使用 pkill 命令则不会，举个例子：

```bash
[root@localhost ~]# w
#使用w命令查询本机已经登录的用户
20:06:34 up 28 min, 3 users, load average: 0.00, 0.00, 0.00
USER  TTY           FROM LOGIN@  IDLE  JCPU  PCPU WHAT
root ttyl              -  19:47 18:52 0.01s 0.01s -bash
root pts/0 192.168.0.100  19:47 0.00s 0.09s 0.04s w
root pts/1 192.168.0.100  19:51 14:56 0.02s 0.02s -bash
#当前主机已经登录了三个root用户，一个是本地终端ttyl登录，另外两个是从192.168.0.100登陆的远程登录
[root@localhost ~]# pkill -9 -t pts/1
#强制杀死从pts/1虚拟终端登陆的进程
[root@localhost ~]# w
20:09:09 up 30 min, 2 users, load average: 0.00, 0.00,0.00
USER   TTY          FROM LOGIN@  IDLE  JCPU  PCPU WHAT
root  ttyl             -  19:47 21:27 0.01s 0.01s -bash
root pts/0 192.168.0.100  19:47 0.00s 0.06s 0.00s w
#虚拟终端pts/1的登录进程已经被杀死了
```

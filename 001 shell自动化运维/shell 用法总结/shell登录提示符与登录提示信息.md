# shell登录提示符与登录提示信息 

# 登录提示符

**常用参数及含义**

在 `/etc/bashrc`​ 文件中会设定 `PS1`​ 变量，这个变量设置的就是登录之后的提示符信息

```bash
[root@localhost ~]$ echo $PS1
[\u@\h \W]\$
```

不同的参数代表的含义不同

* ​`\d`​ ：代表日期，格式为 weekday month date，例如：”Mon Aug 1”
* ​`\H`​ ：完整的主机名称
* ​`\h`​ ：仅取主机名中的第一个名字
* ​`\t`​ ：显示时间为24小时格式 `HH:MM;SS`​
* ​`\T`​ ：显示时间为12小时格式
* ​`\A`​ ：显示时间为24小时格式 `HH:MM`​
* ​`\u`​ ：当前用户的账号名称
* ​`\v`​ ：BASH 的版本信息
* ​`\w`​ ：完整的工作目录名称
* ​`\W`​ ：利用 `basename`​ 取得工作目录名称，只显示最后一个目录名
* ​`\#`​ ：下达的第几个命令
* ​`\$`​ ：提示字符，如果是root用户，提示符为 # ，普通用户则为 $

所以 shell 默认的命令行提示信息的格式 `PS1='[\u@\h \W]\$ '`​ 的意思就是：

```bash
[当前用户的账号名@主机名的第一个名字 工作目录的最后一层目录名]#
```

**颜色参数**

在 `PS1`​ 中还可以设置字符的颜色，其格式为 `\[\e[F;Bm\]........\[\e[0m\]`​，其中 `\[\e[`​ 作为颜色设定的开始。`F`​ 为字体颜色，编号范围是 `30-37`​，`B`​ 为背景颜色，编号范围是 `40-47`​，而 `\[\e[0m\]`​ 作为颜色设定的结束。

下面是颜色对照表：

|F|B|颜色|
| ----| ----| ----------|
|30|40|黑色|
|31|41|红色|
|32|42|绿色|
|33|43|黄色|
|34|44|蓝色|
|35|45|紫红色|
|36|46|青蓝色色|
|37|47|白色|

**个性化配置命令提示符**

在 linux 上终端命令行默认全部为白色，会经常导致命令与输出内容难以分辨，于是我们可以通过自定义 `PS1`​ 环境变量来解决这个问题。

一行显示日期和时间，一行显示标准的提示符

```bash
[user1@study ~]$ export PS1='\D{%c} \w\n[\u@\H]\$ '
Wed 15 Jul 2015 08:22:15 PM CST ~
[user1@study]$ echo Tom                                     
Tom
Wed 15 Jul 2015 08:22:19 PM CST ~
[user1@study]$ echo Jerry                                   
Jerry
Wed 15 Jul 2015 08:22:21 PM CST ~
[user1@study]$
```

显示当前时间

```bash
[user1@study ~]$ export PS1="\u@\h [\$(date +%k:%M:%S)]> "
user1@study [20:21:24]> echo "yes"
yes
user1@study [20:21:29]>
```

为了能永久生效，一般在 `/etc/profile.d/`​ 下自定义一个专门设置 `PS1`​ 的脚本并对其添加可执行权限。上面的格式只是设置了多行提示符，并没有对颜色和自己进行设置。

```bash
[root@study ~]# cat /etc/profile.d/my-PS1.sh
PS1='\[\e[1;36m\][\u@\H \W]\$\[\e[0m\] '
[root@study ~]#
```

# 登录提示信息

## 登录前提示信息

每次登录系统时都会有提示信息，**这个登录提示信息是针对本地终端 tty{1-6} 的，而并非类SSH登录**。

本地终端提示信息默认在文件 `/etc/issue`​ 中

```bash
[user1@study ~]$ cat /etc/issue
\S
Kernel \r on an \m

[user1@study ~]$
```

文件中使用了转义符，下面做一个简要的说明

```bash
\d：显示当前系统日期
\s：显示操作系统名称
\l：显示登录的终端号，这个比较常用
\m：显示硬件体系结构，如x86
\n：显示主机名
\o：显示域名
\r：显示内核版本号
\t：显示当前系统时间
\u：显示当前登录用户的序列号
```

远程终端提示信息默认在文件 `/etc/issue.net`​ 中，如:

```bash
[user1@study ~]$ cat /etc/issue.net 
\S
Kernel \r on an \m
[user1@study ~]$
```

在 SSH 服务中默认并没有开启显示信息，要想在 SSH 登录时显示这些内容，可以在服务配置文件 `/etc/ssh/sshd_config`​ 文件中，把 参数`Banner none`​ 改为 `Banner /etc/issue.net`​，然后重启 sshd 服务重新登录就会看到显示信息。但是 `Kernel \r on an \m`​ 这行字符原样显示并没有进行转义，原因是远程信息提示不支持转义符的使用，一般就是用来写一些警告信息。

# 登陆后提示信息

使用环境变量配置文件来输出会比较易于定制，因为都是用 shell 来做的

```bash
[user1@study ~]$ cat ~/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

# Look at them
hname=`hostname`
echo "Welcome on $hname."

echo -e "Kernel Details: " `uname -smr`
echo -e "`bash --version`"
echo -ne "Uptime: "; uptime
echo -ne "Server time : "; date
```

重新登录后就会出现提示信息

```bash
[root@study ~]# su - user1
Last login: Wed Jul 15 19:43:13 CST 2015 on pts/3
Welcome on study.
Kernel Details:  Linux 3.10.0-862.el7.x86_64 x86_64
GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
Copyright (C) 2011 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Uptime:  20:17:08 up  6:49,  9 users,  load average: 0.00, 0.01, 0.05
Server time : Wed Jul 15 20:17:08 CST 2015
[user1@study ~]$
```

生产环境的服务器最好做到什么信息都不要提示，以免带来安全问题。如果一定要写，建议写在 `/etc/motd`​ 文件中，并且最好写一些警告信息。默认这个文件是空的，将提示信息写入即可。

以下是几个供娱乐使用的提示信息模板

```bash
/***
 * http://www.flvcd.com/
 *  .--,       .--,
 * ( (  \.---./  ) )
 *  '.__/o   o\__.'
 *     {=  ^  =}
 *      >  -  <
 *     /       \
 *    //       \\
 *   //|   .   |\\
 *   "'\       /'"_.-~^`'-.
 *      \  _  /--'         `
 *    ___)( )(___
 *   (((__) (__)))    高山仰止,景行行止.虽不能至,心向往之。
 */
```

```bash

######################################################################
#                              Notice                                #
#                                                                    #
#  1. Please create unique passwords that use a combination of words,#
#   numbers, symbols, and both upper-case and lower-case letters.    #
#   Avoid using simple adjacent keyboard combinations such as        #
#   "Qwert!234","Qaz2wsx",etc.                                       #
#                                                                    #
#  2. Unless necessary, please DO NOT open or use high-risk ports,   #
#   such as Telnet-23, FTP-20/21, NTP-123(UDP), RDP-3389,            #
#   SSH/SFTP-22, Mysql-3306, SQL-1433,etc.                           #
#                                                                    #
#                                                                    #
#                     Any questions please contact 0000-000-000      #
######################################################################
```

```bash
**
 * ┌───┐   ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┐
 * │Esc│   │ F1│ F2│ F3│ F4│ │ F5│ F6│ F7│ F8│ │ F9│F10│F11│F12│ │P/S│S L│P/B│  ┌┐    ┌┐    ┌┐
 * └───┘   └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┘  └┘    └┘    └┘
 * ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐ ┌───┬───┬───┐ ┌───┬───┬───┬───┐
 * │~ `│! 1│@ 2│# 3│$ 4│% 5│^ 6│& 7│* 8│( 9│) 0│_ -│+ =│ BacSp │ │Ins│Hom│PUp│ │N L│ / │ * │ - │
 * ├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤ ├───┼───┼───┤ ├───┼───┼───┼───┤
 * │ Tab │ Q │ W │ E │ R │ T │ Y │ U │ I │ O │ P │{ [│} ]│ | \ │ │Del│End│PDn│ │ 7 │ 8 │ 9 │   │
 * ├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤ └───┴───┴───┘ ├───┼───┼───┤ + │
 * │ Caps │ A │ S │ D │ F │ G │ H │ J │ K │ L │: ;│" '│ Enter  │               │ 4 │ 5 │ 6 │   │
 * ├──────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤     ┌───┐     ├───┼───┼───┼───┤
 * │ Shift  │ Z │ X │ C │ V │ B │ N │ M │< ,│> .│? /│  Shift   │     │ ↑ │     │ 1 │ 2 │ 3 │   │
 * ├─────┬──┴─┬─┴──┬┴───┴───┴───┴───┴───┴──┬┴───┼───┴┬────┬────┤ ┌───┼───┼───┐ ├───┴───┼───┤ E││
 * │ Ctrl│    │Alt │         Space         │ Alt│    │    │Ctrl│ │ ← │ ↓ │ → │ │   0   │ . │←─┘│
 * └─────┴────┴────┴───────────────────────┴────┴────┴────┴────┘ └───┴───┴───┘ └───────┴───┴───┘
 *
```

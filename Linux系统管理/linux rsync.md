# linux rsync

rsync 命令的基本格式有多种，分别是：

```bash
# rsync 命令的基本格式有多种，分别是：
# 用于仅在本地备份数据；
rsync [OPTION] SRC DEST
# 用于将本地数据备份到远程机器上；
rsync [OPTION] SRC [USER@]HOST:DEST   # ssh 认证
rsync [OPTION] SRC [USER@]HOST::DEST  # rsync 认证
# 用于将远程机器上的数据备份到本地机器上；
rsync [OPTION] [USER@]HOST:SRC  DEST
rsync [OPTION] [USER@]HOST::SRC DEST
```

# 使用ssh协议

* yum安装rsync（客户端服务端都需要安装）

  `yum -y install rsync`
* 二进制安装rsync

  下载地址：https://rsync.samba.org/

  ```bash
  ./configure --prefix=/usr/local/rsync
  make
  make install
  ```
* 推送push

  ```bash
  # 格式:rsync 参数 [本地文件路径] root@远程的ip地址:[要放到远程的路径]
  rsync  test.txt root@10.0.0.12:/opt/

  # 参数详解
  -a    # 归档模式传输，等于-tropgDl，一般只用 -az即可
  -v    # 详细模式输出，打印速率，文件数量等
  -z    # 传输时进行压缩以提高效率
  -r    # 递归传输目录及子目录，即目录下得所有目录都同样传输
  -t    # 保持文件时间信息
  -o    # 保持文件属主信息
  -g    # 保持文件属组信息
  -p    # 保持文件权限
  -l    # 保留软连接
  -P    # 显示同步的过程及传输时的进度等信息  
  -D    # 保持设备文件信息
  -L    # 保留软连接指向的目标文件
  -e    # 使用的信道协议，指定替代rsh的shell程序
  -u    # 表示把 DEST 中比 SRC 还新的文件排除掉，不会覆盖。
  --progress # 表示在同步的过程中可以看到同步的过程状态，比如统计要同步的文件数量、 同步的文件传输速度等。
  --append            # 指定文件接着上次传输中断处继续传输
  --exclude           # 排除文件或目录，相对路径
  --exclude-from=file # 按照文件指定内容排除
  --bwlimit=100       # 限速传输（单位：MB）
  --delete            # 让目标目录和源目录数据保持一致
  --password-file=xxx # 使用密码文件
  --port              # 指定端口传输
  ––existing          # 仅仅更新那些已经存在于接收端的文件，而不备份那些新创建的文件
  ––ignore-existing   # 忽略那些已经存在于接收端的文件，仅备份那些新创建的文件

  # 通过rsync同步远程服务器的文件，当ssh为默认端口22时，使用命令：
  rsync -avz file user@remote_IP:/path
  # 当ssh更改端口为 8022 时，rsync同步文件方法为：
  rsync -avz -e 'ssh -p 8022' file user@remote_IP:/path
  ```
* 拉取pull

  ```bash
  # 格式 rsync 参数 root@远程的ip地址:[远程的路径] 要放到本地的地址(路径)
  rsync -azv root@10.0.0.12:/opt/test.txt ./
  ```

# 使用rsync协议

> rsync守护进程模式

## 1.服务端

* 安装rsync

  ```bash
  yum -y install rsync
  ```
* 修改配置文件

  ```bash
  vi /usr/local/rsync/rsyncd.conf
  ```

  ```bash
  uid = nobody
  gid = nobody
  use chroot = no
  read only = yes
  max connections = 4
  timeout = 900
  exclude = lost+found/
  fake super = yes
  transfer logging = yes  
  log file = /var/log/rsyncd.log
  pid file = /var/run/rsyncd.pid
  lock file = /var/run/rsync.lock


  ignore nonreadable = yes
  read only = false    
  dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

  [backup]
  path = /backup
  comment = log backup
  auth users = logbackup
  secrets file = /etc/rsyncd_users.db
  ```
* 创建系统用户,作为守护进程的用户

  ```bash
  # 如果使用默认用户nobody,则可以忽略该步骤
  groupadd rsync;useradd -g rsync -s /sbin/nologin rsync
  ```
* 创建密码文件

  ```bash
  echo "logbackup:123456" > /etc/rsyncd_users.db
  chmod 600 /etc/rsyncd_users.db

  ```
* 创建备份目录

  ```bash
  mkdir /backup
  chown rsync.rsync /backup/

  ```
* 启动rsyncd服务

  ```bash
  systemctl start  rsyncd
  systemctl status rsyncd

  ```

## 2.客户端

* 安装rsync

  `yum -y install rsync`
* 连接服务端

  方式一：手动输入密码

  ```bash
  # rsync 参数 [本地文件路径] 传输用户@远程的ip地址::共享名
  rsync -tz ./* logbackup@10.0.0.12::backup

  ```

  方式二：使用密码文件

  ```bash
  # 编写密码文件
  echo "123456" > /etc/rsync.passwd
  chmod 600 /etc/rsync.passwd
  rsync -tz --password-file=/etc/rsync.passwd ./* logbackup@10.0.0.12::backup

  ```

  方式三：添加环境变量

  ```bash
  export RSYNC_PASSWORD=123456
  rsync -tz ./* logbackup@10.0.0.12::backup

  ```

# 实时同步rsync+inotify

**文件系统事件监听工具inotify**
inotify 是一个 Linux 内核特性，它监控文件系统，并且及时向专门的应用程序发出相关的事件警告，比如删除、读、写和卸载操作等。要使用 inotify，必须具备一台带有 2.6.13 版本的内核操 作系统。 inotify 两个监控命令：inotifywait:用于持续监控，实时输出结果（常用）inotifywatch：用于短期监控，任务完成后再出结果

inotify-tools为inotify提供一个简单接口。它是一个c语言编写的库，同时也包含命令行工具。

**1.inotify-tools安装**

```bash
yum install -y epel-release inotify-tools
```

**2.inotifywait**

监听脚本如下:

```txt
inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f' -e modify,delete,create,attrib /home/data/file/ | while read file
do
rsync -tz /home/data/file/ logbackup@10.0.0.12::backup
echo "${file} was synchronized" >> /var/log/inotifywait.log
done
```

inotifywait参数：

```bash
-m         # 保持持续监听状态，如果不写该参数，inotifywait会在监听到一次事件之后退出。
-r         # 递归方式监听目录。
-q         # 安静模式，打印输出较少的内容。
--timefmt  # 指定时间的输出格式。
--format   # 指定事件输出的格式。
-e         # 设置监听的事件类型。这里监听增删改和metadata的变更。
  # -e 指定监控的事件
  #   access :  访问
  #   modify :  内容修改
  #   attrib :  属性修改
  #   close_write :  修改真实文件内容
  #   open   :  打开
  #   create :  创建
  #   delete :  删除
  #   umount :  卸载

```

**【由于是脚本自动远程备份，所以需要提前配置ssh免密登录】**

ssh-keygen -t rsa -b 2048   #生成密钥（一路回车）
ssh-copy-id root@192.168.3.155 #将公钥发送给另一台服务器

# rsync配置文件详解

```bash
########### 全局参数 ##################
motd file = /etc/rsyncd.motd    #设置服务器信息提示文件，在该文件中编写提示信息
transfer logging = yes    #开启rsync数据传输日志功能
log file = /var/log/rsyncd.log    #设置日志文件名，可通过log format参数设置日志格式
pid file = /var/run/rsyncd.log    #设置rsync进程号保存文件名称
lock file = /var/run/rsync.lock    #设置锁文件名称
port = 873    #设置服务器监听的端口号，默认是873
address = 192.168.0.230    #设置本服务器所监听网卡接口的ip地址
uid = nobody    #设置进行数据传输时所使用的帐户名或ID号，默认使用nobody
gid = nobody    #设置进行数据传输时所使用的组名或GID号，默认使用nobody
#如果"use chroot"指定为true，那么rsync在传输文件以前首先chroot到path参数所指定的目录下。
#这样做的原因是实现额外的安全防护，但是缺点是需要root权限，
#并且不能备份指向外部的符号连接所指向的目录文件。默认情况下chroot值为true。
use chroot = no 
read only = yes    #是否允许客户端上传数据，yes表示不允许
max connections =10    #设置并发连接数，0表示无限制
# rsync使用-ac参数，必须具备fake supper = yes的配置参数才可以
fake super = yes
timeout = 900
# 指定rysnc服务器完全忽略那些用户没有访问权限的文件。这对于在需要备份的目录中有些文件是不应该被备份者得到的情况是有意义的。
ignore nonreadable
# 用来指定那些不进行压缩处理再传输的文件，默认值是*.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz。
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
incoming chmod = Du=r,Do=r,Fug=r,Fo=r  # 设置服务器收到的文件权限
outgoing chmod = Du=rwx,Dog=x,Fg=rw,Fog=r
# 其中D表示目录，F表示文件
# Du=r,Dgo=r表示目录权限是444
# Fu=r,Fgo=r表示文件权限是444
# incoming chmod另一种写法如下
# incoming chmod = D444,F444
hosts allow = 127.0.0.1
########### 模块参数 ##################
# 共享名：用来连接是写在url上的,切记
[backup]
#同步目录，路径通过path指定
path = /backup
#定义注释说明字串
comment = log backup
#设置允许连接服务器的账户，此账户可以是系统中不存在的用户
auth users = logbackup
#密码验证文件名，该文件权限要求为只读，建议为600，仅在设置auth users后有效
secrets file = /etc/rsyncd_users.db
#设置哪些主机可以同步数据，多ip和网段之间使用空格分隔
hosts allow = 192.168.0.0/255.255.255.0
#除了hosts allow定义的主机外，拒绝其他所有
hosts deny=*
#客户端请求显示模块列表时，本模块名称是否显示，默认为true
list = false
```

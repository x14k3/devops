# rsync

**rsync命令** 是一个远程数据同步工具，可通过LAN/WAN快速同步多台主机间的文件。rsync使用所谓的“rsync算法”来使本地和远程两个主机之间的文件达到同步，这个算法只传送两个文件的不同部分，而不是每次都整份传送，因此速度相当快。

* yum安装rsync（客户端服务端都需要安装）

  ​`yum -y install rsync`​
* 二进制安装rsync

  下载地址：https://rsync.samba.org/

  ```bash
  ./configure --prefix=/usr/local/rsync
  make
  make install
  ```

‍

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

######################### 选项 ##########################
-v, --verbose 详细模式输出。
-q, --quiet 精简输出模式。
-c, --checksum 打开校验开关，强制对文件传输进行校验。
-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD。
-r, --recursive 对子目录以递归模式处理。
-R, --relative 使用相对路径信息。
-b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
--backup-dir 将备份文件(如~filename)存放在在目录下。
-suffix=SUFFIX 定义备份文件前缀。
-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件，不覆盖更新的文件。
-l, --links 保留软链结。
-L, --copy-links 想对待常规文件一样处理软链结。
--copy-unsafe-links 仅仅拷贝指向SRC路径目录树以外的链结。
--safe-links 忽略指向SRC路径目录树以外的链结。
-H, --hard-links 保留硬链结。
-p, --perms 保持文件权限。
-o, --owner 保持文件属主信息。
-g, --group 保持文件属组信息。
-D, --devices 保持设备文件信息。
-t, --times 保持文件时间信息。
-S, --sparse 对稀疏文件进行特殊处理以节省DST的空间。
-n, --dry-run 显示哪些文件将被传输。
-w, --whole-file 拷贝文件，不进行增量检测。
-x, --one-file-system 不要跨越文件系统边界。
-B, --block-size=SIZE 检验算法使用的块尺寸，默认是700字节。
-e, --rsh=command 指定使用rsh、ssh方式进行数据同步。
--rsync-path=PATH 指定远程服务器上的rsync命令所在路径信息。
-C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件。
--existing 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件。
--delete 删除那些DST中SRC没有的文件。
--delete-excluded 同样删除接收端那些被该选项指定排除的文件。
--delete-after 传输结束以后再删除。
--ignore-errors 及时出现IO错误也进行删除。
--max-delete=NUM 最多删除NUM个文件。
--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输。
--force 强制删除目录，即使不为空。
--numeric-ids 不将数字的用户和组id匹配为用户名和组名。
--timeout=time ip超时时间，单位为秒。
-I, --ignore-times 不跳过那些有同样的时间和长度的文件。
--size-only 当决定是否要备份文件时，仅仅察看文件大小而不考虑文件时间。
--modify-window=NUM 决定文件是否时间相同时使用的时间戳窗口，默认为0。
-T --temp-dir=DIR 在DIR中创建临时文件。
--compare-dest=DIR 同样比较DIR中的文件来决定是否需要备份。
-P 等同于 --partial。
--progress 显示备份过程。
-z, --compress 对备份的文件在传输时进行压缩处理。
--exclude=PATTERN 指定排除不需要传输的文件模式。
--include=PATTERN 指定不排除而需要传输的文件模式。
--exclude-from=FILE 排除FILE中指定模式的文件。
--include-from=FILE 不排除FILE指定模式匹配的文件。
--version 打印版本信息。
--address 绑定到特定的地址。
--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件。
--port=PORT 指定其他的rsync服务端口。
--blocking-io 对远程shell使用阻塞IO。
-stats 给出某些文件的传输状态。
--progress 在传输时显示传输过程。
--log-format=formAT 指定日志文件格式。
--password-file=FILE 从FILE中得到密码。
--bwlimit=KBPS 限制I/O带宽，KBytes per second。
-h, --help 显示帮助信息。
```

## 使用ssh协议

```bash
rsync -az --progress  root@192.168.2.1:/data/alist /opt/
```

## 使用rsync守护进程模式

### 1.服务端

* 1.1 编辑配置文件

  ```bash
  vi /usr/local/rsync/rsyncd.conf
  ```

  ```bash
  uid = root
  gid = root
  use chroot = no
  read only = no
  max connections = 4
  timeout = 900
  exclude = lost+found/
  fake super = yes
  pid file = /var/run/rsyncd.pid
  lock file = /var/run/rsyncd.lock
  dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
  ignore nonreadable = yes

  [backup]
  path = /backup
  comment = backup
  auth users = backup
  secrets file = /data/script/rsyncd_users.db
  ```
* 1.2 创建系统用户,作为守护进程的用户

  ```bash
  # 如果使用默认用户nobody,则可以忽略该步骤
  groupadd rsync;useradd -g rsync -s /sbin/nologin rsync
  ```
* 1.3 创建密码文件

  ```bash
  echo "logbackup:123456" > /etc/rsyncd_users.db
  chmod 600 /etc/rsyncd_users.db
  ```
* 1.4 创建备份目录

  ```bash
  mkdir /backup
  chown rsync.rsync /backup/
  ```
* 1.5 启动rsyncd服务

  ```bash
  systemctl restart  rsyncd
  systemctl status rsyncd
  ```

### 2.客户端

* 2.1 连接服务端

  2.1.1 方式一：手动输入密码

  ```bash
  # rsync 参数 传输用户@远程的ip地址::共享名 [本地文件路径]
  # 下载
  rsync  -azv backup@192.168.2.1::backup ./

  # 上传
  rsync  -azv ./test.tar.gz backup@192.168.2.1::backup 
  ```

  2.1.2 方式二：使用密码文件

  ```bash
  # 编写密码文件
  echo "123456" > /etc/rsync.passwd
  chmod 600 /etc/rsync.passwd
  rsync -azv --password-file=/etc/rsync.passwd backup@10.0.0.12::backup  ./

  ```

  2.1.3 方式三：添加环境变量

  ```bash
  export RSYNC_PASSWORD=123456
  rsync -azv backup@10.0.0.12::backup ./

  ```

## 实时同步rsync+inotify

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
-m       # 保持持续监听状态，如果不写该参数，inotifywait会在监听到一次事件之后退出。
-r         # 递归方式监听目录。
-q        # 安静模式，打印输出较少的内容。
--timefmt  # 指定时间的输出格式。
--format   # 指定事件输出的格式。
-e        # 设置监听的事件类型。这里监听增删改和metadata的变更。
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

参考ssh的密钥登录

## rsync配置文件详解

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

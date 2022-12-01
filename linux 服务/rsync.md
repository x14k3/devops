#system/rsync
# 使用ssh协议

## 1.服务端

*   yum安装rsync

    `yum -y install rsync`

* 二进制安装rsync
	下载地址：https://rsync.samba.org/
	```bash
	./configure --prefix=/usr/local/rsync
	make
	make install
	```


## 2.客户端

*   安装rsync

    `yum -y install rsync`

*   推送push

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
    --append            # 指定文件接着上次传输中断处继续传输
    --exclude-from=file # 按照文件指定内容排除
    --bwlimit=100       # 限速传输（单位：MB）
    --delete            # 让目标目录和源目录数据保持一致
    --password-file=xxx # 使用密码文件
    --port              # 指定端口传输
    ––existing          # 仅仅更新那些已经存在于接收端的文件，而不备份那些新创建的文件
    ––ignore-existing   # 忽略那些已经存在于接收端的文件，仅备份那些新创建的文件

    ```

*   拉取pull

    ```bash
    # 格式 rsync 参数 root@远程的ip地址:[远程的路径] 要放到本地的地址(路径)
    rsync -v root@10.0.0.12:/opt/test.txt ./
    ```

# 使用rsync协议

> rsync守护进程模式

## 1.服务端

*   安装rsync
	```bash
	yum -y install rsync
	```

*   修改配置文件
	```bash
	vi /usr/local/rsync/rsyncd.conf
	```
 
    ```bash
    uid = rsync
    gid = rsync
    use chroot = no
    max connections = 4
    pid file = /var/run/rsyncd.pid
    exclude = lost+found/
    fake super = yes
    transfer logging = yes
    timeout = 900
    ignore nonreadable = yes
    read only = false    
    dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

    [backup]
    path = /backup
    comment = log backup
    auth users = logbackup
    secrets file = /etc/rsyncd_users.db
    ```

*   创建系统用户,作为守护进程的用户

    ```bash
    groupadd rsync;useradd -g rsync -s /sbin/nologin rsync
    ```

*   创建密码文件

    ```bash
    echo "logbackup:123456" > /etc/rsyncd_users.db
    chmod 600 /etc/rsyncd_users.db

    ```

*   创建备份目录

    ```bash
    mkdir /backup
    chown rsync.rsync /backup/

    ```

*   启动rsyncd服务

    ```bash
    systemctl start  rsyncd
    systemctl status rsyncd

    ```

## 2.客户端

*   安装rsync

    `yum -y install rsync`

*   连接服务端

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

```powershell
########### 全局参数 ##################
uid = rsync
gid = rsync
use chroot = no
max connections = 4
pid file = /var/run/rsyncd.pid
exclude = lost+found/
# rsync使用-ac参数，必须具备fake supper = yes的配置参数才可以
fake super = yes
transfer logging = yes
timeout = 900
ignore nonreadable = yes
# false 才能上传文件，true 不能上传文件
read only = false    
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
path = /backup
comment = log backup
auth users = logbackup
secrets file = /etc/rsyncd_users.db
```

参考：

<https://www.wangt.cc/2021/12/linux中架构中的备份服务器搭建rsync/>

源码部署：

<https://www.jianshu.com/p/db08a6e50013>

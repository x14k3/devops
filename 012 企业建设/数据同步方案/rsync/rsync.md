# rsync

## 1.Rsync 简介

　　**Rsync** 是一款开源的、快速的 多功能的 可以实现全量以及增量的本地或者是远程的数据同步备份的优秀工具  
并且可以不进行改变原有的数据属性信息，实现数据的备份和迁移的特性 ，**Rsync**软件适用于 **Linux/unix/windows** 等多种操作系统上 。

## 2.Rsync备份服务知识点

### 2.1 Rsync可以实现的备份方式

* 本地备份
* 远程备份
* 无差异备份

### 2.2 Rsync实现方式介绍

* 全量备份数据
* 增量备份数据

　　+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
**全量**和**增量**的区别  
完整数据传送表示为**全量** ， 传送新增加的数据表示**增量**。  
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

　　**实现rsync增量同步数据，是运用了其独特的“quick check”算法**  
CentOS5，rsync2.x比对方法，把所有的文件比对一遍，然后进行同步。  
CentOS6，rysnc3.x比对方法，一边比对差异，一边对差异的部分进行同步。

### 2.3 Rsync 特性总结说明

* ：支持多种类型文件拷贝
* ：支持文件复制排除功能
* ：支持文件复制属性不变
* ：支持文件复制增量同步
* ：支持文件复制隧道加密
* ：支持守护进程同步数据
* ：支持数据同步身份验证

　　**可以镜像保存整个目录树和文件系统**

1. 可以很容易做到保持原来文件的权限、时间、软硬链接等；
2. 无须特殊权限即可安装；
3. 优化的流程，文件传输效率高；
4. 可以使用rcp、ssh等方式来传输文件，当然也可以通过直接的socket连接；
5. 支持匿名传输，以方便进行网站镜像。

### 2.4 Rsync复制原理说明

```
网站内部人员数据备份场景 
    1，定时任务+rsync

网站外部用户数据备份场景
    2，实时同步工具+rsync
```

### 2.5 Rsync工作方式

```
1  本地方式  、 隧道方式  、守护进程 ；
2  单个主机本地之间的数据传输（此时类似于cp命令的功能）。
3  借助rcp,ssh等通道来传输数据（此时类似于scp命令的功能）。
4  以守护进程（socket）的方式传输数据（这个是rsync自身的重要的功能）。
```

## 3.Rsync服务端部署&配置

### 3.1 Rsync服务端安装

```bash
wget https://download.samba.org/pub/rsync/rsync-3.1.2.tar.gz
tar -zxf rsync-3.1.2.tar.gz
cd rsync-3.1.2
./configure --prefix=/work/admin/rsync
make && make install

#========================================
zypper install rsync
```

### 3.2 配置服务端主配置文件：

```bash
mkdir /work/admin/rsync/etc/

cat <<EOF >> /work/admin/rsync/etc/rsyncd.conf

uid = nobody
gid = nobody
use chroot = yes
max connections = 4
#pid file = /var/run/rsyncd.pid
pid file = /work/admin/rsync/rsyncd.pid  
lock file = /work/admin/rsync/rsync.lock
log file = /work/admin/rsync/rsyncd.log
exclude = lost+found/
transfer logging = yes
timeout = 200
ignore nonreadable = yes
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

[static]
path=/storage/
comment=static
ignore errors
read only=yes
write only=no
list=yes
auth user= admin
secrets file=/work/admin/rsync/etc/rsyncd.passwd
hosts allow= 192.168.5.246 192.168.1.223
hosts deny = *
EOF
```

### 3.3 配置服务端认证文件：

```bash
cat /work/admin/rsync/etc/rsyncd.passwd 
admin:123456
```

### 3.4 启动服务端：

```ini
systemctl start rsync
```

## 4.Rsync客户端部署&配置

### 4.1 客户端安装

　　客户端安装和服务端一样，不同的是客户端不需要启动rsync服务

```bash
wget https://download.samba.org/pub/rsync/rsync-3.1.2.tar.gz
tar -zxf rsync-3.1.2.tar.gz
cd rsync-3.1.2
./configure --prefix=/work/admin/rsync
make && make install

#========================================
zypper install rsync
```

### 4.2 客户端配置密码文件

```bash
cat /etc/rsyncd.passwd 
123456
```

### 4.3 客户端拉取

```bash
rsync -vzrtopg --progress --delete admin@192.168.6.220::static /storage/ --password-file=/work/admin/rsync/etc/rsyncd.passwd

#使用ssh协议

```

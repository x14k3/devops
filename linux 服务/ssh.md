#system/ssh


## ssh 的登录验证模式

#### 口令登录
`ssh -p 2222 -i /opt/vps.rsa user@ip`

#### 公钥登录

公钥登录是为了解决每次登录服务器都要输入密码的问题，流行使用RSA加密方案，主要流程包含：

```bash
# 1.客户端生成RSA公钥和私钥
ssh-keygen
ssh-keygen -t rsa -b 2048
# b:指定密钥对加密长
# t:指定加密类型（rsa/dsa等）`

# 2.运行上面的命令以后，在$HOME/.ssh/目录下，会新生成两个文件：
# id_rsa.pub  你的公钥
# id_rsa      你的私钥

# 3.将自己的公钥上传到服务器
ssh-copy-id x.x.x.x

# 4.把公钥文件内容加入到主机B的~/.ssh/authorized_keys文件中
cat id_rsa.pub >> ~/.ssh/authorized_keys
```

**原理**

```bash
1.客户端请求连接服务器，服务器将一个随机字符串发送给客户端
2.客户端根据自己的私钥加密这个随机字符串之后再发送给服务器
3.服务器接受到加密后的字符串之后用公钥解密，如果正确就让客户端登录，否则拒绝。这样就不用使用密码了。

```

**ssh配置**

```bash
#关闭密码登录  禁止使用root远程登陆
vim /etc/ssh/sshd_config
---------------------------
PasswordAuthentication no
PermitRootLogin no
UseDNS no
-------------------------
/usr/sbin/sshd   #重新加载sshd

#配置ssh免密码登录后，仍提示输入密码**
chown -R test.test /home/test
chmod 700 /home/test/.ssh
chmod 600 /home/test/.ssh/authorized_keys
```

#### ssh 别名登录

```bash
vim ~/.ssh/config
-----------------------------------------
Host vps
    HostName 119.28.77.113
    User sunds
    Port 2022
    IdentityFile ~/.ssh/vps.rsa
-----------------------------------------
ssh vps
```



## ssh 服务相关命令

#### scp 安全的远程文件复制目录

```bash
# scp 本地文件 远程登录用户名@远程主机IP地址:目标目录
scp -P 2222 /root/test.txt  root@192.168.72.137:/data
# 指定其他端口 要使用大写-P  指定端口
```

#### sftp 安全的文件传输协议

SFTP是SSH File Transfer Protocol的缩写，安全文件传送协议。SFTP与FTP有着几乎一样的语法和功能。

SFTP为SSH的其中一部分，是一种传输档案至 Blogger 伺服器的安全方式。其实在SSH软件包中，已经包含了一个叫作SFTP的安全文件信息传输子系统，SFTP本身没有单独的守护进程，它必须使用sshd守护进程(端口号默认是22)来完成相应的连接和答复操作。
```bash
# sftp 用户名@服务器ip
sftp -P 2222 root@192.168.x.x
```


## ssh 服务升级
1、安装telnet-server，防止openssh安装失败，而导致无法远程登陆服务器
2、升级openssh操作
3、闭关telnet-server
```bash
# 查看ssl 和 ssh 版本
openssl version   # OpenSSL 1.0.2k-fips  26 Jan 2017
ssh -V            # OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017


# 卸载 旧版本的openssh
rpm -e --nodeps `rpm -qa | grep openssh`
rm -rf /etc/ssh/ssh_host_*

# 升级openssh操作
# 解压安装和安装依赖
yum -y install zlib-devel gcc openssl-devel wget
# 下载指定版本的openssh 
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.9p1.tar.gz
tar zxvf openssh-7.9p1.tar.gz
cd openssh-7.9p1
./configure --prefix=/usr --sysconfdir=/etc/ssh

# 执行make
make &&  make install

# 查看新版的本号
ssh -V

# 配置并启动sshd服务
cp contrib/redhat/sshd.init /etc/init.d/sshd
chkconfig --add sshd
systemctl start sshd

# 修改配置文件：
vim /etc/ssh/sshd_config
---------------------------------------
PermitRootLogin yes   # 允许root登录
```


# openssh升级

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

　　‍

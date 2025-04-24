# sftp-linux

## 1.新建用户

```bash
# 创建用户组
groupadd ftpuser
# 创建用户
useradd -g ftpuser -s /sbin/nologin ftpuser
# 设置密码
echo "Ninestar123" | passwd stdin ftpuser
```

## 2.修改配置

​`vim /etc/ssh/sshd_config`​

```bash
# 指定sshd使用内置sshd的SFTP服务器代码，而不是运行另一个进程
Subsystem sftp internal-sftp
# 配置匹配该用户组
Match Group ftpuser
   ChrootDirectory /home/ftpuser  #  表示SFTP所访问的主目录为/home/ftpuser
   X11Forwarding no               #  禁止使用X11转发
   AllowTcpForwarding no          #  用户不能使用端口转发
   ForceCommand internal-sftp     #  强制执行内部sftp,并忽略任何~/.ssh/rc文件中的命令
```

## 3.设定权限

```bash
# 创建SFTP指定的主目录
mkdir -p /home/ftpuser
# 配置可写入的目录
mkdir -p /home/ftpuser/data
# 主目录的属主必须为ROOT用户,属组改为我们上面创建的sftp的用户组
chown root:ftpuser /home/ftpuser
chown ftpuser:ftpuser /home/ftpuser/data
# 设置SFTP主目录权限为755,不可以超过755否则会登入报错
chmod 755 /home/ftpuser
# 重启下SSHD服务
systemctl restart sshd
```

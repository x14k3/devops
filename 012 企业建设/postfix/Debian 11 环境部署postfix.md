# Debian 11 环境部署postfix

```bash
email@email:/var/spool/mail$ cat /etc/os-release 
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
email@email:/var/spool/mail$ 
```

　　‍

## 安装postfix

```bash
apt install postfix
```

　　安装postfix时系统会让选择邮件服务器的配置类型，可选项有以下五个：

　　No configuration                   # 保持现有配置不做改变

　　Internet Site(此项默认)         # 一般选择此项。直接使用SMTP发送和接收邮件

　　Internet with smarthost      # 直接使用SMTP或通过fetchmail等实用程序接收邮件。发送邮件时使用smarthost。

　　Satellite system(卫星系统)    # 所有邮件都会发送到另一台称为“smarthost”的机器上进行传递。

　　Local only                                # 仅交付本地用户的邮件，没有网络。

　　‍

　　下一步需要设置系统邮件名称，也就是@后面的。  
[doshell.cn]

　　‍

## 安装dovecot

```bash
apt install dovecot-pop3d dovecot-imapd
```

## 启动

```bash
service postfix start
service dovecot start
```

## 测试

　　此时从客户端电脑telnet到邮件服务器的25、110、143端口都会看到连接成功的界面。【开启防火墙】

　　使用以下步骤做简单测试：

```bash
telnet mail.test.com 25
220 mail.test.com ESMTP Postfix (Debian/GNU)
mail from: testuser@test.com
250 2.1.0 Ok
rcpt to: testuser@test.com
250 2.1.5 Ok
data
354 End data with .
dsfsd
lkwef
.
250 2.0.0 Ok: queued as AF0B742C0788
quit
221 2.0.0 Bye
```

　　‍

## 相关配置

　　请参考 Centos 7.x 环境部署postfix

　　‍

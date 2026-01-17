
## 1. 系统准备和更新

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要工具
sudo apt install -y curl wget vim git net-tools ufw

# 设置主机名
sudo hostnamectl set-hostname mail.doshell.cn

# 修改hosts文件
sudo vim /etc/hosts
```

添加以下内容到`/etc/hosts`：

```bash
127.0.0.1 localhost
127.0.1.1 mail.doshell.cn mail
47.83.22.122 mail.doshell.cn doshell.cn
```

## 2. 配置防火墙和安全组

```bash
# 配置UFW防火墙
sudo ufw allow 22/tcp
sudo ufw allow 25/tcp
sudo ufw allow 465/tcp
sudo ufw allow 587/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 993/tcp
sudo ufw allow 995/tcp
sudo ufw enable

# 阿里云安全组还需要开放这些端口（在阿里云控制台操作）
# 25, 465, 587, 80, 443, 993, 995
```

## 3. DNS记录设置（在阿里云DNS控制台）

为`doshell.cn`添加以下记录：

```bash
类型   名称             值
A      mail             47.83.22.122
MX     @                mail.doshell.cn (优先级10)
TXT    @                "v=spf1 mx ~all"
CNAME  autodiscover     mail.doshell.cn
CNAME  autoconfig       mail.doshell.cn
TXT    _dmarc           "v=DMARC1; p=none; rua=mailto:admin@doshell.cn"
```

DKIM记录稍后生成并添加。

## 4. 安装和配置Postfix

```bash
# 安装Postfix和相关组件
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix postfix-pcre

# 安装过程中选择"Internet Site"
# 系统邮件名输入：doshell.cn

# 备份原始配置
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.backup

# 编辑Postfix主配置
sudo vim /etc/postfix/main.cf
```

将`/etc/postfix/main.cf`替换为以下配置：

```bash
# 基础设置
myhostname = mail.doshell.cn
myorigin = doshell.cn
mydestination = $myhostname, doshell.cn, localhost.doshell.cn, localhost
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
inet_interfaces = all

# 限制设置
smtpd_banner = $myhostname ESMTP
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 2

# TLS/SSL配置
smtpd_tls_cert_file = /etc/ssl/certs/doshell.cn.crt
smtpd_tls_key_file = /etc/ssl/private/doshell.cn.key
smtpd_tls_security_level = may
smtpd_tls_protocols = !SSLv2, !SSLv3
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtpd_tls_loglevel = 1

# 认证设置
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $myhostname
broken_sasl_auth_clients = yes

# 收件人限制
smtpd_recipient_restrictions = 
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination,
    reject_unknown_recipient_domain,
    reject_unauth_pipelining,
    reject_invalid_helo_hostname,
    reject_non_fqdn_helo_hostname,
    reject_non_fqdn_sender,
    reject_non_fqdn_recipient,
    reject_unknown_sender_domain,
    reject_unknown_recipient_domain,
    permit

# 其他配置
mailbox_size_limit = 0
message_size_limit = 52428800
recipient_delimiter = +
inet_protocols = ipv4
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
home_mailbox = Maildir/

# SMTP Submission端口设置
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
```

```bash
# 重启Postfix
sudo systemctl restart postfix
sudo systemctl enable postfix
```

## 5. 安装和配置Dovecot

```bash
# 安装Dovecot
apt install -y dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd \
dovecot-sieve dovecot-managesieved dovecot-mysql

# 配置Dovecot
vim /etc/dovecot/dovecot.conf
```

确保`/etc/dovecot/dovecot.conf`包含：

```bash
# 基础设置
protocols = imap pop3 lmtp sieve
listen = *

# SSL/TLS配置
ssl = required
ssl_cert = </etc/ssl/certs/doshell.cn.crt
ssl_key = </etc/ssl/private/doshell.cn.key
ssl_prefer_server_ciphers = yes
ssl_protocols = !SSLv2 !SSLv3
ssl_cipher_list = ALL:!LOW:!SSLv2:!EXP:!aNULL
```

配置邮件存储

```bash
sudo vim /etc/dovecot/conf.d/10-mail.conf
```

修改为：

```bash
mail_location = maildir:~/Maildir
namespace inbox {
  inbox = yes
}
```

配置认证

```bash

sudo vim /etc/dovecot/conf.d/10-auth.conf
```

修改为：

```bash
disable_plaintext_auth = yes
auth_mechanisms = plain login
!include auth-system.conf.ext
```

配置SSL

```bash
sudo vim /etc/dovecot/conf.d/10-ssl.conf
```

修改为：

```
ssl = required
ssl_cert = </etc/ssl/certs/doshell.cn.crt
ssl_key = </etc/ssl/private/doshell.cn.key
```

重启Dovecot

```bash
sudo systemctl restart dovecot
sudo systemctl enable dovecot
```

## 6. 配置SSL证书

```bash
# 创建自签名证书（生产环境建议使用Let's Encrypt）
sudo mkdir -p /etc/ssl/private
sudo mkdir -p /etc/ssl/certs

# 生成证书
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/doshell.cn.key \
  -out /etc/ssl/certs/doshell.cn.crt \
  -subj "/C=CN/ST=Zhejiang/L=Hangzhou/O=Doshell/CN=mail.doshell.cn"

# 设置权限
sudo chmod 600 /etc/ssl/private/doshell.cn.key
sudo chmod 644 /etc/ssl/certs/doshell.cn.crt
```

## 7. 配置DKIM（域名密钥识别邮件）

```bash
# 安装OpenDKIM
sudo apt install -y opendkim opendkim-tools

# 创建目录
sudo mkdir -p /etc/opendkim/keys/doshell.cn

# 生成DKIM密钥
sudo opendkim-genkey -b 2048 -d doshell.cn -D /etc/opendkim/keys/doshell.cn -s mail -v
sudo chown -R opendkim:opendkim /etc/opendkim/keys

# 配置OpenDKIM
sudo vim /etc/opendkim.conf
```

修改为以下配置：

```
Domain                  doshell.cn
KeyFile                 /etc/opendkim/keys/doshell.cn/mail.private
Selector                mail
Socket                  inet:8891@localhost
```

```
# 创建信任主机文件
sudo vim /etc/opendkim/TrustedHosts
```

添加：

```
127.0.0.1
localhost
doshell.cn
*.doshell.cn
```

```
# 查看DKIM公钥
sudo cat /etc/opendkim/keys/doshell.cn/mail.txt
```

将输出的TXT记录添加到阿里云DNS控制台：

```
mail._domainkey.doshell.cn  "v=DKIM1; k=rsa; p=这里是公钥内容"
```

```
# 配置Postfix使用DKIM
sudo vim /etc/postfix/main.cf
```

在文件末尾添加：

```ini
# DKIM配置
milter_protocol = 2
milter_default_action = accept
smtpd_milters = inet:localhost:8891
non_smtpd_milters = inet:localhost:8891
```

```
# 重启服务
sudo systemctl restart opendkim
sudo systemctl enable opendkim
sudo systemctl restart postfix
```

## 8. 安装和配置Roundcube

```bash
# 安装Apache和PHP
sudo apt install -y apache2 php php-common php-mysql php-imap \
php-json php-curl php-zip php-mbstring php-xml php-bcmath

# 安装MariaDB
sudo apt install -y mariadb-server

# 配置MySQL
sudo mysql_secure_installation
# 设置root密码，并回答Y到所有安全选项

# 创建Roundcube数据库
sudo mysql -u root -p
```

在MySQL中执行：

```sql
CREATE DATABASE roundcube;
CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '设置一个强密码';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# 下载Roundcube
cd /tmp
wget https://github.com/roundcube/roundcubemail/releases/download/1.6.4/roundcubemail-1.6.4-complete.tar.gz
sudo tar -xzf roundcubemail-1.6.4-complete.tar.gz -C /var/www/
sudo mv /var/www/roundcubemail-1.6.4 /var/www/roundcube
sudo chown -R www-data:www-data /var/www/roundcube

# 配置Apache
sudo vim /etc/apache2/sites-available/roundcube.conf
```

添加以下内容：

```xml
<VirtualHost *:80>
    ServerName mail.doshell.cn
    DocumentRoot /var/www/roundcube
    
    <Directory /var/www/roundcube>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/roundcube_error.log
    CustomLog ${APACHE_LOG_DIR}/roundcube_access.log combined
</VirtualHost>
```

```bash
# 启用站点和模块
sudo a2ensite roundcube
sudo a2enmod rewrite
sudo systemctl restart apache2

# 访问Web安装向导
# 打开浏览器访问 http://mail.doshell.cn/installer
```

## 9. 创建邮箱账户

```bash
# 创建邮箱用户
sudo adduser email
# 设置密码

# 测试邮件发送
echo "Test email" | mail -s "Test from server" email@doshell.cn
```

## 10. 最终配置和测试

```bash
# 创建邮件别名（可选）
sudo vim /etc/aliases
```

添加：

```
postmaster: root
root: email@doshell.cn
```

```bash
# 更新别名数据库
sudo newaliases

# 检查服务状态
sudo systemctl status postfix
sudo systemctl status dovecot
sudo systemctl status apache2
sudo systemctl status opendkim

# 测试邮件发送
sudo apt install -y mailutils
echo "测试邮件" | mail -s "服务器配置测试" email@doshell.cn
```

## 11. 客户端配置

使用以下设置配置邮件客户端：

**IMAP/SMTP设置：**

- 服务器地址：[mail.doshell.cn](https://mail.doshell.cn/)
- 用户名：email@doshell.cn
- 密码：您设置的密码
- IMAP端口：993 (SSL/TLS)
- SMTP端口：587 (STARTTLS) 或 465 (SSL/TLS)
- 需要认证：是



## 12. 故障排查

```
# 查看邮件日志
sudo tail -f /var/log/mail.log

# 测试端口
telnet mail.doshell.cn 25
telnet mail.doshell.cn 587
telnet mail.doshell.cn 993

# 测试DNS记录
dig MX doshell.cn
dig A mail.doshell.cn
```

## 注意事项：

1. **阿里云25端口** ：阿里云默认封禁25端口，建议使用465或587端口
2. **反向DNS** ：联系阿里云客服设置47.83.22.122的反向DNS为[mail.doshell.cn](https://mail.doshell.cn/)
3. **Let's Encrypt证书** ：建议申请免费SSL证书替换自签名证书
4. **安全** ：定期更新系统，使用强密码，监控日志
5. **垃圾邮件** ：可能需要额外配置spamassassin等反垃圾邮件工具



这个配置提供了一个完整的邮件系统。如有问题，请检查相关服务的日志文件。
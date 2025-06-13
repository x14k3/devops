
## 开始部署

1.安装

​`yum install -y vsftpd`​

2.修改配置文件

​`cp /etc/vsftpd/vsftpd.conf{,.bak} ; vim /etc/vsftpd/vsftpd.conf`​

```bash
anonymous_enable=NO                   # 禁用匿名登录和本地用户登录
###################   以下是新增 ######################
#限制ftp用户只能在其主目录下活动（禁止切换到上级目录）
chroot_local_user=YES
chroot_list_enable=NO
#表示让家目录有可写权限
allow_writeable_chroot=YES
#可以通过定义用户配置文件来实现不同的用户使用不同的配置
user_config_dir=/etc/vsftpd/userconf
reverse_lookup_enable=NO
ascii_upload_enable=YES
ascii_download_enable=YES

```

3.创建目录

​`mkdir -p /etc/vsftpd/userconf`​

4.定义用户配置文件

​`vim /etc/vsftpd/userconf/ftp_dzhd `​  # 文件名要和ftp用名相同

```bash
# 设置ftp_dzhd这个用户的根目录为/data/bps/data/sdq
local_root=/data/bps/data/sdq
```

5.修改pam

​`cp /etc/pam.d/vsftpd{,.bak} ; vim /etc/pam.d/vsftpd`​

```bash
# 删除或注释该行
# auth       required     pam_shells.so


#  配置项的含义为仅允许用户的shell为 /etc/shells文件内的shell命令时，才能够成功
```

6.创建用户

```bash
groupadd ftpuser
useradd -s /sbin/nologin -G ftpuser ftp_dzhd && echo "Ninestar123" |passwd --stdin ftp_dzhd
# 设置目录权限
mkdir -p /data/bps/data/sdq
chown ftp_dzhd:ftpuser /data/bps/data/sdq

```

7.重启vsftp  
​`systemctl restart vsftpd`​

## 被动模式

1.修改配置文件

​`vim /etc/vsftpd/vsftpd.conf`​

```bash
# linux ftp 客户端默认使用被动模式
# windows ftp 客户端默认使用主动模式
# 使用被动模式添加以下参数：
pasv_min_port=2024
pasv_max_port=2034
```

2.重启vsftp  
​`systemctl restart vsftpd`​

## 启用ssl

1.修改配置文件

​`vim /etc/vsftpd/vsftpd.conf`​

```bash
#添加如下选项
ssl_enable=yes
ssl_sslv2=yes
ssl_sslv3=yes
ssl_tlsv1=yes
#表示强制用户使用加密登陆和数据传输
force_local_logins_ssl=yes
force_local_data_ssl=yes
rsa_cert_file=/etc/vsftpd/vsftpd.pem
#以添加下面的选项增强 FTP 服务器的安全性
require_ssl_reuse=NO
ssl_ciphers=HIGH

```

2.制作ssl证书

```bash
yum install -y openssl
cd /etc/vsftpd
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem
chmod 400 vsftpd.pem
```

3.重启vsftp  
​`systemctl restart vsftpd`​

‍

‍

## vsftpd.conf 配置文件说明

ftp的配置文件主要有三个，位于/etc/vsftpd/目录下，分别是：

```nginx
ftpusers    # 不受任何配制项的影响，它总是有效，它是一个黑名单！
user_list   # 和vsftpd.conf中的userlist_enable和userlist_deny两个配置项紧密相关的，它可以有效，也可以无效，有效时它可以是一个黑名单，也可以是一个白名单
vsftpd.conf # vsftpd的主配置文件
```

### 匿名用户

```
anon_upload_enable=NO   # 是否允许匿名登录
write_enable=YES        # 是否允许登陆用户有写权限。属于全局设置，默认值为YES
no_anon_password=YES/NO # 使用匿名登入时，不会询问密码
ftp_username=ftp        # 定义匿名登入的使用者名称。默认值为ftp。
anon_root=/var/ftp      # 使用匿名登入时，所登入的目录。默认值为/var/ftp。
anon_upload_enable=YES/NO # 如果设为YES，则允许匿名登入者有上传文件（非目录）的权限，
                          # 只有在write_enable=YES时，此项才有效。
                          # 当然，匿名用户必须要有对上层目录的写入权。默认值为NO
anon_world_readable_only=YES/NO # 如果设为YES，则允许匿名登入者下载，默认值为YES。
anon_mkdir_write_enable=YES/NO  # 则允许匿名登入者有新增目录的权限，只有在write_enable=YES时，此项才有效。
anon_other_write_enable=YES/NO  # 则允许匿名登入者更多于上传或者建立目录之外的权限，譬如删除或者重命名。
chown_uploads=YES/NO   # 设置是否改变匿名用户上传文件（非目录）的属主
anon_umask=077         # 设置匿名登入者新增或上传档案时的umask 值

```

### 本地用户

```bash
local_enable=NO           # 控制是否允许本地用户登入
local_root=/home/username # 当本地用户登入时，将被更换到定义的目录下。默认值为各用户的家目录。
write_enable=YES/NO       # 是否允许登陆用户有写权限。属于全局设置，默认值为YES。
local_umask=022           # 本地用户新增档案时的umask 值。
file_open_mode=0755       # 本地用户上传档案后的档案权限，与chmod 所使用的数值相同。默认值为0666。
dirmessage_enable=YES/NO  # 使用者第一次进入一个目录时，会检查该目录下是否有.message这个档案，
                          # 如果有，则会出现此档案的内容，通常这个档案会放置欢迎话语，或是对该目录的说明。
message_file=.message     # 设置目录消息文件，可将要显示的信息写入该文件。默认值为.message。
banner_file=/etc/vsftpd/banner # 当使用者登入时，会显示此设定所在的档案内容，通常为欢迎话语或是说明。默认值为无。如果欢迎信息较多，则使用该配置项。
ftpd_banner=Welcome to BOB's FTP server # 这里用来定义欢迎话语的字符串，banner_file是档案的形式，而ftpd_banner 则是字符串的形式。
```

### 访问控制设置

```bash
#控制主机访问：
tcp_wrappers=YES/NO  # 设置vsftpd是否与tcp wrapper相结合来进行主机的访问控制。默认值为YES。
# 如果启用，则vsftpd服务器会检查/etc/hosts.allow 和/etc/hosts.deny 中的设置
# 来决定请求连接的主机，是否允许访问该FTP服务器。这两个文件可以起到简易的防火墙功能。

#控制用户访问：
#对于用户的访问控制可以通过/etc目录下的vsftpd.user_list和ftpusers文件来实现
userlist_enable=YES/NO  # 是否启用vsftpd.user_list文件
userlist_file=/etc/vsftpd.user_list # 控制用户访问FTP的文件，里面写着用户名称。一个用户名称一行。
userlist_deny=YES/NO  # 决定vsftpd.user_list文件中的用户是否能够访问FTP服务器。
# 若设置为YES，则vsftpd.user_list文件中的用户不允许访问FTP，
# 若设置为NO，则只有vsftpd.user_list文件中的用户才能访问FTP。


# 控制用户是否允许切换到上级目录
chroot_list_enable=YES/NO    # 是否启动限制用户的名单
chroot_list_file=/etc/vsftpd/chroot_list  # 用于指定用户列表文件
chroot_local_user=YES       # 1.所有用户都被限制在其主目录下 2.使用chroot_list_file指定的用户列表，这些用户作为“例外”，不受限制
chroot_local_user=NO(默认)   # 1.所有用户都不被限制其主目录下 2.使用chroot_list_file指定的用户列表，这些用户作为“例外”，受到限制

# 数据传输模式设置
ascii_upload_enable=YES/NO
ascii_download_enable=YES/NO

# 定义用户配置文件
# 在vsftpd中，可以通过定义用户配置文件来实现不同的用户使用不同的配置。
user_config_dir=/etc/vsftpd/userconf
# 设置用户配置文件所在的目录。当设置了该配置项后，用户登陆服务器后，
# 系统就会到/etc/vsftpd/userconf目录下，读取与当前用户名相同的文件，并根据文件中的配置命令，对当前用户进行更进一步的配置。

```

对于chroot\_local\_user与chroot\_list\_enable的组合效果，可以参考下表：

||chroot\_local\_user=YES|chroot\_local\_user=NO|
| ------------------------------------------------------------------------------| --------------------------------| ------------------------------|
|chroot\_list\_enable=YES|1.所有用户都被限制在其主目录下||
|2.使用chroot\_list\_file指定的用户列表，这些用户作为“例外”，不受限制|1.所有用户都不被限制其主目录下||
|2.使用chroot\_list\_file指定的用户列表，这些用户作为“例外”，受到限制|||
|chroot\_list\_enable=NO|1.所有用户都被限制在其主目录下||
|2.不使用chroot\_list\_file指定的用户列表，没有任何“例外”用户|1.所有用户都不被限制其主目录下||
|2.不使用chroot\_list\_file指定的用户列表，没有任何“例外”用户|||

### 日志

```nginx
#vsftpd日志：默认不启用
dual_log_enable=YES                  # 使用vsftpd日志格式，默认不启用
vsftpd_log_file=/var/log/vsftpd.log  # 可自动生成， 此为默认值
```

### 提示信息

```bash
# 登录前提示信息
ftpd_banner="welcome to mage ftp server"   # 配置文件直接定义
banner_file=/etc/vsftpd/ftpbanner.txt      # 在文件中定义

# 目录访问提示信息
dirmessage_enable=YES    # 开启此为默认值
message_file=.message    # 信息存放在指定目录下.message ，此为默认值,只支持单行说明
```

### PAM模块实现用户访问控制

```bash
pam_service_name=vsftpd
#pam配置文件:/etc/pam.d/vsftpd
/etc/vsftpd/ftpusers   #默认文件中用户拒绝登录，默认是黑名单，但也可以是白名单

```

范例：

```bash
[11:00:56 root@ftp ~]#ldd /usr/sbin/vsftpd | grep pam
libpam.so.0 => /lib64/libpam.so.0 (0x00007fbe30904000)
[11:07:33 root@ftp ~]#cat /etc/pam.d/vsftpd
#%PAM-1.0
session    optional     pam_keyinit.so    force revoke
#将sense=deny 修改为 sense=allow    #修改黑名单为白名单
auth       required	pam_listfile.so item=user sense=allow file=/etc/vsftpd/ftpusers onerr=succeed
auth       required	pam_shells.so
auth       include	password-auth
account    include	password-auth
session    required     pam_loginuid.so
session    include	password-auth
```

### 连接数限制

```bash
max_clients=0  # 最大并发连接数
max_per_ip=0   # 每个IP同时发起的最大连接数
```

### 传输速率，单位：字节/秒

```bash
anon_max_rate=0    # 匿名用户的最大传输速率,以字节为单位,比如:1024000表示1MB/s
local_max_rate=0   # 本地用户的最大传输速率
```

**范例：**

```bash
#限速
[11:23:58 root@ftp ~]#vim /etc/vsftpd/vsftpd.conf
anon_max_rate=1024000
local_max_rate=10240000
#生成测试文件
[11:29:16 root@ftp ~]#dd if=/dev/zero of=/home/ls/1.test bs=1G count=2
[11:29:16 root@ftp ~]#dd if=/dev/zero of=/var/ftp/pub/1.test bs=1G count=2
#测试匿名下载速度
[11:30:50 root@centos8 ~]#wget ftp://192.168.10.81:2121/pub/1.test
1.test                 1%[                       ]  29.38M  1000KB/s    eta 34m 27s
#测试本地用户下载速度
[11:31:29 root@centos8 ~]#wget ftp://ls:123456@192.168.10.81:2121/1.test
1.test.1               4%[                       ]  83.57M  9.76MB/s    eta 3m 22s
```

### 连接时间：秒为单位

```bash
connect_timeout=60          # 主动模式数据连接超时时长
accept_timeout=60           # 被动模式数据连接超时时长
data_connection_timeout=300 # 数据连接无数据输超时时长
idle_session_timeout=60     # 无命令操作超时时长
```

### 以文本方式传输

以文本方式传输文件时,会自动对文件进行格式转换,比如转换成windows的文本格式

```bash
#启用此选项可使服务器在ASCII模式下实际对文件进行ASCII处理。
#默认是禁用,禁用后，服务器将假装允许ASCII模式，但实际上会忽略激活它的请求
ascii_upload_enable=YES
ascii_download_enable=YES
```

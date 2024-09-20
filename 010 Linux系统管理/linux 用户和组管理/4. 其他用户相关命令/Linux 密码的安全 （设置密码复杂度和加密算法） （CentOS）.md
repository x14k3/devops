# Linux 密码的安全 （设置密码复杂度和加密算法） （CentOS）

　　这个目录下文件的名称就代表服务的名称：

```bash
sds@notebook:~ $ ls /etc/pam.d
chage                              groupadd        smtp
chfn                               groupdel        sshd
chpasswd                           groupmod        su
chsh                               kde             sudo
common-account                     login           sudo-i
common-account.pam-config-backup   newusers        su-l
common-account-pc                  other           systemd-user
common-auth                        passwd          tigervnc
common-auth.pam-config-backup      polkit-1        useradd
common-auth-pc                     ppp             userdel
common-password                    remote          usermod
common-password.pam-config-backup  runuser         vlock
common-password-pc                 runuser-l       vnc
common-session                     samba           xdm
common-session.pam-config-backup   screen          xdm-np
common-session-pc                  sddm            xscreensaver
crond                              sddm-autologin
cups                               sddm-greeter
sds@notebook:~ $ 
```

　　Linux对应的密码策略模块有：pam_passwdqc 和 pam_pwquality。

　　**pam_passwdqc**：/etc/login.defs 密码过期时间等策略配置。

　　**pam_pwquality**：/etc/security/pwquality.conf 密码复杂度配置。

### 过期时间等配置

```bash
~]# cat /etc/login.defs
...
#密码最大有效期
PASS_MAX_DAYS   90
#两次修改密码的最小间隔时间
PASS_MIN_DAYS   0
#密码最小长度，对于root无效
PASS_MIN_LEN    8
#密码过期前多少天开始提示
PASS_WARN_AGE   30
...
```

　　‍

### 密码复杂度配置

```bash
~]# cat /etc/pam.d/system-auth
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_tally2.so deny=5 unlock_time=300 even_deny_root root_unlock_time=300
auth        required      pam_env.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so
 
account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so
 
#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so
 
session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
```

　　​`password requisite pam_pwquality.so try_first_pass local_users_only retry=5 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root`​

```bash
minlen=8   密码最小长度为8个字符。
lcredit=-1 密码应包含的小写字母的至少一个
ucredit=-1 密码应包含的大写字母至少一个
dcredit=-1 将密码包含的数字至少为一个
ocredit=-1 设置其他符号的最小数量，例如@，＃、! $％等，至少要有一个
enforce_for_root 确保即使是root用户设置密码，也应强制执行复杂性策略。
```

### 登陆过期配置

　　添加的内容一定要写在前面，如果写在后面，虽然用户被锁定，但是只要用户输入正确的密码，还是可以登录的！

　　下面这段如果配置在ssh文件里面就是限制的ssh，如果配置在login文件里限制的就是tty处登陆。

　　​`auth required pam_tally2.so deny=5 unlock_time=300 even_deny_root root_unlock_time=300`​

　　详解：

```bash
even_deny_root   # 也限制root用户
deny             # 设置普通用户和root用户连续错误登陆的最大次数，超过最大次数，则锁定该用户
unlock_time      # 设定普通用户锁定后，多少时间后解锁，单位是秒
root_unlock_time # 设定root用户锁定后，多少时间后解锁，单位是秒
#此处使用的是 pam_tally2 模块，如果不支持 pam_tally2 可以使用 pam_tally 模块。另外，不同的pam版本，设置可能有所不同，具体使用方法，可以参照相关模块的使用规则
```

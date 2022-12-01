#system/pam
## pam的配置文件

`vim /etc/pam.d/vsftpd`

```纯文本
#%PAM-1.0
session    optional     pam_keyinit.so    force revoke
auth       required     pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth       include      password-auth
account    include      password-auth
session    required     pam_loginuid.so
session    include      password-auth

```

## pam的常用模块

*   pam\_shell.so

    检查当前shell是否为安全的shell

*   pam\_limit.so

    在用户级别实现对其可用资源的限制，例如限制可打开的文件数量，可运行的进程数量，可用内存空间

*   pam\_access.so

    根据主机名或者FQDN、IP地址和用户实现全面的访问控制

*   pam\_time.so

    在不同时间、日期，终端对特定程序访问时进行验证

*   pam\_tally2.so　

    为避免暴力破解，在登录失败若干次后锁定账户

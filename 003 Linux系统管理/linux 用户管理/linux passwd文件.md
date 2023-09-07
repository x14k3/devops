# linux passwd文件

在 Linux 系统，可以使用几种不同的身份验证方案。最常用和标准的方案是对 /etc/passwd 和 /etc/shadow 文件执行认证。

/etc/passwd 是基于纯文本的数据库，其中包含系统所有用户帐户的信息，文件[所有权](https://www.myfreax.com/chmod-command-in-linux/)归root用户所有，具有 644 权限。

/etc/passwd 文件只能由root用户或具有 sudo 权限的用户可以修改，并且所有系统用户都可以读取。

除非您知道自己在做什么，否则应避免手动修改 /etc/passwd 文件。应该始终使用专门为此目的设计的命令。

例如要修改用户帐户，请使用 usermod 命令。如需要添加新的用户帐户，请使用useradd 命令。

```bash
root@sds:~# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
sshd:x:110:65534::/run/sshd:/usr/sbin/nologin
sds:x:1000:1000:sds:/home/sds:/bin/bash
postgres:x:1001:1001::/home/postgres:/bin/bash
test:x:1002:1002::/home/test:/bin/bash
用户名:口令:用户标识号:组标识号:注释性描述:主目录:登录Shell
```

‍

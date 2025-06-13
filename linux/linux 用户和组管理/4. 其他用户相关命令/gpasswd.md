

为了避免系统管理员（root）太忙碌，无法及时管理群组，我们可以使用 gpasswd 命令给群组设置一个群组管理员，代替 root 完成将用户加入或移出群组的操作。

gpasswd 命令的基本格式如下：

```bash
[root@localhost ~]# gpasswd 选项 组名
```

表 1 详细介绍了此命令提供的各种选项以及功能。

|选项|功能|
| --------------| ------------------------------------------------------------------------------------------------------------|
||选项为空时，表示给群组设置密码，仅 root 用户可用。|
|-A user1,...|将群组的控制权交给 user1,... 等用户管理，也就是说，设置 user1,... 等用户为群组的管理员，仅 root 用户可用。|
|-M user1,...|将 user1,... 加入到此群组中，仅 root 用户可用。|
|-r|移除群组的密码，仅 root 用户可用|
|-R|让群组的密码失效，仅 root 用户可用。|
|-a user|将 user 用户加入到群组中。|
|-d user|将 user 用户从群组中移除。|

从表 1 可以看到，除 root 可以管理群组外，可设置多个普通用户作为群组的管理员，但也只能做“将用户加入群组”和“将用户移出群组”的操作。

【例 1】

```bash
#创建新群组 group1，并将群组交给 lamp 管理
[root@localhost ~]# groupadd group1  <-- 创建群组
[root@localhost ~]# gpasswd group1   <-- 设置密码吧！
Changing the password for group group1
New Password:
Re-enter new password:
[root@localhost ~]# gpasswd -A lamp group1  <==加入群组管理员为 lamp
[root@localhost ~]# grep "group1" /etc/group /etc/gshadow
/etc/group:group1:x:506:
/etc/gshadow:group1:$1$I5ukIY1.$o5fmW.cOsc8.K.FHAFLWg0:lamp:
```

可以看到，此时 lamp 用户即为 group1 群组的管理员。

【例 2】

```bash
#以lamp用户登陆系统，并将用户 lamp 和 lamp1 加入group1群组。
[lamp@localhost ~]#gpasswd -a lamp group1
[lamp@localhost ~]#gpasswd -a lamp1 group1
[lamp@localhost ~]#grep "group1" /etc/group
group1:x:506:lamp,lamp1
```

前面讲过，使用 `usermod -G`​ 命令也可以将用户加入群组，但会产生一个问题，即使用此命令将用户加入到新的群组后，该用户之前加入的那些群组都将被清空。例如：

```bash
#新创建一个群组group2
[root@localhost ~]# groupadd group2
[root@localhost ~]# usermod -G group2 lamp
[root@localhost ~]# grep "group2" /etc/group
group2:x:509:lamp
[root@localhost ~]# grep "group1" /etc/group
group1:x:506:lamp1
```

对比例 2 可以发现，虽然使用 usermod 命令成功地将 lamp 用户加入在 group2 群组中，但 lamp 用户原本在 group1 群组中，此时却被移出，这就是使用 usermod 命令造成的。

因此，将用户加入或移出群组，最好使用 gpasswd 命令。

‍

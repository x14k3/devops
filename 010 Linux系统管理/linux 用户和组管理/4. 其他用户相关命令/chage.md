# chage

‍

除了 `passwd -S`​ 命令可以查看用户的密码信息外，还可以利用 chage 命令，它可以显示更加详细的用户密码信息，并且和 passwd 命令一样，提供了修改用户密码信息的功能。

**如果你要修改用户的密码信息，我个人建议，还是直接修改 /etc/shadow 文件更加方便。**

首先，我们来看 chage 命令的基本格式：

```bash
[root@localhost ~]#chage [选项] 用户名
```

选项： *  -l：列出用户的详细密码状态;

* -d 日期：修改 /etc/shadow 文件中指定用户密码信息的第 3 个字段，也就是最后一次修改密码的日期，格式为 YYYY-MM-DD；
* -m 天数：修改密码最短保留的天数，也就是 /etc/shadow 文件中的第 4 个字段；
* -M 天数：修改密码的有效期，也就是 /etc/shadow 文件中的第 5 个字段；
* -W 天数：修改密码到期前的警告天数，也就是 /etc/shadow 文件中的第 6 个字段；
* -i 天数：修改密码过期后的宽限天数，也就是 /etc/shadow 文件中的第 7 个字段；
* -E 日期：修改账号失效日期，格式为 YYYY-MM-DD，也就是 /etc/shadow 文件中的第 8 个字段。

【例 1】

```bash
#查看一下用户密码状态
[root@localhost ~]# chage -l lamp
Last password change:Jan 06, 2013
Password expires:never
Password inactive :never
Account expires :never
Minimum number of days between password change :0
Maximum number of days between password change :99999
Number of days of warning before password expires :7
```

读者可能会问，既然直接修改用户密码文件更方便，为什么还要讲解 chage 命令呢？因为 chage 命令除了修改密码信息的功能外，还可以强制用户在第一次登录后，必须先修改密码，并利用新密码重新登陆系统，此用户才能正常使用。

例如，我们创建 lamp 用户，并让其首次登陆系统后立即修改密码，执行命令如下：

```bash
#创建新用户 lamp
[root@localhost ~]#useradd lamp
#设置用户初始密码为 lamp
[root@localhost ~]#echo "lamp" | passwd --stdin lamp
#通过chage命令设置此账号密码创建的日期为 1970 年 1 月 1 日（0 就表示这一天），这样用户登陆后就必须修改密码
[root@localhost ~]#chage -d 0 lamp
```

这样修改完 lamp 用户后，我们尝试用 lamp 用户登陆系统（初始密码也是 lamp）：

```bash
local host login:lamp
Password:     <--输入密码登陆
You are required to change your password immediately (root enforced)
changing password for lamp.     <--有一些提示，就是说明 root 强制你登录后修改密码
(current)UNIX password:
#输入旧密码
New password:
Retype new password:
#输入两次新密码
```

chage 的这个功能常和 passwd  批量初始化用户密码功能合用，且对学校老师帮助比较大，因为老师不想知道学生账号的密码，他们在初次上课时就使用与学号相同的账号和密码给学生，让他们登陆时自行设置他们的密码。这样一来，既能避免学生之间随意使用别人的账号，也能保证学生知道如何修改自己的密码。

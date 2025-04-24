# passwd

passwd 命令的基本格式如下：

```bash
[root@localhost ~]#passwd [选项] 用户名
```

选项：

```bash
-S  # 查询用户密码的状态，也就是 /etc/shadow 文件中此用户密码的内容。仅 root 用户可用；
-l  # 暂时锁定用户，该选项会在 /etc/shadow 文件中指定用户的加密密码串前添加 "!"，使密码失效。仅 root 用户可用；
-u  # 解锁用户，和 -l 选项相对应，也是只能 root 用户使用；
--stdin  # 可以将通过管道符输出的数据作为用户的密码。主要在批量添加用户时使用；
-n 天数   # 设置该用户修改密码后，多长时间不能再次修改密码，也就是修改 /etc/shadow 文件中各行密码的第 4 个字段；
-x 天数   # 设置该用户的密码有效期，对应 /etc/shadow 文件中各行密码的第 5 个字段；
-w 天数   # 设置用户密码过期前的警告天数，对于 /etc/shadow 文件中各行密码的第 6 个字段；
-i 日期   # 设置用户密码失效日期，对应 /etc/shadow 文件中各行密码的第 7 个字段。
```

例如，我们使用 root 账户修改 lamp 普通用户的密码，可以使用如下命令：

```bash
[root@localhost ~]#passwd lamp
Changing password for user lamp.
New password: <==直接输入新的口令，但屏幕不会有任何反应
BAD PASSWORD: it is WAY too short <==口令太简单或过短的错误！这里只是警告信息，输入的密码依旧能用
Retype new password:  <==再次验证输入的密码，再输入一次即可
passwd: all authentication tokens updated successfully.  <==提示修改密码成功
```

当然，也可以使用 passwd 命令修改当前系统已登录用户的密码，但要注意的是，需省略掉 "选项" 和  "用户名"。例如，我们登陆 lamp 用户，并使用 passwd 命令修改 lamp 的登陆密码，执行过程如下：

```bash
[root@localhost ~]#passwd
#passwd直接回车代表修改当前用户的密码
Changing password for user vbird2.
Changing password for vbird2
(current) UNIX password: <==这里输入『原有的旧口令』
New password: <==这里输入新口令
BAD PASSWORD: it is WAY too short <==口令检验不通过，请再想个新口令
New password: <==这里再想个来输入吧
Retype new password: <==通过口令验证！所以重复这个口令的输入
passwd: all authentication tokens updated successfully. <==成功修改用户密码
```

注意，普通用户只能使用 passwd 命令修改自己的密码，而不能修改其他用户的密码。

可以看到，与使用 root 账户修改普通用户的密码不同，普通用户修改自己的密码需要先输入自己的旧密码，只有旧密码输入正确才能输入新密码。不仅如此，此种修改方式对密码的复杂度有严格的要求，新密码太短、太简单，都会被系统检测出来并禁止用户使用。

**很多Linux 发行版为了系统安装，都使用了 PAM 模块进行密码的检验，设置密码太短、与用户名相同、是常见字符串等，都会被 PAM 模块检查出来，从而禁止用户使用此类密码。有关 PAM 模块，后续章节会进行详细介绍。**

而使用 root 用户，无论是修改普通用户的密码，还是修改自己的密码，都可以不遵守 PAM 模块设定的规则，就比如我刚刚给 lamp  用户设定的密码是 "123"，系统虽然会提示密码过短和过于简单，但依然可以设置成功。当然，在实际应用中，就算是 root  身份，在设定密码时也要严格遵守密码规范，因为只有好的密码规范才是服务器安全的基础。

passwd 命令还提供了一些选项，接下来给大家介绍各个选项的具体用法。

【例 1】

```bash
#查看用户密码的状态
[root@localhost ~]# passwd -S lamp
lamp PS 2013-01-06 0 99999 7 -1 (Password set, SHA512 crypt.)
#上面这行代码的意思依次是：用户名 密码 设定时间(2013*01-06) 密码修改间隔时间(0) 密码有效期(99999) 警告时间(7) 密码不失效(-1)，密码已使用
```

"-S"选项会显示出密码状态，这里的密码修改间隔时间、密码有效期、警告时间、密码宽限时间其实分别是 /etc/shadow 文件的第四、五、六、七个字段的内容。 当然，passwd 命令是可以通过命令选项修改这几个字段的值的，例如：

```bash
#修改 lamp的密码，使其具有 60 天变更、10 天密码失效
[root@localhost ~]# passwd -x 60 -i 10 lamp
[root@localhost ~]# passwd -S lamp
lamp PS 2013-01-06 0 60 7 10 (Password set, SHA512 crypt.)
但我个人认为，还是直接修改 /etc/shadow 文件简单一些。
```

这里显示 SHA512 为密码加密方式，CentOS 6.3 加密方式已经从 MD5 加密更新到 SHA512 加密，我们不用了解具体的加密算法，只要知道这种加密算法更加可靠和先进就足够了。

【例 2】

```bash
#锁定 lamp 用户
[root@localhost ~]# passwd -I lamp
Locking password for user lamp.
passwd:Successg
#用"-S"选项査看状态，很清楚地提示密码已被锁定
[root@localhost ~]# passwd -S lamp
lamp LK 2013-01-06 0 99999 7 -1 (Password locked.)
[root@localhost ~]# grep "lamp" /etc/shadow
lamp:!! $6$ZTq7o/9o $lj07iZ0bzW.D1zBa9CsY43d04onskUCzjwiFMNt8PX4GXJoHX9zA1S C9.i Yzh9LZA4fEM2lg92hM9w/p6NS50.:15711:0:99999:7:::
#可以看到，锁定其实就是在加密密码之前加入了"!!"，让密码失效而已
```

暂时锁定 lamp 用户后，此用户就不能登录系统了。那么，怎么解锁呢？也一样简单，使用如下命令即可：

```bash
#解锁 lamp 用户
[root@localhost ~]# passwd -u lamp
Unlocking password for user lamp.
passwd:Success
[root@localhost ~]# passwd -S lamp
lamp PS 2013-01-06 0 99999 7 -1 (Password set, SHA512 crypt.)
#可以看到，锁定状态消失
[root@localhost ~]# grep "lamp" /etc/shadow
lamp: $6$ZTq7cV9o $lj07iZ0bzW.D1zBa9CsY43d04onskUCzjwiFMNt8PX4GXJoHX9zA1S C9.iYz h9LZA4fEM2lg92hM9w/p6NS50.:15711:0:99999:7:::
#密码前面的 "!!" 删除了
```

【例 3】

```bash
#调用管道符，给 lamp 用户设置密码 "123"
[root@localhost ~]# echo "123" | passwd --stdin lamp
Changing password for user lamp.
passwd: all authentication tokens updated successfully.
```

为了方便系统管理，passwd 命令提供了 --stdin 选项，用于批量给用户设置初始密码。

使用此方式批量给用户设置初始密码，当然好处就是方便快捷，但需要注意的是，这样设定的密码会把密码明文保存在历史命令中，如果系统被攻破，别人可以在 /root/.bash_history 中找到设置密码的这个命令，存在安全隐患。

因此，读者如果使用这种方式修改密码，那么应该记住两件事情：第一，手工清除历史命令；第二，强制这些新添加的用户在第一次登录时必须修改密码（具体方法参考 "chage" 命令）。

注意，并非所有 Linux 发行版都支持使用此选项，使用之前可以使用 man passwd 命令确认当前系统是否支持。

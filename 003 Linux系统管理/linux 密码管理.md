# linux 密码管理

账号犹如一张通行证，有了账号你才能顺利的使用Linux。不过 Linux 怎么确认使用某账号的人，是这个账号的真正拥有者呢？此时Linux 会根据用户的密码，来确认用户的身份。Linux 的用户账号与群组账号都可设置密码。用户账号的密码用来验证用户的身份；而群组账号的密码则是用来确认用户是否为该群组的成员，以及确认是否为该群组的管理者。

在 Linux 中，使用 useradd 新建一个用户账号时，useradd 会锁定用户的密码，如此一来，用户暂时不能使用 。你必须要修改其密码后，新建的用户才能用他的账号登录。要修改用户账号的密码需要使用passwd命令

## passwd

**用法: passwd [选项...] &lt;帐号名称&gt;**​

```
  -k, --keep-tokens       保持身份验证令牌不过期
  -d, --delete            删除已命名帐号的密码(只有根用户才能进行此操作)
  -l, --lock              锁定指名帐户的密码(仅限 root 用户)
  -u, --unlock            解锁指名账户的密码(仅限 root 用户)
  -e, --expire            终止指名帐户的密码(仅限 root 用户)
  -f, --force             强制执行操作
  -x, --maximum=DAYS      密码的最长有效时限(只有根用户才能进行此操作)
  -n, --minimum=DAYS      密码的最短有效时限(只有根用户才能进行此操作)
  -w, --warning=DAYS      在密码过期前多少天开始提醒用户(只有根用户才能进行此操作)
  -i, --inactive=DAYS     当密码过期后经过多少天该帐号会被禁用(只有根用户才能进行此操作)
  -S, --status            报告已命名帐号的密码状态(只有根用户才能进行此操作)
  --stdin                 从标准输入读取令牌(只有根用户才能进行此操作)
```

### 知识扩展

与用户、组账户信息相关的文件

存放用户信息：

```shell
/etc/passwd
/etc/shadow
```

存放组信息：

```shell
/etc/group
/etc/gshadow
```

* 📄 [linux shadow文件](siyuan://blocks/20230610173728-xs4na7q)

### 实例

如果是普通用户执行passwd只能修改自己的密码。如果新建用户后，要为新用户创建密码，则用passwd用户名，注意要以root用户的权限来创建。

```shell
[root@localhost ~]# passwd linuxde     # 更改或创建linuxde用户的密码；
Changing password for user linuxde.
New UNIX password:           # 请输入新密码；
Retype new UNIX password:    # 再输入一次；
passwd: all authentication tokens updated successfully.  # 成功；
```

普通用户如果想更改自己的密码，直接运行passwd即可，比如当前操作的用户是linuxde。

```shell
[linuxde@localhost ~]$ passwd
Changing password for user linuxde.  # 更改linuxde用户的密码；
(current) UNIX password:    # 请输入当前密码；
New UNIX password:          # 请输入新密码；
Retype new UNIX password:   # 确认新密码；
passwd: all authentication tokens updated successfully.  # 更改成功；
```

比如我们让某个用户不能修改密码，可以用`-l`​选项来锁定：

```shell
[root@localhost ~]# passwd -l linuxde     # 锁定用户linuxde不能更改密码；
Locking password for user linuxde.
passwd: Success            # 锁定成功；

[linuxde@localhost ~]# su linuxde    # 通过su切换到linuxde用户；
[linuxde@localhost ~]$ passwd       # linuxde来更改密码；
Changing password for user linuxde.
Changing password for linuxde
(current) UNIX password:           # 输入linuxde的当前密码；
passwd: Authentication token manipulation error      # 失败，不能更改密码；
```

再来一例：

```shell
[root@localhost ~]# passwd -d linuxde   # 清除linuxde用户密码；
Removing password for user linuxde.
passwd: Success                          # 清除成功；

[root@localhost ~]# passwd -S linuxde     # 查询linuxde用户密码状态；
Empty password.                          # 空密码，也就是没有密码；
```

注意：当我们清除一个用户的密码时，登录时就无需密码，这一点要加以注意。

## chpasswd

**chpasswd命令** 是批量更新用户口令的工具，是把一个文件内容重新定向添加到`/etc/shadow`​​中。

```shell
chpasswd(选项)
-e：输入的密码是加密后的密文；
-h：显示帮助信息并退出；
-m：当被支持的密码未被加密时，使用MD5加密代替DES加密。
```

### 实例

先创建用户密码对应文件，格式为`username:password`​，如`abc:abc123`​，必须以这种格式来书写，并且不能有空行，保存成文本文件user.txt，然后执行chpasswd命令：

```shell
chpasswd < user.txt
```

以上是运用chpasswd命令来批量修改密码。是linux系统管理中的捷径。

## chage

修改帐号和密码的有效期限

```bash
chage [选项] 用户名
-m：密码可更改的最小天数。为零时代表任何时候都可以更改密码。
-M：密码保持有效的最大天数。
-w：用户密码到期前，提前收到警告信息的天数。
-E：帐号到期的日期。过了这天，此帐号将不可用。
-d：上一次更改的日期。
-I：停滞时期。如果一个密码已过期这些天，那么此帐号将不可用。
-l：例出当前的设置。由非特权用户来确定他们的密码或帐号何时过期。
```

### 实例

可以编辑`/etc/login.defs`​来设定几个参数，以后设置口令默认就按照参数设定为准：

```shell
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_MIN_LEN    5
PASS_WARN_AGE   7
```

当然在`/etc/default/useradd`​可以找到如下2个参数进行设置：

```shell
# useradd defaults file
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```

通过修改配置文件，能对之后新建用户起作用，而目前系统已经存在的用户，则直接用chage来配置。

我的服务器root帐户密码策略信息如下：

```shell
chage -l root

最近一次密码修改时间                  ： 3月 12, 2013
密码过期时间                         ：从不
密码失效时间                         ：从不
帐户过期时间                         ：从不
两次改变密码之间相距的最小天数          ：0
两次改变密码之间相距的最大天数          ：99999
在密码过期之前警告的天数               ：7
```

我可以通过如下命令修改我的密码过期时间：

```shell
chage -M 60 root
chage -l root

最近一次密码修改时间                  ： 3月 12, 2013
密码过期时间                         ： 5月 11, 2013
密码失效时间                         ：从不
帐户过期时间                         ：从不
两次改变密码之间相距的最小天数          ：0
两次改变密码之间相距的最大天数          ：60
在密码过期之前警告的天数               ：9
```

然后通过如下命令设置密码失效时间：

```shell
chage -I 5 root
chage -l root

最近一次密码修改时间                  ： 3月 12, 2013
密码过期时间                         ： 5月 11, 2013
密码失效时间                         ： 5月 16, 2013
帐户过期时间                         ：从不
两次改变密码之间相距的最小天数          ：0
两次改变密码之间相距的最大天数          ：60
在密码过期之前警告的天数               ：9
```

从上述命令可以看到，在密码过期后5天，密码自动失效，这个用户将无法登陆系统了。

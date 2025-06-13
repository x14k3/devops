

我们知道，使用 su 命令可以让普通用户切换到 root 身份去执行某些特权命令，但存在一些问题，比如说：

- 仅仅为了一个特权操作就直接赋予普通用户控制系统的完整权限；
- 当多人使用同一台主机时，如果大家都要使用 su 命令切换到 root 身份，那势必就需要 root 的密码，这就导致很多人都知道 root 的密码；

考虑到使用 su 命令可能对系统安装造成的隐患，最常见的解决方法是使用 sudo 命令，此命令也可以让你切换至其他用户的身份去执行命令。

相对于使用 su 命令还需要新切换用户的密码，sudo 命令的运行只需要知道自己的密码即可，甚至于，我们可以通过手动修改 sudo 的配置文件，使其无需任何密码即可运行。

sudo 命令默认只有 root 用户可以运行，该命令的基本格式为：

```bash
[root@localhost ~]# sudo [-b] [-u 新使用者账号] 要执行的命令
```

常用的选项与参数： 

- -b  ：将后续的命令放到背景中让系统自行运行，不对当前的 shell 环境产生影响。
- -u  ：后面可以接欲切换的用户名，若无此项则代表切换身份为 root 。
- -l： 此选项的用法为 sudo -l，用于显示当前用户可以用 sudo 执行那些命令。

## 赋予用户sudo操作的权限

```bash
#通过useradd添加的用户，并不具备sudo权限。在ubuntu/centos等系统下, 需要将用户加入admin组或者wheel组或者sudo组。以root用户身份执行如下命令, 将用户加入wheel/admin/sudo组:
usermod -a -G wheel <用户名>

#如果提示wheel组不存在, 则还需要先创建该组:
groupadd wheel
```

## /etc/sudoers内容详解

修改 /etc/sudoers，不建议直接使用 vim，而是使用 visudo。因为修改 /etc/sudoers  文件需遵循一定的语法规则，使用 visudo 的好处就在于，当修改完毕 /etc/sudoers 文件，离开修改页面时，系统会自行检验  /etc/sudoers 文件的语法。

因此，修改 /etc/sudoers 文件的命令如下：

```bash
#Defaults targetpw   # ask for the password of the target user i.e. root
ALL   ALL=(ALL) ALL   # WARNING! Only use this together with 'Defaults targetpw'!

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL:ALL) ALL
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) ALL

## Same thing without a password
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL

## Read drop-in files from /etc/sudoers.d

```

```bash
sudo的权限控制可以在/etc/sudoers文件中查看到。一般来说，通过cat /etc/sudoers指令来查看该文件, 会看到如下几行代码:
root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL) ALL
%sudo ALL=(ALL:ALL) ALL

对/etc/sudoers文件进行编辑的代码公式可以概括为:
授权用户/组 主机=[(切换到哪些用户或组)] [是否需要输入密码验证] 命令1,命令2,...
凡是[ ]中的内容, 都能省略; 命令和命令之间用,号分隔，为了方便说明, 将公式的各个部分称呼为字段1 - 字段5:
授权用户/组 主机 =[(切换到哪些用户或组)] [是否需要输入密码验证] 命令1,命令2,...
字段1 字段2 =[(字段3)] [字段4] 字段5
字段3、字段4，是可以省略的。

在上面的默认例子中：
	"字段1"不以%号开头的表示"将要授权的用户", 比如例子中的root；以%号开头的表示"将要授权的组", 比如例子中的%wheel组 和 %sudo组。
　	"字段2"表示允许登录的主机, ALL表示所有; 如果该字段不为ALL,表示授权用户只能在某些机器上登录本服务器来执行sudo命令. 比如:jack mycomputer=/usr/sbin/reboot,/usr/sbin/shutdown 表示: 普通用户jack在主机(或主机组)mycomputer上, 可以通过sudo执行reboot和shutdown两个命令。"字段3"和"字段4"省略。
　　"字段3"如果省略, 相当于(root:root)，表示可以通过sudo提权到root; 如果为(ALL)或者(ALL:ALL), 表示能够提权到(任意用户:任意用户组)。请注意，"字段3"如果没省略,必须使用( )双括号包含起来。这样才能区分是省略了"字段3"还是省略了"字段4"。
　　"字段4"的可能取值是NOPASSWD:。请注意NOPASSWD后面带有冒号:。表示执行sudo时可以不需要输入密码。比如:lucy ALL=(ALL) NOPASSWD: /bin/useradd表示: 普通用户lucy可以在任何主机上, 通过sudo执行/bin/useradd命令, 并且不需要输入密码.又比如:peter ALL=(ALL) NOPASSWD: ALL
　　表示: 普通用户peter可以在任何主机上, 通过sudo执行任何命令, 并且不需要输入密码。
　　"字段5"是使用逗号分开一系列命令,这些命令就是授权给用户的操作; ALL表示允许所有操作。命令都是使用绝对路径, 这是为了避免目录下有同名命令被执行，从而造成安全隐患。如果你将授权写成如下安全性欠妥的格式:lucy ALL=(ALL) chown,chmod,useradd那么用户就有可能创建一个他自己的程序, 也命名为userad, 然后放在它的本地路径中, 如此一来他就能够使用root来执行这个"名为useradd的程序"。这是相当危险的!
命令的绝对路径可通过which指令查看到: 比如which useradd可以查看到命令useradd的绝对路径: /usr/sbin/useradd
```

## 其他说明

​`targetpw`​此标志控制调用用户是需要输入目标用户（例如 `root`​）的口令 (ON) 还是需要输入调用用户的口令 (OFF)。

```
Defaults targetpw # Turn targetpw flag ON
```

​`rootpw`​如果设置，`sudo`​ 将提示输入 `root`​ 口令。默认值为 OFF。

```
Defaults !rootpw # Turn rootpw flag OFF
```

​`env_reset`​如果设置，`sudo`​ 会构造一个具有 `TERM`​、`PATH`​、`HOME`​、`MAIL`​、`SHELL`​、`LOGNAME`​、`USER`​、`USERNAME`​ 和 `SUDO_*`​ 的极简环境。此外，会从调用环境导入 `env_keep`​ 中列出的变量。默认值为“ON”。

```
Defaults env_reset # Turn env_reset flag ON
```

## sudo 有效时间修改

打开 `/etc/sudoers`​ 文件

```bash
#请找到下面行
Defaults env_reset

#改变此行为下面这样
Defaults env_reset, timestamp_timeout=x
```

‍

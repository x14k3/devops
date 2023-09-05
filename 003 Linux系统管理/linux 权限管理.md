# linux 权限管理

Linux系统是一个典型的多用户操作系统，不同的用户处于不同的地位，为了保护系统的安全性，linux系统对于不同用户访问同一个文件或目录做了不同的访问控制。而这种控制就是通过权限实现的，本节课我们介绍linux权限的使用

# 一、基本权限

## 1.1 基本权限的介绍

Linux中每个文件或目录都有3个基本权限位，控制三种访问级别用户的读、写、执行，所以linux的基本权限位一共有9个。基本权限位和另外3个可以影响可执行程序运行的3个特殊权限位一起构成了文件访问模式。三个属性规定了对应三种级别的用户能够如何使用这个文件，这三个基本权限位对于文件和目录的含义有所差别的，我们一起来看一下

|字符|权限|对文件的含义|对目录的含义|
| ----| ----| --------------------------------------------| ----------------------------|
|r|读|意味着我们可以查看阅读|可以列出目录中的文件列表|
|w|写|意味着，对文件可以修改或删除|可以在该目录中创建、删除文件|
|x|执行|如果是文件就可以运行，比如二进制文件或脚本。|可以使用cd命令进入该目录|

那三种访问级别都有哪些呢？每个文件都有三组不同的读、写和执行权限，分别适用于三种访问级别，其中每组中的三个栏位分别使用读取权限（r）、写入权限（w）、执行权限（x）或没有相应的权限（-）来表示，共9位来表示。

![1571370358704.png](https://www.zutuanxue.com:8000/static/media/images/2020/10/11/1602399589987.png)

- 第一组：适用于文件的属主，图中属主的权限是rwx。
- 第二组：适用于文件的属组，图中属组的权限是r-x。
- 第三组：使用于其它用户权限位，图中其它用户权限位是r-x。

当有人试图访问一个文件的时候，linux系统会按顺序执行如下步骤：

（1）使用者拥有这个文件吗？如果是，启用用户权限。

（2）用户是组所有者成员吗？如果是，启用组权限

（3）如果以上两个都不是，启用其它人权限

上面我们提到的是第一种表示方法，在linux中还有另外一种表示方法，八进制表示法，我们来看下字母和八进制表示方法的对应关系

|字符表示法|八进制表示法|含义|
| ----------| ------------| ----|
|r|4|读|
|w|2|写|
|x|1|执行|

所以上面给出的权限rwxr-xr-x换成数字的表示方式就是755，那权限如何设置呢？

## 1.2 基本权限的设置和查看

通过前面的学习我们知道，用户分为所有者，所有者组，其他人这三类，而每一类有包含三种基本权限，他们的对应关系是

|权限位|含义|
| --------------| ------------------------------------------------------------|
|属主权限位|用于限制文件或目录的创建者|
|属组权限位|用于限制文件或目录所属组的成员|
|其它用户的权限|用于限制既不是属主又不是所属组的能访问该文件或目录的其他人员|

当我们使用命令来查看文件或目录时，会看如下内容

```
[root@zutuanxue ~]# ls -l
总用量 13804
drwxr-xr-x.  2 root root        6 10月 11 06:36 公共
drwxr-xr-x.  2 root root        6 10月 11 06:36 模板
drwxr-xr-x.  2 root root        6 10月 11 06:36 视频
drwxr-xr-x.  2 root root        6 10月 11 06:36 图片
drwxr-xr-x.  2 root root        6 10月 11 06:36 文档
drwxr-xr-x.  2 root root        6 10月 11 06:36 下载
drwxr-xr-x.  2 root root        6 10月 11 06:36 音乐
drwxr-xr-x.  2 root root        6 10月 11 06:36 桌面
-rw-------.  1 root root     1214 10月 11 06:12 anaconda-ks.cfg
-rw-r--r--.  1 root root     1369 10月 11 06:17 initial-setup-ks.cfg
```

每一行显示一个文件或目录的信息，这些信息包括文件的类型（1位）、文件的权限(9位)、文件的连接数、文件的属主（第3列）、文件的所属组（第4列），大小以及相关时间和文件名。其中Linux 文件的权限标志位九个，分为3 组，分别代表文件拥有者的权限，文件所属用户组的权限和其它用户的权限，现在我们知道文件有三种权限（（r）读取、（w）写入和（x）执行）和三种访问级别（（u）用户、（g）主要组和（o）其它人）决定文件可以被如何使用。那如何修改？

- **chmod命令:修改文件权限**

![1571375694210.png](https://www.zutuanxue.com:8000/static/media/images/2020/10/11/1602399812604.png)

|缩写|含义|
| ----| --------------|
|u|User(用户)|
|g|Group (组)|
|o|Other(其它)|
|a|All(所有)|
|+|Add(加)|
|-|Remove(减去)|
|=|Set (设置)|
|r|Read (可读)|
|w|Write (可写)|
|x|Execute (执行)|

|命令|作用|结果权限|
| -------------------| ------------------------------------| -----------|
|chmod o-r a.file|取消其他人的可读权限|rw-rw—|
|chmod g-w a.file|取消组的写入权限|rw-r–r--|
|chmod ug+w a.file|赋予用户和组写入权限|rwxrwxr–|
|chmod o+w a.file|赋予其他人写入权限|rw-rw-rw-|
|chmod go-rwx a.file|取消组和其他人的阅读、写入和执行权限|rw-------|
|chmod a-w a.file|取消所有人的写入权限|r-- r-- r–|
|chmod uo-r a.file|取消用户和其它人的阅读权限|-w-rw–w-|
|chmod go=rw a.file|将组和其他人的权限设置为阅读和写入|rw-rw-rw-|

使用数字的表示方式类似chmod 755 a,执行完成后a这个文件的权限对应就是 -rwxr-xr-x,这是文件权限的两种修改方式，如果你想修改文件的所有者和所有者组需要使用的命令就是chown,chgrp

- **chown命令:改变文件或文件夹的所有者**

```
[root@zutuanxue test]# ll
总用量 0
-rw-r--r-- 1 root root 0 10月 18 01:26 file1
[root@zutuanxue test]# chown oracle file1
[root@zutuanxue test]# ll
总用量 0
-rw-r--r-- 1 oracle root 0 10月 18 01:26 file1
```

- **chgrp命令: 改变文件或文件夹属组**

```
[root@zutuanxue test]# chgrp oracle file1
[root@zutuanxue test]# ll
总用量 0
-rw-r--r-- 1 oracle oracle 0 10月 18 01:26 file1
```

这里，我们涉及到了三条与权限修改相关的命令

|操作|可以执行的用户|
| -----| --------------------------------------|
|chmod|Root用户和文件的所有者|
|chgrp|Root用户和文件的所有者（必须是组成员）|
|chown|只有root用户|

以上是三种基本权限 -R

## 1.3 文件或目录的默认权限

每一个新产生的文件都会有一个默认的权限，这个权限是通过系统中的umask来控制的

文件的最大权限是666

目录的权限是777

使用umask查看

# 二、特殊权限

linux基本权限只是规定了所有者、属组、其他人三种用户的权限，如果希望对文件或文件夹做一些特殊的权限设置呢？
比如：

- 设置属组继承权限
- 为执行文件设置临时超管执行权限
- 公共文件夹中的文件谁建立谁删除
  这些任务基本权限就解决不聊了，需要解决这个问题得靠特殊权限。

## 2.1 特殊权限的介绍

之前我们提到了特殊权限有三个，这三个特殊权限是在可执行程序运行时影响操作权限的，它们分别是SUID,SGID,sticky-bit位

|特殊权限|说明|
| ---------| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|SUID|当一个设置了SUID 位的可执行文件被执行时，该文件将以所有者的身份运行，也就是说无论谁来执行这个文件，他都有文件所有者的特权。任意存取该文件拥有者能使用的全部系统资源。如果所有者是 root 的话，那么执行人就有超级用户的特权了。|
|SGID|当一个设置了SGID 位的可执行文件运行时，该文件将具有所属组的特权，任意存取整个组所能使用的系统资源；若一个目录设置了SGID，则所有被复制到这个目录下的文件，其所属的组都会被重设为和这个目录一样，除非在复制文件时保留文件属性，才能保留原来所属的群组设置。|
|stickybit|对一个文件设置了sticky-bit之后，尽管其他用户有写权限，也必须由属主执行删除、移动等操作；对一个目录设置了sticky-bit之后，存放在该目录的文件仅准许其属主执行删除、移动等操作。|

一个典型的例子就是passwd命令，这个命令允许用户修改自己的密码。我们可以看到本来是rwx的权限表示形式变成了rws，同样如果/usr/bin/passwd这个文件同时被设置了三个特殊权限，那么权限的格式就会变成rwsrwsrwt,需要注意的是特殊权限设置的前置要求是可执行，也就是如果没有x权限位，是不要设置的，即便你使用root用户设置上了特殊权限，也不会生效。

```
[root@zutuanxue test]# ll /usr/bin/passwd 
-rwsr-xr-x. 1 root root 34928 5月  11 11:14 /usr/bin/passwd
```

## 2.2 特殊权限的设置和查看

**特殊权限的设置也是使用chmod**

```
[root@zutuanxue test]# ll
总用量 0
-rwxr-xr-x 1 oracle oracle 0 10月 18 01:26 file1
[root@zutuanxue test]# chmod u+s file1
[root@zutuanxue test]# ll
总用量 0
-rwsr-xr-x 1 oracle oracle 0 10月 18 01:26 file1
[root@zutuanxue test]# chmod g+s file1
[root@zutuanxue test]# ll
总用量 0
-rwsr-sr-x 1 oracle oracle 0 10月 18 01:26 file1
[root@zutuanxue test]# chmod o+t file1
[root@zutuanxue test]# ll
总用量 0
-rwsr-sr-t 1 oracle oracle 0 10月 18 01:26 file1
```

或者使用数字

```
[root@zutuanxue test]# chmod u-s,g-s,o-t file1
[root@zutuanxue test]# ll
总用量 0
-rwxr-xr-x 1 oracle oracle 0 10月 18 01:26 file1
[root@zutuanxue test]# chmod 7755 file1
[root@zutuanxue test]# ll
总用量 0
-rwsr-sr-t 1 oracle oracle 0 10月 18 01:26 file1
```

# 三、隐藏权限

有时候你发现即时使用的是root用户也不能修改某个文件，大部分原因是因为使用过chattr命令锁定了该文件，这个命令的作用很大，通过chattr可以提高系统的安全性，但是这个命令并不适合所有的目录，如/dev,/tmp,/var。与我们前面看到的chmod这些命令修改权限不同的是chattr修改的是更底层的属性，这里面我们所提到的隐藏权限指的就是使用chattr来设置属性

## 3.1 隐藏权限的设置和查看

chattr的用户与我们之前讲的chmod，chow这些命令相似，都是直接对需要修改的文件进行操作就可以了

- **chattr命令：为文件设置隐藏权限**

```
命令选项
+ 增加权限
- 删除权限
= 赋予什么权限，文件最终权限
A 文件或目录的atime不可被修改
S 硬盘I/O同步选项，功能类似sync。
a 只能向文件中添加数据，而不能删除，多用于服务器日志文件安全，只有root才能设定这个属性。
d 文件不能成为dump程序的备份目标。
i 设定文件不能被删除、改名、设定链接关系，同时不能写入或新增内容。
```

- **lsattr命令: 查看文件隐藏权限**

通过案例学习命令用法：

```
给file1文件添加AaiSd权限
[root@zutuanxue test]# chattr +AaiSd file1

查看文件file1隐藏权限
[root@zutuanxue test]# lsattr file1 
--S-iadA---------- file1

设置删除file1文件隐藏权限
- 可以使用-号  
- 可以使用=为空设置
[root@zutuanxue test]# chattr = file1
[root@zutuanxue test]# lsattr file1 
------------------ file1
```

通过上面的例子可以看到查看的时候使用的是lsattr，chattr还有很多参数，各位可以在man手册中获取到帮助，另外有些参数的使用是有局限性的。

# 四、sudo & su

## 4.1 sudo

**sudo命令** 用来以其他身份来执行命令，预设的身份为root。在`/etc/sudoers`​中设置了可执行sudo指令的用户。若其未经授权的用户企图使用sudo，则会发出警告的邮件给管理员。用户使用sudo时，必须先输入密码，之后有5分钟的有效期限，超过期限则必须重新输入密码。

延长Linux中sudo密码在终端的有效时间

```bash
vim  /etc/sudoers
Defaults env_reset,timestamp_timeout=20
```

### **给用户添加sudo权限**

根据需要可以选择下面四行中的一行：

```bash
# 允许用户youuser执行sudo命令(需要输入密码).
youuser ALL=(ALL) ALL 
# 允许用户组youuser里面的用户执行sudo命令(需要输入密码).
%youuser ALL=(ALL) ALL 
# 允许用户youuser执行sudo命令,并且在执行的时候不输入密码.
youuser ALL=(ALL) NOPASSWD: ALL 
# 允许用户组youuser里面的用户执行sudo命令,并且在执行的时候不输入密码.
%youuser ALL=(ALL) NOPASSWD: ALL
```

### Defaults 配置项

使用 Defaults 配置，可以改变 sudo 命令的行为，如：

```
# 指定用户尝试输入密码的次数，默认值为3
Defaults passwd_tries=5

# 设置密码超时时间，默认为 5 分钟
Defaults passwd_timeout=2

# 默认 sudo 询问用户自己的密码，添加 targetpw 或 rootpw 配置可以让 sudo 询问 root 密码
Defaults targetpw

# 指定自定义日志文件
Defaults logfile="/var/log/sudo.log"

# 要在自定义日志文件中记录主机名和四位数年份，可以加上 log_host 和 log_year 参数
Defaults log_host, log_year, logfile="/var/log/sudo.log"

# 保持当前用户的环境变量
Defaults env_keep += "LANG LC_ADDRESS LC_CTYPE COLORS DISPLAY HOSTNAME EDITOR"
Defaults env_keep += "ftp_proxy http_proxy https_proxy no_proxy"

# 安置一个安全的 PATH 环境变量
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

‍

## 4.2 su

‍

‍

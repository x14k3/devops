Linux 系统传统的权限控制方式，无非是利用 3 种身份（文件所有者，所属群组，其他用户），并分别搭配 3 种权限（读 r，写 w，访问 x）。比如，我们可以通过 ls -l 命令查看当前目录中所有文件的详细信息，其中就包含对各文件的权限设置：

```bash
[root@localhost ~]# ls -l
total 36
drwxr-xr-x. 2 root root 4096 Apr 15 16:33 Desktop
drwxr-xr-x. 2 root root 4096 Apr 15 16:33 Documents
...
-rwxr-xr-x. 2 root root 4096 Apr 15 16:33 post-install
...
```

以上输出信息中，“rwxr-xr-x”就指明了不同用户访问文件的权限，即文件所有者拥有对文件的读、写、访问权限（rwx），文件所属群组拥有对文件的读、访问权限（r-x），其他用户拥有对文件的读、访问权限（r-x）。

权限前的字符，表示文件的具体类型，比如 d 表示目录，- 表示普通文件，l 表示连接文件，b 表示设备文件，等等。
但在实际应用中，以上这 3 种身份根本不够用，给大家举个例子。
![[linux/linux 文件属性和权限/assets/273a4f9f1471339044901c33a8965214_MD5.jpg]]

图 1 的根目录中有一个 /project 目录，这是班级的项目目录。班级中的每个学员都可以访问和修改这个目录，老师需要拥有对该目录的最高权限，其他班级的学员当然不能访问这个目录。
需要怎么规划这个目录的权限呢？应该这样，老师使用 root 用户，作为这个目录的属主，权限为 rwx；班级所有的学员都加入 tgroup 组，使 tgroup 组作为 /project 目录的属组，权限是 rwx；其他人的权限设定为 0（也就是 ---）。这样一来，访问此目录的权限就符合我们的要求了。
有一天，班里来了一位试听的学员 st，她必须能够访问 /project 目录，所以必须对这个目录拥有 r 和 x 权限；但是她又没有学习过以前的课程，所以不能赋予她 w 权限，怕她改错了目录中的内容，所以学员 st 的权限就是 r-x。可是如何分配她的身份呢？变为属主？当然不行，要不 root 该放哪里？加入 tgroup 组？也不行，因为 tgroup 组的权限是 rwx，而我们要求学员 st 的权限是 r-x。如果把其他人的权限改为 r-x 呢？这样一来，其他班级的所有学员都可以访问 /project 目录了。
显然，普通权限的三种身份不够用了，无法实现对某个单独的用户设定访问权限，这种情况下，就需要使用 ACL 访问控制权限。
ACL，是 Access Control List（访问控制列表）的缩写，在 Linux 系统中， ACL 可实现对单一用户设定访问文件的权限。也可以这么说，设定文件的访问权限，除了用传统方式（3 种身份搭配 3 种权限），还可以使用 ACL 进行设定。拿本例中的 st 学员来说，既然赋予它传统的 3 种身份，无法解决问题，就可以考虑使用 ACL 权限控制的方式，直接对 st 用户设定访问文件的 r-x 权限。

## 开启 ACL 权限
CentOS 6.x 系统中，ACL 权限默认处于开启状态，无需手工开启。但如果你的操作系统不是 CentOS 6.x，可以通过如下方式查看ACL权限是否开启：

```bash
[root@localhost ~]# mount
/dev/sda1 on /boot type ext4 (rw)
/dev/sda3 on I type ext4 (rw)
…省略部分输出…
#使用mount命令可以看到系统中已经挂载的分区，但是并没有看到ACL权限的设置
[root@localhost ~]# dumpe2fs -h /dev/sda3
#dumpe2fs是查询指定分区文件系统详细信息的命令
…省略部分输出…
Default mount options: user_xattr acl
…省略部分输出…
```

其中，dumpe2fs 命令的 -h 选项表示仅显示超级块中的信息，而不显示磁盘块组的详细信息；
使用 mount 命令可以查看到系统中已经挂载的分区，而使用 dumpe2fs 命令可以查看到这个分区文件系统的详细信息。大家可以看到，我们的 ACL 权限是 /dev/sda3 分区的默认挂载选项，所以不需要手工挂载。
如果 Linux 系统如果没有默认挂载，可以执行如下命令实现手动挂载：

```bash
[root@localhost ~]# mount -o remount,acl /
#重新挂载根分区，并加入ACL权限
使用 mount 命令重新挂载，并加入 ACL 权限。但使用此命令只是临时生效，要想永久生效，需要修改 /etc/fstab 文件，修改方法如下：
[root@localhost ~]#vi /etc/fstab
UUID=c2ca6f57-b15c-43ea-bca0-f239083d8bd2 /ext4 defaults,acl 1 1
#加入ACL权限
[root@localhost ~]# mount -o remount /
#重新挂载文件系统或重启系统，使修改生效
```

在你需要开启 ACL 权限的分区行上（也就是说 ACL 权限针对的是分区），手工在 defaults 后面加入 "，acl" 即可永久在此分区中开启 ACL 权限。

## setfacl 和 getfacl

设定 ACl 权限，常用命令有 2 个，分别是setfacl和getfacl命令，前者用于给指定文件或目录设定 ACL 权限，后者用于查看是否配置成功。
getfacl 命令用于查看文件或目录当前设定的 ACL 权限信息。该命令的基本格式为：

```bash
[root@localhost ~]# getfacl 文件名
getfacl 命令的使用非常简单，且常和 setfacl 命令一起搭配使用。

setfacl 命令可直接设定用户或群组对指定文件的访问权限。此命令的基本格式为：
[root@localhost ~]# setfacl 选项 文件名
```

表 1 罗列出了该命令可以使用的所用选项及功能。

| 选项 | 功能 |
| --- | --- |
| -m 参数 | 设定 ACL 权限。如果是给予用户 ACL 权限，参数则使用 "u:用户名:权限" 的格式，例如`setfacl -m u:st:rx /project`表示设定 st 用户对 project 目录具有 rx 权限；如果是给予组 ACL 权限，参数则使用 "g:组名:权限" 格式，例如`setfacl -m g:tgroup:rx /project`表示设定群组 tgroup 对 project 目录具有 rx 权限。 |
| -x 参数 | 删除指定用户（参数使用 u:用户名）或群组（参数使用 g:群组名）的 ACL 权限，例如`setfacl -x u:st /project`表示删除 st 用户对 project 目录的 ACL 权限。 |
| -b | 删除所有的 ACL 权限，例如`setfacl -b /project`表示删除有关 project 目录的所有 ACL 权限。 |
| -d | 设定默认 ACL 权限，命令格式为 "setfacl -m d:u:用户名:权限 文件名"（如果是群组，则使用 d:g:群组名:权限），只对目录生效，指目录中新建立的文件拥有此默认权限，例如`setfacl -m d:u:st:rx /project`表示 st 用户对 project 目录中新建立的文件拥有 rx 权限。 |
| -R | 递归设定 ACL 权限，指设定的 ACL 权限会对目录下的所有子文件生效，命令格式为 "setfacl -m u:用户名:权限 -R 文件名"（群组使用 g:群组名:权限），例如`setfacl -m u:st:rx -R /project`表示 st 用户对已存在于 project 目录中的子文件和子目录拥有 rx 权限。 |
| -k | 删除默认 ACL 权限。 |

### setfacl -m：给用户或群组添加 ACL 权限

回归上一节案例，解决方案如下：

- 老师使用 root 用户，并作为 /project 的所有者，对 project 目录拥有 rwx 权限；
- 新建 tgroup 群组，并作为 project 目录的所属组，包含本班所有的班级学员（假定只有 zhangsan 和 lisi），拥有对 project 的 rwx 权限；
- 将其他用户访问 project 目录的权限设定为 0（也就是 ---）。
- 对于试听学员 st 来说，我们对其设定 ACL 权限，令该用户对 project 拥有 rx 权限。

具体的设置命令如下：

```bash
[root@localhost ~]# useradd zhangsan
[root@localhost ~]# useradd lisi
[root@localhost ~]# useradd st
[root@localhost ~]# groupadd tgroup <-- 添加需要试验的用户和用户组，省略设定密码的过程
[root@localhost ~]# mkdir /project <-- 建立需要分配权限的目录
[root@localhost ~]# chown root:tgroup /project <-- 改变/project目录的所有者和所属组
[root@localhost ~]# chmod 770 /project  <-- 指定/project目录的权限
[root@localhost ~]# ll -d /project
drwxrwx---. 2 root tgroup 4096 Apr 16 12:55 /project
#这时st学员来试听了，如何给她分配权限
[root@localhost ~]# setfacl -m u:st:rx /project
#给用户st赋予r-x权限，使用"u:用户名：权限" 格式
[root@localhost /]# cd /
[root@localhost /]# ll -d /project
drwxrwx---+ 2 root tgroup 4096 Apr 16 12:55 /project
#如果查询时会发现，在权限位后面多了一个"+"，表示此目录拥有ACL权限
[root@localhost /]# getfacl project
#查看/prpject目录的ACL权限
#file:project <--文件名
#owner:root <--文件的所有者
#group:tgroup <--文件的所属组
user::rwx <--用户名栏是空的，说明是所有者的权限
user:st:r-x <--用户st的权限
group::rwx <--组名栏是空的，说明是所属组的权限
mask::rwx <--mask权限
other::--- <--其他人的权限
```

可以看到，通过设定 ACL 权限，我们可以单独给 st 用户分配 r-x 权限，而无需给 st 用户设定任何身份。
同样的道理，也可以给用户组设定 ACL 权限，例如：

```bash
[root@localhost /]# groupadd tgroup2
#添加新群组
[root@localhost /]# setfacl -m g:tgroup2:rwx project
#为组tgroup2纷配ACL权限
[root@localhost /]# ll -d project
drwxrwx---+ 2 root tgroup 4096 1月19 04:21 project
#属组并没有更改
[root@localhost /]# getfacl project
#file: project
#owner: root
#group: tgroup
user::rwx
user:st:r-x
group::rwx
group:tgroup2:rwx <-用户组tgroup2拥有了rwx权限
mask::rwx
other::---
```


### setfacl -d：设定默认 ACL 权限

既然已经对 project 目录设定了 ACL 权限，那么，如果在这个目录中新建一些子文件和子目录，这些文件是否会继承父目录的 ACL 权限呢？执行以下命令进行验证：

```bash
[root@localhost /]# cd project
[root@localhost project]# touch abc
[root@localhost project]# mkdir d1
#在/project目录中新建了abc文件和d1目录
[root@localhost project]#ll
总用量4
-rw-r--r-- 1 root root 01月19 05:20 abc
drwxr-xr-x 2 root root 4096 1月19 05:20 d1
```

可以看到，这两个新建立的文件权限位后面并没有 "+"，表示它们没有继承 ACL 权限。这说明，后建立的子文件或子目录，并不会继承父目录的 ACL 权限。
当然，我们可以手工给这两个文件分配 ACL 权限，但是如果在目录中再新建文件，都要手工指定，则显得过于麻烦。这时就需要用到默认 ACL 权限。
默认 ACL 权限的作用是，如果给父目录设定了默认 ACL 权限，那么父目录中所有新建的子文件都会继承父目录的 ACL 权限。需要注意的是，默认 ACL 权限只对目录生效。
例如，给 project 文件设定 st 用户访问 rx 的默认 ACL 权限，可执行如下指令：

```bash
[root@localhost /]# setfacl -m d:u:st:rx project
[root@localhost project]# getfacl project
# file: project
# owner: root
# group: tgroup
user:: rwx
user:st:r-x
group::rwx
group:tgroup2:rwx
mask::rwx
other::---
default:user::rwx <--多出了default字段
default:user:st:r-x
default:group::rwx
default:mask::rwx
default:other::---
[root@localhost /]# cd project
[root@localhost project]# touch bcd
[root@localhost project]# mkdir d2
#新建子文件和子目录
[root@localhost project]# ll 总用量8
-rw-r--r-- 1 root root 01月19 05:20 abc
-rw-rw----+ 1 root root 01月19 05:33 bcd
drwxr-xr-x 2 root root 4096 1月19 05:20 d1
drwxrwx---+ 2 root root 4096 1月19 05:33 d2
#新建的bcd和d2已经继承了父目录的ACL权限
```

大家发现了吗？原先的 abc 和 d1 还是没有 ACL 权限，因为默认 ACL 权限是针对新建立的文件生效的。
对目录设定的默认 ACL 权限，可直接使用setfacl -k 命令删除。例如：

```bash
[root@localhost /]# setfacl -k project
```

通过此命令，即可删除 project 目录的默认 ACL 权限，读者可自行通过 getfacl 命令查看。

### setfacl -R：设定递归 ACL 权限

递归 ACL 权限指的是父目录在设定 ACL 权限时，所有的子文件和子目录也会拥有相同的 ACL 权限。
例如，给 project 目录设定 st 用户访问权限为 rx 的递归 ACL 权限，执行命令如下：

```bash
[root@localhost project]# setfacl -m u:st:rx -R project
[root@localhost project]# ll
总用量 8
-rw-r-xr--+ 1 root root 01月19 05:20 abc
-rw-rwx--+ 1 root root 01月19 05:33 bcd
drwxr-xr-x+ 2 root root 4096 1月19 05:20 d1
drwxrwx---+ 2 root root 4096 1月19 05:33 d2
#abc和d1也拥有了ACL权限
```

注意，默认 ACL 权限指的是针对父目录中后续建立的文件和目录会继承父目录的 ACL 权限；递归 ACL 权限指的是针对父目录中已经存在的所有子文件和子目录会继承父目录的 ACL 权限。

### setfacl -x：删除指定的 ACL 权限

使用`setfacl -x`命令，可以删除指定的 ACL 权限，例如，删除前面建立的 st 用户对 project 目录的 ACL 权限，执行命令如下：

```bash
[root@localhost /]# setfacl -x u:st project
#删除指定用户和用户组的ACL权限
[root@localhost /]# getfacl project
# file:project
# owner: root
# group: tgroup
user::rwx
group::rwx
group:tgroup2:rwx
mask::rwx
other::---
#st用户的权限已被删除
```


### setfacl -b：删除指定文件的所有 ACL 权限
此命令可删除所有与指定文件或目录相关的 ACL 权限。例如，现在我们删除一切与 project 目录相关的 ACL 权限，执行命令如下：

```bash
[root@localhost /]# setfacl -b project
#会删除文件的所有ACL权限
[root@localhost /]# getfacl project
#file: project
#owner: root
# group: tgroup
user::rwx
group::rwx
other::---
#所有ACL权限已被删除

```

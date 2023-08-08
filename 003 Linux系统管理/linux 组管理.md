# linux 组管理

## 组账号管理

本机的群组账号数据被储存在 /etc/group 文件中，权限也必须为0644，与 /etc/passwd 一样，这也是一个文本文件。

```
root:x:0:
bin:x:1:
daemon:x:2:
```

这与/etc/passwd文件的格式类似

```
GROUPNAME:PASSWORD:GID:MEMBERS 

- GROUPNAME:组名

- PASSWORD:组密码，这里也和passwd文件一样是个x

- GID：群组识别号

- MEMBERS：组成员
```

‍

## groupadd

```
groupadd(选项)(参数)
-g：指定新建工作组的id；
-r：创建系统工作组，系统工作组的组ID小于500；
-K：覆盖配置文件“/etc/login.defs”；
-o：允许添加组ID号不唯一的工作组。

#组相关文件
/etc/group       # 组账户信息
/etc/gshadow     # 安全组账户信息
/etc/login.defs  # Shadow 密码套件配置
```

## **groupmod** 

**groupmod命令** 更改群组识别码或名称。需要更改群组的识别码或名称时，可用groupmod指令来完成这项工作。

```
groupmod(选项)(参数)
-g<群组识别码>：设置欲使用的群组识别码；
-o：重复使用群组识别码；
-n<新群组名称>：设置欲使用的群组名称。
```

## **groupdel** 

**groupdel命令** 用于删除指定的工作组，本命令要修改的系统文件包括/ect/group和/ect/gshadow。若该群组中仍包括某些用户，则必须先删除这些用户后，方能删除群组。

```
groupdel 组名
```

**您不能移除现有用户的主组。在移除此组之前，必须先移除此用户。**

## groupmems

​`groupmems`​ 命令允许用户管理他/她自己的组成员列表，而不需要超级用户权限。`groupmems`​ 实用程序适用于将其用户配置为以他们自己的名义主组（即来宾/来宾）的系统。

只有作为管理员的超级用户可以使用 `groupmems`​ 来更改其他组的成员资格。

```nginx
groupmems -a user_name | -d 用户名 | [-g 用户组名] | -l | -p
-a, --add user_name # 将用户添加到组成员列表。如果 /etc/gshadow 文件存在，并且该组在 /etc/gshadow 文件中没有条目，则将创建一个新条目。

-d, --delete user_name
# 从组成员列表中删除用户。
# 如果 /etc/gshadow 文件存在，用户将从组的成员和管理员列表中删除。
# 如果 /etc/gshadow 文件存在，并且该组在 /etc/gshadow 文件中没有条目，则将创建一个新条目。

-g, --group group_name # 超级用户可以指定要修改的组成员列表。
-l, --list             # 列出组成员列表。
-p, --purge            # 从组成员列表中清除所有用户。
# 如果 /etc/gshadow 文件存在，并且该组在 /etc/gshadow 文件中没有条目，则将创建一个新条目。

```

### 配置

​`/etc/login.defs`​ 中的以下配置变量会更改此工具的行为：

```shell
MAX_MEMBERS_PER_GROUP (number)
```

<pre class="language-shell"><div data-code="MAX_MEMBERS_PER_GROUP (number)
" class="copied"></div></pre>

每个组条目的最大成员数。 当达到最大值时，在 `/etc/group`​ 中启动一个新的组条目（行）（具有相同的名称、相同的密码和相同的 GID）。

默认值为 0，表示组中的成员数量没有限制。

此功能（拆分组）允许限制组文件中的行长度。 这有助于确保 NIS 组的行不超过 1024 个字符。

如果你需要强制执行这样的限制，你可以使用 25。

注意：并非所有工具都支持拆分组（即使在 Shadow 工具包中）。 除非你真的需要它，否则你不应该使用这个变量。

### 例子

groupmems 可执行文件应该在模式 2770 中作为用户 root 和组组。 系统管理员可以将用户添加到组中，以允许或禁止他们使用 groupmems 实用程序来管理他们自己的组成员列表。

```shell
groupadd -r groups
chmod 2770 groupmems

chown root.groups groupmems
groupmems -g groups -a gk4
```

<pre class="language-shell"><div data-code="groupadd -r groups
chmod 2770 groupmems

chown root.groups groupmems
groupmems -g groups -a gk4
" class="copied"></div></pre>

让我们创建一个新用户和一个新组并验证结果：

```shell
useradd student
passwd student
groupadd staff
```

<pre class="language-shell"><div data-code="useradd student
passwd student
groupadd staff
" class="copied"></div></pre>

使用户 student 成为组人员的成员：

```shell
groupmems -g staff -a student
groupmems -g staff -l 
```

<pre class="language-shell"><div data-code="groupmems -g staff -a student
groupmems -g staff -l 
" class="copied"></div></pre>

将用户添加到组：

```shell
groupmems -a mike -g SUPPORT
groupmems --add mike -g SUPPORT 
```

<pre class="language-shell"><div data-code="groupmems -a mike -g SUPPORT
groupmems --add mike -g SUPPORT 
" class="copied"></div></pre>

从组中删除/移除用户：

```shell
groupmems -d mike SUPPORT -g SUPPORT
groupmems --delete mike SUPPORT -g SUPPORT
```

<pre class="language-shell"><div data-code="groupmems -d mike SUPPORT -g SUPPORT
groupmems --delete mike SUPPORT -g SUPPORT
" class="copied"></div></pre>

更改组名称：

```shell
groupmems -g SUPPORT
```

<pre class="language-shell"><div data-code="groupmems -g SUPPORT
" class="copied"></div></pre>

从组中删除用户：

```shell
groupmems -p -g SUPPORT
groupmems --purge -g SUPPORT
```

<pre class="language-shell"><div data-code="groupmems -p -g SUPPORT
groupmems --purge -g SUPPORT
" class="copied"></div></pre>

要列出组的成员：

```shell
groupmems -l -g SUPPORT
groupmems --list -g SUPPORT
```

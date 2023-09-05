# linux shadow文件

说到用户管理，就不得不提到shadow这个文件，shadow有三个功能：

- 隐藏密码
- 扩充密码的功能
- 提供账号管理工具

**隐藏密码：** 因为/etc/passwd和/etc/group文件的权限必须是0644，这意味着所有的用户都能读取到内容，所以为了安全起见，我们通过shaodw把用户和组的密码分别隐藏在/etc/shadow,/etc/gshadow文件中，且这两个文件只有管理员，也就是root能调用

**提供账号管理工具** ：我们之前所介绍的用户和组管理的相关命令，都是shadow所提供的工具

**扩充密码功能**： 这个扩充密码功能就是除了密码之外的额外功能，如，密码的有效期限，设置群组管理员（组长）等，这些都是记录在/etc/shadow,/etc/gshadow文件中

## **/etc/shadow**

存储用户密码及密码额外功能的文件

```
文件内容：
root:$6$T52Xvk7zu84.tDXp$nfXcm6LTfUx.ZviEo7Eq1bPjDO...::0:99999:7:::
bin:*:18027:0:99999:7:::
```

/etc/shadow文件的格式与/etc/passwd类似，也是每一行代表一个账号的数据，使用：进行分隔.

**内容详解**

```
USERNAME:PASSWORD:LAST_CHANGED:MIN_DAYS:MAX_DAYS:WARNNING:EXPIRES:INVALID:RESERVED

USERNAME：用户账号名称。
PASSWORD：加密后的密码。
LAST_CHANGED：密码最后一次修改的日期。
MIN_DAYS：密码修改的最小间隔天数。
MAX_DAYS：密码修改的最大天数。
WARNNING：密码过期前警告的天数。
EXPIRES：密码过期的日期
INVALID:	账号失效日期
RESERVED：保留位，未定义功能
```

这里面我们所提到的日期都是从1970年1月1日起经过的天数，所以我们看到的不是日期的格式，而是一组数字，我们接下来看下另一个文件

## **/etc/gshadow**

存储组密码及密码额外功能的文件

```
文件内容：
root:::
bin:::
daemon:::
```

**内容详解**

```
GROUPNAME:PASSWORD:ADMINISTRATORS:MEMBERS   

GROUPNAME:	 组名
PASSWORD：	 组密码
ADMINISTRATORS： 组长
MEMBERS：	 组成员
```

‍

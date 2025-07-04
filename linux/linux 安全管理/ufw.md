

**UFW (简单的防火墙)**  是广泛使用的 **iptables 防火墙** 的前端应用，这是非常适合于基于主机的防火墙。UFW 即提供了一套管理**网络过滤器**的框架，又提供了控制防火墙的命令行界面接口。它给那些不熟悉防火墙概念的 Linux 新用户提供了友好、易使用的用户界面。

同时，另一方面，它也提供了命令行界面，为系统管理员准备了一套复杂的命令，用来设置复杂的防火墙规则。**UFW** 对像 **Debian、Ubuntu** 和 **Linux Mint** 这些发布版本来说也是上上之选。


## UFW 基本用法

首先，用如下命令来检查下系统上是否已经安装了 **UFW** 。

```notranslate
$ sudo dpkg --get-selections | grep ufw
```

如还没有安装，可以使用 **apt** 命令来安装，如下所示：

```notranslate
$ sudo apt-get install ufw
```

在使用前，你应该检查下 **UFW** 是否已经在运行。用下面的命令来检查。

```notranslate
$ sudo ufw status
```

如果你发现状态是： **inactive** , 意思是没有被激活或不起作用。

### 启用/禁用 UFW

要启用它，你只需在终端下键入如下命令：

```notranslate
$ sudo ufw enable
```

在系统启动时启用和激活防火墙

要禁用，只需输入：

```notranslate
$ sudo ufw disable
```

### 列出当前UFW规则

在防火墙被激活后，你可以向里面添加你自己的规则。如果你想看看默认的规则，可以输入。

```notranslate
$ sudo ufw status verbose
```

输出样例：

```notranslate
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing)
New profiles: skip
$
```

### 添加UFW规则

如你所见，默认是不允许所有外部访问连接的。如果你想远程连接你的机器，就得开放相应的端口。例如，你想用 ssh 来连接，下面是添加的命令。

### 允许访问

```notranslate
$ sudo ufw allow ssh

[sudo] password for pungki :
Rule added
Rule added (v6)
$
```

再一次检查状态，会看到如下的一些输出。

```notranslate
$ sudo ufw status

To 		Action 			From
-- 		----------- 		------
22 		ALLOW 			Anywhere
22 		ALLOW 			Anywhere (v6)
```

如果你有很多条规则，想快速的在每条规则上加个序号数字的话，请使用 numbered 参数。

```notranslate
$ sudo ufw status numbered

To 		Action 			From
------ 		----------- 		------
[1] 22 		ALLOW 			Anywhere
[2] 22 		ALLOW 			Anywhere (v6)
```

第一条规则的意思是**所有**通过**22端口**访问机器的 **tcp** 或 **udp** 数据包都是允许的。如果你希望仅允许 **tcp** 数据包访问应该怎么办？可以在**服务端口**后加个 **tcp** 参数。下面的示例及相应的输出。

```notranslate
$ sudo ufw allow ssh/tcp

To 		Action 			From
------ 		----------- 		------
22/tcp 		ALLOW 			Anywhere
22/tcp 		ALLOW 			Anywhere (v6)
```

### 拒绝访问

添加拒绝规则也是同样的招数。我们假设你想拒绝 ftp 访问, 你只需输入

```notranslate
$ sudo ufw deny ftp

To 		Action 			From
------ 		----------- 		------
21/tcp 		DENY 			Anywhere
21/tcp 		DENY 			Anywhere (v6)
```

### 添加特定端口

有时候，我们会自定义一个端口而不是使用标准提供的。让我们试着把机器上 **ssh** 的 **22** 端口换成 **2290** 端口，然后允许从 **2290** 端口访问，我们像这样添加：

```notranslate
$ sudo ufw allow 2290/ssh (译者注：些处演示例子有问题)

To 		Action 			From
-- 		----------- 		------
2290 		ALLOW 			Anywhere
2290 		ALLOW 			Anywhere (v6)
```

你也可以把**端口范围**添加进规则。如果我们想打开从 **2290到2300** 的端口以供 **tcp** 协议使用，命令如下示：

```notranslate
$ sudo ufw allow 2290:2300/tcp

To 			Action 			From
------ 			----------- 		------
2290:2300/tcp 		ALLOW 			Anywhere
2290:2300/tcp 		ALLOW			Anywhere (v6)
```

同样你想使用 **udp** 的话，如下操作。

```notranslate
$ sudo ufw allow 2290:2300/udp

To 			Action 			From
------ 			----------- 		------
2290:2300/udp 		ALLOW 			Anywhere
2290:2300/udp 		ALLOW			Anywhere (v6)
```

请注意你得明确的指定是 ‘**tcp**’ 或 ‘**udp**’，否则会出现跟下面类似的错误信息。

```notranslate
ERROR: Must specify ‘tcp’ or ‘udp’ with multiple ports
```

### 添加特定 IP

前面我们添加的规则都是基于 **服务程序** 或 **端口** 的，UFW 也可以添加基于 **IP 地址**的规则。下面是命令样例。

```notranslate
$ sudo ufw allow from 192.168.0.104
```

你也可以使用子网掩码来扩宽范围。

```notranslate
$ sudo ufw allow form 192.168.0.0/24

To 		Action 			From
-- 		----------- 		------
Anywhere	ALLOW 			192.168.0.104
Anywhere	ALLOW 			192.168.0.0/24
```

如你所见， from 参数仅仅限制连接的来源，而目的（用 **To** 列表示）是**所有地方**。让我们看看允许访问 \*\*22端口(ssh)\*\*的例子。

```notranslate
$ sudo ufw allow to any port 22
```

上面的命令会允许从任何地方以及任何协议都可以访问**22端口**。

### 组合参数

对于更具体的规则，你也可以把 **IP 地址**、**协议**和**端口**这些组合在一起用。我们想创建一条规则，限制仅仅来自于 192.168.0.104 的 IP ，而且只能使用 **tcp 协议**和通过 **22端口** 来访问本地资源。我们可以用如下所示的命令。

```notranslate
$ sudo ufw allow from 192.168.0.104 proto tcp to any port 22
```

创建拒绝规则的命令和允许的规则类似，仅需要把 **allow** 参数换成 **deny** 参数就可以。

### 删除规则

某些时候需要删除现有的规则。再一次使用 **UFW** 删除规则是很简单的。在上面的示例中，已经创建了如下的规则，现在你想删除它们。

```notranslate
To 		Action 			From
-- 		----------- 		------
22/tcp		ALLOW 			192.168.0.104
21/tcp		ALLOW 			Anywhere
21/tcp 		ALLOW 			Anywhere (v6)
```

删除规则有两个方法。

**方法1**

下面的命令将会 **删除** 与 **ftp** 相关的规则。所以像 **21/tcp** 这条 **ftp** 默认访问端口的规则将会被删除掉。

```notranslate
$ sudo ufw delete allow ftp
```

**方法2**

但当你使用如下命令来删除上面例子中的规则时，

```notranslate
$ sudo ufw delete allow ssh

或者 

$ sudo ufw delete allow 22/tcp
```

会出现如下所示的一些错误

```notranslate
Could not delete non-existent rule
Could not delete non-existent rule (v6)
```

我们还有一招。上面已经提到过，可以序列数字来代替你想删除的规则。让我们试试。

```notranslate
$ sudo ufw status numbered

To 		Action 			From
-- 		----------- 		------
[1] 22/tcp		ALLOW 			192.168.0.104
[2] 21/tcp		ALLOW 			Anywhere
[3] 21/tcp 		ALLOW 			Anywhere (v6)
```

然后我们删除正在使用的第一条规则。按 “ **y** ” 就会永久的删除这条规则。

```notranslate
$ sudo ufw delete 1

Deleting :
Allow from 192.168.0.104 to any port 22 proto tcp
Proceed with operation (y|n)? y
```

从这些用法中你就可以发现它们的不同。 **方法2** 在删除前需要 **用户确认** ，而 **方法1** 不需要。

### 重置所有规则###

某些情况下，你也许需要 **删除/重置** 所有的规则。可以输入。

```notranslate
$ sudo ufw reset

Resetting all rules to installed defaults. Proceed with operation (y|n)? y
```

如果你输入“ **y** ”， **UFW** 在重置你的 ufw 前会备份所有已经存在规则，然后重置。重置操作也会使你的防火墙处于不可用状态，如果你想使用得再一次启用它。

### 高级功能

正如我上面所说，UFW防火墙能够做到iptables可以做到的一切。这是通过一些规则文件来完成的，他们只不过是 **iptables-restore** 所对应的文本文件而已。是否可以通过 ufw 命令微调 UFW 的与/或逻辑来增加 iptables 命令其实就是编辑几个文本文件的事。

- /etc/default/ufw: 默认策略的主配置文件，支持 IPv6 和 内核模块。
- /etc/ufw/before[6].rules: 通过 ufw 命令添加进规则之前里面存在的规则会首先计算。
- /etc/ufw/after[6].rules: 通过 ufw 命令添加进规则之后里面存在的规则会进行计算。
- /etc/ufw/sysctl.conf: 内核网络可调参数。
- /etc/ufw/ufw.conf: 设置系统启动时 UFW 是否可用，和设置日志级别。

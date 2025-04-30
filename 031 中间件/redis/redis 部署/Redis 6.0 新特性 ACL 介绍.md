# Redis 6.0 新特性 ACL 介绍 

‍

在 Redis 6.0 中引入了 ACL（Access Control List) 的支持，在此前的版本中 Redis 中是没有用户的概念的，其实没有办法很好的控制权限，redis 6.0 开始支持用户，可以给每个用户分配不同的权限来控制权限。

下面我们就来介绍一下 Redis 6.0 中的 ACL 吧，下面的示例可以通过 docker 运行了一个 redis-6.0 的容器来实验的

## AUTH

在 redis 的之前版本中是有一个 “AUTH” 命令，但是之前的版本只是支持一个 Password，是没有用户的概念的，这就导致所有的客户端相当于是使用同一个账户来操作 redis 的，redis 6.0 扩展了 AUTH 的语法:

```xml
AUTH <username> <password>
```

同时也兼容了旧版本的 `AUTH`​

```xml
AUTH <password>
```

使用这种方式时，也就是只提供密码，相当于使用了一个默认的用户 “default”，通过这样的方式，实现了对低版本的兼容

## ACL

### ACL 使用场景

在使用 ACL 之前，您可能会问自己，这个功能主要用来干嘛，它能帮我实现什么，ACL 可以帮助你实现下面两个主要目标：

* 通过限制对命令和密钥的访问来提高安全性，以使不受信任的客户端无法访问，而受信任的客户端仅具有对数据库的最低访问级别才能执行所需的工作。例如，某些客户端可能仅能够执行只读命令，
* 提高操作安全性，以防止由于软件错误或人为错误而导致进程或人员访问 Redis，从而损坏数据或配置。例如，没有必要让工作人员从 Redis 调用 `FLUSHALL`​ 命令。

ACL 的另一种典型用法与托管Redis实例有关。Redis通常由管理内部Redis基础结构的内部公司团队为其所拥有的其他内部客户提供的一项托管服务，或者由云提供商在软件即服务设置中提供。
在这两种设置中，我们都希望确保为客户排除配置命令。过去，通过命令重命名来完成此操作的方法是一种技巧，它使我们可以长时间不用 ACL 生存，但使用体验并不理想。

### 通过 ACL 命令来配置 ACL 规则

ACL是使用 DSL（domain specific language）定义的，该 DSL 描述了给定用户能够执行的操作。此类规则始终从左到右从第一个到最后一个实施，因为有时规则的顺序对于理解用户的实际能力很重要。

默认情况下，有一个用户定义，称为default。

我们可以使用 `ACL LIST`​ 命令来检查当前启用的 ACL 规则

```bash
127.0.0.1:6379> ACL LIST 1) "user default on nopass ~* +@all"
```

参数说明：

|参 数|说明|
| ---------| ---------------------------------------|
|user|用户|
|default|表示默认用户名，或则自己定义的用户名|
|on|表示是否启用该用户，默认为off（禁用）|

## ... | 表示用户密码，nopass表示不需要密码

~\* | 表示可以访问的Key（正则匹配）
+@ | 表示用户的权限，“+”表示授权权限，有权限操作或访问，“-”表示还是没有权限； @为权限分类，可以通过 `ACL CAT`​ 查询支持的分类。+@all 表示所有权限，nocommands 表示不给与任何命令的操作权限

权限对key的类型和命令的类型进行了分类，如有对数据类型进行分类：string、hash、list、set、sortedset，和对命令类型进行分类：connection、admin、dangerous。
执行 `ACL CAT`​ 可以查看支持的权限分类列表

```bash
127.0.0.1:6379> ACL CAT
 1) "keyspace"
 2) "read"
 3) "write"
 4) "set"
 5) "sortedset"
 6) "list"
 7) "hash"
 8) "string"
 9) "bitmap"
10) "hyperloglog"
11) "geo"
12) "stream"
13) "pubsub"
14) "admin"
15) "fast"
16) "slow"
17) "blocking"
18) "dangerous"
19) "connection"
20) "transaction"
21) "scripting"

-- 返回指定类别中的命令
> ACL CAT hash
 1) "hsetnx"
 2) "hset"
 3) "hlen"
 4) "hmget"
 5) "hincrbyfloat"
 6) "hgetall"
 7) "hvals"
 8) "hscan"
 9) "hkeys"
10) "hstrlen"
11) "hget"
12) "hdel"
13) "hexists"
14) "hincrby"
15) "hmset" 

```

## 配置用户权限

我们可以通过两种主要方式创建和修改用户：

* 使用 ACL 命令及其 ACL SETUSER 子命令。
* 修改服务器配置（可以在其中定义用户）并重新启动服务器，或者如果我们使用的是外部 `ACL`​ 文件，则只需发出 `ACL LOAD`​ 即可。

```bash
+<command>：将命令添加到用户可以调用的命令列表中，如+@hash
-<command>: 将命令从用户可以调用的命令列表中移除
+@<category>: 添加一类命令，如：@admin, @set, @hash ... 可以`ACL CAT` 查看具体的操作指令。特殊类别@all表示所有命令，包括当前在服务器中存在的命令，以及将来将通过模块加载的命令
-@<category>: 类似+@<category>，从客户端可以调用的命令列表中删除命令
+<command>|subcommand: 允许否则禁用特定子命令。注意，这种形式不允许像-DEBUG | SEGFAULT那样，而只能以“ +”开头
allcommands：+@all的别名，允许所有命令操作执行。注意，这意味着可以执行将来通过模块系统加载的所有命令。
nocommands：-@all的别名，不允许所有命令操作执行。

```

### 使用 `ACL SETUSER`​ 命令

首先，让我们尝试最简单的 `ACL SETUSER`​ 命令调用：

```bash
> ACL SETUSER alice OK
```

在上面的示例中，我根本没有指定任何规则。如果用户不存在，这将使用just created的默认属性来创建用户。如果用户已经存在，则上面的命令将不执行任何操作。

让我们检查一下默认的用户状态：

```bash
> ACL LIST
1) "user alice off -@all"
2) "user default on nopass ~* +@all"
```

刚创建的用户“ alice”为：

处于关闭状态，即已禁用。 `AUTH`​ 将不起作用。
无法访问任何命令。请注意，默认情况下，该用户是默认创建的，无法访问任何命令，因此-@all可以忽略上面输出中的，但是 `ACL LIST`​ 尝试是显式的，而不是隐式的。
最后，没有用户可以访问的密钥模式。
用户也没有设置密码。

这样的用户是完全无用的。让我们尝试定义用户，使其处于活动状态，具有密码，并且仅可以使用GET命令访问以字符串“ cached：”开头的键名称。

```bash
> ACL SETUSER alice on >p1pp0 ~cached:* +get
OK
```

现在，用户可以执行某些操作，但是会拒绝执行其他没有权限的操作：

```bash
> AUTH alice p1pp0
OK
> GET foo
(error) NOPERM this user has no permissions to access one of the keys used as arguments
> GET cached:1234
(nil)
> SET cached:1234 zap
(error) NOPERM this user has no permissions to run the 'set' command or its subcommand

```

事情按预期进行。为了检查用户alice的配置（请记住用户名区分大小写），可以使用 `ACL LIST`​的替代方法 `ACL GETUSER`​

```bash
> ACL GETUSER alice
1) "flags"
2) 1) "on"
3) "passwords"
4) 1) "2d9c75..."
5) "commands"
6) "-@all +get"
7) "keys"
8) 1) "cached:*"

```

如果我们使用RESP3，则输出的可读性可能更高，因此将其作为地图回复返回：

```bash
> ACL GETUSER alice
1# "flags" => 1~ "on"
2# "passwords" => 1) "2d9c75..."
3# "commands" => "-@all +get"
4# "keys" => 1) "cached:*"
```

> 多次调用ACL SETUSER会发生什么

了解多次调用 `ACL SETUSER`​ 会发生什么非常重要。重要的是要知道，每个`SETUSER`​调用都不会重置用户，而只会将ACL规则应用于现有用户。
仅在之前不知道的情况下才重置用户：
在这种情况下，将使用归零的ACL创建一个全新的用户，即该用户无法执行任何操作，被禁用，没有密码等等：为了安全起见，最佳默认值。

但是，以后的调用只会逐步修改用户，因此例如以下调用顺序将导致 `myuser`​ 能够同时调用 `GET`​ 和 `SET`​：

```bash
> ACL SETUSER myuser +set
OK
> ACL SETUSER myuser +get
OK

> ACL LIST
1) "user default on nopass ~* +@all"
2) "user myuser off -@all +set +get"
```

### 使用外部 `ACL`​ 文件

有两种方法可以将用户存储在Redis配置中，一种是 `redis.conf`​ 中配置，一种是使用一个独立的外部 acl 文件，这两种方式不兼容，只能选择一种方式
通常外部文件的方式更灵活，推荐使用。

内部redis.conf和外部ACL文件中使用的格式是完全相同的，因此从一个切换到另一个很简单

配置内容如下：

```xml
user <username> ... acl rules ...
```

来看一个示例：

```scss
user worker +@list +@connection ~jobs:* on >ffa9203c493aa99
```

当您要使用外部ACL文件时，需要指定名为的配置指令 `aclfile`​，如下所示：

```bash
aclfile /etc/redis/users.acl
```

当仅在redis.conf 文件内部直接指定几个用户时，可以使用CONFIG REWRITE以便通过重写将新的用户配置存储在文件中。

但是，外部ACL文件功能更强大。您可以执行以下操作：

* 使用 `ACL LOAD`​ 重新加载外部 ACL 文件，通常在你手动修改了这个文件，希望 redis 重新加载的时候使用，需要注意的是要确保 acl 文件内容的正确性
* 使用 `ACL SAVE`​ 将当前 ACL 配置保存到一个外部文件

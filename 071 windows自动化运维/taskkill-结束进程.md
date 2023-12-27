# taskkill-结束进程

> 适用范围：Windows Server 2022、Windows Server 2019、Windows Server 2016、Windows Server 2012 R2、Windows Server 2012

结束一个或多个任务或进程。 可以通过进程 ID 或图像名称结束进程。 可以使用 [tasklist](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/tasklist) 命令来确定要结束的进程的进程 ID (PID)。

 备注

该命令替换 kill 工具。

## 语法

```
taskkill [/s <computer> [/u [<domain>\]<username> [/p [<password>]]]] {[/fi <filter>] [...] [/pid <processID> | /im <imagename>]} [/f] [/t]
```

### 参数

|参数|说明|
| --------| --------------------------------------------------------------------------------------------------------------------------------------------------|
|/s`<computer>`​|指定远程计算机的名称或 IP 地址（请勿使用反斜杠）。 默认为本地计算机。|
|/u`<domain>\<username>`​|使用`<username>`​或`<domain>\<username>`​指定的用户的帐户权限运行该命令。 仅当还指定了 /s时，才能指定 /u参数。 默认值是当前登录到发出该命令的计算机的用户的权限。|
|/p`<password>`​|指定 /u 参数中指定的用户帐户的密码。|
|/fi`<filter>`​|应用筛选器以选择一组任务。 可以使用多个筛选器或使用通配符 (`*`​) 指定所有任务或映像名称。 本文的“筛选器名称、运算符和值”部分列出了有效的筛选器。|
|/pid`<processID>`​|指定要终止的进程的进程 ID。|
|/im`<imagename>`​|指定要终止的进程的映像名称。 使用通配符 (`*`​) 指定所有映像名称。|
|/f|指定强制结束进程。 对于远程进程，将忽略此参数；所有远程进程都会被强制结束。|
|/t|结束指定的进程及其启动的任何子进程。|

#### 筛选器名称、运算符和值

|筛选器名称|有效运算符|有效值|
| -------------| ------------------------| -------------------------------------------------------------------------------------|
|状态|eq、ne|​`RUNNING \| NOT RESPONDING \| UNKNOWN`​|
|IMAGENAME|eq、ne|映像名称|
|PID|eq、ne、gt、lt、ge、le|PID 值|
|SESSION|eq、ne、gt、lt、ge、le|会话号|
|CPUtime|eq、ne、gt、lt、ge、le|采用 HH:MM:SS 格式的 CPU 时间，其中 MM 和 SS 介于 0 到 59 之间，HH 是任何无符号数字|
|MEMUSAGE|eq、ne、gt、lt、ge、le|内存使用量 (KB)|
|USERNAME|eq、ne|任何有效的用户名（`<user>`​或`<domain\user>`​）|
|服务|eq、ne|服务名称|
|WINDOWTITLE|eq、ne|Window title|
|MODULES|eq、ne|DLL name|

## 备注

* 指定远程系统时，不支持 WINDOWTITLE 和 STATUS 筛选器。
* 只有在应用筛选器时，`*/im`​ 选项才接受通配符 (`*`​)。
* 无论是否指定了 /f 选项，总是强制执行结束远程进程的操作。
* 向主机名筛选器提供计算机名称会导致关闭，从而停止所有进程。

## 示例

若要结束进程 ID 为 1230、1241 和 1253 的进程，请键入：

‍

```
taskkill /pid 1230 /pid 1241 /pid 1253
```

如果进程 Notepad.exe 是由系统启动的，要强行结束它，请键入：

```
taskkill /f /fi "USERNAME eq NT AUTHORITY\SYSTEM" /im notepad.exe
```

若要结束远程计算机 Srvmain 上映像名称以 note 开头的所有进程，同时使用用户帐户 Hiropln 的凭据，请键入：

```
taskkill /s srvmain /u maindom\hiropln /p p@ssW23 /fi "IMAGENAME eq note*" /im *
```

若要结束进程 ID 为 2134 的进程及其它启动的任何子进程，但前提是这些进程是由管理员帐户启动的，请键入：

```
taskkill /pid 2134 /t /fi "username eq administrator"
```

若要结束进程 ID 大于或等于 1000 的所有进程，无论其映像名称如何，请键入：

```
taskkill /f /fi "PID ge 1000" /im *
```

‍

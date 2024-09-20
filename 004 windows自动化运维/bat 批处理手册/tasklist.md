# tasklist

　　显示本地计算机或远程计算机上当前正在运行的进程列表。 Tasklist 替换 tlist 工具。

## 语法

```
tasklist [/s <computer> [/u [<domain>\]<username> [/p <password>]]] [{/m <module> | /svc | /v}] [/fo {table | list | csv}] [/nh] [/fi <filter> [/fi <filter> [ ... ]]]
```

### 参数

|参数|说明|
| -------| --------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|/s`<computer>`​|指定远程计算机的名称或 IP 地址（请勿使用反斜杠）。 默认为本地计算机。|
|/u`<domain>\<username>`​|使用`<username>`​或`<domain>\<username>`​指定的用户的帐户权限运行该命令。 仅当还指定了 /s时，才能指定 /u参数。 默认值是当前登录到发出该命令的计算机的用户的权限。|
|/p`<password>`​|指定 /u 参数中指定的用户帐户的密码。|
|/m`<module>`​|列出加载了与给定模式名称匹配的 DLL 模块的所有任务。 如果未指定模块名称，则此选项将显示每个任务加载的所有模块。|
|svc|列出每个进程的所有服务信息，而不截断。 当 /fo参数设置为 table时有效。|
|/v|在输出中显示详细的任务信息。 若要获得不截断的完整详细输出，请同时使用 /v和 /svc。|
|/fo`{table \| list \| csv}`​|指定要用于输出的格式。 有效值为 table、list 或 csv。 输出的默认格式为 table。|
|/nh|取消在输出中显示列标题。 当 /fo参数设置为 table或 csv时有效。|
|/fi`<filter>`​|指定要包含在查询中或从查询中排除的进程类型。 可以使用多个筛选器或使用通配符 (`\`​) 指定所有任务或映像名称。 本文的“筛选器名称、运算符和值”部分列出了有效的筛选器。|
|/?|在命令提示符下显示帮助。|

#### 筛选器名称、运算符和值

|筛选器名称|有效运算符|有效值|
| -------------| ------------------------| -------------------------------------------------------------------------------------|
|状态|eq、ne|​`RUNNING \| NOT RESPONDING \| UNKNOWN`​。 如果指定远程系统，则不支持此筛选器。|
|IMAGENAME|eq、ne|映像名称|
|PID|eq、ne、gt、lt、ge、le|PID 值|
|SESSION|eq、ne、gt、lt、ge、le|会话号|
|SESSIONNAME|eq、ne|会话名称|
|CPUtime|eq、ne、gt、lt、ge、le|采用 HH:MM:SS 格式的 CPU 时间，其中 MM 和 SS 介于 0 到 59 之间，HH 是任何无符号数字|
|MEMUSAGE|eq、ne、gt、lt、ge、le|内存使用量 (KB)|
|USERNAME|eq、ne|任何有效的用户名（`<user>`​或`<domain\user>`​）|
|服务|eq、ne|服务名称|
|WINDOWTITLE|eq、ne|窗口标题。 如果指定远程系统，则不支持此筛选器。|
|MODULES|eq、ne|DLL name|

## 示例

　　若要列出进程 ID 大于 1000 的所有任务，并将它们以 csv 格式显示，请键入：

　　‍

```
tasklist /v /fi "PID gt 1000" /fo csv
```

　　若要列出当前正在运行的系统进程，请键入：

```
tasklist /fi "USERNAME ne NT AUTHORITY\SYSTEM" /fi "STATUS eq running"
```

　　若要列出当前正在运行的所有进程的详细信息，请键入：

```
tasklist /v /fi "STATUS eq running"
```

　　若要列出远程计算机 srvmain（其 DLL 名称以 ntdll 开头）上进程的所有服务信息，请键入：

　　‍

```
tasklist /s srvmain /svc /fi "MODULES eq ntdll*"
```

　　若要使用当前登录用户帐户的凭据列出远程计算机 srvmain 上的进程，请键入：

```
tasklist /s srvmain
```

　　若要使用用户帐户 Hiropln 的凭据列出远程计算机 srvmain 上的进程，请键入：

```
tasklist /s srvmain /u maindom\hiropln /p p@ssW23
```

　　‍

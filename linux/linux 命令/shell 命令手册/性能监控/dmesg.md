

​`Linux`​ 内核是操作系统的核心，它控制对系统资源（例如： `CPU`​、`I/O`​设备、物理内存和文件系统）的访问。在引导过程中以及系统运行时，内核会将各种消息写入内核环形缓冲区。这些消息包括有关系统操作的各种信息。

内核环形缓冲区是物理内存的一部分，用于保存内核的日志消息。它具有固定的大小，这意味着一旦缓冲区已满，较旧的日志记录将被覆盖。

​`dmesg`​ 命令行实用程序用于在 `Linux`​ 和其他类似 `Unix`​ 的操作系统中打印和控制内核环形缓冲区。对于检查内核启动消息和调试与硬件相关的问题很有用。

在本教程中，我们将介绍 `dmesg`​ 命令的基础。

​`dmesg`​ 命令的语法如下：

```bash
dmesg [OPTIONS]
```

在不带任何选项的情况下调用时，`dmesg`​ 将所有消息从内核环形缓冲区写入标准输出：

```bash
$ dmesg
```

默认情况下，所有用户都可以运行 `dmesg`​ 命令。但是，在某些系统上，非 root 用户可能会限制对 `dmesg`​的访问。在这种情况下，调用 dmesg\`时您将收到如下错误消息：

```bash
dmesg: read kernel buffer failed: Operation not permitted
```

内核参数 `kernel.dmesg_restrict`​ 指定非特权用户是否可以使用 `dmesg`​ 查看来自内核日志缓冲区的消息。要删除限制，请将其设置为零：

```bash
$ sudo sysctl -w kernel.dmesg_restrict=0
```

通常，输出包含很多信息行，因此只能看到输出的最后一部分。要一次查看一页，请将输出通过管道传送到分页实用程序，例如 `less`​ 或 `more`​：

```bash
$ dmesg --color=always | less
```

其中的 `--color=always`​ 参数用于保留彩色输出。

如果要过滤缓冲区消息，可能使用 `grep`​ 。例如，要仅查看与 USB 相关的消息，请键入：

```bash
$ dmesg | grep -i usb
```

dmesg 从 `/proc/kmsg`​ 虚拟文件中读取内核生成的消息。该文件提供了到内核环形缓冲区的接口，并且只能由一个进程打开。如果系统上正在运行 `syslog`​ 进程，并且你尝试使用 `cat`​ 或 `less`​ 命令读取文件，则命令将挂起。

​`syslog`​ 守护程序将内核消息转储到 `/var/log/dmesg`​，因此你也可以使用该日志文件：

```bash
$ cat /var/log/dmesg
```

## 格式化 dmesg 输出

​`dmesg`​ 命令提供了许多选项，可帮助你格式化和过滤输出。

​`dmesg`​ 中最常用的选项之一是 `-H（--human）`​，它将输出更容易读的结果。

```bash
$ dmesg -H
```

要打印人类可读的时间戳，请使用 `-T（--ctime`​ 选项：

```bash
$ dmesg -T

[Mon Oct 14 14:38:04 2019] IPv6: ADDRCONF(NETDEV_CHANGE): wlp1s0: link becomes ready
```

时间戳格式也可以使用 `--time-format <format>`​ 选项设置，可以是 `ctime`​，`reltime`​，`delta`​，`notime`​或 `iso`​。例如：要使用增量格式，你可以输入：

```bash
$ dmesg --time-format=delta
```

你也可以组合两个或多个选项：

```bash
$ dmesg -H -T
```

要实时观看 `dmesg`​ 命令的输出，请使用 `-w（--follow）`​选项：

```bash
$ dmesg --follow
```

‍

## 过滤 dmesg 输出

你可以将 `dmesg`​ 输出限制为给定的设施和等级。`dmesg`​ 支持以下类型：

- kern-内核消息
- user-用户级消息
- mail-邮件系统
- daemon-系统守护程序
- auth-安全/授权消息
- syslog-内部 syslogd 消息
- lpr-行式打印机子系统
- news-网络新闻子系统

​`-f（--facility <list>）`​ 选项允许你将输出限制为特定的设备，该选项接受一个或多个逗号分隔的功能。

例如，要仅显示内核和系统守护程序消息，可以使用：

```bash
$ dmesg -f kern,daemon
```

每条日志消息都与一个显示消息重要性的日志级别相关联，`dmesg`​ 支持以下日志级别：

- emerg-系统无法使用
- alert-必须立即采取措施
- crit-紧急情况
- err-错误条件
- warn-警告条件
- notice-正常但重要的条件
- info-信息性
- debug-调试级消息

​`-l（--level <list>）`​选项允许你将输出限制为定义的级别，该选项接受一个或多个逗号分隔的级别。以下命令仅显示错误和严重消息：

```bash
$ dmesg -l err,crit
```

## 清除环形缓冲区

​`-C（--clear）`​ 选项可让您清除环形缓冲区：

```bash
$ sudo dmesg -C
```

只有 `root`​ 或具有 `sudo`​ 特权的用户才能清除缓冲区。

要在清除之前打印缓冲区内容，请使用 `-c（--read-clear）`​选项：

```bash
$ sudo dmesg -c
```

如果要在清除文件之前将当前 `dmesg`​ 日志保存到文件中，你可以将输出重定向到文件：

```bash
$ dmesg > dmesg_messages
```

## 结论

​`dmesg`​ 命令允许你查看和控制内核环形缓冲区。对内核或硬件问题进行故障排除时，它非常有用。

在终端中输入 `man dmesg`​，你可以获取有关所有可用 `dmesg`​ 选项的信息。

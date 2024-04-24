# systemd

Systemd 是 Linux 系统工具，用来启动守护进程，已成为大多数发行版的标准配置。

历史上，[Linux 的启动](https://www.ruanyifeng.com/blog/2013/08/linux_boot_process.html)一直采用[`init`](https://en.wikipedia.org/wiki/Init)​进程。

下面的命令用来启动服务。

```bash
$ sudo /etc/init.d/apache2 start
# 或者
$ service apache2 start
```

这种方法有两个缺点。

一是启动时间长。`init`​进程是串行启动，只有前一个进程启动完，才会启动下一个进程。

二是启动脚本复杂。`init`​进程只是执行启动脚本，不管其他事情。脚本需要自己处理各种情况，这往往使得脚本变得很长。

‍

Systemd 就是为了解决这些问题而诞生的。它的设计目标是，为系统的启动和管理提供一套完整的解决方案。

根据 Linux 惯例，字母`d`​是守护进程（daemon）的缩写。 Systemd 这个名字的含义，就是它要守护整个系统。

使用了 Systemd，就不需要再用`init`​了。Systemd 取代了`initd`​，成为系统的第一个进程（PID 等于 1），其他进程都是它的子进程。

‍

Systemd 的优点是功能强大，使用方便，缺点是体系庞大，非常复杂。事实上，现在还有很多人反对使用 Systemd，理由就是它过于复杂，与操作系统的其他部分强耦合，违反"keep simple, keep stupid"的[Unix 哲学](https://www.ruanyifeng.com/blog/2009/06/unix_philosophy.html)。

​![](https://www.ruanyifeng.com/blogimg/asset/2016/bg2016030703.png)​

（上图为 Systemd 架构图）

# Systemd-命令篇

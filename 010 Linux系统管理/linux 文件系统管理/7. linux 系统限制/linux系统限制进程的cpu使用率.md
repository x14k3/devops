# linux系统限制进程的cpu使用率

cpu是公平的，大多数进程以相同的优先级启动，并且Linux内核在处理器上平均地为每个任务调度时间。在资源紧张时，cpu一般也是平均的分配进程占用cpu的时间片段。不过我们要对某些进程调高优先级，或者降低某进程的优先级呢，我们可以用下面几种方式控制cpu：

## [limits.conf 文件](limits.conf%20文件.md)

## [taskset](001%20shell自动化运维/shell%20命令手册/性能监控/taskset.md)

## [nice](001%20shell自动化运维/shell%20命令手册/性能监控/nice.md)

## [cpulimit](001%20shell自动化运维/shell%20命令手册/性能监控/cpulimit.md)

## [cgroups](010%20Linux系统管理/linux%20内核/cgroups.md)

‍

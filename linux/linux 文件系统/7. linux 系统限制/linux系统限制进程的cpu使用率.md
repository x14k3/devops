

cpu是公平的，大多数进程以相同的优先级启动，并且Linux内核在处理器上平均地为每个任务调度时间。在资源紧张时，cpu一般也是平均的分配进程占用cpu的时间片段。不过我们要对某些进程调高优先级，或者降低某进程的优先级呢，我们可以用下面几种方式控制cpu：

## [limits.conf 文件](010%20Linux系统管理/linux%20文件系统管理/7.%20linux%20系统限制/limits.conf%20文件.md)

## [taskset](../../linux%20命令/shell%20命令手册/性能监控/taskset.md)

## [nice](../../linux%20命令/shell%20命令手册/性能监控/nice.md)

## [cpulimit](../../linux%20命令/shell%20命令手册/性能监控/cpulimit.md)

## [cgroups](../../linux%20内核配置/内核模块/cgroups.md)

‍

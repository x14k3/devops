# nice

当 Linux 内核尝试决定哪些运行中的进程可以访问 CPU 时，其中一个需要考虑的因素就是进程优先级的值（也称为 nice 值）。每个进程都有一个介于 -20 到 19 之间的 nice 值。默认情况下，进程的 nice 值为 0。

 进程的 nice 值，可以通过 nice 命令和 renice 命令修改，进而调整进程的运行顺序。

## nice命令

nice 命令可以给要启动的进程赋予 NI 值，但是不能修改已运行进程的 NI 值。

nice 命令格式如下：

```bash
[root@localhost ~] # nice [-n NI值] 命令

 -n NI值：给命令赋予 NI 值，该值的范围为 -20~19；
```

例如：

```
[root@localhost ~]# service httpd start
[root@localhost ~]# ps -le 丨 grep "httd" | grep -v grep
F S UID  PID PPID C PRI NI ADDR   SZ   WCHAN TTY      TIME   CMD
1 S   0 2084    1 0 80   0    - 1130     -     ?  00:00:00 httpd
5 S   2 2085 2084 0 80   0    - 1130     -     ?  00:00:00 httpd
5 S   2 2086 2084 0 80   0    - 1130     -     ?  00:00:00 httpd
5 S   2 2087 2084 0 80   0    - 1130     -     ?  00:00:00 httpd
5 S   2 2088 2084 0 80   0    - 1130     -     ?  00:00:00 httpd
5 S   2 2089 2084 0 80   0    - 1130     -     ?  00:00:00 httpd
#用默认优先级自动apache服务，PRI值是80，而NI值是0
[root@localhost ~]# service httpd stop
#停止apache服务
[root@localhost ~]# nice -n -5 service httpd start
#启动apache服务，同时修改apache服务进程的NI值为-5
[rooteiocdlhost ~]# ps -le | grep "httpd" | grep -v grep
F S UID  PID PPID C FRI NI ADDR    SZ WCHAN TTY      TIME   CMD
1 S   0 2122    1 0 75   5    -  1130    -    ?  00:00:00 httpd
5 S   2 2123 2122 0 75   5    -  1130    -    ?  00:00:00 httpd
5 S   2 2124 2122 0 75   5    -  1130    -    ?  00:00:00 httpd
5 S   2 2125 2122 0 75   5    -  1130    -    ?  00:00:00 httpd
5 S   2 2126 2122 0 75   5    -  1130    -    ?  00:00:00 httpd
5 S   2 2127 2122 0 75   5    -  1130    -    ?  00:00:00 httpd
#httpd进程的PRI值变为了75，而NI值为-5
```

## renice 命令

同 nice 命令恰恰相反，renice 命令可以在进程运行时修改其 NI 值，从而调整优先级。

renice 命令格式如下：  [root@localhost ~] # renice [优先级] PID

注意，此命令中使用的是进程的 PID 号，因此常与 ps 等命令配合使用。

例如：

```
[root@localhost ~]# renice -10 2125
2125: old priority -5, new priority -10
[root@localhost ~]# ps -le | grep "httpd" | grep -v grep
1 S 0 2122 1 0 75 -5 - 113.0 - ? 00:00:00 httpd
5 S 2 2123 2122 0 75 -5 - 1130 - ? 00:00:00 httpd
5 S 2 2124 2122 0 75 -5 - 1130 - ? 00:00:00 httpd
5 S 2 2125 2122 0 70 -10 - 1130 - ? 00:00:00 httpd
5 S 2 2126 2122 0 75 -5 - 1130 - ? 00:00:00 httpd
5 S 2 2.127 2122 0 75 -5 - 1130 - ? 00:00:00 httpd
#PID为2125的进程的PRI值为70，而NI值为-10
```

如何合理地设置进程优先级，曾经是一件让系统管理员非常费神的事情。但现在已经不是了，如何地 CPU  足够强大，能够合理地对进程进行调整，输入输出设备也远远跟不上 CPU 地脚步，反而在更多的情况下，CPU 总是在等待哪些缓慢的  I/O（输入/输出）设备完成数据的读写和传输任务。

然而，手动设置进程的优先级并不能影响 I/O 设备对它的处理，这就意味着，哪些有着低优先级的进程常常不合理地占据着本就低效地 I/O 资源。

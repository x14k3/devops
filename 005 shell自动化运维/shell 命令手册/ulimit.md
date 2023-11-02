# ulimit

ulimit[命令](https://www.linuxcool.com/ "命令")来自英文词组“user limit”的缩写，是一条bash解释器的内部命令，其功能是用于限制使用[系统](https://www.linuxdown.com/ "系统")​[资源](https://www.itcool.net/ "资源")。通过使用ulimit命令能够限制用户最大启动进程数、最长CPU使用时长、最高内存占用量等资源，提高整体服务器的运行稳定性，让每位用户都可以充分、合理、公平地利用系统资源。

**语法格式：** ulimit 参数 [对象]

**常用参数：**

<table><tbody><tr><td>-a</td><td>显示当前全部的限制信息</td></tr><tr><td>-d</td><td>设置每个进程最大数据段大小（KB）</td></tr><tr><td>-f</td><td>设置每个进程最大创建文件大小（KB）</td></tr><tr><td>-H</td><td>设置硬资源限制，超过就不可再使用</td></tr><tr><td>-l</td><td>设置最大可加锁的内存值大小（KB）</td></tr><tr><td>-m</td><td>设置最大使用内存大小（KB）</td></tr><tr><td>-n</td><td>设置每个进程最多打开文件个数（个）</td></tr><tr><td>-p</td><td>设置管道缓冲区大小（KB）</td></tr><tr><td>-s</td><td>设置线程栈大小（KB）</td></tr><tr><td>-S</td><td>设置软资源限制，超过还可以使用</td></tr><tr><td>-t</td><td>设置CPU使用时长的上限（秒）</td></tr><tr><td>-u</td><td>设置用户最多可开启的程序数量（个）</td></tr><tr><td>-v</td><td>设置用户最大可使用的内容上限（KB）</td></tr></tbody></table>

**参考示例**

显示当前系统资源的限制信息：

```
[root@linuxcool ~]# ulimit -a
core file size          (blocks, -c) unlimited
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7744
max locked memory       (kbytes, -l) 16384
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 7744
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

限制每个用户的最大启动进程上限：

```
[root@linuxcool ~]# ulimit -u 500
```

限制每个进程的最多可以打开文件数量上限：

```
[root@linuxcool ~]# ulimit -n 100
```

限制每个用户的最大使用内存占用量上限：

```
[root@linuxcool ~]# ulimit -v 12800 
```

限制每个进程的使用CPU时长上限：

```
[root@linuxcool ~]# ulimit -t 2
```

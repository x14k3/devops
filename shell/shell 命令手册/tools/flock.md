

当多个进程可能会对同样的数据执行操作时，这些进程需要确保没有其它进程在同时操作，以免损坏数据。

通常，这样的进程会使用一个「锁文件」，也就是建立一个文件来告诉别的进程自己在运行，如果检测到那个文件存在，则认为有操作同样数据的其他进程也在工作。这样的问题是，进程不小心意外死亡了，没有清理掉那个锁文件，那么只能由用户手动来清理了。

‍

```bash
Usage:
 flock [options] <file|directory> <command> [command args]
 flock [options] <file|directory> -c <command>
 flock [options] <file descriptor number>

Options:

-s   # 获取一个共享锁，在定向为某文件的FD上设置共享锁而未释放锁的时间内，其他进程试图在定向为此文件的FD上设置独占锁的请求失败，而其他进程试图在定向为此文件的FD上设置共享锁的请求会成功。
-x   # 获取一个排它锁，或者称为写入锁，为默认项
-u   # 手动释放锁，一般情况不必须，当FD关闭时，系统会自动解锁，此参数用于脚本命令一部分需要异步执行，一部分可以同步执行的情况。
-n   # 非阻塞模式，当获取锁失败时，返回1而不是等待
-w   # 设置阻塞超时，当超过设置的秒数时，退出阻塞模式，返回1，并继续执行后面的语句
-o   # 表示当执行command前关闭设置锁的FD，以使command的子进程不保持锁。
-c   # 在shell中执行其后的语句
-E   # exit code after conflict or timeout
-h   # display this help and exit
-V   # output version information and exit
```

用它来实现我们上边说的“任务互斥”。可如下配置：

```bash
# old 
*/10 * * * * /bin/bash do_somethings_with_long_time.sh 

# new 
*/10 * * * * flock -xn /tmp/my.lock -c "/bin/bash do_somethings_with_long_time.sh "
```

- x 表示文件锁为互斥文件锁，这个参数可以省略，默认即为互斥文件锁。
- n 表示当有任务执行时，直接退出，符合我们的预期。

‍

除了上边的功能，大家还可以实现排队等待、共享锁等功能。可如下配置：

```bash
# 排队执行  每个任务等待 20s，超时则退出
*/10 * * * * flock -w 20 /tmp/my.lock -c "/bin/bash do_somethings_with_long_time.sh "

# 共享锁
*/10 * * * * flock -s /tmp/my.lock -c "/bin/bash do_somethings_with_long_time.sh "

# 忽略锁，直接执行
*/10 * * * * flock -u /tmp/my.lock -c "/bin/bash do_somethings_with_long_time.sh "

# 自定义退出码
*/10 * * * * flock -E 1 -w 20 /tmp/my.lock -c "/bin/bash do_somethings_with_long_time.sh "
```

这里需要注意，在自定义退出码时，尽量使用1位的数字，当使用多位数字时，会出现不是自定义的其他返回码。

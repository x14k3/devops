

Cpulimit 是一个限制进程的 CPU 使用率的工具（以百分比表示，而不是以 CPU 时间表示）。 当您不希望批处理作业占用太多 CPU  周期时，控制批处理作业很有用。 目标是防止进程运行超过指定的时间比率。它不会更改 nice 值或其他调度优先级设置，而是更改真实的 CPU  使用率。 此外，它能够动态且快速地适应整个系统负载。 使用的 CPU 数量的控制是通过向进程发送 SIGSTOP 和 SIGCONT POSIX 信号来完成的。 指定进程的所有子进程和线程将共享相同百分比的 CPU。

## CPULimit 安装方法

CPULimit 并不是系统自带的工具，使用前要先安装。在 Debian 或 Ubuntu 系列的 Linux 中，可以使用 apt 来安装：

```
sudo apt-get install cpulimit
```

若在 CentOS、RHEL 或者是 Fedora Linux 中，可在启用 EPEL 套件库后，再以 yum 安装：

```
sudo yum install cpulimit
```

或者直接：

```
sudo yum install epel-release cpulimit
```

## CPULimit 使用

```bash
Usage: cpulimit [OPTIONS...] TARGET
   OPTIONS
      -l, --limit=N          percentage of cpu allowed from 0 to 800 (required) # 允许的 CPU 百分比，范围从 0 到 800（必需）
      -v, --verbose          show control statistics                            # 显示控制统计信息
      -z, --lazy             exit if there is no target process, or if it dies  # 如果没有目标进程或目标进程终止，则退出
      -i, --include-children limit also the children processes                  # 还限制子进程
      -h, --help             display this help and exit
   TARGET must be exactly one of these:
      -p, --pid=N            pid of the process (implies -z)                    # 进程的 pid（隐含 -z）
      -e, --exe=FILE         name of the executable program file or path name   # 可执行程序文件的名称或路径名
      COMMAND [ARGS]         run this command and limit it (implies -z)         # 命令 [参数] 运行此命令并限制它（隐含 -z）
```

```bash
[root@localhost ~]# cpulimit -l 20 -p 27677
Process 27677 found
```

‍

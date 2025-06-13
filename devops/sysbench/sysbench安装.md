

sysbench 是一款开源的多线程性能测试工具，可以执行 CPU/内存/线程/IO/数据库等方面的性能测试。

## 安装

### 源码编译安装

1、安装依赖包

```bash
yum -y install gcc gcc-c++ autoconf automake libtool  git
```

2、下载源码

```bash
git clone https://github.com/akopytov/sysbench.git
```

3、编译安装

```bash
cd sysbench/
./autogen.sh
./configure --without-mysql   #如果需要测试mysql就去掉--without-mysql这个选项
make && make install
```

‍

### 使用 yum 安装

sysbench 在 epel-release 这个包里面，因此要先安装 epel-release

```bash
yum -y install epel-release
yum -y install sysbench
```

> 如果需要比较新的版本，可以直接使用 git 上面的源码进行编译。yum 安装就比较方便了，省去编译的时间。

‍

## sysbench 用法讲解

sysbench 命令语法如下

```css
sysbench [options]... [testname] [command]
```

​**​`testname`​**​**是测试项名称**。sysbench 支持的测试项包括：

- \*.lua          数据库性能基准测试。
- fileio          磁盘 IO 基准测试。
- cpu            CPU 性能基准测试。
- memory     内存访问基准测试。
- threads      基于线程的调度程序基准测试。
- mutex         POSIX 互斥量基准测试。

​**​`command`​**​**是 sysbench 要执行的命令**，支持的选项有：`prepare`​，`prewarm`​，`run`​，`cleanup`​，`help`​。注意，不是所有的测试项都支持这些选项。

​**​`options`​**​**是配置项**。sysbench 中的配置项主要包括以下两部分：

1. 通用配置项。这部分配置项可通过 `sysbench --help`​ 查看。

    ```bash
    [root@localhost src]# ./sysbench --help
    Usage:
      sysbench [options]... [testname] [command]

    Commands implemented by most tests: prepare run cleanup help

    General options:
      --threads=N                     number of threads to use [1]
      --events=N                      limit for total number of events [0]
      --time=N                        limit for total execution time in seconds [10]
      --warmup-time=N                 execute events for this many seconds with statistics disabled before the actual benchmark run with statistics enabled [0]
      --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off]
      --thread-stack-size=SIZE        size of stack per thread [64K]
      --thread-init-timeout=N         wait time in seconds for worker threads to initialize [30]
      --rate=N                        average transactions rate. 0 for unlimited rate [0]
      --report-interval=N             periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports [0]
      --report-checkpoints=[LIST,...] dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default. []
      --debug[=on|off]                print more debugging info [off]
      --validate[=on|off]             perform validation checks where possible [off]
      --help[=on|off]                 print help and exit [off]
      --version[=on|off]              print version and exit [off]
      --config-file=FILENAME          File containing command line options
      --luajit-cmd=STRING             perform LuaJIT control command. This option is equivalent to 'luajit -j'. See LuaJIT documentation for more information

    Pseudo-Random Numbers Generator options:
      --rand-type=STRING   random numbers distribution {uniform, gaussian, pareto, zipfian} to use by default [uniform]
      --rand-seed=N        seed for random number generator. When 0, the current time is used as an RNG seed. [0]
      --rand-pareto-h=N    shape parameter for the Pareto distribution [0.2]
      --rand-zipfian-exp=N shape parameter (exponent, theta) for the Zipfian distribution [0.8]

    Log options:
      --verbosity=N verbosity level {5 - debug, 0 - only critical messages} [3]

      --percentile=N       percentile to calculate in latency statistics (1-100). Use the special value of 0 to disable percentile calculations [95]
      --histogram[=on|off] print latency histogram in report [off]

    General database options:

      --db-driver=STRING  specifies database driver to use ('help' to get list of available drivers) [mysql]
      --db-ps-mode=STRING prepared statements usage mode {auto, disable} [auto]
      --db-debug[=on|off] print database-specific debug information [off]


    Compiled-in tests:
      fileio - File I/O test
      cpu - CPU performance test
      memory - Memory functions speed test
      threads - Threads subsystem performance test
      mutex - Mutex performance test

    See 'sysbench <testname> help' for a list of options for each test.

    [root@localhost src]# 

    ```

2. 测试项相关的配置项。各个测试项支持的配置项可通过 `sysbench testname help`​ 查看。例如

    ```bash
    # sysbench memory help
    sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

    memory options:
      --memory-block-size=SIZE    size of memory block for test [1K]
      --memory-total-size=SIZE    total size of data to transfer [100G]
      --memory-scope=STRING       memory access scope {global,local} [global]
      --memory-hugetlb[=on|off]   allocate memory from HugeTLB pool [off]
      --memory-oper=STRING        type of memory operations {read, write, none} [write]
      --memory-access-mode=STRING memory access mode {seq,rnd} [seq]
    ```

‍

‍

‍

‍

‍

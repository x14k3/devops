# sysbench

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

* \*.lua          数据库性能基准测试。
* fileio          磁盘 IO 基准测试。
* cpu            CPU 性能基准测试。
* memory     内存访问基准测试。
* threads      基于线程的调度程序基准测试。
* mutex         POSIX 互斥量基准测试。

　　​**​`command`​**​**是 sysbench 要执行的命令**，支持的选项有：`prepare`​，`prewarm`​，`run`​，`cleanup`​，`help`​。注意，不是所有的测试项都支持这些选项。

　　​**​`options`​**​**是配置项**。sysbench 中的配置项主要包括以下两部分：

1. 通用配置项。这部分配置项可通过 `sysbench --help`​ 查看。

    ```bash
    # sysbench --help
    General options:
      --threads=N                     number of threads to use [1]
      --events=N                      limit for total number of events [0]
      --time=N                        limit for total execution time in seconds [10]
     ...
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

## 数据库性能基准测试

* 📄 [对 MySQL 进行基准测试的基本步骤](siyuan://blocks/20241212134451-vmik8g6)
* 📄 [对 Oracle 进行基准测试的基本步骤](siyuan://blocks/20241212134641-mzowcea)
* 📄 [对 Postgresql 进行基准测试的基本步骤](siyuan://blocks/20241212134631-qm0vzpc)
* 📄 [对 达梦 进行基准测试的基本步骤](siyuan://blocks/20241212134612-59t386h)

　　‍

　　‍

　　‍

　　‍

# taskset

## 使用taskset命令让进程运行在指定CPU上

#### 适用场景

　　CentOS、EulerOS系列操作系统。

#### 操作步骤

1. 执行如下命令，查看云服务器CPU核数。

    ```bash
    [root@localhost ~]# lscpu 
    Architecture:          x86_64
    CPU op-mode(s):        32-bit, 64-bit
    Byte Order:            Little Endian
    CPU(s):                8
    On-line CPU(s) list:   0-7
    Thread(s) per core:    1
    Core(s) per socket:    1
    座：                 8
    NUMA 节点：         1
    厂商 ID：           GenuineIntel
    CPU 系列：          6
    型号：              79
    型号名称：        Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz
    步进：              1
    CPU MHz：             2299.998
    BogoMIPS：            4599.99
    超管理器厂商：  VMware
    虚拟化类型：     完全
    L1d 缓存：          32K
    L1i 缓存：          32K
    L2 缓存：           256K
    L3 缓存：           51200K
    NUMA 节点0 CPU：    0-7

    ```

    ‍
2. 执行以下命令，获取进程状态（pid为10825）

    ```bash
    [root@localhost ~]# ps -ef|grep sdatad
    root     10825     1  2 7月23 ?       00:27:50 /usr/local/sdata/sbin/sdatad
    ```
3. 执行以下命令，查看进程当前运行在哪个CPU上。  

    ```bash
    [root@localhost ~]# taskset -p 10825
    pid 10825's current affinity mask: ff
    [root@localhost ~]#
    ```

    显示的是十六进制数字ff，转换为二进制为11111111。每个1对应一个CPU，所以进程运行在8个（全部）CPU上。
4. 执行以下命令，指定进程运行在第二个CPU（CPU1）上。  
    **taskset -pc 1** ***进程号***

    ```bash
    taskset -pc 1 10825
    ```

　　CPU的标号是从0开始的，所以CPU1表示第二个CPU（第一个CPU的标号是0），这样就把应用程序test.sh绑定到了CPU1上运行。

　　也可以使用如下命令在启动程序时绑定CPU（启动时绑定到第二个CPU）上。

　　​`taskset -c 1 ./test.sh&amp;`​

```bash
# taskset -pc 0 1467
pid 1467's current affinity list: 1
pid 1467's new affinity list: 0
# taskset -pc 0,1 1467
pid 1467's current affinity list: 0
pid 1467's new affinity list: 0,1
```

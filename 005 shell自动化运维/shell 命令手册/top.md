# top

top命令是Linux下常用的性能分析工具，能够实时显示系统中各个进程的资源占用状况，常用于服务端性能分析。

## [#](https://wiki.eryajf.net/pages/5279.html#_1-%E6%89%A7%E8%A1%8C%E3%80%82) 1，执行

```
[root@fbtest4 ~]# top
top - 17:56:13 up 161 days,  3:11,  3 users,  load average: 0.23, 0.37, 0.18
Tasks: 129 total,   1 running, 128 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.7%us,  0.5%sy,  0.0%ni, 98.3%id,  0.2%wa,  0.2%hi,  0.2%si,  0.0%st
Mem:   3924744k total,  3164944k used,   759800k free,   183256k buffers
Swap:  6291452k total,   545464k used,  5745988k free,   965616k cached
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
12991 root      20   0 3521m 486m  13m S  1.0 12.7   2:07.28 java
 5521 zabbix    20   0 79548 1140 1032 S  0.3  0.0   3:41.13 zabbix_agentd
10595 root      20   0 1428m 7052 2324 S  0.3  0.2  37:49.02 agentWorker
12291 nobody    20   0 60316  12m 2104 S  0.3  0.3   1:12.91 nginx
17913 root      20   0 3793m 689m  11m S  0.3 18.0  14:35.05 java
    1 root      20   0 19232  668  528 S  0.0  0.0   0:02.70 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
    3 root      RT   0     0    0    0 S  0.0  0.0   1:36.53 migration/0
    4 root      20   0     0    0    0 S  0.0  0.0   1:59.82 ksoftirqd/0
    5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/0
    6 root      RT   0     0    0    0 S  0.0  0.0   0:31.77 watchdog/0
    7 root      RT   0     0    0    0 S  0.0  0.0   1:14.78 migration/1
    8 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/1
    9 root      20   0     0    0    0 S  0.0  0.0   1:48.74 ksoftirqd/1
   10 root      RT   0     0    0    0 S  0.0  0.0   0:20.99 watchdog/1
   11 root      20   0     0    0    0 S  0.0  0.0  13:29.31 events/0
   12 root      20   0     0    0    0 S  0.0  0.0  22:37.27 events/1
   13 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cgroup
```

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_2-%E8%BF%9B%E5%85%A5%E8%AF%A6%E8%A7%A3%E3%80%82) 2，进入详解

### [#](https://wiki.eryajf.net/pages/5279.html#_1-top%E5%91%BD%E4%BB%A4%E7%9A%84%E7%BB%93%E6%9E%9C%E5%88%86%E4%B8%BA%E4%B8%A4%E4%B8%AA%E9%83%A8%E5%88%86%E3%80%82) 1，top命令的结果分为两个部分

* 统计信息：前五行是系统整体的统计信息；
* 进程信息：统计信息下方类似表格区域显示的是各个进程的详细信息，默认5秒刷新一次。

### [#](https://wiki.eryajf.net/pages/5279.html#_2-%E7%BB%9F%E8%AE%A1%E4%BF%A1%E6%81%AF%E8%AF%B4%E6%98%8E%E3%80%82) 2，统计信息说明

* 第1行：Top 任务队列信息(系统运行状态及平均负载)，与uptime命令结果相同。

  * 第1列：系统当前时间，例如：16:07:37
  * 第2列：系统运行时间，未重启的时间，时间越长系统越稳定。
  * 格式：up xx days, HH:MM
  * 例如：241 days, 20:11, 表示连续运行了241天20小时11分钟
  * 第3列：当前登录用户数，例如：1 user，表示当前只有1个用户登录
  * 第4列：系统负载，即任务队列的平均长度，3个数值分别统计最近1，5，15分钟的系统平均负载
  * 系统平均负载：单核CPU情况下，0.00 表示没有任何负荷，1.00表示刚好满负荷，超过1侧表示超负荷，理想值是0.7；
  * 多核CPU负载：CPU核数 * 理想值0.7 = 理想负荷，例如：4核CPU负载不超过2.8何表示没有出现高负载。
* 第2行：Tasks 进程相关信息

  * 第1列：进程总数，例如：Tasks: 231 total, 表示总共运行231个进程
  * 第2列：正在运行的进程数，例如：1 running,
  * 第3列：睡眠的进程数，例如：230 sleeping,
  * 第4列：停止的进程数，例如：0 stopped,
  * 第5列：僵尸进程数，例如：0 zombie
* 第3行：Cpus CPU相关信息，如果是多核CPU，按数字1可显示各核CPU信息，此时1行将转为Cpu核数行，数字1可以来回切换。

  * 第1列：us 用户空间占用CPU百分比，例如：Cpu(s): 12.7%us,
  * 第2列：sy 内核空间占用CPU百分比，例如：8.4%sy,
  * 第3列：ni 用户进程空间内改变过优先级的进程占用CPU百分比，例如：0.0%ni,
  * 第4列：id 空闲CPU百分比，例如：77.1%id,
  * 第5列：wa 等待输入输出的CPU时间百分比，例如：0.0%wa,
  * 第6列：hi CPU服务于硬件中断所耗费的时间总额，例如：0.0%hi,
  * 第7列：si CPU服务软中断所耗费的时间总额，例如：1.8%si,
  * 第8列：st Steal time 虚拟机被hypervisor偷去的CPU时间（如果当前处于一个hypervisor下的vm，实际上hypervisor也是要消耗一部分CPU处理时间的）
* 第4行：Mem 内存相关信息（Mem: 12196436k total, 12056552k used, 139884k free, 64564k buffers）

  * 第1列：物理内存总量，例如：Mem: 12196436k total,
  * 第2列：使用的物理内存总量，例如：12056552k used,
  * 第3列：空闲内存总量，例如：Mem: 139884k free,
  * 第4列：用作内核缓存的内存量，例如：64564k buffers
* 第5行：Swap 交换分区相关信息（Swap: 2097144k total, 151016k used, 1946128k free, 3120236k cached）

  * 第1列：交换区总量，例如：Swap: 2097144k total,
  * 第2列：使用的交换区总量，例如：151016k used,
  * 第3列：空闲交换区总量，例如：1946128k free,
  * 第4列：缓冲的交换区总量，3120236k cached

​

​

### [#](https://wiki.eryajf.net/pages/5279.html#_3-%E8%BF%9B%E7%A8%8B%E4%BF%A1%E6%81%AF%E3%80%82) 3，进程信息。

在top命令中按f按可以查看显示的列信息，按对应字母来开启/关闭列，大写字母表示开启，小写字母表示关闭。带*号的是默认列。

* A: PID = (Process Id) 进程Id；
* E: USER = (User Name) 进程所有者的用户名；
* H: PR = (Priority) 优先级
* I: NI = (Nice value) nice值。负值表示高优先级，正值表示低优先级
* O: VIRT = (Virtual Image (kb)) 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
* Q: RES = (Resident size (kb)) 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA
* T: SHR = (Shared Mem size (kb)) 共享内存大小，单位kb
* W: S = (Process Status) 进程状态。D=不可中断的睡眠状态,R=运行,S=睡眠,T=跟踪/停止,Z=僵尸进程
* K: %CPU = (CPU usage) 上次更新到现在的CPU时间占用百分比
* N: %MEM = (Memory usage (RES)) 进程使用的物理内存百分比
* M: TIME+ = (CPU Time, hundredths) 进程使用的CPU时间总计，单位1/100秒
* b: PPID = (Parent Process Pid) 父进程Id
* c: RUSER = (Real user name)
* d: UID = (User Id) 进程所有者的用户id
* f: GROUP = (Group Name) 进程所有者的组名
* g: TTY = (Controlling Tty) 启动进程的终端名。不是从终端启动的进程则显示为 ?
* j: P = (Last used cpu (SMP)) 最后使用的CPU，仅在多CPU环境下有意义
* p: SWAP = (Swapped size (kb)) 进程使用的虚拟内存中，被换出的大小，单位kb
* l: TIME = (CPU Time) 进程使用的CPU时间总计，单位秒
* r: CODE = (Code size (kb)) 可执行代码占用的物理内存大小，单位kb
* s: DATA = (Data+Stack size (kb)) 可执行代码以外的部分(数据段+栈)占用的物理内存大小，单位kb
* u: nFLT = (Page Fault count) 页面错误次数
* v: nDRT = (Dirty Pages count) 最后一次写入到现在，被修改过的页面数
* y: WCHAN = (Sleeping in Function) 若该进程在睡眠，则显示睡眠中的系统函数名
* z: Flags = (Task Flags <sched.h>) 任务标志，参考 sched.h
* X: COMMAND = (Command name/line) 命令名/命令行

## [#](https://wiki.eryajf.net/pages/5279.html#_3-top%E5%91%BD%E4%BB%A4%E9%80%89%E9%A1%B9%E3%80%82) 3，top命令选项。

* -b：以批处理模式操作；
* -c：显示完整的治命令；
* -d：屏幕刷新间隔时间；
* -I：忽略失效过程；
* -s：保密模式；
* -S：累积模式；
* -i<时间>：设置间隔时间；
* -u<用户名>：指定用户名；
* -p<进程号>：指定进程；
* -n<次数>：循环显示的次数。

## [#](https://wiki.eryajf.net/pages/5279.html#_4-top%E5%91%BD%E4%BB%A4%E4%BA%A4%E4%BA%92) 4，top命令交互

* 常用交互操作

  * 基础操作

    * 1：显示CPU详细信息，每核显示一行
    * d / s ：修改刷新频率，单位为秒
    * h：可显示帮助界面
    * n：指定进程列表显示行数，默认为满屏行数
    * q：退出top
  * 面板隐藏显示

    * l：隐藏/显示第1行负载信息；
    * t：隐藏/显示第2~3行CPU信息；
    * m：隐藏/显示第4~5行内存信息；
  * 进程列表排序

    * M：根据驻留内存大小进行排序；
    * P：根据CPU使用百分比大小进行排序；
    * T：根据时间/累计时间进行排序；
* 详细交互指令：h / ? 可显示帮助界面，原始为英文版，简单翻译如下：

```
Help for Interactive Commands - procps version 3.2.8
Window 1:Def: Cumulative mode Off.  System: Delay 3.0 secs; Secure mode Off.
  Z,B       Global: 'Z' change color mappings; 'B' disable/enable bold
            Z：修改颜色配置；B：关闭/开启粗体
  l,t,m     Toggle Summaries: 'l' load avg; 't' task/cpu stats; 'm' mem info
            l：隐藏/显示第1行负载信息；t：隐藏/显示第2~3行CPU信息；m：隐藏/显示第4~5行内存信息；
  1,I       Toggle SMP view: '1' single/separate states; 'I' Irix/Solaris mode
            1：单行/多行显示CPU信息；I：Irix/Solaris模式切换
  f,o     . Fields/Columns: 'f' add or remove; 'o' change display order
            f：列显示控制；o：列排序控制，按字母进行调整
  F or O  . Select sort field  选择排序列
  <,>     . Move sort field: '<' next col left; '>' next col right 上下移动内容
  R,H     . Toggle: 'R' normal/reverse sort; 'H' show threads
            R：内容排序；H：显示线程
  c,i,S   . Toggle: 'c' cmd name/line; 'i' idle tasks; 'S' cumulative time
            c：COMMAND列命令名称与完整命令行路径切换；i：忽略闲置和僵死进程开关；S：累计模式切换
  x,y     . Toggle highlights: 'x' sort field; 'y' running tasks
            x：列排序；y：运行任务
  z,b     . Toggle: 'z' color/mono; 'b' bold/reverse (only if 'x' or 'y')
            z：颜色模式；b：粗体开关 仅适用于x，y模式中
  u       . Show specific user only 按用户进行过滤，当输入错误可按Ctrl + Backspace进行删除
  n or #  . Set maximum tasks displayed 设置进程最大显示条数
  k,r       Manipulate tasks: 'k' kill; 'r' renice
            k：终止一个进程；r：重新设置一个进程的优先级别
  d or s    Set update interval  改变两次刷新之间的延迟时间（单位为s），如果有小数，就换算成ms。输入0值则系统将不断刷新，默认值是5s；
  W         Write configuration file 将当前设置写入~/.toprc文件中
  q         Quit       退出
          ( commands shown with '.' require a visible task display window )
            注意：带.的命令需要一个可见的任务显示窗口
Press 'h' or '?' for help with Windows, any other key to continue
```

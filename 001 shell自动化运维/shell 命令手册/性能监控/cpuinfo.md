# cpuinfo

## **CPU 基础信息**

### 1. 通过 cat /proc/cpuinfo查看

```
[root@root ~]# cat /proc/cpuinfo 
processor       : 0                 // 逻辑处理器的唯一标识符
vendor_id       : GenuineIntel      // CPU制造商，GenuineIntel表示是英特尔处理器
cpu family      : 6                 // CPU产品系列代号
model           : 79                // 表明CPU属于其系列中的哪一代号
model name      : Intel(R) Xeon(R) CPU E5-2682 v4 @ 2.50GHz    // CPU属于的名字、编号、主频
stepping        : 1                 // 步进编号，用来标识处理器的设计或制作版本，有助于控制和跟踪处理器的更改
microcode       : 0x1               // CPU微代码
cpu MHz         : 2494.220          // CPU的实际试用主频
cache size      : 40960 KB          // CPU二级cache大小
physical id     : 0                 // 物理CPU的标号，物理CPU就是硬件上真实存在的CPU
siblings        : 1                 // 一个物理CPU有几个逻辑CPU
core id         : 0                 // 一个物理CPU上的每个内核的唯一标识符，不同物理CPU的core id可以相同，因为每个CPU上的core id都从0开始标识
cpu cores       : 1                 // 指的是一个物理CPU有几个核
apicid          : 0                 // 用来区分不同逻辑核的编号，系统中每个逻辑核的此编号都不同
initial apicid  : 0
fpu             : yes               // 是否具有浮点运算单元
fpu_exception   : yes               // 是否支持浮点计算异常
cpuid level     : 13                // 执行cpuid指令前，eax寄存器中的值，不同cpuid指令会返回不同内容
wp              : yes               // 表明当前CPU是否在内核态支持对用户空间的写保护（Write Protection）
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch ibrs ibpb stibp fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm rdseed adx smap xsaveopt spec_ctrl intel_stibp
bogomips        : 4988.44           // 在系统内核启动时粗略测算的CPU速度
clflush size    : 64                // 每次刷新缓存的大小单位
cache_alignment : 64                // 缓存地址对齐单位
address sizes   : 46 bits physical, 48 bits virtual // 可访问地址空间位数  
power management:                   // 电源管理相关

```

### 2. 通过lscpu命令进行查看

> lscpu命令从sysfs和/proc/cpuinfo收集cpu体系结构信息，命令的输出比较易读，命令输出的信息包含cpu数量，线程，核数，套接字等。

```
[root@localhost ~]# lscpu
Architecture:          x86_64            // 架构，这里的64指的位处理器
CPU op-mode(s):        32-bit, 64-bit    // CPU支持的模式：32位、64位
Byte Order:            Little Endian     // 字节排序的模式，常用小端模式
CPU(s):                32                // 逻辑CPU数量
On-line CPU(s) list:   0-31              // 在线的cpu数量 有些时候为了省电或者过热的时候，某些CPU会停止运行
Thread(s) per core:    2                 // 每个核心支持的线程数
Core(s) per socket:    8                 // 每颗物理cpu的核数
Socket(s):             2                 // 主板上插CPU的槽的数量，即物理cpu数量
NUMA node(s):          2
Vendor ID:             GenuineIntel      // cpu厂商ID
CPU family:            6                 // CPU系列
Model:                 69                // CPU型号  
Model name:            Intel(R) Core(TM) i5-4210U CPU @ 1.70GHz
Stepping:              1  
CPU MHz:               1704.097          // cpu主频
CPU max MHz:           2700.0000     
CPU min MHz:           800.0000
BogoMIPS:              4788.97           // MIPS是每秒百万条指令,Bogo是Bogus(伪)的意思，这里是估算MIPS值
Virtualization:        VT-x              // cpu支持的虚拟化技术
L1d cache:             32K               // 一级高速缓存 dcache 用来存储数据
L1i cache:             32K               // 一级高速缓存 icache 用来存储指令
L2 cache:              256K              // 二级缓存
L3 cache:              3072K             // 三级缓存 缓存速度上 L1 > L2 > L3 > DDR(内存)
NUMA node0 CPU(s):     0-3

```

### 3. 逻辑核数、物理cpu、线程数关系

基本概念：

* 物理CPU数：主板上实际插入的cpu数量，**cpuinfo中不重复的physical id数量**
* 逻辑CPU数：  一般情况，一个cpu可以有多核，加上intel的超线程技术(HT), 可以在逻辑上再分一倍数量的cpu core出来。
* cpu核数：一块CPU能处理数据的芯片组的数量
* 超线程：超线程技术就是利用特殊的硬件指令，把两个逻辑内核模拟成两个物理芯片，让单个处理器都能使用线程级并行计算，进而兼容多线程操作系统和软件，减少了CPU的闲置时间，提高的CPU的运行效率。

关系：

* **总核数 =**  **物理CPU个数 ***  **每颗物理CPU的核数**
* **总逻辑CPU数 =**  **物理CPU个数 ***  **每颗物理CPU的核数 ***  **超线程数**

判断是否是否开启了超线程：  
 一般来说，物理CPU个数×每颗核数就应该等于逻辑CPU的个数，如果不相等的话，则表示服务器的CPU支持超线程技术。

‍

平常工作会涉及到一些 Linux 性能分析的问题，因此决定总结一下常用的一些性能分析手段，仅供参考。

说到性能分析，基本上就是 CPU、内存、磁盘 IO 以及网络这几个部分，本文先来看 CPU 这个部分。

### 4. 查看cpu相关信息命令

```
// 查看CPU型号
[root@root /]# cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

// 查看物理CPU个数
[root@root /]# cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l

// 查看每个物理CPU的核数
[root@root /]# cat /proc/cpuinfo | grep 'core id' | sort -u | wc -l

// 查看逻辑CPU的数量（总线程数量）
[root@root /]# cat /proc/cpuinfo| grep "processor"| wc -l

// 查看CPU的主频
[root@root /]# cat  /proc/cpuinfo | grep MHz | uniq

```

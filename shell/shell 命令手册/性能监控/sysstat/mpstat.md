# mpstat

**mpstat命令** 主要用于多CPU环境下，它显示各个可用CPU的状态信息。这些信息存放在`/proc/stat`​文件中。在多CPUs系统里，其不但能查看所有CPU的平均状况信息，而且能够查看特定CPU的信息。

### 语法

```shell
mpstat [选项] [<间隔时间> [<次数>]]
```

### 选项

```shell
-P：指定CPU编号。
```

### 参数

- 间隔时间：每次报告的间隔时间（秒）；
- 次数：显示报告的次数。

### 表头含义

- %user：表示处理用户进程所使用CPU的百分比。
- %nice：表示在用户级别处理经nice降级的程序所使用CPU的百分比。
- %system：表示内核进程使用的CPU百分比。
- %iowait：表示等待进行I/O所占用CPU时间百分比。
- %irq：表示用于处理系统中断的CPU百分比。
- %soft：表示用于处理软件中断的CPU百分比。
- %steal：在管理程序为另一个虚拟处理器服务时，显示虚拟的一个或多个CPU在非自愿等待中花费的时间的百分比。
- %guest：表示一个或多个CPU在运行虚拟处理器时所花费的时间百分比。
- %gnice：表示一个或多个CPU在运行经nice降级后的虚拟处理器时所花费的时间百分比。
- %idle：CPU的空闲时间百分比。

### 实例

当mpstat不带参数时，输出为从系统启动以来的平均值。

```shell
mpstat
Linux 3.10.0-1160.71.1.el7.x86_64 (centos)      08/14/2022      _x86_64_        (4 CPU)

04:28:36 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
04:28:36 PM  all    0.03    0.00    0.07    0.00    0.00    0.01    0.00    0.00    0.00   99.89
```

**每2秒产生了全部处理器的统计数据报告：**

下面的命令可以每2秒产生全部处理器的统计数据报告，一共产生三个interval的信息，最后再给出这三个interval的平均信息。默认时，输出是按照CPU号排序。第一个行给出了2秒内所有处理器使用情况。接下来每行对应一个处理器使用情况。

```shell
mpstat -P ALL 2 3
Linux 3.10.0-1160.71.1.el7.x86_64 (centos)      08/15/2022      _x86_64_        (4 CPU)

09:32:43 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:32:45 AM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:45 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:45 AM    1    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:45 AM    2    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:45 AM    3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

09:32:45 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:32:47 AM  all    0.00    0.00    0.12    0.00    0.00    0.12    0.00    0.00    0.00   99.75
09:32:47 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:47 AM    1    0.00    0.00    0.50    0.00    0.00    0.00    0.00    0.00    0.00   99.50
09:32:47 AM    2    0.00    0.00    0.00    0.00    0.00    0.50    0.00    0.00    0.00   99.50
09:32:47 AM    3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

09:32:47 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:32:49 AM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:49 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:49 AM    1    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:49 AM    2    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
09:32:49 AM    3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
Average:     all    0.00    0.00    0.04    0.00    0.00    0.04    0.00    0.00    0.00   99.92
Average:       0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       1    0.00    0.00    0.17    0.00    0.00    0.00    0.00    0.00    0.00   99.83
Average:       2    0.00    0.00    0.00    0.00    0.00    0.17    0.00    0.00    0.00   99.83
Average:       3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
```

**比较带参数和不带参数的mpstat的结果：**

对localhost进行压力测试

```shell
ping -f localhost
```

然后在另一个终端运行mpstat命令

```shell
mpstat
Linux 3.10.0-1160.71.1.el7.x86_64 (centos)      08/15/2022      _x86_64_        (4 CPU)

09:34:20 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:34:20 AM  all    0.03    0.00    0.07    0.00    0.00    0.02    0.00    0.00    0.00   99.88
```

上文说到：当mpstat不带参数时，输出为从系统启动以来的平均值，所以这看不出什么变化。

```shell
mpstat
Linux 3.10.0-1160.71.1.el7.x86_64 (centos)      08/15/2022      _x86_64_        (4 CPU)

09:34:40 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:34:40 AM  all    0.03    0.00    0.07    0.00    0.00    0.02    0.00    0.00    0.00   99.88
```

只有加上间隔时间才能显示某一段时间CPU的使用情况

```shell
mpstat 3 10
Linux 3.10.0-1160.71.1.el7.x86_64 (centos)      08/15/2022      _x86_64_        (4 CPU)

09:36:21 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
09:36:24 AM  all    1.81    0.00    7.03    0.00    0.00    6.37    0.00    0.00    0.00   84.79
09:36:27 AM  all    1.82    0.00    6.88    0.00    0.00    5.83    0.00    0.00    0.00   85.47
09:36:30 AM  all    1.95    0.00    5.86    0.00    0.00    4.98    0.00    0.00    0.00   87.21
09:36:33 AM  all    3.95    0.00    6.50    0.00    0.00    5.46    0.00    0.00    0.00   84.09
09:36:36 AM  all    4.05    0.00    6.21    0.00    0.00    5.64    0.00    0.00    0.00   84.10
09:36:39 AM  all    4.21    0.00    6.92    0.00    0.00    5.33    0.00    0.00    0.00   83.54
09:36:42 AM  all    3.72    0.00    7.17    0.00    0.00    6.05    0.00    0.00    0.00   83.05
09:36:45 AM  all    3.97    0.00    6.93    0.00    0.00    6.65    0.00    0.00    0.00   82.46
09:36:48 AM  all    4.30    0.00    9.55    0.00    0.00    9.55    0.00    0.00    0.00   76.59
09:36:51 AM  all    4.35    0.00    9.31    0.00    0.00    8.79    0.00    0.00    0.00   77.55
Average:     all    3.44    0.00    7.28    0.00    0.00    6.52    0.00    0.00    0.00   82.76
```

上两表显示出当要正确反映系统的情况，需要正确使用命令的参数。vmstat 和iostat 也需要注意这一问题。

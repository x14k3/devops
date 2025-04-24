# warn-Linux标准大页设置不合理案例

‍

Oracle数据库中如果标准大页设置不合理，可能导致物理内存被浪费掉。下面介绍一个案例：

查看标准大页的信息，如下所示：

```bash
$ grep HugePages /proc/meminfo
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:       199680
HugePages_Free:        97561
HugePages_Rsvd:        77082
HugePages_Surp:        0
```

这个是计算标准大页的使用的公式：

```shell
( HugePages_Total - HugePages_Free ) + HugePages_Rsvd = HugePages Usage
( HugePages_Total - HugePages Usage) x Hugepagesize = Free HugePages
```

下面根据实际情况计算，如下所示：

```bash
$ grep Hugepagesize /proc/meminfo
Hugepagesize:       2048 kB

(199680 - 97561 ) + 77082 =  179201  <<<---- HugePages Usage

(199680 - 179201 ) * 2048 = 41940992 kB   <<<----- Free HugePages
```

由于标准大页设置不合理，导致接近40G的物理内存被浪费了。所以标准大页需要合理设置，避免物理内存的浪费。尤其是在调整SGA后，需要使用官方提供的脚本hugepages\_settings.sh **重新计算**标准大页的值。

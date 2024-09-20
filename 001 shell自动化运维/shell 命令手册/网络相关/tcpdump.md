# tcpdump

　　tcpdump采用命令行方式对接口的数据包进行筛选抓取，其丰富特性表现在灵活的表达式上。

　　不带任何选项的tcpdump，默认会抓取第一个网络接口，且只有将tcpdump进程终止才会停止抓包。

　　例如：

```
tcpdump -nn -i eth0 icmp
```

　　下面是tcpdump的基本用法说明。

## tcpdump选项

　　它的命令格式为：

```bash
tcpdump [ -DenNqvX ] [ -c count ] [ -F file ] [ -i interface ] [ -r file ]
        [ -s snaplen ] [ -w file ] [ expression ]

抓包选项：
-c：指定要抓取的包数量。注意，是最终要获取这么多个包。
    例如，指定"-c 10"将获取10个包，但可能已经处理了
    100个包，只不过只有10个包是满足条件的包。
-i interface：指定tcpdump需要监听的接口。若未指定该
    选项，将从系统接口列表中搜寻编号最小的已配置好的
    接口(不包括loopback接口，要抓取loopback接口使用
    tcpdump -i lo)，一旦找到第一个符合条件的接口，搜
    寻马上结束。可以使用'any'关键字表示所有网络接口。
-n：对地址以数字方式显式，否则显式为主机名，也就是说-n
    选项不做主机名解析。
-nn：除了-n的作用外，还把端口显示为数值，否则显示端口服
     务名。
-N：不打印出host的域名部分。例如tcpdump将会打印'nic'而
    不是'nic.ddn.mil'。
-P：指定要抓取的包是流入还是流出的包。可给定的值为"in"、
    "out"和"inout"，默认为"inout"。
-s len：设置tcpdump的数据包抓取长度为len，如果不设置默认
    将会是65535字节。对于要抓取的数据包较大时，长度设置不
    够可能会产生包截断，若出现包截断，输出行中会出现
    "[|proto]"的标志(proto实际会显示为协议名)。但是抓取
    len越长，包的处理时间越长，并且会减少tcpdump可缓存的
    数据包的数量，从而会导致数据包的丢失，所以在能抓取我们
    想要的包的前提下，抓取长度越小越好。

输出选项：
-e：输出的每行中都将包括数据链路层头部信息，例如源MAC和目标MAC。
-q：快速打印输出。即打印很少的协议相关信息，从而输出行都比较简短。
-X：输出包的头部数据，会以16进制和ASCII两种方式同时输出。
-XX：输出包的头部数据，会以16进制和ASCII两种方式同时输出，更详细。
-v：当分析和打印的时候，产生详细的输出。
-vv：产生比-v更详细的输出。
-vvv：产生比-vv更详细的输出。

其他功能性选项：
-D：列出可用于抓包的接口。将会列出接口的数值编号和接口名，
    它们都可以用于"-i"后。
-F：从文件中读取抓包的表达式。若使用该选项，则命令行中给
    定的其他表达式都将失效。
-w：将抓包数据输出到文件中而不是标准输出。可以同时配合
    "-G time"选项使得输出文件每time秒就自动切换到另一个
    文件。可通过"-r"选项载入这些文件以进行分析和打印。
-r：从给定的数据包文件中读取数据。使用"-"表示从标准输入中
    读取。
```

　　所以常用的选项也就这几个：

```
tcpdump -D
tcpdump -c num -i int -nn -XX -vvv
```

## tcpdump表达式

　　表达式用于筛选输出哪些类型的数据包，如果没有给定表达式，所有的数据包都将输出，否则只输出表达式为true的包。在表达式中出现的shell元字符建议使用单引号包围。

　　tcpdump的表达式由一个或多个”单元”组成，每个单元一般包含ID的修饰符和一个ID(数字或名称)。有三种修饰符：

　　(1).type：指定ID的类型。

　　可以给定的值有host/net/port/portrange。例如”host foo”，”net 128.3”，”port 20”，”portrange 6000-6008”。默认的type为host。

　　(2).dir：指定ID的方向。

　　可以给定的值包括src/dst/src or dst/src and dst，默认为src or dst。例如，”src  foo”表示源主机为foo的数据包，”dst net 128.3”表示目标网络为128.3的数据包，”src or dst port  22”表示源或目的端口为22的数据包。

　　(3).proto：通过给定协议限定匹配的数据包类型。

　　常用的协议有tcp/udp/arp/ip/ether/icmp等，若未给定协议类型，则匹配所有可能的类型。例如”tcp port 21”，”udp portrange 7000-7009”。

　　所以，一个基本的表达式单元格式为”proto dir type ID”

　　​![](https://www.junmajinlong.com/img/linux/733013-20180621121410609-1741572810.png)[https://www.junmajinlong.com/img/linux/733013-20180621121410609-1741572810.png](https://www.junmajinlong.com/img/linux/733013-20180621121410609-1741572810.png)

　　除了使用修饰符和ID组成的表达式单元，还有关键字表达式单元：gateway，broadcast，less，greater以及算术表达式。

　　表达式单元之间可以使用操作符`and / && / or / || / not / !`​进行连接，从而组成复杂的条件表达式。如”host foo and not port ftp and not port  ftp-data”，这表示筛选的数据包要满足”主机为foo且端口不是ftp(端口21)和ftp-data(端口20)的包”，常用端口和名字的对应关系可在linux系统中的/etc/service文件中找到。

　　另外，同样的修饰符可省略，如`tcp dst port ftp or ftp-data or domain`​与`tcp dst port ftp or tcp dst port ftp-data or tcp dst port domain`​意义相同，都表示包的协议为tcp且目的端口为ftp或ftp-data或domain(端口53)。

　　使用括号`()`​可以改变表达式的优先级，但需要注意的是括号会被shell解释，所以应该使用反斜线`\`​转义为`\(\)`​，在需要的时候，还需要包围在引号中。

## tcpdump示例

　　注意，tcpdump只能抓取**流经本机**的数据包。

　　 **(1).默认启动**

```
tcpdump
```

　　默认情况下，直接启动tcpdump将监视第一个网络接口(非lo口)上所有流通的数据包。这样抓取的结果会非常多，滚动非常快。

　　 **(2).监视指定网络接口的数据包**

```
tcpdump -i eth1
```

　　如果不指定网卡，默认tcpdump只会监视第一个网络接口，如eth0。

　　 **(3).监视指定主机的数据包，例如所有进入或离开longshuai的数据包**

```
tcpdump host longshuai
```

　　 **(4).打印**​**​`helios<-->hot`​**​**或**​**​`helios<-->ace`​**​**之间通信的数据包**

```
tcpdump host helios and \( hot or ace \)
```

　　 **(5).打印ace与任何其他主机之间通信的IP数据包,但不包括与helios之间的数据包**

```
tcpdump ip host ace and not helios
```

　　 **(6).截获主机hostname发送的所有数据**

```
tcpdump src host hostname
```

　　 **(7).监视所有发送到主机hostname的数据包**

```
tcpdump dst host hostname
```

　　 **(8).监视指定主机和端口的数据包**

```
tcpdump tcp port 22 and host hostname
```

　　 **(9).对本机的udp 123端口进行监视(123为ntp的服务端口)**

```
tcpdump udp port 123
```

　　 **(10).监视指定网络的数据包，如本机与192.168网段通信的数据包，”-c 10”表示只抓取10个包**

```
tcpdump -c 10 net 192.168
```

　　 **(11).打印所有通过网关snup的ftp数据包(注意,表达式被单引号括起来了,这可以防止shell对其中的括号进行错误解析)**

```
shell> tcpdump 'gateway snup and (port ftp or ftp-data)'
```

　　 **(12).抓取ping包**

```
[root@server2 ~]# tcpdump -c 5 -nn -i eth0 icmp 

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
12:11:23.273638 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16422, seq 10, length 64
12:11:23.273666 IP 192.168.100.62 > 192.168.100.70: ICMP echo reply, id 16422, seq 10, length 64
12:11:24.356915 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16422, seq 11, length 64
12:11:24.356936 IP 192.168.100.62 > 192.168.100.70: ICMP echo reply, id 16422, seq 11, length 64
12:11:25.440887 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16422, seq 12, length 64
5 packets captured
6 packets received by filter
0 packets dropped by kernel
```

　　如果明确要抓取主机为192.168.100.70对本机的ping，则使用and操作符。

```
[root@server2 ~]# tcpdump -c 5 -nn -i eth0 icmp and src 192.168.100.62

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
12:09:29.957132 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16166, seq 1, length 64
12:09:31.041035 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16166, seq 2, length 64
12:09:32.124562 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16166, seq 3, length 64
12:09:33.208514 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16166, seq 4, length 64
12:09:34.292222 IP 192.168.100.70 > 192.168.100.62: ICMP echo request, id 16166, seq 5, length 64
5 packets captured
5 packets received by filter
0 packets dropped by kernel
```

　　注意不能直接写`icmp src 192.168.100.70`​，因为icmp协议不支持直接应用host这个type。

　　 **(13).抓取到本机22端口包**

```
[root@server2 ~]# tcpdump -c 10 -nn -i eth0 tcp dst port 22  

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
12:06:57.574293 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 535528834, win 2053, length 0
12:06:57.629125 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 193, win 2052, length 0
12:06:57.684688 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 385, win 2051, length 0
12:06:57.738977 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 577, win 2050, length 0
12:06:57.794305 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 769, win 2050, length 0
12:06:57.848720 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 961, win 2049, length 0
12:06:57.904057 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 1153, win 2048, length 0
12:06:57.958477 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 1345, win 2047, length 0
12:06:58.014338 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 1537, win 2053, length 0
12:06:58.069361 IP 192.168.100.1.5788 > 192.168.100.62.22: Flags [.], ack 1729, win 2052, length 0
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

　　 **(14).解析包数据**

```
[root@server2 ~]# tcpdump -c 2 -q -XX -vvv -nn -i eth0 tcp dst port 22
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
12:15:54.788812 IP (tos 0x0, ttl 64, id 19303, offset 0, flags [DF], proto TCP (6), length 40)
    192.168.100.1.5788 > 192.168.100.62.22: tcp 0
        0x0000:  000c 2908 9234 0050 56c0 0008 0800 4500  ..)..4.PV.....E.
        0x0010:  0028 4b67 4000 4006 a5d8 c0a8 6401 c0a8  .(Kg@.@.....d...
        0x0020:  643e 169c 0016 2426 5fd6 1fec 2b62 5010  d>....$&_...+bP.
        0x0030:  0803 7844 0000 0000 0000 0000            ..xD........
12:15:54.842641 IP (tos 0x0, ttl 64, id 19304, offset 0, flags [DF], proto TCP (6), length 40)
    192.168.100.1.5788 > 192.168.100.62.22: tcp 0
        0x0000:  000c 2908 9234 0050 56c0 0008 0800 4500  ..)..4.PV.....E.
        0x0010:  0028 4b68 4000 4006 a5d7 c0a8 6401 c0a8  .(Kh@.@.....d...
        0x0020:  643e 169c 0016 2426 5fd6 1fec 2d62 5010  d>....$&_...-bP.
        0x0030:  0801 7646 0000 0000 0000 0000            ..vF........
2 packets captured
2 packets received by filter
0 packets dropped by kernel
```

　　总的来说，tcpdump对基本的数据包抓取方法还是较简单的。只要掌握有限的几个选项(`-nn -XX -vvv -i -c -q`​)，再组合表达式即可。

　　文章作者: [骏马金龙](https://www.junmajinlong.com)

　　文章链接: [https://junmajinlong.github.io/linux/tcpdump_basic_usage/](https://junmajinlong.github.io/linux/tcpdump_basic_usage/)

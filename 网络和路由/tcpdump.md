#network 

`tcpdump` 是一个命令行抓包工具，允许抓取和分析经过系统的流量数据包。  
`tcpdump` 是一款强大的工具，支持多种选项和过滤规则，适用场景十分广泛。由于它是命令行工具，因此适用于在远程服务器或者没有图形界面的设备中收集数据包以便于事后分析。

### 1、安装tcpdump

`yum install tcpdump`
**`注：`**`tcpdump依赖libpcap包，该库文件用于捕获网络数据包。`

### 2、用tcpdump抓包

##### 2.1、tcpdump -D命令列出可以抓包的网络接口

```bash
[root@192-168-188-155 ~]# tcpdump -D
1.nflog (Linux netfilter log (NFLOG) interface)
2.nfqueue (Linux netfilter queue (NFQUEUE) interface)
3.ens192
4.any (Pseudo-device that captures on all interfaces)
5.lo
```

##### 2.2、对 any 接口进行抓包。-c选项可以限制tcpdump抓包的数量

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
13:44:38.787141 IP 155.ssh > 192.168.149.80.52125: Flags [P.], seq 3003480388:3003480628, ack 3961612848, win 265, options [nop,nop,TS val 558985376 ecr 1389975002], length 240
13:44:38.787542 IP 192.168.149.80.52125 > 155.ssh: Flags [.], ack 240, win 2079, options [nop,nop,TS val 1389975016 ecr 558985363], length 0
13:44:38.787576 IP 155.55339 > public1.114dns.com.domain: 46628+ PTR? 80.149.168.192.in-addr.arpa. (45)
13:44:42.652354 IP 192.168.149.80.52125 > 155.ssh: Flags [P.], seq 1:113, ack 240, win 2079, options [nop,nop,TS val 1389978880 ecr 558985363], length 112
13:44:42.691891 IP 155.ssh > 192.168.149.80.52125: Flags [.], ack 113, win 265, options [nop,nop,TS val 558989281 ecr 1389978880], length 0
13:44:43.792694 IP 155.55339 > public1.114dns.com.domain: 46628+ PTR? 80.149.168.192.in-addr.arpa. (45)
13:44:48.800101 IP 155.50787 > public1.114dns.com.domain: 12945+ PTR? 114.114.114.114.in-addr.arpa. (46)
13:44:48.800219 IP 155.ssh > 192.168.149.80.52125: Flags [P.], seq 240:656, ack 113, win 265, options [nop,nop,TS val 558995389 ecr 1389978880], length 416
13:44:48.811569 IP public1.114dns.com.domain > 155.50787: 12945 1/0/0 PTR public1.114dns.com. (78)
13:44:48.812713 IP 155.ssh > 192.168.149.80.52125: Flags [P.], seq 656:1616, ack 113, win 265, options [nop,nop,TS val 558995401 ecr 1389978880], length 960
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

##### 2.3、用-n选项显示IP地址，-nn选项显示端口号

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
13:47:09.373152 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 3003483044:3003483284, ack 3961613536, win 265, options [nop,nop,TS val 559135962 ecr 1390125588], length 240
13:47:09.373592 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 240:512, ack 1, win 265, options [nop,nop,TS val 559135962 ecr 1390125588], length 272
13:47:09.373669 IP 192.168.149.80.52125 > 192.168.188.155.22: Flags [.], ack 240, win 2076, options [nop,nop,TS val 1390125605 ecr 559135947], length 0
13:47:09.373805 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 512:928, ack 1, win 265, options [nop,nop,TS val 559135962 ecr 1390125605], length 416
13:47:09.374020 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 928:1184, ack 1, win 265, options [nop,nop,TS val 559135963 ecr 1390125605], length 256
13:47:09.374365 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1184:1440, ack 1, win 265, options [nop,nop,TS val 559135963 ecr 1390125605], length 256
13:47:09.374399 IP 192.168.149.80.52125 > 192.168.188.155.22: Flags [.], ack 1184, win 2081, options [nop,nop,TS val 1390125606 ecr 559135962], length 0
13:47:09.374597 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1440:1856, ack 1, win 265, options [nop,nop,TS val 559135963 ecr 1390125606], length 416
13:47:09.374879 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1856:2112, ack 1, win 265, options [nop,nop,TS val 559135964 ecr 1390125606], length 256
13:47:09.375066 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 2112:2368, ack 1, win 265, options [nop,nop,TS val 559135964 ecr 1390125606], length 256
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

### 3、理解抓取的报文

tcpdump能够抓取并解码多种协议类型的数据报文，如TCP、UDP、ICMP等。

具体分析TCP类型的数据报文

```bash
13:47:09.373152 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 3003483044:3003483284, ack 3961613536, win 265, options [nop,nop,TS val 559135962 ecr 1390125588], length 240
```

`13:47:09.373152` 是该报文被抓取的系统本地时间超  
`IP` 是网络层协议类型，这里是IPv4，如果是IPv6协议，该字段值是IP6  
`192.168.188.155.22` 是源IP地址和端口号  
`192.168.149.80.52125` 是目的IP地址和端口号  
`Flags [P.]` TCP报文标记段，该字段通常取值如下：  
      S SYN Connection Start  
      F FIN Connection Finish  
      P PUSH Data Push  
      R RST Connection Reset  
      . ACK Acknowledgment  
      该字段也可以是这些值的组合，例如 \[P.\] 代表 PUSH-ACK数据包  
`seq` 该数据包中数据的序列号。对于抓取的第一个数据包，该字段值是一个绝对数字，后续包使用相对数值，以便更容易查询跟踪。例如此处 seq 3003483044:3003483284 代表该数据包包含该数据流的第3003483044到3003483284字节。  
`ack` 该数据包是数据发送方，ack值为1，在数据接收方，该字段代表数据流上的下一个预期字节数据  
`win 265` 表示接受窗口大小  
`length 240` 表示数据包有效载荷字节长度

### 4、过滤数据包
##### 4.1、协议

在命令中执行协议便可以按照协议类型筛选数据包，例如只抓取ICMP报文。

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:33:29.692055 IP 54.204.39.132 > 155: ICMP echo reply, id 6598, seq 3, length 64
14:33:30.438041 IP 155 > 54.204.39.132: ICMP echo request, id 6598, seq 4, length 64
14:33:30.701486 IP 54.204.39.132 > 155: ICMP echo reply, id 6598, seq 4, length 64
14:33:31.439503 IP 155 > 54.204.39.132: ICMP echo request, id 6598, seq 5, length 64
14:33:31.694941 IP 54.204.39.132 > 155: ICMP echo reply, id 6598, seq 5, length 64
14:33:32.441008 IP 155 > 54.204.39.132: ICMP echo request, id 6598, seq 6, length 64
14:33:32.703821 IP 54.204.39.132 > 155: ICMP echo reply, id 6598, seq 6, length 64
14:33:33.441973 IP 155 > 54.204.39.132: ICMP echo request, id 6598, seq 7, length 64
14:33:33.696855 IP 54.204.39.132 > 155: ICMP echo reply, id 6598, seq 7, length 64
14:33:34.442966 IP 155 > 54.204.39.132: ICMP echo request, id 6598, seq 8, length 64
10 packets captured
21 packets received by filter
0 packets dropped by kernel
```

##### 4.2、主机

用host参数只抓取和特定主机相关的数据包。

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn host 192.168.212.229
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:38:03.094394 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 2687507850:2687507919, ack 146170312, win 545, options [nop,nop,TS val 107732754 ecr 562180490], length 69
14:38:03.094983 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1:454, ack 69, win 243, options [nop,nop,TS val 562189684 ecr 107732754], length 453
14:38:03.095529 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 454, win 568, options [nop,nop,TS val 107732755 ecr 562189684], length 0
14:38:03.623210 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 69:138, ack 454, win 568, options [nop,nop,TS val 107733283 ecr 562189684], length 69
14:38:03.623789 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 454:907, ack 138, win 243, options [nop,nop,TS val 562190212 ecr 107733283], length 453
14:38:03.624349 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 907, win 591, options [nop,nop,TS val 107733284 ecr 562190212], length 0
14:38:04.285987 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 138:207, ack 907, win 591, options [nop,nop,TS val 107733946 ecr 562190212], length 69
14:38:04.286512 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 907:1360, ack 207, win 243, options [nop,nop,TS val 562190875 ecr 107733946], length 453
14:38:04.286972 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 1360, win 613, options [nop,nop,TS val 107733947 ecr 562190875], length 0
14:38:04.767128 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 207:276, ack 1360, win 613, options [nop,nop,TS val 107734427 ecr 562190875], length 69
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

##### 4.3、端口号

用port参数来过滤端口筛选数据包

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn port 3306
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:40:32.948120 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 2687508195:2687508264, ack 146172577, win 658, options [nop,nop,TS val 107882612 ecr 562191900], length 69
14:40:32.948528 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1:454, ack 69, win 243, options [nop,nop,TS val 562339537 ecr 107882612], length 453
14:40:32.948929 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 454, win 681, options [nop,nop,TS val 107882613 ecr 562339537], length 0
14:40:33.470752 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 69:138, ack 454, win 681, options [nop,nop,TS val 107883135 ecr 562339537], length 69
14:40:33.471053 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 454:907, ack 138, win 243, options [nop,nop,TS val 562340060 ecr 107883135], length 453
14:40:33.471484 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 907, win 704, options [nop,nop,TS val 107883136 ecr 562340060], length 0
14:40:37.622476 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 138:207, ack 907, win 704, options [nop,nop,TS val 107887287 ecr 562340060], length 69
14:40:37.622749 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 907:1360, ack 207, win 243, options [nop,nop,TS val 562344211 ecr 107887287], length 453
14:40:37.623139 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 1360, win 726, options [nop,nop,TS val 107887287 ecr 562344211], length 0
14:40:38.170642 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 207:276, ack 1360, win 726, options [nop,nop,TS val 107887835 ecr 562344211], length 69
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

##### 4.4、源IP地址和目的IP地址

筛选源IP地址使用 src 参数 筛选目的IP地址使用 dst 参数

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn src 192.168.188.155
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:44:37.599113 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 3003606548:3003606788, ack 3961634656, win 275, options [nop,nop,TS val 562584188 ecr 1393573897], length 240
14:44:37.599810 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 240:512, ack 1, win 275, options [nop,nop,TS val 562584188 ecr 1393573908], length 272
14:44:37.600126 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 512:768, ack 1, win 275, options [nop,nop,TS val 562584189 ecr 1393573908], length 256
14:44:37.600324 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 768:1024, ack 1, win 275, options [nop,nop,TS val 562584189 ecr 1393573908], length 256
14:44:37.600547 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1024:1280, ack 1, win 275, options [nop,nop,TSval 562584189 ecr 1393573908], length 256
14:44:37.600750 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1280:1536, ack 1, win 275, options [nop,nop,TS val 562584189 ecr 1393573908], length 256
14:44:37.601009 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1536:1792, ack 1, win 275, options [nop,nop,TS val 562584190 ecr 1393573909], length 256
14:44:37.601161 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 1792:2048, ack 1, win 275, options [nop,nop,TS val 562584190 ecr 1393573909], length 256
14:44:37.601354 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 2048:2304, ack 1, win 275, options [nop,nop,TS val 562584190 ecr 1393573909], length 256
14:44:37.601580 IP 192.168.188.155.22 > 192.168.149.80.52125: Flags [P.], seq 2304:2560, ack 1, win 275, options [nop,nop,TS val 562584190 ecr 1393573909], length 256
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

##### 4.5、多条件筛选
可以使用and和or逻辑操作符来创建过滤规则。

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn src 192.168.188.155 and port 3306
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:55:15.432404 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 146180731:146181184, ack 2687509506, win 243, options [nop,nop,TS val 563222021 ecr 108765119], length 453
14:55:15.977604 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 453:906, ack 70, win 243, options [nop,nop,TS val 563222566 ecr 108765666], length 453
14:55:16.340620 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 906:1359, ack 139, win 243, options [nop,nop,TS val 563222929 ecr 108766029], length 453
14:55:16.800256 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1359:1812, ack 208, win 243, options [nop,nop,TS val 563223389 ecr 108766488], length 453
14:55:28.975813 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1812:2265, ack 277, win 243, options [nop,nop,TS val 563235564 ecr 108778665], length 453
14:55:29.962688 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 2265:2718, ack 346, win 243, options [nop,nop,TS val 563236551 ecr 108779651], length 453
14:55:30.346075 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 2718:3171, ack 415, win 243, options [nop,nop,TS val 563236935 ecr 108780035], length 453
14:55:30.709520 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 3171:3624, ack 484, win 243, options [nop,nop,TS val 563237298 ecr 108780398], length 453
14:55:30.977005 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 3624:4077, ack 553, win 243, options [nop,nop,TS val 563237566 ecr 108780666], length 453
14:55:31.271016 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 4077:4530, ack 622, win 243, options [nop,nop,TS val 563237860 ecr 108780960], length 453
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

### 5、保存抓包数据

使用 -w 参数保存数据包而不是在屏幕上显示出抓取的数据包。

```bash
[root@192-168-188-155 ~]# tcpdump -i any -c 10 -nn port 3306 -w database.pcap
tcpdump: listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
10 packets captured
11 packets received by filter
0 packets dropped by kernel
```

使用 -r 参数读取该文件

```bash
[root@192-168-188-155 ~]# tcpdump -nn -r database.pcap
reading from file database.pcap, link-type LINUX_SLL (Linux cooked)
15:41:29.856764 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 2687514958:2687515027, ack 146225772, win 1424, options [nop,nop,TS val 111539619 ecr 565526732], length 69
15:41:29.862172 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1:902, ack 69, win 243, options [nop,nop,TS val 565996451 ecr 111539619], length 901
15:41:29.862931 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 902, win 1424, options [nop,nop,TS val 111539625 ecr 565996451], length 0
15:41:30.727853 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 69:138, ack 902, win 1424, options [nop,nop,TS val 111540490 ecr 565996451], length 69
15:41:30.728423 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 902:1803, ack 138, win 243, options [nop,nop,TS val 565997317 ecr 111540490], length 901
15:41:30.728958 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 1803, win 1424, options [nop,nop,TS val 111540491 ecr 565997317], length 0
15:41:31.348066 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 138:207, ack 1803, win 1424, options [nop,nop,TS val 111541110 ecr 565997317], length 69
15:41:31.348694 IP 192.168.188.155.3306 > 192.168.212.229.40844: Flags [P.], seq 1803:2704, ack 207, win 243, options [nop,nop,TS val 565997937 ecr 111541110], length 901
15:41:31.349299 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [.], ack 2704, win 1424, options [nop,nop,TS val 111541111 ecr 565997937], length 0
15:41:31.916164 IP 192.168.212.229.40844 > 192.168.188.155.3306: Flags [P.], seq 207:276, ack 2704, win 1424, options [nop,nop,TS val 111541678 ecr 565997937], length 69
```


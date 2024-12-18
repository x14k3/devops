# arping

　　通过发送ARP协议报文测试网络

　　**arping命令** 是用于发送arp请求到一个相邻主机的工具，arping使用arp数据包，通过ping命令检查设备上的硬件地址。能够测试一个ip地址是否是在网络上已经被使用，并能够获取更多设备信息。功能类似于ping。

### 语法

```
arping(选项)(参数)
```

### 选项

```bash
-A  # 与-U参数类似，但是使用的是ARP REPLY包而非ARP REQUEST包。
-b  # 发送以太网广播帧，arping在开始时使用广播地址，在收到回复后使用unicast单播地址。
-c  # 发送指定的count个ARP REQUEST包后停止。如果指定了-w参数，则会等待相同数量的ARP REPLY包，直到超时为止。
-D  # 重复地址探测模式，即，Duplicate address detection mode (DAD)，用来检测有没有IP地址冲突，如果没有IP冲突则返回0。
-f  # 收到第一个响应包后退出。
-h  # 显示帮助页。
-I  # 用来发送ARP REQUEST包的网络设备的名称。
-q  # quite模式，不显示输出。
-U  # 无理由的（强制的）ARP模式去更新别的主机上的ARP CACHE列表中的本机的信息，不需要响应。
-V  # 显示arping的版本号。
-w  # 指定一个超时时间，单位为秒，arping在到达指定时间后退出，无论期间发送或接收了多少包。在这种情况下，arping在发送完指定的count（-c）个包后并不会停止，而是等待到超时或发送的count个包都进行了回应后才会退出。
-s  # 设置发送ARP包的IP资源地址，如果为空，则按如下方式处理：
	# 1、DAD模式（-D）设置为0.0.0.0；
	# 2、Unsolicited模式（-U）设置为目标地址；
	# 3、其它方式，从路由表计算。
```

### 参数

　　目的主机：指定发送ARP报文的目的主机。

### 实例

##### **1、探测重复地址**

　　-D 可以探测是否有重复ip地址，只有在同网段主机上才有用，在和被测ip不同网断无效。

```bash
[root@edge_auto_6 vpp]# arping -D -c 1 -I ens160 192.168.0.104
ARPING 192.168.0.104 from 0.0.0.0 ens160
Sent 1 probes (1 broadcast(s))
Received 0 response(s) #0表示此ip地址空闲
[root@edge_auto_6 vpp]# arping -D -c 1 -I ens160 192.168.0.100
ARPING 192.168.0.100 from 0.0.0.0 ens160
Unicast reply from 192.168.0.100 [00:0C:29:63:94:1C]  1.144ms
Sent 1 probes (1 broadcast(s))
Received 1 response(s) ##1表示此ip地址已经被使用

```

##### **2、更新邻近主机arp缓存**

　　arping功能只更新对端设备的arp缓存表，本地arp缓存表不会更新。 但是ping需要更新,因为需要发送icmp报文，需要封装DMac地址。

```bash
#本段设备192.168.0.103,发起arping后，192.168.0.100的arp并没有学习。
[root@edge_auto_6 vpp]# arp
Address                  HWtype  HWaddress           Flags Mask            Iface
gateway                  ether   b8:f8:83:9f:cc:95   C                     ens160
10.0.0.1                         (incomplete)                              tap0
192.168.0.101            ether   00:2b:67:fe:d4:f8   C                     ens160
[root@edge_auto_6 vpp]# arping  -c 2 -I ens160 192.168.0.100
ARPING 192.168.0.100 from 192.168.0.103 ens160
Unicast reply from 192.168.0.100 [00:0C:29:63:94:1C]  1.489ms
Unicast reply from 192.168.0.100 [00:0C:29:63:94:1C]  1.041ms
Sent 2 probes (1 broadcast(s))
Received 2 response(s)
[root@edge_auto_6 vpp]# arp  #本端设备并没有192.168.0.100的arp表
Address                  HWtype  HWaddress           Flags Mask            Iface
gateway                  ether   b8:f8:83:9f:cc:95   C                     ens160
10.0.0.1                         (incomplete)                              tap0
192.168.0.101            ether   00:2b:67:fe:d4:f8   C                     ens160
###对端设备192.168.0.100，已经学习到192.168.0.103的arp表项
[root@edge_auto_6 vpp]# arp
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.101            ether   00:2b:67:fe:d4:f8   C                     ens160
gateway                  ether   b8:f8:83:9f:cc:95   C                     ens160
10.0.0.1                         (incomplete)                              tap0
192.168.0.103            ether   00:0c:29:17:0a:30   C                     ens160
```

#### **vpp arping功能**

　　vpp arping命令行如下：

```bash
arping [gratuitous] {addr} {interface} [interval {sec}] [repeat {cnt}]

```

> 参数说明：
>
> gratuitous：表示发送免费arp。
>
>  interval ：发送时间间隔。
>
> repeat ： 发送数量。

　　下面来学习一下基本的使用，和查询arp缓存表情况：

```bash
# 1、在vpp1上发送免费arp，在vpp2上并不会生产arp表
learning_vpp1# arping gratuitous 192.168.100.1  GigabitEthernet13/0/0 repeat 1
Sending 1 GARP to 192.168.100.1
在vpp3上并arp表。
learning_vpp2# show ip neighbors GigabitEthernet13/0/0
# 2、在vpp1上发送arp，双方都会生成arp表
learning_vpp1# arping  192.168.100.2  GigabitEthernet13/0/0 repeat 1        
Sending 1 ARP Request to 192.168.100.2
Received 1 ARP Replies from 00:0c:29:17:0a:44 (192.168.100.2)
learning_vpp1# show ip neighbors GigabitEthernet13/0/0
    Time                       IP                    Flags      Ethernet              Interface   
    602.3858              192.168.100.2                D    00:0c:29:17:0a:44 GigabitEthernet13/0/0
#vpp2能查询到192.168.100.1的arp表
earning_vpp2# show ip neighbors GigabitEthernet13/0/0
    Time                       IP                    Flags      Ethernet              Interface   
    563.5455              192.168.100.1                D    00:0c:29:63:94:30 GigabitEthernet13/0/0
# 3、更新arp1接口的mac地址，此时再发送免费arp
 learning_vpp1# set interface mac address GigabitEthernet13/0/0 00:0c:29:aa:cc:bb
learning_vpp1# arping gratuitous 192.168.100.1  GigabitEthernet13/0/0 repeat 1  
Sending 1 GARP to 192.168.100.1
#vpp1发送免费arp前，查询vpp2 arp缓存表
learning_vpp2# show ip neighbors GigabitEthernet13/0/0
    Time                       IP                    Flags      Ethernet              Interface   
    563.5455              192.168.100.1                D    00:0c:29:63:94:30 GigabitEthernet13/0/0
#vpp1发送免费arp后，查询vpp2 arp缓存表，地址已经更新。
learning_vpp2# show ip neighbors GigabitEthernet13/0/0
    Time                       IP                    Flags      Ethernet              Interface   
    791.7851              192.168.100.1                D    00:0c:29:aa:cc:bb GigabitEthernet13/0/0

```

> 1、vpp的实现和内核有点差距，内核arping并不会在本地生成arp缓存表。
>
> 2、arping发送免费arp时，如果对端已经存在arp表，会更新arp表；如果不存在也不会生成arp表。

　　免费 ARP（Gratuitous ARP）包是一种特殊的 ARP 请求，它并非期待得到 IP 对应的 MAC 地址，而是当主机启动的时候，发送一个 Gratuitous ARP 请求，即请求自己的 IP 地址的 MAC 地址。

　　免费 ARP 报文与普通 ARP 请求报文的区别在于报文中的目标 IP 地址。普通 ARP 报文中的目标 IP 地址是其他主机的 IP 地址；而免费 ARP 的请求报文中，目标 IP 地址是自己的 IP 地址。

　　**免费 ARP 数据包有以下 3 个作用：**

　　1、该类型报文起到一个宣告作用。它以广播的形式将数据包发送出去，不需要得到回应，只为了告诉其他计算机自己的 IP 地址和 MAC 地址。

　　2、可用于检测 IP 地址冲突。当一台主机发送了免费 ARP 请求报文后，如果收到了 ARP 响应报文，则说明网络内已经存在使用该 IP 地址的主机。

　　3、可用于更新其他主机的 ARP 缓存表。如果该主机更换了网卡，而其他主机的 ARP 缓存表仍然保留着原来的 MAC 地址。这时，可以发送免费的 ARP 数据包。其他主机收到该数据包后，将更新 ARP 缓存表，将原来的 MAC 地址替换为新的 MAC 地址。

#### **trace流程**

　　1、arping流程

```javascript
 arping 192.168.100.2 GigabitEthernet13/0/0 repeat 1
Sending 1 ARP Request to 192.168.100.2
Received 1 ARP Replies from 00:0c:29:17:0a:44 (192.168.100.2)
```

　　vpp2 收到arp请求并回应

```javascript
learning_vpp# show trace 
------------------- Start of thread 0 vpp_main -------------------
Packet 1

05:41:57:776784: dpdk-input
  GigabitEthernet13/0/0 rx queue 0
  buffer 0x9b5f1: current data 0, length 60, buffer-pool 0, ref-count 1, totlen-nifb 0, trace handle 0x0
                  ext-hdr-valid 
                  l4-cksum-computed l4-cksum-correct 
  PKT MBUF: port 1, nb_segs 1, pkt_len 60
    buf_len 2176, data_len 60, ol_flags 0x0, data_off 128, phys_addr 0x7f0d7cc0
    packet_type 0x1 l2_len 0 l3_len 0 outer_l2_len 0 outer_l3_len 0
    rss 0x0 fdir.hi 0x0 fdir.lo 0x0
    Packet Types
      RTE_PTYPE_L2_ETHER (0x0001) Ethernet packet
  ARP: 00:0c:29:aa:cc:bb -> ff:ff:ff:ff:ff:ff
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:00:00:00:00:00/192.168.100.2
05:41:57:776811: ethernet-input
  frame: flags 0x1, hw-if-index 2, sw-if-index 2
  ARP: 00:0c:29:aa:cc:bb -> ff:ff:ff:ff:ff:ff
05:41:57:776826: arp-input
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:00:00:00:00:00/192.168.100.2
05:41:57:776831: arp-reply
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:00:00:00:00:00/192.168.100.2
05:41:57:776871: GigabitEthernet13/0/0-output
  GigabitEthernet13/0/0 
  ARP: 00:0c:29:17:0a:44 -> 00:0c:29:aa:cc:bb
  reply, type ethernet/IP4, address size 6/4
  00:0c:29:17:0a:44/192.168.100.2 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:41:57:776874: GigabitEthernet13/0/0-tx
  GigabitEthernet13/0/0 tx queue 0
  buffer 0x9b5f1: current data 0, length 60, buffer-pool 0, ref-count 1, totlen-nifb 0, trace handle 0x0
                  ext-hdr-valid 
                  l4-cksum-computed l4-cksum-correct l2-hdr-offset 0 l3-hdr-offset 14 
  PKT MBUF: port 1, nb_segs 1, pkt_len 60
    buf_len 2176, data_len 60, ol_flags 0x0, data_off 128, phys_addr 0x7f0d7cc0
    packet_type 0x1 l2_len 0 l3_len 0 outer_l2_len 0 outer_l3_len 0
    rss 0x0 fdir.hi 0x0 fdir.lo 0x0
    Packet Types
      RTE_PTYPE_L2_ETHER (0x0001) Ethernet packet
  ARP: 00:0c:29:17:0a:44 -> 00:0c:29:aa:cc:bb
  reply, type ethernet/IP4, address size 6/4
  00:0c:29:17:0a:44/192.168.100.2 -> 00:0c:29:aa:cc:bb/192.168.100.1
```

　　vpp1收到arp回应

```javascript
5:42:36:573647: dpdk-input
  GigabitEthernet13/0/0 rx queue 0
  buffer 0x9b666: current data 0, length 60, buffer-pool 0, ref-count 1, totlen-nifb 0, trace handle 0x2
                  ext-hdr-valid 
                  l4-cksum-computed l4-cksum-correct 
  PKT MBUF: port 1, nb_segs 1, pkt_len 60
    buf_len 2176, data_len 60, ol_flags 0x0, data_off 128, phys_addr 0x804d9a00
    packet_type 0x1 l2_len 0 l3_len 0 outer_l2_len 0 outer_l3_len 0
    rss 0x0 fdir.hi 0x0 fdir.lo 0x0
    Packet Types
      RTE_PTYPE_L2_ETHER (0x0001) Ethernet packet
  ARP: 00:0c:29:17:0a:44 -> 00:0c:29:aa:cc:bb
  reply, type ethernet/IP4, address size 6/4
  00:0c:29:17:0a:44/192.168.100.2 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:42:36:573707: ethernet-input
  frame: flags 0x1, hw-if-index 2, sw-if-index 2
  ARP: 00:0c:29:17:0a:44 -> 00:0c:29:aa:cc:bb
05:42:36:573722: arp-input
  reply, type ethernet/IP4, address size 6/4
  00:0c:29:17:0a:44/192.168.100.2 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:42:36:573729: arping-input
  sw-if-index: 2, opcode: reply, from 00:0c:29:17:0a:44 (192.168.100.2)
05:42:36:573732: arp-reply
  reply, type ethernet/IP4, address size 6/4
  00:0c:29:17:0a:44/192.168.100.2 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:42:36:573787: error-drop
  rx:GigabitEthernet13/0/0
05:42:36:573792: drop
  dpdk-input: no error
```

> arping 流程在报文发送前会使能arping-input节点，用于等待arp 回应报文的处理。vpp在这个处理是增加了一个arping的feature arc，在arp-input收到报文是回应报文时，检查arping arc是否有feature使能，使能就是送到arping-input节点处理后，再送到arp-reply节点处理（更新本地arp缓存表）后再丢弃。

　　2、免费arp场景

```bash
learning_vpp# arping gratuitous 192.168.100.1 GigabitEthernet13/0/0 repeat 1
Sending 1 GARP to 192.168.100.1
vpp2收到后，进行处理后丢弃
learning_vpp# show trace
------------------- Start of thread 0 vpp_main -------------------
Packet 1

05:47:48:968631: dpdk-input
  GigabitEthernet13/0/0 rx queue 0
  buffer 0x9b5a3: current data 0, length 60, buffer-pool 0, ref-count 1, totlen-nifb 0, trace handle 0x0
                  ext-hdr-valid 
                  l4-cksum-computed l4-cksum-correct 
  PKT MBUF: port 1, nb_segs 1, pkt_len 60
    buf_len 2176, data_len 60, ol_flags 0x0, data_off 128, phys_addr 0x7f0d6940
    packet_type 0x1 l2_len 0 l3_len 0 outer_l2_len 0 outer_l3_len 0
    rss 0x0 fdir.hi 0x0 fdir.lo 0x0
    Packet Types
      RTE_PTYPE_L2_ETHER (0x0001) Ethernet packet
  ARP: 00:0c:29:aa:cc:bb -> ff:ff:ff:ff:ff:ff
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:47:48:968652: ethernet-input
  frame: flags 0x1, hw-if-index 2, sw-if-index 2
  ARP: 00:0c:29:aa:cc:bb -> ff:ff:ff:ff:ff:ff
05:47:48:968666: arp-input
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:47:48:968670: arp-reply
  request, type ethernet/IP4, address size 6/4
  00:0c:29:aa:cc:bb/192.168.100.1 -> 00:0c:29:aa:cc:bb/192.168.100.1
05:47:48:968695: error-drop
  rx:GigabitEthernet13/0/0
05:47:48:968699: drop
  arp-reply: ARP request IP4 source address learned
```

> 免费arping流程只是将本段报文封装按照免费arp格式，封装后直接发送出去，不需要等待回应。

　　‍

　　‍

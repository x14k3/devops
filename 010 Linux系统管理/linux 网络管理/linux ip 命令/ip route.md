# ip route

ip route：用于管理静态路由表。

## 主路由表（Master Routing Table）

Linux  RPDB 系统使用一个主路由表作为索引，实现间接使用至多 256 个相互独立的路由表，并能支持至多 32768 条与路由表交互的规则。

主路由表是一个文件，位于 `/etc/iproute2/rt_tables`​ ，其是一个包含最多 256 条记录的列表。每条记录都由一个整数和一个名称组成，表示对一个实际路由表的索引。Linux 内核使用规则来选择要用到的路由表。

该文件的内容大概是下面这样：

```text
# 
# reserved values 
# 
255 local 
254 main 
253 default 
0 unspec 
# 
# local 
# 
#1 inr.ruhep
```

主路由表列出了当前主机中所有的路由表。在未进行修改的情况下，其中应包括下面这些表：

* local：本地和广播地址。该路由表由内核维护，用户无法向该表中添加任何条目
* main：由 `route`​ 或 `ip route`​ 管理（部分由内核管理），在不指定策略的时候会使用该表
* default：为后处理规则（post-processing rules）保留
* unspec：用于失效安全（failsafe），请勿修改和移除
* inr.ruhep：这行是个例子，告诉用户可以这样以 `<整数值 名称>`​ 的方式来设置路由表。

该文件中的记录数值并不需要是有序的。确保数字、名称唯一即可。用户可以随时修改该文件，且修改可以立即生效。系统不会对该文件做缓存，每当一个规则引用某个路由表时，系统都会读一次该文件。

# **ip route 命令格式说明**

```bash
Usage: ip route { list | flush } SELECTOR
       ip route save SELECTOR
       ip route restore
       ip route showdump
       ip route get ADDRESS [ from ADDRESS iif STRING ]
                            [ oif STRING ]  [ tos TOS ]
                            [ mark NUMBER ]
       ip route { add | del | change | append | replace } ROUTE
SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]
            [ table TABLE_ID ] [ proto RTPROTO ]
            [ type TYPE ] [ scope SCOPE ]
ROUTE := NODE_SPEC [ INFO_SPEC ]
NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]
             [ table TABLE_ID ] [ proto RTPROTO ]
             [ scope SCOPE ] [ metric METRIC ]
INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...
NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS
OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]
           [ rtt TIME ] [ rttvar TIME ] [reordering NUMBER ]
           [ window NUMBER ] [ cwnd NUMBER ] [ initcwnd NUMBER ]
           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]
           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]
           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]
           [ expires TIME ]
TYPE := { unicast | local | broadcast | multicast | throw |
          unreachable | prohibit | blackhole | nat }
TABLE_ID := [ local | main | default | all | NUMBER ]
SCOPE := [ host | link | global | NUMBER ]
NHFLAGS := [ onlink | pervasive ]
RTPROTO := [ kernel | boot | static | NUMBER ]
TIME := NUMBER[s|ms]
BOOL := [1|0]
FEATURES := ecn

```

# **ip route show**

该命令显示路由表的内容或按某些条件选择的路由

**option：**

* to SELECTOR (default)：仅从给定的目的地范围内选择路线。  SELECTOR由一个可选的修饰符（root  、match、exact）和一个前缀组成。  root PREFIX选择前缀不小于PREFIX的路由。  F.e.  根0/0选择整个路由表。   match PREFIX选择前缀不超过PREFIX的路由。 比如：   匹配10.0/16选择10.0/16、10/8和0/0，但不选择10.1/16和10.0.0/24。   精确的PREFIX（或仅PREFIX）选择具有此精确前缀的路由。  如果这两个选项都不存在，则ip假定根目录为0/0，即列出整个表。
* tos TOS：仅选择具有给定TOS的路线
* table TABLEID：显示此表中的路由。默认设置是显示主表。TABLEID可以是实表的ID，也可以是特殊值之一：

  * all：列出所有表
  * cache：转储路由缓存
* cloned：缓存列表克隆的路由，即由于某些路由属性（例如MTU）已更新而从其他路由动态分叉的路由。  实际上，它等效于表缓存。
* from SELECTOR：与to的语法相同，但它绑定的是源地址范围而不是目的地。请注意，from选项仅适用于克隆路由
* protocol RTPROTO：只列出该协议的路由
* scope SCOPE_VAL：仅列出具有此范围的路由
* type TYPE：仅列出该类型的路由
* dev NAME：仅列出通过此设备的路由
* via PREFIX：仅列出通过前缀选择的nexthop路由器的路由
* src PREFIX：仅列出具有按前缀选择的首选源地址的路由
* realms FROMREALM/TOREALM/REALMID：仅列出具有这些领域的路由。

```bash
ip route
#或：ip r
#或：ip route show
#或：ip route list	                    # 列出默认路由表，和下面这句相同：
#或：ip route show table main
ip route show [exact] 169.254.0.0/16	# 精准查看具体某一条路由
ip route show match 172.18	            # 模糊匹配某一条路由
ip route show src 172.18.16.0/20	    # 仅列出源地址前缀为172.18.16.0/20的路由
ip route show via 172.18.31.253	        # 仅列出通过前缀选择的为该ip的路由
ip -s route show cache 192.168.100.17	# 显示来自路由缓存的统计信息
ip route show table local
#或：ip route list table local	        # 查看本地路由表
```

在一个新安装的系统上，输出值应该和下面差不多：

```text
default via 192.168.10.10 dev eth0 
192.168.10.0/24 dev eth0 proto kernel scope link src 192.168.10.11
```

每条路由条目的含义都是：若没有与目的地地址更相符的路由，则使用本条路由。

第一行是  default 路由条目。"default" 会在没有找到更具体的路由（数据包目的地地址与路由条目更匹配）时使用。"via  192.168.10.10" 指的是网关 IP 地址为 192.168.10.10，"dev eth0" 指使用 eth0 接口。

第二行是通过  eth0 接口到达 192.168.10.0/24 网络的路由。"proto kernel"  说明该条路由是内核在系统网络接口配置阶段添加的，而不是由管理员手动添加或由路由协议动态添加的。 "scope link"  的意思是说该路由直接连接在当前主机上，即处于同一局域网内。"src" 是指会使用该路由条目的数据包应有的源地址，也就是意味着本机在该局域网内的  IP 地址被设置为了 192.168.10.11。

路由记录的格式通常都是这样的：

```text
<目的地> via <网关> dev <接口> proto <协议> src <源地址> <附加信息>
```

​`<目的地>`​：目的地网络或主机，可以是具体的 IP 地址（如 `192.168.1.1`​）、网络地址 （如`192.168.1.0/24`​）或 default 等。default 会在没有其他符合的路由条目时使用；

​`via <网关>`​：可选字段，指的是到达该目的地需要使用的网关的 IP 地址。发往这个路由条目对应的目的地的数据包，都会把这个网关设置为下一跳，经由此发往最终目的地；

​`dev <接口>`​：要发往本条目对应目的地时所需要使用的网络接口（设备）；

​`proto <协议>`​：添加本条条目的协议。常见的值有：`kernel`​（本条目由内核添加）、`static`​（手动添加）、`dhcp`​（通过 DHCP 添加）、`boot`​ （在启动时添加）、`redirect`​ （由 ICMP 重定向添加）。此外，该值还可以是 `bgp`​、`ospf`​ 这类动态路由协议。该值可能是整数值或者一个字符串值，字符串值都可以在 `/etc/iproute2/rt_protos`​ 中找到；

​`src <源地址>`​：在使用本条路由，向目的地发送数据包时所需采用的 IP 地址；

​`<附加信息>`​ 代表多个可选项，常见的有：

* ​`scope <scope>`​：定义这条路由的范围。`global`​ 表示有网关的单播（unicast）路由，`link`​ 表示直连的单播或广播（broadcast）路由，`host`​ 表示本地（local）路由。该值可能是一个整数值或者是字符串值，字符串值应该能在 `/etc/iproute2/rt_scopes`​ 中找到
* ​`metric <整数>`​：表示路由的优先级，数字越小优先级越高。最小值为 0 ，最大值为 65535
* ​`table <表名/数字>`​：如果一条路由不属于 main 表，则会在这里指出该路由所属的路由表

路由记录还可以有个表示路由类型的前缀，该字段能说明路由用途以及特性。类型有下面这些：

1. unicast（单播）：标准类型，表示把数据发往一个特定的目的地 IP 地址。通常省略不显示；
2. unreachable（不可达）：目的地不可达。发往该地址的数据包会被丢弃，ICMP 会返回 `host unreachable`​，发送代码会报错 `EHOSTUNREACH`​ ；
3. blackhole（黑洞）：目的地不可达，数据包会被无声丢弃（discarded silently），发送代码会报错 `EINVAL`​ ；
4. prohabit（禁止）：目的地不可达，数据包会被丢弃，ICMP 会返回 `communication administratively prohibited`​。发送代码会报错 `EACCES`​；
5. local（本地）：目的地是当前主机，数据包会回环发送；
6. broadcast（广播）：目的地是广播地址，数据包作为链路广播发送，通常是向本地网络广播；
7. throw（抛弃）：这是个特殊路由，如果策略规则选择了该路由的路由表，则系统会装作是没有找到对应路由。ICMP 会返回 `net unreachable`​，发送代码会报错 `ENETUNREACH`​ ；
8. nat（网络地址转换）：该路由已在 2.6 内核后停止支持。这是个特殊的 NAT 路由。目的地地址是假地址（外部地址），需要在转发前转换为真实（内部）地址；
9. anycast（任播）：尚未实现。目的地是本主机的 `anycast`​ 地址。和 `local`​ 只有一个区别：该地址不能被用于任何数据包的源地址；
10. multicast（多播）：用于多播路由的特殊路由。不会在普通的路由表中出现。

‍

‍

‍

# **ip route add/change/replace**

**option：**

* to TYPE PREFIX  (default)：路由的目标前缀。如果省略TYPE，则ip采用unicast类型。上面列出了其他类型的值。前缀是一个IP或IPv6地址，后跟斜杠和前缀长度。如果前缀的长度丢失，ip将采用全长主机路由。还有一个特殊的前缀默认值-相当于IP  0/0或IPv6:：/0。
* tos TOS：服务类型（TOS）密钥。这个密钥没有相关的掩码，最长的匹配被理解为：首先，比较路由和包的TOS。如果它们不相等，则分组仍然可以匹配具有零TOS的路由。TOS是8位十六进制数或`/etc/iproute2/rt_dsfield`​中的标识符。
* metric ：跳数，该条路由记录的质量，一般情况下，如果有多条到达相同目的地的路由记录，路由器会采用metric值小的那条路由
* table TABLEID：要将此路由添加到的表。TABLEID可以是文件`/etc/iproute2/rt_tables`​中的数字或字符串。如果省略此参数，ip将采用主表，但本地、广播和nat路由除外，默认情况下，这些路由将放入本地表中
* dev NAME：输出设备名称
* via ADDRESS：下一跳路由器的地址。  实际上，此字段的含义取决于路由类型。  对于普通的单播路由，它要么是真正的下一跳路由器，要么是以BSD兼容模式安装的直接路由，它可以是接口的本地地址。  对于NAT路由，它是已转换IP目标块的第一个地址
* src ADDRESS：发送到路由前缀所覆盖的目的地时首选的源地址
* realm REALMID：此路由被分配到的领域。REALMID可以是`/etc/iproute2/rt_realms`​文件中的数字或字符串。
* mtu  MTU/mtu lock MTU：到达目的地的路径上的MTU。  如果未使用修饰符锁定，则由于路径MTU发现，内核可能会更新MTU。   如果使用了修饰符锁定，则将不尝试任何路径MTU发现，在IPv4情况下，所有数据包将在没有DF位的情况下发送，或者将其分片到IPv6的MTU
* window NUMBER：TCP播发到这些目的地的最大窗口，以字节为单位。它限制了允许TCP对等方发送给我们的最大数据突发
* rtt TIME：初始RTT（“往返时间”）估算值。  如果未指定后缀，则这些单位是直接传递到路由代码的原始值，以保持与先前版本的兼容性。  否则，如果使用后缀s，sec或secs来指定秒数，而使用ms，msec或msecs的后缀来指定毫秒。
* rttvar TIME (2.3.15+ only)：初始RTT方差估算值。  与上面的rtt一样指定值
* rto_min TIME (2.6.23+ only)：与此目标通信时要使用的最小TCP重新传输超时。值的指定与上面的rtt相同
* ssthresh NUMBER (2.3.15+ only)：初始慢启动阈值的估计值
* cwnd NUMBER (2.3.15+ only)：锁定标志，如果不使用锁定标志，则忽略该选项
* initcwnd NUMBER (2.5.70+ only)：到此目标的连接的初始拥塞窗口大小。  实际窗口大小是该值乘以相同连接的MSS（``最大段大小''）。  默认值为零，表示使用RFC2414中指定的值。
* initrwnd NUMBER (2.6.33+ only)：到此目标的连接的初始接收窗口大小。  实际窗口大小是此值乘以连接的MSS。  默认值为零，表示使用慢启动值。
* features FEATURES (3.18+only)：启用或禁用每路由功能。此时唯一可用的特性是ecn，它可以在启动到给定目标网络的连接时启用显式拥塞通知。当响应来自给定网络的连接请求时，即使net.ipv4.tcp_ecn sysctl设置为0
* congctl  NAME/congctl lock NAME (3.20+ only)：仅针对给定的目的地设置特定的TCP拥塞控制算法。   如果未指定，Linux将保留当前的全局默认TCP拥塞控制算法或应用程序中的一种。   如果未使用修饰符锁定，则应用程序仍可能会覆盖该目的地的建议拥塞控制算法。   如果使用了修饰符锁，则不允许应用程序覆盖该目的地的指定拥塞控制算法，因此将强制/保证使用建议的算法
* advmss NUMBER (2.3.15+ only)：在建立TCP连接时向这些目标播发的MSS（“最大段大小”）。如果没有给定，Linux将使用从第一跳设备MTU计算的默认值
* reordering NUMBER (2.3.15+ only)：到此目的地的路径上的最大重新排序。  如果未给出，则Linux使用通过sysctl变量`net/ipv4/tcp_reordering`​选择的值
* nexthop NEXTHOP：多路径路由的下一跳。  NEXTHOP是一个复杂值，其语法类似于顶级参数列表：

  * via ADDRESS：下一跳路由
  * dev NAME：输出设备名称
  * weight NUMBER：是多路径路由的此元素的权重，反映其相对带宽或质量
* scope SCOPE_VAL：路由前缀所覆盖的目的地范围。  SCOPE_VAL可以是数字`/etc/iproute2/rt_scopes`​中的字符串。  如果省略此参数，则ip假定所有网关单播路由的作用域是全局范围，直接单播和广播路由的作用域链接以及本地路由的作用域主机
* protocol  RTPROTO：该路由的路由协议标识符。  RTPROTO可以是文件/ etc / iproute2 /  rt_protos中的数字或字符串。如果未提供路由协议ID，则ip会采用协议引导方式（即假定路由是由不了解自己在做什么的人添加的）。   几个协议值具有固定的解释。

  * redirect： 路由是由于ICMP重定向而安装的
  * kernel：路由是在自动配置期间由内核安装的
  * boot：路由是在启动过程中安装的。如果路由守护进程启动，它将清除所有这些守护进程
  * static：该路由由管理员安装，以覆盖动态路由。  路由守护程序将尊重它们，甚至可能将它们通告给其对等端。
  * ra：路由是通过路由器发现协议安装的

```bash
ip route add default via 192.168.1.1	                # 设置系统默认路由
ip route add 192.168.4.0/24 via 192.168.0.254 dev eth0	# 设置192.168.4.0网段的网关为192.168.0.254,数据走eth0接口
ip route add default via 192.168.0.254 dev eth0	        # 设置默认网关为192.168.0.254
ip route add default via 192.168.1.1 table 1	        # 在一号表中添加默认路由为192.168.1.1
ip route add 192.168.0.0/24 via 192.168.1.2 table 1	    # 在一号表中添加一条到192.168.0.0网段的路由为192.168.1.2
ip route add prohibit 209.10.26.51	                    # 设置请求的目的地不可达的路由
ip route add prohibit 209.10.26.51 from 192.168.99.35	# 假设您不想阻止所有用户访问此特定主机，则可以使用该from选项，阻止了源IP 192.168.99.35到达209.10.26.51
ip route change default via 192.168.99.113 dev eth0	    # 更改默认路由。此操作等同于先删除，后新增
```

# **ip route get**

此命令获取到目标的单个路由，并按照内核所看到的方式打印其内容。  
此操作不等同于ip route show。  ip  routeshow会显示现有路线，而get解析它们并在必要时创建新克隆。基本上，get相当于沿着此路径发送数据包。如果没有给出iif参数，内核将创建一个路由，以将数据包输出到请求的目的地。这相当于用后续的ip路由ls缓存ping目标，但是实际上没有发送任何数据包。使用iif参数，内核假装一个数据包从这个接口到达，并搜索一条路径来转发数据包

**option：**

* to ADDRESS (default)：目的地址
* from ADDRESS：源地址
* tos TOS：服务类型
* iif NAME：此数据包预期从中到达的设备
* oif NAME：强制将此数据包路由到的输出设备
* connected：如果未给出源地址（选项from），则重新查找源设置为从第一次查找收到的首选地址的路由。  如果使用策略路由，则可能是其他路由

```bash
ip route get 169.254.0.0/16	  # 获取到目标的单个路由，并按照内核所看到的方式打印其内容
```

# **ip route delete**

```bash
ip route del 192.168.4.0/24   	         # 删除192.168.4.0网段的网关
ip route del default	                 # 删除默认路由
ip route delete 192.168.1.0/24 dev eth0	 # 删除路由
```

# **ip route save**

将路由表信息保存到标准输出。该命令的行为类似于ip route show，除了输出是适合传递给ip route restore的原始数据外。

# **ip route restore**

从stdin恢复路由表信息  该命令希望读取从ip route save返回的数据流。  它将尝试完全还原保存时的路由表信息，因此必须先完成流中信息的任何转换（例如设备索引）。  任何现有路线均保持不变。  表中已经存在的数据流中指定的任何路由都将被忽略。  
​`ip route restore`​

# **ip route flush**

该`flush`​选项与**ip route**一起使用时，将清空路由表或删除特定目标的路由

```bash
ip route flush 10.38.0.0/16	 # 删除特定路由
ip route flush table main	 # 清空路由表
```

**Route type 解释:**

* unicast：由路由前缀覆盖的目的地址的真实路径
* unreachable：目的路由无法到达。丢弃数据包并生成ICMP消息主机不可访问。本地发件人收到一个EHOSTUNREACH错误。
* blackhole：目的路由无法到达。数据包被悄悄丢弃。本地发件人收到EINVAL错误。
* prohibit：目的路由无法到达。数据包将被丢弃，并生成管理上禁止的ICMP消息通信。  本地发件人收到EACCES错误。
* local：目的地已分配给此主机。数据包被环回并在本地传递
* broadcast：目的路由是广播地址。数据包作为链接广播发送
* throw：与策略规则一起使用的特殊控制路径。   如果选择了这样的路由，则会在未找到路由的情况下终止此表中的查找。  如果没有策略路由，则等同于路由表中没有路由。   数据包被丢弃，并生成ICMP消息net unreachable。  本地发件人收到ENETUNREACH错误
* nat：一条特殊的NAT路由。  前缀所覆盖的目的地被认为是虚拟（或外部）地址，在转发之前需要将其转换为真实（或内部）地址。  使用属性via选择要转换为的地址
* anycast：未分配给此主机的路由地址，它们主要等效于本地，只是有一个区别：这些地址用作任何数据包的源地址时都是无效的。
* multicast：一种用于多播路由的特殊类型。  它在常规路由表中不存在。

**运行实例：**

```bash
// 查看本地路由表
// 此输出中的第一个字段告诉我们该路由是针对该计算机本地托管的广播地址还是IP地址或范围。
//随后的字段会通知我们目标可通过哪个设备到达，并且特别是（在此表中）内核已添加了这些路由，作为建立IP层接口的一部分
[root@izwz91quxhnlkan8kjak5hz net]# ip route show table local
broadcast 127.0.0.0 dev lo proto kernel scope link src 127.0.0.1 
local 127.0.0.0/8 dev lo proto kernel scope host src 127.0.0.1 
local 127.0.0.1 dev lo proto kernel scope host src 127.0.0.1 
broadcast 127.255.255.255 dev lo proto kernel scope link src 127.0.0.1 

// 添加请求目的不可达的路由
[root@masq-gw]# ip route add prohibit 209.10.26.51
[root@tristan]# ssh 209.10.26.51
ssh: connect to address 209.10.26.51 port 22: No route to host
[root@masq-gw]# tcpdump -nnq -i eth2
tcpdump: listening on eth2
22:13:13.740406 192.168.99.35.51973 &gt; 209.10.26.51.22: tcp 0 (DF)
22:13:13.740714 192.168.99.254 &gt; 192.168.99.35: icmp: host 209.10.26.51 unreachable - admin prohibited filter [tos 0xc0]

```

‍

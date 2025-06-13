# arping

# arping命令详解

## 一、版本[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#一版本)

==arping==命令是用于发送==arp==请求到相邻主机的工具，arping使用arp数据包  
arping有两个版本，一个版本是***Thomas Habets***这个人写的，这个版本有个好处是可以arping \<MAC地址\>，也就是说我们可以通过MAC地址得到IP。还有一个版本是***Linux iputils suite***的，这个版本就不能通过MAC地址，解析出IP地址了。

可以使用==arping -V==来查看自己系统的arping的版本

据观察Redhat\\CentOS使用的是Linux iputils suite版本的，debian使用的是Thomas Habets。

注意两个版本的的arping使用的参数有很大的区别，所以要根据自己的arping版本去使用相应的参数。不看版本在网上抄的命令可能在自己的系统上无法执行。下面介绍Linux iputils suite版本的arping命令用法。

## 二、语法[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#二语法)

​`Usage: arping [-fqbDUAV] [-c count] [-w timeout] [-I device] [-s source] destination`​

## 三、参数释义[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#三参数释义)

```bash

-A：与-U参数类似，但是使用的是==ARP REPLY==包而非==ARP REQUEST==包。
-b：发送以太网广播帧，arping在开始时使用广播地址，在收到回复后使用==unicast==单播地址。
-c：发送指定的count个==ARP REQUEST==包后停止。如果指定了-w参数，则会等待相同数量的==ARP REPLY==包，直到超时为止。
-D：重复地址探测模式，即，==Duplicate address detection mode (DAD)==，用来检测有没有IP地址冲突，如果没有IP冲突则返回0。
-f：收到第一个响应包后退出。
-h：显示帮助页。
-I：用来发送ARP REQUEST包的网络设备的名称。
-q：quite模式，不显示输出。
-U：无理由的（强制的）ARP模式去更新别的主机上的==ARP CACHE==列表中的本机的信息，不需要响应。
-V：显示arping的版本号。
-w：指定一个超时时间，单位为秒，arping在到达指定时间后退出，无论期间发送或接收了多少包。在这种情况下，arping在发送完指定的count（-c）个包后并不会停止，而是等待到超时或发送的count个包都进行了回应后才会退出。
-s：设置发送ARP包的IP资源地址，如果为空，则按如下方式处理：
    1、==DAD==模式（-D）设置为0.0.0.0；
    2、==Unsolicited==模式（-U）设置为目标地址；
    3、其它方式，从路由表计算。
```

‍

## 四、实例[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#四实例)

### 1、查看某个IP的MAC地址[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#1查看某个ip的mac地址)

有多个网卡可以用 -I 指定网卡接口

```basic
[root@CentOS7.9 ~]# arping -I enp5s0f0 192.168.52.1
ARPING 192.168.52.1 from 192.168.52.14 enp5s0f0
Unicast reply from 192.168.52.1 [00:00:5E:00:01:69] 3.024ms
Unicast reply from 192.168.52.1 [00:00:5E:00:01:69] 2.988ms
Sent 2 probes (1 broadcast(s))
Received 2 response(s)

```

### 2、查看某个IP的MAC地址，并指定count数量[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#2查看某个ip的mac地址并指定count数量)

-c 可以指定发送特定数量的ARP REQUEST包

```basic

[root@CentOS7.9 ~]# arping -c 2 -I enp5s0f0 192.168.52.1
ARPING 192.168.52.1 from 192.168.52.14 enp5s0f0
Unicast reply from 192.168.52.1 [00:00:5E:00:01:69] 3.394ms
Unicast reply from 192.168.52.1 [00:00:5E:00:01:69] 3.235ms
Sent 2 probes (1 broadcast(s))
Received 2 response(s)

```

### 3、探测重复地址[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#3探测重复地址)

-D 可以探测是否有重复ip地址，测试发现-D似乎只有在同网段主机上才有用，在和被测ip不同网断无效。

有重复地址即存在IP冲突则返回1

```bash
[root@CentOS7.9 ~]# arping -c 1 -D -I enp5s0f0 192.168.52.18
ARPING 192.168.52.18 from 0.0.0.0 enp5s0f0
Unicast reply from 192.168.52.18 [A0:B3:CC:E5:8B:46] 4.741ms
Sent 1 probes (1 broadcast(s))
 Received 1 response(s)
```

无重复地址则返回0

```bash
 [root@CentOS7.9 ~]# arping -c 1 -D -I enp5s0f0 192.168.52.18
ARPING 192.168.52.18 from 0.0.0.0 enp5s0f0
Sent 1 probes (1 broadcast(s))
Received 0 response(s)
```

### 4、更新邻近主机arp缓存[#](https://www.cnblogs.com/xzongblogs/p/14391379.html#4更新邻近主机arp缓存)

每台主机都会在自己的 ARP 缓冲区中建立一个 ARP 列表，以表示 IP 地址和 MAC  地址之间的对应关系，二层的数据传输靠的就是MAC地址。不同厂商默认的ARP表老化时间也不一样：思科是 5分钟，华为是 20分钟。ARP  表缓存老化时间过长有时可能会导致一些网络问题，我们后面讨论。先看下arp协议大致的工作原理。

**ARP协议工作原理**  
　　ARP 协议包（ARP 报文）主要分为 ARP 请求包和 ARP 响应包。网络中的主机可以通过这两种报文获取ip和MAC的对应关系或更新邻近主机的arp表。

**ARP请求包**

某个主机需要发送报文时，首先检查 ARP 列表中是否有对应 IP 地址的目的主机的 MAC  地址，如果有，则直接发送数据，如果没有，就向本网段的所有主机发送 ARP 广播数据包，该数据包包括的内容有：源主机 IP 地址，源主机 MAC  地址，目的主机的 IP 地址等。当本网络的主机收到该 ARP 数据包时：  
　（A）首先检查数据包中的 IP 目标地址是否是自己的 IP 地址，如果不是，则忽略该数据包。  
　（B）如果是，则**首先从数据包中取出源主机的 IP 和 MAC 地址写入到 ARP 列表中，如果已经存在，则覆盖。然后将自己的  MAC 地址写入 ARP 响应包中，单播给发送请求的主机，告诉源主机自己就是它想要找的 MAC地址。源主机收到 ARP 响应包后。将目的主机的  IP 和 MAC 地址写入 ARP 列表，** 并利用此信息发送数据。如果源主机一直没有收到 ARP 响应数据包，表示 ARP 查询失败。

**ARP响应包**  
　　要更新邻近主机关于自己的arp记录可以发送ARP响应包文。如：某设备（网络接口）新加入网络或mac地址发生变化亦或接口发生重启时，会**发送免费ARP报文把自己IP地址与Mac地址的映射关系广播给其他主机。网络上的主机接收到免费ARP报文时，会更新自己的ARP缓冲区。** 将新的映射关系更新到自己的ARP表中。

**ARP表老化时间造成的问题**

在一些HA的场景会配置浮动ip，可能会出现浮动ip切到其他主机后网络不通的问题，这很有可能是交换机ARP表没有更新造成的，因为在ip切换的过程中也许没有网络接口状态的变化触发ARP表的更新，交换机或其他主机缓存的依然是老的数据。等到交换机ARP表老化时间到了再次更新arp表网络就通了。显然我们没有那么多的时间，而且这样HA的意义又何在呢？为了使交换机尽快更新ARP表，可以将交换机的ARP缓存清理掉，让交换机自动学习一遍，但交换机不是每个系统管理员都能操作的。最方便的办法是在服务器上发送ARP请求或响应报文，从而更新交换机和邻近主机的ARP缓存，操作完成后网络就通了。前面说了这么多，其实就是为了引出最后的ARP缓存导致网络不通的问题和解决办法，但如果对ARP工作的工作缺乏基本的了解，在出现类似故障时是很难想到问题所在的。如下两台命令可以帮助更新APR缓存表：

**在浮动ip所在的主机执行如下两条命令中任意一个，192.168.52.18 为vip，enp5s0f0是vip需要绑定的网卡名**

```bash
 arping -c 3 -U -I enp5s0f0 192.168.52.18
 arping -c 3 -A -I enp5s0f0 192.168.52.18
```

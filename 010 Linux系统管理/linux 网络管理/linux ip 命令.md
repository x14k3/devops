# linux ip 命令

**ip命令** 用来显示或操纵Linux主机的路由、网络设备、策略路由和隧道，是Linux下较新的功能强大的网络配置工具。

### 语法

```
ip(选项)(对象)
Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }
       ip [ -force ] -batch filename
```

### OPTIONS选项

```
OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |
       tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |
       netns | l2tp | macsec | tcp_metrics | token }
   
-V：显示指令版本信息；
-s：-stats, -statistics输出更详细的信息；可以使用多个-s来显示更多的信息
-f：-family {inet, inet6, link} 强制使用指定的协议族；
-4：-family inet的简写，指定使用的网络层协议是IPv4协议；
-6：-family inet6的简写，指定使用的网络层协议是IPv6协议；
-0：shortcut for -family link.
-o：-oneline，输出信息每条记录输出一行，即使内容较多也不换行显示；
-r：-resolve，显示主机时，不使用IP地址，而使用主机的域名。

```

### OBJECT对象

```bash
link        网络设备
address     ip地址
addrlabel   label configuration for protocol address selection
route       路由
neigh       arp 或者 NDISC 缓存条目管理
ntable      临近网络操作管理
tunnel      基于 IP 的隧道
tuntap      TUN/TAP 设备管理
maddress    多播地址
mroute      多播路由缓存条目
mrule       多播路由策略数据库里的规则
monitor     查看 netlink 信息
xfrm        IPSec 策略管理
netns       网络命名空间管理
l2tp        基于 IP 的隧道网络
tcp_metrics tcp 指标管理
token       标记的接口认证管理
```

### 实例

```bash
ip link show                     # 显示网络接口信息
ip link set eth0 up              # 开启网卡
ip link set eth0 down            # 关闭网卡
ip link set eth0 promisc on      # 开启网卡的混合模式
ip link set eth0 promisc offi    # 关闭网卡的混合模式
ip link set eth0 txqueuelen 1200 # 设置网卡队列长度
ip link set eth0 mtu 1400        # 设置网卡最大传输单元
ip addr show     # 显示网卡IP信息
ip addr add 192.168.0.1/24 dev eth0 # 为eth0网卡添加一个新的IP地址192.168.0.1
ip addr del 192.168.0.1/24 dev eth0 # 为eth0网卡删除一个IP地址192.168.0.1

ip route show    # 显示系统路由
ip route list    # 查看路由信息
ip route add default via 192.168.1.254                 # 设置系统默认路由
ip route add default via 192.168.0.254 dev eth0        # 设置默认网关为192.168.0.254
ip route add 192.168.4.0/24 via 192.168.0.254 dev eth0 # 设置192.168.4.0网段的网关为192.168.0.254,数据走eth0接口

ip route del default                    # 删除默认路由
ip route del 192.168.4.0/24             # 删除192.168.4.0网段的网关
ip route delete 192.168.1.0/24 dev eth0 # 删除路由

# --------------------------------------------------------------------
ip -c  link     彩色
ip -br link     概述
ip -o  link     一行显示
ip -d  link     详细
ip -s  addr     摘要
```

‍

#### P命令管理网桥bridge

```python
ip link add bridge_name type bridge
ip link set bridge_name up
# 想要添加Interface到网桥上，interface状态必须是Up
ip link set eth0 up
# 添加eth0 interface到网桥上
ip link set eth0 master bridge_name
# 从网桥解绑eth0
ip link set eth0 nomaster
# eth0 可以关闭的
ip link set eth0 down
# 删除网桥可以用
ip link delete bridge_name type bridge
# 也可以简化为
ip link del bridge_name

```

‍

#### **用ip命令显示网络设备的运行状态**

```
[root@localhost ~]# ip link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:51 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:52 brd ff:ff:ff:ff:ff:ff
```

#### **显示更加详细的设备信息**

```
[root@localhost ~]# ip -s link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast   
    5082831    56145    0       0       0       0  
    TX: bytes  packets  errors  dropped carrier collsns
    5082831    56145    0       0       0       0  
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:51 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    3641655380 62027099 0       0       0       0  
    TX: bytes  packets  errors  dropped carrier collsns
    6155236    89160    0       0       0       0  
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:3e:00:1e:52 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    2562136822 488237847 0       0       0       0  
    TX: bytes  packets  errors  dropped carrier collsns
    3486617396 9691081  0       0       0       0   
```

#### **显示核心路由表**

```
[root@localhost ~]# ip route list 
112.124.12.0/22 dev eth1  proto kernel  scope link  src 112.124.15.130
10.160.0.0/20 dev eth0  proto kernel  scope link  src 10.160.7.81
192.168.0.0/16 via 10.160.15.247 dev eth0
172.16.0.0/12 via 10.160.15.247 dev eth0
10.0.0.0/8 via 10.160.15.247 dev eth0
default via 112.124.15.247 dev eth1
```

#### **显示邻居表**

```
[root@localhost ~]# ip neigh list
112.124.15.247 dev eth1 lladdr 00:00:0c:9f:f3:88 REACHABLE
10.160.15.247 dev eth0 lladdr 00:00:0c:9f:f2:c0 STALE
```

#### **获取主机所有网络接口**

```
ip link | grep -E '^[0-9]' | awk -F: '{print $2}'
```

‍

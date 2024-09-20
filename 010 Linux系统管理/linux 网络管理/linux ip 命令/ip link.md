# ip link

# **ip link 命令格式**

```bash
Usage: ip link add [link DEV] [ name ] NAME
                   [ txqueuelen PACKETS ]
                   [ address LLADDR ]
                   [ broadcast LLADDR ]
                   [ mtu MTU ]
                   [ numtxqueues QUEUE_COUNT ]
                   [ numrxqueues QUEUE_COUNT ]
                   type TYPE [ ARGS ]
       ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]

       ip link set { DEVICE | dev DEVICE | group DEVGROUP }
                          [ { up | down } ]
                          [ type TYPE ARGS ]
                          [ arp { on | off } ]
                          [ dynamic { on | off } ]
                          [ multicast { on | off } ]
                          [ allmulticast { on | off } ]
                          [ promisc { on | off } ]
                          [ trailers { on | off } ]
                          [ txqueuelen PACKETS ]
                          [ name NEWNAME ]
                          [ address LLADDR ]
                          [ broadcast LLADDR ]
                          [ mtu MTU ]
                          [ netns { PID | NAME } ]
                          [ link-netnsid ID ]
                          [ alias NAME ]
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ]
                                   [ max_tx_rate TXRATE ]
                                   [ min_tx_rate TXRATE ]
                                   [ spoofchk { on | off} ]
                                   [ query_rss { on | off} ]
                                   [ state { auto | enable | disable} ] ]
                                   [ trust { on | off} ] ]
                          [ master DEVICE ]
                          [ nomaster ]
                          [ addrgenmode { eui64 | none } ]
                          [ protodown { on | off } ]
       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]
       ip link help [ TYPE ]

TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |
          gre | gretap | ip6gre | ip6gretap | vti | nlmon |
          bond_slave | geneve | bridge_slave | macsec }
```

# **ip link add**

　　**option：** 

* link DEVICE：指定要操作的物理设备
* name NAME：指定新虚拟设备的名称
* type TYPE：指定新设备的类型

  * bridge - Ethernet Bridge device
  * bond - Bonding device
  * dummy - Dummy network interface
  * ifb - Intermediate Functional Block device
  * ipoib - IP over Infiniband device
  * macvlan - Virtual interface base on link layer address (MAC)
  * macvtap - Virtual interface based on link layer address (MAC) and TAP.
  * vcan - Virtual Controller Area Network interface
  * veth - Virtual ethernet interface
  * vlan - 802.1q tagged virtual LAN interface
  * vxlan - Virtual eXtended LAN
  * ip6tnl - Virtual tunnel interface IPv4|IPv6 over IPv6
  * ipip - Virtual tunnel interface IPv4 over IPv4
  * sit - Virtual tunnel interface IPv6 over IPv4
  * gre - Virtual tunnel interface GRE over IPv4
  * gretap - Virtual L2 tunnel interface GRE over IPv4
  * ip6gre - Virtual tunnel interface GRE over IPv6
  * ip6gretap - Virtual L2 tunnel interface GRE over IPv6
  * vti - Virtual tunnel interface
  * nlmon - Netlink monitoring device
  * geneve - GEneric NEtwork Virtualization Encapsulation
  * macsec - Interface for IEEE 802.1AE MAC Security (MACsec)

* numtxqueues QUEUE_COUNT：指定新设备的传输队列数
* numrxqueues QUEUE_COUNT：指定新设备的接收队列数

　　‍

　　添加类型格式：

　　VLAN类型的链路，支持以下附加参数：

```bash
ip link add link DEVICE name NAME type vlan [ protocol VLAN_PROTO ] id VLANID [ reorder_hdr { on | off } ] [ gvrp { on | off } ] [ mvrp { on | off } ] [ loose_binding { on | off } ] [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ] 
```

* id VLANID：指定要使用的VLAN标识符。请注意，带前导“0”或“0x”的数字分别被解释为八进制或十六进制
* reorder_hdr { on | off }：指定以太网报头是否重新排序
* gvrp { on | off } ：指定是否应使用GARP VLAN注册协议注册此VLAN
* mvrp{on | off}：指定是否应使用多个VLAN注册协议注册此VLAN
* loose_binding {on | off}：指定VLAN设备状态是否绑定到物理设备状态
* ingress-qos-map QOS-MAP：定义传入帧上优先级代码点之间的映射。格式为从：到由空格分隔的多个映射
* egress-qos-map QOS-MAP：与入口qos映射相同，但用于输出帧

　　实例

```bash
ip link add link eth0 name eth0.10 type vlan id 10	#在设备eth0上创建新的vlan设备eth0.10
```

---

# **ip link set**

　　该命令用于更改设备属性。如果请求多个参数更改，则任何更改失败后，ip会立即中止。 这是ip可以将系统移至不可预测状态的唯一情况。 解决方案是避免通过一个ip链接集调用更改多个参数。

　　**option：**

* dev DEVICE：指定要操作的网络设备。 在配置SR-IOV虚拟功能（VF）设备时，此关键字应指定关联的物理功能（PF）设备
* group GROUP：GROUP具有双重作用：如果同时存在group和dev，则将设备移至指定的组。  如果仅指定了一个组，则该命令将在该组中的所有设备上运行
* up and down：将设备的状态更改为UP或DOWN
* arp on or arp off：开启或关闭arp
* multicast on or multicast off：更改设备上的多播标志
* protodown on or protodown off：更改设备上的PROTODOWN状态。 表示已在端口上检测到协议错误。 交换机驱动程序可以通过对交换机端口进行物理检查来对此错误做出反应
* dynamic on or dynamic off：更改设备上的DYNAMIC标志
* name NAME：更改设备的名称。 如果设备正在运行或已经配置了某些地址，则不建议执行此操作
* txqueuelen NUMBER / txqlen NUMBER：更改设备的传输队列长度
* mtu NUMBER：更改设备的MTU
* address LLADDRESS：更改接口地址
* peer LLADDRESS：当接口为点对点时，更改链路层广播地址或对等地址
* netns NETNSNAME | PID：将设备移至与名称NETNSNAME关联的网络名称空间或处理PID
* alias NAME：为设备提供一个符号名称，以便于参考
* vf NUM：vf NUM指定要配置的虚拟功能设备。必须使用dev参数指定关联的PF设备

  * mac LLADDRESS： 更改指定VF的站地址。必须指定vf参数
  * vlan  VLANID：更改为指定VF分配的VLAN。  指定后，将从VF发送的所有流量标记为指定的VLAN ID。  传入的流量将针对指定的VLAN  ID进行过滤，并在将所有VLAN标记传递给VF之前将其剥离。  将此参数设置为0将禁用VLAN标记和过滤。  必须指定vf参数
  * qos  VLAN-QOS：为VLAN标记分配VLAN  QOS（优先级）位。指定时，VF传输的所有VLAN标记将在VLAN标记中包含指定的优先级位。如果未指定，则假定该值为0。必须同时指定vf和vlan参数。将vlan和qos都设置为0将禁用VF的vlan标记和筛选
  * rate TXRATE：更改指定VF的允许传输带宽（以Mbps为单位）。 将此参数设置为0将禁用速率限制。 必须指定vf参数。 请改用新的API max_tx_rate选项
  * max_tx_rate TXRATE：更改指定VF允许的最大传输带宽（以Mbps为单位）。必须指定vf参数
  * min_tx_rate TXRATE：更改指定VF的允许的最小传输带宽（以Mbps为单位）。 最小TXRATE应始终<=最大TXRATE。 必须指定vf参数
  * spoofchk on|off：打开或关闭指定VF的数据包欺骗检查
  * query_rss on|off：切换查询特定VF的RSS配置的功能。 VF RSS信息（例如RSS哈希键）在某些设备上可能被认为是敏感的，这些设备在VF和PF之间共享，因此默认情况下可能禁止其查询
  * state   auto|enable|disable：将虚拟链接状态设置为指定的VF所看到的状态。设置为auto表示PF-link状态的反映，enable允许VF与该主机上的其他VF通信，即使PF-link状态为down，disable也会导致HW丢弃VF发送的任何数据包
  * trust on|off：信任指定的VF用户。这使得VF用户可以设置可能影响安全性和/或性能的特定特性。（例如VF多播混杂模式）
* master DEVICE：设置设备的主设备
* nomaster：取消设置设备的主设备
* addrgenmode eui64 or addrgenmode none：设置IPv6地址生成模式
* link-netnsid：为跨网络接口设置对等网络标识
* type ETYPE TYPE_ARGS：

```bash
# 开启eth0网卡
ip link set eth0 up    # 或：ifconfig eth0 up
# 关闭eth0网卡
ip link set eth0 down  # 或：ifconfig eth0 down

# 开启网卡的混合模式
ip link set eth0 promisc on
# 关闭网卡的混合模式
ip link set eth0 promisc offi
# 设置网卡队列长度
ip link set eth0 txqueuelen 1200
# 设置网卡最大传输单元
ip link set eth0 mtu 1400

# 修改mac地址
ip link set dev eth0 address 52:54:00:1c:f5:99
```

# **ip link show**

　　**option：**

* dev NAME (default)：名称指定要显示的网络设备。如果省略此参数，则会列出默认组中的所有设备
* group GROUP：指定要显示的设备组
* up：仅显示正在运行的接口
* master DEVICE：显示主设备
* type TYPE：指定要显示的设备类型

```bash
ip link show	        # 显示网络接口信息
ip link show eht0	    # 显示eth0网卡的网络接口信息
ip link show type vlan	# 显示vlan类型设备
```

# **ip link delete**

　　**option：**

* dev DEVICE：指定要操作的虚拟设备
* group GROUP：指定要删除的虚拟链接组。不允许删除组0，因为它是默认组
* type TYPE：指定设备的类型

```bash
ip link delete dev eth0.10	# 删除设备
```

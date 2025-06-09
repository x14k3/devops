# ip rule

ip rule：用于管理路由规则。

互联网上使用的经典路由算法仅根据数据包的目的地址（理论上，但实际上，在TOS域上）做出路由决策。

在某些情况下，我们不仅要根据目的地地址，还要根据其他数据包字段（源地址、IP协议、传输协议端口甚至数据包有效负载）来不同地路由数据包。此任务称为'策略路由'。为了解决这一问题，传统的基于目的地的路由表（根据最长匹配规则排序）被替换为“路由策略数据库”（简称RPDB），RPDB通过执行一组规则来选择路由。

每个策略路由规则都由一个选择器和一个动作谓词组成。RPDB按优先级降低的顺序进行扫描。每个规则的选择器应用于{源地址，目标地址，传入接口，tos，fwmark}并且，如果选择器与数据包匹配，则执行该操作。动作谓词可以成功返回。在这种情况下，它将给出路由或故障指示，并且RPDB查找被终止。否则RPDB程序继续执行下一个规则。

在启动时，内核配置默认的RPDB，包括三个规则：

1. 优先级：0，选择器：匹配任何内容，操作：查找路由表本地（ID 255）。本地表是一种特殊的路由表，包含本地和广播地址的高优先级控制路由
2. 优先级：32766，选择器：匹配任何内容，操作：查找路由表main（ID 254）。主表是包含所有非策略路由的常规路由表。此规则可以被删除和/或由其他规则覆盖管理员
3. 优先级：32767，选择器：匹配任何内容，操作：查找路由表默认值（ID253）。默认表为空。如果没有先前的默认规则选择数据包，则它将保留用于某些后处理。这条规则也可能将被删除

每个RPDB条目都有附加属性。F、 每个规则都有一个指向某个路由表的指针。NAT和伪装规则有一个属性来选择要翻译/伪装的新IP地址。除此之外，规则还有一些可选的路由拥有的属性，即领域。这些值不会覆盖路由表中包含的值。它们仅在路由未选择任何属性时使用。

        RPDB可能包含以下类型的规则： * unicast：规则规定返回在规则引用的路由表中找到的路由

- blackhole：规则规定悄悄地丢弃数据包
- unreachable：规则规定生成“网络不可达”错误
- prohibit：规则规定生成“管理禁止通信”错误
- nat：规则规定将IP数据包的源地址转换为其他值

# **ip rule 命令格式**

```bash
Usage: ip rule { add | del } SELECTOR ACTION
       ip rule { flush }
       ip rule [ list ]
SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]
            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]
ACTION := [ table TABLE_ID ]
          [ nat ADDRESS ]
          [ realms [SRCREALM/]DSTREALM ]
          [ goto NUMBER ]
TABLE_ID := [ local | main | default | NUMBER ]

```

# **ip rule add/del**

option：

- type TYPE (default)：规则类型
- from PREFIX：选择要匹配的源前缀
- to PREFIX：选择要匹配的目的前缀
- iif NAME：选择要匹配的传入设备。如果接口是环回，则该规则仅匹配源自此主机的数据包。这意味着您可以为转发的数据包和本地数据包创建单独的路由表，从而完全隔离它们。
- oif NAME：选择要匹配的传出设备。传出接口仅适用于来自绑定到设备的本地套接字的数据包
- tos TOS/dsfield TOS：选择要匹配的TOS值
- fwmark MARK：选择要匹配的标记值
- priority PREFERENCE：此规则的优先级。每个规则都应该有一个显式设置的唯一优先级值
- table TABLEID：如果规则选择器匹配，则要查找的路由表标识符。也可以使用查找而不是表格
- realms FROM/TO：选择规则是否匹配以及路由表查找是否成功的领域。 仅当路由未选择任何领域时才使用领域TO
- nat ADDRESS：要转换的IP地址块的基础（用于源地址）。 地址可以是NAT地址块的开始（由NAT路由选择），也可以是本地主机地址（甚至为零）。 在最后一种情况下，路由器不转换数据包，而是将其伪装到该地址。使用map-to代替nat意味着同样的事情

```bash
# 通过路由表 inr.ruhep 路由来自源地址为192.203.80/24的数据包
ip rule add from 192.203.80/24 table inr.ruhep prio 220
# 把源地址为193.233.7.83的数据报的源地址转换为192.203.80.144，并通过表1进行路由
ip rule add from 193.233.7.83 nat 192.203.80.144 table 1 prio 320
```

实例：双网卡数据路由策略选择，让来自192.168.1.0/24的数据包走10.60.60.1网关，来自192.168.2.0/24的数据包走172.0.0.1网关

```bash
# 1、定义表
echo 10 clinet_cnc >>/etc/iproute2/rt_tables
echo 20 clinet_tel >>/etc/iproute2/rt_tables   
# 2、新增规则
ip rule add from 192.168.1.0/24 table clinet_cnc
ip rule add from 192.168.2.0/24 table clinet_tel
# 3、添加路由
ip route add default via 10.60.60.1  table clinet_cnc
ip route add default via 172.0.0.1   table clinet_tel
# 4、刷新路由表
ip route flush cache
```

# **ip rule flush**

刷新路由规则，此命令没有参数

# **ip rule list**

列出路由规则，此命令没有参数

‍

# ((20231110105237-2j9ggf1 'linux 策略路由'))

‍

# ip address

　　ip address：用于管理ip地址

　　**ip address命令格式说明：**

```bash
Usage: ip address {add|change|replace} IFADDR dev IFNAME [ LIFETIME ]
                                                      [ CONFFLAG-LIST ]
       ip address del IFADDR dev IFNAME [mngtmpaddr]
       ip address {save|flush} [ dev IFNAME ] [ scope SCOPE-ID ]
                            [ to PREFIX ] [ FLAG-LIST ] [ label LABEL ] [up]
       ip address [ show [ dev IFNAME ] [ scope SCOPE-ID ] [ master DEVICE ]
                         [ type TYPE ] [ to PREFIX ] [ FLAG-LIST ]
                         [ label LABEL ] [up] ]
       ip address {showdump|restore}
IFADDR := PREFIX | ADDR peer PREFIX
          [ broadcast ADDR ] [ anycast ADDR ]
          [ label IFNAME ] [ scope SCOPE-ID ]
SCOPE-ID := [ host | link | global | NUMBER ]
FLAG-LIST := [ FLAG-LIST ] FLAG
FLAG  := [ permanent | dynamic | secondary | primary |
           [-]tentative | [-]deprecated | [-]dadfailed | temporary |
           CONFFLAG-LIST ]
CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG
CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute | autojoin ]
LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]
LFT := forever | SECONDS
TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |
          gre | gretap | ip6gre | ip6gretap | vti | nlmon |
          bond_slave | ipvlan | geneve | bridge_slave | vrf | macsec }

```

# **ip address add**

　　此命令用于新增ip地址

　　**option：**

* dev IFNAME：要将地址添加到的设备的名称
* local ADDRESS (default)：ip地址，地址的格式取决于协议
* peer ADDRESS：点对点接口的远程端点的地址。 同样，ADDRESS后面可以跟一个斜杠和一个十进制数，对网络前缀长度进行编码。 如果指定了对等地址，则本地地址不能具有前缀长度。 网络前缀与对等方而不是与本地地址相关联。
* broadcast ADDRESS：接口上的广播地址。 可以使用特殊符号“ +”和“-”代替广播地址。 在这种情况下，广播地址是通过设置/重置接口前缀的主机位得出的。
* label LABEL：每个地址都可以用标签字符串进行标记。为了保持与Linux-2.0网络别名的兼容性，此字符串必须与设备名称一致，或者必须以设备名称的前缀后跟冒号
* scope SCOPE_VALUE：此地址有效的区域的范围。可用的作用域列在`/etc/iproute2/rt_scopes`​文件中。预定义的范围值包括：

  * global：地址全局有效
  * site：地址是站点本地地址，即在该站点内有效
  * link：该地址是本地链接，即仅在此设备上有效
  * host：地址仅在此主机内有效
* valid_lft LFT：此地址的有效生存期；请参阅RFC 4862第5.5.4节。当它过期时，该地址将被内核删除。默认为“永远”
* preferred_lft LFT：该地址的首选生存时间； 请参阅RFC 4862的5.5.4节。到期后，该地址将不再用于新的传出连接。 默认为永远
* home：（仅IPv6）将此地址指定为RFC 6275中定义的“本地地址”
* mngtmpaddr：（仅IPv6）代表“隐私扩展”（RFC3041）使内核将以此地址创建的临时地址作为模板进行管理。  为了使它生效，必须将use_tempaddr sysctl设置设置为大于零的值。  给定地址的前缀长度必须为64。此标志允许在手动配置的网络中使用隐私扩展，就像无状态自动配置处于活动状态一样。
* nodad：  （仅限IPv6）添加此地址时不执行重复地址检测（RFC 4862）
* noprefixroute：不要为添加的地址的网络前缀自动创建路由，并且不要在删除地址时搜索要删除的路由

```bash
# 设置eth0网卡IP
ip addr add 192.168.0.1/24 dev eth0
# 设置ip、网关、dns
# ip addr add 192.168.0.1/24 dev eth0 && ip route add default via 192.168.1.1 && echo "nameserver 114.114.114.114" >> /etc/resolv.conf
# 或：ifconfig eth0 192.168.0.1 netmask 255.255.255.0 up
# 或：ifconfig eth0 192.168.0.1/24 up
```

# **ip address delete**

　　此命令用于删除ip地址。与ip addr add的参数一致。设备名称是必需的参数。其余的是可选的。如果没有给出参数，则删除第一个地址。

```bash
# 删除eth0网卡IP地址192.168.0.1
ip addr del 192.168.0.1/24 dev eth0
#或：ifconfig eth0 192.168.0.1 netmask 255.255.255.0 down
#或：ifconfig eth0 192.168.0.1/24 dwon
```

# **ip address flush**

　　此命令刷新根据某些条件选择的协议地址。此命令的参数与show相同，只是不支持类型选择器和主选择器

```bash
# 从设备eth4删除所有全局IPv4和IPv6地址。 如果没有“范围全局”，它将删除所有地址，包括本地IPv6链接
ip address flush dev eth4 scope global
```

# **ip address show**

　　**option：**

* dev IFNAME (default)：设备名称
* scope SCOPE_VAL：仅列出具有此作用域的地址
* to PREFIX：仅列出与此前缀匹配的地址
* label PATTERN：仅列出标签与PATTERN相匹配的地址
* master DEVICE：仅列出从站到该主设备的接口
* type TYPE：只列出给定类型的接口
* up：仅列出正在运行的接口
* dynamic and permanent：（仅IPv6）仅列出由于无状态地址配置而安装的地址，或仅列出永久（非动态）地址
* tentative：（仅限IPv6）仅列出尚未通过重复地址检测的地址
* -tentative：（仅IPv6）仅列出当前不在重复地址检测过程中的地址
* deprecated：（仅限IPv6）仅列出不推荐使用的地址
* -deprecated：（仅IPv6）仅列出未弃用的地址
* dadfailed：（仅IPv6）仅列出未检测到重复地址的地址
* -dadfailed：（仅IPv6）仅列出未通过重复地址检测失败的地址
* temporary：（仅IPv6）仅列出临时地址
* primary and secondary：仅列出主要（或次要）地址

```bash
ip address show	         # 显示网卡IP信息
ip address show up	     # 仅列出正在运行的
ip address show eth0	 # 显示eth0网卡的ip信息
```

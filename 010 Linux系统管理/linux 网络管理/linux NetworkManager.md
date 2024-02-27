# linux NetworkManager

## NetworkManager 介绍

NetworkManager是一个程序，用于为系统自动提供检测和配置以自动连接到网络。NetworkManager的功能对于无线和有线网络都非常有用。对于无线网络，NetworkManager首选已知的无线网络，并且能够切换到最可靠的网络。支持NetworkManager的应用程序可以从联机和脱机模式切换。与无线连接相比NetworkManager更喜欢有线连接，它支持调制解调器连接和某些类型的VPN。NetworkManager最初是由Red  Hat开发的，现在由GNOME项目托管。

NetworkManager主要管理2个对象： Connection（网卡连接配置） 和 Device（网卡设备），他们之间是多对一的关系，但是同一时刻只能有一个Connection对于Device才生效。

NetworkManager的配置工具有多种形式，如下：

1. nmcli：命令行。这是最常用的工具。
2. nmtui：在shell终端开启文本图形界面。
3. nm-applet:GUI界面配置工具。

NetworkManager的配置在这个目录里面：

```bash
[Unauthorized System] root@Kylin:/# ll /etc/NetworkManager/system-connections/
总用量 12
drwxr-xr-x 2 root root 4096 9月   5 16:52 ./
drwxr-xr-x 8 root root 4096 9月   5 16:40 ../
-rw------- 1 root root  406 9月   5 08:32 有线连接 1

```

‍

## nmcli 基本选项

|选项|作用|
| --------| -------------------------------------------------------|
|\-t|简洁输出，会将多余的空格删除，|
|\-p|人性化输出，输出很漂亮|
|\-n|优化输出，有两个选项tabular(不推荐)和multiline(默认)|
|\-c|颜色开关，控制颜色输出(默认启用)|
|\-f|过滤字段，all为过滤所有字段，common打印出可过滤的字段|
|\-g|过滤字段，适用于脚本，以:分隔|
|\-w|超时时间|

## general 常规选项

命令格式：`nmcli general {status|hostname|permissions|logging}`​
命令描述：使用此命令可以显示网络管理器状态和权限，你可以获取和更改系统主机名，以及网络管理器日志记录级别和域。

### status

显示网络管理器的整体状态

```bash
[root@www ~]# nmcli general status
STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN  
connected  full          enabled  enabled  enabled  enabled 
```

### hostname

获取主机名或该更主机名，在没有给定参数的情况下，打印配置的主机名，当指定了参数，它将被移交给NetworkManager，以设置为新的系统主机名。

```bash
[root@www ~]# nmcli general hostname
www.keepdown.cn
[root@www ~]# nmcli general hostname myself
[root@www ~]# nmcli general hostname
myself
```

### permissions

显示当前用户对网络管理器可允许的操作权限。 如启用和禁用网络、更改WI-FI和WWAN状态、修改连接等。

```bash
[root@www ~]# nmcli general permissions 
PERMISSION                                                 VALUE 
org.freedesktop.NetworkManager.enable-disable-network      yes   
org.freedesktop.NetworkManager.enable-disable-wifi         yes   
org.freedesktop.NetworkManager.enable-disable-wwan         yes   
org.freedesktop.NetworkManager.enable-disable-wimax        yes   
org.freedesktop.NetworkManager.sleep-wake                  yes   
org.freedesktop.NetworkManager.network-control             yes   
org.freedesktop.NetworkManager.wifi.share.protected        yes   
org.freedesktop.NetworkManager.wifi.share.open             yes   
org.freedesktop.NetworkManager.settings.modify.system      yes   
org.freedesktop.NetworkManager.settings.modify.own         yes   
org.freedesktop.NetworkManager.settings.modify.hostname    yes   
org.freedesktop.NetworkManager.settings.modify.global-dns  yes   
org.freedesktop.NetworkManager.reload                      yes   
org.freedesktop.NetworkManager.checkpoint-rollback         yes   
org.freedesktop.NetworkManager.enable-disable-statistics   yes
```

### logging

获取和更改网络管理器日志记录级别和域，没有任何参数当前日志记录级别和域显示。为了更改日志记录状态, 请提供级别和域参数,有关可用级别和域值, 参阅**NetworkManager.conf(5)**

```bash
[root@www ~]# nmcli general logging
LEVEL  DOMAINS                                                                                                                                                                                                                     
INFO   PLATFORM,RFKILL,ETHER,WIFI,BT,MB,DHCP4,DHCP6,PPP,IP4,IP6,AUTOIP4,DNS,VPN,SHARING,SUPPLICANT,AGENTS,SETTINGS,SUSPEND,CORE,DEVICE,OLPC,INFINIBAND,FIREWALL,ADSL,BOND,VLAN,BRIDGE,TEAM,CONCHECK,DCB,DISPATCH,AUDIT,SYSTEMD,PROXY
```

---

## networking 网络控制

命令格式：`nmcli networking {on|off|connectivity}`​
命令描述：查询网络管理器网络状态，开启和关闭网络
选项：

* **on**: 禁用所有接口
* **off**: 开启所有接口
* **connectivity**: 获取网络状态，可选参数`checl`​告诉网络管理器重新检查连接性，否则显示最近已知的状态。而无需重新检查。（可能的状态如下所示）

  * **none**: 主机为连接到任何网络
  * **portal**: 无法到达完整的互联网
  * **limited**: 主机已连接到网络，但无法访问互联网
  * **full**: 主机连接到网络，并具有完全访问
  * **unknown**: 无法找到连接状态

```bash
[root@www ~]# nmcli networking connectivity
full
[root@www ~]# nmcli networking connectivity check
full
```

---

## radio 无线限传输控制

命令格式：`nmcli radio {all|wifi|wwan}`​
显示无线开关状态，或启用和禁用开关

```bash
[root@www ~]# nmcli radio all
WIFI-HW  WIFI     WWAN-HW  WWAN  
enabled  enabled  enabled  enabled 
[root@www ~]# nmcli radio all off
[root@www ~]# nmcli radio all
WIFI-HW  WIFI      WWAN-HW  WWAN   
enabled  disabled  enabled  disabled 
[root@www ~]# nmcli radio wifi on
[root@www ~]# nmcli radio wwan on
[root@www ~]# nmcli radio all
WIFI-HW  WIFI     WWAN-HW  WWAN  
enabled  enabled  enabled  enabled
```

---

## monitor 活动监视器

观察网络管理器活动。监视连接的变化状态、设备或连接配置文件。

另请参阅 `nmcli connection monitor`​ 和`nmcli device monitor`​某些设备或连接中的更改。

---

## connection 连接管理

命令格式：`nmcli connection {show|up|down|modify|add|edit|clone|delete|monitor|reload|load|import|export}`​
这是主要使用的一个功能。

### show

show有两种用法，分别是：

**1.**  **列出活动的连接，或进行排序（+-为升降序）**

```bash
# 查看所有连接状态
[root@www ~]# nmcli connection show
# 等同于nmcli connection show --order +active
[root@www ~]# nmcli connection show --active
# 以活动的连接进行排序
[root@www ~]# nmcli connection show --order +active
# 将所有连接以名称排序
[root@www ~]# nmcli connection show --order +name
# 将所有连接以类型排序(倒序)
[root@www ~]# nmcli connection show --order -type
```

**2.**  **查看指定连接的详细信息**

```bash
[root@www ~]# nmcli connection show eth0 # 省略......
```

### up

激活连接，提供连接名称或uuid进行激活，若未提供，则可以使用ifname指定设备名进行激活。

```bash
# 以连接名进行激活
[root@www ~]# nmcli connection up eth0
# 以uuid进行激活
[root@www ~]# nmcli connection up 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
# 以设备接口名进行激活
[root@www ~]# nmcli connection up ifname eth0
```

### down

停用连接，提供连接名或uuid进行停用，若未提供，则可以使用ifname指定设备名进行激活。

```bash
# 以连接名进行激活
[root@www ~]# nmcli connection down eth0
# 以uuid进行激活
[root@www ~]# nmcli connection down 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
# 以设备接口名进行激活
[root@www ~]# nmcli connection down ifname eth0
```

‍

### modify

这些属性可以用`nmcli connection show eth0`​进行获取，然后可以修改、添加或删除属性，若要设置属性，只需指定属性名称后跟值，空值将删除属性值，同一属性添加多个值使用`+`​。同一属性删除指定值用`-`​加索引。

**添加多个ip**

```bash
# 添加三个
[root@www ~]# nmcli connection modify eth0 +ipv4.addresses 192.168.100.102/24
[root@www ~]# nmcli connection modify eth0 +ipv4.addresses 192.168.100.103/24
[root@www ~]# nmcli connection modify eth0 +ipv4.addresses 192.168.100.104/24
# 查看
[root@www ~]# nmcli -f IP4 connection show eth0
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8
# 启用配置
[root@www ~]# nmcli connection up eth0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/18)
# 再次查看
[root@www ~]# nmcli -f IP4 connection show eth0
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.ADDRESS[2]:                         192.168.100.102/24
IP4.ADDRESS[3]:                         192.168.100.103/24
IP4.ADDRESS[4]:                         192.168.100.104/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8
```

**删除指定ip**

```bash
[root@www ~]# nmcli -f IP4 connection show eth0
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.ADDRESS[2]:                         192.168.100.102/24
IP4.ADDRESS[3]:                         192.168.100.103/24
IP4.ADDRESS[4]:                         192.168.100.104/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8
# 删除索当前索引为2的地址
[root@www ~]# nmcli connection modify eth0 -ipv4.addresses 2
# 查看
[root@www ~]# nmcli -f IP4 connection show eth0
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.ADDRESS[2]:                         192.168.100.102/24
IP4.ADDRESS[3]:                         192.168.100.103/24
IP4.ADDRESS[4]:                         192.168.100.104/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8
# 再次激活
[root@www ~]# nmcli connection up eth0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/19)
# 查看
[root@www ~]# nmcli -f IP4 connection show eth0
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.ADDRESS[2]:                         192.168.100.102/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8
```

### add

这是创建一个新的连接，需要指定新创建连接的属性，语法与modify相同。

```bash
[root@www ~]# nmcli con add con-name eth1 type ethernet  autoconnect yes ifname eth0
# con-name    连接名称
# type        连接类型
# autoconnect 是否自动连接
# ifname      连接到的设备名称
```

更多的类型或方法可以使用`nmcli connection add help`​查看。

### clone

克隆连接，克隆一个存在的连接，除了连接名称和uuid是新生成的，其他都是一样的。

```bash
[root@www ~]# nmcli connection clone eth0 eth0_1
```

### delete

删除连接，这将删除一个连接。

```bash
[root@www ~]# nmcli connection delete eth0_1
```

‍

### load

从磁盘加载/重新加载一个或多个连接文件，例如你手动创建了一个`/etc/sysconfig/network-scripts/ifcfg-ethx`​连接文件，你可以将其加载到网络管理器，以便管理。

```bash
[root@www ~]# echo -e "TYPE=Ethernet\nNAME=ethx" > /etc/sysconfig/network-scripts/ifcfg-ethx
[root@www ~]# nmcli connection show
NAME  UUID                                  TYPE            DEVICE 
eth0  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  802-3-ethernet  eth0 
[root@www ~]# nmcli connection load /etc/sysconfig/network-scripts/ifcfg-ethx 
[root@www ~]# nmcli connection show
NAME  UUID                                  TYPE            DEVICE 
eth0  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  802-3-ethernet  eth0   
ethx  d45d97fb-8530-60e2-2d15-d92c0df8b0fc  802-3-ethernet  --
```

### monitor

监视连接配置文件活动。每当指定的连接更改时, 此命令都会打印一行。要监视的连接由其名称、UUID 或 D 总线路径标识。如果 ID 不明确, 则可以使用关键字 id、uuid 或路径。有关 ID 指定关键字的说明, 请参阅上面的连接显示。

监视所有连接配置文件, 以防指定无。当所有监视的连接消失时, 该命令将终止。如果要监视连接创建, 请考虑使用带有 nmcli 监视器命令的全局监视器。

```bash
[root@www ~]# nmcli connection monitor eth0
```

---

## device 设备管理

命令格式：`nmcli device {status|show|set|connect|reapply|modify|disconnect|delete|monitor|wifi|lldp}`​
显示和管理设备接口。该选项有很多功能，例如连接wifi，创建热点，扫描无线，邻近发现等，下面仅列出常用选项。详细功能可使用`nmcli device help`​查看。

### status

打印设备状态，如果没有将命令指定给`nmcli device`​，则这是默认操作。

```bash
[root@www ~]# nmcli device status
DEVICE  TYPE      STATE      CONNECTION 
eth0    ethernet  connected  eth0     
lo      loopback  unmanaged  --       
[root@www ~]# nmcli device
DEVICE  TYPE      STATE      CONNECTION 
eth0    ethernet  connected  eth0     
lo      loopback  unmanaged  --
```

### show

显示所有设备接口的详细信息。

```bash
# 不指定设备接口名称，则显示所有接口的信息
[root@www ~]# nmcli device show eth0
GENERAL.DEVICE:                         eth0
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         00:0C:29:99:9A:A1
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     eth0
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/9
WIRED-PROPERTIES.CARRIER:               on
IP4.ADDRESS[1]:                         192.168.100.101/24
IP4.ADDRESS[2]:                         192.168.100.102/24
IP4.GATEWAY:                            192.168.100.100
IP4.DNS[1]:                             8.8.8.8

```

### set

设置设备属性

```bash
[root@www ~]# nmcli device set ifname eth0 autoconnect yes
```

### connect

连接设备。提供一个设备接口，网络管理器将尝试找到一个合适的连接, 将被激活。它还将考虑未设置为自动连接的连接。(默认超时为90s)

```bash
[root@www ~]# nmcli dev connect eth0
Device 'eth0' successfully activated with '5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03'.
```

### reapply

使用上次应用后对当前活动连接所做的更改来更新设备。

```bash
[root@www ~]# nmcli device reapply eth0
Connection successfully reapplied to device 'eth0'.
```

### modify

修改设备上处于活动的设备，但该修改只是临时的，并不会写入文件。（语法与 nmcli connection modify 相同）

```bash
[root@www ~]# nmcli device modify eth0 +ipv4.addresses 192.168.100.103/24
Connection successfully reapplied to device 'eth0'.
[root@www ~]# nmcli dev show eth0
[root@www ~]# nmcli device modify eth0 -ipv4.addresses 1
Connection successfully reapplied to device 'eth0'.
```

### disconnect

断开当前连接的设备，防止自动连接。但注意，断开意味着设备停止！但可用 connect 进行连接

```bash
[root@www ~]# nmcli device disconnect eth0
```

### delete

删除设备，该命令从系统中删除接口。请注意, 这仅适用于诸如bonds, bridges, teams等软件设备。命令无法删除硬件设备 (如以太网)。超时时间为10秒

```bash
[root@www ~]# nmcli device delete bonds
```

### monitor

监视设备活动。每当指定的设备更改状态时, 此命令都会打印一行。

监视所有设备以防未指定接口。当所有指定的设备消失时, 监视器将终止。如果要监视设备添加, 请考虑使用带有 nmcli 监视器命令的全局监视器。

```bash
[root@www ~]# nmcli device monitor eth0
```

---

## nmcli 返回状态码

mcli 如果成功退出状态值为0，如果发生错误则返回大于0的值。

* **0**: 成功-指示操作已成功
* **1**: 位置或指定的错误
* **2**: 无效的用户输入，错误的nmcli调用
* **3**: 超时了（请参阅 --wait 选项）
* **4**: 连接激活失败
* **5**: 连接停用失败
* **6**: 断开设备失败
* **7**: 连接删除失败
* **8**: 网络管理器没有运行
* **10**: 连接、设备或接入点不存在
* **65**: 当使用 --complete-args 选项，文件名应遵循。

---

‍

## 配置案例

常用参数和网卡配置文件参数的对应关系这个只使用RHEL系列的发行版，不适合Debian系列发行版

​![1273933-20200325211914161-1280908985](assets/1273933-20200325211914161-1280908985-20230924105556-khnssx2.png)​

### 给网卡配置静态IP地址

```bash
# 创建connection，配置静态ip（等同于配置ifcfg，其中BOOTPROTO=none，并ifup启动）
nmcli connection add type ethernet con-name eth1-static ifname eth1 ipv4.method manual ipv4.addresses "192.168.31.203/20" ipv4.gateway 192.168.31.1 ipv4.dns 114.114.114.114,8.8.8.8 connection.autoconnect yes

# type ethernet                    创建连接时候必须指定类型，类型有很多，可以通过 nmcli c add type-h看到，这里指定为ethernet。
# con-name ethX ifname ethX        第一个ethX表示连接（connection）的名字，这个名字可以任意定义，无需和网卡名相同；第二个ethX表示网卡名，这个ethX必须是在 nmcli d里能看到的。
# ipv4.addresses '192.168.1.100/24,192.168.1.101/32'   配置2个ip地址，分别为192.168.1.100/24和192.168.1.101/32
# ipv4.gateway 192.168.1.254       网关为192.168.1.254
# ipv4.dns '8.8.8.8,4.4.4.4'       dns为8.8.8.8和4.4.4.4
# ipv4.method manual               配置静态IP  [ipv4.method auto] 动态DHCP
# connection.autoconnect yes       开机自动启用
```

启用配置

```
nmcli connection up eth0-static
```

修改配置

```bash
cat set_ip.sh 

#!/bin/bash
nmcli conn modify eth0  \
ipv4.addresses "10.10.0.10/24" \
ipv4.gateway 10.10.0.1 \
ipv4.dns 114.114.114.114 \
ipv4.method manual \
ipv6.method ignore \
ipv4.routes "10.10.0.0/24 10.10.0.1" \
connection.autoconnect yes

nmcli connection down eth0  && nmcli connection up eth0


#ipv4.routes "10.10.0.0/24 10.10.0.1" #这会将 10.10.0.0/16 子网的流量定向到网关 10.10.1.1。
```

‍

### 创建网桥

```bash
# 接下来创建一个名为br0的网桥：
nmcli con add type bridge ifname br0
# 把主接口桥到br0上，例如我的主接口名是eno1：
nmcli con add type bridge-slave ifname eno1 master br0
# 关闭主接口，这里可以使用你之前查看获得到的UUID来关闭：
nmcli con down 9a25e1e1-63fc-3cf3-a9ea-549f9e5ab431
# 一般情况下，当NetworkManager检测到主接口down掉后，会自动帮你把网桥up起来，如果没有，手动执行下面的命令：
nmcli con up bridge-br0

# 由于我的路由器是开了DHCP服务的，这里br0会自动分配IP，但如果是服务器上面，一般是要配置静态IP的，以下是设置静态IP的方法：
nmcli con modify bridge-br0 ipv4.method manual ipv4.address "192.168.0.251/24" ipv4.gateway "192.168.0.1" ipv4.dns "114.114.114.114"
nmcli con up bridge-br0

# 如果要恢复成使用DHCP自动分配IP：
nmcli con modify bridge-br0 ipv4.method auto
nmcli con up bridge-br0
```

IPv6桥接模式在一些情况下可能会遇到没有地址的问题。这通常是因为IPv6桥接模式被配置为使用透明的桥接，桥接器本身不分配或管理IP地址。

‍

‍

### 给网卡添加vlan tag并配置IP地址

接下来一个例子是给网卡打vlan tag，这个场景也比较常见，特别是在交换机端是trunk口的情况下：

```
[root@localhost ~]# nmcli connection add type vlan con-name eth1-vlan-100 ifname eth1.100 dev eth1 vlan.id 100 ipv4.method manual ipv4.addresses 192.168.100.10/24 ipv4.gateway 192.168.100.1
Connection 'eth1-vlan-100' (c0036d90-1edf-4085-8b9c-691433fc5afd) successfully added.
```

可以发现和上个例子有一点点的不同，因为实际的流量必须通过某个设备出去，所以和之前相比需要多加上dev eth1参数，声明流量的出口。

Connection创建成功后自动激活了:

```
[root@localhost ~]# nmcli connection
NAME           UUID                                  TYPE      DEVICE
eth0-static    3ae60979-d6f1-4dbb-8a25-ff1178e7305c  ethernet  eth0
eth1-vlan-100  c0036d90-1edf-4085-8b9c-691433fc5afd  vlan      eth1.100
eth0           72534820-fb8e-4c5a-8d49-8c013441d390  ethernet  --
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:b3:80:01 brd ff:ff:ff:ff:ff:ff
    inet 192.168.145.59/20 brd 192.168.159.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a7cf:fd2:7970:4bd4/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:b3:80:02 brd ff:ff:ff:ff:ff:ff
7: eth1.100@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:15:5d:b3:80:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.10/24 brd 192.168.100.255 scope global noprefixroute eth1.100
       valid_lft forever preferred_lft forever
    inet6 fe80::6c74:c8d8:7448:370a/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

可以看到，因为有`eth1-vlan-100`​这个_connection_并且是Active状态，所以NetworkManager创建了一个虚拟的_device_：`eth1.100`​，如果我把这个_connection_给down掉之后:

```
[root@localhost ~]# nmcli connection down eth1-vlan-100
Connection 'eth1-vlan-100' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/15)
[root@localhost ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:b3:80:01 brd ff:ff:ff:ff:ff:ff
    inet 192.168.145.59/20 brd 192.168.159.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a7cf:fd2:7970:4bd4/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:b3:80:02 brd ff:ff:ff:ff:ff:ff
```

可以发现`eth1.100`​直接就没了。所以针对这些虚拟的_device_，它的生命周期和_connection_是一致的。

### 配置网卡的Bonding

接下来该轮到bonding了，bonding也是经常遇到的配置了，配置方法也比较简单：

首先先把bonding master给加上，并且配置好bonding的模式和其他参数，另外，由于bonding之后IP地址一般会配置到bond设备上，在添加的时候顺便也把IP这些信息也填上：

```
[root@localhost ~]# nmcli connection add type bond con-name bonding-bond0 ifname bond0 bond.options "mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4,updelay=5000" ipv4.method manual ipv4.addresses 192.168.100.10 ipv4.gateway 192.168.100.1
8.100.10/24 ipv4.gateway 192.168.100.1
Connection 'bonding-bond0' (a81a11b0-547e-4c6b-9518-62ce51d17ab4) successfully added.
```

添加完bonding master，再把两个slave添加到master口上：

```
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f0 ifname ens1f0 master bond0
Connection 'bond0-slave-ens1f0' (be6285ae-e07a-468d-a302-342c233d1346) successfully added.
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f1 ifname ens1f1 master bond0
Connection 'bond0-slave-ens1f1' (321aa982-5ca0-4379-b822-4200f366cc27) successfully added.
```

再Down/Up一下bond口：

```
[root@localhost ~]# nmcli connection down bonding-bond0;nmcli connection up bonding-bond0
Connection 'bonding-bond0' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/251123)
Connection successfully activated (master waiting for slaves) (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/251126)
[root@localhost ~]# nmcli connection
NAME                UUID                                  TYPE      DEVICE
bonding-bond0       a81a11b0-547e-4c6b-9518-62ce51d17ab4  bond      bond0
bond0-slave-ens1f0  be6285ae-e07a-468d-a302-342c233d1346  ethernet  ens1f0
bond0-slave-ens1f1  321aa982-5ca0-4379-b822-4200f366cc27  ethernet  ens1f1
```

### 添加dummy网卡并配置多个IP地址

再举个dummy网卡的例子，因为有其他部门目前在用DR模式的LVS负载均衡，所以需要配置dummy网卡和IP地址，之前也稍微看了看，也比较简单：

```
[root@localhost ~]# nmcli connection add type dummy con-name dummy-dummy0 ifname dummy0 ipv4.method manual ipv4.addresses "1.1.1.1/32,2.2.2.2/32,3.3.3.3/32,4.4.4.4/32"
Connection 'dummy-dummy0' (e02daf93-d1bc-4ec7-a985-7435426129be) successfully added.
[root@localhost ~]# nmcli connection
NAME          UUID                                  TYPE      DEVICE
System eth0   5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
dummy-dummy0  e02daf93-d1bc-4ec7-a985-7435426129be  dummy     dummy0
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether fa:16:3e:a6:14:86 brd ff:ff:ff:ff:ff:ff
    inet 10.185.14.232/24 brd 10.185.14.255 scope global dynamic noprefixroute eth0
       valid_lft 314568640sec preferred_lft 314568640sec
    inet6 fe80::f816:3eff:fea6:1486/64 scope link
       valid_lft forever preferred_lft forever
5: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether e6:ff:39:ca:c7:91 brd ff:ff:ff:ff:ff:ff
    inet 1.1.1.1/32 scope global noprefixroute dummy0
       valid_lft forever preferred_lft forever
    inet 2.2.2.2/32 scope global noprefixroute dummy0
       valid_lft forever preferred_lft forever
    inet 3.3.3.3/32 scope global noprefixroute dummy0
       valid_lft forever preferred_lft forever
    inet 4.4.4.4/32 scope global noprefixroute dummy0
       valid_lft forever preferred_lft forever
    inet6 fe80::ad93:23f1:7913:b741/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

需要注意的是，一个连接是可以配置多个IP地址的，多个IP地址之间用`,`​分割就可以了。

### 配置Bond+Bridge

Bond+Bridge的配置在虚拟化场景比较常见，需要注意的是，有了Bridge之后，IP地址需要配置到Bridige上。

```
[root@localhost ~]# nmcli connection add type bridge con-name bridge-br0 ifname br0 ipv4.method manual ipv4.addresses 192.168.100.10 ipv4.gateway 192.168.100.1
Connection 'bridge-br0' (6052d8ca-ed8f-474b-88dd-9414bf028a2c) successfully added.
```

此时创建了一个网桥br0，但是还没有任何接口连接到这个网桥上，下面需要创建个bond0口，并把bond0加到br0上。

```
[root@localhost ~]# nmcli connection add type bond con-name bonding-bond0 ifname bond0 bond.options "mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4,updelay=5000" connection.master br0 connection.slave-type bridge
Connection 'bonding-bond0' (755f0c93-6638-41c1-a7de-5e932eba6d1f) successfully added.
```

这里配置比较特殊，创建bond口和上面差不多，但是多了点配置`connection.master br0 connection.slave-type bridge`​，这个和普通的bridge-slave口直接指定`master br0`​的方式不太一样，因为bond0也是个虚拟的接口，所以需要将接口的属性`connection.master`​配置成br0，才能实现把bond0这个虚拟接口添加到br0的功能。

后面bond0添加两个slave口还是和之前没有区别：

```
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f0 ifname ens1f0 master bond0
Connection 'bond0-slave-ens1f0' (7ec188d0-d2db-4f80-a6f9-b7f93ab873f5) successfully added.
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f1 ifname ens1f1 master bond0
Connection 'bond0-slave-ens1f1' (655c2960-0532-482a-8227-8b98eb7f829b) successfully added.
[root@localhost ~]# nmcli connection
NAME                UUID                                  TYPE      DEVICE
bridge-br0          6052d8ca-ed8f-474b-88dd-9414bf028a2c  bridge    br0
bond0-slave-ens1f0  7ec188d0-d2db-4f80-a6f9-b7f93ab873f5  ethernet  ens1f0
bond0-slave-ens1f1  655c2960-0532-482a-8227-8b98eb7f829b  ethernet  ens1f1
bonding-bond0       755f0c93-6638-41c1-a7de-5e932eba6d1f  bond      bond0
```

### 配置Bond+OVS Bridge

好了，地狱级难度的例子来了，想要利用NetworkManager来管理OVS Bridge，这该怎么做？这个场景是我们线上在用的，实验了很多次，总算找到办法解决了。

首先，需要安装`NetworkManager-ovs`​这个包，这个包是NetworkManager支持OVS的插件，所以得安装并重启NetworkManager服务后生效：

```
[root@localhost ~]# yum install -y NetworkManager-ovs && systemctl restart NetworkManager
```

第二步，需要创建一个`ovs-bridge`​，但是呢，这里有个坑，在`man nm-openvswitch`​里也有一些说明：

> * NetworkManager only ever talks to a single OVSDB instance via an UNIX domain socket.
> * The configuration is made up of Bridges, Ports and Interfaces. Interfaces are always enslaved to Ports, and Ports are
>   always enslaved to Bridges.
> * NetworkManager only creates Bridges, Ports and Interfaces you ask it to. Unlike ovs-vsctl, it doesn’t create the local
>   interface nor its port automatically.
> * You can’t enslave Interface directly to a Bridge. You always need a Port, even if it has just one interface.
> * There are no VLANs. The VLAN tagging is enabled by setting a ovs-port.tag property on a Port.
> * There are no bonds either. The bonding is enabled by enslaving multiple Interfaces to a Port and configured by setting
>   properties on a port.

> Bridges
> Bridges are represented by connections of ovs-bridge type. Due to the limitations of OVSDB, “empty” Bridges (with no
> Ports) can’t exist. NetworkManager inserts the records for Bridges into OVSDB when a Port is enslaved.
>
> Ports
> Ports are represented by connections of ovs-port type. Due to the limitations of OVSDB, “empty” Ports (with no Interfaces)
> can’t exist. Ports can also be configured to do VLAN tagging or Bonding. NetworkManager inserts the records for Ports into
> OVSDB when an Interface is enslaved. Ports must be enslaved to a Bridge.
>
> Interfaces
> Interfaces are represented by a connections enslaved to a Port. The system interfaces (that have a corresponding Linux
> link) have a respective connection.type of the link (e.g. “wired”, “bond”, “dummy”, etc.). Other interfaces (“internal” or
> “patch” interfaces) are of ovs-interface type. The OVSDB entries are inserted upon enslavement to a Port.

怎么理解呢，首先NetworkManager之和OVSDB通信，而OVSDB是有些限制的：1. 不允许空Bridge（没有任何Port）存在；2. 不允许空Port（没有任何Interface）存在；3. 不能直接将一个Interface接到Bridge上，必须有对应的Port才行。

不明白也没事，看下面的例子就好，首先我们要创建一个OVS Bridge ovsbr0：

```
[root@localhost ~]# nmcli connection add type ovs-bridge con-name ovs-br0 conn.interface-name ovsbr0
Connection 'ovs-br0' (c409c13a-3bc3-42fc-a6f2-79cb315fd26b) successfully added.
[root@localhost ~]# nmcli connection add  type ovs-port con-name ovs-br0-port0 conn.interface-name br0-port0 master ovsbr0
Connection 'ovs-br0-port0' (32982ce8-41ec-44e9-8010-da80bbefa5d4) successfully added.
[root@localhost ~]# nmcli conn add type ovs-interface slave-type ovs-port conn.interface-name ovsbr0-iface0 master br0-port0 ipv4.method manual ipv4.address 192.168.2.100/24
Connection 'ovs-slave-ovsbr0-iface0' (f8ba0e5e-c136-4287-aede-e4d59031d878) successfully added.
```

请注意，这三个connection必须完整创建好，才能真正的创建ovsbr0，这个和我们平常意识的逻辑很不一样。如果直接用`ovs-vsctl`​命令创建，那只需要执行`ovs-vsctl add-br ovsbr0`​就行了，然而在NetworkManager里，你必须把详细的内部逻辑拆分开：1. 创建个OVS Bridge ovsbr0；2. 在ovsbr0上创建个Port br0-port0；3. 创建个interface ovsbr0-iface0并连接到br0-port0上。

如此看来，ovs-vsctl命令行的操作把很多细节给隐藏掉了。

按照步骤创建上面三个connection之后，可以看到ovsbr0被创建好了：

```
[root@localhost ~]# nmcli connection
NAME                     UUID                                  TYPE           DEVICE
ovs-slave-ovsbr0-iface0  f8ba0e5e-c136-4287-aede-e4d59031d878  ovs-interface  ovsbr0-iface0
ovs-br0                  c409c13a-3bc3-42fc-a6f2-79cb315fd26b  ovs-bridge     ovsbr0
ovs-br0-port0            32982ce8-41ec-44e9-8010-da80bbefa5d4  ovs-port       br0-port0
[root@localhost ~]# ovs-vsctl show
a2ab0cdf-9cf1-41a5-99f4-ae81c58e3fa8
    Bridge ovsbr0
        Port br0-port0
            Interface ovsbr0-iface0
                type: internal
    ovs_version: "2.13.1"
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
10: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ca:cb:22:a1:a7:fb brd ff:ff:ff:ff:ff:ff
11: ovsbr0-iface0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether c2:51:c2:2b:6d:b5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.100/24 brd 192.168.2.255 scope global noprefixroute ovsbr0-iface0
       valid_lft forever preferred_lft forever
```

创建好ovsbr0之后，需要把bond0也加进去，如果是ovs-vsctl命令操作的话，直接`ovs-vsctl add-port ovsbr0 bond0`​就行了，ovs-vsctl帮我们隐藏了细节。同样的操作如果用NetworkManager，就需要先创建一个Port，然后再把bond0加到这个Port上了：

```
[root@localhost ~]# nmcli connection add type ovs-port con-name ovs-br0-port-bond0 conn.interface-name br0-bond0 master ovsbr0
Connection 'ovs-br0-port-bond0' (de863ea6-4e1b-4343-93a3-91790895256f) successfully added.
[root@localhost ~]# nmcli connection add type bond con-name bonding-bond0 ifname bond0 bond.options "mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4,updelay=5000" connection.master br0-bond0 connection.slave-type ovs-port
Connection 'bonding-bond0' (8b233d53-65b1-4237-b835-62135bb66ada) successfully added.
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f0 ifname ens1f0 master bond0
Connection 'bond0-slave-ens1f0' (6d5febe2-fc65-428a-94f1-9a782cd6b397) successfully added.
[root@localhost ~]# nmcli connection add type bond-slave con-name bond0-slave-ens1f1 ifname ens1f1 master bond0
Connection 'bond0-slave-ens1f1' (55ce8e7f-233d-430f-901d-f0e5f326c8c7) successfully added.
[root@localhost ~]# nmcli connection
NAME                     UUID                                  TYPE           DEVICE
ovs-slave-ovsbr0-iface0  f8ba0e5e-c136-4287-aede-e4d59031d878  ovs-interface  ovsbr0-iface0
bond0-slave-ens1f0       6d5febe2-fc65-428a-94f1-9a782cd6b397  ethernet       ens1f0
bond0-slave-ens1f1       55ce8e7f-233d-430f-901d-f0e5f326c8c7  ethernet       ens1f1
bonding-bond0            8b233d53-65b1-4237-b835-62135bb66ada  bond           bond0
ovs-br0                  c409c13a-3bc3-42fc-a6f2-79cb315fd26b  ovs-bridge     ovsbr0
ovs-br0-port0            32982ce8-41ec-44e9-8010-da80bbefa5d4  ovs-port       br0-port0
ovs-br0-port-bond0       de863ea6-4e1b-4343-93a3-91790895256f  ovs-port       br0-bond0
[root@localhost ~]# ovs-vsctl show
a2ab0cdf-9cf1-41a5-99f4-ae81c58e3fa8
    Bridge ovsbr0
        Port br0-port0
            Interface ovsbr0-iface0
                type: internal
        Port br0-bond0
            Interface bond0
                type: system
    ovs_version: "2.13.1"
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens1f0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether 0c:42:a1:70:c7:2a brd ff:ff:ff:ff:ff:ff
3: ens1f1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether 0c:42:a1:70:c7:2a brd ff:ff:ff:ff:ff:ff
4: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ca:cb:22:a1:a7:fb brd ff:ff:ff:ff:ff:ff
5: ovsbr0-iface0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether c2:51:c2:2b:6d:b5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.100/24 brd 192.168.2.255 scope global noprefixroute ovsbr0-iface0
       valid_lft forever preferred_lft forever
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue master ovs-system state UP group default qlen 1000
    link/ether 0c:42:a1:70:c7:2a brd ff:ff:ff:ff:ff:ff
```

可以看到，NetworkManager和直接用ovs-ctl最大的不同，就是把一些细节暴露了出来，本质上把一个接口加到Bridge上不是直接加的，而是加到了Bridge的某个Port上。但是仔细一想也没毛病，对应到现实世界的交换机，你接接线也是接到交换机的某个端口上，如果没有端口，那线往哪插呢？

### 配置持久化

好了，上面举了很多例子实现了一些我们可能会用到的场景，但是一大堆问题又来了，这些配置能持久化么？重启了机器之后还会有么？如果有，那这些配置是保存在哪里的？我能不能不用nmcli这个命令行工具了，使用配置文件，能完成网络的配置么？

这些问题的答案都是肯定的！

首先呢，针对老版本network-scripts，也就是存放在`/etc/sysconfig/network-scripts/`​目录下的那些ifcfg-*开头的配置文件，NetworkManager通过一个ifcfg-rh plugin去识别，这个插件在RHEL里是默认开启的，而且，针对一些配置类型，比如ethernet，bond，vlan，bridge等配置，通过nmcli创建或者修改connections，都会同步到这个目录下对应的配置文件里：

```
[root@localhost ~]# nmcli connection
NAME           UUID                                  TYPE      DEVICE
eth0-static    3ae60979-d6f1-4dbb-8a25-ff1178e7305c  ethernet  eth0
eth1-vlan-100  7bc246cb-140a-4515-8dc1-8efa03b789cb  vlan      eth1.100
bridge-br0     3230425c-505d-4a97-adbe-6f26e27fe53c  bridge    br0
eth0           72534820-fb8e-4c5a-8d49-8c013441d390  ethernet  --
[root@localhost ~]# ls -l /etc/sysconfig/network-scripts/
total 16
-rw-r--r--. 1 root root 372 Feb 20 15:13 ifcfg-bridge-br0
-rw-r--r--. 1 root root 278 Feb 11 22:02 ifcfg-eth0
-rw-r--r--. 1 root root 360 Feb 17 18:34 ifcfg-eth0-static
-rw-r--r--. 1 root root 415 Feb 20 16:11 ifcfg-eth1-vlan-100
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=eth0
UUID=72534820-fb8e-4c5a-8d49-8c013441d390
DEVICE=eth0
ONBOOT=yes
```

可以看到每个_connection_都对应了一个配置文件。

然后NetworkManager还会读取`/etc/NetworkManager/system-connections/`​目录下的配置文件，同时，通过nmcli创建和修改一些其他类型的connections，比如ovs-bridge， dummy这些，也会同步写入到这个目录下：

```
[root@localhost ~]# nmcli connection
NAME           UUID                                  TYPE      DEVICE
eth0-static    3ae60979-d6f1-4dbb-8a25-ff1178e7305c  ethernet  eth0
dummy-dummy0   190f363b-190b-4b98-b85c-046ec8995453  dummy     dummy0
eth1-vlan-100  7bc246cb-140a-4515-8dc1-8efa03b789cb  vlan      eth1.100
bridge-br0     3230425c-505d-4a97-adbe-6f26e27fe53c  bridge    br0
eth0           72534820-fb8e-4c5a-8d49-8c013441d390  ethernet  --
[root@localhost ~]# ls -l /etc/NetworkManager/system-connections/
total 4
-rw-------. 1 root root 310 Feb 20 16:16 dummy-dummy0.nmconnection
[root@localhost ~]# cat /etc/NetworkManager/system-connections/dummy-dummy0.nmconnection
[connection]
id=dummy-dummy0
uuid=190f363b-190b-4b98-b85c-046ec8995453
type=dummy
interface-name=dummy0
permissions=

[dummy]

[ipv4]
address1=1.1.1.1/32
address2=2.2.2.2/32
address3=3.3.3.3/32
address4=4.4.4.4/32
dns-search=
method=manual

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]
```

可以看到dummy-dummy0的配置被持久化在`/etc/NetworkManager/system-connections/`​。

所以如果要修改配置，也是可以到这两个对应目录下直接修改对应的配置文件的。但是这里有个小问题，就是修改配置文件后，NetworkManager不会自动重新加载这些配置，需要手动执行`nmcli connection load XXXX`​手动重载单个配置或者执行`nmcli connection reload`​重新加载所有的配置文件。加载完成后，要想配置真正生效，还需要执行`nmcli connection down XXXX; nmcli connection up XXXX`​或者`nmcli device reapply XXX`​来真正让配置生效。

### Leave Me Alone！

说了这么多，还有一件很重要的事还没说：假如我真的不希望NetworkManager帮我管理某些网卡，怎么办？因为默认情况下，NetworkManager会自动得把很多设备的纳入管理，然后自动创建一堆`Wired connection`​，就像这样：

```
[root@localhost ~]# nmcli connection
NAME                UUID                                  TYPE      DEVICE
eth0                72534820-fb8e-4c5a-8d49-8c013441d390  ethernet  eth0
Wired connection 1  3a8d6eb9-9d38-3c38-9519-4918f58ee42c  ethernet  ens1f0_0
Wired connection 2  d0efb693-45d0-4245-8018-6738f7509094  ethernet  ens1f0_1
Wired connection 3  b3ecf462-a0ed-4f08-a203-c4f10b4dde0b  ethernet  ens1f0_2
Wired connection 4  5f0ca36b-2add-4815-a859-ff651238f893  ethernet  ens1f0_3
Wired connection 5  3f010d3e-74ba-405c-a575-eba53641fe4f  ethernet  ens1f0_4
Wired connection 6  88e4d303-fd6b-4f66-9e4e-6743ec47c8b7  ethernet  ens1f0_5
Wired connection 7  2800a439-44e1-4304-9c2c-dedbbba74c40  ethernet  ens1f0_6
Wired connection 8  21ae8892-8a51-4c77-854c-08e9857e32d9  ethernet  ens1f0_7
```

在我们的SR-IOV场景下更是这样，因为开启SR-IOV之后，会创建很多的网卡，然后NetworkManager不分青红皂白，全部给管理上，让人头大。所以需要一个配置能通知NetworkManager哪些网卡不需要纳入管理。

还好NetworkManager提供了这个配置项，可以声明哪些网卡不被管理：在`/etc/NetworkManager/conf.d/`​目录下创建`unmanaged.conf`​

```
[root@localhost ~]# cat /etc/NetworkManager/conf.d/unmanaged.conf
[keyfile]
unmanaged-devices=mac:00:1E:65:30:D1:C4;interface-name:eth1;interface-name:ens1f0_*
```

具体的匹配规则有很多，可以参考`man NetworkManager.conf`​的`Device List Format`​部分，这里就不在赘述了。

重启生效后，瞬间清净了：

```
[root@localhost ~]# nmcli device
DEVICE    TYPE      STATE      CONNECTION
eth0      ethernet  connected  eth0
ens1f0_0  ethernet  unmanaged  --
ens1f0_1  ethernet  unmanaged  --
ens1f0_2  ethernet  unmanaged  --
ens1f0_3  ethernet  unmanaged  --
lo        loopback  unmanaged  --
```

‍

# netsh

netsh(全称：Network Shell) 是windows下内置的一个功能强大的网络配置命令行工具。

## 使用技巧

执行netsh设置可以分为“全命令操作”和“特定提示符下操作”，两者最终效果一样。
在不熟悉`netsh`​工具的情况下，后者是个不错的学习方案。

例如：
从系统提示符进入`netsh`​提示符:

```
C:\Users\WQT>netsh
netsh>
```

当需要获得帮助时，输入`?`​或`help`​关键字，然后回车即可：

```
netsh> ?
netsh> help
```

上述只是获得当前层级的帮助信息，如需获得二级、三级等命令下的帮助信息，只需进入到该命令下，使用同样的`?`​或`help`​方法，即可获得对应层级的帮助：

```
netsh>interface          # 进入interface设置
netsh interface>?        # 获取interface帮助信息
netsh interface>ipv4     # 进入ipv4设置
netsh interface ipv4>?   # 获取ipv4 帮助信息
```

当需要退出 netsh 工具时，使用`bye`​或`quit`​即可退出:

```
netsh interface ipv4>bye
或
netsh interface ipv4>quit
```

上述操作均是在“特定提示符下操作”，待执行命令依赖于当前提示符，书写指令时，只需书写当前级下提供的指令即可。而“全命令操作”常指从 netsh 根命令开始书写指令，例如：`netsh interface ip show addresses`​ (功能：显示ip地址配置信息)。

PS：在 netsh 配置中，同样适用短命令格式，如：`netsh interface ip show addresses`​ 等价于 `netsh int ip show addresses`​

## 查看网络配置

```
netsh interface ip show {选项}
```

{选项}信息可以使用`netsh interface ip show ?`​查询得到：

```bat
show addresses           显示 IP 地址配置。
show compartments        显示分段参数。
show config              显示 IP 地址和其他信息。
show destinationcache    显示目标缓存项目。
show dnsservers          显示 DNS 服务器地址。
show dynamicportrange    显示动态端口范围配置参数。
show excludedportrange   显示所有排除的端口范围。
show global              显示全局配置普通参数。
show icmpstats           显示 ICMP 统计。
show interfaces          显示接口参数。
show ipaddresses         显示当前 IP 地址。
show ipnettomedia        显示 IP 的网络到媒体的映射。
show ipstats             显示 IP 统计。
show joins               显示加入的多播组。
show neighbors           显示邻居缓存项。
show offload             显示卸载信息。
show route               显示路由表项目。
show subinterfaces       显示子接口参数。
show tcpconnections      显示 TCP 连接。
show tcpstats            显示 TCP 统计。
show udpconnections      显示 UDP 连接。
show udpstats            显示 UDP 统计。
show winsservers         显示 WINS 服务器地址。
```

例如，查看本机IP地址信息：

```
netsh interface ip show address
```

## 启用/禁用网卡

```
netsh interface set interface wlan0 disabled   # 禁用无线网卡
netsh interface set interface wlan0 enabled    # 启用无线网卡
netsh interface set interface eth0 disabled    # 禁用有线网卡
netsh interface set interface eth0 enabled     # 启用有线网卡
```

## 网络配置

## 获取帮助信息

```
netsh interface ipv4 ?     # ipv4 配置帮助(缺省v4时，默认为v4协议)
netsh interface ipv6 ?     # ipv6 配置帮助
```

## IP/gateway设置

```bash
netsh interface ip set
	name
	address
	mask
	gateway
	source [static | dhcp]
	gwmetric [auto | number]
	store
		active       # 下一次启动时消失
		persistent   # 永久有效

netsh interface ip add
	name
	address
	mask
	store
		active       # 下一次启动时消失
		persistent   # 永久有效
	skipassource [false | true]
```

```powershell
netsh interface ip set address name="Ethernet0" source=dhcp    # 自动获取 ip
# set VIP
netsh interface ip set address name="Ethernet0" source=static address=192.168.0.10 mask=255.255.255.0 gateway=192.168.1.1 gwmetric=1 store=active 

# 首先set vip 临时有效
netsh interface ip set address source=static name="本地连接" addr=192.168.1.10 mask=255.255.255.0 gateway=192.168.1.1 gwmetric=1 store=active
# 再 add 管理ip 永久有效
netsh interface ip set address name="本地连接" addr=10.10.1.10 mask=255.255.255.0 gateway=10.101.1 gwmetric=1  store=persistent skipassource=true

```

### Add an IP Using Skip as source使用 Skip 作为源添加 IP

**问题描述：**

在window环境下（windows server2008/vista及以上版本）中，绑定了辅助IP后，主动外访时有可能不再走主IP。

微软官方镜像的IP选择策略发生了变化：windows server08/Vista之前的版本，会默认从第一个add到网卡的IP出去。

而windows server2008/Vista 及其之后的版本（包括windows server2008、windows server2012、windows server2016、windows 7等），会遵循以下方式：

- Rule 1： Prefer same address (applies)
- Rule 2： Prefer appropriate scope (applies)
- Rule 3： Avoid deprecated addresses (applies)
- Rule 4： Prefer home addresses - does not apply to IP v4
- Rule 5： Prefer outgoing Interfaces (applies)
- Rule 6： Prefer matching label - does not apply to IP v4
- Rule 7： Prefer public addresses - does not apply to IP v4
- Rule 8: **Use longest matching prefix with the next hop IP address.**

**根据规则8，如果主IP与下一跳IP的 matching prefix（前缀匹配） 短于辅助IP与下一跳的 matching prefix ，那辅助IP的优先级会高于主IP，packet 就会由辅助IP发送。**

本示例案例中，辅助IP（10.10.20.30）与下一条（即网关10.10.20.1）的 matching prefix 更长，因此流量不再走主IP。

![prefix+code](assets/prefix+code-20240412145510-orque79.png)

**设置方法**

```bash
# server 2008
netsh int ipv4 add address <Interface Name> <ip address> <subnet mask> skipassource=true
# server 2012
netsh int ipv4 add address <Interface Name> <ip address> skipassource=true
```

> windows server2008/Vista 之前的版本         先add添加的ip就是出口
>
> windows server2008/Vista 及其之后的版本   默认是ip小的优先（最后一个数值）

‍

‍

## 重置ip配置

```bat
netsh interface ip reset      # 重置ipv4信息
netsh interface ipv6 reset    # 重置ipv6信息
```

‍

## DNS设置

```
etsh interface ip set dnsservers name="适配器名称" source=dhcp    # 自动获取 dns
netsh interface ip set dnsservers name="适配器名称" source=static address=114.114.114.114 register=PRIMARY    # 固定DNS(主：primary)
```

## Wins设置

```bat
netsh interface ip set winsservers name="适配器名称" source=dhcp                 # 自动获取 wins
netsh interface ip set winsservers name="适配器名称" source=static 10.1.2.200    # 固定 wins
```

## 使用配置文件快速添加配置

```bat
netsh -c interface ip dump > c:\interface.txt    #导出所有网口ipv4配置信息到文件
netsh -f c:\interface.txt                        #从文件导入配置ip配置信息(或：netsh exec c:\interface.txt)
```

## http代理

```
netsh winhttp show proxy      # 查看当前代理设置
netsh winhttp reset proxy     # 重置代理服务器
netsh winhttp import proxy source=ie    # 从ie(本地)导入代理设置
netsh winhttp set proxy proxy-server="http=myproxy;https=sproxy:88" bypass-list="*.foo.com"    # 设定代理
```

设定 winhttp 语法：

```
netsh winhttp set proxy [proxy-server=]<server name> [bypass-list=]<hosts list>
```

参数:

- proxy-server ：http 和/或 https 协议使用的代理服务器
- bypass-list ：绕过代理服务器访问的站点列表(使用 "<local>" 绕过所有短名称主机)

## sock代理

```
netsh winsock reset    # 重置sock代理
```

更多操作： netsh winsock ?

## 端口转发

- 查看：显示所有 portproxy 信息(默认：无)

```
netsh interface portproxy show all
```

- 添加：监听任意IP来源(\*),且是连接到本机65531端口的数据,将其所有TCP协议的数据流量转发到192.168.1.53的22端口

```
netsh interface portproxy add v4tov4 listenport=65531 connectaddress=192.168.1.53 connectport=22 listenaddress=* protocol=tcp
```

- 删除

```
netsh interface portproxy delete v4tov4 listenport=65531 listenaddress=* protocol=tcp
```

更多参考官文：[点这](https://docs.microsoft.com/en-us/windows-server/networking/technologies/netsh/netsh-interface-portproxy)

## wifi 热点设置

```
netsh wlan show drivers # 判断网卡是否支持承载网

netsh wlan set hostednetwork mode=allow ssid=wifiname key=wifipassword    # 设置wifi热点
mode：[allow/disallow]
ssid: wifi name
key: wifi password

netsh wlan start hostednetwork # 启动承载网
netsh wlan stop hostednetwork  # 停止承载网
netsh wlan show hostednetwork  # 查看
```

‍

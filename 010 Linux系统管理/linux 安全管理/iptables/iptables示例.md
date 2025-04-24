# iptables示例

### 1. 清空当前的所有规则和计数

```bash
iptables -F  # 清空所有的防火墙规则
iptables -X  # 删除用户自定义的空链
iptables -Z  # 清空计数
```

### 2. 配置允许 ssh 端口连接

```bash
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
# 22为你的ssh端口， -s 192.168.1.0/24表示允许这个网段的机器来连接，其它网段的ip地址是登陆不了你的机器的。 -j ACCEPT表示接受这样的请求
```

### 3. 允许本地回环地址可以正常使用

```bash
iptables -A INPUT -i lo -j ACCEPT
#本地圆环地址就是那个127.0.0.1，是本机上使用的,它进与出都设置为允许
iptables -A OUTPUT -o lo -j ACCEPT
```

### 4. 设置默认的规则

```shell
iptables -P INPUT DROP # 配置默认的不让进
iptables -P FORWARD DROP # 默认的不允许转发
iptables -P OUTPUT ACCEPT # 默认的可以出去
```

### 5. 配置白名单

```bash
iptables -A INPUT -p all -s 192.168.1.0/24 -j ACCEPT  # 允许机房内网机器可以访问
iptables -A INPUT -p all -s 192.168.140.0/24 -j ACCEPT  # 允许机房内网机器可以访问
iptables -A INPUT -p tcp -s 183.121.3.7 --dport 3380 -j ACCEPT # 允许183.121.3.7访问本机的3380端口
```

### 6. 开启相应的服务端口

```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT # 开启80端口，因为web对外都是这个端口
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT # 允许被ping
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT # 已经建立的连接得让它进来
```

### 7. 保存规则到配置文件中

```shell
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.bak # 任何改动之前先备份，请保持这一优秀的习惯
iptables-save > /etc/sysconfig/iptables
cat /etc/sysconfig/iptables
```

### 8. 列出已设置的规则

> iptables -L [-t 表名][链名]

* 四个表名 `raw`​，`nat`​，`filter`​，`mangle`​
* 五个规则链名 `INPUT`​、`OUTPUT`​、`FORWARD`​、`PREROUTING`​、`POSTROUTING`​
* filter 表包含`INPUT`​、`OUTPUT`​、`FORWARD`​三个规则链

```bash
iptables -L -t nat                  # 列出 nat 上面的所有规则
#            ^ -t 参数指定，必须是 raw， nat，filter，mangle 中的一个
iptables -L -t nat  --line-numbers  # 规则带编号
iptables -L INPUT

iptables -L -nv  # 查看，这个列表看起来更详细
```

### 9. 清除已有规则

```bash
iptables -F INPUT  # 清空指定链 INPUT 上面的所有规则
iptables -X INPUT  # 删除指定的链，这个链必须没有被其它任何规则引用，而且这条上必须没有任何规则。
                   # 如果没有指定链名，则会删除该表中所有非内置的链。
iptables -Z INPUT  # 把指定链，或者表中的所有链上的所有计数器清零。
```

### 10. 删除已添加的规则

```bash
# 添加一条规则
iptables -A INPUT -s 192.168.1.5 -j DROP
# 将所有 iptables 以序号标记显示，执行：
iptables -L -n --line-numbers
# 比如要删除 INPUT 里序号为 8 的规则，执行：
iptables -D INPUT 8
```

### 11. 开放指定的端口

```bash
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT               #允许本地回环接口(即运行本机访问本机)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT    #允许已建立的或相关连的通行
iptables -A OUTPUT -j ACCEPT         #允许所有本机向外的访问
iptables -A INPUT -p tcp --dport 22 -j ACCEPT    #允许访问22端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT    #允许访问80端口
iptables -A INPUT -p tcp --dport 21 -j ACCEPT    #允许ftp服务的21端口
iptables -A INPUT -p tcp --dport 20 -j ACCEPT    #允许FTP服务的20端口
iptables -A INPUT -j reject       #禁止其他未允许的规则访问
iptables -A FORWARD -j REJECT     #禁止其他未允许的规则访问
```

### 12. 屏蔽 IP

```bash
iptables -A INPUT -p tcp -m tcp -s 192.168.0.8 -j DROP  # 屏蔽恶意主机（比如，192.168.0.8
iptables -I INPUT -s 123.45.6.7 -j DROP       #屏蔽单个IP的命令
iptables -I INPUT -s 123.0.0.0/8 -j DROP      #封整个段即从123.0.0.1到123.255.255.254的命令
iptables -I INPUT -s 124.45.0.0/16 -j DROP    #封IP段即从123.45.0.1到123.45.255.254的命令
iptables -I INPUT -s 123.45.6.0/24 -j DROP    #封IP段即从123.45.6.1到123.45.6.254的命令是
```

### 13. 指定数据包出去的网络接口

只对 OUTPUT，FORWARD，POSTROUTING 三个链起作用。

```bash
iptables -A FORWARD -o eth0
```

### 14. 查看已添加的规则

```bash
iptables -nvL
Chain INPUT (policy DROP 48106 packets, 2690K bytes)
 pkts bytes target     prot opt in     out     source               destination
 5075  589K ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
 191K   90M ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:22
1499K  133M ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:80
4364K 6351M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
 6256  327K ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 3382K packets, 1819M bytes)
 pkts bytes target     prot opt in     out     source               destination
 5075  589K ACCEPT     all  --  *      lo      0.0.0.0/0            0.0.0.0/0

```

### 15. 启动网络转发规则

公网`210.14.67.7`​让内网`192.168.188.0/24`​上网

```bash
# 添加nat规则，对所有源地址（openvpn为客户端分配的地址）为10.66.1.0/24的数据包转发后进行源地址伪装，伪装成openvpn服务器内网地址192.168.1.1，这样就可以和内网的其它机器通信了。
iptables -t nat -A POSTROUTING -s 10.66.1.0/24 -j SNAT --to-source 192.168.1.1

iptables -t nat -A POSTROUTING -s 10.66.1.0/24 -o eth0 -j MASQUERADE
```

### 16. 端口映射

本机的 2222 端口映射到内网 虚拟机的 22 端口

```bash
# 开启数据转发功能
vi /etc/sysctl.conf
net.ipv4.ip_forward=1
sysctl -p
 
# 将本地的端口转发到本机端口
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j REDIRECT --to-port 22
 
# 将本机的端口转发到其他机器
iptables -t nat -A PREROUTING -d 192.168.172.130 -p tcp --dport 8000 -j DNAT --to-destination 192.168.172.131:80
iptables -t nat -A POSTROUTING -d 192.168.172.131 -p tcp --dport 80 -j SNAT --to 192.168.172.130
 
# 清空nat表的所有链
iptables -t nat -F PREROUTING

# 在linux使用iptable转发端口9876端口到windows的3389端口
nc -lk 9876 &
iptables -t nat -A PREROUTING  -p tcp --dport 9876  -j DNAT --to-dest 192.168.3.101:3389
```

### 17. 字符串匹配

比如，我们要过滤所有 TCP 连接中的字符串`test`​，一旦出现它我们就终止这个连接，我们可以这么做：

```bash
iptables -A INPUT -p tcp -m string --algo kmp --string "test" -j REJECT --reject-with tcp-reset
iptables -L

# Chain INPUT (policy ACCEPT)
# target     prot opt source               destination
# REJECT     tcp  --  anywhere             anywhere            STRING match "test" ALGO name kmp TO 65535 reject-with tcp-reset
#
# Chain FORWARD (policy ACCEPT)
# target     prot opt source               destination
#
# Chain OUTPUT (policy ACCEPT)
# target     prot opt source               destination
```

### 18. 阻止 Windows 蠕虫的攻击

```bash
iptables -I INPUT -j DROP -p tcp -s 0.0.0.0/0 -m string --algo kmp --string "cmd.exe"
```

### 19. 防止 SYN 洪水攻击

```bash
iptables -A INPUT -p tcp --syn -m limit --limit 5/second -j ACCEPT
```

### 20.网络防火墙

主机防火墙：针对于单个主机进行防护。  
网络防火墙： 往往处于网络入口或边缘，针对于网络入口进行防护，服务于防火墙背后的本地局域网。  
在前面的举例中，iptables都是作为主机防火墙的角色出现的。

![](assets/Pasted%20image%2020221205221216-20230610173810-zyvds06.png)

```bash
# 配置网关，将内网C主机的网关指向防火墙B主机上的网卡1
----------------------------------------------------
IPADDR=10.1.0.1
PREFIX=24
GATEWAY=10.1.0.3
DNS1=10.1.0.3
---------------------------------------------------
# 为了简化路由，将主机A访问10.1.0网络时的网关指向B主机的网卡2上的IP
route add -net 10.1.0.0/24 gw 192.168.1.146

# 此时我们直接在A主机上向C主机发起ping请求，并没有得到任何回应。
# 但是直接在A主机上向B主机的内部网IP发起ping请求，发现是可以ping通的
# 此时需要在B主机上开启报文转发,使用如下方法开启核心转发功能，永久生效。
配置/etc/sysctl.conf文件,在配置文件中将 net.ipv4.ip_forward设置为1


#由于iptables此时的角色为"网络防火墙"，所以需要在FORWARD链的filter表中设置规则。
#可以使用"白名单机制"，先添加一条默认拒绝的规则，然后再为需要放行的报文设置规则。
#配置规则时需要考虑"方向问题"，针对请求报文与回应报文，考虑报文的源地址与目标地址，源端口与目标端口等。

#示例为允许内网主机访问外网主机的web服务与sshd服务。

iptables -A FORWARD -j REJECT

iptables -I FORWARD -s 10.1.0.0/24 -p tcp --dport 80 -j ACCEPT
iptables -I FORWARD -d 10.1.0.0/24 -p tcp --sport 80 -j ACCEPT

iptables -I FORWARD -s 10.1.0.0/24 -p tcp --dport 22 -j ACCEPT
iptables -I FORWARD -d 10.1.0.00/24 -p tcp --sport 22 -j ACCEPT

#可以使用state扩展模块，对上述规则进行优化，使用如下配置可以省略许多"回应报文放行规则"。

iptables -A FORWARD -j REJECT

iptables -I FORWARD -s 10.1.0.0/24 -p tcp --dport 80 -j ACCEPT
iptables -I FORWARD -s 10.1.0.0/24 -p tcp --dport 22 -j ACCEPT
iptables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
```

一些注意点：  
1、当测试网络防火墙时，默认前提为网络已经正确配置。  
2、当测试网络防火墙时，如果出现问题，请先确定主机防火墙规则的配置没有问题。

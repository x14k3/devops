# nmap

Nmap 是一个网络连接端扫描软件，用来扫描网上电脑开放的网络连接端。确定哪些服务运行在哪些连接端，并且推断计算机运行哪个操作系统（这是亦称  fingerprinting）。它是网络管理员必用的软件之一，以及用以评估网络系统安全。它不局限于仅仅收集信息和枚举，同时可以用来作为一个漏洞探测器或安全扫描器。

## 特点

Nmap 对于网络检查的作用，应该相当于网址导航、搜索引擎的作用：入口。

* 检测活在网络上的主机（主机发现）
* 检测主机上开放的端口（端口发现或枚举）
* 检测到相应的端口（服务发现）的软件和版本
* 检测操作系统，硬件地址，以及软件版本
* 检测脆弱性的漏洞（Nmap 的脚本）

Nmap 使用不同的技术来执行扫描，包括：TCP 的 connect 扫描，TCP 反向的 ident 扫描，FTP 反弹扫描等。所有这些扫描的类型有自己的优点和缺点。

‍

在CentOS7 下，可以直接使用yum来进行安装，具体操作如下所示。

```
# 安装
yum -y install nmap
namp -v
```

## 参数详解

```bash
目标探测： 
  -iL #后面加IP列表文件，扫描IP列表文件的IP
  -iR #随机扫描目标，例如【nmap -iR 100 -p22】
  --exclude #排除网络段中的地址 例如【nmap 192.168.1.0/24 --exclude 192.168.0.1-100】
  --excludefile #把要排除的地址放入一个文件

主机发现: 
  -sL: #例出你想扫描的目标,可用于子网掩码计算  例如【nmap -sL 192.168.1.0/24】
  -sn: #不做端口扫描
  -Pn: #不管检测主机是否存活，都进行扫描
  -PS/PA/PU/PY\[portlist\]: #SYN发现/ACK发现/UDP发现/SCTP发现
  -PE/PP/PM: #ICMP echo/时间戳发现/查子网掩码（通常查不到）
  -PO\[protocol list\]: #用IP协议扫描
  -n/-R: #不做DNS解析/做DNS反向解析
  --dns-servers <serv1\[,serv2\],...>: #使用其他DNS地址去解析 例如【nmap --dns-servers 8.8.8.8 www.sina.com】
  --system-dns: #使用操作系统默认的DNS，加不加都是使用系统默认的
  --traceroute: #追踪路由  例如【nmap  www.baidu.com --traceroute】

端口发现:
  -sS/sT/sA/sW/sM: #SYN扫描/全连接TCP扫描/ACK扫描/TCP窗口扫描/Maimon扫描
  -sU: #UDP扫描
  -sN/sF/sX: #TCP flags全空/只带FIN/FIN,PSH,URG组合扫描
  --scanflags <flags>: #自定义TCP的flags
  -sI <zombie host\[:probeport\]>: #僵尸扫描
  -sY/sZ: #SCTP扫描使用的参数，用于VoIP
  -sO: #IP协议扫描
  -b <FTP relay host>: #FTP中继扫描

指定端口扫描:
  -p <port ranges>: #指定端口
    Ex: -p22; -p1-65535; -p U:53,111,137,T:21-25,80,139,8080,S:9 #U是UDP扫描T是TCP扫描
  --exclude-ports <port ranges>: #排除端口
  -F: #快速扫描模式
  -r: #连续扫描端口
  --top-ports <number>: #只扫描前面几个端口。例如【nmap 192.168.0.1 --top-ports 10 //扫描前十个端口】
  --port-ratio <ratio>: #扫描常见端口

服务扫描:
  -sV: #根据端口进行服务扫描
  --version-intensity <level>: #根据深入模式扫描，0-9级别的，与sV搭配使用
  --version-light: #以最低级别扫描
  --version-all: #以最高级别扫描
  --version-trace: #显示详细的扫描信息

脚本扫描:
  -sC:#指定什么脚本扫描
  --script=<Lua scripts>: #后面跟扫描脚本
  --script-args=<n1=v1,\[n2=v2,...\]>: #跟脚本参数
  --script-args-file=filename: #跟脚本文件参数扫描
  --script-trace: #显示所用的发送和接收数据
  --script-updatedb: #更新脚本数据库
  --script-help=<Lua scripts>: #获取如何使用脚本方法

系统扫描:
  -O: #进行系统扫描
  --osscan-limit: #限制扫描系统类型
  --osscan-guess: #猜测扫描

时间和性能扫描:
  #采取的选项<time>以秒为单位，或附加“毫秒”（毫秒）， “s”（秒）、“m”（分钟）或“h”（小时）到该值（例如 30m）.
  -T<0-5>: #设置计时模板（越高速度越快）
  --min-hostgroup/max-hostgroup <size>: #设置最少或最多扫描多少主机
  --min-parallelism/max-parallelism <numprobes>: #指定并行数量
  --min-rtt-timeout/max-rtt-timeout/initial-rtt-timeout <time>: #设置最小或最少的rtt时间
  --max-retries <tries>: #设置最大探测次数
  --host-timeout <time>: #设置超时时间
  --scan-delay/--max-scan-delay <time>: #设置扫描中间延迟时间
  --min-rate <number>:#扫描最小速率
  --max-rate <number>: #扫描最大速率

防火墙或IDS欺骗:
  -f; --mtu <val>: #设置Mtu值，以太网默认1500
  -D <decoy1,decoy2\[,ME\],...>: #增加噪声IP，虚假发包地址，作为源地址，迷惑对方
  -S <IP\_Address>: #伪造源地址扫描
  -e <iface>: #使用特定接口扫描
  -g/--source-port <portnum>: #指定源端口扫描
  --proxies <url1,\[url2\],...>: #使用代理服务器扫描
  --data <hex string>: #加数据字段，16进制
  --data-string <string>: #加ASCII码
  --data-length <num>: #指定数据长度
  --ip-options <options>: #加option字段
  --ttl <val>: #设置TTL值
  --spoof-mac <mac address/prefix/vendor name>:#欺骗MAC地址
  --badsum: #发送差错校验

输入格式:
  -oN/-oX/-oS/-oG <file>: Output scan in normal, XML, s|<rIpt kIddi3,
     and Grepable format, respectively, to the given filename.
  -oA <basename>: Output in the three major formats at once
  -v: Increase verbosity level (use -vv or more for greater effect)
  -d: Increase debugging level (use -dd or more for greater effect)
  --reason: Display the reason a port is in a particular state
  --open: Only show open (or possibly open) ports
  --packet-trace: Show all packets sent and received
  --iflist: Print host interfaces and routes (for debugging)
  --append-output: Append to rather than clobber specified output files
  --resume <filename>: Resume an aborted scan
  --noninteractive: Disable runtime interactions via keyboard
  --stylesheet <path/URL>: XSL stylesheet to transform XML output to HTML
  --webxml: Reference stylesheet from Nmap.Org for more portable XML
  --no-stylesheet: Prevent associating of XSL stylesheet w/XML output

杂项:
  -6: #IPV6扫描
  -A: Enable OS detection, version detection, script scanning, and traceroute
  --datadir <dirname>: Specify custom Nmap data file location
  --send-eth/--send-ip: Send using raw ethernet frames or IP packets
  --privileged: Assume that the user is fully privileged
  --unprivileged: Assume the user lacks raw socket privileges
  -V: Print version number
  -h: Print this help summary page.
```



端口敲门服务，即：knockd服务。该服务通过动态的添加iptables规则来隐藏系统开启的服务，
端口碰撞的原理其实很简单，设想这样一个场景：目标主机T上运行着防火墙F和一个后台守护进程D。防火墙F配置了规则，禁止所有外界主机连接端口port-n；守护进程D配置了端口序列口令，如port-a、port-b、port-c，持续监视着本机网络连接状态。如果外部客户端C首先**依次**访问了主机T的端口port-a、port-b、port-c，则守护进程D自动向防火墙F中插入一条规则R，允许客户端C连接port-n（芝麻开门）。另外，也可以通过配置守护进程D，实现“如果外部客户端C**依次**访问了主机T的端口port-d、port-e、port-f，则删除规则R”的效果（芝麻关门）。

现实中，目标主机T通常是Linux，防火墙F通常是iptables，后台守护进程D通常是knockd，port-n通常是SSH的默认监听端口22。


## 环境搭建

我们来简单测试一下，测试环境为Ubuntu 16.04。

首先做一些基本配置，禁止外部主机连接SSH端口10001：

```bash
# stop ubuntu firewall
ufw disable
# install iptables
apt-get install iptables iptables-persistent
# allow all firstly
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# reject all connections to port 10001
iptables -A INPUT -p tcp --dport 10001 -j REJECT
netfilter-persistent save
netfilter-persistent reload
```

此时使用Nmap去扫描，可以发现端口已经被过滤：

```bash
➜  ~ nmap -p 10001 192.168.1.100

Starting Nmap 7.01 ( https://nmap.org ) at 2021-01-07 19:31 CST
Nmap scan report for victim (192.168.1.100)
Host is up (0.00062s latency).
PORT      STATE    SERVICE
10001/tcp filtered scp-config
MAC Address: 00:50:56:82:86:B0 (VMware)

Nmap done: 1 IP address (1 host up) scanned in 0.57 seconds
```

安装knockd：

```bash
apt-get install knockd -y
```

配置knockd启动参数，编辑`/etc/default/knockd`，其中网卡名一定要正确：

```bash
# PLEASE EDIT /etc/knockd.conf BEFORE ENABLING
START_KNOCKD=1

# command line options
KNOCKD_OPTS="-i eth0"
```

配置knockd动作，编辑`/etc/knockd.conf`：

```bash
[options]
	UseSyslog

[openSSH]
	sequence    = 11003,11002,11001
	seq_timeout = 5
	command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 10001 -j ACCEPT
	tcpflags    = syn

[closeSSH]
	sequence    = 11001,11002,11003
	seq_timeout = 5
	command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 10001 -j ACCEPT
	tcpflags    = syn
```

上述命令的意思是：如果外界客户端依次访问了11003、11002、11001端口，则允许其访问10001；如果它依次访问了11001、11002、11003端口，则删除前面的允许规则。

OK，启动knockd。在我的环境中，使用systemctl命令无法启动knockd，也没有任何日志报错，knockd的服务状态为`active (exited)`，需要使用service命令启动才可以，具体原因尚未研究：

```bash
service knockd start
```

## 测试

客户端也安装knockd，然后执行：

```bash
knock 192.168.1.100 11003 11002 11001
```

`/var/log/syslog`报日志如下：

```bash
Jan  7 19:41:06 victim knockd: 192.168.1.101: openSSH: Stage 1
Jan  7 19:41:06 victim knockd: 192.168.1.101: openSSH: Stage 2
Jan  7 19:41:06 victim knockd: 192.168.1.101: openSSH: Stage 3
Jan  7 19:41:06 victim knockd: 192.168.1.101: openSSH: OPEN SESAME
Jan  7 19:41:06 victim knockd: openSSH: running command: /sbin/iptables -I INPUT -s 192.168.1.101 -p tcp --dport 10001 -j ACCEPT
```

然后再次用Nmap扫描：

```bash
➜  ~ nmap -p 10001 192.168.1.100

Starting Nmap 7.01 ( https://nmap.org ) at 2021-01-07 19:41 CST
Nmap scan report for victim (192.168.1.100)
Host is up (0.00066s latency).
PORT      STATE SERVICE
10001/tcp open  scp-config
MAC Address: 00:50:56:82:86:B0 (VMware)

Nmap done: 1 IP address (1 host up) scanned in 0.59 seconds
```

OK，尝试一下“芝麻关门”：

```bash
knock 192.168.1.100 11001 11002 11003
```

日志如下：

```bash
Jan  7 19:42:26 victim knockd: 192.168.1.101: closeSSH: Stage 1
Jan  7 19:42:26 victim knockd: 192.168.1.101: closeSSH: Stage 2
Jan  7 19:42:26 victim knockd: 192.168.1.101: closeSSH: Stage 3
Jan  7 19:42:26 victim knockd: 192.168.1.101: closeSSH: OPEN SESAME
Jan  7 19:42:26 victim knockd: closeSSH: running command: /sbin/iptables -D INPUT -s 192.168.1.101 -p tcp --dport 10001 -j ACCEPT
```


## /etc/knockd.conf 配置文件详解

```bash
[options] # 全局配置
UseSyslog                  # 日志输出到系统syslog，即/var/log/messages
LogFile = /path/to/file    # 指定日志的输出文件
PidFile = /path/to/file    # 指定pid的输出文件
Interface = interface_name # 指定监听的网口

[section] # 定义knockd的规则
Sequence = port1[:tcp\|udp],port2[:tcp\|udp]...       # 定义特殊的端口队列，如果相同的flag的不同端口队列接受，整个队列都会被丢弃。
One_Time_Sequences = /path/to/one_time_sequences_file # 一次性敲门队列,可以在一个文件中定义一些一次性的敲门队列，每次敲门后，将会在在正在使用的敲门队列前加上#，并启用下一个敲门队列,一旦队列耗尽，整个程序就会退出|
Seq_Timeout = timeout                     # 敲门队列完成的超时时间
TCPFlags = fin\|syn\|rst\|psh\|ack\|urg   # 验证tcp的敲门信号的flag标志位
Start_Command = command  # 当收到正确的敲门队列的情况下，执行的命令
Cmd_Timeout = timeout    # 在Start_Command and Stop_Command之间的执行的超时时间
Stop_Command = command   # 在Start_Command已经执行，并且Cmd_Timeout已经超时执行
```

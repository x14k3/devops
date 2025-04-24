# knock

端口敲门服务，即：knockd服务。该服务通过动态的添加iptables规则来隐藏系统开启的服务，使用自定义的一系列序列号来“敲门”，使系统开启需要访问的服务端口，才能对外访问。不使用时，再使用自定义的序列号来“关门”，将端口关闭，不对外监听。进一步提升了服务和系统的安全性。

‍

‍

## 1 安装knockd

```sh
# apt install knockd
tar xf knock-0.7.tar.gz
cd knock-0.7
./configure --prefix=/usr/local/knock
make && make install
```

knocked 选项：

* -i,–interface     监听的网口
* -d,–daemon    守护模式运行
* -c,–config        指定一个配置文件
* -D,–debug       输出debug信息
* -l,–lookup        dns解析
* -p,–pidfile       指定pidfile
* -g,–logfile       指定logfile
* -v,–vebose      输出详细信息

## 2 配置knockd服务

​`vim /usr/local/knock/etc/knockd.conf`​

```bash
[options]                       
	logfile = /var/log/knockd.log

[openSSH]
	sequence    = 7000,8000,10000
	seq_timeout = 5
	command     = /usr/sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
	tcpflags    = syn

[closeSSH]
	sequence    = 10000,8000,7000
	seq_timeout = 5
	 command     = /usr/sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
	tcpflags    = syn

-----------------------------------------------------------------------------------------------------------------------

[options] 全局配置：
UseSyslog: 日志输出到系统syslog，即/var/log/messages
LogFile = /path/to/file: 指定日志的输出文件
PidFile = /path/to/file: 指定pid的输出文件
Interface = interface_name : 指定监听的网口
[section] 定义knockd的规则：
Sequence = port1[:tcp|udp],port2[:tcp|udp]...: 定义特殊的端口队列，如果相同的flag的不同端口队列接受，整个队列都会被丢弃。
One_Time_Sequences = /path/to/one_time_sequences_file :一次性敲门队列,可以在一个文件中定义一些一次性的敲门队列，每次敲门后，将会在在正在使用的敲门队列前加上#，并启用下一个敲门队列,一旦队列耗尽，整个程序就会退出
Seq_Timeout = timeout: 敲门队列完成的超时时间
TCPFlags = fin|syn|rst|psh|ack|urg: 验证tcp的敲门信号的flag标志位
Start_Command = command: 当收到正确的敲门队列的情况下，执行的命令
Cmd_Timeout = timeout: 在Start_Command and Stop_Command之间的执行的超时时间
Stop_Command = command: 在Start_Command已经执行，并且Cmd_Timeout已经超时执行
```

‍

## 3 knocked测试

```sh
# systemctl start knockd

#服务端
~]# ./knockd -D -c ../etc/knockd.conf 
config: new section: 'options'
config: log file: /var/log/knockd.log
config: new section: 'openSSH'
config: openSSH: sequence: 7000:tcp,8000:tcp,9000:tcp
config: openSSH: seq_timeout: 5
config: openSSH: start_command: echo '%IP%' >> /tmp/test.txt
config: tcp flag: SYN
config: new section: 'closeSSH'
config: closeSSH: sequence: 9000:tcp,8000:tcp,7000:tcp
config: closeSSH: seq_timeout: 5
config: closeSSH: start_command: /usr/sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
config: tcp flag: SYN
ethernet interface detected
Local IP: 172.19.122.250
Adding pcap expression for door 'openSSH': (dst host 172.19.122.250 and (((tcp dst port 7000 or 8000 or 9000) and tcp[tcpflags] & tcp-syn != 0)))
Adding pcap expression for door 'closeSSH': (dst host 172.19.122.250 and (((tcp dst port 9000 or 8000 or 7000) and tcp[tcpflags] & tcp-syn != 0)))


#客户端
~]# ./knock -v 10.211.55.6 7000 8000 9000
hitting tcp 10.211.55.6:7000
hitting tcp 10.211.55.6:8000
hitting tcp 10.211.55.6:9000


#服务端
~]# ./knockd -D -c ../etc/knockd.conf 
2017-09-28 09:23:51: tcp: 112.10.95.255:1060 -> 10.211.55.6:7000 78 bytes
2017-09-28 09:23:51: tcp: 112.10.95.255:1061 -> 10.211.55.6:8000 78 bytes
2017-09-28 09:23:51: tcp: 112.10.95.255:1062 -> 10.211.55.6:9000 78 bytes

~]# iptables -L -n

Chain INPUT (policy ACCEPT)

target     prot opt source               destination     
ACCEPT     tcp  --  112.10.95.255        0.0.0.0/0            tcp dpt:22

38

......
```

‍

查看测试系统的SSH端口开启状态

```yaml
┌──(kali㉿kali)-[~]
└─$ nmap -A -p 22 192.168.50.71 -oA djinn   
Starting Nmap 7.92 ( https://nmap.org ) at 2022-03-28 11:03 CST
Nmap scan report for 192.168.50.71
Host is up (0.00071s latency).

PORT   STATE  SERVICE VERSION
22/tcp closed ssh

```

使用`1356 6784 3409`​暗号敲门

```yaml
┌──(kali㉿kali)-[~]
└─$ knock 192.168.50.71 1356 6784 3409
┌──(kali㉿kali)-[~]
└─$ nmap -A -p 22 192.168.50.71 -oA djinn
Starting Nmap 7.92 ( https://nmap.org ) at 2022-03-28 11:03 CST
Nmap scan report for 192.168.50.71
Host is up (0.00051s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 b8:cb:14:15:05:a0:24:43:d5:8e:6d:bd:97:c0:63:e9 (RSA)
|   256 d5:70:dd:81:62:e4:fe:94:1b:65:bf:77:3a:e1:81:26 (ECDSA)
|_  256 6a:2a:ba:9c:ba:b2:2e:19:9f:5c:1c:87:74:0a:25:f0 (ED25519)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

使用`3409 6784 1356  `​暗号关门

```yaml
┌──(kali㉿kali)-[~]
└─$ knock 192.168.50.71 3409 6784 1356
┌──(kali㉿kali)-[~]
└─$ nmap -A -p 22 192.168.50.71 -oA djinn
Starting Nmap 7.92 ( https://nmap.org ) at 2022-03-28 11:03 CST
Nmap scan report for 192.168.50.71
Host is up (0.00028s latency).

PORT   STATE  SERVICE VERSION
22/tcp closed ssh

```

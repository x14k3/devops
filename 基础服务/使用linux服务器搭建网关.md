

网关服务器的常见用途:
1.企业局域网想要访问外网,可以使用网关服务器上网
2.可以一个网卡连接公网,一个网卡连接局域网交换机,让网关服务器做路由器使用

## 用firewalld

> 多网卡机器做网关做nat转发, 局域网其他机器需要配置网关地址.

开启内核转发

```bash
sudo vim /etc/sysctl.conf
---
net.ipv4.ip_forward = 1
```

立即生效

```bash
sudo sysctl -p
```

开启 NAT 转发

```bash
firewall-cmd --permanent --zone=public --add-masquerade
firewall-cmd --reload
```

检查是否允许 NAT 转发

```bash
firewall-cmd --query-masquerade
```

如果不想用了, 禁止防火墙 NAT 转发

```bash
firewall-cmd --remove-masquerade
```

## 使用iptables

> 这里服务端平台用Centos 7 1804版本,客户端用的是Win7
> 外网IP:192.168.111.0/24 内网IP:192.168.222.0/24


关闭firewalld,打开iptables服务

```bash
systemctl stop firewalld
systemctl mask firewalld
```

安装iptables-services

```bash
yum install iptables-service
```

设置开机启动防火墙

```bash
systemctl enable iptables
```

开启内核转发

```bash
net.ipv4.ip_forward = 1
```

配置iptables

```bash
iptables -t nat -A POSTROUTING -s 192.168.222.0/24 -j MASQUERADE
```

保存&重启iptables

```bash
service iptables save
service iptables restart
```

‍

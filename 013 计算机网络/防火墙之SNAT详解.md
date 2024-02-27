# 防火墙之SNAT详解

在防火墙配置策略当中有 SNAT 以及 DNAT 之分，两者各有区别，今天先来说明一下 SNAT。

多应用在公司只有一个外网 IP, 那么整个公司的内网, 该怎么上网呢?

​![image](assets/net-img-bbe8d489eae0c756-20240208125312-w05ntgq.jpg)​

要想都能够访问外网, 就可以通过防火墙规则将它们出去时的源地址修改成唯一的公网 IP, 然后与外网对接, 数据返回之后, 它再交给内网 (局域网)PC 机。

​![image](assets/net-img-87d3a39488ca31c2-20240208125313-mjfc60l.jpg)​

现在可以通过简单的实验来做个验证。

主机 A: 模拟内网主机 eth0 192.168.66.10

主机 B: 模拟网关服务器 eth0 192.168.66.20 eth1 200.200.200.10

主机 C: 模拟外网 Web 站点 eth0 200.200.200.20

条件：

1. 内网各主机将设置正确的 IP 地址 / 子网掩码，并设置网关服务器的内网 IP 为默认网关地址。（可由 DHCP 服务器分发）

```
route add default gw 192.168.66.20
```

2. 网关服务器支持 IP 路由转发，并编写 SNAT 转换规则。

```bash
# 开启转发
vim /etc/sysctl.conf
net.ipv4.ip_forward = 1
-------------------------------------
sysctl -p
```

```
iptables -t nat -A POSTROUTING -s 192.168.66.0/24 -o eth1 -j SNAT --to-source 200.200.200.10
```

解释这条规则如下：

#在防火墙的 nat 表当中的 POSTROUTING 链上添加（-A）一条规则，规则是从（-s）66 网段过来的请求，出去（-o OPUTPUT）的时候都走 eth1（外网网卡），做的动作（-j）是转换它的源地址（SNAT）为 200.200.200.10

查看一下这条规则

​![image](assets/net-img-869ddd1285dda213-20240208125313-3j6yoe0.jpg)​

3. 外网服务器，安装 apache，写一个测试网页！

```
yum -y install httpd
echo “11111” >  /var/www/html/index.html
service httpd start
```

‍

测试：

直接在内网主机输入 curl 200.200.200.20，如果访问到，则说明成功。

插曲：

上边是针对企业中常应用的，但在家庭当中，很少有固定地址，一般都是动态地址，也就是说，出去的跳板是变动的，这样刚才所设置的规则就不行了，不过现在可以通过一个叫做 MASQUERADE—- 地址伪装来解决。

按刚才的环境不变，清空刚才的的防火墙规则。重新添加。

```
iptables-F -t nat
iptables -t nat -A POSTROUTING -s <span>192.168</span>.66.0/24 -o eth1 -j MASQUERADE
```

‍

​![image](assets/net-img-c153c386284c2a43-20240208125313-nxfm3o4.jpg)​

ok，现在，可以模拟改变外网 IP

```
ifconfig eth1 200.200.200.200 netmask 255.255.255.0
```

测试：

直接在内网主机输入 curl 200.200.200.20，如果访问到，则说明成功。

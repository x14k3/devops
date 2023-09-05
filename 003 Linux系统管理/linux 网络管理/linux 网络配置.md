# linux 网络配置

## Centos

配置文件位于/etc/sysconfig/network-scripts/ifcfg-网卡名称

```bash
DEVICE=ens33                         #网卡的设备名称
NAME=ens33                           #网卡设备的别名
TYPE=Ethernet                        #网络类型：Ethernet以太网
BOOTPROTO=static                     #引导协议：static静态、dhcp、none
DEFROUTE=yes                         #启动默认路由
IPV4_FAILURE_FATAL=no                #不启用IPV4错误检测功能
IPV6INIT=yes                         #启用IPV6协议
IPV6_AUTOCONF=yes                    #自动配置IPV6地址
IPV6_DEFROUTE=yes                    #启用IPV6默认路由
IPV6_FAILURE_FATAL=no                #不启用IPV6错误检测功能
UUID=sjdfga-asfd-asdf-asdf-f82b      #网卡设备的UUID唯一标识号
ONBOOT=yes                           #开机自动启动网卡
DNS=114.114.114.114                  #DNS域名解析服务器的IP地址 可以多设置一个DNS1
IPADDR=192.168.1.22                  #网卡的IP地址
PREFIX=24                            #子网前缀长度(子网掩码)
GATEWAY=192.168.1.1                  #默认网关IP地址
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPADDR=192.168.1.22                  #你想要设置的固定IP，理论上192.168.2.2-255之间都可以，请自行验证；如果是dhcp可以不填写
NETMASK=255.255.255.0                #子网掩码，不需要修改；

```

### 虚拟网卡设置

#### **方法1：修改网卡配置文件**

新建别名独立配置文件 ：重启生效，多IP地址存在别名。

```bash
vi /etc/sysconfig/network-scripts/ifcfg-ens33:0 
---------------------------------------------
DEVICE=eno167777336:01 #和配置文件名保持一致  
IPADDR=192.168.1.10    #要设置的ip1  
PREFIX=24              #要设置的ip的子网掩码  
---------------------------------------------
#第2步 重启网络 或者重新启动系统  
systemctl restart network   
#第3步 查看配置是否生效  
ip addr show
```

#### **方法2：ifconfig命令创建\删除虚拟网卡**

```bash
ifconfig eth0:0 192.168.1.10 netmask 255.255.255.0 up
#删除虚拟网卡:
ifconfig eth0:0 down

#重启服务器或者网络后,虚拟网卡就失效. 注意：添加的虚拟网卡和原网卡物理地址是一样的。
```

#### **方法3：创建tap**

**前两种方法都有一个特点，创建的网卡可有不同的ip地址，但是Mac地址相同，无法用来创建虚拟机。**  
使用命令tunctl添加虚拟网卡tap。

关于tap请参考TUN-TAP

```bash
#确认是否有tunctl命令,如果没有通过yum安装即可
apt-get install uml-utilities  
#或 yum install tunctl
#创建虚拟网卡设备
tunctl -t tap0 -u root
#设置虚拟网卡
ifconfig tap0 192.168.0.1 netmask 255.255.255.0 promisc
```

## debian

配置文件位于/etc/network/interfaces

```bash
auto lo       # auto说明lo接口跟eth0接口会在系统启动时被自动配置;
iface lo inet loopback  # 将lo接口设置为一个本地回环（loopback）地址;

# The primary network interface
auto eth0
iface eth0 inet static  # 指出eth0接口具有一个静态的（static）IP配置;
	address 192.168.0.100 # 分别设置eth0接口的ip、网络号、掩码、广播地址和网关。
	network 192.168.0.0
	netmask 255.255.255.0
	broadcast 192.168.0.255
	gateway 192.168.0.1


	up route add -net 192.168.1.128 netmask 255.255.255.128 gw 192.168.1.2 # 接口启用的时候，添加一条静态路由
	up route add default gw 192.168.1.200   # 接口启用的时候，添加一个缺省路由；
	down route del default gw 192.168.1.200 # 在接口禁用的时候，删掉这两条路由配置。
	down route del -net 192.168.1.128 netmask 255.255.255.128 gw 192.168.1.2
```

一个物理网卡上多个接口

```bash
auto eth0 eth0:1
iface eth0 inet static
	address 192.168.0.100
	network 192.168.0.0
	netmask 255.255.255.0
	broadcast 192.168.0.255
	gateway 192.168.0.1
	dns-nameservers 10.112.18.1
iface eth0:1 inet static
	address 192.168.0.200
	network 192.168.0.0
	netmask 255.255.255.0
```

‍

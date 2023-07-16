# linux 网络管理

对于Linux来说，现在流行的有网络管理有两个工具，Network服务与NetworkManager
前者做为基础服务，桌面版和服务器中都有，后者，即NetworkManager，一般只在桌面版中安装，因为其有图形配置界面，也深受用户欢迎。
需要注意的是，这两个网络配置，只能有一个生效，而不能同时生效。

# Network

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

一个物理网卡上多个接口【方式一】

无别名配置方式 ：重启可以生效，配置相对快速。IP地址没有别名不好进行管理。

```bash
#第1步 直接在该网卡的配置文件添加ip地址，配置文件路径为 /etc/sysconfig/network-scripts/ifcfg-网卡名称
vim /etc/sysconfig/network-scripts/ifcfg-【网卡名】  
-------------------------------------------------
BOOTPROTO=none  
DEVICE=enp0s17      # 要配置的网卡名称  
  
##以下为多IP配置方式  
IPADDR=192.168.1.10 # 要设置的ip1  
PREFIX=24           # 要设置的ip的子网掩码  
IPADDR1=10.168.1.11 # 要设置的ip2  
PREFIX1=24  
IPADDR2=40.168.1.12 # 要设置的ip3  
PREFIX2=24  
IPADDR3=70.168.1.13 # 要设置的ip4  
PREFIX3=24
------------------------------------------------

#第2步 重启网络 或者重新启动系统  
systemctl restart network  
#第3步 查看配置是否生效  
ip addr show
```

一个物理网卡上多个接口【方式二】

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

# NetworkManager

# 网桥

**brctl**命令用于设置、维护和检查linux内核中的以太网网桥配置。

以太网网桥是一种设备，通常用于将以太网的不同网络连接在一起，以便这些以太网对参与者显示为一个以太网。所连接的每个以太网对应于网桥中的一个物理接口。这些单独的以太网被聚集成一个更大的（“逻辑”）以太网，这个更大的以太网对应于网桥网络接口。

|参数|说明|示例|
| -----------------| ----------------------| -----------------|
|`addbr <bridge>`|创建网桥|**brctl** addbr br10|
|`delbr <bridge>`|删除网桥|**brctl** delbr br10|
|`addif <bridge> <device>`|将网卡接口接入网桥|**brctl** addif br10 eth0|
|`delif <bridge> <device>`|删除网桥接入的网卡接口|**brctl** delif br10 eth0|
|`show <bridge>`|查询网桥信息|**brctl** show br10|
|`stp <bridge> {on|off}`|启用禁用 STP|
|`showstp <bridge>`|查看网桥 STP 信息|**brctl** showstp br10|
|`setfd <bridge> <time>`|设置网桥延迟|**brctl** setfd br10 10|
|`showmacs <bridge>`|查看 mac 信息|**brctl** showmacs br10|

配置网桥

```bash
################# Centos #######################
# 1. 编辑网桥设备，在/etc/sysconfig/network-scripts/目录下创建ifcgg-br0文件，并写入以下内容
vi /etc/sysconfig/network-scripts/ifcfg-br0  
-------------------------------------------
DEVICE="br0"  
ONBOOT="yes"  
TYPE="Bridge"  
BOOTPROTO=static  
IPADDR=192.168.0.101
NETMASK=255.255.255.0  
GATEWAY=192.168.0.1
DEFROUTE=yes

################# debian #######################
vim /etc/network/interfaces
-------------------------------------------
# 添加如下内容
auto br0
iface br0 inet static
	address 192.168.0.110
	netmask 255.255.255.0
	broadcast 192.168.0.255
	gateway 192.168.0.1
	bridge_ports enp2s0
	bridge_stp off
	bridge_fd 0


################# ubuntu#######################
#对于已经使用netplan来管理网络的ubuntu服务器需要修改netplan而非/etc/network/interfaces
cat /etc/netplan/50-cloud-init.yaml 
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp5s0:
            dhcp4: false 
            addresses: [192.168.40.20/24]
            gateway4: 192.168.40.1 
            nameservers:
                addresses:
                - 223.5.5.5
                - 114.114.114.114
                - 192.168.40.1
   version: 2
# systemctl restart NetworkManager

```

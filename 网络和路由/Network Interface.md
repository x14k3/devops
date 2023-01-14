#network 

# 一、网卡

## 网卡配置
配置静态ip
`vim /etc/sysconfig/network-scripts/ifcfg-ens33`

```bash
BOOTPROTO="static"
DEFROUTE="yes"
DEVICE="ens33"
ONBOOT="yes"
IPADDR=192.168.0.110
NETMASK=255.255.255.0
#PREFIX=24
GATEWAY=192.168.0.1
```

`ifdown ens33 && ifup ens33`

## 配置虚拟网卡
通过命令行添加，只能临时生效，重启后虚拟ip就没了。

```bash
# 使用 iproute2 工具配置 配置临时虚拟ip
ip addr add 192.168.130.101/24 brd 192.168.130.255 dev ens33 label ens33:1
# 删除
ip addr del 192.168.130.101/24 dev ens33 label ens33:1

```

若要永久生效需要写配置文件。

`cp /etc/sysconfig/network-scripts/ifcfg-ens33{,:1}`

`vim /etc/sysconfig/network-scripts/ifcfg-ens33:1`

```bash
BOOTPROTO="static"
DEFROUTE="yes"
DEVICE="ens33:1"
ONBOOT="yes"
IPADDR=192.168.130.100
NETMASK=255.255.255.0
#PREFIX=24
GATEWAY=192.168.130.2
```

`ifdown ens33 && ifup ens33`

***

# 二、路由

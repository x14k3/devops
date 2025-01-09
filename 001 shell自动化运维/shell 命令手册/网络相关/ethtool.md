# ethtool

　　[纠正错误](https://github.com/jaywcjlove/linux-command/edit/master/command/ethtool.md) [添加实例](https://github.com/jaywcjlove/linux-command/edit/master/command/ethtool.md)

　　显示或修改以太网卡的配置信息

## 补充说明

　　ethtool命令用于获取以太网卡的配置信息，或者修改这些配置。这个命令比较复杂，功能特别多。

### 语法

```shell
ethtool [ -a | -c | -g | -i | -d | -k | -r | -S |] ethX
ethtool [-A] ethX [autoneg on|off] [rx on|off] [tx on|off]
ethtool [-C] ethX [adaptive-rx on|off] [adaptive-tx on|off] [rx-usecs N] [rx-frames N] [rx-usecs-irq N] [rx-frames-irq N] [tx-usecs N] [tx-frames N] [tx-usecs-irq N] [tx-frames-irq N] [stats-block-usecs N][pkt-rate-low N][rx-usecs-low N] [rx-frames-low N] [tx-usecs-low N] [tx-frames-lowN] [pkt-rate-high N] [rx-usecs-high N] [rx-frames-high N] [tx-usecs-high N] [tx-frames-high N] [sample-interval N]
ethtool [-G] ethX [rx N] [rx-mini N] [rx-jumbo N] [tx N]
ethtool [-e] ethX [raw on|off] [offset N] [length N]
ethtool [-E] ethX [magic N] [offset N] [value N]
ethtool [-K] ethX [rx on|off] [tx on|off] [sg on|off] [tso on|off]
ethtool [-p] ethX [N]
ethtool [-t] ethX [offline|online]
ethtool [-s] ethX [speed 10|100|1000] [duplex half|full] [autoneg on|off] [port tp|aui|bnc|mii] [phyad N] [xcvr internal|external]
[wol p|u|m|b|a|g|s|d...] [sopass xx:yy:zz:aa:bb:cc] [msglvl N]

```

### 选项

```shell
-a 查看网卡中 接收模块RX、发送模块TX和Autonegotiate模块的状态：启动on 或 停用off。
-A 修改网卡中 接收模块RX、发送模块TX和Autonegotiate模块的状态：启动on 或 停用off。
-c display the Coalesce information of the specified ethernet card。
-C Change the Coalesce setting of the specified ethernet card。
-g Display the rx/tx ring parameter information of the specified ethernet card。
-G change the rx/tx ring setting of the specified ethernet card。
-i 显示网卡驱动的信息，如驱动的名称、版本等。
-d 显示register dump信息, 部分网卡驱动不支持该选项。
-e 显示EEPROM dump信息，部分网卡驱动不支持该选项。
-E 修改网卡EEPROM byte。
-k 显示网卡Offload参数的状态：on 或 off，包括rx-checksumming、tx-checksumming等。
-K 修改网卡Offload参数的状态。
-p 用于区别不同ethX对应网卡的物理位置，常用的方法是使网卡port上的led不断的闪；N指示了网卡闪的持续时间，以秒为单位。
-r 如果auto-negotiation模块的状态为on，则restarts auto-negotiation。
-S 显示NIC- and driver-specific 的统计参数，如网卡接收/发送的字节数、接收/发送的广播包个数等。
-t 让网卡执行自我检测，有两种模式：offline or online。
-s 修改网卡的部分配置，包括网卡速度、单工/全双工模式、mac地址等。

```

### 数据来源

　　Ethtool命令显示的信息来源于网卡驱动层，即TCP/ip协议的链路层。该命令在Linux内核中实现的逻辑层次为：

　　最重要的结构体`struct ethtool_ops`​，该结构体成员为用于显示或修改以太网卡配置的一系列函数指针，见下表中的第二列。

　　网卡驱动负责实现（部分）这些函数，并将其封装入`ethtool_ops`​结构体，为网络核心层提供统一的调用接口。因此，不同的网卡驱动会给应用层返回不同的信息。`Ethtool命令选项`​、`struct ethtool_ops成员函数`​、`Ethtool命令显示参数的来源`​，三者间的对应关系如下表所示：

　　由上可见，ethtool命令用于显示/配置网卡硬件（寄存器）。

　　‍

```bash
 [root@vworkstation ~]# ethtool enp4s0
 Settings for enp4s0:
 Supported ports: [ TP MII ]
 //支持模式
 Supported link modes:   10baseT/Half 10baseT/Full
                        100baseT/Half 100baseT/Full
                        1000baseT/Half 1000baseT/Full
 Supported pause frame use: No
 Supports auto-negotiation: Yes// 支持自动协商
 Supported FEC modes: Not reported
 //通告模式
 Advertised link modes: 10baseT/Half 10baseT/Full
                        100baseT/Half 100baseT/Full
                        1000baseT/Full
 Advertised pause frame use: Symmetric Receive-only
 Advertised auto-negotiation: Yes
 Advertised FEC modes: Not reported
 Speed: 10Mb/s//当前速率
 Duplex: Half//工作模式为半双工
 Port: MII
 PHYAD: 0
 Transceiver: internal
 Auto-negotiation: on//自动协商
 Supports Wake-on: pumbg
 Wake-on: g
 Current message level: 0x00000033 (51)
        drv probe ifdown ifup
 Link detected: no
```

1. 网口驱动信息

　　​`ethtool -i ethX`​

```javascript
 driver: r8169//驱动
 version: 2.3LK-NAPI//版本
 firmware-version: rtl8168g-3_0.0.1 04/23/13//固件信息
 expansion-rom-version:
 bus-info: 0000:04:00.0
 supports-statistics: yes
 supports-test: no
 supports-eeprom-access: no
 supports-register-dump: yes
 supports-priv-flags: no
```

　　    3. 设置网口工作方式

　　(1)关闭/打开网卡对数据包的校验功能

　　    关闭/打开网卡对收到的数据包的校验功能，请输入：`ethtool -K eth0 rx off/on`​

　　    关闭/打开网卡对发送的数据包的校验功能，请输入：`ethtool -K eth0 tx off/on`​

　　    操作完毕后可以输入`ethtool -k eth0`​查看校验功能是否已关闭

　　(2)定位ethX对应的网卡

　　    输入`ethtool -p eth0 10`​，操作完毕后eth0网卡的led灯会闪烁。

　　注：本文为小yip原创，未经许可不得在任何平台转载。如需转载，与作者联系\~

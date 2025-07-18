`
nmcli` 是 Linux 上 **NetworkManager 的命令行管理工具**，用于配置和管理网络连接。相比传统的 `ifconfig`/`ip` 命令，它提供更高级的网络管理功能（如 WiFi、VPN、绑定接口等）。以下是详细指南：
‍

### <span id="20240110163353-dr29v8p" style="display: none;"></span>nmcli 基本命令结构

```bash
nmcli [全局选项] <对象> <命令> [具体选项]

## 常用选项
# -t          简洁输出，会将多余的空格删除，  
# -p          人性化输出，输出很漂亮
# -n          优化输出，有两个选项tabular(不推荐)和multiline(默认)
# -c          颜色开关，控制颜色输出(默认启用)
# -f          过滤字段，all为过滤所有字段，common打印出可过滤的字段
# -g          过滤字段，适用于脚本，以:分隔
# -w          超时时间

## 常用对象
# general             NetworkManager 状态
# networking          整体网络开关
# radio               无线射频开关
# connection（或 con） 管理连接配置
# device（或 dev）     管理物理/虚拟设备
```

### 核心功能详解

#### 查看网络状态

|命令|说明|
|---|---|
|`nmcli general status`|查看 NetworkManager 状态|
|`nmcli networking on/off`|启用/禁用所有网络|
|`nmcli networking connectivity`|检查网络连通性（full/limited/none）|

#### 设备管理

| 命令                                     | 说明               |
| -------------------------------------- | ---------------- |
| `nmcli device status`                  | 列出所有网络设备         |
| `nmcli device show [设备名]`              | 显示设备详情（IP、MAC 等） |
| `nmcli device connect/disconnect eth0` | 连接/断开指定设备        |
| `nmcli device monitor`                 | 实时监控设备事件         |
#### 连接管理

|命令|说明|
|---|---|
|`nmcli connection show`|列出所有连接配置|
|`nmcli connection show --active`|仅显示活动连接|
|`nmcli connection up/down "MyWiFi"`|启用/停用指定连接|
|`nmcli connection delete "MyWiFi"`|删除连接配置|

#### WiFi 操作

| 命令                                           | 说明            |
| -------------------------------------------- | ------------- |
| `nmcli device wifi list`                     | 扫描可用 WiFi     |
| `nmcli device wifi rescan`                   | 重新扫描 WiFi     |
| `nmcli device wifi connect SSID password 密码` | 连接 WiFi       |
| `nmcli radio wifi on/off`                    | 打开/关闭 WiFi 射频 |


### 高级配置示例

#### 创建新连接

```bash
# 创建静态 IP 的有线连接
nmcli connection add type ethernet con-name "Static-LAN" ifname eth0 \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8" \
  ipv4.method manual

# 创建 DHCP 连接的 WiFi
nmcli device wifi connect "MySSID" password "123456" ifname wlan0

# 启用配置
nmcli connection up eth0-static

# 修改配置
nmcli conn modify eth0  \
ipv4.addresses "10.10.0.10/24" \
ipv4.gateway 10.10.0.1 \
ipv4.dns 114.114.114.114 \
ipv4.method manual \
ipv6.method ignore \
ipv4.routes "10.10.0.0/24 10.10.0.1" \
connection.autoconnect yes

nmcli connection down eth0  && nmcli connection up eth0
#ipv4.routes "10.10.0.0/24 10.10.0.1" #这会将 10.10.0.0/16 子网的流量定向到网关 10.10.1.1。
```

#### 修改现有连接

```bash
# 修改 IP 地址
nmcli connection modify "Static-LAN" ipv4.addresses "192.168.1.200/24"

# 添加备用 DNS
nmcli connection modify "Static-LAN" +ipv4.dns "1.1.1.1"

# 设置自动连接
nmcli connection modify "Static-LAN" connection.autoconnect yes
```


#### VPN 连接

```bash
# 添加 OpenVPN 连接
nmcli connection add type vpn vpn-type openvpn \
  con-name "MyVPN" \
  vpn.data "username=user, password=pass, remote=vpn.example.com"

```

#### 创建网桥

```bash
# 接下来创建一个名为br0的网桥：
nmcli con add type bridge ifname br0
# 把主接口桥到br0上，例如我的主接口名是eno1：
nmcli con add type bridge-slave ifname eno1 master br0
# 关闭主接口，这里可以使用你之前查看获得到的UUID来关闭：
nmcli con down 9a25e1e1-63fc-3cf3-a9ea-549f9e5ab431
# 一般情况下，当NetworkManager检测到主接口down掉后，会自动帮你把网桥up起来，如果没有，手动执行下面的命令：
nmcli con up bridge-br0

# 由于我的路由器是开了DHCP服务的，这里br0会自动分配IP，但如果是服务器上面，一般是要配置静态IP的，以下是设置静态IP的方法：
nmcli con modify bridge-br0 ipv4.method manual ipv4.address "192.168.0.251/24" ipv4.gateway "192.168.0.1" ipv4.dns "114.114.114.114"
nmcli con up bridge-br0

# 如果要恢复成使用DHCP自动分配IP：
nmcli con modify bridge-br0 ipv4.method auto
nmcli con up bridge-br0
```

IPv6桥接模式在一些情况下可能会遇到没有地址的问题。这通常是因为IPv6桥接模式被配置为使用透明的桥接，桥接器本身不分配或管理IP地址。

‍

#### 配置网卡的Bonding

首先先把bonding master给加上，并且配置好bonding的模式和其他参数，另外，由于bonding之后IP地址一般会配置到bond设备上，在添加的时候顺便也把IP这些信息也填上：

```bash
nmcli connection add type bond con-name bonding-bond0 ifname bond0 bond.options "mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4,updelay=5000" ipv4.method manual ipv4.addresses 192.168.100.10 ipv4.gateway 192.168.100.1
8.100.10/24 ipv4.gateway 192.168.100.1

```

添加完bonding master，再把两个slave添加到master口上：

```bash
nmcli connection add type bond-slave con-name bond0-slave-ens1f0 ifname ens1f0 master bond0

nmcli connection add type bond-slave con-name bond0-slave-ens1f1 ifname ens1f1 master bond0
```

再Down/Up一下bond口：

```bash
nmcli connection down bonding-bond0;nmcli connection up bonding-bond0

nmcli connection
```


#### 添加dummy网卡并配置多个IP地址

再举个dummy网卡的例子，因为有其他部门目前在用DR模式的LVS负载均衡，所以需要配置dummy网卡和IP地址，之前也稍微看了看，也比较简单：

```bash
nmcli connection add type dummy con-name dummy-dummy0 ifname dummy0 ipv4.method manual ipv4.addresses "1.1.1.1/32,2.2.2.2/32,3.3.3.3/32,4.4.4.4/32"

nmcli connection

ip addr
```

需要注意的是，一个连接是可以配置多个IP地址的，多个IP地址之间用`,`​分割就可以了。


#### 配置Bond+Bridge

Bond+Bridge的配置在虚拟化场景比较常见，需要注意的是，有了Bridge之后，IP地址需要配置到Bridige上。

```bash
nmcli connection add type bridge con-name bridge-br0 ifname br0 ipv4.method manual ipv4.addresses 192.168.100.10 ipv4.gateway 192.168.100.1

```

此时创建了一个网桥br0，但是还没有任何接口连接到这个网桥上，下面需要创建个bond0口，并把bond0加到br0上。

```bash
nmcli connection add type bond con-name bonding-bond0 ifname bond0 bond.options "mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4,updelay=5000" connection.master br0 connection.slave-type bridge
```

这里配置比较特殊，创建bond口和上面差不多，但是多了点配置`connection.master br0 connection.slave-type bridge`​，这个和普通的bridge-slave口直接指定`master br0`​的方式不太一样，因为bond0也是个虚拟的接口，所以需要将接口的属性`connection.master`​配置成br0，才能实现把bond0这个虚拟接口添加到br0的功能。

后面bond0添加两个slave口还是和之前没有区别：

```bash
nmcli connection add type bond-slave con-name bond0-slave-ens1f0 ifname ens1f0 master bond0
nmcli connection add type bond-slave con-name bond0-slave-ens1f1 ifname ens1f1 master bond0
nmcli connection

```


#### 配置持久化

使用 `connection modify` 命令（自动持久化）

```bash
# 修改配置（自动保存到配置文件）
sudo nmcli connection modify "连接名" <参数> <值>
```

- **所有 `connection modify` 命令的修改都会自动写入配置文件**
- 配置文件路径：`/etc/NetworkManager/system-connections/连接名.nmconnection`
# linux 网络配置

## 配置主机名

### 简介

hostname有三种类型：static、transient和pretty。

- static：静态主机名，可由用户自行设置，并保存在/etc/hostname 文件中。
- transient：动态主机名，由内核维护，初始是 static 主机名，默认值为“localhost”。可由DHCP或mDNS在运行时更改。
- pretty：灵活主机名，允许使用自由形式（包括特殊/空白字符）进行设置。静态/动态主机名遵从域名的通用限制。

> ![](assets/net-img-icon-note-20230906153802-nmivsd8.gif) **说明：** 
> static和transient主机名只能包含a-z、A-Z、0-9、“-”、“_”和“.”，不能在开头或结尾处使用句点，不允许使用两个相连的句点，大小限制为 64 个字符。

### 使用hostnamectl配置主机名

#### 查看所有主机名

查看当前的主机名，使用如下命令：

```
$ hostnamectl status
```

> ![](assets/net-img-icon-note-20230906153802-9j2dfdm.gif) **说明：** 
> 如果命令未指定任何选项，则默认使用status选项。

#### 设定所有主机名

在root权限下，设定系统中的所有主机名，使用如下命令：

```
# hostnamectl set-hostname name
# exec bash
```

#### 设定特定主机名

在root权限下，通过不同的参数来设定特定主机名，使用如下命令：

```
# hostnamectl set-hostname name [option...]
```

其中option可以是--pretty、--static、--transient中的一个或多个选项。

如果--static或--transient与--pretty选项一同使用时，则会将static和transient主机名简化为pretty主机名格式，使用“-”替换空格，并删除特殊字符。

当设定pretty主机名时，如果主机名中包含空格或单引号，需要使用引号。命令示例如下：

```
# hostnamectl set-hostname "Stephen's notebook" --pretty
```

#### 清除特定主机名

要清除特定主机名，并将其还原为默认形式，在root权限下，使用如下命令：

```
# hostnamectl set-hostname "" [option...]
```

其中 "" 是空白字符串，option是--pretty、--static和--transient中的一个或多个选项。

#### 远程更改主机名

在远程系统中运行hostnamectl命令时，要使用-H，--host 选项，在root权限下使用如下命令：

```
# hostnamectl set-hostname -H [username]@hostname new_hostname
```

其中hostname是要配置的远程主机，username为自选项，new_hostname为新主机名。hostnamectl会通过SSH连接到远程系统。

### 使用nmcli配置主机名

查询static主机名，使用如下命令：

```
$ nmcli general hostname
```

在root权限下，将static主机名设定为host-server，使用如下命令：

```
# nmcli general hostname host-server
```

要让系统hostnamectl感知到static主机名的更改，在root权限下，重启hostnamed服务，使用如下命令：

```
# systemctl restart systemd-hostnamed
```

---

‍

## 配置 IP

‍

### 使用[nmcli ](linux%20NetworkManager.md#20240110163353-dr29v8p)命令

列出目前可用的网络连接：

```bash
$ nmcli con show

NAME    UUID                                  TYPE      DEVICE
enp4s0  5afce939-400e-42fd-91ee-55ff5b65deab  ethernet  enp4s0
enp3s0  c88d7b69-f529-35ca-81ab-aa729ac542fd  ethernet  enp3s0
virbr0  ba552da6-f014-49e3-91fa-ec9c388864fa  bridge    virbr0
```

> ![](assets/net-img-icon-note-20230906153802-4oa4n1z.gif) **说明：** 
> 输出结果中的NAME字段代表连接ID（名称）。

添加一个网络连接会生成相应的配置文件，并与相应的设备关联。检查可用的设备，方法如下：

```bash
$ nmcli dev status

DEVICE      TYPE      STATE      CONNECTION
enp3s0      ethernet  connected  enp3s0
enp4s0      ethernet  connected  enp4s0
virbr0      bridge    connected  virbr0
lo          loopback  unmanaged  --
virbr0-nic  tun       unmanaged  --
```

##### 配置动态IP连接

要使用 DHCP 分配网络时，可以使用动态IP配置添加网络配置文件，命令格式如下：

```bash
nmcli connection add type ethernet con-name connection-name ifname interface-name
```

例如创建名为net-test的动态连接配置文件，在root权限下使用以下命令：

```bash
# nmcli connection add type ethernet con-name net-test ifname enp3s0
Connection 'net-test' (a771baa0-5064-4296-ac40-5dc8973967ab) successfully added.
```

NetworkManager 会将参数 connection.autoconnect 设定为 yes，并将设置保存到 “/etc/sysconfig/network-scripts/ifcfg-net-test”文件中，在该文件中会将 ONBOOT 设置为 yes。

###### 激活连接并检查状态

在root权限下使用以下命令激活网络连接：

```bash
# nmcli con up net-test 
Connection successfully activated (D-Bus active path:/org/freedesktop/NetworkManager/ActiveConnection/5)
```

检查这些设备及连接的状态，使用以下命令：

```bash
$ nmcli device status

DEVICE      TYPE      STATE      CONNECTION
enp4s0      ethernet  connected  enp4s0
enp3s0      ethernet  connected  net-test
virbr0      bridge    connected  virbr0
lo          loopback  unmanaged  --
virbr0-nic  tun       unmanaged  --
```

##### 配置静态IP连接

###### 配置IP

添加静态 IPv4 配置的网络连接，可使用以下命令：

```bash
nmcli conn modify eth0  \
ipv4.addresses "10.10.0.10/24" \
ipv4.gateway 10.10.0.1 \
ipv4.dns 114.114.114.114 \
ipv4.method manual \
ipv6.method ignore \
ipv4.routes "10.10.0.0/24 10.10.0.1" \
connection.autoconnect yes
```

### 使用ip命令

[linux ip 命令](linux%20ip%20命令.md)

##### 配置静态地址

在root权限下，配置静态IP地址，使用示例如下：

```
# ip address add 192.168.0.10/24 dev enp3s0
```

##### 配置多个地址

ip 命令支持为同一接口分配多个地址，可在root权限下重复多次使用 ip 命令实现分配多个地址。使用示例如下：

```
# ip address add 192.168.2.223/24 dev enp4s0
# ip address add 192.168.4.223/24 dev enp4s0

3: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:aa:da:e2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.203.12/16 brd 192.168.255.255 scope global dynamic noprefixroute enp4s0
       valid_lft 8389sec preferred_lft 8389sec
    inet 192.168.2.223/24 scope global enp4s0
       valid_lft forever preferred_lft forever
    inet 192.168.4.223/24 scope global enp4s0
       valid_lft forever preferred_lft forever
    inet6 fe80::1eef:5e24:4b67:f07f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

#### 配置静态路由

如果需要静态路由，可使用 ip route add 命令在路由表中添加，使用 ip route del 命令删除。最常使用的 ip route 命令格式如下：

```
ip route [ add | del | change | append | replace ] destination-address
```

```bash
#1）添加到达目标主机的路由记录
ip route add 目标主机 via 网关

#2）添加到达网络的路由记录
ip route add 目标网络/掩码 via 网关

#添加默认路由
ip route add default via 网关 下面只举一个例子说明一下。
#比如增加一条到达主机10.2.111.112的路由，网关是10.1.111.112
ip route add 10.2.111.112 via 10.1.111.112

#3) 删除路由
ip route del 目标网络/掩码
ip route del default [via 网关]

#4) 清空路由
ip route flush  #不建议尝试
```

‍

### 通过ifcfg文件配置网络

> ![](assets/net-img-icon-note-20230906153802-cq4kxy7.gif) **说明：** 
> 通过ifcfg文件配置的网络配置不会立即生效，修改文件后（以ifcfg-enp3s0为例），需要在root权限下执行**nmcli con reload;nmcli con up enp3s0**命令以重新加载配置文件并激活连接才生效。

#### 配置静态网络

以enp4s0网络接口进行静态网络设置为例，通过在root权限下修改ifcfg文件实现，在/etc/sysconfig/network-scripts/目录中生成名为ifcfg-enp4s0的文件中，修改参数配置，示例如下：

##### Redhat/CentOS

```bash
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=192.168.0.10
GATEWAY=192.168.0.1
PREFIX=24
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp4s0static
UUID=08c3a30e-c5e2-4d7b-831f-26c3cdc29293
DEVICE=enp4s0
ONBOOT=yes
EOF

ifdown ens33 && ifup ens33
```

##### Ubuntu-netplan

```bash
cat <<EOF > /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
  	ens3:
      dhcp4: no
      addresses: [192.168.128.1/16]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [114.114.114.114]
EOF

netplan apply
```

‍

#### 配置动态网络

要通过ifcfg文件为em1接口配置动态网络，请按照如下操作在/etc/sysconfig/network-scripts/目录中生成名为 ifcfg-em1 的文件，示例如下：

```
DEVICE=em1
BOOTPROTO=dhcp
ONBOOT=yes
```

要配置一个向DHCP服务器发送不同的主机名的接口，请在ifcfg文件中新增一行内容，如下所示：

```
DHCP_HOSTNAME=hostname
```

要配置忽略由DHCP服务器发送的路由，防止网络服务使用从DHCP服务器接收的DNS服务器更新/etc/resolv.conf。请在ifcfg文件中新增一行内容，如下所示：

```
PEERDNS=no
```

要配置一个接口使用具体DNS服务器，请将参数PEERDNS=no，并在ifcfg文件中添加以下行：

```
DNS1=ip-address
DNS2=ip-address
```

其中ip-address是DNS服务器的地址。这样就会让网络服务使用指定的DNS服务器更新/etc/resolv.conf。

#### 配置默认网关

在确定默认网关时，首先解析 /etc/sysconfig/network 文件，然后解析 ifcfg 文件 ，将最后读取的 GATEWAY 的取值作为路由表中的默认路由。

在动态网络环境中，使用 NetworkManager 管理主机时，建议设置为由 DHCP 来分配。

---

‍

## 配置网络绑定

### 使用nmcli

- 创建名为mybond0的绑定，使用示例如下：

  ```
  $ nmcli con add type bond con-name mybond0 ifname mybond0 mode active-backup
  ```
- 添加从属接口，使用示例如下：

  ```
  $ nmcli con add type bond-slave ifname enp3s0 master mybond0
  ```

  要添加其他从属接口，重复上一个命令，并在命令中使用新的接口，使用示例如下：

  ```
  $ nmcli con add type bond-slave ifname enp4s0 master mybond0
  Connection 'bond-slave-enp4s0' (05e56afc-b953-41a9-b3f9-0791eb49f7d3) successfully added.
  ```
- 要启动绑定，则必须首先启动从属接口，使用示例如下：

  ```
  $ nmcli con up bond-slave-enp3s0
  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/14)
  ```

  ```
  $ nmcli con up bond-slave-enp4s0
  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/15)
  ```

  现在可以启动绑定，使用示例如下：

  ```
  $ nmcli con up mybond0
  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/16)
  ```

### 使用命令行

#### 检查是否已安装Bonding内核模块

在系统中默认已加载相应模块。要载入绑定模块，可在root权限下使用如下命令：

```
# modprobe --first-time bonding
```

显示该模块的信息，可在root权限下使用如下命令：

```
# modinfo bonding
```

更多命令请在root权限下使用modprobe --help查看。

#### 创建频道绑定接口

要创建绑定接口，可在root权限下通过在 /etc/sysconfig/network-scripts/ 目录中创建名为 ifcfg-bondN 的文件（使用接口号码替换 N，比如 0）。

根据要绑定接口类型的配置文件来编写相应的内容，比如网络接口。接口配置文件示例如下：

```
DEVICE=bond0
NAME=bond0
TYPE=Bond
BONDING_MASTER=yes
IPADDR=192.168.1.1
PREFIX=24
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="bonding parameters separated by spaces"
```

#### 创建从属接口

创建频道绑定接口后，必须在从属接口的配置文件中添加 MASTER 和 SLAVE 指令。

例如将两个网络接口enp3s0 和 enp4s0 以频道方式绑定，其配置文件示例分别如下：

```
TYPE=Ethernet
NAME=bond-slave-enp3s0
UUID=3b7601d1-b373-4fdf-a996-9d267d1cac40
DEVICE=enp3s0
ONBOOT=yes
MASTER=bond0
SLAVE=yes
```

```
TYPE=Ethernet
NAME=bond-slave-enp4s0
UUID=00f0482c-824f-478f-9479-abf947f01c4a
DEVICE=enp4s0
ONBOOT=yes
MASTER=bond0
SLAVE=yes
```

#### 激活频道绑定

要激活绑定，则需要启动所有从属接口。请在root权限下，运行以下命令：

```
# ifup enp3s0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/7)
```

```
# ifup enp4s0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/8)
```

> ![](assets/net-img-icon-note-20230906153802-6ub2vdj.gif) **说明：** 
> 对于已经处于“up”状态的接口，请首先使用“ifdown *enp3s0* ”命令修改状态为down，其中 *enp3s0* 为实际网卡名称。

完成后，启动所有从属接口以便启动绑定（不将其设定为 “down”）。

要让 NetworkManager 感知到系统所做的修改，在每次修改后，请在root权限下，运行以下命令：

```
# nmcli con load /etc/sysconfig/network-scripts/ifcfg-device
```

查看绑定接口的状态，请在root权限下运行以下命令：

```
# ip link show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:aa:ad:4a brd ff:ff:ff:ff:ff:ff
3: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:aa:da:e2 brd ff:ff:ff:ff:ff:ff
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/ether 86:a1:10:fb:ef:07 brd ff:ff:ff:ff:ff:ff
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:29:35:4c brd ff:ff:ff:ff:ff:ff
```

#### 创建多个绑定

系统会为每个绑定创建一个频道绑定接口，包括 BONDING_OPTS 指令。使用这个配置方法可让多个绑定设备使用不同的配置。请按照以下操作创建多个频道绑定接口：

- 创建多个 ifcfg-bondN 文件，文件中包含 BONDING_OPTS 指令，让网络脚本根据需要创建绑定接口。
- 创建或编辑要绑定的现有接口配置文件，添加 SLAVE 指令。
- 使用 MASTER 指令工具在频道绑定接口中分配要绑定的接口，即从属接口。

以下是频道绑定接口配置文件示例：

```
DEVICE=bondN
NAME=bondN
TYPE=Bond
BONDING_MASTER=yes
IPADDR=192.168.1.1
PREFIX=24
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="bonding parameters separated by spaces"
```

在这个示例中，使用绑定接口的号码替换 N。例如要创建两个接口，则需要使用正确的 IP 地址创建两个配置文件 ifcfg-bond0 和 ifcfg-bond1。

‍

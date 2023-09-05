# linux bridge

## 什么是bridge？

首先，bridge是一个虚拟网络设备，所以具有网络设备的特征，可以配置IP、MAC地址等；其次，bridge是一个虚拟交换机，和物理交换机有类似的功能。  
对于普通的网络设备来说，只有两端，从一端进来的数据会从另一端出去，如物理网卡从外面网络中收到的数据会转发给内核协议栈，而从协议栈过来的数据会转发到外面的物理网络中。  
而bridge不同，bridge有多个端口，数据可以从任何端口进来，进来之后从哪个口出去和物理交换机的原理差不多，要看mac地址。

## **brctl**命令

用于设置、维护和检查linux内核中的以太网网桥配置。

|参数|说明|示例|
| ------| ------------------------| -----------------------------------|
|​`addbr <bridge>`​|创建网桥|**brctl** addbr br10|
|​`delbr <bridge>`​|删除网桥|ifconfig kvmbr1 down**; brctl** delbr kvmbr1|
|​`addif <bridge> <device>`​|将网卡接口接入网桥|**brctl** addif br10 eth0|
|​`delif <bridge> <device>`​|删除网桥接入的网卡接口|**brctl** delif br10 eth0|
|​`show <bridge>`​|查询网桥信息|**brctl** show br10|
|​`stp <bridge> {on|off}`​|启用禁用 STP|**brctl** stp br10 off/on|
|​`showstp <bridge>`​|查看网桥 STP 信息|**brctl** showstp br10|
|​`setfd <bridge> <time>`​|设置网桥延迟|**brctl** setfd br10 10|
|​`showmacs <bridge>`​|查看 mac 信息|**brctl** showmacs br10|

```bash
#brctl命令安装
yum -y install bridge-utils
# 多网口配置网桥需开启转发。
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

#查看系统是否存在网桥配置
brctl show
#添加一个新的逻辑网桥接口br0
brctl addbr br0
#将eth1加入逻辑网桥br0
brctl addif br0 eth1/eth2
#配置网桥地址并启动
ifconfig br0 172.168.0.1 up
```

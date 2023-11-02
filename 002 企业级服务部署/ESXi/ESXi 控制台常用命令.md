# ESXi 控制台常用命令

‍

## esxcli命令

esxcli命令用途广泛，我们不能简单地将其归为单个命令。esxcli包括许多不同的命名空间，允许你控制ESXi提供的几乎所有设备。下面列出了使用最频繁（肯定不是所有）的命名空间：

```bash
# esxcli hardware – 想获取ESXi主机的硬件及配置信息时，esxcli硬件命名空间就能够派上用场了。
esxcli hardware cpu list            # 获取CPU信息（系列、型号以及缓存）
esxcli hardware memory get   # 获取内存信息（可用内存以及非一致内存访问）

# esxcli iscsi – iscsi命名空间可以被用于监控并管理硬件iSCSI及软件iSCSI设置。
esxcli iscsi software          # 用于启用/禁用软件iSCSI initiator。
esxcli iscsi adapter            # 用于设置软硬件iSCSI适配器的发现、CHAP以及其他设置
esxcli iscsi sessions           # 用于列出主机上已建立的iSCSI会话。

# esxcli network –需要监控vSphere网络并对如下网络组件进行调整时，包括虚拟交换机、VMkernel网络接口、防火墙以及物理网卡等，esxcli网络命名空间就派上用场了。
esxcli network nic              # 列出并修改网卡信息，比如名字、唤醒网卡以及速度。
esxcli network vm list       # 列出有一个活动网络端口的虚拟机的网络信息。
esxcli network vswitch     # 检索并管理VMware的标准交换机以及分布式虚拟交换机。
esxcli network ip               # 管理VMkernel端口，包括管理、vMotion以及FT网络。还可以修改主机的所有IP栈，包括DNS、IPsec以及路由信息。

# esxcli software – 软件命名空间可以用于检索ESXi主机已安装的软件及驱动并可以安装新组件。
esxcli software vib list      # 列出ESXi主机上已经安装的软件及驱动。

# esxcli storage – 可能是最常用的esxcli命令命名空间之一，包括了管理连接到vSphere的存储的所有信息。
esxcli storage core device list                        # 列出当前存储设备
esxcli storage core device vaai status get   # 获得存储设备支持的VAAI的当前状态。

# esxcli system – 通过该命令使你能够控制ESXi的高级选项，比如设置syslog并管理主机状态。
esxcli system maintenanceMode set –enabled yes/no   # 将主机设置为维护模式
# 查看并更改ESXi高级设置（提示：使用esxcli system settings  advanced list –d 命令查看非默认设置）
esxcli system syslog                      # 查看 Syslog 及配置信息
esxcli system logs query              # 查询主机日志
esxcli system logs rotate -n 30   # 设置日志保留天数为30天

# esxcli vm – ESXi的虚拟机命名空间用于列出运行在主机上的虚拟机的各种信息，如果需要可以强制关闭这些虚拟机。
esxcli vm process list         # 列出已启动的虚拟机的进程信息。
esxcli vm process kill         # 停止正在运行的虚拟机的进程，关闭虚拟机或者强制关闭虚拟机电源。

# esxcli vsan – ESXi的VSAN命名空间包括配置并维护VSAN的很多命令，包括数据存储、网络、默认域名以及策略配置。
esxcli vsan storage           # 配置VSAN使用的本地存储，包括增加、删除物理存储并修改自动声明。
esxcli vsan cluster             # 本地主机脱离/加入VSAN集群。

# esxcli esxcli – esxcli命令包括一个称为esxcli的命名空间，通过使用esxcli命名空间，你可以获得更多信息。
esxcli esxcli command list          # 列出所有的esxcli命令及其提供的功能。
```

当然，上述命令及示例并未涵盖ESXi提供的所有功能。所有的ESXi命令有多个开关及选项，提供了多种功能。通过输入-h参数可以获得相关帮助信息。

```bash
esxcli network ip interface list                                        # 显示主机的所有网络接口信息
esxcli network vswitch standard portgroup add         # 添加一个端口组
esxcli network vswitch standard portgroup remove  # 删除一个端口组
esxcli network ip neighbor list                                       # 显示主机的ARP缓存表

esxcli system access user list          # 显示所有本地用户
esxcli system access group add     # 添加一个用户组
esxcli system access user create   # 创建一个本地用户
```

‍

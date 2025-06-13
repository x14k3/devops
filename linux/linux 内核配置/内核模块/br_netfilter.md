
## br_netfilter 模块开机自动方法

环境

cat /etc/redhat-release  
CentOS Linux release 7.4.1708 (Core)

在/etc/sysctl.conf中添加：

```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1 
```

执行sysctl -p 时出现：

```
[root@localhost ~]# sysctl -p
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: No such file or directory
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory
```

解决方法：

```
[root@localhost ~]# modprobe br_netfilter
[root@localhost ~]# sysctl -p
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

重启后模块失效，下面是开机自动加载模块的脚本

在/etc/新建rc.sysinit 文件

cat /etc/rc.sysinit

```
#!/bin/bash
for file in /etc/sysconfig/modules/*.modules ; do
[ -x $file ] && $file
done
```

在/etc/sysconfig/modules/目录下新建文件如下

```
cat /etc/sysconfig/modules/br_netfilter.modules
modprobe br_netfilter
```

增加权限

```
chmod 755 br_netfilter.modules
```

重启后 模块自动加载

```
[root@localhost ~]# lsmod |grep br_netfilter
br_netfilter           22209  0
bridge                136173  1 br_netfilter
```

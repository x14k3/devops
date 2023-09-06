# CentOS8 dnf

DNF是新一代的rpm软件包管理器。最早出现在 Fedora 18 这个发行版中，在Fedora 22中正式取代了yum

DNF器克服了YUM的一些瓶颈，提升了包括用户体验，内存占用，依赖分析，运行速度等多方面的内容。

### dnf安装

在CentOS7中需要单独安装

```
yum install epel-release -y
yum install dnf
```

在CentOS8中系统默认使用的是DNF，我们所看到的yum只是dnf的一个软连接

```
[root@zutuanxue ~]# which yum
/usr/bin/yum
[root@zutuanxue ~]# ll /usr/bin/yum 
lrwxrwxrwx. 1 root root 5 5月  14 2019 /usr/bin/yum -> dnf-3
```

#### **相关目录和使用**

* **目录**

/etc/dnf/dnf.conf 配置文件

/etc/dnf/aliases.d/ 为相关命令定义别名的如dnf alias add rm=remove

/etc/dnf/modules.d&/etc/dnf/modules.defaults.d 模块的设置

/etc/dnf/plugins/ 插件的设置

/etc/dnf/protected.d/ 受保护的软件包的设置

/etc/dnf/vars/ 变量设置

* **dnf用法展示**

```bash
查看DNF的版本
[root@zutuanxue ~]# dnf --version

查看dnf的可用软件仓库
[root@zutuanxue ~]# dnf repolist

查看所有软件仓库
[root@zutuanxue ~]# dnf repolist all

查看已安装的软件包
[root@zutuanxue ~]# dnf list installed	  

查看可安装的软件包
[root@zutuanxue ~]# dnf list available 

搜索dhcp-server
[root@zutuanxue ~]# dnf search dhcp-server

查询一个文件是由哪个软件包提供的
[root@zutuanxue ~]# dnf provides /usr/sbin/dhclient

查询软件包详细信息
[root@zutuanxue ~]# dnf info dhcp-server

安装软件包
[root@zutuanxue ~]# dnf install dhcp-server

升级软件包
[root@zutuanxue ~]# dnf update systemd

检查软件包的更新
[root@zutuanxue ~]# dnf check-update

升级所有可升级的软件包
[root@zutuanxue ~]# dnf update

升级所有可升级的软件包
[root@zutuanxue ~]# dnf upgrade

卸载软件包
[root@zutuanxue ~]# dnf remove dhcp-server
[root@zutuanxue ~]# dnf erase dhcp-server

删除无用孤立的软件包
[root@zutuanxue ~]# dnf autoremove

清除缓存中的无用数据
[root@zutuanxue ~]# dnf clean all

获取某一个命令的帮助
[root@zutuanxue ~]# dnf help clean

获取dnf命令的帮助
[root@zutuanxue ~]# dnf help

查看历史命令
[root@zutuanxue ~]# dnf history

重新执行历史命令中的第19条
[root@zutuanxue ~]# dnf history redo 19

查看软件包组
[root@zutuanxue ~]# dnf grouplist

安装一组软件包
[root@zutuanxue ~]# dnf groupinstall '系统工具' 

升级一组软件包
[root@zutuanxue ~]# dnf groupupdate '系统工具'

删除一组软件包
[root@zutuanxue ~]# dnf groupremove '系统工具'

从特定的软件仓库安装软件包
[root@zutuanxue ~]# dnf --enablerepo=epel install zabbix

将软件包更新到最新的稳定版
[root@zutuanxue ~]# dnf distro-sync

重新安装指定的软件包
[root@zutuanxue ~]# dnf reinstall dhcp-server

降级软件包
[root@zutuanxue ~]# dnf downgrade dhcp-server
```

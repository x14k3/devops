# Corosync

## corosync简介

　　Corosync是OpenAIS发展到Wilson版本后衍生出来的开放性集群引擎工程，corosync最初只是用来演示OpenAIS集群框架接口规范的一个应用，可以说corosync是OpenAIS的一部分，但后面的发展明显超越了官方最初的设想，越来越多的厂商尝试使用corosync作为集群解决方案。如RedHat的RHCS集群套件就是基于corosync实现。
corosync只提供了message layer，而没有直接提供CRM，一般使用Pacemaker进行资源管理。

## pacemaker简介

　　pacemaker就是Heartbeat 到了V3版本后拆分出来的资源管理器(CRM)，用来管理整个HA的控制中心，要想使用pacemaker配置的话需要安装一个pacemaker的接口，它的这个程序的接口叫crmshell，它在新版本的 pacemaker已经被独立出来了，不再是pacemaker的组成部分。

　　详细介绍请见：[https://www.linuxidc.com/Linux/2016-08/133864.htm](https://www.linuxidc.com/Linux/2016-08/133864.htm)

## 基础环境准备

　　两台互通的机器，如IP地址分别为：192.168.2.101，192.168.2.102

## 主机名设置

　　在两台机器上分别设置

```
vi /etc/hosts
```

　　尾部添加

```
192.168.2.101 node1
192.168.2.102 node2

```

　　在node1上验证

```
ping -c 3 node2
```

　　在node2上验证

```
ping -c 3 node1
```

　　两边都能ping通

## 修改验证主机名

```
vi /etc/sysconfig/network
```

　　将node1机器设置为：HOSTNAME=node1
将node2机器设置为：HOSTNAME=node2

## 关闭防火墙

```
iptables -F
service iptables stop
chkconfig iptables off
```

## 集群部署

## 本地安装corosync pacemaker crmsh

　　两台机器都要先安装好

```
# 上传本地cluster_rpm.tar.gz包到服务器，我的放在/home/tmp目录下
cd /home/tmp
tar -zxvf cluster_rpm.tar.gz
yum -y localinstall rpm/*.rpm
```

> 不能本地安装的请在线安装

## 修改corosync.conf配置文件

```
cd /etc/corosync/
cp corosync.conf.example corosync.conf
vi corosync.conf
# secauth改为on
# 修改bindnetaddr为192.168.2.0保证机器IP与它在同一个网段
# 在末尾增加如下配置
 service {
         var: 0
         name: pacemaker
 }
 aisexec {
         user: root
         group: root
 }
```

## 生成密钥

　　在/etc/corosync目录执行

```
corosync-keygen
```

## 同步密钥和配置

```
scp authkey corosync.conf node2:/etc/corosync/
```

## 启动服务

　　两台机器上都启动

```
service corosync start
chkconfig corosync on # 开启启动
```

## 验证

```
corosync-cfgtool -s
corosync-objctl | grep members
```

## CRM配置

　　只需要在一台机器上操作就可以了，下面的配置只能保证多个节点中只有一个节点的资源处于运行状态，当主节点挂掉后，corosync会自动启动其他节点来继续提供服务。

## 进入crm管理命令窗口

```
crm
```

## 查看状态

```
crm(live)# status
```

　　输出如下，表示两个节点都已经互通了处于在线状态，但是还没有配置资源

```
Stack: classic openais (with plugin)
Current DC: node1 (version 1.1.15-5.el6-e174ec8) - partition with quorum
Last updated: Tue May 21 17:01:15 2019          Last change: Tue May 21 16:57:14 2019 by hacluster via crmd on node1
, 2 expected votes
2 nodes and 0 resources configured

Online: [ node1 node2 ]

No resources
```

## 配置参数

```
crm(live)# configure
crm(live)configure# property stonith-enabled=false
crm(live)configure# property no-quorum-policy=ignore
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show
# 输出如下
node node1
node node2
property cib-bootstrap-options: \
        have-watchdog=false \
        dc-version=1.1.15-5.el6-e174ec8 \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes=2 \
        stonith-enabled=false \
        no-quorum-policy=ignore
```

> 由于这里部署的是两个节点所以no-quorum-policy必须设置为ignore，否则当一个节点关机后另外一个节点就不正常了（生成环境应该至少三个节点，其中一个可以作为投票节点）

## 增加虚拟IP资源

```
crm(live)configure# primitive vip ocf:heartbeat:IPaddr params ip=192.168.2.100
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show
node node1
node node2
primitive vip IPaddr \
        params ip=192.168.2.100
property cib-bootstrap-options: \
        have-watchdog=false \
        dc-version=1.1.15-5.el6-e174ec8 \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes=2 \
        stonith-enabled=false \
        no-quorum-policy=ignore
```

> 添加资源后发现添加错了，可以删除掉再添加，如：delete vip

## 增加我的服务资源

　　我的程序名字是gohttpd是一个简单的http服务，监听8081端口，输出当前机器IP和时间。
crm要管理的资源必须符合它的规则，需要在/etc/init.d目录下添加控制程序的脚本，脚本名是gohttpd，内容如下：

```
SHELL_PATH="$( cd `dirname "$0"` && pwd )"
BIN_PATH=/home/tujiaw/
RETVAL=0
start() {
        echo -n $"start gohttpd..."
        ${BIN_PATH}gohttpd &
        return $RETVAL
}

stop() {
        echo -n $"stop gohttpd..."
        pkill -9 gohttpd
}

case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
esac

exit $RETVAL
```

　　我的程序放在/home/tujiaw目录下

　　同步程序和脚本到另外一台机器

```
# node2机器的/home目录下创建：mkdir tujiaw
# 在node1机器上执行同步操作
scp /home/tujiaw/gohttpd node2:/home/tujiaw
scp /etc/init.d/gohttpd node2:/etc/init.d
```

　　验证两台机器上的gohttpd资源是否准备好

```
crm
crm(live)# ra
crm(live)ra# classes
crm(live)ra# list lsb
gohttpd  # 输出的列表里面有gohttpd说明已经准备好的
```

　　添加资源

```
crm(live)# configure
crm(live)configure# primitive gohttpd lsb:gohttpd
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show
node node1
node node2
primitive gohttpd lsb:gohttpd
primitive vip IPaddr \
        params ip=192.168.2.100
property cib-bootstrap-options: \
        have-watchdog=false \
        dc-version=1.1.15-5.el6-e174ec8 \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes=2 \
        stonith-enabled=false \
        no-quorum-policy=ignore
```

　　此时通过浏览器就可以访问gohttpd服务了，由于node1和node2只有一个为主所以只有下面的其中一个地址能提供服务：

```
http://192.168.2.101:8081/
http://192.168.2.102:8081/
```

　　要想做到高可用我们应该通过vip地址来访问，上面两个地址任何一个挂了都不影响正常服务，下面就是通过分组将vip与gohttpd服务绑在一起来实现。

　　分组将虚拟IP资源绑在一定

```
crm(live)# configure
crm(live)configure# group my_group vip gohttpd
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show
node node1
node node2
primitive gohttpd lsb:gohttpd
primitive vip IPaddr \
        params ip=192.168.2.100
group my_group vip gohttpd
property cib-bootstrap-options: \
        have-watchdog=false \
        dc-version=1.1.15-5.el6-e174ec8 \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes=2 \
        stonith-enabled=false \
        no-quorum-policy=ignore
```

　　这样通过虚拟IP就可以访问到http服务了,当发生节点切换后对用户而言无感知，虚拟IP能够帮我们访问到后台可用的地址

```
访问：http://192.168.2.100:8081/
如果显示node1节点的信息，standby node1节点再次访问的时候显示的是node2节点的信息
可以使用standby和online节点名字来切换状态看看
```

　　本文转自：https://ningto.com/

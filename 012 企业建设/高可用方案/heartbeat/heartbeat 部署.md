# heartbeat 部署

　　Heartbeat 是一款开源提供高可用（Highly-Available）服务的软件，通过 heartbeat 可以将资源（IP及程序服务等资源）从一台已经故障的计算机快速转移到另一台正常运转的机器上继续提供服务，一般称之为高可用服务。在实际生产应用场景中，heartbeat 的功能和另一个高可用软件 keepalived 有很多相同之处，但在生产中，对应实际的业务应用也是有区别的，例如： **keepalived 主要是控制IP的漂移，配置、应用简单，而 heartbeat 则不但可以控制IP漂移，更擅长对资源服务的控制，配置、应用比较复杂。**

# 一、实验准备

|名称|ip|部署软件|
| ----| ---------------| --------|
|vip|192.168.0.100||
|web1|192.168.137.104|nginx|
|web2|192.168.137.105|nginx|

1. 安装nginx
   `yum install nginx`
2. 参考 [ntp](../Linux企业服务/ntp.md) 搭建时间同步是服务器
3. 配置主机名解析
   `hostnamectl set-hostname www.nginx1.com`
4. 创建所需要的用户和组
   `groupadd haclient ; useradd -g haclient hacluster`
5. 创建安装目录 `mkdir -p /data/heartbeat`
6. 参考 [linux ssh](../Linux系统管理/linux%20ssh.md) 部署免密认证

# 二、heartbeat 部署

## 1. 下载安装包，安装依赖

　　`yum install gcc gcc-c++ autoconf automake libtool glib2-devel libxml2-devel bzip2 bzip2-devel e2fsprogs-devel libxslt-devel libtool-ltdl-devel asciidoc`

　　下载源码包并上传到 /opt

　　[Cluster Glue.tar.bz2](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/277d2ff6-a54b-43d9-904e-a19551895408/Cluster_Glue.tar.bz2 "Cluster Glue.tar.bz2")

　　[heartbeat.tar.bz2](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/71fff30b-c2ca-4424-8c2b-858e86f98b37/heartbeat.tar.bz2 "heartbeat.tar.bz2")

　　[resource-agents-3.9.6.tar.gz](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/161a32b1-b532-4c71-8200-c9b7ab237cf5/resource-agents-3.9.6.tar.gz "resource-agents-3.9.6.tar.gz")

## 2. 安装 glue

```bash
tar -jxvf Cluster\ Glue.tar.bz2
cd Reusable-Cluster-Components-glue--0a7add1d9996

# 重新根据当前所处环境生成新的configure
./autogen.sh  

#用来生成 Makefile,为下一步的编译做准备
./configure --prefix=/data/heartbeat --with-daemon-user=hacluster --with-daemon-group=haclient --enable-fatal-warnings=no LIBS='/lib64/libuuid.so.1' 

#编译、安装
make && make install
```

## 3. 安装 resource-agents

```bash
tar -zxvf resource-agents-3.9.6.tar.gz
cd resource-agents-3.9.6
./autogen.sh
./configure --prefix=/data/heartbeat --with-daemon-user=hacluster --with-daemon-group=haclient --enable-fatal-warnings=no LIBS='/lib64/libuuid.so.1'
make && make install
```

## 4. 安装 heartbeat

```bash
tar -jxvf heartbeat.tar.bz2

cd Heartbeat-3-0-958e11be8686/
#构建出项目环境来
./bootstrap
export CFLAGS="$CFLAGS -I/data/heartbeat/include -L/data/heartbeat/lib"

./configure --prefix=/data/heartbeat --with-daemon-user=hacluster --with-daemon-group=haclient --enable-fatal-warnings=no LIBS='/lib64/libuuid.so.1'

make && make install
```

## 5. 复制配置文件

```bash
cd /tmp/heartbeat/Heartbeat-3-0-958e11be8686/doc

#拷贝三个模版配置文件到 /data/heartbeat/etc/ha.d 目录下
cp {ha.cf,haresources,authkeys} /data/heartbeat/etc/ha.d/
chmod 600 /data/heartbeat/etc/ha.d/authkeys

#配置网卡支持插件文件
mkdir -pv /data/heartbeat/usr/lib/ocf/lib/heartbeat/
cp /usr/lib/ocf/lib/heartbeat/ocf-* /data/heartbeat/usr/lib/ocf/lib/heartbeat/

#注意：一般启动时会报错因为 ping和ucast这些配置都需要插件支持 需要将lib64下面的插件软连接到lib目录 才不会抛出异常
ln -svf /data/heartbeat/lib64/heartbeat/plugins/RAExec/* /data/heartbeat/lib/heartbeat/plugins/RAExec/
ln -svf /data/heartbeat/lib64/heartbeat/plugins/* /data/heartbeat/lib/heartbeat/plugins/

mkdir /usr/lib64/heartbeat/
cp /data/heartbeat/libexec/heartbeat/* /usr/lib64/heartbeat/
```

# 三、修改配置文件

　　`cd /data/heartbeat/etc/ha.d/`

## 1. 修改 authkeys

　　该文件表示发送心跳时 机器用于验证的key的hash算法，节点之间必须配置成一致的密码

```bash
auth 1          #表示使用id为1的验证 下边需要定义一个1的验证算法
1 sha1 1a2b3c    #ID 1的验证加密为shal,并添加密码
```

## 2. 修改 ha.cf

　　该配置文件用于配置 心跳的核心配置

```bash
logfile /var/log/ha-log
keepalive 2
deadtime 30
warntime 10 
initdead 120
udpport 694     
ucast ens33 192.168.137.105
auto_failback on
node www.nginx1.com 
node www.nginx2.com
respawn hacluster /usr/lib64/heartbeat/ipfail
```

## 3. 修改 haresources

　　该文件表示资源的管理，如果是主机，当主机启动后自动加载该文件中配置的所有启动资源，资源脚本默认在haresources同级目录下的resource.d目录下

```bash
www.nginx1.com 192.168.0.100/24/ens33:0 nginx.sh
#www.nginx1.com     主服务器名  
#192.168.0.100/24/  VIP地址
#ens33:0            网卡名
#nginx.sh           resource.d/下写的脚本启动时运行
```

### 资源脚本 ngixn.sh

　　`vim /data/heartbeat/etc/ha.d/resource.d/nginx.sh`

```bash
#!/bin/bash
if [ $(netstat -lnupt | grep nginx | wc -l) -eq 0 ];then
        systemctl restart nginx
        if [ $(netstat -lnupt | grep nginx | wc -l) -eq 0 ];then
                systemctl stop heartbeat
        fi
else
        echo "nginx" &> /dev/null
fi
```

　　添加执行权限`chmod u+x nginx.sh`

## 4. 节点2上准备配置文件

　　拷贝三个配置好的文件到节点2上，只需修改ha.cf配置文件中的单播地址为对方地址即可(ucast ens33 192.168.137.104)。

```bash
cd /data/heartbeat/etc/ha.d/`
scp authkeys ha.cf haresources root@192.168.137.105:/data/heartbeat/etc/ha.d/`
```

## 5. 目录权限

　　`chown -R  hacluster:haclient /data/`

# 四、测试

```bash
# 开启heartbeat服务(先主后备)
systemctl restart heartbeat
# 查看nginx服务和网卡信息
netstat -tunlp|grep nginx
ip addr

# 测试机添加路由
route add -host 192.168.0.100 dev ens33
# 测试机访问vip
curl 192.168.0.100
# 关闭web1的heartbeat服务
systemctl stop heartbeat
# 再访问vip
curl 192.168.0.100
# 查看web2的网卡信息

# 开启web1的heartbeat服务
systemctl stop heartbeat
# 再次访问vip
curl 192.168.0.100
```

# 五、HA集群错误排障

```bash
[root@133 ha.d]# cat /var/log/ha-log 
**问题一:**
ERROR: **Client child command [/usr/lib/heartbeat/ipfail] is not executable**
ERROR: Heartbeat not started: configuration error.
ERROR: Configuration error, heartbeat not started.

**解决方案:**
错误日志提示：意思是这个文件不是可执行文件。
则用find / -name ipfail命令去查找了一下ipfail这个文件，
发现它是在/usr/lib64/heartbeat/ipfail 这个目录下，
因此在配置HA集群的时候要注意所使用的centos是32位还是64位的。
用uname -i  进行查看. **32位放在/usr/lib/下 64位放在/usr/lib64下**

=====================================================================
**问题二:**
ERROR: **Bad permissions on keyfile [/etc/ha.d//authkeys], 600 recommended.**
ERROR: Authentication configuration error.
ERROR: Configuration error, heartbeat not started.
**info: Pacemaker support: false

解决方案:**
chmod 600 authkeys即可

****=====================================================================
****
**问题三:**
**ERROR: Current node [133] not in configuration!**
info: By default, cluster nodes are named by `uname -n` and must be declared with a 'node' directive in the ha.cf file.
info: See also: http://linux-ha.org/wiki/Ha.cf#node_directive
WARN: Logging daemon is disabled --enabling logging daemon is recommended
ERROR: Configuration error, heartbeat not started.
info: Pacemaker support: false

**解决方案:**
表示节点不在配置文件中。
主要要考虑主机名的配置上是否一致则对/etc/ha.d目录下的三个文件
进行authkeys、authkeys、ha.cf修改
========================================================================
```

# 六、heartbeat配置文件详解

　　**heartbeat**主要的**配置**文件有3个，**authkeys, ha.cf 和 haresources** 。下面具体说一下这3个文件的具体功能以及**配置**

## 1. authkeys

　　heartbeat的认证配置文件

```bash
#auth 1
#1 crc
#2 sha1 HI!
#3 md5 Hello!
注释说得很清楚，在这里我还是解释一下，该文件主要是用于集群中两个节点的认证，采用的算法和密钥(如果有的话)在集群中节点上必须相同，目前提供了3种算法：md5,sha1和crc。其中crc不能够提供认证，它只能够用于校验数据包是否损坏，而sha1,md5需要一个密钥来进行认证，从资源消耗的角度来讲，md5消耗的比较多，sha1次之，因此建议一般使用sha1算法。
我们如果要采用sha1算法，只需要将authkeys中的auth 指令(去掉注释符)改为2，而对应的2 sha1行则需要去掉注释符(#)，后面的密钥自己改变(两节点上必须相同)。改完之后，保存，同时需要改变该文件的属性为600，否则heartbeat启动将失败。具体命令为：chmod 600 authkeys
```

## 2. ha.cf

　　heartbeat的主要配置文件

```bash
debugfile /var/log/ha-debug
#将调试日志文件

logfile  /var/log/ha-log
#将其他消息写入的日志文件

#logfacility  local0
#使用系统日志syslog（不建议使用）

keepalive 2
#心跳间隔多长时间（默认时间单位是秒）

deadtime 30
#在30秒后宣布节点死亡。

warntime 10
#在日志中发出“late heartbeat“警告之前等待的时间，单位为秒。

initdead 120
#在某些配置下，重启后网络需要一些时间才能正常工作。
#它的取值至少应该为通常deadtime的两倍。

udpport  694
#使用端口694进行bcast和ucast通信。这是默认的

#baud  19200
#波特率，串口通信的速度。
#用于双机使用串口线连接的情况。如果双机使用以太网连接,则应该关闭该选项。

#  serial  serialportname ...
#serial  /dev/ttyS0  # Linux
#serial  /dev/cuaa0  # FreeBSD
#serial /dev/cuad0  # FreeBSD 6.x
#serial  /dev/cua/a  # Solaris
#
#
#  What interfaces to broadcast heartbeats over?
#
#bcast  eth0    # Linux
#bcast  eth1 eth2  # Linux
#bcast  le0    # Solaris
#bcast  le1 le2    # Solaris

#mcast ens33 225.0.0.1 694 1 0
#设置多播心跳

ucast ens33 192.168.137.105
#设置单播心跳 【ucast 网卡名 从服务器ip】
#在从服务器上要改成主服务器ip

auto_failback on
#该选项是必须配置的。
#当auto_failback设置为on时，一旦主节点重新恢复联机，将从从节点取回所有资源。
#若该选项设置为off，主节点便不能重新获得资源。

node  www.nginx1.com
node  www.nginx2.com
#该选项是必须配置的。HA集群中机器的主机名，与“uname –n”的输出相同。

#ping 10.10.10.254
#将10.10.10.254视为伪集群成员
#与下面的ipfail一起使用...
#注意：不要将群集节点用作ping节点

respawn hacluster /usr/lib/heartbeat/ipfail
#使得Heartbeat以userid（在本例中为hacluster）的身份来执行该进程并监视该进程的执行情况，
#如果其死亡便重启之。
```

## 3. haresource

　　该文件表示资源的管理，如果是主机，当主机启动后自动加载该文件中配置的所有启动资源，资源脚本默认在haresources同级目录下的resource.d目录下

```bash
www.nginx1.com 192.168.0.100/24/ens33:0 nginx.sh
#www.nginx1.com     主服务器名  
#192.168.0.100/24/  VIP地址
#ens33:0            网卡名
#nginx.sh           resource.d/下写的脚本启动时运行
```

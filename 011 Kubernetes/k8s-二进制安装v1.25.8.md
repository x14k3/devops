# k8s-二进制安装v1.25.8

安装说明：

1. 本文章将演示CentOS 7二进制方式安装高可用k8s ；
2. 生产环境中，建议使用小版本大于5的Kubernetes版本，比如1.19.5以后的才可用于生产环境。
3. 本文档安装版本为v1.25.8；
4. k8s集群1.24以及以上版本官方不在支持docker作为容器运行时；需要下载containerd和runc；
5. master节点为部署节点，主要操作都是在master节点执行，然后分发到集群各个节点；

部署架构图如下：

​![](assets/net-img-1675881-20230403100444428-1726387034-20230824180139-5k5o4u2.png)​

1. 由外部负载均衡器提供一个vip，流量负载到keepalived master节点上。
2. 当keepalived节点出现故障, vip自动漂到其他可用节点。
3. haproxy负责将流量负载到apiserver节点。
4. 三个apiserver会同时工作。注意k8s中controller-manager和scheduler只会有一个工作，其余处于backup状态。我猜测apiserver主要是读写数据库，数据一致性的问题由数据库保证，此外apiserver是k8s中最繁忙的组件，多个同时工作也有利于减轻压力。而controller-manager和scheduler主要处理执行逻辑，多个大脑同时运作可能会引发混乱。

# 一、集群矩阵

## 1.1 网段划分

|网段名称|网段|备注|
| -----------------| -----------------| ------|
|node网段|192.168.75.0/24||
|k8s service网段|10.96.0.0/12||
|k8s pod网段|172.16.0.0/12||

注意：

1. node节点IP地址不能设置成dhcp，要配置成静态IP；VIP（虚拟IP）不要和公司内网IP重复，首先去ping一下，不通才可用；VIP需要和主机在同一个局域网内！
2. node网段、K8s Service网段、k8s Pod网段不能重复!

## 1.2 节点信息

|主机名|IP|操作系统|角色|主机配置|软件列表|
| -----------| ----------------| -----------| -------------------------------------| ----------| --------------------------------------------------------------------------------------------------------------------------------------------|
|master|192.168.75.10|centos7.9|k8s-master、k8s-node、keepalived-主|2C2G 40G|haproxy、keepalived、kube-apiserver、kube-controller-manager、kube-scheduler、etcd、kubelet、kube-proxy、Containerd、runc、calico、coreDNS|
|master1|192.168.75.13|centos7.9|k8s-master、k8s-node、keepalived-从|2C2G 40G|haproxy、keepalived、kube-apiserver、kube-controller-manager、kube-scheduler、etcd、kubelet、kube-proxy、Containerd、runc、calico、coreDNS|
|master2|192.168.75.14|centos7.9|k8s-master、k8s-node、keepalived-从|2C2G 40G|haproxy、keepalived、kube-apiserver、kube-controller-manager、kube-scheduler、etcd、kubelet、kube-proxy、Containerd、runc、calico、coreDNS|
|node1|192.168.75.11|centos7.9|k8s-node|2C2G 40G|kubelet、kube-proxy、Containerd、runc、calico、coreDNS|
|node2|192.168.75.12|centos7.9|k8s-node|2C2G 40G|kubelet、kube-proxy、Containerd、runc、calico、coreDNS|
|master-lb|192.168.75.100|无|vip|无|无，VIP 虚IP不占用机器资源,如果不是高可用集群，该IP为Master的IP|

## 1.3 软件版本信息

|软件名称|版本|备注|
| ------------| ---------| --------------|
|keepalived|v1.3.5|yum默认|
|haproxy|v1.5.18|yum默认|
|cfssl|v1.2.0|制作证书工具|
|etcd|v3.5.7||
|kubernetes|v1.25.8||
|Containerd|v1.6.19|配置runtime|
|runc|v1.1.4||
|calico|v3.24.5||

‍

# 二、基本环境准备

## 2.1 配置所有节点hosts文件

```
[root@master ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.75.10   master
192.168.75.11   node1
192.168.75.12   node2
192.168.75.13   master1
192.168.75.14   master2
192.168.75.100master-lb
```

## 2.2 所有节点CentOS 7安装yum源

```
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
```

## 2.3 所有节点安装工具(选安)

```
yum install wget jq psmisc vim net-tools telnet yum-utils device-mapper-persistent-data lvm2 git lrzsz -y

```

## 2.4 关闭防火墙

所有节点关闭firewalld 、dnsmasq、selinux(CentOS7需要关闭NetworkManager，CentOS8不需要)

```
systemctl disable --now firewalld
systemctl disable --now dnsmasq
systemctl disable --now NetworkManager
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

## 2.5 关闭swap分区

所有节点关闭swap分区，fstab注释swap

```
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

## 2.6 所有节点同步时间

chrony

## 2.7 所有节点配置limit

```
ulimit -SHn 65535

vim /etc/security/limits.conf

# 末尾添加如下内容
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* soft memlock unlimited
* hard memlock unlimited
```

## 2.8 配置免密

```bash
# apt install -y sshpass
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.8.61 192.168.8.62 192.168.8.63 192.168.8.64 192.168.8.65"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done
```

## 2.9 所有节点升级系统

升级系统并重启

```
yum update -y --exclude=kernel* && reboot     #CentOS7需要升级，CentOS8可以按需升级系统
```

内核升级：CentOS7 需要升级内核至4.18+，本次升级的版本为4.19

```bash
######## 添加启用源
# Ubuntu忽略，CentOS执行

# 为 RHEL-8或 CentOS-8配置源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-7 SL-7 或 CentOS-7 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 查看可用安装包
yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available

########### 升级内核至4.18版本以上

# Ubuntu忽略，CentOS执行

# 安装最新的内核
# 我这里选择的是稳定版kernel-ml   如需更新长期维护版本kernel-lt  
yum -y --enablerepo=elrepo-kernel  install  kernel-ml

# 查看已安装那些内核
rpm -qa | grep kernel

# 查看默认内核
grubby --default-kernel

# 若不是最新的使用命令设置
grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo)

# 重启生效
reboot
```

## 2.10 所有节点安装配置ipvsadm

### 2.10.1 安装ipvsadm

```
yum install ipvsadm ipset sysstat conntrack libseccomp -y
```

### 2.10.2所有节点配置ipvs模块

在内核4.19+版本nf_conntrack_ipv4已经改为nf_conntrack， 4.18以下使用nf_conntrack_ipv4即可：

1.执行如下命令

```
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
```

2.编辑ipvs.conf

```
vim /etc/modules-load.d/ipvs.conf
# 加入以下内容
ip_vs
ip_vs_lc
ip_vs_wlc
ip_vs_rr
ip_vs_wrr
ip_vs_lblc
ip_vs_lblcr
ip_vs_dh
ip_vs_sh
ip_vs_fo
ip_vs_nq
ip_vs_sed
ip_vs_ftp
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
```

3.然后执行

```
systemctl enable --now systemd-modules-load.service
```

### 2.10.3检查是否加载

```
[root@master ~]# lsmod | grep -e ip_vs -e nf_conntrack
ip_vs_sh               16384  0
ip_vs_wrr              16384  0
ip_vs_rr               16384  0
ip_vs                 151552  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          143360  1 ip_vs
nf_defrag_ipv6         20480  1 nf_conntrack
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  3 nf_conntrack,xfs,ip_vs


#所有节点都检查下
for i in master1 master2 node1 node2 ;do ssh $i lsmod | grep -e ip_vs -e nf_conntrack  ; done

```

## 2.11 开启一些k8s集群中必须的内核参数

1.所有节点配置k8s内核

```
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384
EOF

sysctl --system
```

2.所有节点配置完内核后，重启服务器，保证重启后内核依旧加载

```
reboot
lsmod | grep --color=auto -e ip_vs -e nf_conntrack

for i in master1 master2 node1 node2 ;do ssh $i lsmod | grep --color=auto -e ip_vs -e nf_conntrack  ; done
```

# 三、高可用组件安装

‍

## 3.1 keepalived和haproxy 高可用方案 （不推荐）

‍

### 3.1.1 所有master节点下载haproxy和keepalived

```
yum -y install haproxy keepalived

```

### 3.1.2 所有master节点配置haproxy （配置一样）

```
cat >/etc/haproxy/haproxy.cfg<<"EOF"
global
maxconn 2000
ulimit-n 16384
log 127.0.0.1 local0 err
stats timeout 30s

defaults
log global
mode http
option httplog
timeout connect 5000
timeout client 50000
timeout server 50000
timeout http-request 15s
timeout http-keep-alive 15s

frontend k8s-master
bind 0.0.0.0:8443
bind 127.0.0.1:8443
mode tcp
option tcplog
tcp-request inspect-delay 5s
default_backend k8s-master

backend k8s-master
mode tcp
option tcplog
option tcp-check
balance roundrobin
default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
server  master1  192.168.75.13:6443 check
server  master2  192.168.75.14:6443 check
server  master  192.168.75.10:6443 check
EOF

```

### 3.1.3 所有master节点配置keepalived （注意主从配置不一样）

主master:

```
cat >/etc/keepalived/keepalived.conf<<"EOF"          
! Configuration File for keepalived                  
global_defs {                                        
   router_id LVS_DEVEL                               
script_user root                                     
   enable_script_security                            
}                                                    
vrrp_script chk_apiserver {                          
   script "/etc/keepalived/check_apiserver.sh"       
   interval 5                                        
   weight -5                                         
   fall 2                                            
rise 1                                               
}                                                    
vrrp_instance VI_1 {                                 
   state MASTER                                      
   interface ens33                                   
   mcast_src_ip 192.168.75.10                        
   virtual_router_id 51                              
   priority 100                                      
   advert_int 2                                      
   authentication {                                  
       auth_type PASS                                
       auth_pass K8SHA_KA_AUTH                       
   }                                                 
   virtual_ipaddress {                               
       192.168.75.100                                
   }                                                 
   track_script {                                    
      chk_apiserver                                  
   }                                                 
}
EOF

```

从master1：

```
cat >/etc/keepalived/keepalived.conf<<"EOF"
! Configuration File for keepalived
global_defs {
   router_id LVS_DEVEL
script_user root
   enable_script_security
}
vrrp_script chk_apiserver {
   script "/etc/keepalived/check_apiserver.sh"
  interval 5
   weight -5
   fall 2 
rise 1
}
vrrp_instance VI_1 {
   state BACKUP
   interface ens33
   mcast_src_ip 192.168.75.13
   virtual_router_id 51
   priority 99
   advert_int 2
   authentication {
       auth_type PASS
       auth_pass K8SHA_KA_AUTH
   }
   virtual_ipaddress {
       192.168.75.100
   }
   track_script {
      chk_apiserver
   }
}
EOF

```

从master2：

```
cat >/etc/keepalived/keepalived.conf<<"EOF"
! Configuration File for keepalived
global_defs {
   router_id LVS_DEVEL
script_user root
   enable_script_security
}
vrrp_script chk_apiserver {
   script "/etc/keepalived/check_apiserver.sh"
  interval 5
   weight -5
   fall 2 
rise 1
}
vrrp_instance VI_1 {
   state BACKUP
   interface ens33
   mcast_src_ip 192.168.75.14
   virtual_router_id 51
   priority 99
   advert_int 2
   authentication {
       auth_type PASS
       auth_pass K8SHA_KA_AUTH
   }
   virtual_ipaddress {
       192.168.75.100
   }
   track_script {
      chk_apiserver
   }
}
EOF

```

### 3.1.4 所有master节点配置健康检查脚本

```
cat >/etc/keepalived/check_apiserver.sh<<"EOF"

#!/bin/bash

err=0
for k in $(seq 1 3)
do
check_code=$(pgrep haproxy)
if [[ $check_code == "" ]]; then
err=$(expr $err + 1)
sleep 1
continue
else
err=0
break
fi
done

if [[ $err != "0" ]]; then
echo "systemctl stop keepalived"
/usr/bin/systemctl stop keepalived
exit 1
else
exit 0
fi
EOF

##给执行权限
chmod +x /etc/keepalived/check_apiserver.sh

##所有master节点启动haproxy和keepalived

systemctl daemon-reload
systemctl enable --now haproxy
systemctl enable --now keepalived

```

### 3.1.5测试vip

​![](assets/net-img-1675881-20230331100053093-1840840046-20230824180139-w4ckp0e.png)​

‍

## 3.2 NGINX高可用方案 （推荐）

在所有节点执行

```bash
# 安装编译环境
yum install gcc -y

# 下载解压nginx二进制文件
wget http://nginx.org/download/nginx-1.22.1.tar.gz
tar xvf nginx-*.tar.gz
cd nginx-*

# 进行编译
./configure --with-stream --without-http --without-http_uwsgi_module --without-http_scgi_module --without-http_fastcgi_module
make && make install 

# 写入nginx配置文件
cat > /usr/local/nginx/conf/kube-nginx.conf <<EOF
worker_processes 1;
events {
    worker_connections  1024;
}
stream {
    upstream backend {
    	least_conn;
        hash $remote_addr consistent;
        server 192.168.8.61:6443        max_fails=3 fail_timeout=30s;
        server 192.168.8.62:6443        max_fails=3 fail_timeout=30s;
        server 192.168.8.63:6443        max_fails=3 fail_timeout=30s;
    }
    server {
        listen 127.0.0.1:8443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
EOF

# 写入启动配置文件
cat > /etc/systemd/system/kube-nginx.service <<EOF
[Unit]
Description=kube-apiserver nginx proxy
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStartPre=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/kube-nginx.conf -p /usr/local/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/kube-nginx.conf -p /usr/local/nginx
ExecReload=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/kube-nginx.conf -p /usr/local/nginx -s reload
PrivateTmp=true
Restart=always
RestartSec=5
StartLimitInterval=0
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target
EOF

# 设置开机自启
systemctl enable --now  kube-nginx 
systemctl restart kube-nginx
systemctl status kube-nginx
```

# 四、master节点执行配置证书工具cfssl

说明：

1. cfssl是使用go编写，由CloudFlare开源的一款PKI/TLS工具。主要程序有：cfssl和cfssljson
2. cfssl，是CFSSL的命令行工具;
3. cfssljson用来从cfssl程序获取JSON输出，并将证书，密钥，CSR和bundle写入文件中。

## 4.1 下载证书生成工具

cfssl的GitHub地址：[https://github.com/cloudflare/cfssl/releases/tag/1.2.0](https://github.com/cloudflare/cfssl/releases/tag/1.2.0)

```bash
# master01节点下载证书生成工具
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64" -O /usr/local/bin/cfssl
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64" -O /usr/local/bin/cfssljson

chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

[root@k8s-master01 ~]# cfssl version
Version: 1.6.1
Runtime: go1.12.12
```

## 4.2 配置ca证书策略

```bash
cfssl print-defaults config > /etc/kubernetes/pki/ca-config.json

#或
mkdir -p /etc/kubernetes/pki/
cd /etc/kubernetes/pki/
cat > ca-config.json <<"EOF"
{
  "signing": {
      "default": {
          "expiry": "87600h"
        },
      "profiles": {
          "kubernetes": {
              "usages": [
                  "signing",
                  "key encipherment",
                  "server auth",
                  "client auth"
              ],
              "expiry": "87600h"
          }
      }
  }
}
EOF


#server auth 表示client可以对使用该ca对server提供的证书进行验证
#client auth 表示server可以使用该ca对client提供的证书进行验证
```

# 五、所有master节点安装etcd集群（非标注则在master节点执行）

## 5.1 创建etcd证书

### 5.1.1 配置etcd请求文件

```bash
mkdir -p /etc/kubernetes/pki/etcd 
cd /etc/kubernetes/pki/etcd 

cat > etcd-ca-csr.json <<"EOF"
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "192.168.2.10",
    "192.168.2.11",
    "192.168.2.12"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [{
    "C": "CN",
    "ST": "Beijing",
    "L": "Beijing",
    "O": "kubemsb",
    "OU": "CN"
  }]
}
EOF

```

### 5.1.2生成etcd证书

```
# 生成etcd证书和etcd证书的key（如果你觉得以后可能会扩容，可以在ip那多写几个预留出来）
# 若没有IPv6 可删除可保留 
cfssl gencert -initca /etc/kubernetes/pki/etcd/etcd-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/etcd/etcd-ca
cfssl gencert \
   -ca=/etc/kubernetes/pki/etcd/etcd-ca.pem \
   -ca-key=/etc/kubernetes/pki/etcd/etcd-ca-key.pem \
   -config=/etc/kubernetes/pki/ca-config.json \
   -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,192.168.8.61,192.168.8.62,192.168.8.63,fc00:43f4:1eea:1::10,fc00:43f4:1eea:1::20,fc00:43f4:1eea:1::30 \
   -profile=kubernetes \
   /etc/kubernetes/pki/etcd/etcd-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/etcd/etcd

```

## 5.2 所有master下载etcd

github地址：[https://github.com/etcd-io/etcd/releases/](https://github.com/etcd-io/etcd/releases/)

```bash
wget https://github.com/etcd-io/etcd/releases/download/v3.5.7/etcd-v3.5.7-linux-amd64.tar.gz
tar -xvf etcd-v3.5.7-linux-amd64.tar.gz
cp -p etcd-v3.5.7-linux-amd64/etcd* /usr/local/bin/
```

‍

## 5.3 所有master创建etcd配置文件

```
mkdir -p /var/lib/etcd/default.etcd
mkdir -p /var/lib/etcd /var/lib/etcd/wal

cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://192.168.2.10:2380'
listen-client-urls: 'https://192.168.2.10:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://192.168.2.10:2380'
advertise-client-urls: 'https://192.168.2.10:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://192.168.2.10:2380,k8s-master02=https://192.168.2.11:2380,k8s-master03=https://192.168.2.12:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF


```

其他master节点需要修改【name】、【listen-peer-urls:】、【listen-client-urls】、【initial-advertise-peer-urls】、【advertise-client-urls】

‍

## 5.4 创建服务配置文件etcd.service

官网选项：[https://etcd.io/docs/v3.5/op-guide/configuration/](https://etcd.io/docs/v3.5/op-guide/configuration/)

```bash
cat > /usr/lib/systemd/system/etcd.service << EOF

[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.config.yml
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd3.service

EOF
```

## 5.5 分发证书文件及服务配置文件

```
#分发证书文件
Master="192.168.2.11 192.168.2.12"
for i in $Master ;do \
ssh $i "mkdir -p /etc/kubernetes/pki/etcd" ; \
scp /etc/kubernetes/pki/etcd/* $i:/etc/kubernetes/pki/etcd/ ; \
scp /usr/lib/systemd/system/etcd.service $i:/usr/lib/systemd/system/ ; \
done
```

## 5.6 所有节点执行启动etcd集群

```
systemctl daemon-reload
systemctl enable --now etcd.service
systemctl status etcd

```

## 5.7 验证集群状态

```bash
[root@k8s-master01 etcd]# ETCDCTL_API=3 /usr/local/bin/etcdctl \
--write-out=table \
--cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem \
--cert=/etc/kubernetes/pki/etcd/etcd.pem \
--key=/etc/kubernetes/pki/etcd/etcd-key.pem \
--endpoints=https://192.168.2.10:2379,https://192.168.2.11:2379,https://192.168.2.12:2379 \
endpoint health

+---------------------------+--------+--------------+-------+
|         ENDPOINT          | HEALTH |     TOOK     | ERROR |
+---------------------------+--------+--------------+-------+
| https://192.168.2.10:2379 |   true |  10.816754ms |       |
| https://192.168.2.12:2379 |   true | 117.220741ms |       |
| https://192.168.2.11:2379 |   true | 122.747481ms |       |
+---------------------------+--------+--------------+-------+
[root@k8s-master01 etcd]# 

```

# ​​六、kubernetes集群服务器二进制包（server-binaries）下载与分发 （master节点执行）​​

## 6.1 master节点载k8s安装包

github地址：[https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.25.md#server-binaries](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.25.md#server-binaries)

```
cd /data/k8s-work/
wget https://dl.k8s.io/v1.25.8/kubernetes-server-linux-amd64.tar.gz

```

## 6.2 k8s安装包解压

```
tar -xvf kubernetes-server-linux-amd64.tar.gz

```

## 6.3 k8s软件分发

```
cd kubernetes/server/bin/
cp kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
scp kube-apiserver kube-controller-manager kube-scheduler kubectl master2:/usr/local/bin/
scp kube-apiserver kube-controller-manager kube-scheduler kubectl master1:/usr/local/bin/


scp kubelet kube-proxy master1:/usr/local/bin
scp kubelet kube-proxy master2:/usr/local/bin
scp kubelet kube-proxy master:/usr/local/bin
scp kubelet kube-proxy node1:/usr/local/bin
scp kubelet kube-proxy node2:/usr/local/bin
```

## 6.4 在集群所有节点创建目录

```
mkdir -p /etc/kubernetes/    
mkdir -p /etc/kubernetes/ssl   
mkdir -p /var/log/kubernetes 

```

# 七、部署apiserver（master节点执行）

## 7.1创建apiserver证书

### 7.1.1创建apiserver证书请求文件

```
cd /data/k8s-work/
cat > kube-apiserver-csr.json << "EOF"
{
"CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "192.168.75.12",
    "192.168.75.13",
    "192.168.75.14",
    "192.168.75.11",
    "192.168.75.10",
    "192.168.75.15",
    "192.168.75.16",
    "192.168.75.17",
    "192.168.75.100",
    "10.96.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "kubemsb",
      "OU": "CN"
    }
  ]
}
EOF


#说明：
#1. 如果 hosts 字段不为空则需要指定授权使用该证书的 IP（含VIP） 或域名列表。由于该证书被集群使用，需要将节点的IP都填上，为了方便后期扩容可以多写几个预留的IP。
#2. 同时还需要填写 service 网络的首个IP(一般是 kube-apiserver 指定的 service-cluster-ip-range 网段的第一个IP，如 10.96.0.1)。
```

### 7.1.2生成apiserver的证书及token文件

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-apiserver-csr.json | cfssljson -bare kube-apiserver

```

### 7.1.3 配置TLS

```
cat > token.csv << EOF
$(head -c 16 /dev/urandom | od -An -t x | tr -d ' '),kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF


#说明：
#创建TLS机制所需TOKEN
#TLS Bootstraping：Master apiserver启用TLS认证后，Node节点kubelet和kube-proxy与kube-apiserver进行通信，必须使用CA签发的有效证书才可以，当Node节点很多时，这种客户端证书颁发需要大量工作，同样也会增加集群扩展复杂度。为了简化流程，Kubernetes引入了TLS bootstraping机制来自动颁发客户端证书，kubelet会以一个低权限用户自动向apiserver申请证书，kubelet的证书由apiserver动态签署。所以强烈建议在Node上使用这种方式，目前主要用于kubelet，kube-proxy还是由我们统一颁发一个证书。
```

```
[root@master k8s-work]# ls
ca-config.json  etcd.csr                 etcd-v3.5.7-linux-amd64.tar.gz  kubernetes
ca.csr          etcd-csr.json            kube-apiserver.csr              kubernetes-server-linux-amd64.tar.gz
ca-csr.json     etcd-key.pem             kube-apiserver-csr.json         token.csv
ca-key.pem      etcd.pem                 kube-apiserver-key.pem
ca.pem          etcd-v3.5.7-linux-amd64  kube-apiserver.pem

```

## 7.2 所有master节点创建apiserver服务配置文件

官网选项：[https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-apiserver/)

master节点：

```
cat > /etc/kubernetes/kube-apiserver.conf << "EOF"
KUBE_APISERVER_OPTS="--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --anonymous-auth=false \
  --bind-address=192.168.75.10 \
  --secure-port=6443 \
  --advertise-address=192.168.75.10 \
  --authorization-mode=Node,RBAC \
  --runtime-config=api/all=true \
  --enable-bootstrap-token-auth \
  --service-cluster-ip-range=10.96.0.0/12 \
  --token-auth-file=/etc/kubernetes/token.csv \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/etc/kubernetes/ssl/kube-apiserver.pem  \
  --tls-private-key-file=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/ssl/kube-apiserver.pem \
  --kubelet-client-key=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-account-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  \
  --service-account-issuer=api \
  --etcd-cafile=/etc/etcd/ssl/ca.pem \
  --etcd-certfile=/etc/etcd/ssl/etcd.pem \
  --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem \
  --etcd-servers=https://192.168.75.10:2379,https://192.168.75.13:2379,https://192.168.75.14:2379 \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/kube-apiserver-audit.log \
  --event-ttl=1h \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=4"
EOF

```

master1节点：

```
cat > /etc/kubernetes/kube-apiserver.conf << "EOF"
KUBE_APISERVER_OPTS="--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --anonymous-auth=false \
  --bind-address=192.168.75.13 \
  --secure-port=6443 \
  --advertise-address=192.168.75.13 \
  --authorization-mode=Node,RBAC \
  --runtime-config=api/all=true \
  --enable-bootstrap-token-auth \
  --service-cluster-ip-range=10.96.0.0/12 \
  --token-auth-file=/etc/kubernetes/token.csv \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/etc/kubernetes/ssl/kube-apiserver.pem  \
  --tls-private-key-file=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/ssl/kube-apiserver.pem \
  --kubelet-client-key=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-account-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  \
  --service-account-issuer=api \
  --etcd-cafile=/etc/etcd/ssl/ca.pem \
  --etcd-certfile=/etc/etcd/ssl/etcd.pem \
  --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem \
  --etcd-servers=https://192.168.75.10:2379,https://192.168.75.13:2379,https://192.168.75.14:2379 \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/kube-apiserver-audit.log \
  --event-ttl=1h \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=4"
EOF

```

master2节点：

```
cat > /etc/kubernetes/kube-apiserver.conf << "EOF"
KUBE_APISERVER_OPTS="--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --anonymous-auth=false \
  --bind-address=192.168.75.14 \
  --secure-port=6443 \
  --advertise-address=192.168.75.14 \
  --authorization-mode=Node,RBAC \
  --runtime-config=api/all=true \
  --enable-bootstrap-token-auth \
  --service-cluster-ip-range=10.96.0.0/12 \
  --token-auth-file=/etc/kubernetes/token.csv \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/etc/kubernetes/ssl/kube-apiserver.pem  \
  --tls-private-key-file=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/ssl/kube-apiserver.pem \
  --kubelet-client-key=/etc/kubernetes/ssl/kube-apiserver-key.pem \
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-account-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  \
  --service-account-issuer=api \
  --etcd-cafile=/etc/etcd/ssl/ca.pem \
  --etcd-certfile=/etc/etcd/ssl/etcd.pem \
  --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem \
  --etcd-servers=https://192.168.75.10:2379,https://192.168.75.13:2379,https://192.168.75.14:2379 \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/kube-apiserver-audit.log \
  --event-ttl=1h \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=4"
EOF

```

## 7.3 创建apiserver服务管理配置文件

```
cat > /etc/systemd/system/kube-apiserver.service << "EOF"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/kube-apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

## 7.4 分发配置文件及证书 master节点执行

```
cp ca*.pem /etc/kubernetes/ssl/
cp kube-apiserver*.pem /etc/kubernetes/ssl/
cp token.csv /etc/kubernetes/


scp /etc/kubernetes/token.csv master1:/etc/kubernetes
scp /etc/kubernetes/token.csv master2:/etc/kubernetes


scp /etc/kubernetes/ssl/kube-apiserver*.pem master1:/etc/kubernetes/ssl
scp /etc/kubernetes/ssl/kube-apiserver*.pem master2:/etc/kubernetes/ssl


scp /etc/kubernetes/ssl/ca*.pem master1:/etc/kubernetes/ssl
scp /etc/kubernetes/ssl/ca*.pem master2:/etc/kubernetes/ssl


scp /etc/systemd/system/kube-apiserver.service master1:/etc/systemd/system/kube-apiserver.service
scp /etc/systemd/system/kube-apiserver.service master2:/etc/systemd/system/kube-apiserver.service

```

## 7.5 启动apiserver服务(所有master节点执行)

```
systemctl daemon-reload
systemctl enable --now kube-apiserver

systemctl status kube-apiserver
```

## 7.6 所有master节点测试连通性

```
curl --insecure https://192.168.75.10:6443/
curl --insecure https://192.168.75.13:6443/
curl --insecure https://192.168.75.14:6443/
curl --insecure https://192.168.75.100:8443/


[root@master k8s-work]# curl --insecure https://192.168.75.10:6443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}[root@master k8s-work]# curl --insecure https://192.168.75.13:6443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}[root@master k8s-work]# curl --insecure https://192.168.75.14:6443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}[root@master k8s-work]# curl --insecure https://192.168.75.100:8443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}[root@master k8s-work]#

```

# 八、部署kubectl

## 8.1创建kubectl证书

### 8.1.1创建kubectl证书请求文件

```
cd /data/k8s-work/

cat > admin-csr.json << "EOF"
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:masters",         
      "OU": "system"
    }
  ]
}
EOF


#说明：
#后续 kube-apiserver 使用 RBAC 对客户端(如 kubelet、kube-proxy、Pod)请求进行授权；
#kube-apiserver 预定义了一些 RBAC 使用的 RoleBindings，如 cluster-admin 将 Group system:masters 与 Role cluster-admin 绑定，该 Role 授予了调用kube-apiserver 的所有 API的权限；
#O指定该证书的 Group 为 system:masters，kubelet 使用该证书访问 kube-apiserver 时 ，由于证书被 CA 签名，所以认证通过，同时由于证书用户组为经过预授权的 system:masters，所以被授予访问所有 API 的权限；
#注：
#这个admin 证书，是将来生成管理员用的kubeconfig 配置文件用的，现在我们一般建议使用RBAC 来对kubernetes 进行角色权限控制， kubernetes 将证书中的CN 字段 作为User， O 字段作为 Group；
#"O": "system:masters", 必须是system:masters，否则后面kubectl create clusterrolebinding报错。

```

### 8.1.2生成kubectl证书文件

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

```

```
[root@master k8s-work]# ls
admin.csr       etcd-key.pem
admin-csr.json  etcd.pem
admin-key.pem   etcd-v3.5.7-linux-amd64
admin.pem       etcd-v3.5.7-linux-amd64.tar.gz
ca-config.json  kube-apiserver.csr
ca.csr          kube-apiserver-csr.json
ca-csr.json     kube-apiserver-key.pem
ca-key.pem      kube-apiserver.pem
ca.pem          kubernetes
etcd.csr        kubernetes-server-linux-amd64.tar.gz
etcd-csr.json   token.csv

```

### 8.1.3复制文件到指定目录

```
cp admin*.pem /etc/kubernetes/ssl/
scp  admin*.pem   master1:/etc/kubernetes/ssl/
scp  admin*.pem   master2:/etc/kubernetes/ssl/
```

## 8.2 生成kubeconfig配置文件

kube.config 为 kubectl 的配置文件，包含访问 apiserver 的所有信息，如 apiserver 地址、CA 证书和自身使用的证书

```
kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.75.100:8443 --kubeconfig=kube.config
kubectl config set-credentials admin --client-certificate=admin.pem --client-key=admin-key.pem --embed-certs=true --kubeconfig=kube.config
kubectl config set-context kubernetes --cluster=kubernetes --user=admin --kubeconfig=kube.config
kubectl config use-context kubernetes --kubeconfig=kube.config

```

## 8.3 准备kubectl配置文件并进行绑定

```
mkdir ~/.kube
cp kube.config ~/.kube/config
kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes --kubeconfig=/root/.kube/config

```

## 8.4 分发kubectl到其他master节点

```
ssh master1 mkdir /root/.kube
ssh master2 mkdir /root/.kube

scp /root/.kube/config master1:/root/.kube/config
scp /root/.kube/config master2:/root/.kube/config

```

## 8.5配置kubectl命令补全 （可选）

```
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
kubectl completion bash > ~/.kube/completion.bash.inc
source '/root/.kube/completion.bash.inc'  
source $HOME/.bash_profile

```

## 8.6 测试

```
[root@master1 ~]# kubectl get all --all-namespaces       #查看集群所有资源
NAMESPACE   NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
default     service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4h
[root@master1 ~]# kubectl get componentstatuses       #查看集群组件状态
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                        ERROR
scheduler            Unhealthy   Get "https://127.0.0.1:10259/healthz": dial tcp 127.0.0.1:10259: connect: connection refused
controller-manager   Unhealthy   Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused
etcd-1               Healthy     {"health":"true","reason":""}
etcd-0               Healthy     {"health":"true","reason":""}
etcd-2               Healthy     {"health":"true","reason":""}
[root@master1 ~]# kubectl cluster-info    #查看集群信息
Kubernetes control plane is running at https://192.168.75.100:8443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
[root@master1 ~]#

```

# 九、部署kube-controller-manager

## 9.1 创建kube-controller-manager证书

### 9.1.1 创建kube-controller-manager证书请求文件

```
cd /data/k8s-work/

cat > kube-controller-manager-csr.json << "EOF"
{
    "CN": "system:kube-controller-manager",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "hosts": [
      "127.0.0.1",
      "192.168.75.10",
      "192.168.75.13",
      "192.168.75.14"
    ],
    "names": [
      {
        "C": "CN",
        "ST": "Beijing",
        "L": "Beijing",
        "O": "system:kube-controller-manager",
        "OU": "system"
      }
    ]
}
EOF



#说明：
#hosts 列表包含所有 kube-controller-manager 节点 IP；
#CN 为 system:kube-controller-manager;
#O 为 system:kube-controller-manager，kubernetes 内置的 ClusterRoleBindings system:kube-controller-manager 赋予 kube-controller-manager 工作所需的权限

```

### 9.1.2创建kube-controller-manager证书文件

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager


```

## 9.2 创建服务的启动文件kube-controller-manager.service

```
cat > kube-controller-manager.service << "EOF"
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/kube-controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

```

## 9.3 创建kube-controller-manager的配置文件kube-controller-manager.config

官网选项：[https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-controller-manager/](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-controller-manager/)

```
cat > kube-controller-manager.conf << "EOF"
KUBE_CONTROLLER_MANAGER_OPTS=" \
  --secure-port=10257 \
  --bind-address=127.0.0.1 \
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --service-cluster-ip-range=10.96.0.0/12 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --allocate-node-cidrs=true \
  --cluster-cidr=172.16.0.0/12 \
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --leader-elect=true \
  --feature-gates=RotateKubeletServerCertificate=true \
  --controllers=*,bootstrapsigner,tokencleaner \
  --horizontal-pod-autoscaler-sync-period=10s \
  --tls-cert-file=/etc/kubernetes/ssl/kube-controller-manager.pem \
  --tls-private-key-file=/etc/kubernetes/ssl/kube-controller-manager-key.pem \
  --use-service-account-credentials=true \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=2"
EOF

```

## 9.4 创建kube-controller-manager的kube-controller-manager.kubeconfig

```
kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.75.100:8443 --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager.pem --client-key=kube-controller-manager-key.pem --embed-certs=true --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-context system:kube-controller-manager --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig

```

## 9.5 同步文件到集群所有master节点

```

scp  kube-controller-manager*.pem master1:/etc/kubernetes/ssl/
scp  kube-controller-manager*.pem master2:/etc/kubernetes/ssl/
scp  kube-controller-manager*.pem master:/etc/kubernetes/ssl/
scp  kube-controller-manager.kubeconfig kube-controller-manager.conf master1:/etc/kubernetes/
scp  kube-controller-manager.kubeconfig kube-controller-manager.conf master2:/etc/kubernetes/
scp  kube-controller-manager.kubeconfig kube-controller-manager.conf master:/etc/kubernetes/
scp  kube-controller-manager.service master1:/usr/lib/systemd/system/
scp  kube-controller-manager.service master2:/usr/lib/systemd/system/
scp  kube-controller-manager.service master:/usr/lib/systemd/system/

```

## 9.6 启动服务(所有master节点执行)

```
systemctl daemon-reload 
systemctl restart kube-controller-manager
systemctl enable --now kube-controller-manager
systemctl status kube-controller-manager

```

## 9.7 检查

```
kubectl get componentstatuses

```

```
[root@master2 bin]# kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                        ERROR
scheduler            Unhealthy   Get "https://127.0.0.1:10259/healthz": dial tcp 127.0.0.1:10259: connect: connection refused
controller-manager   Healthy     ok      ###变为ok
etcd-2               Healthy     {"health":"true","reason":""}
etcd-1               Healthy     {"health":"true","reason":""}
etcd-0               Healthy     {"health":"true","reason":""}

```

# 十、部署kube-scheduler

## 10.1 创建kube-schedule证书

### 10.1.1 创建kube-schedule证书请求文件

```
cd /data/k8s-work/

cat > kube-scheduler-csr.json << "EOF"
{
    "CN": "system:kube-scheduler",

    "hosts": [
      "127.0.0.1",
      "192.168.75.10",
      "192.168.75.13",
      "192.168.75.14"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "Beijing",
        "L": "Beijing",
        "O": "system:kube-scheduler",
        "OU": "system"
      }
    ]
}
EOF

```

### 10.1.2 生成kube-schedule证书文件

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler


```

## 10.2 创建kube-schedule的kubeconfig

```
kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.75.100:8443 --kubeconfig=kube-scheduler.kubeconfig
kubectl config set-credentials system:kube-scheduler --client-certificate=kube-scheduler.pem --client-key=kube-scheduler-key.pem --embed-certs=true --kubeconfig=kube-scheduler.kubeconfig
kubectl config set-context system:kube-scheduler --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig
kubectl config use-context system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

```

## 10.3 创建服务配置文件kube-scheduler.conf

官网选项：[https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-scheduler/](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-scheduler/)

```
cat > kube-scheduler.conf << "EOF"
KUBE_SCHEDULER_OPTS=" \
--kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \
--leader-elect=true \
--alsologtostderr=true \
--logtostderr=false \
--log-dir=/var/log/kubernetes \
--v=2"
EOF

```

## 10.4 创建服务管理配置文件kube-scheduler.service

```
cat > kube-scheduler.service << "EOF"
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/kube-scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

```

## 10.5 分发证书及文件

```
scp  kube-scheduler*.pem master1:/etc/kubernetes/ssl/
scp  kube-scheduler*.pem master2:/etc/kubernetes/ssl/
scp  kube-scheduler*.pem master:/etc/kubernetes/ssl/
scp  kube-scheduler.kubeconfig kube-scheduler.conf master1:/etc/kubernetes/
scp  kube-scheduler.kubeconfig kube-scheduler.conf master2:/etc/kubernetes/
scp  kube-scheduler.kubeconfig kube-scheduler.conf master:/etc/kubernetes/
scp  kube-scheduler.service master1:/usr/lib/systemd/system/
scp  kube-scheduler.service master2:/usr/lib/systemd/system/
scp  kube-scheduler.service master:/usr/lib/systemd/system/

```

## 10.6 启动服务

```
systemctl daemon-reload
systemctl enable --now kube-scheduler
systemctl status kube-scheduler

```

---

# ！！！开始node节点

# 十一、安装Containerd

github项目推荐文档，安装containerd：[https://github.com/containerd/containerd/blob/main/docs/getting-started.md](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)

## 11.1 下载containerd安装包并解压

github地址：[https://github.com/containerd/containerd/releases](https://github.com/containerd/containerd/releases)

```
cd /data/k8s-work/

wget https://github.com/containerd/containerd/releases/download/v1.6.19/cri-containerd-cni-1.6.19-linux-amd64.tar.gz


tar -xvf cri-containerd-cni-1.6.19-linux-amd64.tar.gz  -C /

```

## 11.2 生成配置文件config.toml

```
cat > config.toml<<EOF
root = "/var/lib/containerd"
state = "/run/containerd"
oom_score = -999

[grpc]
  address = "/run/containerd/containerd.sock"
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

[debug]
  address = ""
  uid = 0
  gid = 0
  level = ""

[metrics]
  address = ""
  grpc_histogram = false

[cgroup]
  path = ""

[plugins]
  [plugins.cgroups]
    no_prometheus = false
  [plugins.cri]
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    enable_selinux = false
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.6"
    stats_collect_period = 10
    systemd_cgroup = true
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    [plugins.cri.containerd]
      snapshotter = "overlayfs"
      no_pivot = false
      [plugins.cri.containerd.default_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = ""
        runtime_root = ""
      [plugins.cri.containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
    [plugins.cri.cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      conf_template = "/etc/cni/net.d/10-default.conf"
    [plugins.cri.registry]
      [plugins.cri.registry.mirrors]
        [plugins.cri.registry.mirrors."docker.io"]
          endpoint = [
            "https://docker.mirrors.ustc.edu.cn",
            "http://hub-mirror.c.163.com"
          ]
        [plugins.cri.registry.mirrors."gcr.io"]
          endpoint = [
            "https://gcr.mirrors.ustc.edu.cn"
          ]
        [plugins.cri.registry.mirrors."k8s.gcr.io"]
          endpoint = [
            "https://gcr.mirrors.ustc.edu.cn/google-containers/"
          ]
        [plugins.cri.registry.mirrors."quay.io"]
          endpoint = [
            "https://quay.mirrors.ustc.edu.cn"
          ]
    [plugins.cri.x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""
  [plugins.diff-service]
    default = ["walking"]
  [plugins.linux]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
  [plugins.opt]
    path = "/opt/containerd"
  [plugins.restart]
    interval = "10s"
  [plugins.scheduler]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
EOF

```

## 11.3 安装runc

github地址：[https://github.com/opencontainers/runc/releases](https://github.com/opencontainers/runc/releases)

```
cd /data/k8s-work/
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64


chmod +x runc.amd64

```

## 11.4 分发配置文件

```
ssh master mkdir /etc/containerd
ssh master1 mkdir /etc/containerd
ssh master2 mkdir /etc/containerd
ssh node1 mkdir /etc/containerd
ssh node2 mkdir /etc/containerd


scp /data/k8s-work/config.toml master:/etc/containerd/config.toml
scp /data/k8s-work/config.toml master1:/etc/containerd/config.toml
scp /data/k8s-work/config.toml master2:/etc/containerd/config.toml
scp /data/k8s-work/config.toml node1:/etc/containerd/config.toml
scp /data/k8s-work/config.toml node2:/etc/containerd/config.toml



scp /data/k8s-work/cri-containerd-cni-1.6.19-linux-amd64.tar.gz master1:/root/
scp /data/k8s-work/cri-containerd-cni-1.6.19-linux-amd64.tar.gz master2:/root/
scp /data/k8s-work/cri-containerd-cni-1.6.19-linux-amd64.tar.gz node1:/root/
scp /data/k8s-work/cri-containerd-cni-1.6.19-linux-amd64.tar.gz node2:/root/


scp  runc.amd64 master:/usr/local/sbin/runc
scp  runc.amd64 master1:/usr/local/sbin/runc
scp  runc.amd64 master2:/usr/local/sbin/runc
scp  runc.amd64 node1:/usr/local/sbin/runc
scp  runc.amd64 node2:/usr/local/sbin/runc
```

## 11.5 集群其他每个节点解压软件包

```
tar -xvf /root/cri-containerd-cni-1.6.19-linux-amd64.tar.gz  -C /

```

## 11.6 集群所有节点启动containerd

```
systemctl enable containerd
systemctl restart containerd
systemctl status containerd

```

# 十二、部署kubelet (主要还是master执行)

## 12.1 创建kubelet-bootstrap.kubeconfig文件

```
cd /data/k8s-work/

BOOTSTRAP_TOKEN=$(awk -F "," '{print $1}' /etc/kubernetes/token.csv)
kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.75.100:8443 --kubeconfig=kubelet-bootstrap.kubeconfig
kubectl config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN} --kubeconfig=kubelet-bootstrap.kubeconfig
kubectl config set-context default --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=kubelet-bootstrap.kubeconfig
kubectl config use-context default --kubeconfig=kubelet-bootstrap.kubeconfig
```

创建clusterrolebingding角色资源

```
kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=kubelet-bootstrap
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap --kubeconfig=kubelet-bootstrap.kubeconfig
```

```
kubectl describe clusterrolebinding cluster-system-anonymous
kubectl describe clusterrolebinding kubelet-bootstrap

```

## 12.2 创建kubelet配置文件kubelet-conf.yaml

配置conf.yml结构参考官网：<br />[https://kubernetes.io/zh-cn/docs/reference/config-api/kubelet-config.v1beta1/](https://kubernetes.io/zh-cn/docs/reference/config-api/kubelet-config.v1beta1/)<br />[https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/)

```

cat > kubelet-conf.yaml << "EOF"

apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 192.168.75.10    #修改为本节点地址
port: 10250
readOnlyPort: 10255
serializeImagePulls: false
evictionHard:
    memory.available:  "200Mi"
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/ssl/ca.pem
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: systemd     # 如果docker的驱动为systemd，处修改为systemd。此处设置很重要   
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.2
clusterDomain: cluster.local

EOF

```

## 12.3 创建kubelet管理配置文件kubelet.service

```
cat > kubelet.service << "EOF"
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/etc/kubernetes/kubelet.conf
ExecStart=/usr/local/bin/kubelet $KUBELET_OPTS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


```

## 12.4 创建kubelet服务配置文件kubelet.conf

官网选项：[https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kubelet/](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kubelet/)

|运行时（--container-runtime-endpoint）|Unix 域套接字|
| ----------------------------------------| --------------------------------------------|
|containerd|unix:///var/run/containerd/containerd.sock|
|CRI-O|unix:///var/run/crio/crio.sock|
|Docker Engine（使用 cri-dockerd）|unix:///var/run/cri-dockerd.sock|

```
cat > kubelet.conf << EOF
KUBELET_OPTS="\
  --bootstrap-kubeconfig=/etc/kubernetes/kubelet-bootstrap.kubeconfig \
  --cert-dir=/etc/kubernetes/ssl \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --config=/etc/kubernetes/kubelet-conf.yaml \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock \ 
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock \
  --rotate-certificates \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=2"
EOF

```

## 12.5 分发配置文件

```
scp kubelet-bootstrap.kubeconfig  master:/etc/kubernetes/
scp kubelet-bootstrap.kubeconfig  master1:/etc/kubernetes/
scp kubelet-bootstrap.kubeconfig  master2:/etc/kubernetes/
scp kubelet-bootstrap.kubeconfig  node1:/etc/kubernetes/
scp kubelet-bootstrap.kubeconfig  node2:/etc/kubernetes/

scp kubelet-conf.yaml master:/etc/kubernetes/
scp kubelet-conf.yaml master1:/etc/kubernetes/
scp kubelet-conf.yaml master2:/etc/kubernetes/
scp kubelet-conf.yaml node1:/etc/kubernetes/
scp kubelet-conf.yaml node2:/etc/kubernetes/


scp kubelet.conf master:/etc/kubernetes/
scp kubelet.conf master1:/etc/kubernetes/
scp kubelet.conf master2:/etc/kubernetes/
scp kubelet.conf node1:/etc/kubernetes/
scp kubelet.conf node2:/etc/kubernetes/

scp ca.pem master:/etc/kubernetes/ssl/
scp ca.pem master1:/etc/kubernetes/ssl/
scp ca.pem master2:/etc/kubernetes/ssl/
scp ca.pem node1:/etc/kubernetes/ssl/
scp ca.pem node2:/etc/kubernetes/ssl/

scp kubelet.service master:/usr/lib/systemd/system/
scp kubelet.service master1:/usr/lib/systemd/system/
scp kubelet.service master2:/usr/lib/systemd/system/
scp kubelet.service node1:/usr/lib/systemd/system/
scp kubelet.service node2:/usr/lib/systemd/system/

scp /usr/local/bin/kube* node1:/usr/local/bin/
scp /usr/local/bin/kube* node2:/usr/local/bin/

```

## 12.6修正kubelet.json文件中的主机ip

```

ssh master1 sed -i s#192.168.75.10#192.168.75.13#g   /etc/kubernetes/kubelet-conf.yaml

ssh master2 sed -i s#192.168.75.10#192.168.75.14#g   /etc/kubernetes/kubelet-conf.yaml

ssh node1 sed -i s#192.168.75.10#192.168.75.11#g   /etc/kubernetes/kubelet-conf.yaml

ssh node2 sed -i s#192.168.75.10#192.168.75.12#g   /etc/kubernetes/kubelet-conf.yaml

```

## 12.7 创建目录启动服务（所有节点执行）

```
mkdir -p /var/lib/kubelet
mkdir -p /var/log/kubernetes

systemctl daemon-reload
systemctl enable --now kubelet
systemctl restart kubelet
systemctl status kubelet

```

## 12.8 检查

```
[root@master k8s-work]# kubectl get nodes
NAME      STATUS   ROLES    AGE   VERSION
master    Ready    <none>   30m   v1.25.8
master1   Ready    <none>   90s   v1.25.8
master2   Ready    <none>   20s   v1.25.8
node1     Ready    <none>   14s   v1.25.8
node2     Ready    <none>   8s    v1.25.8

```

# 十三、部署kube-proxy

## 13.1 创建kube-proxy证书请求文件

```
cd /data/k8s-work/

cat > kube-proxy-csr.json << "EOF"
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "kubemsb",
      "OU": "CN"
    }
  ]
}
EOF

```

## 13.2 生成证书

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy


# ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem

```

## 13.3 创建kubeconfig文件

```
kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.75.100:8443 --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy --client-certificate=kube-proxy.pem --client-key=kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

```

## 13.4 创建服务配置文件kube-proxy.yaml

```
cat > kube-proxy.yaml << "EOF"
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 192.168.75.10
clientConnection:
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
clusterCIDR: 172.16.0.0/12
healthzBindAddress: 192.168.75.10:10256
kind: KubeProxyConfiguration
metricsBindAddress: 192.168.75.10:10249
mode: "ipvs"
EOF

```

## 13.5 创建服务管理文件kube-proxy.service

官网选项：[https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-proxy/](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-proxy/)

```
cat >  kube-proxy.service << "EOF"
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/usr/local/bin/kube-proxy \
  --config=/etc/kubernetes/kube-proxy.yaml \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

## 13.6分发配置文件

```

scp kube-proxy*.pem  master:/etc/kubernetes/ssl/
scp kube-proxy*.pem  master1:/etc/kubernetes/ssl/
scp kube-proxy*.pem  master2:/etc/kubernetes/ssl/
scp kube-proxy*.pem  node1:/etc/kubernetes/ssl/
scp kube-proxy*.pem  node2:/etc/kubernetes/ssl/

scp kube-proxy.kubeconfig master:/etc/kubernetes/
scp kube-proxy.kubeconfig master1:/etc/kubernetes/
scp kube-proxy.kubeconfig master2:/etc/kubernetes/
scp kube-proxy.kubeconfig node1:/etc/kubernetes/
scp kube-proxy.kubeconfig node2:/etc/kubernetes/

scp kube-proxy.yaml master:/etc/kubernetes/
scp kube-proxy.yaml master1:/etc/kubernetes/
scp kube-proxy.yaml master2:/etc/kubernetes/
scp kube-proxy.yaml node1:/etc/kubernetes/
scp kube-proxy.yaml node2:/etc/kubernetes/

scp kube-proxy.service master:/usr/lib/systemd/system/
scp kube-proxy.service master1:/usr/lib/systemd/system/
scp kube-proxy.service master2:/usr/lib/systemd/system/
scp kube-proxy.service node1:/usr/lib/systemd/system/
scp kube-proxy.service node2:/usr/lib/systemd/system/

```

## 13.7 修改kube-proxy.yaml文件中的地址

```

ssh master1 sed -i s#192.168.75.10#192.168.75.13#g   /etc/kubernetes/kube-proxy.yaml

ssh master2 sed -i s#192.168.75.10#192.168.75.14#g   /etc/kubernetes/kube-proxy.yaml

ssh node1 sed -i s#192.168.75.10#192.168.75.11#g   /etc/kubernetes/kube-proxy.yaml

ssh node2 sed -i s#192.168.75.10#192.168.75.12#g   /etc/kubernetes/kube-proxy.yaml

```

## 13.8 创建工作目录

```
for i in master master1 master2 node1 node2 ;do ssh $i mkdir -p /var/lib/kube-proxy ;done

```

## 13.8启动服务

```
systemctl daemon-reload
systemctl enable --now kube-proxy
systemctl restart kube-proxy
systemctl status kube-proxy

```

# 十四、部署calico

## 14.1 获取安装calico的manifest（清单）

官网安装教程：[https://docs.tigera.io/calico/3.24/getting-started/kubernetes/self-managed-onprem/onpremises](https://docs.tigera.io/calico/3.24/getting-started/kubernetes/self-managed-onprem/onpremises)

```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico.yaml -O

```

## 14.2 修改pod CALICO_IPV4POOL_CIDR

```
#注意缩进

4551              - name: CALICO_IPV4POOL_CIDR
4552                value: "172.16.0.0/12"

```

## 14.3 apply文件安装

```
kubectl apply -f calico.yaml

```

## 14.4 检查

```
[root@master k8s-work]# kubectl get pods -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE     IP              NODE      NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-798cc86c47-9kdgn   1/1     Running   0          3h11m   10.88.2.89      node1     <none>           <none>
kube-system   calico-node-7nx46                          1/1     Running   0          124m    192.168.75.12   node2     <none>           <none>
kube-system   calico-node-fzk4f                          1/1     Running   0          124m    192.168.75.14   master2   <none>           <none>
kube-system   calico-node-ld94g                          1/1     Running   0          124m    192.168.75.13   master1   <none>           <none>
kube-system   calico-node-pkmrd                          1/1     Running   0          124m    192.168.75.11   node1     <none>           <none>
kube-system   calico-node-rvq8x                          1/1     Running   0          124m    192.168.75.10   master    <none>           <none>
```

# 十五、部署core DNS

## 15.1 创建部署文件coredns.yaml

```
cd /data/k8s-work/

cat >  coredns.yaml << "EOF"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
  - apiGroups:
    - ""
    resources:
    - endpoints
    - services
    - pods
    - namespaces
    verbs:
    - list
    - watch
  - apiGroups:
    - discovery.k8s.io
    resources:
    - endpointslices
    verbs:
    - list
    - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes cluster.local  in-addr.arpa ip6.arpa {
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "CoreDNS"
spec:
  # replicas: not specified here:
  # 1. Default is 1.
  # 2. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      nodeSelector:
        kubernetes.io/os: linux
      affinity:
         podAntiAffinity:
           preferredDuringSchedulingIgnoredDuringExecution:
           - weight: 100
             podAffinityTerm:
               labelSelector:
                 matchExpressions:
                   - key: k8s-app
                     operator: In
                     values: ["kube-dns"]
               topologyKey: kubernetes.io/hostname
      containers:
      - name: coredns
        image: coredns/coredns:1.8.4
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 8181
            scheme: HTTP
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.96.0.2
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
 
EOF

```

## 15.2 部署coredns

```
kubectl apply -f coredns.yaml

```

## 15.3 检查

```
[root@master k8s-work]# kubectl get pods -A -o wide  | grep dns
kube-system   coredns-564fd8c776-c8prw                   1/1     Running   0          53s     172.27.205.129   master    <none>           <none>
[root@master k8s-work]#

```

---

## 到这里k8s集群已经搭建完成

## 查看集群节点的信息

```
[root@master ~]# kubectl get nodes -o wide
NAME      STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
master    Ready    <none>   25h   v1.25.8   192.168.75.10   <none>        CentOS Linux 7 (Core)   4.19.12-1.el7.elrepo.x86_64   containerd://1.6.19
master1   Ready    <none>   25h   v1.25.8   192.168.75.13   <none>        CentOS Linux 7 (Core)   4.19.12-1.el7.elrepo.x86_64   containerd://1.6.19
master2   Ready    <none>   25h   v1.25.8   192.168.75.14   <none>        CentOS Linux 7 (Core)   4.19.12-1.el7.elrepo.x86_64   containerd://1.6.19
node1     Ready    <none>   25h   v1.25.8   192.168.75.11   <none>        CentOS Linux 7 (Core)   4.19.12-1.el7.elrepo.x86_64   containerd://1.6.19
node2     Ready    <none>   25h   v1.25.8   192.168.75.12   <none>        CentOS Linux 7 (Core)   4.19.12-1.el7.elrepo.x86_64   containerd://1.6.19

```

# 十六、部署应用验证

## 16.2创建部署文件

```
cat >  nginx.yaml  << "EOF"
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-web
spec:
  replicas: 2
  selector:
    name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.19.6
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-nodeport
spec:
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30001
      protocol: TCP
  type: NodePort
  selector:
    name: nginx
EOF

```

## 16.3 apply

```
kubectl apply -f nginx.yaml

```

## 16.4 验证

```

[root@master k8s-work]# kubectl get pods -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE     IP               NODE      NOMINATED NODE   READINESS GATES
default       nginx-web-lr25s                            1/1     Running   0          38s     172.27.205.130   master    <none>           <none>
default       nginx-web-xfktj                            1/1     Running   0          38s     172.17.40.65     master1   <none>           <none>
kube-system   calico-kube-controllers-798cc86c47-9kdgn   1/1     Running   0          3h34m   10.88.2.89       node1     <none>           <none>
kube-system   calico-node-7nx46                          1/1     Running   0          146m    192.168.75.12    node2     <none>           <none>
kube-system   calico-node-fzk4f                          1/1     Running   0          146m    192.168.75.14    master2   <none>           <none>
kube-system   calico-node-ld94g                          1/1     Running   0          146m    192.168.75.13    master1   <none>           <none>
kube-system   calico-node-pkmrd                          1/1     Running   0          146m    192.168.75.11    node1     <none>           <none>
kube-system   calico-node-rvq8x                          1/1     Running   0          146m    192.168.75.10    master    <none>           <none>
kube-system   coredns-564fd8c776-c8prw                   1/1     Running   0          6m7s    172.27.205.129   master    <none>           <none>
[root@master k8s-work]#
[root@master k8s-work]# kubectl get service  -A -o wide
NAMESPACE     NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE     SELECTOR
default       kubernetes               ClusterIP   10.96.0.1      <none>        443/TCP                  29h     <none>
default       nginx-service-nodeport   NodePort    10.97.169.35   <none>        80:30001/TCP             115s    name=nginx
kube-system   kube-dns                 ClusterIP   10.96.0.2      <none>        53/UDP,53/TCP,9153/TCP   7m24s   k8s-app=kube-dns
[root@master k8s-work]#

```

​![](assets/net-img-1675881-20230402144459014-1999635022-20230824180139-4w0zgr2.png)​

# 十七、安装Metrics Server

以下步骤只在master01操作

在新版的Kubernetes中系统资源的采集均使用Metrics-server，可以通过Metrics采集节点和Pod的内存、磁盘、CPU和网络的使用率

```bash
# 安装metrics server
cd metrics-server/

kubectl  apply -f metrics-server.yaml 

# 稍等片刻查看状态
kubectl  top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master01   154m         1%     1715Mi          21%     
k8s-master02   151m         1%     1274Mi          16%     
k8s-master03   523m         6%     1345Mi          17%     
k8s-node01     84m          1%     671Mi           8%      
k8s-node02     73m          0%     727Mi           9%      
k8s-node03     96m          1%     769Mi           9%      
k8s-node04     68m          0%     673Mi           8%      
k8s-node05     82m          1%     679Mi           8% 
```

# 十八、安装dashboard

## 18.1 安装dashboard

```bash
wget https://raw.githubusercontent.com/cby-chen/Kubernetes/main/yaml/dashboard.yaml
wget https://raw.githubusercontent.com/cby-chen/Kubernetes/main/yaml/dashboard-user.yaml

sed -i "s#kubernetesui/dashboard#registry.cn-hangzhou.aliyuncs.com/google_containers/dashboard#g" dashboard.yaml
sed -i "s#kubernetesui/metrics-scraper#registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-scraper#g" dashboard.yaml

cat dashboard.yaml | grep image
          image: registry.cn-hangzhou.aliyuncs.com/google_containers/dashboard:v2.6.1
          imagePullPolicy: Always
          image: registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-scraper:v1.0.8


kubectl  apply -f dashboard.yaml
kubectl  apply -f dashboard-user.yaml
```

## 18.2 更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
  type: NodePort
  
```

## 18.3 查看端口号

```shell
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.108.120.110   <none>        443:30034/TCP   34s
  
```

## 18.4 创建token

```shell
kubectl -n kubernetes-dashboard create token admin-user
eyJhbGciOiJSUzI1NiIsImtpZCI6IllnWjFheFpNeDgxZ2pxdTlTYzBEWFJvdVoyWFZBTFZWME44dTgwam1DY2MifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjcwMzE0Mzk5LCJpYXQiOjE2NzAzMTA3OTksImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiZjcyMTQ5NzctZDBlNi00NjExLWFlYzctNDgzMWE5MzVjN2M4In19LCJuYmYiOjE2NzAzMTA3OTksInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.JU28wtYdQ2TkAUHJx0tz5pBH5Z3bHPoSNWC_z8bKjmU5IztvckUPiv7_VaNwJC3da39rSOfvIoMN7cvq0MNi4qLKm5k8S2szODh9m2FPWeN81aQpneVB8CcwL0PZVL3hvUy7VqnM_Q3L7PhDfsrS3EK3bo1blHJRmSLuQcAIEICU8WNX7R2zxvOlNyXorxkwk68jDUvuAO1-AXfTOTpXWS1NDmm_zceKAIscTeT_nH1qlEXsPLfofKqDnA8XmtQIGr89VfIBBDhh1eox_hC7qNkLvPKY2oIuSBXG5mttcziqZBijtbU7rwirtgiIVVWSTdLOZmeXaDWpyZAnNzBAVg
  
```

## 18.5 登录dashboard

[https://192.168.8.61:30034/](https://192.168.8.61:30034/)

# 十九、安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

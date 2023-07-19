# 二进制-Kubernetes高可用集群

# 一、集群环境准备

## 1.1 主机规划

![](assets/image-20230317194307626-20230610173809-g14omgs.png)

|IP地址|主机名|配置|主机角色|软件 列表||
| -------------| ------------| ----| --------| ----------------------------------------------------------------------------------------------------------| -|
|192.168.0.200|k8s-master01|2C4G|master|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、Containerd、runc||
|192.168.0.201|k8s-master02|2C4G|master|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、Containerd、runc||
|192.168.0.202|k8s-master03|2C4G|master|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、Containerd、runc||
|192.168.0.203|k8s-node01|2C4G|node|kubelet、kube-proxy、Containerd、runc||
|192.168.0.210|ha1|1C2G|LB|haproxy、keepalived||
|192.168.0.211|ha2|1C2G|LB|haproxy、keepalived||
|192.168.0.220|/|/|VIP|||

## 1.2 软件版本

|软件名称|版本|
| ----------| -----------|
|CentOS7|kernel:5.17|
|kubernetes|v1.25.0|
|etcd|v3.5.4|
|containerd|v1.6.8|
|cfssl|v1.6.1|
|cni|v1.1.1|
|crictl|v1.24.2|
|runc|1.1.0|
|keepalived|v3.5|
|haproxy|v5.18|

## 1.3 网络分配

|网络名称|网段|
| -----------| --------------|
|Node网络|192.168.0.0/24|
|Service网络|10.96.0.0/16|
|Pod网络|172.16.0.0/12|

## 1.4 k8s组件下载

- kubernetes1.25.+的二进制包
  github二进制包下载地址：https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.25.md
  `wget https://dl.k8s.io/v1.25.0/kubernetes-server-linux-amd64.tar.gz`
- etcdctl二进制包
  github二进制包下载地址：https://github.com/etcd-io/etcd/releases
  `wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz`
- containerd二进制包
  github下载地址：https://github.com/containerd/containerd/releases
- containerd带cni插件的二进制包
  `wget https://github.com/containerd/containerd/releases/download/v1.6.8/cri-containerd-cni-1.6.8-linux-amd64.tar.gz`
- cfssl二进制包
  github二进制包下载地址：https://github.com/cloudflare/cfssl/releases
  `wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64`
  `wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64`
  `wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64`
- cni插件
  github下载地址：https://github.com/containernetworking/plugins/releases
  `wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz`
- crictl客户端二进制
  github下载：https://github.com/kubernetes-sigs/cri-tools/releases
  `wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.2/crictl-v1.24.2-linux-amd64.tar.gz`
- runc
  `wget https://github.com/opencontainers/runc/releases/download/v1.1.2/runc.amd64`

# 二、集群部署

## 2.1 主机准备

### 2.1.1 关闭防火墙和SElinux

```shell
systemctl disable --now firewalld
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

### 2.1.2 主机名和hosts

```bash
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02
hostnamectl set-hostname k8s-node03
hostnamectl set-hostname k8s-node04
hostnamectl set-hostname k8s-node05
hostnamectl set-hostname lb01
hostnamectl set-hostname lb02

### 所有节点配置hosts本地解析
cat >> /etc/hosts <<EOF
192.168.0.200 k8s-master01
192.168.0.201 k8s-master02
192.168.0.202 k8s-master03
192.168.0.203 k8s-worker01
192.168.0.210 lb01
192.168.0.211 lb02
192.168.0.220 lb-vip
EOF
```

### 2.1.3 配置免密登录

```bash
yum install -y sshpass

ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.0.200 192.168.0.201 192.168.0.202 192.168.0.210 192.168.0.211"
export SSHPASS=123456
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done

```

### 2.1.4 配置yum源

```bash
# 备份Linux本地现有的yum仓库文件
cd /etc/yum.repos.d
mkdir backup
mv ./* backup/

# 下载新的仓库文件
## 这是第一个仓库
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
## 下载第二个epel仓库
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# 其他(非阿里云ECS用户会出现出现 curl#6 - "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error")
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo


# 配置elrepo-kernel 源
# 为 RHEL-8或 CentOS-8配置elrepo-kernel 源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-7 SL-7 或 CentOS-7配置elrepo-kernel 源
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache 
# 查看可用安装包
yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available

```

### 2.1.5 安装依赖升级内核

```shell
# 安装依赖
yum -y install wget jq psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl chrony -y

# 升级内核【master和node节点】
# 安装最新的内核
# 我这里选择的是稳定版kernel-ml   如需更新长期维护版本kernel-lt  
yum  --enablerepo=elrepo-kernel  install  kernel-ml

# 查看已安装那些内核
[root@k8s-master01 ~]# rpm -qa | grep kernel
kernel-3.10.0-1160.el7.x86_64
kernel-headers-3.10.0-1160.83.1.el7.x86_64
kernel-ml-6.2.6-1.el7.elrepo.x86_64
kernel-tools-3.10.0-1160.el7.x86_64
kernel-tools-libs-3.10.0-1160.el7.x86_64

# 查看默认内核
[root@k8s-master01 ~]# grubby --default-kernel
/boot/vmlinuz-3.10.0-1160.el7.x86_64

# 若不是最新的使用命令设置
grubby --set-default /boot/vmlinuz-6.2.6-1.el7.elrepo.x86_64
reboot
```

### 2.1.6 网络配置（俩种方式二选一）

```shell
# 方式一
# systemctl disable --now NetworkManager
# systemctl start network && systemctl enable network

# 方式二
cat > /etc/NetworkManager/conf.d/calico.conf << EOF 
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF
systemctl restart NetworkManager
```

### 2.1.7 关闭交换分区

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab
# /dev/mapper/centos-swap swap                    swap    defaults        0 0
```

### 2.1.8 配置ulimit

```shell
ulimit -SHn 65535
cat >> /etc/security/limits.conf <<EOF
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* seft memlock unlimited
* hard memlock unlimitedd
EOF
```

### 2.1.9 修改内核参数

```shell
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
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

net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
EOF

sysctl --system
```

### 2.1.10 安装ipvsadm

```shell
yum install ipvsadm ipset sysstat conntrack libseccomp -y
cat >> /etc/modules-load.d/ipvs.conf <<EOF 
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
ip_vs_sh               16384  0
ip_vs_wrr              16384  0
ip_vs_rr               16384  0
ip_vs                 180224  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          176128  1 ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  3 nf_conntrack,xfs,ip_vs
```

### 2.1.12 时间同步

```shell
# 服务端
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 0.0.0.0/0
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

# 客户端

yum install chrony -y
cat > /etc/chrony.conf << EOF 
server 192.168.0.200 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

#使用客户端进行验证
chronyc sources -v
```

## 2.2 生成相关证书

特别说明除外，以下操作在所有master节点操作

### 2.2.1 安装cfssl

```shell
# master01节点下载证书生成工具
# wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64" -O /usr/local/bin/cfssl
# wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64" -O /usr/local/bin/cfssljson

# 软件包内有
cp cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson

chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
```

### 2.2.2 创建etcd集群证书

```bash
# 创建ca-config配置文件
mkdir -p /etc/etcd/ssl
cd /etc/etcd/ssl
cat > ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "etcd": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

# 创建etcd-ca根证书请求文件
cat > etcd-ca-csr.json  << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

# 生成etcd的ca根证书
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca

# 创建etcd证书请求文件
cat > etcd-csr.json << EOF 
{
  "CN": "etcd",
  "hosts": [
    "192.168.0.200",
    "192.168.0.201",
    "192.168.0.202"
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
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ]
}
EOF

# 生成etcd证书
cfssl gencert  -ca=etcd-ca.pem \
-ca-key=etcd-ca-key.pem \
-config=ca-config.json \
-profile=etcd  \
etcd-csr.json | cfssljson -bare etcd

### 创建ServiceAccount Key ——secret

openssl genrsa -out /etc/kubernetes/ssl/sa.key 2048
openssl rsa -in /etc/kubernetes/ssl/sa.key -pubout -out /etc/kubernetes/ssl/sa.pub
```

将etcd证书copy到其他etcd节点

```bash
ETCD='k8s-master02 k8s-master03'
for NODE in $ETCD; do ssh $NODE "mkdir -p /etc/etcd/ssl"; scp -r /etc/etcd/ssl/* $NODE:/etc/etcd/ssl/ ;done; 
```

### 2.2.3 创建k8s证书

```bash
# 创建ca-config配置文件
mkdir -p /etc/kubernetes/ssl
cd /etc/kubernetes/ssl
cat > ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

# 生成k8s-ca根证书请求文件
cat > ca-csr.json   << EOF 
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

# 生成k8s-ca根证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# 生成apiserver证书请求文件
# hosts字段填写上所有的主机ip
cat > apiserver-csr.json << EOF 
{
  "CN": "kube-apiserver",
  "hosts": [
    "127.0.0.1",
    "192.168.0.200",
    "192.168.0.201",
    "192.168.0.202",
    "192.168.0.203",
    "192.168.0.210",
    "192.168.0.211",
    "192.168.0.220"
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
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

# 生成k8s-apiserver证书
cfssl gencert   \
-ca=ca.pem   \
-ca-key=ca-key.pem   \
-config=ca-config.json   \
-profile=kubernetes \
apiserver-csr.json | cfssljson -bare apiserver

############################################
# 创建controller-manage证书
cat > manager-csr.json << EOF 
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=ca.pem \
   -ca-key=ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   manager-csr.json | cfssljson -bare controller-manager

###################################################
# 创建kube-proxy证书
cat > kube-proxy-csr.json  << EOF 
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
      "O": "system:kube-proxy",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=ca.pem \
   -ca-key=ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   kube-proxy-csr.json | cfssljson -bare kube-proxy

######################################################
cat > admin-csr.json << EOF 
{
  "CN": "admin",
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
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=ca.pem \
   -ca-key=ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   admin-csr.json | cfssljson -bare admin


##################################################
cat > scheduler-csr.json << EOF 
{
  "CN": "system:kube-scheduler",
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
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=ca.pem \
   -ca-key=ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   scheduler-csr.json | cfssljson -bare scheduler


#######################################################
# 创建apiserver聚合证书
cat > front-proxy-ca-csr.json  << EOF 
{
  "CN": "kubernetes",
  "key": {
     "algo": "rsa",
     "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cfssl gencert -initca front-proxy-ca-csr.json | cfssljson -bare front-proxy-ca 

cat > front-proxy-client-csr.json  << EOF 
{
  "CN": "front-proxy-client",
  "key": {
     "algo": "rsa",
     "size": 2048
  }
}
EOF

cfssl gencert  \
-ca=front-proxy-ca.pem   \
-ca-key=front-proxy-ca-key.pem   \
-config=ca-config.json   \
-profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare  front-proxy-client

```

将k8s证书发送到其他k8s节点

```bash
for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02; do ssh $NODE "mkdir -p /etc/kubernetes/ssl"; for NODE in k8s-master02  k8s-node01 k8s-node02; do scp -r /etc/kubernetes/ssl/* $NODE:/etc/kubernetes/ssl ; done ; done
```

## 2.3 etcd集群部署

建议将etcd 集群搭建在所有master节点

```shell
# 安装etcd
# wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz

# 解压etcd安装文件
tar -xf etcd*.tar.gz && mv etcd-*/etcd /usr/local/bin/ && mv etcd-*/etcdctl /usr/local/bin/

# 将etcd组件发送至其他k8s节点
Master='k8s-master02 k8s-master03'
for NODE in $Master; do echo $NODE; scp /usr/local/bin/etcd* $NODE:/usr/local/bin/; done

# 所有etcd节点创建配置文件，同时修改配置文件中的ip地址
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://192.168.0.200:2380'
listen-client-urls: 'https://192.168.0.200:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://192.168.0.200:2380'
advertise-client-urls: 'https://192.168.0.200:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://192.168.0.200:2380,k8s-master02=https://192.168.0.201:2380,k8s-master03=https://192.168.0.202:2380'
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
  cert-file: '/etc/etcd/ssl/etcd.pem'
  key-file: '/etc/etcd/ssl/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/etcd/ssl/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/etcd/ssl/etcd.pem'
  key-file: '/etc/etcd/ssl/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/etcd/ssl/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF


# 创建etcd.service并启动（所有etcd节点操作）
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


## 创建etcd证书目录
systemctl daemon-reload
systemctl enable --now etcd  # 依次启动主节点从节点


# 查看etcd状态
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
export ETCDCTL_API=3
etcdctl --endpoints="192.168.0.202:2379,192.168.0.201:2379,192.168.0.200:2379" --cacert=/etc/etcd/ssl/etcd-ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  endpoint status --write-out=table

```

## 2.4 高可用配置

在lb01和lb02两台服务器上操作

### 2.4.1 安装keepalived和haproxy服务

```shell
systemctl disable --now firewalld

setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config

yum -y install keepalived haproxy
```

### 2.4.2 修改haproxy配置文件（两台配置文件一样）

```shell
# cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

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


frontend monitor-in
 bind *:33305
 mode http
 option httplog
 monitor-uri /monitor

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
 server  k8s-master01  192.168.0.200:6443 check
 server  k8s-master02  192.168.0.201:6443 check
 server  k8s-master03  192.168.0.202:6443 check
EOF
```

### 2.4.3 lb01配置keepalived master节点

```shell
#cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
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
    # 注意网卡名
    interface ens18 
    mcast_src_ip 192.168.0.210
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.0.220
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 2.4.4 lb02配置keepalived backup节点

```shell
# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
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
    # 注意网卡名
    interface ens33
    mcast_src_ip 192.168.0.211
    virtual_router_id 51
    priority 50
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.0.220
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 2.4.5 健康检查脚本配置（两台lb主机）

```shell
cat >  /etc/keepalived/check_apiserver.sh << EOF
#!/bin/bash

err=0
for k in \$(seq 1 3)
do
    check_code=\$(pgrep haproxy)
    if [[ \$check_code == "" ]]; then
        err=\$(expr \$err + 1)
        sleep 1
        continue
    else
        err=0
        break
    fi
done

if [[ \$err != "0" ]]; then
    echo "systemctl stop keepalived"
    /usr/bin/systemctl stop keepalived
    exit 1
else
    exit 0
fi
EOF

# 给脚本授权

chmod +x /etc/keepalived/check_apiserver.sh
```

### 2.4.6 启动服务

```shell
systemctl daemon-reload
systemctl enable --now haproxy
systemctl enable --now keepalived
```

### 2.4.7 测试高可用

```shell
# 能ping同

[root@k8s-node02 ~]# ping 192.168.0.220

# 能telnet访问

[root@k8s-node02 ~]# telnet 192.168.0.220 8443

# 关闭主节点，看vip是否漂移到备节点
```

## 2.5 k8s基本组件安装配置

所有k8s节点创建以下目录

```shell
mkdir -p /etc/kubernetes/manifests/ /etc/systemd/system/kubelet.service.d /var/lib/kubelet /var/log/kubernetes
```

### 2.5.1 安装Containerd作为Runtime （推荐）

所有k8s节点操作

```shell
# wget https://github.com/containerd/containerd/releases/download/v1.6.8/cri-containerd-cni-1.6.8-linux-amd64.tar.gz

#解压
tar -xzf cri-containerd-cni-1.6.8-linux-amd64.tar.gz -C /

#创建服务启动文件
cat > /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

#  配置Containerd所需的模块
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# 加载模块
systemctl restart systemd-modules-load.service

# 配置Containerd所需的内核
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核
sysctl --system

# 创建Containerd的配置文件
# 创建默认配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 修改Containerd的配置文件
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep SystemdCgroup

sed -i "s#k8s.gcr.io#registry.aliyuncs.com/google_containers#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox_image

## 配置加速器
#添加 config_path = "/etc/containerd/certs.d"
sed -i 's/config_path\ =.*/config_path = \"\/etc\/containerd\/certs.d\"/g' /etc/containerd/config.toml
mkdir /etc/containerd/certs.d/docker.io -p

cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://tu2ax1rl.mirror.aliyuncs.com"]
  capabilities = ["pull", "resolve"]
EOF

# 启动并设置为开机启动
systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd

```

配置crictl

`crictl` 是 CRI 兼容的容器运行时命令行接口。 你可以使用它来检查和调试 Kubernetes节点上的容器运行时和应用程序。

```bash
# wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.25.0/crictl-v1.25.0-linux-amd64.tar.gz

#解压
tar -zxf crictl-v1.25.0-linux-amd64.tar.gz -C /usr/bin/
#生成配置文件
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

systemctl restart  containerd
crictl info
```

注意经测试 cri-containerd-cni-1.6.8-linux-amd64.tar.gz 包中包含的 runc 在 CentOS 7 下的动态链接有问题，

```bash
#这里从 runc 的 github 上单独下载 runc，并替换上面安装的 containerd 中的 runc:
wget https://github.com/opencontainers/runc/releases/download/v1.1.2/runc.amd64
mv runc.amd64 runc ; chmod u+x runc ; scp runc /usr/local/sbin/
runc -v

# Containerd 提示runc: symbol lookup error: runc: undefined symbol: seccomp_notify_respond
# 解决：下载libseccomp-2.5.2-1.el8.x86_64.rpm （yum 下载的版本较低，无法适配runc）
https://developer.aliyun.com/packageSearch?word=libseccomp
#卸载原来的
rpm -qa | grep libseccomp
rpm -e libseccomp-2.3.1-4.el7.x86_64 --nodeps
rpm -ivh libseccomp-2.5.2-1.el8.x86_64.rpm 

```

Containerd取代docker之后，无法通过http拉取harbor镜像的解决方法

```bash
#/etc/containerd/config.toml 默认最末的配置是关于mirror的，和StackOverflow的写法略有区别，但大致可以猜测层级结构，于是在后面追加了：

    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]
		[plugins.cri.registry.configs."hub.xxx.com".tls]
		    insecure_skip_verify = true
      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
	    [plugins.cri.registry.mirrors."hub.xxx.com"]
		    endpoint = ["http://hub.xxx.com"]

```

### 2.5.2 安装docker作为Runtime （不推荐）

```bash
# 更新源信息
yum update
# 安装必要软件
yum install -y yum-utils   device-mapper-persistent-data   lvm2

# 写入docker源信息
yum-config-manager \
--add-repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo

# 更新源信息并进行安装
yum install docker-ce docker-ce-cli containerd.io -y

# 配置加速器
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://ted9wxpi.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl status docker

### 安装cri-docker

# 由于1.24以及更高版本不支持docker所以安装cri-docker
# 下载cri-docker 
wget  https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.5/cri-dockerd-0.2.5.amd64.tgz

# 解压cri-docker
tar xvf cri-dockerd-0.2.5.amd64.tgz 
cp cri-dockerd/cri-dockerd  /usr/bin/

# 写入启动配置文件
cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

# 写入socket配置文件
cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service
[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
[Install]
WantedBy=sockets.target
EOF

# 进行启动cri-docker
systemctl daemon-reload ; systemctl enable cri-docker --now
```

### 2.5.3 安装kubernetes-server

k8s-master01节点操作，然后将执行文件拷贝到其他所有节点

```shell
# 下载安装包
# wget https://dl.k8s.io/v1.24.2/kubernetes-server-linux-amd64.tar.gz

# 解压k8s安装文件
tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

# 查看/usr/local/bin下内容

ls /usr/local/bin/
containerd  containerd-shim-runc-v1  containerd-stress  critest  ctr   etcdctl  kube-controller-manager  kubelet  kube-scheduler  containerd-shim  containerd-shim-runc-v2  crictl  ctd-decoder  etcd  kube-apiserver  kubectl  kube-proxy

# 查看版本
kubelet --version

### 将组件发送至其他k8s节点
Master='k8s-master02 k8s-master03'
Work='k8s-node01 k8s-node02 k8s-node03 k8s-node04 k8s-node05'

for NODE in $Master; do echo $NODE; scp /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} $NODE:/usr/local/bin/;  done

for NODE in $Work; do scp /usr/local/bin/kube{let,-proxy} $NODE:/usr/local/bin/ ; done
```

### 2.5.4 配置集群kubeconfig文件

配置集群

```bash

# 设置一个集群项

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/ssl/ca.pem \
     --embed-certs=true \
     --server=https://192.168.0.220:8443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置一个环境项，一个上下文

kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置一个用户项

kubectl config set-credentials system:kube-controller-manager \
     --client-certificate=/etc/kubernetes/ssl/controller-manager.pem \
     --client-key=/etc/kubernetes/ssl/controller-manager-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置默认环境

kubectl config use-context system:kube-controller-manager@kubernetes \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig


kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/ssl/ca.pem \
     --embed-certs=true \
     --server=https://192.168.0.220:8443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/ssl/scheduler.pem \
     --client-key=/etc/kubernetes/ssl/scheduler-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@kubernetes \
     --cluster=kubernetes \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config use-context system:kube-scheduler@kubernetes \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig


kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem     \
  --embed-certs=true     \
  --server=https://192.168.0.220:8443     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-credentials kubernetes-admin  \
  --client-certificate=/etc/kubernetes/ssl/admin.pem     \
  --client-key=/etc/kubernetes/ssl/admin-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-context kubernetes-admin@kubernetes    \
  --cluster=kubernetes     \
  --user=kubernetes-admin     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config use-context kubernetes-admin@kubernetes  --kubeconfig=/etc/kubernetes/admin.kubeconfig


kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem     \
  --embed-certs=true     \
  --server=https://192.168.0.220:8443     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy  \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem     \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-context kube-proxy@kubernetes    \
  --cluster=kubernetes     \
  --user=kube-proxy     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

### 将配置文件发送至其他k8s节点
for NODE in k8s-master02 k8s-node01 k8s-node02 ; do scp /etc/kubernetes/*.kubeconfig $NODE:/etc/kubernetes/;  done

```

### 2.5.5 配置apiserver

所有master节点

```bash
# 所有master节点 创建启动文件，修改ip地址
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF

[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
      --v=2  \\
      --logtostderr=true  \\
      --allow-privileged=true  \\
      --bind-address=0.0.0.0  \\
      --secure-port=6443  \\
      --advertise-address=192.168.0.200 \\
      --service-cluster-ip-range=10.96.0.0/12 \\
      --service-node-port-range=30000-32767  \\
      --etcd-servers=https://192.168.0.200:2379,https://192.168.0.201:2379 \\
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \\
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \\
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \\
      --client-ca-file=/etc/kubernetes/ssl/ca.pem  \\
      --tls-cert-file=/etc/kubernetes/ssl/apiserver.pem  \\
      --tls-private-key-file=/etc/kubernetes/ssl/apiserver-key.pem  \\
      --kubelet-client-certificate=/etc/kubernetes/ssl/apiserver.pem  \\
      --kubelet-client-key=/etc/kubernetes/ssl/apiserver-key.pem  \\
      --service-account-key-file=/etc/kubernetes/ssl/sa.pub  \\
      --service-account-signing-key-file=/etc/kubernetes/ssl/sa.key  \\
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \\
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \\
      --enable-bootstrap-token-auth=true  \\
      --requestheader-client-ca-file=/etc/kubernetes/ssl/front-proxy-ca.pem  \\
      --proxy-client-cert-file=/etc/kubernetes/ssl/front-proxy-client.pem  \\
      --proxy-client-key-file=/etc/kubernetes/ssl/front-proxy-client-key.pem  \\
      --requestheader-allowed-names=aggregator  \\
      --requestheader-group-headers=X-Remote-Group  \\
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \\
      --requestheader-username-headers=X-Remote-User \\
      --enable-aggregator-routing=true
      # --feature-gates=IPv6DualStack=true
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF

# 启动apiserver（所有master节点）
systemctl daemon-reload && systemctl enable --now kube-apiserver

# 注意查看状态是否启动正常
# systemctl status kube-apiserver
```

### 2.5.6 配置kube-controller-manager

所有master节点

```shell
# 所有master节点配置，且配置相同
# 172.16.0.0/12为pod网段，按需求设置你自己的网段

cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF

[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
      --v=2 \\
      --logtostderr=true \\
      --bind-address=127.0.0.1 \\
      --root-ca-file=/etc/kubernetes/ssl/ca.pem \\
      --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \\
      --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \\
      --service-account-private-key-file=/etc/kubernetes/ssl/sa.key \\
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
      --leader-elect=true \\
      --use-service-account-credentials=true \\
      --node-monitor-grace-period=40s \\
      --node-monitor-period=5s \\
      --pod-eviction-timeout=2m0s \\
      --controllers=*,bootstrapsigner,tokencleaner \\
      --allocate-node-cidrs=true \\
      --service-cluster-ip-range=10.96.0.0/12,fd00::/108 \\
      --cluster-cidr=172.16.0.0/12,fc00::/48 \\
      --node-cidr-mask-size-ipv4=24 \\
      --node-cidr-mask-size-ipv6=64 \\
      --requestheader-client-ca-file=/etc/kubernetes/ssl/front-proxy-ca.pem 
      # --feature-gates=IPv6DualStack=true

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF

## 启动kube-controller-manager，并查看状态

systemctl daemon-reload
systemctl enable --now kube-controller-manager
# systemctl  status kube-controller-manager
```

### 2.5.7 配置kube-scheduler

所有master节点

```bash
# 所有master节点配置，且配置相同
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
      --v=2 \\
      --logtostderr=true \\
      --bind-address=127.0.0.1 \\
      --leader-elect=true \\
      --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
Restart=always
RestartSec=10s
[Install]
WantedBy=multi-user.target
EOF

# 启动并查看服务状态
systemctl daemon-reload
systemctl enable --now kube-scheduler
# systemctl status kube-scheduler
```

### 2.5.8 配置TLS Bootstrapping

在master01上配置

```bash

cd /etc/kubernetes

cat > bootstrap.secret.yaml << EOF 
apiVersion: v1
kind: Secret
metadata:
  name: bootstrap-token-c8ad9c
  namespace: kube-system
type: bootstrap.kubernetes.io/token
stringData:
  description: "The default bootstrap token generated by 'kubelet '."
  token-id: c8ad9c
  token-secret: 2e4d610cf3e7426e
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"
  auth-extra-groups:  system:bootstrappers:default-node-token,system:bootstrappers:worker,system:bootstrappers:ingress
 
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubelet-bootstrap
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-bootstrapper
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers:default-node-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-autoapprove-bootstrap
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:nodeclient
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers:default-node-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-autoapprove-certificate-rotation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:nodes
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kube-apiserver
EOF

kubectl config set-cluster kubernetes     \
--certificate-authority=/etc/kubernetes/ssl/ca.pem     \
--embed-certs=true     --server=https://192.168.0.220:8443     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-credentials tls-bootstrap-token-user     \
--token=c8ad9c.2e4d610cf3e7426e \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-context tls-bootstrap-token-user@kubernetes     \
--cluster=kubernetes     \
--user=tls-bootstrap-token-user     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config use-context tls-bootstrap-token-user@kubernetes     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

# token的位置在bootstrap.secret.yaml，如果修改的话到这个文件修改
mkdir -p /root/.kube ; cp /etc/kubernetes/admin.kubeconfig /root/.kube/config

# # 将bootstrap-kubelet.kubeconfig发送到其他k8s节点
for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02; do scp /etc/kubernetes/bootstrap-kubelet.kubeconfig $NODE:/etc/kubernetes/bootstrap-kubelet.kubeconfig ; done
```

查看集群状态，没问题的话继续后续操作

```bash
kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok                              
controller-manager   Healthy   ok                              
etcd-0               Healthy   {"health":"true","reason":""}   
etcd-2               Healthy   {"health":"true","reason":""}   
etcd-1               Healthy   {"health":"true","reason":""} 

# 切记执行，别忘记！！！
kubectl create -f bootstrap.secret.yaml
```

### 2.5.9 配置kubelet

所有k8s节点

```bash
# 所有k8s节点配置kubelet service
cat > /usr/lib/systemd/system/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service
[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock  \\
    --node-labels=node.kubernetes.io/node=
    # --feature-gates=IPv6DualStack=true
    # --container-runtime=remote
    # --runtime-request-timeout=15m
    # --cgroup-driver=systemd
[Install]
WantedBy=multi-user.target
EOF

# ### 所有k8s节点创建kubelet的配置文件
cat > /etc/kubernetes/kubelet-conf.yml <<EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
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
cgroupDriver: systemd
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kubeAPIBurst: 10
kubeAPIQPS: 5
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
EOF

#### 启动kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl enable --now kubelet
systemctl status kubelet

### 查看集群
[root@k8s-master01 ~]# kubectl  get node
NAME           STATUS     ROLES    AGE   VERSION
k8s-master01   Ready    <none>   18s   v1.24.3
k8s-master02   Ready    <none>   16s   v1.24.3
k8s-master03   Ready    <none>   16s   v1.24.3
k8s-node01     Ready    <none>   14s   v1.24.3
k8s-node02     Ready    <none>   14s   v1.24.3
k8s-node03     Ready    <none>   14s   v1.24.3
k8s-node04     Ready    <none>   14s   v1.24.3
k8s-node05     Ready    <none>   14s   v1.24.3
[root@k8s-master01 ~]#
```

### 2.5.10 配置kube-proxy

所有k8s节点

```bash
cat >  /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy.yaml \\
  --v=2
Restart=always
RestartSec=10s
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/kubernetes/kube-proxy.yaml << EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 172.16.0.0/12,fc00::/48 
configSyncPeriod: 15m0s
conntrack:
  max: null
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  masqueradeAll: true
  minSyncPeriod: 5s
  scheduler: "rr"
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: "ipvs"
nodePortAddresses: null
oomScoreAdj: -999
portRange: ""
udpIdleTimeout: 250ms
EOF

#### 启动kube-proxy
systemctl daemon-reload
systemctl restart kube-proxy
systemctl enable --now kube-proxy
systemctl status kube-proxy
```

## 2.6 安装Calico

以下步骤只在master01操作

```shell
wget https://docs.projectcalico.org/v3.25/manifests/calico.yaml --no-check-certificate
### 更改calico网段
# vim calico.yaml
vim calico-ipv6.yaml
# calico-config ConfigMap处
    "ipam": {
        "type": "calico-ipam",
        "assign_ipv4": "true",
        "assign_ipv6": "true"
    },
    - name: IP
      value: "autodetect"

    - name: IP6
      value: "autodetect"

    - name: CALICO_IPV4POOL_CIDR
      value: "172.16.0.0/12"

    - name: CALICO_IPV6POOL_CIDR
      value: "fc00::/48"

    - name: FELIX_IPV6SUPPORT
      value: "true"

# 本地没有IPv6 使用 calico.yaml
# kubectl apply -f calico.yaml

# 本地有IPv6 使用 calico-ipv6.yaml 
kubectl apply -f calico-ipv6.yaml 
# kubectl delete -f calico-ipv6.yaml 

### 查看容器状态
# calico 初始化会很慢 需要耐心等待一下，大约十分钟左右
kubectl  get pod -A
--------------------------------------------------
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-56cdb7c587-bq6rn   1/1     Running   0          10m
kube-system   calico-node-2vt27                          1/1     Running   0          10m
kube-system   calico-node-7bg82                          1/1     Running   0          10m
kube-system   calico-node-gg9tv                          1/1     Running   0          10m
kube-system   calico-node-lkdhr                          1/1     Running   0          10m
kube-system   calico-node-msl6j                          1/1     Running   0          10m
kube-system   calico-node-qqrx9                          1/1     Running   0          10m
kube-system   calico-node-tgzxk                          1/1     Running   0          10m
kube-system   calico-node-z59jx                          1/1     Running   0          10m
kube-system   calico-typha-6775694657-xzmcs              1/1     Running   0          10m


```

## 2.7 安装CoreDNS

以下步骤只在master01操作

```shell
## 修改文件
mkdir -p  /opt/coredns/ ; cd  /opt/coredns/
cat > coredns.yaml << EOF 
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
        kubernetes cluster.local in-addr.arpa ip6.arpa {
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
        image: registry.cn-beijing.aliyuncs.com/dotbalo/coredns:1.8.6 
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
  clusterIP: 10.96.0.10 
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


cat coredns.yaml | grep clusterIP:
  clusterIP: 10.96.0.10 

# 安装
kubectl  create -f coredns.yaml 
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
```

## 2.8 安装Metrics Server

以下步骤只在master01操作

在新版的Kubernetes中系统资源的采集均使用Metrics-server，可以通过Metrics采集节点和Pod的内存、磁盘、CPU和网络的使用率

```shell

# 安装metrics server
mkdir -p /opt/metrics-server/ ; cd /opt/metrics-server/

cat > metrics-server.yaml << EOF 
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem # change to front-proxy-ca.crt for kubeadm
        - --requestheader-username-headers=X-Remote-User
        - --requestheader-group-headers=X-Remote-Group
        - --requestheader-extra-headers-prefix=X-Remote-Extra-
        image: registry.cn-beijing.aliyuncs.com/dotbalo/metrics-server:0.5.0
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
        - name: ca-ssl
          mountPath: /etc/kubernetes/pki
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
      - name: ca-ssl
        hostPath:
          path: /etc/kubernetes/pki
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF

kubectl  apply -f metrics-server.yaml 

# 稍等片刻查看状态
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

## 2.9 集群验证

### 2.9.1 部署pod资源

```shell
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox:1.28
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF

# 查看
kubectl  get pod
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          17s
```

### 2.9.2 用pod解析默认命名空间中的kubernetes

```shell
kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

kubectl exec  busybox -n default -- nslookup kubernetes
3Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

### 2.9.3 测试跨命名空间是否可以解析

```shell
kubectl exec  busybox -n default -- nslookup kube-dns.kube-system
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kube-dns.kube-system
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
```

### 2.9.4 每个节点都必须要能访问Kubernetes的kubernetes svc 443和kube-dns的service 53

```shell
telnet 10.96.0.1 443
Trying 10.96.0.1...
Connected to 10.96.0.1.
Escape character is '^]'.

 telnet 10.96.0.10 53
Trying 10.96.0.10...
Connected to 10.96.0.10.
Escape character is '^]'.

curl 10.96.0.10:53
curl: (52) Empty reply from server
```

### 2.9.5 Pod和Pod之前要能通

```shell
kubectl get po -owide
NAME      READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
busybox   1/1     Running   0          17m   172.27.14.193   k8s-node02   <none>           <none>

 kubectl get po -n kube-system -owide
NAME                                       READY   STATUS    RESTARTS      AGE   IP               NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-5dffd5886b-4blh6   1/1     Running   0             77m   172.25.244.193   k8s-master01   <none>           <none>
calico-node-fvbdq                          1/1     Running   1 (75m ago)   77m   192.168.0.200     k8s-master01   <none>           <none>
calico-node-g8nqd                          1/1     Running   0             77m   192.168.1.64     k8s-node01     <none>           <none>
calico-node-mdps8                          1/1     Running   0             77m   192.168.1.65     k8s-node02     <none>           <none>
calico-node-nf4nt                          1/1     Running   0             77m   192.168.0.202     k8s-master03   <none>           <none>
calico-node-sq2ml                          1/1     Running   0             77m   192.168.0.201     k8s-master02   <none>           <none>
calico-typha-8445487f56-mg6p8              1/1     Running   0             77m   192.168.1.65     k8s-node02     <none>           <none>
calico-typha-8445487f56-pxbpj              1/1     Running   0             77m   192.168.0.200     k8s-master01   <none>           <none>
calico-typha-8445487f56-tnssl              1/1     Running   0             77m   192.168.1.64     k8s-node01     <none>           <none>
coredns-5db5696c7-67h79                    1/1     Running   0             63m   172.25.92.65     k8s-master02   <none>           <none>
metrics-server-6bf7dcd649-5fhrw            1/1     Running   0             61m   172.18.195.1     k8s-master03   <none>           <none>

# 进入busybox ping其他节点上的pod

kubectl exec -ti busybox -- sh
/ # ping 192.168.1.64
PING 192.168.1.64 (192.168.1.64): 56 data bytes
64 bytes from 192.168.1.64: seq=0 ttl=63 time=0.358 ms
64 bytes from 192.168.1.64: seq=1 ttl=63 time=0.668 ms
64 bytes from 192.168.1.64: seq=2 ttl=63 time=0.637 ms
64 bytes from 192.168.1.64: seq=3 ttl=63 time=0.624 ms
64 bytes from 192.168.1.64: seq=4 ttl=63 time=0.907 ms

# 可以连通证明这个pod是可以跨命名空间和跨主机通信的
```

### 2.9.6 创建三个副本，可以看到3个副本分布在不同的节点上（用完可以删了）

```shell
cat > deployments.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80

EOF

kubectl  apply -f deployments.yaml 
deployment.apps/nginx-deployment created

kubectl  get pod 
NAME                               READY   STATUS    RESTARTS   AGE
busybox                            1/1     Running   0          6m25s
nginx-deployment-9456bbbf9-4bmvk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-9rcdk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-dqv8s   1/1     Running   0          8s

# 删除nginx

[root@k8s-master01 ~]# kubectl delete -f deployments.yaml 
```

## 2.10 安装dashboard

```shell
wget https://raw.githubusercontent.com/cby-chen/Kubernetes/main/yaml/dashboard.yaml
wget https://raw.githubusercontent.com/cby-chen/Kubernetes/main/yaml/dashboard-user.yaml

kubectl  apply -f dashboard.yaml
kubectl  apply -f dashboard-user.yaml
```

### 2.10.1 更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
  type: NodePort
```

### 2.10.2 查看端口号

```shell
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.108.120.110   <none>        443:30034/TCP   34s
```

### 2.10.3 创建token

```shell
kubectl -n kubernetes-dashboard create token admin-user
eyJhbGciOiJSUzI1NiIsImtpZCI6Inlkd0RKV2lQeUpvNmRxb2hENDlRM3llWU55T2I4dC0wVW5KOU5PZGRSdWsifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjU1NzA2MTQwLCJpYXQiOjE2NTU3MDI1NDAsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiZGVhYjdiY2MtNDczZS00N2E0LThlYTUtZmE4Yjc2NGY2NGJjIn19LCJuYmYiOjE2NTU3MDI1NDAsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.YzVrnSq3IuWn3qqY_td7SPqHisT40Gk1neMx7Ok9PsTxd6RASWxv9Y_1-T4wpE3ljaCiXxMBETzvYDgf-y9FOxm6drkQWWLk9UUuvOdjexxkdTXztB5X_0BiUGcMlvD3CA0qFbnzcg1cLpokypkuOnlSB8GBTleNyhQvHQnoXU3fSUCNRR_zHu2bRNgJZwABPMdj2D42EQndD56ZDP4g4IK8iMVJbaM-6DdNjdpfQx2358n8syPDjznu_1W1fUvwxY3eoEyeuIEjDbEeYEwh5uW2k4NOjW8m54W2YgmipDuqpvIB_-cnAo_KzF2q1Qb4WpIAItGkkpgwQFMFagKRTg
```

### 2.10.4 登录dashboard

https://192.168.0.200:30034/

## 2.11 ingress安装

### 2.11.1 执行部署

```shell
cd ingress/

kubectl  apply -f deploy.yaml 
kubectl  apply -f backend.yaml 

# 等创建完成后在执行：
kubectl  apply -f ingress-demo-app.yaml 

kubectl  get ingress
NAME               CLASS   HOSTS                            ADDRESS     PORTS   AGE
ingress-host-bar   nginx   hello.chenby.cn,demo.chenby.cn   192.168.0.201   80      7s

```

### 2.11.2 过滤查看ingress端口

```shell
[root@hello ~/yaml]# kubectl  get svc -A | grep ingress
ingress-nginx          ingress-nginx-controller             NodePort    10.104.231.36    <none>        80:32636/TCP,443:30579/TCP   104s
ingress-nginx          ingress-nginx-controller-admission   ClusterIP   10.101.85.88     <none>        443/TCP                      105s
[root@hello ~/yaml]#
```

## 2.12 IPv6测试

```shell
#部署应用
[root@k8s-master01 ~]# vim cby.yaml 
[root@k8s-master01 ~]# cat cby.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      containers:
      - name: chenby
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: chenby
spec:
  ipFamilyPolicy: PreferDualStack
  ipFamilies:
  - IPv6
  - IPv4
  type: NodePort
  selector:
    app: chenby
  ports:
  - port: 80
    targetPort: 80
[root@k8s-master01 ~]# kubectl  apply -f cby.yaml

#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
chenby         NodePort    fd00::a29c       <none>        80:30779/TCP   5s
[root@k8s-master01 ~]# 

#使用内网访问
[root@localhost yaml]# curl -I http://[fd00::a29c]
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:35 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@localhost yaml]# curl -I http://192.168.0.200:30779
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:59 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@localhost yaml]# 

#使用公网访问
[root@localhost yaml]# curl -I http://[2408:8207:78cc:5cc1:181c::10]:30779
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:54 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes
```

## 2.13 安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

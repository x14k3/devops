
系统环境基于：Rocky Linux 9.4 版本 x86_64
部署环境为三台 Master 两台 Node

## 1. 初始化配置
### 设置主机名

```bash
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02
```

### 配置hosts本地解析

```bash
echo '192.168.3.131 k8s-master01
192.168.3.132 k8s-master02
192.168.3.133 k8s-master03
192.168.3.134 k8s-node01
192.168.3.135 k8s-node02
192.168.3.136 lb-vip
' >> /etc/hosts
```

### 关闭防火墙 & SELINUX

```bash
# Ubuntu忽略，CentOS执行
systemctl disable --now firewalld

### 关闭SELinux
# Ubuntu忽略，CentOS执行
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

### 配置免密登录

```bash
# apt install -y sshpass
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.3.131 192.168.3.132 192.168.3.133 192.168.3.134 192.168.3.135"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done
```


### 关闭交换分区

```bash
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0
```


### 添加启用源

```bash
# Ubuntu忽略，CentOS执行
# 为 RHEL-9或 CentOS-9配置源
yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-8或 CentOS-8配置源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-7 SL-7 或 CentOS-7 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 
```


### 安装ipvsadm

```bash
# 对于 Ubuntu
# apt install ipvsadm ipset sysstat conntrack -y

# 对于 CentOS
yum install ipvsadm ipset sysstat conntrack libseccomp -y

echo 'ip_vs
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
' >> /etc/modules-load.d/ipvs.conf

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
ip_vs_sh               16384  0
ip_vs_wrr              16384  0
ip_vs_rr               16384  0
ip_vs                 237568  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          217088  3 nf_nat,nft_ct,ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  5 nf_conntrack,nf_nat,nf_tables,xfs,ip_vs

# 参数解释
#
# ip_vs
# IPVS 是 Linux 内核中的一个模块，用于实现负载均衡和高可用性。它通过在前端代理服务器上分发传入请求到后端实际服务器上，提供了高性能和可扩展的网络服务。
# ip_vs_rr
# IPVS 的一种调度算法之一，使用轮询方式分发请求到后端服务器，每个请求按顺序依次分发。
# ip_vs_wrr
# IPVS 的一种调度算法之一，使用加权轮询方式分发请求到后端服务器，每个请求按照指定的权重比例分发。
# ip_vs_sh
# IPVS 的一种调度算法之一，使用哈希方式根据源 IP 地址和目标 IP 地址来分发请求。
# nf_conntrack
# 这是一个内核模块，用于跟踪和管理网络连接，包括 TCP、UDP 和 ICMP 等协议。它是实现防火墙状态跟踪的基础。
# ip_tables
# 这是一个内核模块，提供了对 Linux 系统 IP 数据包过滤和网络地址转换（NAT）功能的支持。
# ip_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的 IP 地址集合操作。
# xt_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的数据包匹配和操作。
# ipt_set
# 这是一个用户空间工具，用于配置和管理 xt_set 内核模块。
# ipt_rpfilter
# 这是一个内核模块，用于实现反向路径过滤，用于防止 IP 欺骗和 DDoS 攻击。
# ipt_REJECT
# 这是一个 iptables 目标，用于拒绝 IP 数据包，并向发送方发送响应，指示数据包被拒绝。
# ipip
# 这是一个内核模块，用于实现 IP 封装在 IP（IP-over-IP）的隧道功能。它可以在不同网络之间创建虚拟隧道来传输 IP 数据包。

```


### 进行时间同步

```bash
# 服务端
# apt install chrony -y
yum install chrony -y

echo 'pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.3.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
' >> /etc/chrony.conf 

systemctl restart chronyd ; systemctl enable chronyd

# 客户端
# apt install chrony -y
yum install chrony -y

echo 'pool 192.168.3.131 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
' >> /etc/chrony.conf

systemctl restart chronyd ; systemctl enable chronyd

#使用客户端进行验证
chronyc sources -v

```


资源下载

```bash
# cfssl
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64

# etcd
wget https://github.com/etcd-io/etcd/releases/download/v3.6.7/etcd-v3.6.7-linux-amd64.tar.gz

# cri-docker
wget  https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz

# helm
wget https://get.helm.sh/helm-v4.0.4-linux-amd64.tar.gz

# calico.yaml 文件
https://github.com/projectcalico/calico/archive/refs/tags/v3.28.0.zip

```


### 修改内核参数 & 配置ulimit

```bash
### 配置ulimit
ulimit -SHn 65535
echo '* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* seft memlock unlimited
* hard memlock unlimitedd
' >> /etc/security/limits.conf

### 
echo 'net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
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
' >> /etc/sysctl.d/k8s.conf

sysctl --system
echo modprobe br_netfilter >> /etc/rc.d/rc.local  
chmod +x /etc/rc.d/rc.local
### 重启
reboot

# 这些是Linux系统的一些参数设置，用于配置和优化网络、文件系统和虚拟内存等方面的功能。以下是每个参数的详细解释：
# 
# 1. net.ipv4.ip_forward = 1
#    - 这个参数启用了IPv4的IP转发功能，允许服务器作为网络路由器转发数据包。
# 2. net.bridge.bridge-nf-call-iptables = 1
#    - 当使用网络桥接技术时，将数据包传递到iptables进行处理。
# 3. fs.may_detach_mounts = 1
#    - 允许在挂载文件系统时，允许被其他进程使用。
# 4. vm.overcommit_memory=1
#    - 该设置允许原始的内存过量分配策略，当系统的内存已经被完全使用时，系统仍然会分配额外的内存。
# 5. vm.panic_on_oom=0
#    - 当系统内存不足（OOM）时，禁用系统崩溃和重启。
# 6. fs.inotify.max_user_watches=89100
#    - 设置系统允许一个用户的inotify实例可以监控的文件数目的上限。
# 7. fs.file-max=52706963
#    - 设置系统同时打开的文件数的上限。
# 8. fs.nr_open=52706963
#    - 设置系统同时打开的文件描述符数的上限。
# 9. net.netfilter.nf_conntrack_max=2310720
#    - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 10. net.ipv4.tcp_keepalive_time = 600
#     - 设置TCP套接字的空闲超时时间（秒），超过该时间没有活动数据时，内核会发送心跳包。
# 11. net.ipv4.tcp_keepalive_probes = 3
#     - 设置未收到响应的TCP心跳探测次数。
# 12. net.ipv4.tcp_keepalive_intvl = 15
#     - 设置TCP心跳探测的时间间隔（秒）。
# 13. net.ipv4.tcp_max_tw_buckets = 36000
#     - 设置系统可以使用的TIME_WAIT套接字的最大数量。
# 14. net.ipv4.tcp_tw_reuse = 1
#     - 启用TIME_WAIT套接字的重新利用，允许新的套接字使用旧的TIME_WAIT套接字。
# 15. net.ipv4.tcp_max_orphans = 327680
#     - 设置系统可以同时存在的TCP套接字垃圾回收包裹数的最大数量。
# 16. net.ipv4.tcp_orphan_retries = 3
#     - 设置系统对于孤立的TCP套接字的重试次数。
# 17. net.ipv4.tcp_syncookies = 1
#     - 启用TCP SYN cookies保护，用于防止SYN洪泛攻击。
# 18. net.ipv4.tcp_max_syn_backlog = 16384
#     - 设置新的TCP连接的半连接数（半连接队列）的最大长度。
# 19. net.ipv4.ip_conntrack_max = 65536
#     - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 20. net.ipv4.tcp_timestamps = 0
#     - 关闭TCP时间戳功能，用于提供更好的安全性。
# 21. net.core.somaxconn = 16384
#     - 设置系统核心层的连接队列的最大值。
# 22. net.ipv6.conf.all.disable_ipv6 = 0
#     - 启用IPv6协议。
# 23. net.ipv6.conf.default.disable_ipv6 = 0
#     - 启用IPv6协议。
# 24. net.ipv6.conf.lo.disable_ipv6 = 0
#     - 启用IPv6协议。
# 25. net.ipv6.conf.all.forwarding = 1
#     - 允许IPv6数据包转发。
```


## 2. 安装 etcd 集群

[[../中间件/etcd/etcd 集群部署|etcd 集群部署]]

## 3. 安装docker

[[../docker/docker install|docker install]]


## 4. 安装 docker 的 cri


```bash
# 由于1.24以及更高版本不支持docker所以安装cri-docker
# 下载cri-docker 
# https://github.com/Mirantis/cri-dockerd/releases/
wget  https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz
tar xf cri-dockerd-0.3.16.amd64.tgz
cp cri-dockerd/cri-dockerd /usr/local/bin/

echo '[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd://
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
' >> /etc/systemd/system/cri-docker.service


echo '[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
' >> /etc/systemd/system/cri-docker.socket

systemctl daemon-reload
systemctl enable --now cri-docker.socket
systemctl enable --now cri-docker.service
```


## 5. 安装 kubeadm, kubelet 和 kubectl

### 添加镜像源地址

官方文档给出的配置如下

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

```

由于国内环境替换镜像源地址为中科大的地址

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

```
### 安装

所有节点都需要安装

```bash
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

`--disableexcludes=kubernetes`：表示临时禁用相关排除规则，保证安装顺利，如果机器上没有设置排除规则，不追加此参数也行。

### 启动 kubelet

必须在运行`kubeadm`之前运行 `kubelet`服务

```bash
systemctl enable --now kubelet
systemctl status kubelet
```


## 6. 初始化<任意主节点>

准备好 `etcd`集群和相关证书，开始初始化

获取默认的配置文件进行修改

token生成命令:`echo "$(head -c 6 /dev/urandom | md5sum | head -c 6)"."$(head -c 16 /dev/urandom | md5sum | head -c 16)"`

```bash
mkdir -p /etc/kubernetes/pki && cd /etc/kubernetes/

echo 'apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  # advertiseAddress: 1.2.3.4
  advertiseAddress: 192.168.3.131  # master 节点的 ip
  bindPort: 6443
nodeRegistration:
  # criSocket: unix:///var/run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock    # 替换为 docker 的 cri
  imagePullPolicy: IfNotPresent
  # name: node
  name: master1   # master 节点的主机名,必须 hosts 文件解析
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
# 使用外部 etcd 集群
etcd:
  external:
    endpoints:
    - https://192.168.3.131:2379
    - https://192.168.3.132:2379
    - https://192.168.3/133:2379
    caFile: /etc/etcd/ssl/etcd-ca.pem
    certFile: /etc/etcd/ssl/etcd.pem
    keyFile: /etc/etcd/ssl/etcd-key.pem
# etcd:
#   local:
#     dataDir: /var/lib/etcd
# imageRepository: registry.k8s.io
imageRepository: registry.aliyuncs.com/google_containers # 切换镜像仓库下载源为国内阿里的
kind: ClusterConfiguration
kubernetesVersion: 1.30.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16    # 追加字段设置，设置 pod 子网网段 后续 calico 中的配置需要和这个一样
scheduler: {}
' >> init-defaults.yaml 
```

查看需要下载的镜像列表

```bash
kubeadm config images list --config init-defaults.yaml

registry.aliyuncs.com/google_containers/kube-apiserver:v1.30.0
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.30.0
registry.aliyuncs.com/google_containers/kube-scheduler:v1.30.0
registry.aliyuncs.com/google_containers/kube-proxy:v1.30.0
registry.aliyuncs.com/google_containers/coredns:v1.11.3
registry.aliyuncs.com/google_containers/pause:3.9
```

开始拉取镜像

```bash
kubeadm config images pull --config init-defaults.yaml

# 本笔记安装需要额外重命名镜像
docker pull registry.aliyuncs.com/google_containers/pause:3.9 && docker tag registry.aliyuncs.com/google_containers/pause:3.9 registry.k8s.io/pause:3.9
```

开始初始化

```bash
kubeadm init --config init-defaults.yaml

### 如果初始化失败，需要进行重置
kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock && \
iptables -F && \
iptables -X && \
ipvsadm -C && \
rm -rf /etc/cni/net.d && \
rm -rf $HOME/.kube/config 

# 还需要清空 etcd 数据
etcdctl del "" --prefix

# 初始化成功，会打印如下
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

# 然后根据提示，执行以下命令
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.3.131:6443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:0398d543f807bc16eb7f7fd499cc306ea53f66536eba0b009236e242c3c13b1b

```

根据提示，在其他节点执行加入集群操作

注意其他节点必须运行 kubelet 才可以

## 7. 加入集群<其他节点>

执行主节点初始化成功提示的加入命令，追加使用的 `cri`

```bash
kubeadm join 192.168.3.131:6443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:0398d543f807bc16eb7f7fd499cc306ea53f66536eba0b009236e242c3c13b1b --cri-socket=unix:///var/run/cri-dockerd.sock

This node has joined the cluster:  
* Certificate signing request was sent to apiserver and a response was received.  
* The Kubelet was informed of the new secure connection details.  
  
Run 'kubectl get nodes' on the control-plane to see this node join the cluster.  

```


## 8. 验证集群状态

执行提示的命令，查看集群节点状态，初始状态都是 `NotReady` 为正常。因为集群的网络插件还没有配置，节点之间的通信还存在问题。

```bash
kubectl get nodes
NAME           STATUS     ROLES           AGE   VERSION
k8s-master02   NotReady   <none>          25m   v1.30.14
k8s-master03   NotReady   <none>          25m   v1.30.14
k8s-node01     NotReady   <none>          6s    v1.30.14
k8s-node02     NotReady   <none>          4s    v1.30.14
master1        NotReady   control-plane   30m   v1.30.14
```


## 9. 安装 Helm

根据官网文档在 Github 下载二进制文件，加入系统环境变量即可。

官网：[https://helm.sh/](https://helm.sh/)

```bash
wget https://get.helm.sh/helm-v4.0.4-linux-amd64.tar.gz
tar xf helm-v4.0.4-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
```

## 10. 安装 calico

直接打开官方仓库地址：[https://github.com/projectcalico/calico](https://github.com/projectcalico/calico)

切换 Tag 分支到对应的版本，在仓库文件中寻找 `manifests/calico.yaml` 文件，点击 `raw`，复制链接在服务器上下载
```bash
https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
```

下载下来之后修改配置，找到配置项`CALICO_IPV4POOL_CIDR` 也就是集群的 `podSubnet` 地址设置。
```bash
- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"
- name: IP_AUTODETECTION_METHOD
  value: "interface=ens192"
```

> 关于 podSubnet 设置有以下几种方式
> 
> - podSubnet 可以在使用 kubeadm init 初始化集群的时候使用 –pod-network-cidr=192.168.0.0/16 指定
> - 修改 kubeadm config 导出的集群初始化配置文件中：networking.podSubnet 的值，不存在该字段就手动添加上。
> - 如果错过了初始化，可以直接修改集群中的 kubeadm-config，使用命令：kubectl edit configmap kubeadm-config -n kube-system -o yaml，找到 networking 添加字段 podSubnet 如果存在就修改该值。
> 
> 如果使用 kubeadm-config 修改配置，改完之后需要重启集群。（重启所有机器）

查找配置文件中所有的镜像，在所有节点下载拉取
```bash
cat  calico.yaml | grep image:
          image: quay.io/calico/cni:master
          image: quay.io/calico/cni:master
          image: quay.io/calico/node:master
          image: quay.io/calico/node:master
          image: quay.io/calico/kube-controllers:master

# 命令
docker pull quay.io/calico/cni:master
docker pull quay.io/calico/node:master
docker pull quay.io/calico/kube-controllers:master

# 导出命令
docker save -o calico_kube-controllers_v3.28.0.tar quay.io/calico/kube-controllers:master
docker save -o calico_cni_v3.28.0.tar  quay.io/calico/cni:master
docker save -o calico_node_v3.28.0.tar quay.io/calico/node:master

# 导入命令
docker load -i calico_cni_v3.28.0.tar 
docker load -i calico_kube-controllers_v3.28.0.tar 
docker load -i calico_node_v3.28.0.tar

```

应用创建

```bash
kubectl create -f calico.yaml 
```

## 11. 检查集群状态

获取 `pod` 状态

```bash
kubectl get pods --all-namespaces
```

获取节点状态

```bash
kubectl get node  
```

## 设置集群角色

- NoSchedule: 一定不能被调度，已存在的 pod 不会被驱逐
- PreferNoSchedule: 尽量不要调度
- NoExecute: 一定不能被调度, 还会驱逐 node 上已有的 pod

```bash
kubectl taint node master1 node-role.kubernetes.io/master=true:NoSchedule && \
kubectl taint node k8s-master2 node-role.kubernetes.io/master=true:PreferNoSchedule && \
kubectl taint node k8s-master3 node-role.kubernetes.io/master=true:PreferNoSchedule && \
kubectl label node k8s-node1 node-role.kubernetes.io/node= && \
kubectl label node k8s-node2 node-role.kubernetes.io/node=

# 取消不可调度污点
kubectl taint nodes k8s-node1 node-role.kubernetes.io/node=true:NoExecute-
# 查看节点污点
kubectl describe node k8s-node1 | grep Taints
```
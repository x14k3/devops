# k8s部署-kubeadm

# 一、基础环境准备

　　**集群规划信息：**

|主机名称|IP地址|说明|
| -----------| -----------------| -------------------|
|master01|192.168.10.51|master节点|
|master02|192.168.10.52|master节点|
|master03|192.168.10.53|master节点|
|node01|192.168.10.54|node节点|
|node02|192.168.10.55|node节点|
|master-lb|127.0.0.1:16443|nginx组件监听地址|

　　**说明：**

* master节点为3台实现高可用，并且通过nginx进行代理master流量实现高可用，master也安装node组件。
* node节点为2台
* nginx在所有节点安装，监听127.0.0.1:16443端口
* 系统使用centos7.X

## 1.1 基础环境配置

### 1.所有节点配置hosts

```
cat >>/etc/hosts<<EOF
192.168.10.11 master01
192.168.10.12 master02
192.168.10.13 master03
192.168.10.14 node01
192.168.10.15 node02
EOF
```

### 2.所有节点关闭防火墙、selinux、dnsmasq、swap

```
#关闭防火墙
systemctl disable --now firewalld
#关闭dnsmasq
systemctl disable --now dnsmasq
#关闭postfix
systemctl  disable --now postfix
#关闭NetworkManager
systemctl disable --now NetworkManager
#关闭selinux
sed -ri 's/(^SELINUX=).*/\1disabled/' /etc/selinux/config
setenforce 0
#关闭swap
 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭 关闭
```

### 3.配置时间同步

　　方法1：使用ntp

　　方法2：使用chrony(推荐使用)

### 4.所有节点修改资源限制

```
cat > /etc/security/limits.conf <<EOF
*       soft        core        unlimited
*       hard        core        unlimited
*       soft        nproc       1000000
*       hard        nproc       1000000
*       soft        nofile      1000000
*       hard        nofile      1000000
*       soft        memlock     32000
*       hard        memlock     32000
*       soft        msgqueue    8192000
EOF
```

### 3.ssh认证

```
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.10.11 192.168.10.12 192.168.10.13 192.168.10.14 192.168.10.15"
export SSHPASS=123456
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done
```

### 5.升级系统以及内核

```
#升级系统
yum update -y --exclude=kernel*
#升级内核到4.18以上
rpm -ivh kernel-ml-6.1.0-1.el7.elrepo.x86_64.rpm
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
#修改内核参数
cat >/etc/sysctl.conf<<EOF
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=10
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0 # 默认为1，系统会严格校验数据包的反向路径，可能导致丢包
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2
net.ipv4.ip_local_port_range= 45001 65000
net.ipv4.ip_forward=1
net.ipv4.tcp_max_tw_buckets=6000
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_synack_retries=2
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.netfilter.nf_conntrack_max=2310720
net.ipv6.neigh.default.gc_thresh1=8192
net.ipv6.neigh.default.gc_thresh2=32768
net.ipv6.neigh.default.gc_thresh3=65536
net.core.netdev_max_backlog=16384 # 每CPU网络设备积压队列长度
net.core.rmem_max = 16777216 # 所有协议类型读写的缓存区大小
net.core.wmem_max = 16777216
net.ipv4.tcp_max_syn_backlog = 8096 # 第一个积压队列长度
net.core.somaxconn = 32768 # 第二个积压队列长度
fs.inotify.max_user_instances=8192 # 表示每一个real user ID可创建的inotify instatnces的数量上限，默认128.
fs.inotify.max_user_watches=524288 # 同一用户同时可以添加的watch数目，默认8192。
fs.file-max=52706963
fs.nr_open=52706963
kernel.pid_max = 4194303
net.bridge.bridge-nf-call-arptables=1
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
vm.max_map_count = 262144
EOF
#加载ipvs模块
cat >/etc/modules-load.d/ipvs.conf <<EOF
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
systemctl enable --now systemd-modules-load.service
#重启
reboot
#重启服务器执行检查
lsmod | grep -e ip_vs -e nf_conntrack
```

### 6.安装基础软件

```
#安装基础软件
yum install curl conntrack ipvsadm ipset iptables jq sysstat libseccomp rsync wget jq psmisc vim net-tools telnet -y
```

### 7.优化journald日志

```
mkdir -p /var/log/journal
mkdir -p /etc/systemd/journald.conf.d
cat >/etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
# 最大占用空间 1G
SystemMaxUse=1G
# 单日志文件最大 10M
SystemMaxFileSize=10M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 不将日志转发到 syslog
ForwardToSyslog=no
EOF
systemctl restart systemd-journald && systemctl enable systemd-journald
```

### 8.配置kubernetes的yum源

　　我这里使用的自己的代理源,你们可以使用清华源：[https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/](https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/)

```
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=kubernetes
baseurl=http://192.168.10.254:8081/repository/kubernetes/
gpgcheck=0
EOF
#测试
yum list --showduplicates | grep kubeadm
```

## 1.2 安装docker

　　配置docker源，我这里使用自己的源，你们可以使用清华源：[https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/](https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/)

　　1.24.+版本如果使用docker作为容器运行时，需要额外安装cri-docker插件,下载地址:[https://github.com/Mirantis/cri-dockerd/releases](https://github.com/Mirantis/cri-dockerd/releases)

```
cat > /etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce]
name=docker-ce
baseurl=http://192.168.10.254:8081/repository/docker-ce/
gpgcheck=0
EOF
#测试
yum list --showduplicates | grep docker-ce
```

　　**部署docker-ce**

```
#所有节点安装
yum install container-selinux -y
yum install docker-ce -y
systemctl enable --now docker
#验证
docker info
Client:
 Debug Mode: false
#配置docker
#温馨提示：
#由于新版kubelet建议使用systemd，所以可以把docker的CgroupDriver改成systemd
mkdir /etc/docker/ -p
cat >/etc/docker/daemon.json <<EOF
{
   "insecure-registries": ["192.168.10.254:5000"],
   "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl restart docker
#验证
docker info
 Insecure Registries:
  192.168.10.254:5000
  127.0.0.0/8
 Cgroup Driver: systemd
```

　　**安装cri-docker，需要事先下载rpm包**

　　下载地址：[https://github.com/Mirantis/cri-dockerd/releases](https://github.com/Mirantis/cri-dockerd/releases)

```
#安装
rpm -ivh cri-dockerd-0.2.6-3.el7.x86_64.rpm
#修改配置
vim /usr/lib/systemd/system/cri-docker.service
ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni --pod-infra-container-image=192.168.10.254:5000/k8s/pause:3.7
#启动
systemctl enable --now cri-docker.socket
systemctl enable --now cri-docker.service
#验证
systemctl status cri-docker
```

## 1.3 安装kubernetes组件安装

```
#所有节点安装kubeadm
yum list kubeadm.x86_64 --showduplicates | sort -r #查看所有版本
#安装1.25.5
yum install kubeadm-1.25.5-0 kubelet-1.25.5-0 kubectl-1.25.5-0 -y
#设置kubelet
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f4)
cat >/etc/sysconfig/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS"
EOF
#重启kubelet
systemctl daemon-reload && systemctl restart kubelet && systemctl enable kubelet
```

## 1.4 安装高可用组件nginx

```
#解压
tar xf nginx.tar.gz -C /usr/bin/
#生成配置文件
mkdir /etc/nginx -p
mkdir /var/log/nginx -p
cat >/etc/nginx/nginx.conf<<EOF 
user root;
worker_processes 1;

error_log  /var/log/nginx/error.log warn;
pid /var/log/nginx/nginx.pid;

events {
    worker_connections  3000;
}

stream {
    upstream apiservers {
        server 192.168.10.11:6443  max_fails=2 fail_timeout=3s;
        server 192.168.10.12:6443  max_fails=2 fail_timeout=3s;
        server 192.168.10.13:6443  max_fails=2 fail_timeout=3s;
    }

    server {
        listen 127.0.0.1:16443;
        proxy_connect_timeout 1s;
        proxy_pass apiservers;
    }
}
EOF
#生成启动文件
cat >/etc/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx proxy
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStartPre=/usr/bin/nginx -c /etc/nginx/nginx.conf -p /etc/nginx -t
ExecStart=/usr/bin/nginx -c /etc/nginx/nginx.conf -p /etc/nginx
ExecReload=/usr/bin/nginx -c /etc/nginx/nginx.conf -p /etc/nginx -s reload
PrivateTmp=true
Restart=always
RestartSec=15
StartLimitInterval=0
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
#启动
systemctl enable --now nginx.service
#验证
ss -ntl | grep 16443
LISTEN     0      511    127.0.0.1:16443                    *:*
```

# 二、k8s组件安装

## 2.1 准备kubeadm-config.yaml配置文件

```
#生成kubeadm文件
cat >kubeadm-config.yaml<<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.25.5
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
apiServer:
  certSANs:
  - 127.0.0.1
controlPlaneEndpoint: "127.0.0.1:16443"
networking:
  # This CIDR is a Calico default. Substitute or remove for your CNI provider.
  podSubnet: "10.100.0.0/16"
  serviceSubnet: 10.200.0.0/16
  dnsDomain: cluster.local
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: "/var/run/cri-dockerd.sock"
EOF
#更新kubeadm文件
kubeadm config migrate --old-config kubeadm-config.yaml --new-config new.yaml

#下载镜像修改上传到自己镜像chan
kubeadm config images pull --config new.yaml
cat >1.sh<<EOF
name="
`docker images | grep regis | awk -v OFS=':' 'NR!=1{print $1,$2}'`
"
host='192.168.10.254:5000'
for var in \$name;do
  tmp=\${var##*/}
  eval new_image_url=\${host}/k8s/\${tmp}
  docker tag \$var \$new_image_url
  docker push \$new_image_url
done
EOF
bash 1.sh
#修改kubeadm配置文件
imageRepository: 192.168.10.254:5000/k8s
#验证拉取镜像
kubeadm config images pull --config new.yaml
```

## 2.2 初始化k8s集群

　　在一个master节点执行即可

```
kubeadm init --config new.yaml  --upload-certs
#出现以下信息表示正常
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 127.0.0.1:16443 --token ucpfmd.zbjcz4n5uqe5f9jy \
--discovery-token-ca-cert-hash sha256:d8141316a384146a251c5dfbdc843d5de8f8d6e7c17f671c6e72e4b452880da2 \
--control-plane --certificate-key 52e1ddcf79e3a275c6dcc84cb2ecf910ff41735debd293c508ccbf63fa2a9f1d

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 127.0.0.1:16443 --token ucpfmd.zbjcz4n5uqe5f9jy \
--discovery-token-ca-cert-hash sha256:d8141316a384146a251c5dfbdc843d5de8f8d6e7c17f671c6e72e4b452880da2
```

## 2.3 初始化master

```
kubeadm join 127.0.0.1:16443 --token ucpfmd.zbjcz4n5uqe5f9jy \
--discovery-token-ca-cert-hash sha256:d8141316a384146a251c5dfbdc843d5de8f8d6e7c17f671c6e72e4b452880da2 \
--control-plane --certificate-key 52e1ddcf79e3a275c6dcc84cb2ecf910ff41735debd293c508ccbf63fa2a9f1d \
 --cri-socket unix:///var/run/cri-dockerd.sock
```

## 2.4 初始化node节点

```
kubeadm join 127.0.0.1:16443 --token ucpfmd.zbjcz4n5uqe5f9jy \
--discovery-token-ca-cert-hash sha256:d8141316a384146a251c5dfbdc843d5de8f8d6e7c17f671c6e72e4b452880da2 \
 --cri-socket unix:///var/run/cri-dockerd.sock
```

# 三、其他组件安装

## 3.1 网络组件安装

### 1.安装calico网络插件

　　**这里安装v3.24.5版本**

　　yaml下载地址：[https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico-typha.yaml](https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico-typha.yaml)

```
mkdir /opt/k8s/calico -p
#下载yaml文件，修改的内容为下
#以下需要使用命令编码证书文件之后粘贴内容,命令如下
cat calico-typha.yaml | grep 'image:'
          image: 192.168.10.254:5000/kubernetes/cni:v3.24.5
          image: 192.168.10.254:5000/kubernetes/cni:v3.24.5
          image: 192.168.10.254:5000/kubernetes/node:v3.24.5
          image: 192.168.10.254:5000/kubernetes/node:v3.24.5
          image: 192.168.10.254:5000/kubernetes/kube-controllers:v3.24.5
      - image: 192.168.10.254:5000/kubernetes/typha:v3.24.5
#修改配置
            - name: CALICO_IPV4POOL_CIDR
              value: "10.100.0.0/16" 
#创建
kubectl apply -f calico-typha.yaml
#验证
kubectl  get pod -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-5896d7d958-gc72q   1/1     Running   0          56s
calico-node-7gmb4                          1/1     Running   0          56s
calico-node-v7lh7                          1/1     Running   0          56s
calico-node-vtg6l                          1/1     Running   0          56s
calico-node-wrxdk                          1/1     Running   0          56s
calico-node-x5zfm                          1/1     Running   0          56s
calico-typha-86fbc78fb-z5zxh               1/1     Running   0          56s
#验证node节点状态
kubectl get node
NAME            STATUS   ROLES    AGE   VERSION
192.168.10.11   Ready    <none>   11m   v1.25.5
192.168.10.12   Ready    <none>   11m   v1.25.5
192.168.10.13   Ready    <none>   11m   v1.25.5
192.168.10.14   Ready    <none>   11m   v1.25.5
192.168.10.15   Ready    <none>   11m   v1.25.5
```

　　**安装calicoctl客户端工具**

　　下载地址：[https://github.com/projectcalico/calico](https://github.com/projectcalico/calico)

```
#创建配置文件
mkdir /etc/calico -p
cat >/etc/calico/calicoctl.cfg <<EOF
apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "kubernetes"
  kubeconfig: "/root/.kube/config"
EOF
#验证
calicoctl node status
Calico process is running.

IPv4 BGP status
+---------------+-------------------+-------+----------+-------------+
| PEER ADDRESS  |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+---------------+-------------------+-------+----------+-------------+
| 192.168.10.52 | node-to-node mesh | up    | 13:03:48 | Established |
| 192.168.10.53 | node-to-node mesh | up    | 13:03:48 | Established |
| 192.168.10.54 | node-to-node mesh | up    | 13:03:48 | Established |
| 192.168.10.55 | node-to-node mesh | up    | 13:03:47 | Established |
+---------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.
```

## 3.2 安装dashboard

　　下载地址：[https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml](https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml)

```
#修改yaml文件
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort  #添加
  ports:
    - port: 443 
      targetPort: 8443
      nodePort: 30001  #添加
  selector:
    k8s-app: kubernetes-dashboard
#创建
kubectl apply -f dashboard.yaml
#创建用户
cat >admin.yaml<<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
kubectl apply -f admin.yaml
#获取用户token
kubectl describe secrets -n kubernetes-dashboard admin-user
```

## 3.3 安装Metrics-server

　　下载地址：[https://github.com/kubernetes-sigs/metrics-server/](https://github.com/kubernetes-sigs/metrics-server/)

```
#需要修改配置
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls 
        - --requestheader-username-headers=X-Remote-User
        - --requestheader-group-headers=X-Remote-Group
        - --requestheader-extra-headers-prefix=X-Remote-Extra- 
#创建
kubectl apply -f components.yaml
#验证
kubectl top node 
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
192.168.10.51   98m          4%     1445Mi          37%   
192.168.10.52   78m          3%     1008Mi          26%   
192.168.10.53   82m          4%     1252Mi          32%   
192.168.10.54   43m          1%     771Mi           20%   
192.168.10.55   55m          1%     640Mi           16%
```

# 四、一些必要的修改

## 4.1 修改kube-proxy工作模式为ipvs

　　将Kube-proxy改为ipvs模式，因为在初始化集群的时候注释了ipvs配置，所以需要自行修改一下：

```
#在控制节点修改configmap
kubectl edit cm -n kube-system kube-proxy
mode: "ipvs"  #默认没有值是iptables工作模式
#更新kube-proxy的pod
kubectl patch daemonset kube-proxy -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}" -n kube-system
#验证工作模式
curl 127.0.0.1:10249/proxyMode
ipvs
```

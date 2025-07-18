

# 1.环境

|主机名称|IP地址|说明|软件|
| ----------| --------------| ------------| ------------------------------------------------------------------------------------------------------------------------------|
||192.168.1.60|外网节点|下载各种所需安装包|
|Master01|192.168.1.31|master节点|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client、haproxy、keepalived、nginx|
|Master02|192.168.1.32|master节点|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client、haproxy、keepalived、nginx|
|Master03|192.168.1.33|master节点|kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client、haproxy、keepalived、nginx|
|Node01|192.168.1.34|node节点|kubelet、kube-proxy、nfs-client、nginx|
|Node02|192.168.1.35|node节点|kubelet、kube-proxy、nfs-client、nginx|
||192.168.1.36|VIP||

|详细版本||
|软件|版本|
| ----------------------------| ---------|
|cni_plugins_version|v1.6.1|
|cri_containerd_cni_version|2.0.1|
|crictl_version|v1.32.0|
|cri_dockerd_version|0.3.16|
|etcd_version|v3.5.17|
|cfssl_version|1.6.5|
|kubernetes_server_version|1.32.0|
|docker_version|27.4.0|
|runc_version|1.2.3|
|kernel_version|5.4.278|
|helm_version|3.16.3|
|nginx_version|1.27.3|

网段  

IPv4   
  
物理主机：192.168.1.0/24  
  
service：10.96.0.0/12  
  
pod：172.16.0.0/12 

IPv6   
  
物理主机：2408:822a:732:5ce1::1001/64  
  
物理主机：fc00::31/8  
  
service：fd00:1111::/112  
  
pod：fc00:2222::/112

安装包已经整理好：https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.32.0/kubernetes-v1.32.0.tar

## 1.1.k8s基础系统环境配置

### 1.2.配置IP

```shell
# 注意！
# 若虚拟机是进行克隆的那么网卡的UUID和MachineID会重复
# 需要重新生成新的UUIDUUID和MachineID
# UUID和MachineID重复无法DHCP获取到IPV6地址
ssh root@192.168.1.153 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.158 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.159 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.160 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.161 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
# 
# 查看当前的网卡列表和 UUID：
# nmcli con show
# 删除要更改 UUID 的网络连接：
# nmcli con delete uuid <原 UUID>
# 重新生成 UUID：
# nmcli con add type ethernet ifname <接口名称> con-name <新名称>
# 重新启用网络连接：
# nmcli con up <新名称>

# 更改网卡的UUID
# 先配置静态IP之后使用ssh方式配置不断连
ssh root@192.168.1.153 "nmcli con delete uuid 628b03ed-3c1e-32ea-b001-eb5b8ac73285;nmcli con add type ethernet ifname ens18 con-name ens18;nmcli con up ens18"
ssh root@192.168.1.158 "nmcli con delete uuid 628b03ed-3c1e-32ea-b001-eb5b8ac73285;nmcli con add type ethernet ifname ens18 con-name ens18;nmcli con up ens18"
ssh root@192.168.1.159 "nmcli con delete uuid 628b03ed-3c1e-32ea-b001-eb5b8ac73285;nmcli con add type ethernet ifname ens18 con-name ens18;nmcli con up ens18"
ssh root@192.168.1.160 "nmcli con delete uuid 628b03ed-3c1e-32ea-b001-eb5b8ac73285;nmcli con add type ethernet ifname ens18 con-name ens18;nmcli con up ens18"
ssh root@192.168.1.161 "nmcli con delete uuid 628b03ed-3c1e-32ea-b001-eb5b8ac73285;nmcli con add type ethernet ifname ens18 con-name ens18;nmcli con up ens18"

# 参数解释
# 
# ssh ssh root@192.168.1.31
# 使用SSH登录到IP为192.168.1.31的主机，使用root用户身份。
# 
# nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44
# 删除 UUID 为 708a1497-2192-43a5-9f03-2ab936fb3c44 的网络连接，这是 NetworkManager 中一种特定网络配置的唯一标识符。
# 
# nmcli con add type ethernet ifname ens18 con-name ens18
# 添加一种以太网连接类型，并指定接口名为 ens18，连接名称也为 ens18。
# 
# nmcli con up ens18
# 开启 ens18 这个网络连接。
# 
# 简单来说，这个命令的作用是删除一个特定的网络连接配置，并添加一个名为 ens18 的以太网连接，然后启用这个新的连接。

# 修改静态的IPv4地址
ssh root@192.168.1.153 "nmcli con mod ens18 ipv4.addresses 192.168.1.31/24; nmcli con mod ens18 ipv4.gateway  192.168.1.1; nmcli con mod ens18 ipv4.method manual; nmcli con mod ens18 ipv4.dns "8.8.8.8"; nmcli con up ens18"
ssh root@192.168.1.158 "nmcli con mod ens18 ipv4.addresses 192.168.1.32/24; nmcli con mod ens18 ipv4.gateway  192.168.1.1; nmcli con mod ens18 ipv4.method manual; nmcli con mod ens18 ipv4.dns "8.8.8.8"; nmcli con up ens18"
ssh root@192.168.1.159 "nmcli con mod ens18 ipv4.addresses 192.168.1.33/24; nmcli con mod ens18 ipv4.gateway  192.168.1.1; nmcli con mod ens18 ipv4.method manual; nmcli con mod ens18 ipv4.dns "8.8.8.8"; nmcli con up ens18"
ssh root@192.168.1.160 "nmcli con mod ens18 ipv4.addresses 192.168.1.34/24; nmcli con mod ens18 ipv4.gateway  192.168.1.1; nmcli con mod ens18 ipv4.method manual; nmcli con mod ens18 ipv4.dns "8.8.8.8"; nmcli con up ens18"
ssh root@192.168.1.161 "nmcli con mod ens18 ipv4.addresses 192.168.1.35/24; nmcli con mod ens18 ipv4.gateway  192.168.1.1; nmcli con mod ens18 ipv4.method manual; nmcli con mod ens18 ipv4.dns "8.8.8.8"; nmcli con up ens18"

# 参数解释
# 
# ssh root@192.168.1.154
# 使用SSH登录到IP为192.168.1.154的主机，使用root用户身份。
# 
# "nmcli con mod ens18 ipv4.addresses 192.168.1.31/24"
# 修改ens18网络连接的IPv4地址为192.168.1.31，子网掩码为 24。
# 
# "nmcli con mod ens18 ipv4.gateway 192.168.1.1"
# 修改ens18网络连接的IPv4网关为192.168.1.1。
# 
# "nmcli con mod ens18 ipv4.method manual"
# 将ens18网络连接的IPv4配置方法设置为手动。
# 
# "nmcli con mod ens18 ipv4.dns "8.8.8.8"
# 将ens18网络连接的IPv4 DNS服务器设置为 8.8.8.8。
# 
# "nmcli con up ens18"
# 启动ens18网络连接。
# 
# 总体来说，这条命令是通过SSH远程登录到指定的主机，并使用网络管理命令 (nmcli) 修改ens18网络连接的配置，包括IP地址、网关、配置方法和DNS服务器，并启动该网络连接。

# 我这里有公网的IPv6的地址，但是是DHCP动态的，无法固定，使用不方便
# 所以我配置了内网的IPv6地址，可以实现固定的访问地址

# 我使用的方式。只配置IPv6地址不配置网关DNS
ssh root@192.168.1.31 "nmcli con mod ens18 ipv6.addresses fc00::31/8; nmcli con up ens18"
ssh root@192.168.1.32 "nmcli con mod ens18 ipv6.addresses fc00::32/8; nmcli con up ens18"
ssh root@192.168.1.33 "nmcli con mod ens18 ipv6.addresses fc00::33/8; nmcli con up ens18"
ssh root@192.168.1.34 "nmcli con mod ens18 ipv6.addresses fc00::34/8; nmcli con up ens18"
ssh root@192.168.1.35 "nmcli con mod ens18 ipv6.addresses fc00::35/8; nmcli con up ens18"

# IPv6地址路由DNS，样例
ssh root@192.168.1.31 "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::10; nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens18 ipv6.method manual; nmcli con mod ens18 ipv6.dns "2400:3200::1"; nmcli con up ens18"
ssh root@192.168.1.32 "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::20; nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens18 ipv6.method manual; nmcli con mod ens18 ipv6.dns "2400:3200::1"; nmcli con up ens18"
ssh root@192.168.1.33 "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::30; nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens18 ipv6.method manual; nmcli con mod ens18 ipv6.dns "2400:3200::1"; nmcli con up ens18"
ssh root@192.168.1.34 "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::40; nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens18 ipv6.method manual; nmcli con mod ens18 ipv6.dns "2400:3200::1"; nmcli con up ens18"
ssh root@192.168.1.35 "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::50; nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens18 ipv6.method manual; nmcli con mod ens18 ipv6.dns "2400:3200::1"; nmcli con up ens18"

# 参数解释
# 
# ssh root@192.168.1.31
# 通过SSH连接到IP地址为192.168.1.31的远程主机，使用root用户进行登录。
# 
# "nmcli con mod ens18 ipv6.addresses fc00:43f4:1eea:1::10"
# 使用nmcli命令修改ens18接口的IPv6地址为fc00:43f4:1eea:1::10。
# 
# "nmcli con mod ens18 ipv6.gateway fc00:43f4:1eea:1::1"
# 使用nmcli命令修改ens18接口的IPv6网关为fc00:43f4:1eea:1::1。
# 
# "nmcli con mod ens18 ipv6.method manual"
# 使用nmcli命令将ens18接口的IPv6配置方法修改为手动配置。
# 
# "nmcli con mod ens18 ipv6.dns "2400:3200::1"
# 使用nmcli命令设置ens18接口的IPv6 DNS服务器为2400:3200::1。
# 
# "nmcli con up ens18"
# 使用nmcli命令启动ens18接口。
# 
# 这个命令的目的是在远程主机上配置ens18接口的IPv6地址、网关、配置方法和DNS服务器，并启动ens18接口。

# 查看网卡配置
# nmcli device show ens18
# nmcli con show ens18
[root@localhost ~]#  cat /etc/NetworkManager/system-connections/ens18.nmconnection 
[connection]
id=ens18
uuid=5fd4642e-4aa4-4b59-8e22-dd38a4611f06
type=ethernet
interface-name=ens18
timestamp=1734243991

[ethernet]

[ipv4]
address1=192.168.1.31/24,192.168.1.1
dns=192.168.1.99;
method=manual

[ipv6]
addr-gen-mode=default
address1=fc00::31/8
method=auto

[proxy]

[root@localhost ~]# 

# 参数解释
# 1. `[connection]`:
#    - `id`: 连接的唯一标识符，用于内部引用。
#    - `uuid`: 连接的通用唯一标识符（UUID），确保在系统中的唯一性。
#    - `type`: 指定连接的类型，本例中为以太网。
#    - `interface-name`: 网络接口的名称（`ens18`），表示与此连接关联的物理或逻辑网络接口。
#    - `timestamp`: 时间戳，指示连接配置上次修改的时间。
# 2. `[ethernet]`:
#    - 通常包含以太网特定的配置设置，如MAC地址或链路速度。
# 3. `[ipv4]`:
#    - `address1`: 以CIDR表示法指定IPv4地址和子网掩码（`192.168.1.31/24`）。还包括网关IP（`192.168.1.1`）。
#    - `dns`: 指定要使用的DNS服务器（本例中为`8.8.8.8`），提供将域名转换为IP地址的手段。
#    - `method`: 指定获取IPv4地址的方法。在本例中，设置为手动，表示IP地址是静态配置的。
# 4. `[ipv6]`:
#    - `addr-gen-mode`: 指定IPv6地址生成模式。设置为默认，通常意味着地址是根据接口的MAC地址生成的。
#    - `method`: 指定获取IPv6地址的方法。在本例中，设置为自动，表示使用DHCPv6或SLAAC等协议进行自动配置。
# 5. `[proxy]`:
#    - 通常用于配置代理设置，如HTTP或SOCKS代理。
```

### 1.3.设置主机名

```shell
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02

# 参数解释
# 
# 参数: set-hostname
# 解释: 这是hostnamectl命令的一个参数，用于设置系统的主机名。
# 
# 参数: k8s-master01
# 解释: 这是要设置的主机名，将系统的主机名设置为"k8s-master01"。
```

### 1.4.配置yum源

```shell
# 其他系统的源地址
# https://help.mirrors.cernet.edu.cn/

# 对于私有仓库
sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://mirror.centos.org/\$contentdir|baseurl=http://192.168.1.123/centos|g' -i.bak  /etc/yum.repos.d/CentOS-*.repo

# 对于 Ubuntu
sed -i 's/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# epel扩展源
sudo yum install -y epel-release
sudo sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirror.nju.edu.cn/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirror.nju.edu.cn/epel!g' \
    -i /etc/yum.repos.d/epel{,-testing}.repo

# 对于 CentOS 7
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirror.nju.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于 CentOS 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirror.nju.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于CentOS 9
cat <<'EOF' > /etc/yum.repos.d/centos.repo
[baseos]
name=CentOS Stream $releasever - BaseOS
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[baseos-debuginfo]
name=CentOS Stream $releasever - BaseOS - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[baseos-source]
name=CentOS Stream $releasever - BaseOS - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[appstream]
name=CentOS Stream $releasever - AppStream
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[appstream-debuginfo]
name=CentOS Stream $releasever - AppStream - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[appstream-source]
name=CentOS Stream $releasever - AppStream - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[crb]
name=CentOS Stream $releasever - CRB
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[crb-debuginfo]
name=CentOS Stream $releasever - CRB - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[crb-source]
name=CentOS Stream $releasever - CRB - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0
EOF

cat <<'EOF' > /etc/yum.repos.d/centos-addons.repo
[highavailability]
name=CentOS Stream $releasever - HighAvailability
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[highavailability-debuginfo]
name=CentOS Stream $releasever - HighAvailability - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[highavailability-source]
name=CentOS Stream $releasever - HighAvailability - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[nfv]
name=CentOS Stream $releasever - NFV
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[nfv-debuginfo]
name=CentOS Stream $releasever - NFV - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[nfv-source]
name=CentOS Stream $releasever - NFV - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[rt]
name=CentOS Stream $releasever - RT
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[rt-debuginfo]
name=CentOS Stream $releasever - RT - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[rt-source]
name=CentOS Stream $releasever - RT - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[resilientstorage]
name=CentOS Stream $releasever - ResilientStorage
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[resilientstorage-debuginfo]
name=CentOS Stream $releasever - ResilientStorage - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[resilientstorage-source]
name=CentOS Stream $releasever - ResilientStorage - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[extras-common]
name=CentOS Stream $releasever - Extras packages
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/SIGs/$releasever-stream/extras/$basearch/extras-common
# metalink=https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[extras-common-source]
name=CentOS Stream $releasever - Extras packages - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/SIGs/$releasever-stream/extras/source/extras-common
# metalink=https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0
EOF
```

### 1.5.安装一些必备工具

```shell
# 对于 Ubuntu
apt update && apt upgrade -y && apt install -y wget psmisc vim net-tools nfs-kernel-server telnet lvm2 git tar curl

# 对于 CentOS 7
yum update -y && yum -y install  wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl

# 对于 CentOS 8
yum update -y && yum -y install wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl

# 对于 CentOS 9
yum update -y && yum -y install wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl
```

#### 1.5.1 下载离线所需文件(可选)

在互联网服务器上安装一个一模一样的系统进行下载所需包

##### CentOS7

```shell
# 下载必要工具
yum -y install createrepo yum-utils wget epel*

# 下载全量依赖包
repotrack createrepo wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl gcc keepalived haproxy bash-completion chrony sshpass ipvsadm ipset sysstat conntrack libseccomp

# 删除libseccomp
rm -rf libseccomp-*.rpm

# 下载libseccomp
wget http://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm

# 创建yum源信息
createrepo -u -d /data/centos7/

# 拷贝包到内网机器上
scp -r /data/centos7/ root@192.168.1.31:
scp -r /data/centos7/ root@192.168.1.32:
scp -r /data/centos7/ root@192.168.1.33:
scp -r /data/centos7/ root@192.168.1.34:
scp -r /data/centos7/ root@192.168.1.35:

# 在内网机器上创建repo配置文件
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/123.repo  << EOF 
[cby]
name=CentOS-$releasever - Media
baseurl=file:///root/centos7/
gpgcheck=0
enabled=1
EOF

# 安装下载好的包
yum clean all
yum makecache
yum install /root/centos7/* --skip-broken -y

#### 备注 #####
# 安装完成后，可能还会出现yum无法使用那么再次执行
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/123.repo  << EOF 
[cby]
name=CentOS-$releasever - Media
baseurl=file:///root/centos7/
gpgcheck=0
enabled=1
EOF
yum clean all
yum makecache
yum install /root/centos7/*.rpm --skip-broken -y

#### 备注 #####
# 安装 chrony 和 libseccomp
# yum install /root/centos7/libseccomp-2.5.1*.rpm -y
# yum install /root/centos7/chrony-*.rpm -y
```

##### CentOS8

```shell
# 下载必要工具
yum -y install createrepo yum-utils wget epel*

# 下载全量依赖包
repotrack wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl gcc keepalived haproxy bash-completion chrony sshpass ipvsadm ipset sysstat conntrack libseccomp

# 创建yum源信息
createrepo -u -d /data/centos8/

# 拷贝包到内网机器上
scp -r centos8/ root@192.168.1.31:
scp -r centos8/ root@192.168.1.32:
scp -r centos8/ root@192.168.1.33:
scp -r centos8/ root@192.168.1.34:
scp -r centos8/ root@192.168.1.35:

# 在内网机器上创建repo配置文件
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/123.repo  << EOF 
[cby]
name=CentOS-$releasever - Media
baseurl=file:///root/centos8/
gpgcheck=0
enabled=1
EOF

# 安装下载好的包
yum clean all
yum makecache
yum install /root/centos8/* --skip-broken -y

#### 备注 #####
# 安装完成后，可能还会出现yum无法使用那么再次执行
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/123.repo  << EOF 
[cby]
name=CentOS-$releasever - Media
baseurl=file:///root/centos8/
gpgcheck=0
enabled=1
EOF
yum clean all
yum makecache
yum install /root/centos8/*.rpm --skip-broken -y
```

##### CentOS9

```shell
# 下载必要工具
yum -y install createrepo yum-utils wget epel*

# 下载全量依赖包
repotrack wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl
# 创建yum源信息
createrepo -u -d centos9/

# 拷贝包到内网机器上
scp -r centos9/ root@192.168.1.31:
scp -r centos9/ root@192.168.1.32:
scp -r centos9/ root@192.168.1.33:
scp -r centos9/ root@192.168.1.34:
scp -r centos9/ root@192.168.1.35:

# 在内网机器上创建repo配置文件
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/123.repo  << EOF 
[cby]
name=CentOS-$releasever - Media
baseurl=file:///root/centos9/
gpgcheck=0
enabled=1
EOF

# 安装下载好的包
yum clean all
yum makecache
yum install /root/centos9/*.rpm --skip-broken -y
```

##### Ubuntu 下载包和依赖

```shell
#!/bin/bash

logfile=123.log
ret=""
function getDepends()
{
   echo "fileName is" $1>>$logfile
   # use tr to del < >
   ret=`apt-cache depends $1|grep Depends |cut -d: -f2 |tr -d "<>"`
   echo $ret|tee  -a $logfile
}
# 需要获取其所依赖包的包
libs="wget psmisc vim net-tools nfs-kernel-server telnet lvm2 git tar curl gcc keepalived haproxy bash-completion chrony sshpass ipvsadm ipset sysstat conntrack libseccomp"

# download libs dependen. deep in 3
i=0
while [ $i -lt 3 ] ;
do
    let i++
    echo $i
    # download libs
    newlist=" "
    for j in $libs
    do
        added="$(getDepends $j)"
        newlist="$newlist $added"
        apt install $added --reinstall -d -y
    done

    libs=$newlist
done

# 创建源信息
apt install dpkg-dev
sudo cp /var/cache/apt/archives/*.deb /data/ubuntu/ -r
dpkg-scanpackages . /dev/null |gzip > /data/ubuntu/Packages.gz -r

# 拷贝包到内网机器上
scp -r ubuntu/ root@192.168.1.31:
scp -r ubuntu/ root@192.168.1.32:
scp -r ubuntu/ root@192.168.1.33:
scp -r ubuntu/ root@192.168.1.34:
scp -r ubuntu/ root@192.168.1.35:

# 在内网机器上配置apt源
vim /etc/apt/sources.list
cat /etc/apt/sources.list
deb file:////root/ ubuntu/

# 安装deb包
apt install ./*.deb
```

### 1.6.选择性下载需要工具

```shell
#!/bin/bash

# 查看版本地址：
# 
# https://github.com/containernetworking/plugins/releases/
# https://github.com/containerd/containerd/releases/
# https://github.com/kubernetes-sigs/cri-tools/releases/
# https://github.com/Mirantis/cri-dockerd/releases/
# https://github.com/etcd-io/etcd/releases/
# https://github.com/cloudflare/cfssl/releases/
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG
# https://download.docker.com/linux/static/stable/x86_64/
# https://github.com/opencontainers/runc/releases/
# https://github.com/helm/helm/tags
# http://nginx.org/download/

# Version numbers
cni_plugins_version='v1.6.1'
cri_containerd_cni_version='2.0.1'
crictl_version='v1.32.0'
cri_dockerd_version='0.3.16'
etcd_version='v3.5.17'
cfssl_version='1.6.5'
kubernetes_server_version='1.32.0'
docker_version='27.4.0'
runc_version='1.2.3'
kernel_version='5.4.278'
helm_version='3.16.3'
nginx_version='1.27.3'

# URLs 
base_url='https://mirrors.chenby.cn/https://github.com'
kernel_url="http://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/kernel-lt-${kernel_version}-1.el7.elrepo.x86_64.rpm"
runc_url="${base_url}/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"
docker_url="https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/x86_64/docker-${docker_version}.tgz"
cni_plugins_url="${base_url}/containernetworking/plugins/releases/download/${cni_plugins_version}/cni-plugins-linux-amd64-${cni_plugins_version}.tgz"
cri_containerd_cni_url="${base_url}/containerd/containerd/releases/download/v${cri_containerd_cni_version}/containerd-${cri_containerd_cni_version}-linux-amd64.tar.gz"
crictl_url="${base_url}/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz"
cri_dockerd_url="${base_url}/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"
etcd_url="${base_url}/etcd-io/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz"
cfssl_url="${base_url}/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_amd64"
cfssljson_url="${base_url}/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_amd64"
helm_url="https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-amd64.tar.gz"
kubernetes_server_url="https://cdn.dl.k8s.io/release/v${kubernetes_server_version}/kubernetes-server-linux-amd64.tar.gz"
nginx_url="http://nginx.org/download/nginx-${nginx_version}.tar.gz"

# Download packages
packages=(
  # $kernel_url
  $runc_url
  $docker_url
  $cni_plugins_url
  $cri_containerd_cni_url
  $crictl_url
  $cri_dockerd_url
  $etcd_url
  $cfssl_url
  $cfssljson_url
  $helm_url
  $kubernetes_server_url
  $nginx_url
)

for package_url in "${packages[@]}"; do
  filename=$(basename "$package_url")
  if curl --parallel --parallel-immediate -k -L -C - -o "$filename" "$package_url"; then
    echo "Downloaded $filename"
  else
    echo "Failed to download $filename"
    exit 1
  fi
done
```

### 1.7.关闭防火墙

```shell
# Ubuntu忽略，CentOS执行
systemctl disable --now firewalld
```

### 1.8.关闭SELinux

```shell
# Ubuntu忽略，CentOS执行
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config

# 参数解释
# 
# setenforce 0
# 此命令用于设置 SELinux 的执行模式。0 表示关闭 SELinux。
# 
# sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
# 该命令使用 sed 工具来编辑 /etc/selinux/config 文件。其中 '-i' 参数表示直接修改原文件，而不是输出到终端或另一个文件。's#SELINUX=enforcing#SELINUX=disabled#g' 是 sed 的替换命令，它将文件中所有的 "SELINUX=enforcing" 替换为 "SELINUX=disabled"。这里的 '#' 是分隔符，用于替代传统的 '/' 分隔符，以避免与路径中的 '/' 冲突。
```

### 1.9.关闭交换分区

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab
# /dev/mapper/centos-swap swap                    swap    defaults        0 0


# 参数解释：
# 
# -ri: 这个参数用于在原文件中替换匹配的模式。-r表示扩展正则表达式，-i允许直接修改文件。
# 's/.*swap.*/#&/': 这是一个sed命令，用于在文件/etc/fstab中找到包含swap的行，并在行首添加#来注释掉该行。
# /etc/fstab: 这是一个文件路径，即/etc/fstab文件，用于存储文件系统表。
# swapoff -a: 这个命令用于关闭所有启用的交换分区。
# sysctl -w vm.swappiness=0: 这个命令用于修改vm.swappiness参数的值为0，表示系统在物理内存充足时更倾向于使用物理内存而非交换分区。
```

### 1.10.网络配置（俩种方式二选一）

```shell
# Ubuntu忽略，CentOS执行，CentOS9不支持方式一

# 方式一
# systemctl disable --now NetworkManager
# systemctl start network && systemctl enable network

# 方式二
cat > /etc/NetworkManager/conf.d/calico.conf << EOF 
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF
systemctl restart NetworkManager

# 参数解释
#
# 这个参数用于指定不由 NetworkManager 管理的设备。它由以下两个部分组成
# 
# interface-name:cali*
# 表示以 "cali" 开头的接口名称被排除在 NetworkManager 管理之外。例如，"cali0", "cali1" 等接口不受 NetworkManager 管理。
# 
# interface-name:tunl*
# 表示以 "tunl" 开头的接口名称被排除在 NetworkManager 管理之外。例如，"tunl0", "tunl1" 等接口不受 NetworkManager 管理。
# 
# 通过使用这个参数，可以将特定的接口排除在 NetworkManager 的管理范围之外，以便其他工具或进程可以独立地管理和配置这些接口。
```

### 1.11.进行时间同步

```shell
# 服务端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.1.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

# 客户端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool 192.168.1.31 iburst
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

# 参数解释
#
# pool ntp.aliyun.com iburst
# 指定使用ntp.aliyun.com作为时间服务器池，iburst选项表示在初始同步时会发送多个请求以加快同步速度。
# 
# driftfile /var/lib/chrony/drift
# 指定用于保存时钟漂移信息的文件路径。
# 
# makestep 1.0 3
# 设置当系统时间与服务器时间偏差大于1秒时，会以1秒的步长进行调整。如果偏差超过3秒，则立即进行时间调整。
# 
# rtcsync
# 启用硬件时钟同步功能，可以提高时钟的准确性。
# 
# allow 192.168.0.0/24
# 允许192.168.0.0/24网段范围内的主机与chrony进行时间同步。
# 
# local stratum 10
# 将本地时钟设为stratum 10，stratum值表示时钟的准确度，值越小表示准确度越高。
# 
# keyfile /etc/chrony.keys
# 指定使用的密钥文件路径，用于对时间同步进行身份验证。
# 
# leapsectz right/UTC
# 指定时区为UTC。
# 
# logdir /var/log/chrony
# 指定日志文件存放目录。
```

### 1.12.配置ulimit

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

# 参数解释
#
# soft nofile 655360
# soft表示软限制，nofile表示一个进程可打开的最大文件数，默认值为1024。这里的软限制设置为655360，即一个进程可打开的最大文件数为655360。
#
# hard nofile 131072
# hard表示硬限制，即系统设置的最大值。nofile表示一个进程可打开的最大文件数，默认值为4096。这里的硬限制设置为131072，即系统设置的最大文件数为131072。
#
# soft nproc 655350
# soft表示软限制，nproc表示一个用户可创建的最大进程数，默认值为30720。这里的软限制设置为655350，即一个用户可创建的最大进程数为655350。
#
# hard nproc 655350
# hard表示硬限制，即系统设置的最大值。nproc表示一个用户可创建的最大进程数，默认值为4096。这里的硬限制设置为655350，即系统设置的最大进程数为655350。
#
# seft memlock unlimited
# seft表示软限制，memlock表示一个进程可锁定在RAM中的最大内存，默认值为64 KB。这里的软限制设置为unlimited，即一个进程可锁定的最大内存为无限制。
#
# hard memlock unlimited
# hard表示硬限制，即系统设置的最大值。memlock表示一个进程可锁定在RAM中的最大内存，默认值为64 KB。这里的硬限制设置为unlimited，即系统设置的最大内存锁定为无限制。
```

### 1.13.配置免密登录

```shell
# apt install -y sshpass
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.1.31 192.168.1.32 192.168.1.33 192.168.1.34 192.168.1.35"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done

# 这段脚本的作用是在一台机器上安装sshpass工具，并通过sshpass自动将本机的SSH公钥复制到多个远程主机上，以实现无需手动输入密码的SSH登录。
# 
# 具体解释如下：
# 
# 1. `apt install -y sshpass` 或 `yum install -y sshpass`：通过包管理器（apt或yum）安装sshpass工具，使得后续可以使用sshpass命令。
# 
# 2. `ssh-keygen -f /root/.ssh/id_rsa -P ''`：生成SSH密钥对。该命令会在/root/.ssh目录下生成私钥文件id_rsa和公钥文件id_rsa.pub，同时不设置密码（即-P参数后面为空），方便后续通过ssh-copy-id命令自动复制公钥。
# 
# 3. `export IP="192.168.1.31 192.168.1.32 192.168.1.33 192.168.1.34 192.168.1.35"`：设置一个包含多个远程主机IP地址的环境变量IP，用空格分隔开，表示要将SSH公钥复制到这些远程主机上。
# 
# 4. `export SSHPASS=123123`：设置环境变量SSHPASS，将sshpass所需的SSH密码（在这里是"123123"）赋值给它，这样sshpass命令可以自动使用这个密码进行登录。
# 
# 5. `for HOST in $IP;do`：遍历环境变量IP中的每个IP地址，并将当前IP地址赋值给变量HOST。
# 
# 6. `sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST`：使用sshpass工具复制本机的SSH公钥到远程主机。其中，-e选项表示使用环境变量中的密码（即SSHPASS）进行登录，-o StrictHostKeyChecking=no选项表示连接时不检查远程主机的公钥，以避免交互式确认。
# 
# 通过这段脚本，可以方便地将本机的SSH公钥复制到多个远程主机上，实现无需手动输入密码的SSH登录。
```

### 1.14.添加启用源

```shell
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
```

### 1.15.升级内核至4.18版本以上

```shell
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

# v8 整合命令为：
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y ; sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo ; sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install kernel-lt -y ; grubby --default-kernel ; reboot 

# v7 整合命令为：
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y ; sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo ; sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install  kernel-lt -y ; grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo) ; grubby --default-kernel ; reboot 

# 离线版本 
yum install -y /root/cby/kernel-lt-*-1.el7.elrepo.x86_64.rpm ; grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo) ; grubby --default-kernel ; reboot 
```

### 1.16.安装ipvsadm

```shell
# 对于CentOS7离线安装
# yum install /root/centos7/ipset-*.el7.x86_64.rpm /root/centos7/lm_sensors-libs-*.el7.x86_64.rpm  /root/centos7/ipset-libs-*.el7.x86_64.rpm /root/centos7/sysstat-*.el7_9.x86_64.rpm  /root/centos7/ipvsadm-*.el7.x86_64.rpm  -y

# 对于 Ubuntu
# apt install ipvsadm ipset sysstat conntrack -y

# 对于 CentOS
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
ip_vs                 237568  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          217088  3 nf_nat,nft_ct,ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  5 nf_conntrack,nf_nat,nf_tables,xfs,ip_vs

# 参数解释
#
# ip_vs
# IPVS 是 Linux 内核中的一个模块，用于实现负载均衡和高可用性。它通过在前端代理服务器上分发传入请求到后端实际服务器上，提供了高性能和可扩展的网络服务。
#
# ip_vs_rr
# IPVS 的一种调度算法之一，使用轮询方式分发请求到后端服务器，每个请求按顺序依次分发。
#
# ip_vs_wrr
# IPVS 的一种调度算法之一，使用加权轮询方式分发请求到后端服务器，每个请求按照指定的权重比例分发。
#
# ip_vs_sh
# IPVS 的一种调度算法之一，使用哈希方式根据源 IP 地址和目标 IP 地址来分发请求。
#
# nf_conntrack
# 这是一个内核模块，用于跟踪和管理网络连接，包括 TCP、UDP 和 ICMP 等协议。它是实现防火墙状态跟踪的基础。
#
# ip_tables
# 这是一个内核模块，提供了对 Linux 系统 IP 数据包过滤和网络地址转换（NAT）功能的支持。
#
# ip_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的 IP 地址集合操作。
#
# xt_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的数据包匹配和操作。
#
# ipt_set
# 这是一个用户空间工具，用于配置和管理 xt_set 内核模块。
#
# ipt_rpfilter
# 这是一个内核模块，用于实现反向路径过滤，用于防止 IP 欺骗和 DDoS 攻击。
#
# ipt_REJECT
# 这是一个 iptables 目标，用于拒绝 IP 数据包，并向发送方发送响应，指示数据包被拒绝。
#
# ipip
# 这是一个内核模块，用于实现 IP 封装在 IP（IP-over-IP）的隧道功能。它可以在不同网络之间创建虚拟隧道来传输 IP 数据包。
```

### 1.17.修改内核参数

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

# 这些是Linux系统的一些参数设置，用于配置和优化网络、文件系统和虚拟内存等方面的功能。以下是每个参数的详细解释：
# 
# 1. net.ipv4.ip_forward = 1
#    - 这个参数启用了IPv4的IP转发功能，允许服务器作为网络路由器转发数据包。
# 
# 2. net.bridge.bridge-nf-call-iptables = 1
#    - 当使用网络桥接技术时，将数据包传递到iptables进行处理。
#   
# 3. fs.may_detach_mounts = 1
#    - 允许在挂载文件系统时，允许被其他进程使用。
#   
# 4. vm.overcommit_memory=1
#    - 该设置允许原始的内存过量分配策略，当系统的内存已经被完全使用时，系统仍然会分配额外的内存。
# 
# 5. vm.panic_on_oom=0
#    - 当系统内存不足（OOM）时，禁用系统崩溃和重启。
# 
# 6. fs.inotify.max_user_watches=89100
#    - 设置系统允许一个用户的inotify实例可以监控的文件数目的上限。
# 
# 7. fs.file-max=52706963
#    - 设置系统同时打开的文件数的上限。
# 
# 8. fs.nr_open=52706963
#    - 设置系统同时打开的文件描述符数的上限。
# 
# 9. net.netfilter.nf_conntrack_max=2310720
#    - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 
# 10. net.ipv4.tcp_keepalive_time = 600
#     - 设置TCP套接字的空闲超时时间（秒），超过该时间没有活动数据时，内核会发送心跳包。
# 
# 11. net.ipv4.tcp_keepalive_probes = 3
#     - 设置未收到响应的TCP心跳探测次数。
# 
# 12. net.ipv4.tcp_keepalive_intvl = 15
#     - 设置TCP心跳探测的时间间隔（秒）。
# 
# 13. net.ipv4.tcp_max_tw_buckets = 36000
#     - 设置系统可以使用的TIME_WAIT套接字的最大数量。
# 
# 14. net.ipv4.tcp_tw_reuse = 1
#     - 启用TIME_WAIT套接字的重新利用，允许新的套接字使用旧的TIME_WAIT套接字。
# 
# 15. net.ipv4.tcp_max_orphans = 327680
#     - 设置系统可以同时存在的TCP套接字垃圾回收包裹数的最大数量。
# 
# 16. net.ipv4.tcp_orphan_retries = 3
#     - 设置系统对于孤立的TCP套接字的重试次数。
# 
# 17. net.ipv4.tcp_syncookies = 1
#     - 启用TCP SYN cookies保护，用于防止SYN洪泛攻击。
# 
# 18. net.ipv4.tcp_max_syn_backlog = 16384
#     - 设置新的TCP连接的半连接数（半连接队列）的最大长度。
# 
# 19. net.ipv4.ip_conntrack_max = 65536
#     - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 
# 20. net.ipv4.tcp_timestamps = 0
#     - 关闭TCP时间戳功能，用于提供更好的安全性。
# 
# 21. net.core.somaxconn = 16384
#     - 设置系统核心层的连接队列的最大值。
# 
# 22. net.ipv6.conf.all.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 23. net.ipv6.conf.default.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 24. net.ipv6.conf.lo.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 25. net.ipv6.conf.all.forwarding = 1
#     - 允许IPv6数据包转发。
```

### 1.18.所有节点配置hosts本地解析

```shell
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.31 k8s-master01
192.168.1.32 k8s-master02
192.168.1.33 k8s-master03
192.168.1.34 k8s-node01
192.168.1.35 k8s-node02
192.168.1.36 lb-vip

fc00::31 k8s-master01
fc00::32 k8s-master02
fc00::33 k8s-master03
fc00::34 k8s-node01
fc00::35 k8s-node02
EOF
```

# 2.k8s基本组件安装

**注意 ： 2.1 和 2.2 二选其一即可**

## 2.1.安装Containerd作为Runtime （推荐）

```shell
# https://github.com/containernetworking/plugins/releases/
# wget https://mirrors.chenby.cn/https://github.com/containernetworking/plugins/releases/download/v1.6.1/cni-plugins-linux-amd64-v1.6.1.tgz

cd cby/

#创建cni插件所需目录
mkdir -p /etc/cni/net.d /opt/cni/bin 
#解压cni二进制包
tar xf cni-plugins-linux-amd64-v*.tgz -C /opt/cni/bin/

# https://github.com/containerd/containerd/releases/
# wget https://mirrors.chenby.cn/https://github.com/containerd/containerd/releases/download/v2.0.1/containerd-2.0.1-linux-amd64.tar.gz

#解压
tar -xzf containerd-*-linux-amd64.tar.gz -C /usr/local/

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


# 参数解释：
#
# 这是一个用于启动containerd容器运行时的systemd unit文件。下面是对该文件不同部分的详细解释：
# 
# [Unit]
# Description=containerd container runtime
# 描述该unit的作用是作为containerd容器运行时。
# 
# Documentation=https://containerd.io
# 指向容器运行时的文档的URL。
# 
# After=network.target local-fs.target
# 定义了在哪些依赖项之后该unit应该被启动。在网络和本地文件系统加载完成后启动，确保了容器运行时在这些依赖项可用时才会启动。
# 
# [Service]
# ExecStartPre=-/sbin/modprobe overlay
# 在启动containerd之前执行的命令。这里的命令是尝试加载内核的overlay模块，如果失败则忽略错误继续执行下面的命令。
# 
# ExecStart=/usr/local/bin/containerd
# 实际执行的命令，用于启动containerd容器运行时。
# 
# Type=notify
# 指定服务的通知类型。这里使用notify类型，表示当服务就绪时会通过通知的方式告知systemd。
# 
# Delegate=yes
# 允许systemd对此服务进行重启和停止操作。
# 
# KillMode=process
# 在终止容器运行时时使用的kill模式。这里使用process模式，表示通过终止进程来停止容器运行时。
# 
# Restart=always
# 定义了当容器运行时终止后的重启策略。这里设置为always，表示无论何时终止容器运行时，都会自动重新启动。
# 
# RestartSec=5
# 在容器运行时终止后重新启动之前等待的秒数。
# 
# LimitNPROC=infinity
# 指定容器运行时可以使用的最大进程数量。这里设置为无限制。
# 
# LimitCORE=infinity
# 指定容器运行时可以使用的最大CPU核心数量。这里设置为无限制。
# 
# LimitNOFILE=infinity
# 指定容器运行时可以打开的最大文件数。这里设置为无限制。
# 
# TasksMax=infinity
# 指定容器运行时可以创建的最大任务数。这里设置为无限制。
# 
# OOMScoreAdjust=-999
# 指定容器运行时的OOM（Out-Of-Memory）分数调整值。负数值表示容器运行时的优先级较高。
# 
# [Install]
# WantedBy=multi-user.target
# 定义了服务的安装位置。这里指定为multi-user.target，表示将服务安装为多用户模式下的启动项。
```

### 2.1.1配置Containerd所需的模块

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# 参数解释：
#
# containerd是一个容器运行时，用于管理和运行容器。它支持多种不同的参数配置来自定义容器运行时的行为和功能。
# 
# 1. overlay：overlay是容器d默认使用的存储驱动，它提供了一种轻量级的、可堆叠的、逐层增量的文件系统。它通过在现有文件系统上叠加文件系统层来创建容器的文件系统视图。每个容器可以有自己的一组文件系统层，这些层可以共享基础镜像中的文件，并在容器内部进行修改。使用overlay可以有效地使用磁盘空间，并使容器更加轻量级。
# 
# 2. br_netfilter：br_netfilter是Linux内核提供的一个网络过滤器模块，用于在容器网络中进行网络过滤和NAT转发。当容器和主机之间的网络通信需要进行DNAT或者SNAT时，br_netfilter模块可以将IP地址进行转换。它还可以提供基于iptables规则的网络过滤功能，用于限制容器之间或容器与外部网络之间的通信。
# 
# 这些参数可以在containerd的配置文件或者命令行中指定。例如，可以通过设置--storage-driver参数来选择使用overlay作为存储驱动，通过设置--iptables参数来启用或禁用br_netfilter模块。具体的使用方法和配置细节可以参考containerd的官方文档。
```

### 2.1.2加载模块

```shell
systemctl restart systemd-modules-load.service

# 参数解释：
# - `systemctl`: 是Linux系统管理服务的命令行工具，可以管理systemd init系统。
# - `restart`: 是systemctl命令的一个选项，用于重新启动服务。
# - `systemd-modules-load.service`: 是一个系统服务，用于加载内核模块。
# 
# 将上述参数结合在一起来解释`systemctl restart systemd-modules-load.service`的含义：
# 这个命令用于重新启动系统服务`systemd-modules-load.service`，它是负责加载内核模块的服务。在重新启动该服务后，系统会重新加载所有的内核模块。
```

### 2.1.3配置Containerd所需的内核

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核
sysctl --system

# 参数解释：
# 
# 这些参数是Linux操作系统中用于网络和网络桥接设置的参数。
# 
# - net.bridge.bridge-nf-call-iptables：这个参数控制网络桥接设备是否调用iptables规则处理网络数据包。当该参数设置为1时，网络数据包将被传递到iptables进行处理；当该参数设置为0时，网络数据包将绕过iptables直接传递。默认情况下，这个参数的值是1，即启用iptables规则处理网络数据包。
# 
# - net.ipv4.ip_forward：这个参数用于控制是否启用IP转发功能。IP转发使得操作系统可以将接收到的数据包从一个网络接口转发到另一个网络接口。当该参数设置为1时，启用IP转发功能；当该参数设置为0时，禁用IP转发功能。在网络环境中，通常需要启用IP转发功能来实现不同网络之间的通信。默认情况下，这个参数的值是0，即禁用IP转发功能。
# 
# - net.bridge.bridge-nf-call-ip6tables：这个参数与net.bridge.bridge-nf-call-iptables类似，但是它用于IPv6数据包的处理。当该参数设置为1时，IPv6数据包将被传递到ip6tables进行处理；当该参数设置为0时，IPv6数据包将绕过ip6tables直接传递。默认情况下，这个参数的值是1，即启用ip6tables规则处理IPv6数据包。
# 
# 这些参数的值可以通过修改操作系统的配置文件（通常是'/etc/sysctl.conf'）来进行设置。修改完成后，需要使用'sysctl -p'命令重载配置文件使参数生效。
```

### 2.1.4创建Containerd的配置文件

```shell
# 参数解释：
# 
# 这段代码是用于修改并配置containerd的参数。
# 
# 1. 首先使用命令`mkdir -p /etc/containerd`创建/etc/containerd目录，如果该目录已存在，则不进行任何操作。
# 2. 使用命令`containerd config default | tee /etc/containerd/config.toml`创建默认配置文件，并将输出同时传递给/etc/containerd/config.toml文件。
# 3. 使用sed命令修改/etc/containerd/config.toml文件，将SystemdCgroup参数的值从false改为true。-i参数表示直接在原文件中进行编辑。
# 4. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中SystemdCgroup参数的值是否已修改为true。
# 5. 使用sed命令修改/etc/containerd/config.toml文件，将registry.k8s.io的地址替换为m.daocloud.io/registry.k8s.io。-i参数表示直接在原文件中进行编辑。
# 6. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中sandbox_image参数的值是否已修改为m.daocloud.io/registry.k8s.io。
# 7. 使用sed命令修改/etc/containerd/config.toml文件，将config_path参数的值从""改为"/etc/containerd/certs.d"。-i参数表示直接在原文件中进行编辑。
# 8. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中certs.d参数的值是否已修改为/etc/containerd/certs.d。
# 9. 使用mkdir命令创建/etc/containerd/certs.d/docker.io目录，如果目录已存在，则不进行任何操作。-p参数表示创建目录时，如果父级目录不存在，则自动创建父级目录。
# 
# 最后，使用cat重定向操作符将内容写入/etc/containerd/certs.d/docker.io/hosts.toml文件。该文件会配置加速器，其中server参数设置为"https://docker.io"，host参数设置为"https://hub-mirror.c.163.com"，并添加capabilities参数。

# 创建默认配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 修改Containerd的配置文件

# sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
# cat /etc/containerd/config.toml | grep SystemdCgroup

# 沙箱pause镜像
sed -i "s#registry.k8s.io#registry.aliyuncs.com/chenby#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox

# 配置加速器
[root@k8s-master01 ~]# vim /etc/containerd/config.toml
[root@k8s-master01 ~]# cat /etc/containerd/config.toml | grep certs.d -C 5

    [plugins.'io.containerd.cri.v1.images'.pinned_images]
      sandbox = 'registry.aliyuncs.com/chenby/pause:3.10'

    [plugins.'io.containerd.cri.v1.images'.registry]
      config_path = '/etc/containerd/certs.d'

    [plugins.'io.containerd.cri.v1.images'.image_decryption]
      key_model = 'node'

  [plugins.'io.containerd.cri.v1.runtime']
[root@k8s-master01 ~]# 

mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://jockerhub.com"]
  capabilities = ["pull", "resolve"]
EOF

# 注意！
# SystemdCgroup参数是containerd中的一个配置参数，用于设置containerd在运行过程中使用的Cgroup（控制组）路径。Containerd使用SystemdCgroup参数来指定应该使用哪个Cgroup来跟踪和管理容器的资源使用。
# 
# Cgroup是Linux内核提供的一种资源隔离和管理机制，可以用于限制、分配和监控进程组的资源使用。使用Cgroup，可以将容器的资源限制和隔离，以防止容器之间的资源争用和不公平的竞争。
# 
# 通过设置SystemdCgroup参数，可以确保containerd能够找到正确的Cgroup路径，并正确地限制和隔离容器的资源使用，确保容器可以按照预期的方式运行。如果未正确设置SystemdCgroup参数，可能会导致容器无法正确地使用资源，或者无法保证资源的公平分配和隔离。
# 
# 总而言之，SystemdCgroup参数的作用是为了确保containerd能够正确地管理容器的资源使用，以实现资源的限制、隔离和公平分配。
```

### 2.1.5启动并设置为开机启动

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now containerd.service
# 启用并立即启动docker.service单元。docker.service是Docker守护进程的systemd服务单元。

systemctl stop containerd.service
# 停止运行中的docker.service单元，即停止Docker守护进程。

systemctl start containerd.service
# 启动docker.service单元，即启动Docker守护进程。

systemctl restart containerd.service
# 重启docker.service单元，即重新启动Docker守护进程。

systemctl status containerd.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 2.1.6配置crictl客户端连接的运行时位置

```shell
# https://github.com/kubernetes-sigs/cri-tools/releases/
# wget https://mirrors.chenby.cn/https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.32.0/crictl-v1.32.0-linux-amd64.tar.gz

#解压
tar xf crictl-v*-linux-amd64.tar.gz -C /usr/bin/
#生成配置文件
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

#测试
systemctl restart  containerd
crictl info

# 注意！
# 下面是参数`crictl`的详细解释
# 
# `crictl`是一个用于与容器运行时通信的命令行工具。它是容器运行时接口（CRI）工具的一个实现，可以对容器运行时进行管理和操作。
# 
# 1. `runtime-endpoint: unix:///run/containerd/containerd.sock`
# 指定容器运行时的终端套接字地址。在这个例子中，指定的地址是`unix:///run/containerd/containerd.sock`，这是一个Unix域套接字地址。
# 
# 2. `image-endpoint: unix:///run/containerd/containerd.sock`
# 指定容器镜像服务的终端套接字地址。在这个例子中，指定的地址是`unix:///run/containerd/containerd.sock`，这是一个Unix域套接字地址。
# 
# 3. `timeout: 10`
# 设置与容器运行时通信的超时时间，单位是秒。在这个例子中，超时时间被设置为10秒。
# 
# 4. `debug: false`
# 指定是否开启调式模式。在这个例子中，调式模式被设置为关闭，即`false`。如果设置为`true`，则会输出更详细的调试信息。
# 
# 这些参数可以根据需要进行修改，以便与容器运行时进行有效的通信和管理。
```

## 2.2 安装docker作为Runtime

### 2.2.1 解压docker程序

```shell
# 二进制包下载地址：https://download.docker.com/linux/static/stable/x86_64/
# wget https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/x86_64/docker-27.4.0.tgz

#解压
tar xf docker-*.tgz 
#拷贝二进制文件
cp docker/* /usr/bin/
```

### 2.2.2 创建containerd的service文件

```shell
#创建containerd的service文件,并且启动
cat >/etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

# 参数解释：
# 
# [Unit]
# - Description=containerd container runtime：指定服务的描述信息。
# - Documentation=https://containerd.io：指定服务的文档链接。
# - After=network.target local-fs.target：指定服务的启动顺序，在网络和本地文件系统启动之后再启动该服务。
# 
# [Service]
# - ExecStartPre=-/sbin/modprobe overlay：在启动服务之前执行的命令，使用`-`表示忽略错误。
# - ExecStart=/usr/bin/containerd：指定服务的启动命令。
# - Type=notify：指定服务的类型，`notify`表示服务会在启动完成后向systemd发送通知。
# - Delegate=yes：允许服务代理其他服务的应答，例如收到关机命令后终止其他服务。
# - KillMode=process：指定服务终止时的行为，`process`表示终止服务进程。
# - Restart=always：指定服务终止后是否自动重启，`always`表示总是自动重启。
# - RestartSec=5：指定服务重启的时间间隔，单位为秒。
# - LimitNPROC=infinity：限制服务的最大进程数，`infinity`表示没有限制。
# - LimitCORE=infinity：限制服务的最大核心数，`infinity`表示没有限制。
# - LimitNOFILE=1048576：限制服务的最大文件数，指定为1048576。
# - TasksMax=infinity：限制服务的最大任务数，`infinity`表示没有限制。
# - OOMScoreAdjust=-999：指定服务的OOM（Out of Memory）得分，负数表示降低被终止的概率。
# 
# [Install]
# - WantedBy=multi-user.target：指定服务的安装方式，`multi-user.target`表示该服务在多用户模式下安装。


# 设置开机自启
systemctl enable --now containerd.service
```

### 2.2.3 准备docker的service文件

```shell
#准备docker的service文件
cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service cri-docker.service docker.socket containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
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
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

# 参数解释：
# 
# [Unit]
# - Description: 描述服务的作用，这里是Docker Application Container Engine，即Docker应用容器引擎。
# - Documentation: 提供关于此服务的文档链接，这里是Docker官方文档链接。
# - After: 说明该服务在哪些其他服务之后启动，这里是在网络在线、firewalld服务和containerd服务后启动。
# - Wants: 说明该服务想要的其他服务，这里是网络在线服务。
# - Requires: 说明该服务需要的其他服务，这里是docker.socket和containerd.service。
# 
# [Service]
# - Type: 服务类型，这里是notify，表示服务在启动完成时发送通知。
# - ExecStart: 命令，启动该服务时会执行的命令，这里是/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock，即启动dockerd并指定一些参数，其中-H指定dockerd的监听地址为fd://，--containerd指定containerd的sock文件位置。
# - ExecReload: 重载命令，当接收到HUP信号时执行的命令，这里是/bin/kill -s HUP $MAINPID，即发送HUP信号给主进程ID。
# - TimeoutSec: 服务超时时间，这里是0，表示没有超时限制。
# - RestartSec: 重启间隔时间，这里是2秒，表示重启失败后等待2秒再重启。
# - Restart: 重启策略，这里是always，表示总是重启。
# - StartLimitBurst: 启动限制次数，这里是3，表示在启动失败后最多重试3次。
# - StartLimitInterval: 启动限制时间间隔，这里是60秒，表示两次启动之间最少间隔60秒。
# - LimitNOFILE: 文件描述符限制，这里是infinity，表示没有限制。
# - LimitNPROC: 进程数限制，这里是infinity，表示没有限制。
# - LimitCORE: 核心转储限制，这里是infinity，表示没有限制。
# - TasksMax: 最大任务数，这里是infinity，表示没有限制。
# - Delegate: 修改权限，这里是yes，表示启用权限修改。
# - KillMode: 杀死模式，这里是process，表示杀死整个进程组。
# - OOMScoreAdjust: 用于调整进程在系统内存紧张时的优先级调整，这里是-500，表示将OOM分数降低500。
# 
# [Install]
# - WantedBy: 安装目标，这里是multi-user.target，表示在多用户模式下安装。
#      在WantedBy参数中，我们可以使用以下参数：
#      1. multi-user.target：指定该服务应该在多用户模式下启动。
#      2. graphical.target：指定该服务应该在图形化界面模式下启动。
#      3. default.target：指定该服务应该在系统的默认目标（runlevel）下启动。
#      4. rescue.target：指定该服务应该在系统救援模式下启动。
#      5. poweroff.target：指定该服务应该在关机时启动。
#      6. reboot.target：指定该服务应该在重启时启动。
#      7. halt.target：指定该服务应该在停止时启动。
#      8. shutdown.target：指定该服务应该在系统关闭时启动。
#      这些参数可以根据需要选择一个或多个，以告知系统在何时启动该服务。
```

### 2.2.4 准备docker的socket文件

```shell
#准备docker的socket文件
cat > /etc/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

# 这是一个用于Docker API的socket配置文件，包含了以下参数：
# 
# [Unit]
# - Description：描述了该socket的作用，即为Docker API的socket。
# 
# [Socket]
# - ListenStream：指定了socket的监听地址，该socket会监听在/var/run/docker.sock上，即Docker守护程序使用的默认sock文件。
# - SocketMode：指定了socket文件的权限模式，此处为0660，即用户和用户组有读写权限，其他用户无权限。
# - SocketUser：指定了socket文件的所有者，此处为root用户。
# - SocketGroup：指定了socket文件的所属用户组，此处为docker用户组。
# 
# [Install]
# - WantedBy：指定了该socket被启用时的目标，此处为sockets.target，表示当sockets.target启动时启用该socket。
# 
# 该配置文件的作用是为Docker提供API访问的通道，它监听在/var/run/docker.sock上，具有root用户权限，但只接受docker用户组的成员的连接，并且其他用户无法访问。这样，只有docker用户组的成员可以通过该socket与Docker守护进程进行通信。
```

### 2.2.5 配置加速器

```shell
# 配置加速器
mkdir /etc/docker/ -pv
cat >/etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://jockerhub.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}
EOF


# 该参数文件中包含以下参数：
# 
# 1. exec-opts: 用于设置Docker守护进程的选项，native.cgroupdriver=systemd表示使用systemd作为Cgroup驱动程序。
# 2. registry-mirrors: 用于指定Docker镜像的镜像注册服务器。在这里有三个镜像注册服务器：https://docker.m.daocloud.io、https://docker.mirrors.ustc.edu.cn和http://hub-mirror.c.163.com。
# 3. max-concurrent-downloads: 用于设置同时下载镜像的最大数量，默认值为3，这里设置为10。
# 4. log-driver: 用于设置Docker守护进程的日志驱动程序，这里设置为json-file。
# 5. log-level: 用于设置日志的级别，这里设置为warn。
# 6. log-opts: 用于设置日志驱动程序的选项，这里有两个选项：max-size和max-file。max-size表示每个日志文件的最大大小，这里设置为10m，max-file表示保存的最大日志文件数量，这里设置为3。
# 7. data-root: 用于设置Docker守护进程的数据存储根目录，默认为/var/lib/docker，这里设置为/var/lib/docker。
```

### 2.2.6 启动docker

```shell
groupadd docker
#创建docker组

systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now docker.socket
# 启用并立即启动docker.socket单元。docker.socket是一个systemd的socket单元，用于接收来自网络的Docker API请求。

systemctl enable --now docker.service
# 启用并立即启动docker.service单元。docker.service是Docker守护进程的systemd服务单元。

systemctl stop docker.service
# 停止运行中的docker.service单元，即停止Docker守护进程。

systemctl start docker.service
# 启动docker.service单元，即启动Docker守护进程。

systemctl restart docker.service
# 重启docker.service单元，即重新启动Docker守护进程。

systemctl status docker.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。

docker info
#验证
```

### 2.2.7 解压cri-docker

```shell
# 由于1.24以及更高版本不支持docker所以安装cri-docker
# 下载cri-docker 
# https://github.com/Mirantis/cri-dockerd/releases/
# wget  https://mirrors.chenby.cn/https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz

# 解压cri-docker
tar xvf cri-dockerd-*.amd64.tgz 
cp -r cri-dockerd/  /usr/bin/
chmod +x /usr/bin/cri-dockerd/cri-dockerd
```

### 2.2.8 写入启动cri-docker配置文件

```shell
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
ExecStart=/usr/bin/cri-dockerd/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
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


# [Unit]
# - Description：该参数用于描述该单元的功能，这里描述的是CRI与Docker应用容器引擎的接口。
# - Documentation：该参数指定了相关文档的网址，供用户参考。
# - After：该参数指定了此单元应该在哪些其他单元之后启动，确保在网络在线、防火墙和Docker服务启动之后再启动此单元。
# - Wants：该参数指定了此单元希望也启动的所有单元，此处是希望在网络在线之后启动。
# - Requires：该参数指定了此单元需要依赖的单元，此处是cri-docker.socket单元。
# 
# [Service]
# - Type：该参数指定了服务的类型，这里是notify，表示当服务启动完成时向系统发送通知。
# - ExecStart：该参数指定了将要运行的命令和参数，此处是执行/usr/bin/cri-dockerd/cri-dockerd命令，并指定了网络插件为cni和Pod基础设施容器的镜像为registry.aliyuncs.com/google_containers/pause:3.7。
# - ExecReload：该参数指定在服务重载时运行的命令，此处是发送HUP信号给主进程。
# - TimeoutSec：该参数指定了服务启动的超时时间，此处为0，表示无限制。
# - RestartSec：该参数指定了自动重启服务的时间间隔，此处为2秒。
# - Restart：该参数指定了在服务发生错误时自动重启，此处是始终重启。
# - StartLimitBurst：该参数指定了在给定时间间隔内允许的启动失败次数，此处为3次。
# - StartLimitInterval：该参数指定启动失败的时间间隔，此处为60秒。
# - LimitNOFILE：该参数指定了允许打开文件的最大数量，此处为无限制。
# - LimitNPROC：该参数指定了允许同时运行的最大进程数，此处为无限制。
# - LimitCORE：该参数指定了允许生成的core文件的最大大小，此处为无限制。
# - TasksMax：该参数指定了此服务的最大任务数，此处为无限制。
# - Delegate：该参数指定了是否将控制权委托给指定服务，此处为是。
# - KillMode：该参数指定了在终止服务时如何处理进程，此处是通过终止进程来终止服务。
# 
# [Install]
# - WantedBy：该参数指定了希望这个单元启动的多用户目标。在这里，这个单元希望在multi-user.target启动。
```

### 2.2.9 写入cri-docker的socket配置文件

```shell
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


# 该配置文件是用于systemd的单元配置文件(unit file)，用于定义一个socket单元。
# 
# [Unit]
# - Description：表示该单元的描述信息。
# - PartOf：表示该单元是cri-docker.service的一部分。
# 
# [Socket]
# - ListenStream：指定了该socket要监听的地址和端口，这里使用了%t占位符，表示根据单元的类型来决定路径。%t/cri-dockerd.sock表示将监听Unix域套接字cri-dockerd.sock。Unix域套接字用于在同一台主机上的进程之间通信。
# - SocketMode：指定了socket文件的权限模式，此处为0660，即用户和用户组有读写权限，其他用户无权限。
# - SocketUser：指定了socket文件的所有者，此处为root用户。
# - SocketGroup：指定了socket文件的所属用户组，此处为docker用户组。
# 
# [Install]
# - WantedBy：部分定义了该单元的安装配置信息。WantedBy=sockets.target表示当sockets.target单元启动时，自动启动该socket单元。sockets.target是一个系统服务，用于管理所有的socket单元。
```

### 2.2.10 启动cri-docker

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now cri-docker.service
# 启用并立即启动cri-docker.service单元。cri-docker.service是cri-docker守护进程的systemd服务单元。

systemctl restart cri-docker.service
# 重启cri-docker.service单元，即重新启动cri-docker守护进程。

systemctl status docker.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。
```

## 2.3.k8s与etcd下载及安装（仅在master01操作）

### 2.3.1解压k8s安装包

```shell
# 下载安装包
# https://github.com/etcd-io/etcd/releases/
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG
# 
# wget https://mirrors.chenby.cn/https://github.com/etcd-io/etcd/releases/download/v3.5.17/etcd-v3.5.17-linux-amd64.tar.gz
# wget https://cdn.dl.k8s.io/release/v1.32.0/kubernetes-server-linux-amd64.tar.gz

# 解压k8s安装文件
cd cby
tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

# 这是一个tar命令，用于解压指定的kubernetes-server-linux-amd64.tar.gz文件，并将其中的特定文件提取到/usr/local/bin目录下。
# 
# 命令的解释如下：
# - tar：用于处理tar压缩文件的命令。
# - -xf：表示解压操作。
# - kubernetes-server-linux-amd64.tar.gz：要解压的文件名。
# - --strip-components=3：表示解压时忽略压缩文件中的前3级目录结构，提取文件时直接放到目标目录中。
# - -C /usr/local/bin：指定提取文件的目标目录为/usr/local/bin。
# - kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}：要解压和提取的文件名模式，用花括号括起来表示模式中的多个可能的文件名。
# 
# 总的来说，这个命令的作用是将kubernetes-server-linux-amd64.tar.gz文件中的kubelet、kubectl、kube-apiserver、kube-controller-manager、kube-scheduler和kube-proxy六个文件提取到/usr/local/bin目录下，同时忽略文件路径中的前三级目录结构。


# 解压etcd安装文件
tar -xf etcd*.tar.gz && mv etcd-*/etcd /usr/local/bin/ && mv etcd-*/etcdctl /usr/local/bin/

# 这是一个将文件解压并移动到特定目录的命令。这是一个用于 Linux 系统中的命令。
# 
# - tar -xf etcd*.tar.gz：这个命令将解压以 etcd 开头并以.tar.gz 结尾的文件。`-xf` 是使用 `tar` 命令的选项，它表示解压文件并展开其中的内容。
# - mv etcd-*/etcd /usr/local/bin/：这个命令将 etcd 文件移动到 /usr/local/bin 目录。`mv` 是移动命令，它将 etcd-*/etcd 路径下的 etcd 文件移动到了 /usr/local/bin 目录。
# - mv etcd-*/etcdctl /usr/local/bin/：这个命令将 etcdctl 文件移动到 /usr/local/bin 目录，和上一条命令类似。
# 
# 总结起来，以上命令将从名为 etcd*.tar.gz 的压缩文件中解压出 etcd 和 etcdctl 文件，并将它们移动到 /usr/local/bin 目录中。

# 查看/usr/local/bin下内容
ll /usr/local/bin/
总用量 581544
-rwxr-xr-x 1 root root 55953192 12月 14 07:57 containerd
-rwxr-xr-x 1 root root  7725208 12月 14 07:57 containerd-shim-runc-v2
-rwxr-xr-x 1 root root 21463361 12月 14 07:57 containerd-stress
-rwxr-xr-x 1 root root 22196545 12月 14 07:57 ctr
-rwxr-xr-x 1 1000 1000 23625880 11月 13 00:32 etcd
-rwxr-xr-x 1 1000 1000 17899672 11月 13 00:32 etcdctl
-rwxr-xr-x 1 root root 93237400 12月 12 02:15 kube-apiserver
-rwxr-xr-x 1 root root 85975192 12月 12 02:15 kube-controller-manager
-rwxr-xr-x 1 root root 57323672 12月 12 02:15 kubectl
-rwxr-xr-x 1 root root 77398276 12月 12 02:15 kubelet
-rwxr-xr-x 1 root root 66822296 12月 12 02:15 kube-proxy
-rwxr-xr-x 1 root root 65835160 12月 12 02:15 kube-scheduler
```

### 2.3.2查看版本

```shell
[root@k8s-master01 ~]#  kubelet --version
Kubernetes v1.32.0
[root@k8s-master01 ~]# etcdctl version
etcdctl version: 3.5.17
API version: 3.5
[root@k8s-master01 ~]# 
```

### 2.3.3将组件发送至其他k8s节点

```shell
Master='k8s-master02 k8s-master03'
Work='k8s-node01 k8s-node02'

# 拷贝master组件
for NODE in $Master; do echo $NODE; scp /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} $NODE:/usr/local/bin/; scp /usr/local/bin/etcd* $NODE:/usr/local/bin/; done

# 该命令是一个for循环，对于在$Master变量中的每个节点，执行以下操作：
# 
# 1. 打印出节点的名称。
# 2. 使用scp命令将/usr/local/bin/kubelet、kubectl、kube-apiserver、kube-controller-manager、kube-scheduler和kube-proxy文件复制到节点的/usr/local/bin/目录下。
# 3. 使用scp命令将/usr/local/bin/etcd*文件复制到节点的/usr/local/bin/目录下。


# 拷贝work组件
for NODE in $Work; do echo $NODE; scp /usr/local/bin/kube{let,-proxy} $NODE:/usr/local/bin/ ; done
# 该命令是一个for循环，对于在$Master变量中的每个节点，执行以下操作：
# 
# 1. 打印出节点的名称。
# 2. 使用scp命令将/usr/local/bin/kubelet和kube-proxy文件复制到节点的/usr/local/bin/目录下。

# 所有节点执行
mkdir -p /opt/cni/bin
```

## 2.3创建证书相关文件

```shell
# 请查看Github仓库 或者进行获取已经打好的包
# 可以根据下文3.x进行手动部署操作 
https://github.com/cby-chen/Kubernetes/
https://github.com/cby-chen/Kubernetes/tags
https://github.com/cby-chen/Kubernetes/releases/download/v1.32.0/kubernetes-v1.32.0.tar
```

# 3.相关证书生成

```shell
# master01节点下载证书生成工具
# wget "https://mirrors.chenby.cn/https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64" -O /usr/local/bin/cfssl
# wget "https://mirrors.chenby.cn/https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64" -O /usr/local/bin/cfssljson

# 软件包内有
cp cfssl_*_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_*_linux_amd64 /usr/local/bin/cfssljson

# 添加执行权限
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
```

## 3.1.生成etcd证书

特别说明除外，以下操作在所有master节点操作

### 3.1.1所有master节点创建证书存放目录

```shell
mkdir /etc/etcd/ssl -p
```

### 3.1.2master01节点生成etcd证书

```shell
# 写入生成证书所需的配置文件
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
# 这段配置文件是用于配置加密和认证签名的一些参数。
# 
# 在这里，有两个部分：`signing`和`profiles`。
# 
# `signing`包含了默认签名配置和配置文件。
# 默认签名配置`default`指定了证书的过期时间为`876000h`。`876000h`表示证书有效期为100年。
# 
# `profiles`部分定义了不同的证书配置文件。
# 在这里，只有一个配置文件`kubernetes`。它包含了以下`usages`和过期时间`expiry`：
# 
# 1. `signing`：用于对其他证书进行签名
# 2. `key encipherment`：用于加密和解密传输数据
# 3. `server auth`：用于服务器身份验证
# 4. `client auth`：用于客户端身份验证
# 
# 对于`kubernetes`配置文件，证书的过期时间也是`876000h`，即100年。

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
# 这是一个用于生成证书签名请求（Certificate Signing Request，CSR）的JSON配置文件。JSON配置文件指定了生成证书签名请求所需的数据。
# 
# - "CN": "etcd" 指定了希望生成的证书的CN字段（Common Name），即证书的主题，通常是该证书标识的实体的名称。
# - "key": {} 指定了生成证书所使用的密钥的配置信息。"algo": "rsa" 指定了密钥的算法为RSA，"size": 2048 指定了密钥的长度为2048位。
# - "names": [] 包含了生成证书时所需的实体信息。在这个例子中，只包含了一个实体，其相关信息如下：
#   - "C": "CN" 指定了实体的国家/地区代码，这里是中国。
#   - "ST": "Beijing" 指定了实体所在的省/州。
#   - "L": "Beijing" 指定了实体所在的城市。
#   - "O": "etcd" 指定了实体的组织名称。
#   - "OU": "Etcd Security" 指定了实体所属的组织单位。
# - "ca": {} 指定了生成证书时所需的CA（Certificate Authority）配置信息。
#   - "expiry": "876000h" 指定了证书的有效期，这里是876000小时。
# 
# 生成证书签名请求时，可以使用这个JSON配置文件作为输入，根据配置文件中的信息生成相应的CSR文件。然后，可以将CSR文件发送给CA进行签名，以获得有效的证书。

# 生成etcd证书和etcd证书的key（如果你觉得以后可能会扩容，可以在ip那多写几个预留出来）
# 若没有IPv6 可删除可保留 

cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca
# 具体的解释如下：
# 
# cfssl是一个用于生成TLS/SSL证书的工具，它支持PKI、JSON格式配置文件以及与许多其他集成工具的配合使用。
# 
# gencert参数表示生成证书的操作。-initca参数表示初始化一个CA（证书颁发机构）。CA是用于签发其他证书的根证书。etcd-ca-csr.json是一个JSON格式的配置文件，其中包含了CA的详细信息，如私钥、公钥、有效期等。这个文件提供了生成CA证书所需的信息。
# 
# | 符号表示将上一个命令的输出作为下一个命令的输入。
# 
# cfssljson是cfssl工具的一个子命令，用于格式化cfssl生成的JSON数据。 -bare参数表示直接输出裸证书，即只生成证书文件，不包含其他格式的文件。/etc/etcd/ssl/etcd-ca是指定生成的证书文件的路径和名称。
# 
# 所以，这条命令的含义是使用cfssl工具根据配置文件ca-csr.json生成一个CA证书，并将证书文件保存在/etc/etcd/ssl/etcd-ca路径下。

cat > etcd-csr.json << EOF 
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
  ]
}
EOF
# 这段代码是一个JSON格式的配置文件，用于生成一个证书签名请求（Certificate Signing Request，CSR）。
# 
# 首先，"CN"字段指定了该证书的通用名称（Common Name），这里设为"etcd"。
# 
# 接下来，"key"字段指定了密钥的算法（"algo"字段）和长度（"size"字段），此处使用的是RSA算法，密钥长度为2048位。
# 
# 最后，"names"字段是一个数组，其中包含了一个名字对象，用于指定证书中的一些其他信息。这个名字对象包含了以下字段：
# - "C"字段指定了国家代码（Country），这里设置为"CN"。
# - "ST"字段指定了省份（State）或地区，这里设置为"Beijing"。
# - "L"字段指定了城市（Locality），这里设置为"Beijing"。
# - "O"字段指定了组织（Organization），这里设置为"etcd"。
# - "OU"字段指定了组织单元（Organizational Unit），这里设置为"Etcd Security"。
# 
# 这些字段将作为证书的一部分，用于标识和验证证书的使用范围和颁发者等信息。

cfssl gencert \
   -ca=/etc/etcd/ssl/etcd-ca.pem \
   -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,192.168.1.31,192.168.1.32,192.168.1.33,::1 \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd
# 这是一条使用cfssl生成etcd证书的命令，下面是各个参数的解释：
# 
# -ca=/etc/etcd/ssl/etcd-ca.pem：指定用于签名etcd证书的CA文件的路径。
# -ca-key=/etc/etcd/ssl/etcd-ca-key.pem：指定用于签名etcd证书的CA私钥文件的路径。
# -config=ca-config.json：指定CA配置文件的路径，该文件定义了证书的有效期、加密算法等设置。
# -hostname=xxxx：指定要为etcd生成证书的主机名和IP地址列表。
# -profile=kubernetes：指定使用的证书配置文件，该文件定义了证书的用途和扩展属性。
# etcd-csr.json：指定etcd证书请求的JSON文件的路径，该文件包含了证书请求的详细信息。
# | cfssljson -bare /etc/etcd/ssl/etcd：通过管道将cfssl命令的输出传递给cfssljson命令，并使用-bare参数指定输出文件的前缀路径，这里将生成etcd证书的.pem和-key.pem文件。
# 
# 这条命令的作用是使用指定的CA证书和私钥，根据证书请求的JSON文件和配置文件生成etcd的证书文件。
```

### 3.1.3将证书复制到其他节点

```shell
Master='k8s-master02 k8s-master03'
for NODE in $Master; do ssh $NODE "mkdir -p /etc/etcd/ssl"; for FILE in etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pem; do scp /etc/etcd/ssl/${FILE} $NODE:/etc/etcd/ssl/${FILE}; done; done

# 这个命令是一个简单的for循环，在一个由`$Master`存储的主机列表中迭代执行。对于每个主机，它使用`ssh`命令登录到主机，并在远程主机上创建一个名为`/etc/etcd/ssl`的目录（如果不存在）。接下来，它使用`scp`将本地主机上`/etc/etcd/ssl`目录中的四个文件（`etcd-ca-key.pem`，`etcd-ca.pem`，`etcd-key.pem`和`etcd.pem`）复制到远程主机的`/etc/etcd/ssl`目录中。最终的结果是，远程主机上的`/etc/etcd/ssl`目录中包含与本地主机上相同的四个文件的副本。
```

## 3.2.生成k8s相关证书

特别说明除外，以下操作在所有master节点操作

### 3.2.1 所有k8s节点创建证书存放目录

```shell
mkdir -p /etc/kubernetes/pki
```

### 3.2.2 master01节点生成k8s证书

```shell
# 写入生成证书所需的配置文件
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
# 这是一个用于生成 Kubernetes 相关证书的配置文件。该配置文件中包含以下信息：
# 
# - CN：CommonName，即用于标识证书的通用名称。在此配置中，CN 设置为 "kubernetes"，表示该证书是用于 Kubernetes。
# - key：用于生成证书的算法和大小。在此配置中，使用的算法是 RSA，大小是 2048 位。
# - names：用于证书中的名称字段的详细信息。在此配置中，有以下字段信息：
#   - C：Country，即国家。在此配置中，设置为 "CN"。
#   - ST：State，即省/州。在此配置中，设置为 "Beijing"。
#   - L：Locality，即城市。在此配置中，设置为 "Beijing"。
#   - O：Organization，即组织。在此配置中，设置为 "Kubernetes"。
#   - OU：Organization Unit，即组织单位。在此配置中，设置为 "Kubernetes-manual"。
# - ca：用于证书签名的证书颁发机构（CA）的配置信息。在此配置中，设置了证书的有效期为 876000 小时。
# 
# 这个配置文件可以用于生成 Kubernetes 相关的证书，以确保集群中的通信安全性。

cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca

# 具体的解释如下：
# 
# cfssl是一个用于生成TLS/SSL证书的工具，它支持PKI、JSON格式配置文件以及与许多其他集成工具的配合使用。
# 
# gencert参数表示生成证书的操作。-initca参数表示初始化一个CA（证书颁发机构）。CA是用于签发其他证书的根证书。ca-csr.json是一个JSON格式的配置文件，其中包含了CA的详细信息，如私钥、公钥、有效期等。这个文件提供了生成CA证书所需的信息。
# 
# | 符号表示将上一个命令的输出作为下一个命令的输入。
# 
# cfssljson是cfssl工具的一个子命令，用于格式化cfssl生成的JSON数据。 -bare参数表示直接输出裸证书，即只生成证书文件，不包含其他格式的文件。/etc/kubernetes/pki/ca是指定生成的证书文件的路径和名称。
# 
# 所以，这条命令的含义是使用cfssl工具根据配置文件ca-csr.json生成一个CA证书，并将证书文件保存在/etc/kubernetes/pki/ca路径下。

cat > apiserver-csr.json << EOF 
{
  "CN": "kube-apiserver",
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

# 这是一个用于生成 Kubernetes 相关证书的配置文件。该配置文件中包含以下信息：
# 
# - `CN` 字段指定了证书的通用名称 (Common Name)，这里设置为 "kube-apiserver"，表示该证书用于 Kubernetes API Server。
# - `key` 字段指定了生成证书时所选用的加密算法和密钥长度。这里选用了 RSA 算法，密钥长度为 2048 位。
# - `names` 字段包含了一组有关证书持有者信息的项。这里使用了以下信息：
#   - `C` 表示国家代码 (Country)，这里设置为 "CN" 表示中国。
#   - `ST` 表示州或省份 (State)，这里设置为 "Beijing" 表示北京市。
#   - `L` 表示城市或地区 (Location)，这里设置为 "Beijing" 表示北京市。
#   - `O` 表示组织名称 (Organization)，这里设置为 "Kubernetes" 表示 Kubernetes。
#   - `OU` 表示组织单位 (Organizational Unit)，这里设置为 "Kubernetes-manual" 表示手动管理的 Kubernetes 集群。
# 
# 这个配置文件可以用于生成 Kubernetes 相关的证书，以确保集群中的通信安全性。


# 生成一个根证书 ，多写了一些IP作为预留IP，为将来添加node做准备
# 10.96.0.1是service网段的第一个地址，需要计算，192.168.1.36为高可用vip地址
# 若没有IPv6 可删除可保留 

cfssl gencert   \
-ca=/etc/kubernetes/pki/ca.pem   \
-ca-key=/etc/kubernetes/pki/ca-key.pem   \
-config=ca-config.json   \
-hostname=10.96.0.1,192.168.1.36,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,x.oiox.cn,z.oiox.cn,192.168.1.31,192.168.1.32,192.168.1.33,192.168.1.34,192.168.1.35,192.168.1.36,192.168.1.37,192.168.1.38,192.168.1.39,192.168.1.40,::1   \
-profile=kubernetes   apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver

# 这个命令是使用cfssl工具生成Kubernetes API Server的证书。
# 
# 命令的参数解释如下：
# - `-ca=/etc/kubernetes/pki/ca.pem`：指定证书的颁发机构（CA）文件路径。
# - `-ca-key=/etc/kubernetes/pki/ca-key.pem`：指定证书的颁发机构（CA）私钥文件路径。
# - `-config=ca-config.json`：指定证书生成的配置文件路径，配置文件中包含了证书的有效期、加密算法等信息。
# - `-hostname=10.96.0.1,192.168.1.36,127.0.0.1,fc00:43f4:1eea:1::10`：指定证书的主机名或IP地址列表。
# - `-profile=kubernetes`：指定证书生成的配置文件中的配置文件名。
# - `apiserver-csr.json`：API Server的证书签名请求配置文件路径。
# - `| cfssljson -bare /etc/kubernetes/pki/apiserver`：通过管道将生成的证书输出到cfssljson工具，将其转换为PEM编码格式，并保存到 `/etc/kubernetes/pki/apiserver.pem` 和 `/etc/kubernetes/pki/apiserver-key.pem` 文件中。
# 
# 最终，这个命令将会生成API Server的证书和私钥，并保存到指定的文件中。
```

### 3.2.3 生成apiserver聚合证书

```shell
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

# 这个JSON文件表示了生成一个名为"kubernetes"的证书的配置信息。这个证书是用来进行Kubernetes集群的身份验证和安全通信。
# 
# 配置信息包括以下几个部分：
# 
# 1. "CN": "kubernetes"：这表示了证书的通用名称（Common Name），也就是证书所代表的实体的名称。在这里，证书的通用名称被设置为"kubernetes"，表示这个证书是用来代表Kubernetes集群。
# 
# 2. "key"：这是用来生成证书的密钥相关的配置。在这里，配置使用了RSA算法，并且设置了密钥的大小为2048位。
# 
# 3. "ca"：这个字段指定了证书的颁发机构（Certificate Authority）相关的配置。在这里，配置指定了证书的有效期为876000小时，即100年。这意味着该证书在100年内将被视为有效，过期后需要重新生成。
# 
# 总之，这个JSON文件中的配置信息描述了如何生成一个用于Kubernetes集群的证书，包括证书的通用名称、密钥算法和大小以及证书的有效期。

cfssl gencert   -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca 
# 具体的解释如下：
# 
# cfssl是一个用于生成TLS/SSL证书的工具，它支持PKI、JSON格式配置文件以及与许多其他集成工具的配合使用。
# 
# gencert参数表示生成证书的操作。-initca参数表示初始化一个CA（证书颁发机构）。CA是用于签发其他证书的根证书。front-proxy-ca-csr.json是一个JSON格式的配置文件，其中包含了CA的详细信息，如私钥、公钥、有效期等。这个文件提供了生成CA证书所需的信息。
# 
# | 符号表示将上一个命令的输出作为下一个命令的输入。
# 
# cfssljson是cfssl工具的一个子命令，用于格式化cfssl生成的JSON数据。 -bare参数表示直接输出裸证书，即只生成证书文件，不包含其他格式的文件。/etc/kubernetes/pki/front-proxy-ca是指定生成的证书文件的路径和名称。
# 
# 所以，这条命令的含义是使用cfssl工具根据配置文件ca-csr.json生成一个CA证书，并将证书文件保存在/etc/kubernetes/pki/front-proxy-ca路径下。

cat > front-proxy-client-csr.json  << EOF 
{
  "CN": "front-proxy-client",
  "key": {
     "algo": "rsa",
     "size": 2048
  }
}
EOF

# 这是一个JSON格式的配置文件，用于描述一个名为"front-proxy-client"的配置。配置包括两个字段：CN和key。
# 
# - CN（Common Name）字段表示证书的通用名称，这里为"front-proxy-client"。
# - key字段描述了密钥的算法和大小。"algo"表示使用RSA算法，"size"表示密钥大小为2048位。
# 
# 该配置文件用于生成一个SSL证书，用于在前端代理客户端进行认证和数据传输的加密。这个证书中的通用名称是"front-proxy-client"，使用RSA算法生成，密钥大小为2048位。

cfssl gencert  \
-ca=/etc/kubernetes/pki/front-proxy-ca.pem   \
-ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem   \
-config=ca-config.json   \
-profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client

# 这个命令使用cfssl工具生成一个用于Kubernetes的front-proxy-client证书。
# 
# 主要参数解释如下：
# - `-ca=/etc/kubernetes/pki/front-proxy-ca.pem`: 指定用于签署证书的根证书文件路径。
# - `-ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem`: 指定用于签署证书的根证书的私钥文件路径。
# - `-config=ca-config.json`: 指定用于配置证书签署的配置文件路径。该配置文件描述了证书生成的一些规则，如加密算法和有效期等。
# - `-profile=kubernetes`: 指定生成证书时使用的配置文件中定义的profile，其中包含了一些默认的参数。
# - `front-proxy-client-csr.json`: 指定用于生成证书的CSR文件路径，该文件包含了证书请求的相关信息。
# - `| cfssljson -bare /etc/kubernetes/pki/front-proxy-client`: 通过管道将生成的证书输出到cfssljson工具进行解析，并通过`-bare`参数将证书和私钥分别保存到指定路径。
# 
# 这个命令的作用是根据提供的CSR文件和配置信息，使用指定的根证书和私钥生成一个前端代理客户端的证书，并将证书和私钥分别保存到`/etc/kubernetes/pki/front-proxy-client.pem`和`/etc/kubernetes/pki/front-proxy-client-key.pem`文件中。
```

### 3.2.4 生成controller-manage的证书

在《5.高可用配置》选择使用那种高可用方案  
若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`​  
若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`​

```shell
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
# 这是一个用于生成密钥对（公钥和私钥）的JSON配置文件。下面是针对该文件中每个字段的详细解释：
# 
# - "CN": 值为"system:kube-controller-manager"，代表通用名称（Common Name），是此密钥对的主题（subject）。
# - "key": 这个字段用来定义密钥算法和大小。
#   - "algo": 值为"rsa"，表示使用RSA算法。
#   - "size": 值为2048，表示生成的密钥大小为2048位。
# - "names": 这个字段用来定义密钥对的各个名称字段。
#   - "C": 值为"CN"，表示国家（Country）名称是"CN"（中国）。
#   - "ST": 值为"Beijing"，表示省/州（State/Province）名称是"Beijing"（北京）。
#   - "L": 值为"Beijing"，表示城市（Locality）名称是"Beijing"（北京）。
#   - "O": 值为"system:kube-controller-manager"，表示组织（Organization）名称是"system:kube-controller-manager"。
#   - "OU": 值为"Kubernetes-manual"，表示组织单位（Organizational Unit）名称是"Kubernetes-manual"。
# 
# 这个JSON配置文件基本上是告诉生成密钥对的工具，生成一个带有特定名称和属性的密钥对。


cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager

# 这是一个命令行操作，使用cfssl工具生成证书。
# 
# 1. `cfssl gencert` 是cfssl工具的命令，用于生成证书。
# 2. `-ca` 指定根证书的路径和文件名，这里是`/etc/kubernetes/pki/ca.pem`。
# 3. `-ca-key` 指定根证书的私钥的路径和文件名，这里是`/etc/kubernetes/pki/ca-key.pem`。
# 4. `-config` 指定配置文件的路径和文件名，这里是`ca-config.json`。
# 5. `-profile` 指定证书使用的配置文件中的配置模板，这里是`kubernetes`。
# 6. `manager-csr.json` 是证书签发请求的配置文件，用于生成证书签发请求。
# 7. `|` 管道操作符，将前一条命令的输出作为后一条命令的输入。
# 8. `cfssljson -bare` 是 cfssl 工具的命令，作用是将证书签发请求的输出转换为PKCS＃1、PKCS＃8和x509 PEM文件。
# 9. `/etc/kubernetes/pki/controller-manager` 是转换后的 PEM 文件的存储位置和文件名。
# 
# 这个命令的作用是根据根证书和私钥、配置文件以及证书签发请求的配置文件，生成经过签发的控制器管理器证书和私钥，并将转换后的 PEM 文件保存到指定的位置。


# 设置一个集群项
# 在《5.高可用配置》选择使用那种高可用方案
# 若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`
# 若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`
kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://127.0.0.1:8443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
# kubectl config set-cluster命令用于配置集群信息。
# --certificate-authority选项指定了集群的证书颁发机构（CA）的路径，这个CA会验证kube-apiserver提供的证书是否合法。
# --embed-certs选项用于将证书嵌入到生成的kubeconfig文件中，这样就不需要在kubeconfig文件中单独指定证书文件路径。
# --server选项指定了kube-apiserver的地址，这里使用的是127.0.0.1:8443，表示使用本地主机上的kube-apiserver，默认端口为8443。
# --kubeconfig选项指定了生成的kubeconfig文件的路径和名称，这里指定为/etc/kubernetes/controller-manager.kubeconfig。
# 综上所述，kubectl config set-cluster命令的作用是在kubeconfig文件中设置集群信息，包括证书颁发机构、证书、kube-apiserver地址等。


# 设置一个环境项，一个上下文
kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 这个命令用于配置 Kubernetes 控制器管理器的上下文信息。下面是各个参数的详细解释：
# 1. `kubectl config set-context system:kube-controller-manager@kubernetes`: 设置上下文的名称为 `system:kube-controller-manager@kubernetes`，这是一个标识符，用于唯一标识该上下文。
# 2. `--cluster=kubernetes`: 指定集群的名称为 `kubernetes`，这是一个现有集群的标识符，表示要管理的 Kubernetes 集群。
# 3. `--user=system:kube-controller-manager`: 指定使用的用户身份为 `system:kube-controller-manager`。这是一个特殊的用户身份，具有控制 Kubernetes 控制器管理器的权限。
# 4. `--kubeconfig=/etc/kubernetes/controller-manager.kubeconfig`: 指定 kubeconfig 文件的路径为 `/etc/kubernetes/controller-manager.kubeconfig`。kubeconfig 文件是一个用于管理 Kubernetes 配置的文件，包含了集群、用户和上下文的相关信息。
# 通过运行这个命令，可以将这些配置信息保存到 `/etc/kubernetes/controller-manager.kubeconfig` 文件中，以便在后续的操作中使用。



  # 设置一个用户项
kubectl config set-credentials system:kube-controller-manager \
   --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
   --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
   --embed-certs=true \
   --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
# 上述命令是用于设置 Kubernetes 的 controller-manager 组件的客户端凭据。下面是每个参数的详细解释：
# 
# - `kubectl config`: 是使用 kubectl 命令行工具的配置子命令。
# - `set-credentials`: 是定义一个新的用户凭据配置的子命令。
# - `system:kube-controller-manager`: 是设置用户凭据的名称，`system:` 是 Kubernetes API Server 内置的身份验证器使用的用户标识符前缀，它表示是一个系统用户，在本例中是 kube-controller-manager 组件使用的身份。
# - `--client-certificate=/etc/kubernetes/pki/controller-manager.pem`: 指定 controller-manager.pem 客户端证书的路径。
# - `--client-key=/etc/kubernetes/pki/controller-manager-key.pem`: 指定 controller-manager-key.pem 客户端私钥的路径。
# - `--embed-certs=true`: 表示将证书和私钥直接嵌入到生成的 kubeconfig 文件中，而不是通过引用外部文件。
# - `--kubeconfig=/etc/kubernetes/controller-manager.kubeconfig`: 指定生成的 kubeconfig 文件的路径和文件名，即 controller-manager.kubeconfig。
# 
# 通过运行上述命令，将根据提供的证书和私钥信息，为 kube-controller-manager 创建一个 kubeconfig 文件，以便后续使用该文件进行身份验证和访问 Kubernetes API。


# 设置默认环境
kubectl config use-context system:kube-controller-manager@kubernetes \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 这个命令是用来指定kubectl使用指定的上下文环境来执行操作。上下文环境是kubectl用来确定要连接到哪个Kubernetes集群以及使用哪个身份验证信息的配置。
# 
# 在这个命令中，`kubectl config use-context`是用来设置当前上下文环境的命令。 `system:kube-controller-manager@kubernetes`是指定的上下文名称，它告诉kubectl要使用的Kubernetes集群和身份验证信息。 
# `--kubeconfig=/etc/kubernetes/controller-manager.kubeconfig`是用来指定使用的kubeconfig文件的路径。kubeconfig文件是存储集群连接和身份验证信息的配置文件。
# 通过执行这个命令，kubectl将使用指定的上下文来执行后续的操作，包括部署和管理Kubernetes资源。
```

### 3.2.5 生成kube-scheduler的证书

```shell
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
# 这个命令是用来创建一个叫做scheduler-csr.json的文件，并将其中的内容赋值给该文件。
# 
# 文件内容是一个JSON格式的文本，包含了一个描述证书请求的结构。
# 
# 具体内容如下：
# 
# - "CN": "system:kube-scheduler"：Common Name字段，表示该证书的名称为system:kube-scheduler。
# - "key": {"algo": "rsa", "size": 2048}：key字段指定生成证书时使用的加密算法是RSA，并且密钥的长度为2048位。
# - "names": [...]：names字段定义了证书中的另外一些标识信息。
# - "C": "CN"：Country字段，表示国家/地区为中国。
# - "ST": "Beijing"：State字段，表示省/市为北京。
# - "L": "Beijing"：Locality字段，表示所在城市为北京。
# - "O": "system:kube-scheduler"：Organization字段，表示组织为system:kube-scheduler。
# - "OU": "Kubernetes-manual"：Organizational Unit字段，表示组织单元为Kubernetes-manual。
# 
# 而EOF是一个占位符，用于标记开始和结束的位置。在开始的EOF之后到结束的EOF之间的内容将会被写入到scheduler-csr.json文件中。
# 
# 总体来说，这个命令用于生成一个描述kube-scheduler证书请求的JSON文件。

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler

# 上述命令是使用cfssl工具生成Kubernetes Scheduler的证书。
# 
# 具体解释如下：
# 
# 1. `cfssl gencert`：使用cfssl工具生成证书。
# 2. `-ca=/etc/kubernetes/pki/ca.pem`：指定根证书文件的路径。在这里，是指定根证书的路径为`/etc/kubernetes/pki/ca.pem`。
# 3. `-ca-key=/etc/kubernetes/pki/ca-key.pem`：指定根证书私钥文件的路径。在这里，是指定根证书私钥的路径为`/etc/kubernetes/pki/ca-key.pem`。
# 4. `-config=ca-config.json`：指定证书配置文件的路径。在这里，是指定证书配置文件的路径为`ca-config.json`。
# 5. `-profile=kubernetes`：指定证书的配置文件中的一个配置文件模板。在这里，是指定配置文件中的`kubernetes`配置模板。
# 6. `scheduler-csr.json`：指定Scheduler的证书签名请求文件（CSR）的路径。在这里，是指定请求文件的路径为`scheduler-csr.json`。
# 7. `|`（管道符号）：将前一个命令的输出作为下一个命令的输入。
# 8. `cfssljson`：将cfssl工具生成的证书签名请求(CSR)进行解析。
# 9. `-bare /etc/kubernetes/pki/scheduler`：指定输出路径和前缀。在这里，是将解析的证书签名请求生成以下文件：`/etc/kubernetes/pki/scheduler.pem`（包含了证书）、`/etc/kubernetes/pki/scheduler-key.pem`（包含了私钥）。
# 
# 总结来说，这个命令的目的是根据根证书、根证书私钥、证书配置文件、CSR文件等生成Kubernetes Scheduler的证书和私钥文件。



# 在《5.高可用配置》选择使用那种高可用方案
# 若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`
# 若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://127.0.0.1:8443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
# 该命令用于配置一个名为"kubernetes"的集群，并将其应用到/etc/kubernetes/scheduler.kubeconfig文件中。
# 
# 该命令的解释如下：
# - `kubectl config set-cluster kubernetes`: 设置一个集群并命名为"kubernetes"。
# - `--certificate-authority=/etc/kubernetes/pki/ca.pem`: 指定集群使用的证书授权机构的路径。
# - `--embed-certs=true`: 该标志指示将证书嵌入到生成的kubeconfig文件中。
# - `--server=https://127.0.0.1:8443`: 指定集群的 API server 位置。
# - `--kubeconfig=/etc/kubernetes/scheduler.kubeconfig`: 指定要保存 kubeconfig 文件的路径和名称。

kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/pki/scheduler.pem \
     --client-key=/etc/kubernetes/pki/scheduler-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
# 这段命令是用于设置 kube-scheduler 组件的身份验证凭据，并生成相应的 kubeconfig 文件。
# 
# 解释每个选项的含义如下：
# - `kubectl config set-credentials system:kube-scheduler`：设置 `system:kube-scheduler` 用户的身份验证凭据。
# - `--client-certificate=/etc/kubernetes/pki/scheduler.pem`：指定一个客户端证书文件，用于基于证书的身份验证。在这种情况下，指定了 kube-scheduler 组件的证书文件路径。
# - `--client-key=/etc/kubernetes/pki/scheduler-key.pem`：指定与客户端证书相对应的客户端私钥文件。
# - `--embed-certs=true`：将客户端证书和私钥嵌入到生成的 kubeconfig 文件中。
# - `--kubeconfig=/etc/kubernetes/scheduler.kubeconfig`：指定生成的 kubeconfig 文件的路径和名称。
# 
# 该命令的目的是为 kube-scheduler 组件生成一个 kubeconfig 文件，以便进行身份验证和访问集群资源。kubeconfig 文件是一个包含了连接到 Kubernetes 集群所需的所有配置信息的文件，包括服务器地址、证书和秘钥等。

kubectl config set-context system:kube-scheduler@kubernetes \
     --cluster=kubernetes \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

# 该命令用于设置一个名为"system:kube-scheduler@kubernetes"的上下文，具体配置如下：
# 
# 1. --cluster=kubernetes: 指定集群的名称为"kubernetes"，这个集群是在当前的kubeconfig文件中已经定义好的。
# 2. --user=system:kube-scheduler: 指定用户的名称为"system:kube-scheduler"，这个用户也是在当前的kubeconfig文件中已经定义好的。这个用户用于认证和授权kube-scheduler组件访问Kubernetes集群的权限。
# 3. --kubeconfig=/etc/kubernetes/scheduler.kubeconfig: 指定kubeconfig文件的路径为"/etc/kubernetes/scheduler.kubeconfig"，这个文件将被用来保存上下文的配置信息。
# 
# 这个命令的作用是将上述的配置信息保存到指定的kubeconfig文件中，以便后续使用该文件进行认证和授权访问Kubernetes集群。

kubectl config use-context system:kube-scheduler@kubernetes \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

# 上述命令是使用`kubectl`命令来配置Kubernetes集群中的调度器组件。
# 
# `kubectl config use-context`命令用于切换`kubectl`当前使用的上下文。上下文是Kubernetes集群、用户和命名空间的组合，用于确定`kubectl`的连接目标。下面解释这个命令的不同部分：
# 
# - `system:kube-scheduler@kubernetes`是一个上下文名称。它指定了使用`kube-scheduler`用户和`kubernetes`命名空间的系统级别上下文。系统级别上下文用于操作Kubernetes核心组件。
# 
# - `--kubeconfig=/etc/kubernetes/scheduler.kubeconfig`用于指定Kubernetes配置文件的路径。Kubernetes配置文件包含连接到Kubernetes集群所需的身份验证和连接信息。
# 
# 通过运行以上命令，`kubectl`将使用指定的上下文和配置文件，以便在以后的命令中能正确地与Kubernetes集群中的调度器组件进行交互。
```

### 3.2.6 生成admin的证书配置

```shell
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
# 这段代码是一个JSON格式的配置文件，用于创建和配置一个名为"admin"的Kubernetes凭证。
# 
# 这个凭证包含以下字段：
# 
# - "CN": "admin": 这是凭证的通用名称，表示这是一个管理员凭证。
# - "key": 这是一个包含证书密钥相关信息的对象。
#   - "algo": "rsa"：这是使用的加密算法类型，这里是RSA加密算法。
#   - "size": 2048：这是密钥的大小，这里是2048位。
# - "names": 这是一个包含证书名称信息的数组。
#   - "C": "CN"：这是证书的国家/地区字段，这里是中国。
#   - "ST": "Beijing"：这是证书的省/州字段，这里是北京。
#   - "L": "Beijing"：这是证书的城市字段，这里是北京。
#   - "O": "system:masters"：这是证书的组织字段，这里是system:masters，表示系统的管理员组。
#   - "OU": "Kubernetes-manual"：这是证书的部门字段，这里是Kubernetes-manual。
# 
# 通过这个配置文件创建的凭证将具有管理员权限，并且可以用于管理Kubernetes集群。

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin

# 上述命令是使用cfssl工具生成Kubernetes admin的证书。
# 
# 具体解释如下：
# 
# 1. `cfssl gencert`：使用cfssl工具生成证书。
# 2. `-ca=/etc/kubernetes/pki/ca.pem`：指定根证书文件的路径。在这里，是指定根证书的路径为`/etc/kubernetes/pki/ca.pem`。
# 3. `-ca-key=/etc/kubernetes/pki/ca-key.pem`：指定根证书私钥文件的路径。在这里，是指定根证书私钥的路径为`/etc/kubernetes/pki/ca-key.pem`。
# 4. `-config=ca-config.json`：指定证书配置文件的路径。在这里，是指定证书配置文件的路径为`ca-config.json`。
# 5. `-profile=kubernetes`：指定证书的配置文件中的一个配置文件模板。在这里，是指定配置文件中的`kubernetes`配置模板。
# 6. `admin-csr.json`：指定admin的证书签名请求文件（CSR）的路径。在这里，是指定请求文件的路径为`admin-csr.json`。
# 7. `|`（管道符号）：将前一个命令的输出作为下一个命令的输入。
# 8. `cfssljson`：将cfssl工具生成的证书签名请求(CSR)进行解析。
# 9. `-bare /etc/kubernetes/pki/admin`：指定输出路径和前缀。在这里，是将解析的证书签名请求生成以下文件：`/etc/kubernetes/pki/admin.pem`（包含了证书）、`/etc/kubernetes/pki/admin-key.pem`（包含了私钥）。
# 
# 总结来说，这个命令的目的是根据根证书、根证书私钥、证书配置文件、CSR文件等生成Kubernetes Scheduler的证书和私钥文件。

# 在《5.高可用配置》选择使用那种高可用方案
# 若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`
# 若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`

kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://127.0.0.1:8443     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig
# 该命令用于配置一个名为"kubernetes"的集群，并将其应用到/etc/kubernetes/scheduler.kubeconfig文件中。
# 
# 该命令的解释如下：
# - `kubectl config set-cluster kubernetes`: 设置一个集群并命名为"kubernetes"。
# - `--certificate-authority=/etc/kubernetes/pki/ca.pem`: 指定集群使用的证书授权机构的路径。
# - `--embed-certs=true`: 该标志指示将证书嵌入到生成的kubeconfig文件中。
# - `--server=https://127.0.0.1:8443`: 指定集群的 API server 位置。
# - `--kubeconfig=/etc/kubernetes/admin.kubeconfig`: 指定要保存 kubeconfig 文件的路径和名称。

kubectl config set-credentials kubernetes-admin  \
  --client-certificate=/etc/kubernetes/pki/admin.pem     \
  --client-key=/etc/kubernetes/pki/admin-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig
# 这段命令是用于设置 kubernetes-admin 组件的身份验证凭据，并生成相应的 kubeconfig 文件。
# 
# 解释每个选项的含义如下：
# - `kubectl config set-credentials kubernetes-admin`：设置 `kubernetes-admin` 用户的身份验证凭据。
# - `--client-certificate=/etc/kubernetes/pki/admin.pem`：指定一个客户端证书文件，用于基于证书的身份验证。在这种情况下，指定了 admin 组件的证书文件路径。
# - `--client-key=/etc/kubernetes/pki/admin-key.pem`：指定与客户端证书相对应的客户端私钥文件。
# - `--embed-certs=true`：将客户端证书和私钥嵌入到生成的 kubeconfig 文件中。
# - `--kubeconfig=/etc/kubernetes/admin.kubeconfig`：指定生成的 kubeconfig 文件的路径和名称。
# 
# 该命令的目的是为 admin 组件生成一个 kubeconfig 文件，以便进行身份验证和访问集群资源。kubeconfig 文件是一个包含了连接到 Kubernetes 集群所需的所有配置信息的文件，包括服务器地址、证书和秘钥等。


kubectl config set-context kubernetes-admin@kubernetes    \
  --cluster=kubernetes     \
  --user=kubernetes-admin     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

# 该命令用于设置一个名为"kubernetes-admin@kubernetes"的上下文，具体配置如下：
# 
# 1. --cluster=kubernetes: 指定集群的名称为"kubernetes"，这个集群是在当前的kubeconfig文件中已经定义好的。
# 2. --user=kubernetes-admin: 指定用户的名称为"kubernetes-admin"，这个用户也是在当前的kubeconfig文件中已经定义好的。这个用户用于认证和授权admin组件访问Kubernetes集群的权限。
# 3. --kubeconfig=/etc/kubernetes/admin.kubeconfig: 指定kubeconfig文件的路径为"/etc/kubernetes/admin.kubeconfig"，这个文件将被用来保存上下文的配置信息。
# 
# 这个命令的作用是将上述的配置信息保存到指定的kubeconfig文件中，以便后续使用该文件进行认证和授权访问Kubernetes集群。


kubectl config use-context kubernetes-admin@kubernetes  --kubeconfig=/etc/kubernetes/admin.kubeconfig
# 上述命令是使用`kubectl`命令来配置Kubernetes集群中的调度器组件。
# 
# `kubectl config use-context`命令用于切换`kubectl`当前使用的上下文。上下文是Kubernetes集群、用户和命名空间的组合，用于确定`kubectl`的连接目标。下面解释这个命令的不同部分：
# 
# - `kubernetes-admin@kubernetes`是一个上下文名称。它指定了使用`kubernetes-admin`用户和`kubernetes`命名空间的系统级别上下文。系统级别上下文用于操作Kubernetes核心组件。
# 
# - `--kubeconfig=/etc/kubernetes/admin.kubeconfig`用于指定Kubernetes配置文件的路径。Kubernetes配置文件包含连接到Kubernetes集群所需的身份验证和连接信息。
# 
# 通过运行以上命令，`kubectl`将使用指定的上下文和配置文件，以便在以后的命令中能正确地与Kubernetes集群中的调度器组件进行交互。
```

### 3.2.7 创建kube-proxy证书

在《5.高可用配置》选择使用那种高可用方案  
若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`​  
若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`​

```shell
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
# 这段代码是一个JSON格式的配置文件，用于创建和配置一个名为"kube-proxy-csr"的Kubernetes凭证。
# 
# 这个凭证包含以下字段：
# 
# - "CN": "system:kube-proxy": 这是凭证的通用名称，表示这是一个管理员凭证。
# - "key": 这是一个包含证书密钥相关信息的对象。
#   - "algo": "rsa"：这是使用的加密算法类型，这里是RSA加密算法。
#   - "size": 2048：这是密钥的大小，这里是2048位。
# - "names": 这是一个包含证书名称信息的数组。
#   - "C": "CN"：这是证书的国家/地区字段，这里是中国。
#   - "ST": "Beijing"：这是证书的省/州字段，这里是北京。
#   - "L": "Beijing"：这是证书的城市字段，这里是北京。
#   - "O": "system:kube-proxy"：这是证书的组织字段，这里是system:kube-proxy。
#   - "OU": "Kubernetes-manual"：这是证书的部门字段，这里是Kubernetes-manual。
# 
# 通过这个配置文件创建的凭证将具有管理员权限，并且可以用于管理Kubernetes集群。

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   kube-proxy-csr.json | cfssljson -bare /etc/kubernetes/pki/kube-proxy

# 上述命令是使用cfssl工具生成Kubernetes admin的证书。
# 
# 具体解释如下：
# 
# 1. `cfssl gencert`：使用cfssl工具生成证书。
# 2. `-ca=/etc/kubernetes/pki/ca.pem`：指定根证书文件的路径。在这里，是指定根证书的路径为`/etc/kubernetes/pki/ca.pem`。
# 3. `-ca-key=/etc/kubernetes/pki/ca-key.pem`：指定根证书私钥文件的路径。在这里，是指定根证书私钥的路径为`/etc/kubernetes/pki/ca-key.pem`。
# 4. `-config=ca-config.json`：指定证书配置文件的路径。在这里，是指定证书配置文件的路径为`ca-config.json`。
# 5. `-profile=kubernetes`：指定证书的配置文件中的一个配置文件模板。在这里，是指定配置文件中的`kubernetes`配置模板。
# 6. `kube-proxy-csr.json`：指定admin的证书签名请求文件（CSR）的路径。在这里，是指定请求文件的路径为`kube-proxy-csr.json`。
# 7. `|`（管道符号）：将前一个命令的输出作为下一个命令的输入。
# 8. `cfssljson`：将cfssl工具生成的证书签名请求(CSR)进行解析。
# 9. `-bare /etc/kubernetes/pki/kube-proxy`：指定输出路径和前缀。在这里，是将解析的证书签名请求生成以下文件：`/etc/kubernetes/pki/kube-proxy.pem`（包含了证书）、`/etc/kubernetes/pki/kube-proxy-key.pem`（包含了私钥）。
# 
# 总结来说，这个命令的目的是根据根证书、根证书私钥、证书配置文件、CSR文件等生成Kubernetes Scheduler的证书和私钥文件。


# 在《5.高可用配置》选择使用那种高可用方案
# 若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`
# 若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`

kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://127.0.0.1:8443     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
# 该命令用于配置一个名为"kubernetes"的集群，并将其应用到/etc/kubernetes/kube-proxy.kubeconfig文件中。
# 
# 该命令的解释如下：
# - `kubectl config set-cluster kubernetes`: 设置一个集群并命名为"kubernetes"。
# - `--certificate-authority=/etc/kubernetes/pki/ca.pem`: 指定集群使用的证书授权机构的路径。
# - `--embed-certs=true`: 该标志指示将证书嵌入到生成的kubeconfig文件中。
# - `--server=https://127.0.0.1:8443`: 指定集群的 API server 位置。
# - `--kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig`: 指定要保存 kubeconfig 文件的路径和名称。

kubectl config set-credentials kube-proxy  \
  --client-certificate=/etc/kubernetes/pki/kube-proxy.pem     \
  --client-key=/etc/kubernetes/pki/kube-proxy-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
# 这段命令是用于设置 kube-proxy 组件的身份验证凭据，并生成相应的 kubeconfig 文件。
# 
# 解释每个选项的含义如下：
# - `kubectl config set-credentials kube-proxy`：设置 `kube-proxy` 用户的身份验证凭据。
# - `--client-certificate=/etc/kubernetes/pki/kube-proxy.pem`：指定一个客户端证书文件，用于基于证书的身份验证。在这种情况下，指定了 kube-proxy 组件的证书文件路径。
# - `--client-key=/etc/kubernetes/pki/kube-proxy-key.pem`：指定与客户端证书相对应的客户端私钥文件。
# - `--embed-certs=true`：将客户端证书和私钥嵌入到生成的 kubeconfig 文件中。
# - `--kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig`：指定生成的 kubeconfig 文件的路径和名称。
# 
# 该命令的目的是为 kube-proxy 组件生成一个 kubeconfig 文件，以便进行身份验证和访问集群资源。kubeconfig 文件是一个包含了连接到 Kubernetes 集群所需的所有配置信息的文件，包括服务器地址、证书和秘钥等。

kubectl config set-context kube-proxy@kubernetes    \
  --cluster=kubernetes     \
  --user=kube-proxy     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

# 该命令用于设置一个名为"kube-proxy@kubernetes"的上下文，具体配置如下：
# 
# 1. --cluster=kubernetes: 指定集群的名称为"kubernetes"，这个集群是在当前的kubeconfig文件中已经定义好的。
# 2. --user=kube-proxy: 指定用户的名称为"kube-proxy"，这个用户也是在当前的kubeconfig文件中已经定义好的。这个用户用于认证和授权kube-proxy组件访问Kubernetes集群的权限。
# 3. --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig: 指定kubeconfig文件的路径为"/etc/kubernetes/kube-proxy.kubeconfig"，这个文件将被用来保存上下文的配置信息。
# 
# 这个命令的作用是将上述的配置信息保存到指定的kubeconfig文件中，以便后续使用该文件进行认证和授权访问Kubernetes集群。

kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
# 上述命令是使用`kubectl`命令来配置Kubernetes集群中的调度器组件。
# 
# `kubectl config use-context`命令用于切换`kubectl`当前使用的上下文。上下文是Kubernetes集群、用户和命名空间的组合，用于确定`kubectl`的连接目标。下面解释这个命令的不同部分：
# 
# - `kube-proxy@kubernetes`是一个上下文名称。它指定了使用`kube-proxy`用户和`kubernetes`命名空间的系统级别上下文。系统级别上下文用于操作Kubernetes核心组件。
# 
# - `--kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig`用于指定Kubernetes配置文件的路径。Kubernetes配置文件包含连接到Kubernetes集群所需的身份验证和连接信息。
# 
# 通过运行以上命令，`kubectl`将使用指定的上下文和配置文件，以便在以后的命令中能正确地与Kubernetes集群中的调度器组件进行交互。
```

### 3.2.8 创建ServiceAccount Key ——secret

```shell
openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub

# 这两个命令是使用OpenSSL工具生成RSA密钥对。
# 
# 命令1：openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
# 该命令用于生成私钥文件。具体解释如下：
# - openssl：openssl命令行工具。
# - genrsa：生成RSA密钥对。
# - -out /etc/kubernetes/pki/sa.key：指定输出私钥文件的路径和文件名。
# - 2048：指定密钥长度为2048位。
# 
# 命令2：openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub
# 该命令用于从私钥中导出公钥。具体解释如下：
# - openssl：openssl命令行工具。
# - rsa：与私钥相关的RSA操作。
# - -in /etc/kubernetes/pki/sa.key：指定输入私钥文件的路径和文件名。
# - -pubout：指定输出公钥。
# - -out /etc/kubernetes/pki/sa.pub：指定输出公钥文件的路径和文件名。
# 
# 总结：通过以上两个命令，我们可以使用OpenSSL工具生成一个RSA密钥对，并将私钥保存在/etc/kubernetes/pki/sa.key文件中，将公钥保存在/etc/kubernetes/pki/sa.pub文件中。
```

### 3.2.9 将证书发送到其他master节点

```shell
#其他节点创建目录
# mkdir  /etc/kubernetes/pki/ -p

for NODE in k8s-master02 k8s-master03; do  for FILE in $(ls /etc/kubernetes/pki | grep -v etcd); do  scp /etc/kubernetes/pki/${FILE} $NODE:/etc/kubernetes/pki/${FILE}; done;  for FILE in admin.kubeconfig controller-manager.kubeconfig scheduler.kubeconfig; do  scp /etc/kubernetes/${FILE} $NODE:/etc/kubernetes/${FILE}; done; done
```

### 3.2.10 查看证书

```shell
ll /etc/kubernetes/pki/
总用量 104
-rw-r--r-- 1 root root 1025 12月 15 16:18 admin.csr
-rw------- 1 root root 1675 12月 15 16:18 admin-key.pem
-rw-r--r-- 1 root root 1444 12月 15 16:18 admin.pem
-rw-r--r-- 1 root root 1415 12月 15 16:15 apiserver.csr
-rw------- 1 root root 1675 12月 15 16:15 apiserver-key.pem
-rw-r--r-- 1 root root 1805 12月 15 16:15 apiserver.pem
-rw-r--r-- 1 root root 1070 12月 15 16:15 ca.csr
-rw------- 1 root root 1675 12月 15 16:15 ca-key.pem
-rw-r--r-- 1 root root 1363 12月 15 16:15 ca.pem
-rw-r--r-- 1 root root 1082 12月 15 16:16 controller-manager.csr
-rw------- 1 root root 1679 12月 15 16:16 controller-manager-key.pem
-rw-r--r-- 1 root root 1501 12月 15 16:16 controller-manager.pem
-rw-r--r-- 1 root root  940 12月 15 16:16 front-proxy-ca.csr
-rw------- 1 root root 1679 12月 15 16:16 front-proxy-ca-key.pem
-rw-r--r-- 1 root root 1094 12月 15 16:16 front-proxy-ca.pem
-rw-r--r-- 1 root root  903 12月 15 16:16 front-proxy-client.csr
-rw------- 1 root root 1679 12月 15 16:16 front-proxy-client-key.pem
-rw-r--r-- 1 root root 1188 12月 15 16:16 front-proxy-client.pem
-rw-r--r-- 1 root root 1045 12月 15 16:18 kube-proxy.csr
-rw------- 1 root root 1675 12月 15 16:18 kube-proxy-key.pem
-rw-r--r-- 1 root root 1464 12月 15 16:18 kube-proxy.pem
-rw------- 1 root root 1704 12月 15 16:19 sa.key
-rw-r--r-- 1 root root  451 12月 15 16:19 sa.pub
-rw-r--r-- 1 root root 1058 12月 15 16:17 scheduler.csr
-rw------- 1 root root 1675 12月 15 16:17 scheduler-key.pem
-rw-r--r-- 1 root root 1476 12月 15 16:17 scheduler.pem


# 一共26个就对了
ls /etc/kubernetes/pki/ |wc -l
26
```

# 4.k8s系统组件配置

## 4.1.etcd配置

```shell
这个配置文件是用于 etcd 集群的配置，其中包含了一些重要的参数和选项：

- `name`：指定了当前节点的名称，用于集群中区分不同的节点。
- `data-dir`：指定了 etcd 数据的存储目录。
- `wal-dir`：指定了 etcd 数据写入磁盘的目录。
- `snapshot-count`：指定了触发快照的事务数量。
- `heartbeat-interval`：指定了 etcd 集群中节点之间的心跳间隔。
- `election-timeout`：指定了选举超时时间。
- `quota-backend-bytes`：指定了存储的限额，0 表示无限制。
- `listen-peer-urls`：指定了节点之间通信的 URL，使用 HTTPS 协议。
- `listen-client-urls`：指定了客户端访问 etcd 集群的 URL，同时提供了本地访问的 URL。
- `max-snapshots`：指定了快照保留的数量。
- `max-wals`：指定了日志保留的数量。
- `initial-advertise-peer-urls`：指定了节点之间通信的初始 URL。
- `advertise-client-urls`：指定了客户端访问 etcd 集群的初始 URL。
- `discovery`：定义了 etcd 集群发现相关的选项。
- `initial-cluster`：指定了 etcd 集群的初始成员。
- `initial-cluster-token`：指定了集群的 token。
- `initial-cluster-state`：指定了集群的初始状态。
- `strict-reconfig-check`：指定了严格的重新配置检查选项。
- `enable-v2`：启用了 v2 API。
- `enable-pprof`：启用了性能分析。
- `proxy`：设置了代理模式。
- `client-transport-security`：客户端的传输安全配置。
- `peer-transport-security`：节点之间的传输安全配置。
- `debug`：是否启用调试模式。
- `log-package-levels`：日志的输出级别。
- `log-outputs`：指定了日志的输出类型。
- `force-new-cluster`：是否强制创建一个新的集群。

这些参数和选项可以根据实际需求进行调整和配置。
```

### 4.1.1master01配置

```shell
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://192.168.1.31:2380'
listen-client-urls: 'https://192.168.1.31:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://192.168.1.31:2380'
advertise-client-urls: 'https://192.168.1.31:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://192.168.1.31:2380,k8s-master02=https://192.168.1.32:2380,k8s-master03=https://192.168.1.33:2380'
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
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
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

### 4.1.2master02配置

```shell
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master02'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://192.168.1.32:2380'
listen-client-urls: 'https://192.168.1.32:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://192.168.1.32:2380'
advertise-client-urls: 'https://192.168.1.32:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://192.168.1.31:2380,k8s-master02=https://192.168.1.32:2380,k8s-master03=https://192.168.1.33:2380'
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
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
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

### 4.1.3master03配置

```shell
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master03'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://192.168.1.33:2380'
listen-client-urls: 'https://192.168.1.33:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://192.168.1.33:2380'
advertise-client-urls: 'https://192.168.1.33:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://192.168.1.31:2380,k8s-master02=https://192.168.1.32:2380,k8s-master03=https://192.168.1.33:2380'
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
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
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

## 4.2.创建service（所有master节点操作）

### 4.2.1创建etcd.service并启动

```shell
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
# 这是一个系统服务配置文件，用于启动和管理Etcd服务。
# 
# [Unit] 部分包含了服务的一些基本信息，它定义了服务的描述和文档链接，并指定了服务应在网络连接之后启动。
# 
# [Service] 部分定义了服务的具体配置。在这里，服务的类型被设置为notify，意味着当服务成功启动时，它将通知系统。ExecStart 指定了启动服务时要执行的命令，这里是运行 /usr/local/bin/etcd 命令并传递一个配置文件 /etc/etcd/etcd.config.yml。Restart 设置为 on-failure，意味着当服务失败时将自动重启，并且在10秒后进行重启。LimitNOFILE 指定了服务的最大文件打开数。
# 
# [Install] 部分定义了服务的安装配置。WantedBy 指定了服务应该被启动的目标，这里是 multi-user.target，表示在系统进入多用户模式时启动。Alias 定义了一个别名，可以通过etcd3.service来引用这个服务。
# 
# 这个配置文件描述了如何启动和管理Etcd服务，并将其安装到系统中。通过这个配置文件，可以确保Etcd服务在系统启动后自动启动，并在出现问题时进行重启。
```

### 4.2.2创建etcd证书目录

```shell
mkdir /etc/kubernetes/pki/etcd
ln -s /etc/etcd/ssl/* /etc/kubernetes/pki/etcd/

systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now etcd.service
# 启用并立即启动etcd.service单元。etcd.service是etcd守护进程的systemd服务单元。

systemctl restart etcd.service
# 重启etcd.service单元，即重新启动etcd守护进程。

systemctl status etcd.service
# etcd.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 4.2.3查看etcd状态

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
export ETCDCTL_API=3
etcdctl --endpoints="192.168.1.33:2379,192.168.1.32:2379,192.168.1.31:2379" --cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem --cert=/etc/kubernetes/pki/etcd/etcd.pem --key=/etc/kubernetes/pki/etcd/etcd-key.pem  endpoint status --write-out=table
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 192.168.1.33:2379 |  8065f2e59c8d68c |  3.5.17 |   20 kB |      true |      false |         3 |         13 |                 13 |        |
| 192.168.1.32:2379 | b7b7ad6bf4db3f28 |  3.5.17 |   20 kB |     false |      false |         3 |         13 |                 13 |        |
| 192.168.1.31:2379 | bf047bcfe3b9bf27 |  3.5.17 |   20 kB |     false |      false |         3 |         13 |                 13 |        |
+-------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+


# 这个命令是使用etcdctl工具，用于查看指定etcd集群的健康状态。下面是每个参数的详细解释：
# 
# - `--endpoints`：指定要连接的etcd集群节点的地址和端口。在这个例子中，指定了3个节点的地址和端口，分别是`192.168.1.33:2379,192.168.1.32:2379,192.168.1.31:2379`。
# - `--cacert`：指定用于验证etcd服务器证书的CA证书的路径。在这个例子中，指定了CA证书的路径为`/etc/kubernetes/pki/etcd/etcd-ca.pem`。CA证书用于验证etcd服务器证书的有效性。
# - `--cert`：指定用于与etcd服务器进行通信的客户端证书的路径。在这个例子中，指定了客户端证书的路径为`/etc/kubernetes/pki/etcd/etcd.pem`。客户端证书用于在与etcd服务器建立安全通信时进行身份验证。
# - `--key`：指定与客户端证书配对的私钥的路径。在这个例子中，指定了私钥的路径为`/etc/kubernetes/pki/etcd/etcd-key.pem`。私钥用于对通信进行加密解密和签名验证。
# - `endpoint status`：子命令，用于检查etcd集群节点的健康状态。
# - `--write-out`：指定输出的格式。在这个例子中，指定以表格形式输出。
# 
# 通过执行这个命令，可以获取到etcd集群节点的健康状态，并以表格形式展示。
```

# 5.高可用配置（在Master服务器上操作）

**注意* 5.1.1 和5.1.2 二选一即可**

选择使用那种高可用方案，同时可以俩种都选用，实现内外兼顾的效果，比如：  
5.1 的 NGINX方案实现集群内的高可用  
5.2 的 haproxy、keepalived 方案实现集群外访问

在《3.2.生成k8s相关证书》

若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`​  
若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`​

## 5.1 NGINX高可用方案

### 5.1.1 进行编译

```shell
# 安装编译环境
yum install gcc -y

# 下载解压nginx二进制文件
# wget http://nginx.org/download/nginx-1.25.3.tar.gz
tar xvf nginx-*.tar.gz
cd nginx-*

# 进行编译
./configure --with-stream --without-http --without-http_uwsgi_module --without-http_scgi_module --without-http_fastcgi_module
make && make install 

# 拷贝编译好的nginx
node='k8s-master02 k8s-master03 k8s-node01 k8s-node02'
for NODE in $node; do scp -r /usr/local/nginx/ $NODE:/usr/local/nginx/; done

# 这是一系列命令行指令，用于编译和安装软件。
# 
# 1. `./configure` 是用于配置软件的命令。在这个例子中，配置的软件是一个Web服务器，指定了一些选项来启用流模块，并禁用了HTTP、uwsgi、scgi和fastcgi模块。
# 2. `--with-stream` 指定启用流模块。流模块通常用于代理TCP和UDP流量。
# 3. `--without-http` 指定禁用HTTP模块。这意味着编译的软件将没有HTTP服务器功能。
# 4. `--without-http_uwsgi_module` 指定禁用uwsgi模块。uwsgi是一种Web服务器和应用服务器之间的通信协议。
# 5. `--without-http_scgi_module` 指定禁用scgi模块。scgi是一种用于将Web服务器请求传递到应用服务器的协议。
# 6. `--without-http_fastcgi_module` 指定禁用fastcgi模块。fastcgi是一种用于在Web服务器和应用服务器之间交换数据的协议。
# 7. `make` 是用于编译软件的命令。该命令将根据之前的配置生成可执行文件。
# 8. `make install` 用于安装软件。该命令将生成的可执行文件和其他必要文件复制到系统的适当位置，以便可以使用该软件。
# 
# 总之，这个命令序列用于编译一个配置了特定选项的Web服务器，并将其安装到系统中。
```

### 5.1.2 写入启动配置

在所有主机上执行

```shell
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
        server 192.168.1.31:6443        max_fails=3 fail_timeout=30s;
        server 192.168.1.32:6443        max_fails=3 fail_timeout=30s;
        server 192.168.1.33:6443        max_fails=3 fail_timeout=30s;
    }
    server {
        listen 127.0.0.1:8443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
EOF
# 这段配置是一个nginx的stream模块的配置，用于代理TCP和UDP流量。
# 
# 首先，`worker_processes 1;`表示启动一个worker进程用于处理流量。
# 接下来，`events { worker_connections 1024; }`表示每个worker进程可以同时处理最多1024个连接。
# 在stream块里面，定义了一个名为`backend`的upstream，用于负载均衡和故障转移。
# `least_conn`表示使用最少连接算法进行负载均衡。
# `hash $remote_addr consistent`表示用客户端的IP地址进行哈希分配请求，保持相同IP的请求始终访问同一台服务器。
# `server`指令用于定义后端的服务器，每个服务器都有一个IP地址和端口号，以及一些可选的参数。
# `max_fails=3`表示当一个服务器连续失败3次时将其标记为不可用。
# `fail_timeout=30s`表示如果一个服务器被标记为不可用，nginx将在30秒后重新尝试。
# 在server块内部，定义了一个监听地址为127.0.0.1:8443的服务器。
# `proxy_connect_timeout 1s`表示与后端服务器建立连接的超时时间为1秒。
# `proxy_pass backend`表示将流量代理到名为backend的上游服务器组。
# 
# 总结起来，这段配置将流量代理到一个包含3个后端服务器的上游服务器组中，使用最少连接算法进行负载均衡，并根据客户端的IP地址进行哈希分配请求。如果一个服务器连续失败3次，则将其标记为不可用，并在30秒后重新尝试。


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
# 这是一个用于kube-apiserver的NGINX代理的systemd单位文件。
# 
# [Unit]部分包含了单位的描述和依赖关系。它指定了在network.target和network-online.target之后启动，并且需要network-online.target。
# 
# [Service]部分定义了如何运行该服务。Type指定了服务进程的类型（forking表示主进程会派生一个子进程）。ExecStartPre指定了在服务启动之前需要运行的命令，用于检查NGINX配置文件的语法是否正确。ExecStart指定了启动服务所需的命令。ExecReload指定了在重新加载配置文件时运行的命令。PrivateTmp设置为true表示将为服务创建一个私有的临时文件系统。Restart和RestartSec用于设置服务的自动重启机制。StartLimitInterval设置为0表示无需等待，可以立即重启服务。LimitNOFILE指定了服务的文件描述符的限制。
# 
# [Install]部分指定了在哪些target下该单位应该被启用。
# 
# 综上所述，此单位文件用于启动和管理kube-apiserver的NGINX代理服务。它通过NGINX来反向代理和负载均衡kube-apiserver的请求。该服务会在系统启动时自动启动，并具有自动重启的机制。


# 设置开机自启

systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。
systemctl enable --now kube-nginx.service
# 启用并立即启动kube-nginx.service单元。kube-nginx.service是kube-nginx守护进程的systemd服务单元。
systemctl restart kube-nginx.service
# 重启kube-nginx.service单元，即重新启动kube-nginx守护进程。
systemctl status kube-nginx.service
# kube-nginx.service单元的当前状态，包括运行状态、是否启用等信息。
```

## 5.2 keepalived和haproxy 高可用方案

### 5.2.1安装keepalived和haproxy服务

```shell
systemctl disable --now firewalld
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
yum -y install keepalived haproxy
```

### 5.2.2修改haproxy配置文件（配置文件一样）

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
 bind 0.0.0.0:9443
 bind 127.0.0.1:9443
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
 server  k8s-master01  192.168.1.31:6443 check
 server  k8s-master02  192.168.1.32:6443 check
 server  k8s-master03  192.168.1.33:6443 check
EOF
```

参数

```shell
这段配置代码是指定了一个HAProxy负载均衡器的配置。下面对各部分进行详细解释：
1. global:
   - maxconn 2000: 设置每个进程的最大连接数为2000。
   - ulimit-n 16384: 设置每个进程的最大文件描述符数为16384。
   - log 127.0.0.1 local0 err: 指定日志的输出地址为本地主机的127.0.0.1，并且只记录错误级别的日志。
   - stats timeout 30s: 设置查看负载均衡器统计信息的超时时间为30秒。

2. defaults:
   - log global: 使默认日志与global部分相同。
   - mode http: 设定负载均衡器的工作模式为HTTP模式。
   - option httplog: 使负载均衡器记录HTTP协议的日志。
   - timeout connect 5000: 设置与后端服务器建立连接的超时时间为5秒。
   - timeout client 50000: 设置与客户端的连接超时时间为50秒。
   - timeout server 50000: 设置与后端服务器连接的超时时间为50秒。
   - timeout http-request 15s: 设置处理HTTP请求的超时时间为15秒。
   - timeout http-keep-alive 15s: 设置保持HTTP连接的超时时间为15秒。

3. frontend monitor-in:
   - bind *:33305: 监听所有IP地址的33305端口。
   - mode http: 设定frontend的工作模式为HTTP模式。
   - option httplog: 记录HTTP协议的日志。
   - monitor-uri /monitor: 设置监控URI为/monitor。

4. frontend k8s-master:
   - bind 0.0.0.0:9443: 监听所有IP地址的9443端口。
   - bind 127.0.0.1:9443: 监听本地主机的9443端口。
   - mode tcp: 设定frontend的工作模式为TCP模式。
   - option tcplog: 记录TCP协议的日志。
   - tcp-request inspect-delay 5s: 设置在接收到请求后延迟5秒进行检查。
   - default_backend k8s-master: 设置默认的后端服务器组为k8s-master。

5. backend k8s-master:
   - mode tcp: 设定backend的工作模式为TCP模式。
   - option tcplog: 记录TCP协议的日志。
   - option tcp-check: 启用TCP检查功能。
   - balance roundrobin: 使用轮询算法进行负载均衡。
   - default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100: 设置默认的服务器参数。
   - server k8s-master01 192.168.1.31:6443 check: 增加一个名为k8s-master01的服务器，IP地址为192.168.1.31，端口号为6443，并对其进行健康检查。
   - server k8s-master02 192.168.1.32:6443 check: 增加一个名为k8s-master02的服务器，IP地址为192.168.1.32，端口号为6443，并对其进行健康检查。
   - server k8s-master03 192.168.1.33:6443 check: 增加一个名为k8s-master03的服务器，IP地址为192.168.1.33，端口号为6443，并对其进行健康检查。

以上就是这段配置代码的详细解释。它主要定义了全局配置、默认配置、前端监听和后端服务器组的相关参数和设置。通过这些配置，可以实现负载均衡和监控功能。
```

### 5.2.3Master01配置keepalived master节点

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
    mcast_src_ip 192.168.1.31
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 5.2.4Master02配置keepalived backup节点

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
    interface ens18
    mcast_src_ip 192.168.1.32
    virtual_router_id 51
    priority 80
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 5.2.5Master03配置keepalived backup节点

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
    interface ens18
    mcast_src_ip 192.168.1.33
    virtual_router_id 51
    priority 50
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

参数

```shell
这是一个用于配置keepalived的配置文件。下面是对每个部分的详细解释：

- `global_defs`部分定义了全局参数。
- `router_id`参数指定了当前路由器的标识，这里设置为"LVS_DEVEL"。

- `vrrp_script`部分定义了一个VRRP脚本。`chk_apiserver`是脚本的名称，
    - `script`参数指定了脚本的路径。该脚本每5秒执行一次，返回值为0表示服务正常，返回值为1表示服务异常。
    - `weight`参数指定了根据脚本返回的值来调整优先级，这里设置为-5。
    - `fall`参数指定了失败阈值，当连续2次脚本返回值为1时认为服务异常。
    - `rise`参数指定了恢复阈值，当连续1次脚本返回值为0时认为服务恢复正常。

- `vrrp_instance`部分定义了一个VRRP实例。`VI_1`是实例的名称。
    - `state`参数指定了当前实例的状态，这里设置为MASTER表示当前实例是主节点。
    - `interface`参数指定了要监听的网卡，这里设置为ens18。
    - `mcast_src_ip`参数指定了VRRP报文的源IP地址，这里设置为192.168.1.31。
    - `virtual_router_id`参数指定了虚拟路由器的ID，这里设置为51。
    - `priority`参数指定了实例的优先级，优先级越高（数值越大）越有可能被选为主节点。
    - `nopreempt`参数指定了当主节点失效后不要抢占身份，即不要自动切换为主节点。
    - `advert_int`参数指定了发送广播的间隔时间，这里设置为2秒。
    - `authentication`部分指定了认证参数
        - `auth_type`参数指定了认证类型，这里设置为PASS表示使用密码认证，
        - `auth_pass`参数指定了认证密码，这里设置为K8SHA_KA_AUTH。
    - `virtual_ipaddress`部分指定了虚拟IP地址，这里设置为192.168.1.36。
    - `track_script`部分指定了要跟踪的脚本，这里跟踪了chk_apiserver脚本。
```

### 5.2.6健康检查脚本配置（lb主机）

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

# 这段脚本是一个简单的bash脚本，主要用来检查是否有名为haproxy的进程正在运行。
# 
# 脚本的主要逻辑如下：
# 1. 首先设置一个变量err为0，用来记录错误次数。
# 2. 使用一个循环，在循环内部执行以下操作：
#    a. 使用pgrep命令检查是否有名为haproxy的进程在运行。如果不存在该进程，将err加1，并暂停1秒钟，然后继续下一次循环。
#    b. 如果存在haproxy进程，将err重置为0，并跳出循环。
# 3. 检查err的值，如果不为0，表示检查失败，输出一条错误信息并执行“systemctl stop keepalived”命令停止keepalived进程，并退出脚本返回1。
# 4. 如果err的值为0，表示检查成功，退出脚本返回0。
# 
# 该脚本的主要作用是检查是否存在运行中的haproxy进程，如果无法检测到haproxy进程，将停止keepalived进程并返回错误状态。如果haproxy进程存在，则返回成功状态。这个脚本可能是作为一个健康检查脚本的一部分，在确保haproxy服务可用的情况下，才继续运行其他操作。
```

### 5.2.7启动服务

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。
systemctl enable --now haproxy.service
# 启用并立即启动haproxy.service单元。haproxy.service是haproxy守护进程的systemd服务单元。
systemctl enable --now keepalived.service
# 启用并立即启动keepalived.service单元。keepalived.service是keepalived守护进程的systemd服务单元。
systemctl status haproxy.service
# haproxy.service单元的当前状态，包括运行状态、是否启用等信息。
systemctl status keepalived.service
# keepalived.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 5.2.8测试高可用

```shell
# 能ping同
[root@k8s-node02 ~]# ping 192.168.1.36

# 能telnet访问
[root@k8s-node02 ~]# telnet 192.168.1.36 9443

# 关闭主节点，看vip是否漂移到备节点
```

# 6.k8s组件配置

所有k8s节点创建以下目录

```shell
mkdir -p /etc/kubernetes/manifests/ /etc/systemd/system/kubelet.service.d /var/lib/kubelet /var/log/kubernetes
```

## 6.1.创建apiserver（所有master节点）

### 6.1.1master01节点配置

```shell
# 若关闭IPv6 删除 --service-cluster-ip-range 的 IPv6 即可
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
      --v=2  \\
      --allow-privileged=true  \\
      --bind-address=0.0.0.0  \\
      --secure-port=6443  \\
      --advertise-address=192.168.1.31 \\
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112  \\
      --service-node-port-range=30000-32767  \\
      --etcd-servers=https://192.168.1.31:2379,https://192.168.1.32:2379,https://192.168.1.33:2379 \\
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \\
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \\
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \\
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \\
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \\
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \\
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \\
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \\
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \\
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \\
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \\
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \\
      --enable-bootstrap-token-auth=true  \\
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \\
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \\
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \\
      --requestheader-allowed-names=aggregator  \\
      --requestheader-group-headers=X-Remote-Group  \\
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \\
      --requestheader-username-headers=X-Remote-User \\
      --enable-aggregator-routing=true
Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

### 6.1.2master02节点配置

```shell
# 若关闭IPv6 删除 --service-cluster-ip-range 的 IPv6 即可
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
      --v=2  \\
      --allow-privileged=true  \\
      --bind-address=0.0.0.0  \\
      --secure-port=6443  \\
      --advertise-address=192.168.1.32 \\
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112  \\
      --service-node-port-range=30000-32767  \\
      --etcd-servers=https://192.168.1.31:2379,https://192.168.1.32:2379,https://192.168.1.33:2379 \\
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \\
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \\
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \\
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \\
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \\
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \\
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \\
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \\
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \\
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \\
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \\
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \\
      --authorization-mode=Node,RBAC  \\
      --enable-bootstrap-token-auth=true  \\
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \\
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \\
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \\
      --requestheader-allowed-names=aggregator  \\
      --requestheader-group-headers=X-Remote-Group  \\
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \\
      --requestheader-username-headers=X-Remote-User \\
      --enable-aggregator-routing=true

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

### 6.1.3master03节点配置

```shell
# 若关闭IPv6 删除 --service-cluster-ip-range 的 IPv6 即可
cat > /usr/lib/systemd/system/kube-apiserver.service  << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
      --v=2  \\
      --allow-privileged=true  \\
      --bind-address=0.0.0.0  \\
      --secure-port=6443  \\
      --advertise-address=192.168.1.33 \\
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112  \\
      --service-node-port-range=30000-32767  \\
      --etcd-servers=https://192.168.1.31:2379,https://192.168.1.32:2379,https://192.168.1.33:2379 \\
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \\
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \\
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \\
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \\
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \\
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \\
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \\
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \\
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \\
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \\
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \\
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \\
      --authorization-mode=Node,RBAC  \\
      --enable-bootstrap-token-auth=true  \\
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \\
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \\
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \\
      --requestheader-allowed-names=aggregator  \\
      --requestheader-group-headers=X-Remote-Group  \\
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \\
      --requestheader-username-headers=X-Remote-User \\
      --enable-aggregator-routing=true

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

参数

```shell
该配置文件是用于定义Kubernetes API Server的systemd服务的配置。systemd是一个用于启动和管理Linux系统服务的守护进程。

[Unit]
- Description: 服务的描述信息，用于显示在日志和系统管理工具中。
- Documentation: 提供关于服务的文档链接。
- After: 规定服务依赖于哪些其他服务或单元。在这个例子中，API Server服务在网络目标启动之后启动。

[Service]
- ExecStart: 定义服务的命令行参数和命令。这里指定了API Server的启动命令，包括各种参数选项。
- Restart: 指定当服务退出时应该如何重新启动。在这个例子中，服务在失败时将被重新启动。
- RestartSec: 指定两次重新启动之间的等待时间。
- LimitNOFILE: 指定进程可以打开的文件描述符的最大数量。

[Install]
- WantedBy: 指定服务应该安装到哪个系统目标。在这个例子中，服务将被安装到multi-user.target目标，以便在多用户模式下启动。

上述配置文件中定义的kube-apiserver服务将以指定的参数运行，这些参数包括：

- `--v=2` 指定日志级别为2，打印详细的API Server日志。
- `--allow-privileged=true` 允许特权容器运行。
- `--bind-address=0.0.0.0` 绑定API Server监听的IP地址。
- `--secure-port=6443` 指定API Server监听的安全端口。
- `--advertise-address=192.168.1.31` 广告API Server的地址。
- `--service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112` 指定服务CIDR范围。
- `--service-node-port-range=30000-32767` 指定NodePort的范围。
- `--etcd-servers=https://192.168.1.31:2379,https://192.168.1.32:2379,https://192.168.1.33:2379` 指定etcd服务器的地址。
- `--etcd-cafile` 指定etcd服务器的CA证书。
- `--etcd-certfile` 指定etcd服务器的证书。
- `--etcd-keyfile` 指定etcd服务器的私钥。
- `--client-ca-file` 指定客户端CA证书。
- `--tls-cert-file` 指定服务的证书。
- `--tls-private-key-file` 指定服务的私钥。
- `--kubelet-client-certificate` 和 `--kubelet-client-key` 指定与kubelet通信的客户端证书和私钥。
- `--service-account-key-file` 指定服务账户公钥文件。
- `--service-account-signing-key-file` 指定服务账户签名密钥文件。
- `--service-account-issuer` 指定服务账户的发布者。
- `--kubelet-preferred-address-types` 指定kubelet通信时的首选地址类型。
- `--enable-admission-plugins` 启用一系列准入插件。
- `--authorization-mode` 指定授权模式。
- `--enable-bootstrap-token-auth` 启用引导令牌认证。
- `--requestheader-client-ca-file` 指定请求头中的客户端CA证书。
- `--proxy-client-cert-file` 和 `--proxy-client-key-file` 指定代理客户端的证书和私钥。
- `--requestheader-allowed-names` 指定请求头中允许的名字。
- `--requestheader-group-headers` 指定请求头中的组头。
- `--requestheader-extra-headers-prefix` 指定请求头中的额外头前缀。
- `--requestheader-username-headers` 指定请求头中的用户名头。
- `--enable-aggregator-routing` 启用聚合路由。

整个配置文件为Kubernetes API Server提供了必要的参数，以便正确地启动和运行。
```

### 6.1.4启动apiserver（所有master节点）

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now kube-apiserver.service
# 启用并立即启动kube-apiserver.service单元。kube-apiserver.service是kube-apiserver守护进程的systemd服务单元。

systemctl restart kube-apiserver.service
# 重启kube-apiserver.service单元，即重新启动etcd守护进程。

systemctl status kube-apiserver.service
# kube-apiserver.service单元的当前状态，包括运行状态、是否启用等信息。
```

## 6.2.配置kube-controller-manager service

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
      --bind-address=0.0.0.0 \\
      --root-ca-file=/etc/kubernetes/pki/ca.pem \\
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \\
      --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \\
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key \\
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
      --leader-elect=true \\
      --use-service-account-credentials=true \\
      --node-monitor-grace-period=40s \\
      --node-monitor-period=5s \\
      --controllers=*,bootstrapsigner,tokencleaner \\
      --allocate-node-cidrs=true \\
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112 \\
      --cluster-cidr=172.16.0.0/12,fc00:2222::/112 \\
      --node-cidr-mask-size-ipv4=24 \\
      --node-cidr-mask-size-ipv6=120 \\
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF



# 关闭IPv6 
# 删除 --service-cluster-ip-range 中的IPv6地址
# 删除 --cluster-cidr 中的IPv6地址
# 删除 --node-cidr-mask-size-ipv6=120
cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
      --v=2 \\
      --bind-address=0.0.0.0 \\
      --root-ca-file=/etc/kubernetes/pki/ca.pem \\
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \\
      --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \\
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key \\
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
      --leader-elect=true \\
      --use-service-account-credentials=true \\
      --node-monitor-grace-period=40s \\
      --node-monitor-period=5s \\
      --controllers=*,bootstrapsigner,tokencleaner \\
      --allocate-node-cidrs=true \\
      --service-cluster-ip-range=10.96.0.0/12 \\
      --cluster-cidr=172.16.0.0/12 \\
      --node-cidr-mask-size-ipv4=24 \\
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
```

参数

```shell
这是一个用于启动 Kubernetes 控制器管理器的 systemd 服务单元文件。下面是对每个部分的详细解释：

[Unit]：单元的基本信息部分，用于描述和标识这个服务单元。
Description：服务单元的描述信息，说明了该服务单元的作用，这里是 Kubernetes 控制器管理器。
Documentation：可选项，提供了关于该服务单元的文档链接。
After：定义了该服务单元在哪些其他单元之后启动，这里是 network.target，即在网络服务启动之后启动。

[Service]：定义了服务的运行参数和行为。
ExecStart：指定服务启动时执行的命令，这里是 /usr/local/bin/kube-controller-manager，并通过后续的行继续传递了一系列的参数设置。
Restart：定义了服务在退出后的重新启动策略，这里设置为 always，表示总是重新启动服务。
RestartSec：定义了重新启动服务的时间间隔，这里设置为 10 秒。

[Install]：定义了如何安装和启用服务单元。
WantedBy：指定了服务单元所属的 target，这里是 multi-user.target，表示启动多用户模式下的服务。
在 ExecStart 中传递的参数说明如下：

--v=2：设置日志的详细级别为 2。
--bind-address=0.0.0.0：绑定的 IP 地址，用于监听 Kubernetes 控制平面的请求，这里设置为 0.0.0.0，表示监听所有网络接口上的请求。
--root-ca-file：根证书文件的路径，用于验证其他组件的证书。
--cluster-signing-cert-file：用于签名集群证书的证书文件路径。
--cluster-signing-key-file：用于签名集群证书的私钥文件路径。
--service-account-private-key-file：用于签名服务账户令牌的私钥文件路径。
--kubeconfig：kubeconfig 文件的路径，包含了与 Kubernetes API 服务器通信所需的配置信息。
--leader-elect=true：启用 Leader 选举机制，确保只有一个控制器管理器作为 leader 在运行。
--use-service-account-credentials=true：使用服务账户的凭据进行认证和授权。
--node-monitor-grace-period=40s：节点监控的优雅退出时间，节点长时间不响应时会触发节点驱逐。
--node-monitor-period=5s：节点监控的检测周期，用于检测节点是否正常运行。
--controllers：指定要运行的控制器类型，在这里使用了通配符 *，表示运行所有的控制器，同时还包括了 bootstrapsigner 和 tokencleaner 控制器。
--allocate-node-cidrs=true：为节点分配 CIDR 子网，用于分配 Pod 网络地址。
--service-cluster-ip-range：定义 Service 的 IP 范围，这里设置为 10.96.0.0/12 和 fd00::/108。
--cluster-cidr：定义集群的 CIDR 范围，这里设置为 172.16.0.0/12 和 fc00::/48。
--node-cidr-mask-size-ipv4：分配给每个节点的 IPv4 子网掩码大小，默认是 24。
--node-cidr-mask-size-ipv6：分配给每个节点的 IPv6 子网掩码大小，默认是 120。
--requestheader-client-ca-file：设置请求头中客户端 CA 的证书文件路径，用于认证请求头中的 CA 证书。

这个服务单元文件描述了 Kubernetes 控制器管理器的启动参数和行为，并且定义了服务的依赖关系和重新启动策略。通过 systemd 启动该服务单元，即可启动 Kubernetes 控制器管理器组件。
```

### 6.2.1启动kube-controller-manager，并查看状态

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now kube-controller-manager.service
# 启用并立即启动kube-controller-manager.service单元。kube-controller-manager.service是kube-controller-manager守护进程的systemd服务单元。

systemctl restart kube-controller-manager.service
# 重启kube-controller-manager.service单元，即重新启动etcd守护进程。

systemctl status kube-controller-manager.service
# kube-controller-manager.service单元的当前状态，包括运行状态、是否启用等信息。
```

## 6.3.配置kube-scheduler service

### 6.3.1所有master节点配置，且配置相同

```shell
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF

[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
      --v=2 \\
      --bind-address=0.0.0.0 \\
      --leader-elect=true \\
      --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF
```

参数

```shell
这是一个用于启动 Kubernetes 调度器的 systemd 服务单元文件。下面是对每个部分的详细解释：

[Unit]：单元的基本信息部分，用于描述和标识这个服务单元。
Description：服务单元的描述信息，说明了该服务单元的作用，这里是 Kubernetes 调度器。
Documentation：可选项，提供了关于该服务单元的文档链接。
After：定义了该服务单元在哪些其他单元之后启动，这里是 network.target，即在网络服务启动之后启动。

[Service]：定义了服务的运行参数和行为。
ExecStart：指定服务启动时执行的命令，这里是 /usr/local/bin/kube-scheduler，并通过后续的行继续传递了一系列的参数设置。
Restart：定义了服务在退出后的重新启动策略，这里设置为 always，表示总是重新启动服务。
RestartSec：定义了重新启动服务的时间间隔，这里设置为 10 秒。

[Install]：定义了如何安装和启用服务单元。
WantedBy：指定了服务单元所属的 target，这里是 multi-user.target，表示启动多用户模式下的服务。

在 ExecStart 中传递的参数说明如下：

--v=2：设置日志的详细级别为 2。
--bind-address=0.0.0.0：绑定的 IP 地址，用于监听 Kubernetes 控制平面的请求，这里设置为 0.0.0.0，表示监听所有网络接口上的请求。
--leader-elect=true：启用 Leader 选举机制，确保只有一个调度器作为 leader 在运行。
--kubeconfig=/etc/kubernetes/scheduler.kubeconfig：kubeconfig 文件的路径，包含了与 Kubernetes API 服务器通信所需的配置信息。

这个服务单元文件描述了 Kubernetes 调度器的启动参数和行为，并且定义了服务的依赖关系和重新启动策略。通过 systemd 启动该服务单元，即可启动 Kubernetes 调度器组件。
```

### 6.3.2启动并查看服务状态

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now kube-scheduler.service
# 启用并立即启动kube-scheduler.service单元。kube-scheduler.service是kube-scheduler守护进程的systemd服务单元。

systemctl restart kube-scheduler.service
# 重启kube-scheduler.service单元，即重新启动etcd守护进程。

systemctl status kube-scheduler.service
# kube-scheduler.service单元的当前状态，包括运行状态、是否启用等信息。
```

# 7.TLS Bootstrapping配置

## 7.1在master01上配置

```shell
# 在《5.高可用配置》选择使用那种高可用方案
# 若使用 haproxy、keepalived 那么为 `--server=https://192.168.1.36:9443`
# 若使用 nginx方案，那么为 `--server=https://127.0.0.1:8443`

kubectl config set-cluster kubernetes     \
--certificate-authority=/etc/kubernetes/pki/ca.pem     \
--embed-certs=true     --server=https://127.0.0.1:8443     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
# 这是一个使用 kubectl 命令设置 Kubernetes 集群配置的命令示例。下面是对每个选项的详细解释：
# 
# config set-cluster kubernetes：指定要设置的集群名称为 "kubernetes"，表示要修改名为 "kubernetes" 的集群配置。
# --certificate-authority=/etc/kubernetes/pki/ca.pem：指定证书颁发机构（CA）的证书文件路径，用于验证服务器证书的有效性。
# --embed-certs=true：将证书文件嵌入到生成的 kubeconfig 文件中。这样可以避免在 kubeconfig 文件中引用外部证书文件。
# --server=https://127.0.0.1:8443：指定 Kubernetes API 服务器的地址和端口，这里使用的是 https 协议和本地地址（127.0.0.1），端口号为 8443。你可以根据实际环境修改该参数。
# --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig：指定 kubeconfig 文件的路径和名称，这里是 /etc/kubernetes/bootstrap-kubelet.kubeconfig。
# 通过执行此命令，你可以设置名为 "kubernetes" 的集群配置，并提供 CA 证书、API 服务器地址和端口，并将这些配置信息嵌入到 bootstrap-kubelet.kubeconfig 文件中。这个 kubeconfig 文件可以用于认证和授权 kubelet 组件与 Kubernetes API 服务器之间的通信。请确保路径和文件名与实际环境中的配置相匹配。


# 可以使用这个命令进行创建token也可以使用我的
echo "$(head -c 6 /dev/urandom | md5sum | head -c 6)"."$(head -c 16 /dev/urandom | md5sum | head -c 16)"

kubectl config set-credentials tls-bootstrap-token-user     \
--token=c8ad9c.2e4d610cf3e7426e \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
# 这是一个使用 kubectl 命令设置凭证信息的命令示例。下面是对每个选项的详细解释：
# 
# config set-credentials tls-bootstrap-token-user：指定要设置的凭证名称为 "tls-bootstrap-token-user"，表示要修改名为 "tls-bootstrap-token-user" 的用户凭证配置。
# --token=c8ad9c.2e4d610cf3e7426e：指定用户的身份验证令牌（token）。在这个示例中，令牌是 c8ad9c.2e4d610cf3e7426e。你可以根据实际情况修改该令牌。
# --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig：指定 kubeconfig 文件的路径和名称，这里是 /etc/kubernetes/bootstrap-kubelet.kubeconfig。
# 通过执行此命令，你可以设置名为 "tls-bootstrap-token-user" 的用户凭证，并将令牌信息加入到 bootstrap-kubelet.kubeconfig 文件中。这个 kubeconfig 文件可以用于认证和授权 kubelet 组件与 Kubernetes API 服务器之间的通信。请确保路径和文件名与实际环境中的配置相匹配。

kubectl config set-context tls-bootstrap-token-user@kubernetes     \
--cluster=kubernetes     \
--user=tls-bootstrap-token-user     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
# 这是一个使用 kubectl 命令设置上下文信息的命令示例。下面是对每个选项的详细解释：
# 
# config set-context tls-bootstrap-token-user@kubernetes：指定要设置的上下文名称为 "tls-bootstrap-token-user@kubernetes"，表示要修改名为 "tls-bootstrap-token-user@kubernetes" 的上下文配置。
# --cluster=kubernetes：指定上下文关联的集群名称为 "kubernetes"，表示使用名为 "kubernetes" 的集群配置。
# --user=tls-bootstrap-token-user：指定上下文关联的用户凭证名称为 "tls-bootstrap-token-user"，表示使用名为 "tls-bootstrap-token-user" 的用户凭证配置。
# --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig：指定 kubeconfig 文件的路径和名称，这里是 /etc/kubernetes/bootstrap-kubelet.kubeconfig。
# 通过执行此命令，你可以设置名为 "tls-bootstrap-token-user@kubernetes" 的上下文，并将其关联到名为 "kubernetes" 的集群配置和名为 "tls-bootstrap-token-user" 的用户凭证配置。这样，bootstrap-kubelet.kubeconfig 文件就包含了完整的上下文信息，可以用于指定与 Kubernetes 集群建立连接时要使用的集群和凭证。请确保路径和文件名与实际环境中的配置相匹配。

kubectl config use-context tls-bootstrap-token-user@kubernetes     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
# 这是一个使用 kubectl 命令设置当前上下文的命令示例。下面是对每个选项的详细解释：
# 
# config use-context tls-bootstrap-token-user@kubernetes：指定要使用的上下文名称为 "tls-bootstrap-token-user@kubernetes"，表示要将当前上下文切换为名为 "tls-bootstrap-token-user@kubernetes" 的上下文。
# --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig：指定 kubeconfig 文件的路径和名称，这里是 /etc/kubernetes/bootstrap-kubelet.kubeconfig。
# 通过执行此命令，你可以将当前上下文设置为名为 "tls-bootstrap-token-user@kubernetes" 的上下文。这样，当你执行其他 kubectl 命令时，它们将使用该上下文与 Kubernetes 集群进行交互。请确保路径和文件名与实际环境中的配置相匹配。


# token的位置在bootstrap.secret.yaml，如果修改的话到这个文件修改
mkdir -p /root/.kube ; cp /etc/kubernetes/admin.kubeconfig /root/.kube/config
```

## 7.2查看集群状态，没问题的话继续后续操作

```shell
# 1.28 版本只能查看到一个etcd 属于正常现象
# export ETCDCTL_API=3
# etcdctl --endpoints="192.168.1.33:2379,192.168.1.32:2379,192.168.1.31:2379" --cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem --cert=/etc/kubernetes/pki/etcd/etcd.pem --key=/etc/kubernetes/pki/etcd/etcd-key.pem  endpoint status --write-out=table

kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
scheduler            Healthy   ok    
controller-manager   Healthy   ok    
etcd-0               Healthy   ok 

# 写入bootstrap-token
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
# 切记执行，别忘记！！！
kubectl create -f bootstrap.secret.yaml
```

# 8.node节点配置

## 8.1.在master01上将证书复制到node节点

```shell
cd /etc/kubernetes/

for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02; do ssh $NODE mkdir -p /etc/kubernetes/pki; for FILE in pki/ca.pem pki/ca-key.pem pki/front-proxy-ca.pem bootstrap-kubelet.kubeconfig kube-proxy.kubeconfig; do scp /etc/kubernetes/$FILE $NODE:/etc/kubernetes/${FILE}; done; done
```

## 8.2.kubelet配置

**注意 ： 8.2.1 和 8.2.2 需要和 上方 2.1 和 2.2 对应起来**

### 8.2.1当使用docker作为Runtime

```shell
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=network-online.target firewalld.service cri-docker.service docker.socket containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/cri-dockerd.sock  \\
    --node-labels=node.kubernetes.io/node= 


[Install]
WantedBy=multi-user.target
EOF

# 这是一个表示 Kubernetes Kubelet 服务的 systemd 单位文件示例。下面是对每个节（[Unit]、[Service]、[Install]）的详细解释：
# 
# [Unit]
# 
# Description=Kubernetes Kubelet：指定了此单位文件对应的服务描述信息为 "Kubernetes Kubelet"。
# Documentation=...：指定了对该服务的文档链接。
# - After: 说明该服务在哪些其他服务之后启动，这里是在网络在线、firewalld服务和containerd服务后启动。
# - Wants: 说明该服务想要的其他服务，这里是网络在线服务。
# - Requires: 说明该服务需要的其他服务，这里是docker.socket和containerd.service。
# [Service]
# 
# ExecStart=/usr/local/bin/kubelet ...：指定了启动 Kubelet 服务的命令和参数。这里使用的是 /usr/local/bin/kubelet 命令，并传递了一系列参数来配置 Kubelet 的运行。这些参数包括：
# --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig：指定了用于引导 kubelet 的 kubeconfig 文件的路径和名称。
# --kubeconfig=/etc/kubernetes/kubelet.kubeconfig：指定了 kubelet 的 kubeconfig 文件的路径和名称。
# --config=/etc/kubernetes/kubelet-conf.yml：指定了 kubelet 的配置文件的路径和名称。
# --container-runtime-endpoint=unix:///run/cri-dockerd.sock：指定了容器运行时接口的端点地址，这里使用的是 Docker 运行时（cri-dockerd）的 UNIX 套接字。
# --node-labels=node.kubernetes.io/node=：指定了节点的标签。这里的示例只给节点添加了一个简单的标签 node.kubernetes.io/node=。
# [Install]
# 
# WantedBy=multi-user.target：指定了在 multi-user.target 被启动时，该服务应该被启用。
# 通过这个单位文件，你可以配置 Kubelet 服务的启动参数，指定相关的配置文件和凭证文件，以及定义节点的标签。请确认路径和文件名与你的实际环境中的配置相匹配。


# IPv6示例
# 若不使用IPv6那么忽略此项即可
# 下方 --node-ip 更换为每个节点的IP即可
cat > /usr/lib/systemd/system/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=network-online.target firewalld.service cri-docker.service docker.socket containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/cri-dockerd.sock  \\
    --node-labels=node.kubernetes.io/node=   \\
    --node-ip=192.168.1.31,fc00::31
[Install]
WantedBy=multi-user.target
EOF
```

### 8.2.2当使用Containerd作为Runtime （推荐）

```shell
mkdir -p /var/lib/kubelet /var/log/kubernetes /etc/systemd/system/kubelet.service.d /etc/kubernetes/manifests/

# 所有k8s节点配置kubelet service
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock  \\
    --node-labels=node.kubernetes.io/node=

[Install]
WantedBy=multi-user.target
EOF

# 这是一个表示 Kubernetes Kubelet 服务的 systemd 单位文件示例。与之前相比，添加了 After 和 Requires 字段来指定依赖关系。
# 
# [Unit]
# 
# Description=Kubernetes Kubelet：指定了此单位文件对应的服务描述信息为 "Kubernetes Kubelet"。
# Documentation=...：指定了对该服务的文档链接。
# - After: 说明该服务在哪些其他服务之后启动，这里是在网络在线、firewalld服务和containerd服务后启动。
# - Wants: 说明该服务想要的其他服务，这里是网络在线服务。
# - Requires: 说明该服务需要的其他服务，这里是docker.socket和containerd.service。
# [Service]
# 
# ExecStart=/usr/local/bin/kubelet ...：指定了启动 Kubelet 服务的命令和参数，与之前的示例相同。
# --container-runtime-endpoint=unix:///run/containerd/containerd.sock：修改了容器运行时接口的端点地址，将其更改为使用 containerd 运行时（通过 UNIX 套接字）。
# [Install]
# 
# WantedBy=multi-user.target：指定了在 multi-user.target 被启动时，该服务应该被启用。
# 通过这个单位文件，你可以配置 Kubelet 服务的启动参数，并指定了它依赖的 containerd 服务。确保路径和文件名与你实际环境中的配置相匹配。



# IPv6示例
# 若不使用IPv6那么忽略此项即可
# 下方 --node-ip 更换为每个节点的IP即可
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock  \\
    --node-labels=node.kubernetes.io/node=  \\
    --node-ip=192.168.1.31,fc00::31
[Install]
WantedBy=multi-user.target
EOF
```

### 8.2.3所有k8s节点创建kubelet的配置文件

```shell
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
    clientCAFile: /etc/kubernetes/pki/ca.pem
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

# 这是一个Kubelet的配置文件，用于配置Kubelet的各项参数。
# 
# - apiVersion: kubelet.config.k8s.io/v1beta1：指定了配置文件的API版本为kubelet.config.k8s.io/v1beta1。
# - kind: KubeletConfiguration：指定了配置类别为KubeletConfiguration。
# - address: 0.0.0.0：指定了Kubelet监听的地址为0.0.0.0。
# - port: 10250：指定了Kubelet监听的端口为10250。
# - readOnlyPort: 10255：指定了只读端口为10255，用于提供只读的状态信息。
# - authentication：指定了认证相关的配置信息。
#   - anonymous.enabled: false：禁用了匿名认证。
#   - webhook.enabled: true：启用了Webhook认证。
#   - x509.clientCAFile: /etc/kubernetes/pki/ca.pem：指定了X509证书的客户端CA文件路径。
# - authorization：指定了授权相关的配置信息。
#   - mode: Webhook：指定了授权模式为Webhook。
#   - webhook.cacheAuthorizedTTL: 5m0s：指定了授权缓存时间段为5分钟。
#   - webhook.cacheUnauthorizedTTL: 30s：指定了未授权缓存时间段为30秒。
# - cgroupDriver: systemd：指定了Cgroup驱动为systemd。
# - cgroupsPerQOS: true：启用了每个QoS类别一个Cgroup的设置。
# - clusterDNS: 指定了集群的DNS服务器地址列表。
#   - 10.96.0.10：指定了DNS服务器地址为10.96.0.10。
# - clusterDomain: cluster.local：指定了集群的域名后缀为cluster.local。
# - containerLogMaxFiles: 5：指定了容器日志文件保留的最大数量为5个。
# - containerLogMaxSize: 10Mi：指定了容器日志文件的最大大小为10Mi。
# - contentType: application/vnd.kubernetes.protobuf：指定了内容类型为protobuf。
# - cpuCFSQuota: true：启用了CPU CFS Quota。
# - cpuManagerPolicy: none：禁用了CPU Manager。
# - cpuManagerReconcilePeriod: 10s：指定了CPU管理器的调整周期为10秒。
# - enableControllerAttachDetach: true：启用了控制器的挂载和拆卸。
# - enableDebuggingHandlers: true：启用了调试处理程序。
# - enforceNodeAllocatable: 指定了强制节点可分配资源的列表。
#   - pods：强制节点可分配pods资源。
# - eventBurst: 10：指定了事件突发的最大数量为10。
# - eventRecordQPS: 5：指定了事件记录的最大请求量为5。
# - evictionHard: 指定了驱逐硬性限制参数的配置信息。
#   - imagefs.available: 15%：指定了镜像文件系统可用空间的限制为15%。
#   - memory.available: 100Mi：指定了可用内存的限制为100Mi。
#   - nodefs.available: 10%：指定了节点文件系统可用空间的限制为10%。
#   - nodefs.inodesFree: 5%：指定了节点文件系统可用inode的限制为5%。
# - evictionPressureTransitionPeriod: 5m0s：指定了驱逐压力转换的时间段为5分钟。
# - failSwapOn: true：指定了在发生OOM时禁用交换分区。
# - fileCheckFrequency: 20s：指定了文件检查频率为20秒。
# - hairpinMode: promiscuous-bridge：设置了Hairpin Mode为"promiscuous-bridge"。
# - healthzBindAddress: 127.0.0.1：指定了健康检查的绑定地址为127.0.0.1。
# - healthzPort: 10248：指定了健康检查的端口为10248。
# - httpCheckFrequency: 20s：指定了HTTP检查的频率为20秒。
# - imageGCHighThresholdPercent: 85：指定了镜像垃圾回收的上阈值为85%。
# - imageGCLowThresholdPercent: 80：指定了镜像垃圾回收的下阈值为80%。
# - imageMinimumGCAge: 2m0s：指定了镜像垃圾回收的最小时间为2分钟。
# - iptablesDropBit: 15：指定了iptables的Drop Bit为15。
# - iptablesMasqueradeBit: 14：指定了iptables的Masquerade Bit为14。
# - kubeAPIBurst: 10：指定了KubeAPI的突发请求数量为10个。
# - kubeAPIQPS: 5：指定了KubeAPI的每秒请求频率为5个。
# - makeIPTablesUtilChains: true：指定了是否使用iptables工具链。
# - maxOpenFiles: 1000000：指定了最大打开文件数为1000000。
# - maxPods: 110：指定了最大的Pod数量为110。
# - nodeStatusUpdateFrequency: 10s：指定了节点状态更新的频率为10秒。
# - oomScoreAdj: -999：指定了OOM Score Adjustment为-999。
# - podPidsLimit: -1：指定了Pod的PID限制为-1，表示无限制。
# - registryBurst: 10：指定了Registry的突发请求数量为10个。
# - registryPullQPS: 5：指定了Registry的每秒拉取请求数量为5个。
# - resolvConf: /etc/resolv.conf：指定了resolv.conf的文件路径。
# - rotateCertificates: true：指定了是否轮转证书。
# - runtimeRequestTimeout: 2m0s：指定了运行时请求的超时时间为2分钟。
# - serializeImagePulls: true：指定了是否序列化镜像拉取。
# - staticPodPath: /etc/kubernetes/manifests：指定了静态Pod的路径。
# - streamingConnectionIdleTimeout: 4h0m0s：指定了流式连接的空闲超时时间为4小时。
# - syncFrequency: 1m0s：指定了同步频率为1分钟。
# - volumeStatsAggPeriod: 1m0s：指定了卷统计聚合周期为1分钟。
```

### 8.2.4启动kubelet

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now kubelet.service
# 启用并立即启动kubelet.service单元。kubelet.service是kubelet守护进程的systemd服务单元。

systemctl restart kubelet.service
# 重启kubelet.service单元，即重新启动kubelet守护进程。

systemctl status kubelet.service
# kubelet.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 8.2.5查看集群

```shell
[root@k8s-master01 ~]# kubectl  get node
NAME           STATUS   ROLES    AGE   VERSION
k8s-master01   NotReady    <none>   16s   v1.32.0
k8s-master02   NotReady    <none>   13s   v1.32.0
k8s-master03   NotReady    <none>   12s   v1.32.0
k8s-node01     NotReady    <none>   10s   v1.32.0
k8s-node02     NotReady    <none>   9s    v1.32.0
[root@k8s-master01 ~]#
```

### 8.2.6查看容器运行时

```shell
[root@k8s-master01 ~]# kubectl describe node | grep Runtime
  Container Runtime Version:  containerd://2.0.1
  Container Runtime Version:  containerd://2.0.1
  Container Runtime Version:  containerd://2.0.1
  Container Runtime Version:  containerd://2.0.1
  Container Runtime Version:  containerd://2.0.1
[root@k8s-master01 ~]# kubectl describe node | grep Runtime
  Container Runtime Version:  docker://27.4.0
  Container Runtime Version:  docker://27.4.0
  Container Runtime Version:  docker://27.4.0
  Container Runtime Version:  docker://27.4.0
  Container Runtime Version:  docker://27.4.0
```

## 8.3.kube-proxy配置

### 8.3.1将kubeconfig发送至其他节点

```shell
# master-1执行
for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02; do scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig; done
```

### 8.3.2所有k8s节点添加kube-proxy的service文件

```shell
cat >  /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy.yaml \\
  --cluster-cidr=172.16.0.0/12,fc00:2222::/112 \\
  --v=2
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF


# 关闭IPv6
# 删除 --cluster-cidr 的IPv6地址
cat >  /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy.yaml \\
  --cluster-cidr=172.16.0.0/12 \\
  --v=2
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF

# 这是一个 systemd 服务单元文件的示例，用于配置 Kubernetes Kube Proxy 服务。下面是对其中一些字段的详细解释：
# 
# [Unit]
# 
# Description: 描述了该服务单元的用途，这里是 Kubernetes Kube Proxy。
# Documentation: 指定了该服务单元的文档地址，即 https://github.com/kubernetes/kubernetes。
# After: 指定该服务单元应在 network.target（网络目标）之后启动。
# [Service]
# 
# ExecStart: 指定了启动 Kube Proxy 服务的命令。通过 /usr/local/bin/kube-proxy 命令启动，并指定了配置文件的路径为 /etc/kubernetes/kube-proxy.yaml，同时指定了日志级别为 2。
# Restart: 配置了服务在失败或退出后自动重启。
# RestartSec: 配置了重启间隔，这里是每次重启之间的等待时间为 10 秒。
# [Install]
# 
# WantedBy: 指定了该服务单元的安装目标为 multi-user.target（多用户目标），表示该服务将在多用户模式下启动。
# 通过配置这些字段，你可以启动和管理 Kubernetes Kube Proxy 服务。请注意，你需要根据实际情况修改 ExecStart 中的路径和文件名，确保与你的环境一致。另外，可以根据需求修改其他字段的值，以满足你的特定要求。
```

### 8.3.3所有k8s节点添加kube-proxy的配置

```shell
cat > /etc/kubernetes/kube-proxy.yaml << EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 172.16.0.0/12,fc00:2222::/112
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

# 这是一个Kubernetes的kube-proxy组件配置文件示例。以下是每个配置项的详细解释：
# 
# 1. apiVersion: kubeproxy.config.k8s.io/v1alpha1
#    - 指定该配置文件的API版本。
# 
# 2. bindAddress: 0.0.0.0
#    - 指定kube-proxy使用的监听地址。0.0.0.0表示监听所有网络接口。
# 
# 3. clientConnection:
#    - 客户端连接配置项。
# 
#    a. acceptContentTypes: ""
#       - 指定接受的内容类型。
# 
#    b. burst: 10
#       - 客户端请求超出qps设置时的最大突发请求数。
# 
#    c. contentType: application/vnd.kubernetes.protobuf
#       - 指定客户端请求的内容类型。
# 
#    d. kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
#       - kube-proxy使用的kubeconfig文件路径。
# 
#    e. qps: 5
#       - 每秒向API服务器发送的请求数量。
# 
# 4. clusterCIDR: 172.16.0.0/12,fc00:2222::/112
#    - 指定集群使用的CIDR范围，用于自动分配Pod IP。
# 
# 5. configSyncPeriod: 15m0s
#    - 指定kube-proxy配置同步到节点的频率。
# 
# 6. conntrack:
#    - 连接跟踪设置。
# 
#    a. max: null
#       - 指定连接跟踪的最大值。
# 
#    b. maxPerCore: 32768
#       - 指定每个核心的最大连接跟踪数。
# 
#    c. min: 131072
#       - 指定最小的连接跟踪数。
# 
#    d. tcpCloseWaitTimeout: 1h0m0s
#       - 指定处于CLOSE_WAIT状态的TCP连接的超时时间。
# 
#    e. tcpEstablishedTimeout: 24h0m0s
#       - 指定已建立的TCP连接的超时时间。
# 
# 7. enableProfiling: false
#    - 是否启用性能分析。
# 
# 8. healthzBindAddress: 0.0.0.0:10256
#    - 指定健康检查监听地址和端口。
# 
# 9. hostnameOverride: ""
#    - 指定覆盖默认主机名的值。
# 
# 10. iptables:
#     - iptables设置。
# 
#     a. masqueradeAll: false
#        - 是否对所有流量使用IP伪装。
# 
#     b. masqueradeBit: 14
#        - 指定伪装的Bit标记。
# 
#     c. minSyncPeriod: 0s
#        - 指定同步iptables规则的最小间隔。
# 
#     d. syncPeriod: 30s
#        - 指定同步iptables规则的时间间隔。
# 
# 11. ipvs:
#     - ipvs设置。
# 
#     a. masqueradeAll: true
#        - 是否对所有流量使用IP伪装。
# 
#     b. minSyncPeriod: 5s
#        - 指定同步ipvs规则的最小间隔。
# 
#     c. scheduler: "rr"
#        - 指定ipvs默认使用的调度算法。
# 
#     d. syncPeriod: 30s
#        - 指定同步ipvs规则的时间间隔。
# 
# 12. kind: KubeProxyConfiguration
#     - 指定该配置文件的类型。
# 
# 13. metricsBindAddress: 127.0.0.1:10249
#     - 指定指标绑定的地址和端口。
# 
# 14. mode: "ipvs"
#     - 指定kube-proxy的模式。这里指定为ipvs，使用IPVS代理模式。
# 
# 15. nodePortAddresses: null
#     - 指定可用于NodePort的网络地址。
# 
# 16. oomScoreAdj: -999
#     - 指定kube-proxy的OOM优先级。
# 
# 17. portRange: ""
#     - 指定可用于服务端口范围。
# 
# 18. udpIdleTimeout: 250ms
#     - 指定UDP连接的空闲超时时间。
```

### 8.3.4启动kube-proxy

```shell
 systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now kube-proxy.service
# 启用并立即启动kube-proxy.service单元。kube-proxy.service是kube-proxy守护进程的systemd服务单元。

systemctl restart kube-proxy.service
# 重启kube-proxy.service单元，即重新启动kube-proxy守护进程。

systemctl status kube-proxy.service
# kube-proxy.service单元的当前状态，包括运行状态、是否启用等信息。
```

# 9.安装网络插件

**注意 9.1 和 9.2 二选其一即可，建议在此处创建好快照后在进行操作，后续出问题可以回滚**

** centos7 要升级libseccomp 不然 无法安装网络插件**

```shell
# https://github.com/opencontainers/runc/releases
# 升级runc
# wget https://mirrors.chenby.cn/https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64

install -m 755 runc.amd64 /usr/local/sbin/runc
cp -p /usr/local/sbin/runc  /usr/local/bin/runc
cp -p /usr/local/sbin/runc  /usr/bin/runc

#查看当前版本
[root@k8s-master-1 ~]# rpm -qa | grep libseccomp
libseccomp-2.5.2-2.el9.x86_64

#下载高于2.4以上的包
# yum -y install http://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm
# 清华源
# yum -y install https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm
```

## 9.1安装Calico

### 9.1.1更改calico网段

```shell

# 安装operator
kubectl create -f https://mirrors.chenby.cn/https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml


# 下载配置文件
curl https://mirrors.chenby.cn/https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml -O




# 修改地址池
vim custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 172.16.0.0/12 
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}


# 执行安装
kubectl create -f custom-resources.yaml



# 安装客户端
curl -L https://mirrors.chenby.cn/https://github.com/projectcalico/calico/releases/download/v3.28.2/calicoctl-linux-amd64 -o calicoctl


# 给客户端添加执行权限
chmod +x ./calicoctl


# 查看集群节点
./calicoctl get nodes
# 查看集群节点状态
./calicoctl node status
#查看地址池
./calicoctl get ipPool
./calicoctl get ipPool -o yaml


```

### 9.1.2查看容器状态

```shell
# calico 初始化会很慢 需要耐心等待一下，大约十分钟左右
[root@k8s-master01 ~]# kubectl get pod -A
NAMESPACE          NAME                                       READY   STATUS              RESTARTS        AGE
calico-apiserver   calico-apiserver-574778dd99-gn6sz          1/1     Running             0               117s
calico-apiserver   calico-apiserver-574778dd99-j2d9b          1/1     Running             0               117s
calico-system      calico-kube-controllers-5486fc7dd4-kj8lv   1/1     Running             0               8m31s
calico-system      calico-node-7xjrq                          1/1     Running             0               8m32s
calico-system      calico-node-p9mpf                          1/1     Running             0               8m31s
calico-system      calico-node-vc8vh                          1/1     Running             0               8m32s
calico-system      calico-node-wgdkb                          1/1     Running             0               8m31s
calico-system      calico-node-zwthm                          1/1     Running             0               8m32s
calico-system      calico-typha-859bf9f49d-gtj6z              1/1     Running             0               8m28s
calico-system      calico-typha-859bf9f49d-jzjw9              1/1     Running             0               8m28s
calico-system      calico-typha-859bf9f49d-phdcf              1/1     Running             0               8m32s
calico-system      csi-node-driver-5llzf                      2/2     Running             0               8m31s
calico-system      csi-node-driver-9rgjn                      2/2     Running             0               8m31s
calico-system      csi-node-driver-j6gl8                      2/2     Running             0               8m31s
calico-system      csi-node-driver-k4dqg                      2/2     Running             1 (5m28s ago)   8m31s
calico-system      csi-node-driver-rvhwd                      2/2     Running             0               8m31s
tigera-operator    tigera-operator-89c775547-m46h4            1/1     Running             0               9m3s
[root@k8s-master01 ~]#
```

## 9.2 安装cilium(推荐)

### 9.2.1 安装helm

```shell
# [root@k8s-master01 ~]# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# [root@k8s-master01 ~]# chmod 700 get_helm.sh
# [root@k8s-master01 ~]# ./get_helm.sh

# wget https://mirrors.huaweicloud.com/helm/v3.16.3/helm-v3.16.3-linux-amd64.tar.gz
tar xvf helm-*-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
```

### 9.2.2 安装cilium

```shell
# 添加源
helm repo add cilium https://helm.cilium.io

# 修改为国内源
helm pull cilium/cilium
tar xvf cilium-*.tgz
cd cilium/

# sed -i "s#quay.io/#quay.m.daocloud.io/#g" values.yaml

# 默认参数安装
helm install  cilium ./cilium/ -n kube-system

# 启用ipv6
# helm install cilium ./cilium/ --namespace kube-system --set ipv6.enabled=true

# 启用路由信息和监控插件
# helm install cilium ./cilium/ --namespace kube-system --set ipv6.enabled=true --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" 
```

### 9.2.3 查看

```shell
[root@k8s-master01 ~]# kubectl  get pod -A | grep cil
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   cilium-2tnfb                       1/1     Running   0          60s
kube-system   cilium-5tgcb                       1/1     Running   0          60s
kube-system   cilium-6shf5                       1/1     Running   0          60s
kube-system   cilium-ccbcx                       1/1     Running   0          60s
kube-system   cilium-cppft                       1/1     Running   0          60s
kube-system   cilium-operator-675f685d59-7q27q   1/1     Running   0          60s
kube-system   cilium-operator-675f685d59-kwmqz   1/1     Running   0          60s
[root@k8s-master01 ~]#
```

### 9.2.4 下载专属监控面板

安装时候没有创建 监控可以忽略

```shell
[root@k8s-master01 yaml]# wget https://mirrors.chenby.cn/https://raw.githubusercontent.com/cilium/cilium/1.12.1/examples/kubernetes/addons/prometheus/monitoring-example.yaml

[root@k8s-master01 yaml]# sed -i "s#docker.io/#jockerhub.com/#g" monitoring-example.yaml

[root@k8s-master01 yaml]# kubectl  apply -f monitoring-example.yaml
namespace/cilium-monitoring created
serviceaccount/prometheus-k8s created
configmap/grafana-config created
configmap/grafana-cilium-dashboard created
configmap/grafana-cilium-operator-dashboard created
configmap/grafana-hubble-dashboard created
configmap/prometheus created
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
service/grafana created
service/prometheus created
deployment.apps/grafana created
deployment.apps/prometheus created
[root@k8s-master01 yaml]#
```

### 9.2.5 修改为NodePort

安装时候没有创建 监控可以忽略

```shell
[root@k8s-master01 yaml]# kubectl  edit svc  -n kube-system hubble-ui
service/hubble-ui edited
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl  edit svc  -n cilium-monitoring grafana
service/grafana edited
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl  edit svc  -n cilium-monitoring prometheus
service/prometheus edited
[root@k8s-master01 yaml]#

type: NodePort
```

### 9.2.6 查看端口

安装时候没有创建 监控可以忽略

```shell
[root@k8s-master01 yaml]# kubectl get svc -A | grep NodePort
cilium-monitoring   grafana          NodePort    10.111.74.3      <none>        3000:32648/TCP   74s
cilium-monitoring   prometheus       NodePort    10.107.240.124   <none>        9090:30495/TCP   74s
kube-system         hubble-ui        NodePort    10.96.185.26     <none>        80:31568/TCP     99s
```

### 9.2.7 访问

安装时候没有创建 监控可以忽略

```shell
http://192.168.1.31:32648
http://192.168.1.31:30495
http://192.168.1.31:31568
```

# 10.安装CoreDNS

## 10.1以下步骤只在master01操作

### 10.1.1修改文件

```shell
# 下载tgz包
helm repo add coredns https://coredns.github.io/helm
helm pull coredns/coredns
tar xvf coredns-*.tgz
cd coredns/

# 修改IP地址
vim values.yaml
cat values.yaml | grep clusterIP:
clusterIP: "10.96.0.10"

# 示例
---
service:
# clusterIP: ""
# clusterIPs: []
# loadBalancerIP: ""
# externalIPs: []
# externalTrafficPolicy: ""
# ipFamilyPolicy: ""
  # The name of the Service
  # If not set, a name is generated using the fullname template
  clusterIP: "10.96.0.10"
  name: ""
  annotations: {}
---

# 修改为国内源
sed -i "s#registry.k8s.io/#k8s.m.daocloud.io/#g" values.yaml

# 默认参数安装
helm install  coredns ./coredns/ -n kube-system
```

# 11.安装Metrics Server

## 11.1以下步骤只在master01操作

### 11.1.1安装Metrics-server

在新版的Kubernetes中系统资源的采集均使用Metrics-server，可以通过Metrics采集节点和Pod的内存、磁盘、CPU和网络的使用率

```shell
# 下载 
wget https://mirrors.chenby.cn/https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml 

# 修改配置
vim metrics-server.yaml 

---
# 1
    - args:
        - --cert-dir=/tmp
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem
        - --requestheader-username-headers=X-Remote-User
        - --requestheader-group-headers=X-Remote-Group
        - --requestheader-extra-headers-prefix=X-Remote-Extra-

# 2
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
        - name: ca-ssl
          mountPath: /etc/kubernetes/pki

# 3
      volumes:
      - emptyDir: {}
        name: tmp-dir
      - name: ca-ssl
        hostPath:
          path: /etc/kubernetes/pki
---


# 修改为国内源 docker源可选
sed -i "s#registry.k8s.io/#k8s.m.daocloud.io/#g" metrics-server.yaml

# 执行部署
kubectl apply -f metrics-server.yaml 
```

### 11.1.2稍等片刻查看状态

```shell
kubectl  top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master01   268m         6%     2318Mi          60%   
k8s-master02   147m         3%     1802Mi          47%   
k8s-master03   147m         3%     1820Mi          47%   
k8s-node01     62m          1%     1152Mi          30%   
k8s-node02     63m          1%     1114Mi          29%  
```

# 12.集群验证

## 12.1部署pod资源

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
    image: docker.m.daocloud.io/library/busybox:1.28
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

## 12.2用pod解析默认命名空间中的kubernetes

```shell
# 查看name
kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

# 进行解析
kubectl exec  busybox -n default -- nslookup kubernetes
3Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

## 12.3测试跨命名空间是否可以解析

```shell
# 查看有那些name
kubectl  get svc -A
NAMESPACE     NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
default       kubernetes        ClusterIP   10.96.0.1       <none>        443/TCP         76m
kube-system   calico-typha      ClusterIP   10.105.100.82   <none>        5473/TCP        35m
kube-system   coredns-coredns   ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP   8m14s
kube-system   metrics-server    ClusterIP   10.105.60.31    <none>        443/TCP         109s

# 进行解析
kubectl exec  busybox -n default -- nslookup coredns.kube-system
Server:    10.96.0.10
Address 1: 10.96.0.10 coredns-coredns.kube-system.svc.cluster.local

Name:      coredns-coredns.kube-system
Address 1: 10.96.0.10 coredns-coredns.kube-system.svc.cluster.local
[root@k8s-master01 metrics-server]# 
```

## 12.4每个节点都必须要能访问Kubernetes的kubernetes svc 443和kube-dns的service 53

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

## 12.5Pod和Pod之前要能通

```shell
kubectl get po -owide
NAME      READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
busybox   1/1     Running   0          17m   172.27.14.193   k8s-node02   <none>           <none>

kubectl get po -n kube-system -owide
NAME                                       READY   STATUS    RESTARTS   AGE     IP               NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-76754ff848-pw4xg   1/1     Running   0          38m     172.25.244.193   k8s-master01   <none>           <none>
calico-node-97m55                          1/1     Running   0          38m     192.168.1.34     k8s-node01     <none>           <none>
calico-node-hlz7j                          1/1     Running   0          38m     192.168.1.32     k8s-master02   <none>           <none>
calico-node-jtlck                          1/1     Running   0          38m     192.168.1.33     k8s-master03   <none>           <none>
calico-node-lxfkf                          1/1     Running   0          38m     192.168.1.35     k8s-node02     <none>           <none>
calico-node-t667x                          1/1     Running   0          38m     192.168.1.31     k8s-master01   <none>           <none>
calico-typha-59d75c5dd4-gbhfp              1/1     Running   0          38m     192.168.1.35     k8s-node02     <none>           <none>
coredns-coredns-c5c6d4d9b-bd829            1/1     Running   0          10m     172.25.92.65     k8s-master02   <none>           <none>
metrics-server-7c8b55c754-w7q8v            1/1     Running   0          3m56s   172.17.125.3     k8s-node01     <none>           <none>

# 进入busybox ping其他节点上的pod

kubectl exec -ti busybox -- sh
/ # ping 192.168.1.34
PING 192.168.1.34 (192.168.1.34): 56 data bytes
64 bytes from 192.168.1.34: seq=0 ttl=63 time=0.358 ms
64 bytes from 192.168.1.34: seq=1 ttl=63 time=0.668 ms
64 bytes from 192.168.1.34: seq=2 ttl=63 time=0.637 ms
64 bytes from 192.168.1.34: seq=3 ttl=63 time=0.624 ms
64 bytes from 192.168.1.34: seq=4 ttl=63 time=0.907 ms

# 可以连通证明这个pod是可以跨命名空间和跨主机通信的
```

## 12.6创建三个副本，可以看到3个副本分布在不同的节点上（用完可以删了）

```shell
cat<<EOF | kubectl apply -f -
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
        image: nginx
        ports:
        - containerPort: 80
EOF

kubectl  get pod 
NAME                               READY   STATUS    RESTARTS   AGE
busybox                            1/1     Running   0          6m25s
nginx-deployment-9456bbbf9-4bmvk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-9rcdk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-dqv8s   1/1     Running   0          8s

# 删除nginx
[root@k8s-master01 ~]# kubectl delete deployments nginx-deployment 
```

# 13.安装dashboard

```shell
# 添加源信息
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/


# 修改为国内源
helm pull kubernetes-dashboard/kubernetes-dashboard
tar xvf kubernetes-dashboard-*.tgz
cd kubernetes-dashboard
sed -i "s#docker.io/#jockerhub.com/#g" values.yaml

# 默认参数安装
helm upgrade --install kubernetes-dashboard ./kubernetes-dashboard/  --create-namespace --namespace kube-system


# 我的集群使用默认参数安装 kubernetes-dashboard-kong 出现异常 8444 端口占用
# 使用下面的命令进行安装，在安装时关闭kong.tls功能
helm upgrade --install kubernetes-dashboard ./kubernetes-dashboard/ --namespace kube-system --set kong.admin.tls.enabled=false
```

## 13.1更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc  -n kube-system kubernetes-dashboard-kong-proxy
  type: NodePort
```

## 13.2查看端口号

```shell
[root@k8s-master01 ~]# kubectl get svc kubernetes-dashboard-kong-proxy -n kube-system
NAME                              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard-kong-proxy   NodePort   10.96.247.74   <none>        443:30465/TCP   2m29s
[root@k8s-master01 ~]# 
```

## 13.3创建token

```shell
cat > dashboard-user.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
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
  namespace: kube-system
EOF

kubectl  apply -f dashboard-user.yaml

# 创建token
kubectl -n kube-system create token admin-user
eyJhbGciOiJSUzI1NiIsImtpZCI6ImotRHRvelZuWGcta2xHUi1pX1dxTWhRZjJpV0dhS3pwNW5XS2Zwd2c0QXcifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzM0MjYxOTExLCJpYXQiOjE3MzQyNTgzMTEsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNzUxZTQ1ODMtODc5OC00NWU3LTlmMWMtOWY2Zjc2ZjQ3OWJkIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiNjIwMjZjYTgtNDZhNy00OWU3LTk3ODktYWE1MGE2OTQ1MDAyIn19LCJuYmYiOjE3MzQyNTgzMTEsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbi11c2VyIn0.MdGe149S5T6oJP82DVI9BjNa6LGvqRY1t8iDw1gvH9ad28SZf__1KdfnillB3Og6JFWnyssaPeijApbtnkrPoTjRiuq2S_w_H5XBa_s90GkbQZkvcAg_3_MfpRSQacvk2wFngPmOA1GzqVoqibhxRgFK6QGKHEW3RrNd9Z7o4IMtTRzid5nKDafizZVvGTB3JjFTneWPa5pqilYVQzMX-jN035lU_p6Mx2y4EI4BN6C0O092Kwsl7FOcgEbVfi7GxdYSFGgqlZmzj1sQOYMhyqsoLu6SmUvBuCYOHnqYZy3Z3aNC6TxaDYsidkU4hz2HwoQGuH_VmEgnVGT7vR36PQ
```

## 13.4创建长期token

```shell
cat > dashboard-user-token.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token  
EOF

kubectl  apply -f dashboard-user-token.yaml

# 查看密码
kubectl get secret admin-user -n kube-system -o jsonpath={".data.token"} | base64 -d

eyJhbGciOiJSUzI1NiIsImtpZCI6ImotRHRvelZuWGcta2xHUi1pX1dxTWhRZjJpV0dhS3pwNW5XS2Zwd2c0QXcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI2MjAyNmNhOC00NmE3LTQ5ZTctOTc4OS1hYTUwYTY5NDUwMDIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.IpeeLb0XWRKWQl60Ma0IWq6IsKUT3WwbwKVRzNnbiqzia1aLmNWnYgP2i0YitLb1ktYS2fnn_BZx3rkdnycSTtFyGWdZXovCL6t_4_Nitgv_fg4XhMaduewUtbhd6sXVy2HJIV_dZ8MFNqXq4MqlAgSQmumXqw54VYC4-UOoXUQZ9A-qIalHNBh4BQ1BcIsQid8HFxKcewi7rF6uf8hGEAMHuTHGHxpbDXgJE1tYcC2yDz_CySPACilk-SImiCeaLU8nNnVSzPJRKdvRQB9ikh3u0nr0YxKBO35m90eultuSZTNeA3unBNKlv_tCmLI1jaqTV1QMKNTFwuZoyoBkHg
```

## 13.5登录dashboard

https://192.168.1.31:30465/

# 14.ingress安装

## 14.1执行部署

```shell
wget https://mirrors.chenby.cn/https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml -O ingress.yaml

# 修改为国内源 docker源可选
sed -i "s#registry.k8s.io/ingress-nginx/#registry.aliyuncs.com/chenby/#g" ingress.yaml
cat > ingress-backend.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app.kubernetes.io/name: default-http-backend
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: default-http-backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        image: registry.cn-hangzhou.aliyuncs.com/chenby/defaultbackend-amd64:1.5 
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: kube-system
  labels:
    app.kubernetes.io/name: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app.kubernetes.io/name: default-http-backend
EOF

kubectl  apply -f ingress.yaml 
kubectl  apply -f ingress-backend.yaml 


cat > ingress-demo-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-server
  template:
    metadata:
      labels:
        app: hello-server
    spec:
      containers:
      - name: hello-server
        image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/hello-server
        ports:
        - containerPort: 9000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  selector:
    app: nginx-demo
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-server
  name: hello-server
spec:
  selector:
    app: hello-server
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 9000
---
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: ingress-host-bar
spec:
  ingressClassName: nginx
  rules:
  - host: "hello.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: hello-server
            port:
              number: 8000
  - host: "demo.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/nginx"  
        backend:
          service:
            name: nginx-demo
            port:
              number: 8000
EOF

# 等创建完成后在执行：
kubectl  apply -f ingress-demo-app.yaml 

kubectl  get ingress
NAME               CLASS   HOSTS                            ADDRESS     PORTS   AGE
ingress-host-bar   nginx   hello.chenby.cn,demo.chenby.cn   192.168.1.32   80      7s
```

## 14.2过滤查看ingress端口

```shell
# 修改为nodeport
kubectl edit svc -n ingress-nginx   ingress-nginx-controller
type: NodePort

[root@hello ~/yaml]# kubectl  get svc -A | grep ingress
ingress-nginx          ingress-nginx-controller             NodePort    10.104.231.36    <none>        80:32636/TCP,443:30579/TCP   104s
ingress-nginx          ingress-nginx-controller-admission   ClusterIP   10.101.85.88     <none>        443/TCP                      105s
[root@hello ~/yaml]#
```

# 15.IPv6测试

```shell
#部署应用

cat<<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      hostNetwork: true
      containers:
      - name: chenby
        image: docker.io/library/nginx
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
EOF


#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME           TYPE        CLUSTER-IP            EXTERNAL-IP   PORT(S)        AGE
chenby         NodePort    fd00:1111::361a       <none>        80:30915/TCP   5s
[root@k8s-master01 ~]# 

# 直接访问POD地址
[root@k8s-master01 ~]# curl -I http://[fd00:1111::361a]
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 15 Dec 2024 10:56:49 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 26 Nov 2024 15:55:00 GMT
Connection: keep-alive
ETag: "6745ef54-267"
Accept-Ranges: bytes


# 使用IPv4地址访问测试
[root@k8s-master01 ~]# curl -I http://192.168.1.31:30915
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:59 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# 使用主机的内网IPv6地址测试
[root@k8s-master01 ~]# curl -I http://[fc00::31]:30915
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:54 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# 使用主机的公网IPv6地址测试
[root@k8s-master01 ~]# curl -I http://[2408:822a:732:5ce1::1e2]:30915
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 15 Dec 2024 10:54:16 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 26 Nov 2024 15:55:00 GMT
Connection: keep-alive
ETag: "6745ef54-267"
Accept-Ranges: bytes

```

# 16.污点

```shell
# 查看当前污点状态
[root@k8s-master01 ~]# kubectl describe node  | grep Taints
Taints:             <none>
Taints:             <none>
Taints:             <none>
Taints:             <none>
Taints:             <none>

# 设置污点 禁止调度 同时进行驱赶现有的POD
kubectl taint nodes k8s-master01 key1=value1:NoExecute
kubectl taint nodes k8s-master02 key1=value1:NoExecute
kubectl taint nodes k8s-master03 key1=value1:NoExecute

# 取消污点
kubectl taint nodes k8s-master01 key1=value1:NoExecute-
kubectl taint nodes k8s-master02 key1=value1:NoExecute-
kubectl taint nodes k8s-master03 key1=value1:NoExecute-

# 设置污点 禁止调度 不进行驱赶现有的POD
kubectl taint nodes k8s-master01 key1=value1:NoSchedule
kubectl taint nodes k8s-master02 key1=value1:NoSchedule
kubectl taint nodes k8s-master03 key1=value1:NoSchedule

# 取消污点
kubectl taint nodes k8s-master01 key1=value1:NoSchedule-
kubectl taint nodes k8s-master02 key1=value1:NoSchedule-
kubectl taint nodes k8s-master03 key1=value1:NoSchedule-
```

# 17.安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

# 附录

```shell
# 镜像加速器可以使用DaoCloud仓库，替换规则如下
# docker.io 仓库：
  # 官方地址：
  docker pull docker.io/nginx:latest
  docker pull docker.io/calico/node:v3.28.0
  # 镜像地址：
  docker pull docker.chenby.cn/library/nginx:latest
  docker pull docker.chenby.cn/calico/node:v3.28.0

# docker.elastic.co 仓库：
  # 官方地址：
  docker pull docker.elastic.co/apm/apm-server:8.14.0
  # 镜像地址：
  docker pull elastic.chenby.cn/apm/apm-server:8.14.0
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/apm-server:8.14.0

# quay.io 仓库：
  # 官方地址：
  docker pull quay.io/ceph/ceph:v18.2.1
  # 镜像地址：
  docker pull quay.chenby.cn/ceph/ceph:v18.2.1
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/ceph:v18.2.1

# k8s.gcr.io 仓库：
  # 官方地址：
  docker pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.8.2
  # 镜像地址：
  docker pull k8s.chenby.cn/kube-state-metrics/kube-state-metrics:v2.8.2
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/kube-state-metrics:v2.8.2

# registry.k8s.io 仓库：
  # 官方地址：
  docker pull registry.k8s.io/sig-storage/nfsplugin:v4.2.0
  # 镜像地址：
  docker pull k8s.chenby.cn/sig-storage/nfsplugin:v4.2.0
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/nfsplugin:v4.2.0

# gcr.io 仓库：
  # 官方地址：
  docker pull gcr.io/kaniko-project/executor:v1.23.1
  # 镜像地址：
  docker pull gcr.chenby.cn/kaniko-project/executor:v1.23.1
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/executor:v1.23.1

# ghcr.io 仓库：
  # 官方地址：
  docker pull ghcr.io/coroot/coroot:1.1.0
  # 镜像地址：
  docker pull ghcr.chenby.cn/coroot/coroot:1.1.0
  # 阿里云地址：
  docker pull registry.aliyuncs.com/chenby/coroot:1.1.0




# 镜像版本要自行查看，因为镜像版本是随时更新的，文档无法做到实时更新

# docker pull 镜像

docker pull registry.cn-hangzhou.aliyuncs.com/chenby/cni:master 
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/node:master
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/kube-controllers:master
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/typha:master
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/coredns:v1.10.0
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/pause:3.6
docker pull registry.cn-hangzhou.aliyuncs.com/chenby/metrics-server:v0.5.2
docker pull kubernetesui/dashboard:v2.7.0
docker pull kubernetesui/metrics-scraper:v1.0.8
docker pull quay.io/cilium/cilium:v1.12.6
docker pull quay.io/cilium/certgen:v0.1.8
docker pull quay.io/cilium/hubble-relay:v1.12.6
docker pull quay.io/cilium/hubble-ui-backend:v0.9.2
docker pull quay.io/cilium/hubble-ui:v0.9.2
docker pull quay.io/cilium/cilium-etcd-operator:v2.0.7
docker pull quay.io/cilium/operator:v1.12.6
docker pull quay.io/cilium/clustermesh-apiserver:v1.12.6
docker pull quay.io/coreos/etcd:v3.5.4
docker pull quay.io/cilium/startup-script:d69851597ea019af980891a4628fb36b7880ec26

# docker 保存镜像
docker save registry.cn-hangzhou.aliyuncs.com/chenby/cni:master -o cni.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/node:master -o node.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/typha:master -o typha.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/kube-controllers:master -o kube-controllers.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/coredns:v1.10.0 -o coredns.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/pause:3.6 -o pause.tar 
docker save registry.cn-hangzhou.aliyuncs.com/chenby/metrics-server:v0.5.2 -o metrics-server.tar 
docker save kubernetesui/dashboard:v2.7.0 -o dashboard.tar 
docker save kubernetesui/metrics-scraper:v1.0.8 -o metrics-scraper.tar 
docker save quay.io/cilium/cilium:v1.12.6 -o cilium.tar 
docker save quay.io/cilium/certgen:v0.1.8 -o certgen.tar 
docker save quay.io/cilium/hubble-relay:v1.12.6 -o hubble-relay.tar 
docker save quay.io/cilium/hubble-ui-backend:v0.9.2 -o hubble-ui-backend.tar 
docker save quay.io/cilium/hubble-ui:v0.9.2 -o hubble-ui.tar 
docker save quay.io/cilium/cilium-etcd-operator:v2.0.7 -o cilium-etcd-operator.tar 
docker save quay.io/cilium/operator:v1.12.6 -o operator.tar 
docker save quay.io/cilium/clustermesh-apiserver:v1.12.6 -o clustermesh-apiserver.tar 
docker save quay.io/coreos/etcd:v3.5.4 -o etcd.tar 
docker save quay.io/cilium/startup-script:d69851597ea019af980891a4628fb36b7880ec26 -o startup-script.tar 

# 传输到各个节点
for NODE in k8s-master01 k8s-master02 k8s-master03 k8s-node01 k8s-node02; do scp -r images/  $NODE:/root/ ; done

# 创建命名空间
ctr ns create k8s.io

# 导入镜像
ctr --namespace k8s.io image import images/cni.tar
ctr --namespace k8s.io image import images/node.tar
ctr --namespace k8s.io image import images/typha.tar
ctr --namespace k8s.io image import images/kube-controllers.tar 
ctr --namespace k8s.io image import images/coredns.tar 
ctr --namespace k8s.io image import images/pause.tar 
ctr --namespace k8s.io image import images/metrics-server.tar 
ctr --namespace k8s.io image import images/dashboard.tar 
ctr --namespace k8s.io image import images/metrics-scraper.tar 
ctr --namespace k8s.io image import images/dashboard.tar 
ctr --namespace k8s.io image import images/metrics-scraper.tar 
ctr --namespace k8s.io image import images/cilium.tar 
ctr --namespace k8s.io image import images/certgen.tar 
ctr --namespace k8s.io image import images/hubble-relay.tar 
ctr --namespace k8s.io image import images/hubble-ui-backend.tar 
ctr --namespace k8s.io image import images/hubble-ui.tar 
ctr --namespace k8s.io image import images/cilium-etcd-operator.tar 
ctr --namespace k8s.io image import images/operator.tar 
ctr --namespace k8s.io image import images/clustermesh-apiserver.tar 
ctr --namespace k8s.io image import images/etcd.tar 
ctr --namespace k8s.io image import images/startup-script.tar 

# pull tar包 解压后
helm pull cilium/cilium

# 查看镜像版本
root@hello:~/cilium# cat values.yaml| grep tag: -C1
  repository: "quay.io/cilium/cilium"
  tag: "v1.12.6"
  pullPolicy: "IfNotPresent"
--
    repository: "quay.io/cilium/certgen"
    tag: "v0.1.8@sha256:4a456552a5f192992a6edcec2febb1c54870d665173a33dc7d876129b199ddbd"
    pullPolicy: "IfNotPresent"
--
      repository: "quay.io/cilium/hubble-relay"
      tag: "v1.12.6"
       # hubble-relay-digest
--
        repository: "quay.io/cilium/hubble-ui-backend"
        tag: "v0.9.2@sha256:a3ac4d5b87889c9f7cc6323e86d3126b0d382933bd64f44382a92778b0cde5d7"
        pullPolicy: "IfNotPresent"
--
        repository: "quay.io/cilium/hubble-ui"
        tag: "v0.9.2@sha256:d3596efc94a41c6b772b9afe6fe47c17417658956e04c3e2a28d293f2670663e"
        pullPolicy: "IfNotPresent"
--
    repository: "quay.io/cilium/cilium-etcd-operator"
    tag: "v2.0.7@sha256:04b8327f7f992693c2cb483b999041ed8f92efc8e14f2a5f3ab95574a65ea2dc"
    pullPolicy: "IfNotPresent"
--
    repository: "quay.io/cilium/operator"
    tag: "v1.12.6"
    # operator-generic-digest
--
    repository: "quay.io/cilium/startup-script"
    tag: "d69851597ea019af980891a4628fb36b7880ec26"
    pullPolicy: "IfNotPresent"
--
    repository: "quay.io/cilium/cilium"
    tag: "v1.12.6"
    # cilium-digest
--
      repository: "quay.io/cilium/clustermesh-apiserver"
      tag: "v1.12.6"
      # clustermesh-apiserver-digest
--
        repository: "quay.io/coreos/etcd"
        tag: "v3.5.4@sha256:795d8660c48c439a7c3764c2330ed9222ab5db5bb524d8d0607cac76f7ba82a3"
        pullPolicy: "IfNotPresent"
```

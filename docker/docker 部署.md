

_docker-io, docker-engin_是以前早期的版本,版本号是 1. x 默认centos7 安装的是docker-io,最新版是 1.13

_docker-ce_是社区版本,适用于刚刚开始docker 和开发基于docker研发的应用开发者或者小型团队。Ubuntu默认安装的是docker-ce

_docker-ee_是docker的企业版,适用于企业级开发,同样也适用于开发、分发和运行商务级别的应用的IT 团队。

## 官方脚本安装

```bash
yum update
# 下载脚本并执行
curl -sSL https://get.docker.com/ | sh
# 启动
systemctl start docker
# 查看是否启动成功
systemctl status docker

----------------------------------------------------------------------------------------------------------------
# 安装过程报错（新版本常见问题）
#sh -c 'yum install -y -q docker-ce docker-ce-cli containerd.io docker-scan-plugin docker-compose-plugin docker-ce-rootless-extras'
#错误：软件包：docker-ce-rootless-extras-20.10.17-3.el7.x86_64 (docker-ce-stable)
#         需要：slirp4netns >= 0.4
#错误：软件包：docker-ce-rootless-extras-20.10.17-3.el7.x86_64 (docker-ce-stable)
#         需要：fuse-overlayfs >= 0.7
#错误：软件包：3:docker-ce-20.10.17-3.el7.x86_64 (docker-ce-stable)
#         需要：container-selinux >= 2:2.74
#错误：软件包：containerd.io-1.6.7-3.1.el7.x86_64 (docker-ce-stable)
#         需要：container-selinux >= 2:2.74
# 您可以尝试添加 --skip-broken 选项来解决该问题
# 您可以尝试执行：rpm -Va --nofiles --nodigest

# 更新为阿里源
# 备份Linux本地现有的yum仓库文件
cd /etc/yum.repos.d
mkdir backup
mv ./* backup/

# 下载新的仓库文件
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

#curl -o  /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
#curl -o  /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# 其他(非阿里云ECS用户会出现出现 curl#6 - "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error")
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/*.repo

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache 
```

‍

## yum源安装

预置条件，更新yum源 [阿里源](../linux/linux%20命令/shell%20命令手册/软件安装/yum.md#20231110105237-mtqvqbk)

```bash
# 增加docker源
yum -y install yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum clean all && yum makecache
yum -y install docker-ce
# 启动
systemctl start docker

```

## rpm方式安装

```bash
# 内核版本3.10以上  uname -r
#首先我们去Docker官网下载rpm包，地址[https://download.docker.com/linux/centos/7/x86_64/stable/Packages/]
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.0.ce-1.el7.centos.noarch.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.0.ce-1.el7.centos.x86_64.rpm

#  命令进行安装
yum install *.rpm
systemctl enable docker;sudo systemctl start docker

```

## docker-daemon.json各配置详解

```json
{
"api-cors-header": " ",          // 在引擎API中设置CORS标头
"authorization-plugins": [],     // 要加载的授权插件
"bridge": "",                    // 将容器附加到网桥
"cgroup-parent": "",             // 为所有容器设置父cgroup
"cluster-store": "",             // 分布式存储后端的URL
"cluster-store-opts": {},        // 设置集群存储选项（默认map []）
"cluster-advertise": "",         // 要通告的地址或接口名称
"debug": true,                   // 启用调试模式,启用后,可以看到很多的启动信息。默认false
"default-gateway": "",           // 容器默认网关IPv4地址
"default-gateway-v6": "",        // 容器默认网关IPv6地址
"default-runtime": "runc",       // 容器的默认OCI运行时（默认为" runc"）
"default-ulimits": {},           // 容器的默认ulimit（默认[]）
"dns": ["192.168.1.1"],          // 设定容器DNS的地址,在容器的 /etc/resolv.conf文件中可查看。
"dns-opts": [],                  // 容器 /etc/resolv.conf 文件,其他设置
"dns-search": [],                // 设定容器的搜索域,当设定搜索域为 .example.com 时,在搜索一个名为 host 的 主机时,DNS不仅搜索host,还会搜索host.example.com 。 注意：如果不设置, Docker 会默认用主机上的 /etc/resolv.conf 来配置容器。
"exec-opts": [],                 // 运行时执行选项
"exec-root": "",                 // 执行状态文件的根目录（默认为’/var/run/docker‘）
"fixed-cidr": "",                // 固定IP的IPv4子网
"fixed-cidr-v6": "",             // 固定IP的IPv6子网
"data-root": "/var/lib/docker",  // Docker运行时使用的根路径,默认/var/lib/docker
"group": "",                     // UNIX套接字的组（默认为"docker"）
"hosts": [],                     // 设置容器hosts
"icc": false,                    // 启用容器间通信（默认为true）
"ip": "0.0.0.0",                 // 绑定容器端口时的默认IP（默认0.0.0.0）
"iptables": false,               // 启用iptables规则添加（默认为true）
"ipv6": false,                   // 启用IPv6网络
"ip-forward": false,             // 默认true, 启用 net.ipv4.ip_forward ,进入容器后使用 sysctl -a | grepnet.ipv4.ip_forward 查看
"ip-masq": false,                // 启用IP伪装（默认为true）
"labels": ["nodeName=node-121"], // docker主机的标签,很实用的功能,例如定义：–label nodeName=host-121
"live-restore": true,            // 在容器仍在运行时启用docker的实时还原
"log-driver": "",                // 容器日志的默认驱动程序（默认为" json-file"）
"log-level": "",                 // 设置日志记录级别（"调试","信息","警告","错误","致命"）（默认为"信息"）
"max-concurrent-downloads": 3,   // 设置每个请求的最大并发下载量（默认为3）
"max-concurrent-uploads": 5,     // 设置每次推送的最大同时上传数（默认为5）
"mtu": 0,                        // 设置容器网络MTU
"oom-score-adjust": -500,        // 设置守护程序的oom_score_adj（默认值为-500）
"pidfile": "",                   // Docker守护进程的PID文件
"raw-logs": false,               // 全时间戳机制
"selinux-enabled": false,        // 默认 false,启用selinux支持
"storage-driver": "",            // 要使用的存储驱动程序
"swarm-default-advertise-addr": "", // 设置默认地址或群集广告地址的接口
"tls": true,                     // 默认 false, 启动TLS认证开关
"tlscacert": "",                 // 默认 ~/.docker/ca.pem,通过CA认证过的的certificate文件路径
"tlscert": "",                   // 默认 ~/.docker/cert.pem ,TLS的certificate文件路径
"tlskey": "",                    // 默认~/.docker/key.pem,TLS的key文件路径
"tlsverify": true,               // 默认false,使用TLS并做后台进程与客户端通讯的验证
"userland-proxy": false,         // 使用userland代理进行环回流量（默认为true）
"userns-remap": "",              // 用户名称空间的用户/组设置
"bip": "192.168.88.0/22",        // 指定网桥IP
"registry-mirrors": ["https://192.498.89.232:89"],// 设置镜像加速
"insecure-registries": ["120.123.122.123:12312"], // 设置私有仓库地址可以设为http
"storage-opts": [
"overlay2.override_kernel_check=true",
"overlay2.size=15G"
],                               // 存储驱动程序选项
"log-opts": {
"max-file": "3",
"max-size": "10m",
},                               // 容器默认日志驱动程序选项
"iptables": false                // 启用iptables规则添加（默认为true）
}

```

## docker 登录docker-harbor

```bash
docker login 192.168.10.31 -u admin -p Ninestar123

# 若出现一下报错：
# Error response from daemon: Get "https://192.168.10.31/v2/": x509: certificate relies on legacy Common Name field, use SANs instead

# 修改docker客户端文件 /etc/docker/daemon.json 添加以下配置：

{ 
    "insecure-registries": ["0.0.0.0/0"]
}

# 重启docker服务
systemctl restart docker
```

‍

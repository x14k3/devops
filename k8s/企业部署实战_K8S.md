

![[assets/Pasted image 20250718154618.png]]

可以简单理解成：

>11 机器：反向代理
>12 机器：反向代理
>21 机器：主控+运算节点（即服务群都是跑在21和22上）
>22 机器：主控+运算节点（生产上我们会把主控和运算分开）
>200 机器：运维主机（放各种文件资源）

这样控节点有两个，运算节点有两个，就是小型的分布式，现在你可能没办法理解这些内容，我们接着做下去，慢慢的，你就理解了


## K8S前置准备工作

### 资源准备

准备一台8C64G的机器，我们将它分成5个节点，如下图

|      | 反向代理           | 反向代理           | 主控+运算          | 主控+运算          | 运维机器            |
| ---- | -------------- | -------------- | -------------- | -------------- | --------------- |
| 主机名  | hdss-7-11      | hdss-7-12      | hdss-7-21      | hdss-7-22      | hdss-7-200      |
| ip地址 | 192.168.133.11 | 192.168.133.12 | 192.168.133.21 | 192.168.133.22 | 192.168.133.200 |
| 标配   | 2C4G           | 2C4G           | 2C16G          | 2C16G          | 2C2G            |

```bash
# 全部机器，设置名字，11是hdss7-11,12是hdss7-12,以此类推
hostnamectl set-hostname hdss7-11.host.com

# 查看enforce是否关闭，确保disabled状态，当然可能没有这个命令
getenforce
# 如果不为disabled，需要vim /etc/selinux/config，将SELINUX=后改为disabled后重启即可

# 查看内核版本，确保在3.8以上版本
uname -a

# 关闭并禁止firewalld自启
systemctl stop firewalld
systemctl disable firewalld

# 安装epel源及相关工具
yum install epel-release -y
yum install wget net-tools telnet tree nmap sysstat lrzsz dos2unix bind-utils -y
```

---
### 部署DNS服务

>**WHAT**：DNS（域名系统）说白了，就是把一个域和IP地址做了一下绑定，如你在里机器里面输入 `nslookup www.qq.com`，出来的Address是一堆IP，IP是不容易记的，所以DNS让IP和域名做一下绑定，这样你输入域名就可以了
>**WHY**：我们要用ingress，在K8S里要做7层调度，而且无论如何都要用域名（如之前的那个百度页面的域名，那个是host的方式），但是问题是我们怎么给K8S里的容器绑host，所以我们必须做一个DNS，然后容器服从我们的DNS解析调度

在11机器部署 [[../基础服务/DNS/dnsmasq|dnsmasq]]

```bash
# 在11机器：
vim /etc/dnsmasq.conf

# Include all files in /etc/dnsmasq.d except RPM backup files

conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
listen-address=127.0.0.1,192.168.133.11

address=/hdss-7-11.host.com/192.168.133.11
address=/hdss-7-12.host.com/192.168.133.12
address=/hdss-7-21.host.com/192.168.133.21
address=/hdss-7-22.host.com/192.168.133.22
address=/hdss-7-200.host.com/192.168.133.200
address=/harbor.od.com/192.168.133.200

server=114.114.114.114

```

---

### 签发证书环境

> **WHAT**： 证书，可以用来审计也可以保障安全，k8S组件启动的时候，则需要有对应的证书，证书的详解你也可以在网上搜到，这里就不细细说明了
> **WHY**：当然是为了让我们的组件能正常运行

在200机器

```bash
# 在200机器：

# cfssl方式做证书，需要三个软件，按照我们的架构图，我们部署在200机器:
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O /usr/bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O /usr/bin/cfssl-json
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O /usr/bin/cfssl-certinfo
chmod +x /usr/bin/cfssl*


cd /opt/
mkdir certs
cd certs/
echo '
{
    "CN": "ben123123",
    "hosts": [
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "od",
            "OU": "ops"
        }
    ],
    "ca": {
        "expiry": "1752000h"
    }
}' >> ca-csr.json

cfssl gencert -initca ca-csr.json | cfssl-json -bare ca

```

---
### 部署docker环境

>**WHAT**：docker是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的镜像中，然后发布到任何流行的 Linux或Windows 机器上，也可以实现虚拟化。
**WHY**：Pod里面就是由数个docker容器组成，Pod是豌豆荚，docker容器是里面的豆子。

在21/22机器 [[../docker/docker 部署|docker 部署]]

```bash
# 如我们架构图所示，运算节点是21/22机器（没有docker则无法运行pod），运维主机是200机器（没有docker则没办法下载docker存入私有仓库），所以在三台机器安装（21/22/200）
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
# 上面的下载可能网络有问题，需要多试几次，这些部署我已经不同机器试过很多次了
mkdir -p /data/docker /etc/docker
# # 注意，172.7.21.1，这里得21是指在hdss7-21得机器，如果是22得机器，就是172.7.22.1，共一处需要改机器名："bip": "172.7.21.1/24"
echo '
{
  "data-root": "/data/docker",
  "storage-driver": "overlay2",
  "insecure-registries": ["registry.access.redhat.com","quay.io","harbor.od.com"],
  "registry-mirrors": ["https://q2gr04ke.mirror.aliyuncs.com"],
  "bip": "172.7.21.1/24",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "live-restore": true
} ' >> /etc/docker/daemon.json

systemctl restart docker
docker version
docker ps -a
```

>**daemon.json解析：**重点说一下这个为什么192.168.133.21机器对应着172.7.21.1/24，这里可以看到192的21对应得是172的21，这样做的好处就是，当你的pod出现问题时，你可以马上定位到是在哪台机器出现的问题，是21还是22还是其它的，这点在生产上非常重要，有时候你的dashboard（后面会安装）宕掉了，你没办法只能去机器找，而这时候你又找不到的时候，你老板会拿你祭天的

---

### 部署harbor仓库

> **WHAT **：harbor仓库是可以部署到本地的私有仓库，也就是你可以把镜像推到这个仓库，然后需要用的时候再下载下来，这样的好处是：1、下载速度快，用到的时候能马上下载下来2、不用担心镜像改动或者下架等。
> **WHY**：因为我们的部署K8S涉及到很多镜像，制作相关包的时候如果网速问题会导致失败重来，而且我们在公司里也会建自己的仓库，所以必须按照harbor仓库

在200机器部署 [[../docker/docker harbor|docker harbor]]

```bash
# 修改harbor.yml文件
#----------------------------------------------
hostname: harbor.od.com  # 原reg.mydomain.com
http:
  port: 180  # 原80
data_volume: /data/harbor
location: /data/harbor/logs
#----------------------------------------------
```

>**harbor.yml解析：**
port为什么改成180：因为后面我们要装nginx，nginx用的80，所以要把它们错开
data_volume：数据卷，即docker镜像放在哪里
location：日志文件
**./install.sh**：启动shell脚本


在200机器部署 [[../中间件/nginx/nginx 部署|nginx 部署]]

```bash
yum install nginx -y

echo '
server {
    listen       80;
    server_name  harbor.od.com;
    client_max_body_size 1000m;
    location / {
        proxy_pass http://127.0.0.1:180;
    }
} ' >> /etc/nginx/conf.d/harbor.od.com.conf

nginx -t
systemctl start nginx
systemctl enable nginx
```


```bash
# 200机器，尝试下是否能push成功到harbor仓库
docker pull nginx
docker images|grep nginx
# 在harbor新建public，然后上传镜像
docker tag 2cd1d97f893f harbor.od.com/public/nginx:v20250728
docker login harbor.od.com
# 账号：admin 密码：Harbor12345
docker push harbor.od.com/public/nginx:v20250728
# 报错：如果发现登录不上去了，过一阵子再登录即可，大约5分钟左右
```

---

## 部署etcd服务

>**WHAT**：一个高可用强一致性的服务发现存储仓库，关于服务发现，其本质就是知道了集群中是否有进程在监听udp和tcp端口（如上面部署的harbor就是监听180端口），并且通过名字就可以查找和连接。
>- **一个强一致性、高可用的服务存储目录**：基于Raft算法的etcd天生就是这样
>- **一种注册服务和监控服务健康状态的机制**：在etcd中注册服务，并且对注册的服务设置`key TTL`（TTL上面有讲到），定时保持服务的心跳以达到监控健康状态的效果
>- **一种查找和连接服务的机制**：通过在etcd指定的主题下注册的服务也能在对应的主题下查找到，为了确保连接，我们可以在每个服务机器上都部署一个Proxy模式的etcd，这样就可以确保能访问etcd集群的服务都能互相连接
**WHY**：我们需要让服务快速透明地接入到计算集群中，让共享配置信息快速被集群中的所有机器发现

我们在12/21/22机器部署[[../中间件/etcd|etcd]]


---

## 部署API-server集群

[kubernetes官网](https://github.com/kubernetes/kubernetes)

根据架构图，我们把运算节点部署在21和22机器
```bash
# 21/22机器
cd /opt/src/
# 可以去官网下载
wget https://dl.k8s.io/v1.15.2/kubernetes-server-linux-amd64.tar.gz
mv kubernetes-server-linux-amd64.tar.gz kubernetes-server-linux-amd64-v1.15.2.tar.gz

tar xf kubernetes-server-linux-amd64-v1.15.2.tar.gz -C /opt/

# 签发client证书，200机器：
cd /opt/certs
echo '{
    "CN": "k8s-node",
    "hosts": [
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "od",
            "OU": "ops"
        }
    ]
} ' >> client-csr.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client-csr.json |cfssl-json -bare client


# 给API-server做证书，200机器
echo '{
    "CN": "k8s-apiserver",
    "hosts": [
        "127.0.0.1",
        "192.168.0.1",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster",
        "kubernetes.default.svc.cluster.local",
        "192.168.133.11",
        "192.168.133.12",
        "192.168.133.21",
        "192.168.133.22"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "od",
            "OU": "ops"
        }
    ]
}' >> apiserver-csr.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server apiserver-csr.json |cfssl-json -bare apiserver


# 21/22机器：
cd /opt/kubernetes/server/bin
mkdir cert && cd cert/
# 把证书考过来
scp hdss7-200:/opt/certs/ca.pem .
scp hdss7-200:/opt/certs/ca-key.pem .
scp hdss7-200:/opt/certs/client-key.pem .
scp hdss7-200:/opt/certs/client.pem .
scp hdss7-200:/opt/certs/apiserver.pem .
scp hdss7-200:/opt/certs/apiserver-key.pem .

```


```bash
# 21/22机器：
cd /opt/kubernetes/server/bin
mkdir conf

cat  >> conf/audit.yaml <<EOF
apiVersion: audit.k8s.io/v1beta1 # This is required.
kind: Policy
# Don't generate audit events for all requests in RequestReceived stage.
omitStages:
  - "RequestReceived"
rules:
  # Log pod changes at RequestResponse level
  - level: RequestResponse
    resources:
    - group: ""
      # Resource "pods" doesn't match requests to any subresource of pods,
      # which is consistent with the RBAC policy.
      resources: ["pods"]
  # Log "pods/log", "pods/status" at Metadata level
  - level: Metadata
    resources:
    - group: ""
      resources: ["pods/log", "pods/status"]

  # Don't log requests to a configmap called "controller-leader"
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
      resourceNames: ["controller-leader"]

  # Don't log watch requests by the "system:kube-proxy" on endpoints or services
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
    - group: "" # core API group
      resources: ["endpoints", "services"]

  # Don't log authenticated requests to certain non-resource URL paths.
  - level: None
    userGroups: ["system:authenticated"]
    nonResourceURLs:
    - "/api*" # Wildcard matching.
    - "/version"

  # Log the request body of configmap changes in kube-system.
  - level: Request
    resources:
    - group: "" # core API group
      resources: ["configmaps"]
    # This rule only applies to resources in the "kube-system" namespace.
    # The empty string "" can be used to select non-namespaced resources.
    namespaces: ["kube-system"]

  # Log configmap and secret changes in all other namespaces at the Metadata level.
  - level: Metadata
    resources:
    - group: "" # core API group
      resources: ["secrets", "configmaps"]

  # Log all other resources in core and extensions at the Request level.
  - level: Request
    resources:
    - group: "" # core API group
    - group: "extensions" # Version of group should NOT be included.

  # A catch-all rule to log all other requests at the Metadata level.
  - level: Metadata
    # Long-running requests like watches that fall under this rule will not
    # generate an audit event in RequestReceived.
    omitStages:
      - "RequestReceived"
EOF
      

cat >> /opt/kubernetes/server/bin/kube-apiserver.sh <<EOF
#!/bin/bash
./kube-apiserver \
  --apiserver-count 2 \
  --audit-log-path /data/logs/kubernetes/kube-apiserver/audit-log \
  --audit-policy-file ./conf/audit.yaml \
  --authorization-mode RBAC \
  --client-ca-file ./cert/ca.pem \
  --requestheader-client-ca-file ./cert/ca.pem \
  --enable-admission-plugins NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
  --etcd-cafile ./cert/ca.pem \
  --etcd-certfile ./cert/client.pem \
  --etcd-keyfile ./cert/client-key.pem \
  --etcd-servers https://10.4.7.12:2379,https://10.4.7.21:2379,https://10.4.7.22:2379 \
  --service-account-key-file ./cert/ca-key.pem \
  --service-cluster-ip-range 192.168.0.0/16 \
  --service-node-port-range 3000-29999 \
  --target-ram-mb=1024 \
  --kubelet-client-certificate ./cert/client.pem \
  --kubelet-client-key ./cert/client-key.pem \
  --log-dir  /data/logs/kubernetes/kube-apiserver \
  --tls-cert-file ./cert/apiserver.pem \
  --tls-private-key-file ./cert/apiserver-key.pem \
  --v 2
EOF

chmod +x kube-apiserver.sh
# 一处修改：[program:kube-apiserver-7-21]
bin]# vi /etc/supervisord.d/kube-apiserver.ini
[program:kube-apiserver-7-21]
command=/opt/kubernetes/server/bin/kube-apiserver.sh            ; the program (relative uses PATH, can take args)
numprocs=1                                                      ; number of processes copies to start (def 1)
directory=/opt/kubernetes/server/bin                            ; directory to cwd to before exec (def no cwd)
autostart=true                                                  ; start at supervisord start (default: true)
autorestart=true                                                ; retstart at unexpected quit (default: true)
startsecs=30                                                    ; number of secs prog must stay running (def. 1)
startretries=3                                                  ; max # of serial start failures (default 3)
exitcodes=0,2                                                   ; 'expected' exit codes for process (default 0,2)
stopsignal=QUIT                                                 ; signal used to kill process (default TERM)
stopwaitsecs=10                                                 ; max num secs to wait b4 SIGKILL (default 10)
user=root                                                       ; setuid to this UNIX account to run the program
redirect_stderr=true                                            ; redirect proc stderr to stdout (default false)
stdout_logfile=/data/logs/kubernetes/kube-apiserver/apiserver.stdout.log        ; stderr log path, NONE for none; default AUTO
stdout_logfile_maxbytes=64MB                                    ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=4                                        ; # of stdout logfile backups (default 10)
stdout_capture_maxbytes=1MB                                     ; number of bytes in 'capturemode' (default 0)
stdout_events_enabled=false                                     ; emit events on stdout writes (default false)

bin]# mkdir -p /data/logs/kubernetes/kube-apiserver
bin]# supervisorctl update
# 查看21/22两台机器是否跑起来了，可能比较慢在starting，等10秒
bin]# supervisorctl status
```
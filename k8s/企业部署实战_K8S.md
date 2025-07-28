
- Pod
    - Pod是K8S里能够被运行的最小的逻辑单元（原子单元）
    - 1个Pod里面可以运行多个容器，它们共享UTS+NET+IPC名称空间
    - 可以把Pod理解成豌豆荚，而同一Pod内的每个容器是一颗颗豌豆
    - 一个Pod里运行多个容器，又叫边车（SideCar）模式
- Pod控制器（关于更多[初识Pod](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md#%E5%88%9D%E8%AF%86pod)）
    - Pod控制器是Pod启动的一种模板，用来保证在K8S里启动的Pod始终按照人们的预期运行（副本数、生命周期、健康状态检查...）
    - Pod内提供了众多的Pod控制器，常用的有以下几种：
        - Deployment
        - DaemonSet
        - ReplicaSet
        - StatefulSet
        - Job
        - Cronjob
- Name
    - 由于K8S内部，使用“资源”来定义每一种逻辑概念（功能），故每种“资源”，都应该有自己的“名称”
    - “资源”有api版本（apiVersion）类别（kind）、元数据（metadata）、定义清单（spec）、状态（status）等配置信息
    - “名称”通常定义在“资源”的“元数据”信息里
- [namespace](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Docker%E5%9F%BA%E7%A1%80.md#%E5%85%B3%E4%BA%8Enamespace)
    - 随着项目增多、人员增加、集群规模的扩大，需要一种能够隔离K8S内各种“资源”的方法，这就是名称空间
    - 名称空间可以理解为K8S内部的虚拟集群组
    - 不同名称空间内的“资源”名称可以相同，相同名称空间内的同种“资源”、“名称”不能相同
    - 合理的使用K8S名称空间，使得集群管理员能够更好的对交付到K8S里的服务进行分类管理和浏览
    - K8S内默认存在的名称空间有：default、kube-system、kube-public
    - 查询K8S里特定“资源”要带上相应的名称空间
- Label
    - 标签是K8S特色的管理方式，便于分类管理资源对象
    - 一个标签可以对应多个资源，一个资源也可以有多个标签，它们是多对多的关系
    - 一个资源拥有多个标签，可以实现不同维度的管理
    - 标签的组成：key=value
    - 与标签类似的，还有一种“注解”（annotations）
- Label选择器
    - 给资源打上标签后，可以使用标签选择器过滤指定的标签
    - 标签选择器目前有两个：基于等值关系（等于、不等于）和基于集合关系（属于、不属于、存在）
    - 许多资源支持内嵌标签选择器字段
        - matchLabels
        - matchExpressions
- Service
    - 在K8S的世界里，虽然每个Pod都会被分配一个单独的IP地址，但这个IP地址会随着Pod的销毁而消失
    - Service（服务）就是用来解决这个问题的核心概念
    - 一个Service可以看作一组提供相同服务的Pod的对外访问接口
    - Service作用与哪些Pod是通过标签选择器来定义的
- Ingress
    - Ingress是K8S集群里工作在OSI网络参考模型下，第7层的应用，对外暴露的接口
    - Service只能进行L4流量调度，表现形式是ip+port
    - Ingress则可以调度不同业务域、不同URL访问路径的业务流量

简单理解：Pod可运行的原子，name定义名字，namespace名称空间（放一堆名字），label标签（另外的名字），service提供服务，ingress通信

### K8S架构图

![[assets/1582188308711.png]]

kubectl：Kubernetes集群的命令行接口
API Server：的核心功能是对核心对象（例如：Pod，Service，RC）的增删改查操作，同时也是集群内模块之间数据交换的枢纽
Etcd：包含在 APIServer 中，用来存储资源信息
Controller Manager ：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等
Scheduler**：负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上。可以通过这些有更深的了解：
- [Kubernetes调度机制](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md)
- [Kubernetes的资源模型与资源管理](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubernetes%E7%9A%84%E8%B5%84%E6%BA%90%E6%A8%A1%E5%9E%8B%E4%B8%8E%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%86)
- [Kubernetes默认的调度策略](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubernetes%E9%BB%98%E8%AE%A4%E7%9A%84%E8%B0%83%E5%BA%A6%E7%AD%96%E7%95%A5)
- [调度器的优先级与强制机制](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#%E8%B0%83%E5%BA%A6%E5%99%A8%E7%9A%84%E4%BC%98%E5%85%88%E7%BA%A7%E4%B8%8E%E5%BC%BA%E5%88%B6%E6%9C%BA%E5%88%B6)

**kube-proxy**：负责为Service提供cluster内部的服务发现和负载均衡
**Kubelet**：在Kubernetes中，应用容器彼此是隔离的，并且与运行其的主机也是隔离的，这是对应用进行独立解耦管理的关键点。[Kubelet工作原理解析](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubelet)
**Node**：运行容器应用，由Master管理

#### 我们部署的K8S架构图

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

[[../基础服务/DNS/dnsmasq|dnsmasq]]

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
cat ca.pem

```

---
### 部署docker环境

>**WHAT**：docker是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的镜像中，然后发布到任何流行的 Linux或Windows 机器上，也可以实现虚拟化。
**WHY**：Pod里面就是由数个docker容器组成，Pod是豌豆荚，docker容器是里面的豆子。

[[../docker/docker 部署|docker 部署]]

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

在200机器部署harbor [[../docker/docker harbor|docker harbor]]

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

在200机器部署nginx

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
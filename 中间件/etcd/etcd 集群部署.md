

### 准备证书

```bash
### 所有etcd节点创建证书存放目录
mkdir /etc/etcd/ssl -p
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64" -O /usr/local/bin/cfssl
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64" -O /usr/local/bin/cfssljson

# 添加执行权限
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

cd /etc/etcd/ssl 
# 写入生成证书所需的配置文件
echo '{
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
' >> ca-config.json 

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

echo '{
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
' >> etcd-ca-csr.json 

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

cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca
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

echo '{
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
' >> etcd-csr.json 
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
   -ca=etcd-ca.pem \
   -ca-key=etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,192.168.3.131,192.168.3.132,192.168.3.133,::1 \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare etcd
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


### 将证书复制到其他节点
Master='k8s-master02 k8s-master03'
for NODE in $Master; do ssh $NODE "mkdir -p /etc/etcd/ssl"; for FILE in etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pem; do scp /etc/etcd/ssl/${FILE} $NODE:/etc/etcd/ssl/${FILE}; done; done

# 这个命令是一个简单的for循环，在一个由`$Master`存储的主机列表中迭代执行。对于每个主机，它使用`ssh`命令登录到主机，并在远程主机上创建一个名为`/etc/etcd/ssl`的目录（如果不存在）。接下来，它使用`scp`将本地主机上`/etc/etcd/ssl`目录中的四个文件（`etcd-ca-key.pem`，`etcd-ca.pem`，`etcd-key.pem`和`etcd.pem`）复制到远程主机的`/etc/etcd/ssl`目录中。最终的结果是，远程主机上的`/etc/etcd/ssl`目录中包含与本地主机上相同的四个文件的副本。

```


### 安装 etcd集群

在3台机器上安装etcd 组成集群

```bash

wget https://github.com/etcd-io/etcd/releases/download/v3.6.7/etcd-v3.6.7-linux-amd64.tar.gz
tar -xf etcd*.tar.gz && mv etcd-*/etcd /usr/local/bin/ && mv etcd-*/etcdctl /usr/local/bin/

### 生成配置文件，每个节点的ip信息手动修改
echo '# 修改此处
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
# 各个节点修改此处
listen-peer-urls: 'https://192.168.3.131:2380'
# 各个节点修改此处
listen-client-urls: 'https://192.168.3.131:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
# 各个节点修改此处
initial-advertise-peer-urls: 'https://192.168.3.131:2380'
# 各个节点修改此处
advertise-client-urls: 'https://192.168.3.131:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
# 各个节点修改此处
initial-cluster: 'k8s-master01=https://192.168.3.131:2380,k8s-master02=https://192.168.3.132:2380,k8s-master03=https://192.168.3.133:2380'
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
' >> /etc/etcd/etcd.config.yml

#这个配置文件是用于 etcd 集群的配置，其中包含了一些重要的参数和选项：

#- `name`：指定了当前节点的名称，用于集群中区分不同的节点。
#- `data-dir`：指定了 etcd 数据的存储目录。
#- `wal-dir`：指定了 etcd 数据写入磁盘的目录。
#- `snapshot-count`：指定了触发快照的事务数量。
#- `heartbeat-interval`：指定了 etcd 集群中节点之间的心跳间隔。
#- `election-timeout`：指定了选举超时时间。
#- `quota-backend-bytes`：指定了存储的限额，0 表示无限制。
#- `listen-peer-urls`：指定了节点之间通信的 URL，使用 HTTPS 协议。
#- `listen-client-urls`：指定了客户端访问 etcd 集群的 URL，同时提供了本地访问的 URL。
#- `max-snapshots`：指定了快照保留的数量。
#- `max-wals`：指定了日志保留的数量。
#- `initial-advertise-peer-urls`：指定了节点之间通信的初始 URL。
#- `advertise-client-urls`：指定了客户端访问 etcd 集群的初始 URL。
#- `discovery`：定义了 etcd 集群发现相关的选项。
#- `initial-cluster`：指定了 etcd 集群的初始成员。
#- `initial-cluster-token`：指定了集群的 token。
#- `initial-cluster-state`：指定了集群的初始状态。
#- `strict-reconfig-check`：指定了严格的重新配置检查选项。
#- `enable-v2`：启用了 v2 API。
#- `enable-pprof`：启用了性能分析。
#- `proxy`：设置了代理模式。
#- `client-transport-security`：客户端的传输安全配置。
#- `peer-transport-security`：节点之间的传输安全配置。
#- `debug`：是否启用调试模式。
#- `log-package-levels`：日志的输出级别。
#- `log-outputs`：指定了日志的输出类型。
#- `force-new-cluster`：是否强制创建一个新的集群。

#这些参数和选项可以根据实际需求进行调整和配置。
## 创建service
echo '[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target
[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.config.yml
TimeoutSec=0
RestartSec=60
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
[Install]
WantedBy=multi-user.target
Alias=etcd3.service
' >> /usr/lib/systemd/system/etcd.service 

# 这是一个系统服务配置文件，用于启动和管理Etcd服务。
# 
# [Unit] 部分包含了服务的一些基本信息，它定义了服务的描述和文档链接，并指定了服务应在网络连接之后启动。
# 
# [Service] 部分定义了服务的具体配置。在这里，服务的类型被设置为notify，意味着当服务成功启动时，它将通知系统。ExecStart 指定了启动服务时要执行的命令，这里是运行 /usr/local/bin/etcd 命令并传递一个配置文件 /etc/etcd/etcd.config.yml。Restart 设置为 on-failure，意味着当服务失败时将自动重启，并且在10秒后进行重启。LimitNOFILE 指定了服务的最大文件打开数。
# 
# [Install] 部分定义了服务的安装配置。WantedBy 指定了服务应该被启动的目标，这里是 multi-user.target，表示在系统进入多用户模式时启动。Alias 定义了一个别名，可以通过etcd3.service来引用这个服务。
# 
# 这个配置文件描述了如何启动和管理Etcd服务，并将其安装到系统中。通过这个配置文件，可以确保Etcd服务在系统启动后自动启动，并在出现问题时进行重启。

systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now etcd.service
# 启用并立即启动etcd.service单元。etcd.service是etcd守护进程的systemd服务单元。

systemctl status etcd.service
# etcd.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 查看etcd状态

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
export ETCDCTL_API=3
etcdctl --endpoints="192.168.3.131:2379,192.168.3.132:2379,192.168.3.133:2379" --cacert=/etc/etcd/ssl/etcd-ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  endpoint status --write-out=table

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
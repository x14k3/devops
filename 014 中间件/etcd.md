# etcd

是一个分布式的，一致的 key-value 存储，主要用途是共享配置和服务发现。etcd的使用场景默认处理的数据都是控制数据，对于应用数据，只推荐数据量很小，但是更新访问频繁的情况。

1. 简单：基于HTTP+JSON的API让你用curl就可以轻松使用。
2. 安全：可选SSL客户认证机制。
3. 快速：每个实例每秒支持一千次写操作。
4. 可信：使用Raft算法充分实现了分布式。

## etcd 单机部署

```bash
# 下载二进制源码包,解压即可直接使用
https://github.com/etcd-io/etcd/releases/tag/v3.4.20


# 启动etcd，通过【配置文件】、【命令行标志】和【环境变量】来配置etcd

########## 命令行标记 单机启动 ########## 
nohup ./etcd --name etcd-node1 \
--data-dir /data/etcd/data \
--listen-client-urls http://192.168.10.150:2379 \
--advertise-client-urls http://192.168.10.150:2379 2>&1 >/tmp/etcd-node-1.log &

##########  配置文件 单机启动 ########## 
vim etcd-node-1.yml
------------------------------------------
name: tmp-test
data-dir: /data/etcd/data
listen-client-urls: http://192.168.10.150:2379
advertise-client-urls: http://192.168.10.150:2379
------------------------------------------
nohup ./etcd --config-file etcd-node-1.yml 2>&1 > /tmp/etcd-node-1.log &

#查看是否启动成功
./etcdctl --endpoints=192.168.10.150:2379 endpoint status 
192.168.10.150:2379, 8e9e05c52164694d, 3.4.20, 20 kB, true, false, 2, 4, 4, 

#### 注册为systemctl
cat  >> /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
Documentation=https://github.com/coreos/etcd
After=network.target

[Service]
User=root
Type=notify
EnvironmentFile=-/data/etcd/etcd.conf
ExecStart=/data/etcd/etcd
Restart=on-failure
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

# systemctl指定的EnvironmentFile为环境变量，所以该文件中使用环境变量格式
cat >> /data/etcd/etcd.conf  <<EOF
ETCD_NAME=test
ETCD_DATA_DIR=/data/etcd/data
ETCD_LISTEN_CLIENT_URLS=http://192.168.130.134:2333
ETCD_ADVERTISE_CLIENT_URLS=http://192.168.130.134:2333
EOF

systemctl daemon-reload
systemctl start etcd

```

## etcd 集群部署

etcd集群可以配置证书进行安全认证，在部署集群之前需要制作etcd所用到的证书。
这里安装证书用到了cfssl工具，先安装cfssl工具

### 证书配置

#### 1. 安装cfssl

```bash
wget -O /usr/bin/cfssl          https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssl_1.6.0_linux_amd64 
wget -O /usr/bin/cfssljson      https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssljson_1.6.0_linux_amd64   
wget -O /usr/bin/cfssl-certinfo https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssl-certinfo_1.6.0_linux_amd64  
chmod +x /usr/bin/cfssl*
```

#### 2. CA证书配置文件ca-config.json

- expiry：指定了证书的过期时间为87600小时（即10年）
- profiles证书类型
  client certificate：用于服务端认证客户端,例如etcdctl、etcd proxy、fleetctl、docker客户端
  server certificate :  服务端使用，客户端以此验证服务端身份,例如docker服务端、kube-apiserver
  peer certificate :    双向证书，用于etcd集群成员间通信

`cfssl print-defaults config > ca-config.json`

```json
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "peer": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            },
            "server": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}

```

#### 3. CA证书凭证签发配置文件ca-csr.json

`cfssl print-defaults csr > ca-csr.json`

```json
{
    "CN": "example.net",  // 标识具体的域
    "hosts": [            // 使用该证书的域名
        "example.net",
        "www.example.net"
    ],
    "key": {              // 加密方式，一般RSA 2048
        "algo": "ecdsa",
        "size": 256
    },
    "names": [            // 证书包含的信息，例如国家、地区等
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}

```

#### 4. 生成CA证书和私钥

`cfssl gencert -initca ca-csr.json | cfssljson -bare ca`

#### 5. 生成server端证书

`cfssl print-defaults csr > etcd-server.json`

```json
// 修改如下部分
 "CN": "etcd",   // 服务域名 
 "hosts": [ 
 "172.29.203.58" // server地址 
 ],

```

`cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server etcd-server.json | cfssljson -bare etcd-server`

#### 6. 生成client端证书

`cfssl print-defaults csr > etcd-client.json`

```json
// 修改如下部分
 "CN": "etcd",   // 服务域名 
 "hosts": [ 
 "172.29.203.58" // 允许的clinet地址，不指定为允许所有
 ],
```

`cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client etcd-client.json | cfssljson -bare etcd-client`

#### 7. 生成peer端证书

`cfssl print-defaults csr > etcd-peer.json`

```json
// 修改如下部分
 "CN": "etcd",   // 服务域名 
 "hosts": [ 
 "172.29.203.58" //允许的peer地址
 ],
```

`cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer etcd-peer.json | cfssljson -bare etcd-peer`

#### 8. 服务证书到指定位置

```bash
# 服务证书到指定位置
mkdir /etc/etcd/pki/
cp -rp *.pem /etc/etcd/pki/
chmod 755 /etc/etcd/pki
chmod 644 /etc/etcd/pki/*.pem
# 该目录下分别为cline、server、peer的公钥和私钥，
# 以及ca的公钥和私钥（cd的私钥这里不需要，安全起见还是不要放到这里）

```

## etcd 相关配置

### 成员相关配置项

```bash
--name   #节点名称
default: "default"
env variable: ETCD_NAME
#这个值和--initial-cluster flag (e.g., default=http://localhost:2380)中的key值一一对应，如果在集群环境中，name必须是唯一的，建议用主机名称或者机器ID。
--data-dir  #数据存储目录
default: "${name}.etcd"
env variable: ETCD_DATA_DIR
--wal-dir  #存放预写式日志,最大的作用是记录了整个数据变化的全部历程。未设置，共用--data-dir文件所在目录。可以配置路径为专用磁盘，有助于避免日志记录和其他io操作之间的io竞争
default: ""
env variable: ETCD_WAL_DIR

--snapshot-count   #数据快照触发数量，etcd处理指定的次数的事务提交后，生成数据快照
default: "100000"
env variable: ETCD_SNAPSHOT_COUNT

--heartbeat-interval  #客户端连接后的心跳间隔（毫秒）
default: "100"
env variable: ETCD_HEARTBEAT_INTERVAL

--election-timeout  #集群选举的超时时间
default: "1000"
env variable: ETCD_ELECTION_TIMEOUT

--listen-peer-urls   #本节点与其他节点进行数据交换(选举，数据同步)的监听地址，地址写法是 scheme://IP:port，可以多个并用逗号隔开，如果配置是http://0.0.0.0:2380,将不限制node访问地址
default: "http://localhost:2380"
env variable: ETCD_LISTEN_PEER_URLS
example: "http://10.0.0.1:2380"
invalid example: "http://example.com:2380" (domain name is invalid for binding)

--listen-client-urls  #监听地址，地址写法是 scheme://IP:port，可以多个并用逗号隔开，如果配置是http://0.0.0.0:2379,将不限制node访问地址
default: "http://localhost:2379"
env variable: ETCD_LISTEN_CLIENT_URLS
example: "http://10.0.0.1:2379"
invalid example: "http://example.com:2379" (domain name is invalid for binding)

--max-snapshots  #要保留的快照文件的最大数量，0是无限制。Windows用户的默认值是无限制的，建议设置5以下的值。
default: 5
env variable: ETCD_MAX_SNAPSHOTS

--max-wals    #要保留的wal文件的最大数量，0是无限制。Windows用户的默认值是无限制的，建议设置5以下的值。
default: 5
env variable: ETCD_MAX_WALS

--cors     #Comma-separated white list of origins for CORS (cross-origin resource sharing).
default: ""
env variable: ETCD_CORS

--quota-backend-bytes    #当后端大小超过给定的配额时发出报警
default: 0
env variable: ETCD_QUOTA_BACKEND_BYTES
#如果键空间的任何成员的后端数据库超过了空间配额， etcd 发起集群范围的警告，让集群进入维护模式，仅接收键的读取和删除。在键空间释放足够的空间之后，警告可以被解除，而集群将恢复正常运作。

--backend-batch-limit   #提交后端实物之前的最大操作
default: 0
env variable: ETCD_BACKEND_BATCH_LIMIT

--backend-batch-interval   #提交后端事物之前的最长时间
default: 0
env variable: ETCD_BACKEND_BATCH_INTERVAL

--max-txn-ops     #事物中允许的最大操作数
default: 128
env variable: ETCD_MAX_TXN_OPS

--max-request-bytes   #服务器可以接受的客户端请求大小
default: 1572864
env variable: ETCD_MAX_REQUEST_BYTES

--grpc-keepalive-min-time   #客户端在ping服务器之前最少要等待多久
default: 5s
env variable: ETCD_GRPC_KEEPALIVE_MIN_TIME

--grpc-keepalive-interval   #服务器ping客户端的频率，检查连接是否处于活动状态（0表示禁用）
default: 2h
env variable: ETCD_GRPC_KEEPALIVE_INTERVAL

--grpc-keepalive-timeout   #关闭非响应连接之前额外等待时间（0表示禁用）
default: 20s
env variable: ETCD_GRPC_KEEPALIVE_TIMEOUT


```

---

### 集群配置

```bash
--initial-advertise-peer-urls    #通知其他节点与本节点进行数据交换（选举，同步）的地址，URL可以使用domain地址。
default: "http://localhost:2380"
env variable: ETCD_INITIAL_ADVERTISE_PEER_URLS
example: "http://example.com:2380, http://10.0.0.1:2380"
#与--listener-peer-urls不同在于listener-peer-urls用于请求客户端的接入控制，initial-advertise-peer-urls是告知其他集群节点访问哪个URL，一般来说，initial-advertise-peer-urlsl将是istener-peer-urls的子集

--initial-cluster   #用于引导初始集群配置，集群中所有节点的信息。
default: "default=http://localhost:2380"
env variable: ETCD_INITIAL_CLUSTER
#此处default为节点的--name指定的名字；localhost:2380为--initial-advertise-peer-urls指定的值。

--initial-cluster-state  #加入集群的当前状态，new是新集群，existing表示加入已有集群
default: "new"
env variable: ETCD_INITIAL_CLUSTER_STATE

--initial-cluster-token  #集群唯一标识，相同标识的节点将视为在一个集群内
default: "etcd-cluster"
env variable: ETCD_INITIAL_CLUSTER_TOKEN

--advertise-client-urls   #用于通知其他ETCD节点，客户端接入本节点的监听地址，一般来说advertise-client-urls是listen-client-urls子集，这些URL可以包含域名。
default: "http://localhost:2379"
env variable: ETCD_ADVERTISE_CLIENT_URLS
example: "http://example.com:2379, http://10.0.0.1:2379"
#注意，不能写http://localhost:237，这样就是通知其他节点，可以用localhost访问，将导致ectd的客户端用localhost访问本地,导致访问不通。还有一个更可怕情况，ectd布置了代理层，代理层将一直通过locahost访问自己的代理接口，导致无限循环。

--discovery    #集群发现服务地址
default: none
env variable: ETCD_DISCOVERY_SRV

--discovery-srv   #用于引导集群的DNS sry域
default: ""
env variable: ETCD_DISCOVERY_SRV

--discovery-srv-name   #使用DNS引导时查询的DNS srv名称的后缀
default: ""
env variable: ETCD_DISCOVERY_SRV_NAME

--discovery-fallback  #发现服务失败时的预期行为（“退出”或“代理”）。“proxy”仅支持v2 API
default: "proxy"
env variable: ETCD_DISCOVERY_FALLBACK

--discovery-proxy  #用于流量到发现服务的HTTP代理
default: ""
env variable: ETCD_DISCOVERY_PROXY

--strict-reconfig-check  #拒绝可能导致仲裁丢失的重新配置请求。
default: true
env variable: ETCD_STRICT_RECONFIG_CHECK

--auto-compaction-retention  #在一个小时内为mvcc键值存储的自动压实保留。0表示禁用自动压缩
default: 0
env variable: ETCD_AUTO_COMPACTION_RETENTION

--auto-compaction-mode  #说明--auto-compaction-retention配置的基于时间保留的三种模式：periodic, revision. periodic
default: periodic
env variable: ETCD_AUTO_COMPACTION_MODE

--enable-v2   #接受etcd V2客户端请求
default: true
env variable: ETCD_ENABLE_V2

```

---

### 其他（代理、安全）

```bash
##### 代理 #####
--proxy     #代理模式设置，（"off", "readonly" or "on"）
default: "off"
env variable: ETCD_PROXY

--proxy-failure-wait  #在重新考虑代理请求之前，endpoints 将处于失败状态的时间（以毫秒为单位）
default: 5000
env variable: ETCD_PROXY_FAILURE_WAIT

--proxy-refresh-interval   #endpoints 刷新间隔的时间（以毫秒为单位）
default: 30000
env variable: ETCD_PROXY_REFRESH_INTERVAL

--proxy-dial-timeout    #拨号超时的时间（以毫秒为单位）或0表示禁用超时
default: 1000
env variable: ETCD_PROXY_DIAL_TIMEOUT

--proxy-write-timeout   #写入超时的时间（以毫秒为单位）或0以禁用超时
default: 5000
env variable: ETCD_PROXY_WRITE_TIMEOUT

--proxy-read-timeout   #读取超时的时间（以毫秒为单位）或0以禁用超时。如果使用watch，不要改变这个值，因为使用长轮询请求
default: 0
env variable: ETCD_PROXY_READ_TIMEOUT


##### 安全 #####
--ca-file      #已弃用，可以替换为--trusted-ca-file ca.crt、--client-cert-auth，etcd将执行相同的操作
default: ""
env variable: ETCD_CA_FILE
--cert-file   #客户端服务器TLS证书文件的路径。
default: ""
env variable: ETCD_CERT_FILE
--key-file   #客户端服务器TLS密钥文件的路径
default: ""
env variable: ETCD_KEY_FILE
--client-cert-auth      #启用客户端证书验证。
default: false
env variable: ETCD_CLIENT_CERT_AUTH
#grpc-gateway不支持CN身份验证
--client-crl-file    #客户端证书吊销列表文件的路径
default: ""
env variable: ETCD_CLIENT_CRL_FILE
--trusted-ca-file    #客户端服务器的路径TLS可信CA证书文件
default: ""
env variable: ETCD_TRUSTED_CA_FILE
--auto-tls     #客户端TLS使用生成的证书
default: false
env variable: ETCD_AUTO_TLS
--peer-ca-file   #已弃用，可以替换为--peer-trusted-ca-file ca.crt --peer-client-cert-auth，etcd将执行相同的操作。
default: ""
env variable: ETCD_PEER_CA_FILE
--peer-cert-file     #对等服务器TLS证书文件的路径。这是对等流量的证书，用于服务器和客户端。
default: ""
env variable: ETCD_PEER_CERT_FILE
--peer-key-file    #对等服务器TLS密钥文件的路径。这是对等流量的关键，用于服务器和客户端。
default: ""
env variable: ETCD_PEER_KEY_FILE
--peer-client-cert-auth   #启用对等客户端证书验证
default: false
env variable: ETCD_PEER_CLIENT_CERT_AUTH
--peer-crl-file     #对等证书吊销列表文件的路径。
default: ""
env variable: ETCD_PEER_CRL_FILE
--peer-trusted-ca-file    #对等服务器TLS可信CA文件的路径
default: ""
env variable: ETCD_PEER_TRUSTED_CA_FILE
--peer-auto-tls    #Peer TLS使用自动生成的证书
default: false
env variable: ETCD_PEER_AUTO_TLS
--peer-cert-allowed-cn    #允许CommonName进行对等体认证
default: none
env variable: ETCD_PEER_CERT_ALLOWED_CN
--cipher-suites
#Comma-separated list of supported TLS cipher suites between server/client and peers.
default: ""
env variable: ETCD_CIPHER_SUITES


##### 日志配置 #####
--logger    #为结构化日志记录指定'zap'或'capnslog'。
default: capnslog
env variable: ETCD_LOGGER
--log-outputs   #指定'stdout'或'stderr'以跳过日志记录，即使在systemd或逗号分隔的输出目标列表下运行也是如此。
default: default
env variable: ETCD_LOG_OUTPUTS
#在zap日志程序迁移期间，默认使用v3.4的“stderr”配置
--debug    #将所有子包的默认日志级别设置为DEBUG。
default: false (INFO for all packages)
env variable: ETCD_DEBUG
--log-package-levels        #将单个etcd子包设置为特定的日志级别。一个例子是etcdserver=WARNING,security=DEBUG
default: "" (INFO for all packages)
env variable: ETCD_LOG_PACKAGE_LEVELS


##### 非安全配置 ##### 
--force-new-cluster      #强制创建新的单成员群集。它提交配置更改，强制删除集群中的所有现有成员并添加自身。需要将其设置为还原备份。
default: false
env variable: ETCD_FORCE_NEW_CLUSTER


##### 其他配置 #####
--version   #Print the version and exit.
default: false
--config-file        #从文件中加载服务器配置。注意如果提供了配置文件，其他命令行参数和环境变量将被忽略
default: ""
example: sample configuration file
env variable: ETCD_CONFIG_FILE

##### 性能配置 #####
--enable-pprof       #通过HTTP服务器启用运行时分析数据。地址位于客户端URL +“/ debug / pprof /”
default: false
env variable: ETCD_ENABLE_PPROF
--metrics         #设置导出的指标的详细程度，指定“扩展”以包括直方图指标。
default: basic
env variable: ETCD_METRICS
--listen-metrics-urls          #要监听的其他URL列表将响应端点/metrics和/health端点
default: ""
env variable: ETCD_LISTEN_METRICS_URLS

##### 认证配置 #####
--auth-token
default: "simple"
env variable: ETCD_AUTH_TOKEN
--bcrypt-cost          #为散列身份验证密码指定bcrypt算法的成本/强度。有效值介于4和31之间。
default: 10
env variable: (not supported)
```

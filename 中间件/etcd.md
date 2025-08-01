
[[../k8s/企业部署实战_K8S#K8S前置准备工作|企业部署实战_K8S]]

### 准备证书

```bash
# 我们开始制作证书，200机器：
# 在200机器：

# cfssl方式做证书，需要三个软件，按照我们的架构图，我们部署在200机器:
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O /usr/bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O /usr/bin/cfssl-json
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O /usr/bin/cfssl-certinfo
chmod +x /usr/bin/cfssl*

mkdir /opt/certs
cd /opt/certs/

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


echo '
{
    "signing": {
        "default": {
            "expiry": "1752000h"
        },
        "profiles": {
            "server": {
                "expiry": "1752000h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "1752000h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "1752000h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
} ' >> /opt/certs/ca-config.json

echo '
{
    "CN": "k8s-etcd",
    "hosts": [
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
} ' >> /opt/certs/etcd-peer-csr.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer etcd-peer-csr.json |cfssl-json -bare etcd-peer
```

>**ca-config.json解析：**
	- expiry：有效期为200年
	- profiles-server：启动server的时候需要配置证书
	- profiles-client：client去连接server的时候需要证书
	- profiles-peer：双向证书，服务端找客户端需要证书，客户端找服务端需要证书
>**etcd-peer-csr解析：**
	- hosts：etcd有可能部署到哪些组件的IP都要填进来
>**cfssl gencert**：生成证书

### 安装etcd

在12/21/22机器

```bash
# 12/21/22机器，安装etcd：
cd /data
# 创建用户
useradd -s /sbin/nologin -M etcd
id etcd

# 到GitHub下载安装包 https://github.com/etcd-io/etcd/releases/tag/v3.1.20
wget https://github.com/etcd-io/etcd/releases/download/v3.1.20/etcd-v3.1.20-linux-amd64.tar.gz
tar xf etcd-v3.1.20-linux-amd64.tar.gz 
mv etcd-v3.1.20-linux-amd64 etcd-v3.1.20

cd etcd-v3.1.20
mkdir data certs logs
scp hdss-7-200:/opt/certs/ca.pem /data/etcd-v3.1.20/certs
scp hdss-7-200:/opt/certs/etcd-peer.pem /data/etcd-v3.1.20/certs
scp hdss-7-200:/opt/certs/etcd-peer-key.pem /data/etcd-v3.1.20/certs


# 注意，如果是21机器，这下面得12都得改成21，initial-cluster则是全部机器都有不需要改，一共5处：etcd-server-12、listen-peer-urls后、client-urls后、advertise-peer-urls后、advertise-client-urls后
echo '#!/bin/sh
./etcd --name etcd-server-12 \
       --data-dir /data/etcd-v3.1.20/data \
       --listen-peer-urls https://192.168.133.12:2380 \
       --listen-client-urls https://192.168.133.12:2379,http://127.0.0.1:2379 \
       --quota-backend-bytes 8000000000 \
       --initial-advertise-peer-urls https://192.168.133.12:2380 \
       --advertise-client-urls https://192.168.133.12:2379,http://127.0.0.1:2379 \
       --initial-cluster  etcd-server-12=https://192.168.133.12:2380,etcd-server-21=https://192.168.133.21:2380,etcd-server-22=https://192.168.133.22:2380 \
       --ca-file ./certs/ca.pem \
       --cert-file ./certs/etcd-peer.pem \
       --key-file ./certs/etcd-peer-key.pem \
       --client-cert-auth  \
       --trusted-ca-file ./certs/ca.pem \
       --peer-ca-file ./certs/ca.pem \
       --peer-cert-file ./certs/etcd-peer.pem \
       --peer-key-file ./certs/etcd-peer-key.pem \
       --peer-client-cert-auth \
       --peer-trusted-ca-file ./certs/ca.pem \
       --log-output stdout ' >> /data/etcd-v3.1.20/etcd-server-startup.sh

chmod +x etcd-server-startup.sh
chown -R etcd.etcd /data/etcd-v3.1.20/

### 分别拷贝到12/21/22
ssh hdss-7-21 'mkdir /data'
ssh hdss-7-21 'useradd -s /sbin/nologin -M etcd'
ssh hdss-7-22 'mkdir /data'
ssh hdss-7-22 'useradd -s /sbin/nologin -M etcd'
scp -r /data/etcd-v3.1.20 hdss-7-21:/data/
scp -r /data/etcd-v3.1.20 hdss-7-22:/data/

```

### 后台运行

```bash
# 12/21/22机器，我们同时需要supervisor（守护进程工具）来确保etcd是启动的，后面还会不断用到：
yum install supervisor -y
systemctl start supervisord
systemctl enable supervisord
# 注意修改下面得12，对应上机器，如21机器就是21，一共一处：[program:etcd-server-12]

echo '[program:etcd-server-12]
command=/data/etcd-v3.1.20/etcd-server-startup.sh               ; the program (relative uses PATH, can take args)
numprocs=1                                                      ; number of processes copies to start (def 1)
directory=/data/etcd-v3.1.20                                    ; directory to cwd to before exec (def no cwd)
autostart=true                                                  ; start at supervisord start (default: true)
autorestart=true                                                ; retstart at unexpected quit (default: true)
startsecs=30                                                    ; number of secs prog must stay running (def. 1)
startretries=3                                                  ; max # of serial start failures (default 3)
exitcodes=0,2                                                   ; 'expected' exit codes for process (default 0,2)
stopsignal=QUIT                                                 ; signal used to kill process (default TERM)
stopwaitsecs=10                                                 ; max num secs to wait b4 SIGKILL (default 10)
user=etcd                                                       ; setuid to this UNIX account to run the program
redirect_stderr=true                                            ; redirect proc stderr to stdout (default false)
stdout_logfile=/data/etcd-v3.1.20/logs/etcd.stdout.log          ; stdout log path, NONE for none; default AUTO
stdout_logfile_maxbytes=64MB                                    ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=4                                        ; # of stdout logfile backups (default 10)
stdout_capture_maxbytes=1MB                                     ; number of bytes in 'capturemode' (default 0)
stdout_events_enabled=false                                     ; emit events on stdout writes (default false) ' >> /etc/supervisord.d/etcd-server.ini

supervisorctl update
# out：etcd-server-7-21: added process group
supervisorctl start etcd-server-12
supervisorctl start etcd-server-21
supervisorctl start etcd-server-22
supervisorctl status
# out: etcd-server-7-12                 RUNNING   pid 16582, uptime 0:00:59
netstat -luntp|grep etcd
# 必须是监听了2379和2380这两个端口才算成功

# 任意节点（12/21/22）检测集群健康状态的两种方法
./etcdctl cluster-health
./etcdctl member list
```

> 这里你再哪个机器先update，哪个机器就是leader

完成

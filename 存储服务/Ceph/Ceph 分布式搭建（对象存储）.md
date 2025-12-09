
搭建一个专门用于对象存储（RADOS Gateway）的Ceph分布式集群。

## **1. 环境准备**

### **1.1 架构规划**

```bash
节点1 (node1): Monitor + Manager + RGW + OSD
节点2 (node2): Monitor + RGW + OSD
节点3 (node3): Monitor + OSD
节点4 (node4): OSD + RGW（可选）
```

### **1.2 系统配置**

```bash
# 所有节点执行
# 设置主机名和hosts
cat > /etc/hosts << EOF
192.168.1.10 node1
192.168.1.11 node2
192.168.1.12 node3
192.168.1.13 node4
EOF

# 禁用防火墙和SELinux
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 配置时间同步
yum install -y chrony
systemctl enable --now chronyd
chronyc sources
```

## **2. 部署Ceph集群**

### **2.1 安装cephadm（所有节点）**

```bash
# 方法1：使用官方脚本
curl -L https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm -o /usr/bin/cephadm
chmod +x /usr/bin/cephadm

# 方法2：使用包管理器（推荐）
dnf install -y cephadm  # RHEL 8/CentOS 8

# 添加Ceph仓库
cephadm add-repo --release quincy
cephadm install ceph-common ceph-base
```

### **2.2 初始化集群（在node1执行）**

```bash
# 引导集群
cephadm bootstrap \
  --mon-ip 192.168.1.10 \
  --initial-dashboard-user admin \
  --initial-dashboard-password admin123 \
  --allow-fqdn-hostname \
  --cluster-network 192.168.1.0/24 \
  --skip-monitoring-stack \
  --dashboard-password-noupdate

# 验证集群
ceph status
ceph orch status

# 安装命令行工具
cephadm install ceph-common
```

### **2.3 添加其他节点**

```bash
# 将SSH密钥复制到其他节点
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node2
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node3
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node4

# 添加主机到集群
ceph orch host add node2 192.168.1.11
ceph orch host add node3 192.168.1.12
ceph orch host add node4 192.168.1.13

# 查看主机列表
ceph orch host ls
```

## **3. 部署存储设备（OSD）**

### **3.1 自动部署OSD**

```bash
# 查看可用设备
ceph orch device ls

# 自动部署所有可用磁盘（最简单方式）
ceph orch apply osd --all-available-devices

# 或手动指定设备
ceph orch daemon add osd node1:/dev/sdb
ceph orch daemon add osd node2:/dev/sdb
ceph orch daemon add osd node3:/dev/sdb
ceph orch daemon add osd node4:/dev/sdb

# 查看OSD状态
ceph osd tree
ceph osd stat
```

### **3.2 使用规格文件部署OSD**

```bash
# 创建OSD规格文件
cat > osd_spec.yaml << EOF
service_type: osd
service_id: rgw-osds
placement:
  hosts:
    - node1
    - node2
    - node3
    - node4
spec:
  data_devices:
    paths:
      - /dev/sdb
      - /dev/sdc
  db_devices:
    paths:
      - /dev/nvme0n1  # 如果有SSD用于元数据
  encrypted: false
  osds_per_device: 1
EOF

ceph orch apply -i osd_spec.yaml
```

## **4. 部署对象存储服务（RGW）**

### **4.1 创建专用存储池**

```bash
# RGW需要多个专用池，但会自动创建
# 我们可以预先创建并优化参数

# 计算PG数量（公式：(OSD数量 × 100) / 副本数）
# 假设4个OSD，副本数3： (4×100)/3 ≈ 133，取128

# 创建根池（已自动创建，但可调整）
ceph osd pool create .rgw.root 32 32
ceph osd pool set .rgw.root size 3
ceph osd pool set .rgw.root min_size 2

# 创建其他可能用到的池
for pool in .rgw.control .rgw.meta .rgw.log .rgw.buckets.index .rgw.buckets.data .rgw.buckets.non-ec; do
  ceph osd pool create $pool 128 128
  ceph osd pool set $pool size 3
  ceph osd pool set $pool min_size 2
done

# 启用应用标签
for pool in .rgw.root .rgw.control .rgw.meta .rgw.log .rgw.buckets.index .rgw.buckets.data .rgw.buckets.non-ec; do
  ceph osd pool application enable $pool rgw
done
```

### **4.2 部署RADOS Gateway服务**

#### **方式1：使用命令行部署**

```bash
# 部署RGW服务（基本配置）
ceph orch apply rgw object-store \
  --placement="3 node1 node2 node4" \
  --port=8080 \
  --ssl=false

# 查看RGW服务状态
ceph orch ps --daemon-type rgw
```

#### **方式2：使用规格文件部署（推荐）**

```bash
# 创建RGW规格文件
cat > rgw_spec.yaml << EOF
service_type: rgw
service_id: object-store
service_name: rgw.object-store
placement:
  hosts:
    - node1
    - node2
    - node4
  count: 3
spec:
  # 网络配置
  rgw_frontend_type: "beast"
  rgw_frontend_port: 8080
  rgw_frontend_ssl_certificate: ""
  
  # 性能优化
  rgw_num_rados_handles: 256
  rgw_thread_pool_size: 512
  rgw_cache_enabled: true
  rgw_cache_lru_size: 10000
  
  # 区域配置
  rgw_realm: myrealm
  rgw_zonegroup: myzonegroup
  rgw_zone: myzone
  
  # 资源限制
  rgw_max_chunk_size: 4194304  # 4MB
  rgw_objexp_gc_interval: 600  # 10分钟
  rgw_objexp_time: 86400       # 1天
  
  # 日志配置
  rgw_log_object_name: "%Y-%m-%d-%H-%i-%n"
  rgw_log_object_name_utc: true
  rgw_enable_usage_log: true
EOF

# 应用规格文件
ceph orch apply -i rgw_spec.yaml
```

### **4.3 验证RGW部署**

```bash
# 查看所有服务
ceph orch ls

# 查看RGW特定服务
ceph orch ls --service-type rgw

# 查看RGW守护进程
ceph orch ps --daemon-type rgw

# 检查RGW端点
ceph orch ls --service-name rgw.object-store --format json-pretty | jq -r '.[].status.running'

# 测试RGW是否响应
curl http://node1:8080
```

## **5. 配置对象存储域和用户**

### **5.1 创建和管理域（Realm）**

```bash
# 查看当前域
radosgw-admin realm list

# 创建新域（如果尚未创建）
radosgw-admin realm create --rgw-realm=myrealm --default

# 创建区域组
radosgw-admin zonegroup create \
  --rgw-zonegroup=myzonegroup \
  --master \
  --default \
  --endpoints=http://node1:8080,http://node2:8080,http://node4:8080

# 创建主区域
radosgw-admin zone create \
  --rgw-zonegroup=myzonegroup \
  --rgw-zone=myzone \
  --master \
  --default \
  --endpoints=http://node1:8080,http://node2:8080,http://node4:8080 \
  --access-key=SYSTEM_ACCESS_KEY \
  --secret-key=SYSTEM_SECRET_KEY

# 更新并提交更改
radosgw-admin period update --commit
```

### **5.2 创建和管理用户**

```bash
# 创建S3用户
radosgw-admin user create \
  --uid="testuser" \
  --display-name="Test User" \
  --email="test@example.com" \
  --access-key="AKIAIOSFODNN7EXAMPLE" \
  --secret-key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# 创建Swift用户（如果需要）
radosgw-admin subuser create \
  --uid=testuser \
  --subuser=testuser:swift \
  --access=full

# 生成Swift密钥
radosgw-admin key create \
  --subuser=testuser:swift \
  --key-type=swift \
  --gen-secret

# 查看用户信息
radosgw-admin user info --uid=testuser

# 修改用户配额
radosgw-admin quota set \
  --uid=testuser \
  --bucket=mybucket \
  --max-size=10737418240  # 10GB
  --max-objects=10000

# 启用配额
radosgw-admin quota enable --uid=testuser --quota-scope=bucket
```

## **6. 客户端配置和使用**

### **6.1 安装S3客户端工具**

```bash
# 安装AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 或者使用pip安装
pip3 install awscli

# 安装s3cmd（可选）
yum install -y s3cmd
# 或
pip3 install s3cmd
```

### **6.2 配置AWS CLI**

```bash
# 配置AWS CLI
aws configure set aws_access_key_id AKIAIOSFODNN7EXAMPLE
aws configure set aws_secret_access_key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
aws configure set default.region us-east-1
aws configure set default.s3.signature_version s3v4
aws configure set default.s3.max_concurrent_requests 20
aws configure set default.s3.max_queue_size 10000
aws configure set default.s3.multipart_threshold 64MB
aws configure set default.s3.multipart_chunksize 16MB

# 测试连接（指定端点）
aws --endpoint-url=http://node1:8080 s3 ls
```

### **6.3 配置s3cmd**

```bash
# 配置s3cmd
cat > ~/.s3cfg << EOF
[default]
access_key = AKIAIOSFODNN7EXAMPLE
secret_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
host_base = node1:8080
host_bucket = %(bucket).node1:8080
use_https = False
signature_v2 = False
check_ssl_certificate = False
EOF

# 测试s3cmd
s3cmd ls
```

### **6.4 基本操作示例**

```bash
# 创建存储桶
aws --endpoint-url=http://node1:8080 s3 mb s3://mybucket
# 列出所有存储桶
aws --endpoint-url=http://node1:8080 s3 ls
# 上传文件
aws --endpoint-url=http://node1:8080 s3 cp myfile.txt s3://mybucket/
# 下载文件
aws --endpoint-url=http://node1:8080 s3 cp s3://mybucket/myfile.txt ./downloaded.txt
# 同步目录
aws --endpoint-url=http://node1:8080 s3 sync ./localdir s3://mybucket/prefix/
# 删除文件
aws --endpoint-url=http://node1:8080 s3 rm s3://mybucket/myfile.txt
# 删除存储桶（需要先清空）
aws --endpoint-url=http://node1:8080 s3 rb s3://mybucket --force
```

## **7. 高级配置**

### **7.1 配置负载均衡**

```bash
# 使用HAProxy作为负载均衡器
yum install -y haproxy

# 配置HAProxy
cat > /etc/haproxy/haproxy.cfg << EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend rgw_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/private/rgw.pem
    default_backend rgw_backend

backend rgw_backend
    balance roundrobin
    option forwardfor
    server rgw1 node1:8080 check
    server rgw2 node2:8080 check
    server rgw3 node4:8080 check

listen stats
    bind *:1936
    stats enable
    stats uri /
    stats hide-version
    stats auth admin:admin123
EOF

systemctl enable --now haproxy
```

### **7.2 配置多站点复制**

```bash
# 在主站点
# 创建复制用户
radosgw-admin user create --uid=replication-user --display-name="Replication User" --system

# 在从站点
# 拉取域信息
radosgw-admin realm pull --url=http://primary-site:8080 --access-key=ACCESS_KEY --secret-key=SECRET_KEY

# 创建从区域
radosgw-admin zone create --rgw-zonegroup=myzonegroup --rgw-zone=secondary-zone --endpoints=http://secondary-site:8080

# 设置为主区域的从区域
radosgw-admin zone modify --rgw-zone=secondary-zone --master --default=false

# 更新周期
radosgw-admin period update --commit
```

### **7.3 配置生命周期策略**

```bash
# 创建生命周期策略JSON
cat > lifecycle.json << EOF
{
  "Rules": [
    {
      "ID": "TransitionRule",
      "Filter": {
        "Prefix": "archive/"
      },
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      }
    }
  ]
}
EOF

# 应用生命周期策略
aws --endpoint-url=http://node1:8080 s3api put-bucket-lifecycle-configuration \
  --bucket mybucket \
  --lifecycle-configuration file://lifecycle.json
```

## **8. 监控和优化**

### **8.1 启用Ceph Dashboard**

```bash
# 启用Dashboard模块
ceph mgr module enable dashboard

# 创建自签名证书
ceph dashboard create-self-signed-cert

# 设置访问凭据
ceph dashboard set-login-credentials admin admin123

# 配置外部访问
ceph config set mgr mgr/dashboard/server_addr 0.0.0.0
ceph config set mgr mgr/dashboard/server_port 8443
ceph config set mgr mgr/dashboard/ssl true

# 重启Dashboard服务
ceph mgr module disable dashboard
ceph mgr module enable dashboard

# 访问地址：https://node1:8443
```

### **8.2 配置Prometheus监控**

```bash
# 启用Prometheus模块
ceph mgr module enable prometheus

# 创建Prometheus服务
cat > prometheus.yaml << EOF
service_type: prometheus
service_id: prometheus
placement:
  hosts:
    - node1
spec:
  retention_time: 30d
  storage:
    size: 10G
EOF
ceph orch apply -i prometheus.yaml

# 创建Grafana服务
cat > grafana.yaml << EOF
service_type: grafana
service_id: grafana
placement:
  hosts:
    - node1
spec:
  initial_admin_password: admin123
EOF
ceph orch apply -i grafana.yaml
```

### **8.3 性能优化配置**

```bash
# RGW性能调优
ceph config set global rgw_num_rados_handles 512
ceph config set global rgw_thread_pool_size 1024
ceph config set global rgw_max_chunk_size 8388608  # 8MB
ceph config set global rgw_objexp_gc_interval 300  # 5分钟

# OSD性能优化
ceph config set osd osd_op_num_threads_per_shard 4
ceph config set osd osd_op_num_shards 8
ceph config set osd osd_recovery_max_active 10
ceph config set osd osd_recovery_max_single_start 5

# 重启RGW服务应用配置
ceph orch daemon restart rgw.object-store.*
```

## **9. 备份和恢复**

### **9.1 配置RGW元数据备份**

```bash
# 备份元数据
radosgw-admin metadata list bucket
radosgw-admin metadata list user

# 导出所有元数据
for bucket in $(radosgw-admin metadata list bucket | jq -r .[]); do
    radosgw-admin metadata get bucket:$bucket > bucket_${bucket}.json
done

for user in $(radosgw-admin metadata list user | jq -r .[]); do
    radosgw-admin metadata get user:$user > user_${user}.json
done

# 备份周期配置
radosgw-admin period get > period_latest.json
```

### **9.2 创建备份脚本**

```bash
#!/bin/bash
# rgw_backup.sh

BACKUP_DIR="/backup/rgw/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# 备份元数据
echo "备份RGW元数据..."
radosgw-admin metadata list bucket | jq -r .[] | while read bucket; do
    radosgw-admin metadata get bucket:$bucket > $BACKUP_DIR/bucket_${bucket}.json
done

radosgw-admin metadata list user | jq -r .[] | while read user; do
    radosgw-admin metadata get user:$user > $BACKUP_DIR/user_${user}.json
done

# 备份配置
radosgw-admin period get > $BACKUP_DIR/period.json
ceph config dump > $BACKUP_DIR/ceph_config.json

# 压缩备份
tar czf /backup/rgw_backup_$(date +%Y%m%d_%H%M%S).tar.gz $BACKUP_DIR

# 清理旧备份（保留最近7天）
find /backup -name "rgw_backup_*.tar.gz" -mtime +7 -delete

echo "备份完成：/backup/rgw_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
```

## **10. 故障排除**

### **10.1 常见问题解决**

```bash
# 1. RGW服务无法启动
# 查看日志
ceph logs rgw.object-store.node1
journalctl -u ceph-rgw@object-store.node1

# 检查端口占用
netstat -tlnp | grep 8080

# 2. 存储桶操作失败
# 检查用户权限
radosgw-admin user info --uid=testuser

# 检查存储桶策略
radosgw-admin policy --bucket=mybucket

# 3. 上传下载慢
# 检查网络
iperf3 -c node1

# 检查磁盘IO
iostat -x 1

# 4. 认证失败
# 检查密钥
radosgw-admin user info --uid=testuser | jq '.keys[0]'

# 重置密钥
radosgw-admin key create --uid=testuser --key-type=s3 --gen-access-key --gen-secret
```

### **10.2 监控命令**

```bash
# 集群状态
ceph -s
ceph status

# RGW特定状态
ceph orch ps --daemon-type rgw
ceph orch ls --service-type rgw

# 性能统计
ceph perf
ceph osd perf

# 存储使用情况
ceph df
ceph osd df

# 请求统计
radosgw-admin usage show --uid=testuser
radosgw-admin bucket stats --bucket=mybucket
```

### **10.3 日志查看**

```bash
# 实时日志
ceph -w

# RGW访问日志
tail -f /var/log/ceph/ceph-client.rgw.*.log

# 集群日志
ceph log last 100

# 调试模式（临时）
ceph config set client.rgw.object-store.node1 debug_rgw 20/20
ceph config set client.rgw.object-store.node1 debug_ms 1/5
```

## **11. 安全配置**

### **11.1 启用SSL/TLS**

```bash
# 生成自签名证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ceph/rgw-key.pem \
  -out /etc/ceph/rgw-cert.pem \
  -subj "/CN=rgw.example.com"

# 更新RGW配置
ceph config set client.rgw.object-store.node1 rgw_frontends \
  "beast ssl_port=8443 ssl_certificate=/etc/ceph/rgw-cert.pem ssl_private_key=/etc/ceph/rgw-key.pem"

# 重启RGW
ceph orch daemon restart rgw.object-store.node1
```

### **11.2 配置访问控制**

```bash
# 创建只读用户
radosgw-admin user create --uid=readonly-user --display-name="Readonly User"
radosgw-admin caps add --uid=readonly-user --caps="buckets=read"

# 创建存储桶策略
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::mybucket/*"]
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": ["s3:PutObject", "s3:DeleteObject"],
      "Resource": ["arn:aws:s3:::mybucket/*"]
    }
  ]
}
EOF

aws --endpoint-url=http://node1:8080 s3api put-bucket-policy \
  --bucket mybucket \
  --policy file://bucket-policy.json
```

这样您就完成了一个完整的企业级Ceph对象存储集群的搭建。这个配置专注于对象存储，适合云原生应用、大数据分析、备份归档、内容分发等场景。

搭建一个专门用于块存储（RBD）的Ceph分布式集群，特别适合虚拟化、容器和数据库场景。

## **1. 环境规划与准备**

### **1.1 架构设计**

```bash
节点1 (node1): Monitor + Manager + OSD + iSCSI Gateway (可选)
节点2 (node2): Monitor + OSD + iSCSI Gateway (可选)
节点3 (node3): Monitor + OSD
节点4 (node4): OSD  # 纯存储节点

客户端节点: KVM/Hyper-V主机、容器节点、数据库服务器
```

### **1.2 系统准备**

```bash
# 所有节点执行
# 1. 设置主机名和网络
cat > /etc/hosts << EOF
192.168.1.10 node1 ceph-mon1
192.168.1.11 node2 ceph-mon2
192.168.1.12 node3 ceph-mon3
192.168.1.13 node4 ceph-osd4
192.168.1.50 client1
192.168.1.51 client2
EOF

# 2. 配置ntp时间同步
yum install -y chrony
systemctl enable --now chronyd
timedatectl set-ntp true
chronyc sources -v

# 3. 禁用防火墙和SELinux（生产环境请配置规则）
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 4. 优化内核参数
cat >> /etc/sysctl.conf << EOF
# Ceph性能优化
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 40
vm.dirty_background_ratio = 10
vm.dirty_expire_centisecs = 3000
net.core.rmem_max = 56623104
net.core.wmem_max = 56623104
net.ipv4.tcp_rmem = 4096 87380 56623104
net.ipv4.tcp_wmem = 4096 87380 56623104
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_slow_start_after_idle = 0
EOF
sysctl -p

# 5. 调整文件句柄限制
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc 65536" >> /etc/security/limits.conf
echo "* hard nproc 65536" >> /etc/security/limits.conf
ulimit -n 65536
```

## **2. Ceph集群部署（cephadm方式）**

### **2.1 安装cephadm**

```bash
# 所有节点安装cephadm
# 方法1：使用curl（推荐）
curl --silent --remote-name --location \
  https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
mv cephadm /usr/local/bin/

# 方法2：从包管理器安装
# CentOS 8 Stream / RHEL 8
dnf install -y cephadm

# Ubuntu 20.04/22.04
apt-get install -y cephadm
```

### **2.2 引导集群（在node1执行）**

```bash
# 1. 引导集群
cephadm bootstrap \
  --mon-ip 192.168.1.10 \
  --initial-dashboard-user admin \
  --initial-dashboard-password CephAdmin123! \
  --allow-fqdn-hostname \
  --cluster-network 192.168.1.0/24 \
  --skip-pull \
  --skip-dashboard \
  --skip-monitoring-stack

# 2. 启用Dashboard（可选）
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
ceph config set mgr mgr/dashboard/server_addr 0.0.0.0
ceph config set mgr mgr/dashboard/server_port 8443
ceph dashboard set-login-credentials admin CephAdmin123!

# 3. 安装命令行工具
cephadm install ceph-common ceph-base

# 4. 验证集群状态
ceph status
ceph version
ceph orch status
```

### **2.3 添加集群节点**

```bash
# 1. 复制SSH密钥到其他节点
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node2
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node3
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node4

# 2. 添加主机到集群
ceph orch host add node2 192.168.1.11
ceph orch host add node3 192.168.1.12
ceph orch host add node4 192.168.1.13

# 3. 设置标签（可选）
ceph orch host label add node1 mon mgr osd
ceph orch host label add node2 mon osd
ceph orch host label add node3 mon osd
ceph orch host label add node4 osd

# 4. 查看主机列表
ceph orch host ls
```

## **3. 部署OSD存储设备**

### **3.1 准备磁盘**

```bash
# 在所有存储节点执行
# 1. 查看磁盘信息
lsblk -f
fdisk -l

# 2. 清空磁盘（如果磁盘有数据）
wipefs -a /dev/sdb
wipefs -a /dev/sdc

# 3. 创建GPT分区表（可选）
parted /dev/sdb mklabel gpt
parted /dev/sdc mklabel gpt
```

### **3.2 部署OSD**

```bash
# 方法1：自动部署所有可用磁盘
ceph orch apply osd --all-available-devices

# 方法2：使用规格文件（推荐）
cat > osd_spec.yaml << EOF
service_type: osd
service_id: rbd-osds
placement:
  hosts:
    - node1
    - node2
    - node3
    - node4
spec:
  # 数据磁盘配置
  data_devices:
    paths:
      - /dev/sdb
      - /dev/sdc
    rotational: 1  # 1为HDD，0为SSD
    size_limit: 0  # 0表示使用整个磁盘
  
  # WAL/DB设备配置（如果有SSD）
  db_devices:
    paths:
      - /dev/nvme0n1
    size_limit: "100G"  # WAL/DB大小
  
  # OSD配置
  osds_per_device: 1
  encrypted: false
  filter_logic: AND
  mode: lvm
EOF

ceph orch apply -i osd_spec.yaml

# 查看部署进度
ceph orch device ls
ceph osd tree
```

### **3.3 验证OSD状态**

```bash
# 检查OSD状态
ceph osd stat
ceph osd tree
ceph osd df

# 查看OSD详细信息
ceph osd dump | head -50

# 检查PG状态
ceph pg stat
ceph pg dump | grep -v "^pg" | head -20
```

## **4. 配置块存储（RBD）**

### **4.1 创建块存储池**

```bash
# 1. 创建专用存储池
# 计算PG数量（参考公式：Total PGs = (OSD数量 × 100) / 副本数）
# 假设：8个OSD，副本数3 => (8×100)/3 ≈ 267，取256

# 创建SSD池（用于高性能）
ceph osd pool create rbd-ssd 256 256
ceph osd pool application enable rbd-ssd rbd

# 创建HDD池（用于大容量）
ceph osd pool create rbd-hdd 256 256
ceph osd pool application enable rbd-hdd rbd

# 创建缓存层池（如果有SSD）
ceph osd pool create rbd-cache 128 128
ceph osd pool application enable rbd-cache rbd

# 2. 配置池参数
for pool in rbd-ssd rbd-hdd rbd-cache; do
  ceph osd pool set $pool size 3        # 副本数
  ceph osd pool set $pool min_size 2    # 最小可用副本
  ceph osd pool set $pool pg_num 256    # PG数量
  ceph osd pool set $pool pgp_num 256   # PGP数量
done

# 3. 配置缓存层（可选）
# 创建缓存层
ceph osd tier add rbd-hdd rbd-cache
ceph osd tier cache-mode rbd-cache writeback
ceph osd tier set-overlay rbd-hdd rbd-cache

# 设置缓存参数
ceph osd pool set rbd-cache hit_set_type bloom
ceph osd pool set rbd-cache hit_set_count 1
ceph osd pool set rbd-cache hit_set_period 3600
ceph osd pool set rbd-cache target_max_bytes 100000000000  # 100GB缓存
```

### **4.2 初始化RBD**

```bash
# 1. 初始化存储池
rbd pool init rbd-ssd
rbd pool init rbd-hdd

# 2. 创建RBD镜像
# 创建不同大小的镜像
rbd create vm-disk1 --size 100G --pool rbd-ssd --image-feature layering
rbd create db-data --size 500G --pool rbd-hdd --image-feature layering,exclusive-lock,object-map,fast-diff,deep-flatten

# 3. 查看镜像信息
rbd ls --pool rbd-ssd
rbd info vm-disk1 --pool rbd-ssd

# 4. 调整镜像大小
rbd resize --size 200G vm-disk1 --pool rbd-ssd

# 5. 创建快照
rbd snap create vm-disk1@snapshot1 --pool rbd-ssd
rbd snap ls vm-disk1 --pool rbd-ssd
```

## **5. 客户端配置**

### **5.1 客户端安装**

```bash
# 在客户端节点执行
# 1. 安装Ceph客户端
# CentOS/RHEL
yum install -y ceph-common rbd-nbd qemu-img

# Ubuntu/Debian
apt-get install -y ceph-common rbd-nbd qemu-utils

# 2. 获取配置文件
# 从Ceph集群节点复制
scp root@node1:/etc/ceph/ceph.conf /etc/ceph/
scp root@node1:/etc/ceph/ceph.client.admin.keyring /etc/ceph/

# 3. 创建专用客户端密钥
# 在Ceph集群节点执行
ceph auth get-or-create client.kvm \
  mon 'allow r' \
  osd 'allow rwx pool=rbd-ssd, allow rwx pool=rbd-hdd' \
  -o /etc/ceph/ceph.client.kvm.keyring

# 复制到客户端
scp /etc/ceph/ceph.client.kvm.keyring client1:/etc/ceph/
```

### **5.2 Linux客户端使用**

```bash
# 1. 映射RBD设备
# 方法A：使用内核模块
rbd map vm-disk1 --pool rbd-ssd --id kvm --keyring /etc/ceph/ceph.client.kvm.keyring

# 方法B：使用NBD（Network Block Device）
rbd-nbd map vm-disk1 --pool rbd-ssd --id kvm

# 2. 查看映射的设备
rbd device list
lsblk | grep rbd

# 3. 格式化并使用
mkfs.xfs /dev/rbd0
mkdir -p /mnt/rbd
mount /dev/rbd0 /mnt/rbd

# 4. 自动挂载
echo "rbd map vm-disk1 --pool rbd-ssd --id kvm" >> /etc/rc.local
chmod +x /etc/rc.local
```

### **5.3 KVM/QEMU集成**

```bash
# 1. 创建QCOW2格式镜像
qemu-img convert -f raw -O qcow2 rbd:rbd-ssd/vm-disk1:id=kvm:keyring=/etc/ceph/ceph.client.kvm.keyring vm-disk1.qcow2

# 2. 创建虚拟机使用RBD
virt-install \
  --name vm1 \
  --ram 4096 \
  --vcpus 4 \
  --disk path=rbd:rbd-ssd/vm-disk1:id=kvm:keyring=/etc/ceph/ceph.client.kvm.keyring,format=raw,bus=virtio \
  --os-type linux \
  --os-variant centos8 \
  --network bridge=br0 \
  --graphics vnc \
  --console pty \
  --cdrom /path/to/centos.iso

# 3. 编辑虚拟机XML配置
cat > /etc/libvirt/qemu/vm1-rbd.xml << EOF
<disk type='network' device='disk'>
  <driver name='qemu' type='raw' cache='writeback'/>
  <source protocol='rbd' name='rbd-ssd/vm-disk1'>
    <host name='node1' port='6789'/>
    <host name='node2' port='6789'/>
    <host name='node3' port='6789'/>
  </source>
  <auth username='kvm'>
    <secret type='ceph' uuid='YOUR-SECRET-UUID'/>
  </auth>
  <target dev='vda' bus='virtio'/>
</disk>
EOF

# 4. 创建Ceph secret
cat > secret.xml << EOF
<secret ephemeral='no' private='no'>
  <usage type='ceph'>
    <name>client.kvm secret</name>
  </usage>
</secret>
EOF

virsh secret-define --file secret.xml
virsh secret-set-value --secret {uuid} --base64 $(ceph auth get-key client.kvm)
```

### **5.4 Docker容器集成**

```bash
# 1. 安装rbd-docker-plugin
docker plugin install \
  --alias rbd \
  rexray/rbd \
  RBD_USERID=kvm \
  RBD_POOL=rbd-ssd \
  RBD_CONFFILE=/etc/ceph/ceph.conf

# 2. 创建Docker卷
docker volume create --driver rbd \
  --opt size=10 \
  --opt pool=rbd-ssd \
  --opt name=container-data \
  rbd-volume

# 3. 使用卷启动容器
docker run -d \
  --name mysql \
  --mount source=rbd-volume,target=/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0

# 4. Kubernetes使用Ceph RBD
# 创建StorageClass
cat > ceph-sc.yaml << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ceph-rbd
provisioner: kubernetes.io/rbd
parameters:
  monitors: node1:6789,node2:6789,node3:6789
  pool: rbd-ssd
  imageFormat: "2"
  imageFeatures: layering
  csi.storage.k8s.io/provisioner-secret-name: ceph-secret
  csi.storage.k8s.io/provisioner-secret-namespace: default
  csi.storage.k8s.io/controller-expand-secret-name: ceph-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: default
  csi.storage.k8s.io/node-stage-secret-name: ceph-secret
  csi.storage.k8s.io/node-stage-secret-namespace: default
reclaimPolicy: Retain
allowVolumeExpansion: true
EOF

kubectl apply -f ceph-sc.yaml
```

## **6. 部署iSCSI网关（可选）**

### **6.1 安装iSCSI网关**

```bash
# 在node1和node2上执行
# 1. 安装软件包
yum install -y ceph-iscsi tcmu-runner targetcli

# 2. 部署iSCSI网关服务
cat > iscsi_spec.yaml << EOF
service_type: iscsi
service_id: iscsi-gateway
placement:
  hosts:
    - node1
    - node2
spec:
  pool: rbd-ssd
  trusted_ip_list: "192.168.1.0/24"
  api_user: admin
  api_password: iscsiadmin123
  api_secure: false
  api_port: 5000
EOF

ceph orch apply -i iscsi_spec.yaml

# 3. 验证部署
ceph orch ps --daemon-type iscsi
systemctl status ceph-iscsi
```

### **6.2 配置iSCSI目标**

```bash
# 1. 进入iSCSI配置界面
gwcli

# 2. 创建iSCSI网关
/> cd /iscsi-targets
/iscsi-targets> create iqn.2023-01.com.ceph:iscsi-gw

# 3. 创建iSCSI磁盘
/> cd /disks
/disks> create pool=rbd-ssd image=iscsi-disk1 size=100G

# 4. 创建客户端
/> cd /iscsi-targets/iqn.2023-01.com.ceph:iscsi-gw
...> cd clients
.../clients> create client1

# 5. 查看配置
/> ls
/> cd /disks
/disks> ls
```

### **6.3 Windows客户端连接**

```bash
# 1. 安装iSCSI发起程序
# 控制面板 -> 程序和功能 -> 启用或关闭Windows功能
# 勾选 "iSCSI发起程序服务"

# 2. 连接iSCSI目标
# 打开iSCSI发起程序
# 发现 -> 发现门户 -> 添加: node1, node2
# 目标 -> 选择目标 -> 连接
# 快速连接 -> 确定

# 3. 初始化磁盘
# 磁盘管理 -> 找到新磁盘 -> 初始化为GPT
# 新建简单卷 -> 格式化
```

## **7. 性能优化**

### **7.1 RBD性能调优**

```bash
# 1. 配置RBD缓存
ceph config set global rbd_cache true
ceph config set global rbd_cache_size 67108864  # 64MB
ceph config set global rbd_cache_max_dirty 50331648  # 48MB
ceph config set global rbd_cache_target_dirty 33554432  # 32MB
ceph config set global rbd_cache_max_dirty_age 5  # 5秒

# 2. 调整客户端参数
# 在客户端/etc/ceph/ceph.conf添加
cat >> /etc/ceph/ceph.conf << EOF
[client]
    rbd cache = true
    rbd cache size = 67108864
    rbd cache max dirty = 50331648
    rbd cache target dirty = 33554432
    rbd cache max dirty age = 5
    rbd cache writethrough until flush = true
    admin socket = /var/run/ceph/gu-\$pid.asok
    log file = /var/log/ceph/ceph-client.\$pid.log
EOF

# 3. 设置RBD镜像特性
# 创建时设置
rbd create perf-disk --size 100G --pool rbd-ssd \
  --image-feature layering,exclusive-lock,object-map,fast-diff,deep-flatten,journaling

# 修改现有镜像
rbd feature enable perf-disk exclusive-lock object-map fast-diff deep-flatten --pool rbd-ssd
```

### **7.2 OSD性能优化**

```bash
# 1. 调整OSD参数
# 对于SSD OSD
ceph config set osd bluestore_cache_size 8589934592  # 8GB
ceph config set osd bluestore_cache_autotune true
ceph config set osd bluestore_prefer_deferred_size 0

# 对于HDD OSD
ceph config set osd osd_op_num_threads_per_shard 4
ceph config set osd osd_op_num_shards 8
ceph config set osd osd_recovery_max_active 10
ceph config set osd osd_recovery_max_single_start 5
ceph config set osd osd_max_backfills 4

# 2. 调整网络参数
ceph config set global ms_tcp_read_timeout 300
ceph config set global ms_tcp_keepalive_time 300
ceph config set global ms_dispatch_throttle_bytes 104857600  # 100MB

# 3. 启用压缩（如果CPU充足）
ceph osd pool set rbd-hdd compression_algorithm snappy
ceph osd pool set rbd-hdd compression_mode aggressive

# 4. 定期碎片整理
ceph config set osd osd_fast_info_enabled true
ceph osd defrag all
```

### **7.3 监控优化参数**

```bash
# 创建性能监控脚本
cat > /usr/local/bin/ceph_perf_check.sh << 'EOF'
#!/bin/bash
echo "====== Ceph性能状态 ======"
echo "1. 集群状态:"
ceph -s

echo -e "\n2. OSD性能:"
ceph osd perf

echo -e "\n3. OSD使用率:"
ceph osd df

echo -e "\n4. PG状态:"
ceph pg stat

echo -e "\n5. 监控延迟:"
ceph time-sync-status

echo -e "\n6. RBD缓存统计:"
for pid in $(pgrep -f "rbd map"); do
    echo "进程 $pid:"
    ceph daemon client.rbd.$pid perf dump | jq '.rbd'
done

echo -e "\n7. 网络延迟:"
for node in node1 node2 node3 node4; do
    ping -c 2 $node | tail -1
done
EOF

chmod +x /usr/local/bin/ceph_perf_check.sh
```

## **8. 高可用和故障转移**

### **8.1 配置多路径**

```bash
# 1. 安装多路径工具
yum install -y device-mapper-multipath

# 2. 配置多路径
cat > /etc/multipath.conf << EOF
defaults {
    user_friendly_names yes
    find_multipaths yes
    polling_interval 10
}
blacklist {
    devnode "^sd[a-b]"
}
devices {
    device {
        vendor "CEPH"
        product "RBD"
        path_grouping_policy multibus
        path_checker tur
        features "1 queue_if_no_path"
        hardware_handler "1 alua"
        failback immediate
        rr_weight uniform
        no_path_retry 5
        rr_min_io 1000
    }
}
EOF

systemctl enable --now multipathd

# 3. 使用多路径映射RBD
rbd map disk1 --pool rbd-ssd --options="multi-path"

# 4. 查看多路径设备
multipath -ll
ls -l /dev/mapper/
```

### **8.2 配置存储策略**

```bash
# 1. 创建CRUSH规则
# SSD规则
ceph osd crush rule create-replicated ssd-rule default host ssd

# HDD规则
ceph osd crush rule create-replicated hdd-rule default host hdd

# 2. 应用规则到存储池
ceph osd pool set rbd-ssd crush_rule ssd-rule
ceph osd pool set rbd-hdd crush_rule hdd-rule

# 3. 配置故障域
# 修改默认CRUSH规则
ceph osd getcrushmap -o crushmap.bin
crushtool -d crushmap.bin -o crushmap.txt
# 编辑crushmap.txt，将step chooseleaf type 0改为step chooseleaf type host
crushtool -c crushmap.txt -o newcrushmap.bin
ceph osd setcrushmap -i newcrushmap.bin
```

### **8.3 备份和恢复策略**

```bash
# 1. 定期备份RBD镜像
cat > /usr/local/bin/rbd_backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/rbd/$DATE"
mkdir -p $BACKUP_DIR

# 备份所有RBD镜像信息
for pool in $(ceph osd pool ls | grep rbd); do
    for image in $(rbd ls $pool); do
        echo "备份 $pool/$image..."
        # 导出镜像
        rbd export $pool/$image $BACKUP_DIR/${pool}_${image}.img
        # 导出快照
        rbd snap ls $pool/$image | tail -n +2 | while read snap; do
            snap_name=$(echo $snap | awk '{print $2}')
            rbd export $pool/$image@$snap_name $BACKUP_DIR/${pool}_${image}_${snap_name}.img
        done
    done
done

# 保留最近7天备份
find /backup/rbd -type d -mtime +7 -exec rm -rf {} \;
echo "备份完成: $BACKUP_DIR"
EOF

chmod +x /usr/local/bin/rbd_backup.sh

# 2. 配置定时备份
echo "0 2 * * * /usr/local/bin/rbd_backup.sh" >> /etc/crontab

# 3. 恢复镜像
rbd import backup.img rbd-ssd/restored-disk
```

## **9. 监控和告警**

### **9.1 启用Dashboard**

```bash
# 1. 安装Dashboard插件
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
ceph config set mgr mgr/dashboard/server_addr 0.0.0.0
ceph config set mgr mgr/dashboard/server_port 8443
ceph config set mgr mgr/dashboard/ssl true

# 2. 配置块存储面板
ceph dashboard set-rbd-mirroring-pool-monitoring-pools rbd-ssd,rbd-hdd

# 3. 访问Dashboard
# https://node1:8443
```

### **9.2 配置Prometheus监控**

```bash
# 1. 启用Prometheus模块
ceph mgr module enable prometheus

# 2. 部署Prometheus和Grafana
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

cat > grafana.yaml << EOF
service_type: grafana
service_id: grafana
placement:
  hosts:
    - node1
spec:
  initial_admin_password: GrafanaAdmin123!
EOF

ceph orch apply -i prometheus.yaml
ceph orch apply -i grafana.yaml

# 3. 导入Grafana仪表板
# 访问: http://node1:3000
# 导入Ceph官方仪表板: 2842, 5346, 5347
```

### **9.3 设置告警规则**

```bash
# 1. 配置健康告警
cat > /etc/ceph/ceph.conf << EOF
[global]
...
mon health preluminous osd warning = 3
mon health preluminous osd error = 1
mon health preluminous pg warning = 10
mon health preluminous pg error = 3
mon health preluminous pool full warning = 0.85
mon health preluminous pool full error = 0.95
EOF

# 2. 配置邮件告警
ceph dashboard set-alertmanager-api-host http://alertmanager:9093
ceph dashboard set-alertmanager-api-username admin
ceph dashboard set-alertmanager-api-password Alert123!

# 3. 创建自定义告警规则
cat > /etc/prometheus/rules/ceph_alerts.yml << EOF
groups:
  - name: ceph_alerts
    rules:
    - alert: CephOSDDown
      expr: ceph_osd_up == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "OSD {{ $labels.osd }} is down"
        
    - alert: CephPoolLowSpace
      expr: ceph_pool_used_bytes / ceph_pool_max_avail_bytes > 0.85
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Pool {{ $labels.pool }} is low on space"
        
    - alert: CephHighLatency
      expr: rate(ceph_osd_op_latency_sum[5m]) / rate(ceph_osd_op_latency_count[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High latency detected on OSD {{ $labels.osd }}"
EOF
```

## **10. 故障排除**

### **10.1 常见问题解决**

```bash
# 1. RBD映射失败
# 检查权限
ceph auth get client.kvm

# 检查网络连接
ping node1
telnet node1 6789

# 检查内核模块
modprobe rbd
lsmod | grep rbd

# 2. 性能问题
# 检查IO延迟
iostat -x 1

# 检查网络延迟
ping -c 10 node1

# 调整队列深度
echo 1024 > /sys/block/rbd0/queue/nr_requests

# 3. OSD故障
# 重新启动OSD
ceph orch daemon restart osd.0

# 标记OSD out/in
ceph osd out osd.0
ceph osd in osd.0

# 重新平衡数据
ceph osd reweight osd.0 1.0

# 4. 存储池满
# 添加更多OSD
ceph orch daemon add osd node4:/dev/sdd

# 清理过期数据
rbd trash purge rbd-ssd
```

### **10.2 调试工具**

```bash
# 1. 启用调试日志
ceph config set client debug_rbd 20/20
ceph config set osd debug_bluestore 20/20

# 2. 收集诊断信息
ceph report
ceph crash archive-all
ceph health detail

# 3. 性能分析
# 使用blktrace分析IO
blktrace -d /dev/rbd0 -o trace
blkparse trace.blktrace.* > trace.txt

# 使用fio测试性能
fio --name=test --ioengine=libaio --rw=randrw --bs=4k --numjobs=16 \
  --size=1G --runtime=300 --group_reporting --filename=/dev/rbd0
```

### **10.3 日志管理**

```bash
# 1. 配置日志级别
ceph config set global debug_ms 1/5
ceph config set mon debug_mon 1/5
ceph config set osd debug_osd 1/5

# 2. 查看日志
# 实时查看
ceph -w
tail -f /var/log/ceph/ceph.log

# 查看特定组件
journalctl -u ceph-mon@node1
journalctl -u ceph-osd@0

# 3. 日志轮转
cat > /etc/logrotate.d/ceph << EOF
/var/log/ceph/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 644 ceph ceph
    postrotate
        killall -HUP ceph-mon ceph-osd ceph-mgr 2>/dev/null || true
    endscript
}
EOF
```

## **11. 安全加固**

### **11.1 配置认证和授权**

```bash
# 1. 创建最小权限用户
# 只读用户
ceph auth get-or-create client.readonly \
  mon 'allow r' \
  osd 'allow r' \
  -o /etc/ceph/ceph.client.readonly.keyring

# RBD专用用户
ceph auth get-or-create client.rbduser \
  mon 'allow r' \
  osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd-ssd' \
  -o /etc/ceph/ceph.client.rbduser.keyring

# 2. 配置密钥轮转
ceph auth caps client.rbduser \
  mon 'allow r' \
  osd 'allow rwx pool=rbd-ssd'

# 3. 启用CephX认证（默认已启用）
ceph config set global auth_cluster_required cephx
ceph config set global auth_service_required cephx
ceph config set global auth_client_required cephx
```

### **11.2 网络安全**

```bash
# 1. 配置防火墙规则
firewall-cmd --permanent --zone=public --add-service=ceph
firewall-cmd --permanent --zone=public --add-port=6789/tcp  # mon
firewall-cmd --permanent --zone=public --add-port=3300/tcp  # mgr
firewall-cmd --permanent --zone=public --add-port=6800-7300/tcp  # osd
firewall-cmd --reload

# 2. 配置网络隔离
# 集群网络
ceph config set global cluster_network 192.168.2.0/24
# 公共网络
ceph config set global public_network 192.168.1.0/24

# 3. 启用SSL/TLS
ceph config set mon mon_client_bytes_per_sec 104857600
ceph config set mon mon_cluster_bytes_per_sec 104857600
```

这样您就完成了一个完整的、高性能的Ceph块存储集群搭建。这个配置专注于块存储，适合虚拟化、数据库、容器等需要高性能、低延迟块设备的场景。
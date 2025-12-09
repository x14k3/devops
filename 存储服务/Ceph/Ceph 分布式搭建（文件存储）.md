
步骤：
1. 准备工作：配置主机名、hosts文件、ssh无密码登录、时间同步、防火墙和SELinux设置。
2. 安装Ceph部署工具（cephadm或传统方法）。这里使用cephadm（Ceph 15及以上版本）进行部署。
3. 引导集群，并添加OSD。
4. 创建CephFS所需的存储池（数据池和元数据池）。
5. 创建CephFS文件系统。
6. 部署MDS服务。


### **1. 环境准备**

#### **1.1 节点规划**

假设有3个节点，配置如下：

```bash
节点1 (node1): 监控节点 + MDS + OSD + 管理节点
节点2 (node2): 监控节点 + MDS + OSD
节点3 (node3): 监控节点 + OSD
```

#### **1.2 系统要求**

```bash
# 所有节点执行
# 1. 设置主机名
hostnamectl set-hostname node1  # 在对应节点执行

# 2. 配置hosts文件（所有节点相同）
cat >> /etc/hosts << EOF
192.168.1.10 node1
192.168.1.11 node2
192.168.1.12 node3
EOF

# 3. 关闭防火墙和SELinux
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 4. 配置时间同步
yum install -y chrony
systemctl enable chronyd
systemctl start chronyd
chronyc sources

# 5. 创建Ceph用户（如果需要）
useradd -d /home/ceph -m ceph
echo "ceph:ceph123" | chpasswd
echo "ceph ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/ceph
chmod 0440 /etc/sudoers.d/ceph
```

### **2. 部署Ceph集群（cephadm方式）**

#### **2.1 安装cephadm**

```bash
# 在所有节点执行
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
./cephadm add-repo --release quincy  # 使用Quincy版本，稳定
./cephadm install

# 或者直接安装
dnf install -y cephadm  # CentOS 8/RHEL 8

```


#### **2.2 初始化集群（在node1执行）**

```bash
# 引导集群
cephadm bootstrap --mon-ip 192.168.1.10 \
  --allow-fqdn-hostname \
  --initial-dashboard-user admin \
  --initial-dashboard-password admin123 \
  --dashboard-password-noupdate \
  --skip-monitoring-stack \
  --cluster-network 192.168.2.0/24  # 集群网络（如果有）

# 验证集群状态
ceph status
ceph orch status

```


#### **2.3 添加其他节点**

```bash
# 生成SSH密钥并分发到其他节点
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node2
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node3

# 添加主机到集群
ceph orch host add node2 192.168.1.11
ceph orch host add node3 192.168.1.12

# 查看所有主机
ceph orch host ls

```

### **3. 配置OSD存储**

#### **3.1 添加存储设备**

```bash
# 查看可用磁盘
ceph orch device ls

# 自动添加所有可用磁盘作为OSD
ceph orch apply osd --all-available-devices

# 或者手动指定磁盘（推荐）
# 先查看磁盘
lsblk

# 创建OSD规格文件
cat > osd_spec.yaml << EOF
service_type: osd
service_id: osd_spec
placement:
  host_pattern: '*'
data_devices:
  paths:
    - /dev/sdb
    - /dev/sdc
  db_devices:
    paths:
      - /dev/nvme0n1  # 如果有SSD做WAL/DB
encrypted: false
EOF

ceph orch apply -i osd_spec.yaml

# 查看OSD状态
ceph osd stat
ceph osd tree
```


### **4. 部署CephFS文件存储**

#### **4.1 创建CephFS存储池**

```bash
# 创建数据池（建议PG数根据OSD数量计算）
# 计算PG数量：每个OSD建议50-100个PG
# 公式：总PG数 = (OSD数量 × 100) / 副本数
# 这里假设3个OSD，副本数3： (3×100)/3 = 100

# 创建数据池
ceph osd pool create cephfs_data 128  # 128个PG
ceph osd pool create cephfs_metadata 64  # 元数据池，64个PG

# 设置池参数
ceph osd pool set cephfs_data size 3  # 设置副本数为3
ceph osd pool set cephfs_metadata size 3
ceph osd pool set cephfs_data min_size 2  # 最小可用副本数
ceph osd pool set cephfs_metadata min_size 2

# 启用应用标签
ceph osd pool application enable cephfs_data cephfs
ceph osd pool application enable cephfs_metadata cephfs

```

#### **4.2 创建CephFS文件系统**

```bash
# 创建文件系统
ceph fs new cephfs cephfs_metadata cephfs_data

# 查看文件系统状态
ceph fs status
ceph fs ls

# 查看MDS状态
ceph mds stat
```


#### **4.3 部署MDS服务（元数据服务器）**

```bash
# 创建MDS部署规格文件
cat > mds_spec.yaml << EOF
service_type: mds
service_id: cephfs
placement:
  hosts:
    - node1
    - node2
  count: 2  # 部署2个MDS实例（一主一备）
spec:
  mds_cache_memory_limit: 4294967296  # 4GB缓存
  mds_cache_reservation: 0.25  # 25%内存保留
  mds_standby_for_fscid: cephfs
  mds_standby_replay: true  # 备用MDS实时同步
EOF

ceph orch apply -i mds_spec.yaml

# 查看MDS部署状态
ceph orch ps --daemon-type mds

```


### **5. 客户端挂载CephFS**

#### **5.1 安装客户端软件**

```bash
# 在客户端机器上执行
# CentOS/RHEL
yum install -y ceph-fuse ceph-common

# Ubuntu/Debian
apt-get install -y ceph-fuse ceph-common

```


#### **5.2 获取配置文件**

从集群节点（如node1）复制配置文件和密钥：

```bash
# 在node1上
scp /etc/ceph/ceph.conf client-node:/etc/ceph/
scp /etc/ceph/ceph.client.admin.keyring client-node:/etc/ceph/

```


#### **5.3 挂载CephFS**

```bash
# 方法1：使用内核驱动（推荐，性能更好）
# 安装内核模块
modprobe ceph

# 创建挂载点
mkdir -p /mnt/cephfs

# 挂载
mount -t ceph node1:6789,node2:6789,node3:6789:/ /mnt/cephfs \
  -o name=admin,secretfile=/etc/ceph/admin.secret

# 或使用monitor列表
mount -t ceph 192.168.1.10:6789,192.168.1.11:6789,192.168.1.12:6789:/ /mnt/cephfs \
  -o name=admin,secretfile=/etc/ceph/admin.secret

# 方法2：使用FUSE（更灵活）
mkdir -p /mnt/cephfs_fuse
ceph-fuse -m node1:6789,node2:6789,node3:6789 /mnt/cephfs_fuse

# 查看挂载
df -hT | grep ceph
mount | grep ceph

```


#### **5.4 配置自动挂载**

```bash
# 编辑fstab
cat >> /etc/fstab << EOF
# CephFS挂载
192.168.1.10:6789,192.168.1.11:6789,192.168.1.12:6789:/ /mnt/cephfs ceph name=admin,secretfile=/etc/ceph/admin.secret,_netdev,noatime 0 0
EOF

# 或者使用ceph-fuse自动挂载
echo "ceph-fuse#/mnt/cephfs_fuse /mnt/cephfs_fuse fuse.ceph _netdev,noatime 0 0" >> /etc/fstab

```


### **6. 高级配置和优化**

#### **6.1 CephFS参数优化**

```bash

# 设置文件系统参数
ceph fs set cephfs max_file_size 1099511627776  # 最大文件1TB
ceph fs set cephfs allow_new_snaps true  # 允许快照
ceph fs set cephfs standby_count_wanted 2  # 期望的备用MDS数量

# 设置MDS参数
ceph tell mds.* injectargs '--mds_cache_memory_limit 4294967296'
ceph tell mds.* injectargs '--mds_log_max_segments 128'

# 查看当前配置
ceph fs get cephfs
```


#### **6.2 配置CephFS配额**

```bash
# 设置目录配额
# 创建测试目录
mkdir /mnt/cephfs/projects

# 设置最大文件数
ceph fs quota set /mnt/cephfs/projects --max_files 10000

# 设置最大字节数（10GB）
ceph fs quota set /mnt/cephfs/projects --max_bytes 10737418240

# 查看配额
ceph fs quota get /mnt/cephfs/projects

# 启用/禁用配额
ceph fs quota enable /mnt/cephfs/projects
ceph fs quota disable /mnt/cephfs/projects

```


#### **6.3 配置快照功能**

```bash
# 启用快照支持
ceph fs set cephfs allow_new_snaps true

# 创建目录快照
mkdir /mnt/cephfs/data
mkdir /mnt/cephfs/data/.snap/daily_backup

# 或使用命令创建
ceph fs subvolume snapshot create cephfs data_volume snap1

# 列出快照
ls /mnt/cephfs/data/.snap/
ceph fs subvolume snapshot ls cephfs data_volume

# 恢复快照
cp -a /mnt/cephfs/data/.snap/daily_backup/* /mnt/cephfs/data/
```


### **7. 监控和维护**

#### **7.1 监控仪表板**

```bash
# 启用Ceph Dashboard（如果未启用）
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
ceph dashboard set-login-credentials admin admin123

# 访问Dashboard
# https://node1:8443
```


#### **7.2 健康检查脚本**

```bash
#!/bin/bash
# ceph_health_check.sh

echo "=== Ceph集群状态 ==="
ceph -s

echo -e "\n=== OSD状态 ==="
ceph osd stat
ceph osd tree

echo -e "\n=== MDS状态 ==="
ceph mds stat

echo -e "\n=== CephFS状态 ==="
ceph fs status

echo -e "\n=== 存储池状态 ==="
ceph osd pool ls detail

echo -e "\n=== 使用情况 ==="
ceph df

echo -e "\n=== 性能指标 ==="
ceph perf

# 检查是否有PG不正常
echo -e "\n=== PG状态 ==="
ceph pg stat
```


#### **7.3 常用维护命令**

```bash
# 查看文件系统使用情况
ceph fs status
ceph df detail

# 查看客户端会话
ceph session ls

# 查看目录统计
ceph fs du /mnt/cephfs

# 平衡MDS负载
ceph mds compat rm_invalid_affected
```


### **8. 故障排除**

#### **8.1 常见问题解决**

```bash
# 1. MDS服务异常
ceph orch daemon restart mds.node1

# 2. 客户端无法连接
# 检查网络
ping node1
telnet node1 6789

# 检查防火墙
firewall-cmd --list-all

# 3. 存储空间不足
# 添加更多OSD或扩展现有OSD

# 4. 性能问题
# 检查网络延迟
ping -c 10 node1

# 查看IO统计
iostat -x 1

# 调整参数
ceph tell osd.* injectargs '--osd_op_num_threads_per_shard 4'

```

#### **8.2 日志查看**

```bash

# Ceph集群日志
ceph log last 100

# MDS特定日志
ceph tell mds.* help  # 查看可用命令
journalctl -u ceph-mds@node1

# 客户端日志
dmesg | grep ceph
/var/log/messages

```

### **9. 扩展配置**

#### **9.1 多文件系统支持**

```bash
# 创建第二个文件系统
ceph osd pool create cephfs2_data 128
ceph osd pool create cephfs2_metadata 64
ceph fs new cephfs2 cephfs2_metadata cephfs2_data

# 部署额外的MDS服务
cat > mds2_spec.yaml << EOF
service_type: mds
service_id: cephfs2
placement:
  hosts:
    - node1
    - node3
spec:
  mds_cache_memory_limit: 2147483648  # 2GB
EOF
ceph orch apply -i mds2_spec.yaml

```


#### **9.2 配置NFS网关**

```bash
# 部署NFS网关
ceph orch apply nfs cephfs-nfs --placement="2 node1 node2" \
  --spec '{
    "pool": "cephfs_data",
    "namespace": "cephfs-nfs"
  }'

# 查看NFS服务
ceph nfs cluster ls
```


### **10. 安全配置**

#### **10.1 创建专用客户端用户**

```bash
# 创建只读用户
ceph auth get-or-create client.readonly mon 'allow r' \
  osd 'allow r pool=cephfs_data, allow r pool=cephfs_metadata' \
  mds 'allow r' \
  -o /etc/ceph/ceph.client.readonly.keyring

# 创建读写用户
ceph auth get-or-create client.user1 mon 'allow r' \
  osd 'allow rw pool=cephfs_data, allow rw pool=cephfs_metadata' \
  mds 'allow rw' \
  -o /etc/ceph/ceph.client.user1.keyring
```

这样您就完成了一个完整的CephFS文件存储集群的搭建。这个配置专注于文件存储，适合需要共享文件系统的场景，如虚拟化环境、容器存储、备份存储等。
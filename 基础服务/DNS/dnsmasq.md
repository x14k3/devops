
为Oracle 19c RAC搭建轻量级DNS服务器（用于解析SCAN IP）,这里使用**dnsmasq**作为DNS服务器，因其轻量且配置简单：

### 环境假设

- **节点1**: `rac1` (IP: 192.168.1.101)

- **节点2**: `rac2` (IP: 192.168.1.102)

- **SCAN名称**: `rac-scan` (IP: 192.168.1.200, 192.168.1.201, 192.168.1.202)  

  *（通常需要3个IP，但测试环境可用1个）*

- **网络**: 私有网络 `192.168.1.0/24`
---



```bash
# 在两个节点上安装 dnsmasq
sudo yum install dnsmasq -y
# 修改主配置文件 /etc/dnsmasq.conf, 添加以下内容
-------------------------------------
# 监听本地和集群网络接口,替换为实际节点IP
listen-address=127.0.0.1,192.168.1.101,192.168.1.102  
# 禁止读取 /etc/hosts（避免冲突）
# no-hosts

# 添加自定义解析记录
#address=/rac-scan/192.168.1.200
#address=/rac-scan/192.168.1.201
#address=/rac-scan/192.168.1.202 

host-record=rac01.scan.com,192.168.133.221
host-record=rac01.scan.com,192.168.133.222
host-record=rac01.scan.com,192.168.133.223

# 设置上游DNS（可选）
server=8.8.8.8
-------------------------------------


# 修改每个节点的 `/etc/resolv.conf`：
-------------------------------------
nameserver 127.0.0.1    # 本机dnsmasq
search localdomain      # 可选搜索域
-------------------------------------


sudo systemctl start dnsmasq
sudo systemctl enable dnsmasq

# 测试SCAN名称解析：
nslookup rac01.scan.com

# 测试节点间解析：
nslookup rac1  # 应解析到192.168.1.101
nslookup rac2  # 应解析到192.168.1.102
```


### 重要补充：双节点高可用配置

在每个节点的 `/etc/resolv.conf` 中配置备用DNS：

```bash

sudo vi /etc/resolv.conf

```

```ini

# 节点1 (rac1) 配置：
nameserver 127.0.0.1    # 本机DNS
nameserver 192.168.1.102 # 备用节点（rac2）

# 节点2 (rac2) 配置：
nameserver 127.0.0.1    # 本机DNS
nameserver 192.168.1.101 # 备用节点（rac1）
```

这样即使一个节点的dnsmasq服务宕机，仍可通过另一节点解析名称，确保RAC的高可用性。
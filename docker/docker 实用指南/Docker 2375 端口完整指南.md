

**2375 端口是 Docker 的非加密 HTTP API 端口，直接暴露在公网非常危险！**
- ✅ **推荐**: 使用 2376 端口 (TLS 加密)
- ⚠️ **仅限**: 内网环境或有防火墙保护
- 🚫 **禁止**: 在公网直接开启 2375

开启过程中可能会出现的问题

```bash
docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
     Active: activating (auto-restart) (Result: exit-code) since Fri 2025-10-24 18:16:57 CST; 858ms ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
    Process: 15870 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (code=exited, status=1/FAILURE)
   Main PID: 15870 (code=exited, status=1/FAILURE)
        CPU: 61ms
```

以下的方法将会解决上面的问题。

## 方法一：修改 Docker Daemon 配置（推荐）
### Ubuntu/Debian 系统

#### 1. 编辑 Docker 服务配置

```bash
# 创建或编辑 daemon.json
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

#### 2. 添加配置

```bash
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2375"
  ]
}
```

**仅监听本地:**

```bash
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://127.0.0.1:2375"
  ]
}
```

**监听特定内网 IP:**

```
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://192.168.1.100:2375"
  ]
}
```

**验证语法:**

```bash
# 检测docker配置语法错误
sudo dockerd --validate

#  验证JSON格式
sudo cat /etc/docker/daemon.json | jq .  # 验证JSON格式
```

#### 3. 修改 systemd 配置（重要！）

```bash
# 编辑 systemd 服务文件
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/override.conf
```

> 用`nano`编辑器在该目录下创建名为 override.conf的配置文件。


**添加以下内容：**

```bash
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
```

**说明：**

1. 清空默认启动命令​​：ExecStart=这一行至关重要，它用于​​清除​​ Docker 服务单元文件中原始的定义。 ​​2. 设置新启动命令​​：紧接着的 ExecStart=/usr/bin/dockerd则​​重新定义​​了启动命令，但这次​​没有携带任何参数​​（特别是移除了默认的 -H fd://）。

其核心目的是为了确保您在`/etc/docker/daemon.json`配置文件中对 Docker 守护进程（Docker Daemon）所做的设置（例如配置远程访问）能够真正生效 。

**为什么要这样做？**

这么做的根本原因在于 systemd 的配置优先级以及 Docker 默认配置的冲突。


1. 解决冲突：在默认情况下，通过 systemd 管理的 Docker 服务，其服务单元文件（如 /usr/lib/systemd/system/docker.service）中已经定义了一个启动命令，通常会包含 -H fd:// 这样的参数 。这个参数本身会指定一个监听方式，并且它的优先级很高，会覆盖您在 /etc/docker/daemon.json 文件中通过 "hosts" 字段设置的监听配置 。
> `cat /lib/systemd/system/docker.service`查看原始配置

2. 使用覆盖配置：直接修改 /usr/lib/systemd/system/docker.service 这个原文件是不推荐的，因为当 Docker 升级时，这个文件可能会被新版本覆盖，导致您的修改丢失 。而在 /etc/systemd/system/docker.service.d/ 目录下创建 .conf 文件（如 override.conf）是一种标准且安全的方法。systemd 会优先读取这个目录下的配置，并将其与原始服务文件合并，从而实现自定义配置而不影响原文件 。


最终效果

当您完成上述配置并执行 sudo systemctl daemon-reload 和 sudo systemctl restart docker 后： • Docker 守护进程将不再被强制使用 -H fd:// 参数启动。

• 取而代之，它会读取并遵循您在 /etc/docker/daemon.json 文件中的 "hosts" 设置 。

• 例如，如果您在 daemon.json 中配置了 "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]，那么 Docker 就会同时监听本地 Unix Socket 和网络 2375 端口，从而实现远程管理。

简单来说，您执行的这套操作就像是在对 systemd 说：“请忘记 Docker 服务原来的启动指令，完全按照我新给的指令（一个不带参数的简单指令）来启动，具体的细节由 daemon.json 这个配置文件来提供。” 这样就确保了您对 Docker 的核心配置集中在 daemon.json 这一个文件中进行管理 。

---

**3.1 💾 在** `nano` **中保存文件的步骤：**

1️⃣ **按下**
```
Ctrl + O
```

> （字母 O，不是数字 0） 这是 “写入文件”（即保存）的快捷键。


2️⃣ 终端底部会提示：
```
File Name to Write: /etc/systemd/system/docker.service.d/override.conf
```

直接 **按回车键 Enter** 确认保存。

3️⃣ 然后再按：
```
Ctrl + X
```

退出编辑器。

---

#### 4. 重启 Docker 服务

```
# 重载 systemd 配置
sudo systemctl daemon-reload

# 重启 Docker
sudo systemctl restart docker

# 检查状态
sudo systemctl status docker
```

#### 5. 验证端口已开启

```
# 检查监听端口
sudo netstat -tulnp | grep 2375
# 或
sudo ss -tulnp | grep 2375

# 测试 API
curl http://localhost:2375/version

# 局域网内的其他机器，命令测试
# Docker 命令
docker -H tcp://192.168.0.60:2375 version
```

---

## 方法二：直接修改 systemd 服务

```
# 编辑 Docker 服务文件
sudo systemctl edit docker.service --full
```

找到`ExecStart`行，修改为：

```
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
```

**重启服务:**

```
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---


## Docker Compose 环境变量配置

如果使用 Docker Compose 远程连接：

```
# 设置环境变量
export DOCKER_HOST=tcp://192.168.1.100:2375

# 测试连接
docker ps

# 或在 docker-compose.yml 中使用
docker-compose -H tcp://192.168.1.100:2375 up -d
```

---

## 安全配置方案

### 方案 A: 使用 TLS 加密（强烈推荐）

#### 1. 生成 CA 证书

```
# 创建证书目录
mkdir -p ~/.docker/certs
cd ~/.docker/certs

# 生成 CA 私钥
openssl genrsa -aes256 -out ca-key.pem 4096

# 生成 CA 证书
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```

#### 2. 生成服务器证书

```
# 服务器私钥
openssl genrsa -out server-key.pem 4096

# 服务器 CSR
openssl req -subj "/CN=your-server-ip" -sha256 -new -key server-key.pem -out server.csr

# 配置扩展
echo subjectAltName = DNS:your-domain.com,IP:192.168.1.100,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

# 签名服务器证书
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

#### 3. 生成客户端证书

```
# 客户端私钥
openssl genrsa -out key.pem 4096

# 客户端 CSR
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# 配置扩展
echo extendedKeyUsage = clientAuth > extfile-client.cnf

# 签名客户端证书
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```

#### 4. 配置 Docker 使用 TLS

```
# 复制证书到 Docker 目录
sudo mkdir -p /etc/docker/certs
sudo cp ca.pem server-cert.pem server-key.pem /etc/docker/certs/

# 修改 daemon.json
sudo nano /etc/docker/daemon.json
```

```
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem",
  "tlsverify": true
}
```

```
# 重启 Docker
sudo systemctl restart docker

# 客户端连接（需要证书）
docker --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=cert.pem \
  --tlskey=key.pem \
  -H=tcp://192.168.1.100:2376 version
```

---

### 方案 B: 使用防火墙限制访问

```
# UFW 防火墙（Ubuntu）
sudo ufw allow from 192.168.1.0/24 to any port 2375
sudo ufw enable

# iptables
sudo iptables -A INPUT -p tcp --dport 2375 -s 192.168.1.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2375 -j DROP

# 保存规则
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

---

### 方案 C: 使用 SSH 隧道（最安全）

```
# 在客户端建立 SSH 隧道
ssh -N -L 2375:localhost:2375 user@remote-server

# 然后本地连接
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

---

## 测试连接

### 本地测试

```
# 测试 API
curl http://localhost:2375/version

# Docker 命令
docker -H tcp://localhost:2375 ps
```

### 远程测试

```
# 从其他机器测试
curl http://192.168.1.100:2375/version

# 设置环境变量
export DOCKER_HOST=tcp://192.168.1.100:2375
docker info
```

### Python 测试

```
import docker

# 连接远程 Docker
client = docker.DockerClient(base_url='tcp://192.168.1.100:2375')

# 获取信息
print(client.version())
print(client.info())

# 列出容器
for container in client.containers.list():
    print(container.name)
```

---

## 常见问题排查

### 问题 1: 端口未监听

```
# 检查 Docker 日志
sudo journalctl -u docker -n 50

# 检查配置语法
sudo dockerd --validate

# 检查进程
ps aux | grep dockerd
```

### 问题 2: 连接被拒绝

```
# 检查防火墙
sudo ufw status
sudo iptables -L -n

# 检查 SELinux（CentOS/RHEL）
sudo getenforce
sudo setenforce 0  # 临时关闭测试
```

### 问题 3: systemd 冲突

**错误信息:** `unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: hosts`

**解决方案:**

```
# 必须清空 systemd 的 ExecStart
sudo systemctl edit docker.service --full
```

找到并修改：

```
# 删除原来的 ExecStart
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

# 改为
ExecStart=/usr/bin/dockerd
```

---

## 配置检查清单

- 确认仅内网使用或已配置 TLS
- 检查防火墙规则
- 测试 API 连接
- 验证 Docker 命令可用
- 检查日志无错误
- 配置自动启动
- 备份证书（如使用 TLS）
- 文档记录配置信息



---

## 生产环境最佳实践

```
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "ip-forward": true
}
```

---

## 快速配置命令（内网环境）

```
# 一键配置（仅限内网测试！）
sudo mkdir -p /etc/systemd/system/docker.service.d
echo '[Service]
ExecStart=
ExecStart=/usr/bin/dockerd' | sudo tee /etc/systemd/system/docker.service.d/override.conf

echo '{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo netstat -tulnp | grep 2375
```

---

## 紧急关闭 2375 端口

```
# 删除配置
sudo rm /etc/docker/daemon.json
sudo rm -rf /etc/systemd/system/docker.service.d/

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证端口已关闭
sudo netstat -tulnp | grep 2375
```

记住： **安全第一** ！在生产环境务必使用 TLS 加密或 SSH 隧道。
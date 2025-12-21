
#### 环境要求

1. **系统**：Linux（推荐 Ubuntu/CentOS）
2. **依赖**：
    - Docker 20.10.0+
    - Docker Compose 2.0.0+
3. **资源**：至少 4GB RAM + 40GB 磁盘空间
4. **网络**：开放 80 (HTTP) 和 443 (HTTPS) 端口

---

### 安装步骤

1. 安装 Docker 和 Docker Compose

```bash
# 安装 Docker
export http_proxy="http://192.168.3.100:10809" 
export https_proxy="http://192.168.3.100:10809" 
curl -sSL https://get.docker.com/ | sh
systemctl start docker && systemctl enable docker

# 安装 Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

```

2. 下载 Harbor 离线安装包

```bash
mkdir /data && cd /data
wget https://github.com/goharbor/harbor/releases/download/v2.9.0/harbor-offline-installer-v2.9.0.tgz
tar xvf harbor-offline-installer-v2.9.0.tgz
cd harbor

mkdir -p /data/harbor/logs /data/harbor/cert
```

3. 配置 `harbor.yml`

```bash
cp harbor.yml.tmpl harbor.yml

vim harbor.yml  # 修改以下关键配置
#---------------------------------------------
# 必改项
hostname: harbor.od.com  # 或服务器 IP（如 192.168.1.100）

# 可选修改
port: 180                  # HTTP 端口（默认 80）
https:                    # 注释掉整个 https 部分使用 HTTP
  port: 443
  certificate: /data/harbor/cert/harbor.od.com.crt
  private_key: /data/harbor/cert/harbor.od.com.key

# 管理员密码（默认用户 admin）
harbor_admin_password: Harbor12345
# 数据存储路径（默认 /data）
data_volume: /data/harbor 
location: /data/harbor/logs
#---------------------------------------------
```


4. 生成 HTTPS 证书（如需 HTTPS）

```bash
cd /data/harbor/cert

openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.od.com" \
  -key ca.key \
  -out ca.crt
  
# 生成私钥
openssl genrsa -out harbor.od.com.key 4096

# 生成证书签名请求 (CSR)
openssl req -sha512 -new \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.od.com" \
  -key harbor.od.com.key \
  -out harbor.od.com.csr

# 生成 X509 v3 扩展文件
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.od.com
DNS.2=harbor
DNS.3=localhost
IP.1=192.168.133.200  # 替换为你的服务器IP
EOF

# 生成证书
openssl x509 -req -sha512 -days 3650 \
  -extfile v3.ext \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -in harbor.od.com.csr \
  -out harbor.od.com.crt
```


5. 执行安装脚本

```bash
sudo ./install.sh
#> 输出 `✔ ----Harbor has been installed and started successfully.----` 表示成功
```


6. nginx 代理(可选)

```bash
# 200机器：
docker-compose ps
docker ps -a
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

7. 访问 Harbor

```bash
### 客户端配置

# 分发 CA 证书到 Docker 客户端
# 在 Docker 客户端机器上操作
mkdir -p /etc/docker/certs.d/harbor.od.com
scp root@your-harbor-ip:~/certs/ca.crt /etc/docker/certs.d/harbor.od.com/ca.crt
    
# 重启 Docker
systemctl restart docker
    
# 登录 Harbor
docker login harbor.od.com
Username: admin
Password: Harbor12345  # 你在 harbor.yml 中设置的密码
    

### 验证 HTTPS 访问
# 浏览器访问
https://harbor.od.com
# 首次访问需信任自签名证书（高级 → 继续访问）
    
# API 验证
curl -k https://harbor.od.com/api/v2.0/health
# 应返回 {"status":"healthy"}
```


---

### 常用管理命令

```bash
# 停止 Harbor
docker-compose down -v

# 启动 Harbor
docker-compose up -d

# 修改配置后重新部署
sudo ./prepare
docker-compose down -v
docker-compose up -d


# docker上传镜像到harbor镜像仓库
docker login 192.168.3.100:8902
docker tag x14k3.dockerhub/code-server-go:v1.0  192.168.3.100:8902/library/code-server-go:v1.0
docker push 192.168.3.100/library/code-server-go:v1.0

```


---

### 其他问题

1. Docker 客户端信任 HTTP 仓库（非 HTTPS 时）

	```bash
	# 在客户端机器的 /etc/docker/daemon.json 添加
	{
	  "insecure-registries": ["192.168.3.100:8902"]
	}
	systemctl restart docker

	```

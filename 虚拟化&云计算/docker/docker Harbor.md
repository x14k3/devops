#virtual/docker

Harbor是由VMware公司开源的企业级的Docker Registry管理项目，它包括权限管理(RBAC)、LDAP、日志审核、管理界面、自我注册、镜像复制和中文支持等功能

## docker-harbor 部署
```bash
############################# 准备https证书 #############################

# 生成 CA 证书私钥
openssl genrsa -out ca.key 4096
# 生成 CA 证书
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=yourdomain.com" \
 -key ca.key \
 -out ca.crt
 

# 生成私钥
openssl genrsa -out server.key 4096
# 生成证书签名请求 (CSR)
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=yourdomain.com" \
    -key server.key \
    -out server.csr
# 生成 x509 v3 扩展文件
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = IP:192.168.10.31
EOF
# 使用该v3.ext文件为您的 Harbor 主机生成证书
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in server.csr \
    -out server.crt


######################## 下载docker-harbor离线安装包 #########################
# 需要先安装：docker-ce 、docker-compose
yum -y install docker-ce docker-compose
# docker-harbor 下载地址
https://github.com/goharbor/harbor/releases
# 解压harbor离线安装包
tar -zxvf harbor-offline-installer-v1.10.11.tgz -C /data/

######################## 修改配置文件 #########################
hostname: 192.168.10.31
harbor_admin_password: Ninestar123
data_volume: /data/images
certificate: /data/docker/ssl/server.crt
private_key: /data/docker/ssl/server.key

######################## 安装docker-harbor #########################
cd /data/harbor/
sh install.sh

# 启动
docker-compose up -d  #停止：docker-compose stop
# 默认用户名密码：admin/Harbar123456
```


## docker-harbor 使用

### 1. 网页登录docker-harbor
直接访问：https://192.168.10.31/

### 2. docker 登录docker-harbor
```bash
docker login 192.168.10.31 -u admin -p Ninestar123

# 若出现一下报错：
# Error response from daemon: Get "https://192.168.10.31/v2/": x509: certificate relies on legacy Common Name field, use SANs instead

# 修改docker客户端文件 /etc/docker/daemon.json 添加以下配置：

{ 
    "insecure-registries": ["0.0.0.0/0"]
}

# 重启docker服务
systemctl restart docker
```
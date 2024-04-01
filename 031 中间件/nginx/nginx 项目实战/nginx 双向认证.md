# nginx 双向认证

‍

## 使用openssl生成证书

```bash
################################### 启用双向认证 ###################################
## 使用openssl生成证书
### 创建根证私钥
openssl genrsa -out root-key.key 1024
### 创建根证书请求文件
openssl req -new -out root-req.csr -key root-key.key
### 自签根证书
openssl x509 -req -in root-req.csr -out root-cert.cer -signkey root-key.key -CAcreateserial -days 365
### 生成p12格式根证书，密码123456
openssl pkcs12 -export -clcerts -in root-cert.cer -inkey root-key.key -out root.p12
### 生成服务端ley
openssl genrsa -out  server-key.key 1024
### 生成服务端请求文件
openssl req -new -out server-req.csr -key server-key.key
### 生成服务端证书（root证书，rootkey，服务端key，服务端请求文件这4个生成服务端证书）
openssl x509 -req -in server-req.csr -out server-cert.cer -signkey server-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 365
### 生成客户端key
openssl genrsa -out client-key.key 1024
### 生成客户端请求文件
openssl req -new -out client-req.csr -key client-key.key
### 生成客户端证书（root证书，rootkey，客户端key，客户端请求文件这4个生成客户端证书）
openssl x509 -req -in client-req.csr -out client-cert.cer -signkey client-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 365
### 生成客户端p12格式根证书  密码123456
openssl pkcs12 -export -clcerts -in client-cert.cer -inkey client-key.key -out client.p12
```

## nginx.conf双向认证配置

```nginx
server {
    listen 443 ssl;
    server_name www.doshell.cn ;
    ssl_certificate         /data/nginx/ssl/server.crt;   # 证书其实是个公钥，它会被发送到连接服务器的每个客户端
    ssl_certificate_key  /data/nginx/ssl/server.key;  # 私钥是用来解密的，所以它的权限要得到保护但nginx的主进程能够读取。
    ssl_session_cache    shared:SSL:1m;    # 设置ssl/tls会话缓存的类型和大小。
    ssl_session_timeout  5m;               # 客户端可以重用会话缓存中ssl参数的过期时间
    ssl_protocols TLSv1.2 TLSv1.3;         # 使用特定的加密协议(TLSv1.1与TLSv1.2要确保OpenSSL >= 1.0.1)
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4; # 握手时使用 ECDHE 算法进行密钥交换；用 RSA 签名和身份认证；握手后的通信使用 AES 对称算法，密钥长度 256 位；分组模式是 GCM， 摘要算法 SHA384 用于消息认证和产生随机数
    ssl_prefer_server_ciphers  on;         # 设置协商加密算法时，优先使用我们服务端的加密套件
    # 双向认证
    ssl_client_certificate /data/nginx/ssl/ca.crt; # 根级证书公钥，用于验证各个二级client
    ssl_verify_client on;   # 启用客户端证书审核
    ssl_verify_depth  2;    # 设置客户证书认证链的长度
    location / {
        proxy_pass  http://127.0.0.1:8080 ;
    }
}

```

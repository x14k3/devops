

## 查看 openssl 版本和配置文件位置

```bash
$ openssl version -a
OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)
built on: Mon Jul  4 11:20:23 2022 UTC
platform: debian-amd64
options:  bn(64,64)
OPENSSLDIR: "/usr/lib/ssl" # 所在目录
ENGINESDIR: "/usr/lib/x86_64-linux-gnu/engines-3"
MODULESDIR: "/usr/lib/x86_64-linux-gnu/ossl-modules"
$ ls /usr/lib/ssl # 查看目录
certs  misc  openssl.cnf  private
$ cat /usr/lib/ssl/openssl.cnf # 查看配置文件

# openssl证书版本
openssl ciphers -v | awk '{print $2}' | sort | uniq
openssl s_client -help 2>&1  > /dev/null | egrep "\-(ssl|tls)[^a-z]"
```

## 证书认证相关

**1.**  **https 单项认证：**

server: server.crt + server.key
client: server\_ca.crt

**2.**  **https 双向认证：**

server: server.crt + server.key + client\_ca.crt
client: server\_ca.crt + client.crt + client.key

在使用 CA 证书进行签署证书时加入`-extfile`​和`-extensions`​选项，具体命令如下：

```bash
openssl x509 -req  -days 365 -sha256 -extfile openssl.cnf -extensions v3_req
 -in server.csr -signkey server.key -out server.crt
```

证书详情信息：

```bash
Version: 版本号
Serial Number: 证书序列号
Signature Algorithm: 签名算法
Issuer: 签发者(签发证书的CA实体)
Subject: 证书主体(证书持有者实体)
Validity: 有效期
    Not Before: 开始生效时间
    Not After: 证书失效时间
Subject Public Key Info: 主体公钥信息
    Public Key Algorithm: 证书主题持有的公钥密钥算法
    RSA Public-Key: 具体的公钥数据
```

一般证书的签发流程是：

申请者把自己的申请做成证书申请文件 csr(csr 中放入了申请者的公钥以及申请者的信息)
然后把 csr 发送给签发者 CA 进行证书签发，签发过程就是 CA 用自己的私钥给 csr 生成签名，然后制作为证书文件(.crt 或.pem)

nginx 判定证书的时候，是根据证书中的两个字段：Issuer 和 Subject
如果 Issuer == Subject 那么 nginx 就会认为这是一个自签名的根证书
如果 Issuer != Subject 那么 nginx 就会认为这不是一个自签名的证书，验证时需要带上签发这个证书的根证书

正式使用时，subject 中的 CN 字段需要填写使用者的域名，也就是 nginx 所在主机的域名。

## 证书生成

流程：自签 CA，由自签 CA 签发二级 CA，最后由二级 CA 签发网站证书。

[openssl](../../linux/linux%20命令/shell%20命令手册/tools/openssl.md) 参数参考：

```bash
-extensions v3_req 指定 X.509 v3版本
-extensions v3_ca 生成CA扩展名
-extfile /tmp/openssl.conf 指定特殊的配置文件
```

```bash
# 生成ROOT CA
# 5年有效期
openssl genrsa -out /opt/certs/root_ca.key 4096
openssl req -passin pass:1111 -x509 -new -nodes -key /opt/certs/root_ca.key -subj "/C=CN/ST=BJ/L=ZJ/O=Pony/OU=Pony/CN=PonyTest ROOT CA" -days 1825 -out /opt/certs/root_ca.crt

# 生成 SERVER CA 和 CLIENT CA
## 基本约束扩展，注明这个二级CA可以颁发证书，不添加则证书链无法认证
cat > certV3.ext << EOF
basicConstraints=CA:TRUE
EOF

## 服务端 SERVER CA
openssl genrsa -out /opt/certs/server_ca.key 2048
openssl req -new -key /opt/certs/server_ca.key -subj "/CN=Pony SERVER CA" -out /opt/certs/server_ca.csr
openssl x509 -req -in /opt/certs/server_ca.csr -CA /opt/certs/root_ca.crt -CAkey /opt/certs/root_ca.key -CAcreateserial -extfile certV3.ext -out /opt/certs/server_ca.crt -days 1825

## 客户端 CLIENT CA
openssl genrsa -out /opt/certs/client_ca.key 2048
openssl req -new -key /opt/certs/client_ca.key -subj "/CN=Pony CLIENT CA" -out /opt/certs/client_ca.csr
openssl x509 -req -in /opt/certs/client_ca.csr -CA /opt/certs/root_ca.crt -CAkey /opt/certs/root_ca.key -CAcreateserial -extfile certV3.ext -out /opt/certs/client_ca.crt -days 1825

# 生成server证书和client证书
## server
## 基本约束，声明证书用途为服务端证书，测试发现添加与否应该都可以
cat > certV3.ext << EOF
extendedKeyUsage=serverAuth
EOF
## 注意！！！server的subject中的CN一定要填自己的域名，https认证过程中会对比证书中的subject.CN和实际域名是否一致
openssl genrsa -out /opt/certs/server.key 2048
openssl req -new -key /opt/certs/server.key -subj "/CN=127.0.0.1" -out /opt/certs/server.csr
openssl x509 -req -in /opt/certs/server.csr -CA /opt/certs/server_ca.crt -CAkey /opt/certs/server_ca.key -CAcreateserial -extfile certV3.ext -out /opt/certs/server.crt -days 1825

## client
## 基本约束，声明证书用途为客户端证书，测试发现添加与否应该都可以
cat > certV3.ext << EOF
extendedKeyUsage=clientAuth
EOF
openssl genrsa -out client.key 2048
openssl req -new -key client.key -subj "/CN=CLIENT" -out client.csr
openssl x509 -req -in client.csr -CA client_ca.crt -CAkey client_ca.key -CAcreateserial  -extfile certV3.ext -out client.crt -days 1825

# 将 CA 证书拼接为证书链，最好把根证书放到最前面
cat root_ca.crt server_ca.crt client_ca.crt > caAll.crt
```

实例：

在 Nginx 配置参考：

```bash
server {
        listen       443 ssl;
        server_name  httpstst.com;

        ssl_certificate      certs/server.crt;
        ssl_certificate_key  certs/server.key;
        ssl_client_certificate  certs/caAll.crt;
        ssl_verify_client on;

        #ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS;
        ssl_prefer_server_ciphers  on;

        location / {
            root   html;
            index  index.html index.htm;
        }
    }
```

## 查看证书

```bash
# 查看csr证书申请文件
openssl req -noout -text -in server.csr

# 查看证书内容
openssl x509 -noout -text -in server.crt
```

## 自定义配置文件

### 创建根 CA

**1. 创建目录：**

```bash
mkdir -p /opt/certs/root/key
mkdir /opt/certs/root/newcerts
touch /opt/certs/root/index.txt
touch /opt/certs/root/index.txt.attr
echo 01 > /opt/certs/root/serial
```

**2. 编辑配置文件：**

​`vim /opt/certs/root/openssl.cnf`​ :

```bash
[ ca ]
default_ca    = CA_default
[ CA_default ]
dir            = /opt/certs/root
certs        = $dir/certs
crl_dir        = $dir/crl
database    = $dir/index.txt
new_certs_dir    = $dir/newcerts
certificate    = $dir/key/cacert.crt
serial        = $dir/serial
crlnumber    = $dir/crlnumber
crl            = $dir/crl.pem
private_key    = $dir/key/cakey.pem
RANDFILE    = $dir/key/.rand
unique_subject    = no
x509_extensions    = usr_cert
copy_extensions = copy
name_opt     = ca_default
cert_opt     = ca_default
default_days    = 365
default_crl_days= 30
default_md    = sha256
preserve    = no
policy        = policy_ca
[ policy_ca ]
countryName        = supplied
stateOrProvinceName    = supplied
organizationName    = supplied
organizationalUnitName    = supplied
commonName        = supplied
emailAddress        = optional
[ req ]
default_bits        = 2048
default_keyfile     = privkey.pem
distinguished_name    = req_distinguished_name
attributes        = req_attributes
x509_extensions    = v3_ca
string_mask = utf8only
utf8 = yes
prompt                  = no
[ req_distinguished_name ]
countryName            = CN
stateOrProvinceName        = BeiJing
localityName            = BeiJing
organizationName        = Global Pony CA Inc
organizationalUnitName    = Root CA
commonName            = Global Pony Root CA
[ usr_cert ]
basicConstraints = CA:TRUE
[ v3_ca ]
basicConstraints = CA:TRUE
[ req_attributes ]
```

**3. 生成证书：**

```bash
# 1，创建根CA私钥
openssl genrsa -out /opt/certs/root/key/cakey.pem 4096

# 2，创建根CA证书请求文件
openssl req -new -key /opt/certs/root/key/cakey.pem -out /opt/certs/root/key/ca.csr -config /opt/certs/root/openssl.cnf

# 3，自签根CA证书
openssl ca -selfsign -in /opt/certs/root/key/ca.csr -out /opt/certs/root/key/cacert.crt -config /opt/certs/root/openssl.cnf -days 1825

# 4，查看证书信息（可选）
openssl x509 -text -in /opt/certs/root/key/cacert.crt
```

经过以上几个步骤，就生成了根 CA 的相关证书和私钥，可以用于签发其他的 CA（二级 CA），不可签发服务器证书。

### 创建二级 CA

**1. 创建目录：**

```bash
mkdir -p /opt/certs/agent/key
mkdir /opt/certs/agent/newcerts
touch /opt/certs/agent/index.txt
touch /opt/certs/agent/index.txt.attr
echo 01 > /opt/certs/agent/serial
```

**2. 编辑配置文件:**

​`vim /opt/certs/agent/openssl.cnf`​ :

```bash

[ ca ]
default_ca    = CA_default
[ CA_default ]
dir            = /opt/certs/agent
certs        = $dir/certs
crl_dir        = $dir/crl
database    = $dir/index.txt
new_certs_dir    = $dir/newcerts
certificate    = $dir/key/cacert.crt
serial        = $dir/serial
crlnumber    = $dir/crlnumber
crl            = $dir/crl.pem
private_key    = $dir/key/cakey.pem
RANDFILE    = $dir/key/.rand
unique_subject    = no
x509_extensions    = usr_cert
copy_extensions = copy
name_opt     = ca_default
cert_opt     = ca_default
default_days    = 365
default_crl_days= 30
default_md    = sha256
preserve    = no
policy        = policy_ca
[ policy_ca ]
countryName        = supplied
stateOrProvinceName    = supplied
organizationName    = supplied
organizationalUnitName    = supplied
commonName        = supplied
emailAddress        = optional
[ req ]
default_bits        = 2048
default_keyfile     = privkey.pem
distinguished_name    = req_distinguished_name
attributes        = req_attributes
x509_extensions    = v3_ca
string_mask = utf8only
utf8 = yes
prompt = no
[ req_distinguished_name ]
countryName            = CN
stateOrProvinceName        = BeiJing
localityName            = BeiJing
organizationName        = Global Pony CA Inc
organizationalUnitName    = Pony 2022 CA
commonName            = Pony 2022 CA
[ usr_cert ]
basicConstraints = CA:FALSE
[ v3_ca ]
basicConstraints        = CA:TRUE
[ req_attributes ]
```

**3. 生成证书：**

```bash
# 1，创建二级CA私钥
openssl genrsa -out /opt/certs/agent/key/cakey.pem 2048

# 2，：创建二级CA证书请求文件
openssl req -new -key /opt/certs/agent/key/cakey.pem -out /opt/certs/agent/key/ca.csr -config /opt/certs/agent/openssl.cnf

# 3，使用根CA签发二级CA
openssl ca -in /opt/certs/agent/key/ca.csr -out /opt/certs/agent/key/cacert.crt -config /opt/certs/root/openssl.cnf -days 1825

# 4，查看证书信息（可选）
openssl x509 -text -in /opt/certs/agent/key/cacert.crt
```

经过以上几个步骤，就生成了一个二级 CA，这个二级 CA 可以签发服务器证书（不能签发其他的 CA）。

### 使用二级 CA 签发服务器端证书

**1. 创建目录：**

```bash
mkdir /opt/certs/vault
```

**2. 编辑配置文件:**

​`vim /opt/certs/vault/openssl.cnf`​ :

```bash
[ req ]
prompt             = no
distinguished_name = server_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_req
attributes        = req_attributes
[ server_distinguished_name ]
commonName              = Pony
stateOrProvinceName     = BeiJing
countryName             = CN
organizationName        = Pony vault Inc
organizationalUnitName  = vault IT
[ v3_req ]
basicConstraints        = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
[ req_attributes ]
[ req_ext ]
subjectAltName      = @alternate_names
[ alternate_names ]
# DNS.1        = vault2018.cn
# DNS.2        = bbs.vault2018.cn
# DNS.3        = vault2019.cn

# 改成自己的域名
#DNS.1 = kb.example.com
#DNS.2 = helpdesk.example.org

# 改成自己的ip
IP.1 = 10.10.0.103
# IP.2 = 10.10.0.85
```

**3. 生成证书：**

```bash
# 1，生成网站私钥
openssl genrsa -out /opt/certs/vault/privkey.pem 2048

# 2，生成证书请求文件（csr文件）
openssl req -new -key /opt/certs/vault/privkey.pem -out /opt/certs/vault/vault.csr -config /opt/certs/vault/openssl.cnf

# 3，使用二级CA进行签发证书（这里不能用根CA签发）
openssl ca -in /opt/certs/vault/vault.csr -out /opt/certs/vault/vault.crt -config /opt/certs/agent/openssl.cnf -days 1825

# 4，聚合证书（重要）
# PS：注意顺序
# 由于是二级CA颁发的证书，所以，服务器需要把根CA、二级CA等证书都要发送给浏览器，所以给到web服务器的证书是要一个聚合的证书
cat /opt/certs/vault/vault.crt /opt/certs/agent/key/cacert.crt /opt/certs/root/key/cacert.crt | tee /opt/certs/vault/vault_all.crt

# 5，查看证书信息（可选）
openssl x509 -text -in /opt/certs/vault/vault_all.crt
```

经过以上几个步骤，就生成了由二级 CA 签发的证书了

## 25519 证书

**1. 编辑配置文件：**

​`vim openssl-25519.cnf`​

```bash

[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
x509_extensions = v3_ca
prompt = no
[req_distinguished_name]
CN = localhost
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[ v3_ca ]
basicConstraints = CA:FALSE
[alt_names]
IP.1 = 127.0.0.1
```

**2. 生成证书：**

```bash

openssl genpkey -algorithm ED25519 > server.key
openssl req -new -out server.csr -key server.key -config openssl-25519.cnf

# 查看 csr
openssl req -in server.csr -text -noout

openssl x509 -req -days 1825 -extfile openssl-25519.cnf -extensions v3_req -in server.csr -signkey server.key -out server.crt

# 查看 crt
openssl x509 -in server.crt -text -noout
```

## CA 和证书区别

CA 和证书是有区别的，CA 是用来颁发证书和签发二级 CA 的，且两者是互斥的。也就是说，一个 CA 要么是用来签发二级 CA 的，要么是用来签发证书的。如何判断？

在 `/opt/certs/root/openssl.cnf`​ 配置文件中，有如下配置

```bash
[ usr_cert ]
basicConstraints = CA:TRUE

[ v3_ca ]
basicConstraints = CA:TRUE
```

usr\_cert 下面的 basicConstraints 代表的是当前 CA 的配置，

CA:TRUE 是当前 CA 签发的是 CA（二级 CA），不能签发证书，
CA:FALSE 是当前 CA 签发的是证书，不能签发 CA（二级 CA）

v3\_ca 下面的 basicConstraints 代表的是请求的证书是 CA 还是证书

CA:TRUE 表示当前请求的是 CA（二级 CA）
CA:FALSE 表示当前请求的是证书

如果是 CA（二级 CA），则证书请求中的 commonName 不需要填写域名，可以填写组织机构
如果是证书，则证书请求中的 commonName 需要填写域名（一般是主域名），当然了，这个主域名也要在后面的 subjectAltName 属性中

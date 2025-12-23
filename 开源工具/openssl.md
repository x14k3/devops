
# 基于 OpenSSL 自建 CA 和颁发 SSL 证书

自建 CA 颁发证书不仅可以用来鉴权，而且使你的通信更加的安全（请保护好你的证书）。在实际的软件开发中，越来越多的服务用到 HTTPS，证书的需求随之增加。那么对于我们开发者，通过自签名证书来进行测试必将非常的方便。so，有一个自己的 CA 是不是非常的库呢！下面我们一步步操作，创建我们自己的 CA。

由于 Mac 自带的 openssl 版本过低，请安装更高版本。

### 建立 CA

所有命令均在同一目录执行，没有进行跳转。

```bash
mkdir -p ./demoCA/{private,newcerts} && \ 
touch ./demoCA/index.txt && \ 
touch ./demoCA/serial && \ 
echo 01 > ./demoCA/serial
```

通过以上命令，你将得到如下目录：

```bash
tree
.
└── demoCA
    ├── index.txt
    ├── newcerts
    ├── private
    └── serial
```

#### 生成 CA 根密钥

```sh
openssl genrsa -des3 -out ./demoCA/private/cakey.pem 2048 #可以去掉des，以后签证书不用输密码
```

#### 生成 CA 证书请求

```sh
openssl req -new -key ./demoCA/private/cakey.pem -out careq.pem
```

#### 自签发 CA 根证书

```sh
openssl ca -selfsign -days 3650 -in careq.pem -out ./demoCA/cacert.pem -extensions v3_ca
```

#### 以上合二为一

```sh
openssl req -new -x509 -days 3650 -key ./demoCA/private/cakey.pem -out ./demoCA/cacert.pem -extensions v3_ca
```

到这里，我们已经有了自己的 CA 了，下面我们开始为用户颁发证书。

### 为用户颁发证书

#### 生成用户 RSA 密钥

```sh
openssl genrsa -des3 -out userkey.pem 2048 # 4096
```

#### 生成用户证书请求

```bash
openssl req -new -days 365 -key userkey.pem -out userreq.pem                       # NO SAN
openssl req -new -days 365 -key userkey.pem -out userreq.pem -config openssl.cnf   # SAN
```

#### 使用 CA 签发证书

```bash
openssl ca -in userreq.pem -out usercert.pem                      # NO SAN
openssl ca -in userreq.pem -out usercert.pem -extensions v3_ca    # 签发中级 ca
openssl ca -in userreq.pem -out usercert.pem -config openssl.cnf -extensions v3_req # SAN
```
#### 其他证书操作

```bash
# 查看证书的内容：
openssl x509 -in cert.pem -text -noout
# 吊销证书：
openssl ca -revoke cert.pem -config openssl.cnf
# 证书吊销列表：
openssl ca -gencrl -out cacert.crl -config openssl.cnf
# 查看列表内容：
openssl crl -in cacert.crl -text -noout
```



### openssl.cnf

上面步骤中，你可以观察到 `SAN` 与 `NO SAN` 标记。那么什么是 `SAN`，SAN（Subject Alternative Name）是 SSL 标准 x509 中定义的一个扩展。使用了 SAN 字段的 SSL 证书，可以扩展此证书支持的域名，使得一个证书可以支持多个不同域名的解析。所以，只执行 `NO SAN` 命令也可以签发证书，不过却不能够添加多个域名。

想要添加多个域名或泛域名，你需要使用到该扩展。那么默认的 OpenSSL 的配置是不能够满足的，我们需要复制或下载一份默认的 openssl.cnf 文件到本地。如 [github openssl](https://github.com/openssl/openssl/blob/master/apps/openssl.cnf)。这里我已经准备好一份 [openssl.cnf](http://7xokm2.com1.z0.glb.clouddn.com/openssl/openssl.cnf)。

#### 修改匹配策略

默认匹配策略是：国家名，省份，组织名必须相同（match）。我们改为可选（optional），这样避免我们生成证书请求文件时（csr）去参考 CA 证书。

```bash
# For the CA policy
[ policy_match ]
countryName         = match
stateOrProvinceName = optional
organizationName    = optional
organizationalUnitName  = optional
commonName          = supplied
emailAddress        = optional
```

#### 修改默认值

这是可选项，修改默认值，可以让你更快的颁发证书，一直回车就可以了：

```bash
[ req_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = CN
countryName_min     = 2
countryName_max     = 2

stateOrProvinceName     = State or Province Name (full name)
stateOrProvinceName_default = Shanghai

localityName        = Locality Name (eg, city)
localityName_default   = Shanghai

0.organizationName     = Organization Name (eg, company)
0.organizationName_default  = deepzz

# we can do this but it is not needed normally :-)
#1.organizationName     = Second Organization Name (eg, company)
#1.organizationName_default = World Wide Web Pty Ltd

organizationalUnitName      = Organizational Unit Name (eg, section)
organizationalUnitName_default  = deepzz
```

#### 关键步骤

最关键的地方是修改 `v3_req`。添加成如下：

```bash
[ v3_req ]

# Extensions to add to a certificate request

basicConstraints  = CA:FALSE
keyUsage          = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName    = @alt_names

[ alt_names ]
DNS.1 = abc.com
DNS.2 = *.abc.com
DNS.3 = xyz.com
IP.1 = 127.0.0.1
```

每次如果你要签发不同域名或 IP，可以直接修改 `[ alt_names ]`。

注意之后的操作，均要指定 `-config openssl.cnf`。

再来看看我们的目录结构：

```bash
$ tree
.
├── demoCA
│   ├── cacert.pem
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.attr.old
│   ├── index.txt.old
│   ├── newcerts
│   │   └── 01.pem
│   ├── private
│   │   └── cakey.pem
│   ├── serial
│   └── serial.old
├── openssl.cnf
├── usercert.pem
├── userkey.pem
└── userreq.pem
```

#### 环境变量

尽管很多文章都没有说到，但 openssl 确实是支持环境变量的。

openssl 通过 `$ENV::name` 获取环境变量，在配置文件里使用的时候只需将 `name` 替换为需要用到的环境变量的名称就可以了。

其实上面的步骤可以改成这样：

```bash
$ export SNAS=DNS:abc.com,DNS:*.abc.com,DNS:xyz.com,IP:127.0.0.1

# 修改 openssl.cnf
[ v3_req ]

# Extensions to add to a certificate request

basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName      = $ENV::SANS

# 注释掉这段配置
#[ alt_names ]
#DNS.1 = abc.com
#DNS.2 = *.abc.com
#DNS.3 = xyz.com
#IP.1 = 127.0.0.1
```
### 一步签发

如果你只是需要一张临时的证书，可以参考下面的命令：

```bash
openssl req -x509 -out localhost.crt -keyout localhost.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config<(\printf"[dn]\nCN=localhost\n[req]\ndistinguished_name=dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```


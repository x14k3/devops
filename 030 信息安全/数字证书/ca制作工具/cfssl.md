# cfssl

　　我们在实际的工作中经常遇到制作自定义的服务器证书的场景，目前能够制作CA根证书及服务器证书有`Openssl`及`cfssl`两种常用工具。

　　`cfssl`使用相对简单，本文采用cfssl 1.6.1版本进行简单介绍。

- 第一步：安装，直接二进制安装。
- 第二步：编辑配置文件和CA根证书请求配置文件，均为`json`格式。默认配置文件可以通过`cfssl print-defaults config`生成，默认请求文件可以通过`cfssl print-defaults csr`生成。推荐采用`CAT EOF`方式。
- 第三步：生成CA根证书。输入是CA证书请求配置文件，输出是三个文件，分别是CA根证书私钥、CA根证书、CA根证书请求文件。
- 第四步：编辑服务器或者客户端的证书请求配置文件，另外一个输入文件是第二步的配置文件，输出三个文件，分别是服务器或客户端证书，请求文件以及服务器或客户端的秘钥文件。

# 一、安装

　　下载地址：https://github.com/cloudflare/cfssl/releases

```bash
# wget下载cfssl
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64" -O /usr/local/bin/cfssl 
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64" -O /usr/local/bin/cfssljson

# 添加执行权限
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

# 验证
[root@k8s-master01 ~]# cfssl version
Version: 1.6.1
Runtime: go1.12.12
```

# 二、开始使用

## 2.1 获取默认设置

　　我们首先看下程序默认的配置文件和证书请求配置文件模板。

```bash
# 默认配置文件和证书请求文件
cfssl print-defaults config > ca-config.json
cfssl print-defaults csr > ca-csr.json
```

　　1.6版本的默认的配置文件`ca-config.json`

```bash
[root@k8s-master01 ~]# cat ca-config.json 
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "www": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}
```

　　1.6版本的默认的ca根证书请求文件`ca-csr.json`

```bash
[root@k8s-master01 ~]# cat ca-csr.json 
{
    "CN": "example.net",
    "hosts": [
        "example.net",
        "www.example.net"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "US",
            "ST": "CA",
            "L": "San Francisco"
        }
    ]
}
```

　　我们可以直接采用`cat EOF`方式快速生成自定义的配置文件。
将其中`profiles`修改为自己组织相对贴切的配置名称，有效期为825天（谷歌浏览器支持最长的证书有效期，即19800小时）

　　我们这里定义了两个配置模板
1、CjServer：用于服务器证书认证场景，我们后续使用这个。
2、CjClient：用于客户端证书认证

```bash
cat > ca-config.json <<EOF
{
    "signing": {
        "default": {
            "expiry": "19800h"
        },
        "profiles": {
            "kubernetes": {
                "expiry": "19800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                    "client auth"
                ]
            }
        }
    }
}
EOF

```

　　这个策略，有一个`default`默认的配置，和一个`profiles`，`profiles`可以设置多个`profile`，这里的`profile`是`etcd`。

- default默认策略，指定了证书的默认有效期是一年(8760h)
- kubernetes：表示该配置(profile)的用途是为kubernetes生成证书及相关的校验工作
- signing: 表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE;
- server auth: 用来生成服务器证书，并由客户端验证服务器身份
- client auth: 用来生成客户端证书，并由服务器验证客户端身份，如etcdctl客户端
- peer auth: 生成对等证书，用来相互通信，如etcd集群节点相互通信
- expiry：也表示过期时间，如果不写以default中的为准

　　修改根证书请求配置文件`ca-csr.json`

```bash
cat > ca-csr.json <<EOF
{
    "CN": "CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "Shanghai",
            "L": "Shanghai",
            "O": "cj.io",
            "OU": "infrastructure"
        }
    ]
}
EOF
```

- CN：Common Name；颁发者信息，
- C：Country，所在国家
- ST：State，所在省份
- L：Locality，所在城市
- O：Organization，组织名称

## 2.2 生成CA证书

```bash
[root@k8s-master01 ~]# cfssl gencert -initca ca-csr.json | cfssljson -bare ca
2023/03/17 20:19:36 [INFO] generating a new CA key and certificate from CSR
2023/03/17 20:19:36 [INFO] generate received request
2023/03/17 20:19:36 [INFO] received CSR
2023/03/17 20:19:36 [INFO] generating key: ecdsa-256
2023/03/17 20:19:36 [INFO] encoded CSR
2023/03/17 20:19:36 [INFO] signed certificate with serial number 21167330310161606485046612690190896668486866917
```

> cfssljson -bare ca这里的`ca`是生成文件的前缀名称。

　　最终生成三个输出文件，请保持ca-key.pem文件安全。此密钥允许在CA中创建任何类型的证书

```bash
$ tree
.
|-- ca-config.json
|-- ca-csr.json
|-- ca-key.pem             # 根证书私钥
|-- ca.csr                 # 根证书请求文件
|-- ca.pem                 # CA根证书
```

## 2.3 生成服务器证书

　　先手动配置服务器证书请求配置文件，这里是`vc7-csr.json`

```bash
cat > vcenter7-csr.json <<EOF
{
    "CN": "vcenter7.vmware7.cj.io",
    "hosts": [
        "vcenter7.vmware7.cj.io",
        "192.168.100.250"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "Shanghai",
            "L": "Shanghai",
	        "O": "cj.io",
	        "OU": "infrastructure"
        }
    ]
}
EOF
```

　　接下来正式使用命令生成服务器证书。

```bash
[root@k8s-master01 ~]# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=CjServer vcenter7-csr.json | cfssljson -bare vc7
2023/03/17 20:31:24 [INFO] generate received request
2023/03/17 20:31:24 [INFO] received CSR
2023/03/17 20:31:24 [INFO] generating key: rsa-2048
2023/03/17 20:31:24 [INFO] encoded CSR
2023/03/17 20:31:24 [INFO] signed certificate with serial number 37498500039785761876298069521529820767603250262

# 若证书请求文件中不配置hosts字段，则在命令行中可以通过-hostname=xxx来指定域名
[root@k8s-master01 ~]# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=192.111.111.111 -profile=CjServer test-csr.json  | cfssljson -bare test
2023/03/17 20:46:43 [INFO] generate received request
2023/03/17 20:46:43 [INFO] received CSR
2023/03/17 20:46:43 [INFO] generating key: rsa-2048
2023/03/17 20:46:43 [INFO] encoded CSR
2023/03/17 20:46:43 [INFO] signed certificate with serial number 12490631920948620397482805998355871592457978948
```

> 注意这里`-profile=CjServer`,对应的是`ca-config.json`的`profiles`下的字段

## 2.4 证书验证

```bash
[root@k8s-master01 ~]# cfssl certinfo -cert v7.pem 
{
  "subject": {
    "common_name": "vcenter7.vmware7.cj.io",
    "country": "CN",
    "organization": "cj.io",
    "organizational_unit": "infrastructure",
    "locality": "Shanghai",
    "province": "Shanghai",
    "names": [
      "CN",
      "Shanghai",
      "Shanghai",
      "cj.io",
      "infrastructure",
      "vcenter7.vmware7.cj.io"
    ]
  },
  "issuer": {
    "common_name": "CA",
    "country": "CN",
    "organization": "cj.io",
    "organizational_unit": "infrastructure",
    "locality": "Shanghai",
    "province": "Shanghai",
    "names": [
      "CN",
      "Shanghai",
      "Shanghai",
      "cj.io",
      "infrastructure",
      "CA"
    ]
  },
  "serial_number": "37498500039785761876298069521529820767603250262",
  "sans": [
    "vcenter7.vmware7.cj.io",
    "192.168.0.210"
  ],
  "not_before": "2023-03-17T12:26:00Z",
  "not_after": "2025-06-19T12:26:00Z",
  "sigalg": "SHA256WithRSA",
  "authority_key_id": "E0:E8:01:1C:FF:DF:C3:CA:60:8E:86:C6:43:46:9A:85:E5:A1:73:1A",
  "subject_key_id": "50:AC:6E:BC:9C:29:93:DD:48:13:D6:45:9E:59:3D:E1:A4:C6:D1:31",
  "pem": "-----BEGIN CERTIFICATE-----\nMIIEFDCCAvygAwIBAgIUBpF9q2cW73UFoqbTeAuQnI1B1FYwDQYJKoZIhvcNAQEL\nBQAwaTELMAkGA1UEBhMCQ04xETAPBgNVBAgTCFNoYW5naGFpMREwDwYDVQQHEwhT\naGFuZ2hhaTEOMAwGA1UEChMFY2ouaW8xFzAVBgNVBAsTDmluZnJhc3RydWN0dXJl\nMQswCQYDVQQDEwJDQTAeFw0yMzAzMTcxMjI2MDBaFw0yNTA2MTkxMjI2MDBaMH0x\nCzAJBgNVBAYTAkNOMREwDwYDVQQIEwhTaGFuZ2hhaTERMA8GA1UEBxMIU2hhbmdo\nYWkxDjAMBgNVBAoTBWNqLmlvMRcwFQYDVQQLEw5pbmZyYXN0cnVjdHVyZTEfMB0G\nA1UEAxMWdmNlbnRlcjcudm13YXJlNy5jai5pbzCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAMT61IJ1CuZf+3Cy+wwd0G9j+rP88TrN45wZTLrToXvsTWyH\n0JnXuKwkMWOy6SnXFZ7vrdA+iDRpuHtBFHZ5W0LMiJeVJsX7PaP1W3YsLVqYXRWy\ny+A2Wifb+0g0So4TbZ1oYaMhGSygFG72tGNJo0bLJmoeVjhHwMH/kNYV2Eps7yme\nNXRJpcQnAaRJGqaX9zqjoyjsuUKWOgdKfO9f8BiALlzD6uv+UhwJpjTCI6ACmxss\nIWqtIizMEHd/zkvfamYeoex0ksHOhtv1PUxtTwkV5uDr4xV6sE0BMpnXhwFuAAB3\n8w3KOP1/9nrsVvvFVdf9ZL5gb8UBOBhrXWVeIiUCAwEAAaOBnzCBnDAOBgNVHQ8B\nAf8EBAMCBaAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDAYDVR0TAQH/BAIwADAdBgNV\nHQ4EFgQUUKxuvJwpk91IE9ZFnlk94aTG0TEwHwYDVR0jBBgwFoAU4OgBHP/fw8pg\njobGQ0aaheWhcxowJwYDVR0RBCAwHoIWdmNlbnRlcjcudm13YXJlNy5jai5pb4cE\nwKgA0jANBgkqhkiG9w0BAQsFAAOCAQEAggKgS6sky2FyCwXXC/KEfhO7CI6LOO5w\n1XI+HGi2ONo81qn7OlONzvYjRXc4FsRUejRmvx07BygSmCtDNiHRBb3Cu/fwnDsD\nR07pxSXPqJqmudishLTCv27ZJYVv10XmsU7OHf8t8F7GZEyJ9C1Kwrr+8UXHsRZH\nqBpuf0MSpHSlivw9oIY0ctQTdGIxZhVHu8g7jeG6D7rmPtSr6DNCp1X4JWFsdz9M\nCybhFaNla0QEmxxNsG5aIa2cfe5crk4c4HMyK4Gxs0naMpda1EYpVweGOqrW3Frr\nKbdv73M/F8psqxz1PpVG/33dvazmb+cxhhgjA4oz8b2AZAbZZgHnTg==\n-----END CERTIFICATE-----\n"
}
```

> 注意其中`"sans"`字段和所设计的域名是否匹配。

# 三、cfssl 命令介绍

　　cfssl工具，子命令介绍：

```bash
bundle     # 创建包含客户端证书的证书包
genkey     # 生成一个key(私钥)和CSR(证书签名请求)
scan       # 扫描主机问题
revoke     # 吊销证书
certinfo   # 输出给定证书的证书信息， 跟cfssl-certinfo 工具作用一样
gencrl     # 生成新的证书吊销列表
selfsign   # 生成一个新的自签名密钥和 签名证书
print-defaults # 打印默认配置，这个默认配置可以用作模板
	config     # 生成ca配置模板文件
	csr        # 生成证书请求模板文件 
serve      # 启动一个HTTP API服务
gencert    # 生成新的key(密钥)和签名证书
	-initca    # 初始化一个新ca
	-ca        # 指明ca的证书
	-ca-key    # 指明ca的私钥文件
	-config    # 指明请求证书的json文件
	-profile   # 与-config中的profile对应，是指根据config中的profile段来生成证书的相关信息
ocspdump
ocspsign
info        # 获取有关远程签名者的信息
sign        # 签名一个客户端证书，通过给定的CA和CA密钥，和主机名
ocsprefresh
ocspserve
```

# 四、补充-公钥基础设施(PKI)

## 1. 基础概念

　　CA(Certification Authority)证书，指的是权威机构给我们颁发的证书。

　　密钥就是用来加解密用的文件或者字符串。密钥在非对称加密的领域里，指的是私钥和公钥，他们总是成对出现，其主要作用是加密和解密。常用的加密强度是2048bit。

　　RSA即非对称加密算法。非对称加密有两个不一样的密码，一个叫私钥，另一个叫公钥，用其中一个加密的数据只能用另一个密码解开，用自己的都解不了，也就是说用公钥加密的数据只能由私钥解开。

## 2. 证书的编码格式

　　PEM(Privacy Enhanced Mail)，通常用于数字证书认证机构（Certificate Authorities，CA），扩展名为.pem, .crt, .cer, 和 .key。内容为Base64编码的ASCII码文件，有类似"-----BEGIN CERTIFICATE-----" 和 "-----END CERTIFICATE-----"的头尾标记。服务器认证证书，中级认证证书和私钥都可以储存为PEM格式（认证证书其实就是公钥）。Apache和nginx等类似的服务器使用PEM格式证书。

　　DER(Distinguished Encoding Rules)，与PEM不同之处在于其使用二进制而不是Base64编码的ASCII。扩展名为.der，但也经常使用.cer用作扩展名，所有类型的认证证书和私钥都可以存储为DER格式。Java使其典型使用平台。

## 3. 证书签名请求CSR

　　CSR(Certificate Signing Request)，它是向CA机构申请数字×××书时使用的请求文件。在生成请求文件前，我们需要准备一对对称密钥。私钥信息自己保存，请求中会附上公钥信息以及国家，城市，域名，Email等信息，CSR中还会附上签名信息。当我们准备好CSR文件后就可以提交给CA机构，等待他们给我们签名，签好名后我们会收到crt文件，即证书。

　　注意：CSR并不是证书。而是向权威证书颁发机构获得签名证书的申请。

　　把CSR交给权威证书颁发机构,权威证书颁发机构对此进行签名,完成。保留好CSR,当权威证书颁发机构颁发的证书过期的时候,你还可以用同样的CSR来申请新的证书,key保持不变.

## 4. 数字签名

　　数字签名就是"非对称加密+摘要算法"，其目的不是为了加密，而是用来防止他人篡改数据。

　　其核心思想是：比如A要给B发送数据，A先用摘要算法得到数据的指纹，然后用A的私钥加密指纹，加密后的指纹就是A的签名，B收到数据和A的签名后，也用同样的摘要算法计算指纹，然后用A公开的公钥解密签名，比较两个指纹，如果相同，说明数据没有被篡改，确实是A发过来的数据。假设C想改A发给B的数据来欺骗B，因为篡改数据后指纹会变，要想跟A的签名里面的指纹一致，就得改签名，但由于没有A的私钥，所以改不了，如果C用自己的私钥生成一个新的签名，B收到数据后用A的公钥根本就解不开。

　　常用的摘要算法有MD5、SHA1、SHA256。

　　使用私钥对需要传输的文本的摘要进行加密，得到的密文即被称为该次传输过程的签名。

## 5. 数字证书和公钥

　　数字证书则是由证书认证机构（CA）对证书申请者真实身份验证之后，用CA的根证书对申请人的一些基本信息以及申请人的公钥进行签名（相当于加盖发证书机 构的公章）后形成的一个数字文件。实际上，数字证书就是经过CA认证过的公钥，除了公钥，还有其他的信息，比如Email，国家，城市，域名等。

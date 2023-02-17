#openSource

# easy-rsa3

easy-rsa 是一个 CLI 实用程序，用于构建和管理 PKI CA。通俗地说，这意味着创建根证书颁发机构，并请求和签署证书，包括中间 CA 和证书吊销列表 （CRL）。

下载地址：https://github.com/OpenVPN/easy-rsa

## 一、安装easy-rsa3

```bash
tar -zxf EasyRSA-3.1.1.tgz -C /data

[root@fmsrvdb EasyRSA-3.1.1]# tree /data/EasyRSA-3.1.1/
/data/EasyRSA-3.1.1/
├── ChangeLog
├── COPYING.md
├── doc
│   ├── EasyRSA-Advanced.md
│   ├── EasyRSA-Contributing.md
│   ├── EasyRSA-Readme.md
│   ├── EasyRSA-Renew-and-Revoke.md
│   ├── EasyRSA-Upgrade-Notes.md
│   ├── Hacking.md
│   └── Intro-To-PKI.md
├── easyrsa
├── gpl-2.0.txt
├── mktemp.txt
├── openssl-easyrsa.cnf
├── README.md
├── README.quickstart.md
├── vars.example
└── x509-types
    ├── ca
    ├── client
    ├── code-signing
    ├── COMMON
    ├── email
    ├── kdc
    ├── server
    └── serverClient

2 directories, 24 files
[root@fmsrvdb EasyRSA-3.1.1]# 
```

## 二、配置环境变量

```bash
cd /usr/share/easy-rsa/3.0.8
vim vars
-----------------------------------------------------------------
set_var EASYRSA                 "$PWD"
set_var EASYRSA_PKI             "$EASYRSA/pki"
set_var EASYRSA_DN              "cn_only"
set_var EASYRSA_REQ_COUNTRY     "ID"
set_var EASYRSA_REQ_PROVINCE    "Jakarta"
set_var EASYRSA_REQ_CITY        "Jakarta"
set_var EASYRSA_REQ_ORG         "hakase-labs CERTIFICATE AUTHORITY"
set_var EASYRSA_REQ_EMAIL       "openvpn@hakase-labs.io"
set_var EASYRSA_REQ_OU          "HAKASE-LABS EASY CA"
set_var EASYRSA_KEY_SIZE        2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       7500
set_var EASYRSA_CERT_EXPIRE     3650
set_var EASYRSA_NS_SUPPORT      "no"
set_var EASYRSA_NS_COMMENT      "HAKASE-LABS CERTIFICATE AUTHORITY"
set_var EASYRSA_EXT_DIR         "$EASYRSA/x509-types"
set_var EASYRSA_SSL_CONF        "$EASYRSA/openssl-1.0.cnf"
set_var EASYRSA_DIGEST          "sha256"
-----------------------------------------------------------------
chmod u+x vars
```

## 三、服务端

```bash
mkdir /etc/openvpn/server
cp /usr/share/easy-rsa/3.0.8/* /etc/openvpn/server
cd /etc/openvpn/server

# 初始化，会在当前目录创建PKI目录，用于存储一些中间变量及最终生成的证书
./easyrsa init-pki 

# 创建根证书，首先会提示设置密码，用于ca对之后生成的server和client证书签名时使用
./easyrsa build-ca

# 创建server端证书和private key，nopass表示不加密private key
./easyrsa gen-req server nopass

# 给server端证书做签名，首先是对一些信息的确认，可以输入yes，然后输入build-ca时设置的那个密码
./easyrsa sign server server

# 创建Diffie-Hellman(加密解密密钥)，时间会有点长，耐心等待
./easyrsa gen-dh
# Diffie-Hellman:一种确保共享KEY安全穿越不安全网络的方法，
# 它是OAKLEY的一个组成部分。Whitefield与Martin Hellman在1976年提出了一个奇妙的密钥交换协议，
# 称为Diffie-Hellman密钥交换协议/算法(Diffie-Hellman Key Exchange/Agreement Algorithm).
# 这个机制的巧妙在于需要安全通信的双方可以用这个方法确定对称密钥。然后可以用这个密钥进行加密和解密。
# 但是注意，这个密钥交换协议/算法只能用于密钥的交换，而不能进行消息的加密和解密。
# 双方确定要用的密钥后，要使用其他对称密钥操作加密算法实现加密和解密消息。

```

## 四、客户端

```bash
mkdir /etc/openvpn/clinet
cp /usr/share/easy-rsa/3.0.8/* /etc/openvpn/clinet
cd /etc/openvpn/clinet

# 创建client端证书和private key，clientname为自定义字符串，nopass表示不加密private key
./easyrsa gen-req clientname nopass

# 客户签约:回到server目录，准备签名。
# client.req路径为上步生成的client.req的绝对路径，clientname为上步的clientname
cd /etc/openvpn/server
./easyrsa import-req [client.req所在路径] [clientname]
# 给client端证书做签名，首先是对一些信息的确认，输入yes然后输入build-ca时设置的那个密码便成功
./easyrsa sign client clientname

```

至此，server和client端证书已制作完毕

```bash
openvpn server端：

server/pki/ca.crt
server/pki/private/server.key
server/pki/issued/server.crt
server/pki/dh.pem
========================================
openvpn client端：

client/pki/ca.crt
client/pki/issued/client.crt
client/pki/private/client.key


```

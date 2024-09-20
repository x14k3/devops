# wireguard

　　基于Wireguard技术的虚拟个人网络搭建（基于Lighthouse服务器）

## 服务端配置

### 安装Wireguard

```bash
#root权限
sudo -i
#安装wireguard软件
apt install wireguard resolvconf -y
#开启IP转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
cd /etc/wireguard/
chmod 0777 /etc/wireguard
#调整目录默认权限
umask 077
```

### 生成秘钥

```
#生成私钥
wg genkey > server.key
#通过私钥生成公钥
wg pubkey < server.key > server.key.pub

### 生成客户端(client1)秘钥
#生成私钥
wg genkey > client1.key
#通过私钥生成公钥
wg pubkey < client1.key > client1.key.pub
#生成私钥
wg genkey > client2.key
#通过私钥生成公钥
wg pubkey < client2.key > client2.key.pub
```

### 创建服务器配置文件

```bash
cat <<EOF >> /etc/wireguard/wg0.conf
[Interface]
# 填写本机的privatekey 内容
PrivateKey = $(cat server.key)
# 本机虚拟局域网IP
Address = 10.9.0.1/24

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT;iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT;iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
#注意eth0需要为本机网卡名称
# 监听端口
ListenPort = 50814
DNS = 8.8.8.8
MTU = 1420

[Peer]
#client1的公钥
PublicKey =  $(cat client1.key.pub) 
#客户端Client1所使用的IP
AllowedIPs = 10.9.0.2/32
#client2的公钥
PublicKey =  $(cat client2.key.pub) 
#客户端Client2所使用的IP
AllowedIPs = 10.9.0.3/32
EOF
```

### 启动wireguard

```bash
systemctl enable wg-quick@wg0
#启动wg0
wg-quick up wg0
#关闭wg0
wg-quick down wg0
```

　　‍

## 客户端配置（以client1为例）

```bash
[Interface]
#此处为client1的私钥
PrivateKey = 6M8HEZioew+vR3i53sPc64Vg40YsuMzh4vI1Lkc88Xo=
#此处为peer规定的客户端IP
Address = 10.9.0.2/32
MTU = 1500

[Peer]
#此处为server的公钥
PublicKey = Tt5WEa0Vycf4F+TTjR2TAHDfa2onhh+tY8YOIT3cKjI=
#此处为允许的服务器IP
AllowedIPs = 10.9.0.0/24
#服务器对端IP+端口
Endpoint = 114.132.56.178:50814
```

　　‍

## Docker安装Wireguard

### 通过容器安装wg-easy

```docker
docker run -d \
  --name=wg-easy \
  -e WG_HOST=123.123.123.123 (🚨这里输入服务器的公网IP) \
  -e PASSWORD=passwd123 (🚨这里输入你的密码) \
  -e WG_DEFAULT_ADDRESS=10.0.8.x （🚨默认IP地址）\
  -e WG_DEFAULT_DNS=114.114.114.114 （🚨默认DNS）\
  -e WG_ALLOWED_IPS=10.0.8.0/24 （🚨允许连接的IP段）\
  -e WG_PERSISTENT_KEEPALIVE=25 （🚨重连间隔）\
  -v ~/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy
```

### 更新容器命令

```
docker stop wg-easy
docker rm wg-easy
docker pull weejewel/wg-easy
```

　　‍

　　‍

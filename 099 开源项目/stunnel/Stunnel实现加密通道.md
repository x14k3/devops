# Stunnel实现加密通道

## 创建自签名证书

在要做为stunnel server的服务器上使用下面命令生成自签名证书：

```bash
openssl req -new -x509 -days 3650 -nodes -out stunnel.pem -keyout stunnel.pem

# req指令，用来创建和管理证书请求（Certificate Signing Request, CSR）以让第三方权威机构CA来签发我们需要的证书。也可以使用-x509参数来生成自签名证书。
  # -new参数，表示新建证书（或证书请求）
  # -x509参数，表示要生成x.509格式的证书而不是证书请求
  # -days参数，表示生成的证书的有效时间
  # -nodes参数，不要加密私钥（如果没有定义这个参数，执行openssl req命令时候会要求输入一个密码，来对要生成的私钥文件进行加密，然后后面stunnel或nginx这些服务器程序要使用这个私钥的时候就会被要求输入密码）
  # -out参数，要生成的证书(certificate)文件名（如果没有定义-x509参数，生成的就是证书请求certificate request）
  # -keyout参数，要生成的私钥(private key)文件名（上面使用了跟证书一样的文件名，并不会覆盖该文件，而是追加到一起）
```

‍

## 安装配置stunnel

### 安装Stunnel

```
sudo apt-get install stunnel
```

stunnel在ubuntu上的配置文件是要放在/etc/stunnel/目录下的，用vim打开这个目录下的/etc/stunnel/README文件（`vim /etc/stunnel/README`​ ），就可以看到给的示例文件是在下边的路径上，实例文件可以参考使用

```hljs
/usr/share/doc/stunnel4/examples/stunnel.conf-sample
```

### 配置stunnel server

默认的stunnel配置文件在/etc/stunnel/stunnel.conf。关于更多参数信息，可以参考：[https://www.stunnel.org/static/stunnel.html](https://www.stunnel.org/static/stunnel.html)

```conf
; 设置工作目录
chroot = /var/run/stunnel/
; 设置stunnel的pid文件路径（在chroot下）
pid = /stunnel.pid
; 设置stunnel工作的用户（组）
setuid = root
setgid = root

; 开启日志等级：emerg (0), alert (1), crit (2), err (3), warning (4), notice (5), info (6), or debug (7)
; 默认为5
debug = 7
; 日志文件路径（我的server的版本有个bug，这个文件也被放在chroot路径下了，client的版本则是独立的=。=#）
output = /stunnel.log

; 证书文件，就是在本文2.2中用openssl生成的自签名证书（server端必须设置这两项）
cert = /etc/stunnel/stunnel.pem
; 私钥文件
key = /etc/stunnel/stunnel.pem

; 设置stunnel服务，可以设置多个服务，监听同的端口，并发给不同的server。
; 自定义服务名squid-proxy
[squid-proxy]
; 服务监听的端口，client要连接这个端口与server通信
accept = 3129
; 服务要连接的端口，连接到squid的3128端口，将数据发给squid
connect = 3128

; **************************************************************************
; * 下面这些配置我都注释掉了，但也需要了解下 *
; **************************************************************************

; 设置是否对传输数据进行压缩，默认不开启。
; 这是跟openssl相关的，如果你的openssl没有zlib，开启这个设置会导致启动失败（failed to initialize compression method）
;compression = zlib

; 设置ssl版本,这个也是跟安装的openssl有关的
;sslVersion = TLSv1

; Authentication stuff needs to be configured to prevent MITM attacks
; It is important to understand that this option was solely designed for access control and not for authorization
; It is not enabled by default!
; 下面这些配置用来定义是否信任对方发过来的证书。就好比浏览器访问https的时候，浏览器默认会信任那些由权威CA机构签发的证书，
; 对于那些自签名证书，浏览器就会弹出对话框提醒用户这个证书可能不安全，是否要信任该证书。
; 这是有效防止中间人攻击的手段
; verify 等级2表示需要验证对方发过来的证书（默认0，不需要验证，都信任）
; 因为这个配置是server端的，我们不需要理会client的证书（client也不会没事发证书过来啦）
;verify = 2
; CAfile 表示受信的证书文件，即如果对方发过来的证书在这个CAfile里，那么就是受信任的证书；否则不信任该证书，断开连接。
;CAfile = /etc/stunnel/stunnel-client.pem
```

‍

### 配置stunnel client

因为我会在client的配置中开启了证书验证，就是对于对方发过来的证书文件，client需要去CAfile中进行匹配，匹配到的证书才是受信证书，才允许建立连接。这样的话，我们就需要把server端的证书拷贝过来。我是直接打开server端的stunnel.pem，然后将里面CERITIFICATE拷贝到client端新建的/etc/stunnel/stunnel-server.pem文件中。

```conf
; stunnel工作目录
chroot = /var/run/stunnel/
; stunnel工作的用户组
setuid = root
setgid = root
; stunnel工作时候的pid
pid = /stunnel.pid

; 日志等级
debug = 7
; 日志文件
output = /var/log/stunnel/stunnel.log

; 表示以client模式启动stunnel，默认client = no，即server模式
client = yes

; 定义一个服务
[squid-proxy]
; 监听3128端口，那么用户浏览器的代理设置就是 stunnel-client-ip:3128
accept = 3128
; 要连接到的stunnel server的ip与端口
connect = xx.xx.xx.xx:3129

; 需要验证对方发过来的证书
verify = 2
; 用来进行证书验证的文件（里面有stunnel server的证书）
CAfile = /etc/stunnel/stunnel-server.pem

; 客户端不需要传递自己的证书，所以注释掉
;cert = /etc/stunnel/stunnel.pem
;key = /etc/stunnel/stunnel.key
```

### 双向认证

上面的配置中，client需验证来自对方的证书是否可信，而server不需要验证对方的证书，这是常规的https的做法，可以有效防止中间人攻击。

但如果我们不希望stunnel server被别人利用，就应该进行双向认证，实现client的access  control。即在连接时候，client也需要给server发送自己的证书，server验证对方证书可信才进行连接，这样可以避免server被其他人搭建的client利用（当然这个可能性很小）。

但是！如果进行双向认证的话，肯定要比单向认证更耗时间，降低连接效率。我觉得更好的办法是在stunnel  server的防火墙上限制对server端口的访问，只允许来自我们自建的client-ip的连接，对于其他ip则直接拒绝。同理，也可以在client端去掉对server证书的认证，通过防火墙进行限制。注意这只是忽略掉了对证书的认证，server-client之间的连接还是需要用ssl进行加密的，server还是得传递共有证书给client。

‍

**a. 在client端操作**

```bash
openssl req -x509 -newkey rsa:4096 -days 7300 -nodes -keyout client.key.pem -out client.crt.pem
# 拷贝 client.crt.pem 到 server 端的 /etc/stunnel/
-------------------------------------------------------------------------------
cert = /etc/stunnel/client.crt.pem
key  = /etc/stunnel/client.key.pem
client        = yes

[xxx client]
accept        = 192.168.1.20:9000
connect       = a.b.c.d:8000
verify = 3
CAfile        = /etc/stunnel/server.crt.pem
-------------------------------------------------------------------------------
```

**b. 在server端操作**

```bash
# 
openssl req -x509 -newkey rsa:4096 -days 7300 -nodes -keyout server.key.pem -out server.crt.pem
# 拷贝 server.crt.pem 到 client 端的 /etc/stunnel/
-------------------------------------------------------------------------------
cert = /etc/stunnel/server.crt.pem
key  = /etc/stunnel/server.key.pem
client        = no

[xxx server]
accept        = a.b.c.d:8000
connect       = 192.168.1.10:9000
verify = 3
CAfile        = /etc/stunnel/client.crt.pem
-------------------------------------------------------------------------------
```

### 配置日志文件

注：在client/server端同时操作

**a. 准备日志路径**

```bash
mkdir -p /var/log/stunnel/
chown stunnel:stunnel /var/log/stunnel/
chmod 644 /var/log/stunnel/

```

**b. 日志轮转**

创建文件`/etc/logrotate.d/stunnel`​

```bash
/var/log/stunnel/*.log {
    create 0644 stunnel stunnel
    missingok
    daily
    rotate 30
    compress
    sharedscripts
    postrotate
        pkill --signal SIGUSR1 -f /usr/bin/stunnel
    endscript
}

```

### 添加systemd service文件

```bash
cat << OEF >>/etc/systemd/system/stunnel.service 
[Unit]
Description=TLS Tunnel
After=network.target
After=syslog.target

[Service]
Type=simple
User=stunnel
Group=stunnel
Restart=always
RestartSec=30
StartLimitInterval=5
StartLimitBurst=0
ExecStart=/usr/bin/stunnel /etc/stunnel/stunnel.conf

[Install]
WantedBy=multi-user.target
EOF

```

设置开机启动

```bash
systemctl enable stunnel.service 
systemctl start stunnel.service 
systemctl status stunnel.service 
```

# frp

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

下载地址：

[https://github.com/fatedier/frp/releases](https://github.com/fatedier/frp/releases)

## 1.frp服务端配置

在具有公网 IP 的机器上部署 frps，修改 frps.ini 文件，这里使用了最简化的配置，设置了 frp 服务器用户接收客户端连接的端口：

```bash
# 1.修改frps.ini配置文件
---------------------------------
[common]
bind_port = 8905
token = Sds289970862
authentication_timeout = 90
---------------------------------

# 2.创建systemd服务
cat > /usr/lib/systemd/system/frps.service <<EOF
Description = frp server
After = network.target syslog.target
Wants = network.target
[Service]
Type = simple
ExecStart = /data/frps/bin/frps -c /data/frps/conf/frps.ini
[Install]
WantedBy = multi-user.target
EOF

# 启动frps
systemctl daemon-reload
systemctl enable frps
systemctl start frps
systemctl status frps
```

## 2.frp客户端配置

在需要被访问的内网机器上（SSH 服务通常监听在 22 端口）部署 frpc，修改 frpc.ini 文件，

```bash
[common]
server_addr = 119.28.xx.113
server_port = 8905
token = Sds289970862

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 22922

# local_ip 和 local_port 配置为本地需要暴露到公网的服务地址和端口。
# remote_port 表示在 frp 服务端监听的端口，访问此端口的流量将会被转发到本地服务对应的端口。
# frp 服务端防火墙需要开放 remote_port 端口

# 启动服务
nohup  /data/frps/frpc -c /data/frps/frpc.ini >> /data/logs/frpc.log 2>&1 &

# 访问frp服务端 119.28.xx.113:22922 的流量转发到内网机器的 22 端口。
```

## 3.其他

### 使用nginx代理frps

```nginx
    # 代理frps dashboard服务端口
    server {
            listen       31903 ssl;
            server_name  xxxxxxxxx;
            #证书文件名称
            ssl_certificate /data/nginx/ssl/doshell.crt;
            #私钥文件名称
            ssl_certificate_key /data/nginx/ssl/doshell.key;
            ssl_session_timeout 5m;
            ssl_protocols TLSv1.2 TLSv1.3;
            ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
            ssl_prefer_server_ciphers on;
            #access_log  logs/host.access.log  main;
            location / {
                proxy_pass http://127.0.0.1:7001;
                limit_conn conn_zone 5;
                # 限制下载速度
                limit_rate 512k;
            }
        }
      
      # 代理frps服务端口和frpc映射到frps公网的端口
        upstream frps {
        server 127.0.0.1:7000;
        }
        upstream frpc {
        server 127.0.0.1:6000;
        }
        server {
            listen 31901;
            proxy_connect_timeout 10s;
            proxy_timeout 10s;
            proxy_pass frps;
        }
        server {
            listen 31902;
            proxy_connect_timeout 10s;
            proxy_timeout 10s;
            proxy_pass frpc;
        }
```

### ftps.ini配置文件详解

```bash
# 下面这句开头必须要有，表示配置的开始
[common]
# frp 服务端端口（必须）
bind_port = 7000
# frp 服务端密码（必须）
token = 12345678

# 认证超时时间，由于时间戳会被用于加密认证，防止报文劫持后被他人利用
# 因此服务端与客户端所在机器的时间差不能超过这个时间（秒）
# 默认为900秒，即15分钟，如果设置成0就不会对报文时间戳进行超时验证
authentication_timeout = 900
# 仪表盘端口，只有设置了才能使用仪表盘（即后台）
dashboard_port = 7500

# 仪表盘访问的用户名密码，如果不设置，则默认都是 admin
dashboard_user = admin
dashboard_pwd = admin

# 为 HTTP 类型代理监听的端口，启用后才支持 HTTP 类型的代理，默认不启用
vhost_http_port = 10080
# 为 HTTPS 类型代理监听的端口，启用后才支持 HTTPS 类型的代理，默认不启用
vhost_https_port = 10443

# 此设置需要配合客户端设置，仅在穿透到内网中的 http 或 https 时有用（可选）
# 二级域名后缀
subdomain_host = example.com

#日志
log_file          # 日志文件地址
log_level         # 日志等级trace, debug, info, warn, error
log_max_days      # 日志文件保留天数  3
tcp_keepalive     # 和客户端底层 TCP 连接的 keepalive 间隔时间，单位秒
heartbeat_timeout # 服务端和客户端心跳连接的超时时间
```

### ftpc.ini配置文件详解

```bash
# 下面这句开头必须要有，表示配置的开始
[common]
# 修改成服务端的公网IP
server_addr = 0.0.0.0
# 服务端公开的公网IP端口，需要提前开通进出
server_port = 7000
# 填写 frp 服务端密码
token = 12345678

# 自定义一个配置名称，格式为“[名称]”，放在开头
[ssh]
# 连接类型，填 tcp 或 udp
type = tcp
# 修改成你要连接的IP，如果是本地就修改成127.0.0.1
local_ip = 127.0.0.1
# 要连接的内网IP端口
local_port = 22
# 是否加密客户端与服务端之间的通信，默认是 false
use_encryption = false
# 是否压缩客户端与服务端之间的通信，默认是 false
# 压缩可以节省流量，但需要消耗 CPU 资源
# 加密自然也会消耗 CPU 资源，但是不大
use_compression = false
# 映射后的公网端口
remote_port = 6000
```

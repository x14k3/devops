

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

下载地址：

[https://github.com/fatedier/frp/releases](https://github.com/fatedier/frp/releases)

```bash
#https://github.com/fatedier/frp/releases
wget --no-check-certificate --content-disposition https://github.com/fatedier/frp/releases/download/v0.52.3/frp_0.52.3_linux_amd64.tar.gz 
```

## 1.frp服务端配置

在具有公网 IP 的机器上部署 frps

1.修改frps.toml 配置文件

```bash
bindPort = 8903
auth.token = "11d75226-df37-4ebf-9e2a-4ec408b9bdd0"
log.to = "/data/frps/frps.log"
log.level = "info"
```

2.创建systemd服务

```bash
echo '
[Unit]
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = /data/frps/frps -c /data/frps/frps.toml

[Install]
WantedBy = multi-user.target
' >> /etc/systemd/system/frps.service 
```

3.启动frps

```bash
systemctl daemon-reload
systemctl start frps
```

‍

## 2.frp客户端配置

在需要被访问的内网机器上（SSH 服务通常监听在 22 端口）部署 frpc，

1.修改 frpc.toml 文件，

​`vim /data/frpc/frpc.toml`​

```bash
serverAddr = "8.210.145.225"
serverPort = 11053
auth.token = "22d75226-df37-4ebf-9e2a-4ec408b9bdd0"

[[proxies]]
name = "note-ssh-tcp"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8902
remotePort = 22922
```

2.启动服务

​`nohup  /data/frpc/frpc -c /data/frpc/frpc.toml >> frpc.log 2>&1 &`​

## 3.其他

### 使用nginx代理frps

```nginx
stream {
  log_format proxy '$remote_addr $status [$time_iso8601] $session_time ';
  open_log_file_cache off;
  limit_conn_zone $binary_remote_addr zone=stream_conn_zone:5m;
  #limit_req_zone $binary_remote_addr zone=req_zone:5m  rate=1r/s;

  #frps
  server {
    listen 11053;
    proxy_pass 127.0.0.1:8903;
    proxy_timeout 120;     # 链接保持时间    proxy_connect_timeout 30s;
    limit_conn stream_conn_zone 6;
    access_log logs/frps.log proxy ;
  }

}
```

### ftps.toml 配置文件详解

```bash

```

### ftpc.toml 配置文件详解

```bash

```

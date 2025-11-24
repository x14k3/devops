
- 免费、轻量！简单调用接口即可给自己的iPhone发送推送。
- 依赖苹果APNs，及时、稳定、可靠
- 不会消耗设备的电量， 基于系统推送服务与推送扩展，APP本体并不需要运行。
- 隐私安全，可以通过一些方式确保包含作者本人在内的所有人都无法窃取你的隐私。  

类似的工具有 [[iGotify]]

- [Bark](https://github.com/Finb/Bark) 是完整开源的 iOS APP，用来接收自定义推送。
- [bark-server](https://github.com/Finb/bark-server) 是完整开源的 Bark 服务后端，用来接收用户的推送请求并转发给苹果APNS。

## bark-server 部署

### docker 部署

```bash
docker run -dt --name bark \
-p 8080:8080 \
-v `pwd`/bark-data:/data \
finab/bark-server
```


### docker compose 部署

```bash
mkdir bark && cd bark 
curl -sL https://git.io/JvSRl > docker-compose.yaml 
docker-compose up -d
```

### 手动部署

1. 根据平台下载可执行文件:  
    [https://github.com/Finb/bark-server/releases](https://github.com/Finb/bark-server/releases)  
    或自己编译  
    [https://github.com/Finb/bark-server](https://github.com/Finb/bark-server)
2. 运行
    ```bash
    wget https://github.com/Finb/bark-server/releases/download/v2.2.6/bark-server_linux_amd64
    chmod u+x bark-server_linux_amd64
    ./bark-server_linux_amd64 -addr 0.0.0.0:8903 -data ./bark-data

	# 如果你需要短时间大批量推送，可以配置 bark-server 使用多个 APNS Clients 推送， 每一个 Client 代表一个新的连接（可能连接到不同的APNs服务器），请根据 CPU 核心数设置这个参数，Client 数量不能超过CPU核心数（超过会自动设置为当前 CPU 核心数）。
    # --max-apns-client-count 4
    ```
3. 启动脚本
	```bash
	#!/bin/bash
	nohup ./bark-server_linux_amd64 -addr 0.0.0.0:8903 -data ./bark-data >> bark-server.log 2>&1 &
	```


## nginx 代理

```bash
####### bark
        location /bark/ {
            proxy_pass http://127.0.0.1:8903/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
        }
```


## 使用说明

### 测试服务器

```bash
# 使用 `curl` 命令测试服务器的 
curl https://xxxx.com:1234/bark/ping
{"code":200,"message":"pong","timestamp":1903969315}
# 结果: 如果返回 `pong`，则表示服务器部署成功且可以正常访问。 
```

### 配置客户端

- **下载 App**: 在你的 iPhone 上下载并安装 [Bark app](https://zhuanlan.zhihu.com/p/375637631)。
- **添加服务器**: 打开 Bark App，进入设置或添加服务器的选项，输入你的私有服务器地址。这个地址是 `http://你的服务器IP:端口`。
- 获取设备ID：[[开源工具/assets/3f2b268a06f02b20de2ad1937071e89d_MD5.jpg|Open: Pasted image 20251124153800.png]]
![[开源工具/assets/3f2b268a06f02b20de2ad1937071e89d_MD5.jpg|375]]

### 发送消息

```bash
# 你可以使用 `curl` 命令
# 消息会通过 Bark 服务器推送，并显示在你的 iPhone 上的 Bark App 中。
curl https://xxxx.com:1234/bark/你的设备ID/标题/内容


# 以下是我发送到手机 阿里云ssl证书到期告警通知 的脚本
# ##################################################
#!/bin/bash
cert_file="/etc/nginx/ssl/xxxxx.xyz.pem"
bark_url='https://xxxxxxx.xyz:123/bark/xxidididididid'

expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
expiry_timestamp=$(date -d "$expiry_date" +%s)
current_timestamp=$(date +%s)
days_left=$(( (expiry_timestamp - current_timestamp) / 86400 ))

echo "证书文件: $cert_file"
echo "过期时间: $expiry_date"
echo "剩余天数: $days_left"

# 提前5天发送告警
if [[ $days_left -le 5 ]];then
curl -X POST "${bark_url}/阿里云SSL证书即将过期/剩余天数${days_left}"
fi


# 定时任务
0 9 * * * /data/script/check_ssl.sh >> /tmp/check_ssl.log 2>&1
```
也可以通过浏览器或任何支持发送 HTTP 请求的工具，向 `http://你的服务器IP:端口/你的设备ID/消息标题` 发送 POST 请求。
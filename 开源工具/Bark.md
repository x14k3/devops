
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
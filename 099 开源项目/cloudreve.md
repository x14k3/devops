# cloudreve

　　Cloudreve是一款免费开源的网盘系统， 支持腾讯云COS、本机、OneDrive等作为存储端，支持上传/下载，支持客户端直传，支持下载限速，可对接Aria2实现离线下载，支持在线压缩/解压、多文件打包下载。Cloudreve同时也支持多用户注册和使用，视频、图像、音频、文本、Office 文档在线预览。覆盖全部存储策略的 WebDAV 协议支持，将网盘映射到本地管理。

　　下载地址：[https://github.com/cloudreve/Cloudreve](https://github.com/cloudreve/Cloudreve)

　　✨ 特性

- ☁️ 支持本机、从机、七牛、阿里云 OSS、腾讯云 COS、又拍云、OneDrive (包括世纪互联版) 作为存储端
- 上传/下载 支持客户端直传，支持下载限速
- 可对接 Aria2 离线下载 [aria2](aria2.md)
- 在线 压缩/解压缩、多文件打包下载
- 覆盖全部存储策略的 WebDAV 协议支持
- ⚡ 拖拽上传、目录上传、流式上传处理
- 文件拖拽管理
- 多用户、用户组
- 创建文件、目录的分享链接，可设定自动过期
- 视频、图像、音频、文本、Office 文档在线预览
- 自定义配色、黑暗模式、PWA 应用、全站单页应用
- All-In-One 打包，开箱即用

## Cloudreve 搭建

```bash
#解压获取到的主程序
wget https://github.com/cloudreve/Cloudreve/releases/download/3.8.3/cloudreve_3.8.3_linux_amd64.tar.gz
tar xvf cloudreve_3.8.3_linux_amd64.tar.gz

# 启动 Cloudreve
./cloudreve

#你也可以在启动时加入-c参数指定配置文件路径：
./cloudreve -c /path/to/conf.ini
```

　　进程守护

　　​`vim /usr/lib/systemd/system/cloudreve.service`​

```ini
[Unit]
Description=Cloudreve
Documentation=https://docs.cloudreve.org
After=network.target
After=mysqld.service
Wants=network.target

[Service]
WorkingDirectory=/PATH_TO_CLOUDREVE
ExecStart=/PATH_TO_CLOUDREVE/cloudreve
Restart=on-abnormal
RestartSec=5s
KillMode=mixed

StandardOutput=null
StandardError=syslog

[Install]
WantedBy=multi-user.target
```

　　反向代理

```ini
location / {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:5212;

    # 如果您要使用本地存储策略，请将下一行注释符删除，并更改大小为理论最大文件尺寸
    # client_max_body_size 20000m;
}
```

## 配置文件

```ini
[System]
; 运行模式
Mode = master
; 监听端口
Listen = :5212
; 是否开启 Debug
Debug = false
; Session 密钥, 一般在首次启动时自动生成
SessionSecret = 23333
; Hash 加盐, 一般在首次启动时自动生成
HashIDSalt = something really hard to guss
; 呈递客户端 IP 时使用的 Header
ProxyHeader = X-Forwarded-For

; SSL 相关
[SSL]
; SSL 监听端口
Listen = :443
; 证书路径
CertPath = C:\Users\i\Documents\fullchain.pem
; 私钥路径
KeyPath = C:\Users\i\Documents\privkey.pem

; 启用 Unix Socket 监听
[UnixSocket]
Listen = /run/cloudreve/cloudreve.sock
; 设置产生的 socket 文件的权限
Perm = 0666

; 数据库相关，如果你只想使用内置的 SQLite 数据库，这一部分直接删去即可
[Database]
; 数据库类型，目前支持 sqlite/mysql/mssql/postgres
Type = mysql
; MySQL 端口
Port = 3306
; 用户名
User = root
; 密码
Password = root
; 数据库地址
Host = 127.0.0.1
; 数据库名称
Name = v3
; 数据表前缀
TablePrefix = cd_
; 字符集
Charset = utf8mb4
; SQLite 数据库文件路径
DBFile = cloudreve.db
; 进程退出前安全关闭数据库连接的缓冲时间
GracePeriod = 30
; 使用 Unix Socket 连接到数据库
UnixSocket = false

; 从机模式下的配置
[Slave]
; 通信密钥
Secret = 1234567891234567123456789123456712345678912345671234567891234567
; 回调请求超时时间 (s)
CallbackTimeout = 20
; 签名有效期
SignatureTTL = 60

; 跨域配置
[CORS]
AllowOrigins = *
AllowMethods = OPTIONS,GET,POST
AllowHeaders = *
AllowCredentials = false
SameSite = Default
Secure = lse

; Redis 相关
[Redis]
Server = 127.0.0.1:6379
Password =
DB = 0

; 从机配置覆盖
[OptionOverwrite]
; 可直接使用 `设置名称 = 值` 的格式覆盖
max_worker_num = 50
```

## OnlyOffice

　　OnlyOffice 在 6.4 版本后支持了 WOPI 协议，请参考 官方文档 部署你的 [OnlyOffice](https://helpcenter.onlyoffice.com/) 实例。推荐使用 [Docker-DocumentServer](https://github.com/ONLYOFFICE/Docker-DocumentServer) 来快速部署。

　　参考 [官方文档](https://helpcenter.onlyoffice.com/installation/docs-developer-configuring.aspx#WOPI) 配置 OnlyOffice 开启 WOPI 功能。如果使用 Docker，可在创建 Contianer 时指定 `WOPI_ENABLED`​ 为 `true`​ 来开启：

```
docker pull onlyoffice/documentserver
docker run -i -t -d -p 8080:80 -e WOPI_ENABLED=true onlyoffice/documentserver
```

　　你可以手动访问 `<你的 OnlyOffice 主机>/hosting/discovery`​ 来确认是否返回了预期的 XML 响应。

　　在 后台 - 参数设置 - 图像与预览 - 文件预览 - WOPI 客户端 中开启 `使用 WOPI`​ 并在 `WOPI Discovery Endpoint`​ 中填入`<你的服务主机>/hosting/discovery`​。保存后可在前台测试文档预览和编辑。

　　‍

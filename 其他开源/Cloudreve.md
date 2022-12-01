#openSource

Cloudreve是一款免费开源的网盘系统， 支持腾讯云COS、本机、OneDrive等作为存储端，支持上传/下载，支持客户端直传，支持下载限速，可对接Aria2实现离线下载，支持在线压缩/解压、多文件打包下载。Cloudreve同时也支持多用户注册和使用，视频、图像、音频、文本、Office 文档在线预览。覆盖全部存储策略的 WebDAV 协议支持，将网盘映射到本地管理。

下载地址：https://github.com/cloudreve/Cloudreve

## ✨ 特性

-   ☁️ 支持本机、从机、七牛、阿里云 OSS、腾讯云 COS、又拍云、OneDrive (包括世纪互联版) 作为存储端
-   上传/下载 支持客户端直传，支持下载限速
-   可对接 Aria2 离线下载
-   在线 压缩/解压缩、多文件打包下载
-   覆盖全部存储策略的 WebDAV 协议支持
-   ⚡ 拖拽上传、目录上传、流式上传处理
-   ️ 文件拖拽管理
-   ‍ ‍ 多用户、用户组
-   创建文件、目录的分享链接，可设定自动过期
-   ️‍ ️ 视频、图像、音频、文本、Office 文档在线预览
-   自定义配色、黑暗模式、PWA 应用、全站单页应用
-   All-In-One 打包，开箱即用
-   ... ...


## Cloudreve 搭建教程
```bash
# 创建相应的网盘目录
mkdir /data/cloudreve
tar -zxvf  xxx.tar.gz -C /data/cloudreve
cd /data/cloudreve
chmod +x ./cloudreve
./cloudreve
------------------------------------------

   ___ _                 _                    
  / __\ | ___  _   _  __| |_ __ _____   _____ 
 / /  | |/ _ \| | | |/ _  | '__/ _ \ \ / / _ \
/ /___| | (_) | |_| | (_| | | |  __/\ V /  __/
\____/|_|\___/ \__,_|\__,_|_|  \___| \_/ \___|

   V3.5.3  Commit #0e5683b  Pro=false
------------------------------------------

[Info]    2022-10-04 21:05:12 初始化数据库连接
[Info]    2022-10-04 21:05:12 开始进行数据库初始化...
[Info]    2022-10-04 21:05:12 初始管理员账号：admin@cloudreve.org
[Info]    2022-10-04 21:05:12 初始管理员密码：VQSELmpr
[Info]    2022-10-04 21:05:12 开始执行数据库脚本 [UpgradeTo3.4.0]
[Info]    2022-10-04 21:05:12 数据库初始化结束
[Info]    2022-10-04 21:05:12 初始化任务队列，WorkerNum = 10
[Info]    2022-10-04 21:05:12 初始化定时任务...
[Info]    2022-10-04 21:05:12 当前运行模式：Master
[Info]    2022-10-04 21:05:12 开始监听 :5212
```

记住相应的账号和密码，这样的话就可以使用云盘了

但是服务还是无法在后台运行，这时需要相应的进程守护配置

```bash
# 编辑配置文件
vim /usr/lib/systemd/system/cloudreve.service
#进入后更换为程序所在目录
[Unit]
Description=Cloudreve
Documentation=https://docs.cloudreve.org
After=network.target
After=mysqld.service
Wants=network.target
 
[Service]
WorkingDirectory=/data/cloudreve
StandardOutput=/data/cloudreve/cloudreve.log
ExecStart=/data/cloudreve/cloudreve
Restart=on-abnormal
RestartSec=5s
KillMode=mixed
 
StandardOutput=null
StandardError=syslog
 
[Install]
WantedBy=multi-user.target

# 更新配置
systemctl daemon-reload
# 启动服务
systemctl start cloudreve
# 设置开机启动
systemctl enable cloudreve
# 查看状态
systemctl status cloudreve
# 如果后续出现中断了重启一下
systemctl restart cloudreve
```

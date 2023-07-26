# Cloudreve

Cloudreve是一款免费开源的网盘系统， 支持腾讯云COS、本机、OneDrive等作为存储端，支持上传/下载，支持客户端直传，支持下载限速，可对接Aria2实现离线下载，支持在线压缩/解压、多文件打包下载。Cloudreve同时也支持多用户注册和使用，视频、图像、音频、文本、Office 文档在线预览。覆盖全部存储策略的 WebDAV 协议支持，将网盘映射到本地管理。

下载地址：https://github.com/cloudreve/Cloudreve

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
# 创建相应的网盘目录
mkdir /data/cloudreve
tar -zxvf  xxx.tar.gz -C /data/cloudreve
cd /data/cloudreve
chmod +x ./cloudreve
# 后台启动，在日志中会生成登录的用户名和默认密码
nohup ./cloudreve  >> ./cloudreve.log 2>&1 &
```

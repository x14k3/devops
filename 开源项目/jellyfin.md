
#openSource 

Jellyfin是一个自由软件媒体系统，可让您控制媒体的管理和流媒体。它是专有的Emby和Plex的替代品，可通过多个应用程序从专用服务器向终端用户设备提供媒体。Jellyfin是Emby 3.5.2版本的后代，移植到 .NET Core框架以支持完整的跨平台支持。没有任何附加条件，只是一个团队想要更好地构建更好的东西并共同努力实现它，致力于让所有用户都能访问最好的媒体系统。

## jellyfin部署

使用docker部署

```bash
# 拉取镜像
docker pull jellyfin/jellyfin
# 新建Jellyfin文件目录（/data/jellyfin 可修改为挂载的硬盘）
mkdir /data/jellyfin 

docker run -d -p 8096:8096 -v /data/jellyfin/config:/config -v /data/jellyfin/media:/media jellyfin/jellyfin
```
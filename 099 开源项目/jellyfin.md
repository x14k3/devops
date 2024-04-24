# jellyfin

随着家庭NAS的普及，NAS除了储存个人照片和视频外，电影和电视剧之类的影音存储已经然成为个人NAS中的大头。对于少量的影音文件的管理，传统的Windows资源管理器就可以胜任，但影音的数量达到一个数量及，传统的管理和使用方式来绝对是个灾难。而随着各种智能终端，尤其是智能移动终端的普及，人们对于不限时间和地点的观影需求及迫切。因此家庭媒体服务器就应运而生。

说了一堆废话，现在进入正题。目前市面上比较主流的家庭媒体服务器的选择主要有三个，Plex、Emby和Jellyfin。其中前两款对于基本使用免费，但对于像通过显卡硬件解码等功能是需付费订阅才能使用。而Jellyfin作为Emby分支的一个影音服务软件，则是完全开源和免费。如果只是简单的在家庭局域网中使用，而且终端的播放设备已经具有强大的解码能力，那么这三款软件都可以使用，可以根据三款软件的特点自行选择。如果像笔者我，需要在外出时，利用空余时间看家中存存储的视频，又或者使用的终端又是一个老掉牙的Ipad Mini4，同时又是口袋憋憋，囊中羞涩之徒，那Jellyfin是最佳的选择。

本文的安装主要是基于X86/AMD64平台，ArchLinux或群晖NAS环境下的安装。

## 1、安装前准备

可能有人会为问，为什么不在Linux下直接安装/编译Jellyfin，而要在Docker下安装？由于国内网络环境的影响在本地安装/编辑 Jellyfin 时，很多依赖包都无法链接和下载，导致安装失败，所以Docker下安装也算是省时，省心和省力的方式。

### 1.2 Docker的安装

docker 部署

​​

## 2、Jellyfin Docer 版本安装

### 2.1 版本的选择

目前在官方的 Docker 仓库里，有三个主流的Jellyfin的容器，分别是 jellyfin/jellyfin、linuxserver/jellyfin和nyanmisaka/jellyfin。

* jellyfin/jellyfin 为官方镜像，貌似仅限 x86/amd64 平台；
* linuxserver/jellyfin 镜像，根据说明，可以使用在 x86/amd64 平台上，也可以使用在 ARM 的平台上;
* nyanmisaka/jellyfin 的镜像，也是只能用在x86/amd64平台上，但该镜像集成了显卡驱动和字体，可直接使用，无需配置，可以直接跳到 Jellyfin 系统设置章节；

### 2.2 镜像下载

jellyfin/jellyfin 官方镜像下载：

```bash
$ sudo docker pull jellyfin/jellyfin:latest
```

linuxserver/jellyfin 镜像下载：

```bash
$ sudo docker pull linuxserver/jellyfin:latest
```

nyanmisaka/jellyfin 即插即用镜像下载：

```bash
$ sudo docker pull nyanmisaka/jellyfin:latest
```

### 2.3 容器的创建与启动

2.3.1 应用程序必要文件夹的准备：

在创建与启动 Jellyfin 容器前，先要在 Linux 系统下创建两个文件夹，分别用于保存配置文件，应用程序缓存，定位一个媒体库文件夹，假设你的媒体库文件夹在  */media* 文件中。

```bash
# 在系统根目录下创建 /data/jellyfin 文件夹，并在 /data/jellyfin文件夹下再创建 config 和 cache 两个三级文件夹 
$ sudo mkdir -p /data/jellyfin/{config,cache}
```

2.3.2 创建与启动Jellyfin容器：

```bash
docker run -d --name jellyfin \
-e PUID=1000 -e PGID=1000 -e TZ=Asia/Shanghai \
--net=host \
-p 8096:8096 \
-v /data/application/jellyfin/config:/config \
-v /data/application/jellyfin/cache:/cache \
-v /data/media:/media \
--device=/dev/dri:/dev/dri \
--add-host=api.themoviedb.org:13.224.161.90 \
--add-host=api.themoviedb.org:13.35.8.65 \
--add-host=api.themoviedb.org:13.35.8.93 \
--add-host=api.themoviedb.org:13.35.8.6 \
--add-host=api.themoviedb.org:13.35.8.54 \
--add-host=image.tmdb.org:138.199.37.230 \
--add-host=image.tmdb.org:108.138.246.49 \
--add-host=api.thetvdb.org:13.225.89.239 \
--add-host=api.thetvdb.org:192.241.234.54 \
--restart unless-stopped nyanmisaka/jellyfin:latest 
```

端口说明：

|端口号|用途|可选项|
| --------| ------------------------------------| --------|
|8096|默认http端口号|必须|
|8920|默认https端口号|可选|
|7359|让同一局域网中的客户端设备自动发现|可选|
|1900|DLNA的端口|可选|

2.3.3 确认容器：

```bash
$ sudo docker ps -l 
#查看最后一个创建和启动的容器 #或者 
$ sudo docker ps 
#查看所有正在运行的容器
```

### 2.4 系统环境调试

‍

```bash
#进入 Jellyfin 的 Bash 模式：
docker exec -it Jellyfin /bin/bash

# 更新容器内 debain 仓库信息
apt update 
# 字体安装
apt install fonts-noto-cjk-extra
# Intel核心显卡直通确认与驱动安装
#显卡直通确认 
ls /dev/dri
#驱动安装 
apt install intel-media-va-driver 
#解码支持确认 
/usr/lib/jellyfin-ffmpeg/vainfo
```

​​​​

PS：VAProfile输出的多少，视显卡而定，示例机的CPU是J4125，显卡是UHD600。

都确认没问题后，系统的环境设置就已经完成，可以输入 ***exit*** 命令退出配置环境。

## 3、启动并初始化Jellyfin

Jellyfin的容器已经在Docker里创建、启动和调试好了，接下来可以打开浏览器，输入Jellyfin服务器地址加端口号打开Jellyfin的页面，比如 [http://xxx.xxx.xxx.xxx:8096](https://link.zhihu.com/?target=http%3A//xxx.xxx.xxx.xxx%3A8096) 。

启动后可以根据提示进行设置，媒体库设置可以先跳过，然后一路下一步即可。

### 3.1 媒体库设置

菜单中选择“控制台”- 再选择 ”媒体库“：

右侧点击“添加媒体库”，然后根据提示完成媒体库的添加。​​

* 内容类型：电影内容选“电影”；电视剧选“节目”；
* 显示名称：自定义：
* 点击 “文件夹” 旁边的加号，分别添加电影或电视剧内容所在的文件夹；
* 首选语言选择“Chinese”，国家/地区选择“People's Republic of China”;
* 元数据下载器里：只保留“TheMovieDb”；
* 图片获取程序：只保留 “TheMovieDb”；
* 没提到的，则根据情况自行选择；

全部设置完点“确定”，之后系统便会自动生成电影和电视剧的海报列表，完成的速度和你使用的网络环境相关。

### 3.2 网络设置：

* 打开“控的制台”，在“高级”里选择“联网”；
* 设置“监听的本地网络地址”，设为 Jellyfin 服务器所在的网址；
* 设置“LAN网络”，设置为你的局域网地址，比如：192.168.1.0/255.255.255.0，如果有多个局域网网段，则用“逗号”隔开；
* 最后点”确定“完成网络配置。

### 3.3 视频硬解设置：

* 打开”控制台“，在”服务器“里选择”播放“；
* 硬件加速这里：下拉选择”Video Acceleartion API(VAAP)“或者”Intel QuickSync(QSV)“，不是太老的CPU/显卡，建议选QSV；
* 启用硬件解码：根据显卡支持的解码进行选择，Intel J3455及以上的CPU，即UHD500及以上的显卡可以全选；
* 首选系统原生DXVA或VA-API硬件解码器：不选；
* 硬件编码选项：只选择“启用硬件编码”，“启用VPP色调映射，没有提到的均不选；
* 最后根据实际情况选中”允许实时提取字幕“和”限制转码速度“；
* 没有提到的选择项均不选，其他参数均使用默认值；
* 最后确定完成设置。

注意，千万不要选择”启用色调映射“，这是个坑，选中后，很多HEVC/HDR的片子在播放时会报错，提示没有合适的容器，最终无法播放。

‍

## 4、电视直播配置

### 4.1 m3u 文件

[https://github.com/fanmingming/live/blob/main/tv/m3u/ipv6.m3u](https://github.com/fanmingming/live/blob/main/tv/m3u/ipv6.m3u)

注意使用iptv6需要设置光猫和路由器设置ipv6，docker-jellyfin 使用`docker run --net=host`​参数

确认开启ipv6测试地址：[http://test-ipv6.com/](ipv6测试网址)

### 4.2 XMLTV 文件

[https://epg.112114.xyz/pp.xml](http://epg.51zmt.top:8000/e.xml)

http://epg.51zmt.top:8000/e.xml

‍

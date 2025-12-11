

## 1、安装前准备

[docker 部署](../docker/docker%20部署.md)


## 2、Jellyfin Docer 版本安装

### 2.1 版本的选择

目前在官方的 Docker 仓库里，有三个主流的Jellyfin的容器，分别是 jellyfin/jellyfin、linuxserver/jellyfin和nyanmisaka/jellyfin。

- jellyfin/jellyfin 为官方镜像，貌似仅限 x86/amd64 平台；
- linuxserver/jellyfin 镜像，根据说明，可以使用在 x86/amd64 平台上，也可以使用在 ARM 的平台上;
- nyanmisaka/jellyfin 的镜像，也是只能用在x86/amd64平台上，但该镜像集成了显卡驱动和字体，可直接使用，无需配置，可以直接跳到 Jellyfin 系统设置章节；

### 2.2 镜像下载

```bash
# jellyfin/jellyfin 官方镜像下载
docker pull jellyfin/jellyfin:latest
# linuxserver/jellyfin 镜像下载
docker pull linuxserver/jellyfin:latest
# nyanmisaka/jellyfin 即插即用镜像下载
docker pull nyanmisaka/jellyfin:latest
```

### 2.3 容器的创建与启动

```bash
#  应用程序必要文件夹的准备
mkdir -p /data/jellyfin/{config,cache}
# 创建与启动Jellyfin容器
docker run -d --name jellyfin -e PUID=1000 -e PGID=1000 \
-e TZ=Asia/Shanghai --net=host \
-v /data/application/jellyfin/config:/config \
-v /data/application/jellyfin/cache:/cache \
-v /mnt/backup_OptiPlex3000/media:/media \
--device=/dev/dri:/dev/dri  \
--restart unless-stopped jellyfin/jellyfin:latest
```

|端口号|用途|可选项|
| --------| ------------------------------------| --------|
|8096|默认http端口号|必须|
|8920|默认https端口号|可选|
|7359|让同一局域网中的客户端设备自动发现|可选|
|1900|DLNA的端口|可选|

### 2.4 系统环境调试

```bash
#进入 Jellyfin 的 Bash 模式：
docker exec -it Jellyfin /bin/bash
# 更新容器内 debain 仓库信息
apt update 
# 字体安装
apt install fonts-noto-cjk-extra
# Intel核心显卡直通确认与驱动安装
# 显卡直通确认 
ls /dev/dri
# 驱动安装 
apt install intel-media-va-driver 
# 解码支持确认 
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

- 内容类型：电影内容选“电影”；电视剧选“节目”；
- 显示名称：自定义：
- 点击 “文件夹” 旁边的加号，分别添加电影或电视剧内容所在的文件夹；
- 首选语言选择“Chinese”，国家/地区选择“People's Republic of China”;
- 元数据下载器里：只保留“TheMovieDb”；
- 图片获取程序：只保留 “TheMovieDb”；
- 没提到的，则根据情况自行选择；

全部设置完点“确定”，之后系统便会自动生成电影和电视剧的海报列表，完成的速度和你使用的网络环境相关。

### 3.2 视频硬解设置

- 打开”控制台“，在”服务器“里选择”播放“；
- 硬件加速这里：下拉选择”Video Acceleartion API(VAAP)“或者”Intel QuickSync(QSV)“，不是太老的CPU/显卡，建议选QSV；
- 启用硬件解码：根据显卡支持的解码进行选择，Intel J3455及以上的CPU，即UHD500及以上的显卡可以全选；
- 首选系统原生DXVA或VA-API硬件解码器：不选；
- 硬件编码选项：只选择“启用硬件编码”，“启用VPP色调映射，没有提到的均不选；
- 最后根据实际情况选中”允许实时提取字幕“和”限制转码速度“；
- 没有提到的选择项均不选，其他参数均使用默认值；
- 最后确定完成设置。

注意，千万不要选择”启用色调映射“，这是个坑，选中后，很多HEVC/HDR的片子在播放时会报错，提示没有合适的容器，最终无法播放。


### 3.3 metashark 刮削器配置

#### 插件安装

1. 进入 Jellyfin 控制台 > 插件 > 存储库，点击添加
2. 新版 Jellyfin 控制台 > 插件 > 目录 > 设置图标 > 点击加号图标
3. 输入存储库名称：metashark
4. 输入存储库URL：`https://github.com/cxfksword/jellyfin-plugin-metashark/releases/download/manifest/manifest.json`
5. 在插件目录元数据类别下找到 metashark，点击安装
6. 重启 Jellyfin
7. 进入控制台 -> 我的插件，确认 metashark 插件的状态为 Active，点击进入设置界面


#### 如何使用

上述操作完成后，就可以来刮削影片了。

1. 创建媒体库，选择电影类型，选择影片所在文件夹。
2. 配置媒体库，勾选 metashark 作为元数据下载器 (电影)， 注意只勾选这一个即可。
3. 图片获取程序也只选择 metashark，然后勾选 “将媒体图像保存到媒体所在文件夹”
4. 扫描媒体库 - 刷新元数据，即可开始刮削，不出意外，刮削完成后会自动显示封面和影片信息。
5. 可以设置成 “启用实时监控”，不需要手动刷新，有的实在扫描不出来的可以手动选择识别，填写影片号码后查找。




### 3.4 metabute 刮削器配置

#### 插件安装

1. 进入 Jellyfin 控制台 > 插件 > 存储库，点击添加
2. 新版 Jellyfin 控制台 > 插件 > 目录 > 设置图标 > 点击加号图标
3. 输入存储库名称：MetaTube
4. 输入存储库URL：`https://raw.githubusercontent.com/metatube-community/jellyfin-plugin-metatube/dist/manifest.json`
5. 在插件目录元数据类别下找到 MetaTube，点击安装
6. 重启 Jellyfin
7. 进入控制台 -> 我的插件，确认 Metatube 插件的状态为 Active，点击进入设置界面

适用于中国的存储库URL：`https://cdn.jsdelivr.net/gh/metatube-community/jellyfin-plugin-metatube@dist/manifest.json`（可能有缓存）

#### 后端服务安装

为什么需要安装 Metatube 后端服务？

因为 jellyfin 需要通过后端来刮削数据，metatube 作为刮削源，jellyfin 把影片名称等信息交给 metatube后端去刮削，metatube后端根据代号去不同的数据站获取数据，jellyfin 拿到元数据后保存到本地或者影片文件夹中。

后端使用go语言编写，部署比较方便，有多种方式。有一定动手能力的可以选择自己部署，也可以选择部署免费的云服务。

```bash
# 二进制运行
wget https://github.com/metatube-community/metatube-server-releases/releases/download/v1.3.1/metatube-server-linux-amd64.zip

./metatube-server-linux-amd64

# docker 方式部署
docker run -d --name metatube -p 8097:8080 -v /data/application/jellyfin/metatube/config:/config ghcr.io/metatube-community/metatube-server:latest -dsn /config/metatube.db

```

然后通过浏览器访问 http://192.168.3.100:8097 输出以下信息

```json
{"data":{"app":"metatube","version":"v1.3.2-f2bbaee"}}
```

或者使用curl验证

```powerShell
curl http://192.168.3.100:8097 

{"data":{"app":"metatube","version":"v1.3.2-f2bbaee"}}
```

注意这个服务需要一直运行，刮削时会持续输出日志，关闭后无法刮削，所以最好配置开机启动和后台运行。


#### 配置插件

安装好插件和后端服务后，进入插件设置界面，配置服务端地址(http://192.168.3.100:8097) 和 Token，Token 相当于密钥，如果在部署的时候配置了 Token，在插件里一定要配置 Token，否则会因为校验失败无法使用。

[[开源工具/assets/46b69b4f0c5ed498d893084eedd8e2cf_MD5.jpg|Open: Pasted image 20251211125958.png]]
![[开源工具/assets/46b69b4f0c5ed498d893084eedd8e2cf_MD5.jpg|600]]


#### 如何使用

上述操作完成后，就可以来刮削影片了。

1. 创建媒体库，选择电影类型，选择影片所在文件夹。
2. 配置媒体库，勾选 Metatube 作为元数据下载器 (电影)， 注意只勾选这一个即可。
3. 图片获取程序也只选择 Metatube，然后勾选 “将媒体图像保存到媒体所在文件夹”
4. 扫描媒体库 - 刷新元数据，即可开始刮削，不出意外，刮削完成后会自动显示封面和影片信息。
5. 可以设置成 “启用实时监控”，不需要手动刷新，有的实在扫描不出来的可以手动选择识别，填写影片号码后查找。


## 4、电视直播配置

### 4.1 m3u 文件

[https://github.com/fanmingming/live/blob/main/tv/m3u/ipv6.m3u](https://github.com/fanmingming/live/blob/main/tv/m3u/ipv6.m3u)
```bash
curl -O https://raw.githubusercontent.com/fanmingming/live/refs/heads/main/tv/m3u/ipv6.m3u
#curl -O https://raw.githubusercontent.com/imDazui/Tvlist-awesome-m3u-m3u8/master/m3u/移动IPV6IPTV直播源.m3u
```
注意使用iptv6需要设置光猫和路由器设置ipv6，docker-jellyfin 使用`docker run --net=host`​参数

确认开启ipv6测试地址：[http://test-ipv6.com/](ipv6测试网址)

### 4.2 XMLTV 文件

[https://epg.112114.xyz/pp.xml](http://epg.51zmt.top:8000/e.xml)

http://epg.51zmt.top:8000/e.xml

‍

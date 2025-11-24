
[Navidrome](https://github.com/navidrome/navidrome/)🎧☁️ 与 Subsonic/Airsonic 兼容的现代音乐服务器和串流器。
Navidrome 是一款基于网络的开源音乐收藏服务器和流媒体。它让您可以通过任何浏览器或移动设备自由收听您收藏的音乐。它就像你的个人 Spotify！

## 特点[#](https://bytejog.com/posts/linux/navidrome/#%E7%89%B9%E7%82%B9)

- 处理超大音乐收藏
- 几乎可串流任何音频格式
- 读取并使用所有精心策划的元数据
- 对合集（Various Artists 专辑）和盒装（多碟专辑）的强大支持
- 多用户，每个用户都有自己的播放次数、播放列表、收藏夹等。
- 资源使用率极低
- 多平台，可在 macOS、Linux 和 Windows 上运行。还提供 Docker 映像
- 所有主要平台（包括 Raspberry Pi）的二进制文件均可随时使用
- 自动监控资料库变化，导入新文件并重新加载新元数据
- 基于 Material UI 的可主题化、现代化和响应式网络界面
- 与所有 Subsonic/Madsonic/Airsonic 客户端兼容
- 即时转码可按用户/播放器设置。支持 Opus 编码
- 翻译成各种语言


## 创建docker文件[#](https://bytejog.com/posts/linux/navidrome/#%E5%88%9B%E5%BB%BAdocker%E6%96%87%E4%BB%B6)

采用Docker形式安装服务，准备工作是安装docker服务，参考[Install using the apt repository](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
Navidrome的主目录假定在`/opt/navidrome`, 创建docker compose文件

```bash
cd /opt/navidrome
vim docker-compose.yml
```

`docker-compose.yml`内容

```dockerfile
version: "3"
services:
  navidrome:
    image: deluan/navidrome:develop
    ports:
      - "14533:4533"
    restart: unless-stopped
    environment:
      ND_SCANSCHEDULE: 0
      ND_LOGLEVEL: info
      ND_SESSIONTIMEOUT: 24h
      ND_BASEURL: "/nav"
      ND_PLAYLISTSPATH: "."
      ND_LASTFM_LANGUAGE: "zh"
      ND_LASTFM_APIKEY: "lastfm_apikey"
      ND_LASTFM_SECRET: "lastfm_secret"
      ND_SPOTIFY_ID: "spotify_id"
      ND_SPOTIFY_SECRET: "spotify_secret"
      ND_ENABLEARTWORKPRECACHE: "false"
      ND_ENABLESHARING: "true"
    volumes:
      - "/opt/navidrome/data:/data"
      - "/opt/navidrome/music:/music:ro"
```

Navidrome有很多参数[Advanced configuration](https://www.navidrome.org/docs/usage/configuration-options/#advanced-configuration)，使用熟悉了可以自己在环境变量里再增加配置。

| 参数名称 | 参数值 | 说明 |
| ---|---|--- |
| ND_SCANSCHEDULE | 0 | 设置为0不自动扫描，有变动了到网页里点击快速刷新就可以 |
| ND_LOGLEVEL | info | 输出日志格式 |
| ND_SESSIONTIMEOUT | 24h | 登录自动过期时间 |
| ND_BASEURL | /nav | 相对路径，通过nginx代理很有用，不暴露navidrome的端口，有一定的保护作用 |
| ND_PLAYLISTSPATH | . | 播放列表的相对路径，也就是在`/opt/navidrome/music` |
| ND_LASTFM_LANGUAGE | zh | LastFM配置为中文，配置三个参数，Navidrome 会自动去查询歌手的信息 |
| ND_LASTFM_APIKEY | lastfm_apikey | [Last.fm配置](https://www.navidrome.org/docs/usage/external-integrations/#lastfm) |
| ND_LASTFM_SECRET | lastfm_secret | [Last.fm配置](https://www.navidrome.org/docs/usage/external-integrations/#lastfm) |
| ND_SPOTIFY_ID | spotify_id | 查询Spotify上的歌手信息 |
| ND_SPOTIFY_SECRET | spotify_secret | [Spotify配置](https://www.navidrome.org/docs/usage/external-integrations/#spotify) |
| ND_ENABLEARTWORKPRECACHE | false | 不启用封面图片缓存，因为服务器资源紧张，就关闭了，推进设置为`true` |
| ND_ENABLESHARING | true | 启用分享功能，可以不登录就可以听歌 |

volumes映射说明：

- /opt/navidrome/data：navidrome运行时生成的数据库文件
- /opt/navidrome/music：上传音乐文件的目录，可以有多级目录，都会加载，不用担心

## 准备音乐文件[#](https://bytejog.com/posts/linux/navidrome/#%E5%87%86%E5%A4%87%E9%9F%B3%E4%B9%90%E6%96%87%E4%BB%B6)

将音乐文件上传到`/opt/navidrome/music`目录内容示意，按照个人喜好组织文件

```bash
music
├── 0
├── 1
├── 163-跑步音乐超燃歌曲180步频踩点节奏控必备单.m3u
├── 163-热歌榜.m3u
├── A
├── Apple-Top Songs.m3u
├── Q
├── QQ-热歌榜.m3u
├── R
├── S
├── Spotify-Running 180 BPM.m3u
├── Spotify-Weekly Top Songs Global.m3u
├── Spotify-Weekly Top Songs Hong Kong.m3u
├── T
├── U
├── V
├── W
├── X
├── Y
└── Z
```


歌曲播放列表文件内容示意(歌曲的位置是相对`/opt/navidrome/music`的位置)：
```bash
#EXTM3U

#EXTINF:181, Benson Boone - Beautiful Things
B/Benson Boone/Benson Boone - Beautiful Things.mp3
#EXTINF:229, Ariana Grande - we can't be friends (wait for your love)
A/Ariana Grande/Ariana Grande - we can't be friends (wait for your love).mp3
#EXTINF:159, Djo,Joe Keery - End of Beginning
D/Djo/Djo,Joe Keery - End of Beginning.mp3
#EXTINF:268, Metro Boomin,Future - Like That
M/Metro Boomin/Metro Boomin,Future - Like That.mp3
#EXTINF:265, ¥$,Kanye West,Ty Dolla $ign - CARNIVAL
0/¥$/¥$,Kanye West,Ty Dolla $ign - CARNIVAL.mp3
#EXTINF:211, Teddy Swims - Lose Control
T/Teddy Swims/Teddy Swims - Lose Control.mp3
#EXTINF:132, Tate McRae - greedy
T/Tate McRae/Tate McRae - greedy.mp3
#EXTINF:252, Hozier - Too Sweet
H/Hozier/Hozier - Too Sweet.mp3
复制
```


M3U格式参考[https://en.wikipedia.org/wiki/M3U](https://en.wikipedia.org/wiki/M3U)

## 启动Navidrome[#](https://bytejog.com/posts/linux/navidrome/#%E5%90%AF%E5%8A%A8navidrome)

```bash
cd /opt/navidrome
# 第一次启动
docker compose up -d

# 重启
docker compose stop
docker compose start

# 升级
docker compose down
docker compose pull
docker compose up -d

# 查看日志
docker compose logs -f docs-navidrome-1
```

## Nginx配置[#](https://bytejog.com/posts/linux/navidrome/#nginx%E9%85%8D%E7%BD%AE)

Nginx的服务配置请网络搜索

```nginx
location ^~ /nav/{
            proxy_pass  http://xxx.xxx.xxx.xxx:14533;
            proxy_buffering off;
            client_max_body_size    300m;
        }
```

## Navidrome使用[#](https://bytejog.com/posts/linux/navidrome/#navidrome%E4%BD%BF%E7%94%A8)

第一次需要浏览器访问，创建管理员账号和密码，后续进入系统就可以愉快的使用了。
可以用管理员账号创建其他账号，分享给其他人使用

也可以手机端使用，Navidrome提供Subsonic API，兼容的APP可以到官网查看[APPS](https://www.navidrome.org/docs/overview/#apps)

我是使用[Ultrasonic](https://ultrasonic.gitlab.io/)， 现在推荐使用[Tempo](https://github.com/CappielloAntonio/tempo)文末有链接。


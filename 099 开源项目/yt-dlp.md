# yt-dlp

　　YT-DLP 是一个免费且开源的软件项目，是基于已停止维护的 youtube-dlc 项目而创建的（作为其分支）。yt-dlp 基于流行的  YouTube 下载器 youtube-dlc，但现在具有额外的功能和改进。该软件主要用于从 YouTube、Vimeo  和其他类似网站下载视频。

## 安装yt-dlp

```bash
sudo apt install youtube-dl
```

## 下载视频

　　支持下载哪些网站，项目文档上也有：
[https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

　　我这里就有下载油管的视频举例。

　　比如我想下载这个视频：[https://www.youtube.com/watch?v=kNU2WCHVVBk](https://www.youtube.com/watch?v=kNU2WCHVVBk)
视频格式为：[https://www.youtube.com/watch?v=](https://www.youtube.com/watch?v=)\* ********

### 1.直接下载

```bash
# 默认格式，高于720P的格式一般是 webm 格式
yt-dlp https://www.youtube.com/watch?v=kNU2WCHVVBk

# 下载视频转换成mp4（用--merge-output-format参数）
yt-dlp --merge-output-format mp4 https://www.youtube.com/watch?v=kNU2WCHVVBk
```

### 2.查看视频所有分辨率

　　跟用 youtube-dl命令一样，先用`-F`​参数查看有哪些分辨率。

```bash
yt-dlp -F https://www.youtube.com/watch?v=kNU2WCHVVBk
```

```bash
home:/# yt-dlp --proxy socks5://127.0.0.1:10808 -F https://www.youtube.com/watch?v=0NXQ0HhmONA&list=PLOrf2h5ONlwUTW9etWK4b3xQiz8LdgkKS&index=16
[2] 120866
[3] 120867
home:/# [youtube] Extracting URL: https://www.youtube.com/watch?v=0NXQ0HhmONA
[youtube] 0NXQ0HhmONA: Downloading webpage
[youtube] 0NXQ0HhmONA: Downloading android player API JSON
ID  EXT   RESOLUTION FPS CH │   FILESIZE   TBR PROTO │ VCODEC          VBR ACODEC      ABR ASR MORE INFO
───────────────────────────────────────────────────────────────────────────────────────────────────────────────
sb3 mhtml 48x27        0    │                  mhtml │ images                                  storyboard
sb2 mhtml 80x45        0    │                  mhtml │ images                                  storyboard
sb1 mhtml 160x90       0    │                  mhtml │ images                                  storyboard
sb0 mhtml 320x180      0    │                  mhtml │ images                                  storyboard
140 m4a   audio only      2 │   41.67MiB  129k dash  │ audio only          mp4a.40.2  129k 44k medium, m4a_dash
394 mp4   256x144     25    │   22.59MiB   70k dash  │ av01.0.00M.08   70k video only          144p, mp4_dash
160 mp4   256x144     25    │   24.55MiB   76k dash  │ avc1.4d400c     76k video only          144p, mp4_dash
395 mp4   426x240     25    │   38.48MiB  120k dash  │ av01.0.00M.08  120k video only          240p, mp4_dash
396 mp4   640x360     25    │   77.25MiB  240k dash  │ av01.0.01M.08  240k video only          360p, mp4_dash
134 mp4   640x360     25    │  107.89MiB  335k dash  │ avc1.4d401e    335k video only          360p, mp4_dash
18  mp4   640x360     25  2 │ ~152.82MiB  464k https │ avc1.42001E    464k mp4a.40.2    0k 44k 360p
397 mp4   854x480     25    │  138.18MiB  429k dash  │ av01.0.04M.08  429k video only          480p, mp4_dash
22  mp4   1280x720    25  2 │ ~484.63MiB 1470k https │ avc1.64001F   1470k mp4a.40.2    0k 44k 720p
398 mp4   1280x720    25    │  273.82MiB  851k dash  │ av01.0.05M.08  851k video only          720p, mp4_dash
136 mp4   1280x720    25    │  431.91MiB 1342k dash  │ avc1.64001f   1342k video only          720p, mp4_dash
399 mp4   1920x1080   25    │  531.07MiB 1650k dash  │ av01.0.08M.08 1650k video only          1080p, mp4_dash
137 mp4   1920x1080   25    │  848.46MiB 2636k dash  │ avc1.640028   2636k video only          1080p, mp4_dash
WARNING: [youtube] Unable to download webpage: <urlopen error timed out>
[youtube] 0NXQ0HhmONA: Downloading android player API JSON
home:/# 
```

　　结果跟用 youtube-dl命令的差不多，标题行含义： > ID：文件ID > EXT：格式 > RESOLUTION：分辨率 > FPS：视频的帧率 > FILESIZE：文件大小 > VCODEC：audio only表示仅音频 > ACODEC：video only表示仅视频（没有音频）；像mp4a.40.2（720p）就直接包含了音频

　　‍

### 3.下载指定分辨率

```bash
# 1.只下载音频
# 找m4a格式，列表越靠后越清晰。比如ID：140 | EXT：m4a | audio only
yt-dlp -f140 https://www.youtube.com/watch?v=kNU2WCHVVBk

# 2.下载音频转换成mp3（加上-x --audio-format参数）
yt-dlp -f140 -x --audio-format mp3 https://www.youtube.com/watch?v=kNU2WCHVVBk

# 3.下载视频（带音频）ID：22 | EXT：mp4 | 1280*720
yt-dlp -f22 https://www.youtube.com/watch?v=kNU2WCHVVBk

# 4.下载指定分辨率视频+音频（为了方便就直接下载mp4格式了）
# 1080及以上分辨率的音频和视频是分开的，所以一般会音频和视频一起下载
yt-dlp -f299+140 https://www.youtube.com/watch?v=kNU2WCHVVBk

# 5.(通用）下载最佳mp4视频+最佳m4a音频格式并合成mp4
yt-dlp -f 'bv[ext=mp4]+ba[ext=m4a]' --embed-metadata --merge-output-format mp4 https://www.youtube.com/watch?v=kNU2WCHVVBk

# 6.指定文件名下载（用-o参数）
# 默认下载的文件格式是：title+空格+[id].格式，比如***** [kNU2WCHVVBk].mp4
# 文件名只要标题，不要id，加上 -o '%(title)s.mp4'
yt-dlp -f 'bv[ext=mp4]+ba[ext=m4a]' --embed-metadata --merge-output-format mp4 https://www.youtube.com/watch?v=kNU2WCHVVBk -o '%(title)s.mp4'
```

　　最方便直接用，可以直接用最后一种通用的下载最佳视频的方式。

```bash
yt-dlp -f 'bv[ext=mp4]+ba[ext=m4a]' --proxy socks5://127.0.0.1:10808 --output "%(title)s.%(ext)s" --embed-thumbnail --add-metadata --merge-output-format mp4 "https://www.youtube.com/watch?v=EMPtccgQhRY&t=8625s"

# --proxy使用代理
# 這裡使用--output "%(title)s.%(ext)s"讓輸出影片檔名能跟Youtube上的標題一致。
# 加上--merge-output-format mp4指定轉檔為mp4格式（也可以用mkv格式）。
# --embed-thumbnail加上縮圖
# --add-metadata加上影片資訊
# 最後面的引號" "填入影片網址，加引號的用意是防止特殊符號&干擾指令。
# 如果你想下載特定畫質影片，比方說1080p，那就加上-f "bestvideo[height<=1080]+bestaudio[ext=m4a]"的參數，指定影片最大高度。至於其他畫質，2160為4K，1080為1080p，720為720p，以此類推。
```

### 5.下载播放列表所有视频

```bash
播放列表一般url到有list关键字
#yt-dlp https://www.youtube.com/playlist?list=**********
#
yt-dlp -f 'bv[ext=mp4]+ba[ext=m4a]' --proxy socks5://127.0.0.1:10808 --output "%(playlist)s/%(title)s.%(ext)s" --embed-thumbnail --add-metadata --merge-output-format mp4 "https://www.youtube.com/watch?v=CTRvs6bW6CQ&list=PLOrf2h5ONlwUTW9etWK4b3xQiz8LdgkKS"

```

　　‍

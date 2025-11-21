
输入 `id 你的用户id` 获取到你的UID和GID，替换命令中的PUID、PGID

**执行命令**

```shell
docker run -d \
  --name=aria2 \
  -e PUID=1026 \
  -e PGID=100 \
  -e TZ=Asia/Shanghai \
  -e SECRET=yourtoken \
  -e CACHE=512M \
  -e PORT=6800 \
  -e BTPORT=32516 \
  -e WEBUI=true \
  -e WEBUI_PORT=8080 \
  -e UT=true \
  -e RUT=true \
  -e FA=falloc \
  -e QUIET=true \
  -e SMD=true \
  -p 32516:32516 \
  -p 32516:32516/udp \
  -p 6800:6800 \
  -p 8080:8080 \
  -v $PWD/config:/config \
  -v $PWD/downloads:/downloads \
  --restart unless-stopped \
  superng6/aria2:webui-latest
```

docker-compose

```yaml
version: "3.1"
services:
aria2:
  image: superng6/aria2:webui-latest
  container_name: aria2
  network_mode: host
  environment:
    - PUID=1026
    - PGID=100
    - TZ=Asia/Shanghai
    - SECRET=yourtoken
    - CACHE=512M
    - PORT=6800
    - WEBUI=true
    - WEBUI_PORT=8080
    - BTPORT=32516
    - UT=true
    - QUIET=true
    - SMD=true
  volumes:
    - $PWD/config:/config
    - $PWD/downloads:/downloads
  restart: unless-stopped   
```

### 自定义tracker地址

CTU="[https://cdn.jsdelivr.net/gh/XIU2/TrackersListCollection@master/best_aria2.txt](https://cdn.jsdelivr.net/gh/XIU2/TrackersListCollection@master/best_aria2.txt)"
### `/config/setting.conf` 配置说明(推荐使用)

推荐使用`setting.conf`进行本镜像附加功能选项设置

```bash
## docker aria2 功能设置 ##
# 配置文件为本项目的自定义设置选项
# 重置配置文件：删除本文件后重启容器
# 所有设置无需重启容器,即刻生效

# 删除任务，`delete`为删除任务后删除文件，`recycle`为删除文件至回收站，`rmaria`为只删除.aria2文件
remove-task=rmaria

# 下载完成后执行操作选项，默认`false`
# `true`，下载完成后保留目录结构移动
# `dmof`非自定义目录任务，单文件，不执行移动操作。自定义目录、单文件，保留目录结构移动（推荐）
move-task=false

# 文件过滤，任务下载完成后删除不需要的文件内容，`false`、`true`
# 由于aria2自身限制，无法在下载前取消不需要的文件（只能在任务完成后删除文件）
content-filter=false

# 下载完成后删除空文件夹，默认`true`，需要开启文件过滤功能才能生效
# 开启内容过滤后，可能会产生空文件夹，开启`DET`选项后可以删除当前任务中的空文件夹
delete-empty-dir=true

# 对磁力链接生成的种子文件进行操作
# 在开启`SMD`选项后生效，上传的种子无法更名、移动、删除，仅对通过磁力链接保存的种子生效
# 默认保留`retain`,可选删除`delete`，备份种子文件`backup`、重命名种子文件`rename`，重命名种子文件并备份`backup-rename`
# 种子备份位于`/config/backup-torrent`
handle-torrent=backup-rename

# 删除重复任务，检测已完成文件夹，如果有该任务文件，则删除任务，并删除文件，仅针对文件数量大于1的任务生效
# 默认`true`，可选`false`关闭该功能
remove-repeat-task=true

# 任务暂停后移动文件，部分任务下载至百分之99时无法下载，可以启动本选项
# 建议仅在需要时开启该功能，使用完后请记得关闭
# 默认`false`，可选`true`开启该功能
move-paused-task=false
```

### `/config/文件过滤.conf` 配置说明

```bash
## 文件过滤设置(全局) ##

# 仅 BT 多文件下载时有效，用于过滤无用文件。
# 可自定义；如需启用请删除对应行的注释 # 

# 排除小文件。低于此大小的文件将在下载完成后被删除。
#min-size=10M

# 保留文件类型。其它文件类型将在下载完成后被删除。
#include-file=mp4|mkv|rmvb|mov|avi|srt|ass

# 排除文件类型。排除的文件类型将在下载完成后被删除。
#exclude-file=html|url|lnk|txt|jpg|png

# 按关键词排除。包含以下关键字的文件将在下载完成后被删除。
#keyword-file=广告1|广告2|广告3

# 保留文件(正则表达式)。其它文件类型将在下载完成后被删除。
#include-file-regex=

# 排除文件(正则表达式)。排除的文件类型将在下载完成后被删除。
# 示例为排除比特彗星的 padding file
#exclude-file-regex="(.*/)_+(padding)(_*)(file)(.*)(_+)"
```

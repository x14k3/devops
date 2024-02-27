# aria2

## Aria2部署搭建

这里基于 `Ubuntu`​, 内置的 `apt`​ 源已经有该软件了, 直接安装配置就行:

```
# 安装配置软件
sudo apt install aria2

# 查看软件版本
aria2c --version
```

## 管理账号

这里需要创建新的 `Linux`​ 账号来托管下载权限, 并且设置主要配置文件夹:

```
# 创建账号
useradd -M -s /usr/sbin/nologin aria2

# 创建系统配置目录和赋予权限
mkdir /etc/aria2
chown -R aria2:aria2 /etc/aria2
```

## 系统服务

写入系统服务配置:

```
cat <<EOF >>/lib/systemd/system/aria2.service
[Unit]
Description=Aria2-Download Service
After=network.target

[Service]
User=aria2
Group=aria2
ExecStart=/usr/bin/aria2c --conf-path=/etc/aria2/aria2.conf
LimitNOFILE=10240

[Install]
WantedBy=default.target
EOF
```

完成之后就更新下系统服务即可:

```
systemctl daemon-reload 
```

### Aria2配置

这里创建 `Aria2`​ 配置文件来处理

```
# 以 aria2 权限创建对应配置文件
vim /etc/aria2/aria2.conf 
touch /etc/aria2/aria2.session
chown -R aria2:aria2 /etc/aria2/
```

内部配置内容:

```bash
##  文件保存相关 
## ============== ==============

# 文件保存目录
dir = /data/archive/downloads

# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=32M

# 启用断点续传
continue=true

# 始终尝试断点续传，无法断点续传则终止下载，默认：true
always-resume=false

# 获取服务器文件时间，默认:false
remote-time=true

# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
file-allocation=trunc

##  下载连接相关 
## ============== ==============

# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=8

# 同一服务器连接数, 添加时可指定, 默认:1
# 官方的aria2最高设置为16, 如果需要设置任意数值请重新编译aria2
max-connection-per-server=8

# 整体下载速度限制, 运行时可修改, 默认:0（不限制）
max-overall-download-limit=0

# 单个任务下载速度限制, 默认:0（不限制）
max-download-limit=0

# 整体上传速度限制, 运行时可修改, 默认:0（不限制）
max-overall-upload-limit=0

# 单个任务上传速度限制, 默认:0（不限制）
max-upload-limit=0

# 禁用IPv6, 默认:false
disable-ipv6=true

# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=20M

# 单个任务最大线程数, 添加时可指定, 默认:5
# 建议同max-connection-per-server设置为相同值
split=8

##  进度保存相关 
## ============== ==============

# 从会话文件中读取下载任务
input-file=/etc/aria2/aria2.session

# 在Aria2退出时保存错误的、未完成的下载任务到会话文件
save-session=/etc/aria2/aria2.session

# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=1

##  RPC相关设置 
## ============== ==============

# 启用RPC, 默认:false
enable-rpc=true

# 允许所有来源, 默认:false
rpc-allow-origin-all=true

# 允许外部访问, 默认:false
rpc-listen-all=true

# RPC端口, 仅当默认端口被占用时修改
rpc-listen-port=6800

# 事件轮询方式, 可选：epoll, kqueue, port, poll, select, 不同系统默认值不同
event-poll=epoll

# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
rpc-secret=meteorocat

##  BT/PT下载相关 
## ============== ==============

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
follow-torrent=true

# 启用节点交换, PT 下载(私有种子)会自动禁用, 默认:true
enable-peer-exchange=true

# IPv4 DHT 网络引导节点
dht-entry-point=dht.transmissionbt.com:6881

# IPv4 DHT 文件路径，默认：$HOME/.aria2/dht.dat
dht-file-path=/etc/aria2/dht.dat

# 启用 IPv6 DHT 功能, PT 下载(私有种子)会自动禁用，默认:false
# 在没有 IPv6 支持的环境开启可能会导致 DHT 功能异常
enable-dht6=false

# 客户端伪装, PT需要
peer-agent=Deluge 1.3.15
peer-id-prefix=-DE13F0-

# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
force-save=false

# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true

# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=true

# 单个种子最大连接数, 默认:55 0表示不限制
bt-max-peers=60

# 最小做种时间, 单位:分
seed-time = 60

# 分离做种任务
bt-detach-seed-only=true

# 强制加密, 防迅雷必备
bt-require-crypto=true

# 使用 UTF-8 处理 Content-Disposition ，默认:false
content-disposition-default-utf8=true

# 添加额外tracker, 这里是关键配置, 关系到下载速度
bt-tracker=
```

> 注意: `dir/input-file/save-session`​ 目录的权限必须是 `aria2`​ 所有.

这里 `bt-tracker`​ 后续会说明, 只需要完成并启动服务:

```
# 启动服务并开机启动
sudo systemctl start aria2.service
sudo systemctl enable aria2.service
```

### Aria2Web配置

这里完成需要UI界面来动态添加下载任务处理, 这里采用 [`AriaNg`](https://ariang.mayswind.net/zh_Hans/)​.

这里直接手动下载即可, 仅仅是作为 Web 页面:

```
# 进入临时目录并下载
cd /tmp
wget https://github.com/mayswind/AriaNg/releases/download/1.3.3/AriaNg-1.3.3-AllInOne.zip


# 创建目录解压到目录
sudo mkdir /data/aria2ng
cd /data/aria2ng
sudo unzip /tmp/AriaNg-1.3.3-AllInOne.zip
sudo chown -R www-data:www-data /data/aria2ng

# 创建 Nginx 服务文件
sudo vim /etc/nginx/conf.d/aria2ng.conf
```

Aria2的 Nginx 配置文件如下:

```
server {
    listen 80;
    server_name _;
    root /data/aria2ng;
    index index.html;
}
```

重写加载配置启动 `Nginx`​ 就能看到项目搭建完成, 按照说明 `系统配置 - AriaNG配置 - RPC`​ 之中填入服务地址和密钥就能加载到.

### 目录展示

这一步用于直接 Web 展示下载目录文件, 这样就不需要额外的应用来处理:

参考nginx配置：7.目录展示及文件访问

重启启动服务, 这样就搭建好自身的离线下载服务.

### Tracker源

常见的 `BT`​ 下载文件需要手动添加其他服务器源, 这样才能发扬 `'我为人人, 人人为我'`​ 的精神, Tracker 服务器提供对应资源服务发现功能, 让同个资源下载用户进行互相分享.

所以这里需要配置推荐几个好用的服务:

```
https://cdn.staticaly.com/gh/XIU2/TrackersListCollection/master/best.txt
https://gitee.com/harvey520/www.yaozuopan.top/raw/master/blacklist.txt
https://cdn.jsdelivr.net/gh/ngosang/trackerslist@master/trackers_best.txt
```

这里编写脚本过滤出所有 `Tracker`​ 服务器筛选, 把所有服务器列表内容放置于文件 `tracker.txt`​ , 脚本内容如下( `tracker_exporter.sh`​ ):

```
#!/bin/bash

# files
OUT_DIR="/tmp"
OUT_FILE="tracker.list"
OUT_LINE_FILE="tracker_aria2.list"

# read file
FILE=$1
if [ $FILE ]; then
    # file strings
    FILES=""

    # download files
    for URL in $(cut -d, -f2 < "$FILE")
    do
        # execute curl
        FILENAME=`echo $URL | /bin/sed -e 's#.*/##'`
        URLMD5=`/bin/echo $FILENAME | /usr/bin/md5sum | /bin/cut -f1 -d "" | tr -d " -"`
        /usr/bin/curl -o "$OUT_DIR/$URLMD5.txt" -s $URL

        # ok?
        if [ $? -eq 0 ]; then
            echo "" >> $OUT_DIR/$URLMD5.txt
            FILES="$FILES $OUT_DIR/$URLMD5.txt"
            echo "Output File = $OUT_DIR/$URLMD5.txt"
        fi
    done

    # merge files
    if [[ -n "$FILES" ]]; then
    
        CONTENT=`/bin/cat $FILES | sort |  uniq > $OUT_DIR/tracker.list`
        # ok?
        if [ $? -eq 0 ]; then

            /bin/cat $OUT_DIR/$OUT_FILE | tr "\r\n" ","  | sed 's/\r\n/,/g' > $OUT_DIR/$OUT_LINE_FILE
            echo "Merge File = $OUT_DIR/$OUT_FILE"
            echo "Merge File = $OUT_DIR/$OUT_LINE_FILE"
        fi
    fi
else
    echo "Not Found File"
    exit 1
fi
```

这里只需要执行即可调出所有 `tracker`​ 服务器:

```
# 执行调用合并服务器
sudo bash tracker_exporter.sh tracker.txt
# 完成之后会输出数据:
# Output File = /tmp/11af9b863eb37e4f9b75b90ba695233b.txt
# Output File = /tmp/3c0cf7bf8c0f5c6f1d4e5c51236064d2.txt
# Output File = /tmp/a28607a44fbb7d2180e030a672b588d1.txt
# Merge File = /tmp/tracker.list
# Merge File = /tmp/tracker_aria2.list
```

内部的文件只需要 `/tmp/tracker.list`​ 和 `/tmp/tracker_aria2.list`​, 把 `tracker_aria2.list`​ 内容放置于之前的 `aria2`​ 配置文件:

```
# 放置于tracker该项即可
bt-tracker=xxx,yyy,zzzz
```

这样就完成整体的离线下载服务

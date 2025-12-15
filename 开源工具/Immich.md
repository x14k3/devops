[Immich](https://immich.app/) 是一个开源的照片/视频管理方案，它的功能和用途类似于 Google 相册或 iCloud 照片。任何个人都可以利用 Immich 搭建自己私有的云同步相册，并支持多端/多人使用。

## 部署 Immich

推荐使用 Docker 方式进行部署，简单高效。
项目地址：[GitHub - imagegenius/docker-immich](https://github.com/imagegenius/docker-immich/)
```bash
docker pull ghcr.io/imagegenius/immich:latest  
# 国内用户可使用镜像代理：  
# docker pull ghcr.dockerproxy.net/imagegenius/immich:latest|
```


使用 Docker Compose 启动服务

```yml
services:
# immich本体:
  immich:
    image: ghcr.io/imagegenius/immich:latest
    container_name: immich
    environment:
      ## 常规部分
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      ## PostgreSQL部分
      - DB_HOSTNAME=immich_database
      - DB_USERNAME=postgres
      - DB_PASSWORD=password123 #PostgreSQL密码，注意修改
      - DB_DATABASE_NAME=immich
      ## Redis部分
      - REDIS_HOSTNAME=immich_redis
      - DB_PORT=5432    #默认
      - REDIS_PORT=6379 #默认
      - REDIS_PASSWORD= #默认
      ## 机器学习部分
      - MACHINE_LEARNING_GPU_ACCELERATION=  #默认
      - MACHINE_LEARNING_HOST=0.0.0.0       #默认
      - MACHINE_LEARNING_PORT=3003          #默认
      - MACHINE_LEARNING_WORKERS=1          #默认
      - MACHINE_LEARNING_WORKER_TIMEOUT=120 #默认
    volumes:
# 假设 compose.yml 路径为 /volume1/docker/immich/compose.yml
# config 文件夹与 compose.yml 在同一级目录
# 那么可以直接使用 ./config 代表 /volume1/docker/immich/config
      - /data/application/immich//config:/config
      - /data/application/immich/photos:/photos
      #- /data/application/immich/import:/import #按需启用，外部存储库
    ports:
      - 8901:8080           #暴露端口
    # devices:
    #   - /dev/dri:/dev/dri #英特尔硬件加速，根据实际情况启用
    restart: unless-stopped
    networks:
      - immich              #加入immich网络

# 这个容器需要一个外部应用程序单独运行才能单独运行。
# 默认情况下，数据库的端口是开放的，部署时要小心。
# 但被 mikusa 关掉了，有需要请自行打开。
# Redis缓存:
  immich_redis:
    image: redis
    container_name: immich_redis
    # ports:
    #   - 6379:6379 #不暴露端口
    restart: unless-stopped
    networks:
      - immich ##加入immich网络

# PostgreSQL数据库:
  immich_database:
    image: tensorchord/pgvecto-rs:pg14-v0.2.0
    container_name: immich_database
    user: 1000:1000
    # ports:
    #   - 5432:5432 #不暴露端口
    environment:
      - TZ=Asia/Shanghai
      - POSTGRES_PASSWORD=password123 #PostgreSQL密码，注意修改，与上方配置需一致
      - POSTGRES_USER=postgres
      - POSTGRES_DB=immich
    volumes:
      - /data/application/immich/database:/var/lib/postgresql/data
    restart: unless-stopped
    networks: 
      - immich ##加入immich网络 
networks: 
  immich: ##自动创建immich网络，仅immich内部可用 
    driver: bridge
```


```bash
docker compose -f docker-compose-immich.yaml up -d
```


## Immich目录结构

```bash
immich
├── compose.yml
├── config
│   └── machine-learning
├── database
├── import
└── photos
    ├── backups.      # 数据备份
    ├── encoded-video # 转码视频
    ├── library       # 图库
    ├── thumbs        # 缩略图
    ├── profile       # 用户头像，难以置信immich竟然给头像单独创建了文件夹
    └── upload        # 上传文件夹
```

## Immich 功能配置   

### 存储模板配置

这个功能默认是关闭的，根据官方文档中关于《[存储模板的实现方式](https://immich.app/docs/administration/backup-and-restore#asset-types-and-storage-locations)》的解释，开启后可以自定义图片存储结构。**适合文件夹强迫症用户。

以本文将图片挂载到 `/photos` 文件夹为例。不论你是否启用存储模板，`/photos` 文件夹中都会生成如下文件夹：

- `profile`：用户个人资料图片
- `thumbs`：存储缩略图
- `encoded-video` ：存储转码视频
- `upload`：存储上传的图片，启用存储模板后，这个文件夹会变成临时中转站
- `library`：启用存储模板后，图片会从 `upload` 移动至此

假如没有启用存储模板，即默认设置的状态下，图片会保存在 `/photos/upload/<userID>` 文件夹中，`userID` 可以在账户设置 -> 账户 -> 用户 ID 中找到，这个 ID 为字符串且唯一。

如果启用了存储模板，所有图片会被自动任务移动到 `/photos/library/<userID>` 文件夹中。这个 `userID` 和上面的情况一样，都是唯一的字符串。但管理员可以为用户额外设置**存储标签**（管理员有一个默认的 `admin` 存储标签。），该标签被设置后将会代替 `<userID>`。也就是说，图片会被保存到 `/photos/library/admin` 文件夹。

接着选择自己喜欢的存储模板。我选择的是 `{{y}}/{{MM}}/{{dd}}/{{filename}}`，即最终图片会被保存在结构为 `/2022/02/03/IMAGE_56437.jpg` 的文件夹中。

### 配置地理信息（Geodata）

为解决 Immich 默认地理反编码结果为英文的问题，可以使用社区项目 [immich-geodata-cn](https://github.com/ZingLix/immich-geodata-cn) 实现中文地址显示。

**特点：**
- 国内地址全面汉化（含港澳台）
- 实验性支持海外地址（如日本）
- 地址规范化为标准四级行政区格式（通过高德/Nominatim API）

**挂载方式示例：**
```bash
/data/application/immich/server/geodata:/app/immich/server/geodata:rw    
/data/application/immich/server/i18n-iso-countries:/app/immich/server/node_modules/i18n-iso-countries:rw
```


## 批量从服务器本地导入文件

在 im­mich 设置中创建一个 api key 
![[开源工具/assets/efd15d63b0a2ef1a262d3fd83ffec2ec_MD5.webp]]

使用 `immich login <url> <key>` 的格式连接到 im­mich，例如：
```bash
docker exec -it immich /bin/bash
immich login http://127.0.0.1:8080 eeffggssssseIxxxxxxxyucxxxccTvvvsswwee
# 有如下提示输出即代表登录成功：
$ immich login login http://192.168.31.3:8080 eeffggssssseIxxxxxxxyucxxxccTvvvsswwee
Logging in to http://192.168.31.3:8080
Logged in as mail@email.com
Wrote auth info to /home/mikusa/.config/immich/auth.yml

# 随后就可以直接上传图片了：
immich upload file1.jpg file2.jpg

# 也可以上传一整个文件夹。默认不包括子文件夹，如需上传包含子文件夹的文件夹，需加上 `--recursive`：
immich upload --recursive directory/

# 默认情况下，upload 命令将在上传文件之前对文件进行哈希处理。这是为了避免多次上传同一个文件。如果确定文件是唯一的，则可以通过传递该选项来跳过此步骤。请注意，Immich 始终通过哈希执行自己的重复数据删除，因此这只是一个性能考虑因素。如果您有良好的带宽，跳过哈希可能会更快。`--skip-hash`
immich upload --skip-hash --recursive directory/


# 使用 `--album-name` 上传到指定相册：
immich upload --album-name "初音未来" --recursive miku/

```
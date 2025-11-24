Gotify 是一款简易的发送与接受消息的开源软件。提供 **WEB 服务端**，**Android 端**与**命令行**工具。

四大核心优势
1. **零依赖部署**：单Docker容器搞定，不吃配置
2. **毫秒级延迟**：基于WebSocket协议，消息即发即达
3. **多终端支持**：网页/APP/命令行全平台覆盖
4. **企业级安全**：支持[HTTPS](https://zhida.zhihu.com/search?content_id=255882559&content_type=Article&match_order=1&q=HTTPS&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NjQxMjIzMTcsInEiOiJIVFRQUyIsInpoaWRhX3NvdXJjZSI6ImVudGl0eSIsImNvbnRlbnRfaWQiOjI1NTg4MjU1OSwiY29udGVudF90eXBlIjoiQXJ0aWNsZSIsIm1hdGNoX29yZGVyIjoxLCJ6ZF90b2tlbiI6bnVsbH0.rE51FvEfU0B_GsdjlwF-VHTp8MYYhLN2KQOsK-Y9L7Y&zhida_source=entity)加密、多用户权限控制

## 部署

创建目录

```bash
mkdir -p /data/gotify
```

我们使用 docker-compose 进行部署，所以推荐使用环境变量来配置 gotify

```bash
vim docker-compose.yml
```

修改下面的配置文件后贴入

```yaml
version: "3"
 
services:
  gotify:
    image: gotify/server
    ports:
      - 8080:80  # 如果8080端口已被占用，可以自行修改8080为空余端口号
    environment:
      - GOTIFY_DEFAULTUSER_NAME=yemeng
      - GOTIFY_DEFAULTUSER_PASS=yemeng
    volumes:
      - "/data/gotify:/app/data"
```

可以在 environment 中添加的变量：

```yaml
GOTIFY_SERVER_PORT=80
GOTIFY_SERVER_KEEPALIVEPERIODSECONDS=0
GOTIFY_SERVER_LISTENADDR=
GOTIFY_SERVER_SSL_ENABLED=false
GOTIFY_SERVER_SSL_REDIRECTTOHTTPS=true
GOTIFY_SERVER_SSL_LISTENADDR=
GOTIFY_SERVER_SSL_PORT=443
GOTIFY_SERVER_SSL_CERTFILE=
GOTIFY_SERVER_SSL_CERTKEY=
GOTIFY_SERVER_SSL_LETSENCRYPT_ENABLED=false
GOTIFY_SERVER_SSL_LETSENCRYPT_ACCEPTTOS=false
GOTIFY_SERVER_SSL_LETSENCRYPT_CACHE=certs
# lists are a little weird but do-able (:
# GOTIFY_SERVER_SSL_LETSENCRYPT_HOSTS=- mydomain.tld\n- myotherdomain.tld
GOTIFY_SERVER_RESPONSEHEADERS="X-Custom-Header: \"custom value\""
# GOTIFY_SERVER_CORS_ALLOWORIGINS="- \".+.example.com\"\n- \"otherdomain.com\""
# GOTIFY_SERVER_CORS_ALLOWMETHODS="- \"GET\"\n- \"POST\""
# GOTIFY_SERVER_CORS_ALLOWHEADERS="- \"Authorization\"\n- \"content-type\""
# GOTIFY_SERVER_STREAM_ALLOWEDORIGINS="- \".+.example.com\"\n- \"otherdomain.com\""
GOTIFY_SERVER_STREAM_PINGPERIODSECONDS=45
GOTIFY_DATABASE_DIALECT=sqlite3
GOTIFY_DATABASE_CONNECTION=data/gotify.db
GOTIFY_DEFAULTUSER_NAME=admin
GOTIFY_DEFAULTUSER_PASS=admin
GOTIFY_PASSSTRENGTH=10
GOTIFY_UPLOADEDIMAGESDIR=data/images
GOTIFY_PLUGINSDIR=data/plugins
GOTIFY_REGISTRATION=false
```

启动

```
docker-compose up -d
```

## 4. 反向代理
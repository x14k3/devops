
```bash
# 下载初始数据库文件
cd /data/application/calibre-web/library
wget https://raw.githubusercontent.com/janeczku/calibre-web/master/library/metadata.db
# 设置权限，所有者和所属组更改为 UID 和 GID 为 1000 的用户和组。
chown 1000:1000 metadata.db
# 设置权限 644，即文件所有者可以读取和写入，所属组和其他用户只能读取。
chmod 644 metadata.db

  
docker run -d  \
--name=calibre-web  \
-p 8902:8083  \
-p 8903:8080  \
-v /data/application/calibre-web/config:/config  \
-v /data/application/calibre-web/library:/library  \
-v /data/application/calibre-web/autoaddbooks:/autoaddbooks \
-e UID=1000  \
-e GID=1000  \
-e CALIBRE_SERVER_USER=admin  \
-e CALIBRE_SERVER_PASSWORD=admin123 \
johngong/calibre-web:latest

```
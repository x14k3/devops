
```bash
mkdir -p /data/application/kavita/{manga,comics,books,data}

docker run --name kavita -d \
-p 5000:5000 \
-v /data/application/kavita/manga:/manga \
-v /data/application/kavita/comics:/comics \
-v /data/application/kavita/books:/books \
-v /data/application/kavita/data:/kavita/config \
-e TZ=Asia/Shanghai \
jvmilazz0/kavita:latest
```
# Minio

> 分布式Minio可以让你将多块硬盘（甚至在不同的机器上）组成一个对象存储服务。由于硬盘分布在不同的节点上，分布式Minio避免了单点故障。

FastDFS的部署不过是零件的组装过程，需要你去理解fastDFS的架构设计，才能够正确的安装部署。MinIO在安装的过程是黑盒的，你不用去深入关注它的架构，也不需要你进行零件组装，基本上可以做到开箱即用。普通的技术人员就能够参与后期运维。

‍

```bash
# 正常直接通过
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
./minio server /opt/data
# 启动后，会发现用户名密码默认为 minioadmin，并且 console 监听的是一个动态的端口，下次访问端口会发生变化。


# 配置用户名密码# 默认密码 minioadmin/minioadmin
export MINIO_ROOT_USER = admin
export MINIO_ROOT_PASSWORD = 12345678
# region描述的是服务器的物理位置，默认是us-east-1（美国东区1)
export MINIO_REGION = "Hongkong"
# nohup /data/minio/bin/minio server --config-dir /data/minio/conf --address ":9000" --console-address ":9001" /data/minio >> /data/minio/minio.log  2>&1 &

# 默认的配置目录是${HOME}/.minio，可以通过 --config-dir 命令自定义配置目录
# 默认服务端口家是 9000，可以通过 --address ":port" 指定静态端口
# 控制台监听端口是动态生成的，可以通过 --console-address ":port" 指定静态端口
```

‍

## 分布式集群部署

```bash
# 设置环境变量，作为用户名和密码
export MINIO_ROOT_USER=Ninestar  
export MINIO_ROOT_PASSWORD=Ninestar123

# 启动
nohup /data/minio/bin/minio server --config-dir /etc/minio --console-address ":9001" \  
http://10.98.66.62:9000/data/minio/data \
http://10.98.66.63:9000/data/minio/data \
http://10.98.66.64:9000/data/minio/data \
http://10.98.66.65:9000/data/minio/data > minio.log 2>&1 &
```

### docker部署

```bash
 docker run  -p 9000:9000 --name minio \
 -d --restart=always \
 -e MINIO_ACCESS_KEY=minio \
 -e MINIO_SECRET_KEY=minio@123 \
 -v /data/minio/data:/data \
 -v /data/minio/config:/root/.minio \
  minio/minio server /data  --console-address ":9000" --address ":9090"
```

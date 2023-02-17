#middleware/minio

> 分布式Minio可以让你将多块硬盘（甚至在不同的机器上）组成一个对象存储服务。由于硬盘分布在不同的节点上，分布式Minio避免了单点故障。

说白了：FastDFS的部署不过是零件的组装过程，需要你去理解fastDFS的架构设计，才能够正确的安装部署。MinIO在安装的过程是黑盒的，你不用去深入关注它的架构，也不需要你进行零件组装，基本上可以做到开箱即用。普通的技术人员就能够参与后期运维。

1.下载rmp包

wget [https://dl.min.io/server/minio/release/linux-amd64/minio](https://dl.min.io/server/minio/release/linux-amd64/minio "https://dl.min.io/server/minio/release/linux-amd64/minio")

2.上传并授权

`chmod 700 minio ;mkdir -p /data/minio/{bin,data,etc}`

3.静默启动
```bash
# 设置环境变量，作为用户名和密码
export MINIO_ROOT_USER=Ninestar  
export MINIO_ROOT_PASSWORD=Ninestar123
# 默认密码 minioadmin/minioadmin
# 启动
nohup /data/minio/bin/minio server /data/minio/data --address ":9000" --console-address ":9001" > minio.log 2>&1 &
# --address           服务端口
# --console-address   前端控制台端口
# /data               文件目录
```

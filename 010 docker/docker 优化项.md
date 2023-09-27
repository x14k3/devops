# docker 优化项

‍

## 修改**docker仓库源为阿里源**

```bash
sudo mkdir -p /etc/docker
vim /etc/docker/daemon.json
-------------------------------------------------------------
{
  "registry-mirrors": ["https://tu2ax1rl.mirror.aliyuncs.com"],
  "insecure-registries": ["0.0.0.0"]  //用于docker客户端 通过 http 连接仓库
}
-------------------------------------------------------------
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 修改默认存储路径/var/lib/docker

```bash
# 修改docker默认运行目录 /data/docker
# 停止的docker相关服务:
systemctl stop docker
systemctl stop docker.socket
systemctl stop containerd
#在新选择的磁盘上创建docker使用目录，建议选择有50G以上空闲的磁盘
mkdir -p /data
# 把原来的docker目录移动到/data3:
mv /var/lib/docker /data
# 修改或创建docker配置文件: /etc/docker/daemon.json
vim /etc/docker/daemon.json
# 添加配置项:
root@doshell docker $ cat  /etc/docker/daemon.json 
{ 
    "insecure-registries": ["0.0.0.0/0"],
    "data-root": "/data/docker"
}
# 保存/etc/docker/daemon.json文件后重新启动docker服务:
systemctl start docker
# 执行这条命令docker相关的服务也都会启动了
# 检查下修改生效了没:
docker info -f '{{ .DockerRootDir}}'
# 如果输出的是新的路径就代表修改成功了,从这里也可以看出这个配置的官方名称叫 Docker Root Directory(Docker根目录)
```

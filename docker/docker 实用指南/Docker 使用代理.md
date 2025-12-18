
## docker 镜像加速（仓库改为阿里源）

```bash
mkdir -p /etc/docker
vim /etc/docker/daemon.json
-------------------------------------------------------------
{
  "registry-mirrors": ["https://tu2ax1rl.mirror.aliyuncs.com"],
  "insecure-registries": ["0.0.0.0"]
}
-------------------------------------------------------------
sudo systemctl daemon-reload
sudo systemctl restart docker
```
也可以用其它镜像比如[阿里云](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)或者[daocloud](https://docs.daocloud.io/community/mirror/)等等


## docker pull 拉取镜像使用代理
docker pull /push 的代理被 systemd 接管，所以需要设置 systemd…

```bash
sudo mkdir -p /etc/systemd/system/docker.service.dsudo 
echo '
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8123"
Environment="HTTPS_PROXY=http://127.0.0.1:8123"
' >> /etc/systemd/system/docker.service.d/http-proxy.conf

systemctl daemon-reload
systemctl restart docker
```


## docker build 镜像时使用代理

在 build 时添加 --build-arg 参数来设置生成镜像时使用的环境变量
```bash
docker build --build-arg http_proxy=http://172.17.0.1:8123 --build-arg https_proxy=http://172.17.0.1:8123 -t image_name .
```
另外，也可以设置参数--network=host 来直接和宿主机共用网络，就能直接使用127.0.0.1来访问到宿主机了


## docker 使用宿主机的代理

```bash
# 直接在容器内使用（推荐)
export ALL_PROXY='socks5://172.17.0.1:10808'
```






**Portainer** 是一款轻量级的图形化管理工具，通过它我们可以轻松管理不同的 **Docker** 环境。 **Portainer** 部署和使用都非常简单，它提供一个可以运行在任何 **Docker** 引擎上的容器组成。 **Portainer** 提供管理 **Docker** 的 **container** 、 **images** 、 **volumes** 、 **networks** 等等。它兼容独立的 **Docker** 环境和 **swarm** 集群模式。基本满足中小型单位对 **Docker** 容器的管理工作。

## Docker方式安装

我们可以直接使用 **Docker** 的方式来安装

```bash
docker run -d --name portainer -p 9000:9000  \
-v /var/run/docker.sock:/var/run/docker.sock \
portainer/portainer:latest

# 汉化版本
docker run -d --name portainer -p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
6053537/portainer-ce:latest
```

运行成功后，然后通过 9000端口访问即可


## 使用Portainer管理其它主机

刚刚演示的是使用 **Portainer** 管理本地安装的 **Docker** 主机，如果我们要使用 **portainer** 管理其它地方的主机。我们就需要单独启动一台主机，然后在上面运行 **Docker** ，需要注意：我们还需要开启Docker中的 2375端口号

首先我们编辑 daemon.json

```bash
vim /etc/docker/daemon.json
```

然后加入以下内容即可【注意 **2375** 端口号要慎开，不然可能被当肉鸡挖矿】

```yaml
{
	"hosts": ["tcp://192.168.119.150:2375", "unix:///var/run/docker.sock"]
}
```

然后选择 **端点** 的 **添加端点**
![[docker/assets/201a0d1e9eb9eeb4cbcbd0fbc8829834_MD5.png|700]]

然后选择Docker环境
![[docker/assets/60da4aa4afbcc591745d2e28519cdc50_MD5.png|700]]

最后添加端点完后，就能看到我们刚刚添加的节点了
![[docker/assets/9f89c6428faa0fc2785e2a0395f40764_MD5.png|700]]

我们回到首页，即可看到我们的两台Docker服务了
![[docker/assets/0567449289114e7d261ca971ec1eaa84_MD5.png|700]]

## 使用Portainer部署Nginx服务

下面我们就可以使用Portainer来部署我们的nginx服务，到指定的Docker环境中，由于我们目前有多台Docker环境，因此我们就首先需要选择不同的主机来进行部署

首先，我们选择 192.168.119.148 这台主机
[![[docker/assets/5174b98c8f8fc050a85645dce212eb33_MD5.png|550]]

然后选择镜像，输入 nginx，点击拉取镜像
![[docker/assets/91931845d407e00c18435e4a657aa939_MD5.png|750]]

然后就会去拉取到我们的nginx镜像了，下面我们就可以使用这个拉取的镜像来创建容器

我们输入一些基本信息后，点击创建
![[docker/assets/2b9a1ba419109a64cb8f5241ac46e83c_MD5.png|750]]

完成后，即可看到 nginx的端口号已经对外发布
![[docker/assets/e022187de411e5ccf137b5b42eddd568_MD5.png|750]]

我们输入下面的地址
http://ip:32768

即可看到，nginx已经成功安装
![[docker/assets/85dd10c74fd63f9366ee6567b6363220_MD5.png|750]]
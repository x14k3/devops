# home-assistant

# 部署hass

```bash
#拉取hass的最新版镜像(注意：根据自己需求选择对应版本，并不是越新越好)
docker pull homeassistant/home-assistant:latest
#创建容器并运行
docker run -d --name="hass" -v /data/homeassistant/config:/config -p 8123:8123 homeassistant/home-assistant:latest

```

访问控制台：
http://192.168.0.100:8123

# 安装HACS

安装HACS(Home Assistant Community Store,一个商店，集成丰富，依托于GitHub。

```bash
#进入hass目录,安装hacs 
docker exec -it hass bash 
wget -O - https://get.hacs.xyz | bash -

```

最后重启 homeassistant

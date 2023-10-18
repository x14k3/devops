# Rustdesk

**RustDesk优点**

1、自建服务端。搭建在自己的云服务器就相当于独享高速带宽！

2、点对点通信。TCP隧道功能一旦打洞成功，相当于用户之间直连，不走服务器带宽！

3、通信加密。配置公钥后，必须拥有公钥才能正常使用！

4、内置文件传输。得益于点对点通信，文件传输不也是手到擒来嘛！

‍

服务下载地址：[https://github.com/rustdesk/rustdesk-server/releases](https://github.com/rustdesk/rustdesk-server/releases)

客户端下载地址：[https://rustdesk.com/zh/ ](https://rustdesk.com/zh/)支持IOS、Mac、Windows、Android、Linux等等！

‍

[官方文档](https://www.chengzz.com/?golink=aHR0cHM6Ly9ydXN0ZGVzay5jb20vZG9jcy96aC1jbi9zZWxmLWhvc3Qv) 安装方式多种多样，但是我还是用 [docker-compose](https://www.chengzz.com/tag/docker-compose) 部署比较方便，毕竟不会影响到服务器环境还能在需要的时候修改配置，官方也有提供 docker-compose.yml 配置文件

## 安装 rustdesk-server

### 获取docker-compose脚本

[https://github.com/rustdesk/rustdesk-server/blob/master/docker-compose.yml](https://github.com/rustdesk/rustdesk-server/blob/master/docker-compose.yml)

```yaml
version: '3'

networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21118:21118
    image: rustdesk/rustdesk-server:latest
    command: hbbs -r 8.210.145.225:21117
    volumes:
      - /data/rustdesk/hbbs:/root
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    ports:
      - 21117:21117
      - 21119:21119
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - /data/rustdesk/hbbr:/root
    networks:
      - rustdesk-net
    restart: unless-stopped
```

```yaml
mkdir -p /data/rustdesk/{hbbr,hbbs}
mv docker-compose.yml  /data/rustdesk/
docker-compose up -d
```

默认情况下:  
hbbs 监听

* 21115(tcp)  ：hbbs 用作  NAT 类型测试（无需开启，不用关注）
* 21116(tcp/udp)：21116/UDP 是 hbbs 用作 ID 注册与心跳服务，21116/TCP 是 hbbs 用作 TCP  打洞与连接服务
* 21118(tcp)：网页客户端（可不开）

hbbr 监听 

* 21117(tcp)：hbbr 用作中继服务
* 21119(tcp)：网页客户端（可不开）

‍

‍

## 客户端使用

​![image](assets/image-20231017143514-16qs7my.png)​

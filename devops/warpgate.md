
Warpgate是一款无需客户端的堡垒机软件，目前可用作SSH、MySQL/MariaDB和HTTP的堡垒机服务器，提供基于Web的管理仪表板，旨在简化网络中的远程访问与管理。用户可以将其安装在特定节点上，然后可以轻松添加位于私有基础设施上的目标节点或服务器。

## Warpgate堡垒机优势介绍

**1、简单部署**
Warpgate堡垒机拥有一个独立的二进制文件，无其他依赖，快速启动。
**2、实时监控**
Warpgate堡垒机内置的Web UI允许实时查看和回放会话，增强审计能力。
**3、透明转发**
Warpgate堡垒机不作为跳板主机，直接将连接转发到目标，减少中间环节。
**4、高灵活性**
Warpgate堡垒机支持HTTPS切换多个目标，随时调整访问范围。
## Warpgate堡垒机应用场景

**1、云环境管理**
Warpgate堡垒机为远程团队提供对云基础设施的安全访问，无需暴露内部网络。
**2、多租户环境**
Warpgate堡垒机通过用户账户和目标主机分配，轻松控制每个用户的访问权限。
**3、IT运维**
Warpgate堡垒机部署在DMZ区，允许管理员安全地访问内网服务器，记录所有会话以便审查。
**4、数据安全**
Warpgate堡垒机原生支持2FA和SSO（TOTP和OpenID Connect），提高安全性。


## 部署
```bash
wget https://github.com/warp-tech/warpgate/releases/download/v0.17.0/warpgate-v0.17.0-x86_64-linux

chmod 777 warpgate-v0.17.0-x86_64-linux 
mv warpgate-v0.17.0-x86_64-linux  warpgate

./warpgate setup

22:16:15  INFO Welcome to Warpgate v0.17.0-modified
22:16:15  INFO Let's do some basic setup first.
22:16:15  INFO The new config will be written in /etc/warpgate.yaml.
22:16:15  INFO * Paths can be either absolute or relative to /etc.
? Directory to store app data (up to a few MB) in (/var/lib/warpgate) › /data/application/✔ Directory to store app data (up to a few MB) in · /data/application/warpgate
✔ Endpoint to listen for HTTP connections on · [::]:8888
22:16:36  INFO You will now choose specific protocol listeners to be enabled.
22:16:36  INFO 
22:16:36  INFO NB: Nothing will be exposed by default -
22:16:36  INFO     you'll choose target hosts in the UI later.
✔ Accept SSH connections? · yes
✔ Endpoint to listen for SSH connections on · [::]:2222
✔ Accept MySQL connections? · yes
✔ Endpoint to listen for MySQL connections on · [::]:33306
✔ Accept PostgreSQL connections? · yes
✔ Endpoint to listen for PostgreSQL connections on · [::]:55432
✔ Do you want to record user sessions? · yes
✔ Set a password for the Warpgate admin user · ********

22:16:50  INFO Saved into /etc/warpgate.yaml
22:16:50  INFO Using config: "/etc/warpgate.yaml"
22:17:05  INFO Generating Ed25519 host key
22:17:05  INFO Generating RSA host key (this can take a bit)
22:17:05  INFO Generating Ed25519 client key
22:17:05  INFO Generating RSA client key (this can take a bit)
22:17:09  INFO Generating a TLS certificate
22:17:09  INFO 
22:17:09  INFO Admin user credentials:
22:17:09  INFO   * Username: admin
22:17:09  INFO   * Password: <your password>
22:17:09  INFO 
22:17:09  INFO You can now start Warpgate with:
22:17:09  INFO   ./warpgate --config /etc/warpgate.yaml run


./warpgate run
```

访问 https://192.168.3.100:8888     admin/xxxxxx
# shadowsocks

## 部署

```bash

# 升级内核
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
# 修改grub2引导
# 查看可用内核
awk '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0
#  重启，查看内核
reboot
cat /etc/redhat-release

# 开启bbr
cat <<EOF >> /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

sysctl -p 
# 验证bbr是否已经开启
sysctl net.ipv4.tcp_available_congestion_control

# 添加epel源
yum install epel-release -y
yum clean all
yum makecache
yum update

# 安装shadowsocks
yum install git -y
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
# 更新子模块
git submodule update --init --recursive
# 安装依赖
yum install gcc gettext autoconf libtool automake make pcre-devel \
asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
# 编译安装
./autogen.sh && ./configure && make && make install

```

## 单用户配置

```json
{
    "server": "111.111.111.111",        // 你vps的ip地址
    "server_port": 8388,                // 端口
    "local_port": 1080,                 // 本地端口
    "password": "barfoo!",              // 密码
    "timeout": 600,                     // 超时毫秒数
    "method": "chacha20-ietf-poly1305"  // 加密方式
}
```

## 多用户配置

多用户配置时，应用ss-manager而不是ss-server

```json
{
    "server": "111.111.111.111",
    "local_port": 1080,
    "timeout": 600,
    "method": "chacha20-ietf-poly1305",
    "port_password": {
      "8388": "barfoo1",
      "8389": "barfoo2" 
    }
}

```

## 启动

```bash
# 单用户
nohup ss-server -c /root/ss_serverConfig &

# 多用户时则用ss-manager
nohup ss-manager -c /root/ss_managerConfig &

```

## 启用obfs混淆插件

```bash
# yum install build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
git clone https://github.com/shadowsocks/simple-obfs.git
cd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make && make install
setcap cap_net_bind_service+ep /usr/local/bin/obfs-server
```

==修改shadowsocks配置文件，使用单用户模式==

```json
{
    "server": "111.111.111.111",
    "server_port": 8388,
    "local_port": 1080,
    "password": "barfoo!",
    "timeout": 600,
    "method": "chacha20-ietf-poly1305"
    "plugin": "obfs-server",
    "plugin_opts": "obfs=tls;obfs-host=www.bilibili.com",
    "fast_open": false,
    "reuse_port": false
}
```

## ubuntu 使用代理

```bash
sudo apt-get install shadowsocks-libev
sudo apt-get install simple-obfs

sudo vim /etc/shadowsocks-libev/config.json
-----------------------------------------
{
    "server":"119.28.77.113",
    "server_port":7098,
    "local_port":1080,
    "password":"shad0ws0c4s@202l",
    "timeout":60,
    "method":"chacha20-ietf-poly1305",
    "plugin":"obfs-local",
    "plugin_opts":"obfs=tls;obfs-host=bilibili.com;fast-open"
}

```

### 浏览器代理

下载 SwitchyOmega

### 系统全局代理

```javascript
sudo apt-get install privoxy
sudo vim /etc/privoxy/config
------------------------------
listen-address 127.0.0.1:8118
forward-socks5t / 127.0.0.1:1080 .

# 启动privoxy
systemctl enable|start privoxy

# 终端代理
export http_proxy=127.0.0.1:8118
export https_proxy=127.0.0.1:8118

```

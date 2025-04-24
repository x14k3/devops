# alist

Alist 是一款支持多种存储的目录文件列表程序，支持 web 浏览与 webdav，后端基于`gin`，前端使用`react`

下载地址：[https://github.com/alist-org/alist/releases](https://github.com/alist-org/alist/releases)

```bash
# 解压下载对文件得到可执行文件：  
wget https://github.com/alist-org/alist/releases/download/v3.30.0/alist-linux-amd64.tar.gz
tar -zxf alist-linux-amd64.tar.gz 

# 配置文件
vim /data/alist/data/config.json
---------------------------------
{
  "force": false,
  "address": "0.0.0.0",
  "port": 5244,
  "jwt_secret": "random generated",
  "token_expires_in": 48,
  "site_url": "",
  "cdn": "",
  "database": {
    "type": "sqlite3",
    "host": "",
    "port": 0,
    "user": "",
    "password": "",
    "name": "",
    "db_file": "data/data.db",
    "table_prefix": "x_",
    "ssl_mode": ""
  },
  "scheme": {
    "https": false,
    "cert_file": "",
    "key_file": ""
  },
  "temp_dir": "data/temp",
  "log": {
    "enable": true,
    "name": "log/alist.log",
    "max_size": 10,
    "max_backups": 5,
    "max_age": 28,
    "compress": false
  }
}

---------------------------------

# 运行程序  
cd /data/alist/
nohup ./alist server &
# 查看alist登录密码
./alist password
# 第一次登陆设置密码
./alist admin set NEW_PASSWORD


# 守护进程
cat > /etc/systemd/system/alist.service <<EOF
[Unit]
Description=alist
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/data/alist
ExecStart=/data/alist/alist server
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alist
systemctl start alist

```



## openlist

```bash
export openlist_version="v4.1.8"
wget https://github.com/OpenListTeam/OpenList/releases/download/${openlist_version}/openlist-linux-amd64.tar.gz

tar -zxvf openlist-linux-amd64.tar.gz
chmod +x openlist
./openlist server
./openlist admin
./openlist admin random
./openlist admin set NEW_PASSWORD


# 守护进程
echo '[Unit]
Description=openlist
After=network.target
[Service]
Type=simple
WorkingDirectory=path_openlist
ExecStart=path_openlist/openlist server
Restart=on-failure
[Install]
WantedBy=multi-user.target
' >> /etc/systemd/system/openlist.service

systemctl daemon-reload
systemctl start openlist
```


# 使用方法：
  openlist [命令]
## 可用命令：
  admin      显示管理员用户的信息及管理员用户密码相关操作
  cancel2fa  删除管理员用户的 2FA
  completion 生成指定 shell 的自动补全脚本
  crypt      加密或解密本地文件或目录
  help       显示命令帮助
  kill       强制通过守护进程/进程 ID 文件终止 openlist 服务器进程
  lang       生成语言 JSON 文件
  restart    通过守护进程/进程 ID 文件重启 openlist 服务器
  server     启动指定地址的服务器
  start      静默启动 openlist 服务器，使用 `--force-bin-dir`
  stop       与 kill 命令相同
  storage    管理存储
  version    显示当前 OpenList 版本

## 标志参数：
  --data string   数据文件夹（默认值 "data"）
  --config string 配置文件（默认值 "data/config.json"）
  --debug         启动时使用调试模式
  --dev           启动时使用开发模式
  --force-bin-dir 强制使用二进制文件所在目录作为数据目录
  -h, --help      显示 openlist 命令帮助
  --log-std       强制日志输出到标准输出
  --no-prefix     禁用环境前缀

```


## alist (Expired)


```bash
# 解压下载对文件得到可执行文件：  
wget https://github.com/alist-org/alist/releases/download/v3.30.0/alist-linux-amd64.tar.gz
tar -zxf alist-linux-amd64.tar.gz 

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

# 配置文件详解
cat /data/alist/data/config.json

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


```



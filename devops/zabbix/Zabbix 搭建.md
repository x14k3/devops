

# 环境准备

```bash
zabbix:6.0.0
mysql:8.0.26
PHP:8.1.3
nginx:1.12.1
centos:7.8
```

- 关闭防火墙和selinxu

  ```bash
  systemctl stop firewalld ;systemctl disable firewalld
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  ```
- 下载zabbix安装包解压

  [https://www.zabbix.com/cn/download](https://www.zabbix.com/cn/download_sources "https://www.zabbix.com/cn/download_sources")​[sources](https://www.zabbix.com/cn/download_sources "https://www.zabbix.com/cn/download_sources")

  `tar -zxf zabbix-6.0.0.tar.gz`
- 创建普通用户

  ```bash
  groupadd --system zabbix
  useradd --system -g zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix

  ```

# 安装mysql数据库

数据库版本建议大于 8.0.0 [mysql 单机部署](../../数据库/mysql%20数据库/mysql%20单机部署.md)

- 创建数据库

  ```sql
  mysql -uroot -pNinestar@2022

  # 创建数据库和用户
  create database zabbix character set utf8mb4 collate utf8mb4_bin;
  CREATE USER 'zabbix'@'%' IDENTIFIED with mysql_native_password BY 'Ninestar@2022';
  grant all privileges on zabbix.* to 'zabbix'@'%';
  flush privileges;

  # 导入数据
  cd database/mysql
  mysql -uzabbix -pNinestar@2022 zabbix < schema.sql
  # 如果是创建 Zabbix proxy 的数据库，以下两条命令便不需要再执行。
  mysql -uzabbix -pNinestar@2022 zabbix < images.sql
  mysql -uzabbix -pNinestar@2022 zabbix < data.sql

  ```

# 安装zabbix服务端

- 1.安装依赖

  ```bash
  yum install -y gcc-c++ gcc make pcre-* libxml2 libxml2-devel unixODBC unixODBC-devel net-snmp-utils net-snmp net-snmp-devel libevent libevent-devel curl curl-devel
  ```
- 2.安装配置

  ```bash
  cd zabbix-6.0.0
  ./configure --prefix=/data/zabbix --enable-server --enable-agent --with-mysql --with-net-snmp \
  --with-libcurl --with-libxml2 --with-unixodbc

  # --prefix            安装目录
  # --enable-server     开启 Zabbix 服务器的构建
  # --enable-agent      打开 Zabbix 代理和客户端实用程序的构建
  # --enable-webservice 开启 Zabbix web 服务的构建
  # --enable-java       打开 Zabbix Java 网关的构建
  # --enable-ipv6       开启对 IPv6 的支持
  # --with-mysql        使用 MySQL 数据库

  ```
- 3.编译安装

  `make install `
- 4.编辑zabbix-server配置文件

  `vim /data/zabbix/etc/zabbix_server.conf`

  ```bash
  DBHost=localhost  # 数据库地址
  DBName=zabbix     # 数据库名 
  DBUser=zabbix     # 数据库用户名
  DBPassword=Ninestar@2022 # 数据库密码
  DBPort=3306       # 数据库端口
  ListenIP=0.0.0.0  # 监听地址，留空则会在所有的地址上监听，可以监听多个IP地址
  ListenPort=10051  # 监听端口
  LogFile=          # 日志文件路径
  User=zabbix       # 启动zabbix server的用户，在配置禁止root启动，并且当前shell用户是root得情况下有效
  # 参考
  ExternalScripts   # 外部脚本目录
  AlertScriptsPath  # 告警脚本目录
  AllowRoot         # 是否允许使用root启动，0:不允许，1:允许，默认0
  CacheUpdateFrequency # 默认值：60 多少秒更新一次配置缓存
  DBSchema          # Schema名称. 用于 IBM DB2 、 PostgreSQL
  DBSocket          # mysql sock文件路径
  SSHKeyLocation    # SSH公钥私钥路径
  SSLCertLocation   # SSL证书目录，用于web监控
  SSLKeyLocation    # SSL认证私钥路径、用于web监控
  SSLCALocation     # SSL认证,CA路径，如果为空，将会使用系统默认的CA

  ```
- 5.编辑zabbix-agent配置文件

  `vim /data/zabbix/etc/zabbix_agentd.conf`

  ```bash
  ######################## 被动模式 （server > agent）########################
  Server=192.168.10.145  # zabbix服务端IP或主机名，用逗号分割，支持CIDR。
  ListenPort=10050       # agent监听端口，range=1024-32767。
  ListenIp=0.0.0.0       # 监听的主机的ip。
  StartAgents=3          # 启动agent子进程的数量

  ######################## 主动模式（agent > server） ########################
  ServerActive=192.168.10.145 # zabbix服务端的ip和端口。
  StartAgents=0               # 主动模式下配置=0
  Hostname=Zabbix   # 手工自定义一个主机名，建议关闭此参数，并启用HostnameItem参数。
  HostnameItem=system.hostname  #system.hostname是ZABBIX内置的一个自动获取主机名的方法，建议打开此参数而关闭Hostname参数。

  ######################## 高级参数设置 ########################
  Timeout=30    # 当agent采集一个数据时，多长少算超时。建议保持默认。
  AllowRoot=1   # 是否允许ROOT帐号运行此客户端。0：不允许，1:允许，当一个脚本执行需要以ROOT身份执行的，则此开关必须打开。
  Include=      # 目录路径或扩展配置文件路径。
  UnsafeUserParameters=1 # 是否启用用户自定义监控脚本，1启用，0不启用，建议开启。
  # 自定义key，后面是命令或脚本 Format: UserParameter=<key>,<shell command>
  UserParameter=net.tcp.jinzay.ports,/data/zabbix/script/ports.py

  ```
- 6.启动zabbix和zabbix-agent

  ```bash
  /data/zabbix/sbin/zabbix_server
  /data/zabbix/sbin/zabbix_agentd

  ```

# 安装 Zabbix web 界面

> Zabbix前端是PHP编写的，所以运行它需要PHP支持的网络服务器。安装只需简单的从 UI 目录复制PHP文件到网络服务器 HTML文档目录。

- 安装PHP  **(使用7.x版本)** 
  [php](../../中间件/php.md)
- 安装nginx
  [nginx 部署](../../中间件/Nginx/nginx%20部署.md)
- nginx整合php-fpm
```conf
server {
    listen       8001;
    server_name  192.168.10.145;
    #charset koi8-r;

    #access_log  logs/host.access.log  main;
    location / {
        root /data/nginx/html;
        index index.php;
    }
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        index index.php;
        fastcgi_param  SCRIPT_FILENAME /data/nginx/html/$fastcgi_script_name;
        include        fastcgi_params;
}
```

- 复制PHP文件到nginx 前端资源目录
```bash
cp -a /opt/zabbix-6.0.0/ui/* /data/nginx/html/

# 启动nginx
/data/nginx/sbin/nginx -c /data/nginx/conf/nginx.conf
```

- 访问首页，根据提示修改php参数
```bash
echo '
php_admin_value[memory_limit] = 128M
php_admin_value[max_execution_time] = 300
php_admin_value[post_max_size] = 16M ' >>/data/php/etc/php-fpm.d/www.conf

systemctl restart php-fpm

# 输入用户名和密码Admin/zabbix
```

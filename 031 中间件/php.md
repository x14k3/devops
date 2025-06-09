# php

## yum源安装

```bash
# 安装epel-release源
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# 查看可以安装的php版本
yum list php*

# 安装php精简拓展
yum -y install php72w php72w-cli php72w-fpm php72w-common php72w-devel php72w-mysqlnd
# 安装php豪华拓展
yum -y install php72w php72w-cli php72w-fpm php72w-common php72w-devel php72w-embedded php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-bcmath php72w-xml php72w-ldap

# php-fpm开机自启
systemctl enable php-fpm

```

## 源码包安装

- 下载

  [https://www.php.net/downloads.php](https://www.php.net/downloads.php "https://www.php.net/downloads.php")
- 上传解压

  `tar -zxvf php-7.4.29.tar.gz`
- 创建普通用户

  ```纯文本
  groupadd --system www
  useradd --system -g www -s /sbin/nologin www
  ```
- 安装依赖(适用zabbix)

  ```bash
  yum install -y epel-release
  yum install -y gcc make gd-devel libjpeg-devel libpng-devel libxml2-devel bzip2-devel curl-devel libcurl-devel sqlite-devel libxslt-devel oniguruma oniguruma-devel krb5-devel openssl openssl-devel 

  cp -frp /usr/lib64/libldap* /usr/lib/

  ```
- 编译安装(适用zabbix)

  ```bash
  ./configure --prefix=/data/php --with-jpeg --with-freetype --enable-fpm --enable-gd --with-gettext --with-kerberos --with-libdir=lib64 --with-mysqli --with-openssl --with-pdo-mysql --with-pdo-sqlite --with-pear --with-xsl --with-zlib --with-bz2 --with-mhash --enable-bcmath --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-sysvshm --enable-xml 
  make && make install
  ```
- 修改配置文件

  ```bash
  cd /data/php/etc
  cp php-fpm.conf.default php-fpm.conf
  cd /data/php/etc/php-fpm.d
  cp www.conf.default  www.conf

  ```
- 添加到system service

  ```bash
  cat <<EOF > /lib/systemd/system/php-fpm.service
  [Unit]
  Description=The PHP 7.4.29  FastCGI Process Manager
  Documentation=man:PHP 7.4.29 (fpm-fcgi)
  After=network.target

  [Service]
  Type=simple
  PIDFile=/var/run/php-fpm.pid
  ExecStart=/data/php/sbin/php-fpm --nodaemonize --fpm-config /data/php/etc/php-fpm.conf
  ExecReload=/bin/kill -USR2 $MAINPID

  [Install]
  WantedBy=multi-user.target
  EOF


  # 启动
  systemctl daemon-reload
  systemctl start php-fpm
  systemctl status php-fpm

  ```

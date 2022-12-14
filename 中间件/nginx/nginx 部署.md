#middleware/nginx

nginx源码包下载地址：https://nginx.org/en/download.html

相关依赖下载地址：
ngx-dav-ext-module：https://github.com/arut/nginx-dav-ext-module
openssl 依赖：https://www.openssl.org/source/openssl-1.1.1q.tar.gz
zlib 依赖：http://www.zlib.net/
pcre依赖：http://www.pcre.org/

## 安装依赖
```bash
# Redhat
yum -y install gcc gcc-c++ pcre pcre-devel openssl openssl-devel zlib-devel  automake   libxml2-dev libxslt-devel  gd-devel perl-devel perl-ExtUtils-Embed GeoIP GeoIP-devel GeoIP-data

# Debian
apt-get install libxml2 libxml2-dev libxslt-dev libgd-dev libgeoip-dev  libpcre3 libpcre3-dev zlib1g-dev

#若安装时找不到上述依赖模块，使用--with-openssl=<openssl_dir> --with-pcre=<pcre_dir> --with-zlib=<zlib_dir>
```

## 开始安装

```bash
# 创建nginx目录
mkdir -p /data/nginx

# 创建nginx用户
useradd -M -s /sbin/nologin nginx

cd  nginx-1.22.0
./configure --prefix=/data/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module  --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-stream --with-stream_ssl_module 
# --with-openssl=/opt/openssl-1.1.1q
# --with-http_dav_module

# 编译安装
make -j4 && make install
chown -R nginx.nginx /data/nginx/

# 添加Nginx系统服务
cat >  /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
PIDFile=/data/nginx/logs/nginx.pid
ExecStart=/data/nginx/sbin/nginx -c /data/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service
```




## 置文件nginx.conf详解

```nginx
http {             # 这个是协议级别
    include mime.types;
    default_type application/octet-stream;
    keepalive_timeout 65;
    gzip on;
      
    server {         # 这个是服务器级别
        listen 80;
        server_name localhost;
        
        location / {   # 这个是请求级别
          root html;
          index index.html index.htm;
	    }
	}
}
```

## nginx相关模块说明

<https://www.cnbugs.com/post-116.html>

## 日志切割

```bash


```

# nginx 部署

　　nginx源码包下载地址：[https://nginx.org/en/download.html](https://nginx.org/en/download.html)

　　相关依赖下载地址：  
ngx-dav-ext-module：[https://github.com/arut/nginx-dav-ext-module](https://github.com/arut/nginx-dav-ext-module)  
openssl 依赖：[https://www.openssl.org/source/openssl-1.1.1q.tar.gz](https://www.openssl.org/source/openssl-1.1.1q.tar.gz)  
zlib 依赖：[http://www.zlib.net/](http://www.zlib.net/)  
pcre依赖：[http://www.pcre.org/](http://www.pcre.org/)

## 安装依赖

```bash
# Redhat
yum -y install gcc gcc-c++ pcre pcre-devel openssl openssl-devel zlib-devel  automake   libxml2-dev libxslt-devel  gd-devel perl-devel perl-ExtUtils-Embed GeoIP GeoIP-devel GeoIP-data

# Debian
apt-get install libpcre3 libpcre3-dev zlib1g-dev libxml2 libxml2-dev libxslt-dev libgd-dev libgeoip-dev

#若安装时找不到上述依赖模块，使用--with-openssl=<openssl_dir> --with-pcre=<pcre_dir> --with-zlib=<zlib_dir>
```

## 开始安装

```bash
wget https://nginx.org/download/nginx-1.22.1.tar.gz
tar -xf nginx-1.22.1.tar.gz
cd  nginx-1.22.1
# 创建nginx目录
mkdir -p /data/nginx

# 创建nginx用户
useradd -M -s /sbin/nologin nginx

./configure --prefix=/data/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module \
--with-http_realip_module --with-http_addition_module --with-http_image_filter_module --with-http_geoip_module \
--with-http_sub_module  --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module \
--with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module \
--with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-stream \
--with-stream_ssl_module 
# --with-openssl=/opt/openssl-1.1.1q
# --with-http_dav_module

# 编译安装
make -j4 && make install
chown -R nginx.nginx /data/nginx/

# 添加Nginx系统服务
cat >  /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx
After=network.target
[Service]
User=nginx
Group=nginx
Type=forking
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

　　‍

## 注意

　　众所周知，80端口为系统保留端口，如果通过其他非root用户启动，会报错如下：

```xml
8月 18 11:08:52 OptiPlex-3000 nginx[116935]: nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
8月 18 11:08:52 OptiPlex-3000 systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
8月 18 11:08:52 OptiPlex-3000 systemd[1]: nginx.service: Failed with result 'exit-code'.
8月 18 11:08:52 OptiPlex-3000 systemd[1]: Failed to start nginx.
```

　　<span data-type="text" style="background-color: var(--b3-font-background8);">因为普通用户只能用1024以上的端口，1024以内的端口只能由root用户使用。</span>

* 方法一：所有用户都可以运行（因为是755权限，文件所有者：root，组所有者：root

  ```bash
  chown root:root nginx
  chmod 755 nginx
  chmod u+s nginx
  #chmod u+s 就是给某个程序的所有者以suid权限，可以像root用户一样操作。
  ```

* 方法二：仅 root 用户和 nginx用户可以运行（因为是750权限，文件所有者：root，组所有者：nginx）

  ```bash
  chown root:test nginx
  chmod 750 nginx
  chmod u+s nginx
  ```

* 方法三：修改nginx端口为1024以上

　　‍

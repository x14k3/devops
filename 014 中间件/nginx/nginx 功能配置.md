# nginx 功能配置

‍

# 1.限制IP访问

```nginx
location / { 
  deny 192.168.1.1;       # 拒绝IP
  allow 192.168.1.0/24;   # 允许IP 
  allow 10.1.1.0/16;      # 允许IP 
  deny all;               # 拒绝其他所有IP 
}
```

‍

# 2.其他限制

```nginx
# 指定Nginx服务的用户和用户组
user nginx nginx;
-----------------------------------------
useradd nginx -s /sbin/nologin -M

# 限制http请求方法(只允许GET POST HEAD)
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
  return 403; 
}

# 强制网站使用域名访问
if ( $host !~* 'doshell.com' ) {
    return 403;
}

# 
```

‍

# 3.location

​`location`​ 表示进行路由的匹配，如果匹配则执行对应代码块里的操作。`location`​ 可以使用 **前缀匹配** 以及 **正则匹配**（需要以 `~*`​ 或 `~`​ 开头）。我们这里的配置使用的是前缀匹配。

```nginx
location   =   /uri     # =开头表示精确前缀匹配，只有完全匹配才能生效
location   ^~  /uri     # ^~开头表示普通字符串匹配上以后不再进行正则匹配
location   ~   pattern  # ~开头表示区分大小写的正则匹配
location   ~*  pattern  # ~*开头表示不区分大小写的正则匹配
location   /uri         # 不带任何修饰符，表示前缀匹配
location   /            # 通用匹配，任何未匹配到其他location的请求都会匹配到

###  location 是否以“／”结尾
# 在 ngnix 中 location 进行的是模糊匹配
# 没有“/”结尾时，location/abc/def  可以匹配 /abc/defghi 请求，也可以匹配 /abc/def/ghi 等
# 而有“/”结尾时，location/abc/def/ 不能匹配 /abc/defghi 请求，只能匹配 /abc/def/anything 这样的请求
```

# 4.alias & root

```nginx
#若用alias的话，则访问127.0.0.1/img/目录里面的文件时，ningx会自去/var/www/image/目录找文件
location /img/ {
    alias /var/www/image/;
}

#若用root的话，则访问/127.0.0.1/img/目录下的文件时，nginx会自动去/var/www/image/img/目录下找文件
location /img/ {
    root /var/www/image;
}

```

‍

‍

# 5.缓存和超时

```nginx
client_body_timeout 10;      # 设置客户端请求主体读取超时时间 
client_header_timeout 10;    # 设置客户端请求头读取超时时间 
keepalive_timeout 55;        # 第一个参数指定客户端连接保持活动的超时时间，第二个参数是可选的，它指定了消息头保持活动的有效时间 
send_timeout 10;             # 指定响应客户端的超时时间

client_header_buffer_size 1k;     # 如果(请求行+请求头)的大小如果没超过1k，放行请求  
large_client_header_buffers 4 8k; # (请求行+请求头)最大不能超过32k(4 * 8k)
client_body_buffer_size 128k;
client_max_body_size 1m;
client_body_temp  /data/nginx/client_body_temp  1 2; # 设置存储用户请求体的文件的目录路径
# 如果请求的数据小于client_body_buffer_size直接将数据先在内存中存储。
# 如果请求的值大于client_body_buffer_size小于client_max_body_size，就会将数据先存储到临时文件中
types_hash_max_size 512; # 影响散列表的冲突率
charset UTF-8    # 设置应答的文字格式。
tcp_nopush  on;  # 数据包会累积一下再一起传输，可以提高一些传输效率
tcp_nodelay on;  # 小的数据包不等待直接传输
```

‍

‍

# 6.状态统计

在 nginx 中，有些时候我们希望能够知道目前到底有多少个客户端连接到了我们的网站。我们希望有这样一个页面来专门统计显示这些情况。这个需求在 nginx 中是可以实现的，我们可以通过简单的配置来实现。

```nginx
server {
  location /status {
    stub_status on;
    access_log off;
    }
  }
```

‍

‍

# 7.目录展示及文件访问

```nginx
# mkdir 
location /mkdir/ {
    alias   /data/nginx/data/;
    auth_basic "welcome!";
    auth_basic_user_file /data/nginx/conf/nginx.passwd;
    limit_req zone=one burst=5;
    limit_rate 50k;
    autoindex on;              # 开启目录浏览功能；
    autoindex_exact_size off;  # 关闭详细文件大小统计，让文件大小显示MB，GB单位，默认为b；
    autoindex_localtime on;    # 开启以服务器本地时区显示文件修改日期！
}
```

‍

# 8.目录保护

> 为了保护隐私或者私密文件我们需要对一些网站进行密码保护，比如比如要对网站目录下的test文件夹进行加密认证，那要如何设置nginx目录密码保护呢？

```nginx
# 1.创建密码文件
yum install -y httpd-tools
htpasswd -c ./htpasswd.nginx user password

# 2.修改nginx.conf
autoindex off;      # 禁止目录浏览
server_tokens off;  # 隐藏版本信息

server {
  location /status {
    stub_status on;
    access_log off;
    auth_basic "hello world";
    auth_basic_user_file /data/nginx/conf/passwd.nginx;
    }
  }
```

‍

# 9.虚拟主机

什么是虚拟主机？虚拟主机是一种特殊的软硬件技术，它可以将网络上的计算机分成多个虚拟主机，每个虚拟主机可以独立对外提供www服务，这样就可以实现一台主机对外提供多个web服务，每个虚拟主机之间独立的，互不影响。

**基于端口**

```nginx

server {
  listen 8080
  server_name doshell.cn;
    location / {
      root /data/web/aaa;
      index index.html;
      }
  }
  
server {
  listen 9090;
  server_name doshell.cn;
    location / {
      root /data/web/bbb;
      index index.html;
      }
  }
```

**基于域名**

```nginx

server {
  listen 8080;
  server_name aaa.doshell.cn;
    location / {
      root /data/web/aaa;
      index index.html;
      }
  }
  
server {
  listen 8080;
  server_name bbb.doshell.cn;
    location / {
      root /data/web/bbb;
      index index.html;
      }
  }
```

# 10.反向代理-http

反向代理，其实客户端对代理是无感知的，因为客户端不需要任何配置就可以访问，我们只需要将请求发送到反向代理服务器，由反向代理服务器去选择目标服务器获取数据后，在返回给客户端，此时反向代理服务器和目标服务器对外就是一个服务器，暴露的是代理服务器地址，隐藏了真实服务器IP地址。

反向代理和正向代理的区别就是：**正向代理代理客户端，反向代理代理服务器。**

```nginx
# proxy_pass 后面有“/”
location /test/ {
    proxy_pass http://127.0.0.1/; 
}
# 访问www.doshell.cn:8001/test/
# 会被映射请求为
# 127.0.0.1/

# proxy_pass 后面没有“/”
location /test/ {
    proxy_pass http://127.0.0.1; 
}
# 访问www.doshell.cn:8001/test/
# 会被映射请求为
# 127.0.0.1/test/

=====================================================
# 反向代理相关参数
proxy_pass  http://127.0.0.1:8010; # 代理服务
proxy_redirect off;          # 是否允许重定向
### 允许重新定义或者添加发往后端服务器的请求头 ###
proxy_set_header Host $host; # 代理服务器本身IP。
proxy_set_header Host $proxy_host;       # 代理服务器请求的host，即后端服务器/源站的IP
proxy_set_header Host $host:$proxy_port; # 代理服务器请求的后端服务器的IP和端口
proxy_set_header X-Real-Ip $remote_addr; # 获取的是前一节点的真实IP的值。
proxy_set_header X-Forwarded-For $remote_addr; # 当只有一层代理服务器的情况下，两者的X-Forwarded-For值一致，都是用户的真实IP。
#############################################
proxy_connect_timeout 90; # 连接代理服务超时时间(发起握手的超时时间)
proxy_send_timeout 90;    # 后端处理完成后,nginx 发送消息的最大时间
proxy_read_timeout 90;    # 连接成功后,等候后端服务器响应时间
proxy_buffer_size 4k;     # 设置缓冲区大小(缓存后端响应的响应头信息)，
proxy_buffers 4 32k;      # 设置缓冲区的数量和大小(缓存响应体)。四个32k的缓存 不够才开辟新的
proxy_busy_buffers_size 64k; # 设置专门划出一部分buffer 向客户端传送数据,其他部分的buffer继续读取后端响应,建议为proxy_buffers中单个缓冲区的2倍,这个缓存 是proxy_buffers和proxy_buffer_size的一部分。
proxy_temp_file_write_size 64k;# 当proxy_buffers和proxy_buffer_size的buffer满时,会将额外的数据存到临时文件,这个值指定临时文件的大小
proxy_cache_path /data/nginx/proxy_temp levels=1:2 keys_zone=CACHE:512m inactive=1d max_size=60g;
```

‍

# 11.反向代理-tcp

nginx1.9以后新增了对tcp协议的支持。[nginx](https://so.csdn.net/so/search?q=nginx\&spm=1001.2101.3001.7020 "nginx")使用了一个新的模块`stream`​ 来支持tcp协议，这个模块与 `http`​ 模块比较类似。安装 nginx 时，需要加上--with-stream --with-stream\_ssl\_module

```nginx
http {
.....
}

# stream 和 http 是同一层级模块
stream {
    upstream cmp_zookeeper {
    server 10.9.71.11:22181;  # 被代理的tcp协议地址
    }
    server {
        listen 2181;
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
        proxy_pass cmp_zookeeper;
    }
}

```

‍

‍

# 12.负载均衡

Web服务器，直接面向用户，往往要承载大量并发请求，单台服务器难以负荷，我使用多台WEB服务器组成集群，前端使用Nginx负载均衡，将请求分散的打到我们的后端服务器集群中，
实现负载的分发。那么会大大提升系统的吞吐率、请求性能、高容灾

![](assets/image-20221127215458444-20230610173812-jt904la.png)

* Nginx要实现负载均衡需要用到proxy\_pass代理模块配置（上一个实验）
* Nginx负载均衡与Nginx代理不同地方在于
* Nginx代理仅代理一台服务器，而Nginx负载均衡则是将客户端请求代理转发至一组upstream虚拟服务池
* Nginx可以配置代理多台服务器，当一台服务器宕机之后，仍能保持系统可用。

**负载均衡4中模式**

* 轮询策略（默认负载均衡策略）
* 最少连接数负载均衡策略
* ip-hash 负载均衡策略
* 权重负载均衡策略

**1. 轮询策略**

轮询负载策略是指每次将请求按顺序轮流发送至相应的服务器上，它的配置示例如下所示：

```nginx
http {
	upstream myapp1 {
    	server srv1.example.com;
    	server srv2.example.com;
    	server srv3.example.com;
    }
  
    server {
	listen 80;
        location / {
        proxy_pass http://myapp1;
        }
    }
}

```

在以上实例中，当我们使用“ip:80/”访问时，请求就会轮询的发送至上面配置的三台服务器上。 Nginx 可以实现 HTTP、HTTPS、FastCGI、uwsgi、SCGI、Memcached 和 gRPC 的负载均衡。

**2. 最少连接数负载均衡**

此策略是指每次将请求分发到当前连接数最少的服务器上，也就是 Nginx 会将请求试图转发给相对空闲的服务器以实现负载平衡，它的配置示例如下：

```nginx
upstream myapp1 {
    least_conn;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}

```

**3. 加权负载均衡**

此配置方式是指每次会按照服务器配置的权重进行请求分发，权重高的服务器会收到更多的请求，这就相当于给 Nginx 在请求分发时加了一个参考的权重选项，并且这个权重值是可以人工配置的。因此我们就可以将硬件配置高，以及并发能力强的服务器的权重设置高一点，以更合理地利用服务器的资源，它配置示例如下：

```nginx
upstream myapp1 {
    server srv1.example.com weight=3;
    server srv2.example.com;
    server srv3.example.com;
}
```

以上配置表示，5 次请求中有 3 次请求会分发给 srv1，1 次请求会分发给 srv2，另外 1 次请求会分发给 srv3。

**4. ip-hash 负载均衡**

以上三种负载均衡的配置策略都不能保证将每个客户端的请求固定的分配到一台服务器上。假如用户的登录信息是保存在单台服务器上的，而不是保存在类似于 Redis 这样的第三方中间件上时，如果不能将每个客户端的请求固定的分配到一台服务器上，就会导致用户的登录信息丢失。因此用户在每次请求服务器时都需要进行登录验证，这样显然是不合理的，也是不能被用户所接受的，所以在特殊情况下我们就需要使用 ip-hash 的负载均衡策略。

ip-hash 负载均衡策略可以根据客户端的 IP，将其固定的分配到相应的服务器上，它的配置示例如下：

```nginx
upstream myapp1 {
    ip_hash;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```

‍

# 13.连接&请求频率限制

## limit_conn_module

使用连接频率限制同一IP同时只能有3个连接

```nginx
#limit_conn_zone 指令可以对单个ip、单个会话同时存在的连接数的限制
limit_conn_zone $binary_remote_addr zone=conn_zone:1m;
server {        
  location / {   
    # 表示该location段使用conn_zone定义的 limit_conn_zone ，对单个IP限制同时存在一个连接
    limit_conn conn_zone 1;
    # 限制下载速度
    limit_rate 100k;
  }
```

‍

‍

## limit_req_module

使用请求频率限制对于同一ip的请求，限制平均速率为5个请求/秒

```nginx

# limit_req_zone 指令可进行限流访问，防止用户恶意攻击刷爆服务器
limit_req_zone $binary_remote_addr zone=req_zone:5m  rate=2r/s;
#$binary_remote_addr --二进制格式的客户端地址
#zone=one:10m        --表示生成一个大小为10M，名字为one的内存区域，用来存储访问的频次信息
#rate=1r/s           --表示允许同一个ip地址客户端的访问频次，这里限制的是每秒1次，即每秒只处理一个请求

server {      
  location / {      
    limit_req zone=req_zone burst=5; # limit_req zone=one burst=5 nodelay; 
# zone=one --设置使用哪个配置区域来做限制，与上面limit_req_zone 里的req_zone对应 
# 设置一个大小为5的缓冲区当有大量请求（爆发）过来时，超过了访问频次限制的请求可以先放到这个缓冲区内等待，但是这个等待区里的位置只有5个，超过的请求会直接报503的错误然后返回。
# nodelay：
  # 如果设置，会在瞬时提供处理(burst+rate)个请求的能力，请求超过（burst+rate）的时候就会直接返回503，永远不存在请求需要等待的情况。（这里的rate的单位是：r/s）
  # 如果没有设置，则所有请求会依次等待排队
  } 
```

‍

# 14.SSL 策略和双向认证

```nginx
################################### 启用ssl  ###################################
server {
	listen 443 ssl;
    server_name www.doshell.cn ;
    ssl_certificate         /data/nginx/ssl/server.crt;   # 证书其实是个公钥，它会被发送到连接服务器的每个客户端
    ssl_certificate_key  /data/nginx/ssl/server.key;  # 私钥是用来解密的，所以它的权限要得到保护但nginx的主进程能够读取。
    ssl_session_cache    shared:SSL:1m;    # 设置ssl/tls会话缓存的类型和大小。
    ssl_session_timeout  5m;                     # 客户端可以重用会话缓存中ssl参数的过期时间
    ssl_protocols TLSv1.2 TLSv1.3;            # 使用特定的加密协议(TLSv1.1与TLSv1.2要确保OpenSSL >= 1.0.1)
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4; # 握手时使用 ECDHE 算法进行密钥交换；用 RSA 签名和身份认证；握手后的通信使用 AES 对称算法，密钥长度 256 位；分组模式是 GCM， 摘要算法 SHA384 用于消息认证和产生随机数
    ssl_prefer_server_ciphers  on;              # 设置协商加密算法时，优先使用我们服务端的加密套件
    # 双向认证
    ssl_client_certificate /data/nginx/ssl/ca.crt; # 根级证书公钥，用于验证各个二级client
    ssl_verify_client on;    # 启用客户端证书审核
    ssl_verify_depth  2;    # 设置客户证书认证链的长度
    location / {
        proxy_pass  http://127.0.0.1:8080 ;
    }
}
################################### 启用双向认证 ###################################
## 使用openssl生成证书
### 创建根证私钥
openssl genrsa -out root-key.key 1024
### 创建根证书请求文件
openssl req -new -out root-req.csr -key root-key.key
### 自签根证书
openssl x509 -req -in root-req.csr -out root-cert.cer -signkey root-key.key -CAcreateserial -days 365
### 生成p12格式根证书，密码123456
openssl pkcs12 -export -clcerts -in root-cert.cer -inkey root-key.key -out root.p12
### 生成服务端ley
openssl genrsa -out  server-key.key 1024
### 生成服务端请求文件
openssl req -new -out server-req.csr -key server-key.key
### 生成服务端证书（root证书，rootkey，服务端key，服务端请求文件这4个生成服务端证书）
openssl x509 -req -in server-req.csr -out server-cert.cer -signkey server-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 365
### 生成客户端key
openssl genrsa -out client-key.key 1024
### 生成客户端请求文件
openssl req -new -out client-req.csr -key client-key.key
### 生成客户端证书（root证书，rootkey，客户端key，客户端请求文件这4个生成客户端证书）
openssl x509 -req -in client-req.csr -out client-cert.cer -signkey client-key.key -CA root-cert.cer -CAkey root-key.key -CAcreateserial -days 365
### 生成客户端p12格式根证书  密码123456
openssl pkcs12 -export -clcerts -in client-cert.cer -inkey client-key.key -out client.p12

#
server {
    listen       443 ssl;
    server_name  www.doshell.cn;
    ssl_certificate      /data/sslKey/server-cert.cer;  # server证书公钥
    ssl_certificate_key  /data/sslKey/server-key.key;   # server私钥
    ssl_client_certificate /data/sslKey/root-cert.cer;  # 根级证书公钥，用于验证各个二级client
    ssl_verify_client on;  # 开启客户端证书验证 
}
```

# 15.启用ipv6

安装 nginx 时，需要将--with-ipv6 模块开启(1.3版本以上自动支持)

```nginx
# 修改nginx.conf
server {
  listen 80 ssl;
  listen [::]:80 ssl ipv6only=on;
  server_name www.doshell.cn;
  ssl_certificate     /data/nginx/ssl/nginx.crt;
  ssl_certificate_key /data/nginx/ssl/nginx.key;
  
    location / {
      root /data/web/client/;
      index index.html;
      }
  }
```

‍

# 16.配置WebDav

_DAV_的意思是“Distributed Authoring and Versioning”。RFC 2518为HTTP 1.1定义了一组概念和附加扩展方法来把web变成一个更加普遍的读/写媒体，基本思想是一个WebDAV兼容的web服务器可以像普通的文件服务器一样工作；客户端可以通过HTTP装配类似于NFS或SMB的WebDAV共享文件夹。

```bash
# 1.下载ngx-dav-ext-module
git clone --recursive https://github.com/arut/nginx-dav-ext-module

# 2.下载和自己原有的Nginx版本相同的源码包并解压

# 3.备份远nginx目录，保留nginx.conf

# 4.重新编译安装nginx
+ --with-http_dav_module --add-module=/opt/nginx-dav-ext-module

# 5.安装
make && make install
```

配置httpd-tools，参考((20230620221010-rqw6lbt '5.目录保护'))

```nginx
# 添加webdav配置
###################### obsidian-webdav

    server {
        listen       11052 ssl;
        server_name  www.doshell.cn;
        #证书文件名称
        ssl_certificate /data/nginx/ssl/doshell.crt;
        #私钥文件名称
        ssl_certificate_key /data/nginx/ssl/doshell.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;
        #access_log  logs/host.access.log  main;

		location /obsidian {
            charset utf-8;
            client_max_body_size 1G; # 最大允许上传文件大小
            alias /data/webdav;
            index index.html index.htm;
            autoindex on;
            # autoindex_localtime on;
            set $dest $http_destination;
            # 对目录请求、对URI自动添加"/"
            if (-d $request_filename) {
            rewrite ^(.*[^/])$ $1/;
            set $dest $dest/;
            }
            client_body_temp_path /tmp;
            dav_methods PUT DELETE MKCOL COPY MOVE; #DAV支持的请求方法
            dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK; # DAV扩展支持的请求方法
            create_full_put_path on;  # 启用创建目录支持
            dav_access group:rw all:r; # 创建文件的以及目录的访问权限
            # auth_basic "Authorized Users WebDAV";
            auth_basic "user login";
            auth_basic_user_file /data/nginx/.httpasswd;

        }
    }
```

‍

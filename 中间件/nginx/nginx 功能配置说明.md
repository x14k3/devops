#middleware/nginx


## 1.状态统计

在 nginx 中，有些时候我们希望能够知道目前到底有多少个客户端连接到了我们的网站。我们希望有这样一个页面来专门统计显示这些情况。这个需求在 nginx 中是可以实现的，我们可以通过简单的配置来实现。

```nginx
server {
  location /status {
    stub_status on;
    access_log off;
    }
  }
```

## 2.alias & root

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

## 3.目录展示及文件访问

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

## 4.虚拟主机
什么是虚拟主机？虚拟主机是一种特殊的软硬件技术，它可以将网络上的计算机分成多个虚拟主机，每个虚拟主机可以独立对外提供www服务，这样就可以实现一台主机对外提供多个web服务，每个虚拟主机之间独立的，互不影响。

==基于端口==

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


==基于域名==

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

## 5.location {}

`location` 表示进行路由的匹配，如果匹配则执行对应代码块里的操作。`location` 可以使用 **前缀匹配** 以及 **正则匹配**（需要以 `~*` 或 `~` 开头）。我们这里的配置使用的是前缀匹配。

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

## 6.反向代理

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
```

## 7.负载均衡

Web服务器，直接面向用户，往往要承载大量并发请求，单台服务器难以负荷，我使用多台WEB服务器组成集群，前端使用Nginx负载均衡，将请求分散的打到我们的后端服务器集群中，
实现负载的分发。那么会大大提升系统的吞吐率、请求性能、高容灾

![](assets/nginx%20功能配置说明/image-20221127215458444.png)

*   Nginx要实现负载均衡需要用到proxy\_pass代理模块配置（上一个实验）

*   Nginx负载均衡与Nginx代理不同地方在于

*   Nginx代理仅代理一台服务器，而Nginx负载均衡则是将客户端请求代理转发至一组upstream虚拟服务池

*   Nginx可以配置代理多台服务器，当一台服务器宕机之后，仍能保持系统可用。

**负载均衡4中模式**

*   轮询策略（默认负载均衡策略）

*   最少连接数负载均衡策略

*   ip-hash 负载均衡策略

*   权重负载均衡策略

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


## 8.反向代理tcp协议

nginx1.9以后新增了对tcp协议的支持。[nginx](https://so.csdn.net/so/search?q=nginx\&spm=1001.2101.3001.7020 "nginx")使用了一个新的模块`stream` 来支持tcp协议，这个模块与 `http` 模块比较类似。安装 nginx 时，需要加上--with-stream --with-stream\_ssl\_module

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

## 9.启用ipv6

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

## 10.配置WebDav
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
配置httpd-tools
参考[[nginx 安全及优化#2、目录保护]]

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

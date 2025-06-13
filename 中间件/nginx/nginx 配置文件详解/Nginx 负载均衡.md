

Nginx提供了多种负载均衡算法, 最常见的有5种。我们只需修改对应upstream模块即可。

### 轮询(默认)

每个请求按时间顺序逐一分配到不同的后端服务器，如果后端服务器down掉，能自动剔除;

```nginx
# 轮询，大家权重一样
upstream backend_server {
   server 192.168.0.1:8000;
   server 192.168.0.2:8000;
   server 192.168.0.3:8000 down; # 不参与负载均衡
   server 192.168.0.4:8001 backup; # 热备
}

server {
   listen          80;
   server_name     big.server.com;
   access_log      logs/big.server.access.log main;
  
   charset utf-8;
   client_max_body_size 10M; # 限制用户上传文件大小，默认1M

   location / {
     # 使用proxy_pass转发请求到通过upstream定义的一组应用服务器
     proxy_pass      http://backend_server;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header Host $http_host;
     proxy_redirect off;
     proxy_set_header X-Real-IP  $remote_addr;
   }
```

### 权重(weight)

通过weight指定轮询几率，访问比率与weight成正比，常用于后端服务器性能不均的情况。不怎么忙的服务器可以多承担些任务。

```hash
# 权重，weight越大，承担任务越多
upstream backend_server {
   server 192.168.0.1:8000 weight=3;
   server 192.168.0.2:8000 weight=1;
}
```

### ip\_hash

每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器，可以解决session的问题。

```highlight
# 权重，weight越大，承担任务越多
upstream backend_server {
   ip_hash;
   server 192.168.0.1:8000;
   server 192.168.0.2:8000;
}
```

### url\_hash

按访问url的hash结果来分配请求，使每个url定向到同一个后端服务器，后端服务器为缓存时比较有效。

```highlight
# URL Hash
upstream backend_server {
   hash $request_uri;
   server 192.168.0.1:8000;
   server 192.168.0.2:8000;
}
```

### fair(第三方)

按后端服务器的响应时间来分配请求，响应时间短的优先分配。使用这个算法需要安装`nginx-upstream-fair`​这个库。

```highlight
# Fair
upstream backend_server {
   server 192.168.0.1:8000;
   server 192.168.0.2:8000;
   fair;
}
```

‍

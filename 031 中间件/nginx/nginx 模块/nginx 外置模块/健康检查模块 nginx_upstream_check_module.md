# 健康检查模块 nginx_upstream_check_module

大家都知道，前端nginx做反代，如果后端服务器宕掉的话，nginx是不能把这台realserver剔除upstream的，所以还会有请求转发到后端的这台realserver上面去，虽然nginx可以在localtion中启用proxy_next_upstream来解决返回给用户的错误页面，但这个还是会把请求转发给这台服务器的，然后再转发给别的服务器，这样就浪费了一次转发，这次借助与淘宝技术团队开发的nginx模快nginx_upstream_check_module来检测后方realserver的健康状态，如果后端服务器不可用，则所以的请求不转发到这台服务器

下载，当前下载0.3版本  
​`wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz`​

​`--add-module=/xxx`​

在http区块添加

```c
upstream web_pool {
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

在server区块添加

```c
upstream web_pool {
    zone test_pool 64k;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
    check interval=3000 rise=2 fall=3 timeout=3000 type=http;
    #interval检测间隔时间，默认毫秒，当前3秒
    #rise表示请求2次，正常认为节点正常
    #fall表示请求失败3次，则认为节点失败
    #timout超时时间，默认毫秒，当前3秒
    #type，类型，当前http类型

    check_http_send "GET /status.html HTTP/1.0\r\n\r\n";
    check_http_expect_alive http_2xx http_3xx;
    #分发节点轮询检测后端节点的url/status.html ，如果返回2xx或者3xx认为正常，否则认为失败一次
}

server {
    listen 80;
    server_name xx;

location / {
    proxy_pass http://web_pool;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}

location /status { #可以图形查询到节点状态和一些信息
    check_status; #访问http://xxxx/status可以查询
    access_log off;
    #allow all;
    #deny all;
}
```

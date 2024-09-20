# nginx 配置文件详解

* 📄 [Nginx Location配置](siyuan://blocks/20240801141732-2y8nh4m)
* 📄 [Nginx 基础功能配置集合](siyuan://blocks/20231110105237-a779ski)
* 📄 [Nginx与uWSGI服务器的沟通](siyuan://blocks/20240801142155-4l40gf4)
* 📄 [Nginx双向认证](siyuan://blocks/20231110105237-8uzmy1l)
* 📄 [Nginx反向代理-http](siyuan://blocks/20231110105237-x20efse)
* 📄 [Nginx反向代理-tcp](siyuan://blocks/20231110105237-yyxt7uz)
* 📄 [Nginx日志配置](siyuan://blocks/20240801142004-571rmg7)
* 📄 [Nginx负载均衡](siyuan://blocks/20240801142102-6ajyu1v)
* 📄 [Nginx超时设置](siyuan://blocks/20240801142023-1ilarhh)
* 📄 [Nginx跨域问题](siyuan://blocks/20240321203341-ncktrie)
* 📄 [Nginx配置HTTPS](siyuan://blocks/20240801141924-g9hldza)
* 📄 [Nginx静态文件配置](siyuan://blocks/20240801141831-veg230h)
* 📄 [配置案例](siyuan://blocks/20240910101400-s9d8vsr)

## Nginx配置文件构成

　　一个Nginx配置文件通常包含3个模块：

* 全局块：比如工作进程数，定义日志路径；
* Events块：设置处理轮询事件模型，每个工作进程最大连接数及http层的keep-alive超时时间；
* http块：路由匹配、静态文件服务器、反向代理、负载均衡等。

　　其中http块又可以进一步分成3块，http全局块里的配置对所有站点生效，server块配置仅对单个站点生效，而location块的配置仅对单个页面或url生效。

### Nginx配置文件示例

```nginx
# 全局块
user www-data;
worker_processes  2;  ## 默认1，一般建议设成CPU核数1-2倍
error_log  logs/error.log; ## 错误日志路径
pid  logs/nginx.pid; ## 进程id

# Events块
events {
  # 使用epoll的I/O 模型处理轮询事件。
  # 可以不设置，nginx会根据操作系统选择合适的模型
  use epoll;
  
  # 工作进程的最大连接数量, 默认1024个
  worker_connections  2048;
  
  # http层面的keep-alive超时时间
  keepalive_timeout 60;
  
  # 客户端请求头部的缓冲区大小
  client_header_buffer_size 2k;
}

http { # http全局块
 
  include mime.types;  # 导入文件扩展名与文件类型映射表
  default_type application/octet-stream;  # 默认文件类型
  
  # 日志格式及access日志路径
  log_format   main '$remote_addr - $remote_user [$time_local]  $status '
    '"$request" $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
  access_log   logs/access.log  main;
  
  # 允许sendfile方式传输文件，默认为off。
  sendfile     on;
  tcp_nopush   on; # sendfile开启时才开启。

  # http server块
  # 简单反向代理
  server {
    listen       80;
    server_name  domain2.com www.domain2.com;
    access_log   logs/domain2.access.log  main;
   
    # 转发动态请求到web应用服务器
    location / {
      proxy_pass      http://127.0.0.1:8000;
      deny 192.24.40.8;  # 拒绝的ip
      allow 192.24.40.6; # 允许的ip   
    }
  
    # 错误页面
    error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
  }

  # 负载均衡
  upstream backend_server {
    server 192.168.0.1:8000 weight=5; # weight越高，权重越大
    server 192.168.0.2:8000 weight=1;
    server 192.168.0.3:8000;
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
  
  }
}
```

　　接下来，我们仔细分析下Nginx各个模块的配置选项。

　　‍

　　‍

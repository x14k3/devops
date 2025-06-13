

在前面的案例中，Nginx都是使用`proxy_pass`​转发的动态请求，`proxy_pass`​使用普通的HTTP协议与应用服务器进行沟通。如果你部署的是Python Web应用(Django, Flask), 你的应用服务器(`uwsgi`​, `gunicorn`​)一般是遵守uwsgi协议的，对于这种情况，建议使用`uwsgi_pass`​转发请求。

### Python Web应用部署负载均衡Nginx配置文件参考

如果你部署的是Django或则Flask Web应用，一个完整的nginx配置文件如下所示：

```nginx
# nginx配置文件，nginx.conf

# 全局块
user www-data;
worker_processes  2;  ## 默认1，一般建议设成CPU核数1-2倍

# Events块
events {
  # 使用epoll的I/O 模型处理轮询事件。
  # 可以不设置，nginx会根据操作系统选择合适的模型
  use epoll;
  
  # 工作进程的最大连接数量, 默认1024个
  worker_connections  2048;
  
  # http层面的keep-alive超时时间
  keepalive_timeout 60;
  
}

http {  
    # 开启gzip压缩功能
    gzip on;
  
    # 设置允许压缩的页面最小字节数; 这里表示如果文件小于10k，压缩没有意义.
    gzip_min_length 10k; 
  
    # 设置压缩比率，最小为1，处理速度快，传输速度慢；
    # 9为最大压缩比，处理速度慢，传输速度快; 推荐6
    gzip_comp_level 6; 
  
    # 设置压缩缓冲区大小，此处设置为16个8K内存作为压缩结果缓冲
    gzip_buffers 16 8k; 
  
    # 设置哪些文件需要压缩,一般文本，css和js建议压缩。图片视需要要锁。
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript; 
  
  
    upstream backend_server {
        server 192.168.0.1:8000; # 替换成应用服务器或容器实际IP及端口
        server 192.168.0.2:8000;
    }

    server {
        listen 80; # 监听80端口
        server_name localhost; # 可以是nginx容器所在ip地址或127.0.0.1，不能写宿主机外网ip地址

        charset utf-8;
        client_max_body_size 10M; # 限制用户上传文件大小
    
         # 客户端请求头部的缓冲区大小
        client_header_buffer_size 2k;
        client_header_timeout 15;
        client_body_timeout 15;
  
        access_log /var/log/nginx/mysite1.access.log main;
        error_log /var/log/nginx/mysite1.error.log warn;
    
        # 静态资源路径
        location /static {
            alias /usr/share/nginx/html/static; 
        }
    
        # 媒体资源路径，用户上传文件路径
        location /media {
            alias /usr/share/nginx/html/media;
        }

        location / {   
            include /etc/nginx/uwsgi_params;
            uwsgi_pass backend_server;   # 使用uwsgi_pass, 而不是proxy_pass
            uwsgi_read_timeout 600; # 指定接收uWSGI应答的超时时间
            uwsgi_connect_timeout 600;  # 指定连接到后端uWSGI的超时时间。
            uwsgi_send_timeout 600; # 指定向uWSGI传送请求的超时时间

            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header X-Real-IP  $remote_addr;
        }
    }
  
} 


```

如果你的nginx与uwsgi在同一台服务器上，用不到负载均衡，你还可以通过本地机器的unix socket进行通信，这样速度更快，如下所示：

```highlight
location / {   
    include /etc/nginx/uwsgi_params;
    uwsgi_pass unix:/run/uwsgi/django_test1.sock;
}
```

**注意**：取决于Nginx采用那种方式与uWSGI服务器进行通信(本地socket, 网络TCP socket和http协议)，uWSGI的配置文件也会有所不同。这里以`uwsgi.ini`​为例展示了不同。

```highlight
# uwsgi.ini配置文件

# 对于uwsgi_pass转发的请求，使用本地unix socket通信
# 仅适用于nginx和uwsgi在同一台服务器上的情形
socket=/run/uwsgi/django_test1.sock

# 对于uwsgi_pass转发的请求，使用TCP socket通信
socket=0.0.0.0:8000

# 对于proxy_pass HTTP转发的请求，使用http协议
http=0.0.0.0:8000
```

‍

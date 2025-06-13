

[Nginx 双向认证](Nginx%20双向认证.md)

```nginx
# 负载均衡，设置HTTPS
upstream backend_server {
    server APP_SERVER_1_IP;
    server APP_SERVER_2_IP;
}

# 禁止未绑定域名访问，比如通过ip地址访问
# 444:该网页无法正常运作，未发送任何数据
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

# HTTP请求重定向至HTTPS请求
server {
    listen 80;
    listen [::]:80;
    server_name your_domain.com;
  
    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://backend_server; 
     }
  
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name your_domain.com;

    # ssl证书及密钥路径
    ssl_certificate /path/to/your/fullchain.pem;
    ssl_certificate_key /path/to/your/privkey.pem;

    # SSL会话信息
    client_max_body_size 75MB;
    keepalive_timeout 10;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://django; # Django+uwsgi不在本机上，使用代理转发
    }

}
```

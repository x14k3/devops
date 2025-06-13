

Nginx提供了很多超时设置选项，目的是保护服务器资源，CPU，内存并控制连接数。你可以根据实际项目需求在全局块、Server块和Location块进行配置。

### 请求超时设置

```nginx
# 客户端连接保持会话超时时间，超过这个时间，服务器断开这个链接。
keepalive_timeout 60;

# 设置请求头的超时时间，可以设置低点。
# 如果超过这个时间没有发送任何数据，nginx将返回request time out的错误。
client_header_timeout 15;

# 设置请求体的超时时间，可以设置低点。
# 如果超过这个时间没有发送任何数据，nginx将返回request time out的错误。
client_body_timeout 15;

# 响应客户端超时时间
# 如果超过这个时间，客户端没有任何活动，nginx关闭连接。
send_timeout 15;

# 上传文件大小限制
client_max_body_size 10m;

# 也是防止网络阻塞，不过要包涵在keepalived参数才有效。
tcp_nodelay on;

# 客户端请求头部的缓冲区大小，这个可以根据你的系统分页大小来设置。
# 一般一个请求头的大小不会超过 1k，不过由于一般系统分页都要大于1k
client_header_buffer_size 2k;

# 这个将为打开文件指定缓存，默认是没有启用的。
# max指定缓存数量，建议和打开文件数一致，inactive 是指经过多长时间文件没被请求后删除缓存。
open_file_cache max=102400 inactive=20s;

# 这个是指多长时间检查一次缓存的有效信息。
open_file_cache_valid 30s;

# 告诉nginx关闭不响应的客户端连接。这将会释放那个客户端所占有的内存空间。
reset_timedout_connection on;
```

### Proxy反向代理超时设置

```nginx
# 该指令设置与upstream服务器的连接超时时间，这个超时建议不超过75秒。
proxy_connect_timeout 60;

# 该指令设置应用服务器的响应超时时间，默认60秒。
proxy_read_timeout 60；

# 设置了发送请求给upstream服务器的超时时间
proxy_send_timeout 60;

# max_fails设定Nginx与upstream服务器通信的尝试失败的次数。
# 在fail_timeout参数定义的时间段内，如果失败的次数达到此值，Nginx就认为服务器不可用。
upstream big_server_com {
   server 192.168.0.1:8000 weight=5  max_fails=3 fail_timeout=30s; # weight越高，权重越大
   server 192.168.0.2:8000 weight=1  max_fails=3 fail_timeout=30s;
   server 192.168.0.3:8000;
   server 192.168.0.4:8001 backup; # 热备
}
```


‍

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

## 反向代理相关参数

```nginx
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

## proxy\_pass url 反向代理的坑

说到 Nginx 就不得不说 Nginx 的反向代理是多么的好用，一个指令 `proxy_pass`​ 搞定反向代理，对于接口代理、负载均衡很是实用，但 `proxy_pass`​ 指令后面的参数很有讲究。

网上有很多什么绝对路径、相对路径的说法，其实在实际的应用中就分为两种情况：

‍

### url 只是 host

这里指不包含 `$uri`​ ，如：

- ​`http://host`​ - √
- ​`https://host`​ - √
- ​`http://host:port`​ - √
- ​`https://host:port`​ - √
- ​`http://host/`​ - x
- ​`http://host:port/`​ - x

这时候 `location`​ 匹配的完整路径将直接透传给 url ，如：

```nginx
// 访问：   /                               后端：   /
// 访问：   /api/xx                         后端：   /api/xx
// 访问：   /api/xx?aa                      后端：   /api/xx?aa
location / {
    proxy_pass http://node:8080;
}

// 访问：   /api/                           后端：   /api/
// 访问：   /api/xx                         后端：   /api/xx
// 访问：   /api/xx?aa                      后端：   /api/xx?aa
// 访问：   /api-xx?aa                      后端：
location /api/ {
    proxy_pass http://node:8080;
}

// 访问：   /api/                           后端：   /api/
// 访问：   /api/xx                         后端：   /api/xx
// 访问：   /api/xx?aa                      后端：   /api/xx?aa
// 访问：   /api-xx?aa                      后端：   /api-xx?aa
location /api {
    proxy_pass http://node:8080;
}
```

‍

### url 包含路径

注意，这里的路径哪怕只是一个 `/`​ 也是存在的，如：

- ​`http://host`​ - x
- ​`https//host/`​ - √
- ​`http://host:port`​ - x
- ​`https://host:port/`​ - √
- ​`http://host/api`​ - √
- ​`http://host/api/`​ - √

当 `proxy_pass url`​ 的 `url`​ 包含路径时，匹配时会根据 `location`​ 的匹配后的链接透传给 `url`​ ，注意匹配后就是这样：

|​`location`​ 规则|访问的原始链接|匹配之后的路径|
| -----------| ----------------| ----------------|
|​`location /`​|​`/`​||
|​`location /`​|​`/a`​|​`a`​|
|​`location /`​|​`/a/b/c?d`​|​`a/b/c?d`​|
|​`location /a/`​|​`/a/`​||
|​`location /a/`​|​`/a/b/c?d`​|​`b/c?d`​|

明白匹配之后的路径后，在 `proxy_pass url`​ 包含路径时，将会把匹配之后的路径透传给 `url`​ ，如：

```nginx
// 访问：   /                               后端：   /
// 访问：   /api/xx                         后端：   /api/xx
// 访问：   /api/xx?aa                      后端：   /api/xx?aa
location / {
    proxy_pass http://node:8080/;
}

// 访问：   /api/                           后端：   /
// 访问：   /api/xx                         后端：   /xx
// 访问：   /api/xx?aa                      后端：   /xx?aa
// 访问：   /api-xx?aa                      未匹配
location /api/ {
    proxy_pass http://node:8080/;
}

// 访问：   /api                            后端：   /
// 访问：   /api/                           后端：   //
// 访问：   /api/xx                         后端：   //xx
// 访问：   /api/xx?aa                      后端：   //xx?aa
// 访问：   /api-xx?aa                      后端：   /-xx?aa
location /api {
    proxy_pass http://node:8080/;
}

// 访问：   /api/                           后端：   /v1
// 访问：   /api/xx                         后端：   /v1xx
// 访问：   /api/xx?aa                      后端：   /v1xx
// 访问：   /api-xx?aa                      未匹配
location /api/ {
    proxy_pass http://node:8080/v1;
}

// 访问：   /api/                           后端：   /v1/
// 访问：   /api/xx                         后端：   /v1/xx
// 访问：   /api/xx?aa                      后端：   /v1/xx
// 访问：   /api-xx?aa                      未匹配
location /api/ {
    proxy_pass http://node:8080/v1/;
}
```

由以上规则可以看出，当 `proxy_pass url`​ 中包含路径时，结尾的 `/`​ 最好同 `location`​ 匹配规则一致。

‍

‍

### **特殊场景处理**

**匹配模式**：

- ​`~`​：区分大小写的正则匹配
- ​`~*`​：不区分大小写的正则匹配
- ​`^/(.*/)?api(/|$)`​：匹配包含 `/api/`​ 的路径（如 `/api/user`​ 或 `/v1/api/profile`​）
- ​`~* admin`​：匹配包含 "admin" 的任意路径（如 `/admin`​ 或 `/user/ADMIN/settings`​）

```nginx
# 匹配关键字但不传递原始路径（移除关键字前缀）
location ~ ^/proxy/(.*) {
    proxy_pass http://127.0.0.1:8090/$1;  # 移除 "/proxy/" 前缀
}

# 匹配关键字并保留完整路径
location ~ \.php$ {
    proxy_pass http://127.0.0.1:8090;  # 转发所有.php结尾的请求
}
```

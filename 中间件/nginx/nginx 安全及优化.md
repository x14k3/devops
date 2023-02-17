#middleware/nginx
 

### 1、禁止目录浏览/隐藏版本信息

```nginx
autoindex off;      # 禁止目录浏览
server_tokens off;  # 隐藏版本信息

# 子文件
http {
    include /etc/nginx/conf.d/*.conf;
}
```

### 2、目录保护

> 为了保护隐私或者私密文件我们需要对一些网站进行密码保护，比如比如要对网站目录下的test文件夹进行加密认证，那要如何设置nginx目录密码保护呢？

```nginx
# 1.创建密码文件
yum install -y httpd-tools
htpasswd -c ./htpasswd.nginx user password

# 2.修改nginx.conf
server {
  location /status {
    stub_status on;
    access_log off;
    auth_basic "hello world";
    auth_basic_user_file /data/nginx/conf/passwd.nginx;
    }
  }
```

### 3、请求、连接限制

==连接频率限制 : limit_conn_module==
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

==请求频率限制 : limit_req_module ==
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




### 4、控制超时时间

```nginx
client_body_timeout 10;     # 设置客户端请求主体读取超时时间 
client_header_timeout 10;  # 设置客户端请求头读取超时时间 
keepalive_timeout 55;        # 第一个参数指定客户端连接保持活动的超时时间，第二个参数是可选的，它指定了消息头保持活动的有效时间 
send_timeout 10;               # 指定响应客户端的超时时间

```

### 5、自定义缓存

```nginx
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

### 6、限制IP访问

```nginx
location / { 
  deny 192.168.1.1;       # 拒绝IP
  allow 192.168.1.0/24; # 允许IP 
  allow 10.1.1.0/16;      # 允许IP 
  deny all;                    # 拒绝其他所有IP 
}
```

### 7、其他限制

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

### 8、SSL 策略和双向认证

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

### 9、反向代理相关参数

```nginx
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

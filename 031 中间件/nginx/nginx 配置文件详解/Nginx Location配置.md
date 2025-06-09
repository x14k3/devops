# Nginx Location配置

Nginx Location配置是Nginx的核心配置，它负责匹配请求的url, 并根据Location里定义的规则来处理这个请求，比如拒绝、转发、重定向或直接提供文件下载。

### URL匹配方式及优先级

Nginx的Location配置支持普通字符串匹配和正则匹配，不过url的各种匹配方式是有优先级的，如下所示：

|匹配符|匹配规则|优先级|
| -------------| ------------------------------| --------|
|\=|精确匹配|1|
|\^\~|以某个字符串开头|2|
|\~|区分大小写的正则匹配|3|
|\~\*|不区分大小写的正则匹配|4|
|!\~|区分大小写的不匹配正则|5|
|!\~\*|不区分大小写的不匹配正则|6|
|/|通用匹配，任何请求都会匹配到|7|

为了加深你的理解，我们来看如下一个例子。由于规则2的优先级更高，当用户访问`/static/`​或则`/static/123.html`​时，Nginx会优先执行规则2里的操作，其它的的请求则会交由规则1执行。

```highlight
# 规则1：通用匹配
location / {
}

# 规则2：处理以/static/开头的url
location ^~ /static {                     
    alias /usr/share/nginx/html/static; # 静态资源路径
}
```

**注意**：上例中我们使用了`alias`​别名设置了静态文件所在目录，我们还可以使用`root`​指定静态文件目录。注意：`alias`​和`root`​是有区别的。

- ​`root`​对路径的处理：root路径 ＋ location路径
- ​`alias`​对路径的处理：使用alias路径替换location路径

如果用`root`​设置静态文件资源路径，可以按如下代码设置。两者是等同的。

```highlight
# 规则2：处理以/static/开头的url
location ^~ /static {                     
    root /usr/share/nginx/html; # 静态资源路径
}
```

Location还支持正则匹配，比如下例可以禁止用户访问所有的图片格式文件。

```highlight
# 拒绝访问所有图片格式文件
location ~* .*\.(jpg|gif|png|jpeg)$ {
        deny all;
}
```

### 请求转发和重定向

另一个我们在Location块里经常配置的就是转发请求或重定向，如下例所示：

```highlight
# 转发动态请求
server {  
    listen 80;                                                     
    server_name  localhost;                                           
    client_max_body_size 1024M;

    location / {
        proxy_pass http://localhost:8080;   
        proxy_set_header Host $host:$server_port;
    }
}

# http请求重定向到https请求
server {
    listen 80;
    server_name domain.com;
    return 301 https://$server_name$request_uri;
}
```

无论是转发请求还是重定向，我们都使用了以`$`​符号开头的变量，这些都是Nginx提供的全局变量。它们的具体含义如下所示：

```highlight
$args, 请求中的参数;
$content_length, HTTP请求信息里的"Content-Length";
$content_type, 请求信息里的"Content-Type";
$document_root, 针对当前请求的根路径设置值;
$document_uri, 与$uri相同;
$host, 请求信息中的"Host"，如果请求中没有Host行，则等于设置的服务器名;
$limit_rate, 对连接速率的限制;
$request_method, 请求的方法，比如"GET"、"POST"等;
$remote_addr, 客户端地址;
$remote_port, 客户端端口号;
$remote_user, 客户端用户名，认证用;
$request_filename, 当前请求的文件路径名
$request_body_file,当前请求的文件
$request_uri, 请求的URI，带查询字符串;
$query_string, 与$args相同;
$scheme, 所用的协议，比如http或者是https，比如rewrite ^(.+)$ $scheme://example.com$1 redirect;
$server_protocol, 请求的协议版本，"HTTP/1.0"或"HTTP/1.1";
$server_addr, 服务器地址;
$server_name, 请求到达的服务器名;
$server_port, 请求到达的服务器端口号;
$uri, 请求的URI，可能和最初的值有不同，比如经过重定向之类的。
```

知道这些全局变量的含义后，我们就可以限制用户的请求方法。比如下例中配置了只允许用户通过POST方法访问，其他的请求方法则返回405。

```highlight
if ($request_method !~ ^(GET|POST)$ ) { return 405; }
```

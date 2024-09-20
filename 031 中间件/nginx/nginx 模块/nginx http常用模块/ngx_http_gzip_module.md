# ngx_http_gzip_module

　　​`ngx_http_gzip_module`​ 模块是一个使用了 **gzip** 方法压缩响应的过滤器。有助于将传输数据的大小减少一半甚至更多。

　　‍

## 编译参数如下

　　已默认内置

```bash

./configure --prefix=/data/nginx --with-http_gzip_module
```

## 示例配置

```
gzip            on;
gzip_min_length 1000;
gzip_proxied    expired no-cache no-store private auth;
gzip_types      text/plain application/xml;
```

　　​`$gzip_ratio`​ 变量可用于记录实现的压缩比率。

　　‍

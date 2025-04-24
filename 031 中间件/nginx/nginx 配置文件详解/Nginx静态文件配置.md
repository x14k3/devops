# Nginx静态文件配置

Nginx可直接作为强大的静态文件服务器使用，支持对静态文件进行缓存还可以直接将Nginx作为文件下载服务器使用。

### 静态文件缓存

缓存可以加快下次静态文件加载速度。我们很多与网站样式相关的文件比如css和js文件一般不怎么变化，缓存有效器可以通过`expires`​选项设置得长一些。

```nginx
    # 使用expires选项开启静态文件缓存，10天有效
    location ~ ^/(images|javascript|js|css|flash|media|static)/  {
      root    /var/www/big.server.com/static_files;
      expires 10d;
    }
```

### 静态文件压缩

Nginx可以对网站的css、js 、xml、html 文件在传输前进行压缩，大幅提高页面加载速度。经过Gzip压缩后页面大小可以变为原来的30%甚至更小。使用时仅需开启Gzip压缩功能即可。你可以在http全局块或server块增加这个配置。

```nginx
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
  
} 
```

### 文件下载服务器

Nginx也可直接做文件下载服务器使用，在location块设置`autoindex`​相关选项即可。

```nginx
server {

    listen 80 default_server;
    listen [::]:80 default_server;
    server_name  _;
  
    location /download {  
        # 下载文件所在目录
        root /usr/share/nginx/html;
    
        # 开启索引功能
        autoindex on;  
    
        # 关闭计算文件确切大小（单位bytes），只显示大概大小（单位kb、mb、gb）
        autoindex_exact_size off; 
    
        #显示本机时间而非 GMT 时间
        autoindex_localtime on;   
            
        # 对于txt和jpg文件，强制以附件形式下载，不要浏览器直接打开
        if ($request_filename ~* ^.*?\.(txt|jpg|png)$) {
            add_header Content-Disposition 'attachment';
        }
    }
}
```

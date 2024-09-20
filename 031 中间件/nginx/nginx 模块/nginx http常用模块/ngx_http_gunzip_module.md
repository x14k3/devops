# ngx_http_gunzip_module

　　​`ngx_http_gunzip_module`​ 模块是一个过滤器，用于对不支持 **gzip** 编码方法的客户端解压缩 `Content-Encoding：gzip`​ 的响应。当需要存储压缩数据以节省空间并降低 I/O 成本时，该模块将非常有用。

　　此模块不是默认构建，您可以使用 `--with-http_gunzip_module`​ 配置参数启用。

## 示例配置

```
location /storage/ {
    gunzip on;
    ...
}
```

## 指令

### gunzip

|-|说明|
| ---| ------------------------|
|**语法**|**gunzip** `on`​\|`off`​;|
|**默认**|gunzip off;|
|**上下文**|http、server、location|

　　对缺少 gzip 支持的客户端启用或禁用 gzip 响应解压缩。如果开启，在确定客户端是否支持 gzip 时还会考虑以下指令：[gzip_http_version](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_gzip_module#gzip_http_version)、[gzip_proxied](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_gzip_module#gzip_proxied) 和 [gzip_disable](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_gzip_module#gzip_disable)。另请参阅 [gzip_vary](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_gzip_module#gzip_vary) 指令。

### gunzip\_buffers

|-|说明|
| ---| -------------------------------------|
|**语法**|**gunzip_buffers** `number size`​;|
|**默认**|gunzip\_buffers 32 4k\|16 8k;|
|**上下文**|http、server、location|

　　设置用于解压响应的缓冲区的数量（`number`​）和大小（`size`​）。默认情况下，缓冲区大小等于一个内存页（4K 或 8K，取决于平台）。

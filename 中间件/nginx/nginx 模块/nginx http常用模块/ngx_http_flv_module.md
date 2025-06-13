# ngx_http_flv_module

​`ngx_http_flv_module`​ 模块为 Flash 视频（FLV）文件提供伪流服务端支持。

它通过发送回文件的内容来处理请求 URI 查询字符串中带有特定 `start`​ 参数的请求，文件的内容从请求字节偏移开始的且 FLV 头为前缀。

该模块不是默认构的，您可以在构建时使用 `--with-http_flv_module`​ 配置参数启用。

## 示例配置

```
location ~ \.flv$ {
    flv;
}
```

## 指令

### flv

|-|说明|
| ---| ----------|
|**语法**|**flv**;|
|**默认**|——|
|**上下文**|location|

开启针对 `location`​ 的模块处理。

‍

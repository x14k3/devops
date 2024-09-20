# ngx_http_sub_module

　　​`ngx_http_sub_module`​ 模块是一个过滤器，它通过替换指定的字符串来修改响应数据。

　　默认不构建此模块，可在构建时使用 `--with-http_sub_module`​ 配置参数启用。

## 示例配置

```
location / {
    sub_filter '<a href="http://127.0.0.1:8080/'  '<a href="https://$host/';
    sub_filter '<img src="http://127.0.0.1:8080/' '<img src="https://$host/';
    sub_filter_once on;
}
```

## 指令

### sub\_filter

|-|说明|
| ---| ------------------------|
|**语法**|**sub_filter** `string replacement`​;|
|**默认**|——|
|**上下文**|http、server、location|

　　设置要替换的字符串（`string`​）和要替换成的字符串（`replacement`​）。要替换的字符串匹配忽略大小写。要替换的字符串（1.9.4）和要替换成的字符串可以包含变量。可以在一个配置级别指定几个 `sub_filter`​ 指令（1.9.4）。当且仅当在当前级别上没有定义 `sub_filter`​ 指令时，这些指令才从上级继承。

### sub\_filter\_last\_modified

|-|说明|
| ---| -------------------------------------------|
|**语法**|**sub_filter_last_modified** `on`​\|`off`​;|
|**默认**|sub\_filter\_last\_modified off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.1 版本中出现|

　　允许在替换期间保留原始响应中的 **Last-Modified** 头字段，用于响应缓存。

　　默认情况下，在处理期间修改响应的内容时，将删除头字段。

### sub\_filter\_once

|-|说明|
| ---| -----------------------------|
|**语法**|**sub_filter_once** `on`​\|`off`​;|
|**默认**|sub\_filter\_once on;|
|**上下文**|http、server、location|

　　只查找一次要替换的每个字符串或重复查找。

### sub\_filter\_types

|-|说明|
| ---| -------------------------------------|
|**语法**|**sub_filter_types** `mime-type ...`​;|
|**默认**|sub\_filter\_types text/html;|
|**上下文**|http、server、location|

　　除了 **text/html** 之外，还指定在其他 MIME 类型的响应中启用字符串替换。特殊值 `*`​ 匹配任何 MIME 类型（0.8.29）。

　　‍

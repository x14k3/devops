# ngx_http_addition_module

　　​`ngx_http_addition_module`​ 是一个过滤器，用于在响应之前和之后添加文本。该模块不是默认构建，要启用应使用 `--with-http_addition_module`​ 配置参数构建。

## 示例配置

```
location / {
    add_before_body /before_action;
    add_after_body  /after_action;
}
```

## 指令

### add\_before\_body

|-|说明|
| ---| ------------------------|
|**语法**|**add_before_body** `uri`​;|
|**默认**|——|
|**上下文**|http、server、location|

　　在响应正文之前添加文本，作为给定子请求的一个处理结果返回。空字符串（`""`​）作为参数时将取消从先前配置级别继承的额外文本。

### add\_after\_body

|-|说明|
| ---| ------------------------|
|**语法**|**add_after_body** `uri`​;|
|**默认**|——|
|**上下文**|http、server、location|

　　在响应正文之后添加文本，作为给定子请求的一个处理结果返回。空字符串（`""`​）作为参数时将取消从先前配置级别继承的额外文本。

### addition\_types

|-|说明|
| ---| -------------------------------|
|**语法**|**addition_types** `mime-type ...`​;|
|**默认**|addition\_types text/html;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.9 版本中出现|

　　除了 `text/html`​ 外，允许您在指定的 MIME 类型的响应中添加文本。特殊值 `*`​ 匹配所有 MIME类型（0.8.29）。

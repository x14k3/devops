# ngx_http_realip_module

​`ngx_http_realip_module`​ 模块用于将客户端地址和可选端口更改为发送的指定的头字段。

默认情况下不构建此模块，可在构建时使用 `--with-http_realip_module`​ 配置参数启用。

## 示例配置

```
set_real_ip_from  192.168.1.0/24;
set_real_ip_from  192.168.2.1;
set_real_ip_from  2001:0db8::/32;
real_ip_header    X-Forwarded-For;
real_ip_recursive on;
```

## 指令

### set\_real\_ip\_from

|-|说明|
| ---| ------------------------|
|**语法**|**set_real_ip_from** `address`​\|`CIDR`​\|`unix:`​;|
|**默认**|——|
|**上下文**|http、server、location|

定义已知可发送正确替换地址的可信地址。如果指定了特殊值 `unix:`​，则所有 UNIX 域套接字都将受信任。也可以使用主机名（1.13.1）指定可信地址。

> 从 1.3.0 版本和 1.2.1 版本开始支持 IPv6 地址。

### real\_ip\_header

|-|说明|
| ---| -----------------------------------|
|**语法**|**real_ip_header** `field`​\|`X-Real-IP`​\|`X-Forwarded-For`​\|`proxy_protocol`​;|
|**默认**|real\_ip\_header X-Real-IP;|
|**上下文**|http、server、location|

定义请求头字段，其值将用于替换客户端地址。

包含可选端口的请求头字段值也用于替换客户端端口（1.11.0）。 应根据 [RFC 3986](https://tools.ietf.org/html/rfc3986) 指定地址和端口。

​`proxy_protocol`​ 参数（1.5.12）将客户端地址更改为 PROXY 协议头中的地址。必须先通过在 [listen](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#listen) 指令中设置 `proxy_protocol`​ 参数来启用 PROXY 协议。

### real\_ip\_recursive

|-|说明|
| ---| ----------------------------------------|
|**语法**|**real_ip_recursive** `on`​\|`off`​;|
|**默认**|real\_ip\_recursive off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.3.0 版本和 1.2.1 版本中出现|

如果禁用递归搜索，则匹配其中一个可信地址的原始客户端地址替换为 [real_ip_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_realip_module#real_ip_header) 指令定义的请求头字段中发送的最后一个地址。如果启用了递归搜索，则匹配其中一个可信地址的原始客户端地址替换为请求头字段中发送的最后一个非受信任地址。

## 内嵌变量

* ​`$realip_remote_addr`​  
  原始客户端地址
* ​`$realip_remote_port`​  
  原始客户端端口

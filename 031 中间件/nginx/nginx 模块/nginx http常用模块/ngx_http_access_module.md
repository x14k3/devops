# ngx_http_access_module

　　​`ngx_http_access_module`​ 模块允许限制对某些客户端地址的访问。

　　访问也可以通过[密码](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_auth_basic_module)、[子请求结果](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_auth_request_module)或 [JWT](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_auth_jwt_module) 限制。可用 [satisfy](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#satisfy) 指令通过地址和密码同时限制访问。

## 示例配置

```
location / {
    deny  192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny  all;
}
```

　　按顺序检查规则，直到找到第一个匹配项。在本例中，仅允许 IPv4 网络 `10.1.1.0/16`​ 和 `192.168.1.0/24`​ 与 IPv6 网络 `2001:0db8::/ 32`​ 访问，不包括地址 `192.168.1.1`​。在很多规则的情况下，最好使用 [ngx_http_geo_module](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_geo_module) 模块变量。

## 指令

### allow

|-|说明|
| ---| ------------------------------------------|
|**语法**|**allow** `address`​\|`CIDR`​\|`unix:`​\|`all`​;|
|**默认**|——|
|**上下文**|http、server、location、limit\_except|

　　允许访问指定的网络或地址。如果指定了特殊值 `unix:`​（1.5.1），则允许访问所有 UNIX 域套接字。

### deny

|-|说明|
| ---| ------------------------------------------|
|**语法**|**deny** `address`​\|`CIDR`​\|`unix:`​\|`all`​;|
|**默认**|——|
|**上下文**|http、server、location、limit\_except|

　　拒绝指定网络或地址的访问。如果指定了特殊值 `unix:`​（1.5.1），则拒绝所有 UNIX 域套接字的访问。

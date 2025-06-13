
‍

## 什么是浏览器跨域限制？本质是什么？

所谓浏览器跨域限制，其实是为了数据安全的考虑由Netscape提出来限制浏览器访问跨域数据的策略。这是一种约定，正式叫法为“浏览器同源策略”，目前已经在大多数浏览器中支持。

本质上，所谓浏览器同源策略，即：不允许浏览器访问跨域的Cookie，ajax请求跨域接口等。也就是说，凡是访问与自己不在相同域的数据或接口时，浏览器都是不允许的。最常见的例子：对于前后端完全分离的Web项目，前端页面通过rest接口访问数据时，会出现如下问题：

- 不允许发送POST请求：在发送POST请求之前会发送OPTIONS请求，HTTP响应状态码为403（Forbidden）。
- 允许发送GET请求：HTTP响应状态码为200，但是不能读取服务器返回的数据。

同时，在浏览器（firefox调试）控制台可以看到如下提示：`已拦截跨源请求：同源策略禁止读取位于 http://host:port/path 的远程资源。（原因：CORS 头缺少 'Access-Control-Allow-Origin'）`​。

对URL来说，所谓的“同源”包含3个要素：协议相同，主机名（域名或IP地址，IP地址则看做是根域名）相同，端口相同。举例来说，对于`http://test.chench.org/page.html`​这个地址，以下情况被认为是同源与不同源的：

![umdxozvohp](assets/umdxozvohp-20240321204240-iq5pt60.png)​

|URL|结果|原因|说明|
| ---------------------------------------| --------| --------------------------------| ----------------------------|
|http://test.chench.org/page2.html|同源|协议相同，主机名相同，端口相同||
|http://test.chench.org/dir2/page.html|同源|协议相同，主机名相同，端口相同|相同域名下的不同目录|
|http://102.12.34.123/page.html|不同源|主机不同|域名与域名对应ip也不同源|
|http://test2.chench.org/page.html|不同源|主域名相同，子域名不同||
|http://chench.org/page.html|不同源|域名不同|相同一级域名，不同二级域名|
|http://test.chench.org:81/page.html|不同源|端口不同|相同域名，不同端口|
|https://test.chench.org/page.html|不同源|协议不同|相同域名，不同协议|
|http://blog.icehoney.me/page.html|不同源|主机不同|不同域名|

‍

## 为什么会存在浏览器跨域限制？

既然目前各主流浏览器都存在跨域限制，那么为什么一定要存在这个限制呢？如果没有跨域限制会出现什么问题？浏览器同源策略的提出本来就是为了避免数据安全的问题，即：限制来自不同源的“document”或脚本，对当前“document”读取或设置某些属性。如果没有这个限制，将会出现什么问题？不妨看一下几个情形：

1. 可能a.com的一段JavaScript脚本，在b.com未曾加载此脚本时，也可以随意涂改b.com的页面。
2. 在浏览器中同时打开某电商网站（域名为b.com），同时在打开另一个网站(a.com)，那么在a.com域名下的脚本可以读取b.com下的Cookie，如果Cookie中包含隐私数据，后果不堪设想。
3. 因为可以随意读取任意域名下的Cookie数据，很容易发起CSRF攻击。

所以，同源策略是浏览器安全的基础，同源策略一旦出现漏洞被绕过，也将带来非常严重的后果，很多基于同源策略制定的安全方案都将失去效果。

‍

## nginx 跨域的解决方案

只需要在Nginx的配置文件中配置以下参数：

```nginx
location / {  
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';

    if ($request_method = 'OPTIONS') {
        return 204;
    }
} 
```

- 1. **Access-Control-Allow-Origin**

  服务器默认是不被允许跨域的。给Nginx服务器配置`Access-Control-Allow-Origin *`​后，表示服务器可以接受所有的请求源（Origin）,即接受所有跨域的请求。

- 2. **Access-Control-Allow-Headers** 是为了防止出现以下错误：

  ​`Request header field Content-Type is not allowed by Access-Control-Allow-Headers in preflight response.`​

  这个错误表示当前请求Content-Type的值不被支持。其实是我们发起了"application/json"的类型请求导致的。这里涉及到一个概念：`预检请求（preflight request）`​,请看下面"预检请求"的介绍。

- 3. **Access-Control-Allow-Methods** 是为了防止出现以下错误：

  ​`Content-Type is not allowed by Access-Control-Allow-Headers in preflight response.`​

- 4.给`OPTIONS`​ 添加 `204`​的返回，是为了处理在发送POST请求时Nginx依然拒绝访问的错误

  发送"预检请求"时，需要用到方法 `OPTIONS`​ ,所以服务器需要允许该方法。

‍

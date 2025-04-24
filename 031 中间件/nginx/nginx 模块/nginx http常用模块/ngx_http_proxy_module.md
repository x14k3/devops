# ngx_http_proxy_module

​`ngx_http_proxy_module`​ 模块允许将请求传递给另一台服务器。

## 示例配置

```
location / {
    proxy_pass       http://localhost:8000;
    proxy_set_header Host      $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 指令

### proxy\_bind

|-|说明|
| ---| ----------------------------|
|**语法**|**proxy_bind** `address [transparent]`​\|`off`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 0.8.22 版本中出现|

连接到一个指定了本地 IP 地址和可选端口（1.11.2）的代理服务器。参数值可以包含变量（1.3.12）。特殊值 `off`​ （1.3.12）取消从上层配置级别继承的 `proxy_bind`​ 指令的作用，其允许系统自动分配本地 IP 地址和端口。

​`transparent`​ 参数（1.11.0）允许出站从非本地 IP 地址到代理服务器的连接（例如，来自客户端的真实 IP 地址）：

```
proxy_bind $remote_addr transparent;
```

为了使这个参数起作用，通常需要以[超级用户](https://github.com/DocsHome/nginx-docs/tree/f6135c42a499e9fab0adb433738fcf8cd4041627/模块参考/核心模块.md#user)权限运行 nginx worker 进程。在 Linux 上，不需要指定 `transparent`​ 参数（1.13.8），工作进程会继承 master 进程的 `CAP_NET_RAW`​ 功能。此外，还要配置内核路由表来拦截来自代理服务器的网络流量。

### proxy\_buffer\_size

|-|说明|
| ---| --------------------------------------|
|**语法**|**proxy_buffer_size** `size`​;|
|**默认**|proxy\_buffer\_size 4k\|8k;|
|**上下文**|http、server、location|

设置用于读取从代理服务器收到的第一部分响应的缓冲区大小（`size`​）。这部分通常包含一个小的响应头。默认情况下，缓冲区大小等于一个内存页。4K 或 8K，因平台而异。但是，它可以设置得更小。

### proxy\_buffering

|-|说明|
| ---| -------------------------|
|**语法**|**proxy_buffering** `on`​\|`off`​;|
|**默认**|proxy\_buffering on;|
|**上下文**|http、server、location|

启用或禁用来自代理服务器的响应缓冲。

当启用缓冲时，nginx 会尽可能快地收到接收来自代理服务器的响应，并将其保存到由 [proxy_buffer_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffer_size) 和 [proxy_buffers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffers) 指令设置的缓冲区中。如果内存放不下整个响应，响应的一部分可以保存到磁盘上的[临时文件](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_temp_path)中。写入临时文件由 [proxy_max_temp_file_size ](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_max_temp_file_size) 和 [proxy_temp_file_write_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_temp_file_write_size) 指令控制。

当缓冲被禁用时，nginx 在收到响应时立即同步传递给客户端，不会尝试从代理服务器读取整个响应。nginx 一次可以从服务器接收的最大数据量由 [proxy_buffer_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffer_size) 指令设置。

通过在 `X-Accel-Buffering`​ 响应头字段中通过 `yes`​ 或 `no`​ 也可以启用或禁用缓冲。可以使用 [proxy_ignore_headers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ignore_headers) 指令禁用此功能。

### proxy\_buffers

|-|说明|
| ---| --------------------------------|
|**语法**|**proxy_buffers** `number size`​;|
|**默认**|proxy\_buffers 8 4k\|8k;|
|**上下文**|http、server、location|

设置单个连接从代理服务器读取响应的缓冲区的 `number`​ （数量）和 `size`​ （大小）。默认情况下，缓冲区大小等于一个内存页。为 4K 或 8K，因平台而异。

### proxy\_busy\_buffers\_size

|-|说明|
| ---| ---------------------------------------|
|**语法**|**proxy_busy_buffers_size** `size`​;|
|**默认**|proxy\_buffer\_size 8k\|16k;|
|**上下文**|http、server、location|

当启用代理服务器响应[缓冲](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffering)时，限制缓冲区的总大小（`size`​）在当响应尚未被完全读取时可向客户端发送响应。同时，其余的缓冲区可以用来读取响应，如果需要的话，缓冲部分响应到临时文件中。默认情况下，`size`​ 受 [proxy_buffer_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffer_size) 和 [proxy_buffers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffers) 指令设置的两个缓冲区的大小限制。

### proxy\_cache

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_cache** `zone`​\|`off`​;|
|**默认**|proxy\_cache off;|
|**上下文**|http、server、location|

定义用于缓存的共享内存区域。同一个区域可以在几个地方使用。参数值可以包含变量（1.7.9）。`off`​ 参数将禁用从上级配置级别继承的缓存配置。

### proxy\_cache\_background\_update

|-|说明|
| ---| ------------------------------------------------|
|**语法**|**proxy_cache_background_update** `on`​\|`off`​;|
|**默认**|proxy\_cache\_background\_update off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.10 版本中出现|

允许启动后台子请求来更新过期的缓存项，而过时的缓存响应则返回给客户端。请注意，有必要在更新时[允许](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_use_stale_updating)使用陈旧的缓存响应。

### proxy\_cache\_bypass

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_cache_bypass** `string ...`​;|
|**默认**|——|
|**上下文**|http、server、location|

定义不从缓存中获取响应的条件。如果字符串参数中有一个值不为空且不等于 `0`​，则不会从缓存中获取响应：

```
proxy_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
proxy_cache_bypass $http_pragma    $http_authorization;
```

可以与 [proxy_no_cache](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_no_cache) 指令一起使用。

### proxy\_cache\_convert\_head

|-|说明|
| ---| ------------------------------------------|
|**语法**|**proxy_cache_convert_head** `on`​\|`off`​;|
|**默认**|proxy\_cache\_convert\_head on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.9.7 版本中出现|

启用或禁用将 **HEAD** 方法转换为 **GET** 进行缓存。禁用转换时，应将[缓存键](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_key)配置为包含 `$request_method`​。

### proxy\_cache\_key

|-|说明|
| ---| -----------------------------------------------------------------------------|
|**语法**|**proxy_cache_key** `string`​;|
|**默认**|proxy\_cache\_key \$scheme\$proxy\_host\$request\_uri;|
|**上下文**|http、server、location|

为缓存定义一个 key，例如：

```
proxy_cache_key "$host$request_uri $cookie_user";
```

默认情况下，指令的值与字符串相近：

```
proxy_cache_key $scheme$proxy_host$uri$is_args$args;
```

### proxy\_cache\_lock

|-|说明|
| ---| -------------------------------|
|**语法**|**proxy_cache_key** `on`​\|`off`​;|
|**默认**|proxy\_cache\_lock off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

启用后，通过将请求传递给代理服务器，一次只允许一个请求填充根据 [proxy_cache_key](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_key) 指令标识的新缓存元素。同一缓存元素的其他请求将等待响应出现在缓存中或缓存锁定以释放此元素，直到 [proxy_cache_lock_timeout](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_lock_timeout) 指令设置的时间。

### proxy\_cache\_lock\_age

|-|说明|
| ---| --------------------------------------|
|**语法**|**proxy_cache_lock_age** `time`​;|
|**默认**|proxy\_cache\_lock\_age 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

如果传递给代理服务器以填充新缓存元素的最后一个请求在指定时间（`time`​）内没有完成，则可以将另一个请求传递给代理服务器。

### proxy\_cache\_lock\_timeout

|-|说明|
| ---| ------------------------------------------|
|**语法**|**proxy_cache_lock_timeout** `time`​;|
|**默认**|proxy\_cache\_lock\_timeout 5s;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.12 版本中出现|

设置 [proxy_cache_lock](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_lock) 的超时时间。当时间（`time`​）到期时，请求将被传递到代理服务器，但响应不会被缓存。

> 在 1.7.8 之前可以缓存响应。

### proxy\_cache\_max\_range\_offset

|-|说明|
| ---| ----------------------------|
|**语法**|**proxy_cache_max_range_offset** `number`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.11.6 版本中出现|

设置字节范围（byte-range）请求的偏移量。如果范围超出偏移量，则范围请求将传递到代理服务器，并且不会缓存响应。

### proxy\_cache\_methods

|-|说明|
| ---| ---------------------------------------|
|**语法**|**proxy_cache_methods** `GET`​\|`HEAD`​\|`POST ...`​;|
|**默认**|proxy\_cache\_methods GET HEAD;|
|**上下文**|http、server、location|
|**提示**|该指令在 0.7.59 版本中出现|

如果客户端的请求方法在该列表中，则将缓存响应。`GET`​ 和 `HEAD`​ 方法总是在列表中，但建议显式指定它们。另请参见 [proxy_no_cache](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_no_cache) 指令。

### proxy\_cache\_min\_uses

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_cache_min_uses** `number`​;|
|**默认**|proxy\_cache\_min\_uses 1;|
|**上下文**|http、server、location|

设置在 `number`​ 此请求后缓存响应。

### proxy\_cache\_path

|-|说明|
| ---| ------|
|**语法**|**proxy_cache_path** `path [levels=levels] [use_temp_path=on\|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on\|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time]`​;|
|**默认**|——|
|**上下文**|http|

设置缓存的路径和其他参数。缓存数据存储在文件中。缓存中的文件名为[缓存 key](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_key) 经过 MD5 计算后的结果。`levels`​ 参数定义高速缓存的层次结构级别：从 1 到 3，每个级别接受值 1 或值 2。例如以下配置：

```
proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;
```

缓存中的文件名如下所示：

```
/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
```

首先缓存响应将写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和缓存可以放在不同的文件系统中。但请注意，在这种情况下，文件将跨越两个文件系统进行复制，而不是简单的重命名操作。因此，建议对于任何指定位置，缓存和保存临时文件的目录都放在同一文件系统上。临时文件的目录是根据 `use_temp_path`​ 参数（1.7.10）设置的。如果省略此参数或将其设置为 `on`​，则将使用 [proxy_temp_path](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_temp_path) 指令指定的目录位置。如果该值设置为 `off`​，则临时文件将直接放入缓存目录中。

此外，所有活跃的 key 和有关数据的信息都存储在共享内存区域中，其 `name`​ 和 `size`​ 由 `keys_zone`​ 参数配置。一兆字节区域可以存储大约 8000 个 key。

> 作为商业订阅的一部分，共享存储区域还存储着其他缓存[信息](https://github.com/DocsHome/nginx-docs/tree/f6135c42a499e9fab0adb433738fcf8cd4041627/模块参考/http/ngx_http_api_module.md#http_caches_)，因此，需要为相同数量的 key 指定更大的区域大小。 例如，一兆字节区域可以存储大约 4000 个 key。

在 `inactive`​ 参数指定的时间内未访问的缓存数据将从缓存中删除，无论其新旧程度。默认情况下，`inactive`​ 设置为 10 分钟。

特殊的**缓存管理器**进程监视 `max_size`​ 参数设置的最大缓存大小。超过此大小时，它会删除最近最少使用的数据。`manager_files`​、`manager_threshold`​ 和 `manager_sleep`​ 参数（1.11.5）配置的数据将被迭代删除。在一次迭代期间，不会删除超过 `manager_files`​ 项（默认情况下为 100）。一次迭代的持续时间受 `manager_threshold`​ 参数限制（默认情况下为 200 毫秒）。在迭代之间，由 `manager_sleep`​ 参数（默认为 50 毫秒）配置的间隔时间。

启动一分钟后，特殊**缓存加载程序**进程被激活。它将有关存储在文件系统中的先前缓存数据的信息加载到缓存区。加载也是在迭代中完成的。在一次迭代期间，不会加载超过 `loader_files`​ 项（默认情况下为 100）。此外，一次迭代的持续时间受 `loader_threshold`​ 参数限制（默认为 200 毫秒）。在迭代之间，由 loader\_sleep 参数（默认为 50 毫秒）配置间隔时间。

此外，以下参数作为我们[商业订阅](http://nginx.com/products/?_ga=2.38653990.485685795.1545557717-1363596925.1544107800)的一部分提供：

* ​`purger=on|off`​  
  指示缓存清除程序（cache purger）是否将从磁盘中删除与[通配符 key](https://github.com/DocsHome/nginx-docs/tree/f6135c42a499e9fab0adb433738fcf8cd4041627/模块参考/http/proxy_cache_purge/README.md) 匹配的缓存条目（1.7.12）。将参数设置为 `on`​（默认为 `off`​）将激活 **cache purger** 进程，该进程将永久迭代所有缓存条目并删除与通配符 key 匹配的条目。
* ​`purger_files=number`​  
  设置在一次迭代期间将扫描的条目数（1.7.12）。默认情况下，`purger_files`​ 设置为 10。
* ​`purger_threshold=number`​  
  设置一次迭代的持续时间（1.7.12）。 默认情况下，`purger_threshold`​ 设置为 50 毫秒。
* ​`purger_sleep=number`​  
  设置迭代之间的暂停间隔（1.7.12）。 默认情况下，`purger_sleep`​ 设置为 50 毫秒。

  > 在 1.7.3、1.7.7 和 1.11.10 版本中，缓存头格式已发生更改，升级到较新的 nginx 版本之后，缓存的响应将被视为无效。
  >

### proxy\_cache\_purge

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_cache_purge** `string ...`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

定义将请求视为缓存清除请求的条件。如果该字符串参数至少有一个值不为空并且不等于 `0`​，则删除有相应[缓存 key](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_key) 的缓存项。通过返回 204（No Content）响应来指示操作成功。

如果清除请求的[缓存 key](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_key) 以星号（`*`​）结尾，则将从缓存中删除与通配符 key 匹配的所有缓存项。但是，这些条目将保留在磁盘上，直到它们因为[非活跃](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_path)而被删除，或被[缓存清除程序](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#purger)（1.7.12）处理，抑或客户端尝试访问它们。

配置示例：

```
proxy_cache_path /data/nginx/cache keys_zone=cache_zone:10m;

map $request_method $purge_method {
    PURGE   1;
    default 0;
}

server {
    ...
    location / {
        proxy_pass http://backend;
        proxy_cache cache_zone;
        proxy_cache_key $uri;
        proxy_cache_purge $purge_method;
    }
}
```

> 此功能作为我们[商业订阅](http://nginx.com/products/?_ga=2.96279577.485685795.1545557717-1363596925.1544107800)的一部分提供。

### proxy\_cache\_revalidate

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_cache_revalidate** `on`​\|`off`​;|
|**默认**|proxy\_cache\_revalidate off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.7 版本中出现|

启用使用具有 **If-Modified-Since** 和 **If-None-Match** 头字段的条件请求来重新验证过期的缓存项。

### proxy\_cache\_use\_stale

|-|说明|
| ---| -----------------------------------------------------------------------------------|
|**语法**|**proxy_cache_use_stale** `error`​\|`timeout`​\|`invalid_header`​\|`updating`​\|`http_500`​\|`http_502`​\|`http_503`​\|`http_504`​\|`http_403`​\|`http_404`​\|`http_429`​\|`off ...`​;|
|**默认**|proxy\_cache\_use\_stale off;|
|**上下文**|http、server、location|

确定在与代理服务器通信期间可以在哪些情况下使用过时的缓存响应。该指令的参数与 [proxy_next_upstream](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream) 指令的参数匹配。

如果无法选择代理服务器来处理请求，则 `error`​ 参数还允许使用过时的缓存响应。

此外，如果当前正在更新，则 `updating`​ 参数允许使用过时的缓存响应。这允许在更新缓存数据时最大化减少对代理服务器的访问次数。

也可以直接在响应头中指定响应失效多少秒数后直接启用过时的缓存响应（1.11.10）。这比使用指令参数的优先级低。

* **Cache-Control** 头字段的 [stale-while-revalidate](https://tools.ietf.org/html/rfc5861#section-3) 扩展允许使用过时的缓存响应（如果当前正在更新）。
* **Cache-Control** 头字段的 [stale-if-error](https://tools.ietf.org/html/rfc5861#section-4) 扩展允许在出现错误时使用过时的缓存响应。  
  要在填充新缓存元素时最大化减少对代理服务器的访问次数，可以使用 [proxy_cache_lock](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_lock) 指令。

### proxy\_cache\_valid

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_cache_valid** `[code ...] time`​;|
|**默认**|——|
|**上下文**|http、server、location|

为不同的响应代码设置缓存时间。例如以下指令

```
proxy_cache_valid 200 302 10m;
proxy_cache_valid 404      1m;
```

为代码为 200 和 302 的响应设置 10 分钟的缓存时间，为代码 404 的响应设置 1 分钟的缓存时间。

如果仅指定了缓存 `time`​

```
proxy_cache_valid 5m;
```

将只缓存 200、301 和 302 的响应。

此外，可以指定 `any`​ 参数来缓存任何响应：

```
proxy_cache_valid 200 302 10m;
proxy_cache_valid 301      1h;
proxy_cache_valid any      1m;
```

也可以直接在响应头中设置缓存的参数。这比使用该指令设置缓存时间具有更高的优先级。

* **X-Accel-Expires** 头字段设置以秒为单位的响应缓存时间。零值将禁用响应缓存。如果值以 `@`​ 前缀开头，则设置自 Epoch 以来的绝对时间（以秒为单位）内的响应可以被缓存。
* 如果头不包括 **X-Accel-Expires** 字段，则可以在头字段 **Expires** 或 **Cache-Control** 中设置缓存的参数。
* 如果头包含了 **Set-Cookie** 字段，则不会缓存此类响应。
* 如果头包含有特殊值 `*`​ 的 **Vary** 字段，则不会缓存此类响应（1.7.7）。如果头包含有另一个值的 **Vary** 字段，这样的响应则将考虑缓存相应的请求头字段（1.7.7）。  
  可以使用 [proxy_ignore_headers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ignore_headers) 指令禁用这些响应头字段的一个或多个的处理。

### proxy\_connect\_timeout

|-|说明|
| ---| ------------------------------------|
|**语法**|**proxy_connect_timeout** `time`​;|
|**默认**|proxy\_connect\_timeout 60s;|
|**上下文**|http、server、location|

定义与代理服务器建立连接的超时时间。应该注意，此超时时间通常不会超过 75 秒。

### proxy\_cookie\_path

|-|说明|
| ---| --------------------------------|
|**语法**|**proxy_cookie_path** `off`​;**proxy_cookie_path** `path replacement`​;|
|**默认**|proxy\_cookie\_path off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.15 版本中出现|

设置代理服务器响应的 **Set-Cookie** 头字段的 `path`​ 属性中的应该变更的文本。假设代理服务器返回带有属性 `path=/two/some/uri/`​ 的 **Set-Cookie** 头字段。指令：

```
proxy_cookie_path /two/ /;
```

将此属性重写为 `path=/some/uri/`​。

​`path`​ 和 `replacement`​ 字符串可以包含变量：

```
proxy_cookie_path $uri /some$uri;
```

也可以使用正则表达式指定该指令。在这种情况下，路径应该以区分大小写的 `〜`​ 匹配符号开始，或者以区分大小写的 `〜*`​ 匹配符号开始。正则表达式可以包含命名和位置捕获，`replacement`​ 可以引用它们：

```
proxy_cookie_path ~*^/user/([^/]+) /u/$1;
```

可能有多个 `proxy_cookie_path`​ 指令：

```
proxy_cookie_path /one/ /;
proxy_cookie_path / /two/;
```

​`off`​ 参数取消所有 `proxy_cookie_path`​ 指令对当前级别的影响：

```
proxy_cookie_path off;
proxy_cookie_path /two/ /;
proxy_cookie_path ~*^/user/([^/]+) /u/$1;
```

### proxy\_force\_ranges

|-|说明|
| ---| ---------------------------------|
|**语法**|**proxy_force_ranges** `on`​\|`off`​;|
|**默认**|proxy\_force\_ranges off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

无论代理服务器中的 **Accept-Ranges** 字段如何，对代理服务器的缓存和未缓存响应都启用字节范围（byte-range）支持。

### proxy\_force\_ranges

|-|说明|
| ---| ----------------------------------------------------|
|**语法**|**proxy_headers_hash_bucket_size** `size`​;|
|**默认**|proxy\_headers\_hash\_bucket\_size 64;|
|**上下文**|http、server、location|

设置 [proxy_hide_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_hide_header) 和 [proxy_set_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_set_header) 指令使用的哈希表的桶 `size`​。设置哈希表的详细介绍在[单独的文档](https://docshome.gitbook.io/nginx-docs/readme/she-zhi-ha-xi)中提供。

### proxy\_headers\_hash\_max\_size

|-|说明|
| ---| --------------------------------------------------|
|**语法**|**proxy_headers_hash_max_size** `size`​;|
|**默认**|proxy\_headers\_hash\_max\_size 512;|
|**上下文**|http、server、location|

设置 [proxy_hide_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_hide_header) 和 [proxy_set_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_set_header) 指令使用的哈希表的最大 `size`​。设置哈希表的详细介绍在[单独的文档](https://docshome.gitbook.io/nginx-docs/readme/she-zhi-ha-xi)中提供。

### proxy\_hide\_header

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_hide_header** `field`​;|
|**默认**|——|
|**上下文**|http、server、location|

默认情况下，nginx 不会从代理服务器向客户端的响应中传递头字段 **Date**、**Server**、**X-Pad** 和 **X-Accel-...** 。`proxy_hide_header`​ 指令设置不传递的其他字段。相反，如果需要允许传递字段，则可以使用 [proxy_pass_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass_header) 指令设置。

### proxy\_http\_version

|-|说明|
| ---| ---------------------------------|
|**语法**|**proxy_http_version** `1.0`​\|`1.1`​;|
|**默认**|proxy\_http\_version 1.0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.1.4 版本中出现|

设置代理的 HTTP 协议版本。默认情况下，使用 1.0 版本。建议将 1.1 版与 [keepalive](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_upstream_module#keepalive) 连接和 [NTLM 身份验证](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_upstream_module#ntlm)配合使用。

### proxy\_ignore\_client\_abort

|-|说明|
| ---| --------------------------------------------|
|**语法**|**proxy_ignore_client_abort** `on`​\|`off`​;|
|**默认**|proxy\_ignore\_client\_abort off;|
|**上下文**|http、server、location|

确定在客户端关闭连接不等待响应时是否应关闭与代理服务器的连接。

### proxy\_ignore\_headers

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_ignore_headers** `field ...`​;|
|**默认**|——|
|**上下文**|http、server、location|

禁用处理某些来自代理服务器的响应头字段。可以忽略以下字段：**X-Accel-Redirect**、**X-Accel-Expires**、**X-Accel-Limit-Rate**（1.1.6）、**X-Accel-Buffering**（1.1.6）、**X-Accel-Charset**（1.1.6）、**Expires**、**Cache-Control**、**Set-Cookie**（0.8.44）和 **Vary**（1.7.7）。

如果未禁用，处理这些头字段将会产生以下影响：

* **X-Accel-Expires**、**Expires**、**Cache-Control**、**Set-Cookie** 和 **Vary** 设置响应[缓存](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_valid)的参数
* **X-Accel-Redirect** 执行[内部重定](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#internal)向到指定的 URI
* **X-Accel-Limit-Rate** 设置向客户端传输响应的[速率限制](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#limit_rate)
* **X-Accel-Buffering** 启用或禁用响应[缓冲](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffering)
* **X-Accel-Charset** 设置了所需的响应[字符集](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_charset_module#charset)

### proxy\_intercept\_errors

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_intercept_errors** `on`​\|`off`​;|
|**默认**|proxy\_intercept\_errors off;|
|**上下文**|http、server、location|

确定状态码大于或等于 300 的代理响应是应该传递给客户端还是拦截并重定向到 nginx 以便使用 [error_page](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#error_page) 指令进行处理。

### proxy\_limit\_rate

|-|说明|
| ---| -----------------------------|
|**语法**|**proxy_limit_rate** `rate`​;|
|**默认**|proxy\_limit\_rate 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.7 版本中出现|

限制从代理服务器读取响应的速率。`rate`​ 以每秒字节数指定。零值则禁用速率限制。限制是针对每个请求，因此如果 nginx 同时打开两个到代理服务器的连接，则总速率将是指定限制的两倍。仅当启用了代理服务器的响应[缓冲](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffering)时，此限制才生效。

### proxy\_max\_temp\_file\_size

|-|说明|
| ---| -------------------------------------------------|
|**语法**|**proxy_max_temp_file_size** `size`​;|
|**默认**|proxy\_max\_temp\_file\_size 1024m;|
|**上下文**|http、server、location|

当启用[缓冲](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffering)来自代理服务器的响应，并且整个响应不符合 [proxy_buffer_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffer_size) 和 [proxy_buffers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffers) 指令设置的缓冲时，部分响应可以保存到临时文件中。该指令设置临时文件的最大 `size`​。一次写入临时文件的数据大小由 [proxy_temp_file_write_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_temp_file_write_size) 指令设置。

零值则禁止将缓冲响应写入临时文件。

> 此限制不适用于将要[缓存](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache)或[存储](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_store)在磁盘上的响应。

### proxy\_method

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_method** `method`​;|
|**默认**|——|
|**上下文**|http、server、location|

指定转发到代理服务器的请求使用的 HTTP 方法（`method`​），而不是使用来自客户端请求的方法。参数值可以包含变量（1.11.6）。

### proxy\_next\_upstream

|-|说明|
| ---| -----------------------------------------------------------------------------------|
|**语法**|**proxy_next_upstream** `error`​\|`timeout`​\|`invalid_header`​\|`http_500`​\|`http_502`​\|`http_503`​\|`http_504`​\|`http_403`​\|`http_404`​\|`http_429`​\|`non_idempotent`​\|`off ...`​;|
|**默认**|proxy\_intercept\_errors off;|
|**上下文**|http、server、location|

指定应将请求传递到下一个服务器的条件：

* ​`error`​  
  与服务器建立连接，向其传递请求或读取响应头时发生错误
* ​`timeout`​  
  在与服务器建立连接，向其传递请求或读取响应头时发生超时
* ​`invalid_header`​  
  服务器返回空或无效响应
* ​`http_500`​  
  服务器返回代码为 500 的响应
* ​`http_502`​  
  服务器返回代码为 502 的响应
* ​`http_503`​  
  服务器返回代码为 503 的响应
* ​`http_504`​  
  服务器返回代码 504 的响应
* ​`http_403`​  
  服务器返回代码为 403 的响应
* ​`http_404`​  
  服务器返回代码为 404 的响应
* ​`http_429`​  
  服务器返回代码为 429 的响应（1.11.13）
* ​`non_idempotent`​  
  通常，如果请求已发送到上游服务器，则使用[非幂等](https://tools.ietf.org/html/rfc7231#section-4.2.2)方法（`POST`​、`LOCK`​、`PATCH`​）的请求不会传递给下一个服务器（1.9.13），启用此选项显式允许重试此类请求
* ​`off`​  
  禁止将请求传递给下一个服务器  
  应该记住，只有在尚未向客户端发送任何内容的情况下，才能将请求传递给下一个服务器。也就是说，如果在传输响应的过程中发生错误或超时，则无法修复此问题。

该指令还定义了与服务器通信的[失败尝试](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_upstream_module#max_fails)。`error`​、`timeout`​ 和 `invalid_header`​ 的情况始终被视为失败尝试，即使它们未在指令中指定。`http_500`​、`http_502`​、`http_503`​、`http_504`​ 和 `http_429`​ 的情况仅在指令中指定时才被视为失败尝试。`http_403`​ 和 `http_404`​ 的情况不会被视为失败尝试。

将请求传递到下一个服务器可能会受到[尝试次数](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream_tries)和[时间](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream_timeout)的限制。

### proxy\_next\_upstream\_timeout

|-|说明|
| ---| --------------------------------------------|
|**语法**|**proxy_next_upstream_timeout** `time`​;|
|**默认**|proxy\_next\_upstream\_timeout 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制请求可以传递到[下一个服务器](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream)的时间。`0`​ 值关闭此限制。

### proxy\_next\_upstream\_tries

|-|说明|
| ---| ------------------------------------------|
|**语法**|**proxy_next_upstream_tries** `number`​;|
|**默认**|proxy\_next\_upstream\_tries 0;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.5 版本中出现|

限制将请求传递到[下一个服务器](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream)的可能尝试次数。`0`​ 值关闭此限制。

### proxy\_no\_cache

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_no_cache** `string ...`​;|
|**默认**|——|
|**上下文**|http、server、location|

定义不将响应保存到缓存的条件。如果字符串参数有一个值不为空且不等于 `0`​，则不会保存响应：

```
proxy_no_cache $cookie_nocache $arg_nocache$arg_comment;
proxy_no_cache $http_pragma    $http_authorization;
```

可以与 [proxy_cache_bypass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_bypass) 指令一起使用。

### proxy\_pass

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_pass** `URL`​;|
|**默认**|——|
|**上下文**|http、server、location|

设置代理服务器的协议、地址以及应映射位置的可选 URI。协议可以指定 `http`​ 或 `https`​。可以将地址指定为域名或 IP 地址，以及一个可选端口号：

```
proxy_pass http://localhost:8000/uri/;
```

或者在 `unix`​ 单词后面指定使用冒号括起来的 UNIX 域套接字路径：

```
proxy_pass http://unix:/tmp/backend.socket:/uri/;
```

如果域名解析为多个地址，则所有这些地址将以轮询的方式使用。此外，可以将地址指定为[服务器组](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_upstream_module)。

参数值可以包含变量。在这种情况下，如果将地址指定为域名，则在所描述的服务器组中搜索名称，如果未找到，则使用[解析器](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#resolver)确定。

请求 URI 按如下方式传递给服务器：

* 如果指定了带有 URI 的 `proxy_pass`​，那么当请求传递给服务器时，与该位置（location）匹配的[规范化](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#location)请求 URI 的部分将被指令中指定的 URI 替换：

```
    location /name/ {
        proxy_pass http://127.0.0.1/remote/;
    }
```

* 如果指定了没有 URI 的 `proxy_pass`​，则请求 URI 将以与处理原始请求时客户端发送的格式相同的形式传递给服务器，或者在处理更改的 URI 时传递完整的规范化请求 URI：
* ```
    location /some/path/ {
        proxy_pass http://127.0.0.1;
    }
  ```

  > 在 1.1.12 版本之前，如果指定了没有 URI 的 `proxy_pass`​，则在某些情况下可能会传递原始请求 URI 而不是更改 URI。
  >

在某些情况下，无法确定请求 URI 要替换的部分：

* 使用正则表达式指定 location （位置）时，以及在命名位置内指定位置。 在这些情况下，应指定 `proxy_pass`​ 而不使用 URI。
* 使用 [rewrite](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_rewrite_module#rewrite) 指令在代理位置内更改 URI 时，将使用相同的配置来处理请求（`break`​）：
* ```
    location /name/ {
        rewrite    /name/([^/]+) /users?name=$1 break;
        proxy_pass http://127.0.0.1;
    }
  ```

  在这种情况下，将忽略指令中指定的 URI，并将完整更改的请求 URI 传递给服务器。
* 在 proxy\_pass 中使用变量时：
* ```
    location /name/ {
        proxy_pass http://127.0.0.1$request_uri;
    }
  ```

  在这种情况下，如果在指令中指定了 URI，则将其原样传递给服务器，替换原始请求 URI。

[WebSocket](https://docshome.gitbook.io/nginx-docs/how-to/websocket-dai-li) 代理需要特殊配置，从 1.3.13 版本开始支持。

### proxy\_pass\_header

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_pass_header** `field`​;|
|**默认**|——|
|**上下文**|http、server、location|

允许将[已禁用](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_hide_header)的头字段从代理服务器传递到客户端。

### proxy\_pass\_request\_body

|-|说明|
| ---| -----------------------------------------|
|**语法**|**proxy_pass_request_body** `on`​\|`off`​;|
|**默认**|proxy\_pass\_request\_body on;|
|**上下文**|http、server、location|

指示是否将原始请求体传递给代理服务器。

```
location /x-accel-redirect-here/ {
    proxy_method GET;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";

    proxy_pass ...
}
```

另请参阅 [proxy_set_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_set_header) 和 [proxy_pass_request_headers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass_request_headers) 指令。

### proxy\_pass\_request\_headers

|-|说明|
| ---| --------------------------------------------|
|**语法**|**proxy_pass_request_headers** `on`​\|`off`​;|
|**默认**|proxy\_pass\_request\_headers on;|
|**上下文**|http、server、location|

指示是否将原始请求的 header 字段传递给代理服务器。

```
location /x-accel-redirect-here/ {
    proxy_method GET;
    proxy_pass_request_headers off;
    proxy_pass_request_body off;

    proxy_pass ...
}
```

另请参阅 [proxy_set_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_set_header) 和 [proxy_pass_request_body](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass_request_body) 指令。

### proxy\_read\_timeout

|-|说明|
| ---| ---------------------------------|
|**语法**|**proxy_read_timeout** `time`​;|
|**默认**|proxy\_read\_timeout 60s;|
|**上下文**|http、server、location|

定义从代理服务器读取响应的超时时间。该超时时间仅针对两个连续的读操作之间设置，而不是整个响应的传输过程。如果代理服务器在该时间内未传输任何内容，则关闭连接。

### proxy\_redirect

|-|说明|
| ---| -----------------------------|
|**语法**|**proxy_redirect** `default`​;**proxy_redirect** `off`​;**proxy_redirect** `redirect replacement`​;|
|**默认**|proxy\_redirect default;|
|**上下文**|http、server、location|

设置代理服务器响应 header 中的 **Location** 和 **Refresh** 字段应要更改的文本。假设代理服务器返回header 字段为 `Location: http://localhost:8000/two/some/uri/`​。指令

```
proxy_redirect http://localhost:8000/two/ http://frontend/one/;
```

将此字符串重写为 `Location: http://frontend/one/some/uri/`​。

​`replacement`​ 中可能省略了服务器名称：

```
proxy_redirect http://localhost:8000/two/ /;
```

然后如果不是来自 80 端口，则将插入主服务器的名称和端口。

​`default`​ 参数指定的默认替换使用 [location](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#location) 和 [proxy_pass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass) 指令的参数。因此，以下两种配置是等效的：

```
location /one/ {
    proxy_pass     http://upstream:port/two/;
    proxy_redirect default;
```

```
location /one/ {
    proxy_pass     http://upstream:port/two/;
    proxy_redirect http://upstream:port/two/ /one/;
```

如果使用变量指定 [proxy_pass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass)，则不允许使用 `default`​ 参数。

​`replacement`​ 字符串可以包换变量：

```
proxy_redirect http://localhost:8000/ http://$host:$server_port/;
```

​`redirect`​ 也可以包含变量（1.1.11 版本）:

```
proxy_redirect http://$proxy_host:8000/ /;
```

可以使用正则表达式指定指令（1.1.11）。在这种情况下，`redirect`​ 应该以 `~`​ 符号开头，以区分大小写匹配，或者使用 `~*`​ 符号以区分大小写匹配。正则表达式可以包含命名和位置捕获，并且 `replacement`​ 可以引用它们：

```
proxy_redirect ~^(http://[^:]+):\d+(/.+)$ $1$2;
proxy_redirect ~*/user/([^/]+)/(.+)$      http://$1.example.com/$2;
```

​`off`​ 参数取消所有 `proxy_redirect`​ 指令对当前级别的影响：

```
proxy_redirect off;
proxy_redirect default;
proxy_redirect http://localhost:8000/  /;
proxy_redirect http://www.example.com/ /;
```

使用此指令，还可以将主机名添加到代理服务器发出的相对重定向：

```
proxy_redirect / /;
```

### proxy\_request\_buffering

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_request_buffering** `on`​\|`off`​;|
|**默认**|proxy\_request\_buffering on;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.11 版本中出现|

启用或禁用客户端请求体缓冲。

启用缓冲后，在将请求发送到代理服务器之前，将从客户端[读取](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#client_body_buffer_size)整个请求体。

禁用缓冲时，请求体在收到时立即发送到代理服务器。在这种情况下，如果 nginx 已经开始发送请求体，则无法将请求传递给[下一个服务器](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_next_upstream)。

当使用 HTTP/1.1 分块传输编码发送原始请求体时，无论指令值如何，都将缓冲请求体，除非为代理[启用](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_http_version)了 HTTP/1.1。

### proxy\_send\_lowat

|-|说明|
| ---| -----------------------------|
|**语法**|**proxy_send_lowat** `size`​;|
|**默认**|proxy\_send\_lowat 0;|
|**上下文**|http、server、location|

如果指令设置为非零值，则 nginx 将尝试通过使用 [kqueue](https://docshome.gitbook.io/nginx-docs/readme/lian-jie-chu-li-fang-shi#kqueue) 方法的 `NOTE_LOWAT`​ 标志或有指定大小的 `SO_SNDLOWAT`​ 套接字选项来最小化到代理服务器的传出连接上的发送操作数。

在 Linux、Solaris 和 Windows 上忽略此指令。

### proxy\_send\_timeout

|-|说明|
| ---| ---------------------------------|
|**语法**|**proxy_send_timeout** `time`​;|
|**默认**|proxy\_send\_timeout 60s;|
|**上下文**|http、server、location|

设置将请求传输到代理服务器的超时时间。超时时间仅作用于两个连续的写操作之间，而不是整个请求的传输过程。如果代理服务器在该时间内未收到任何内容，则关闭连接。

### proxy\_set\_body

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_set_body** `value`​;|
|**默认**|——|
|**上下文**|http、server、location|

允许重新定义传递给代理服务器的请求体。该值可以包含文本、变量及其组合。

### proxy\_set\_header

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_set_header** `filed value`​;|
|**默认**|**proxy_set_header** `Host $proxy_host`​;**proxy_set_header** `Connection close`​;|
|**上下文**|http、server、location|

允许将字段重新定义或附加到[传递](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass_request_headers)给代理服务器的请求 header。该值可以包含文本、变量及其组合。当且仅当在当前级别上没有定义 `proxy_set_header`​ 指令时，这些指令才从上层级别继承。默认情况下，只重新定义了两个字段：

```
proxy_set_header Host       $proxy_host;
proxy_set_header Connection close;
```

如果启用了缓存，则来自原始请求的 header 字段 **If-Modified-Since**、**If-Unmodified-Since**、**If-None-Match**、**If-Match**、**Range** 和 **If-Range** 不会传递给代理服务器。

一个未经更改的请求头（header）字段 **Host** 可以像这样传递：

```
proxy_set_header Host       $http_host;
```

但是，如果客户端请求 header 中不存在此字段，则不会传递任何内容。在这种情况下，最好使用 `$host`​ 变量 —— 它的值等于 **Host** 请求头字段中的服务器名称，或者如果此字段不存在则等于主服务器名称：

```
proxy_set_header Host       $host;
```

此外，服务器名称可以与代理服务器的端口一起传递：

```
proxy_set_header Host       $host:$proxy_port;
```

如果头字段的值为空字符串，则此字段将不会传递给代理服务器：

```
proxy_set_header Accept-Encoding "";
```

### proxy\_socket\_keepalive

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_socket_keepalive** `on`​\|`off`​;|
|**默认**|proxy\_socket\_keepalive off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.15.6 版本中出现|

配置到代理服务器的传出连接的 **TCP keepalive** 行为。默认情况下，操作系统的设置对 socket 有影响。如果指令设置为值 `on`​，则为 socket 打开 `SO_KEEPALIVE`​ socket 选项。

### proxy\_ssl\_certificate

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_ssl_certificate** `file`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

指定一个 PEM 格式的证书文件（`file`​），该证书用于 HTTPS 代理服务器身份验证。

### proxy\_ssl\_certificate\_key

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_ssl_certificate_key** `file`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

指定一个有密钥的 PEM 格式文件（`file`​），用于 HTTPS 代理服务器身份验证。

可以指定 `engine:name:id`​ 来代替 `file`​（1.7.9），它将从名为 `name`​ 的 OpenSSL 引擎加载 id 为 `id`​ 的密钥。

### proxy\_ssl\_ciphers

|-|说明|
| ---| ------------------------------------|
|**语法**|**proxy_ssl_ciphers** `ciphers`​;|
|**默认**|proxy\_ssl\_ciphers DEFAULT;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.6 版本中出现|

指定对 HTTPS 代理服务器的请求已启用密码。密码应为 OpenSSL 库支持的格式。

可以使用 `openssl ciphers`​ 命令查看完整的支持列表。

### proxy\_ssl\_crl

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_ssl_crl** `file`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

指定一个包含已撤销证书（CRL）的 PEM 格式的文件（`file`​），用于[验证](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ssl_verify) HTTPS 代理服务器的证书。

### proxy\_ssl\_name

|-|说明|
| ---| ---------------------------------------------|
|**语法**|**proxy_ssl_name** `name`​;|
|**默认**|proxy\_ssl\_name \$proxy\_host;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

允许覆盖用于[验证](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ssl_verify) HTTPS 代理服务器证书的服务器名称，并在与 HTTPS 代理服务器建立连接时[通过 SNI 传送](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ssl_server_name)。

默认情况下，使用 [proxy_pass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass) URL 的 host 部分。

### proxy\_ssl\_password\_file

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_ssl_password_file** `file`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.8 版本中出现|

为[密钥](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ssl_certificate_key)指定一个密码文件（`file`​），每个密码单独占一行。在加载密钥时依次尝试这些密码。

### proxy\_ssl\_protocols

|-|说明|
| ---| ----------------------------------------------------|
|**语法**|**proxy_ssl_protocols** `[SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]`​;|
|**默认**|proxy\_ssl\_protocols TLSv1 TLSv1.1 TLSv1.2;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.5.6 版本中出现|

为 HTTPS 代理服务器请求启用指定的协议。

### proxy\_ssl\_server\_name

|-|说明|
| ---| ----------------------------------------|
|**语法**|**proxy_ssl_server_name** `on`​\|`off`​;|
|**默认**|proxy\_ssl\_server\_name off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

在与 HTTPS 代理服务器建立连接时，启用或禁用通过 [TLS 服务器名称指示扩展](http://en.wikipedia.org/wiki/Server_Name_Indication)（SNI，RFC 6066）传递服务器名称。

### proxy\_ssl\_session\_reuse

|-|说明|
| ---| -----------------------------------------|
|**语法**|**proxy_ssl_session_reuse** `on`​\|`off`​;|
|**默认**|proxy\_ssl\_session\_reuse on;|
|**上下文**|http、server、location|

确定在使用代理服务器时是否可以复用 SSL 会话。如果日志中出现错误 `SSL3_GET_FINISHED:digest check failed`​，请尝试禁用会话复用。

### proxy\_ssl\_trusted\_certificate

|-|说明|
| ---| ---------------------------|
|**语法**|**proxy_ssl_trusted_certificate** `file`​;|
|**默认**|——|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

指定 PEM 格式的可信 CA 证书文件，用于[验证](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_ssl_verify) HTTPS 代理服务器证书。

### proxy\_ssl\_verify

|-|说明|
| ---| -------------------------------|
|**语法**|**proxy_ssl_verify** `on`​\|`off`​;|
|**默认**|proxy\_ssl\_verify off;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

启用或禁用验证 HTTPS 代理服务器证书。

### proxy\_ssl\_verify\_depth

|-|说明|
| ---| ---------------------------------------|
|**语法**|**proxy_ssl_verify_depth** `number`​;|
|**默认**|proxy\_ssl\_verify\_depth 1;|
|**上下文**|http、server、location|
|**提示**|该指令在 1.7.0 版本中出现|

设置代理的 HTTPS 服务器证书链验证深度。

### proxy\_store

|-|说明|
| ---| ------------------------|
|**语法**|**proxy_store** `on`​\|`off`​\|`string`​;|
|**默认**|proxy\_store off;|
|**上下文**|http、server、location|

允许将文件保存到磁盘。`on`​ 参数使用与 [alias](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#alias) 或 [root](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#root) 指令对应的路径保存文件。`off`​ 参数禁用文件保存。此外，可以使用带变量的字符串显式设置文件名：

```
proxy_store /data/www$original_uri;
```

根据接收的 **Last-Modified** 响应 header 字段设置文件的修改时间。首先将响应写入临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和持久化存储可以放在不同的文件系统上。但是，请注意，在这种情况下，文件复制需要跨越两个文件系统，而不是简单的重命名操作。因此，建议由 [proxy_temp_path](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_temp_path) 指令设置的保存文件和保存临时文件的目录都放在同一文件系统上。

该指令可用于创建静态不可更改文件的本地副本，例如：

```
location /images/ {
    root               /data/www;
    error_page         404 = /fetch$uri;
}

location /fetch/ {
    internal;

    proxy_pass         http://backend/;
    proxy_store        on;
    proxy_store_access user:rw group:rw all:r;
    proxy_temp_path    /data/temp;

    alias              /data/www/;
}
```

或者：

```
location /images/ {
    root               /data/www;
    error_page         404 = @fetch;
}

location @fetch {
    internal;

    proxy_pass         http://backend;
    proxy_store        on;
    proxy_store_access user:rw group:rw all:r;
    proxy_temp_path    /data/temp;

    root               /data/www;
}
```

### proxy\_store\_access

|-|说明|
| ---| -------------------------------------|
|**语法**|**proxy_store_access** `users:permissions ...`​;|
|**默认**|proxy\_store\_access user:rw;|
|**上下文**|http、server、location|

为新创建的文件和目录设置访问权限，例如：

```
proxy_store_access user:rw group:rw all:r;
```

如果指定了任何 `group`​ 或 `all`​ 访问权限，则可以省略用户权限：

```
proxy_store_access group:rw all:r;
```

### proxy\_temp\_file\_write\_size

|-|说明|
| ---| --------------------------------------------------------|
|**语法**|**proxy_temp_file_write_size** `size`​;|
|**默认**|proxy\_temp\_file\_write\_size 8k\|16k;|
|**上下文**|http、server、location|

当启用缓冲从代理服务器到临时文件的响应时，限制一次写入临时文件的数据大小（`size`​）。 默认情况下，`size`​ 由 [proxy_buffer_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffer_size) 和 [proxy_buffers](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_buffers) 指令设置的两个缓冲区限制。临时文件的最大大小由 [proxy_max_temp_file_size](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_max_temp_file_size) 指令设置。

### proxy\_temp\_path

|-|说明|
| ---| -----------------------------------------|
|**语法**|**proxy_temp_path** `path [level1 [level2 [level3]]]`​;|
|**默认**|proxy\_temp\_path proxy\_temp;|
|**上下文**|http、server、location|

定义用于存储临时文件的目录，其中包含从代理服务器接收的数据。在指定目录下最多可有三级子目录。例如在以下配置

```
proxy_temp_path /spool/nginx/proxy_temp 1 2;
```

临时文件可能如下：

```
/spool/nginx/proxy_temp/7/45/00000123457
```

另请参阅 [proxy_cache_path](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_cache_path) 指令的 `use_temp_path`​ 参数。

## 内嵌变量

​`ngx_http_proxy_module`​ 模块支持内嵌变量，可使用 [proxy_set_header](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_set_header) 指令来聚合 header：

* ​`$proxy_host`​  
  [proxy_pass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass) 指令中指定的代理服务器的名称和端口
* ​`$proxy_port`​  
  [proxy_pass](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_proxy_module#proxy_pass) 指令中指定的代理服务器的端口或协议的默认端口
* ​`$proxy_add_x_forwarded_for`​  
  **X-Forwarded-For** 客户端请求头字段，其中附加了 `$remote_addr`​ 变量，以逗号分割。如果客户端请求头中不存在 **X-Forwarded-For”**  字段，则 `$proxy_add_x_forwarded_for`​ 变量等于 `$remote_addr`​ 变量。  
  **待续……**

‍

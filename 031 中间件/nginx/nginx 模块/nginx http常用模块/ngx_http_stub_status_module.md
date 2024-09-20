# ngx_http_stub_status_module

　　​`ngx_http_stub_status_module`​ 模块提供对基本状态信息的访问的支持。

　　默认不构建此模块，可在构建时使用 `--with-http_stub_status_module`​ 配置参数启用。

## 示例配置

```
location = /basic_status {
    stub_status;
}
```

　　此配置将创建一个简单的网页，其基本状态数据可能如下：

```
Active connections: 291 
server accepts handled requests
 16630948 16630948 31070465 
Reading: 6 Writing: 179 Waiting: 106
```

## 指令

### stub\_status

|-|说明|
| ---| ------------------|
|**语法**|**stub_status**;|
|**默认**|——|
|**上下文**|server、location|

　　可以从包含该指令的 location 访问基本状态信息。

> 在 1.7.5 之前的版本中，指令语法需要一个任意参数，例如 `stub_status on`​。

## 数据

　　提供以下状态信息：

* ​`Active connections`​  
  当前活动客户端连接数，包括等待连接。
* ​`accepts`​  
  已接受的客户端连接总数。
* ​`handled`​  
  已处理连接的总数。通常，参数值与 `accept`​ 相同，除非已达到某些资源限制阈值（例如，[worker_connections](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng#worker_connections) 限制）。
* ​`requests`​  
  客户端请求的总数。
* ​`Reading`​  
  nginx 正在读取请求头的当前连接数。
* ​`Writing`​  
  nginx 将响应写回客户端的当前连接数。
* ​`Waiting`​  
  当前等待请求的空闲客户端连接数。

## 内嵌变量

　　​`ngx_http_stub_status_module`​ 模块支持以下内嵌变量（1.3.14）：

* ​`$connections_active`​  
  与 `Active connections`​ 的值相同
* ​`$connections_reading`​  
  与 `Reading`​ 的值相同
* ​`$connections_writing`​  
  与 `Writing`​ 的值相同
* ​`$connections_waiting`​  
  与 `Waiting`​ 的值相同

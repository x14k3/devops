

Nginx的日志主要包括访问日志`access_log`​和错误日志`error_log`​，你还可以通过`log_format`​定义日志格式。你可以在全局块，Server块或Location块定义日志。比如下例在http块中定义了一个名为`main`​的日志格式，所有站点的日志都会按这个格式记录。

```highlight
http {
 # 日志格式及access日志路径
  log_format main '$remote_addr - $remote_user [$time_local]  $status '
    '"$request" $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
  access_log   logs/access.log  main;
}
```

​`access_log`​文件随着访问记录增多有可能变得非常大，我们可以使用`access_log off`​关闭一些不需要记录的访问。比如当一个站点没有设置favicon.ico时，`access_log`​会记录了大量favicon.ico 404信息, 这是没有必要的, 可以按如下方式关闭访问日志记录。

```highlight
location = /favicon.ico {
  log_not_found off; 
  access_log off; # 不在access_log记录该项访问
}
```

##

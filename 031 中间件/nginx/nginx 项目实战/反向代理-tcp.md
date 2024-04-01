# 反向代理-tcp

nginx1.9以后新增了对tcp协议的支持。[nginx](https://so.csdn.net/so/search?q=nginx\&spm=1001.2101.3001.7020 "nginx")使用了一个新的模块`stream`​ 来支持tcp协议，这个模块与 `http`​ 模块比较类似。安装 nginx 时，需要加上--with-stream --with-stream\_ssl\_module

```nginx
worker_processes  1;
events {
    worker_connections  1024;
}
stream {  
        upstream tcp_proxy {
        hash $remote_addr consistent;  #远程地址做个hash
        server 192.168.10.4:22;
   }
      server {
        listen 2222;
        proxy_connect_timeout 1s;
        proxy_timeout 10s;  #后端连接超时时间
        proxy_pass tcp_proxy;
     }
  }

```

‍

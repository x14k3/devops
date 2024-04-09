# 监控模块 stub_status

Nginx中的stub_status模块主要用于查看Nginx的一些状态信息.  
当前默认在nginx的源码文件中，不需要单独下载

​`./configure –-with-http_stub_status_module`​

在server板块中添加一个location，访问127.0.0.1/nginx-status将会出现状态信息，里面记录nginx处理链接数等等

```bash
# 放在某个开放的server区块，填写一个location
server{
         location /nginx-status {
             allow -------- #允许的ip，不然都能看了，一般允许本地
             deny all; #默认最后全拒绝，除了allow的
             stub_status on;
             access_log  off；
        }
}
```

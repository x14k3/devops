#cluster/haproxy

负载均衡(Load Balance)的职责是将网络请求，或者其他形式的负载“均摊”到不同的机器上，让每台服务器获取到适合自己处理能力的负载。在为高负载服务器分流的同时，还可以避免资源浪费。负载均衡的原理就是当用户的请求到达前端负载均衡器(Director Server)时，通过设置好的调度算法，智能均衡的将请求分发到后端真正服务器上(Real Server)。根据请求类型的不同可以将负载均衡分为四层负载均衡(L4)和七层负载均衡(L7)， 常见的负载均衡器包括LVS，Nginx, HAProxy等。

LVS： 是基于四层的转发
HAproxy： 是基于四层和七层的转发，是专业的代理服务器
Nginx： 是WEB服务器，缓存服务器，又是反向代理服务器，可以做七层的转发

HAProxy相比较nginx的优点
- 支持Session的保持，Cookie的引导。nginx需要基于ip_hash来实现；
- HAProxy跟LVS类似，本身就只是一款负载均衡软件；


## haproxy 部署

### 1. 安装 haproxy

```bash
yum -y install haproxy
```


### 2. 修改配置文件

- global:  全局配置主要用于设定义全局参数，属于进程级的配置，通常和操作系统配置有关。
- default : 在此部分中设置的参数值，默认会自动引用到下面的frontend、backend、listen部分中，因此某些参数属于公用的配置，只需要在defaults部分添加一次即可。而如果frontend、backend、listen部分也配置了与defaults部分一样的参数，Defaults部分参数对应的值自动被覆盖。
- frontend：接收请求的前端虚拟节点，Frontend可以更加规则直接指定具体使用后端的backend；forntend可以根据ACL规则直接指定要使用的后端backend。
- backend : 后端服务集群的配置，真实服务器，一个Backend对应一个或者多个实体服务器。
- Listen : Fronted和backend的组合体；比如haproxy实例状态监控部分配置。

`vim /etc/haproxy/haproxy.cfg`

示例1（只使用listen 关联“前端”和“后端”定义了一个完整的代理，进行端口转发和负载均衡。通常只对TCP流量有用 ）
```bash
global
    log         127.0.0.1 local2 info # [err warning info debug]
    pidfile     /var/run/haproxy.pid
    maxconn     10240 # 最大连接数
    user        haproxy
    group       haproxy
    daemon            # 以后台形式运行ha-proxy
    nbproc      1     # 工作进程数量 cpu内核是几就写几
defaults
    mode        tcp   # 工作模式 http ,tcp 是 4 层,http是 7 层   
    log         global
    retries     3     # 健康检查。3次连接失败就认为服务器不可用，主要通过后面的check检查
    option httplog                  #日志类别http日志格式  
    option httpclose                #每次请求完毕后主动关闭http通道  
    option dontlognull              #不记录健康检查的日志信息  
    option forwardfor               #如果后端服务器需要获得客户端真实ip需要配置的参数，可以从Http Header中获得客户端ip   
    option redispatch               #serverId对应的服务器挂掉后,强制定向到其他健康的服务器   
    option abortonclose             #当服务器负载很高的时候，自动结束掉当前队列处理比较久的连接  
    stats refresh 30                #统计页面刷新间隔  
	balance roundrobin              #默认的负载均衡的方式,轮询方式  
    #balance source                  #默认的负载均衡的方式,类似nginx的ip_hash  
    #balance leastconn               #默认的负载均衡的方式,最小连接  
    contimeout 5000                 #连接超时  
    clitimeout 50000                #客户端超时  
    srvtimeout 50000                #服务器超时  
    timeout check 2000              #心跳检测超时    

listen admin_status #Frontend和Backend的组合体,监控组的名称，按需自定义名称
    bind    *:81    #监听端口
    mode    http    #http的7层模式
    stats   enable
    stats   uri   /admin_status  #监控页面的url
    stats   auth  test:test1 #用户名和密码
    stats hide-version   #隐藏统计页面上的HAproxy版本信息
    stats admin if TRUE  #手工启用/禁用,后端服务器(haproxy-1.4.9以后版本)
    
    errorfile 403 /etc/haproxy/errorfiles/403.http  
    errorfile 500 /etc/haproxy/errorfiles/500.http  
    errorfile 502 /etc/haproxy/errorfiles/502.http  
    errorfile 503 /etc/haproxy/errorfiles/503.http  
    errorfile 504 /etc/haproxy/errorfiles/504.http  

#################HAProxy的日志记录内容设置###################
    capture request header Host len 40
    capture request header Content-Length len 10
    capture request header Referer len 200
    capture response header Server len 40
    capture response header Content-Length len 10
    capture response header Cache-Control len 8

listen mq          #Frontend和Backend的组合体,监控组的名称，按需自定义名称 
    bind 0.0.0.0:45672                                          #监听端口 
    mode tcp                                                    #tcp模式       
    server s1 192.168.1.56:5672 check inter 5s rise 2 fall 3    #代理的服务1
    server s2 192.168.1.57:5672 check inter 5s rise 2 fall 3    #代理的服务2
    server s3 192.168.1.58:5672 check inter 5s rise 2 fall 3    #代理的服务3
# check inter 1500是检测心跳频率
# rise 3是3次正确认为服务器可用，
# fall 3是3次失败认为服务器不可用，weight代表权重

listen mqweb
    bind 0.0.0.0:15672
    mode tcp
    server s1 192.168.1.56:15672 check inter 5s rise 2 fall 3
    server s2 192.168.1.57:15672 check inter 5s rise 2 fall 3
    server s3 192.168.1.58:15672 check inter 5s rise 2 fall 3


```

示例2（采用frontend+backend模式 大多适用于http请求）
假设客户端访问 http://do1.test.com 时，要把请求分发到192.168.5.171:8080、192.168.5.174:8080、192.168.5.178:8080，这三台服务器上，我们可以这样配置。

```bash
defaults
    log global
    mode http
    maxconn 20480
    option httplog
    option httpclose
    option dontlognull
    #option forwardfor
    option redispatch
    option abortonclose
    #stats refresh 30
    retries 3
    balance roundrobin
    #balance source
    #balance leastconn
    timeout check 2000
    
  
frontend  web1      #frontend 名称自定义
    bind 0.0.0.0:80  #绑定端口
    acl url_do1  path_beg  do1.test.com  #定义规则
    use_backend do1server  if url_do1    #使用规则:如果规则是 url_do1 则跳转到do1server backend
        
    
   
backend do1server  #后端服务集群的配置名称自定义
    balance     roundrobin  #负载均衡算法 轮询
    server  web1 192.168.5.171:8080 check inter 5s rise 2 fall 3
    server  web2 192.168.5.174:8080 check inter 5s rise 2 fall 3
    server  web3 192.168.5.178:8080 check inter 5s rise 2 fall 3
    
```

## 启动Haproxy

```bash
#启动 
systemctl start haproxy 
#检测状态 
systemctl status haproxy 
```

## 集群

Haproxy本身本身是没有集群配置的，但是我们可以通过将Haproxy配置到多台服务器配置可以是一样的。然后再使用Keepalived通过虚拟IP来切换Haproxy达到我们想要的效果。
#cluster/haproxy

负载均衡(Load Balance)的职责是将网络请求，或者其他形式的负载“均摊”到不同的机器上，让每台服务器获取到适合自己处理能力的负载。在为高负载服务器分流的同时，还可以避免资源浪费。负载均衡的原理就是当用户的请求到达前端负载均衡器(Director Server)时，通过设置好的调度算法，智能均衡的将请求分发到后端真正服务器上(Real Server)。根据请求类型的不同可以将负载均衡分为四层负载均衡(L4)和七层负载均衡(L7)， 常见的负载均衡器包括LVS，Nginx, HAProxy等。

HAProxy提供高可用性、负载均衡以及基于TCP和HTTP应用的代理，它是免费、开源、快速并且可靠的一种解决方案。

1. HAProxy 也是支持虚拟主机的
2. HAProxy 的优点能够补充 Nginx 的一些缺点，比如支持 Session 的保持，Cookie的引导；同时支持通过获取指定的 url 来检测后端服务器的状态
3. HAProxy 跟 LVS 类似，本身就只是一款负载均衡软件；单纯从效率上来讲HAProxy 会比 Nginx 有更出色的负载均衡速度，在并发处理上也是优于 Nginx 的
4. HAProxy 支持 TCP 协议的负载均衡转发，可以对 MySQL 读进行负载均衡，对后端的 MySQL 节点进行检测和负载均衡，大家可以用 LVS+Keepalived 对 MySQL主从做负载均衡
5. HAProxy 负载均衡策略非常多， HAProxy 的负载均衡算法现在具体有如下8种:
	- roundrobin，简单的轮询；
	- static-rr，     根据权重；
	- leastconn，  最少连接者先处理；
	- source，       根据请求源 IP，这个跟 Nginx 的 IP_hash 机制类似，我们用其作为解决 session 问题的一种方法；
	- ri，               根据请求的 URI；
	- rl_param，    根据请求的 URl 参数’balance url_param’ requires an URLparameter name；
	- hdr(name)， 根据 HTTP 请求头来锁定每一次 HTTP 请求；
	- rdp-cookie(name)，根据据 cookie(name)来锁定并哈希每一次 TCP 请求。

## haproxy 部署

```bash
# 安装HAparoxy
yum -y install haproxy

# 修改配置文件
cp /etc/haproxy/haproxy.cfg{,.bak} 
vim /etc/haproxy/haproxy.cfg
------------------------------------------------------------------------
global
    log         127.0.0.1 local2 info
    pidfile     /var/run/haproxy.pid
    maxconn     4000  # 优先级低
    user        haproxy
    group       haproxy
    daemon            # 以后台形式运行ha-proxy
    nbproc      1     # 工作进程数量  cpu内核是几就写几
defaults
    mode        http  # 工作模式 http ,tcp 是 4 层,http是 7 层   
    log         global
    retries     3     # 健康检查。3次连接失败就认为服务器不可用，主要通过后面的check检查
    option      redispatch  # 服务不可用后重定向到其他健康服务器。
    maxconn     4000  # 优先级中
    contimeout  5000  # ha服务器与后端服务器连接超时时间，单位毫秒ms
    clitimeout  50000 # 客户端超时
    srvtimeout  50000 # 后端服务器超时
listen stats
    bind    *:81
    stats   enable
    stats   uri   /haproxy  # 使用浏览器访问 http://172.16.0.10:81/haproxy,可以看到服务器状态  
    stats   auth  we:123    # 用户认证
frontend    web
    mode    http  
    bind    *:80         # 监听哪个ip和什么端口
    option   httplog     # 日志类别 http 日志格式
    acl html url_reg  -i  \.html$    # 1.访问控制列表名称html。规则要求访问以html结尾的url(可选)
    use_backend httpservers if  html # 2.如果满足acl html规则，则推送给后端服务器httpservers
    default_backend    httpservers   # 默认使用的服务器组
backend httpservers                  # 名字要与上面的名字必须一样
    balance     roundrobin           # 负载均衡的方式
    server  http1 10.0.0.12:80 maxconn 2000 weight 1  check inter 1s rise 2 fall 2
    server  http2 10.0.0.13:80 maxconn 2000 weight 1  check inter 1s rise 2 fall 2

# 启动Haproxy服务
systemctl start haproxy
```


## haproxy 配置文件详解

### 1. global 段

```bash
maxconn 100000              #每个haproxy进程的最大并发连接数
chroot /apps/haproxy       #把haproxy锁定一个工作目录；当发生特殊情况，haproxy被控制时，也只能在锁定的目录下，不能跳转到其他目录
stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin   #指定socket文件路径及文件的权限
user haproxy
group haproxy
#uid 99
#gid 99                        #99是nobody
daemon                       #以守护进程方式启动
nbproc 4                      #haproxy工作进程数量；与CPU核心数量相对应
cpu-map 1 0                #第一个工作进程绑定在第0核CPU上
cpu-map 2 1                #第二个工作进程绑定在第1核CPU上
cpu-map 3 2
cpu-map 4 3
maxconn                      #每个haproxy进程的最大并发连接数
maxsslconn                  #每个haproxy进程ssl最大连接数,用于haproxy配置了证书的场景下
maxconnrate                #每个进程每秒创建的最大连接数量
pidfile /var/lib/haproxy/haproxy.pid
spread-checks 3           #后端server状态检查，随机提前或延迟百分比时间，建议2-5(20%-50%)之间；设置当前检测时间为3s，则会提前3s的20%-50%，或者 
                                    #延后3s的20%-50%；把同时探测的压力分散开
log 127.0.0.1 local3 info  #生成的日志发送给本机的syslog服务器；最多可以定义两个；定义的是local3设备，所以需要在syslog服务器的配置文件中进行定
                                       #义；vim /etc/rsyslog.conf；添加local3.* /var/log/haproxy.log，记录local3设备的所有级别的日志到指定文件中；并且 
                                       #需要开启$ModLoad imtcp、$InputTCPServerRun 514这两行，使用TCP协议进行日志转发；systemctl restart rsyslog
```

### 2. Proxies 段

```bash
defaults [<name>]  # 默认配置项，针对以下的frontend、backend和lsiten生效，可以多个name;defaults后面的name是一个可有可无的。
frontend <name>    # 前端servername，类似于Nginx的一个虚拟主机 server；后面必须有name。
backend  <name>    # 后端服务器组，等于nginx的upstream；后面必须有name。
listen   <name>    # 将frontend和backend合并在一起配置；后面必须有name。

# 注意1：name字段只能使用”-”、”_”、”.”、和”:”，并且严格区分大小写，例如：Web和web是完全不同的两组服务器。
# 注意2：如果frontend、listen中进行了配置，则以frontend、listen为准；如果frontend、listen中未进行配置，则以defaults配置为准。
```

### 3. Proxies配置-defaults

```bash
option redispatch       # 当server Id（real server）对应的服务器挂掉后，强制定向到其他健康的服务器  
option abortonclose     # 当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接；一般长时间处理的服务器（连接数据库等），需要关闭该选项
option http-keep-alive  # 开启与客户端的会话保持，在不超时的情况下，再次访问就不需要TCP三次握手建立连接
option forwardfor       # 透传客户端真实IP至后端web服务器
mode http               # haproxy默认工作类型，基于应用层；如果后端服务器有自己的应用层协议，可单独在后端代理上定义协议类型；工作中一般为TCP
timeout connect 120s    # 客户端请求到后端server的最长连接等待时间(haproxy与后端服务器TCP三次握手之前)
timeout server 600s     # 客户端请求到后端服务端的超时超时时长（TCP之后）；如果在600s后端服务器还未给haproxy返回，则会报502（后端服务器超时）
timeout client 600s     # 与客户端的最长非活动时间；600s内客户端没有向haproxy请求资源，则haproxy将会主动切断与客户端的连接
timeout http-keep-alive 120s   # session 会话保持超时时间，范围内会转发到相同的后端服务器
timeout check   5s      # 对后端服务器的检测超时时间
```

### 4. Proxies配置-frontend

```bash
 frontend yewu-service-80                     # 前端的名字一般为：业务-服务-端口号
     bind 192.168.38.37:80,192.168.38.37:81   # 指定haproxy监听的IP及端口，可以是多个IP；也可以写成，IP:80-89，或者是sock文件
     mode tcp                                 # 指定负载均衡协议类型
     use_backend yewu-service-80-nodes        # 调用后端服务器组的名称
```

示例：

```bash
 frontend http_https_proxy  # https监听
    bind :80
    bind :443 ssl crt /etc/haproxy/site.pem
```

### 5. Proxies配置-backend

```bash
# 定义一组后端服务器，backend服务器将被frontend进行调用。

server # 定义后端real server
check  # 对指定real server进行健康状态检查，默认不开启
       addr IP    # 可指定的健康状态监测IP
       port num   # 指定的健康状态监测端口；一般先对后端重要的服务的端口进行检查，如果重要服务的端口存在，则进行后端服务器的负载均衡；一般反向代理的
                  IP和端口号与重要服务的IP不在同一个网段；如nginx与php，先检查后端nginx服务器的php的9000端口是否存在，存在才反向代理后端的nginx
                  服务器
       inter num  # 健康状态检查间隔时间，默认2000ms
       fall num   # 后端服务器失效检查次数，默认为3，失败3次，从后端服务器组里面踢出去；1次失败有可能是网络问题，所以设置为检测失败3次；检测的时候，
                  用户的请求也会往服务器进行转发，所以失败检测次数不能太多；被踢出去后，用户的请求将不会往该服务器转发
       rise num   # 后端服务器从下线恢复检查次数，默认为2；后端服务器宕机，恢复后，检查成功2次后，重新添加到haproxy反向代理的服务器组里面

weight    # 默认为1，最大值为256，0表示不参与负载均衡
backup    # 将后端服务器标记为备份状态；当所有服务器都宕机时，backup服务器才会启动，相当于say sorry服务器
disabled  # 将后端服务器标记为不可用状态
redirect prefix http://www.xxx.net/   # 将请求临时重定向至其它URL，只适用于http模式
maxconn <maxconn>：当前，后端server的最大并发连接数
backlog <backlog>：当server的连接数达到上限后的后援队列长度

```

示例：

```bash
backend yewu-service-80-nodes    # 指定后端服务器组的名称；一般为，前端名称-nodes
mode tcp        # 后端服务器组的协议类型必须与前端一致
server web1 192.168.38.27:80 weight 1 check addr 192.168.38.27 port 9000 inter 3s fall 3 rise 5   # 反向代理前，先检查192.168.38.37:9000
                                                                                                  # 端口是否可以访问，可访问才会进行反向代
                                                                                                  # 理；如果9000端口不能访问，则不进行反向代理
server web2 192.168.38.47:80 check   # 指定后端服务器的名称、IP、端口号，以及检查
```

### 6. 使用listen替换frontend+backend的配置方式

```bash
listen yewu-service-80     # 指定名称，业务-服务-端口号
bind 192.168.38.37:80      # 指定haproxy所监听的IP及端口号
mode http                  # 指定反向代理的协议类型
option forwardfor          # 把用户的IP透传给后端服务器
server web1 192.168.38.27:80 weight 1 check inter 3000 fall 3 rise 5     #指定后端服务器的名称、IP、端口号等
server web2 192.168.38.47:80 weight 1 check inter 3000 fall 3 rise 5
```

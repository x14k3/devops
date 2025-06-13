# Nginx限制请求并发连接数与下载速度

‍

‍

ngnix的限流模块主要有三个：

- limit\_conn 限制某个ip的tcp连接数目或者限制某个server（网站）整体的连接数目
- limit\_rate 现在每个请求的数据大小
- limit\_req 限制某个ip的请求次数

其中效果最明显的是第三个limit\_req。

### tcp连接数目和请求数目的区别

tcp连接建立是需要三次握手的，是有一定的耗时的。就像打电话一样，得先拨通电话，两方才能讲话交流（请求资源），自然是tcp链接越少越好。

**那访问一个网站，到底会进行几个tcp连接？**

如果你的站点是http1.1，连接数目 \= 请求数目/ \<浏览器允许并发的数目\>

如果你的站点是http2.0 连接数目 \= 1

http1.1 默认开启keep-alive 特性，支持tcp持久连接，但是由于浏览器限制了并发数目，所以连接太多，仍然会进行再次的tcp连接。

而http2引入了多路复用和二进制帧分层特性，允许所有的请求来自同一个tcp。后续有时间可以在详细的写写http2的优势。

需要注意的是http2.0只适用于https的站点，并且需要在服务器端进行配置。

http站点仍然使用http1.1协议。

下面是nginx配置配置文件中配置http2的一个例子：

```pgsql
server
{
    listen 80;
    listen 443 ssl http2;
}
```

在chrome控制面板中可以看到当前网站建立的tcp连接的id，使用http2后，除了外部资源，本站资源的请求只建立一个tcp链接。

在你自己的服务器上，同样可以使用下面的命令查看tcp连接的连接情况：

```coq
netstat -anlp|grep tcp|awk '{print $5}'|awk -F: '{print $1}'|sort|uniq -c|sort -nr|head -n20 ;
```

​`netstat -anlp`​是linux查看网络情况的一个命令，过滤只显示与tcp相关的，但这里显示的是整个服务器的tcp连接，而不只是其中的某一个网站。

请求数目就是你在chrome面板中看到的request num。当然如果不是你自己站点的资源的请求数目不会占用你的服务器的带宽资源。

总结：如果你是https站点并且配置了http2，那个一个tcp连接 约等于 一个真实的人

而一个真实的人会产生很多个请求数目。

### limit\_req 模块限制请求数

limit\_req 模块用来限制一个ip的请求数目。

在nginx的http字段下配置：

```routeros
limit_req_zone $binary_remote_addr zone=hzcat:10m rate=20r/s;
```

在某个网站下的server字段下配置，或者在下面的location字段配置：

```routeros
limit_req zone=hzcat burst=20 nodelay;
```

这里面有几个变量需要说明一下：

- ​`zone`​: 后面的`hzcat`​是域名称，可以随便取一个，下面对应就可以了，冒号后面的10m 表示了这个域的大小，即该模块需要开辟一个内存空间是缓存nginx的请求记录中的\$binary\_remote\_addr，以便匹配出请求速率是否超过了指定的rate。
- ​`rate`​: 这个是1秒中允许的请求数目，这个地方很容易被误解导致配置错误。比如rate设置为20r/s，即在0～50ms只允许有一个请求，因为nginx是毫秒级的速率控制，这个地方的rate实际上是毫秒级的匀速控制。但实际上我们的站点的请求都是突发流量，即在短时间内很多个请求并发的。所以需要使用到burst来承接突发流量。
- ​`burst`​: 可以理解为一个缓冲队列，假设值为20，假设0～50ms中有21个请求，那么其中20个请求就会进入该队列。
- ​`nodelay`​：这个参数同样是非常容易错误理解的。nodelay即无延迟。以上面的例子为例，20个请求进入缓存队列后，会马上转发给nginx请求数据，获取到数据后返回。需要注意的是一个请求出队列后，该位置（插槽）并非立即释放的。 而是同样按照50ms的间隔（rate设置为20r/s）释放。也就是说，如果在51～100ms的期间又发送了21个请求，那只有2个请求可以成功返回（因为只有一个插槽被释放了），剩余的19个请求会立即返回503错误码。

也就是说，如果按照上面的配置（rate+burst+nodelay同时配置了），在0～1000ms中的任意时刻，有21个突发的并发请求都能够正常的处理，如果大于21个请求，就会直接返回503错误码，告诉客户端当前nginx无法处理该请求。

强烈推荐设置nodelay参数，也可以不设置，则20个请求进入缓冲队列后并不会马上全部转发，而是按照50ms的间隔进行请求和响应（此时该缓冲队列的位置也是按照这个间隔释放）\*\*，那么客户端收到所有21个请求的响应至少是1s后了，这个延迟就大大增加了，是非常不可取的。

如果不设置burst参数，对我们这种突发性请求的应用是非常不适合的。21个请求其中20个请求就会直接返回503，导致站点的资源无法加载的问题。

在http字段下配置下面的设置，会将超流的内容记录到error.log 下。

```nginx
limit_req_log_level error;
```

某个超流的日志如下：

```pgsql
2020/08/25 18:09:49 [error] 10215#0: 2445032 limiting requests, excess: 10.700 by zone "hzcat", client: 120.*.3*.29, server: xxx.com, request: "GET /xxx HTTP/2.0", host: "xxx.com", referrer: "https://***/xxx"
```

如果该网站是反向代理，当上游网站无法访问，此时的日志如下：

```basic
2022/04/24 20:44:50 [error] 12985#0: 9662214 upstream timed out (110: Connection timed out) while connecting to upstream, client: 120.*.3*.29, server: xxx.xxx.com, request: "GET /xxxx HTTP/2.0", upstream: "http://****:8000/xxx", host: "xxx.xxx.com", referrer: ""
```

### ngx\_http\_limit\_conn\_module限制连接数

limit\_conn 用来限制一个ip或者整个站点的tcp连接数目。

```nginx
#需要写在http段内
limit_conn_zone $binary_remote_addr zone=addr:10m;
server {
location /download/ {
    limit_conn addr 10;
}
```

​`$binary_remote_addr`​ : nginx变量，指的是客户端IP

​`zone`​ : 域的名字，随便填写，这里设置的是addr，后面会再次用到

​`10m`​ : 设置共享内存我的理解是客户端的IP会被放入这个内存中，总共享内存不能超过10M，不知道对不对。

​`limit_conn addr 10`​ : 限制addr这个域的最大连接数为10

但是在`HTTP/2`​中每个并发请求被视为单独的连接，如果网站启用了`HTTP/2`​上面的设置就没有作用了，可以继续改进一下。以下配置将限制每个客户端IP与服务器的连接数，同时限制与虚拟服务器的连接总数。

```routeros
#写在http段内
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;
server {
    ...
    #限制perip域（客户端IP）的连接数为10
    limit_conn perip 10;
    #限制perserver域（当前虚拟服务器）的连接数为100
    limit_conn perserver 100;
}
```

上面中100表示一个server站点最多连接数。10表示一个ip的最多连接数目。

如果你的站点配置了http2，正常情况下一个用户的tcp连接数目不会超过5个。可以根据具体请求进行配置。

在http字段下配置下面的设置，会将超流的内容记录到error.log 下。

```nginx
limit_conn_log_level error;
```

某个超流的日志如下：

```pgsql
2020/08/25 18:09:49 [error] 10216#0: 2445033 limiting connections by zone "hzcat", client: 120.*.3*.29, server: .com, request: "GET /xxx HTTP/2.0", host: "*.com", referrer: "https://***/xxx"
```

更多详细说明可参考Nginx官方文档：[http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html)

### ngx\_http\_core\_module限制下载速度

```apache
#数据达到100M后再限制速度（注意：这里指的是单个连接达到100M）
limit_rate_after 100M;
#限制单个连接速度为10k/s
limit_rate 10k;
```

​`limit_rate_after`​ : 指的是请求的数据达到指定大小后才开始限速（这里设置的是100M）

​`limit_rate`​ ： 设置单个连接限速值，这里设置的是10k/s，如果限制同一IP最大连接数为10的话，那么总的下载速度不能超过100k/s

更多说明参考Nginx官方文档：[http://nginx.org/en/docs/http/ngx_http_core_module.html#limit_rate](http://nginx.org/en/docs/http/ngx_http_core_module.html#limit_rate)

#### 同时限制连接数和下载速度

将上面的配置整合一下，我们既要限制单IP的最大连接数，也需要限制下载速度。

```nginx
#写在http段内
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;
#写在server段内
limit_conn perip 10;
limit_conn perserver 100;
limit_rate_after 100M;
limit_rate 10k;
```

上面配置的含义是限制单个IP最大连接数为10个，同时限制单个虚拟服务器的连接总数为100个。当请求的数据达到100M后（指单个连接达到100M）限制连接速度为为10k/s，如果产生了10个连接，最大速度不能超过100k/s

### fail2ban的使用

fail2ban 软件如其名，就是根据错误日志的匹配次数来进行ban的操作。不仅仅可以用来扫描nginx的日志，可以扫描任何日志，可以自定义filter正则表达式匹配上就可以。ban的操作也不仅仅是iptabels 来禁止，可以自定义action来进行处理。

#### 安装

```cmake
# CentOS
yum install -y fail2ban
# ubuntu使用apt的系统
sudo apt-get install -y fail2ban
```

#### 配置

安装完成后，进入`/etc/fail2ban`​，可以看到下面的目录，分别介绍他们的作用如下4：

- ​`action.d`​: 符合ban的条件后的操作
- ​`filter.d`​: 过滤器，即告诉fail2ban 如何匹配上日志中的某一行
- ​`jail.local`​: jail即监狱，在该文件里面配置一个或监狱，定义该监狱的名称，监视的log文件列表，filer，以及符合条件后的action
- ​`jail.conf`​: 这个是官方提供的一份多个监狱例子，你可以直接复制你需要的部分到jail.local中即可。

#### 使用

编辑文件，`vi /etc/fail2ban/jail.local`​，增加一个新的监狱：

```stylus
[nginxcc]
enabled  = true
filter   = nginx-limit-req
logpath  = /data/nginx/logs/xxx.xxx.error.log
        /data/nginx/logs/xxx2.xxx.error.log
maxretry = 120
findtime = 60
bantime  = 120000
action   = iptables-allports[name=nginxcc]
           sendmail-whois-lines[name=nginxcc, dest=xxx@163.com]
```

- 最开头的nginxcc是监狱的名称
- filter 使用的是fail2ban自带的一个过滤器，文件路径为`/etc/fail2ban/filter.d/nginx-limit-req.conf`​
- logpath 即监视的日志列表，这里我是监视errorlog，而不是access.log的，原因是当流量很大的时候，access.log日志刷新的很快，会导致fail2ban跟不上(之前发现明明已经ban掉了，但是日志上还是显示在匹配已经ban掉的ip的访问的日志，就很奇怪，理论上匹配的速度应该很快，但不知道为什么会出现这种情况)（所以我们需要设置好`limit_req_log_level`​和`limit_conn_log_level`​为error）
- findtime\=60 maxretry\=120 指在60s的时间段内如果有某个ip120次超流的记录，就会封禁
- bantime的单位是s
- action 封禁的操作是使用iptables工具，这个action,fail2ban 已经为我们写好了，路径在`/etc/fail2ban/action.d/iptables-allports.conf`​

还需要注意的是，`/etc/fail2ban/filter.d/nginx-limit-req.conf`​只匹配了`limit_req`​模块限流的日志，并没有匹配limit\_conn模块限流的日志，所以我们编辑该文件，增加一个新的正则匹配，一个匹配规则一行，如果是多个匹配规则，则为多行。将`failregex`​的值改为：

```ini
failregex = ^\s*\[[a-z]+\] \d+#\d+: \*\d+ .*, client: <HOST>,
```

此时可以通过下面的命令，测试你的regex能否正常的匹配到你的日志内容：

```vim
fail2ban-regex /etc/fail2ban/filter.d/test.log /etc/fail2ban/filter.d/nginx-limit-req.conf --print-all-matched
```

​`--print-all-matched`​参数用来显示所有匹配上的行，去掉该参数可以显示总体的匹配情况。

除此之外，你也许注意到了action中还有一个`sendmail`​的配置。配置了该项后，当该监狱启用、停止或者ban某个ip的时候，都会给你的dest邮箱地址发送一个邮件。前提是你的服务器配置好了`sendemail`​模块。

默认的邮件地址是`fail2ban@<hostname>`​，邮件的格式在`/etc/fail2ban/action.d/sendmail-whois-lines.conf`​ 文件中。

#### 查看

```bash
# 查看监狱工作时候的filter和ban的日志
tail -f /var/log/fail2ban.log
#启动
systemctl start fail2ban
#停止
systemctl stop fail2ban
# 重新启动
systemctl restart fail2ban
#开机启动
systemctl enable fail2ban
# 查看fail2ban模块的工作状况（一般排查错误原因的时候使用）
journalctl -r -u fail2ban.service
# 查看监狱列表
fail2ban-client status
# 查看某个监狱下的封禁情况
fail2ban-client status nginxcc
#删除某个监狱下的某个ip
fail2ban-client set nginxcc unbanip 192.168.3.3
#手动封禁某个ip
fail2ban-client set nginxcc banip 192.168.3.3
```

最后记得定时清理你的error.log以及fail2ban.log的日志，可以写一个定时任务，每隔半小时清理一次。

#### 问题

以下命令并不会生效

```gams
fail2ban-client set nginxcc unbanip 192.168.3.3
```

即使修改`/etc/fail2ban/jail.conf`​文件

```ini
banaction = ufw
banaction_allports = ufw
```

也不会生效

猫子通过自己写的[文章](https://www.hzcat.net/archives/1701484602497.html)临时解决。

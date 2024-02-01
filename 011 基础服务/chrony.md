# chrony

**什么是时间服务器**

NTP：Network Time Protocol 网络时间协议，用来同步网络中各主机的时间，在linux系统中早期使用ntp来实现，后来使用chrony来实现，Chrony 应用本身已经有几年了，其是是网络时间协议的 (NTP) 的另一种实现。

**Chrony可以同时做为ntp服务的客户端和服务端**

一直以来众多发行版里标配的都是ntpd对时服务，自rhel7/centos7 起，Chrony做为了发行版里的标配服务，不过老的ntpd服务依旧在rhel7/centos7里可以找到 。

**核心组件：**

chronyd：是守护进程，主要用于调整内核中运行的系统时间和时间服务器同步。它确定计算机增减时间的比率，并对此进行调整补偿。

chronyc：提供一个用户界面，用于监控性能并进行多样化的配置。它可以在chronyd实例控制的计算机上工作，也可以在一台不同的远程计算机上工作。

**优势**

chrony用来同步时间，来代替ntp服务，优点是很精巧的时间同步工具，更快响应时钟变化，在应对延时提供更好的稳定性能，不会出现时间空白，跨越互联网同步时间只需要几毫秒。

它的优势主要包括

- 更快的同步：能在最大程度的减少时间和频率误差，这对于非全天运行的台式计算机或系统而言非常有用
- 更快的响应速度：能够更好的响应时间频率的快速变化，这对于具备不稳定时钟的虚拟机或导致时钟频率发生变化的节能技术而言更有帮助
- 稳定：在初始同步后，它并不会停止时钟，以防对需要系统时间的程序造成影响，以及可以更好的应对延迟

**相关文件说明**

/etc/chrony.conf  主配置文件
/usr/bin/chronyc  客户端程序工具
/usr/sbin/chronyd 服务端程序

**配置文件说明**

`vim /etc/chrony.conf`

```bash

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
pool 2.centos.pool.ntp.org iburst
###指定时间服务器的地址，可以使用pool开始也可以使用server开始，iburst可以加速初始同步，perfer表示优先
# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift
#用来记录时间差异，由于chrony是通过BIOS判断时间的，他会用这个时间与上层时间服务器进行对比，将差异记录下来
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3
#让chrony可以根据需求逐步进行时间的调整，避免在某些情况下时间差异较大，导致调整时间耗时过长，以上的设置表示在误差时间大于1.0秒的话，前三次使用update更新时间是使用step（分阶段）而不是slew(微调),如果最后一个值是负数的话，如-1则表示随时步进
# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
#启用内核模式，在内核模式中，系统时间每11分钟会同步到实时时钟（RTC）
# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *
# 通过使用hwtimestamp指令启用硬件时间戳
# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16
#允许同步的网段
# Serve time even if not synchronized to a time source.
#local stratum 10
#即时自己未能通过网络时间服务器同步时间，也允许将本地时间作为标准时间同步给其他客户端
# Specify file containing keys for NTP authentication.
keyfile /etc/chrony.keys
#验证的秘钥文件
# Get TAI-UTC offset and leap seconds from the system tz database.
leapsectz right/UTC
#从system tz数据库中获取TAI(国际原子时)和UTC（协调世界时）之间的时间偏移及闰秒
# Specify directory for log files.
logdir /var/log/chrony
#日志文件的位置
# Select which information is logged.
#log measurements statistics tracking
```

## 时间服务器实战

环境：两台主机，系统为CentOS8，IP地址为192.168.2.100,192.168.2.200,selinux和防火墙关闭

要求: 192.168.2.100为内网时间服务器，192.168.2.200为客户端，200的客户端的时间要与100的时间同步

### 服务端

在192.168.2.100主机上

```bash
# step1	检查时间服务器上是否有相关软件包
rpm -qa | grep chrony


# step2	检查本机的时区
timedatectl 

# 注：如果不是本地时区请设置时区
timedatectl list-timezones | grep Shanghai
timedatectl set-timezone Asia/Shanghai

# step3	修改配置文件
vim /etc/chrony.conf
#-----------------------------------------------
pool ntp.aliyun.com iburst maxsources 4
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.2.0/24	#定义允许谁来同步
local stratum 10	#允许将本地时间作为标准
leapsectz right/UTC
logdir /var/log/chrony
#-----------------------------------------------

# step4	启动服务&查看端口
systemctl start chronyd

#启动`NTP`时间同步（启用`NTP`服务或者`Chrony`服务）
timedatectl set-ntp true
```

### 客户端

在192.168.2.200主机上

```bash

# step5	检查软件包
rpm -qa | grep chrony

# step6	检查并设置本机时区
timedatectl 

#timedatectl list-timezones |grep Shanghai
#timedatectl set-time Asia/Shanghai

# step7	修改配置文件
vim /etc/chrony.conf
#-----------------------------------------------
server 192.168.2.100 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony

#-----------------------------------------------

# step8 启动服务&检查能否连接时间服务器
systemctl start chronyd
#启动`NTP`时间同步（启用`NTP`服务或者`Chrony`服务）
timedatectl set-ntp true
chronyc sources -v

#可以在2.100上使用date -s命令修改时间，在2.200上重启服务，看到时间同步

```

‍

## 配置文件详解

```bash
# server ：指明时间服务器地址，可以添加多个
	# ibust      会在 chrony 启动的2秒内，去快速poll服务器4次来快速矫正当前系统时间。
	# prefer     优先使用指定的服务器
	# minpoll 6  缺省是6，意思是2的6次方，也就是64秒，最小轮询时间服务器的时间间隔是64秒
	# maxpoll 10 缺省是10，同上，2的10次方，也就是1024秒，最大轮询时间间隔是1024秒
	# 通常情况下一过minpoll的时间周期，就会触发一次时间同步询问。
# pool 新版本出现,指示 chrony 从一个 NTP 服务器池中选择多个服务器进行时间同步。
# pool ntp.aliyun.com iburst
server ntp1.aliyun.com iburst prefer minpoll 6 maxpoll 10
server time.neu.edu.cn iburst
server time.windows.com iburst

## 根据实际时间计算出服务器增减时间的比率，然后记录到一个文件中，在系统重启后为系统做出最佳时间补偿调整。
driftfile /var/lib/chrony/drift

# chronyd根据需求减慢或加速时间调整，
# 在某些情况下系统时钟可能漂移过快，导致时间调整用时过长。
# 该指令强制chronyd调整时期，大于某个阀值时（例如1秒）步进调整系统时钟。
# 例如：makestep 1.0 3，意思就是如果时间服务器跟系统时间相差1秒，那么就在下3个时钟更新中追上时间服务器。
makestep 1.0 3

# 把系统时钟同步到主板的硬件时钟（RTC）去，缺省情况下是11分钟同步一次。
rtcsync

# 通过使用hwtimestamp指令启用硬件时间戳
#hwtimestamp *

# 增加调整系统时钟所需最小可选源的数量。
#minsources 2
# Allow NTP client access from local network.
# 指定一台主机、子网，或者网络以允许或拒绝NTP连接到扮演时钟服务器的机器
#deny all
#allow all
allow 192.168.0.0/16
# 即使server指令中时间服务器不可用，也允许将本地时间作为标准时间授时给其它客户端。
#local stratum 10
# 从系统 tz 数据库获取 TAI-UTC 偏移量和闰秒。
leapsectz right/UTC
# 可以指定哪台主机可以通过chronyd使用控制命令。
#cmdallow / cmddeny
# 允许chronyd监听哪个接口来接收由chronyc执行的命令。
#bindcmdaddress 

# 指定包含NTP验证密钥的文件。
#keyfile /etc/chrony.keys

# 如果chrony调整的系统时间，超过了0.5秒的时长，就会发一条消息到syslog，这样我们就能在/var/log/messages里看到这条消息了。
#logchange 0.5

# 指定日志文件的目录。
logdir /var/log/chrony

# 选择日志文件要记录的信息
#log measurements statistics tracking
```

‍

‍

## chronyc命令

```bash
chronyc sources             # 查看时间同步源
chronyc sourcestats -v	    # 查看时间同步源状态
chronyc clients
timedatectl set-local-rtc 1 # 设置硬件时间硬件时间默认为UTC
timedatectl set-ntp yes	    # 启用NTP时间同步
chronyc tracking	    # 校准时间服务器检查 chrony 跟踪
chronyc -a makestep         # 立即手动同步时间（需要chronyd服务运行）
hwclock -w                  # 最后一步，将当前时间和日期写入BIOS，避免重启后失效
hwclock --localtime         # 显示 BIOS 中实际的时间
timedatectl list-timezones
timedatectl list-timezones | grep -E “Asia/Sh.*”
timedatectl set-timezone Asia/Shanghai # 修改时区为上海

#修改日期时间（可以只修改其中一个）
timedatectl set-time "2023-01-31 10:00:20"
#更改当前日期 timedatectl set-time YYYY-MM-DD
#更改当前时间 timedatectl set-time HH:MM:SS
```

‍

## 一些解释

### 示例： chronyc sourcestats -v

```
# chronyc sourcestats -v
                             .- Number of sample points in measurement set.
                            /    .- Number of residual runs with same sign.
                           |    /    .- Length of measurement set (time).
                           |   |    /      .- Est. clock freq error (ppm).
                           |   |   |      /           .- Est. error in freq.
                           |   |   |     |           /         .- Est. offset.
                           |   |   |     |          |          |   On the -.
                           |   |   |     |          |          |   samples. \
                           |   |   |     |          |          |             |
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
stratum2-1.ntp.mow01.ru.>   4   3     7   +109.899   2154.711  +4293us   233us
ntp.wdc2.us.leaseweb.net    4   4     9  +1351.895  55584.047    +64ms  9147us
sv1.ggsrv.de                4   3     7   +633.265  15331.828  -1639us  1955us
119.28.206.193              4   3     6   +965.101  32095.979    +51ms  4542us
```

1. Name/IP address 时间源的域名、IP地址或Refernce ID。
2. NP 服务器当前保留的样本点的数量。偏移率和偏移值是通过这些样本点进行线性回归计算预估的。
3. NR 这是最后一次回归计算后，具有相同符号的残差的运行次数。如果这个数字相对于样本的数量开始变得太小，则表明直线不再适合数据。如果运行的次数过低，那么chronyd将丢弃旧的样本并重新运行回归计算，直到运行的次数可以接受为止。
4. Span 表示最老的样本与最新的样本之前的时间间隔。如果没有显示单位，则单位是s（秒）。
5. Frequency 估计的时间源的residual frequency。以ppm（百万分之一）为单位。‘+’表示本地时间比时间源快，‘-’表示比时间源慢。
6. Freq Skew 这是频率的估计误差范围，以ppm（百万分之一）为单位。
7. Offset 这是估计的时间源的偏移量。
8. Std Dev 这是估计的样本标准差。

### 时区

* UTC  
  整个地球分为二十四时区，每个时区都有自己的本地时间。在国际无线电通信场合，为了统一起见，使用一个统一的时间，称为通用协调时(UTC, Universal Time Coordinated)。
* GMT  
  格林威治标准时间 (Greenwich Mean Time)指位于英国伦敦郊区的皇家格林尼治天文台的标准时间，因为本初子午线被定义在通过那里的经线。(UTC与GMT时间基本相同)
* CST  
  中国标准时间 (China Standard Time)
* DST  
  夏令时(Daylight Saving Time) 指在夏天太阳升起的比较早时，将时间拨快一小时，以提早日光的使用。（中国不使用）
* RTC  
  (Real-Time Clock)或CMOS时间，硬件时间,一般在主板上靠电池供电，服务器断电后也会继续运行。仅保存日期时间数值，无法保存时区和夏令时设置。

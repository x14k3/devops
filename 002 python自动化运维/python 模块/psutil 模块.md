# psutil 模块

psutil是一个跨平台库([http://pythonhosted.org/psutil/](http://pythonhosted.org/psutil/))能够轻松实现获取系统运行的进程和系统利用率（包括CPU、内存、磁盘、网络等）信息。它主要用来做系统监控，性能分析，进程管理。它实现了同等命令行工具提供的功能，如ps、top、lsof、netstat、ifconfig、who、df、kill、free、nice、ionice、iostat、iotop、uptime、pidof、tty、taskset、pmap等。目前支持32位和64位的Linux、Windows、OS X、FreeBSD和Sun Solaris等操作系统.

```bash
#CentOS安装psutil包：python版本：2.7
yum install python-devel
wget https://pypi.python.org/packages/source/p/psutil/psutil-3.2.1.tar.gz --no-check-certificate
tar zxvf psutil-3.2.1.tar.gz
cd psutil-3.2.1
python setup.py install
```

## CPU

*获取CPU逻辑核数。*​*`logical`*​*参数默认为*​*`True`*​ *，指获取逻辑核数。*

```
print(psutil.cpu_count(logical=True))  # 4
```

*获取CPU物理核数。*

```
print(psutil.cpu_count(logical=False))
```

*以百分比的形式返回表示当前CPU的利用率的浮点数。*​*`interval`*​*参数必须设置为大于0，因为它测试的是时间间隔内的利用率。*​*`percpu`*​*参数为*​*`True`*​*则所有CPU利用率的浮点列表，列表的顺序在调用之间是一致的。*

```
print(psutil.cpu_percent(interval=1, percpu=True))  
# [17.2, 23.4, 15.6, 15.6]
```

*在特定模式下，返回CPU所花费的时间百分比。*

```
print(psutil.cpu_times_percent(interval=1, percpu=True))  

# [scputimes(user=3.1, system=3.1, idle=92.3, interrupt=0.0, dpc=1.5), scputimes(user=0.0, system=6.2, idle=92.3, interrupt=1.5, dpc=0.0), scputimes(user=7.8, system=0.0, idle=92.2, interrupt=0.0, dpc=0.0), scputimes(user=0.0, system=1.6, idle=98.4, interrupt=0.0, dpc=0.0)]
```

*在特定模式下，返回CPU所花费的时间（单位为秒）*

```
print(psutil.cpu_times())  

# scputimes(user=24555.5, system=24045.421875, idle=470324.85937499994, interrupt=1376.078125, dpc=482.375)
```

*将CPU频率作为名称包返回，包括 以Mhz表示的当前，最小和最大频率。在Linux 当前频率上报告实时值，在所有其他平台上它代表名义上的“固定”值。如果percpu是True并且系统支持每CPU频率检索（仅限Linux），则为每个CPU返回频率列表，否则返回包含单个元素的列表。如果无法确定最小值和最大值，则将它们设置为0。*

```
print(psutil.cpu_freq(percpu=True)) 
# [scpufreq(current=2000.0, min=0.0, max=2501.0)]
```

## Memory

*获取内存使用情况。相关参数，单位（字节）：*

- total，总大小。
- available，可用内存。
- used，已使用。
- free，空闲。
- percent，使用率。
  需要注意的是，已使用和可用不等于总和。

```
print(psutil.virtual_memory())  
# svmem(total=12797194240, available=6384398336, percent=50.1, used=6412795904, free=6384398336)
```

*获取交换分区内存统计信息。相关参数，单位（字节）：*

- total，总大小。
- used，已使用地swap内存。
- free，空闲。
- sin，系统累计从磁盘交换的字节数。
- sout，系统累计从磁盘换出的字节数。

```
print(psutil.swap_memory())  # sswap(total=19490631680, used=7854170112, free=11636461568, percent=40.3, sin=0, sout=0)
```

## Disk

*返回所有磁盘分区信息。包括设备，挂载点和文件系统类型。*

```
print(psutil.disk_partitions(all=False))
'''
    [   
        sdiskpart(device='C:\\', mountpoint='C:\\', fstype='NTFS', opts='rw,fixed'), 
        sdiskpart(device='D:\\', mountpoint='D:\\', fstype='', opts='cdrom'), 
        sdiskpart(device='E:\\', mountpoint='E:\\', fstype='NTFS', opts='rw,fixed'), 
        sdiskpart(device='F:\\', mountpoint='F:\\', fstype='NTFS', opts='rw,fixed'), 
        sdiskpart(device='G:\\', mountpoint='G:\\', fstype='NTFS', opts='rw,fixed'), 
        sdiskpart(device='M:\\', mountpoint='M:\\', fstype='NTFS', opts='rw,fixed')
    ]
'''
```

*返回指定磁盘的信息。相关参数，单位（字节）：*

- total，总大小。
- used，使用。
- free，空闲。
- percent，使用率。

```
print(psutil.disk_usage('C:\\'))   # sdiskusage(total=128034672640, used=98790318080, free=29244354560, percent=77.2)
for d in psutil.disk_partitions():
    if d[3] != 'cdrom':  # 排除windows中的cd驱动器
        item = psutil.disk_usage(d[0])
        print('磁盘 {0} 总大小 {1[0]} 使用 {1[1]} 空闲 {1[2]} 使用率 {1[3]}'.format(d[0], item))
'''
磁盘 C:\ 总大小 128034672640 使用 98801184768 空闲 29233487872 使用率 77.2
磁盘 E:\ 总大小 2000396320768 使用 1566692167680 空闲 433704153088 使用率 78.3
磁盘 F:\ 总大小 368532213760 使用 107016785920 空闲 261515427840 使用率 29.0
磁盘 G:\ 总大小 314572795904 使用 86216327168 空闲 228356468736 使用率 27.4
磁盘 M:\ 总大小 317093572608 使用 133029965824 空闲 184063606784 使用率 42.0
'''
```

*获取磁盘*​*`I/O`*​*统计信息。相关参数：*

- read\_count，读取次数。
- write\_count，写入次数。
- read\_bytes，读取的字节数。
- write\_bytes，写入的字节数。

```
print(psutil.disk_io_counters())  # sdiskio(read_count=1066650, write_count=1677203, read_bytes=61252281856, write_bytes=77213490688, read_time=21399, write_time=125572)
```

## Network

bytes_sent：发送的字节数
bytes_recv：接收的字节数
packets_sent：发送的包数
packets_recv：接收的数据包数
errin：接收时的错误总数
errout：发送时的错误总数
dropin：丢弃的传入数据包总数
dropout：丢弃的传出数据包总数（macOS和BSD总是0）

```
print(psutil.net_io_counters())  # snetio(bytes_sent=195227541, bytes_recv=1240643732, packets_sent=887249, packets_recv=1320281, errin=0, errout=0, dropin=0, dropout=0)
```

*获取系统的套接字信息。每个命名元组都提供7个属性：*

- fd：套接字文件描述符。如果连接引用当前进程，则可以将其传递给socket.fromfd 以获取可用的套接字对象。在Windows和SunOS上，它始终设置为-1。
- family：地址族，AF_INET，AF_INET6或AF_UNIX。
- type：地址类型，SOCK_STREAM或SOCK_DGRAM。
- laddr：作为命名元组的本地地址或 AF_UNIX套接字的情况。对于UNIX套接字，请参阅下面的注释。(ip, port)
- raddr：作为命名元组的远程地址或UNIX套接字的绝对地址。当远程端点未连接时，您将获得一个空元组（AF_INET \*）或（AF_UNIX）。对于UNIX套接字，请参阅下面的注释。(ip, port)
- status：表示TCP连接的状态。返回值是psutil.CONN_ \*常量之一（字符串）。对于UDP和UNIX套接字，这总是如此 psutil.CONN_NONE。
- pid：打开套接字的进程的PID，如果可以检索，否则None。在某些平台（例如Linux）上，此字段的可用性会根据进程权限（需要root）而更改。

```
print(psutil.net_connections())

[sconn(fd=3, family=2, type=1, laddr=('192.168.0.200', 22), raddr=('192.168.0.100', 50429), status='ESTABLISHED', pid=11902), sconn(fd=4, family=10, type=1, laddr=('::', 22), raddr=(), status='LISTEN', pid=981), sconn(fd=6, family=10, type=2, laddr=('::1', 323), raddr=(), status='NONE', pid=667), sconn(fd=3, family=2, type=1, laddr=('192.168.0.200', 22), raddr=('192.168.0.100', 65264), status='ESTABLISHED', pid=1479), sconn(fd=3, family=2, type=1, laddr=('0.0.0.0', 22), raddr=(), status='LISTEN', pid=981), sconn(fd=5, family=2, type=2, laddr=('127.0.0.1', 323), raddr=(), status='NONE', pid=667), sconn(fd=6, family=2, type=2, laddr=('0.0.0.0', 68), raddr=(), status='NONE', pid=746)]
```

*获取网卡地址相关信息。相关参数：*

- family：地址族，AF\_INET或AF\_INET6或者`psutil.AF_LINK`指MAC地址。
- address：主NIC地址（始终设置）。
- netmask：网络掩码地址（可能是`None`）。
- 广播：广播地址（可能是`None`）。
- ptp：代表“点对点”; 它是点对点接口（通常是VPN）上的目标地址。_广播_和_ptp_是互斥的。可能是`None`。

```
print(psutil.net_if_addrs())
'''
{
'以太网': [snicaddr(family=<AddressFamily.AF_LINK: -1>, address='28-D2-44-6A-20-79', netmask=None, broadcast=None, ptp=None), snicaddr(family=<AddressFamily.AF_INET: 2>, address='192.168.0.98', netmask='255.255.255.0', broadcast=None, ptp=None)], 
'本地连接* 2': [snicaddr(family=<AddressFamily.AF_LINK: -1>, address='1A-E3-47-B5-C4-1C', netmask=None, broadcast=None, ptp=None), snicaddr(family=<AddressFamily.AF_INET: 2>, address='169.254.45.250', netmask='255.255.0.0', broadcast=None, ptp=None), snicaddr(family=<AddressFamily.AF_INET6: 23>, address='fe80::610d:c08e:fbaf:2dfa', netmask=None, broadcast=None, ptp=None)],
    ......
}
'''
```

*获取网卡的信息，相关参数：*

- isup：指示NIC是否已启动并运行的bool。
- duplex：双工通信类型; 它可以是`NIC_DUPLEX_FULL`，`NIC_DUPLEX_HALF`或`NIC_DUPLEX_UNKNOWN`
- speed：以兆位（MB）表示的NIC速度，如果无法确定（例如'localhost'），它将被设置为`0`。
- mtu：NIC的最大传输单位，以字节为单位。

```
print(psutil.net_if_stats())
'''
{
'以太网': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=1000, mtu=1500), 
'蓝牙网络连接': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=3, mtu=1500), 'VMware Network Adapter VMnet1': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=100, mtu=1500), 'VMware Network Adapter VMnet8': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=100, mtu=1500), 
'以太网 2': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=100, mtu=1500), 'Loopback Pseudo-Interface 1': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=1073, mtu=1500), 'WLAN': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=108, mtu=1500), 
'本地连接* 2': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 
'本地连接* 4': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 
'本地连接* 3': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1472)
}
'''
```

## 其他信息

*获取系统进程pid*

```
import os
import psutil
psutil.pids()  # 以列表的形式返回系统所有进程pid号
print([{psutil.Process(pid).name(): pid} for pid in psutil.pids()])   # 返回进程名称和pid的列表
os.system('taskkill /F /IM wmplayer.exe')   # 借助os模块强制杀死指定进程
```

*获取系统开机时间*

```
import time
import psutil
print(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(psutil.boot_time())))
```

*获取当前用户登录信息*

```
print(psutil.users())  
# [suser(name='Anthony', terminal=None, host='0.0.0.0', started=1559002601.0, pid=None)]
```

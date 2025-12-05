

Linux下的hdparm（英文全称：hard disk parameters）命令，主要用来查看硬盘的相关信息或对硬盘进行测速、优化、修改硬盘相关参数设定。它提供了一个命令行的接口用于读取和设置IDE或SCSI硬盘参数。

若没有安装hdparm ，可以通过`sudo yum install hdparm `​来安装。

## 1. 选项说明

```bash
-a<快取分区>：设定读取文件时，预先存入块区的分区数，若不加上<快取分区>选项，则显示目前的设定；
-A<0或1>：启动或关闭读取文件时的快取功能；
-c<I/O模式>：设定IDE32位I/O模式；
-C：检测IDE硬盘的电源管理模式；
-d<0或1>：设定磁盘的DMA模式；
-f：将内存缓冲区的数据写入硬盘，并清除缓冲区；
-g：显示硬盘的磁轨，磁头，磁区等参数；
-h：显示帮助；
-i：显示硬盘的硬件规格信息，这些信息是在开机时由硬盘本身所提供；
-I：直接读取硬盘所提供的硬件规格信息；
-k<0或1>：重设硬盘时，保留-dmu参数的设定；
-K<0或1>：重设硬盘时，保留-APSWXZ参数的设定；
-m<磁区数>：设定硬盘多重分区存取的分区数；
-n<0或1>：忽略硬盘写入时所发生的错误；
-p<PIO模式>：设定硬盘的PIO模式；
-P<磁区数>：设定硬盘内部快取的分区数；
-q:在执行后续的参数时，不在屏幕上显示任何信息；
-r<0或1>:设定硬盘的读写模式；
-S<时间>:设定硬盘进入省电模式前的等待时间；
-t;评估硬盘的读取效率；
-T：评估硬盘缓存的读取速度；
-u<0或1>：在硬盘存取时，允许其他中断要求同时执行；
-v：显示硬盘的相关设定；
-w<0或1>：设定硬盘的写入快取；
-X<传输模式>：设定硬盘的传输模式；
-y：使IDE硬盘进入省电模式；
-Y：使IDE硬盘进入睡眠模式；
-Z：关闭某些Seagate硬盘的自动省电功能。
```

## 2. 常见用法

### 2.1 显示硬盘的相关设置

```javascript
# hdparm /dev/vda

/dev/vda:
 HDIO_DRIVE_CMD(identify) failed: Inappropriate ioctl for device
 readonly      =  0 (off)
 readahead     = 8192 (on)
 geometry      = 104025/16/63, sectors = 104857600, start = 0
```

### 2.2 显示硬盘的柱面、磁头、扇区数

```javascript
# hdparm -g /dev/vda

/dev/vda:
 geometry      = 104025/16/63, sectors = 104857600, start = 0
 
 #其中：
geometry = 104025［柱面数］/16［磁头数］/63［扇区数］, sectors = 104857600［总扇区数］, start = 0［起始扇区数］
```

### 2.3 评估硬盘的读取效率

```javascript
# hdparm -t /dev/vda

/dev/vda:
 Timing buffered disk reads: 290 MB in  3.15 seconds =  92.08 MB/sec
```

### 2.4 评估硬盘缓存的读取速度

```javascript
# hdparm -T /dev/vda

/dev/vda:
 Timing cached reads:   20508 MB in  2.00 seconds = 10267.18 MB/sec
```

### 2.5 检测硬盘的电源管理模式

```javascript
# hdparm -C /dev/vda

/dev/vda:
 drive state is:  unknown
```

### 2.6 查看并设置硬盘多重扇区存取的扇区数，以增进硬盘的存取效率

```javascript
#查看
# hdparm -m /dev/vda

#设置
# hdparm -m 8 /dev/vda
```

### 2.7 读取硬盘所提供的硬件规格信息

```javascript
#hdparm -I /dev/vda
```

### 2.8 将内存缓冲区的数据写入硬盘，并清空缓冲区

```javascript
# hdparm -f /dev/vda
```

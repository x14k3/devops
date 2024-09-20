# cdrecird growisofs

## CD/DVD分类

　　DVD 可以容纳比任何 CD 更多的数据，已经成为现今视频出版业的标准。

　　我们称作可记录 DVD 的有五种物理记录格式：

* DVD-R：这是第一种可用的 DVD 可记录格式。 DVD-R 标准由 DVD Forum 定义。 这种格式是**一次可写**的。
* DVD-RW：这是 DVD-R 标准的可覆写版本。 一张 DVD-RW **可以被覆写**大约 1000 次。
* DVD-RAM：这也是一种被 DVD Forum 所支持的可覆写格式。 DVD-RAM 可以被看作一种可移动硬盘。 然而，这种介质和大部分 DVD-ROM 驱动器以及 DVD-Video 播放器不兼容； 只有少数 DVD 刻录机支持 DVD-RAM。
* DVD+RW：这是一种由 DVD+RW Alliance 定义的可覆写格式。一张 DVD+RW 可**以被覆写**大约 1000 次。
* DVD+R：这种格式是 DVD+RW 格式的**一次可写**变种。

　　一张单层的可记录 DVD 可以存储 4,700,000,000 字节，相当于 4.38 GB 或者说 4485 MB (1 千字节等于 1024 字节)。

　　光盘是以光信息做为存储的载体并用来存储数据的一种物品。分不可擦写光盘，如CD-ROM、DVD-ROM等；和可擦写光盘，如CD-RW、DVD-RAM等。光盘是利用激光原理进行读、写的设备，是迅速发展的一种辅助存储器，可以存放各种文字、声音、图形、图像和动画等多媒体数字信息。

　　光盘定义：即高密度光盘（Compact Disc）是近代发展起来不同于完全磁性载体的光学存储介质（例如：磁光盘也是光盘），用聚焦的氢离子激光束处理记录介质的方法存储和再生信息，又称激光光盘。

　　根据光盘结构，光盘主要分为CD、DVD、蓝光光盘等几种类型，这几种类型的光盘，在结构上有所区别，但主要结构原理是一致的。而只读的CD光盘和可记录的CD光盘在结构上没有区别，它们主要区别在材料的应用和某些制造工序的不同，DVD方面也是同样的道理。

> dvd+r光盘可以多次刻录吗:
>
> 可以，如果盘片未满，可以继续添加数据，但不能删除里面的东西。如果光盘上面写着DVD-R（或+R）的话，只能写入一次，但可以多次刻录(不是覆写刻录，是追加刻录，前面已刻录的文件不能删除)，直到用完整张光盘为止。如果光盘上面写着DVD-RW的话可以重复刻录，即删了前面的文件，重新刻入。

## cdrecord 刻录CD

　　**cdrecord命令**用于Linux系统下光盘刻录，它支持[cd](https://man.niaoge.com/cd "cd命令")和DVD格式。linux下一般都带有cdrecord软件。

　　‍

```bash
# 语法
cdrecord(选项)(参数)

-v              # 显示刻录光盘的详细过程；
-eject          # 刻录完成后弹出光盘；
speed=          # 刻录倍速 指定光盘刻录的倍速；
dev=            # 刻录机设备号 ：指定使用“-scanbus”参数扫描到的刻录机的设备号；
-scanbus：      # 扫描系统中可用的刻录机。


### 参数
ISO文件：指定刻录光盘使用的ISO映像文件。

### 实例
# 查看系统所有 CD-R[w]设备：
cdrecord -scanbus
scsibus0:
  0,0,0     0) *
  0,1,0     1) *
  0,2,0     2) *
  0,3,0     3) 'HP      ' 'CD-Writer+ 9200 ' '1.0c' Removable CD-ROM

# 用iso文件刻录一张光盘：
cdrecord -v -eject speed=4 dev=0,3,0 backup.iso

# 擦写光驱：
cdrecord --dev=0,3,0 --blank=fast
```

## growisofs刻录DVD

```bash
#刻录光盘语法：growisofs -dvd-compat -speed=<刻录速度> -Z <设备名>=<镜像路径>
#刻录ISO文件
sudo growisofs -dvd-compat -Z /dev/sr1=/path/to/image.iso   # 刻录ISO文件 [dvd-compat刻录完后封盘，一般iso都需要封盘]
sudo growisofs -Z /dev/sr0 -R -J /opt/file1                 # 初次刻录（非ISO文件）
sudo growisofs -M /dev/sr1 -R -J /opt/file2                 # 往已有的DVD盘上添加文件
sudo growisofs -M /dev/sr1=/dev/zero                        # 给DVD盘封口(一般用不着）
```

　　‍

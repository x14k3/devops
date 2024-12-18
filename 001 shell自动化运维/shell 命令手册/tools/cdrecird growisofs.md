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

## cdrecord 刻录cd

　　‍

```bash
## 创建 .iso 文件
mkisofs -o test.iso -Jrv -V test_disk /home/carla/

# -o 为新的 .iso 映像文件命名（test.iso）
# -J 为了与 Windows 兼容而使用 Joliet 命名记录
# -r 为了与 UNIX/Linux 兼容而使用 Rock Ridge 命名约定，它使所有文件都公共可读
# -v 设置详细模式，以便在创建映像时获得运行注释
# -V 提供了卷标识（test_disk）；该标识就是出现在 Windows 资源管理器中的盘名
#    列表中的最后一项是选择要打包到 .iso 中的文件（都在 /home/carla/ 中）


## 挂装 .iso,确认刻录内容，这一步可以跳过
mkdir /test_iso 
mount -t iso9660 -o ro,loop test.iso /test_iso


## 找到 CD-R/RW 的 SCSI 地址
cdrecord -scanbus 

## 向盘中写内容
cdrecord -v -eject speed=8 dev=2,0,0 test.iso

#-v     指详细方式
#-eject 在完成写任务后弹出盘
#-speed 指定写速度（8）
#-dev   是从 cdrecord -scanbus 获得的设备号（0,1,0）
#       最后一个是所烧录的映像的名称（test.iso）
```

## growisofs刻录dvd

```bash
#刻录光盘语法：growisofs -dvd-compat -speed=<刻录速度> -Z <设备名>=<镜像路径>
#刻录ISO文件
sudo growisofs -dvd-compat -Z /dev/sr1=/path/to/image.iso   # 刻录ISO文件 [dvd-compat刻录完后封盘，一般iso都需要封盘]
sudo growisofs -Z /dev/sr0 -R -J /opt/file1                 # 初次刻录（非ISO文件）
sudo growisofs -M /dev/sr1 -R -J /opt/file2                 # 往已有的DVD盘上添加文件
sudo growisofs -M /dev/sr1=/dev/zero                        # 给DVD盘封口(一般用不着）
```

　　‍

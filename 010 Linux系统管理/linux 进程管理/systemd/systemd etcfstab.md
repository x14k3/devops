# systemd etcfstab

/etc/fstab文件用于指定在开机时自动挂载的分区、文件系统、远程文件系统或块设备，以及它们的挂载方式。此外，执行`mount -a`​操作也可以重新挂载/etc/fstab中的所有挂载项。

通用格式大致如下：

```bash
# <device>        <dir>        <type>        <options>        <dump> <fsck>
/dev/sda1         /boot        vfat          defaults         0      0
/dev/sda2         /            ext4          defaults         0      0
/dev/sda3         /home        ext4          defaults         0      0
/dev/sda4         none         swap          defaults         0      0

```

使用systemd系统时，systemd接管了挂载/etc/fstab的任务。在系统启动的时候，systemd会读取/etc/fstab文件并通过`systemd-fstab-generator`​工具将该文件转换为systemd unit来执行，从而完成挂载任务。

systemd扩展了fstab文件的定义方式，在/etc/fstab中可使用由systemd.mount提供的挂载选项，这些选项大多以`x-systemd`​为前缀(并非所有选项都如此)，合理使用这些systemd提供的选项，可以完美地解决以前使用/etc/fstab时一些痛点。

比如，systemd.mount可以让那些要求在网络可用时的文件系统在网络已经可用的情况下才去挂载，还可以定义等待网络可用的超时时间，从而避免在开机过程中长时间卡住。

再比如，systemd可以让某个挂载项自动开始挂载和自动卸载，而不是在开机时挂载后永久挂载在后台。

## /etc/fstab文件格式回顾

以如下内容为例：

```bash
# <device>        <dir>        <type>        <options>        <dump> <fsck>
/dev/sda1         /boot        vfat          defaults         0      0
/dev/sda2         /            ext4          defaults         0      0
/dev/sda3         /home        ext4          defaults         0      0
/dev/sda4         none         swap          defaults         0      0

```

1. 第一列指定挂载项的标识符
2. 第二列指定挂载点，即挂载到哪个目录
3. 第三列指定挂载项的文件系统类型，设置为auto 时可让mount命令去推测文件系统类型
4. 第四列指定挂载选项
5. 第五列指定是否dump该文件系统，通常设置为0，表示禁用dump功能
6.  第六列指定开机挂载时的fsck顺序，通常可指定为0表示禁止fsck检查。如果需要开机做分区自检，可将根分区设置为1表示最先自检，其它分区设置为2或0

需要注意，如果第一列或第二列的值包含了空格，则空格使用`\040`​代替。例如:

```bash
PARTLABEL=EFI\040SYSTEM\040PARTITION /boot vfat defaults  0  0

```

## 第一列：挂载项标识符

/etc/fstab的第一列是挂载项的标识符，用于标识哪个设备需要被挂载。

/etc/fstab支持多种标识符类型：

* 内核识别的名称，即/dev/xxx

  * 如/dev/sda1、/dev/mapper/centos-root
  * 需注意，强烈建议不要在/etc/fstab中使用这种标识符，因为如果有多个(SATA/SCSI/IDE)设备时，每次系统启动都能可能导致设备名称改变。但如果是lvm设备，它的设备名是持久不变的，所以安全
* 文件系统LABEL：使用时需加前缀`LABEL=`​，可`lsblk -f`​或blkid查看设备对应的LABEL。如：

  ```bash
  LABEL=EFI  /boot  vfat defaults 0 0


  ```

* 文件系统UUID：使用时需加前缀`UUID=`​，可`lsblk -f`​或blkid查看对应设备的UUID，如：

  ```bash
  UUID=0a3407de-xxxx-848e92a327a3 /  ext4 defaults  0  0
  ```

* GPT分区LABEL：使用时需加前缀`PARTLABEL=`​，可使用blkid查看PARTLABEL，如：

  ```bash
  PARTLABEL=EFI\040SYSTEM\040PARTITION /boot vfat defaults  0  0
  PARTLABEL=GNU/LINUX /     ext4   defaults  0  0
  PARTLABEL=HOME      /home ext4   defaults  0  0
  ```

* GPT UUID：使用时需加前缀`PARTUUID=`​，可使用blkid查看PARTUUID，如：

  ```bash
  PARTUUID=98a81274-xxxx-03df048df366 / ext4 defaults 0 0
  ```

除了第一种标识方式外，其余四种标识方式以及LVM的标识符都是持久不变的，所以都可以安全地在/etc/fstab中使用。

## 第四列：systemd提供的一些有用的挂载技巧

systemd提供了一些以`x-systemd`​为前缀的挂载选项，还提供了`auto noauto nofail _netdev`​这四个选项。

* ​`auto、noauto`​：auto表示开机自动挂载，noauto表示开机不自动挂载(且`mount -a`​也不自动挂载该挂载项)，但如果本挂载项被其它Unit一来，则noauto时仍然会被挂载
* ​`nofail`​：开机时，不在乎也不等待本挂载项，即使本挂载项在开机时挂载失败也无所谓
* ​`_netdev`​：通常mount可以根据指定的文件系统类型来推测是否是网络设备，如果是网络设备，则自动安排在网络可用之后执行挂载操作，但某些时候无法推测，比如ISCSI这类依赖于网络的块设备，使用该选项可以直接告知mount这是一个网络设备

更多挂载选项参考`man systemd.mount`​。

### 延迟到第一次访问时自动挂载

例如，对于一些本地文件系统，可以将挂载选项设置为：

```bash
noauto,x-systemd.automount
```

​`noauto`​表示开机时不要自动挂载，`x-systemd.automount`​表示在第一次对该文件系统进行访问时自动挂载。

内核会将从触发自动挂载到挂载成功期间所有对该设备的访问缓冲下来，当挂载成功后再去访问该设备。

### 自动卸载设备

```bash
noauto,x-systemd.automount,x-systemd.idle-timeout=1min
```

这表示systemd如果发现该设备在1分钟内都处于idle状态，将自动卸载它。默认单位为秒，支持的单位有`s, min, h, ms`​，设置为0表示永不超时。

### 设置远程网络设备挂载超时时长

挂载网络设备时可能会因为各种原因而长时间等待，可设置`x-systemd.mount-timeout`​选项。如：

```bash
noauto,x-systemd.automount,x-systemd.mount-timeout=30,_netdev
```

​`x-systemd.mount-timeout=30`​表示systemd最多等待该设备在30秒内挂载成功。默认单位为秒，支持的单位有`s, min, h, ms`​，设置为0表示永不超时。

### 存在则挂载，不存在则忽略

使用`nofaile`​挂载选项，在挂载失败时(比如设备不存在)直接跳过。

```bash
nofail,x-systemd.device-timeout=1ms
```

​`nofail`​通常会结合`x-systemd.device-timeout`​一起使用，表示等待该设备多长时间才认为可用于挂载(即判断该设备可执行挂载操作)，默认等待90s，这意味着如果结合`nofail`​时，如果挂载的设备不存在，将会卡顿90s。默认单位为秒，支持的单位有`s, min, h, ms`​，设置为0表示永不超时。

注意区分`x-systemd.device-timeout`​和`x-systemd.mount-timeout`​：

* 前者表示等待设备可用于挂载的时间，比如设备目前不存在，因此不可用于挂载，但可能稍后会存在，如果在超时时间段内设备仍不可用于挂载，则不执行挂载操作并认为挂载失败
* 后者表示执行挂载操作的等待时长，如果在超时时间段内还未挂载成功，则认为挂载失败

### 关于atime的挂载选项

读、写文件都会更改atime信息，但很多时候atime这项信息是无关紧要的，它仅表示文件最近一次是何时访问的，只有那些需要实时了解atime信息的程序才在意atime是否更新。

因为atime信息保存在文件系统的inode中，所以每次更新atime都会去访问磁盘，而访问磁盘的效率是非常低的。比如对于机械硬盘来说，频繁更新atime将导致大量磁盘寻道。

如果可以放弃维护atime的读更新，将减少额外的磁盘访问，可大幅提升性能。

挂载文件系统时，可以通过atime相关的挂载选项控制如何更新atime，从而在文件系统层次保证不会因为频繁更新atime而降低文件系统性能。

atime相关挂载选项有：

* ​`strictatime`​：每次访问文件时都更新文件的atime，显然这会严重降低文件系统性能
* ​`noatime`​：在读文件时，禁止更新atime。写文件时，会自动将atime信息更新到inode中
* ​`nodiratime`​：读文件时不更新所在目录的atime

  * 使用`noatime`​时将隐含`nodiratime`​，所以无需同时指定这两项
* ​`relatime`​：读文件时，如果该文件目前的atime信息早于mtime/ctime(这意味着修改过内容但没有更新atime)，则更新atime，且如果本次读文件时发现目前的atime距离现在已经超过24小时，则也立即更新atime

  * 当使用`defaults`​挂载选项时，默认将使用relatime选项。defaults挂载选项表示使用内核的默认值，而内核中对atime的更新行为默认是relatime
* ​`lazytime`​：这是Kernel 4.0才支持的atime更新策略，该选项表示只在内存中维护inode中的atime/mtime和ctime信息，当遇到如下情况时才将inode中的时间戳更新到磁盘上：

  * (1).当inode中和时间戳无关的信息需要更新时(比如文件大小、文件权限)，会顺便把时间戳信息也更新到磁盘(因为会更新整个inode)
  * (2).发生sync类操作时
  * (3).从内存中驱逐未被删除的inode时
  * (4).内存中的atime距离现在已经超出24小时

​`lazytime`​不是独立使用的选项，它可以结合前面的几种atime更新选项，默认它结合的是`relatime`​。但即使它结合的是`strictatime`​，所能达到的性能也至少是单个`relatime`​选项所能达到的性能。

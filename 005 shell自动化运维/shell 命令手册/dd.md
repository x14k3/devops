# dd

‍

> **dd 命令** 用于复制文件并对原文件的内容进行转换和格式化处理。dd 命令功能很强大的，对于一些比较底层的问题，使用 dd 命令往往可以得到出人意料的效果。用的比较多的还是用 dd 来备份裸设备。但是不推荐，如果需要备份 oracle 裸设备，可以使用 rman 备份，或使用第三方软件备份，使用 dd 的话，管理起来不太方便。

建议在有需要的时候使用 dd 对物理磁盘操作，如果是文件系统的话还是使用 tar backup cpio 等其他命令更加方便。另外，使用 dd 对磁盘操作时，最好使用块设备文件。

‍

## 选项

```bash
bs=<字节数>：将ibs（输入）与obs（输出）设成指定的字节数；
cbs=<字节数>：转换时，每次只转换指定的字节数；
conv=<关键字>：指定文件转换的方式；
count=<区块数>：仅读取指定的区块数；
ibs=<字节数>：每次读取的字节数；
obs=<字节数>：每次输出的字节数；
of=<文件>：输出到文件；
seek=<区块数>：一开始输出时，跳过指定的区块数；
skip=<区块数>：一开始读取时，跳过指定的区块数；
--help：帮助；
--version：显示版本信息。
```

‍

## **生成随机字符串**

```bash
dd if=/dev/urandom bs=1 count=15|base64 -w 0
15+0 records in
15+0 records out
15 bytes (15 B) copied, 0.000111993 s, 134 kB/s
wFRAnlkXeBXmWs1MyGEs
```

## 快速创建大文件

```bash
dd if=/dev/zero of=test1 bs=102400 count=1024  # 100MB
```

## 用dd命令制作ISO镜像U盘启动盘

```bash
dd if=~/Desktop/ubuntu-18.04.3-desktop-amd64.iso of=/dev/sdb
dd if=~/Downloads/debian-11.3.0-amd64-netinst.iso of=/dev/sdb bs=1M status=progress
```

## 创建swap分区

```bash
#第一步：创建一个大小为1G的文件：
dd if=/dev/zero of=/swapfile bs=1M count=1024
#第二步：把这个文件变成swap文件：
mkswap /swapfile
#第三步：启用这个swap文件：
swapon /swapfile
#第四步：编辑/etc/fstab文件，使在每次开机时自动加载swap文件：
echo "/swapfile    swap    swap    default   0 0 "  >> /etc/fstab
```

附：Linux下设置swappiness参数来配置内存使用到多少才开始使用swap分区

```bash
sysctl -a | grep vm.swappiness
vm.swappiness = 60
#说明你的内存在使用到100-60=40%的时候，就开始出现有交换分区的使用
vim /etc/sysctl.conf
vm.swappiness = 10
# 生效
sudo sysctl -p
```

## 常用案例汇总

```bash
# 1.将本地的/dev/hdb整盘备份到/dev/hdd
dd if=/dev/hdb of=/dev/hdd

# 2.将/dev/hdb全盘数据备份到指定路径的image文件
dd if=/dev/hdb of=/root/image

# 3.将备份文件恢复到指定盘
dd if=/root/image of=/dev/hdb

# 4.备份/dev/hdb全盘数据，并利用gzip工具进行压缩，保存到指定路径
dd if=/dev/hdb | gzip > /root/image.gz

# 5.将压缩的备份文件恢复到指定盘
gzip -dc /root/image.gz | dd of=/dev/hdb

# 6.备份与恢复MBR
# 备份磁盘开始的512个字节大小的MBR信息到指定文件：
dd if=/dev/hda of=/root/image count=1 bs=512
#count=1指仅拷贝一个块；bs=512指块大小为512个字节。
#恢复：
dd if=/root/image of=/dev/had
#将备份的MBR信息写到磁盘开始部分

# 7.备份软盘
dd if=/dev/fd0 of=disk.img count=1 bs=1440k (即块大小为1.44M)

# 8.拷贝内存内容到硬盘
dd if=/dev/mem of=/root/mem.bin bs=1024 (指定块大小为1k)  

# 9.拷贝光盘内容到指定文件夹，并保存为cd.iso文件
dd if=/dev/cdrom(hdc) of=/root/cd.iso

# 10.销毁磁盘数据
dd if=/dev/urandom of=/dev/hda1
#注意：利用随机的数据填充硬盘，在某些必要的场合可以用来销毁数据。

# 11.测试硬盘的读写速度
dd if=/dev/zero bs=1024 count=1000000 of=/root/1Gb.file
dd if=/root/1Gb.file bs=64k | dd of=/dev/null
#通过以上两个命令输出的命令执行时间，可以计算出硬盘的读、写速度。

# 12.确定硬盘的最佳块大小：
dd if=/dev/zero bs=1024 count=1000000 of=/root/1Gb.file
dd if=/dev/zero bs=2048 count=500000 of=/root/1Gb.file
dd if=/dev/zero bs=4096 count=250000 of=/root/1Gb.file
dd if=/dev/zero bs=8192 count=125000 of=/root/1Gb.file
#通过比较以上命令输出中所显示的命令执行时间，即可确定系统最佳的块大小。

# 13.修复硬盘：
dd if=/dev/sda of=/dev/sda 或dd if=/dev/hda of=/dev/hda
#当硬盘较长时间(一年以上)放置不使用后，磁盘上会产生magnetic flux point，当磁头读到这些区域时会遇到困难，并可能导致I/O错误。当这种情况影响到硬盘的第一个扇区时，可能导致硬盘报废。上边的命令有可能使这些数 据起死回生。并且这个过程是安全、高效的。

# 14.利用netcat远程备份
dd if=/dev/hda bs=16065b | netcat < targethost-IP > 1234
#在源主机上执行此命令备份/dev/hda
netcat -l -p 1234 | dd of=/dev/hdc bs=16065b
#在目的主机上执行此命令来接收数据并写入/dev/hdc
netcat -l -p 1234 | bzip2 > partition.img
netcat -l -p 1234 | gzip > partition.img
#以上两条指令是目的主机指令的变化分别采用bzip2、gzip对数据进行压缩，并将备份文件保存在当前目录。

# 15.将一个很大的视频文件中的第i个字节的值改成0x41（也就是大写字母A的ASCII值）
echo A | dd of=bigfile seek=$i bs=1 count=1 conv=notrunc
```

‍

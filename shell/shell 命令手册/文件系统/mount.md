
## mount

**mount命令** Linux mount命令是经常会使用到的命令，它用于挂载Linux系统外的文件。

如果通过webdav协议挂载网络磁盘，需要运行指令`apt install davfs2`​安装必要的组件

### 语法

```
mount [-hV]
mount -a [-fFnrsvw] [-t vfstype]
mount [-fnrsvw] [-o options [,...]] device | dir
mount [-fnrsvw] [-t vfstype] [-o options] device dir
```

### 选项

```bash
-V    显示程序版本
-h    显示辅助讯息
-v    显示较讯息，通常和 -f 用来除错。
-a    将 /etc/fstab 中定义的所有档案系统挂上。
-F    这个命令通常和 -a 一起使用，它会为每一个 mount 的动作产生一个行程负责执行。在系统需要挂上大量 NFS 档案系统时可以加快挂上的动作。
-f    通常用在除错的用途。它会使 mount 并不执行实际挂上的动作，而是模拟整个挂上的过程。通常会和 -v 一起使用。
-n    一般而言，mount 在挂上后会在 /etc/mtab 中写入一笔资料。但在系统中没有可写入档案系统存在的情况下可以用这个选项取消这个动作。
-s-r  等于 -o ro
-w    等于 -o rw
-L    将含有特定标签的硬盘分割挂上。
-U    将档案分割序号为 的档案系统挂下。-L 和 -U 必须在/proc/partition 这种档案存在时才有意义

-t    指定文件系统的类型，通常不必指定。mount 会自动选择正确的类型。常用类型有：
  DOS fat16文件系统：msdos
  Windows 9x fat32文件系统：vfat
  Windows NT ntfs文件系统：ntfs
  Windows网络文件共享：smbfs （默认的windows系统都支持的）
  windows网络共享文件：cifs （cifs是smbfs的升级版，默认的windows系统都支持的，首先推荐）
  光盘或光盘镜像：iso9660
  UNIX(LINUX) 文件网络共享：nfs

-o options 主要用来描述设备或档案的挂接方式。常用的参数有：
  defaults 使用预设的选项 rw, suid, dev, exec, auto, nouser, and async.
  loop   用来把一个文件当成硬盘分区挂接上系统
  ro  用唯读模式挂上。
  rw  用可读写模式挂上。
  async  打开非同步模式，所有的档案读写动作都会用非同步模式执行。
  sync   在同步模式下执行。
  auto   打开/关闭自动挂上模式。
  dev    允许执行档被执行。
  suid   允许执行档在 root 权限下执行。
  user   使用者可以执行 mount/umount 的动作。
  remount 将一个已经挂下的档案系统重新用不同的方式挂上。例如原先是唯读的系统，现在用可读写的模式重新挂上。

```

‍

### 实例

#### 将 `/dev/hda1`​ 挂在 `/mnt`​ 之下。

```
mount /dev/hda1 /mnt
```

将 `/dev/hda1`​ 用唯读模式挂在 `/mnt`​ 之下。

```
mount -o ro /dev/hda1 /mnt
```

将 `/tmp/image.iso`​ 这个光碟的 `image`​ 档使用 `loop`​ 模式挂在 `/mnt/cdrom`​ 之下。用这种方法可以将一般网络上可以找到的 `Linux`​ 光 碟 ISO 档在不烧录成光碟的情况下检视其内容。

```
mount -o loop /tmp/image.iso /mnt/cdrom
```

‍

#### 通过 webdav 协议挂载网络硬盘

将`https://your.webdav.link.here`​的网络存储以网络磁盘的形式挂载到系统路径`/path/to/mount`​

```
mount -t davfs https://your.webdav.link.here /path/to/mount
```

#### 永久挂载（开机自动挂载）

((20230610173764-f6u7nhy 'fstab参数说明'))

```bash
# 自动挂载
echo '/dev/sdb1 /data xfs defaults 0 0' >> /etc/fstab
```

#### Linux 访问windows共享文件的几种方式

##### samba方式

```
yum install samba-client.x86_64 #安装samba客户端
smbclient //192.168.211.1/test_samba    #通过samba打开windows共享目录
smbclient //192.168.1.1/smb_share/ -U smb_user  #系统提示输入smb_user_passwd
smbclient //192.168.1.1/smb_share/ smb_user_passwd -U smb_user  #不提示输入密码
```

‍

##### mount方式

```bash
yum install cifs-utils #安装cifs工具包 （用于取代被淘汰的smbfs） 

#首先创建被挂载的目录： 
mkdir windows 

#将共享文件夹挂载到windows文件夹： 
mount -t cifs -o username=share,password=share //192.168.66.198/share ./windows 
```

‍

## umount

用于卸载已经加载的文件系统

**umount命令** 用于卸载已经加载的文件系统。利用设备名或挂载点都能umount文件系统，不过最好还是通过挂载点卸载，以免使用绑定挂载（一个设备，多个挂载点）时产生混乱。

### 语法

```
umount(选项)(参数)
```

### 选项

```
-a：卸除/etc/mtab中记录的所有文件系统；
-h：显示帮助；
-n：卸除时不要将信息存入/etc/mtab文件中；
-r：若无法成功卸除，则尝试以只读的方式重新挂入文件系统；
-t<文件系统类型>：仅卸除选项中所指定的文件系统；
-v：执行时显示详细的信息；
-V：显示版本信息。
```

### 参数

文件系统：指定要卸载的文件系统或者其对应的设备文件名。

### 实例

下面两条命令分别通过设备名和挂载点卸载文件系统，同时输出详细信息：

通过设备名卸载

```
umount -v /dev/sda1
/dev/sda1 umounted
```

通过挂载点卸载

```
umount -v /mnt/mymount/
/tmp/diskboot.img umounted
```

如果设备正忙，卸载即告失败。卸载失败的常见原因是，某个打开的shell当前目录为挂载点里的某个目录：

```
umount -v /mnt/mymount/
umount: /mnt/mymount: device is busy
umount: /mnt/mymount: device is busy
```

有时，导致设备忙的原因并不好找。碰到这种情况时，可以用lsof列出已打开文件，然后搜索列表查找待卸载的挂载点：

```
lsof | grep mymount         查找mymount分区里打开的文件
bash   9341  francois  cwd   DIR   8,1   1024    2 /mnt/mymount
```

从上面的输出可知，mymount分区无法卸载的原因在于，francois运行的PID为9341的bash进程。

对付系统文件正忙的另一种方法是执行延迟卸载：

```
umount -vl /mnt/mymount/     执行延迟卸载
```

延迟卸载（lazy unmount）会立即卸载目录树里的文件系统，等到设备不再繁忙时才清理所有相关资源。卸载可移动存储介质还可以用eject命令。下面这条命令会卸载cd并弹出CD：

```
eject /dev/cdrom      卸载并弹出CD 
```

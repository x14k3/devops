# Linux好用命令之mount命令

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
#mount /dev/hda1 /mnt
```

将 `/dev/hda1`​ 用唯读模式挂在 `/mnt`​ 之下。

```
#mount -o ro /dev/hda1 /mnt
```

将 `/tmp/image.iso`​ 这个光碟的 `image`​ 档使用 `loop`​ 模式挂在 `/mnt/cdrom`​ 之下。用这种方法可以将一般网络上可以找到的 `Linux`​ 光 碟 ISO 档在不烧录成光碟的情况下检视其内容。

```
#mount -o loop /tmp/image.iso /mnt/cdrom
```

‍

#### 通过 webdav 协议挂载网络硬盘

将`https://your.webdav.link.here`​的网络存储以网络磁盘的形式挂载到系统路径`/path/to/mount`​

```
mount -t davfs https://your.webdav.link.here /path/to/mount
```

#### 永久挂载

fstab参数说明

```bash
# 自动挂载
echo '/dev/sdb1 /data xfs defaults 0 0' >> /etc/fstab
```

# dattobd

dattobd (Datto Block Driver) dattobd （Datto Block Driver）

Dattobd 的主要功能是实时备份 Linux 系统。  Dattobd 是一个用于时间点实时快照的开源 Linux 内核模块

它可以加载到正在运行的 Linux 计算机上（无需重新启动）。在第一个快照之后，驱动程序会跟踪块设备的增量更改，因此可用于通过仅复制已更改的块来有效更新现有备份。

支持最常见的文件系统：ext2,3,4  xfs  

## 源码安装

[https://github.com/datto/dattobd](https://github.com/datto/dattobd)

```bash




# 加载
modprobe dattobd
# 检查 
cat /proc/datto-info
```

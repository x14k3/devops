# linux系统启动流程分析

## 引言

最近在看 Cobbler 相关资料，提到了要熟悉 Linux 系统的启动流程，很久没有接触这方面了，有些生疏遗忘了，
于是重新复习了下，真要深究，可以分为好多步。

首先贴一张总结得比较好图：

​![Linux 操作系统启动流程图](assets/net-img-111242100-20240415162953-fhzh351.png)[http://img1.51cto.com/attachment/201206/111242100](http://img1.51cto.com/attachment/201206/111242100)

下面进行文字版本再说明：

## 第一阶段：硬件引导启动阶段

```
1.1 POST(Power On Self Test) 加电自检
1.2 BIOS
1.2.1 初始化硬件
1.2.2 查找启动介质
HDD: 查找启动硬盘的第一个扇区（MBR/BootSector）
1.3 MBR
1.3.1 Bootloader（启动装载程序）
GRUB
分区表
```

## 第二阶段：BootLoader 启动引导阶段

```
2.1 Stage1
执行 BootLoader 主程序(位于 MBR 前 446个字节)，它的作用是启动 Stage1.5 或 Stage2
2.2 Stage1.5
Stage1.5 是桥梁，由于 Stage2 较大，存放在文件系统中，需要 Stage1.5 引导位于文件系统中的 Stage2
2.3 Stage2
Stage2 是 GRUB 的核心映像
2.4 grub.conf
Stage2 解析 grub.conf 配置文件，加载内核到内存中
```

## 第三阶段：内核引导阶段

```
3.1 /boot/kernel and Kernel parameter 
内核初始化，加载基本的硬件驱动

3.2 /boot/initrd
引导 initrd 解压载入
3.2.1 阶段一：在内存中释放供 kernel 使用的 root filesystem
执行 initrd 文件系统中的 init，完成加载其他驱动模块
3.2.2 阶段二：执行真正的根文件系统中的 /sbin/init 进程
```

## 第四阶段：Sys V init 初始化阶段

```
4.1 /sbin/init
4.1.1 /etc/inittab
init 进程读取 /etc/inittab 文件，确定系统启动的运行级别
4.1.2 /etc/rc.d/rc.sysinit
执行系统初始化脚本，对系统进行基本的配置
4.1.3 /etc/rc.d/rcN.d
根据先前确定的运行级别启动对应运行级别中的服务
4.1.4 /etc/rc.d/rc.local
执行用户自定义的开机启动程序
4.2 登录
4.2.1 /sbin/mingetty (命令行登录)
验证通过 执行 /etc/login 
加载 /etc/profile  ~/.bash_profile  ~/.bash_login  ~/.profile
取得 non-login Shell

4.2.2 /etc/X11/prefdm (图形界面登录)
gdm kdm xdm
Xinit
加载 ~/.xinitrc  ~/.xserverrc
```

## 第五阶段：启动完成

# sysstat

> ​`sysstat`​是一个软件包，包含监测系统性能及效率的一组工具，这些工具对于我们收集系统性能数据，比如：CPU 使用率、硬盘和网络吞吐数据，这些数据的收集和分析，有利于我们判断系统是否正常运行，是提高系统运行效率、安全运行服务器的得力助手。
>
> 官方网站: [http://sebastien.godard.pagesperso-orange.fr](http://sebastien.godard.pagesperso-orange.fr)

## 包含的工具

- [iostat](iostat.md)

  > 输出CPU的统计信息和所有I/O设备的输入输出（I/O）统计信息
  >
- [mpstat](mpstat.md)

  > 关于CPU的详细信息（单独输出或者分组输出）
  >
- [pidstat](pidstat.md)

  > 关于运行中的进程/任务、CPU、内存等的统计信息
  >
- [sar](sar.md)

  > 保存并输出不同系统资源（CPU、内存、IO、网络、内核等）的详细信息
  >
- **sadc**

  > 系统活动数据收集器，用于收集sar工具的后端数据
  >
- **sa1**

  > 系统收集并存储sadc数据文件的二进制数据，与sadc工具配合使用
  >
- **sa2**

  > 配合sar工具使用，产生每日的摘要报告
  >
- **sadf**

  > 用于以不同的数据格式（CVS或者XML）来格式化sar工具的输出
  >
- **sysstat**

  > sysstat 工具包的 man 帮助页面。
  >
- **nfsiostat**

  > NFS（Network File System）的I/O统计信息
  >
- **cifsiostat**

  > CIFS(Common Internet File System)的统计信息
  >

## 安装

### **CentOS**

通过`yum`​安装：

```bash
yum install sysstat
```

或者通过`rpm`​包安装：

```bash
wget -c http://pagesperso-orange.fr/sebastien.godard/sysstat-11.7.3-1.x86_64.rpm

sudo rpm -Uvh sysstat-11.7.3-1.x86_64.rpm
```

推荐`rpm`​包方式安装，因为能随时安装最新版本。

### **Ubuntu**

```bash
apt-get install sysstat
```

### **编译安装**

从[官网下载](http://sebastien.godard.pagesperso-orange.fr/download.html)最新的源码包，并解压。编译和安装命令：

```bash
./configure
make
su
<enter root password>
make install
```

其他具体的安装信息可以看[官方文档](http://sebastien.godard.pagesperso-orange.fr/documentation.html)。

查看是否成功安装：

```fallback
mpstat -V
sysstat version 9.0.4
(C) Sebastien Godard (sysstat <at> orange.fr)
```

‍

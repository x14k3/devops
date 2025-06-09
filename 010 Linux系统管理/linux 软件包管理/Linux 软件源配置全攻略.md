# Linux 软件源配置全攻略

‍

## 前言

Linux 操作系统安装软件比较常用的一些命令 `yum`​、`dnf`​、`apt-get`​、`zypper`​ 以及 `pacman`​。这些命令分别对应不同的操作系统，大致可以分为 `RHEL`​，`DEB`​，`SUSE`​ 和 `ARCH`​ 四种。

Linux 系统安装软件必须要配置软件源，可以分为网络和本地两种方式。

- 网络源：必须要连接外网，连接到软件源 REPO 进行软件的下载安装。
- 本地源：使用安装的镜像文件（ISO）配置本地软件源，无需联网，比较适合内网使用，安全可控。

‍

## 操作系统

本文主要介绍以下 Linux 操作系统如何配置软件源（点击链接可以下载 ISO 镜像）：

- [RedHat 6/7/8/9 全系](https://developers.redhat.com/products/rhel/download)
- [OracleLinux 6/7/8/9 全系](https://yum.oracle.com/oracle-linux-isos.html)
- [Centos 6/7/8 全系](https://mirrors.tuna.tsinghua.edu.cn/centos/)
- [Rocky Linux 8/9 全系](https://rockylinux.org/download)
- [AlmaLinux 8/9 全系](https://almalinux.org/get-almalinux)
- [SUSE 12/15 全系](https://www.suse.com/download/sles/)
- [华为欧拉 openEuler 20~24 全系](https://mirrors.tuna.tsinghua.edu.cn/openeuler/)
- [华为欧拉 EulerOS V2 全系](https://tools.mindspore.cn/productrepo/iso/euleros/x86_64/)
- [阿里龙蜥 openAnolis 7/8 全系](https://openanolis.cn/download)
- [银河麒麟 Kylin V10 全系](https://sx.ygwid.cn:4431/)
- [中标麒麟 NeoKylin V7 全系](https://sx.ygwid.cn:4431/)
- [统信 UOS V20 全系](https://cdimage-download.chinauos.com/)
- [NingOS](https://www.h3c.com/cn/Service/Document_Software/Software_Download/Server/Catalog/system/system/NingOS/)
- [OpenCloudOS 7/8/9 全系](https://www.opencloudos.tech/ospages/downloadISO)
- [Debian 全系](https://mirrors.tuna.tsinghua.edu.cn/debian-cd/)
- [Deepin 全系](https://mirrors.tuna.tsinghua.edu.cn/deepin-cd/)
- [Ubuntu 全系](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/)
- [ArchLinux](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/)
- [Fedora 13~39 全系](https://fedoraproject.org/zh-Hans/server/download/)
- [红旗 asianux](https://bbs.chinaredflag.cn/?download2.htm)
- [中科方德](https://www.nfschina.com/index.php?catid=24)

## 配置本地软件源

配置本地软件源的方式需要先挂载本地 ISO 安装镜像，所以先介绍下如何在操作系统快速挂载 ISO 安装镜像。

## 挂载 ISO 镜像

挂载分为两种方式：

1、上传 iso 安装镜像到服务器主机指定目录下，以 `/iso`​ 为例：

```
mount -o loop /iso/iso镜像包名称 /mnt
```

2、直接虚拟机或者物理主机层面挂载 iso 安装镜像：

```
mount /dev/sr0 /mnt
```

挂载完之后，通过 `df -Th /mnt`​ 查看挂载情况：

```
df -Th /mnt
```

以上两种方式都可以实现挂载，具体看情况使用即可。

下面命令均为一键配置本地软件源方式，默认 ISO 安装镜像挂载在 `/mnt`​ 目录下，直接复制使用即可。

## RHEL 系

RHEL 系有以下操作系统：

- Centos
- RedHat
- OracleLinux
- RockyLinux
- AlmaLinux
- OpenCloudOS
- 阿里龙蜥 Anolis
- 中标麒麟 NeoKylin V7

RHEL 系的操作系统软件源配置目录均为：`/etc/yum.repos.d`​。

### 6~7 全系

```bash
## 备份系统初始配置文件
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat<<-EOF>/etc/yum.repos.d/local.repo
[server]
name=server
baseurl=file:///mnt
enabled=1
gpgcheck=0
EOF
## 查看配置好的软件源
cat /etc/yum.repos.d/local.repo
```

### 8~9 全系

rhel 从 8 版本开始，安装命令从 `yum`​ 替换为 `dnf`​，但是 `yum`​ 命令还是可以使用。

```
## 备份系统初始配置文件
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat <<-EOF > /etc/yum.repos.d/local.repo
[BaseOS]
name=BaseOS
baseurl=file:///mnt/BaseOS
enabled=1
gpgcheck=0
[AppStream]
name=AppStream
baseurl=file:///mnt/AppStream
enabled=1
gpgcheck=0
EOF
## 查看配置好的软件源
cat /etc/yum.repos.d/local.repo
```

## kylinV10/NingOS/红旗asianux/中科方德NFS

```
## 备份系统初始配置文件
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat<<-EOF>/etc/yum.repos.d/local.repo
[server]
name=server
baseurl=file:///mnt
enabled=1
gpgcheck=0
EOF
## 查看配置好的软件源
cat /etc/yum.repos.d/local.repo
```

## SUSE

SUSE 系的操作系统软件源配置目录均为：`/etc/zypp/repos.d/`​

### SUSE 12 全系

```
## 备份系统初始配置文件
mkdir -p /etc/zypp/repos.d/bak
mv /etc/zypp/repos.d/* /etc/zypp/repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
zypper ar -f /mnt sles
```

### SUSE 15 全系

```
## 备份系统初始配置文件
mkdir -p /etc/zypp/repos.d/bak
mv /etc/zypp/repos.d/* /etc/zypp/repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
zypper ar -f /mnt/Module-Basesystem sles
zypper ar -f /mnt/Module-Legacy sles-Legacy
zypper ar -f /mnt/Module-Development-Tools sles-Tools
```

## 华为欧拉 openEuler

openEuler 软件源配置全版本通用：

```
## 备份系统初始配置文件
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat <<-EOF > /etc/yum.repos.d/local.repo
[openEuler]
name=openeuler
baseurl=file:///mnt
enabled=1
gpgcheck=1
gpgkey=file:///mnt/RPM-GPG-KEY-openEuler
EOF
## 查看配置好的软件源
cat /etc/yum.repos.d/local.repo
```

## 统信 UOS

## A 系

A 系采用的是 openAnolis 技术路线，使用命令方面：在线安装是 dnf 或 yum 命令，离线安装包是 rpm 包。

配置方式参考 RHEL 系。

## C 系

C 系基于 CentOS 社区发行版进行二次商业化发行的 Linux 操作系统。使用命令方面：在线安装是 dnf 或 yum 命令，离线安装包是 rpm 包。

配置方式参考 RHEL 系。

## D 系

D 系采用的是 Debian 技术路线，使用命令方面：在线安装是 apt 命令，离线安装包是 deb 包。

```
uos_codename=$(grep -oP '^VERSION_CODENAME="?(\K[^"]+|[^"]+$)' /etc/os-release)
## 备份系统初始配置文件
mkdir -p /etc/apt/bak
mv /etc/apt/sources.list /etc/apt/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat <<-EOF > /etc/apt/sources.list
deb [trusted=yes] file:///mnt $uos_codename main
EOF
## 查看配置好的软件源
cat /etc/apt/sources.list
```

## E 系

E 系采用的是 openEuler 技术路线，使用命令方面：在线安装是 dnf 或 yum 命令，离线安装包是 rpm 包。

```
## 备份系统初始配置文件
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak
## 一键配置软件源，默认 ISO 安装镜像挂载在 /mnt 目录下
cat <<-EOF > /etc/yum.repos.d/local.repo
[BaseOS]
name=BaseOS
baseurl=file:///mnt/BaseOS
enabled=1
gpgcheck=0
[AppStream]
name=AppStream
baseurl=file:///mnt/AppStream
enabled=1
gpgcheck=0
EOF
## 查看配置好的软件源
cat /etc/yum.repos.d/local.repo
```

# dnf

**DNF** 是新一代的rpm软件包管理器。他首先出现在 Fedora 18 这个发行版中。而最近，它取代了yum，正式成为 Fedora 22 的包管理器。

DNF包管理器克服了YUM包管理器的一些瓶颈，提升了包括用户体验，内存占用，依赖分析，运行速度等多方面的内容。DNF使用 RPM, libsolv 和 hawkey 库进行包管理操作。尽管它没有预装在 CentOS 和 RHEL 7 中，但你可以在使用 YUM 的同时使用 DNF 。

DNF 的最新稳定发行版版本号是 1.0，发行日期是2015年5月11日。 这一版本的 DNF 包管理器（包括在他之前的所有版本） 都大部分采用 Python 编写，发行许可为GPL v2.

## 安装 DNF 包管理器

DNF 并未默认安装在 RHEL 或 CentOS 7系统中，但是 Fedora 22 已经默认使用 DNF .

1、为了安装 DNF ，您必须先安装并启用 epel-release 依赖。

在系统中执行以下命令：

```
yum install epel-release
#或者使用 epel-release 依赖中的 YUM 命令来安装 DNF 包。在系统中执行以下命令
yum install epel-release -y
yum install dnf
```

然后， DNF 包管理器就被成功的安装到你的系统中了。接下来，是时候开始我们的教程了！在这个教程中，您将会学到27个用于 DNF 包管理器的命令。使用这些命令，你可以方便有效的管理您系统中的 RPM 软件包。现在，让我们开始学习 DNF 包管理器的27条常用命令吧！

## 常用命令

```bash
# 查看 DNF 包管理器版本
dnf –version
# 显示系统中可用的 DNF 软件库
dnf repolist
# 用于显示系统中可用和不可用的所有的 DNF 软件库
dnf repolist all
# 列出用户系统上的所有来自软件库的可用软件包和所有已经安装在系统上的软件包
dnf list
# 列出所有安装了的 RPM 包
dnf list installed
# 搜索软件库中的 RPM 包
dnf search nano
# 查找某一文件的提供者
dnf provides /bin/bash
# 查看软件包详情
dnf info nano
# 安装软件包
dnf install nano
# 升级所有系统软件包
dnf update 或 dnf upgrade
# 升级软件包
dnf update xxxx
# 删除系统中指定的软件包
dnf remove nano 或 dnf erase nano
# 删除无用孤立的软件包
#当没有软件再依赖它们时，某一些用于解决特定软件依赖的软件包将会变得没有存在的意义，该命令就是用来自动移除这些没用的孤立软件包。
dnf autoremove
# 删除缓存的无用软件包
dnf clean all
# 查看 DNF 命令的执行历史
dnf history
```

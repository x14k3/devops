

Ubuntu/Debian apt 提供了丰富的命令，完成包的管理任务。

- ​`apt-get`​​ 命令本身并不具有管理软件包功能，只是提供了一个软件包管理的命令行平台。
- ​`apt`​​ 命令不适合在脚本中运行，它会有颜色的显示、进度条显示等一些友好的交互界面，在脚本中不稳定，可能报错：`WARNING: apt does not have a stable CLI interface. Use with caution in scripts.`​​，此时，使用 `apt-get`​​ 替代
- 默认的缓存目录是 `/var/cache/apt/archives/`​​
- 一般的deb包都在 `/usr/share`​​。自己下载的压缩包或者编译的包，一般放在 `/usr/local/`​​ 或 `/opt`​​ 目录下

## 配置阿里源

​`vim /etc/apt/sources.list`​

```
deb https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
deb https://mirrors.aliyun.com/debian-security/ bookworm-security main
deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main
deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
deb https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
```

‍

## **更新或升级**

```
apt-get update          # 更新源
apt-get upgrade         # 更新所有已安装的包
apt-get dist-upgrade    # 发行版升级（如，从10.10到11.04）
```

## **安装或重装类**

```bash
apt-get install pkg                # 安装pkg软件包，多个软件包用空格隔开
apt-get install pkg --reinstall    # 重新安装软件包pkg
apt-get install -f pkg             # 修复安装（破损的依赖关系）软件包pkg
```

## **卸载类**

```
apt-get check                  # 检查是否有损坏的依赖
apt-get remove <package> --purge
apt autoremove -y <package>    # 卸载，同上
apt-get remove pkg             # 删除软件包pkg（不包括配置文件）
apt-get purge pkg              # 删除软件包pkg（包括配置文件）
```

## **下载清除类**

```
apt-get clean                  # 清除缓存(/var/cache/apt/archives/{,partial}下)中所有已下载的包
apt-get autoclean              # 类似于clean，但清除的是缓存中过期的包（即已不能下载或者是无用的包）
apt-get autoremove             # 删除因安装软件自动安装的依赖，而现在不需要的依赖包
```

## **源码编译类**

```
apt-get source pkg             # 下载pkg包的源代码到当前目录
apt-get download pkg           # 下载pkg包的二进制包到当前目录
apt-get source -d pkg          # 下载完源码包后，编译
apt-get build-dep pkg          # 构建pkg源码包的编译环境
```

## **查询类**

​`apt-cache`​ 提供了搜索功能

```
apt-cache stats                 # 显示系统软件包的统计信息
apt-cache search pkg            # 使用关键字pkg搜索软件包
apt-cache show pkg_name         # 显示软件包pkg_name的详细信息，如说明、大小、版本等
apt-cache depends pkg           # 查看pkg所依赖的软件包
apt-cache rdepends pkg          # 查看pkg被那些软件包所依赖
```

其中：

- 普通用户需要可以添加 sudo 申请管理权限
- 在MAN命令中需要退出命令帮助请按 q 键

## 遇到的问题

### aptitude 解决安装包冲突问题

​`aptitude`​ 和 `apt`​、`apt-get`​ 功能一样，都是用来为 Ubuntu 安装软件包，它可以`自动解决安装时出现的各种依赖问题`​，安装命令如下：

```bash
apt install aptitude
```

### Updates for this repository will not be applied.

​`apt update`​ 时，报如上错误，该问题一般由于系统时间不同步导致，使用如下命令同步：

```bash
hwclock --hctosys
```

### apt skip ssl cert verify

```
cat << EOF > /etc/apt/apt.conf.d/80ssl-exceptions
// Do not verify peer certificate
Acquire::https::Verify-Peer "false";
// Do not verify that certificate name matches server name
Acquire::https::Verify-Host "false";
EOF
```

或

```
apt -o "Acquire::https::Verify-Peer=false" update
```

‍

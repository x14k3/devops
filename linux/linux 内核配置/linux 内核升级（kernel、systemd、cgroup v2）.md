
linux内核官网：[https://www.kernel.org/](https://www.kernel.org/)

[https://mirrors.edge.kernel.org/pub/linux/kernel/](https://mirrors.edge.kernel.org/pub/linux/kernel/)

## kernel 升级

### Centos

#### 源码安装

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.228.tar.xz
tar xf linux-5.10.228.tar.xz

#安装核心软件包
yum install -y gcc make git ctags ncurses-devel openssl-devel bison flex elfutils-libelf-devel bc
cd linux-5.10.228
make clean && make mrproper

#创建内核编译目录
mkdir ~/kernelbuild

#内核配置
#复制当前的内核配置文件，config-3.10.0-862.el7.x86_64是我当前环境的内核配置文件，根据实际情况修改
cp /boot/config-3.10.0-862.el7.x86_64 .config

#高级配置
# y 是启用, n 是禁用, m 是需要时启用.
# make menuconfig: 老的 ncurses 界面，被 nconfig 取代
# make nconfig: 新的命令行 ncurses 界面

#编译内核 如果你是四核的机器，x可以是8
make -j x

#安装内核
#编译完内核后安装:Warning: 从这里开始，需要 root 权限执行命令，否则会失败.
make modules_install install

#设置启动
# 查看启动顺序
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
CentOS Linux (4.17.11-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (4.9.9-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-b91f945269084aa98e8257311ee713c5) 7 (Core)

# 设置启动顺序
grub2-set-default 0

# 重启生效
reboot

```

#### rpm安装

[http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/](http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/)

```bash

export kernel_version="5.18.15-1.el7.elrepo.x86_64"

wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-${kernel_version}.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-devel-${kernel_version}.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-headers-${kernel_version}.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-tools-${kernel_version}.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-tools-libs-${kernel_version}.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-tools-libs-devel-${kernel_version}.rpm



# 先移除旧的 kernel-headers，再安装新版本kernel-headers
[root@oracle ~]# rpm -qa|grep kernel
kernel-tools-3.10.0-1160.el7.x86_64
kernel-tools-libs-3.10.0-1160.el7.x86_64
kernel-3.10.0-1160.el7.x86_64
kernel-headers-3.10.0-1160.119.1.el7.x86_64
[root@oracle ~]


yum remove -y kernel-headers-3.10.0-1160.119.1.el7.x86_64 kernel-tools-libs-3.10.0-1160.el7.x86_64

# 安装新版本内核
yum install -y kernel-ml-*

### 重建GRUB配置并重启
### 查看最新内核的顺序，最上边第一条序号就是0，grub2-set-default 就设置为 0
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
[root@oracle opt]# awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
CentOS Linux (5.18.15-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-4c21b50bcb6145aaa3da308601bbe55e) 7 (Core)

##### 设置新安装的内核为默认启动项（假设新内核序号为0）
#### BIOS启动和UEFI启动的GRUB是不一样的 
### 通过判断 /sys/firmware/efi 目录是否存在可以区分，存在是UEFI，否则是BIOS 
## BIOS 
grub2-set-default 0 
# 查看默认内核
grub2-editenv list
# 重新生成 grub 配置
grub2-mkconfig -o /boot/grub2/grub.cfg 
# 重启 
reboot 

## UEFI 
grub2-set-default 0
# 重新生成 grub 配置
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg 
# 重启 
reboot 

### 系统重启后验证内核版本 
[root@node2 ~]# uname -r 
5.18.15-1.el7.elrepo.x86_64 

### 清理旧内核（可选） 
### 删除旧内核 使用`yum`或`rpm`命令删除旧内核包，保留最近1个旧内核以备回退。 
### 查看当前内核 
rpm -qa | grep kernel 
# 删除旧内核包（示例） 
yum remove kernel-3.10.0-*.el7.x86_64 
# 保留最近1个旧内核 
package-cleanup --oldkernels --count=1
```

‍
# linux 升级内核版本

　　‍

　　linux内核官网：[https://www.kernel.org/](https://www.kernel.org/)

　　[https://mirrors.edge.kernel.org/pub/linux/kernel/](https://mirrors.edge.kernel.org/pub/linux/kernel/)

## Centos

### 源码安装

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

### rpm安装

　　[http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/](http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/)

```bash
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-devel-5.18.9-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-headers-5.18.9-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-ml-5.18.9-1.el7.elrepo.x86_64.rpm

#安装内核
rpm -Uvh kernel-ml-5.18.9-1.el7.elrepo.x86_64.rpm 
rpm -Uvh kernel-ml-devel-5.18.9-1.el7.elrepo.x86_64.rpm
rpm -Uvh kernel-ml-headers-5.18.9-1.el7.elrepo.x86_64.rpm 
错误：依赖检测失败：
	kernel-headers < 5.18.9-1.el7.elrepo 与 kernel-ml-headers-5.18.9-1.el7.elrepo.x86_64 冲突

#先移除旧的 kernel-headers，再安装新版本kernel-headers
[root@kvm-test opt]# rpm -qa|grep kernel
kernel-tools-3.10.0-1160.119.1.el7.x86_64
kernel-ml-5.18.9-1.el7.elrepo.x86_64
kernel-3.10.0-1160.71.1.el7.x86_64
kernel-headers-3.10.0-1160.119.1.el7.x86_64
kernel-ml-devel-5.18.9-1.el7.elrepo.x86_64
kernel-tools-libs-3.10.0-1160.119.1.el7.x86_64
kernel-3.10.0-1160.119.1.el7.x86_64
[root@kvm-test opt]#
yum remove -y kernel-headers-3.10.0-1160.118.1.el7.x86_64

#设置开机从新内核启动
# 查看启动顺序
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
# 设置启动顺序
grub2-set-default 0

# 重启生效
reboot

#重启之后，再移除旧版本内核
yum -y remove kernel-3.10.0-1160.71.1.el7.x86_64 
```

　　‍

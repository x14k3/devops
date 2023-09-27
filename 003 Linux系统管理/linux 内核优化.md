# linux 内核优化

‍

## 内核升级

### Centos

```bash
# 查看内核版本
uname -r
# 启用 ELRepo 仓库
# 为 RHEL-8或 CentOS-8配置源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-7 SL-7 或 CentOS-7 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 安装最新的内核
# 稳定版kernel-ml  长期更新维护版本kernel-lt  
yum --enablerepo=elrepo-kernel  install  kernel-ml

# 查看已安装那些内核
[root@k8s-master01 ~]# rpm -qa | grep kernel
kernel-tools-3.10.0-1160.71.1.el7.x86_64
kernel-headers-3.10.0-1160.90.1.el7.x86_64
kernel-ml-6.4.10-1.el7.elrepo.x86_64
kernel-3.10.0-1160.71.1.el7.x86_64
kernel-tools-libs-3.10.0-1160.71.1.el7.x86_64
[root@k8s-master01 ~]# 

# 查看默认内核
[root@k8s-master01 ~]# grubby --default-kernel
/boot/vmlinuz-3.10.0-1160.71.1.el7.x86_64
[root@k8s-master01 ~]# 

# 若不是最新的使用命令设置
grubby --set-default /boot/vmlinuz-「您的内核版本」.x86_64
# grubby --set-default /boot/vmlinuz-6.4.10-1.el7.elrepo.x86_64

# 重启生效
reboot

# 对于确定要删除的内核，使用系统的包管理器即可卸载删除：
# RedHat/CentOS 系的系统使用  
yum remove kernel-3.10.0-1160.71.1.el7.x86_64
```

### ubuntu

升级/降级 Kernel 到指定版本

```bash
#查看当前版本。
uname -r

# 查看当前已经安装的 Kernel Image。
dpkg --get-selections |grep linux-image

#查询当前软件仓库可以安装的 Kernel Image 版本，如果没有预期的版本，则需要额外配置仓库。
apt-cache search linux | grep linux-image

#安装指定版本的 Kernel Image 和 Kernel Header。
sudo apt-get install linux-headers-4.15.0-204-generic linux-image-4.15.0-204-generic

# 查看当前的 Kernel 列表。
grep menuentry /boot/grub/grub.cfg

# 修改 Kernel 的启动顺序：如果安装的是最新的版本，那么默认就是首选的；如果安装的是旧版本，就需要修改 grub 配置。

vim /etc/default/grub
-----------------------------------------------------------------------------
# GRUB_DEFAULT=0
GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 4.15.0-76-generic"
-----------------------------------------------------------------------------

#生效配置。
update-grub
reboot

#删除不需要的 Kernel。
## 查询不包括当前内核版本的其它所有内核版本：
dpkg -l | tail -n +6| grep -E 'linux-image-[0-9]+'| grep -Fv $(uname -r)

#删除指定的 Kernel：
dpkg --purge linux-image-4.15.0-213-generic
```

Kernel 状态：

* rc：表示已经被移除。
* ii：表示符合移除条件（可移除）。
* iU：已进入 apt 安装队列，但还未被安装（不可移除）。

## 开启BBR

```bash
vim /etc/sysctl.conf
----------------------------------------------
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
----------------------------------------------
# 查看是否开启成功
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
sysctl -p
```

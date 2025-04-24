# sysctl.conf

Sysctl是一个功能强大的工具，用于在内核运行时动态地修改内核的参数，在这个命令的帮助下，可以修改内核参数，而无需重新编译内核或重启系统。

### **使用sysctl命令修改内核参数**

内核参数可以临时或永久修改。内核参数的临时修改如下：

```bash
# 读取当前内核的参数：
[root@localhost ~]# sysctl -a
```

使用`-w`​临时修改内核参数。例如，禁止其他设备ping本机：

```bash
[root@localhost ~]# sysctl -w net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_all = 1
```

### **sysctl 使用实例**

#### **forward数据包转发**

仅在充当网关的服务器上启用IP数据包转发。在其他服务器中，可以禁用此功能。

​`# 1表示开启；0表示禁用，可以使用echo 修改，临时效果`​

```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf 
 sysctl -p
```

#### **swap分区停用**

在使用kubernetes环境的时候需要关掉swap分区，为了性能考虑。

​`# 1表示开启；0表示禁用，可以使用echo 修改，临时效果`​

```bash
echo "vm.swappiness = 0" >> /etc/sysctl.conf 
sysctl -p
```

#### **SYN防洪**

防止SYN Flood攻击，需要开启此项。

​`# 1表示开启；0表示禁用，可以使用echo 修改，临时效果`​

```bash
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf 
sysctl -p
```

#### **端口范围设定**

```bash
echo "net.ipv4.ip_local_port_range = 1024    65000" >> /etc/sysctl.conf 
sysctl -p
```

#### **icmp允许/禁止ping**

​`# 1表示不可以ping；0表示可以ping，可以使用echo 修改，临时效果`​

```bash
echo "net.ipv4.icmp_echo_ignore_all=0" >> /etc/sysctl.conf
sysctl -p
```

#### BBR加速打开

```bash
echo "net.core.default_qdisc=fq"  >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr"  >> /etc/sysctl.conf
sysctl -p
# 查看是否开启成功
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
```

‍

### sysctl.conf  优化模板

```bash
fs.file-max = 2097152
 
 
# 减少交换内存使用，默认60，建议10-30
vm.swappiness = 30
 
 
# 脏数据的比例和处理，根据场景不同设置，
# 参考 https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/
# 如果是数据库服务器，希望数据能够尽快安全写入，可降低内存缓存比例
# vm.dirty_background_ratio = 5
# vm.dirty_ratio = 10
 
 
# 如果是业务服务器，对数据安全写入无要求，可加大内存缓存比例
# vm.dirty_background_ratio = 50
# vm.dirty_ratio = 80
 
 
# 设置为1，内核允许分配所有的物理内存,Redis常用
vm.overcommit_memory = 1
 
 
# 系统拥有的内存数，ElasticSearch启动必备
vm.max_map_count = 262144
 
 
# 设置为1
net.ipv4.tcp_no_metrics_save = 1
 
 
# 禁用 sysrq 功能
kernel.sysrq = 0
 
 
# 控制 core 文件的文件名中是否添加 pid 作为扩展
kernel.core_uses_pid = 1
 
 
# 设置为1，防止 SYNC FLOOD 攻击
net.ipv4.tcp_syncookies = 1
 
 
# 消息队列的最大消息大小，默认8k，建议64kb
kernel.msgmax = 65536
# 消息队列存放消息的总字节数
kernel.msgmnb = 163840
 
 
# TIME_WAIT socket的最大数目，不宜太大或者太小，nginx反向代理必备
net.ipv4.tcp_max_tw_buckets = 50000
# 打开 SACK 选项，设置为1
net.ipv4.tcp_sack = 1
# 激活窗口扩充因子，支持64kb以上数据传输
net.ipv4.tcp_window_scaling = 1
 
 
# TCP 缓冲区内存，连接数达到非常高时候需要配置好
net.ipv4.tcp_mem = 786432 2097152 3145728  
net.ipv4.tcp_rmem = 4096 4096 16777216
net.ipv4.tcp_wmem = 4096 4096 16777216
 
 
# socket缓冲区默认值和最大值
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
 
 
# ACCEPT等待队列长度，适当，太大了堆积也无用 
net.core.netdev_max_backlog = 65535
 
 
# 允许最大并发连接数，重要
net.core.somaxconn = 65535
 
 
# 不属于任何进程的socket数目，不宜太大，防止攻击
net.ipv4.tcp_max_orphans = 65535
 
 
# SYNC等待队列长度，适当，太大了排队也没用
net.ipv4.tcp_max_syn_backlog = 65535
 
 
# 禁用timestamp，重要，高并发下设置为0
net.ipv4.tcp_timestamps = 0
 
 
# 发送 SYNC+ACK 的重试次数，不宜太大，5以内
net.ipv4.tcp_synack_retries = 1
# 发送SYNC的重试次数，不宜太大，5以内
net.ipv4.tcp_syn_retries = 1
 
 
# 允许回收TCP连接，重要，必须为1
net.ipv4.tcp_tw_recycle = 1
 
 
# 允许重用TCP连接，重要，必须为1
net.ipv4.tcp_tw_reuse = 1
 
 
# 服务端主动关闭后，客户端释放连接的超时，重要，<30
net.ipv4.tcp_fin_timeout = 5
 
 
# 允许TCP保持的空闲keepalive时长，不需要太长
net.ipv4.tcp_keepalive_time = 30
 
 
# 系统作为TCP客户端连接自动使用的端口(start，end），可发起并发连接数为end-start
net.ipv4.ip_local_port_range = 10240 65535
```

‍

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

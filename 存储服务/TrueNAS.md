


## 在 kvm 中安装TrueNAS

```bash
## 下载
wget https://download.sys.truenas.net/TrueNAS-SCALE-Goldeye/25.10.0.1/TrueNAS-SCALE-25.10.0.1.iso


# 创建存储目录
mkdir -p /var/lib/libvirt/images/truenas

# 创建系统磁盘
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/system.qcow2 20G

# 创建数据磁盘（可选，用于模拟存储池）
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/data1.qcow2 50G
qemu-img create -f qcow2 /var/lib/libvirt/images/truenas/data2.qcow2 50G

# 使用 virt-install 创建虚拟机
sudo virt-install \
--name=truenas \
--description="TrueNAS SCALE VM" \
--os-type=generic \
--ram=8192 \
--vcpus=4 \
--cpu host-passthrough \
--disk path=/var/lib/libvirt/images/truenas/system.qcow2,size=20,format=qcow2 \
--disk path=/var/lib/libvirt/images/truenas/data1.qcow2,size=50,format=qcow2 \
--disk path=/var/lib/libvirt/images/truenas/data2.qcow2,size=50,format=qcow2 \
--cdrom=/path/to/TrueNAS-SCALE-22.12.0.iso \
--network bridge= br0 \
--graphics vnc,listen=0.0.0.0 \
--boot uefi \
--noautoconsole


```


### 虚拟机配置优化

```bash
# 编辑虚拟机配置：
virsh edit truenas

# 添加以下配置：
<!-- CPU 模式 -->
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='4' threads='1'/>
</cpu>

<!-- 内存气球驱动（可选） -->
<memtune>
  <hard_limit unit='KiB'>16777216</hard_limit>
</memtune>

<!-- 时钟同步 -->
<clock offset='utc'>
  <timer name='rtc' tickpolicy='catchup'/>
  <timer name='pit' tickpolicy='delay'/>
  <timer name='hpet' present='no'/>
</clock>

```

### 安装 TrueNAS SCALE

1. **启动虚拟机控制台**
```bash
	sudo virsh start truenas
	virt-viewer truenas
	# 或使用 VNC 连接：宿主机IP:5900
```
2. **安装过程**
    - 选择 "Install/Upgrade"
    - 选择系统磁盘（通常为第一个磁盘）
    - 设置 root 密码
    - 选择引导方式：UEFI
    - 确认安装
    - 安装完成后重启，**记得移除 ISO 启动介质**

3. **移除 CD-ROM 启动**
```bash
	virsh edit truenas
	# 删除或注释掉 <disk type='file' device='cdrom'> 部分
```



## 初始配置

1. **访问 TrueNAS Web 界面**
    - 虚拟机启动后查看控制台显示的 IP 地址
    - 浏览器访问：`http://[TrueNAS-IP]`
    - 用户名：root，密码：安装时设置的密码

2. **基本配置**
    - 网络配置（如果需要静态 IP）
    - 时区设置
    - 创建存储池

3. **创建存储池**
    - 进入 "Storage" → "Pools"
    - 点击 "Add Pool"
    - 选择数据磁盘（如 vdb, vdc）
    - 选择 RAID 类型（如 Mirror、RAIDZ1 等）
    - 创建数据集（Datasets）

## 创建Centos7 虚拟机

使用nographics 方式

> 使用 `–nographic` 以非图形界面的方式启动，所以需要重定向 guest的 console，所以需要`--extra-args='console=tty0 console=ttyS0,115200n8 serial'`​参数

```bash
virt-install --name=CentOS7_templ --ram 8192 --vcpus 2 \
--disk path=/data/CentOS7_templ.qcow2,size=55,format=qcow2,bus=virtio \
--location /data/CentOS-7-x86_64-DVD-1908.iso \
--virt-type=kvm --hvm --network network=default,model=virtio \
--extra-args='console=tty0 console=ttyS0,115200n8 serial' \
--nographics

virt-install --name=Rocky-9 --ram 8192 --vcpus 2 \
--disk path=//data/qemu/images/Rocky9.qcow2,size=55,format=qcow2,bus=virtio \
--location /data/qemu/iso/Rocky-9-latest-x86_64-minimal.iso \
--virt-type=kvm --hvm --network bridge=br0,model=virtio \
--extra-args='console=tty0 console=ttyS0,115200n8 serial' \
--graphics vnc,listen=0.0.0.0
```

‍

## 创建windows 10 虚拟机

要在KVM上使用命令行创建Windows 10虚拟机，请按照以下步骤操作：

1. **下载资源**
[Windows 10 ISO镜像](https://www.microsoft.com/software-download/windows10)
[VirtIO驱动ISO](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)（用于优化磁盘/网络性能）

2. **创建虚拟磁盘**
```
sudo qemu-img create -f qcow2 /data/qemu/images/win10_dev.qcow2 100G
```

3. **执行安装命令**
```bash
virt-install --name win10 --ram 8192 --vcpus 2 --os-variant win10 \
--cdrom /data/qemu/iso/Win10_22H2_Chinese_Simplified_x64v1.iso \
--disk path=/data/qemu/images/win10_sys.qcow2,bus=virtio,format=qcow2 \
--disk path=/data/qemu/images/win10_data.qcow2,bus=virtio,format=qcow2 \
--disk path=/data/qemu/iso/virtio-win-0.1.271.iso,device=cdrom \
--network bridge=br0,model=virtio --graphics vnc,listen=0.0.0.0 
```

4. **安装Windows注意事项**
	1. **加载VirtIO驱动**：
	    - 在安装界面选择磁盘时，点击  **"加载驱动程序"**  ， **"浏览"**
	    - 选择VirtIO光盘中的 `\viostor\w10\amd64`​ 加载磁盘驱动
	    - 安装完成后，从VirtIO光盘安装其他驱动（如网络、Balloon服务）
	2. **启用远程访问**：
    ```bash
    virt-viewer --connect qemu:///system win10  # 图形界面访问
	# 或使用SPICE客户端连接（端口自动分配，用`virsh vncdisplay win10`​查看）
    ```

5. **安装后优化**
  ```bash
  # 修改启动盘
  virsh edit win10
# --------------------------
  <os>
    <type arch='x86_64' machine='pc-q35-7.2'>hvm</type>
    <boot dev='cdrom'/>    --修改为dev=hd
  </os>


# 取消镜像工具
<!--    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/data/qemu/iso/Win10_22H2_Chinese_Simplified_x64v1.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/data/qemu/iso/virtio-win-0.1.271.iso'/>
      <target dev='sdb' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='1'/>
    </disk>-->
  ```



## virt-install 虚拟机创建命令

`virt-install` 是 KVM/Libvirt 环境中创建和管理虚拟机的命令行工具。以下是其参数的详细分类和解释：

### 基本参数

#### 1. **虚拟机标识**
```bash
--name=NAME               # 虚拟机名称（必填）
--uuid=UUID               # 指定虚拟机UUID（可选）
--description="TEXT"      # 虚拟机描述信息
--title="TITLE"           # 虚拟机标题
```

#### 2. **资源分配**
```bash
# 内存设置
--memory=MEMORY          # 内存大小（单位MB/KB/GB）
--memory=MEMORY,maximum=MEMORY  # 最大内存（支持气球驱动）
--memory=MEMORY,maxmemory=MEMORY,currentmemory=MEMORY  # 详细内存配置

# CPU设置
--vcpus=VCPUS            # 虚拟CPU数量
--vcpus=VCPUS,maxvcpus=MAX  # 最大可扩展CPU数
--vcpus=VCPUS,sockets=S,cores=C,threads=T  # CPU拓扑
--cpu=MODEL              # CPU模式：host-model, host-passthrough, custom
--cpu host-model         # 匹配宿主机CPU特性
--cpu host-passthrough   # 直接透传宿主机CPU
--cpu core2duo           # 指定特定CPU型号
--numatune=auto          # NUMA调优

```

#### 3. **磁盘配置**

```bash
# 基本磁盘语法
--disk path=/path/to/image,size=SIZE,format=FORMAT,sparse=BOOL

# 常用参数
path=                     # 磁盘镜像路径（必填）
size=                     # 磁盘大小（单位GB，创建时有效）
format=                   # 镜像格式：raw, qcow2, qed, vmdk
bus=                      # 总线类型：virtio, ide, scsi, usb
device=                   # 设备类型：disk, cdrom, floppy
cache=                    # 缓存模式：none, writeback, writethrough
io=                       # IO模式：native, threads
sparse=                   # 是否稀疏文件：yes/no
disks=[pool1,pool2]      # 使用多个磁盘池

# 示例
--disk path=/var/lib/libvirt/images/vm1.qcow2,size=20,format=qcow2,bus=virtio
--disk path=/var/lib/libvirt/images/data.qcow2,size=100,format=raw
--disk path=/dev/sdb,device=disk,bus=virtio  # 使用物理磁盘
--disk none               # 不创建磁盘
```

#### 4. **CDROM/ISO 安装**

```bash
--cdrom=/path/to/iso      # 使用ISO文件（自动检测为cdrom）
--disk path=/path/to/iso,device=cdrom  # 手动指定为CDROM
--location=LOCATION       # 安装源（URL或本地路径）
```

### 网络配置

#### 1. **网络类型**
```bash
# 基本语法
--network NETWORK_TYPE,model=MODEL,mac=MAC

# 网络类型
network=default          # 使用默认NAT网络
network=NETNAME          # 指定已有虚拟网络
bridge=BRIDGE            # 使用桥接网络
network=source=SRC       # 网络源类型
direct=DEVICE            # 直接连接物理网卡
network=none             # 无网络

# 网卡模型
model=virtio            # 推荐（高性能）
model=e1000             # Intel千兆
model=rtl8139           # Realtek
model=ne2k_pci          # 老式网卡

# 示例
--network network=default,model=virtio
--network bridge=br0,model=virtio
--network network=mynet,mac=52:54:00:ab:cd:ef

```


#### 2. **高级网络设置**

```bash
--network help           # 查看可用网络类型
--network network=...,portgroup=...  # 端口组
--network network=...,filter=...    # 防火墙过滤
--network network=...,trustGuestRxFilters=...  # 信任客户端
```



### 显示和图形

#### 1. **图形显示**
```bash
# 基本语法
--graphics TYPE,listen=ADDR,port=PORT,password=PASS

# 图形类型
graphics=vnc            # VNC
graphics=spice          # SPICE（推荐）
graphics=sdl            # SDL
graphics=none           # 无图形（纯控制台）
graphics=vnc,port=5900  # 指定端口

# 详细参数
listen=0.0.0.0          # 监听地址
port=auto               # 自动分配端口
password=PASSWORD       # 连接密码
keymap=en-us            # 键盘布局

# 示例
--graphics vnc,listen=0.0.0.0,port=5900,password=123456
--graphics spice,port=5900,tlsport=5901
```

#### 2. **视频设备**
```bash
--video=MODEL           # 视频设备
--video qxl             # QXL（支持SPICE）
--video virtio          # VirtIO（现代虚拟机）
--video vga             # VGA（兼容模式）
--video cirrus          # Cirrus（老式）
```

#### 3. **控制台**
```bash
--console pty,target_type=virtio  # 串行控制台
--console pty,target_type=serial  # 串口
--noautoconsole          # 不自动连接控制台
```

### 虚拟化平台

#### 1. **虚拟机类型**
```bash
--virt-type=TYPE        # 虚拟化类型
--virt-type=kvm         # KVM（默认）
--virt-type=qemu        # QEMU
--virt-type=xen         # Xen
```

#### 2. **机器类型**
```bash
--machine=TYPE          # 机器类型
--machine q35           # 现代PC（支持PCIe）
--machine pc            # 标准PC（兼容模式）
--machine virt          # ARM虚拟机

```

#### 3. **固件和引导**
```bash
# UEFI引导
--boot uefi             # 使用UEFI
--boot loader=/usr/share/OVMF/OVMF_CODE.fd  # 指定固件
--boot loader_type=pflash  # PFlash类型

# 传统BIOS
--boot bios             # 传统BIOS

# 引导顺序
--boot hd,cdrom,network # 指定引导顺序
--boot menu=on          # 显示引导菜单
--boot loader=/path/to/kernel,initrd=/path/to/initrd  # 直接引导

```


### 安装选项

#### 1. **操作系统检测**
```bash
--os-variant=OS_TYPE    # 操作系统变体
--os-variant detect=on  # 自动检测
--os-variant list       # 查看支持的OS列表

```


#### 2. **安装方式**
```bash
# 从ISO安装
--cdrom=/path/to/iso

# 网络安装
--location=http://example.com/os/
--location=ftp://example.com/os/
--location=nfs:example.com:/path/to/os

# 导入现有磁盘
--import

# PXE网络引导
--pxe

```


#### 3. **安装参数**
```bash
--extra-args="KERNEL_ARGS"  # 传递给安装内核的参数
--extra-args='console=tty0 console=ttyS0,115200n8 serial'
--initrd-inject="/path/to/ks.cfg"  # 注入kickstart文件
--serial=pty,target_type=usb-serial  # 串行控制台重定向
```


### 设备配置

#### 1. **USB设备**
```bash
--hostdev bus.addr                # 透传USB设备
--hostdevice /dev/bus/usb/...     # USB设备路径
--controller type=usb,model=...   # USB控制器

```

#### 2. **PCI设备透传**
```bash
# 查看PCI设备
lspci -nn

# 透传语法
--hostdev pci_0000_01_00_0  # 设备地址
--hostdev 0000:01:00.0      # 简化格式

# 详细配置
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
  </source>
</hostdev>
```


#### 3. **输入设备**
```bash
--input type=TYPE       # 输入设备类型
--input tablet          # 图形板（推荐）
--input mouse           # 鼠标
--input keyboard        # 键盘
```


#### 4. **声音设备**
```bash
--sound MODEL           # 声音设备
--sound ac97            # AC97
--sound ich6            # Intel HD Audio
--sound none            # 无声音
```


### 高级功能

#### 1. **安全设置**
```bash
--security type=TYPE    # 安全模型
--security type=sev     # AMD SEV加密
--security type=s390-pv # s390x保护
```

#### 2. **时钟设置**
```bash
--clock offset=OFFSET   # 时钟偏移
--clock offset=utc      # UTC时间
--clock offset=localtime # 本地时间
--clock offset=variable  # 可调时间

```

#### 3. **性能优化**
```bash
# CPU特性
--features kvm_hidden=on  # 隐藏KVM
--features acpi=on       # ACPI支持
--features apic=on       # APIC支持
--features pae=on        # PAE支持

# 内存大页
--memorybacking hugepages=yes  # 使用大页
--memorybacking access=shared  # 共享内存
```


#### 4. **虚拟机生命周期**
```bash
--autostart             # 宿主机启动时自动启动
--transient             # 创建临时虚拟机（不保存配置）
--check path_in_use=off # 不检查路径占用
--force                 # 强制覆盖现有配置

```

### 完整示例

#### 示例1：基础安装
```bash
virt-install \
--name=ubuntu-server \
--ram=2048 \
--vcpus=2 \
--cpu host \
--disk path=/var/lib/libvirt/images/ubuntu.qcow2,size=20,format=qcow2 \
--cdrom=/path/to/ubuntu-22.04.iso \
--network network=default,model=virtio \
--graphics vnc,listen=0.0.0.0,port=5900 \
--os-variant=ubuntu22.04 \
--noautoconsole
```


#### 示例2：高级配置

```bash


virt-install \
--name=windows-11 \
--description="Windows 11 VM" \
--ram=8192 \
--vcpus=4,sockets=1,cores=4,threads=1 \
--cpu host-passthrough \
--disk path=/var/lib/libvirt/images/win11.qcow2,size=100,format=qcow2,bus=virtio \
--disk path=/var/lib/libvirt/images/data.qcow2,size=500,format=qcow2 \
--cdrom=/path/to/windows11.iso \
--network bridge=br0,model=virtio \
--graphics spice,port=5900,tlsport=5901 \
--video qxl \
--input tablet \
--sound ich6 \
--boot uefi \
--features kvm_hidden=on \
--clock offset=localtime \
--os-variant=win10 \
--autostart
```

#### 示例3：无图形安装
```bash
virt-install \
--name=centos-minimal \
--ram=1024 \
--vcpus=1 \
--disk path=/var/lib/libvirt/images/centos.qcow2,size=10,format=qcow2 \
--location=http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/ \
--extra-args="console=ttyS0 ks=http://example.com/ks.cfg" \
--network network=default \
--graphics none \
--console pty,target_type=serial \
--os-variant=centos8

```


### 实用技巧

#### 1. **验证命令**
```bash
# 查看可用选项
virt-install --help

# 查看支持的OS变体
osinfo-query os

# 查看磁盘格式支持
qemu-img --help | grep "Supported formats"

```

#### 2. **调试参数**
```bash
# 显示XML配置而不创建
virt-install --print-xml ...

# 调试模式
virt-install --debug ...

# 只验证不执行
virt-install --dry-run ...
```

#### 3. **后续管理**
```bash
# 编辑虚拟机配置
virsh edit vm-name

# 添加额外磁盘
virsh attach-disk vm-name /path/to/new.qcow2 vdb --persistent

# 修改资源
virsh setmem vm-name 4096 --live --config
virsh setvcpus vm-name 4 --live --config
```

### 注意事项

1. **权限问题**：大多数操作需要 `sudo` 或 root 权限
2. **路径问题**：确保存储路径存在且有足够权限
3. **资源分配**：不要超过宿主机物理资源
4. **网络配置**：桥接网络需要提前配置好桥接接口
5. **性能调优**：根据应用类型调整缓存模式、IO策略等

这个参数详解覆盖了 `virt-install` 的大部分常用选项。实际使用时，可以根据具体需求组合使用这些参数。

## virsh 虚拟机管理命令

|命令|功能|
| ------| ------------------------|
|​`virsh list --all`​|查看所有虚拟机|
|​`virsh start/reboot/shutdown win10`​|启/重启/关机|
|​`virsh destroy win10`​|强制停止|
|​`virsh undefine win10`​|删除虚拟机（保留磁盘）|

> **注意**：若安装时未使用 VirtIO，Windows可能无法识别磁盘。此时需在XML中将磁盘总线改为`ide`​（性能降低），安装驱动后再切换回`virtio`​。

‍

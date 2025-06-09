# KVM 创建虚拟机

## 创建Centos7 虚拟机

使用nographics 方式

```bash
virt-install --name=CentOS7_templ --ram 8192 --vcpus 2 \
--disk path=/data/CentOS7_templ.qcow2,size=55,format=qcow2 \
--location /data/CentOS-7-x86_64-DVD-1908.iso \
--nographics --extra-args='console=tty0 console=ttyS0,115200n8 serial' \
--virt-type=kvm --hvm --network network=default
```

‍

## 创建windows 10 虚拟机

要在KVM上使用命令行创建Windows 10虚拟机，请按照以下步骤操作：

### 1. **下载资源**

[Windows 10 ISO镜像](https://www.microsoft.com/software-download/windows10)

[VirtIO驱动ISO](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)（用于优化磁盘/网络性能）

---

### 2. **创建虚拟磁盘**

```
sudo qemu-img create -f qcow2 /data/qemu/images/win10_dev.qcow2 100G
```

- ​`100G`​：磁盘大小（根据需求调整）

---

### 3. **执行安装命令**

```bash
sudo virt-install \
  --name win10 \
  --ram 8192 \
  --vcpus 2 \
  --disk path=/data/qemu/images/win10_dev.qcow2,bus=virtio,format=qcow2 \
  --os-variant win10 \
  --network network=default,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --cdrom /data/qemu/iso/Win10_22H2_Chinese_Simplified_x64v1.iso \
  --disk path=/data/qemu/iso/virtio-win-0.1.271.iso,device=cdrom \
  --boot cdrom
```

### 参数说明：

|参数|说明|
| ------| ----------------------------------|
|​`--name win10`​|虚拟机名称|
|​`--ram 4096`​|内存大小（MB）|
|​`--vcpus 2`​|CPU核心数|
|​`--disk path=...`​|虚拟磁盘路径（`bus=virtio`​需安装驱动）|
|​`--os-variant win10`​|系统优化配置（用`osinfo-query os`​查看支持列表）|
|​`--network network=default`​|使用默认NAT网络|
|​`--graphics spice`​|启用SPICE远程桌面（支持`virt-viewer`​连接）|
|​`--cdrom`​|Windows安装ISO路径|
|​`--disk path=...`​|VirtIO驱动ISO路径|
|​`--boot cdrom`​|优先从光盘启动|

---

### 4. **安装Windows注意事项**

1. **加载VirtIO驱动**：

    - 在安装界面选择磁盘时，点击  **"加载驱动程序"**   **&gt;**   **"浏览"**
    - 选择VirtIO光盘中的 `\viostor\w10\amd64`​ 加载磁盘驱动
    - 安装完成后，从VirtIO光盘安装其他驱动（如网络、Balloon服务）
2. **启用远程访问**：

    ```
    sudo virt-viewer --connect qemu:///system win10  # 图形界面访问
    ```

    或使用SPICE客户端连接（端口自动分配，用`virsh vncdisplay win10`​查看）

---

### 5. **安装后优化**

- **删除安装介质**：

  ```
  virsh edit win10
  ```

  删除 `<disk type='file' device='cdrom'>`​ 相关段落，或使用：

  ```
  virsh change-media win10 hda --eject --config  # 弹出光盘
  ```
- **调整配置**：

  ```
  virsh edit win10  # 手动修改XML（如CPU/内存）
  virsh shutdown win10 && virsh start win10  # 重启生效
  ```

---

### 关键命令管理

|命令|功能|
| ------| ------------------------|
|​`virsh list --all`​|查看所有虚拟机|
|​`virsh start/reboot/shutdown win10`​|启/重启/关机|
|​`virsh destroy win10`​|强制停止|
|​`virsh undefine win10`​|删除虚拟机（保留磁盘）|

> **注意**：若安装时未使用VirtIO，Windows可能无法识别磁盘。此时需在XML中将磁盘总线改为`ide`​（性能降低），安装驱动后再切换回`virtio`​。

‍

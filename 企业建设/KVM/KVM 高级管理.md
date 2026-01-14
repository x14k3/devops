
## 直通 cpu

```bash
virt-install --name win7 \
--ram 4096 \
--vcpus 2 \
--cpu host-passthrough \
--cdrom /data/qemu/iso/cn_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677816.iso \
--disk path=/data/qemu/images/win7.qcow2,bus=virtio,format=qcow2 \
--disk path=/data/qemu/iso/virtio-win-0.1.173.iso,device=cdrom \
--network bridge=br0,model=virtio \
--graphics vnc,listen=0.0.0.0
--os-variant win7 
```

## 直通集显

### 使用 VFIO 直通（独占使用）【简单】

#### 1. 配置内核参数

编辑 `/etc/default/grub`：
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt"
```

更新并重启。
```bash
update-grub
reboot
```

#### 2. 屏蔽集成显卡驱动
```bash
# 查看 GPU ID
sudo lspci -nn|grep 00:02

0000:00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-S GT1 [UHD Graphics 770] [8086:4690] (rev 0c)

# 添加到 VFIO 配置
echo "options vfio-pci ids=8086:4690" | sudo tee /etc/modprobe.d/vfio.conf
echo "vfio-pci" | sudo tee /etc/modules-load.d/vfio-pci.conf
```

#### 3. 创建虚拟机

```bash
virt-install --name win7 \
--ram 4096 --vcpus 2  --cpu host-passthrough \
--video none --sound none --hostdev 0000:00:02.0  --features kvm_hidden=on  \
--cdrom /data/qemu/iso/cn_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677816.iso \
--disk path=/data/qemu/images/win7.qcow2,bus=virtio,format=qcow2 \
--disk path=/data/qemu/iso/virtio-win-0.1.173.iso,device=cdrom \
--network bridge=br0,model=virtio \
--graphics vnc,listen=0.0.0.0 \
--os-variant win7 --machine q35
```
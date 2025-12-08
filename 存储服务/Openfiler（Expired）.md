## openfiler 介绍

Openfiler能把标准 x86/64架构的系统变为一个更强大的 NAS、SAN存储和IP存储网关，为管理员提供一个强大的管理平台，并能应付未来的存储需求。openfiler可以安装在 x86/64架构的工业标准服务器上，否定了昂贵的专有存储系统的需求。只需10分钟即可把系统部署到戴尔、惠普、IBM等标准配置服务器上，服务器就变为一个功能强大的存储网络了。

此外，与其它存储方案不同的是，openfiler的管理是通过一个强大的、直观的基于web的图形用户界面。通过这个界面，管理员可以执行诸如创建卷、网络共享磁盘分配和管理RAID等工作。

‍
### 丰富的协议支持

openfiler 支持多种文件界别和块级别的数据存储输出协议，几乎涵盖现有全部的网络存储服务.

块级别的协议：
- iSCSI
- 光纤通道(FC)

文件级别的协议：
- NFS
- CIFS
- HTTP/DAV
- FTP
- rsync


## 使用 KVM 安装 Openfiler

```bash
# 下载openfiler镜像
wget https://twds.dl.sourceforge.net/project/openfiler/openfiler-distribution-iso-2.99-x64/openfileresa-2.99.1-x86_64-disc1.iso

mv openfileresa-2.99.1-x86_64-disc1.iso /data/qemu/iso

virt-install \
  --name openfiler \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/data/qemu/images/openfiler.qcow2,size=20,bus=virtio \
  --cdrom /data/qemu/iso/openfileresa-2.99.1-x86_64-disc1.iso  \
  #--network network=default,model=virtio \
  --network bridge=br0,model=virtio \
  --graphics vnc,listen=0.0.0.0,port=5901 \
  --noautoconsole \
  --os-type linux \
  --os-variant generic


### 详细配置版本（推荐）
virt-install \
  --name=openfiler \
  --description="Openfiler Storage Appliance" \
  --ram=4096 \
  --vcpus=2 \
  --cpu host-passthrough \
  --disk path=/data/qemu/images/openfiler.qcow2,size=20,format=qcow2,bus=virtio,cache=writeback \
  --cdrom=/data/qemu/iso/openfileresa-2.99.1-x86_64-disc1.iso \
  --network bridge=br0,model=virtio \
  --network bridge=br0,model=virtio \
  --graphics vnc,listen=0.0.0.0,port=5901,password=openfiler \
  --noautoconsole \
  --os-type=linux \
  --os-variant=rhel7 \
  --boot cdrom,hd
```

## 附加存储磁盘配置

```bash
# 创建多个存储磁盘用于 RAID/LVM
for i in {1..4}; do
  qemu-img create -f qcow2 /var/lib/libvirt/images/openfiler/disk${i}.img 50G
done

# 安装时附加额外磁盘
virt-install \
  --name openfiler \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/data/qemu/images/system.qcow2,size=20,bus=virtio \
  --disk path=/data/qemu/images/disk1.img,bus=virtio \
  --disk path=/data/qemu/images/disk2.img,bus=virtio \
  --disk path=/data/qemu/images/disk3.img,bus=virtio \
  --disk path=/data/qemu/images/disk4.img,bus=virtio \
  --cdrom /data/qemu/iso/openfileresa-2.99.1-x86_64-disc1.iso \
  --network bridge=br0,model=virtio \
  --network network=default,model=virtio \
  --graphics vnc,listen=0.0.0.0,port=5901 \
  --noautoconsole

```


## 安装后配置

### 连接到 VNC 控制台
[[存储服务/assets/05f7ef3d591e6268ceb044af071a6569_MD5.jpg|Open: Pasted image 20251207220521.png|600]]
![[存储服务/assets/05f7ef3d591e6268ceb044af071a6569_MD5.jpg|600]]

### 安装完成后转换为从硬盘启动

```bash
# 编辑虚拟机配置
virsh edit openfiler

# 将 <boot dev='cdrom'/> 改为 <boot dev='hd'/>
# 或使用命令行
virsh dumpxml openfiler > openfiler.xml
# 编辑 XML 文件
virsh define openfiler.xml
```


## 注意事项

1. **磁盘格式**：对于存储服务器，建议使用 `raw` 格式而不是 `qcow2` 以获得更好性能
2. **网络配置**：Openfiler 通常需要至少两个网络接口（管理+数据）
3. **内存大小**：建议至少 2GB RAM，4GB 或更多以获得更好性能
4. **安装过程**：通过 VNC 完成安装，按照 Openfiler 安装向导操作
5. **Web 访问**：安装完成后通过 `https://<ip>:446` 访问管理界面
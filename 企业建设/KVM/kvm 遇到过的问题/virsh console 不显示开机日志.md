
virsh start Rocky9 后，使用命令virsh console不显示开机日志，但是可以登陆

## **1. 在 Rocky Linux 9 中启用串行控制台输出**

```bash
# 登录到 Rocky Linux 9 虚拟机
virsh console Rocky9

# 编辑 GRUB 配置
sudo vi /etc/default/grub

# 修改 GRUB_CMDLINE_LINUX 行，添加 console=ttyS0,115200n8
# 原行可能类似：
# GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap"
# 修改为：
GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap console=ttyS0,115200n8"

### 重新生成 GRUB 配置
# 对于 BIOS 系统：
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# 对于 UEFI 系统：
sudo grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg


```



## 2. **配置 systemd 以输出日志到串行控制台**

```bash
# 编辑 systemd 的 journald 配置
sudo vi /etc/systemd/journald.conf

# 取消注释并修改以下行：
ForwardToConsole=yes
TTYPath=/dev/ttyS0
MaxLevelConsole=info

# 重启 journald 服务
sudo systemctl restart systemd-journald
```

## 3. **启用 getty 服务（如果未启用）**

```bash
# 检查是否启用了串行 getty 服务
sudo systemctl status serial-getty@ttyS0

# 如果未启用，启用它：
sudo systemctl enable serial-getty@ttyS0
sudo systemctl start serial-getty@ttyS0
```

## 4. **确保内核启用了串行控制台支持**

```bash
# 检查当前内核是否支持串行控制台
sudo dmesg | grep ttyS

# 如果看不到 ttyS0，可能需要在内核中启用
```

## 5. **在 libvirt XML 配置中添加串行控制台**

虽然`virsh console`通常会自动配置，但可以手动检查：

```bash
# 查看虚拟机的 XML 配置
virsh dumpxml Rocky9 | grep -A 5 -B 5 console

# 确保有以下配置：
<serial type='pty'>
  <target type='isa-serial' port='0'>
    <model name='isa-serial'/>
  </target>
</serial>
<console type='pty'>
  <target type='serial' port='0'/>
</console>
```


## 6. **使用替代方法查看启动日志**

如果上述方法都无效，可以尝试：

```bash
# 方法1：使用 virsh 的 --console 参数
virsh start --console Rocky9

# 方法2：使用 virt-viewer（需要图形界面）
sudo dnf install virt-viewer
virt-viewer -c qemu:///system Rocky9

# 方法3：查看 libvirt 日志
virsh start Rocky9
sudo tail -f /var/log/libvirt/qemu/Rocky9.log
```


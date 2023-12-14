# opensuse

## 桌面linux无声卡

```bash
sudo lspci -v
sudo aplay -l

# 修改 /etc/default/grub 
# GRUB_CMDLINE_LINUX_DEFAULT="xx" 后面添加 snd_hda_intel.dmic_detect=0
-------------------
ds@notebook:~ $ cat  /etc/default/grub
# If you change this file, run 'grub2-mkconfig -o /boot/grub2/grub.cfg' afterwards to update
# /boot/grub2/grub.cfg.

# Uncomment to set your own custom distributor. If you leave it unset or empty, the default
# policy is to determine the value from /etc/os-release
GRUB_DISTRIBUTOR=
GRUB_DEFAULT=saved
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=5
GRUB_CMDLINE_LINUX_DEFAULT="splash=silent preempt=full mitigations=auto quiet security=apparmor snd_hda_intel.dmic_detect=0"
GRUB_CMDLINE_LINUX=""

# Uncomment to automatically save last booted menu entry in GRUB2 environment

------------------------
update-bootloader
reboot

```

## FireFox( 火狐 )无法使用HTML5播放器的解决方法

```bash
#增加Packman
#packman是opensuse第三方源，就是为了提供这些商业软件的。
sudo zypper ar http://mirrors.aliyun.com//packman/suse/openSUSE_Leap_15.5 Packman
sudo zypper dist-upgrade --from Packman --allow-vendor-change
reboot

```

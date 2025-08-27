

GRUB_CMDLINE_LINUX_DEFAULT="xxx" 后面添加 `snd_hda_intel.dmic_detect=0`​

```bash
doshell:/data/backup # cat /etc/default/grub
# If you change this file, run 'grub2-mkconfig -o /boot/grub2/grub.cfg' afterwards to update
# /boot/grub2/grub.cfg.

# Uncomment to set your own custom distributor. If you leave it unset or empty, the default
# policy is to determine the value from /etc/os-release
GRUB_DISTRIBUTOR=
GRUB_DEFAULT=saved
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=8
GRUB_CMDLINE_LINUX_DEFAULT="splash=silent preempt=full mitigations=auto quiet security=apparmor snd_hda_intel.dmic_detect=0"
GRUB_CMDLINE_LINUX=""

```

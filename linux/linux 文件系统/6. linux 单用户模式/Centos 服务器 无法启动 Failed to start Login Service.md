

报错信息：

```bash
Failed to start Install ABRT coredump hook
Failed to load SELinux policy freezing
Failed to start Login Service
```

‍

在选择内核界面按E编辑内核

现在，向下滚动到内核引导行，并在行尾即UTF8后面添加 init=/bin/bash

按ctrl +x启动

```bash
mount -o remount,rw /


vim /etc/sysconfig/selinux
SELINUX=disable
```

重启     sbin/reboot   如报错....failed to link deamon      则    sbin/reboot -f

‍

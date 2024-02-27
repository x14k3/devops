# debian

‍

### 解决基于Debian发行系统的vim鼠标模式（可视模式）问题

​`vim /usr/share/vim/vim82/defaults.vim`​

```bash
if has('mouse')
   if &term =~ 'xterm'
   set mouse-=a
   else
   set mouse=nvi
   endif
endif
```

### 修改sh为bash

```
root@home:~# ll /bin/sh
lrwxrwxrwx 1 root root 9 Feb 26 20:26 /bin/sh -> /bin/dash
root@home:~# rm -rf /bin/sh
root@home:~# ln -s /bin/bash /bin/sh
root@home:~# ll /bin/sh
lrwxrwxrwx 1 root root 9 Feb 26 20:27 /bin/sh -> /bin/bash
```

‍

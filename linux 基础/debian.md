
#### ubuntu/debian将sh改为bash

`dpkg-reconfigure dash`

#### debian禁用vim鼠标的visual模式

```bash
vim /usr/share/vim/vim82/defaults.vim 
----------------------------------------
if has('mouse')
  if &term =~ 'xterm'
    set mouse-=a
  else
    set mouse=nvi
  endif
endif
```


#### 配置apt源

编辑/etc/apt/sources.list文件(需要使用sudo), 在文件最前面添加以下条目(操作前请做好相应备份)

```
deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
```

`apt-get update`
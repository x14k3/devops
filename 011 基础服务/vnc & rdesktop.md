# vnc & rdesktop

## VNC

> *VNC* (Virtual Network Console)是虚拟网络控制台的缩写。它是一款优秀的远程控制工具软件

打开终端并以 root 用户身份登录。

使用以下命令更新软件包管理器：

```
zypper update
```

安装 TigerVNC 服务器：

```bash
apt install tightvncserver
```

配置 VNC 服务器：

```
vncserver :1
```

这将在端口 5901 上启动 VNC 服务器，并分配一个 VNC 会话 ID。你可以通过替换“1”为所需的会话 ID 来启动多个 VNC 服务器。

设置 VNC 服务器密码：

```
vncpasswd
```

这将提示你输入新密码和密码确认。

修改 VNC 配置文件：

```
vi ~/.vnc/xstartup
```

将文件中的默认设置注释掉，并添加以下行：

```
#!/bin/sh
unset SESSION_MANAGER
exec /etc/X11/xinit/xinitrc
```

重启 VNC 服务器：

```
vncserver -kill :1
vncserver :1
```

现在你已经成功在 SUSE Linux 上安装和配置了 VNC 服务器。你可以使用 VNC 客户端连接到服务器并远程访问桌面环境。

## rdesktop

> 用于linux 连接windows RDP远程桌面

* Centos/RedHat可以通过yum命令在线安装：

  ```javascript
  yum -y install rdesktop
  ```

* Windows配置允许此windows远程访问。
* rdesktop连接windows远程桌面

  ```bash
  rdesktop -f -u username -p password  IP
  ```

* rdesktop连接windows服务器并传输文件

  ```bash
  rdesktop -f -u Administrator -p Ninestar123 10.10.0.167 -r disk:share=/data/archiveFile 
  ```

* 其他参数

  ```bash
  #用法：rdesktop [选项] 服务器[:端口]
  Usage: rdesktop [options] server[:port]
     -u: user name
     -d: domain
     -s: shell
     -c: working directory
     -p: password (- to prompt)
     -n: client hostname
     -k: keyboard layout on server (en-us, de, sv, etc.)
     -g: desktop geometry (WxH)
     -f: 全屏打开，使用Ctrl + Alt + Enter可以退出全屏模式。
     -b: force bitmap updates
     -L: local codepage
     -A: enable SeamlessRDP mode
     -B: use BackingStore of X-server (if available)
     -e: disable encryption (French TS)
     -E: disable encryption from client to server
     -m: do not send motion events
     -C: use private colour map
     -D: hide window manager decorations
     -K: keep window manager key bindings
     -S: caption button size (single application mode)
     -T: window title
     -N: enable numlock syncronization
     -X: embed into another window with a given id.
     -a: 连接颜色深度
     -z: enable rdp compression
     -x: RDP5 experience (m[odem 28.8], b[roadband], l[an] or hex nr.)
     -P: use persistent bitmap caching
     -r: enable specified device redirection (this flag can be repeated)
           '-r comport:COM1=/dev/ttyS0': enable serial redirection of /dev/ttyS0 to COM1
           '-r disk:floppy=/mnt/floppy':启用 /mnt/floppy 到 'floppy' 共享的重定向
           '-r clientname=<client name>': Set the client name displayed
               for redirected disks
           '-r lptport:LPT1=/dev/lp0': enable parallel redirection of /dev/lp0 to LPT1
           '-r printer:mydeskjet': enable printer redirection
           '-r sound:[local[:driver[:device]]|off|remote]': enable sound redirection
                       remote would leave sound on server
                       available drivers for 'local':
                       alsa:  ALSA output driver, default device: default
           '-r clipboard:[off|PRIMARYCLIPBOARD|CLIPBOARD]': enable clipboard
                        redirection.
                        'PRIMARYCLIPBOARD' looks at both PRIMARY and CLIPBOARD
                        when sending data to server.
                        'CLIPBOARD' looks at only CLIPBOARD.
           '-r scard[:"Scard Name"="Alias Name[;Vendor Name]"[,...]]
            example: -r scard:"eToken PRO 00 00"="AKS ifdh 0"
                     "eToken PRO 00 00" -> Device in Linux/Unix enviroment
                     "AKS ifdh 0"       -> Device shown in Windows enviroment 
            example: -r scard:"eToken PRO 00 00"="AKS ifdh 0;AKS"
                     "eToken PRO 00 00" -> Device in Linux/Unix enviroment
                     "AKS ifdh 0"       -> Device shown in Windows enviroment 
                     "AKS"              -> Device vendor name             
     -0: attach to console
     -4: use RDP version 4
     -5: use RDP version 5 (default)
  ```

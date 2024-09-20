# vnc & rdesktop

## vnc

　　Debian 11软件源中还有几种不同的VNC服务器，例如TightVNC ，TigerVNC和x11vnc。每个VNC服务器在速度和安全性方面都有其优点和缺点。

　　我们将使用TigerVNC，它是积极维护的高性能VNC服务器。

　　要在您的Debian 11服务器安装TigerVNC，请运行命令`sudo apt install tigervnc-standalone-server tigervnc-common`​。

　　当VNC服务器安装成后，请运行`vncserver`​命令以创建初始配置并设置密码。

```bash
sudo apt install tigervnc-standalone-server tigervnc-common vncserver
```

　　系统将提示您输入并确认密码，以及是否将其设置为仅供查看的密码。Would you like to enter a view-only password (y/n)?n。

　　如果您选择设置仅查看密码，则用户将无法使用鼠标和键盘与VNC实例进行交互。

　　首次运行`vncserver`​命令时，它将创建密码文件并将其存储在`~/.vnc`​目录中。

```
You will require a password to access your desktops.

Password:
Verify:
New 'myfreax.myfreax.local:1 (myfreax)' desktop at :1 on machine myfreax.myfreax.local

Starting applications specified in /home/myfreax/.vnc/xstartup
Log file is /home/myfreax/.vnc/myfreax.myfreax.local:1.log

Use xtigervncviewer -SecurityTypes VncAuth -passwd /home/myfreax/.vnc/passwd :1 to connect to the VNC server
```

　　请注意上面输出中[主机名](https://www.myfreax.com/how-to-change-hostname-on-debian-9/)后的`:1`​，这是vnc服务器的显示端口好。vnc服务器将会监听TCP端口`5901`​，即5900 + 1。

　　如果运行`vncserver`​命令创建第二个实例，它将在使用下一个显示端口即`:2`​，这意味着VNC服务器将会监听端口`5902`​，即5900 + 2。

　　在继续下一步之前，请先停止VNC实例。在我们的例子中，VNC服务器在端口5901运行，显示端口是`:1`​。因此停止显示端口`:1`​的是命令`vncserver -kill :1`​。

```bash
vncserver -kill :1
```

```
Killing Xtigervnc process ID 6677... success!
```

　　‍

## rdesktop

> 用于linux 连接windows RDP远程桌面

* Centos/RedHat可以通过yum命令在线安装：

  ```javascript
  yum -y install rdesktop
  ```

* Windows配置允许此windows远程访问。
* rdesktop连接windows远程桌面

  ```bash
  sudo rdesktop -f -u username -p password  IP
  ```

* rdesktop连接windows服务器并传输文件

  ```bash
  sudo rdesktop -f -u Administrator -p Ninestar123 10.10.0.167 -r disk:share=/data/archiveFile 
  sudo rdesktop -f -u Administrator -p Ninestar123 10.10.0.167 -r clipboard:PRIMARYCLIPBOARD
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
     -x: 开启RDP协议的额外功能，如音频重定向、打印机重定向等；
     -P: use persistent bitmap caching
     -r: 开启远程桌面的额外功能，如共享文件夹、共享粘贴板、共享打印机等
           '-r comport:COM1=/dev/ttyS0': enable serial redirection of /dev/ttyS0 to COM1
           '-r disk:floppy=/mnt/floppy':启用 /mnt/floppy 到 'floppy' 共享的重定向
           '-r clientname=<client name>': Set the client name displayed for redirected disks
           '-r lptport:LPT1=/dev/lp0': enable parallel redirection of /dev/lp0 to LPT1
           '-r printer:mydeskjet': enable printer redirection
           '-r sound:[local[:driver[:device]]|off|remote]': enable sound redirection remote would leave sound on server available drivers for 'local': alsa:  ALSA output driver, default device: default
           '-r clipboard:[off|PRIMARYCLIPBOARD|CLIPBOARD]': enable clipboard redirection.
                        'PRIMARYCLIPBOARD' looks at both PRIMARY and CLIPBOARD when sending data to server.
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

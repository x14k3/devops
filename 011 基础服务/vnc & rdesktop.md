# vnc & rdesktop

## tiger-vnc

```bash
# 安装vnc # debian12 gnome
apt install tigervnc-standalone-server
# 生成密码
su root
vncpasswd 
# 然后按提示输入密码

# 创建启动停止脚本
# 启动脚本
#---------------------------------------------------------
#!/bin/sh
/usr/bin/vncserver -rfbauth /root/.vnc/passwd -localhost no -geometry 1920x1080 -depth 24 :0
#---------------------------------------------------------

# 停止脚本
#---------------------------------------------------------
#!/bin/sh
/usr/bin/vncserver -kill :0
#---------------------------------------------------------

# 配置启动桌面
cat << EOF >> ~/.vnc/xstartup
#!/bin/sh
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
gnome-panel &
metacity &
nautilus &
gnome-terminal &
dbus-launch --exit-with-session gnome-session &
EOF


# 配置开机启动
cat << EOF >>/etc/systemd/system/vncserver.service
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=root
# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/to/path/vnc/stopVNC #停止脚本路径
ExecStart=/to/path/startVNC #启动脚本路径
ExecStop=/to/path/stopVNC #停止脚本路径
[Install]
WantedBy=multi-user.target
EOF


#使用systemctl设置
sudo systemctl daemon-reload                 #让系统知道新的单元文件
sudo systemctl enable vncserver.service      #让系统开机启动这个服务器
sudo systemctl start vncserver.service       #启动这个服务器

root@doshell:~ # ss -tunlp | grep 590
udp   UNCONN 0      0             0.0.0.0:59090      0.0.0.0:*    users:(("avahi-daemon",pid=702,fd=14))               
root@doshell:~ # 
```

‍

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

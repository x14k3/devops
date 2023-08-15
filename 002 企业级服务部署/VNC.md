# VNC

VNC虚拟网络计算，是一个图形桌面共享系统，可让您使用键盘和鼠标远程控制另一台计算机。

## 安装VNC服务器

Debian 11软件源中还有几种不同的VNC服务器，例如TightVNC ，TigerVNC和x11vnc。每个VNC服务器在速度和安全性方面都有其优点和缺点。

我们将使用TigerVNC，它是积极维护的高性能VNC服务器。

要在您的Debian 11服务器安装TigerVNC，请运行命令`sudo apt install tigervnc-standalone-server tigervnc-common`​。

当VNC服务器安装成后，请运行`vncserver`​命令以创建初始配置并设置密码。

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

```
vncserver -kill :1
```

```
Killing Xtigervnc process ID 6677... success!
```

## 配置 VNC 服务器

现在在Debian 11安装Xfce和TigerVNC，我们需要配置TigerVNC以使用Xfce。使用你喜欢的编辑器，编辑文件`~/.vnc/xstartup`​。

在本教程中，我们将使用[vim编辑文件](https://www.myfreax.com/the-basis-of-the-linux-vim-command/)​`~/.vnc/xstartup`​。完成后，[保存文件并退出vim](https://www.myfreax.com/how-to-save-file-in-vim-quit-editor/)。

​`xstartup`​文件是TigerVNC服务器启动时运行的脚本，因此`~/.vnc/xstartup`​文件还需要具有执行权限。运行[`chmod`](https://www.myfreax.com/chmod-command-in-linux/)​[命令](https://www.myfreax.com/chmod-command-in-linux/)。

```
vim ~/.vnc/xstartup
chmod u+x ~/.vnc/xstartup
```

```
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4 
```

如果需要更改VNC服务器[启动参数](http://tigervnc.org/doc/vncserver.html)，则可以使用vim创建`~/.vnc/config`​的文件，并在每行添加一个选项。

```
geometry=1920x1084
dpi=96
```

## 配置防火墙

最后，如果你Debian 11正在运行防火墙，并且使用[ufw](https://www.myfreax.com/how-to-setup-a-firewall-with-ufw-on-debian-10/)作为[防火墙](https://www.myfreax.com/how-to-setup-a-firewall-with-ufw-on-debian-10/)管理工具。则需要打开端口5901的连接。

如果你显示端口是`:2`​。则需要打开端口5902的连接，以此类推，请随时添加你需要允许的端口。

在本教程中我们将打开端口5901，运行ufw命令`sudo ufw allow 5901`​。

```
sudo ufw allow 5901
```

## 启动 VNC 服务器

现在我们完成VNC服务器的安装和配置，在Debian 11中，VNC服务器并没有作为Systemd的服务在后台运行。

因此，VNC服务器的启动关闭都是使用`vncserver`​命令。要启动VNC服务器非常简单运行命令`vncserver`​即可。

通常，仅仅运行`vncserver`​命令是不够用的。你可能需要添加更多选项，运行`vncserver --hel`​p命令查看更多选项。

在本教程中，我们将使用vncserver的-localhost选项运行vnc服务器，只有将-localhost选项的值设置为no时，才允许远程连接到VNC服务器。

```
vncserver -localhost no
```

## 连接 VNC服务器

要连接到远程服务器，请打开Vncviewer，然后在VNC Server字段输入`server_ip:5901`​。

您现在可以使用键盘和鼠标从本地计算机开始在远程桌面上工作。如果你的Debian 9未安装tigervnc-viewer。

你可以简单运行命令`sudo apt install tigervnc-viewer`​安装它。如果你的客户端计算机运行的是Windows系统，请点击此处[下载tigervnc客户端](https://sourceforge.net/projects/tigervnc/files/stable/1.12.0/vncviewer64-1.12.0.exe/download)。

```
sudo apt install tigervnc-viewer
```

### Linux macOS SSH隧道

VNC不是加密协议，可能会受到数据包嗅探。推荐的方法是[创建SSH tunnel隧道](https://www.myfreax.com/how-to-setup-ssh-tunneling/)，使用加密的数据连接到远程服务器。

如果您在计算机正在运行Linux，macOS或其他基于Unix的操作系统，则可以运行[`ssh`](https://www.myfreax.com/ssh-command-in-linux/)​命令轻松创建SSH隧道。

系统将提示您输入用户密码。不要忘记用您的用户名和服务器的IP地址替换`username`​和`server_ip_address`​。

```
ssh -L 5901:127.0.0.1:5901 -N -f -l username remote_server_ip
```

### Windows SSH隧道

Windows用户可以使用[PuTTY](https://www.putty.org/) 。设置SSH tunnel隧道。打开Putty，然后在`Host name or IP address`​字段中输入您的服务器IP地址。

在`Connection`​菜单下，展开`SSH`​并选择`Tunnels`​。在`Source Port`​字段中输入VNC服务器端口`5901`​。

在`Destination`​字段中输入`server_ip_address:5901`​，然后单击`Add`​按钮。

返回`Session`​页面以保存设置，保存后您无需每次都输入它们。要登录到远程服务器，请选择保存的会话，然后单击`Open`​按钮。

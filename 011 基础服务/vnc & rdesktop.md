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
  -u：用户名
  -d：域
  -s：用于远程启动的 shell/无缝应用程序
  -c：工作目录
  -p：密码（- 提示）
  -n：客户端主机名
  -k：服务器上的键盘布局（en-us、de、sv 等）
  -g：桌面几何形状（WxH[@DPI][+X[+Y]]）
  -i：启用智能卡身份验证，密码用作 PIN
  -f：全屏模式
  -b：强制位图更新
  -L：本地代码页
  -A：SeamlessRDP shell 的路径，这将启用 SeamlessRDP 模式
  -V：tls 版本（1.0、1.1、1.2，默认为协商）
  -B：使用 X-server 的 BackingStore（如果可用）
  -e：禁用加密（法语 TS）
  -E：禁用从客户端到服务器的加密
  -m：不发送运动事件
  -M：使用本地鼠标光标
  -C：使用私有颜色图
  -D：隐藏窗口管理器装饰
  -K：保留窗口管理器键绑定
  -S：标题按钮大小（单一应用程序模式）
  -T：窗口标题
  -t：禁用远程 ctrl
  -N：启用数字锁定同步
  -X：嵌入到具有给定 ID 的另一个窗口。
  -a：连接颜色深度
  -z：启用 rdp 压缩
  -x：RDP5 体验（m[odem 28.8]、b[roadband]、l[an] 或十六进制编号）
  -P：使用持久位图缓存
  -r：启用指定设备重定向（此标志可以重复）
  '-r comport：COM1=/dev/ttyS0'：启用 /dev/ttyS0 到 COM1 的串行重定向
  或 COM1=/dev/ttyS0,COM2=/dev/ttyS1
  '-r disk：floppy=/mnt/floppy'：启用 /mnt/floppy 到“floppy”共享的重定向
  或'floppy=/mnt/floppy,cdrom=/mnt/cdrom'
  '-r clientname=<客户端名称>'：设置显示的客户端名称
  用于重定向磁盘
  '-r lptport：LPT1=/dev/lp0'：启用 /dev/lp0 到 LPT1 的并行重定向
  或 LPT1=/dev/lp0,LPT2=/dev/lp1
  '-r Printer:mydeskjet': 启用打印机重定向
  或 mydeskjet="HP LaserJet IIIP" 以同时进入服务器驱动程序
  '-r Sound:[local[:driver[:device]]|off|remote]': 启用声音重定向
  远程将声音留在服务器上
  'local' 可用的驱动程序:
  alsa: ALSA 输出驱动程序，默认设备：默认
  oss: OSS 输出驱动程序，默认设备：/dev/dsp 或 $AUDIODEV
  libao: libao 输出驱动程序，默认设备：系统相关
  '-r Clipboard:[off|PRIMARYCLIPBOARD|CLIPBOARD]': 启用剪贴板
  重定向。
  'PRIMARYCLIPBOARD' 在向服务器发送数据时会同时查看 PRIMARY 和 CLIPBOARD。
  “剪贴板”仅查看剪贴板。
  '-r scard[:"Scard Name"="别名[;供应商名称]"[,...]]
  示例：-r scard:"eToken PRO 00 00"="AKS ifdh 0"
  "eToken PRO 00 00" -> GNU/Linux 和 UNIX 环境中的设备
  "AKS ifdh 0" -> Windows 环境中显示的设备
  示例：-r scard:"eToken PRO 00 00"="AKS ifdh 0;AKS"
  "eToken PRO 00 00" -> GNU/Linux 和 UNIX 环境中的设备
  "AKS ifdh 0" -> Microsoft Windows 环境中显示的设备
  "AKS" -> 设备供应商名称
  -0：连接到控制台
  -4：使用 RDP 版本 4
  -5：使用 RDP 版本 5（默认）
  -o：名称=值：向 rdesktop 添加附加选项。
  sc-csp-name 指定用于通过智能卡验证用户的加密服务提供商名称
  sc-container-name 指定容器名称，通常是用户名
  sc-reader-name 要使用的智能卡读卡器名称
  sc-card-name 指定要使用的智能卡的卡名称
  -v：启用详细日志记录
  ```

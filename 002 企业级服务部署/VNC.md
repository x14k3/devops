# VNC

## opensuse

在 SUSE Linux 上安装 VNC 服务器非常简单。你只需要遵循以下步骤：

1. 打开终端并以 root 用户身份登录。
2. 使用以下命令更新软件包管理器：

    ```
    zypper update
    ```
3. 安装 TigerVNC 服务器：

    ```
    zypper install tigervnc-server
    ```
4. 配置 VNC 服务器：

    ```
    vncserver :1
    ```

    这将在端口 5901 上启动 VNC 服务器，并分配一个 VNC 会话 ID。你可以通过替换“1”为所需的会话 ID 来启动多个 VNC 服务器。
5. 设置 VNC 服务器密码：

    ```
    vncpasswd
    ```

    这将提示你输入新密码和密码确认。
6. 修改 VNC 配置文件：

    ```
    vi ~/.vnc/xstartup
    ```

    将文件中的默认设置注释掉，并添加以下行：

    ```
    #!/bin/sh
    unset SESSION_MANAGER
    exec /etc/X11/xinit/xinitrc
    ```
7. 重启 VNC 服务器：

    ```
    vncserver -kill :1
    vncserver :1
    ```

现在你已经成功在 SUSE Linux 上安装和配置了 VNC 服务器。你可以使用 VNC 客户端连接到服务器并远程访问桌面环境。

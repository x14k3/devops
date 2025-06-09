# Linux下配置VSCode的Go开发环境

‍

## Linux下go安装与环境配置

‍

## 1. 安装必要的软件

### 安装Go语言

```bash
# 下载最新版Go (请访问 https://go.dev/dl/ 查看最新版本)
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz

# 解压到/usr/local目录
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# 设置环境变量
# GOROOT 指go的安装目录
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
# GOPATH 指go的工作目录
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.bashrc
source ~/.bashrc

# 验证安装
go version
```

### 安装VSCode

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

# Fedora/RHEL
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install code
```

## 2. 配置VSCode

1. 打开VSCode
2. 安装Go扩展：

    - 点击左侧活动栏的扩展图标(或按Ctrl+Shift+X)
    - 搜索"Go"并安装由Google发布的官方扩展

## 3. 安装Go工具

1. 在VSCode中打开任何.go文件
2. 右下角会提示安装Go工具，点击"Install"
3. 或者手动安装：

    ```go
    go install golang.org/x/tools/gopls@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install golang.org/x/tools/cmd/goimports@latest
    ```

## 4. 配置VSCode设置

1. 打开VSCode设置(Ctrl+,)
2. 搜索"go"进行相关配置，或直接编辑settings.json：

    ```json
    {
      "go.useLanguageServer": true,
      "go.gopath": "/home/yourusername/go",
      "go.goroot": "/usr/local/go",
      "go.formatTool": "goimports",
      "go.lintTool": "staticcheck",
      "go.lintFlags": ["--severity", "warning"],
      "go.testFlags": ["-v"],
      "editor.formatOnSave": true,
      "[go]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.organizeImports": true
        }
      }
    }
    ```

## 5. 创建测试项目

```bash
mkdir -p ~/go/src/hello
cd ~/go/src/hello
touch main.go
```

在main.go中添加：

```bash
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```

在VSCode中打开该项目文件夹，按F5可以调试运行。

## 6. 常用快捷键和功能

- 格式化代码: Shift+Alt+F
- 快速修复: Ctrl+.
- 转到定义: F12
- 查看引用: Shift+F12
- 运行测试: 在测试文件上右键选择"Run Test"
- 调试: 设置断点后按F5

## 7. 常见问题解决

### 工具安装失败

如果工具安装失败，尝试设置Go代理：

```go
go env -w GOPROXY=https://goproxy.cn,direct  # 国内用户推荐
```

### 权限问题

如果遇到权限问题，可以尝试：

```bash
sudo chown -R $USER:$USER ~/go
```

### gopls问题

如果gopls工作不正常，尝试更新：

```go
go install golang.org/x/tools/gopls@latest
```

这样就完成了Linux下VSCode的Go开发环境配置！

# Linux下go安装与环境配置 & VSCode配置go环境

　　‍

## Linux下go安装与环境配置

　　**1 首先查看linux版本,是否是64位版本，安装go时要确保安装对应版本**

```bash
uname -m
```

　　**2 安装对应go版本**

　　[https://golang.google.cn/dl/](https://golang.google.cn/dl/)

　　**3 解压安装至系统目录 下述命令解压到 /urs/local/ 目录**

```bash
tar -C /data/application/golang -xzvf go1.10.2.linux-amd64.tar.gz
```

　　**4 配置环境**

　　打开.bashrc 或 .profile 文件设置

```bash
# GOROOT 指go的安装目录
export GOROOT="/data/application/golang/go1.20.12"
#export GOROOT="/data/application/golang/go1.10.7"
# GOPATH 指go的工作目录
export GOPATH="/data/application/golang/goProject"
export PATH=$PATH:$GOROOT/bin
```

　　**5 查看是否安装成功**

```bash
go version   
go env

# 配置go源
go env -w GOPROXY="https://mirrors.aliyun.com/goproxy/,direct"
go env -w GOPROXY="https://proxy.golang.org,direct"

```

## **VSCode Golang开发环境配置**

　　**1 安装中文插件**

　　点击拓展按钮-输入`chinese`​-安装中文简体-重启vscode

　　**2 安装golang插件**

　　点击拓展按钮-输入`go`​-安装插件

　　**3 配置代理**

1. 打开 [VS](https://so.csdn.net/so/search?q=VS&spm=1001.2101.3001.7020) Code。
2. 点击左侧边栏的齿轮图标，然后选择“设置”。
3. 在搜索框中输入“代理”，然后点击“编辑设置.json”。
4. 在打开的`settings.json`​文件中，添加以下代码：

    ```json
    "http.proxy": "http://your-proxy-server:port",
    "https.proxy": "https://your-proxy-server:port",
    "http.proxyStrictSSL": false
    ```

    其中，`your-proxy-server`​和`port`​分别是你的[代理服务器](https://so.csdn.net/so/search?q=%E4%BB%A3%E7%90%86%E6%9C%8D%E5%8A%A1%E5%99%A8&spm=1001.2101.3001.7020)地址和端口号。
5. 保存文件并重启 VS Code。

　　**4 安装开发工具包**

　　Windows平台按下`Ctrl+Shift+P`​，Mac平台按`Command+Shift+P`​，这个时候VS Code界面会弹出一个输入框，我们在这个输入框中输入`>go:install`​，下面会自动搜索相关命令，我们选择`Go:Install/Update Tools`​这个命令，在弹出的窗口选中所有，并点击“确定”按钮，进行安装。

　　**5 go env**

```bash
$ go env
GO111MODULE="auto"
GOARCH="amd64"
GOBIN=""
GOCACHE="/home/sds/.cache/go-build"
GOENV="/home/sds/.config/go/env"
GOEXE=""
GOEXPERIMENT=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOINSECURE=""
GOMODCACHE="/data/application/golang/goProject/pkg/mod"
GONOPROXY=""
GONOSUMDB=""
GOOS="linux"
GOPATH="/data/application/golang/goProject"
GOPRIVATE=""
GOPROXY="https://proxy.golang.org,direct"
GOROOT="/data/application/golang/go1.20.12"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/data/application/golang/go1.20.12/pkg/tool/linux_amd64"
GOVCS=""
GOVERSION="go1.20.12"
GCCGO="gccgo"
GOAMD64="v1"
AR="ar"
CC="gcc"
CXX="g++"
CGO_ENABLED="1"
GOMOD=""
GOWORK=""
CGO_CFLAGS="-O2 -g"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-O2 -g"
CGO_FFLAGS="-O2 -g"
CGO_LDFLAGS="-O2 -g"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -Wl,--no-gc-sections -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build2570913735=/tmp/go-build -gno-record-gcc-switches"
```

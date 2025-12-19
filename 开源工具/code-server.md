
## 基于 code-server 镜像构建 Go 开发环境 Dockerfile

### 准备 Dockerfile

```dockerfile
# 使用官方 code-server 镜像作为基础
FROM codercom/code-server:latest
USER root
# 安装基础工具和依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    gcc \
    g++ \
    make \
    ca-certificates \
    procps \
    lsb-release \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 安装 Go 1.21.0
RUN wget -O go.tar.gz https://golang.org/dl/go1.21.0.linux-amd64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

# 设置 Go 环境变量
ENV GOPATH=/go
ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# 创建工作目录
RUN mkdir -p /workspace /go

# 安装常用 Go 开发工具
RUN go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/cweill/gotests/gotests@latest \
    && go install github.com/fatih/gomodifytags@latest \
    && go install github.com/josharian/impl@latest \
    && go install github.com/haya14busa/goplay/cmd/goplay@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest


# 配置 code-server 的 settings.json
RUN mkdir -p /home/coder/.local/share/code-server/User \
    && echo '{ \
        "go.gopath": "/go", \
        "go.goroot": "/usr/local/go", \
        "go.useLanguageServer": true, \
        "go.toolsManagement.autoUpdate": true, \
        "go.lintTool": "golangci-lint", \
        "go.lintOnSave": "package", \
        "editor.formatOnSave": true, \
        "go.formatTool": "goimports", \
        "[go]": { \
            "editor.defaultFormatter": "golang.go" \
        }, \
        "terminal.integrated.defaultProfile.linux": "bash", \
        "telemetry.enableTelemetry": false, \
        "telemetry.enableCrashReporter": false \
    }' > /home/coder/.local/share/code-server/User/settings.json

# 设置工作目录
WORKDIR /workspace

# 暴露 code-server 端口 (默认为 8080)
EXPOSE 8080

# 设置默认用户
USER 1000

# 设置容器启动命令
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "/workspace"]
```

### 构建镜像 / 启动容器

```bash
# 构建镜像
docker build -t my/code-server-go .
# 使用代理
docker build --build-arg http_proxy=http://192.168.3.100:10809 --build-arg https_proxy=http://192.168.3.100:10809 -t my/code-server-go .

# 基本运行
docker run -d \
  --name go-dev \
  -p 8080:8080 \
  -v "$(pwd)/workspace:/workspace" \
  -v "$(pwd)/go:/go" \
  go-code-server:1.21.0

# 带密码的运行方式（推荐）
docker run -d \
  --name go-dev \
  -p 8080:8080 \
  -v "$(pwd)/workspace:/workspace" \
  -v "$(pwd)/go:/go" \
  -e PASSWORD=your_password \
  go-code-server:1.21.0
```


### 安装扩展

在 code-server 中按 `Ctrl+Shift+X` 打开扩展商店，安装以下扩展：

- **Chinese**(Simplified 简体中文)
   1. **打开命令面板**：在 code-server (或 VS Code) 中按下 `Ctrl+Shift+P`.
   2. **输入命令**：输入 `Configure Display Language` (配置显示语言).
- **Go** (由 Go Team at Google 开发)
- **Go Test Explorer** (用于测试)
- **Go Coverage** (代码覆盖率)
- **Better Go Syntax** (语法高亮)
- **Error Lens** (更好的错误显示)


### 创建测试项目

在容器中或通过 code-server 创建测试文件：

```bash\
# 在终端中
mkdir -p /go/src/hello-world
cd /go/src/hello-world
go mod init hello-world
```

创建 `main.go`：
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
    fmt.Println("Go 开发环境已配置成功！")
}
```
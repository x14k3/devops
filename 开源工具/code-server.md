
code-server是一款服务端的vscode，可以在浏览器中使用vscode

## code-server 服务部署
### 准备配置文件

```bash
export coder-server-path="/data/application/coder-server"
mkdir ${coder-server-path}/code-server-data -p
mkdir ${coder-server-path}/project -p
mkdir ${coder-server-path}/.config/code-server/ -p

echo '
bind-addr: 127.0.0.1:8080
auth: password
password: xxxxx@1234
cert: false
' >> ${coder-server-path}/.config/code-server/config.yaml

chown -R 1000:1000 ${coder-server-path}
```
### docker-compose.yml 配置

```yaml
version: "3.9"
services:
  code-server:
    image: codercom/code-server:latest
    container_name: code-server-golang
    restart: unless-stopped
    ports:
      - "8903:8080"
    volumes:
      - /data/application/coder-server/code-server-data:/home/coder/.local/share/code-server
      - /data/application/coder-server/project:/home/coder/project
      - /data/application/coder-server/.config/code-server/config.yaml:/home/coder/.config/code-server/config.yaml
    environment:
      - DOCKER_USER=${USER}
    user: "${UID:-1000}:${GID:-1000}"
    stdin_open: true
    tty: true
```

### 关键配置说明

- **端口映射**: `127.0.0.1:8903:8080` - 本地8680端口映射到容器8080端口
- **数据持久化**: `./code-server-data` - 保存 code-server 配置和扩展
- **项目目录**: `./project` - **重要：这是您应该保存代码文件的目录**
- **配置文件**: `./config.yaml` - code-server 配置文件
- **用户权限**: 使用 UID:GID 1000:1000

### 启动服务

```bash
# 启动服务
docker compose up -d
# 查看服务状态
docker compose ps
# 查看日志
docker compose logs code-server-golang
```

### 访问方式

- **访问地址**: [http://localhost:8903](http://localhost:8903/)
- **登录密码**: `xxxxxx@123`（在 docker-compose.yml 中配置）

---
## 搭建 golang开发环境

### 创建 Dockerfile
vim Dockerfile
```dockerfile
# 使用官方 code-server 镜像
FROM codercom/code-server:latest

# 切换到 root 用户安装依赖
USER root

# 安装基础工具和 Go 开发环境
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    sudo \
    build-essential \
    # Go 依赖
    golang \
    && rm -rf /var/lib/apt/lists/*

# 或者从官方安装最新版 Go（推荐）
# 设置 Go 版本
ARG GO_VERSION=1.21.0
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

# 设置环境变量
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/home/coder/go"
ENV GOBIN="$GOPATH/bin"

# 创建 Go 工作目录并设置权限
RUN mkdir -p /home/coder/go/{bin,src,pkg} \
    && chown -R coder:coder /home/coder/go

# 安装常用 Go 工具
USER coder
RUN go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/cweill/gotests/gotests@latest

# 切换回 code-server 用户
USER coder

# 设置工作目录
WORKDIR /home/coder

# 暴露端口
EXPOSE 8080

# code-server 的默认启动命令
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]
```

### 构建镜像

```bash
# 构建镜像
docker build -t code-server-go .
```
提示：[[../docker/docker 实用指南/Docker 使用代理|Docker 使用代理]]

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

### 配置 Go 设置

创建或编辑 `/home/coder/.config/code-server/User/settings.json`：

```json
{
    "go.gopath": "/home/coder/go",
    "go.goroot": "/usr/local/go",
    "go.toolsGopath": "/home/coder/go/bin",
    "go.useLanguageServer": true,
    "go.languageServerExperimentalFeatures": {
        "diagnostics": true,
        "documentLink": true
    },
    "go.languageServerFlags": [
        "-rpc.trace",
        "serve"
    ],
    "go.formatTool": "goimports",
    "go.autocompleteUnimportedPackages": true,
    "go.testOnSave": false,
    "go.testTimeout": "30s",
    "go.coverOnSave": false,
    "go.enableCodeLens": {
        "references": true,
        "runtest": true
    },
    "editor.formatOnSave": true,
    "files.autoSave": "afterDelay",
    "[go]": {
        "editor.defaultFormatter": "golang.go"
    }
}
```



### 创建测试项目

在容器中或通过 code-server 创建测试文件：

```bash\
# 在终端中
mkdir -p /home/coder/projects/hello-world
cd /home/coder/projects/hello-world
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
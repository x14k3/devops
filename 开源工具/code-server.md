
code-server是一款服务端的vscode，可以在浏览器中使用vscode

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

## 访问方式

- **访问地址**: [http://localhost:8903](http://localhost:8903/)
- **登录密码**: `xxxxxx@123`（在 docker-compose.yml 中配置）

## 搭建 golang开发环境

#### Chinese (Simplified) (简体中文)
[[docker/docker-compose/assets/8956a24e90b6b1a5baa6e989f3ac8d13_MD5.jpg|Open: Pasted image 20251218135607.png]]
![[docker/docker-compose/assets/8956a24e90b6b1a5baa6e989f3ac8d13_MD5.jpg|625]]

1. **打开命令面板**：在 code-server (或 VS Code) 中按下 `Ctrl+Shift+P`.
2. **输入命令**：输入 `Configure Display Language` (配置显示语言).

#### GO
[[docker/docker-compose/assets/70a8e6b48f5934aedf9b45789aa3d0b9_MD5.jpg|Open: Pasted image 20251218135858.png]]
![[docker/docker-compose/assets/70a8e6b48f5934aedf9b45789aa3d0b9_MD5.jpg|600]]

进入容器手动安装
```bash
# 进入正在运行的 code-server 容器
docker exec -it <容器名或容器ID> bash

# 下载并安装 Go（以 Go 1.21 为例）
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
tar xf go1.21.0.linux-amd64.tar.gz

# 设置环境变量
echo 'export PATH=$PATH:/home/coder/go/bin' >> ~/.bashrc
source ~/.bashrc

# 验证安装
go version
```
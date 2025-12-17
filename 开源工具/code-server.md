
code-server是一款服务端的vscode，可以在浏览器中使用vscode


自动创建的`config.yaml`文件会包含密码。密码是自动生成的，可以自己修改。
也可以直接使用以下内容创建新文件

```yaml
bind-addr: 127.0.0.1:8080
auth: password
password: *****
cert: false
```


到这里重启容器后理论上是可以正常使用了，但我在尝试后

```bash
# 拉取镜像
docker pull codercom/code-server:latest

# 创建物理机所需要的映射目录
mkdir -p /data/application/coder-server/.config 
mkdir -p /data/application/coder-server/project
chmod 777 /data/application/coder-server/.config 

# 创建容器
docker run -d -it --name code-server -p 8903:8080 \
  -v "/data/application/coder-server/.config:/home/coder/.config" \
  -v "/data/application/coder-server/project:/home/coder/project" \
  -u "1000:1000" \
  -e "DOCKER_USER=root" \
  codercom/code-server:latest
```

查看`config.yaml`中的密码，并访问8080端口就可以使用了！！！！
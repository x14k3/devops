
## war 包部署

1. 下载 [Jenkins](https://updates.jenkins.io/download/war/) 
	`wget https://mirror.twds.com.tw/jenkins/war/2.530/jenkins.war`
2. 安装 [[../../中间件/JDK/JDK 部署|jdk]]  21 22 高版本
	`wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz`
3. 打开终端进入到下载目录.
4. 运行命令 `java -jar jenkins.war --httpPort=8080`
5. 打开浏览器进入链接 `http://localhost:8080`
6. 按照说明完成安装.

注意：安装过程中，插件安装失败，可能是因为 jenkins 版本和插件版本不一致问题或者是国外源的问题，可以更改插件源、更换 jenkins 版本或使用代理

**使用代理：**
`java -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=10809 -Dsocks.proxyHost=127.0.0.1 -Dsocks.proxyPort=10808 -jar jenkins.war --httpPort=8081`


## docker 部署

为小团队推荐的硬件配置:
- 1GB+可用内存
- 50 GB+ 可用磁盘空间

1. 安装 [[../../docker/docker 部署|docker]]
2. 下载 `jenkinsci/blueocean` 镜像并使用以下docker run 命令将其作为Docker中的容器运行 ：
```bash
docker pull jenkins/jenkins:jdk21

docker run -d --name jenkins \
  -u root \
  -p 8080:8080 \
  -v /data/jenkins/jenkins-data:/var/jenkins_home \
  jenkins/jenkins:jdk21

# 查看初始化密码
docker logs -f jenkins
```
3. 继续按照[Post-installation setup wizard](https://www.jenkins.io/zh/doc/book/installing/#setup-wizard)安装。


## jenkins 集群部署


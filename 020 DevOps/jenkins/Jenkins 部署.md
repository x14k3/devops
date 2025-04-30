# Jenkins 部署

### 准备工作

第一次使用 Jenkins，您需要：

* 机器要求：

  * 256 MB 内存，建议大于 512 MB
  * 10 GB 的硬盘空间（用于 Jenkins 和 Docker 镜像）
* 需要安装以下软件：

  * Java 8 ( JRE 或者 JDK 都可以) [安装jdk](031%20中间件/tuxedo/tuxedo部署.md#20240507152745-d9lfsct)
  * [Docker](https://www.docker.com/) （导航到网站顶部的Get Docker链接以访问适合您平台的Docker下载）[docker 部署](021%20docker/docker%20部署.md)

### 下载并运行 Jenkins

1. [下载 Jenkins](http://mirrors.jenkins.io/war-stable/latest/jenkins.war).
2. 打开终端进入到下载目录.
3. 运行命令 `java -jar jenkins.war --httpPort=8080`​.
4. 打开浏览器进入链接 `http://localhost:8080`​.
5. 按照说明完成安装.

安装完成后，您可以开始使用 Jenkins！

### 准备工作

第一次使用 Jenkins，您需要：

- 机器要求：
    - 256 MB 内存，建议大于 512 MB
    - 10 GB 的硬盘空间（用于 Jenkins 和 Docker 镜像）

- 需要安装以下软件：
    - [[../../中间件/jdk/jdk 部署|jdk 部署]]  Supported Java versions are: [11, 17, 21]
    - [[../../docker/docker 部署|docker 部署]]

### 下载并运行 Jenkins

1. 下载 Jenkins https://updates.jenkins.io/download/war/
	`wget https://mirror.twds.com.tw/jenkins/war/2.430/jenkins.war`
2. 打开终端进入到下载目录.
3. 运行命令 `java -jar jenkins.war --httpPort=8080`
4. 打开浏览器进入链接 `http://localhost:8080`.
5. 按照说明完成安装.

注意：安装过程中，插件安装失败，可能是因为 jenkins 版本和插件版本不一致问题或者是国外源的问题，可以更改插件源、更换 jenkins 版本或使用代理

**使用代理：**
`java -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=10809 -Dsocks.proxyHost=127.0.0.1 -Dsocks.proxyPort=10808 -jar jenkins.war --httpPort=8081`

安装完成后，您可以开始使用 Jenkins！

## 创建您的第一个Pipeline

### 什么是 Jenkins Pipeline?

Jenkins Pipeline（或简称为 "Pipeline"）是一套插件，将持续交付的实现和实施集成到 Jenkins 中。
持续交付 Pipeline 自动化的表达了这样一种流程：将基于版本控制管理的软件持续的交付到您的用户和消费者手中。
Jenkins Pipeline 提供了一套可扩展的工具，用于将“简单到复杂”的交付流程实现为“持续交付即代码”。Jenkins Pipeline 的定义通常被写入到一个文本文件（称为 `Jenkinsfile` ）中，该文件可以被放入项目的源代码控制库中。

### 创建Pipeline任务

新增任务，选择流水线
[[devops/Jenkins/assets/1297d8abf50fffe379f8f99c0a717f8a_MD5.jpg|Open: Pasted image 20251119113651.png]]
![[devops/Jenkins/assets/1297d8abf50fffe379f8f99c0a717f8a_MD5.jpg|700]]

Pipeline定义有两种方式：
一种是Pipeline Script ，是直接把脚本内容写到脚本对话框中；
另一种是 Pipeline script from SCM （Source Control Management–源代码控制管理，即从gitlab/github/git上获得pipeline脚本–JenkisFile）

### Pipeline Script 运行任务

```bash
pipeline{
    agent any
    stages{
        stage("first"){
            steps {
                echo 'hello world'
            }
        }
        stage("run test"){
            steps {
                echo 'run test'
            }
        }
    }
    post{
        always{
            echo 'always say goodbay'
        }
    }
}

```
脚本中定义了2个阶段（stage）：first和run test；post是jenkins完成构建动作之后需要做的事情。  
**运行任务**，可以看到分为3个部分，如下图所示：
[[devops/Jenkins/assets/b6043870b4f6e69d4910a87c066550b4_MD5.jpg|Open: Pasted image 20251119113757.png]]
![[devops/Jenkins/assets/b6043870b4f6e69d4910a87c066550b4_MD5.jpg|825]]
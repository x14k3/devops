[[一些概念释义/敏捷开发|敏捷开发]]
[[一些概念释义/为什么我们需要 DevOps|为什么我们需要 DevOps]]


DevOps是一个不断提高效率并且持续不断工作的过程
DevOps的方式可以让公司能够更快地应对更新和市场发展变化，开发可以快速交付，部署也更加稳定。
核心就在于简化Dev和Ops团队之间的流程，使整体软件开发过程更快速。

整体的软件开发流程包括：
- PLAN：开发团队根据客户的目标制定开发计划
- CODE：根据PLAN开始编码过程，需要将不同版本的代码存储在一个库中。
- BUILD：编码完成后，需要将代码构建并且运行。
- TEST：成功构建项目后，需要测试代码是否存在BUG或错误。
- DEPLOY：代码经过手动测试和自动化测试后，认定代码已经准备好部署并且交给运维团队。
- OPERATE：运维团队将代码部署到生产环境中。
- MONITOR：项目部署上线后，需要持续的监控产品。
- INTEGRATE：然后将监控阶段收到的反馈发送回PLAN阶段，整体反复的流程就是DevOps的核心，即持续集成、持续部署。
![[assets/Pasted image 20250906162430.png|625]]



## Code阶段工具

在code阶段，我们需要将不同版本的代码存储到一个仓库中，常见的版本控制工具就是SVN或者Git，这里我们采用Git作为版本控制工具，GitLab作为远程仓库。

### Git安装

https://git-scm.com/（傻瓜式安装）

### GitLab安装

```bash
# 拉取GitLab镜像
docker pull gitlab/gitlab-ce

# 准备docker-compose.yml文件
echo '
version: '3.1'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:latest'
    container_name: gitlab
    restart: always
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://192.168.11.11:8929'
        gitlab_rails['gitlab_shell_ssh_port'] = 2224
    ports:
      - '8929:8929'
      - '2224:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'
      - './data:/var/opt/gitlab'
' >> docker-compose.yml

# 启动容器
docker-compose up -d
```


访问GitLab首页

![[assets/Pasted image 20250906162713.png|625]]

![[assets/Pasted image 20250906162725.png|625]]

查看root用户初始密码
```bash
docker exec -it gitlab cat /etc/gitlab/initial_root_password
```

![[assets/Pasted image 20250906162755.png|650]]

登录root用户
![[assets/Pasted image 20250906162813.png]]
第一次登录后需要修改密码
![[assets/Pasted image 20250906162823.png]]


## Build阶段工具 **

构建Java项目的工具一般有两种选择，一个是Maven，一个是Gradle。
这里我们选择Maven作为项目的编译工具。
具体安装Maven流程不做阐述，但是需要确保配置好Maven仓库私服以及JDK编译版本。

## Operate阶段工具 **

部署过程，会采用Docker进行部署，暂时只安装Docker即可，后续还需安装Kubenetes

### Docker安装

[[../docker/docker 部署|docker 部署]]
![[assets/Pasted image 20250906163005.png]]

### Docker-Compose安装

[[../docker/docker compose|docker compose]]

## Integrate工具

持续集成、持续部署CI、CD的工具很多，其中Jenkins是一个开源的持续集成平台。
Jenkins涉及到将编写完毕的代码发布到测试环境和生产环境的任务，并且还涉及到了构建项目等任务。
Jenkins需要大量的插件保证工作，安装成本较高，下面会基于Docker搭建Jenkins。

### Jenkins介绍
Jenkins是一个开源软件项目，是基于Java开发的一种持续集成工具
Jenkins应用广泛，大多数互联网公司都采用Jenkins配合GitLab、Docker、K 作为实现DevOps的核心工具。
Jenkins最强大的就在于插件，Jenkins官方提供了大量的插件库，来自动化CI/CD过程中的各种琐碎功能。

Jenkins最主要的工作就是将GitLab上可以构建的工程代码拉取并且进行构建，再根据流程可以选择发布到测试环境或是生产环境。
一般是GitLab上的代码经过大量的测试后，确定发行版本，再发布到生产环境。

CI/CD可以理解为：
CI过程即是通过Jenkins将代码拉取、构建、制作镜像交给测试人员测试。
持续集成：让软件代码可以持续的集成到主干上，并自动构建和测试。
CD过程即是通过Jenkins将打好标签的发行版本代码拉取、构建、制作镜像交给运维人员部署。
持续交付：让经过持续集成的代码可以进行手动部署。
持续部署：让可以持续交付的代码随时随地的自动化部署。

![[assets/Pasted image 20250906163258.png|675]]

### Jenkins安装

```bash
# 拉取Jenkins镜像
docker pull jenkins/jenkins

# 编写docker-compose.yml
echo '
version: "3.1"
services:
  jenkins:
    image: jenkins/jenkins:2.319.1-lts
    container_name: jenkins
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - ./data/:/var/jenkins_home/

' >> docker-compose.yml

# 首次启动会因为数据卷data目录没有权限导致启动失败，设置data目录写权限
chmod -R a+w data/
```


查看密码登录Jenkins，并登录下载插件
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

![[assets/Pasted image 20250906163501.png|675]]

![[assets/Pasted image 20250906163513.png|675]]

选择需要安装的插件
![[assets/Pasted image 20250906163530.png|675]]
![[assets/Pasted image 20250906163540.png]]
![[assets/Pasted image 20250906163546.png]]

下载完毕设置信息进入首页（可能会出现下载失败的插件）
![[assets/Pasted image 20250906163600.png]]
![[assets/Pasted image 20250906163605.png]]
![[assets/Pasted image 20250906163610.png]]
### Jenkins入门配置
由于Jenkins需要从Git拉取代码、需要本地构建、甚至需要直接发布自定义镜像到Docker仓库，所以Jenkins需要配置大量内容。

#### 构建任务

准备好GitLab仓库中的项目，并且通过Jenkins配置项目的实现当前项目的[DevOps](https://blog.csdn.net/a772304419/article/details/134359312)基本流程。

构建Maven工程发布到GitLab（Gitee、Github均可）
GitLab查看项目 
  ![[assets/Pasted image 20250906163746.png]]

Jenkins点击左侧导航新建任务
  ![[assets/Pasted image 20250906163813.png]]
- 选择自由风格构建任务
  ![[assets/Pasted image 20250906163840.png]]


#### 配置源码拉取地址

Jenkins需要将Git上存放的源码存储到Jenkins服务所在磁盘的本地

配置任务源码拉取的地址
  ![[assets/Pasted image 20250906163911.png]]
Jenkins立即构建
  ![[assets/Pasted image 20250906164004.png]]

查看构建工程的日志，点击上述③的任务条即可
![[assets/Pasted image 20250906164024.png]]
可以看到源码已经拉取带Jenkins本地，可以根据第三行日志信息，查看Jenkins本地拉取到的源码。
    
查看Jenkins容器中[/var/jenkins_home/workspace/test](https://blog.csdn.net/a772304419/article/details/134359312)的源码
![[assets/Pasted image 20250906164043.png]]

#### 配置Maven构建代码

代码拉取到Jenkins本地后，需要在Jenkins中对代码进行构建，这里需要Maven的环境，而Maven需要Java的环境，接下来需要在Jenkins中安装JDK和Maven，并且配置到Jenkins服务。

准备JDK、Maven压缩包通过数据卷映射到Jenkins容器内部

数据卷存放位置
![[assets/Pasted image 20250906164159.png]]
解压压缩包，并配置Maven的settings.xml
```xml
<!-- 阿里云镜像地址 -->
<mirror>  
    <id>alimaven</id>  
    <name>aliyun maven</name>  
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>  
</mirror>
<!-- JDK1.8编译插件 -->
<profile>
    <id>jdk-1.8</id>
    <activation>
        <activeByDefault>true</activeByDefault>
        <jdk>1.8</jdk>
    </activation>
    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
    </properties>  
</profile>

```

Jenkins配置JDK&Maven并保存
![[assets/Pasted image 20250906164237.png]]
![[assets/Pasted image 20250906164246.png]]

配置Jenkins任务构建代码
配置Maven构建代码 
  ![[assets/Pasted image 20250906164319.png]]

![[assets/Pasted image 20250906164326.png]]

立即构建测试，查看target下的jar包
构建源码
  ![[assets/Pasted image 20250906164352.png]]
  ![[assets/Pasted image 20250906164400.png]]

#### 配置Publish发布&远程操作

配置Publish Over SSH连接测试、生产环境

Publish Over SSH配置
![[assets/Pasted image 20250906164444.png]]

配置任务的构建后操作，发布jar包到目标服务
配置构建后操作
![[assets/Pasted image 20250906164533.png]]

![[assets/Pasted image 20250906164539.png]]
![[assets/Pasted image 20250906164545.png]]

立即构建任务，并去目标服务查看
立即构建
![[assets/Pasted image 20250906164605.png]]
![[assets/Pasted image 20250906164610.png]]


## CI、CD入门操作

基于Jenkins拉取GitLab的SpringBoot代码进行构建发布到测试环境实现持续集成

基于Jenkins拉取GitLab指定发行版本的SpringBoot代码进行构建发布到生产环境实现CD实现持续部署

### 持续集成

为了让程序代码可以自动推送到测试环境基于Docker服务运行，需要添加Docker配置和脚本文件让程序可以在集成到主干的同时运行起来。

添加Dockerfile文件
构建自定义镜像
![[assets/Pasted image 20250906164655.png]]

添加docker-compose.yml文件
加载自定义镜像启动容器
![[assets/Pasted image 20250906164710.png]]

追加Jenkins构建后操作脚本命令
构建后发布并执行脚本命令 
![[assets/Pasted image 20250906164729.png]]

发布到GitLab后由Jenkins立即构建并托送到目标服务器
构建日志
![[assets/Pasted image 20250906164752.png]]

测试部署到目标服务器程序
查看目标服务器并测试接口
![[assets/Pasted image 20250906164806.png]]
![[assets/Pasted image 20250906164813.png]]

###  持续交付、部署

程序代码在经过多次集成操作到达最终可以交付，持续交付整体流程和持续集成类似，不过需要选取指定的发行版本

下载Git Parameter插件
下载Git Parameter 
![[assets/Pasted image 20250906164845.png]]
设置项目参数化构建
基于Git标签构建
![[assets/Pasted image 20250906164900.png]]
![[assets/Pasted image 20250906164908.png]]
给项目添加tag版本
添加tag版本
![[assets/Pasted image 20250906164924.png]]
任务构建时，采用Shell方式构建，拉取指定tag版本代码
切换指定标签并构建项目
![[assets/Pasted image 20250906164939.png]]

基于Parameter构建任务，任务发布到目标服务器
构建任务
![[assets/Pasted image 20250906164955.png]]

## 集成Sonar Qube

### Sonar Qube介绍

Sonar Qube是一个开源的代码分析平台，支持Java、Python、PHP、JavaScript、CSS等25种以上的语言，可以检测出重复代码、代码漏洞、代码规范和安全性漏洞的问题。

Sonar Qube可以与多种软件整合进行代码扫描，比如Maven，Gradle，Git，Jenkins等，并且会将代码检测结果推送回Sonar Qube并且在系统提供的UI界面上显示出来

![[assets/Pasted image 20250911210411.png|600]]

### Sonar Qube环境搭建

#### Sonar Qube安装

Sonar Qube在7.9版本中已经放弃了对MySQL的支持，并且建议在商业环境中采用PostgreSQL，那么安装Sonar Qube时需要依赖PostgreSQL。

并且这里会安装Sonar Qube的长期支持版本[8.9](https://blog.csdn.net/a772304419/article/details/134359312)

```bash
docker pull postgres 
docker pull sonarqube:8.9.3-community

echo '
version: "3.1"
services:
  db:
    image: postgres
    container_name: db
    ports:
      - 5432:5432
    networks:
      - sonarnet
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
  sonarqube:
    image: sonarqube:8.9.3-community
    container_name: sonarqube
    depends_on:
      - db
    ports:
      - "9000:9000"
    networks:
      - sonarnet
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
networks:
  sonarnet:
    driver: bridge
'  >> docker-compoe.yml

docker-compose up -d
```

访问Sonar Qube首页

http://x.x.x.x:5432

![[assets/Pasted image 20250913081245.png]]

还需要重新设置一次密码

![[assets/Pasted image 20250913081257.png]]

Sonar Qube首页

![[assets/Pasted image 20250913081306.png]]

#### 安装中文插件

![[assets/Pasted image 20250913081322.png]]

安装成功后需要重启，安装失败重新点击install重装即可。

安装成功后，会查看到重启按钮，点击即可

![[assets/Pasted image 20250913081335.png]]

### Sonar Qube基本使用

Sonar Qube的使用方式很多，Maven可以整合，也可以采用sonar-scanner的方式，再查看Sonar Qube的检测效果
#### Maven实现代码检测

修改Maven的settings.xml文件配置Sonar Qube信息
```bash
<profile>
    <id>sonar</id>
    <activation>
        <activeByDefault>true</activeByDefault>
    </activation>
    <properties>
        <sonar.login>admin</sonar.login>
        <sonar.password>123456789</sonar.password>
        <sonar.host.url>http://192.168.11.11:9000</sonar.host.url>
    </properties>
</profile>
```

在代码位置执行命令：`mvn sonar:sonar`
![[assets/Pasted image 20250913081438.png]]

查看Sonar Qube界面检测结果
![[assets/Pasted image 20250913081459.png]]

#### Sonar-scanner实现代码检测

下载Sonar-scanner：[https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip)

解压并配置sonar服务端信息
```bash
yum -y install unzip
unzip sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip

# - 配置sonarQube服务端地址，修改conf下的sonar-scanner.properties
```
![[assets/Pasted image 20250913081603.png]]

执行命令检测代码
```bash
# 在项目所在目录执行以下命令
~/sonar-scanner/bin/sonar-scanner -Dsonar.sources=./ -Dsonar.projectname=demo -Dsonar.projectKey=java -Dsonar.java.binaries=target/
```

Ps：主要查看我的sonar-scanner执行命令的位置
![[assets/Pasted image 20250913081650.png]]

查看SonarQube界面检测结果

![[assets/Pasted image 20250913081700.png]]

### Jenkins集成Sonar Qube

Jenkins继承Sonar Qube实现代码扫描需要先下载整合插件

#### Jenkins安装插件

![[assets/Pasted image 20250913081730.png]]


![[assets/Pasted image 20250913081735.png]]

![[assets/Pasted image 20250913081741.png]]

#### Jenkins配置Sonar Qube

开启Sonar Qube权限验证

![[assets/Pasted image 20250913081806.png]]

获取Sonar Qube的令牌

![[assets/Pasted image 20250913081818.png]]

配置Jenkins的Sonar Qube信息

![[assets/Pasted image 20250913081835.png]]

![[assets/Pasted image 20250913081840.png]]

![[assets/Pasted image 20250913081845.png]]


#### 配置Sonar-scanner

将Sonar-scaner添加到Jenkins数据卷中并配置全局配置

![[assets/Pasted image 20250913081908.png]]

配置任务的Sonar-scanner

![[assets/Pasted image 20250913081925.png]]

#### 构建任务

![[assets/Pasted image 20250913081937.png]]
![[assets/Pasted image 20250913081943.png]]

## 集成Harbor


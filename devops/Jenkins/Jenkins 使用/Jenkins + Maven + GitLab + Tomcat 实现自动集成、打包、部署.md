
[[devops/Jenkins/Jenkins 使用/assets/ff657ecba4a8a08fbf5dbf6218caeb75_MD5.jpg|Open: Pasted image 20251122204535.png]]
![[devops/Jenkins/Jenkins 使用/assets/ff657ecba4a8a08fbf5dbf6218caeb75_MD5.jpg|675]]
## 环境准备

- docker 部署 [[../Jenkins 部署|Jenkins]]
- docker 部署 [[../../GitLab/gitlab 部署|gitlab]]
- gitlab [准备maven项目](https://github.com/x14k3/java-hello-world-with-maven.git) 将 github 这个项目迁移到自己部署的 gitlab上
- tomcat 服务器 [[../../../中间件/JDK/JDK 部署|部署 JDK ]]、[[../../../中间件/tomcat/Tomcat 部署|部署 Tomcat]]
- 在 Jenkins上添加 ssh-servers 资源（tomcat服务器）
- 在 Jenkins 上安装 JDK
```bash
# 将 jdk 安装包上传到 jenkins 服务器
# jenkins 是docker 安装的，所以将 jdk安装包上传到 挂载的目录，解压即可
wget https://mirrors.huaweicloud.com/java/jdk/8u192-b12/jdk-8u192-linux-x64.tar.gz
tar xf jdk-8u192-linux-x64.tar.gz
```
- 在 Jenkins 上安装 Maven
```bash
# 将 maven 安装包上传到 jenkins 服务器
# jenkins 是docker 安装的，所以将 maven安装包上传到 挂载的目录，解压即可
wget https://archive.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar xf apache-maven-3.5.4-bin.tar.gz
# 在 Maven 上配置阿里云加速
vim apache-maven-3.5.4/conf/settings.xml
#-----------------------------------------------
  <mirrors>
    <mirror>
        <id>aliyun maven</id>
        <name>aliyun</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
```


## jenkins 全局工具配置

将 JDK 和 Maven 配置到 Jenkins 上

[[devops/Jenkins/Jenkins 使用/assets/a8abffcafa7929b66f243e00cff2def6_MD5.jpg|Open: Pasted image 20251123132925.png]]
![[devops/Jenkins/Jenkins 使用/assets/a8abffcafa7929b66f243e00cff2def6_MD5.jpg|575]]

[[devops/Jenkins/Jenkins 使用/assets/ca97f9b0619c27decef30bd75b766538_MD5.jpg|Open: Pasted image 20251122210359.png]]
![[devops/Jenkins/Jenkins 使用/assets/ca97f9b0619c27decef30bd75b766538_MD5.jpg|575]]


## 配置CI/CD任务

选择构建一个maven项目，任务名称可以随便写，自己能区别即可
[[devops/Jenkins/Jenkins 使用/assets/e4fd0ebd9b39640776c28d3fffd9b6b0_MD5.jpg|Open: Pasted image 20251123133856.png]]
![[devops/Jenkins/Jenkins 使用/assets/e4fd0ebd9b39640776c28d3fffd9b6b0_MD5.jpg|650]]
### 源码管理

设置Git信息
[[devops/Jenkins/Jenkins 使用/assets/1836d54e4ace6d7a173a70bce3eecc41_MD5.jpg|Open: Pasted image 20251123134032.png]]
![[devops/Jenkins/Jenkins 使用/assets/1836d54e4ace6d7a173a70bce3eecc41_MD5.jpg|650]]

### 构建触发器

这个根据自己情况选择是否勾选，如果勾选的话如果依赖的项目打包的时候这个也会自动打包
[[devops/Jenkins/Jenkins 使用/assets/eb3f93c0c6a430c9af2f34914c5d9b0d_MD5.jpg|Open: Pasted image 20251122210847.png]]
![[devops/Jenkins/Jenkins 使用/assets/eb3f93c0c6a430c9af2f34914c5d9b0d_MD5.jpg|650]]


### 构建环境

这个也根据自身的情况选择是否勾选，如果勾选的话，每次打包的话会清空上次的构建空间的内容

[[devops/Jenkins/Jenkins 使用/assets/1743f3fdd033361fc7cca651e6a2f6be_MD5.jpg|Open: Pasted image 20251122210825.png|375]]
![[devops/Jenkins/Jenkins 使用/assets/1743f3fdd033361fc7cca651e6a2f6be_MD5.jpg|650]]

### Pre Steps（构建前的步骤）

如果在构建前需要执行一下脚本可以选择Pre Steps

[[devops/Jenkins/Jenkins 使用/assets/550ffe452ead7932642b2975d0d1ca1c_MD5.jpg|Open: Pasted image 20251122210945.png]]
![[devops/Jenkins/Jenkins 使用/assets/550ffe452ead7932642b2975d0d1ca1c_MD5.jpg|650]]

### Build

这是设置构建的一个选项，如maven版本和使用工程的pom文件及构建命令
`clean install -Dmaven.test.skip=true`
[[devops/Jenkins/Jenkins 使用/assets/85be96f8b46d1d4eabf0dcabc02a49af_MD5.jpg|Open: Pasted image 20251123134120.png]]
![[devops/Jenkins/Jenkins 使用/assets/85be96f8b46d1d4eabf0dcabc02a49af_MD5.jpg|650]]


### 构建后操作

构建完成后，如果想传到某个服务器，可以选择下面的插件

[[devops/Jenkins/Jenkins 使用/assets/5ed961ff971bb3f6d95021292943870c_MD5.jpg|Open: Pasted image 20251122211116.png]]
![[devops/Jenkins/Jenkins 使用/assets/5ed961ff971bb3f6d95021292943870c_MD5.jpg|650]]

选择要上传的服务器
[[devops/Jenkins/Jenkins 使用/assets/4984fc8e8f9014510f9125dd94e905cf_MD5.jpg|Open: Pasted image 20251123140048.png]]
![[devops/Jenkins/Jenkins 使用/assets/4984fc8e8f9014510f9125dd94e905cf_MD5.jpg|650]]

多个Source files 可以用【,】隔开
如果想给多个服务器部署，可以选择add server

[[devops/Jenkins/Jenkins 使用/assets/9a8c49c5a52f61339d40fa2521235d79_MD5.jpg|Open: Pasted image 20251122211222.png]]
![[devops/Jenkins/Jenkins 使用/assets/9a8c49c5a52f61339d40fa2521235d79_MD5.jpg|650]]

配置完成后点击保存，然后点击build now即可开始自动构建
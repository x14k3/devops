
[[devops/Jenkins/Jenkins 使用/assets/ff657ecba4a8a08fbf5dbf6218caeb75_MD5.jpg|Open: Pasted image 20251122204535.png]]
![[devops/Jenkins/Jenkins 使用/assets/ff657ecba4a8a08fbf5dbf6218caeb75_MD5.jpg|675]]
## 安装 Tomcat 服务

[[../../../中间件/JDK/JDK 部署|部署 JDK ]]
[[../../../中间件/tomcat/Tomcat 部署|部署 Tomcat]]

## 在 Jenkins 上安装 jdk

```bash
# 将 jdk 安装包上传到 jenkins 服务器
# jenkins 是docker 安装的，所以将 jdk安装包上传到 挂载的目录，解压即可
wget https://mirrors.huaweicloud.com/java/jdk/8u192-b12/jdk-8u192-linux-x64.tar.gz
tar xf jdk-8u192-linux-x64.tar.gz
```
## 在 Jenkins 上安装 Maven

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


## 全局工具配置

将 jdk 和maven 配置到 jenkins 上

[[devops/Jenkins/Jenkins 使用/assets/bedc72db1a9a3778ae43a29ae2628ec5_MD5.jpg|Open: Pasted image 20251122203826.png]]
![[devops/Jenkins/Jenkins 使用/assets/bedc72db1a9a3778ae43a29ae2628ec5_MD5.jpg|575]]



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
  -v /data/jenkins:/var/jenkins_home \
  jenkins/jenkins:jdk21

# 查看初始化密码
docker logs -f jenkins
```
3. 继续按照[Post-installation setup wizard](https://www.jenkins.io/zh/doc/book/installing/#setup-wizard)安装。


## jenkins 集群部署




## jenkins 常用插件

- [Publish Over SSH版本390.vb_f56e7405751](https://plugins.jenkins.io/publish-over-ssh)
- [SSH Build Agents plugin版本3.1085.vc64d040efa_85](https://plugins.jenkins.io/ssh-slaves)
- [Git client plugin版本6.4.0](https://plugins.jenkins.io/git-client)
- [Git plugin版本5.8.0](https://plugins.jenkins.io/git)
- [Git Parameter Plug-In版本444.vca_b_84d3703c2](https://plugins.jenkins.io/git-parameter)
- [Generic Webhook TriggerVersion2.4.1](https://plugins.jenkins.io/generic-webhook-trigger)
- [Pipeline: Stage ViewVersion2.38](https://plugins.jenkins.io/pipeline-stage-view)
- [AnsibleVersion588.v2a_a_a_f345e34f](https://plugins.jenkins.io/ansible)
- [DingTalkVersion2.8.0](https://plugins.jenkins.io/dingding-notifications)
- [Qy Wechat NotificationVersion1.1.3](https://plugins.jenkins.io/qy-wechat-notification)
- [Blue OceanVersion1.27.24](https://plugins.jenkins.io/blueocean)
- [KubernetesVersion4392.v19cea_fdb_5913](https://plugins.jenkins.io/kubernetes)
- [Kubernetes Client APIVersion7.3.1-256.v788a_0b_787114](https://plugins.jenkins.io/kubernetes-client-api)

## 环境准备

- 安装 [[../../docker/docker 部署|docker ]]
- 安装 [[../../docker/docker-compose/docker-compose 命令|docker-compose 命令]]


## 1.拉取gitlab镜像

### 1.1.搜索镜像

[Docker Hub](https://hub.docker.com/)

在官网可以找到各种各样需要的镜像，通过搜索可以找到gitlab镜像。

### 1.2.拉取gitlab镜像

```bash
docker pull gitlab/gitlab-ce
```

**注意** ：如果没有指定对应的版本，默认会拉取 **latest** 版本。

通过docker images 命令看到gitlab镜像证明你已经pull完了

```bash
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
gitlab/gitlab-ce    latest              c752bc978a4b        4 days ago          1.78GB
```

## 2.启动gitlab

运行：

```bash
docker run -d --name gitlab --hostname 192.168.3.111 \
-p 443:443 -p 80:80 -p 2222:22 \
-v /data/gitlab/etc:/etc/gitlab \
-v /data/gitlab/log:/var/log/gitlab \
-v /data/gitlab/opt:/var/opt/gitlab \
-e TZ=Asia/Shanghai gitlab/gitlab-ce
```

数据存储地方

| 本地的位置            | 容器的位置           | 作用             |
| ---------------- | --------------- | -------------- |
| /data/gitlab/etc | /etc/gitlab     | 用于存储GitLab配置文件 |
| /data/gitlab/log | /var/log/gitlab | 用于存储日志         |
| /data/gitlab/opt | /var/opt/gitlab | 用于存储应用数据       |

通过docker ps 命令看到gitlab容器证明已经运行成功了

```bash
[root@localhost ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                    PORTS                                                          NAMES
9e12ae220c14        c752bc978a4b        "/assets/wrapper"   13 minutes ago      Up 13 minutes (healthy)   0.0.0.0:23->22/tcp, 0.0.0.0:81->80/tcp, 0.0.0.0:444->443/tcp   gitlab
```

## **3.配置GitLab** 

所有的配置都在唯一的配置文件 dataopt/gitlab/etc/gitlab.rb** 。

本文是直接修改生成的配置文件，当然也可以进入容器内部通过 **shell** 会话进行相关操作。

```bash
# 进入容器命令
docker exec -it gitlab /bin/bash
```

### 3.1.配置端口

**编辑gitlab.rb文件**

修改如下几个端口，修改与docker映射的端口一致

```bash
# external_url 'GENERATED_EXTERNAL_URL'
external_url "http://192.168.3.111"
gitlab_rails['gitlab_shell_ssh_port'] = 2222
nginx['listen_port'] = 80
gitlab_rails['gitlab_ssh_host'] = '192.168.3.111'
gitlab_rails['time_zone'] = ''
#如果用了Https，下面的端口也修改
# nginx['redirect_http_to_https_port'] = 80


```

**说明** ：
- **external_url** ：GitLab的资源都是基于这个URL，其实就是clone的地址，如果不配置端口81，使用http进行clone时，页面链接会不显示端口，复制出来的链接会无效；
- **gitlab_shell_ssh_port** ：ssh端口，使用ssh进行clone时的端口；
- **listen_port** ：nginx监听的端口；
- **redirect_http_to_https_port** ：使用https时，nginx监听的端口；

### 3.2.邮箱配置

GitLab的使用过程中涉及到大量的邮件，而邮件服务可以选择使用`Postfix`，`sendmai`配置`SMTP`服务其中一种；
`Postfix`还要安装其他东西，`sendmai`又是比较老，相对较下`SMTP`配置起来会比较方便。

**编辑gitlab.rb文件**
添加如下配置

```bash
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_user_name'] = "XXX@163.com"
gitlab_rails['smtp_password'] = "password"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = :login
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['gitlab_email_from'] = "XXX@163.com"
user["git_user_email"] = "XXX@163.com"
```

**说明：**
- **gitlab_rails[‘smtp_address’]** ：SMTP服务地址，不同的服务商不同
- **gitlab_rails[‘smtp_port’]** ：服务端口
- **gitlab_rails[‘smtp_user_name’]** ：用户名，自己注册的
- **gitlab_rails[‘smtp_password’]** ：客户端授权秘钥
- **gitlab_rails[‘gitlab_email_from’]** ：发出邮件的用户，注意跟用户名保持一致
- **user[“git_user_email”]** ：发出用户，注意跟用户名保持一致

### 3.3.刷新配置

```bash
# 进入容器
docker exec -it gitlab /bin/bash
# 刷新配置
gitlab-ctl reconfigure
```


默认用户 root
默认密码
```bash
cat /data/gitlab/etc/initial_root_password
```

登录后依次点击【头像】-【Edit profile】-【password】，然后修改密码
至此，gitlab已经安装完成，并已修改密码


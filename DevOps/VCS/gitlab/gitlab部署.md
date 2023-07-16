# gitlab部署

GitLab 是一个用于仓库管理系统的开源项目，使用Git作为代码管理工具，并在此基础上搭建起来的Web服务，可通过Web界面进行访问公开的或者私人项目。它拥有与Github类似的功能，能够浏览源代码，管理缺陷和注释。

gitlab下载地址[https://packages.gitlab.com/gitlab/gitlab-ce](https://packages.gitlab.com/gitlab/gitlab-ce "https://packages.gitlab.com/gitlab/gitlab-ce")

```bash

# 关闭selinux
setenforce 0
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

# 关闭firewalld
systemctl stop firewalld ; systemctl disable firewalld

# 添加gitlab仓库
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
# 安装gitlab
yum install -y gitlab-ce   # 默认安装到/opt目录
# 修改 gitlab 配置文件并初始化 gitlab
vim /etc/gitlab/gitlab.rb 
--------------------------------------------------------
vim /etc/gitlab/gitlab.rb
# 修改ip
external_url 'http://192.168.10.150:8001'

#GitLab默认会占用80、8080和9090端口，如果服务器上还有tomcat、Jenkins等其他服务，可能会遇到端口冲突,如果想修改端口的话可以
#external_url 'http://192.168.2.100:自定义端口'
#unicorn['port'] = xxx
#prometheus['listen_address'] = 'localhost:xxx'
#将xxx更换成自己需要使用的端口

---------------------------------------------------------
# 修改完配置文件要执行此操作初始化gitlab
gitlab-ctl reconfigure 


```

# 命令和目录

/opt/gitlab/ # gitlab的程序安装目录
/var/opt/gitlab # gitlab数据目录
/var/opt/gitlab/git‐data # 存放仓库数据

|命令|function|
| :------------| :-------------------------|
|start|启动所有服务|
|stop|关闭所有服务|
|restart|重启所有服务|
|status|查看所有服务状态|
|tail|查看日志信息|
|service-list|查看所有启动服务|
|graceful-kill|平稳停止一个服务|
|help|帮助|
|reconfigure|修改配置文件之后，重新加载|
|show-config|查看所有服务配置文件信息|
|uninstall|卸载这个软件|
|cleanse|清空gitlab数据|

```
[root@zutuanxue ~]# gitlab-ctl start
ok: run: alertmanager: (pid 1564) 3804s
ok: run: gitaly: (pid 1550) 3804s
[root@zutuanxue ~]# gitlab-ctl start nginx
ok: run: nginx: (pid 1531) 3823s

#这些操作指令，如果不指定名称的话，默认会操作所有
```

# Gitlab的服务构成

```bash
gitlab-ctl service-list
# gitaly*	git RPC服务，用于处理gitlab发出的git调用
# gitlab-workhorse*	轻量级的反向代理服务器
# logrotate*	日志文件管理工具
# nginx*	静态web服务
# postgresql*	数据库
# redis*	缓存数据库
# sidekiq*	用于在后台执行队列任务
# unicorn*	用Ruby编写的web server，GitLab Rails应用是托管在这个服务器上面
# alertmanager*，gitlab-exporter*，grafana*，node-exporter*，postgres-exporter*，# prometheus*，redis-exporter*	#与监控相关的插件
```

在浏览器中访问本机，就可以打开登录界面，初次登录必须修改密码（不能少于8位），更改完成后可以使用管理员账号登录，用户名为root

访问gitlab:http://192.168.10.150:8001

默认用户名：root  密码：`cat /etc/gitlab/initial_root_password`

#devops/git

Git是一个开源的分布式版本控制系统，可以有效、高速地处理从很小到非常大的项目版本管理。

GitLab 是一个用于仓库管理系统的开源项目，使用Git作为代码管理工具，并在此基础上搭建起来的web服务。

简单的说呢，git可以管理软件代码，gitlab是部署在服务器端的，可以使用git将代码上传到服务器保管，gitlab就是服务器端管理项目的一个web工具。

## 1.系统环境准备

```bash
# 关闭selinux
setenforce 0
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

# 关闭firewalld
systemctl stop firewalld ; systemctl disable firewalld
```

## 2.gitlab安装部署

gitlab下载地址[https://packages.gitlab.com/gitlab/gitlab-ce](https://packages.gitlab.com/gitlab/gitlab-ce "https://packages.gitlab.com/gitlab/gitlab-ce")

```bash
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
# 可选邮件通知设置
gitlab_rails['smtp_enable'] = false
gitlab_rails['smtp_address'] = "smtp.qq.com" 
gitlab_rails['smtp_port'] = 465 
gitlab_rails['smtp_user_name'] = "891506240@qq.com" 
gitlab_rails['smtp_password'] = "ublihkwaxcaibebf" 
gitlab_rails['smtp_domain'] = "qq.com" 
gitlab_rails['smtp_authentication'] = :login 
gitlab_rails['smtp_enable_starttls_auto'] = true 
gitlab_rails['smtp_tls'] = true 
gitlab_rails['gitlab_email_from'] = "891506240@qq.com" 
user["git_user_email"] = "891506240@qq.com"
---------------------------------------------------------
# 修改完配置文件要执行此操作初始化gitlab
gitlab-ctl reconfigure 


```

## 3.配置gitlab

访问gitlab:http://192.168.10.150:8001

默认用户名：root  密码：`cat /etc/gitlab/initial_root_password`

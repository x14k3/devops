
## 环境准备

- 安装 [[../../docker/docker 部署|docker ]]
- 安装 [[../../docker/docker compose|docker compose]]

## 直接通过 docker 部署 gitlab

```bash
docker pull gitlab/gitlab-ce

docker run -d -p 80:80 -p 443:443 -p 2222:22 \
--restart always \
--name gitlab \
-v /data/gitlab/etc:/etc/gitlab \
-v /data/gitlab/log:/var/log/gitlab \
-v /data/gitlab/opt:/var/opt/gitlab \
--privileged=true gitlab/gitlab-ce

```

修改gitlab.rb文件
```bash
vi /data/gitlab/etc/gitlab.rb

# 修改如下位置：
# 如果使用公有云且配置了域名了，可以直接设置为域名，如下
external_url 'http://gitlab.redrose2100.com'
# 如果没有域名，则直接使用宿主机的ip，如下
external_url 'http://172.22.27.162'  
# 同样如果有域名，这里也可以直接使用域名
gitlab_rails['gitlab_ssh_host'] =  'gitlab.redrosee2100.com'
# 同样如果没有域名，则直接使用宿主机的ip地址
gitlab_rails['gitlab_ssh_host'] = '172.22.27.162'
# 端口为启动docker时映射的ssh端口
gitlab_rails['gitlab_shell_ssh_port'] =10010 
# 设置时区为东八区，即北京时间
gitlab_rails['time_zone'] = 'Asia/Shanghai'  
```

关于邮箱发邮件的配置如下

```bash
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"   # 邮箱服务器
gitlab_rails['smtp_port'] = 465    # 邮箱服务对应的端口号
gitlab_rails['smtp_user_name'] = "hitredrose@163.com"   # 发件箱的邮箱地址
gitlab_rails['smtp_password'] = "xxxxxxxxxxx"      # 发件箱对应的授权码，注意不是登录密码，是授权码
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'hitredrose@163.com'     # 发件箱地址
gitlab_rails['gitlab_email_display_name'] = 'gitlab.redrose2100.com'    # 显示名称
gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'     # 提示不要回复
```

默认用户 `root `
默认密码
```bash
cat /data/gitlab/etc/initial_root_password
```

登录后依次点击【头像】-【Edit profile】-【password】，然后修改密码

至此，gitlab已经安装完成，并已修改密码
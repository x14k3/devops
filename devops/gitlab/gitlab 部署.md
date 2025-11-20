
GitLab 是一个用于仓库管理系统的开源项目，使用Git作为代码管理工具，并在此基础上搭建起来的Web服务，可通过Web界面进行访问公开的或者私人项目。它拥有与Github类似的功能，能够浏览源代码，管理缺陷和注释。

gitlab下载地址[https://packages.gitlab.com/gitlab/gitlab-ce](https://packages.gitlab.com/gitlab/gitlab-ce "https://packages.gitlab.com/gitlab/gitlab-ce")

### 1. 硬件要求

- cpu
	1个核心最多支持100个用户，但由于所有工作和后台作业都在同一个核心上运行，因此应用程序可能会慢一点  
    2核是建议的核心数，最多支持500个用户  
    4个核心最多可支持2,000个用户  
    8个核心最多支持5,000个用户  
    16个内核最多可支持10,000个用户  
    32个核心最多可支持20,000个用户  
    64个内核最多可支持40,000个用户
- 内存
    至少8GB可寻址内存来安装gitlab，在运行gitlab之前，至少需要4GB可用空间，建议至少有2BG交换，建议将内核的swappiness 设置为较低水平足以。

  ```bash
  vim /etc/sysctl.conf 
  vm.swappiness = 10
  ```

- 数据库  
    运行数据库服务器至少要有5-10GB的可存储空间，但具体要求取决于gitlab安装的大小。强烈支持使用postgresql，Mysql/mariadb（不支持所有的gitlab功能)  
    Postgresql 要求：  
    从GitLab 10.0开始，需要PostgreSQL 9.6或更高版本，并且不支持早期版本。我们强烈建议用户使用PostgreSQL 9.6，因为这是用于开发和测试的PostgreSQL版本。  
    使用PostgreSQL的用户必须确保将pg_trgm扩展加载到每个GitLab数据库中。可以通过对每个数据库运行以下查询来启用此扩展（使用PostgreSQL超级用户）：  
    CREATE EXTENSION pg_trgm;  
    在某些系统上，您可能需要安装额外的软件包（例如 postgresql-contrib）以使此扩展可用。
    参考[PostgreSQL 安装部署](../../database/PostgreSQL/PostgreSQL%20安装部署.md)

- redis和 sidekiq  
    Redis  存储所有用户会话和后台任务队列，redis的存储要求很低，每个用户大约25KB，sidekiq使用多线程进程处理后台作业，此过程从整个redis堆栈（200M+)开始，但由于内存泄露，他可能会随着时间的推移而增长，在非常活跃的服务器上，sidekiq进程可以使用1GB+内存
- Prometheus 及相关，使用默认设置，这些进程将消耗大概200M内存

### 2. 部署gitlab

step 1.OS 环境描述

```bash
[root@test03 ~]# cat /etc/redhat-release 
CentOS Linux release 7.9.2009 (Core)

# 关闭selinux
setenforce 0
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

# 关闭firewalld
systemctl stop firewalld ; systemctl disable firewalld
```

step 2.安装相关依赖

```bash
yum -y install curl policycoreutils-python openssh-server perl
#rpm -ivh http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/policycoreutils-python-utils-2.9-3.el8_1.1.noarch.rpm
```

step 3.下载并配置yum源

```bash
# 添加gitlab仓库-GitLab CE 是GitLab 社区版，免费开源，适用于个人和小型团队。 GitLab EE 是GitLab 企业版，是付费的，适用于中型至大型团队。
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
#curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
# 安装gitlab
yum install -y gitlab-ce   # 默认安装到/opt目录
```

#### 2.1 gitlab服务构成

查看服务状态：`gitlab-ctl status`​ 可以看到gitlab的依赖组件

- Alertmanager：用于监控系统和应用程序，并在发生故障时发送通知。
- Gitaly：一个Git服务器，处理与Git存储库相关的所有请求。它提高了GitLab性能和稳定性。
- GitLab Exporter：将GitLab度量指标导出到Prometheus中，以便进行监控和警报。
- GitLab Kubernetes Agent Server (KAS)：使用Kubernetes管理集群，并支持CI/CD操作。
- GitLab Workhorse：处理所有传入HTTP请求并管理响应。它提高了速度和可靠性。
- Logrotate：日志文件轮换工具，可以避免磁盘空间耗尽。
- Nginx：Web服务器，用于反向代理和负载均衡。
- Postgres Exporter：将PostgreSQL数据库度量指标导出到Prometheus中，以便进行监控和警报。
- PostgreSQL：数据库引擎，用于存储数据。
- Prometheus：开源监控系统，收集时间序列数据并提供可视化、告警等功能。
- Puma：Ruby Web服务器，用于处理Rails应用程序请求。
- Redis：内存缓存数据库，用于加快应用程序的读写速度。
- Redis Exporter: 将Redis度量指标导出到Prometheus中，以便进行监控和警报。
- Sidekiq：用于处理后台任务的任务队列。它是一个非常快速和可靠的工作线程。

#### 2.2 gitlab常用的默认安装目录

```bash
gitlab组件日志路径：/var/log/gitlab
gitlab配置路径：/etc/gitlab/  路径下有gitlab.rb配置文件
应用代码和组件依赖程序：/opt/gitlab
各个组件存储路径： /var/opt/gitlab/
仓库默认存储路径   /var/opt/gitlab/git-data/repositories
版本文件备份路径：/var/opt/gitlab/backups/
nginx安装路径：/var/opt/gitlab/nginx/
redis安装路径：/var/opt/gitlab/redis
```

### 3. 配置gitlab

其中包含所有的主配置的情况，组件的配置，其配置后需要进行reconfigure 进行生效配置并重启方可生效，其生效后的结果在各组件目录中可以看到

```
[root@kids ~]# cd /etc/gitlab/
[root@kids gitlab]# ls 22,1 0%
gitlab.rb gitlab-secrets.json trusted-certs
[root@kids gitlab]# 
```

#### 3.1 配置 URL 访问地址

```bash
#编辑 /etc/gitlab/gitlab.rb ，修改如下：
vim  /etc/gitlab/gitlab.rb
----------------------------------------------
external_url 'http://192.168.2.244:9080'
----------------------------------------------
# 配置生效，重新执行此命令时间也比较长
gitlab-ctl reconfigure

# 重启服务器：
gitlab-ctl restart
gitlab-ctl status
```

#### 3.2 配置邮件服务器

安装Postfix来发送通知邮件

```bash
yum install -y postfix 
# 编辑 /etc/postfix/main.cf 打开main.cf文件，将这行代码改为 “inet_interfaces = all” 。
systemctl enable postfix
systemctl start postfix
```

#### 3.3 配置外部redis

step 1.编辑gitlab.rb文件

```
redis['enable'] = false

#使用TCOP连接
gitlab_rails['redis_host'] = '127.0.0.1'
gitlab_rails['redis_port'] = 6380
gitlab_rails['redis_password'] = 'test' #访问redis的密码
```

step 2. 加载和重启gitlab

```
gitlab-ctl reconfigure 
gitlab-ctl restart
```

#### 3.4 配置外部postgresql

```bash
cd /var/opt/gitlab/

cat gitlab-rails/etc/database.yml

# This file is managed by gitlab-ctl. Manual changes will be
# erased! To change the contents below, edit /etc/gitlab/gitlab.rb
# and run `sudo gitlab-ctl reconfigure`.

production:
  adapter: postgresql
  encoding: unicode
  collation:
  database: gitlabhq_production
  pool: 1
  username: "gitlab"
  password:
  host: "/var/opt/gitlab/postgresql"
  port: 5432
  socket:
  sslmode:
  sslcompression: 0
  sslrootcert:
  sslca:
  load_balancing: {"hosts":[]}
  prepared_statements: false
  statement_limit: 1000
  fdw:
  variables:
    statement_timeout: 60000
```

#### 3.5 配置外部mysql

[mysql 单机部署](mysql%20单机部署.md)

step 1.创建MySQL数据库

```
mysql> CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
mysql> grant all on gitlabhq_production.* to 'git'@'localhost' identified by 'git';
```

step 2.bundle禁止使用postgresql，把mysql改成postgres

```
#cat /opt/gitlab/embedded/service/gitlab-rails/.bundle/config

---
BUNDLE_RETRY: "5"
BUNDLE_JOBS: "33"
BUNDLE_WITHOUT: "development:test:mysql"
```

step 3.修改/etc/gitlab/gitlab.rb

```
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'mysql2'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '127.0.0.1'
gitlab_rails['db_port'] = '3306'
gitlab_rails['db_username'] = 'git'
gitlab_rails['db_password'] = '123456'
```

step 4.检测运行环境

```
gitlab-rake gitlab:check
```

根据提示是0.4.5版本

```
cd /opt/gitlab/embedded/bin/
./gem install mysql2 -v "0.4.5"
./gem install peek-mysql2 -v 1.1.0
```

step 5.检测不报错,从新加载配置

```
gitlab-ctl reconfigure
```

#### 3.6 gitlab更改默认的nginx

step 1.修改配置文件/etc/gitlab/gitlab.rb

```
[root@gitlab ~]# vim /etc/gitlab/gitlab.rb

nginx['enable'] = false        #不启用nginx
```

step 2.检查默认nginx配置文件，并迁移至新Nginx服务

```
nginx配置文件,包含gitlab-http.conf文件
/var/opt/gitlab/nginx/conf/nginx.conf 

gitlab核心nginx配置文件
/var/opt/gitlab/nginx/conf/gitlab-http.conf
```

step 3.重启 nginx、gitlab服务

```
[root@gitlab ~]# gitlab-ctl restart
[root@gitlab ~]# systemctl restart nginx.service
```

访问可能出现报502。原因是nginx用户无法访问gitlab用户的socket文件。 重启gitlab需要重新授权

```
[root@gitlab ~]# chmod -R o+x /var/opt/gitlab/gitlab-rails 
```

‍

### 4. gitlab相关命令

```bash
/opt/gitlab                           # gitlab的程序安装目录
/var/opt/gitlab                    # gitlab数据目录
/var/opt/gitlab/git‐data  # 存放仓库数据

gitlab-ctl start                    #启动全部服务
gitlab-ctl restart                #重启全部服务
gitlab-ctl stop                    #停止全部服务
gitlab-ctl restart nginx     #重启单个服务，如重启nginx
gitlab-ctl status                 #查看服务状态
gitlab-ctl reconfigure       #使配置文件生效
gitlab-ctl show-config      #验证配置文件
gitlab-ctl uninstall            #删除gitlab（保留数据）
gitlab-ctl cleanse              #删除所有数据，从新开始
gitlab-ctl tail <service name> #查看服务的日志
gitlab-ctl tail nginx           #如查看gitlab下nginx日志
gitlab-rails console          #进入控制台
```

‍

### gitlab迁移

迁移的整体思路是：  
step 1.在新服务器上安装相同版本的gitlab  
step 2.将备份生成的备份文件发送到新服务器的相同目录下  
step 3.gitlab恢复

```
[root@gitlab ~]# gitlab-ctl stop unicorn        #停止相关数据连接服务
[root@gitlab ~]# gitlab-ctl stop sidekiq

修改权限，如果是从本服务器恢复可以不修改
[root@gitlab-new ~]# chmod 777 /var/opt/gitlab/backups/1530156812_2018_06_28_10.8.4_gitlab_backup.tar

从1530156812_2018_06_28_10.8.4编号备份中恢复
[root@gitlab ~]# gitlab-rake gitlab:backup:restore BACKUP=1530156812_2018_06_28_10.8.4  
```

按照提示输入两次yes并回车

step 4.启动gitlab

```
[root@gitlab ~]# gitlab-ctl start
```

### gitlab升级

step 1.关闭gitlab服务  
[root@gitlab ~]# gitlab-ctl stop  
step 2.备份  
[root@gitlab ~]# gitlab-rake gitlab:backup:create  
step 3.下载新版gitlab的rpm包安装，安装时选择升级  
step 4.安装成功后重新加载配置并启动

```
[root@gitlab ~]# gitlab-ctl reconfigure
[root@gitlab ~]# gitlab-ctl restart
```

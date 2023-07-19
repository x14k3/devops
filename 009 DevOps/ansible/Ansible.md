# Ansible

ansible是新出现的自动化运维工具，基于Python开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。

snsible默认通过 SSH 协议管理机器.

安装Ansible之后,不需要启动或运行一个后台进程,或是添加一个数据库.只要在一台电脑(可以是一台笔记本)上安装好,就可以通过这台电脑管理一组远程的机器.在远程被管理的机器上,不需要安装运行任何软件,因此升级Ansible版本不会有太多问题.

snsible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。

# 一、基础部署

## 1. 安装 ansible

```bash
yum -y install  ansible
```

## 2. 配置文件

```bash
/etc/ansible/ansible.cfg    #主配置文件
/etc/ansible/hosts          #Inventory 主机清单
/usr/bin/ansible-doc        #帮助文件
/usr/bin/ansible-playbook   #指定运行任务文件
```

`/etc/ansible/ansible.cfg`

```bash
inventory = /etc/ansible/hosts        # ansible主机管理清单
forks = 5                             # 并发数量
sudo_user = root                      # 提权
remote_port = 22                      # 操作主机的端口
host_key_checking = False             # 第一次交互目标主机，需要输入yes/no,改成False不用输入
timeout = 10                          # 连接主机的超时时间
log_path = /var/log/ansible.log       # 设置日志路径
private_key_file = /root/.ssh/id_rsa  # 指定认证密钥的私钥
```

## 3. 主机清单

首先配置ssh密钥方式连接

```bash
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.0.105
ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.0.106
ssh-copy-id -i /root/.ssh/id_rsa.pub root@127.0.0.1
```

`/etc/ansible/hosts`

```bash
192.168.100.1
192.168.100.10

[db]    # db组
10.25.1.56
10.25.1.57
[web]    # web组
xxx.xxx
xxx.xxx

[server:children]  ### 子组分类变量 children
db
web

[web01]   # web组 远程方式基于用户和密码（需要安装sshpass）
10.0.0.50 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=123456
10.0.0.51 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=123456

[web01]  # 一组主机使用相同的ssh配置
10.0.0.50
10.0.0.51
[web01:vars]
ansible_ssh_port=22
ansible_ssh_user=root
ansible_ssh_pass=123456


```

配置完成后可以使用`ansible all -m ping -o`命令进行测试；
若是单独配置了主机清单配置文件，则需要加上 -i 来进行指定
`ansible -i /etc/ansible/hosts-web webservers -m ping -o`

## 4. ansible命令应用基础

```bash
# 语法：ansible <host-pattern> [-f forks] [-m module_name] [-a args]
<host-pattern>  # 这次命令对哪些主机生效的
   inventory group name
   ip
   all
-f forks        # 一次处理多少个主机
-m module_name  # 要使用的模块
-a args         # 模块特有的参数
-i /xxx/xx      # 指定主机清单文件
-o              # 压缩输出，摘要输出.尝试一切都在一行上输出
-v              # 执行详细输出
--become        # 相当于sudo 提权


```

## 二、常见模块

Ansible 官网提供了非常多的 [module 使用说明](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html)

查看ansible的某个模块说明：`ansible-doc -s  script`

### command

默认模块：命令模块，用于在远程主机执行命令；不能使用变量，管道等

```bash
ansible all -m command -a 'date'
ansible all -a 'date'
```

### shell

允许您在远程主机上运行任意命令，就像您登录到 shell 一样。可以使用变量，管道等

```bash
ansible all -m shell -a 'echo magedu | passwd --stdin user1'
```

### ping

测试指定主机是否能连接

```bash
ansible all -m ping -o
```

### script

将本地脚本复制到远程主机并运行之

```bash
ansible test1 -m script -a '/opt/ansible-test/yum_nginx.sh'
```

### file

创建、修改、删除文件或者目录

```bash
# file模块常用的几个参数：state、path、src、dest、mode、owner、group、name、recurse
path     # 创建文件的绝对路径
state    # 状态（touch指创建文件，absent指删除文件或者目录，directory 指创建目录,link：创建链接文件）  
mode     # 文件属性（默认创建的文件的属性是644，默认创建的目录的属性是755）  
owner    # 所有者  
group    # 所属组
recurse  # 当文件为目录时，是否进行递归设置权限

ansible test1 -m file -a "path=/opt/111 state=touch mode=0755 owner=root group=root"
ansible test1 -m file -a "path=/opt/222 state=directory mode=0700 owner=root group=root"
ansible test1 -m file -a "path=/opt/222 state=absent"
ansible test1 -m shell -a "rm -rf /opt/*"
```

### yum

yum模块用于在python2环境下管理基于RPM的Linux发行版中的rpm包，在python3环境中使用dnf模块

```bash
name     # 必须参数，指定要操作的包名，同时可以指定版本，，如果指定了以前的版本，需要打开allow_downgrade参数；如果state参数为latest，name参数可以指定为’*，这意味着yum -y update；如果指定了本地的rpm文件或是一个url连接，需要state参数为present。
allow_downgrade # 是否允许rpm包版本降级（True或False）
state           # 安装 (present or installed, latest) 或删除 (absent or removed) 包，
download_only   # 仅下载，不安装
download_dir    # 与download_only参数一起使用，指定下载包的目录
disable_gpg_check # 当state参数值为present或latest时，禁用gpg检查
list              # 列出包的安装，更新，可用以及仓库信息，相当于yum list

ansible test1 -m yum -a "name=mariadb-libs state=removed"

- name: install php and mariadb
	yum: name= "{{ item }}"
	with_items:
	  - php
	  - mariadb
```

### copy

复制文件(复制本地文件到远程主机的指定位置)

```bash
src     # 指定需要copy的文件，如果src的目录带“/” 则复制该目录下的所有东西,如果src的目录不带“/”则连同该目录一起复制到目标路径.
dest    # 用于指定文件将被拷贝到远程主机的哪个目录中,dest为必须参数。
owner   # 指定文件拷贝到远程主机后的属主,但是远程主机上必须有对应的用户,否则会报错。
group   # 属组
mode    # 指定文件拷贝到远程主机后的权限，如果你想将权限设置为"rw-r--r--"，则可以使用mode=0644表示
content # 取代src=,表示直接用此处的信息生成为文件内容
force   # 当远程主机的目标路径中已经存在同名文件,并且与ansible主机中的文件内容不同时,是否强制覆盖,可选值有yes和no,默认值为yes,表示覆盖,如果设置为no,则不会执行覆盖拷贝操作,远程主机中的文件保持不变。
backup  # 当远程主机的目标路径中已经存在同名文件,并且与ansible主机中的文件内容不同时,是否对远程主机的文件进行备份,可选值有yes和no,当设置为yes时,会先备份远程主机中的文件,然后再将ansible主机中的文件拷贝到远程主机。
validate # 复制前是否检验需要复制目的地的路径
-------------------------------------------------------------------
ansible test1 -m copy -a 'src=/etc/fstab dest=/opt/fstab.ansible owner=root mode=0666'
ansible test1 -m copy -a 'content="hello ansiblenHi ansible" dest=/opt/test.ansible'
```

### fetch

fetch模块与copy模块类似，但作用相反。用于把远程机器的文件拷贝到本地。

### cron

cron 模块可以帮助我们管理远程主机中的计划任务，功能相当于crontab命令

```bash
month   # 指定月份
minute  # 指定分钟
job     # 指定任务
day     # 表示那一天
hour    # 指定小时
weekday # 表示周几
state   # 表示是添加还是删除
  present # 安装
  absent  #移除
backup  # 如果此参数的值设置为 yes，会先对计划任务进行备份，然后再对计划任务进行修改或者删除，cron 模块会在远程主机的 `/tmp` 目录下创建备份文件

# 任务于每天1点5分执行，任务内容为输出test字符
ansible test1 -m cron -a "name=test minute=5 hour=1 job='echo test' "
ansible test1 -m cron -a "name=test2 minute=*  job='echo test2 >> /opt/cron.log 2>&1'"
# 根据任务name删除任务
ansible test1 -m cron -a "name=test2 state=absent"
```

### user

用于管理用户账号和用户属性

```bash
name    # 用户名
uid     # uid
group   # 指定用户所在的基本组
groups  # 指定用户所在的附加组。注意，如果说用户已经存在并且已经拥有多个附加组，那么如果想要继续添加新的附加组，需要结合 append 参数使用，否则在默认情况下，当再次使用 groups 参数设置附加组时，用户原来的附加组会被覆盖
append  # 将 append 设置为 yes，表示追加附加组到现有的附加组设置，append 默认值为 no
home    # 家目录
createhome  # 是否创建家目录
shell   # 指定用户的默认 shell
expires # 指定用户的过期时间,你想要设置用户的过期日期为2018年12月31日，那么你首先要获取到2018年12月31日的 unix 时间戳，使用命令 “`date -d 2018-12-31 +%s`
comment # 用于指定用户的注释信息
system  # 是否是系统用户
state   # 状态,可选值有 present、absent，默认值为 present，表示用户需要存在，当设置为 absent 时表示删除用户。
remove  # 当state 的值设置为 absent 时，如果设置为yes，在删除用户的同时，会删除用户的家目录。
passwor # 创建用户指定密码的时候，直接passwd=xxx 不行，ansible不认明文的密码
# echo "123" | openssl passwd -1 -stdin 
# $1$c1D.OvTM$Ar9Yy8WXVmtGiU2O3FbPi.
# passwd -1表示使用MD5进行加密

# 创建用户user1
ansible test1 -m user -a 'name="user1"'
# 删除用户，同时删除家目录
ansible test1 -m user -a 'name="user1" state=absent remove=yes'
```

### group

组管理

```bash
gid     # gid      
name    # 组名              
state   # present/absent 状态          
system  # 是否是系统组 
```

### service

管理服务运行状态

```bash
enabled # 是否开机自动启动
name    # 指定服务名
state   # 指定服务状态
  started     # 启动服务
  stoped      # 停止服务
  restarted   # 重启服务
arguments   # 服务的参数
   
```

### setup

收集远程主机的facts,每个被管理节点在接受并运行管理命令之前，会将自己主机相关信息，如操作系统版本，IP地址等报告给远程的ansible主机

```bash
ansible all -m setup
```

### archive

功能：在远端主机打包与压缩；

```bash
path	# 要压缩的文件或目录
dest	# 压缩后的文件
format	# 指定打包压缩的类型：bz2、gz、tar、xz、zip

ansible test1 -m archive -a 'path=/opt/jdk dest=/tmp/jdk2.tar.gz format=gz'
```

### unarchive

功能：在远端主机解包与解压缩；

```bash
creates  # 一个文件名，当它已经存在时，这个步骤将不会被运行。
src      # tar源路径，可以是ansible主机上的路径，也可以是远程主机上的路径，如果是远程主机上的路径，则需设置copy=no
dest     # 远程主机上的目标绝对路径
mode     # 设置解压缩后的文件权限
exec     # 列出需要排除的目录和文件
copy     # 默认为yes，拷贝的文件从ansible主机复制到远程主机，no在远程主机上寻找src源文件解压
remote_src # 设置为yes指示已存档文件已在远程系统上，而不是Ansible控制器的本地文件。
owner    # 解压后文件或目录的属主
group    # 解压后的目录或文件的属组


ansible test1 -m unarchive -a 'copy=no src=/tmp/jdk2.tar.gz dest=/tmp'
```

### lineinfile

常用功能：对文件的行替换、插入、删除

```bash
path/dest    # 目标文件绝对路径+文件名,必须参数
line         # 替换/插入的内容
regexp:      # 待匹配内容
insertbefore # 匹配行前面插入 
insertafter  # 匹配行面插入 
state        # 删除匹配行,需要将值设为absent,默认值present。 
backup       # 是否在修改文件之前对文件进行备份。 yes/no
create       # 当要操作的文件并不存在时，是否创建对应的文件。yes/no
backrefso
# backrefs为no时，如果没有匹配，则添加一行line。如果匹配了，则把匹配内容替被换为line内容。
# backrefs为yes时，如果没有匹配，则文件保持不变。如果匹配了，把匹配内容替被换为line内容。

```

参考：https://hellogitlab.com/CM/ansible/user.html

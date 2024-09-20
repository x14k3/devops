# Ansible 部署

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

```
[default]
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

　　‍

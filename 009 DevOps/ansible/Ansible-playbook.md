# Ansible-playbook

> Ansible playbook 使用场景:

- 执行一些简单的任务，使用ad-hoc命令可以方便的解决问题，但是有时一个设施过于复杂，需要大量的操作时候，执行的ad-hoc命令是不适合的，这时最好使用playbook。
- *就像执行shell命令与写shell脚本一样，也可以理解为批处理任务，不过playbook有自己的语法格式。*
- 使用playbook你可以方便的重用这些代码，可以移植到不同的机器上面，像函数一样，最大化的利用代码。在你使用Ansible的过程中，你也会发现，你所处理的大部分操作都是编写playbook。可以把常见的应用都编写成playbook，之后管理服务器会变得十分简单。

> 使用**ansible-playbook**运行playbook文件，得到如下输出信息，输出内容为JSON格式。并且由不同颜色组成，便于识别。一般而言

- **绿色**代表执行成功，系统保持原样
- **黄色**代表系统代表系统状态发生改变
- **红色**代表执行失败，显示错误输出。

## Playbooks 核心组件

|组件名称|说明|参数|
| ------------| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| ----|
|hosts|运行指定任务的目标主机，主机或主机组在inventory清单中指定，可以使用系统默认的/etc/ansible/hosts，也可以自己编辑，在运行的时候加上-i选项，指定清单的位置即可。在运行清单文件的时候，-list-hosts选项会显示那些主机将会参与执行task的过程中||
|remoute_user|在远程主机上执行任务的用户；在远端系统执行task的用户，可以任意指定，也可以使用sudo，但是用户必须要有执行相应task的权限||
|sudo_user|||
|tasks|任务列表；指定远端主机将要执行的一系列动作。tasks的核心为ansible的模块，前面已经提到模块的用法||
|templates|包含了模板语法的文本文件||
|vars|变量||
|handlers|由特定条件触发的任务||

## Playbook 中的变量

**变量调用方式：**

通过{{ variable_name }} 调用变量，且变量名前后建议加空格，有时用“{{ variable_name }}”才生效

**变量来源：**

1. ansible 的 setup facts 远程主机的所有变量都可直接调用
2. 通过命令行指定变量，优先级最高

   ```bash
   ansible-playbook -e varname=value
   ```
3. 在playbook文件中定义

   ```yaml
   ---
   - hosts: websrvs
     remote_user: root
     vars:
       - username: user1
       - groupname: group1

     tasks:
       - name: create group
         group: name={{ groupname }} state=present
       - name: create user
         user: name={{ username }} group={{ groupname }} state=present
   ```
4. 在独立的变量YAML文件中定义

   ```yaml
   vim vars.yml     # 独立的变量yaml
   ---
   # variables file
   var1: httpd
   var2: nginx

   vim  test1.yml    
   ---
   #install package and start service
   - hosts: test1
     remote_user: root
     vars_files:
       - /root/vars.yml

     tasks:
       - name: create httpd log
         file: name=/app/{{ var1 }}.log state=touch
       - name: create nginx log
         file: name=/app/{{ var2 }}.log state=touch

   ```
5. 在 /etc/ansible/hosts 中定义

   ```bash
   # 在inventory 主机清单文件中为指定的主机定义变量以便于在playbook中使用
   [websrvs]
   www1.magedu.com http_port=80 maxRequestsPerChild=808
   www2.magedu.com http_port=8080 maxRequestsPerChild=909

   # 组（公共）变量
   [websrvs]
   www1.magedu.com
   www2.magedu.com

   [websrvs:vars]
   ntp_server=ntp.magedu.com
   nfs_server=nfs.magedu.com
   ```
6. register变量
   register能将tasks的运行过程状态以json格式记录下来,tasks运行可能会产生error,我们在运行playbook的时候,可以根据json中的值来判断是否产生错误.
   例如我们可以根据json中的rc(return code)值来判断运行结果.

   ```bash
   ---
   - name: register接收变量演示
     hosts: all
     tasks:
       - name: shell执行hostname,并将hostname结果保存到变量名myvar
         shell: hostname
         register: myvar
       - name: 打印接收的myvar变量
         debug:
           msg: "{{ myvar }}"
           msg: "{{ myvar.stdout }}"
   ```

### 演示部署jdk+tomcat并启动

1.上传tomcat和jdk安装包至/opt
2.编写playbook剧本

```yaml
---
- name: 部署tomcat
  hosts: test1
  remote_user: root
  tasks:
    - name: 上传、解压jdk
      unarchive: copy="yes" src="/opt/jdk-8u333-linux-x64.tar.gz" dest="/usr/local"
    - name: 设置/etc/profile
      lineinfile: dest=/etc/profile line="export JAVA_HOME=/usr/local/jdk1.8.0_333\nexport JRE_HOME=$JAVA_HOME/jre\nexport CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib\nexport PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin"
    - name: 创建/data目录
      file: path="/data" state="directory"
    - name: 上传、解压tomcat至/data
      unarchive: copy="yes" src="/opt/apache-tomcat-8.5.84.tar.gz" dest="/data"
    - name: 启动tomcat
      shell: source /etc/profile; nohup /data/apache-tomcat-8.5.84/bin/startup.sh
   
```

```yaml
---
- name: 部署tomcat
  hosts: test1
  remote_user: root
  vars:
  - pkg_path: /opt/ansible-store/tomcat
  - data_path: /data
  tasks:
    - name: 上传、解压 jdk
      unarchive: copy="yes" src="{{ pkg_path }}/jdk-8u333-linux-x64.tar.gz" dest="/usr/local"
    - name: 配置 jdk 环境变量
      lineinfile: dest=/etc/profile line="export JAVA_HOME=/usr/local/jdk1.8.0_333\nexport JRE_HOME=$JAVA_HOME/jre\nexport CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib\nexport PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin"
    - name: 创建部署目录
      file: path="{{ data_path }}" state="directory"
    - name: 上传、解压 tomcat
      unarchive: copy="yes" src="{{ pkg_path }}/apache-tomcat-8.5.84.tar.gz" dest="{{ data_path }}"
    - name: 启动 tomcat
      shell: source /etc/profile; nohup "{{ data_path }}"/apache-tomcat-8.5.84/bin/startup.sh
   
```

## ansible 判断和循环

### 1. 标准循环

```yaml
# 模式1
- name: add several users
  user: name={{ item }} state=present groups=wheel
  with_items:
     - testuser1
     - testuser2  
  or  
  with_items: "{{ somelist }}"
```

```yaml
# 模式2. 字典循环
- name: add several users
  user: name={{ item.name }} state=present groups={{ item.groups }}
  with_items:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
```

### 2. 嵌套循环

```yaml
---
- name: test
  hosts: masters
  tasks:
    - name: give users access to multiple databases
      command: "echo name={{ item[0] }} priv={{ item[1] }} test={{ item[2] }}"
      with_nested:
        - [ 'alice', 'bob' ]
        - [ 'clientdb', 'employeedb', 'providerdb' ]
        - [ '1', '2', ]

**result:**
changed: [localhost] => (item=[u'alice', u'clientdb', u'1'])
changed: [localhost] => (item=[u'alice', u'clientdb', u'2'])
changed: [localhost] => (item=[u'alice', u'employeedb', u'1'])
changed: [localhost] => (item=[u'alice', u'employeedb', u'2'])
changed: [localhost] => (item=[u'alice', u'providerdb', u'1'])
changed: [localhost] => (item=[u'alice', u'providerdb', u'2'])
changed: [localhost] => (item=[u'bob', u'clientdb', u'1'])
changed: [localhost] => (item=[u'bob', u'clientdb', u'2'])
changed: [localhost] => (item=[u'bob', u'employeedb', u'1'])
changed: [localhost] => (item=[u'bob', u'employeedb', u'2'])
changed: [localhost] => (item=[u'bob', u'providerdb', u'1'])
changed: [localhost] => (item=[u'bob', u'providerdb', u'2'])
```

### 3. 文件循环(with_file, with_fileglob)

with_file 是将每个文件的文件内容作为item的值
with_fileglob 是将每个文件的全路径作为item的值, 在文件目录下是非递归的, 如果是在role里面应用改循环, 默认路径是roles/role_name/files_directory**

```yaml
- copy: src={{ item }} dest=/opt/ owner=root mode=600
    with_fileglob:
	  - /playbooks/files/fooapp/*
```

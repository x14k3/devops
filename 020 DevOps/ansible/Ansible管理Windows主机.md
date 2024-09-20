# Ansible管理Windows主机

## 1. Ansible如何管理Windows

　　Ansible能管理Linux类系统，它是Agentless的，只要在Linux端安装好Ansible，并指定连接到目标的连接类型(例如ssh)，就可以将操作指令发送到目标节点上执行。

　　但Ansible还能管理Windows系统。可使用三种方式进行管理：

* (1).Windows 10或Windows Server 2016上安装WSL(Windows Subsystem for Linux)，如果是早于该版本的Windows系统，可安装Cygwin模拟Linux环境。然后启动sshd服务，便可让Ansible进行管理
* (2).Windows上开启WinRM(Windows Remote Management)连接方式，出于安全考虑，Windows默认禁用了WinRM。只要开启了WinRM，Ansible指定WinRM连接方式便可以管理Windows
* (3).Ansible 2.8中增加了基于Win32-Openssh的ssh连接方式，目前还处于测试阶段

　　让Ansible通过WSL基于ssh连接的方式管理Windows系统是非常受限的，Windows不像Linux，Linux通过配置文件完成配置，而Windows通过注册表的方式配置程序，所以通过WSL上只能做一些基本操作，比如文件类操作。这样失去了很多Windows自身的能力，比如域、活动目录类的管理。

　　所以，需要让Ansible基于WinRM连接方式去管理Windows是比较可取的，可管理的对象、功能也更为丰富。

　　本文不会介绍如何在Windows 10/Windows Server 2016上开启WSL以及如何让Ansible通过WSL去管理Windows，本文要介绍的是基于WinRM连接方式管理Windows。

## 2. Ansible管理Windows前的设置

　　对于Ansible端来说，唯一需要做的就是安装Python的winrm包：

```bash
pip3 install "pywinrm>=0.3.0"
```

　　对于Windows端来说，要让Ansible管理Windows，要求Windows端：

* (1).PowerShell 3.0+
* (2). .NET 4.0+

　　所以，默认支持的Windows系统包括：

* (1).Windows 7 SP1, 8, 10
* (2).Windows Server 2008 SP2, 2008 R2 SP1, 2012, 2012 R2, 2016, 2019

　　如果是更古老的系统，要求额外安装PowerShell 3.0+以及.NET 4.0+。

　　另外，.NET 4.0有很多漏洞，所以要么安装更高版本的.NET，要么打补丁；PowerShell 3.0下的WinRM也有漏洞，所以要么打补丁，要么使用更高版本的PowerShell。

　　然后就可以开启WinRM了。Ansible官方提供了一个自动化配置的powershell脚本。可先以管理员身份打开PowerShell，按如下方式下载并执行powershell脚本：

```bash
$ansibleconfigurl = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$ansibleconfig = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($ansibleconfigurl, $ansibleconfig)
powershell.exe -ExecutionPolicy ByPass -File $ansibleconfig

```

　　配置好后，winrm将默认以HTTPS的方式监听在5986端口上。

```bash
> netstat -an | Select-String -Pattern '5986'

  TCP    0.0.0.0:5986           0.0.0.0:0              LISTENING
  TCP    [::]:5986              [::]:0                 LISTENING

```

　　为方便演示，这里在Windows上再创建一个新用户junmajinlong，密码为123456，并加入管理员组(Administrators)：

```bash
New-LocalUser -name "junmajinlong" `
              -Password (ConvertTo-SecureString -String '123456' -AsPlainText -Force) `
              -AccountNeverExpires -PasswordNeverExpires

Add-LocalGroupMember -Group "Administrators" -Member "junmajinlong"

```

　　配置好Windows端后，可以先测试下Ansible是否能连接到Windows。

　　如果哪里失败了，可参考官方手册：[https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html)。

## 3. 测试能否成功管理Windows

　　Ansible连接目标节点时，默认使用SSH连接，且默认使用执行Ansible操作的用户名连接目标节点。

　　对Linux来说这些都可以采用默认值，但是对Windows来说，这显然是行不通的，所以需要显式指定Ansible连接Windows时的用户名、密码、端口、winrm连接类型等。

　　例如，对于IP为192.168.200.14的Windows来说，如果用户名为junmajinlong，密码为123456，那么可以配置如下inventory信息：

```bash
[windows]
192.168.200.14 ansible_user=junmajinlong 

[windows:vars]
ansible_password="123456"
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore

```

　　关于上述Inventory配置，需要注意几点：

* (1).对于自签CA，`ansible_winrm_server_cert_validation`​必须设置为ignore
* (2).密码不应直接写在inventory中，而是采用Vault加密的方式或者使用`-k, --ask-pass`​选项由用户手动输入
* (3).如果是域用户，那么`ansible_user`​的格式为：`USERNAME@domain_name`​

　　然后找个ping模块测试是否能成功执行。

```bash
$ ansible -i win_host all -m win_ping
192.168.200.14 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

```

　　Ansible中的Windows相关模块，全部都以`win_`​开头，比如ping模块对应于`win_ping`​。在此列出了Ansible所提供的所有管理Windows的模块：[https://docs.ansible.com/ansible/latest/modules/list_of_windows_modules.html](https://docs.ansible.com/ansible/latest/modules/list_of_windows_modules.html)。

　　比如用Ansible管理Windows来创建一个本地用户并加入Administrators组：

```bash
---
- name: manage win user
  hosts: windows
  gather_facts: no
  tasks: 
    - name: create new user named "junma"
      win_user: 
        name: junma
        password: 123456
        state: present
        groups_action: add
        groups: Administrators
        password_never_expires: yes

```

## 4. Ansible执行PowerShell、CMD命令

　　执行powershell命令和cmd命令非常简单，只需使用`win_shell`​模块即可。该模块默认使用的powershell，如果要使用cmd，明确指明`executable: cmd`​即可。

　　例如：

```bash
- name: create a dir use powershell
  win_shell: New-Item -Path C:\testfile -ItemType Directory
  
- name: create a dir use cmd
  win_shell: mkdir C:\testfilecmd
    args: 
      executable: cmd

```

## 5. 创建域控制器

　　假设现在Windows Server已经开启了WinRM，目前的IP地址是192.168.200.75，使用的是默认管理员administrator。接下来将从0到1将其创建成域控制器(DC, Domain Controller)。

　　如下是dc节点的inventory配置：

```bash
[dc_controller]
192.168.200.75

[dc_controller:vars]
ansible_user=administrator
ansible_password="123456"
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore

```

　　如下是playbook文件内容，相关解释在注释中：

```bash
- name: install first domain controller
  hosts: dc_controller
  gather_facts: no
  tasks:
    # 按需修改主机名，这里改为dc1，修改主机名可能要求重启
    - name: set dc hostname 
      win_hostname:
        name: "dc1"
      register: res
    - name: Reboot
      win_reboot:
      when: res.reboot_required

	  # 等待重启完成
    - name: Wait dc to become reachable
      wait_for_connection:
        timeout: 900

    # 安装Active Direcotry相关功能
    - name: install ad
      win_feature: >
          name=AD-Domain-Services
          include_management_tools=yes
          include_sub_features=yes
          state=present
      register: result
  
    # 创建域控制器，要求重启
    # safe_mode_password参数指定域控制器的恢复密码
    - name: install domain
      win_domain: >
         dns_domain_name="junmajinlong.com"
         safe_mode_password='P@ssword1!'
      register: ad
    - name: reboot server
      win_reboot:
       msg: "Installing AD. Rebooting..."
       pre_reboot_delay: 3
      when: ad.changed

    # 等待重启结束后重连
    - name: Wait dc to become reachable
      wait_for_connection:
        timeout: 900
      
    # 设置域控制器的DNS指向自己
    - name: set dc dns pointer to self
      win_dns_client:
        adapter_names: "*"
        ipv4_addresses: 
          - "{{inventory_hostname}}"

```

　　执行完上面的playbook后，将创建一个`junmajinlong.com`​的域环境。

　　另外，上面示例中是将所有属性直接硬编码在playbook中，合理的做法应该是将其定义为inventory变量或普通变量，然后在playbook中引用。

## 6. 将主机加入域

　　比如将本文之前操作过的192.168.200.14这个Win10主机加入域环境。

　　inventory部分如下：

```bash
[windows]
192.168.200.14 ansible_user=junmajinlong

[windows:vars]
ansible_password='123456'
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore

```

　　要将一个节点加入域，需要修改其DNS指向域控制器。

　　playbook内容如下：

```bash
- name: add win 10 to domain junmajinlong.com
  hosts: windows
  gather_facts: no
  tasks: 
    - name: configure DNS pointer to Domain Controller
      win_dns_client: 
        adapter_names: "*"
        ipv4_addresses: 
          - 192.168.200.75

    - name: set dc hostname 
      win_hostname:
        name: "win10"
      register: res
    - name: Reboot
      win_reboot:
      when: res.reboot_required
  
    - name: join to domain
      win_domain_membership:
        dns_domain_name: junmajinlong.com
        domain_admin_user: administrator@junmajinlong.com
        domain_admin_password: 123456
        state: domain
      register: domain_state
    
    - name: Reboot after joining
      win_reboot:
        msg: "Joining Domain.Rebooting..."
        pre_reboot_delay: 3
      when: domain_state.reboot_required

```

　　关于Ansible管理Windows就介绍这么多，个人用的较少，而且个人觉得Ansible管理Windows更多的时候需要借助于PowerShell命令或PowerShell脚本。

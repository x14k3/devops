# Firewalld

从CentOS7(RHEL7)开始，官方的标准防火墙设置软件从iptables变更为firewalld，相信不少习惯使用iptables的人会感到十分不习惯，但实际上firewalld更为简单易用。

大致用法就是：

把==可信任==的IP地址添加到  *trusted*  区域。

把==不可信任==的IP地址添加到  *block*  区域。

把==公开==的网络服务添加到   *public*  区域。

## 防火墙基本使用

```bash
yum  -y  install      firewalld              # 安装firewalld
systemctl  start      firewalld              # 打开防火墙,或systemctl start firewalld.service

firewall-cmd --version         # 查看版本
firewall-cmd --help             # 查看帮助
firewall-cmd --state            # 显示状态
firewall-cmd --get-active-zones # 查看区域信息
firewall-cmd --get-service   # 获取所有支持的服务
firewall-cmd --get-zone-of-interface=eth0  # 查看指定接口所属区域
firewall-cmd --panic-on       # 拒绝所有包
firewall-cmd --panic-off       # 取消拒绝状态
firewall-cmd --query-panic  # 查看是否拒绝
firewall-cmd --reload      #更新防火墙规则，修改防火墙规则后，需要重新载入
```

## 区域zone

所谓的区域就是一个信赖等级，某一等级下对应有一套规则集。划分方法包括：网络接口、IP地址、端口号等等。一般情况下，会有如下的这些默认区域,由firewalld 提供的区域按照从不信任到信任的顺序排序:

- **丢弃-drop**
  任何流入网络的包都被丢弃，不作出任何响应。只允许流出的网络连接。
  出站链接：允许
  入站链接：丢弃
- **阻塞-block**
  任何进入的网络连接都被拒绝，只允许由该系统初始化的网络连接。
  出站链接：允许
  入站链接：拒绝，并发送icmp-host-prohibited消息
- **公开-public**
  用以可以公开的部分。只允许选中的连接接入。
  出站链接：允许
  入站链接：允许DHCPv6客户端和SSH
- **外部-external**
  用在路由器等启用伪装的外部网络。只允许选中的连接接入。
  出站链接：允许，并伪装成出站网络接口的IP地址
  入站链接：允许SSH
- **隔离区-dmz**
  用以允许隔离区（dmz）中的电脑有限地被外界网络访问。只接受被选中的连接。
  出站链接：允许
  入站链接：允许SSH
- **工作-work**
  用在工作网络,只接受被选中的连接。
  出站链接：允许
  入站链接：允许DHCPv6客户端、IPP和SSH
- **家庭-home**
  用在家庭网络,只接受被选中的连接。
  出站链接：允许
  入站链接：允许DHCPv6客户端、多播DNS、IPP、samba客户端和SSH
- **内部-internal**
  用在内部网络,只接受被选中的连接。
  出站链接：允许
  入站链接：与home区域相同
- **受信任的-trusted**
  允许所有网络连接。
  出站链接：允许
  入站链接：允许

## firewalld 应用

### 1. 开放端口

```bash

firewall-cmd --permanent --zone=public --add-port=2202/tcp        # 永久打开tcp 80端口
firewall-cmd --permanent --zone=public --add-port=2202/udp      # 永久打开udp 123端口
firewall-cmd --permanent --zone=public --remove-port=2202/tcp  # 删除打开的端口
firewall-cmd --permanent --zone=public --add-service=https          # 永久打开https服务的端口
firewall-cmd --permanent --zone=public --add-port=8080-8083/tcp   # 添加多个端口
#–add-service            #添加的服务  
#–zone                      #作用域  
#–add-port=80/tcp   #添加端口，格式为：端口/通讯协议  
#–permanent            #永久生效，没有此参数重启后失效

firewall-cmd  --zone=public --list-ports               # 查看所有打开的端口
firewall-cmd  --zone=public --list-services           # 查看所有打开的服务，也可加--permanent
firewall-cmd  --get-services                                 # 查看还有哪些服务可以打开
##防火墙预定义的服务配置文件是xml文件，目录在 /usr/lib/firewalld/services/，每个服务对应一个端口
```

### 2.端口转发

```bash

firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080   # 将80端口的流量转发至8080
firewall-cmd --permanent --add-forward-port=proto=80:proto=tcp:toaddr=192.168.1.0.1 # 将80端口的流量转发至192.168.0.1
firewall-cmd --permanent  --add-forward-port=proto=80:proto=tcp:toaddr=192.168.0.1:toport=8080 # 将80端口的流量转发至192.168.0.1的8080端口
```

### 3.ip限制

```bash
# 针对某个 IP开放端口
firewall-cmd  --permanent --add-rich-rule="rule family="ipv4" source address="192.168.0.1" accept" 
firewall-cmd  --permanent --add-rich-rule="rule family="ipv4" source address="192.168.0.1" port protocol="tcp" port="6379" accept"

# 删除规则
firewall-cmd  --permanent --remove-rich-rule="rule family="ipv4" source address="192.168.1.51" accept" 

### 针对一个ip段访问
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="192.168.0.0/16" accept"
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="9200" accept"
```

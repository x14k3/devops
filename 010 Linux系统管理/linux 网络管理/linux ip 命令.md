# linux ip 命令

## ip 命令的语法

　　​`ip [OPTIONS] OBJECT [COMMAND [ARGUMENTS]]`​

* **OPTIONS**

  是一些修改 ip 行为或者改变其输出的选项，所有的选项都是以 - 字符开头，分为长、短两种形式:

  ```bash
  -V：显示指令版本信息；
  -s：-stats, -statistics输出更详细的信息；可以使用多个-s来显示更多的信息
  -f：-family {inet, inet6, link} 强制使用指定的协议族；
  -4：-family inet的简写，指定使用的网络层协议是IPv4协议；
  -6：-family inet6的简写，指定使用的网络层协议是IPv6协议；
  -0：shortcut for -family link.
  -o：-oneline，输出信息每条记录输出一行，即使内容较多也不换行显示；
  -r：-resolve，显示主机时，不使用IP地址，而使用主机的域名。

  #--------------------------------------------------
  ip -c  link     彩色
  ip -br link     概述
  ip -o  link     一行显示
  ip -d  link     详细
  ip -s  addr     摘要
  ```

* **OBJECT**

  是你要管理或者获取信息的对象。ip 认识的对象包括:

  ```bash
  link       # 网络设备
  address    # 一个设备的协议（IP或者IPV6）地址
  route      # 路由表条目
  rule       # 路由策略数据库中的规则
  neighbour  # ARP或者NDISC缓冲区条目
  tuntap
  #另外，所有的对象名都可以简写，例如：address可以简写为addr，甚至是a。
  ```

* **COMMAND[ARGUMENTS]**   

  设置针对指定对象执行的操作
  一般情况下，ip 支持对象的增加（add）、删除（delete）和展示（show或者list）。

* **ARGUMENTS** 
  是命令的一些参数，它们倚赖于对象和命令。
  ip 支持两种类型的参数：flag 和 parameter。flag 由一个关键词组成；parameter 由一个关键词加一个数值组成。

　　‍

* 📄 ip address
* 📄 ip link
* 📄 ip neighbour
* 📄 ip route
* 📄 ip rule
* 📄 ip tuntap

　　‍

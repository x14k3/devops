# fail2ban

随着云计算的普及，很多人都会在各大云服务商购买云服务器，只要有互联网就可以登录云服务器。但云服务器直接暴露到互联网上，始终存在被黑客攻击入侵的风险，虽然有安全组功能可以做访问限制，但是对于 Linux 服务器的 SSH 远程登录端口 (默认 22)，很多时候客户端的公网出口 IP 是动态变化的，无法进行安全组规则的收敛。为了降低被暴力破解的风险，本文以 CentOS7 为例，介绍如何使用 fail2ban 防范 SSH 暴力破解攻击。

---

fail2ban 是一款利用 Python 开发的工具，通过扫描 `/var/log/auth.log`​ 等日志文件并自动封禁进行过多次失败登录尝试的 IP 地址，它通过更新系统防火墙来实现这一点。fail2ban 可以读取许多标准日志文件，例如 SSH 和 Apache 的日志文件，并且可以根据需要配置读取任何你指定的日志文件。

- 项目地址：[https://github.com/fail2ban/fail2ban](https://github.com/fail2ban/fail2ban)
- 安装文档：[https://github.com/fail2ban/fail2ban/wiki/How-to-install-fail2ban-packages](https://github.com/fail2ban/fail2ban/wiki/How-to-install-fail2ban-packages)

## 安装并配置 fail2ban

## 源码安装 (推荐)

### 下载 fail2ban

在 [https://github.com/fail2ban/fail2ban/releases](https://github.com/fail2ban/fail2ban/releases) 下载 fail2ban 的源码包 `Source code(tar.gz)`​

### 安装 fail2ban

解压并安装 fail2ban

```bash
tar zxf fail2ban-1.0.2.tar.gz
cd fail2ban-1.0.2
python setup.py  install

```

将 fail2ban 服务添加到 Systemd 管理

```bash
cp -a build/fail2ban.service /usr/lib/systemd/system/
systemctl daemon-reload

```

启动 fail2ban，设置开机自启动

```bash
systemctl start fail2ban
systemctl enable fail2ban
systemctl status fail2ban

```

### 配置 fail2ban

根据 [fail2ban 官网 wiki](https://github.com/fail2ban/fail2ban/wiki/Proper-fail2ban-configuration) 建议，在配置 fail2ban 的时候应该避免直接更改由 fail2ban 安装创建的`.conf`​ 文件（例如 `fail2ban.conf`​ 和 `jail.conf`​），相反，应该创建扩展名为`.local`​ 的新文件（例如 `jail.local`​）来进行自定义配置。`.local`​ 文件将覆盖`.conf`​ 文件相同部分的参数

创建 `/etc/fail2ban/jail.local`​ 文件

```bash
touch /etc/fail2ban/jail.local

```

编辑 `/etc/fail2ban/jail.local`​ 文件，添加如下内容：

```bash
[DEFAULT]
ignoreip = 127.0.0.1/8
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/secure
bantime  = 1mon
findtime  = 5m
maxretry = 3
action = hostsdeny

```

> **参数说明**
> **ignoreip：** 配置忽略检测的 IP (段)，如有多个用空格隔开
> **enabled：** 配置是否启用此 section 的的扫描监控
> **port：** 配置服务端口，如果 SSH 使用非默认端口 22，要修改为实际使用端口
> **filter：** 配置使用的匹配规则文件（位于 `/etc/fail2ban/filter.d`​ 目录中）
> **logpath：** 配置要扫描的日志文件路径
> **bantime：** 配置 IP 封禁的持续时间（秒或时间缩写格式:years/months/weeks/days/hours/minutes/seconds）
> **findtime：** 配置从当前时间的多久之前开始计算失败次数（秒或时间缩写格式:years/months/weeks/days/hours/minutes/seconds）
> **maxretry：** 配置在 findtime 时间内发生多少次失败登录然后将 IP 封禁。
> **action：** 配置封禁 IP 的手段（位于 `/etc/fail2ban/action.d`​ 目录中），可通过 `iptables`​、`firewalld`​ 或者 `TCP Wrapper`​ 等，此处设置为 `hostsdeny`​ 代表使用 `TCP Wrapper`​

重启 fail2ban 使配置生效

```bash
systemctl restart fail2ban
systemctl status fail2ban

```

## Yum 安装

> **说明**
> 我使用 Yum 安装的 fail2ban 不支持通过 `TCP Wrapper`​ 的方式进行拦截，只能通过 `iptables`​ 或者 `firewalld`​，一直没找到解决方法，如果有人知道原因的欢迎评论区指导下 Koen 呀～

### 确认 firewalld 服务已启动

```bash
# 查看是否启动
systemctl status firewalld
# 若未启动执行以下命令启动
systemctl start firewalld
systemctl enable firewalld

```

### 安装 fail2ban

安装 EPEL repository

```bash
yum install epel-release -y
```

安装并启动 fail2ban，设置开机自启动

```bash
yum install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban
systemctl status fail2ban

```

### 配置 fail2ban

根据 [fail2ban 官网 wiki](https://github.com/fail2ban/fail2ban/wiki/Proper-fail2ban-configuration) 建议，在配置 fail2ban 的时候应该避免直接更改由 fail2ban 安装创建的`.conf`​ 文件（例如 `fail2ban.conf`​ 和 `jail.conf`​），相反，应该创建扩展名为`.local`​ 的新文件（例如 `jail.local`​）来进行自定义配置。`.local`​ 文件将覆盖`.conf`​ 文件相同部分的参数

创建 `/etc/fail2ban/jail.local`​ 文件

```bash
touch /etc/fail2ban/jail.local
```

编辑 `/etc/fail2ban/jail.local`​ 文件，添加如下内容：

```bash

[DEFAULT]
ignoreip = 127.0.0.1/8
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/secure
bantime  = 1mon
findtime  = 5m
maxretry = 3
```

> **参数说明**
> **ignoreip：** 配置忽略检测的 IP (段)，如有多个用空格隔开
> **enabled：** 配置是否启用此 section 的的扫描监控
> **port：** 配置服务端口，如果 SSH 使用非默认端口 22，要修改为实际使用端口
> **filter：** 配置使用的匹配规则文件（位于 `/etc/fail2ban/filter.d`​ 目录中）
> **logpath：** 配置要扫描的日志文件路径
> **bantime：** 配置 IP 封禁的持续时间（秒或时间缩写格式:years/months/weeks/days/hours/minutes/seconds）
> **findtime：** 配置从当前时间的多久之前开始计算失败次数（秒或时间缩写格式:years/months/weeks/days/hours/minutes/seconds）
> **maxretry：** 配置在 findtime 时间内发生多少次失败登录然后将 IP 封禁。

重启 fail2ban 使配置生效

```bash
systemctl restart fail2ban
systemctl status fail2ban

```

## 验证

通过 SSH 登录，然后故意输错三次密码，然后查看 fail2ban 日志

```bash

# tail -f /var/log/fail2ban.log
2023-10-13 17:05:02,370 fail2ban.filter         [29824]: INFO    [sshd] Found 36.250.4.182 - 2023-10-13 17:05:02
2023-10-13 17:05:04,739 fail2ban.filter         [29824]: INFO    [sshd] Found 36.250.4.182 - 2023-10-13 17:05:04
2023-10-13 17:05:08,415 fail2ban.filter         [29824]: INFO    [sshd] Found 36.250.4.182 - 2023-10-13 17:05:08
2023-10-13 17:05:08,415 fail2ban.actions        [29824]: NOTICE  [sshd] Ban 36.250.4.182
```

日志显示 `36.250.4.182`​ 存在三次失败登录，该 IP 已被封禁，具体可以通过执行 `fail2ban-client status sshd`​ 查看 `Banned IP list`​ 确认

```bash
# fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     6
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 5
   |- Total banned:     5
   `- Banned IP list:   178.128.191.224 36.250.4.182 173.212.197.129 143.110.189.9 45.79.248.160

```

> 说明
> 如果 `fail2ban`​ 是配置通过 `firewalld`​ 防火墙策略实施封禁，可查看防火墙策略再次确认是否生效
>
> ```bash
> # firewall-cmd --list-all
> ......
> rich rules: 
>        rule family="ipv4" source address="36.250.4.182" port port="10022" protocol="tcp" reject type="icmp-port-unreachable"
>
> ```
>
> 如果 `fail2ban`​ 是配置通过 `TCP Wrapper`​ 实施封禁，可查看 `/etc/hosts.deny`​ 文件再次确认是否生效

## 解封 IP

如果发现有 IP 被 fail2ban 误封了，或者确认登录 IP 是安全的，可以通过以下命令进行手动解封

```bash
# 解封所有IP
fail2ban-client unban --all
# 解封指定IP
# fail2ban-client unban <IP> ... <IP>
fail2ban-client unban 36.250.4.182

```

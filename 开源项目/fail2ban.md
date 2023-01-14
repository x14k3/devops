#openSource

fail2ban用于监视系统日志，通过正则表达式匹配错误错误信息，设置一定的条件触发相应的屏蔽动作。

下载地址：https://www.fail2ban.org/wiki/index.php/Downloads

### fail2ban 部署

```bash
# 安装依赖
yum install python
# 安装
cd ~/fail2ban-0.9.4/
python setup.py install

# 启动
cd ~/fail2ban-0.9.4/files
# 修改服务路径，/usr/bin/fail2ban-xxx 为 /usr/local/bin/fail2ban-xxx
vim  fail2ban.service
cp fail2ban.service /usr/lib/systemd/system/
systemctl daemon-reload

# 解除个别ip
fail2ban-client set sshd unbanip 222.128.103.170
```


### 配置文件说明

 配置文件位于：
```bash
- /etc/fail2ban/action.d          # 采取相对应措施的目录
- /etc/fail2ban/fail2ban.conf  # fail2ban的配置文件
- /etc/fail2ban/fail2ban.d       # fail2ban的配置文件目录
- /etc/fail2ban/filter.d            # 具体过滤规则文件目录
- /etc/fail2ban/jail.conf         # 阻挡设定文件
- /etc/fail2ban/jail.d              # 阻挡设定文件的目录
- /etc/fail2ban/paths-*.conf  # 不同linux发行版下路径的相关设置，在jail.conf的[INCLUDES]里指定

vim /etc/fail2ban/jail.local
--------------------------------------------
ignoreip    # 这是一个空格分隔的IP地址列表，白名单
bantime    # 被fail2ban 后的拉黑时间，单位秒
maxretry   # 被fail2ban之前失败的登录尝试次数
filter         # 指在 /etc/fail2ban/filter.d 中的相应过滤器文件
logpath    # fail2ban 监控的日志文件
--------------------------------------------------
```


### 自定义过滤拦截

创建nginx-ssh规则文件



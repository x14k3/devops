# systemd 开机自启动任务

如果要让任务开机自启动，需将对应的Unit文件存放于/etc/systemd/system下。本文以Service Unit为例，但也支持让path Unit、timer Unit等类型的任务开机自启动。

## systemd中服务开机自启动

用户可以手动将服务配置文件存放至此路径，但更建议采用systemd系统提供的上层工具systemctl来操作。

```bash
# 将服务加入开机自启动
systemctl enable Service_Name
# 禁止服务开机自启动
systemctl disable Service_Name
# 查看服务是否开机自启动
systemctl is-enabled Service_Name
# 查看所有开机自启动服务
systemctl list-unit-files --type service | grep 'enabled'
```

使用systemctl命令时，可以指定服务名称，也可以指定服务对应的服务配置unit文件。

例如下面两条命令是等价的。

```bash
systemctl enable sshd          # 服务名
systemctl enable sshd.service  # 服务对应的unit文件
```

systemctl的很多操作都具备幂等性，这意味着如果要操作的服务已经处于目标状态，则什么都不会做。

比如systemctl启动服务sshd，但如果sshd服务已经处于目标状态：已启动，则本次启动什么操作也不做，systemctl会直接退出。再比如上面将sshd加入开机自启动的操作，sshd服务在安装openssh-server的时候就已经自动加入了开机自启动，用户再手动加入开机自启动，实际上什么也不会做。

如果是未开机自启动的服务加入开机自启动呢？比如，拷贝sshd服务的配置文件，并将拷贝后的服务sshd1加入开机自启动：

```bash
$ cp /usr/lib/systemd/system/{sshd,sshd1}.service

$ systemctl enable sshd1
Created symlink from /etc/systemd/system/multi-user.target.wants/sshd1.service to /usr/lib/systemd/system/sshd1.service.

```

从结果可看到，systemctl将服务加入开机自启动的操作，实际上是在/etc/systemd/system某个target.wants目录下创建服务配置文件的软链接文件。

```bash
$ readlink /etc/systemd/system/multi-user.target.wants/sshd1.service 
/usr/lib/systemd/system/sshd1.service

```

显然，禁用服务开机自启动的操作是移除软链接。

```bash
$ systemctl disable sshd1
Removed symlink /etc/systemd/system/multi-user.target.wants/sshd1.service.

```

最后，如果服务已经加入开机自启动，但想要再次加入(比如更新了/usr/lib/systemd/system下的服务配置文件)，可在enable时加上–force选项：

```bash
systemctl --force enable Service_Name

```

## systemd中自定义开机自启动命令/脚本

* 在SysV系统中，可以将命令或脚本的命令行写入／etc／rc.local。
* 在systemd中，要么将其编写成一个开机自启动服务，要么通过systemd兼容的／etc／rc.local。

但更建议的方案是编写开机自启动服务，后面会专门介绍服务管理配置文件如何编写。

下面是一个简单的让命令(脚本)开机自启动的配置文件：

```bash
$ cat /usr/lib/systemd/system/mycmd.service
[Unit]
Description = some shell script
# 要求脚本具有可执行权限
ConditionFileIsExecutable=/usr/bin/some.sh

# 指定要运行的命令、脚本
[Service]
ExecStart = /usr/bin/some.sh

# 下面这段不能少
[Install]
WantedBy = multi-user.target

$ systemctl daemon-reload
$ systemctl enable mycmd.service

```

如果要使用/etc/rc.local的方式呢？systemd提供了rc-local.service服务来加载/etc/rc.d/rc.local文件中的命令。

```bash
$ cat /usr/lib/systemd/system/rc-local.service 
# This unit gets pulled automatically into multi-user.target by
# systemd-rc-local-generator if /etc/rc.d/rc.local is executable.
[Unit]
Description=/etc/rc.d/rc.local Compatibility
ConditionFileIsExecutable=/etc/rc.d/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.d/rc.local start
TimeoutSec=0
RemainAfterExit=yes

```

这个文件缺少了`[Install]`​段且没有WantedBy，后面将会解释Install中的WantedBy表示设置该服务开机自启动时，该服务加入到哪个『运行级别』中启动。

但这个文件的注释中说明了，如果/etc/rc.d/rc.local文件存在且具有可执行权限，则systemd-rc-local-generator将会自动添加到multi-user.target中，所以，即使没有Install和WantedBy也无关紧要。

另一方面需要注意，和SysV系统在系统启动的最后阶段运行rc.local不太一样，systemd兼容的rc.local是在network.target即网络相关服务启动完成之后就启动的，这意味着rc.local可能在开机启动过程中较早的阶段就开始运行。

如果想要将命令加入到/etc/rc.local中实现开机自启动，直接写入该文件，并设置该文件可执行权限即可。

例如：

```bash
echo -e '#!/bin/bash\ndate +"%F %T" >/tmp/a.log' >>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

```

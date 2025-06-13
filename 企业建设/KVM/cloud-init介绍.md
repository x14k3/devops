# cloud-init介绍 

目前大部分公有云（openstack, AWS, Aliyun）都在使用cloud-init,  已经成为虚拟机元数据管理和OS系统配置初始化的事实标准.最早cloud-init由ubuntu的母公司 Canonical  开发。主要思想是当用户首次创建虚拟机时，将前台设置的主机名，密码或者秘钥等存入metadata  server(顾名思义，存放元数据的服务器）。在openstack环境下当cloud-init随虚拟机启动而运行时，通过http协议访问metadata  server，获取这些信息并修改主机配置。完成系统的环境初始化。本文以openstack + centos7 + cloud-init  0.7.9 为例,分两篇介绍基本概念，工作原理和源码解读。

如下是一些cloud-init的关键信息：  
源码： [https://github.com/cloud-init/cloud-init](https://github.com/cloud-init/cloud-init)  
文档： [https://cloudinit.readthedocs.io/en/latest/](https://cloudinit.readthedocs.io/en/latest/)  
配置文件： /etc/cloud/cloud.cfg  
日志：/var/log/cloud-init.log  
存放关键数据的目录： /var/lib/cloud/

## 基本概念和相关文件目录 [#](https://xixiliguo.github.io/linux/cloud-init.html#基本概念和相关文件目录)

### datasources [#](https://xixiliguo.github.io/linux/cloud-init.html#datasources)

cloud-init将openstack, AWS, Aliyun等众多云平台抽象成数据源，使用统一的接口适配所有平台。  
具体地，openstack下获取数据的方法是访问http://169.254.169.254 下的 userdata和metadata

### userdata [#](https://xixiliguo.github.io/linux/cloud-init.html#userdata)

可以是文件，shell脚本或者cloud-init配置文件。租户可以在前台输入。  
具体的格式,请参考  
[https://cloudinit.readthedocs.io/en/latest/topics/format.html](https://cloudinit.readthedocs.io/en/latest/topics/format.html)  
如下是一个shell脚本的userdata, openstack下用它来初始化root用户的密码

```bash
[root@ecs-test-wangbo log]# curl http://169.254.169.254/openstack/2015-10-15/user_data
#!/bin/bash
echo 'root:$6$O9wyDQ$LYGAz6V/dy66Ve8eJkeATAbXOwjkWGpLbr4QoxkH8iQ0nsLa7.n3lzSlOer7Okb2RD8FObkP3RRPHEKS2xGip0' | chpasswd -e;

```

### metadata [#](https://xixiliguo.github.io/linux/cloud-init.html#metadata)

包含主机名，实例id和其他服务器相关的信息

```bash
[root@ecs-test-wangbo log]# curl http://169.254.169.254/openstack/2015-10-15/meta_data.json | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1297  100  1297    0     0   2452      0 --:--:-- --:--:-- --:--:--  2456
{
    "availability_zone": "cn-east-2a",
    "hostname": "ecs-test-wangbo.novalocal",
    "launch_index": 0,
    "meta": {
        "charging_mode": "0",
        "image_name": "CentOS 7.3 64bit",
        "metering.cloudServiceType": "hws.service.type.ec2",
        "metering.image_id": "643d831d-a69c-433f-803f-065e0e2e2911",
        "metering.imagetype": "gold",
        "metering.resourcespeccode": "c1.medium.linux",
        "metering.resourcetype": "1",
        "os_bit": "64",
        "os_type": "Linux",
        "vpc_id": "8428b86b-7ec1-4b31-97aa-d6a0db2c3aab"
    },
    "name": "ecs-test-wangbo",
    "project_id": "9b4e13cdeb7c4c6ebb929a4a503e51a2",
    "random_seed": "zUPkPLRFdLufLlYMnqQcrcp/nob7nJecOH/Nsv+hjDcNz1oYLvW/6qHgbL/++Kqvt0DLbkgpxRCO+lnqZfdOMadnZUHabdzB5LjEqOBFnk22RewmAh2sITOD1QPqmsvEssAOlz39FrUtK7+0XHIFclwYZIk8XtXPQa9L1lM9v76Y3+cZI18m1V0E+He1qLQzfyfu4qYYc8ER4YcGS2T2L/cZIRT9o20vwrLO7Ut2d98uitHhUphfVMVANG2DkZDK3U4DgR4M8q7jFMl5a3oR370XVYS7XqAn8YopCFXH1wAKCzipbzVL+JXiq9W6xFNvDvnK+bKdMVHf7ge+zUmRG6LnPpBqFLUT03qyhrErTLrV6mjpw3u4+uAX/Okn8NoWB0eEqly/VSgR3eAF4v/Ga2GylUSRCXcHH5Ss0RvbcXmF0NeGcMKH1QueBd9wBRxygBJsXZS0ZKfd+T13cA22TwqWLw4UFj3gu08/NE51A9sZu9quM6HL+XWOdqcOtN1T3aJVp6w2uisAfJCNEVq7Ftr2k0SsJdVHWw6dseDc3kOCC0Q+JPZh8deGF28/v+dykZH7yyHhFZCQZqHGarrd+QPwTzc3mdzzV/BL+GeNbYXKQXf6Uibv5s9usI6QwF+sfOg6AKtyUICWTDGgKRL1FUaDR3zF4sGIftO0AZ49vhI=",
    "uuid": "e9f15094-8157-4c78-96a1-674cbaf26baf"
}

```

### stage [#](https://xixiliguo.github.io/linux/cloud-init.html#stage)

cloud-init对系统的配置分为四个阶段， 内部叫stage。 分别是local, network,config, final

### modules [#](https://xixiliguo.github.io/linux/cloud-init.html#modules)

具体的定制化配置是由模块完成。每个模块根据获取的元数据和配置文件完成相关配置  
cloud.cfg里的部分配置：

```bash
cloud_init_modules:  // 定义init阶段需要执行的模块
 - migrator          // 迁移老的cloud-init数据为新的
 - bootcmd           // 启动时执行相关命令 
 - write-files       // 根据cloud.cfg的配置写数据到文件里
 - growpart          // 扩展分区到硬盘的大小 ，默认对根分区执行。 它需要调用“growpart”或者”gpart“
 - resizefs          // resize文件系统，适配新的大小。 默认对根目录执行
 - set_hostname      // 根据元数据设置主机名
 - update_hostname   // 更新主机名，适用于当用户自定义主机名时
 - update_etc_hosts  
 - rsyslog
 - users-groups      // 根据cloud.cfg的配置创建用户组和用户
 - ssh               // 配置sshd

```

### handlers [#](https://xixiliguo.github.io/linux/cloud-init.html#handlers)

用于具体处理userdata.目前有四类默认的handler： boot hook， cloud config ，shell script， upstart job

### frequencies [#](https://xixiliguo.github.io/linux/cloud-init.html#frequencies)

handler/module的运行频率， 目前有三个有效值:  
once-per-instance  
always  
once

### /var/lib/cloud/目录解读 [#](https://xixiliguo.github.io/linux/cloud-init.html#var-lib-cloud-目录解读)

该目录主要保存元数据和其他一些运行时需要的信息

/var/lib/cloud/data 文件夹存放具体的数据源，主机名和实例ID  
result.json 记录了一些数据源信息  
status.json 记录了每个stage运行的开始时间，结束时间和遇到的error

```bash
/var/lib/cloud/data
├── instance-id
├── previous-datasource
├── previous-hostname
├── previous-instance-id
├── result.json
└── status.json

```

/var/lib/cloud/instance 存放元数据和其他一些缓存文件

```bash
/var/lib/cloud/instance
├── boot-finished         // 记录cloud-ini运行完的时间
├── cloud-config.txt
├── datasource      
├── handlers
├── obj.pkl              // 缓存文件
├── scripts
│   └── part-001         // userdata为shell脚本，解析后归档到此
├── sem                  // 该目录用来存放各模块执行时的锁文件
├── user-data.txt        // 从数据源获取的user-data
├── user-data.txt.i
├── vendor-data.txt
└── vendor-data.txt.i

```

## 工作原理 [#](https://xixiliguo.github.io/linux/cloud-init.html#工作原理)

前面提到cloudinit分四个阶段执行，具体它们以服务的形式注册到系统中按如下顺序依次运行:  
 local - cloud-init-local.service  
 nework - cloud-init.service  
 config - cloud-config.service  
 final - cloud-final.service  
每个具体的服务中对应的命令如下，都只运行一次，没有常驻进程  
可以看到执行的都是 /usr/bin/cloud-init这个文件，但参数不一样  
所有debug日志全部默认输出到/var/log/cloud-init.log

```bash
[root@ecs-test-wangbo ~]# grep ExecStart /lib/systemd/system/cloud-*.service
/lib/systemd/system/cloud-config.service:ExecStart=/usr/bin/cloud-init modules --mode=config
/lib/systemd/system/cloud-final.service:ExecStart=/usr/bin/cloud-init modules --mode=final
/lib/systemd/system/cloud-init-local.service:ExecStart=/usr/bin/cloud-init init --local
/lib/systemd/system/cloud-init-local.service:ExecStart=/bin/touch /run/cloud-init/network-config-ready
/lib/systemd/system/cloud-init.service:ExecStart=/usr/bin/cloud-init init
[root@ecs-test-wangbo ~]# 

[root@ecs-test-wangbo ~]# grep "Cloud-init v. 0.7.9 running" /var/log/cloud-init.log 
2017-10-18 09:57:50,309 - util.py[DEBUG]: Cloud-init v. 0.7.9 running 'init-local' at Wed, 18 Oct 2017 01:57:50 +0000. Up 9.28 seconds.
2017-10-18 09:57:56,036 - util.py[DEBUG]: Cloud-init v. 0.7.9 running 'init' at Wed, 18 Oct 2017 01:57:56 +0000. Up 15.03 seconds.
2017-10-18 09:58:43,771 - util.py[DEBUG]: Cloud-init v. 0.7.9 running 'modules:config' at Wed, 18 Oct 2017 01:58:43 +0000. Up 62.72 seconds.
2017-10-18 09:58:44,165 - util.py[DEBUG]: Cloud-init v. 0.7.9 running 'modules:final' at Wed, 18 Oct 2017 01:58:44 +0000. Up 63.11 seconds.
[root@ecs-test-wangbo ~]# 

```

### local 阶段 [#](https://xixiliguo.github.io/linux/cloud-init.html#local-阶段)

此时  instance 尝试从ConfigDrive等本地源获取信息。在openstack环境下是不存在的，然后cloud-init  检查系统是否有默认网卡，有则配置为dhcp, 并写入 /etc/sysconfig/network-scripts/ifcfg-eth0.  只有配置了dhcp, 该网卡有了ip, 才能进一步连接metadataserver获取元数据 因为使用了dhcp, 所有也会从dhcp  server获取dns配置并写入/etc/resolv.conf。 这个和vpc里配置的dns服务器是一致的。

```bash
2017-10-18 09:57:50,500 - main.py[DEBUG]: No local datasource found
2017-10-18 09:57:50,500 - util.py[DEBUG]: Reading from /sys/class/net/eth0/carrier (quiet=False)
2017-10-18 09:57:50,500 - util.py[DEBUG]: Reading from /sys/class/net/eth0/dormant (quiet=False)
2017-10-18 09:57:50,500 - util.py[DEBUG]: Reading from /sys/class/net/eth0/operstate (quiet=False)
2017-10-18 09:57:50,500 - util.py[DEBUG]: Read 5 bytes from /sys/class/net/eth0/operstate
2017-10-18 09:57:50,500 - util.py[DEBUG]: Reading from /sys/class/net/eth0/address (quiet=False)
2017-10-18 09:57:50,501 - util.py[DEBUG]: Read 18 bytes from /sys/class/net/eth0/address
2017-10-18 09:57:50,501 - stages.py[DEBUG]: applying net config names for {'version': 1, 'config': [{'subnets': [{'type': 'dhcp'}], 'type': 'physical', 'name': 'eth0', 'mac_address': 'fa:16:3e:b0:e3:5d'}]}

```

### network 阶段 [#](https://xixiliguo.github.io/linux/cloud-init.html#network-阶段)

此时 instance 已经有自己的ip, 然后搜索所有网路源如下

```bash
2017-10-18 09:57:56,102 - __init__.py[DEBUG]: Searching for network data source in: [u'DataSourceNoCloudNet', u'DataSourceAzureNet', u'DataSourceAltCloud', u'DataSourceOVFNet', u'DataSourceMAAS', u'DataSourceGCE', u'DataSourceOpenStack', u'DataSourceEc2', u'DataSourceCloudStack', u'DataSourceBigstep', u'DataSourceNone']

```

最终通过访问 169.254.169.254成功获取openstack下的数据,

```bash
2017-10-18 09:58:31,288 - __init__.py[DEBUG]: Seeing if we can get any data from <class 'cloudinit.sources.DataSourceOpenStack.DataSourceOpenStack'>
2017-10-18 09:58:31,289 - url_helper.py[DEBUG]: [0/1] open 'http://169.254.169.254/openstack' with {'url': 'http://169.254.169.254/openstack', 'headers': {'User-Agent': 'Cloud-Init/0.7.9'}, 'allow_redirects': True, 'method': 'GET', 'timeout': 10.0} configuration
2017-10-18 09:58:31,952 - url_helper.py[DEBUG]: Read from http://169.254.169.254/openstack (200, 50b) after 1 attempts
2017-10-18 09:58:31,952 - DataSourceOpenStack.py[DEBUG]: Using metadata source: 'http://169.254.169.254

```

下面日志表明抓取数据成功，并写入`/var/lib/cloud/instances/e9f15094-8157-4c78-96a1-674cbaf26baf`​

```bash
2017-10-18 09:58:43,120 - util.py[DEBUG]: Crawl of openstack metadata service took 11.168 seconds

```

其他步骤如下:

1. 解析userdata,并执行
2. 按cloud.cfg里的配置顺序，依次运行各模块

### config 阶段 [#](https://xixiliguo.github.io/linux/cloud-init.html#config-阶段)

执行一些配置模块。

### final 阶段 [#](https://xixiliguo.github.io/linux/cloud-init.html#final-阶段)

此时大部分定制化已经完成， 这里只是一些简单的收尾工作 比如 final-message 模块，只是在日志里打印cloud-init启动结束

```bash
2017-10-18 09:58:44,236 - handlers.py[DEBUG]: start: modules-final/config-final-message: running config-final-message with frequency always
2017-10-18 09:58:44,236 - helpers.py[DEBUG]: Running config-final-message using lock (<cloudinit.helpers.DummyLock object at 0x1c81750>)
2017-10-18 09:58:44,236 - util.py[DEBUG]: Reading from /proc/uptime (quiet=False)
2017-10-18 09:58:44,236 - util.py[DEBUG]: Read 12 bytes from /proc/uptime
2017-10-18 09:58:44,240 - util.py[DEBUG]: Cloud-init v. 0.7.9 finished at Wed, 18 Oct 2017 01:58:44 +0000. Datasource DataSourceOpenStack [net,ver=2].  Up 63.25 seconds
2017-10-18 09:58:44,240 - util.py[DEBUG]: Writing to /var/lib/cloud/instance/boot-finished - wb: [420] 51 bytes
2017-10-18 09:58:44,241 - handlers.py[DEBUG]: finish: modules-final/config-final-message: SUCCESS: config-final-message ran successfully

```

## cloud-init 源码结构 [#](https://xixiliguo.github.io/linux/cloud-init.html#cloud-init-源码结构)

大部分代码存放于 /lib/python2.7/site-packages/cloudinit

```bash
├── cmd                   // 所有命令的主入口
├── config                // 各种模块文件
├── distros               // 各OS具体操作实现（比如安装软件，写文件）
│   └── parsers
├── filters               // 日志相关的过滤
├── handlers              // 处理userdata的具体实现
├── mergers               // 辅助函数
├── net                   // 网络配置的通用操作 
├── reporting             // 通用的类，用于报告各种事件
└── sources               // openstack, aliyun等数据源的类实现
    └── helpers
        └── vmware
            └── imc

```

## 运行的主入口 [#](https://xixiliguo.github.io/linux/cloud-init.html#运行的主入口)

local, network, config, final三个不同阶段通过不同的参数，传递给主程序.比如local的具体命令行为 `/usr/bin/cloud-init init --local`​.首先主入口是 `cmd/main.py`​, 解析命令行参数

```bash
def main(sysv_args=None):
    if sysv_args is not None:
        parser = argparse.ArgumentParser(prog=sysv_args[0])
        sysv_args = sysv_args[1:]
    else:
        parser = argparse.ArgumentParser()

```

local, init会走入 `main_init`​这个函数， local主要是寻找本地源（比如configdriver）, init阶段是寻找网络源（比如通过http消息获取metadata）

当前华为云的裸金属镜像使用configdriver这种方式，原理如下：

> 物理机启动minios, 下载镜像和metadata  
> 给一块硬盘分区，将镜像dd写入第一分区  
> 在该硬盘的最后位置，生成一个分区，写入metadata  
> minios重启系统，让物理机从新的硬盘引导  
> OS启动后，里面的cloud-init会挂载分区 /dev/sr0类似这样的  
> mount后将读取普通文件一样获取metadata

​`main_init`​主要做的事情如下：

1. 读取配置文件
2. 初始化日志信息
3. 根据配置初始化运行时相关的目录和权限
4. 如果是寻找网络源的过程，检查是否已经存在信息，有则提前退出，无则继续第五步
5. 根据当前Cloud-init所支持的datasource列表， 逐个搜索，看是否可以获取元数据。 所有全部数据源都检查后没有找到数据且命令行没有设置 `--force`​， cloud-init会提前推出， 否则继续第六步。
6. 配置网络， local阶段会自动设置eth0为dhcp模式，用自动获取ip, 这样在init阶段（有时也叫network）时网络源才能正常工作。
7. 如果元数据里有userdata, 则程序开始解析并运行
8. 重读配置文件，获取该阶段需要运行的模块
9. 根据待运行的模块重新配置日志输出
10. 执行8步获取的模块列表

## 常见模板介绍 [#](https://xixiliguo.github.io/linux/cloud-init.html#常见模板介绍)

config文件下包含所有模块，通过名字很容易识别其对应的功能。 比如 `cc_set_hostname.py`​ 用于创建虚拟机时设置主机名。 ``cc_update_hostname.py`用于每次启动时更新主机名。 模块都根据对应的配置项执行， 同时每个模块有自己固定的运行频率（per isntance, per always等）

### cc_set_hostname.py [#](https://xixiliguo.github.io/linux/cloud-init.html#cc-set-hostname-py)

只在创建虚拟机时运行一次， 如果perserve_hostname为false, 则模块不运行。 从metadata里提取hostname, 然后运行对应OS下的设置主机名命令

### cc_update_hostname.py [#](https://xixiliguo.github.io/linux/cloud-init.html#cc-update-hostname-py)

每次虚拟机重启都会运行一次（包括第一次新建虚拟机）， 如果perserve_hostname为true, 则模块不运行。

1. 首先检查是否存在/var/lib/cloud/data/previous-hostname文件，有则对比当前OS的主机名， 如果不一样认为管理员维护主机名。提前退出
2. 发现当前元数据和当前OS的主机名不一样，则直接更新
3. 将最新的主机名写入 previous-hostname

### cc_growpart.py [#](https://xixiliguo.github.io/linux/cloud-init.html#cc-growpart-py)

每次虚拟机重启都会运行一次（包括第一次新建虚拟机）， 它会调整分区， 实现自动扩容，默认对根盘所有的虚拟磁盘执行。若要正常工作，还需要安装cloud-utils-growpart等辅助软件包

### cc_resizefs.py [#](https://xixiliguo.github.io/linux/cloud-init.html#cc-resizefs-py)

每次虚拟机重启都会运行一次（包括第一次新建虚拟机）, 它主要配置growpart, 对文件系统扩容。 growpart主要针对磁盘。 不同的文件系统，调用不同的命令

```bash
def _resize_btrfs(mount_point, devpth):
    return ('btrfs', 'filesystem', 'resize', 'max', mount_point)


def _resize_ext(mount_point, devpth):
    return ('resize2fs', devpth)


def _resize_xfs(mount_point, devpth):
    return ('xfs_growfs', devpth)


def _resize_ufs(mount_point, devpth):
    return ('growfs', devpth)


# Do not use a dictionary as these commands should be able to be used
# for multiple filesystem types if possible, e.g. one command for
# ext2, ext3 and ext4.
RESIZE_FS_PREFIXES_CMDS = [
    ('btrfs', _resize_btrfs),
    ('ext', _resize_ext),
    ('xfs', _resize_xfs),
    ('ufs', _resize_ufs),
]

```

## 数据源实现 [#](https://xixiliguo.github.io/linux/cloud-init.html#数据源实现)

​`sources`​下面是每个数据源的具体实现，openstack, aliyun这些都继承`__init__.py`​中的元类`DataSource`​. 这个metaclass实现了一些通用的操作。

openstack中通过访问 `http://169.254.169.254`​获取信息  
aliyun通过`http://100.100.100.200`​获取  
configdirve 查找`/dev/sr0`​,`/dev/sr1`​,`/dev/cd0`​,`/dev/cd1`​等设备，有则mount 后访问文件

## 配置文件 [#](https://xixiliguo.github.io/linux/cloud-init.html#配置文件)

cloud-init采用yaml格式的文件。yaml格式的具体说明参见 [http://www.ruanyifeng.com/blog/2016/07/yaml.html](http://www.ruanyifeng.com/blog/2016/07/yaml.html)  
特别注意：yaml不支持tab键，支持多个空格，但相同层级的元素左侧对齐。 cloud-init对布尔有特殊处理。 如下， true, 1, on, yes 均认为是true

```bash
TRUE_STRINGS = ('true', '1', 'on', 'yes')
FALSE_STRINGS = ('off', '0', 'no', 'false')
```

‍

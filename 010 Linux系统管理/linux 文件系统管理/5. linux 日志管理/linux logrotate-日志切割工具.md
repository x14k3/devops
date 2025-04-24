# linux logrotate-日志切割工具

logrorare一定程度上可以简化对会生成大量日志文件的系统的管理。logrotate可以实现自动轮替、删除、压缩和mail日志的功能。

Linux系统自带的日志滚动工具logrotate由两部分组成：一是命令行工具logrotate，二是后台服务[rsyslog](012%20企业建设/rsyslog.md)。

**配置文件详解/etc/logrotate.conf**

默认使用 /etc/logrotate.conf 文件，作为全局配置，而不同应用的具体配置则在 /etc/logrotate.d 目录下，通常以应用程序的名称命名，例如 nginx、mysql、syslog、yum 等配置。

```bash
# 每周轮替一次
weekly
#daily   指定转储周期为每天
#weekly  指定转储周期为每周
#monthly 指定转储周期为每月

# 保留4个轮替日志
rotate 4
# 轮替后创建新的日志文件
create
# 使用时间作为轮替文件的后缀
dateext
# 压缩日志
compress
# 让/etc/logrotate.d目录下面配置文件内容参与轮替
include /etc/logrotate.d

# no packages own wtmp and btmp -- we'll rotate them here
/var/log/wtmp {   # 轮替对象为/var/log/中的wtmp文件
    monthly       # 每个月轮替一次
    create 0664 root root # 创建新的日志文件 权限 所属用户 所属组
    minsize 1M    # 日志大小大于1M后才能参与轮替
    rotate 1      # 保留一个轮替日志文件
}

/data/redis/redis.log {
    missingok     # 如果日志文件不存在，继续进行下一个操作，不报错
    daily
    create 0600 root root
    rotate 1
	dateext
	compress
}

```

手动执行logrotate文件 `logrotate /etc/logrotate.d/nginx`

logrotate 配置文件的主要参数如表:

|参数|参数说明|
| -----------------------| ------------------------------------------------------------------------------------------|
|daily|日志的轮替周期是毎天|
|weekly|日志的轮替周期是每周|
|monthly|日志的轮控周期是每月|
|rotate数宇|保留的日志文件的个数。0指没有备份|
|compress|当进行日志轮替时，对旧的日志进行压缩|
|create mode owner group|建立新日志，同时指定新日志的权限与所有者和所属组.如create 0600 root utmp|
|mail address|当进行日志轮替时.输出内存通过邮件发送到指定的邮件地址|
|missingok|如果日志不存在，则忽略该日志的警告信息|
|nolifempty|如果曰志为空文件，則不进行日志轮替|
|minsize 大小|日志轮替的最小值。也就是日志一定要达到这个最小值才会进行轮持，否则就算时间达到也不进行轮替|
|size大小|日志只有大于指定大小才进行日志轮替，而不是按照时间轮替，如size 100k|
|dateext|使用日期作为日志轮替文件的后缀，如secure-20130605|
|sharedscripts|在此关键宇之后的脚本只执行一次|
|prerotate/endscript|在曰志轮替之前执行脚本命令。endscript标识prerotate脚本结束|
|postrotate/endscript|在日志轮替之后执行脚本命令。endscripi标识postrotate脚本结束|

# linux 定时任务

## at-仅执行一次的计划任务

首先，我们先来谈谈仅运行一次的计划任务at

### atd 的启动与 at 运行的方式

在使用at之前我们要确保atd服务是运行的，这个需要我们去检查一下，因为并不是所有的发行版linux默认都是开启这个服务的，但是在CentOS中是默认开启的

```
[root@zutuanxue ~]# systemctl status atd
● atd.service - Job spooling tools
   Loaded: loaded (/usr/lib/systemd/system/atd.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2020-01-13 09:34:03 CST; 1h 17min ago
#查询atd服务的状态

[root@zutuanxue ~]# systemctl is-enabled atd
enabled

#查询是否开启默认启动

如果没有启动
[root@zutuanxue ~]# systemctl start atd  
# 启动
[root@zutuanxue ~]# systemctl enable atd
#设置为开启启动
```

**at的工作模式**

at在运行的时候会将定义好的工作以文本文件的方式写入 /var/spool/at/ 目录内，该工作便能等待 atd 这个服务的调用，但是出于安全考虑，并不是所有的人都可以使用 at 计划任务！所以系统给我们提供了两个文件 /etc/at.allow 与 /etc/at.deny 来进行 at 的使用限制！ 加上这两个文件后， at 的工作情况其实是这样的：

先找寻 /etc/at.allow 这个文件，写在这个文件中的用户才能使用 at ，没有在这个文件中的用户则不能使用 at (即使没有写在 at.deny 当中)；

如果 /etc/at.allow 不存在，就寻找 /etc/at.deny 这个文件，若写在这个 at.deny 的用户则不能使用 at ，而没有在这个 at.deny 文件中的用户，就可以使用 at ；

如果两个文件都不存在，那么只有 root 可以使用 at 这个命令。

在大多数发行版当中，由于假设系统上的所有用户都是可信任的， 因此系统通常会保留一个空的 /etc/at.deny 文件，允许所有人使用 at 。如果有需要的话可以手动建立at.allow文件

### at的使用

单一计划任务的进行就使用 at 这个命令！将 at 加上一个时间即可！基本的语法如下：

```
[root@zutuanxue ~]# at  [-mldv] TIME  
[root@zutuanxue ~]# at -c 工作序号 
选项与参数：  
-m ：当 at 的工作完成后，发邮件通知用户，需要mail服务
-l ：at -l 相当于 atq，查看用户使用at定制的工作
-d ：at -d 相当于 atrm ，删除一个工作；  
-v ：详细信息；  
-c ：查看指定工作的具体内容。  
TIME：时间格式  
		HH:MM      ex> 16:00  
		在今天指定的时刻进行，若该时刻已超过，则明天的这个时间进行此工作。   
		HH:MM  YYYY-MM-DD   ex> 16:00 2021-07-30  
		指定在某年某月的某一天的时间进行该工作！   
		HH:MM[am|pm] [Month] [Date]  ex>  04am Jun 15    			另外一种年月日和时间的指定方式   
		HH:MM[am|pm] + number [minutes|hours|days|weeks]    		ex> now  + 5 minutes 	五分钟之后
		ex> 04am + 3 days    	三天后的上午四点  
```

at在使用过程中的时间指定很重要，另外在使用过程中如果涉及到路径的指定，强烈建议使用绝对路径，定义完成at之后使用键盘上的ctrl+d结束

**at 的管理**

有的时候我用at定义完计划任务之后，发现命令有错误，此时我们就可以使用atq 与 atrm 进行管理。

```
[root@zutuanxue ~]# atq  
[root@zutuanxue ~]# atrm 工作编号 
[root@zutuanxue at]# atq
2	Fri Feb 21 16:00:00 2020 a root
# 在 2020-02-21 的 16:00 有一项工作，该项工作是root设置的，工作编号为2
[root@zutuanxue ~]# atrm 2  
[root@zutuanxue ~]# atq  # 没有任何信息，表示该工作被移除了！  
```

‍

## crontab-周期执行的计划任务

相对于 at 是仅执行一次的工作，周期执行的计划任务则是由 crond这个系统服务来控制的。同样各位在使用的时候也要确认一下此服务的状态

```
[root@zutuanxue ~]# systemctl status crond
● crond.service - Command Scheduler
   Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2020-01-13 09:34:03 CST; 2h 0min ago
[root@zutuanxue ~]# systemctl is-enabled crond
enabled
```

用户使用的是 crontab 这个命令来定义周期性的计划任务，但是为了安全性的问题， 与 at 同样的，我们可以限制使用 crontab 的用户账号！使用的限制数据有：

 **/etc/cron.allow：**   
将可以使用 crontab 的账号写入其中，若不在这个文件内的用户则不可使用 crontab；

 **/etc/cron.deny：**   
将不可以使用 crontab 的账号写入其中，若未记录到这个文件当中的用户，就可以使用 crontab 。

与 at 一样，以优先级来说， /etc/cron.allow 比 /etc/cron.deny 要高， 一般系统默认是提供 /etc/cron.deny ， 你可以将允许使用 crontab 用户写入 /etc/cron.deny 当中，一个账号一行。crontab 建立计划任务会存放在 /var/spool/cron/ 目录中，

### crontab 的使用

```
[root@zutuanxue ~]# crontab
-u ：只有root可以使用，指定其它用户的名称
-e ：建立计划任务  
-l ：查看计划任务  
-r ：删除所有计划任务，若只删除一项，只能使用-e进行编辑  
[root@zutuanxue ~]# crontab -e
#执行后会打开一个vim的页面，每个任务一行  
0	12 	* 	*  *			cp	/etc/passwd /root
分 时 日 	月 周				工作内容
```

编辑完毕之后输入“ :wq ”保存退出， 在cron中每项工作 (每行) 的格式都是具有六个字段，这六个字段的意义为：

|意义|分钟|小时|日期|月份|周|命令|
| ------| ------| ------| ------| ------| -----| ----------|
|范围|0-59|0-23|1-31|1-12|0-7|工作内容|

比较有趣的是那个『周』！周的数字为 0 或 7 时，都代表『星期天』的意思！另外，还有一些辅助的字符，大概有底下这些：

|特殊字符|含义|
| :---------| :--------------------------------------------------------------------------------------|
|*(星号)|代表任何时刻|
|,(逗号)|代表分隔时段的意思。如3:00 与 6:00 时，就是：0 3,6 * * *|
|-(减号)|代表一段时间范围内，如：8 点到 12 点之间的每小时的 20 分都进行一项工作：20 8-12 * * *|
|/n(斜线)|n 代表数字，间隔的单位的意思，如每五分钟进行一次，则：*/5 * * * * 也可以写成 0-59/|

```
[root@zutuanxue ~]# crontab -l		#查看root的计划任务
0 16 1 * *	cp /etc/passwd /root
root@zutuanxue ~]# crontab -u oracle -l
#查看指定用户的计划任务
no crontab for oracle
[root@zutuanxue ~]# crontab -r	#删除所有计划任务
[root@zutuanxue ~]# crontab -l
no crontab for root
```

注意：crontab在使用的时候如果遇到路径，同样建议使用绝对路径，如果只是要删除某个项目，使用 crontab -e 来重新编辑，如果使用 -r 的参数，是会将所有的 crontab 内容都删掉。

### 配置文件

​`/etc/crontab, /etc/cron.d/*`​

crontab -e是针对用户 来设计的，系统的计划任务是通过/etc/crontab文件来实现的，我们只要编辑/etc/crontab 这个文件就可以，由于cron的最低检测时间是分钟，所以编辑好这个文件，系统就会自动定期执行了

```
[root@zutuanxue ~]# cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```

与crontab -e的内容类似，但是多了几个部分

```
SHELL=/bin/bash			shell类型
PATH=/sbin:/bin:/usr/sbin:/usr/bin	执行文件搜索位置
MAILTO=root		发生错误时通知邮件发送给谁

*  *  *  *  * user-name  command to be executed
#比crontab -e多了一个执行者的身份，因为并不是所有工作都需要root用户去执行
```

**额外的文件**

crond有三个相关联的地方，他们分别是：

/etc/crontab 系统计划任务的配置文件

/etc/cron.d/ 此目录和下面的几个目录都是系统计划任务存放运行脚本的位置。

/etc/cron.hourly/

/etc/cron.daily/

/etc/cron.weekly/

/etc/cron.monthly/

/var/spool/cron/* 用户定制的计划任务存放位置

## anacron

anacron 并不是用来取代 crontab 的，anacron 存在的目的就在于处理由于一些原因导致cron无法完成的工作

其实 anacron 也是每个小时被 crond 执行一次，然后 anacron 再去检测相关的工作任务有没有被执行，如果有未完成的工作， 就执行该工作任务，执行完毕或无须执行任何工作时，anacron 就停止了。我们可以通过/etc/cron.d/0hourly的内容查看到

```
[root@zutuanxue ~]# cat /etc/cron.d/0hourly 
# Run the hourly jobs
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 * * * * root run-parts /etc/cron.hourly
```

由于 anacron 默认会以一天、七天、一个月为期去检测系统未进行的 crontab 任务，因此对于某些特殊的使用环境非常有帮助。

那么 anacron 又是怎么知道我们的系统何时关机？这就得要使用 anacron 读取的时间记录文件 (timestamps) 了！ anacron 会去分析现在的时间与时间记录文件所记载的上次执行 anacron 的时间，两者比较后若发现有差异， 那就是在某些时刻没有进行 crontab ！此时 anacron 就会开始执行未进行的 crontab 任务了！

### anacron 与 /etc/anacrontab

anacron 其实是一个程序并非一个服务！这个程序在系统当中已经加入 crontab 的工作！同时 anacron 会每个小时被主动执行一次！所以 anacron 的配置文件应该放置在 /etc/cron.hourly目录中

```
[root@zutuanxue ~]# cat /etc/cron.hourly/0anacron 
#!/bin/sh
# Check whether 0anacron was run today already
.
.
.
/usr/sbin/anacron -s
实际上，也仅仅是执行anacron -s命令，这个命令会根据/etc/anacrontab文件的定义去执行各项工作
```

**anacrontab**

```
[root@zutuanxue ~]# cat /etc/anacrontab 
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45		#最大随机延迟时间，单位是分钟
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22	#仅执行延迟多少个小时之内的任务

#period in days   delay in minutes   job-identifier   command
1	5	cron.daily		nice run-parts /etc/cron.daily
7	25	cron.weekly		nice run-parts /etc/cron.weekly
@monthly 45	cron.monthly		nice run-parts /etc/cron.monthly
间隔时间(天)	延迟时间(分钟)	工作名称	执行的内容
```

以 /etc/cron.daily/ 那一行的为例

每隔一天，在开机后的第5分钟去执行cron.daily目录下的脚本

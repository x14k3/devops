

Rsyslog的全称是 rocket-fast system for log，它提供了高性能，高安全功能和模块化设计。rsyslog能够接受从各种各样的来源，将其输入，输出的结果到不同的目的地。rsyslog可以提供超过每秒一百万条消息给目标文件。

**特点：**

- 多线程
- 可以通过许多协议进行传输UDP，TCP，SSL，TLS，RELP；
- 直接将日志写入到数据库;
- 支持加密协议：ssl，tls，relp
- 强大的过滤器，实现过滤日志信息中任何部分的内容
- 自定义输出格式；

## **配置文件详解**

配置文件/etc/rsyslog.conf主要有3个部分

- MODULES ：模块

  ```
  #### MODULES ####

  # 下面的 imjournal 模块现在用作消息源
  $ModLoad imuxsock   # 提供对本地系统日志记录的支持
  $ModLoad imjournal  # 提供对 systemd 日志的访问
  #$ModLoad imklog    # 读取内核消息（从日志中读取相同的消息）
  #$ModLoad immark    # 提供--MARK--消息能力

  # Provides UDP syslog reception
  #$ModLoad imudp
  #$UDPServerRun 514

  # Provides TCP syslog reception
  #$ModLoad imtcp
  #$InputTCPServerRun 514
  ```
- GLOBAL DRICTIVES :全局设置

  ```
  #### GLOBAL DIRECTIVES ####

  # Where to place auxiliary files
  $WorkDirectory /var/lib/rsyslog

  # 使用默认时间戳格式
  $ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

  # File syncing capability is disabled by default. This feature is usually not required,
  # not useful and an extreme performance hit
  #$ActionFileEnableSync on

  # Include all config files in /etc/rsyslog.d/
  $IncludeConfig /etc/rsyslog.d/*.conf

  # Turn off message reception via local log socket;
  # local messages are retrieved through imjournal now.
  $OmitLocalLogging on

  # File to store the position in the journal
  $IMJournalStateFile imjournal.state

  ```
- RULES：规则

  ```
  #### RULES ####

  # Log all kernel messages to the console.
  # Logging much else clutters up the screen.
  #kern.*                                                 /dev/console

  # Log anything (except mail) of level info or higher.
  # Don't log private authentication messages!
  *.info;mail.none;authpriv.none;cron.none                /var/log/messages

  # The authpriv file has restricted access.
  authpriv.*                                              /var/log/secure

  # Log all the mail messages in one place.
  mail.*                                                  -/var/log/maillog


  # Log cron stuff
  cron.*                                                  /var/log/cron

  # Everybody gets emergency messages
  *.emerg                                                 :omusrmsg:*

  # Save news errors of level crit and higher in a special file.
  uucp,news.crit                                          /var/log/spooler

  # Save boot messages also to boot.log
  local7.*                                                /var/log/boot.log


  # ### begin forwarding rule ###
  # The statement between the begin ... end define a SINGLE forwarding
  # rule. They belong together, do NOT split them. If you create multiple
  # forwarding rules, duplicate the whole block!
  # Remote Logging (we use TCP for reliable delivery)
  #
  # An on-disk queue is created for this action. If the remote host is
  # down, messages are spooled to disk and sent when it is up again.
  #$ActionQueueFileName fwdRule1 # unique name prefix for spool files
  #$ActionQueueMaxDiskSpace 1g   # 1gb space limit (use as much as possible)
  #$ActionQueueSaveOnShutdown on # save messages to disk on shutdown
  #$ActionQueueType LinkedList   # run asynchronously
  #$ActionResumeRetryCount -1    # infinite retries if host is down
  # remote host is: name/ip:port, e.g. 192.168.0.1:514, port optional
  #*.* @@remote-host:514
  # ### end of the forwarding rule ###
  ```

  rules说明

  ```
  facitlity.priority          Target
   
  auth         #pam产生的日志，认证日志
  authpriv     #ssh,ftp等登录信息的验证信息，认证授权认证
  cron         #时间任务相关
  kern         #内核
  lpr          #打印
  mail         #邮件
  mark(syslog) #rsyslog服务内部的信息,时间标识
  news         #新闻组
  user         #用户程序产生的相关信息
  uucp         #unix to unix copy, unix主机之间相关的通讯
  local 1~7    #自定义的日志设备
  ===============================================================
  #priority: 级别日志级别:
  =====================================================================
  debug           #有调式信息的，日志信息最多
  info            #一般信息的日志，最常用
  notice          #最具有重要性的普通条件的信息
  warning, warn   #警告级别
  err, error      #错误级别，阻止某个功能或者模块不能正常工作的信息
  crit            #严重级别，阻止整个系统或者整个软件不能正常工作的信息
  alert           #需要立刻修改的信息
  emerg, panic    #内核崩溃等严重信息
  ###从上到下，级别从低到高，记录的信息越来越少，如果设置的日志内性为err，则日志不会记录比err级别低的日志，只会记录比err更高级别的日志，也包括err本身的日志。
  =====================================================================
  Target：
    #文件, 如/var/log/messages
    #用户， root，*（表示所有用户）
    #日志服务器，@172.16.22.1
    #管道        | COMMAND
  ```

	

‍

## rsyslog集中式日志服务器部署

参考：[rsyslog](../../../企业建设/rsyslog.md)

‍

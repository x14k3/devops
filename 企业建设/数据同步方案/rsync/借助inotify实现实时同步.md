

### inotify

> **工具官方地址:**  **[https://github.com/rvoicilas/inotify-tools](https://github.com/rvoicilas/inotify-tools)**

​`Inotify`​ 是一种文件变化通知机制，`Linux`​ 内核从 `2.6.13`​ 开始引入。在 `BSD`​ 和 `Mac OS`​ 系统中比较有名的是 `kqueue`​，它可以高效地实时跟踪 `Linux`​ 文件系统的变化。近些年来，以 `fsnotify`​ 作为后端，几乎所有的主流 `Linux`​ 发行版都支持 `Inotify`​ 机制。

​`inotify-tools`​ 提供了一系列的命令行工具，这些工具可以用来监控文件系统的事件，除了要求内核支持 `inotify`​ 外不依赖于其他。`inotify-tools`​ 提供两种工具，第一个命令是 `inotifywait`​，它是用来监控文件或目录的变化；第二个命令是 `inotifywatch`​，它是用来统计文件系统访问的次数。

```bash
# inotifywait   实时监控/home的所有事件
inotifywait -rm /home

# inotifywatch  统计/home文件系统的事件
inotifywatch -v -e access -e modify -t 60 -r /home
```

#### **inotifywait**

```
# 语法格式
inotifywait [-hcmrq] [-e ] [-t ] [–format ] [–timefmt ] [ … ]
```

|排序|命令参数|解释说明|
| ------| ----------| ----------------------------------------------------------------------------|
|1|​`-r`​|监视一个目录下的所有子目录|
|2|​`-m`​|接收到一个事情而不退出，无限期地执行；默认的行为是接收到一个事情后立即退出|
|3|​`-e`​|指定监视的事件|
|4|​`-s`​|输出错误信息到系统日志|
|5|​`-q`​|设置之后不显示输出的详细信息|
|6|​`–exclude`​|正则匹配需要排除的文件，大小写敏感|
|7|​`–excludei`​|正则匹配需要排除的文件，忽略大小写|
|8|​`-t`​/`timeout`​|设置超时时间，如果为 0 则表示无限期地执行下去|
|9|​`–timefmt`​|指定时间格式，用于–format 选项中的%T 格式|
|10|​`–format`​|指定事件监听输出格式；`%w`​/`%f`​/`%e`​/`%T`​|
|11|​`–csv`​|输出 csv 格式|
|12|​`-d`​/`–daemon`​|已后台方式运行服务；需要指定–outfile 把事情输出到一个文件|
|13|​`-o`​/`–outfile`​|输出事件到一个文件而不是标准输出|
|14|​`@`​|排除不需要监视的文件，可以是相对路径，也可以是绝对路径|

#### **inotifywatch**

```
# 语法格式
inotifywatch [-hvzrqf] [-e ] [-t ] [-a ] [-d ] [ … ]
```

|排序|命令参数|解释说明|
| ------| ----------| -----------------------------------------------------------------------|
|1|​`-r`​|监视一个目录下的所有子目录|
|2|​`-e`​|指定监视的事件|
|3|​`-t`​|设置超时时间，如果为 0 则表示无限期地执行下去|
|4|​`–exclude`​|正则匹配需要排除的文件，大小写敏感|
|5|​`–excludei`​|正则匹配需要排除的文件，忽略大小写|
|6|​`–fromfile`​|从文件读取需要监视的文件或排除的文件，一个文件一行，排除的文件以@开头|
|7|​`@`​|排除不需要监视的文件，可以是相对路径，也可以是绝对路径|
|8|​`-z`​/`–zero`​|输出表格的行和列，即使元素为空|
|9|​`-a`​/`–ascending`​|以指定事件升序排列|
|10|​`-d`​/`–descending`​|以指定事件降序排列|

#### **可监听事件**

|排序|可监听事件|解释说明|
| ------| ------------| ----------------------------------------------------------------------|
|1|​`access`​|文件读取|
|2|​`modify`​|文件更改|
|3|​`attrib`​|文件属性更改，如权限，时间戳等|
|4|​`close_write`​|以可写模式打开的文件被关闭，不代表此文件一定已经写入数据|
|5|​`close_nowrite`​|以只读模式打开的文件被关闭|
|6|​`close`​|文件被关闭，不管它是如何打开的|
|7|​`open`​|文件打开|
|8|​`moved_to`​|一个文件或目录移动到监听的目录，即使是在同一目录内移动，此事件也触发|
|9|​`moved_from`​|一个文件或目录移出监听的目录，即使是在同一目录内移动，此事件也触发|
|10|​`move`​|包括`moved_to`​和`moved_from`​|
|11|​`move_self`​|文件或目录被移除，之后不再监听此文件或目录|
|12|​`create`​|文件或目录创建|
|13|​`delete`​|文件或目录删除|
|14|​`delete_self`​|文件或目录移除，之后不再监听此文件或目录|
|15|​`unmount`​|文件系统取消挂载，之后不再监听此文件系统|

‍

#### rsync+inotify-tools

> **值的注意的是，inotify-tools 工具至今还在持续有人维护，可以方式使用。**

-  **[1] 调整 inotify 内核参数**

  ```bash
  # 文件末尾添加以下参数
  $ sudo vim /etc/sysctl.conf
  fs.inotify.max_queued_events = 16384    # 监控事件队列;
      # 表示调用inotify_init时分配给instance中可排队的
      # event的数目的最大值，超出这个值的事件被丢弃，但会
      # 触发IN_Q_OVERFLOW事件
  fs.inotify.max_user_instances = 128     # 最多监控实例数;
      # 表示每一个真实用户ID可创建的instatnces的数量上限
  fs.inotify.max_user_watches = 524288    # 每个实例最多监控目录数;
      # 表示每个instatnces可监控的最大目录数量，如果监控
      # 的文件数目巨大，需要根据情况，适当增加此值的大小
  ```

  ```bash
  # 也可以从proc中获取对应参数信息
  $ ll /proc/sys/fs/inotify
  -rw-r--r-- 1 root root 0 Dec 17 15:05 max_queued_events
  -rw-r--r-- 1 root root 0 Dec 17 15:05 max_user_instances
  -rw-r--r-- 1 root root 0 Dec 17 15:05 max_user_watches
  ```

-  **[2] 安装 inotify-tools 工具**

  ```bash
  # 安装编译器
  $ yum -y install gcc gcc-c++

  # 安装工具 - 直接安装
  $ yum install -y inotify-tools

  # 安装工具 - 手动编译
  # https://github.com/rvoicilas/inotify-tools/
  $ tar xvfz inotify-tools-3.20.1.tar.gz
  $ cd inotify-tools-3.20.1
  $ ./configure && make && make install
  ```

-  **[3] 使用 inotifywait 命令进行监控测试**

  ```
  # 实时监控修改、创建、移动、删除操作
  # 递归整个目录: -r
  # 持续的进行监控: -m
  # 指定监控的事件: -e
  $ inotifywait -mrq -e modify,create,move,delete /var/www/html
  /var/www/html  CREATE  abc.txt
  /var/www/html  MODIFY  abc.txt
  /var/www/html  DELETE  abc.txt
  ```

-  **[4] 编写触发式上行同步脚本**

  ```
  # [版本一]
  # 已循环形式触发同步操作，且每次都是全量同步
  # 相当于有10个文件发生变化就触发10次全量同步，还不如死循环

  INOTIFY_CMD="inotifywait -mrq --format '%Xe %w%f' -e modify,create,attrib,move,delete /var/www/html/"
  RSYNC_CMD="rsync -azH --delete --password-file=/etc/rsync.password /var/www/html/ escape@192.168.31.191::aptbackup"

  ${INOTIFY_CMD} | while read DIRECTORY EVENT FILE; do
      if [ $(pgrep rsync | wc -l) -le 0 ]; then
          ${RSYNC_CMD}
      fi
  done
  ```

  ‍

  ```
  # [版本二]
  # 虽然利用到了inotofy的特点，只同步改变的文件
  # 但是并没有进行操作行为更加细致的区分，执行不同的处理

  REMOTE_IP="192.168.31.191"
  REMOTE_USER="escape"
  PASSWORD="/etc/rsync.password"
  INOTIFY_DIR="/var/www/html/"
  INOTIFY_CMD="inotifywait -mrq -e modify,create,attrib,move,delete ${INOTIFY_DIR}"

  ${INOTIFY_CMD} | while read DIRECTORY EVENT FILE; do
      if [ -f ${FILE} ]; then
          rsync -azH --password-file=${PASSWORD} ${DIRECTORY}/${FILE} ${REMOTE_USER}@${REMOTE_IP}::backup
      else
          rsync -azH --delete --password-file=${PASSWORD} ${DIRECTORY}/${FILE} ${REMOTE_USER}@${REMOTE_IP}::backup
      fi
  done
  ```

  ‍

  ```
  # [版本三]
  # 基本可以再生产中使用了

  remote_user="root"
  remote_ip="192.168.31.191"
  remote_model="backup"
  rsync_passwd_file="/etc/rsyncd.passwd"
  inotify_dir="/var/www/html"
  inotify_cmd="inotifywait -mrq --format '%Xe:::%w%f' -e modify,create,delete,attrib,close_write,move ${inotify_dir}"

  # 把监控到有发生更改的文件路径列表循环
  ${inotify_cmd} | while read inotify_info; do
      # 事件类型和文件路径
      EVENT=$(echo ${inotify_info} | awk -F':::' '{print $1}')
      FILES=$(echo ${inotify_info} | awk -F':::' '{print $2}')

      # 增加、修改、写入完成、移动进事件
      if [[ $EVENT =~ 'CREATE' ]] || [[ $EVENT =~ 'MODIFY' ]] || [[ $EVENT =~ 'CLOSE_WRITE' ]] || [[ $EVENT =~ 'MOVED_TO' ]]; then
          echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
          rsync -avzcR --password-file=${rsync_passwd_file} ${FILES} ${remote_user}@${remote_ip}::${remote_model}
      fi

      # 删除、移动出事件
      if [[ $EVENT =~ 'DELETE' ]] || [[ $EVENT =~ 'MOVED_FROM' ]]; then
          echo 'DELETE or MOVED_FROM'
          rsync -avzR --delete --password-file=${rsync_passwd_file} ${FILES} ${remote_user}@${remote_ip}::${remote_model}
      fi

      # 修改属性事件
      # 如果修改属性的是目录则不同步，因为同步目录会发生递归扫描
      if [[ $EVENT =~ 'ATTRIB' ]]; then
          echo 'ATTRIB'
          if [ ! -d "$INO_FILE" ]; then
              rsync -avzcR --password-file=${rsync_passwd_file} ${FILES} ${remote_user}@${remote_ip}::${remote_model}
          fi
      fi
  done
  ```

-  **[5] 定时进行全量同步**

  ```
  # 因为inotify只在启动时会监控目录，没有启动期间的文件发生更改
  # 所以我们每2个小时做1次全量同步，防止各种意外遗漏，保证目录一致
  $ crontab -e
  * */2 --- rsync -avz --password-file=/etc/rsync.passwd \
      /www/var/html root@192.168.31.191::backup
  ```

### sersync

> **官方项目地址:**  **[https://code.google.com/archive/p/sersync](https://code.google.com/archive/p/sersync)**

#### rsync+inotify-tools 与 rsync+sersync 架构的区别

**rsync+inotify-tools**

1. inotify只能记录下被监听的目录发生了变化（增，删，改）并没有把具体是哪个文件或者哪个目录发生了变化记录下来；
2. rsync在同步的时候，并不知道具体是哪个文件或目录发生了变化，每次都是对整个目录进行同步，当数据量很大时，整个目录同步非常耗时（rsync要对整个目录遍历查找对比文件），因此效率很低

**rsync+sersync**

1. sersync可以记录被监听目录中发生变化的（增，删，改）具体某个文件或目录的名字；
2. rsync在同步时，只同步发生变化的文件或目录（每次发生变化的数据相对整个同步目录数据来说很小，rsync在遍历查找对比文件时，速度很快），因此效率很高。

#### **sersync 同步参数说明**

|排序|Sersync 参数|说明|
| ------| --------------| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|1|​ **​`-r`​**​|作用是在开启实时监控之前对主服务器目录与远程目标机目录进行一次整体同步；如果设置了过滤器，即在 xml 配置文件中 filter 为 true，则暂时不能使用-r 参数进行整体同步|
|2|​ **​`–o confxml.xml`​**​|不指定-o 参数时，sersync 可执行文件目录下的默认配置文件 confxml.xml；如果需要使用其他的配置文件，可以使用-o 参数指定其他配置文件，通过-o 参数，我们可以指定多个不同的配置文件，从而实现 sersync 多进行多实例的数据同步|
|3|​ **​`–n number`​**​|该参数为指定默认的线程池的线程总数；如果不指定，默认启用线程池数量为 10 个|
|4|​ **​`-d`​**​|该参数为后台启动服务，在通常情况下，使用-r 参数对本地到远程整体同步一遍后，在后台运行此参数启动守护进程实时同步，在第一次整体同步时，-d 和-r 参数经常会联合使用|
|5|​ **​`-m pluginName`​**​|该参数为不进行同步，只运行插件；例如 sersync –m command，则在监控到时间后，不对远程目标服务器进行同步，而是直接运行 command 插件|

---

#### rsync+sersync

> 在同步主服务器上开启 `sersync`​ 服务，`sersync`​ 负责监控配置路径中的文件系统事件变化，然后调用 `rsync`​ 命令把更新的文件同步到目标服务器。
>
> - [Sersync 项目简介与框架设计](https://www.kancloud.cn/curder/linux/78148)
> - **已经没有人维护了，请谨慎使用哈！**

-  **[1] 备份服务器开启 rsync 守护进程**

-  **[2] 同步服务器安装 rsync**

-  **[3] 同步服务下载 sersync 工具**

  ```
  # 下载sersync的可执行文件版本
  https://code.google.com/archive/p/sersync/downloads

  # 下载并解压，感觉已经不更新了，2011年的
  $ sudo wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/sersync/sersync2.5.4_64bit_binary_stable_final.tar.gz

  # 规范sersync目录结构，非必须
  $ sudo mkdir -pv /usr/local/sersync/bin
  $ sudo mkdir -pv /usr/local/sersync/conf
  $ sudo mkdir -pv /usr/local/sersync/logs
  $ sudo cp -r GNU-Linux-x86/sersync2 /usr/local/sersync/bin
  $ sudo cp -r GNU-Linux-x86/confxml.xml /usr/local/sersync/conf
  ```

-  **[4] 设置 sersync 的配置文件**

  ```xml
  <?xml version="1.0" encoding="ISO-8859-1"?>
  <head version="2.5">
      <!-- IP地址和端口号是针对插件的保留字段，对于同步功能没有任何作用，默认保留即可 -->
      <host hostip="localhost" port="8008"></host>
      <!-- 调试模式的开关 -->
      <!-- 开启debug模式会在sersync正在运行的控制台，打印inotify时间与rsync的同步命令 -->
      <debug start="false"/>
      <!-- xfs文件系统的开关 -->
      <!-- 对于xfs文件系统的用户，需要将这个选项开启 -->
      <fileSystem xfs="false"/>
      <!-- filter文件过滤功能 -->
      <!-- 将start设置为true后开启过滤功能，在exclude标签中填写正则表达式 -->
      <filter start="false">
          <exclude expression="(.*)\.svn"></exclude>
          <exclude expression="(.*)\.gz"></exclude>
          <exclude expression="^info/*"></exclude>
          <exclude expression="^static/*"></exclude>
      </filter>
      <!-- inotify监控参数设定 -->
      <inotify>
          <delete start="true"/>
          <createFolder start="true"/>
          <createFile start="false"/>
          <closeWrite start="true"/>
          <moveFrom start="true"/>
          <moveTo start="true"/>
          <attrib start="false"/>
          <modify start="false"/>
      </inotify>

      <sersync>
          <!--本地文件监控与远程同步设置-->
          <!--如果存在多个目录，可以添加多段进行配置-->
          <localpath watch="/home/root/escape">
              <!--定义要同步的服务器IP和模块名(例如上述的blog等)-->
              <remote ip="192.168.31.100" name="blog"/>
              <!--<remote ip="192.168.8.39" name="tongbu"/>-->
              <!--<remote ip="192.168.8.40" name="tongbu"/>-->
          </localpath>
          <!-- rsync相关参数设置 -->
          <!-- 配置使用rsync同步时候的命令 -->
          <rsync>
              <!-- 可以自定义rsync的同步参数，默认是-artuz -->
              <commonParams params="-avzP"/>
              <!-- 设置为true的时候，使用rsync的认证模式传送 -->
              <auth start="false" users="root" passwordfile="/etc/rsync.password"/>
              <!-- 默认端口 port=874 -->
              <userDefinedPort start="false" port="874"/>
              <!-- 默认超时时间 timeout=100 -->
              <timeout start="false" time="100"/>
              <ssh start="false"/>
          </rsync>
          <!-- 失败日志脚本配置 -->
          <!-- 默认情况下每60mins执行一次 -->
          <failLog path="/usr/local/sersync/logs/rsync_fail_log.sh" timeToExecute="60"/>
          <!--crontab定期整体同步功能  默认时间为600mins-->
          <crontab start="false" schedule="600">
              <crontabfilter start="false">
              <exclude expression="*.php"></exclude>
              <exclude expression="info/*"></exclude>
              </crontabfilter>
          </crontab>
          <plugin start="false" name="command"/>
      </sersync>

      <!-- 插件设置 -->
      <plugin name="command">
          <!--prefix /opt/tongbu/mmm.sh suffix-->
          <param prefix="/bin/sh" suffix="" ignoreError="true"/>
          <filter start="false">
              <include expression="(.*)\.php"/>
              <include expression="(.*)\.sh"/>
          </filter>
      </plugin>

      <plugin name="socket">
          <localpath watch="/opt/tongbu">
              <deshost ip="192.168.138.20" port="8009"/>
          </localpath>
          </plugin>
      <plugin name="refreshCDN">
          <localpath watch="/data0/htdocs/cms.xoyo.com/site/">
              <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
              <sendurl base="http://pic.xoyo.com/cms"/>
              <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
          </localpath>
      </plugin>
  </head>
  ```

-  **[5] 开启 sersync 守护进程同步数据**

  ```
  # 配置sersync环境变量
  $ sudo echo 'export PATH=/usr/local/sersync/bin:$PATH' >> /etc/profile
  $ sudo source /etc/profile

  # 启动sersync命令
  $ sudo sersync2 -r -d -o /usr/local/sersync/conf/confxml.xml

  # 多实例的情况下仅第一个模块的路径能同步，其他模块下面的路径不能同步
  # 因此需要在/usr/local/sersync/conf目录下复制多个配置文件一同启动
  ```

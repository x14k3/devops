# mysql 常用命令

‍

## 启动命令

### mysqld

（1）mysqld是mysql的守护进程，直接使用这种方式启动，会加载MySQL配置（如：/etc/my.cnf）中的[mysqld]和[server]组下的参数内容~  
（2）一般通过手动调用mysqld来启动mysql服务，这种方式只有一个mysqld进程，没有守护进程，如果mysql服务挂了，没有检查重启的机制，生产环境不会使用这种方式启动mysql服务~

```bash
mysqld --defaults-file=/etc/my.cnf --user=mysql &
mysqladmin -uroot -p -S /data/mysql/mysql.sock shut
```

### mysql_safe

**通过**​**`mysqld_safe`**​**启动mysql服务这种方式是生产运维建议使用的启动方式~**

（1）打开mysqld_safe，可以看到其实是一个Shell脚本，这种方式启动除了会加载MySQL配置（如：/etc/my.cnf）中的[mysqld]和[server]组下的参数内容之外，为了兼容老版本，还会加载[safe_mysqld]组下的内容~  
（2）执行脚本mysqld_safe时，脚本中会去调用mysqld启动mysqld和monitor mysqld两个进程，monitor即监视的意思，这样如果mysql服务挂了，那么mysqld_safe会重新启动mysqld进程

```bash
mysqld_safe --defaults-file=/etc/my.cnf --user=mysql  &
mysqladmin -uroot -p -S /data/mysql/mysql.sock shut
```

### mysql.server

（1）脚本mysql.server是mysql安装目录support-files下的一个文件，也是一个启动Shell脚本，脚本中会去调用mysqld_safe脚本  
（2）主要通过拷贝mysql.server脚本刀片/etc/init.d/目录下，并命名为mysql，实现便捷启动和停止~  
（3）启动service mysql start、停止service mysql start，非常适合开发环境的运维~

```bash
# 注意修改脚本中的几个参数
basedir=/data/mysql
datadir=/data/mysql/data
mysqld_pid_file_path=/data/mysql/mysql.pid
conf=/etc/my.cnf

#修改support-files/mysql.server中默认my.cnf自定义配置路径不生效问题~
---------------------------------------------------
case "$mode" in
  'start')
    # Start daemon

    # Safeguard (relative paths, core dumps..)
    cd $basedir

    echo $echo_n "Starting MySQL"
    if test -x $bindir/mysqld_safe
    then
      # Give extra arguments to mysqld with the my.cnf file. This script
      # may be overwritten at next upgrade.
      $bindir/mysqld_safe --defaults-file=/data/mysqldata/my.cnf  --datadir="$datadir" --pid-file="$mysqld_pid_file_path" $other_args >/dev/null &
      wait_for_pid created "$!" "$mysqld_pid_file_path"; return_value=$?


```

## mysql -u root -p 等这些常用的参数

```bash

-h 主机名或ip地址  # 指定登录的主机名；
-u 用户名         # 指定用户登录的用户名；
-p 密码          # 输入登录密码；
-P 端口号         # 指定登录的MySQL的端口号；
-D 数据库名       # 指定登录的数据库名称；
```

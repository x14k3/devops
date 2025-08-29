
## （一）我要学会怎么用

### 1.1 安装

#### 1.1.1 离线安装（源码）

postgresql安装一般推荐源码安装，更加自定义化、个性化。

<u>安装步骤如下:</u>

（1）关闭操作系统防火墙

<!--linux6是这样操作-->

```shell
关闭运行中的服务
# service iptables stop
关闭操作系统自启动
# chkconfig iptables off
检查关闭情况
# chkconfig --list iptables
```

<!--linux7是这样操作-->

```shell
关闭服务
# systemctl stop firewalld
关闭自启动
# systemctl disable firewalld
检查是否关闭
# systemctl status firewalld
```

（2）关闭Selinux

```shell
# vi /etc/selinux/config
SELINUX=disabled
```

（3）关闭Numa

```shell
# vi /etc/default/grub                  --添加numa=off   
# grub2-mkconfig -o /etc/grub2.cfg      --重建MBR 分区表
# grub2-mkconfig -o /etc/grub2-efi.cfg  --重建efi 引导模式， efi + GPT分区表
# reboot                                --重启服务器
# dmesg|grep -i numa                    --查看是否禁用
[  0.000000] NUMA turned off
```

（4）内核参数设置

```shell
# vi /etc/sysctl.conf
kernel.shmmax = 135088316416         #echo $(expr $(getconf _PHYS_PAGES) / 2 \* $(getconf PAGE_SIZE))
kernel.shmall = 32980546             #echo $(expr $(getconf _PHYS_PAGES) / 2)
kernel.shmmni = 4096
#vm.nr_hugepages = 65536             #大页参数
kernel.sem = 4096 2147483647 2147483646 512000    #或者kernel.sem = 250 32000 100 128  
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 10000 65535
net.core.rmem_default = 262144    
net.core.rmem_max = 4194304    
net.core.wmem_default = 262144    
net.core.wmem_max = 4194304
fs.file-max = 6815744
```

使配置生效

```shell
# sysctl -p  
```

（5）添加资源限制

```shell
# vi /etc/security/limits.conf
postgres soft    nofile  1024000
postgres hard    nofile  1024000
postgres soft    nproc   unlimited
postgres hard    nproc   unlimited
postgres soft    core    unlimited
postgres hard    core    unlimited
postgres soft    memlock unlimited
postgres hard    memlock unlimited
```

（6）配置本地yum源

```shell
# mount  /dev/cdrom  /mnt
mount: block device /dev/sr0 is write-protected, mounting read-only

# vi /etc/yum.repos.d/dvd.repo
[DVD]
name=dvd
baseurl=file:///mnt
gpgcheck=0
```

（7）安装必要的依赖包

```shell
# yum -y install coreutils glib2 lrzsz mpstat dstat sysstat e4fsprogs xfsprogs ntp readline-devel zlib-devel openssl-devel pam-devel libxml2-devel libxslt-devel python-devel tcl-devel gcc make smartmontools flex bison perl-devel perl-ExtUtils* openldap-devel jadetex openjade bzip2
```

（8）下载源码包并解压

```shell
# wget https://ftp.postgresql.org/pub/source/v12.2/postgresql-12.2.tar.bz2
# tar xjvf postgresql*.bz2 -C /home/postgres/app
```

（9）进入解压目录进行编译安装

```shell
# ./configure --prefix=/home/postgres/produce/pg12.1 --enable-nls --with-perl --with-python --with-tcl --with-gssapi --with-openssl --with-pam --with-ldap --with-libxml --with-libxslt                      #拟安装至/produce/pg12.1
# make world
# make install-world
```

（10）添加postgres操作系统用户及数据目录

```shell
# adduser postgres                           #增加新用户，系统提示要给定新用户密码
# mkdir /home/postgres/produce/pg12.1/data
# chown -R postgres:postgres /home/postgres/produce/pg12.1/data
```

（11）切换postgres，设置系统环境变量

```shell
# su - postgres
$ vi ~/.bash_profile
export PGDATA=/home/postgres/produce/pg12.1/data  
export LD_LIBRARY_PATH=/home/postgres/produce/pg12.1/lib
```

（12）初始化数据库并启动

```shell
$ initdb -D /home/postgres/produce/pg12.1/data
$ pg_ctl -D /home/postgres/produce/pg12.1/data -l logfile start
```

（13）设置自启动

【第一种方式，使用linux服务】

```shell
# vim /usr/lib/systemd/system/postgresql-12.service

[Unit]
Description=postgresql project

[Service]
Type=forking
User=postgres
Group=postgres
ExecStart=/opt/PostgresPlus/9.5AS/bin/pg_ctl start -D /opt/PostgresPlus/9.5AS/data #启动命令
ExecReload=/opt/PostgresPlus/9.5AS/bin/pg_ctl restart -D /opt/PostgresPlus/9.5AS/data #重新启动
ExecStop=/opt/PostgresPlus/9.5AS/bin/pg_ctl stop -D /opt/PostgresPlus/9.5AS/data  #停止，以上三命令都需要绝对路径
RestartSec=5
Restart=always
PrivateTmp=true
 
[Install]
WantedBy=multi-user.target
```

【第二种方式，使用pg自带启动程序】

```shell
# vi/etc/rc.d/rc.local
su - postgres -c 'pg_ctl start -D /postgres/data -l logfile'

# chmod +x /etc/rc.d/rc.local
```

#### 1.1.2 离线安装（rpm包）

RPM需要：

```
postgresql12-12.3-1PGDG.rhel7.x86_64.rpm
postgresql12-contrib-12.3-1PGDG.rhel7.x86_64.rpm
postgresql12-libs-12.3-1PGDG.rhel7.x86_64.rpm
postgresql12-server-12.3-1PGDG.rhel7.x86_64.rpm
```

作用：

- PGDG 应该是安装资源库的 可以不安装
- contrib 是安装扩展的 没有这个包就没有 ossp-uuid的插件了
- server 是数据库的安装文件
- libs 用来客户端进行连接. 
- 如果是centos8 的话 选择 rhel8 进行下载就可以了

安装顺序：

```shell
# rpm -ivh postgresql13-libs-13.4-1PGDG.rhel8.x86_64.rpm 
# rpm -ivh postgresql13-13.4-1PGDG.rhel8.x86_64.rpm 
# rpm -ivh postgresql13-contrib-13.4-1PGDG.rhel8.x86_64.rpm 
# rpm -ivh postgresql13-server-13.4-1PGDG.rhel8.x86_64.rpm
```

#### 1.1.3 在线安装（yum安装）

```shell
# Install the repository RPM:
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install PostgreSQL:
sudo yum install -y postgresql14-server

# Optionally initialize the database and enable automatic start:
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14

# reference https://www.postgresql.org/download/linux/redhat/
```



### 1.2 升级

#### 1.2.1 大版本升级（本地）

使用pg_upgrade进行升级，分为非link模式和link模式

<u>以下为非link模式</u>

（1）创建测试老库

```shell
$ mkdir /data/pg11.7/olddata/

$ /data/pg11.7/bin/initdb -D /data/pg11.7/olddata/

$ vi /data/pg11.7/olddata/postgresql.conf
listener_address = '*'

$ vi /data/pg11.7/olddata/pg_hba.conf
host all all 0.0.0.0/0 trust

$ /data/pg11.7/bin/psql -p5417
```

```sql
postgres=# create table test(id int);
CREATE TABLE
postgres=# create index ON test using btree ( id);
CREATE INDEX
postgres=# insert into test values (1);
INSERT 0 1
postgres=# create tablespace htbs location '/data/pg117';
CREATE TABLESPACE
postgres=# create table test2(id int) tablespace htbs;
CREATE TABLE
postgres=# insert into test2 values (1);
INSERT 0 1
```

```shell
$ /data/pg11.7/bin/pg_ctl stop -D /data/pg11.7/olddata/
```

（2）创建测试新库

```shell
$ mkdir /data/pg12.1/newdata/

$ /data/pg12.1/bin/initdb -D /data/pg12.1/newdata/

$ vi /data/pg12.1/newdata/postgresql.conf
listener_address = '*'

$ vi /data/pg12.1/newdata/pg_hba.conf
host all all 0.0.0.0/0 trust
```

（3）关闭老库和新库

```shell
$ pg_ctl stop -D /data/pg11.7/olddata/
$ pg_ctl stop -D /data/pg12.1/newdata/
```

（4）检查能否升级

新库bin/pg_upgrade -c -b 老库bin/ -B 新库bin/ -d 老库data/ -D 新库data/

```shell
$ /data/pg12.1/bin/pg_upgrade -c -b /data/pg11.7/bin/ -B /data/pg12.1/bin -d /data/pg11.7/newdata/ -D /data/pg12.1/newdata/
```

```
Performing Consistency Checks
-----------------------------

Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for tables WITH OIDS                               ok
Checking for invalid "sql_identifier" user columns          ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok

*Clusters are compatible
```

（5）通过检查后，开始升级

```shell
$ /data/pg12.1/bin/pg_upgrade -b /data/pg11.7/bin/ -B /data/pg12.1/bin -d /data/pg11.7/newdata/ -D /data/pg12.1/newdata/
```

```
Performing Consistency Checks
-----------------------------

Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for tables WITH OIDS                               ok
Checking for invalid "sql_identifier" user columns          ok
Creating dump of global objects                             ok
Creating dump of database schemas
                                                            ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok

If pg_upgrade fails after this point, you must re-initdb the
new cluster before continuing.

Performing Upgrade
------------------

Analyzing all rows in the new cluster                       ok
Freezing all rows in the new cluster                        ok
Deleting files from new pg_xact                             ok
Copying old pg_xact to new server                           ok
Setting next transaction ID and epoch for new cluster       ok
Deleting files from new pg_multixact/offsets                ok
Copying old pg_multixact/offsets to new server              ok
Deleting files from new pg_multixact/members                ok
Copying old pg_multixact/members to new server              ok
Setting next multixact ID and offset for new cluster        ok
Resetting WAL archives                                      ok
Setting frozenxid and minmxid counters in new cluster       ok
Restoring global objects in the new cluster                 ok
Restoring database schemas in the new cluster
                                                            ok
Copying user relation files
                                                            ok
Setting next OID for new cluster                            ok
Sync data directory to disk                                 ok
Creating script to analyze new cluster                      ok
Creating script to delete old cluster                       ok

Upgrade Complete
----------------

Optimizer statistics are not transferred by pg_upgrade so,
once you start the new server, consider running:
    ./analyze_new_cluster.sh

Running this script will delete the old cluster's data files:
    ./delete_old_cluster.sh
```

（6）启动新库并执行相应脚本

```shell
$ pg_ctl start -D $PGDATA
$ vacuumdb --all --analyze-only
```

<u>以下为link模式</u>

使用-k或者--link采用硬链接的方式，速度快适合数据量大的情况，数据量小建议使用非link的copy模式

软连接与硬链接的区别另见说明



#### 1.2.2 小版本升级

例：PostgreSQL 9.2.4版本升级到PostgreSQL 9.2.24版本

（1）新版本数据库编译安装

```shell
# su - postgres
$ cd $PGHOME
上传新版本软件包postgresql-9.2.24.tar.gz到指定目录下
$ tar -zxvf postgresql-9.2.24.tar.gz
$ cd postgresql-9.2.24
$ ./configure --prefix=$PGHOME --with-ossp-uuid --without-readline --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=32
$ make && make install
```

（2）检查源库扩展并在新库上安装

```shell
# su - postgres
$ cd $PGHOME/postgresql-9.2.24/contrib/dblink
$ make && make install
$ cd $PGHOME/postgresql-9.2.24/contrib/pg_stat_statements
$ make && make install
$ cd $PGHOME/postgresql-9.2.24/contrib/uuid-ossp
$ make && make install
```

（3）关闭源库

```shell
# su - postgres
$ pg_ctl stop -D $PGDATA
```

（4）启动新库

```shell
# su - postgres
$ pg_ctl start -D $PGDATA
```



### 1.3 备份恢复

#### 1.3.1 物理备份

<u>pg_basebackup快速版用法</u>

**做一个压缩的备份，时间较长，但是节省空间**

```shell
pg_basebackup -D /bk1/data -Ft -z -P

（打包为tar格式并压缩，显示进度）
```

**做一个原样的备份，备份快，但是不节省空间**

```shell
pg_basebackup -D /bk2/data -Fp -P

（不打包，默认格式，显示进度）
```

**做流复制**

```shell
pg_basebackup -h 192.168.22.128 -p9622 -U repl -Fp -Xs -v -P -R -D /pgdata/pg9.6/data

（指定ip和端口，并使用流复制用户repl，默认格式，不保留额外的wal，启用冗长模式显示详细信息，显示进度，自动配置primary_key及复制槽信息
```

**-X参数**

- -Xn 或 -X none 不备份wal日志，这将得到一个完整的独立备份
- -Xf 或 -X fetch 在备份末尾收集wal，需要把wal_keep_segments设置的足够高，该模式使用-r控制传输速率的时候，只会控制wal传输速率
- -Xs 或 -X stream 默认值，只要客户端能保持接收预写式日志，使用这种模式不需要在主控机上保存额外的预写式日志，使用tar格式会备份处一个pg_wal.tar文件

 

*注意：如果有外部表空间，需要指定新的外部表空间， -T /home/older=/home/Thornger/newer*



<u>pg_basebackup完整版用法</u>

（1）数据库处于归档模式

```
archive_mode = on 
archive_command = 'test ! -f /pgdata/pg13/archivedir/%f && cp %p /pgdata/pg13/archivedir/%f'
```

（2）白名单配置流复制协议访问权限

```
host  replication   all       127.0.0.1/32      trust
```

（3）备份

- 产生压缩的tar包，-Ft参数指定：

```
pg_basebackup -D bk1 -Ft -z -P     #此备份花的时间比较长，但是节省空间。
```

- 产生跟源文件一样的格式，即原样格式，-Fp参数指定：

```
pg_basebackup -D bk2 -Fp -P        #此备份方式很快，但是不节省空间。
```

（4）恢复

关闭数据库或者kill服务器主进程模拟主机断电

```
pg_ctl stop
```

删除data目录下所有的文件，（如果是删除这个data目录，则下一次创建该目录时要求该目录的权限是750，否则启动数据库时会报错）

```
rm –rf $PGDATA/*
```

若使用tar包进行恢复：

```
tar -zvxf bk1/base.tar.gz -C /usr/local/pg12.2/data
tar -zvxf bk1/pw_wal.tar.gz -C /usr/local/pg12.2/data/pg_wal 
```

若使用原样文件备份进行恢复：

```
cp –rf bk2/* $PGDATA
```

在postgres.conf文件中添加如下2行

```
restore_command = 'cp /home/postgres/arch/%f %p'     #归档路径
recovery_target_timeline = 'latest'              #最新的时间线
```

在$PGDATA目录下touch一个空文件，告诉pg需要做recovery：

```
touch recovery.signal
```

启动数据库

```
pg_ctl start
```

登录数据库，执行函数(否则pg数据库处于只读状态

```
select pg_wal_replay_resume();
```

验证数据的完整性：

```
testdb=# select count(*) from t1; 
count 524288
```



*注意事项：*

- *虽然备库不支持创建复制槽，但是pg_basebackup会使用到临时的复制槽，这一点也需要注意*
- *对于预写式日志（wal）的备份，有可选项-X，包括：*

1.n（none）

不要在备份中包括预写式日志

2.f（fetch）

在备份末尾收集预写式日志文件，需要将wal_keep_segments或者wal_keep_size设置得够大，因为是一个串行的备份方式，先备份数据，再备份wal

3.s（stream）

在备份被创建时流传送预写式日志。这将开启一个到服务器的第二连接并且在运行备份时并行开始流传输预写式日志。因此[max_wal_senders](http://postgres.cn/docs/12/runtime-config-replication.html#GUC-MAX-WAL-SENDERS)至少为2，这是一个并行传输的备份方式，即数据和wal同时传输



附：物理备份脚本

**备份脚本（每天执行一次全备，并删除前一天的备份）：**

```shell
$ more /akcld/pgsql/crontabs/auto_physical_bak.sh

/akcld/pgsql/bin/pg_basebackup -U postgres -p 5432 -D /akcld/pgsql/pgbak_physical/$(date +"%Y-%m-%d") -Fp -P
if [ "$?" -eq "0" ];then
  echo "$(date +"%Y-%m-%d") PostgreSQL physical backuped successfully" >> /akcld/pgsql/crontabs/backup.log
  find /akcld/pgsql/pgbak_physical/20* -maxdepth 0 -type d -mmin +1200 | xargs rm -rf
else
  echo "$(date +"%Y-%m-%d") PostgreSQL physical backuped failed" >> /akcld/pgsql/crontabs/backup.log
fi
```



#### 1.3.2 基于时间点恢复（PITR）

（1）确保开启了归档

```
archive_mode = on 
archive_command = cp %p /pgdata/pg13/archivedir/%f'
```

（2）执行一次基础全备

```shell
pg_basebackup -D /pgdata/pgpitr/ -Pv -U postgres -p 5433
```

（3）插入修改数据（模拟业务正常进行）

```sql
postgres=# insert into testp values (default,default);
INSERT 0 1

#查询修改时间
postgres=# select now();
       now       
------------------------------
 2021-04-27 13:32:30.90999+08

(1 row)
```

（4）删除数据进行误操作模拟

```sql
postgres=# delete from testp;
DELETE 2
```

（5）停掉数据库

```shell
/usr/local/pgsql-13/bin/pg_ctl stop -D /pgdata/pg13/data
```

（6）移除当前数据目录下的文件或者新建一个数据目录

拷贝基础备份到相应数据目录，编辑postgresql.auto.conf

```
restore_command = 'cp <wal日志归档路径>%f %p'
recovery_target_time = '2021-04-27 13:32:30.90999+08'     # 插入数据后的时间
recovery_target_inclusive = on
```

*注意：12版本之前需要在recovery.conf中写上standby_mode = on*

（7）创建恢复标识文件

```shell
touch $PGDATA/recovery.signal
```

（8）启动恢复的数据库

```shell
/usr/local/pgsql-13/bin/pg_ctl start -D /pgdata/pg13/data
```

恢复完成后，数据库处于read-only模式，执行操作会出现以下提示

```
postgres=# delete from test;
ERROR: cannot execute DELETE in a read-only transaction
```

执行以下函数，将只读库更改为可读写

```sql
postgres=# select pg_wal_replay_resume();
```



#### 1.3.3 逻辑备份

pg_dump不阻塞读写

- Fp（默认），输出一个纯文本形式的SQL脚本文件
- Fc，输出一个适合于作为pg_restore输入的自定义格式归档，默认压缩
- Fd，目录模式，默认压缩且支持并行

常用语句如下

| **语句**                                                     | **作用**            |
| ------------------------------------------------------------ | :------------------ |
| pg_dump -Upostgres  -Fc -f postgers.sql postgres             | 备份某个库          |
| pg_restore  -Upostgres -d postgres postgres.sql -c --if-exists -v | 恢复某个库          |
| pg_restore  -Upostgres -t t_test -d postgres  postgres.sql   | 恢复表              |
| pg_restore  -Upostgres -a -t t_test -d postgres postgres.sql | 只恢复表数据        |
| pg_restore  -Upostgres -s -t t_test -d postgres postgres.sql | 只恢复表结构        |
| pg_dump -Fc -U  postgres -t ceshi2 -f ceshi3.sql -d dbtest   | 备份某张表          |
| pg_restore -d  dbtest ceshi3.sql -c --if-exists              | 恢复表(数据和结构） |
| pg_restore -d  dbtest ceshi3.sql -c --if-exists -s           | 只恢复结构          |
| pg_restore -d  dbtest ceshi3.sql -c --if-exists -a           | 只恢复数据          |
| pg_dump -Upostgres  -dpostgres -nschtest -Fc -f schdump.dump | 备份某个schema      |
| pg_restore  -Upostgres -dpostgres schdump.dump -c --if-exist -v | 恢复某个schema      |
| pg_restore  -Upostgres -dpostgres schdump.dump -s -c --if-exist -v | 只恢复结构          |
| pg_restore  -Upostgres -dpostgres schdump.dump -a -c --if-exist -v | 只恢复数据          |

附：逻辑备份脚本

**备份脚本（每天执行一次全备，并删除前一天的备份）：**

```shell
#!/bin/bash
#########################################################
# Function :PostgreSQL Backup tools                     #
# Platform :All Linux Based Platform                    #
# Date     :2022-02-23                                  #
# Author   :Will                                        #
# Contact  :huwnehao@mchz.com.cn                        #
# Company  :MeiChuang                                   #
#########################################################

PGBIN='/software/pgsql13/bin'                         #pg_dump执行路径
USRT='postgres'                                       #备份用户
PORT=5432                                             #备份端口
DBARRAY=('dbtest' 'postgres' 'mc.office')             #备份库名
DUMPPATH='/home/postgres/pgsql/pgbak_logical/alldbs'  #备份目录
DUMPLOGPATH='/home/postgres/pgsql/pgbak_logical'      #备份日志
SAVETIME=1200                                         #备份文件保留时长(分钟)
for(( i=0;i<${#DBARRAY[@]};i++ ))do
$PGBIN/pg_dump -Fd -p 5432 -j 4 -f $DUMPPATH/$(date +"%Y-%m-%d_")${DBARRAY[i]}/ ${DBARRAY[i]}
done;
if [ "$?" -eq "0" ];then
    echo "$(date +"%Y-%m-%d") PostgreSQL logical backuped successfully" >> $DUMPLOGPATH/backup.log
    find $DUMPPATH/20* -maxdepth 0 -type d -mmin +1200 | xargs rm -rf
else
    echo "$(date +"%Y-%m-%d") PostgreSQL logical backuped failed" >> $DUMPLOGPATH/backup.log
fi
```



## （二）我要学会怎么看

### 2.1 数据库状态

#### 2.1.1 是否存活

使用ps -ef | grep postgres

```shell
postgres 18201     1  0 Jun17 ?        00:02:31 /software/pgsql13/bin/postgres
postgres 18202 18201  0 Jun17 ?        00:00:00 postgres: logger 
postgres 18209 18201  0 Jun17 ?        00:00:00 postgres: checkpointer 
postgres 18210 18201  0 Jun17 ?        00:00:21 postgres: background writer 
postgres 18211 18201  0 Jun17 ?        00:00:22 postgres: walwriter 
postgres 18212 18201  0 Jun17 ?        00:02:07 postgres: autovacuum launcher 
postgres 18213 18201  0 Jun17 ?        00:00:03 postgres: archiver 
postgres 18214 18201  0 Jun17 ?        00:03:54 postgres: stats collector 
postgres 18215 18201  0 Jun17 ?        00:00:01 postgres: logical replication launcher
```

使用pg_controldata -D $PGDATA | grep 'Database cluster state'

```shell
[postgres@VM-4-13-centos ~]$ pg_controldata -D $PGDATA | grep 'Database cluster state'
Database cluster state:               in production
```



#### 2.1.2 主备关系

在主库上使用pg_stat_replication

```
[postgres@VM-4-13-centos pgsql13]$ psql -p5432
psql (13.4)
Type "help" for help.

postgres=# \x
Expanded display is on.
postgres=# select * from pg_stat_replication ;
-[ RECORD 1 ]----+------------------------------
pid              | 11687
usesysid         | 25105
usename          | repl
application_name | walreceiver
client_addr      | 10.0.4.13
client_hostname  | 
client_port      | 48496
backend_start    | 2022-07-15 15:06:29.173012+08
backend_xmin     | 1680
state            | streaming
sent_lsn         | 1/C9240508
write_lsn        | 1/C9240508
flush_lsn        | 1/C9240508
replay_lsn       | 1/C9240508
write_lag        | 
flush_lag        | 
replay_lag       | 
sync_priority    | 0
sync_state       | async
reply_time       | 2022-07-15 15:10:39.769239+08
```

在备库上使用pg_stat_wal_receiver

```
[postgres@VM-4-13-centos pgsql13]$ psql -p5433
psql (13.4)
Type "help" for help.

postgres=# \x
Expanded display is on.
postgres=# select * from pg_stat_wal_receiver ;
-[ RECORD 1 ]---------+-------------------------------------------------------------
pid                   | 11686
status                | streaming
receive_start_lsn     | 1/C9000000
receive_start_tli     | 7
written_lsn           | 1/C9240508
flushed_lsn           | 1/C9240508
received_tli          | 7
last_msg_send_time    | 2022-07-15 15:17:00.303113+08
last_msg_receipt_time | 2022-07-15 15:17:00.303155+08
latest_end_lsn        | 1/C9240508
latest_end_time       | 2022-07-15 15:06:29.247739+08
slot_name             | 
sender_host           | 10.0.4.13
sender_port           | 5432
conninfo              | user=repl password=******** channel_binding=prefer dbname=replication host=10.0.4.13 port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=0 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

使用函数pg_is_in_recovery()查看是主库还是备库，主库返回为'f'，备库返回为't'

```
postgres=# select pg_is_in_recovery();
 pg_is_in_recovery 
-------------------
 t
(1 row)
```



### 2.2 数据库基本信息

#### 2.2.1 集簇创建时间

通过pg_control_system()查看initdb的时间

```sql
postgres=# select to_timestamp(system_identifier>>32) from pg_control_system();
      to_timestamp      
------------------------
 2022-01-24 17:54:41+08
(1 row)
```



#### 2.2.2 数据库用户

通过pg_user或者pg_shadow视图查看用户信息，包括权限、密码验证方式等

```sql
postgres=# select usename,usecreatedb,usesuper,userepl,usebypassrls,passwd from pg_shadow ;
 usename  | usecreatedb | usesuper | userepl | usebypassrls |   passwd                
----------+-------------+----------+---------+--------------+---------------------
 sslconn  | f           | f        | f       | f            | md58d48b5594eb603c02111959153e9fa88
 repmgr   | f           | t        | f       | f            | md58ea99ab1ec3bd8d8a6162df6c8e1ddcd
 davide   | f           | f        | f       | f            | md59f07493da0cf9a2c7f0ce8cf1c980b51
 test0315 | f           | f        | f       | f            | 
 repl     | f           | f        | t       | f            | md59ef8fbcc13fdd05a77675af159ae94f5
 htest02  | f           | f        | f       | f            | 
 will     | t           | f        | f       | f            | md56ab18776881a50c6ef1c87aadffcf6f1
 huser    | f           | t        | t       | f            | md555ce20a3ba7a2444e284e67e7d3af897
 postgres | t           | t        | t       | t            | md50960a7b3214a5a0ecb23cd82f44dffb4
 backup   | f           | f        | t       | f            | 
 pgbro    | f           | f        | f       | f            | 
 hwh      | t           | f        | f       | f            | md567dd77ce16a20d9e637a745b942c06f4
(12 rows)
```



#### 2.2.3 查看各个数据库

使用pg_database系统表查看各个数据库信息，包括编码信息、连接限制、所在表空间等

```sql
postgres=# select d.datname,d.encoding,d.datallowconn,d.datconnlimit,t.spcname from pg_database d,pg_tablespace t where d.dattablespace = t.oid;
  datname   | encoding | datallowconn | datconnlimit |  spcname   
------------+----------+--------------+--------------+------------
 will       |        6 | t            |           -1 | pg_default
 template1  |        6 | t            |           -1 | pg_default
 template0  |        6 | f            |           -1 | pg_default
 dbtest     |        6 | t            |           -1 | pg_default
 repmgr     |        6 | t            |           -1 | pg_default
 davide     |        6 | t            |           -1 | pg_default
 only_test  |        6 | t            |           -1 | pg_default
 willtest   |        6 | t            |           -1 | pg_default
 postgres   |        6 | t            |           -1 | pg_default
 only_study |        6 | t            |           -1 | pg_default
(10 rows)
```



### 2.3 数据库日常查询

#### 2.3.1 表对应文件位置

```sql
postgres=# select pg_relation_filepath('pg_statistic');
 pg_relation_filepath 
----------------------
 base/13580/2619
(1 row)
```



#### 2.3.2 数据库大小

查看所有数据库大小

```sql
postgres=# select pg_database.datname, pg_size_pretty (pg_database_size(pg_database.datname)) AS size from pg_database;
  datname   |  size   
------------+---------
 will       | 8533 kB
 template1  | 7909 kB
 template0  | 7737 kB
 dbtest     | 8349 kB
 repmgr     | 7913 kB
 davide     | 7885 kB
 only_test  | 7933 kB
 willtest   | 7933 kB
 postgres   | 2146 MB
 only_study | 8077 kB
(10 rows)
```

查看某个数据库大小

```sql
postgres=# select pg_database.datname, pg_size_pretty (pg_database_size(pg_database.datname)) AS size from pg_database where pg_database.datname = 'dbtest';
 datname |  size   
---------+---------
 dbtest  | 8349 kB
(1 row)
```



#### 2.3.3 数据库对象大小

按顺序查看表大小

```sql
postgres=# select relname, pg_size_pretty(pg_relation_size(relid)) from pg_stat_user_tables where schemaname='public' order by pg_relation_size(relid) desc limit 10;
      relname      | pg_size_pretty 
-------------------+----------------
 oratest           | 2000 MB
 t1                | 42 MB
 t_gist            | 5096 kB
 nullt2            | 8192 bytes
 nullt             | 8192 bytes
 test_txt          | 8192 bytes
 test2             | 8192 bytes
 walminer_contents | 8192 bytes
 pg_to_ora         | 8192 bytes
 newname           | 8192 bytes
(10 rows)
```

按顺序查看索引大小

```sql
postgres=# select indexrelname, pg_size_pretty(pg_relation_size(relid)) from pg_stat_user_indexes where schemaname='public' order by pg_relation_size(relid) desc limit 10;
       indexrelname        | pg_size_pretty 
---------------------------+----------------
 oratest_name_idx          | 2000 MB
 i1                        | 42 MB
 i2                        | 42 MB
 idx_t_gist_1              | 5096 kB
 test_pkey                 | 8192 bytes
 test2_id_idx              | 8192 bytes
 commerce_contractor_pkeys | 8192 bytes
 a_pkey                    | 8192 bytes
 a_id_idx                  | 8192 bytes
 test_a_pkey               | 0 bytes
(10 rows)
```



#### 2.3.4 权限

<u>模式是隔离的，库是隔离的，用户只有拥有者对对象有权限</u>

查看某用户的系统权限

```sql
SELECT * FROM pg_roles WHERE rolname='postgres';
```

查看某用户的表权限

```sql
select * from information_schema.table_privileges where grantee='postgres' and table_name = 'test' and table_schema = 'public';
```

查看某用户的usage权限

```sql
select * from information_schema.usage_privileges where grantee='postgres'; 
```

查看某用户在存储过程函数的执行权限

```sql
select * from information_schema.routine_privileges where grantee='postgres';
```

查看某用户在某表的列上的权限

```sql
select * from information_schema.column_privileges where grantee='postgres';
```

查看当前用户能够访问的数据类型

```sql
select * from information_schema.data_type_privileges ;
```

查看用户自定义类型上授予的USAGE权限

```sql
select * from information_schema.udt_privileges where grantee='postgres';
```



#### 2.3.5 等待事件

执行时间超过5s的慢SQL

```sql
select * from pg_stat_activity where state<>'idle' and now()-query_start > interval '5 s' order by query_start ; 
```

查询大于5分钟的长事务

```sql
select query,state from pg_stat_activity where
state<>'idle' and (backend_xid is not null or backend_xmin is not null) and
now()-xact_start > interval '5 min' order by xact_start;
```

通过pid查看当前进程正在执行的SQL

```sql
SELECT procpid, START, now() - START AS lap, current_query FROM ( SELECT backendid, pg_stat_get_backend_pid (S.backendid) AS procpid,
pg_stat_get_backend_activity_start (S.backendid) AS START,pg_stat_get_backend_activity (S.backendid) AS current_query FROM (SELECT
pg_stat_get_backend_idset () AS backendid) AS S) AS S WHERE current_query <> '<IDLE>' and procpid=71893 ORDER BY lap DESC;
```

<u>等待事件对照表:</u>

| 分类      | 名称                              | 描述                                                         | 关联根因                                     |
| --------- | --------------------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| LWLock    | ShmemIndexLock                    | 等待在共享内存中分配内存                                     | 共享内存操作，并发                           |
| LWLock    | OidGenLock                        | 等待分配OID                                                  | 并发DDL                                      |
| LWLock    | XidGenLock                        | 等待生成事务XID                                              | 并发事务                                     |
| LWLock    | ProcArrayLock                     | 等待获得snapshot或者在会话结束时清理XID                      | 并发事务                                     |
| LWLock    | SInvalReadLock                    | 等待从共享缓冲失效队列中检索或删除消息                       | shared  buffers，并发SQL                     |
| LWLock    | SInvalWriteLock                   | 等待在共享缓冲失效队列中添加消息                             | shared  buffers，并发SQL                     |
| LWLock    | WALBufMappingLock                 | 等待替换 WAL  缓冲区中的页面                                 | WAL  BUFFER,DML，并发写入                    |
| LWLock    | WALWriteLock                      | 等待从WAL缓冲区中写数据到磁盘                                | DML,并发写入，磁盘IO性能                     |
| LWLock    | ControlFileLock                   | 等待读取或者修改控制文件，或者创建一个新的WAL文件            | DML,并发写入，磁盘IO性能                     |
| LWLock    | CheckpointLock                    | 等待执行CKPT                                                 | 并发事务                                     |
| LWLock    | CLogControlLock                   | 等待读取或者修改事务状态                                     | 并发事务                                     |
| LWLock    | SubtransControlLock               | 等待读取或者修改子事务信息                                   | 并发事务，子事务，SAVEPOINT                  |
| LWLock    | MultiXactGenLock                  | 等待读取或者修改共享组合事务(  multixact)状态                | 并发事务，共享组，SAVEPOINT                  |
| LWLock    | MultiXactOffsetControlLock        | 等待读取或者修改组合事务(multixact)  偏移映射信息            | 并发事务                                     |
| LWLock    | MultiXactMemberControlLock        | 等待读取或者修改组合事务(multixact)  成员映射信息            | 并发事务                                     |
| LWLock    | RelCacheInitLock                  | 等待读写  relation cache初始化文件（pg_internal.init）       | 磁盘IO性能，数据库中表的数量过多             |
| LWLock    | CheckpointerCommLock              | 等待管理fsync  请求                                          | 磁盘IO性能，并发写入                         |
| LWLock    | TwoPhaseStateLock                 | 等待读取或者修改prepared  transaction的状态                  | 分布式事务                                   |
| LWLock    | TablespaceCreateLock              | 等待创建或者删除表空间                                       | 表空间操作，磁盘IO性能，文件系统             |
| LWLock    | BtreeVacuumLock                   | 等待读取或者修改vacuum相关的B树索引信息                      | VACUUM,索引                                  |
| LWLock    | AddinShmemInitLock                | 等待共享内存中的内存空间管理                                 | 共享内存初始化                               |
| LWLock    | AutovacuumLock                    | 等待Autovacuum  worker 或者launcher等待读取或者修改 autovacuum worker的当前状态 | VACUUM                                       |
| LWLock    | AutovacuumScheduleLock            | 等待被选择做vacuum  的表仍然需要 vacuuming的确认信息         | VACUUM                                       |
| LWLock    | SyncScanLock                      | 等待获取表上扫描的开始位置以便于进行同步扫描                 | 表或索引扫描操作                             |
| LWLock    | RelationMappingLock               | 等待更新用于存储目录到文件节点映射的关系映射文件             | DDL操作                                      |
| LWLock    | AsyncCtlLock                      | 等待读取或者修改共享通知状态                                 | 会话数，并发执行，并发事务                   |
| LWLock    | AsyncQueueLock                    | 等待读取或者修改通知消息                                     | 会话数，并发执行，并发事务                   |
| LWLock    | SerializableXactHashLock          | 等待检索或者存储serializable事务相关的信息                   | 事务隔离级别，并发事务                       |
| LWLock    | SerializableFinishedListLock      | 等待访问serializable  事务完成清单                           | 事务隔离级别，并发事务                       |
| LWLock    | SerializablePredicateLockListLock | 等待在一个被serializable事务锁锁定的清单上做操作             | 事务隔离级别，并发事务                       |
| LWLock    | OldSerXidLock                     | 等待读取或记录冲突的可序列化事务                             | 事务隔离级别，并发事务                       |
| LWLock    | SyncRepLock                       | 等待读取或更新有关同步复制的信息                             | 流复制，同步复制                             |
| LWLock    | BackgroundWorkerLock              | 等待读取后者修改后台worker进程的状态                         | 并行执行，后台进程启动，后台进程关闭         |
| LWLock    | DynamicSharedMemoryControlLock    | 等待读取或者修改动态共享内存状态                             | 动态共享内存分配、释放                       |
| LWLock    | AutoFileLock                      | 等待修改postgresql.auto.conf 文件                            | 参数文件修改                                 |
| LWLock    | ReplicationSlotAllocationLock     | 等待分配或者始放一个复制槽                                   | 流复制，复制槽                               |
| LWLock    | ReplicationSlotControlLock        | 等待读取或者修改复制槽状态                                   | 流复制，复制槽                               |
| LWLock    | CommitTsControlLock               | 等待读取或者修改事务提交时间戳                               | 事务提交，页控制相关，DB  CACHE,并发事务，   |
| LWLock    | CommitTsLock                      | 等待读取或者修改事务时间戳的最后值集合                       | 事务提交，并发事务，                         |
| LWLock    | ReplicationOriginLock             | 等待设置、删除或使用复制源                                   | 流复制                                       |
| LWLock    | MultiXactTruncationLock           | 等待读取或者截断  multixact 信息                             | 事务并发，大事务                             |
| LWLock    | OldSnapshotTimeMapLock            | 等待读取或者修改旧的snapshot控制信息                         | 事务并发，SAVEPOINT                          |
| LWLock    | BackendRandomLock                 | 等待生成随机数                                               | 随机数生成                                   |
| LWLock    | LogicalRepWorkerLock              | 等待逻辑复制的WORKER结束任务                                 | 流复制                                       |
| LWLock    | CLogTruncationLock                | 等待执行txid_status 或者将可获得的最老的transaction  id赋给它 | 事务并发、磁盘IO性能、检查点配置             |
| LWLock    | WrapLimitsVacuumLock              | 等待修改multixact消耗和transaction  id的限制                 | 事务并发，磁盘IO性能，VACUUM、维护WORKER配置 |
| LWLock    | NotifyQueueTailLock               | 等待修改通知消息存储限制                                     |                                              |
| LWLock    | clog                              | 等待CLOG缓冲区的IO操作                                       | 事务并发、磁盘IO性能                         |
| LWLock    | commit_timestamp                  | 等待  commit timestamp buffer IO操作完成                     | 事务并发、参数配置、磁盘IO性能               |
| LWLock    | subtrans                          | 等待  subtransaction buffer IO操作完成                       | 事务并发，磁盘IO性能                         |
| LWLock    | multixact_offset                  | 等待  multixact offset buffer IO操作完成                     | 事务并发，磁盘IO性能                         |
| LWLock    | multixact_member                  | 等待  multixact_member buffer IO操作完成                     | 事务并发，磁盘IO性能                         |
| LWLock    | async                             | 等待async  (notify) buffer IO完成                            | 活跃会话、磁盘IO性能                         |
| LWLock    | oldserxid                         | 等待oldserxid  buffer IO完成                                 | 磁盘IO性能，事务并发                         |
| LWLock    | wal_insert                        | 等待将WAL插入缓冲区                                          | 事务并发、WALBUFFER                          |
| LWLock    | buffer_content                    | 等待在DB  CACHE中读写数据页                                  | 磁盘IO性能、热块、DBCACHE                    |
| LWLock    | buffer_io                         | 等待数据页IO完成                                             | 磁盘IO性能、检查点、热块                     |
| LWLock    | replication_origin                | 等待读取或者修改复制进度                                     | 数据库复制                                   |
| LWLock    | replication_slot_io               | 等待复制槽上的IO                                             | 数据库复制、磁盘IO性能                       |
| LWLock    | proc                              | 等待读取或者修改快速路径锁的信息                             |                                              |
| LWLock    | buffer_mapping                    | 等待将数据块与缓冲池中的缓冲区关联                           | DBCACHE，热块冲突                            |
| LWLock    | lock_manager                      | 在并行执行中，等待为后端添加或检查锁，或者等待加入或退出锁组 | 事务并发                                     |
| LWLock    | predicate_lock_manager            | 等待添加或检查谓词锁信息                                     | 并发执行                                     |
| LWLock    | parallel_query_dsa                | 等待并行查询动态共享内存分配锁                               |                                              |
| LWLock    | tbm                               | 等待 TBM  共享迭代器锁，一般发生在并行bitmap扫描中，等待TID BITMAP | 并发执行、索引扫描                           |
| Lock      | relation                          | 等待获取关系上的锁                                           | 并发执行                                     |
| Lock      | extend                            | 等待扩展  relation结束                                       |                                              |
| Lock      | frozenid                          | 等待修改 pg_database.datfrozenxid和 pg_database.datminmxid.  | VACUUM、磁盘IO性能、数据库配置               |
| Lock      | page                              | 等待获取relation中的一个页面的锁                             | 热块、DBCACHE                                |
| Lock      | tuple                             | 等待获取元组（tuple）锁                                      | 热块、事务并发、DBCACHE                      |
| Lock      | transactionid                     | 等待一个事务结束                                             | 事务并发、长事务                             |
| Lock      | virtualxid                        | 等待获取虚拟XID锁                                            | 并发执行、活跃会话                           |
| Lock      | speculative  token                | 等待获取推测插入锁                                           | 热块、事务并发、热表                         |
| Lock      | object                            | 等待一个非关系数据库锁                                       |                                              |
| Lock      | userlock                          | 等待获取用户锁                                               |                                              |
| Lock      | advisory                          | 等待获取建议用户锁                                           |                                              |
| BufferPin | BufferPin                         | 等待获得BUFFER的PIN锁                                        | 热块、DBCACHE                                |
| Activity  | ArchiverMain                      | 归档进程的主循环等待                                         | 后台进程，一般可忽略                         |
| Activity  | AutoVacuumMain                    | autovacuum启动进程的主循环等待                               | 后台进程，一般可忽略                         |
| Activity  | BgWriterHibernate                 | 后台写入进程等待，正在休眠                                   | 后台进程，一般可忽略                         |
| Activity  | BgWriterMain                      | bgwriter进程的主循环等待                                     | 后台进程，一般可忽略                         |
| Activity  | CheckpointerMain                  | CKPT进程主循环等待                                           | 后台进程，一般可忽略                         |
| Activity  | LogicalApplyMain                  | 逻辑应用进程主循环等待                                       | 后台进程，一般可忽略                         |
| Activity  | LogicalLauncherMain               | 逻辑启动进程主循环等待                                       | 后台进程，一般可忽略                         |
| Activity  | PgStatMain                        | 统计信息采集进程主循环等待                                   | 后台进程，一般可忽略                         |
| Activity  | RecoveryWalAll                    | 实例恢复时等待WAL数据流到达                                  | 等待新的WAL数据                              |
| Activity  | RecoveryWalStream                 | 在恢复时再次尝试检索  WAL 数据之前，等待任何类型的源（本地、存档或流）中的 WAL 数据不可用时 | 等待新的WAL数据                              |
| Activity  | SysLoggerMain                     | syslogger进程主循环等待                                      | 后台进程，一般可忽略                         |
| Activity  | WalReceiverMain                   | WAL接收进程主循环等待                                        | 后台进程，一般可忽略                         |
| Activity  | WalSenderMain                     | WAL发送进程主循环等待                                        | 后台进程，一般可忽略                         |
| Activity  | WalWriterMain                     | WAL写进程主循环等待                                          | 后台进程，一般可忽略                         |
| Client    | ClientRead                        | 等待读取客户端输入                                           | 未提交事务，空闲等待                         |
| Client    | ClientWrite                       | 等待向客户端发送数据                                         | 网络、TOPSQL                                 |
| Client    | LibPQWalReceiverConnect           | 在 WAL  接收器中等待建立与远程服务器的连接。                 |                                              |
| Client    | LibPQWalReceiverReceive           | 等待 WAL  接收器接收来自远程服务器的数据。                   |                                              |
| Client    | SSLOpenServer                     | 等待SSL连接                                                  |                                              |
| Client    | WalReceiverWaitStart              | 等待启动进程发送初始化复制数据流                             |                                              |
| Client    | WalSenderWaitForWAL               | 在WAL发送进程中等待WAL刷新                                   |                                              |
| Client    | WalSenderWriteData                | 在 WAL  发送者进程中处理来自 WAL 接收者的回复时等待任何活动  |                                              |
| Extension | Extension                         | 等待和extension交换数据或消息                                | 和扩展插件有关                               |
| IPC       | BgWorkerShutdown                  | 等待后台worker关闭                                           |                                              |
| IPC       | BgWorkerStartup                   | 等待后台worker启动                                           |                                              |
| IPC       | BtreePage                         | 等待继续并行 B  树扫描所需的页可用（并行索引扫描）           | 并行执行                                     |
| IPC       | ExecuteGather                     | 执行Gather时等待子进程的活动                                 | 表分析                                       |
| IPC       | LogicalSyncData                   | 等待逻辑复制远程服务发送数据，用于初始表同步                 | 逻辑复制                                     |
| IPC       | LogicalSyncStateChange            | 等待逻辑复制远程服务改变状态                                 | 逻辑复制                                     |
| IPC       | MessageQueueInternal              | 等待其他进程连接到共享消息队列中                             |                                              |
| IPC       | MessageQueuePutMessage            | 等待写一条协议消息到共享消息队列中                           |                                              |
| IPC       | MessageQueueReceive               | 等待从共享消息队列中接收字节                                 |                                              |
| IPC       | MessageQueueSend                  | 等待向共享消息队列发送字节                                   |                                              |
| IPC       | ParallelBitmapScan                | 等待并行位图索引扫描初始化                                   | 并行执行                                     |
| IPC       | ParallelFinish                    | 等待并行查询worker结束计算                                   | 并行执行                                     |
| IPC       | ProcArrayGroupUpdate              | 当事务结束时等待组leader清除transaction  id                  | 长事务                                       |
| IPC       | ReplicationOriginDrop             | 等待复制源变为非活动状态以被删除                             | 复制槽                                       |
| IPC       | ReplicationSlotDrop               | 等待复制槽变为非活动状态以被删除                             | 复制槽                                       |
| IPC       | SafeSnapshot                      | 一个READ  ONLY DEFERRABLE 事务等待snapshot                   | 事务快照                                     |
| IPC       | SyncRep                           | 同步复制时等待远程服务确认                                   | 同步复制                                     |
| Timeout   | BaseBackupThrottle                | 在基础备份时等待限流                                         | 复制                                         |
| Timeout   | PgSleep                           | 进程处于 pg_sleep等待                                        |                                              |
| Timeout   | RecoveryApplyDelay                | 在恢复时因为WAL延迟到达产生的等待                            | 实例恢复                                     |
| IO        | BufFileRead                       | bffered文件读等待                                            | 磁盘IO，热块，DBCACHE                        |
| IO        | BufFileWrite                      | buffered文件写等待                                           | DBCACHE,磁盘IO                               |
| IO        | ControlFileRead                   | 等待控制文件读                                               | 磁盘IO                                       |
| IO        | ControlFileSync                   | 等待控制文件写入持久化存储                                   | 磁盘IO                                       |
| IO        | ControlFileSyncUpdate             | 等待控制文件修改到达持久化存储                               | 磁盘IO                                       |
| IO        | ControlFileWrite                  | 等待写入控制文件                                             | 磁盘IO                                       |
| IO        | ControlFileWriteUpdate            | 等待一个修改控制文件的写操作                                 | 磁盘IO                                       |
| IO        | CopyFileRead                      | COPY命令中的读等待                                           | 磁盘IO                                       |
| IO        | CopyFileWrite                     | COPY命令中的写等待                                           | 磁盘IO                                       |
| IO        | DataFileExtend                    | 等待  relation数据文件扩展                                   | 磁盘IO，磁盘容量                             |
| IO        | DataFileFlush                     | 等待  relation数据文件写入持久存储                           | 磁盘IO                                       |
| IO        | DataFileImmediateSync             | 等待一个立即同步  relation 数据文件写入持久存储              | 磁盘IO                                       |
| IO        | DataFilePrefetch                  | 等待从Relation数据文件异步预读数据                           | 磁盘IO                                       |
| IO        | DataFileRead                      | 等待从relation数据文件读数据                                 | 磁盘IO                                       |
| IO        | DataFileSync                      | 等待  relation 数据文件的变化写入持久存储                    | 磁盘IO                                       |
| IO        | DataFileTruncate                  | 等待relation  数据文件截断                                   | 磁盘IO                                       |
| IO        | DataFileWrite                     | 等待  relation数据文件写                                     | 磁盘IO                                       |
| IO        | DSMFillZeroWrite                  | 等待向一个动态共享内存文件写入字节0                          |                                              |
| IO        | LockFileAddToDataDirRead          | 向数据字典锁文件添加一行时等待读操作                         | 磁盘IO，并发DDL                              |
| IO        | LockFileAddToDataDirSync          | 向数据字典锁文件添加一行时等待数据写入持久存储               | 磁盘IO，并发DDL                              |
| IO        | LockFileAddToDataDirWrite         | 向数据字典锁文件添加一行时等待写操作                         | 磁盘IO，并发DDL                              |
| IO        | LockFileCreateRead                | 创建数据字典锁文件时等待读操作                               | 磁盘IO                                       |
| IO        | LockFileCreateSync                | 创建数据字典锁文件时等待数据写入持久存储                     | 磁盘IO                                       |
| IO        | LockFileCreateWrite               | 创建数据字典锁文件时等待写操作                               | 磁盘IO                                       |
| IO        | LockFileReCheckDataDirRead        | 在重新检查数据字典锁文件期间等待读操作                       | 磁盘IO                                       |
| IO        | LogicalRewriteCheckpointSync      | CKPT时等待逻辑重写映射到达持久化存储                         | 磁盘IO，检查点,逻辑复制                      |
| IO        | LogicalRewriteMappingSync         | 逻辑重写时等待映射数据达到持久化存储                         | 磁盘IO、逻辑复制                             |
| IO        | LogicalRewriteMappingWrite        | 逻辑重写时等待写映射数据达到持久化存储                       | 磁盘IO、逻辑复制                             |
| IO        | LogicalRewriteSync                | 等待逻辑重写映射到达持久化存储                               | 磁盘IO、逻辑复制                             |
| IO        | LogicalRewriteTruncate            | 等待映射数据截断到达持久化存储                               | 磁盘IO、逻辑复制                             |
| IO        | LogicalRewriteWrite               | 等待一个逻辑重写映射写操作                                   | 磁盘IO、逻辑复制                             |
| IO        | RelationMapRead                   | 等待Relation  Map文件读                                      | 磁盘IO、逻辑复制                             |
| IO        | RelationMapSync                   | 等待Relation  Map文件写入持久存储                            | 磁盘IO                                       |
| IO        | RelationMapWrite                  | 等待Relation  Map文件写                                      | 磁盘IO                                       |
| IO        | ReorderBufferRead                 | RecorderBuffer管理中等待读操作（逻辑复制）                   | 磁盘IO、逻辑复制                             |
| IO        | ReorderBufferWrite                | RecorderBuffer管理中等待写操作（逻辑复制）                   | 磁盘IO、逻辑复制                             |
| IO        | ReorderLogicalMappingRead         | RecorderBuffer管理中等待逻辑映射文件读操作                   | 磁盘IO、逻辑复制                             |
| IO        | ReplicationSlotRead               | 等待复制槽控制文件的读操作                                   | 磁盘IO、复制                                 |
| IO        | ReplicationSlotRestoreSync        | 当复制槽控制文件从内存中复制时等待该文件写入持久存储         | 磁盘IO、复制                                 |
| IO        | ReplicationSlotSync               | 等待复制槽控制文件写入持久存储                               | 磁盘IO、复制                                 |
| IO        | ReplicationSlotWrite              | 等待一个复制槽控制文件写操作                                 | 磁盘IO、复制                                 |
| IO        | SLRUFlushSync                     | 检查点或者数据库关闭的时候，等待  SLRU数据写入持久存储       | 磁盘IO、检查点、数据库关闭                   |
| IO        | SLRURead                          | 等待SLRU页读取                                               | 磁盘IO                                       |
| IO        | SLRUSync                          | 页写入后等待SLRU数据写入持久存储                             | 磁盘IO                                       |
| IO        | SLRUWrite                         | 等待 SLRU  页写操作                                          | 磁盘IO                                       |
| IO        | SnapbuildRead                     | 等待读取序列化的历史目录快照                                 | 磁盘IO                                       |
| IO        | SnapbuildSync                     | 等待序列化的历史目录快照写入持久存储                         | 磁盘IO                                       |
| IO        | SnapbuildWrite                    | 等待写入序列化的历史目录快照                                 | 磁盘IO                                       |
| IO        | TimelineHistoryFileSync           | 等待通过流式复制接收到的时间线历史文件写入持久存储           | 磁盘IO                                       |
| IO        | TimelineHistoryFileWrite          | 流式复制时等待时间线文件上的一个写操作被收到                 | 磁盘IO                                       |
| IO        | TimelineHistoryRead               | 等待时间线历史文件上的读操作                                 | 磁盘IO                                       |
| IO        | TimelineHistorySync               | 等待新创建的时间线历史文件写入持久存储                       | 磁盘IO                                       |
| IO        | TimelineHistoryWrite              | 等待新创建的时间线历史文件上的写操作                         | 磁盘IO                                       |
| IO        | TwophaseFileRead                  | 等待两阶段状态文件读操作                                     | 磁盘IO、分布式事务                           |
| IO        | TwophaseFileSync                  | 等待两阶段状态文件写入持久存储                               | 磁盘IO、分布式事务                           |
| IO        | TwophaseFileWrite                 | 等待两阶段状态文件写操作                                     | 磁盘IO、分布式事务                           |
| IO        | WALBootstrapSync                  | bootstrap的时候等待WAL文件写入持久存储                       | 磁盘IO、启动                                 |
| IO        | WALBootstrapWrite                 | bootstrap的时候等待WAL页写操作                               | 磁盘IO、启动                                 |
| IO        | WALCopyRead                       | 当使用拷贝一个现有的WAL  段创建一个新WAL段的时候等待读操作   | 磁盘IO、复制                                 |
| IO        | WALCopySync                       | 当使用拷贝一个现有的WAL  段创建一个新WAL段的时候等待写入持久存储 | 磁盘IO、复制                                 |
| IO        | WALCopyWrite                      | 当使用拷贝一个现有的WAL  段创建一个新WAL段的时候等待写操作   | 磁盘IO、复制                                 |
| IO        | WALInitSync                       | 等待一个新初始化的WAL文件写入持久存储                        | 磁盘IO、检查点                               |
| IO        | WALInitWrite                      | 初始化新的WAL文件的时候等待写操作                            | 磁盘IO、检查点                               |
| IO        | WALRead                           | 等待WAL文件读                                                | 磁盘IO                                       |
| IO        | WALSenderTimelineHistoryRead      | 在  walsender 时间线命令期间等待从时间线历史文件中读取       | 磁盘IO、复制                                 |
| IO        | WALSyncMethodAssign               | WAL  同步模式时等待数据写入持久存储                          | 磁盘IO、WAL量                                |
| IO        | WALWrite                          | 等待WAL文件写                                                | 磁盘IO、WAL量                                |

<a name="pg_stat_statements">使用pg_stat_statements查看慢SQL </a>

设置参数

```
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000        #跟踪的语句的最大数目，默认5000
pg_stat_statements.track = all        #控制哪些语句会被该模块计数，top（默认）跟踪顶层语句（那些直接由客户端发出的语句）
pg_stat_statements.track_utility = off   #是否跟踪非DML语句 (例如DDL，DCL),on表示跟踪, off表示不跟踪，默认on
pg_stat_statements.save = on       #是否在服务器关闭之后还保存语句统计信息，默认on
```

查询语句

| 作用                                 | 语句                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 最耗IO SQL、单次调⽤最耗IO SQL TOP 5 | select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time)/calls desc limit 5; |
| 总最耗IO SQL TOP 5                   | select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time) desc limit 5; |
| 最耗时 SQL，单次调⽤最耗时 SQL TOP 5 | select userid::regrole, dbid, query from pg_stat_statements order by mean_exec_time desc limit 5; |
| 总最耗时 SQL TOP 5                   | select userid::regrole, dbid, query from pg_stat_statements order by total_time desc limit 5; |
| 响应时间抖动最严重 SQL               | select userid::regrole, dbid, query from pg_stat_statements order by stddev_exec_time desc limit 5; |
| 最耗共享内存 SQL                     | select userid::regrole, dbid, query from pg_stat_statements order by (shared_blks_hit+shared_blks_dirtied) desc limit 5; |
| 最耗临时空间 SQL                     | select userid::regrole, dbid, query from pg_stat_statements order by temp_blks_written desc limit 5; |



#### 2.3.6 查看当前活跃会话

```sql
select * from pg_stat_activity where wait_event is not null and (backend_xid is not null or backend_xmin is not null);
```



#### 2.3.7 表膨胀率

死元组大于10000的表膨胀率

```sql
select relname,coalesce(round(n_dead_tup * 100 / (case
when n_live_tup + n_dead_tup = 0 then null else n_live_tup +
n_dead_tup end ),2),0.00) as dead_tup_ratio from pg_stat_all_tables
where 1=1 and n_dead_tup >=10000 order by dead_tup_ratio desc
limit 5
```



#### 2.3.8 索引膨胀率

使用pgstattuple插件中的函数查看索引碎片率

```sql
postgres=# create extension pgstattuple ;
CREATE EXTENSION
postgres=# select leaf_fragmentation from pgstatindex('a_id_idx');
 leaf_fragmentation 
--------------------
               37.18
(1 row)
```



#### 2.3.9 索引创建进度

```sql
select
now(),
query_start as started_at,
now() - query_start as query_duration,
format('[%s] %s', a.pid, a.query) as pid_and_query,
index_relid::regclass as index_name,
relid::regclass as table_name,
(pg_size_pretty(pg_relation_size(relid))) as table_size,
phase,
nullif(wait_event_type, '') || ': ' || wait_event as wait_type_and_event,
current_locker_pid,
(select nullif(left(query, 150), '') || '...' from pg_stat_activity a where a.pid =
current_locker_pid) as current_locker_query,
format(
'%s (%s of %s)',
coalesce((round(100 * lockers_done::numeric / nullif(lockers_total, 0), 2))::text || '%', 'N/A'),
coalesce(lockers_done::text, '?'),
coalesce(lockers_total::text, '?')
) as lockers_progress,
format(
'%s (%s of %s)',
coalesce((round(100 * blocks_done::numeric / nullif(blocks_total, 0), 2))::text || '%', 'N/A'),
coalesce(blocks_done::text, '?'),
coalesce(blocks_total::text, '?')
) as blocks_progress,
format(
'%s (%s of %s)',
coalesce((round(100 * tuples_done::numeric / nullif(tuples_total, 0), 2))::text || '%', 'N/A'),
coalesce(tuples_done::text, '?'),
coalesce(tuples_total::text, '?')
) as tuples_progress,
format(
'%s (%s of %s)',
coalesce((round(100 * partitions_done::numeric / nullif(partitions_total, 0), 2))::text || '%', 'N/
A'),
coalesce(partitions_done::text, '?'),
coalesce(partitions_total::text, '?')
) as partitions_progress
from pg_stat_progress_create_index p
left join pg_stat_activity a on a.pid = p.pid;
-- in psql, use "\watch 5" instead of semicolon to run in loop
```



#### 2.3.10 未被使用的索引

```sql
SELECT
    PSUI.indexrelid::regclass AS IndexName
    ,PSUI.relid::regclass AS TableName
FROM pg_stat_user_indexes AS PSUI    
JOIN pg_index AS PI 
    ON PSUI.IndexRelid = PI.IndexRelid
WHERE PSUI.idx_scan = 0 
    AND PI.indisunique IS FALSE;
```



#### 2.3.11 重复索引

由于pg中允许在同一个列创建多个索引，而大部分情况下都是不需要的。

```sql
SELECT
    indrelid::regclass AS TableName
    ,array_agg(indexrelid::regclass) AS Indexes
FROM pg_index 
GROUP BY 
    indrelid
    ,indkey 
HAVING COUNT(*) > 1;
```



#### 2.3.12 索引使用情况

查看索引的使用情况，去除了包含主键的索引

```sql
select PSAI.schemaname,PSAI.relname,PSAI.indexrelname,PSAI.idx_scan,PSAI.idx_tup_read 
from pg_stat_all_indexes as PSAI
join pg_index AS PI 
ON PSAI.IndexRelid = PI.IndexRelid
where PSAI.schemaname not in ('pg_toast','pg_catalog')
and PI.indisunique IS FALSE;
```



#### 2.3.13 哪些表需要创建索引

```sql
SELECT 
	relname AS TableName
	,seq_scan-idx_scan AS TotalSeqScan
	,CASE WHEN seq_scan-idx_scan > 0 
		THEN 'Missing Index Found' 
		ELSE 'Missing Index Not Found' 
	END AS MissingIndex
	,pg_size_pretty(pg_relation_size(relname::regclass)) AS TableSize
	,idx_scan AS TotalIndexScan
FROM pg_stat_all_tables
WHERE schemaname='public'
	AND pg_relation_size(relname::regclass)>1000000  --单位字节
ORDER BY 2 DESC;
```



#### 2.3.14 某个用户的所有对象

```sql
select 
    nsp.nspname as SchemaName
    ,cls.relname as ObjectName 
    ,rol.rolname as ObjectOwner
    ,case cls.relkind
        when 'r' then 'TABLE'
        when 'm' then 'MATERIALIZED_VIEW'
        when 'i' then 'INDEX'
        when 'S' then 'SEQUENCE'
        when 'v' then 'VIEW'
        when 'c' then 'TYPE'
        else cls.relkind::text
    end as ObjectType
from pg_class cls
join pg_roles rol 
    on rol.oid = cls.relowner
join pg_namespace nsp 
    on nsp.oid = cls.relnamespace
where nsp.nspname not in ('information_schema', 'pg_catalog')
    and nsp.nspname not like 'pg_toast%'
    and rol.rolname = 'postgres'  
order by nsp.nspname, cls.relname;
```



#### 2.3.15 数据库剩余年龄

```sql
SELECT datname,age(datfrozenxid) AS
frozen_xid_age,ROUND(100 * (age(datfrozenxid) / 2000000000::float))
consumed_txid_pct,2 * 1024 ^ 3 - 1 - age(datfrozenxid) AS
remaining_txid,current_setting('autovacuum_freeze_max_age')::int -
age(datfrozenxid) AS remaining_aggressive_vacuum FROM pg_database;
```

```
  datname   | frozen_xid_age | consumed_txid_pct | remaining_txid | remaining_aggressive_vacuum 
------------+----------------+-------------------+----------------+-----------------------------
 will       |           1205 |                 0 |     2147482442 |                   199998795
 template1  |           1205 |                 0 |     2147482442 |                   199998795
 template0  |           1205 |                 0 |     2147482442 |                   199998795
 dbtest     |           1205 |                 0 |     2147482442 |                   199998795
 repmgr     |           1205 |                 0 |     2147482442 |                   199998795
 davide     |           1205 |                 0 |     2147482442 |                   199998795
 only_test  |           1205 |                 0 |     2147482442 |                   199998795
 willtest   |           1205 |                 0 |     2147482442 |                   199998795
 postgres   |           1205 |                 0 |     2147482442 |                   199998795
 only_study |           1205 |                 0 |     2147482442 |                   199998795
(10 rows)
```

- datname 库名
- frozen_xid_age 当前年龄
- consumed_txid_pct 年龄占总年龄百分比
- remaining_txid 剩余年龄
- remaining_aggressive_vacuum 冻结年龄建议值



#### 2.3.16 数据库缓冲区命中率

```sql
select round(sum(blks_hit) * 100 / sum(blks_hit+blks_read),2)::numeric from pg_stat_database where datname= current_database();
```



#### 2.3.17 lsn/wal文件/偏移量

V10版本之后

```sql
postgres=# select pg_current_wal_lsn(),pg_walfile_name(pg_current_wal_lsn()),pg_walfile_name_offset(pg_current_wal_lsn());
 pg_current_wal_lsn |     pg_walfile_name      |       pg_walfile_name_offset       
--------------------+--------------------------+------------------------------------
 1/C9278888         | 0000000700000001000000C9 | (0000000700000001000000C9,2590856)
(1 row)
```

V10版本之前

```sql
select pg_current_xlog_location(),pg_xlogfile_name(pg_current_xlog_location()),pg_xlogfile_name_offset(pg_current_xlog_location());
```



#### 2.3.18 锁堵塞

检查锁堵塞

```sql
postgres=# SELECT
blocked_locks.pid AS blocked_pid,
blocked_activity.usename AS blocked_user,
now() - blocked_activity.query_start AS blocked_duration,
blocking_locks.pid AS blocking_pid,
blocking_activity.usename AS blocking_user,
now() - blocking_activity.query_start AS blocking_duration,
blocked_activity.query AS blocked_statement,
blocking_activity.query AS blocking_statement
FROM
pg_catalog.pg_locks AS blocked_locks
JOIN pg_catalog.pg_stat_activity AS blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks AS blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity AS blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE
NOT blocked_locks.granted;
 blocked_pid | blocked_user | blocked_duration | blocking_pid | blocking_user | blocking_duration |   blocked_statement   | blocking_
statement 
-------------+--------------+------------------+--------------+---------------+-------------------+-----------------------+----------
----------
        8791 | postgres     | 00:00:02.398118  |         8541 | postgres      | 00:00:20.081007   | select * from test2 ; | drop tabl
e test2;
(1 row)
```

检查锁队列

```sql
WITH RECURSIVE t_wait AS (
SELECT
a.locktype,
a.database,
a.relation,
a.page,
a.tuple,
a.classid,
a.objid,
a.objsubid,
a.pid,
a.virtualtransaction,
a.virtualxid,
a.transactionid
FROM
pg_locks a
WHERE
NOT a.granted
),
t_run AS (
SELECT
a.mode,
a.locktype,
a.database,
a.relation,
a.page,
a.tuple,
a.classid,
a.objid,
a.objsubid,
a.pid,
a.virtualtransaction,
a.virtualxid,
a.transactionid,
b.query,
b.xact_start,
b.query_start,
b.usename,
b.datname
FROM
pg_locks a,
pg_stat_activity b
WHERE
a.pid = b.pid
AND a.granted
),
w AS (
SELECT
r.pid r_pid,
w.pid w_pid
FROM
t_wait w,
t_run r
WHERE
r.locktype IS NOT DISTINCT FROM w.locktype
AND r.database IS NOT DISTINCT FROM w.database
AND r.relation IS NOT DISTINCT FROM w.relation
AND r.page IS NOT DISTINCT FROM w.page
AND r.tuple IS NOT DISTINCT FROM w.tuple
AND r.classid IS NOT DISTINCT FROM w.classid
AND r.objid IS NOT DISTINCT FROM w.objid
AND r.objsubid IS NOT DISTINCT FROM w.objsubid
AND r.transactionid IS NOT DISTINCT FROM w.transactionid
AND r.virtualxid IS NOT DISTINCT FROM w.virtualxid
),
c (
waiter, holder, root_holder, path, deep
) AS (
SELECT
w_pid,
r_pid,
r_pid,
w_pid || '->' || r_pid,
1
FROM
w
UNION
SELECT
w_pid,
r_pid,
c.holder,
w_pid || '->' || c.path,
c.deep + 1
FROM
w t,
c
WHERE
t.r_pid = c.waiter
)
SELECT
t1.waiter,
t1.holder,
t1.root_holder,
path,
t1.deep
FROM
c t1
WHERE
NOT EXISTS (
SELECT
1
FROM
c t2
WHERE
t2.path ~ t1.path
AND t1.path <> t2.path)
ORDER BY
root_holder;

 waiter | holder | root_holder |    path    | deep 
--------+--------+-------------+------------+------
   8791 |   8541 |        8541 | 8791->8541 |    1
(1 row)
```



#### 2.3.19 会话连接

查询最大连接数

```sql
show max_connection；
```

查询当前连接数

```sql
select count(*) from pg_stat_activity;                               --当前连接总数
select count(*) from pg_stat_activity where state = 'active';        --当前活跃连接总数
select max_conn-now_conn as resi_conn from (select setting::int8 as max_conn,(select count(*) from pg_stat_activity) as now_conn from pg_settings where name = 'max_connections') t;                                                --剩余连接总数
```

当前会话pid

```sql
select pg_backend_pid();
```

 是否为ssl连接

```sql
postgres=# select pid,ssl,version,bits,compression,client_dn,client_serial,issuer_dn from pg_stat_ssl;
  pid  | ssl | version | bits | compression | client_dn | client_serial | issuer_dn 
-------+-----+---------+------+-------------+-----------+---------------+-----------
 11687 | t   | TLSv1.2 |  256 | f           |           |               | 
 14544 | f   |         |      |             |           |               | 
  8541 | f   |         |      |             |           |               | 
  8791 | f   |         |      |             |           |               | 
(4 rows)
```



#### 2.3.20 白名单信息

遵循先读上面的，再读下面的，依次顺序读取，只要符合其中一条规则就触发

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
host    all             postgres        0.0.0.0/0               reject
host    all             all             0.0.0.0/0               md5
```

通过系统表查询：

```sql
postgres=# select * from pg_hba_file_rules ;
 line_number | type  |   database    | user_name  |  address  |                 netmask                 | auth_method | options | error 
-------------+-------+---------------+------------+-----------+-----------------------------------------+-------------+---------+-------
          88 | local | {all}         | {all}      |           |                                         | trust       |         | 
          90 | host  | {all}         | {all}      | 127.0.0.1 | 255.255.255.255                         | trust       |         | 
          92 | host  | {all}         | {all}      | ::1       | ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff | trust       |         | 
          95 | local | {replication} | {all}      |           |                                         | trust       |         | 
          96 | host  | {replication} | {all}      | 127.0.0.1 | 255.255.255.255                         | trust       |         | 
          97 | host  | {replication} | {all}      | ::1       | ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff | trust       |         | 
          98 | host  | {all}         | {postgres} | 0.0.0.0   | 0.0.0.0                                 | reject      |         | 
          99 | host  | {all}         | {all}      | 0.0.0.0   | 0.0.0.0                                 | md5         |         | 
(8 rows)
```



#### 2.3.21 事务、快照

当前事务号

txid_current()获得当前事务 ID，如果当前事务没有 ID 则分配一个新的 ID

txid_current_if_assigned()与txid_current()相同，但是在事务没有分配ID时是返回空值而不是分配一个新的事务ID

```sql
postgres=# select txid_current();
 txid_current 
--------------
         1684
(1 row)
```

当前快照

```sql
postgres=# select txid_current_snapshot();
 txid_current_snapshot 
-----------------------
 1686:1686:
(1 row)
```



#### 2.3.22 序列

查询孤儿序列（用nextval方式指定的序列，删除表不会将其序列删除）

```sql
postgres=# SELECT ns.nspname AS schema_name, seq.relname AS seq_name
FROM pg_class AS seq
JOIN pg_namespace ns ON (seq.relnamespace=ns.oid)
WHERE seq.relkind = 'S'
  AND NOT EXISTS (SELECT * FROM pg_depend WHERE objid=seq.oid AND deptype='a')
ORDER BY seq.relname;
 schema_name | seq_name 
-------------+----------
 public      | myseq
(1 row)
```



#### 2.3.23 对象所在表空间

pg_default不会出现在查询结果中

```sql
postgres=# select tb.spcname,t.schemaname,c.relname,c.relkind from pg_class c,pg_tables t,pg_tablespace tb where c.relname = t.tablename and tb.oid = c.reltablespace and tb.spcname not in ('pg_global');
```



#### 2.3.24 查看表某一列的离散程度

- 查看列的离散程度，值越接近0，表示越离散，越接近1，表示存储比较有顺序
- 说明目前表是根据 id 有序存储的

```sql
postgres=# select correlation from pg_stats where tablename='test' and attname='id';
 correlation 
-------------
      1
(1 row)


postgres=# select correlation from pg_stats where tablename='test' and attname='info';
 correlation 
---------------
 -0.0030033381
(1 row)
```



## （三）我要学会怎么玩

### 3.1 常规技巧

#### 3.1.1 复制表数据

只复制表结构

```sql
CREATE TABLE bas_cm_customer_bak AS (SELECT * from bas_cm_customer limit 0);
CREATE TABLE bas_cm_customer_bak (LIKE bas_cm_customer);
```

只复制表数据

```sql
INSERT INTO bas_cm_customer_bak (field1,field...) SELECT field1,field2... FROM bas_cm_customer;
INSERT INTO bas_cm_customer_bak SELECT * FROM bas_cm_customer;
```

复制表结构及数据

```sql
CREATE TABLE bas_cm_customer_bak AS(SELECT * FROM bas_cm_customer);
SELECT * INTO bas_cm_customer_bak FROM bas_cm_customer;
```



#### 3.1.2 使用sql方式查看错误日志

创建日志表

```sql
CREATE TABLE pg_log
(
  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  application_name text,
  PRIMARY KEY (session_id, session_line_num)
);
```

使用copy将csv格式的错误日志复制到表中

```sql
copy pg_log from  '/pgdata/data/log/postgresql-2021-01-26_000000.csv' with csv;
```

使用SQL在表中查询

```sql
select * from pg_log;
```



#### 3.1.3 模拟高并发脚本

同时触发100个query的并发连接（shell实现）

 使用shell脚本模拟并发连接 

```shell
shell> vi high_concurrency_query.sh 

#!/bin/bash 
export PATH=/postgresql/app/bin 
export PG_HOST=192.168.238.174 
export USER=hzmc 
export PG_PWD=Hzmc321# 
export PG_TCP_PORT=5432 

normalcount=0 
errorcount=0 
count=1 
while [ $count -le 100 ] 
do 
#mysql -uhzmc -e"select sleep(3600);" > /tmp/ExecLogon.log 2>&1 & 
psql -c "select tbl_test1.info,tbl_test2.c_time from tbl_test1 left join tbl_test2 ON tbl_test1.id=tbl_test2.id ORDER BY tbl_test1.info DESC limit 1" > /tmp/ExecLogon.log 2>&1 & 
if [ $? -eq 0 ];then
let normalcount++ 
else 
let errorcount++ 
fi 
echo "Logon $normalcount is Done." 
if [ $errorcount -ne 0 ];then 
echo "Logon $errorcount is Failed." 
fi 
let count++ 
done 
echo "Normal Counts: $normalcount" 
echo "Error Counts: $errorcount"
```

启动并发连接（query） 

```shell
shell> nohup sh high_concurrency_query.sh > /tmp/ExecLogon2.log 2>&1 & 
shell> ps -ef|grep -w "\-uhzm[c]"|awk '{print $2}'|wc -l 
100 
```

手动kill连接进程（异常关闭） 

```shell
shell> ps -ef|grep -w "\-uhzm[c]"|awk '{print $2}'|xargs kill -9 
```



#### 3.1.4 限制某个用户的最大连接数

```sql
alter user chm connection limit -1;
```



#### 3.1.5 更改pg_wal的目录

关闭数据库

```shell
pg_ctl stop -D $PGDATA
```

将pg_wal目录整个移动走

```shell
mv /pgdata/data/pg_wal /tmp/ 
```

创建pg_wal软链接

```shell
ln -s /tmp/pg_wal /pgdata/data/pg_wal
```

启动数据库

```shell
pg_ctl start -D $PGDATA
```



#### 3.1.6 修改错误日志等级

```
vi $PGDATA/postgresql.conf

log_min_messages = warning
# values in order of decreasing detail:
# 控制写到服务器日志里的信息的详细程度。有效值是DEBUG5， DEBUG4，*
# debug5* 
# DEBUG3，DEBUG2，DEBUG1， INFO，NOTICE，WARNING， ERROR，LOG* 
# 每个级别都包含它后面的级别。越靠后的数值 发往服务器日志的信息越少，
# 缺省是WARNING
```

修改完成后重新加载配置文件即可

```shell
pg_ctl reload -D $PGDATA
```



#### 3.1.7 修改参数并生效

查看参数

```sql
show logging_collector;
select current_setting('logging_collector');
select name,setting from pg_settings where name = 'logging_collector';
```

修改参数

```sql
alter system set logging_collector = 'on' ;  
alter system set logging_collector = default;            #设置为默认值
set work_mem to '5GB' ;                                  #临时修改
```

生效参数（不需要重启生效的参数）

```
select pg_reload_conf();
pg_ctl reload -D $PGDATA
```

查看是否需要重启生效

```sql
select name,context from pg_settings where name = 'logging_collector';
```

<u>context的含义:</u>

| 参数值            | 含义                                                         |
| ----------------- | ------------------------------------------------------------ |
| internal          | 这些设置不能被直接修改，它们反映了内部决定的值。某些可能在使用不同配置选项重建系统时或者改变initdb的选项时可以调整。 |
| postmaster        | 这些设置只能在服务器启动时应用，因此任何修改都**需要重启服务器**。 |
| sighup            | 对于这些设置的修改可以在postgresql.conf中完成并且**不需要重启服务器**。 |
| superuser-backend | 对于这些设置的更改可以在postgresql.conf中进行而**无需重启服务器**。只有在连接用户是超级用户时才能这样做。在会话启动后永不变化。 |
| backend           | 对于这些设置的修改可以在postgresql.conf中完成并且**不需要重启服务器**。任何用户都可以为这个会话做这种修改。在会话启动后永不变化。 |
| superuser         | 这些设置可以从postgresql.conf设置，或者在会话中用SET命令设置。仅当没有通过SET设置会话本地值时，postgresql.conf中的改变才会影响现有的会话。 |
| user              | 这些设置可以从postgresql.conf设置，或者在会话中用SET命令设置。任何用户都被允许修改它们的会话本地值。仅当没有通过SET设置会话本地值时，postgresql.conf中的改变才会影响现有的会话。 |



#### 3.1.8 删除几天前的日志

删除文件

```shell
find /pgdata/data/log/* -type f -mtime +7 -exec rm -f {} \;         #7天前的（不包括7）
find /pgdata/data/log/* -type f -mtime 7 -exec rm -f {} \;          #7天前的【一天内被修改】
find /data/shanchu/test/*.txt -mtime -3 -type f | xargs rm -rf      #3天内的（包括3）
```

删除文件夹

```shell
find /data/shanchu/test* -mtime -1 -type d | xargs rm -rf
```

查找以"前一天"命名的文件夹

```shell
find /akcld/pgsql/pgbak_physical/$(date -d last-day +"%Y-%m-%d")
```

查找1200分钟合计20小时前的目录

```shell
find /home/postgres/media* -maxdepth 0 -type d -mmin +1200
```



#### 3.1.9 查杀会话

查看当前和会话pid

```sql
SELECT pg_backend_pid();
```

杀会话

```sql
SELECT pg_terminate_backend(pid)
#8.4版本之前pg_cancel_backend用来取消该进程进行查询操作，但不能释放连接
```

杀死所有idle进程

```sql
select pg_terminate_backend(pid) from pg_stat_activity where state='idle';
```



#### 3.1.10 暂停/继续恢复wal日志应用

| 函数                      | 返回类型 | 作用             |
| ------------------------- | -------- | ---------------- |
| pg_is_wal_replay_paused() | bool     | 恢复被暂停返回真 |
| pg_wal_replay_pause()     | void     | 暂停应用         |
| pg_wal_replay_resume()    | void     | 恢复应用         |



#### 3.1.11 通用表达式（CTE）with as

- with子句只能被select查询块引用。
- with子句的返回结果存到用户的临时表空间中，只做一次查询，反复使用,提高效率。
- 在同级select前有多个查询定义的时候，第1个用with，后面的不用with，并且用逗号隔开。
- 最后一个with 子句与下面的查询之间不能有逗号，只通过右括号分割，with 子句的查询必须用括号括起来。

<u>举例:</u>

```sql
with t1 as(SELECT count(*) a1 from pg_stat_activity where length(query)=6),
t2 as (SELECT count(*) a2 from pg_stat_activity ),
t3 as (select setting a3 from pg_settings where name = 'max_connections')
select t2.a2-t1.a1 as activity_conn,t3.a3 as max_conn from t1,t2,t3 ;
```



#### 3.1.12 启用ssl连接

查看postgresql是否使用openssl选项编译安装，没有则需重新编译

```shell
$ pg_config|grep CONFIGURE

CONFIGURE = '--prefix=/opt/pgsql' '--enable-nls' '--with-perl' '--with-python' '--with-tcl' '--with-gssapi' '--with-openssl' '--with-pam' '--with-ldap' '--with-libxml' '--with-libxslt'
```

创建私钥

```shell
# openssl genrsa -des3 -out server.key 1024
```

删除私钥密码

```shell
# openssl rsa -in server.key -out server.key
```

修改私钥权限及属组

```shell
# chmod 400 server.key
```

创建服务器证书

```shell
# openssl req -new -key server.key -days 3650 -out server.crt -x509
```

拷贝服务器证书作为自己的签名证书

```shell
# cp server.crt root.crt
```

拷贝证书文件到数据目录

```shell
# cp ./{server.crt,server.key,root.crt} /software/pgsql13/data/
# chown postgres:postgres /software/pgsql13/data/{server.crt,server.key,root.crt}
```

修改postgresql.conf并重启数据库

```shell
$ vi $PGDATA/postgresql.conf
ssl = on
ssl_ca_file = 'root.crt'
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

创建一个用户ssl连接的用户进行测试

```sql
postgres=# create user sslconn;
CREATE ROLE
```

修改白名单pg_hba.conf，加入以下条目

```
hostssl  all  sslconn  192.168.0.0/16  md5
```

连接测试

```sql
$ psql -h 124.222.13.97 -U sslconn -d postgres -p 5432
Password for user sslconn: 
psql (13.4)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=>
```



#### 3.1.13 标准授权

**-- Revoke privileges from 'public' role**（移除公共权限）

```sql
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE mydatabase FROM PUBLIC;
```

**-- Read-only role**（只读用户组）

```sql
CREATE ROLE readonly;
GRANT CONNECT ON DATABASE mydatabase TO readonly;
GRANT USAGE ON SCHEMA myschema TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA myschema TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA myschema GRANT SELECT ON TABLES TO readonly;
```

**-- Read/write role**（读写用户组）

```sql
CREATE ROLE readwrite;
GRANT CONNECT ON DATABASE mydatabase TO readwrite;
GRANT USAGE, CREATE ON SCHEMA myschema TO readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA myschema TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA myschema GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA myschema TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA myschema GRANT USAGE ON SEQUENCES TO readwrite;
```

**-- Users creation**（用户创建）

```sql
CREATE USER reporting_user1 WITH PASSWORD 'some_secret_passwd';
CREATE USER reporting_user2 WITH PASSWORD 'some_secret_passwd';
CREATE USER app_user1 WITH PASSWORD 'some_secret_passwd';
CREATE USER app_user2 WITH PASSWORD 'some_secret_passwd';
```

**-- Grant privileges to users**（授予用户用户组权限）

```sql
GRANT readonly TO reporting_user1;
GRANT readonly TO reporting_user2;
GRANT readwrite TO app_user1;
GRANT readwrite TO app_user2;
```



#### 3.1.14 关闭自动提交（autocommit）

使用完整的事务

```sql
begin;
delete from test;
end;
```

关闭自动提交功能

```sql
\set AUTOCOMMIT off
```



#### 3.1.15 数据误删除

**【列数据误删除】**

创建测试表test，并插入测试数据

```sql
dbtest=# create table test(id int,name varchar(20));
CREATE TABLE
dbtest=# insert into test values (1,'a'),(2,'b'),(3,'c');
INSERT 0 3
dbtest=# select * from test ;
 id | name 
----+------
  1 | a
  2 | b
  3 | c
(3 rows)
```

查询表的列信息

```sql
dbtest=# select oid from pg_class where relname = 'test';
  oid  
-------
 24780
(1 row)

dbtest=# select attrelid,attname,attisdropped,atttypid,attrelid,attnum from pg_attribute where attrelid = 24780 and attname = 'name';
 attrelid | attname | attisdropped | atttypid | attrelid | attnum 
----------+---------+--------------+----------+----------+--------
    24780 | name    | f            |     1043 |    24780 |      2
(1 row)
```

模拟删除"name"列，并查询该列信息

```sql
dbtest=# alter table test drop column name ;
ALTER TABLE
dbtest=# select attrelid,attname,attisdropped,atttypid,attrelid,attnum from pg_attribute where attrelid = 24780 and attisdropped = 't';
 attrelid |           attname            | attisdropped | atttypid | attrelid | attnum 
----------+------------------------------+--------------+----------+----------+--------
    24780 | ........pg.dropped.2........ | t            |        0 |    24780 |      2
(1 row)
```

根据pg_attribute系统表查询误操作表的字段信息，将删除标记attisdropped恢复为'f'，attname为列名，atttypid为列的数据类型，attrelid列所属的表，attnum为列的编号，2.2步骤可获取以上信息，其中列的数据类型可通过常见相同字段类型的测试表来获知。

```sql
dbtest=# update pg_attribute set attisdropped='f',attname='name',atttypid=1043 where attrelid=24780 and attnum =2;
UPDATE 1
```

查询表数据库，验证是否恢复成功

```sql
dbtest=# select * from test ;
 id | name 
----+------
  1 | a
  2 | b
  3 | c
(3 rows)
dbtest=# select attrelid,attname,attisdropped,atttypid,attrelid,attnum from pg_attribute where attrelid = 24780 and attname = 'name';
 attrelid | attname | attisdropped | atttypid | attrelid | attnum 
----------+---------+--------------+----------+----------+--------
    24780 | name    | f            |     1043 |    24780 |      2
(1 row)
```



**【delete误删除】**

创建测试表novels，并插入测试数据

```SQL
dbtest=# create table novels (name varchar(200), id int);
CREATE TABLE
dbtest=# insert into novels values('三国演义',1);
INSERT 0 1
dbtest=# insert into novels values('水浒传',2);
INSERT 0 1
dbtest=# insert into novels values('西游记',3);
INSERT 0 1
dbtest=# insert into novels values('红楼梦',4);
```

查询测试表的文件位置

```SQL
dbtest=# select oid from pg_database where datname='dbtest';

  oid  
-------

 16571
(1 row)

dbtest=# select oid,relfilenode from pg_class where relname='novels';
  oid  | relfilenode 
-------+-------------
 24783 |       24783
(1 row)
```

也可以通过函数获取表文件位置

```SQL
dbtest=# select pg_relation_filepath(' novels ');
pg_relation_filepath 
----------------------
 base/16571/24783
(1 row)
```

模拟delete删除测试表的数据

```SQL
dbtest=# delete from novels;
DELETE 4
dbtest=# select * from novels;
 name | id 
------+----
(0 rows)
```

安装pg_filedump
本操作文档通过pg_filedump插件解析表文件来获取数据，我们通过git下载并安装

```SHELL
[root@VM-4-13-centos ~]# yum install git -y
[postgres@VM-4-13-centos ~]$ cd pg_filedump/
[postgres@VM-4-13-centos pg_filedump]$ make
[postgres@VM-4-13-centos pg_filedump]$ make install
/usr/bin/mkdir -p '/software/pgsql13/bin'
/usr/bin/install -c  pg_filedump '/software/pgsql13/bin'
```

解析删除的数据
解析被删除的数据之前首先查询表在删除时间点之后是否被vacuum（包括手动vacuum和autovacuum）

```SQL
dbtest=# \x
Expanded display is on.
dbtest=# select * from pg_stat_all_tables where relname = 'novels';
-[ RECORD 1 ]-------+------------------------------
relid               | 24783
schemaname          | public
relname             | novels
seq_scan            | 13
seq_tup_read        | 44
idx_scan            | 
idx_tup_fetch       | 
n_tup_ins           | 28
n_tup_upd           | 0
n_tup_del           | 22
n_tup_hot_upd       | 0
n_live_tup          | 6
n_dead_tup          | 18
n_mod_since_analyze | 50
n_ins_since_vacuum  | 24
last_vacuum         | 2022-02-09 11:27:30.501748+08
last_autovacuum     | 
last_analyze        | 
last_autoanalyze    | 
vacuum_count        | 1
autovacuum_count    | 0
analyze_count       | 0
autoanalyze_count   | 0
```

如果没有被vacuum，则关闭表级别的autovacuum并开始解析步骤

```SQL
dbtest=# alter table novels set (autovacuum_enabled = off);
```

通过上述步骤查询到的表数据文件来解析被删除的数据

```SHELL
[postgres@VM-4-13-centos data]$ pg_filedump -D charn,int base/16571/24783

*******************************************************************

* PostgreSQL File/Block Formatted Dump Utility
  *
* File: base/16571/24783
* Options used: -D charn,int

*******************************************************************

Block    0 ********************************************************

<Header> -----
 Block Offset: 0x00000000         Offsets: Lower      40 (0x0028)
 Block: Size 8192  Version    4            Upper    8024 (0x1f58)
 LSN:  logid      0 recoff 0x070351c0      Special  8192 (0x2000)
 Items:    4                      Free Space: 7984
 Checksum: 0x0000  Prune XID: 0x00000242  Flags: 0x0000 ()
 Length (including item array): 40

<Data> -----
 Item   1 -- Length:   44  Offset: 8144 (0x1fd0)  Flags: NORMAL
COPY: 三国演义        1
 Item   2 -- Length:   40  Offset: 8104 (0x1fa8)  Flags: NORMAL
COPY: 水浒传        2
 Item   3 -- Length:   40  Offset: 8064 (0x1f80)  Flags: NORMAL
COPY: 西游记        3
 Item   4 -- Length:   40  Offset: 8024 (0x1f58)  Flags: NORMAL
COPY: 红楼梦        4
```

可以使用以下命令来过滤需要的数据

```SQL
[postgres@VM-4-13-centos data]$ pg_filedump -D charn,int base/16571/24783|grep COPY
COPY: 三国演义        1
COPY: 水浒传        2
COPY: 西游记        3
COPY: 红楼梦        4
```

我们将COPY字段过滤并写入需要的数据到csv文件中

```SQL
[postgres@VM-4-13-centos data]$ pg_filedump -D varchar,int base/16571/24783|grep COPY|sed 's/\COPY: //g' > import.csv
[postgres@VM-4-13-centos data]$ more import.csv 
三国演义        1
水浒传        2
西游记        3
红楼梦        4
```

恢复数据到原表中
使用copy命令导入csv文件中的数据，并验证数据是否恢复

```sql
dbtest=# copy novels from '/software/pgsql13/data/import.csv';
dbtest=# select * from novels ;
   name   | id 
----------+----
 三国演义 |  1
 水浒传   |  2
 西游记   |  3
 红楼梦   |  4
(4 rows)
```



<a name="dml误删除">【dml误删除】 </a>

创建测试表novels，并插入测试数据

```sql
dbtest=# create table novels (name varchar(200), id int);
CREATE TABLE
dbtest=# insert into novels select md5(random()::text),generate_series(1,10);
INSERT 0 10
```

安装pageinspect扩展获取元组记录信息

```sql
dbtest=# create extension pageinspect ;
CREATE EXTENSION
```

查询表的事务操作记录
使用扩展pageinspect中的函数查询当前表的事务操作记录

```sql
dbtest=# select * from heap_page_items(get_raw_page('novels','main', 0));
 lp | lp_off | lp_flags | lp_len | t_xmin | t_xmax | t_field3 | t_ctid | t_infomask2 | t_infomask | t_hoff | t_bits | t_oid |     
                                  t_data                                       

----+--------+----------+--------+--------+--------+----------+--------+-------------+------------+--------+--------+-------+-----
-------------------------------------------------------------------------------

  1 |   8128 |        1 |     64 |    651 |      0 |        0 | (0,1)  |           2 |       2050 |     24 |        |       | \x43
613731663139343239303330323262313732613039383366633066396562663600000001000000
  2 |   8064 |        1 |     64 |    651 |      0 |        0 | (0,2)  |           2 |       2050 |     24 |        |       | \x43
386633363838333134386434323539306265613033636434386536393232383400000002000000
  3 |   8000 |        1 |     64 |    651 |      0 |        0 | (0,3)  |           2 |       2050 |     24 |        |       | \x43
363535323364663966616531663935666538383632646239383166633962623600000003000000
  4 |   7936 |        1 |     64 |    651 |      0 |        0 | (0,4)  |           2 |       2050 |     24 |        |       | \x43
333763383035386564303434316133366438656133333764613837626362616600000004000000
  5 |   7872 |        1 |     64 |    651 |      0 |        0 | (0,5)  |           2 |       2050 |     24 |        |       | \x43
663833356234353939623566336661336662376630323234363133663139663800000005000000
  6 |   7808 |        1 |     64 |    651 |      0 |        0 | (0,6)  |           2 |       2050 |     24 |        |       | \x43
626336623539373031316565396437333236363965313937323265373736333100000006000000
  7 |   7744 |        1 |     64 |    651 |      0 |        0 | (0,7)  |           2 |       2050 |     24 |        |       | \x43
646633323365396535356166376538386632376139666431643739303736356600000007000000
  8 |   7680 |        1 |     64 |    651 |      0 |        0 | (0,8)  |           2 |       2050 |     24 |        |       | \x43
393865616338366430323137363466626462616539333831636436646137333200000008000000
  9 |   7616 |        1 |     64 |    651 |      0 |        0 | (0,9)  |           2 |       2050 |     24 |        |       | \x43
333766383764653134633235666664643563663832313836643064326138653600000009000000
 10 |   7552 |        1 |     64 |    651 |      0 |        0 | (0,10) |           2 |       2050 |     24 |        |       | \x43
32333636613934363930393830316562376564366537376630366231626362610000000a000000
(10 rows)
```

模拟删除表数据
删除id为5的数据，再次查看该表的事务操作记录，可以看到标红处id为5的记录其删除事务号为652

```sql
dbtest=# delete from novels where id = 5;
DELETE 1
dbtest=# select * from heap_page_items(get_raw_page('novels','main', 0));
 lp | lp_off | lp_flags | lp_len | t_xmin | t_xmax | t_field3 | t_ctid | t_infomask2 | t_infomask | t_hoff | t_bits | t_oid |     
                                  t_data                                       

----+--------+----------+--------+--------+--------+----------+--------+-------------+------------+--------+--------+-------+-----
-------------------------------------------------------------------------------

  1 |   8128 |        1 |     64 |    651 |      0 |        0 | (0,1)  |           2 |       2306 |     24 |        |       | \x43
613731663139343239303330323262313732613039383366633066396562663600000001000000
  2 |   8064 |        1 |     64 |    651 |      0 |        0 | (0,2)  |           2 |       2306 |     24 |        |       | \x43
386633363838333134386434323539306265613033636434386536393232383400000002000000
  3 |   8000 |        1 |     64 |    651 |      0 |        0 | (0,3)  |           2 |       2306 |     24 |        |       | \x43
363535323364663966616531663935666538383632646239383166633962623600000003000000
  4 |   7936 |        1 |     64 |    651 |      0 |        0 | (0,4)  |           2 |       2306 |     24 |        |       | \x43
333763383035386564303434316133366438656133333764613837626362616600000004000000
  5 |   7872 |        1 |     64 |    651 |    652 |        0 | (0,5)  |        8194 |        258 |     24 |        |       | \x43
663833356234353939623566336661336662376630323234363133663139663800000005000000
  6 |   7808 |        1 |     64 |    651 |      0 |        0 | (0,6)  |           2 |       2306 |     24 |        |       | \x43
626336623539373031316565396437333236363965313937323265373736333100000006000000
  7 |   7744 |        1 |     64 |    651 |      0 |        0 | (0,7)  |           2 |       2306 |     24 |        |       | \x43
646633323365396535356166376538386632376139666431643739303736356600000007000000
  8 |   7680 |        1 |     64 |    651 |      0 |        0 | (0,8)  |           2 |       2306 |     24 |        |       | \x43
393865616338366430323137363466626462616539333831636436646137333200000008000000
  9 |   7616 |        1 |     64 |    651 |      0 |        0 | (0,9)  |           2 |       2306 |     24 |        |       | \x43
333766383764653134633235666664643563663832313836643064326138653600000009000000
 10 |   7552 |        1 |     64 |    651 |      0 |        0 | (0,10) |           2 |       2306 |     24 |        |       | \x43
32333636613934363930393830316562376564366537376630366231626362610000000a000000
(10 rows)
```

关闭表级别的autovacuum
解析被删除的数据之前首先查询表在删除时间点之后是否被vacuum（包括手动vacuum和autovacuum）

```sql
dbtest=# \x
Expanded display is on.
dbtest=# select * from pg_stat_all_tables where relname = 'novels';
-[ RECORD 1 ]-------+------------------------------
relid               | 24783
schemaname          | public
relname             | novels
seq_scan            | 13
seq_tup_read        | 44
idx_scan            | 
idx_tup_fetch       | 
n_tup_ins           | 28
n_tup_upd           | 0
n_tup_del           | 22
n_tup_hot_upd       | 0
n_live_tup          | 6
n_dead_tup          | 18
n_mod_since_analyze | 50
n_ins_since_vacuum  | 24
last_vacuum         | 2022-02-09 11:27:30.501748+08
last_autovacuum     | 
last_analyze        | 
last_autoanalyze    | 
vacuum_count        | 1
autovacuum_count    | 0
analyze_count       | 0
autoanalyze_count   | 0
```

如果没有被vacuum，则关闭表级别的autovacuum并开始解析步骤

```sql
dbtest=# alter table novels set (autovacuum_enabled = off);
```

关闭数据库重置事务id
关闭数据库服务，使用pg_resetwal工具重置事务id，使得下一个事务id从652开始

```shell
[postgres@VM-4-13-centos ~]$ pg_ctl stop
[postgres@VM-4-13-centos data]$ pg_resetwal -x 652 -D $PGDATA
Write-ahead log reset
```

启动数据库
启动数据库，查看数据是否找回，并重建表导出导入数据

```shell
[postgres@VM-4-13-centos ~]$ pg_ctl start
waiting for server to start....2022-02-09 14:56:51.938 CST [27058] LOG:  redirecting log output to logging collector process
2022-02-09 14:56:51.938 CST [27058] HINT:  Future log output will appear in directory "log".
 done
server started
[postgres@VM-4-13-centos ~]$ psql -ddbtest
```

```sql
psql (13.4)
Type "help" for help.

dbtest=# 
dbtest=# select xmin,xmax,id from novels ;
 xmin | xmax | id 
------+------+----
  651 |    0 |  1
  651 |    0 |  2
  651 |    0 |  3
  651 |    0 |  4
  651 |  652 |  5
  651 |    0 |  6
  651 |    0 |  7
  651 |    0 |  8
  651 |    0 |  9
  651 |    0 | 10
(10 rows)
```

可以使用pg_dump/pg_restore重建表

```shell
[postgres@VM-4-13-centos ~]$ pg_dump -Fc -U postgres -t novels -f novels.sql -d dbtest
```

导出表数据后重命名原表

```sql
dbtest=# alter table novels rename to novelsbak;
```

pg_restore恢复数据

```shell
[postgres@VM-4-13-centos ~]$ pg_restore -d dbtest novels.sql -c --if-exists
```

最后，验证数据完整性

```sql
dbtest=# select * from novels ;
               name               | id 
----------------------------------+----
 a63e2f63c5dbec9065a788f6e774b9ce |  1
 092465fb1c7b58adea3b35b4a5de5fd9 |  2
 1559907b48d5e8efaeddbdace55efad2 |  3
 3f47e858647d8ef838fbaa7e87b3bc07 |  4
 430f91a034857bf996f51cbe1dc6bef3 |  5
 56d65c982438ed56724e3dae4c5e7933 |  6
 4dbecc8fb3d3a8acca631ed359685011 |  7
 98023e6140984d125cc19ee4ba33608f |  8
 f2570c845be93fdf36e9d7c3f4d34ccf |  9
 7d9d3a65770df1573ec58c349d3216f0 | 10
(10 rows)
```



#### 3.1.16 告警/错误日志最佳实践

默认stderr,建议csvlog，可以导入到数据库中方便查看，该配置方案只保留7天的日志，进行循环覆盖

```sql
alter system set log_destination='csvlog';
alter system set log_filename='postgresql-%a.log';
alter system set log_truncate_on_rotation=on;
alter system set log_rotation_age=1d;
alter system set log_rotation_size=0;
```

- log_destination。PostgreSQL支持多种方法来记录服务器消息，包括stderr、csvlog和syslog。在 Windows 上还支持eventlog。设置这个参数为一个由想要的日志目的地的列表，之间用逗号分隔。默认值是只记录到stderr
- log_filename。当logging_collector被启用时，这个参数设置被创建的日志文件的文件名
- log_truncate_on_rotation。当logging_collector被启用时，这个参数将导致PostgreSQL截断（覆盖而不是追加）任何已有的同名日志文件
- log_rotation_age。当logging_collector被启用时，这个参数决定一个个体日志文件的最长生命期
- log_rotation_size。当logging_collector被启用时，这个参数决定一个个体日志文件的最大尺寸

形式如下

```shell
[postgres@VM-4-13-centos ~]$ ls -lrt /software/pgsql13/data/log/
total 796
-rwxr-xr-x 1 postgres postgres      0 Jul 14 00:00 postgresql-Thu.log
-rwxr-xr-x 1 postgres postgres  17486 Jul 14 23:12 postgresql-Thu.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 15 00:00 postgresql-Fri.log
-rwxr-xr-x 1 postgres postgres 691785 Jul 15 22:48 postgresql-Fri.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 16 00:00 postgresql-Sat.log
-rwxr-xr-x 1 postgres postgres  11832 Jul 16 21:22 postgresql-Sat.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 17 00:00 postgresql-Sun.log
-rwxr-xr-x 1 postgres postgres  11249 Jul 17 20:36 postgresql-Sun.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 18 00:00 postgresql-Mon.log
-rwxr-xr-x 1 postgres postgres  11174 Jul 18 23:46 postgresql-Mon.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 19 00:00 postgresql-Tue.log
-rwxr-xr-x 1 postgres postgres  20876 Jul 19 23:05 postgresql-Tue.csv
-rwxr-xr-x 1 postgres postgres      0 Jul 20 00:00 postgresql-Wed.log
-rwxr-xr-x 1 postgres postgres  34682 Jul 20 16:52 postgresql-Wed.csv
```



#### 3.1.17 获取对象的DDL语句

| 获取类型 | 语句                                                         |
| -------- | ------------------------------------------------------------ |
| 索引     | select pg_get_indexdef('tbl_test1_id_info_c_time_idx'::regclass); |
| 视图     | select pg_get_viewdef('view_test'::regclass);                |
| 函数     | select pg_get_functiondef('function_test'::regclass);        |
| 触发器   | select pg_get_triggerdef('trigger_test'::regclass);          |
| 分区表   | select pg_get_partkeydef(''::regclass);                      |
| 规则     | select pg_get_ruledef(''::regclass);                         |
| 表       | pg_dump -U postgres -d postgres -s -t tbl_test1              |

另外表的DDL获取方式还有：

```sql
CREATE OR REPLACE FUNCTION generate_create_table_statement(p_table_name varchar)
  RETURNS text AS
$BODY$
DECLARE
    v_table_ddl   text;
    column_record record;
BEGIN
    FOR column_record IN 
        SELECT 
            b.nspname as schema_name,
            b.relname as table_name,
            a.attname as column_name,
            pg_catalog.format_type(a.atttypid, a.atttypmod) as column_type,
            CASE WHEN 
                (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                 FROM pg_catalog.pg_attrdef d
                 WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) IS NOT NULL THEN
                'DEFAULT '|| (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
                              FROM pg_catalog.pg_attrdef d
                              WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef)
            ELSE
                ''
            END as column_default_value,
            CASE WHEN a.attnotnull = true THEN 
                'NOT NULL'
            ELSE
                'NULL'
            END as column_not_null,
            a.attnum as attnum,
            e.max_attnum as max_attnum
        FROM 
            pg_catalog.pg_attribute a
            INNER JOIN 
             (SELECT c.oid,
                n.nspname,
                c.relname
              FROM pg_catalog.pg_class c
                   LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
              WHERE c.relname ~ ('^('||p_table_name||')$')
                AND pg_catalog.pg_table_is_visible(c.oid)
              ORDER BY 2, 3) b
            ON a.attrelid = b.oid
            INNER JOIN 
             (SELECT 
                  a.attrelid,
                  max(a.attnum) as max_attnum
              FROM pg_catalog.pg_attribute a
              WHERE a.attnum > 0 
                AND NOT a.attisdropped
              GROUP BY a.attrelid) e
            ON a.attrelid=e.attrelid
        WHERE a.attnum > 0 
          AND NOT a.attisdropped
        ORDER BY a.attnum
    LOOP
        IF column_record.attnum = 1 THEN
            v_table_ddl:='CREATE TABLE '||column_record.schema_name||'.'||column_record.table_name||' (';
        ELSE
            v_table_ddl:=v_table_ddl||',';
        END IF;

        IF column_record.attnum <= column_record.max_attnum THEN
            v_table_ddl:=v_table_ddl||chr(10)||
                     '    '||column_record.column_name||' '||column_record.column_type||' '||column_record.column_default_value||' '||column_record.column_not_null;
        END IF;
    END LOOP;
     
    v_table_ddl:=v_table_ddl||');';
    RETURN v_table_ddl;

END;
$BODY$
  LANGUAGE 'plpgsql' COST 100.0 SECURITY INVOKER;

SELECT generate_create_table_statement('tbl_test1');
```



### 3.2  自带工具

#### 3.2.1 pg_rewind时间线修复

在流复制环境下，主备库都设置开启归档，要使用rewind功能，必须开启full_page_writes必须开启data_checksums或wal_log_hints。

| IP地址         | 端口 | 数据目录     | 备注 |
| -------------- | ---- | ------------ | ---- |
| 192.168.22.128 | 5432 | /pgdata/data | 主库 |
| 192.168.22.129 | 5432 | /pgdata/data | 备库 |

**【一、回退只读从库】**

（1）模拟激活从库

激活只读从库，使从库能够读写。

```shell
$ pg_ctl promote -D /pgdata/data
```

（2）模拟从库正常写入

在从库中写入数据，生成wal日志

```shell
$ pgbench -M prepared -v -r -P 1 -c 4 -j 4 -T 120 -p 5432
starting vacuum...end.
starting vacuum pgbench_accounts...end.
```

此时从库和主库已不在同一个时间线上
从库时间线

```shell
$ pg_controldata | grep TimeLineID
Latest checkpoint's TimeLineID:       9
Latest checkpoint's PrevTimeLineID:   9
```

主库时间线

```shell
$ pg_controldata | grep TimeLineID
Latest checkpoint's TimeLineID:       8
Latest checkpoint's PrevTimeLineID:   8
```

（3）修复从库

查看切换点。

```shell
$ ll $PGDATA/pg_wal/*.history
```

查看最新时间线的.history文件。

```shell
$ cat 00000009.history
5/5A000060
```

从00000009000000050000005A开始，所有的wal必须存在从库pg_wal目录中。如果已经覆盖了，必须从归档目录拷贝到从库pg_wal目录中，也可以直接将归档文件全部拷贝到pg_wal目录下。

```shell
$ cp /mnt/server/archivedir/* /pgdata/data/pg_wal/          #/mnt/server/archivedir/为归档目录
```

停掉从库。

```shell
$ pg_ctl stop -m fast -D /pgdata/data
```

测试修复是否能够成功。

```shell
$ pg_rewind -n -D /pgdata/data --source-server="hostaddr=192.168.22.128 user=postgres port=5432"
pg_rewind: servers diverged at WAL location 5/5A000060 on timeline 8
pg_rewind: rewinding from last common checkpoint at 5/59000060 on timeline 8
pg_rewind: Done!
```

可以修复，直接修复。

```shell
$ pg_rewind -D /pgdata/data --source-server="hostaddr=192.168.22.128 user=postgres port=5432"
pg_rewind: servers diverged at WAL location 5/5A000060 on timeline 8
pg_rewind: rewinding from last common checkpoint at 5/59000060 on timeline 8
pg_rewind: Done!
```

修改配置文件postgresql.auto.conf。

```shell
$ vi postgresql.auto.conf

primary_conninfo = 'user=repl passfile=''/home/postgres/.pgpass'' host=192.168.22.128 port=5432 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
restore_command = 'cp /mnt/server/archivedir/%f %p'
recovery_target_timeline = 'latest'  
```

删除错误时间线上产生的归档，即走到时间线00000009上的归档。

```shell
$ mkdir /mnt/server/archivedir/error_tl_9
$ mv 00000009* error_tl_9
```

创建从库标识文件。

```shell
$ touch /pgdata/data/standby.signal
```

（4）启动从库

```shell
$ pg_ctl start -D /pgdata/data
```

在主库上查看流复制同步状态。

```sql
postgres=# select client_addr,sync_state from pg_stat_replication;
  client_addr   | sync_state 
----------------+------------
 192.168.22.128 | async
```



**【二、降级读写主库】**

（1）模拟激活从库

激活只读从库，使从库能够读写。

```shell
$ pg_ctl promote -D /pgdata/data
```

（2）模拟写入主库、从库

在从库中写入数据，生成wal日志

```shell
$ pgbench -M prepared -v -r -P 1 -c 4 -j 4 -T 120 -p 5432
starting vacuum...end.
starting vacuum pgbench_accounts...end.
```

在主库中写入数据，生成wal日志

```shell
$ pgbench -M prepared -v -r -P 1 -c 4 -j 4 -T 120 -p 5432
starting vacuum...end.
starting vacuum pgbench_accounts...end.
```

此时从库和主库已不在同一个时间线上。
从库时间线。

```shell
$ pg_controldata | grep TimeLineID
Latest checkpoint's TimeLineID:       9
Latest checkpoint's PrevTimeLineID:   9
```

主库时间线。

```shell
$ pg_controldata | grep TimeLineID
Latest checkpoint's TimeLineID:       8
Latest checkpoint's PrevTimeLineID:   8
```

（3）修复老主库

查看切换点。

```shell
$ ll $PGDATA/pg_wal/*.history
```

查看最新时间线的.history文件。

```shell
$ cat 00000008.history
5/37000000
```

从000000080000000500000037开始，所有的wal必须存在从库pg_wal目录中。如果已经覆盖了，必须从归档目录拷贝到从库pg_wal目录中，也可以直接将归档文件全部拷贝到pg_wal目录下。

```shell
$ cp /mnt/server/archivedir/* /pgdata/data/pg_wal/            #/mnt/server/archivedir/为归档目录
```

停掉老主库。

```shell
$ pg_ctl stop -m fast -D /pgdata/data
```

测试修复是否能够成功。

```shell
$ pg_rewind -n -D /pgdata/data --source-server="hostaddr=192.168.22.129 user=postgres port=5432"
pg_rewind: servers diverged at WAL location 5/37000000 on timeline 8
pg_rewind: rewinding from last common checkpoint at 5/37000000 on timeline 8
pg_rewind: Done!
```

可以修复，直接修复。

```shell
$ pg_rewind -D /pgdata/data --source-server="hostaddr=192.168.22.129 user=postgres port=5432"
pg_rewind: servers diverged at WAL location 5/37000000 on timeline 8
pg_rewind: rewinding from last common checkpoint at 5/37000000 on timeline 8
pg_rewind: Done!
```

修改配置文件postgresql.auto.conf。

```shell
$ vi postgresql.auto.conf

primary_conninfo = 'user=repl passfile=''/home/postgres/.pgpass'' host=192.168.22.128 port=5432 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
restore_command = 'cp /mnt/server/archivedir/%f %p'
recovery_target_timeline = 'latest'  
```

老主库创建从库标识文件。

```shell
$ touch /pgdata/data/standby.signal
```

（4）启动新从库

```shell
$ pg_ctl start -D /pgdata/data
```

在新主库上查看流复制同步状态。

```sql
postgres=# select client_addr,sync_state from pg_stat_replication;
  client_addr   | sync_state 
----------------+------------
 192.168.22.129 | async
```



#### 3.2.2 pg_receivewal流复制

pg_receivewal被用来从一个运行着的PostgreSQL集簇以流的方式得到预写式日志。预写式日志会被使用流复制协议以流的方式传送，并且被写入到文件的一个本地目录。这个目录可以被用作归档位置来做一次使用时间点恢复的恢复

当预写式日志在服务器上被产生时，pg_receivewal实时以流的方式传输预写式日志，并且不像archive_command那样等待段完成。由于这个原因，在使用pg_receivewal时不必设置archive_timeout

选项：

| 参数                                       | 含义                                                         |
| ------------------------------------------ | ------------------------------------------------------------ |
| -D directory<br/>--directory=directory     | 输出写到哪个目录                                             |
| -E lsn<br/>--endpos=lsn                    | 当接收到达指定的LSN时，自动停止复制并且以正常退出状态0退出   |
| --if-not-exists                            | 当指定--create-slot并且具有指定名称 的槽已经存在时不要抛出错误 |
| -n<br/>--no-loop                           | 不要在连接错误上循环。相反，碰到一个错误时立刻退出           |
| --no-sync                                  | 这个选项导致pg_receivewal不强制WAL数据被刷回磁盘。这样会更快，但是也意味着接下来的操作系统崩溃会让WAL段损坏。通常，这个选项对于测试有用，但不应该在对生产部署进行WAL归档时使用。<br/>这个选项与--synchronous不兼容。 |
| -s interval<br/>--status-interval=interval | 指定发送回服务器的状态包之间的秒数。默认值是 10 秒           |
| -S slotname<br/>--slot=slotname            | 要求pg_receivewal使用一个已有的复制槽                        |
| --synchronous                              | 在 WAL 数据被收到后立即刷入到磁盘                            |
| -v<br/>--verbose                           | 启用冗长模式                                                 |
| -Z level<br/>--compress=level              | 启用预写式日志上的gzip压缩，并且指定压缩级别（0到9，0是不压缩而9是最大压缩）。所有的文件名后都将被追加后缀.gz |
| 以下为连接参数                             |                                                              |
| -d connstr<br/>--dbname=connstr            | 指定用于连接到服务器的参数为一个连接字符串。详见第 34.1.1 节。<br/><br/>为了和其他客户端应用一致，该选项被称为--dbname。但是因为pg_receivewal并不连接到集簇中的任何特定数据库，连接字符串中的数据库名将被忽略。 |
| -h host<br/>--host=host                    | 指定运行服务器的机器的主机名                                 |
| -p port<br/>--port=port                    | 指定服务器正在监听连接的 TCP 端口或本地 Unix 域套接字文件扩展 |
| -U username<br/>--username=username        | 要作为哪个用户连接                                           |
| -w<br/>--no-password                       | 强制pg_receivewal在连接到一个数据库之前提示要求一个口令      |
| 其它参数                                   |                                                              |
| --create-slot                              | 用--slot中指定的名称创建一个新的物理复制槽， 然后退出        |
| --drop-slot                                | 删除--slot中指定的复制槽，然后退出                           |

*例子：*
要从位于mydbserver的服务器流式传送预写式日志并且将它存储在本地目录/usr/local/pgsql/archive：

```shell
$ pg_receivewal -h mydbserver -D /usr/local/pgsql/archive
```



#### 3.2.3 pg_resetwal

一、PostgreSQL恢复pg_control文件：

1.需要下面四个参数：

```
-x XID set next transaction ID
在pg_clog下面，找到最大的文件编号，+1 后面跟上5个0
如：0000

-x = 0x000100000
```

```
-m MXID set next and oldest multitransaction ID
在pg_multixact/offsets下面，找到最大的文件编号，+1 后面跟上4个0
如：0000
-m = 0x00010000
```

```
-O OFFSET set next multitransaction offset
在pg_multixact/members下面，找到最大的文件编号，+1 后面跟上4个0
如：0000
-m = 0x00010000
```

```
-l XLOGFILE force minimum WAL starting location for new transaction log
找到pg_wal下面最新的日志文件，编号+1，然后分别去时间线、高32位、低32位：
如：000000010000000000000002
那么最新的日志文件就是000000010000000000000003
那么参数为：
-l 000000010000000000000003
```

2.执行恢复：

```
touch pg_control
pg_resetxlog -x 0x000100000 -m 0x00010000 -O 0x00010000 -l 000000010000000000000003 -f $PGDATA
```

当然，-m参数如果报错，也可以不要

```
pg_resetxlog -x 0x000100000 -O 0x00010000 -l 000000010000000000000003 -f $PGDATA
```

二、安全清理不必要的日志文件：

```
1）cd $PGDATA/pg_xlog/
2）pg_ctl stop -D $PGDATA -m fast
3）pg_controldata记录清理前的信息，并记录：NextXID NextOID给下面使用
4）pg_resetxlog -o 24584 -x 1745 -f $PGDATA
5）查看清理后大小du -sh
```

 三、使用pg_resetxlog/pg_resetwal来重置事务ID来访问被修改的数据(<a href="#dml误删除">误删除</a>）

- 例如删除数据的xid为100，那么我们回退到99，那么删除到操作还不可见，因此就能看到被删除的数据，但是删除是已经发生的，当我们提升xid到100时，删除就生效，你将无法访问到删除的数据。

- 被重置的xid之后的操作还是存在，无法抹除。当在xid为99时，我们再插入一条数据，那么这个时候访问表，我们将得到原来删除了表，在插入一条记录的情况。删除和插入将在一个xid下。

- 
  因此，使用重置xid的方式，我们也必须在重置之后，将现在的表备份出来，简单方法是create test_old  as select * from test;的方式来做。因为随着xid的增长，误操作也会被重现。


```
pg_resetwal -l 000000060000000100000094 -x 0x10000 -m 0x10000,0x10000 -o 0x10000 -f /pgdata/dataano
```

- -l wal日志最新+1
- -x 数据目录下的pg_xact目录中查找最大的数字文件名，然后在它的基础上加一并且乘以 1048576 (0x100000)
- -m 手工设置下一个和最老的多事务 ID。在数据目录下的pg_multixact/offsets目录中查找最大的数字文件名，然后在它的基础上加一并且乘以 65536 (0x10000)。反过来，确定最老的多事务 ID（-m的第二部分）的方法：在同一个目录中查找最小的数字文件名并且乘以 65536
- -o 手工设置下一个 OID。
- -f $PGDATA

缺少事务文件 dd if=/dev/zero of=0001 bs=512k count=1



#### 3.2.4 pg_test_fsync

pg_test_fsync是想告诉你在特定的系统上，哪一种 wal_sync_method最快，还可以在发生认定的 I/O 问题时提供诊断信息。不过，pg_test_fsync 显示的区别可能不会在真实的数据库吞吐量上产生显著的区别，特别是由于很多数据库服务器被它们的预写日志限制了速度。 pg_test_fsync为 wal_sync_method报告以微秒计的平均文件同步操作时间， 也能被用来提示用于优化commit_delay值的方法。

```shell
$ pg_test_fsync
5 seconds per test
O_DIRECT supported on this platform for open_datasync and open_sync.

Compare file sync methods using one 8kB write:
(in wal_sync_method preference order, except fdatasync is Linux's default)
        open_datasync                       690.728 ops/sec    1448 usecs/op
        fdatasync                           710.997 ops/sec    1406 usecs/op
        fsync                               232.539 ops/sec    4300 usecs/op
        fsync_writethrough                              n/a
        open_sync                           230.760 ops/sec    4333 usecs/op

Compare file sync methods using two 8kB writes:
(in wal_sync_method preference order, except fdatasync is Linux's default)
        open_datasync                       365.714 ops/sec    2734 usecs/op
        fdatasync                           652.194 ops/sec    1533 usecs/op
        fsync                               219.147 ops/sec    4563 usecs/op
        fsync_writethrough                              n/a
        open_sync                           110.862 ops/sec    9020 usecs/op

Compare open_sync with different write sizes:
(This is designed to compare the cost of writing 16kB in different write
open_sync sizes.)
         1 * 16kB open_sync write           225.214 ops/sec    4440 usecs/op
         2 *  8kB open_sync writes          120.955 ops/sec    8268 usecs/op
         4 *  4kB open_sync writes           60.275 ops/sec   16591 usecs/op
         8 *  2kB open_sync writes           32.022 ops/sec   31228 usecs/op
        16 *  1kB open_sync writes           15.893 ops/sec   62921 usecs/op

Test if fsync on non-write file descriptor is honored:
(If the times are similar, fsync() can sync data written on a different
descriptor.)
        write, fsync, close                 221.352 ops/sec    4518 usecs/op
        write, close, fsync                 251.167 ops/sec    3981 usecs/op

Non-sync'ed 8kB writes:
        write                            260511.627 ops/sec       4 usecs/op
```





### 3.4  高可用

#### 3.4.1 流复制

前提：源端和目标端都安装好数据库软件

**【异步流】**

主库参数设置

```
port = 5435
listen_addresses = '*'
wal_log_hints = on
wal_keep_segments = 256
#wal_keep_size = 5GB                                                    #PG13+参数
hot_standby_feedback = on
hot_standby = on
max_wal_size = 1GB
min_wal_size = 80MB
max_wal_sender = 10
wal_level = replica
archive_mode = on 
archive_command = 'test ! -f /pgdata/pg13/archivedir/%f && cp %p /pgdata/pg13/archivedir/%f'
```

pg_hba.conf白名单访问设置

```
host    all             all             0.0.0.0/0               md5
host    all             all             192.168.22.128/24       trust
host    replication     repl            192.168.22.129/24       trust
```

创建流复制用户

```sql
create user repl replication password 'Abcd321#';
```

备端创建数据目录并从主库拷贝数据文件（-R参数就不需要手动添加primary_conninfo参数）

```shell
pg_basebackup -h 192.168.22.128 -U repl -D /data/pg12.5/data/ -Fp -X stream -P -R -p 5432
```

检查postgresql.conf/postgresql.auto.conf（recovery.conf pg12版本之前）

```
--pg12版本之前需要加配standby_mode参数
standby_mode = 'on'  

--配置密码文件方式
primary_conninfo = 'user=repl passfile=/home/postgres/.pgpass host=192.168.22.128 port=9622 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any' 

--明文密码方式
primary_conninfo = 'user=repl password=repl host=192.168.22.128 port=9622 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any' 
```

密码文件格式

```shell
vi /home/postgres/.pgpass

{IP}:{PORT}:{DBNAME}:{USERNAME}:{PASSWORD}
192.168.22.128:9622:replication:repl:repl
```

同时，密码文件的设置，给一个只读权限400即可

```shell
chmod 400 /home/postgres/.pgpass
```

创建信号文件

```shell
touch $PGDATA/standby.signal
```

启动备库

```shell
pg_ctl start -D $PGDATA
```

**【同步流】**

主库的postgresql.conf文件，增加：

```
synchronous_standby_names = 'standby001'   #是设置同步流复制的备库的主机名，该名称会在备库中的参数中指定。         
```

 备库的recoveryt.conf文件

```
primary_conninfo = 'host=192.168.100.32 port=5866 user=tbing application_name=standby001'
#application_name参数就是设置的同步流复制备库的主机名，该参数值和主库的synchronous_standby_names的参数值一致。
```

检查流复制状态

```sql
执行：
select * from pg_stat_replication;

返回：
sync_state    | sync   表示同步流复制
sync_state    | async  表示异步流复制
```

<u>常用管理命令</u>

可以分别看到主备库的发送、接收日志的进程

```shell
ps -ef|grep -i postgres             #可以区分主备库进程
```

命令行工具： 

```shell
pg_controldata|grep -i state        #控制文件相关信息，也可以区分主备库
```

查看主备库状态的函数： 

```sql
select pg_is_in_recovery();         #主库为f，备库为t
```

主库查询流复制类型及备节点信息： 

```sql
select pid,state,client_addr,sync_priority,sync_state from pg_stat_replication;
```

将主库上WAL位置转换为WAL文件名和偏移量： 

```sql
select write_location from pg_stat_replication;         #获取当前在线日志
/select write_lsn from pg_stat_replication; 

select * from pg_xlogfile_name_offset('5BB/606B0788');  #标红是上条语句获取的值
/select * from pg_walfile_name_offset('5BB/606B0788'); 
```

 查看备库落后主库多少字节的WAL日志： 

```sql
select pg_xlog_location_diff(pg_current_xlog_location(),replay_location) from pg_stat_replication; 
/select pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn) from pg_stat_replication;
```

查看备库接收WAL日志和应用WAL日志的状态： 

```sql
select * from pg_last_xlog_receive_location();
/select * from pg_last_wal_receive_lsn();

select * from pg_last_xlog_replay_location(); 
/select * from pg_last_wal_replay_lsn();

select * from pg_last_xact_replay_timestamp(); 
```



#### 3.4.2 逻辑复制（发布/订阅）

**【主库配置】**
修改配置参数

```shell
# vi postgresql.conf

wal_level = logical            #设置成logical才支持逻辑复制,逻辑从库可以视情况设置
max_wal_senders = 10      #由于每个订阅节点和流复制备库在主库上都会占用主库上一个WAL发送进程，因此此参数设置值需大于max_replication_slots参数值加上物理备库数量
max_replication_slots = 8   #设置值需大于订阅节点的数量
```

主备库都需要配置白名单

```
host    replication     all             192.168.0.0/16                 trust
```

创建逻辑复制账号（账户拥有复制权限）

```sql
postgres=# CREATE USER logical_repl REPLICATION LOGIN CONNECTION LIMIT 8 ENCRYPTED PASSWORD 'logical_repl'; 
```

创建用于复制的数据库和表

```sql
postgres=# create database sourcedb;
sourcedb=# create table logical_tb1(id int primary key,name varchar(20));
```

创建发布

```sql
sourcedb=# CREATE PUBLICATION pub1 FOR TABLE logical_tb1;
```

查看发布信息

```sql
sourcedb=# SELECT * FROM pg_publication;
```

账号授权

```sql
sourcedb=# GRANT USAGE ON SCHEMA public TO logical_repl;
GRANT 
sourcedb=# GRANT SELECT ON logical_tb1 TO logical_repl;
GRANT
sourcedb=# GRANT ALL ON logical_tb1 TO logical_repl;
GRANT
```

**【从库配置】**
修改配置参数

```shell
# vi postgresql.conf

wal_level = logical
max_replication_slots = 8
max_logical_replication_workers = 8    #设置逻辑复制进程数，应大于订阅节点的数量，并且给表同步预留一些进程数量，此参数缺省值为4
```

创建用于复制的数据库和表

```sql
postgres=# create database desdb;
desdb=# create table logical_tb1(id int primary key,name varchar(20));
```

创建订阅，会自动创建一个和订阅名相同的复制槽

```sql
desdb=# CREATE SUBSCRIPTION sub1 CONNECTION 'host=192.168.22.128 port=5432 user=logical_repl dbname=sourcedb password=logical_repl' PUBLICATION pub1;
```

备库禁止订阅

```sql
ALTER SUBSCRIPTION sub1 DISABLE;
```

主库删除复制槽

```sql
sourcedb=# SELECT * FROM pg_drop_replication_slot('sub1');
```

*注意：逻辑复制不支持 TRUNCATE 级联删除表数据*



#### 3.4.3 repmgr

**【yum在线安装】**
安装对应PostgreSQL版本的存储库，从列表中找到PostgreSQL对应版本的存储库RPM：Https://dl.2ndquadrant.com/。

安装发行版和PostgreSQL版本的存储库定义（以postgresql12为例）

```shell
# curl https://dl.2ndquadrant.com/default/release/get/12/rpm | sudo bash
```

验证存储库安装，执行如下：

```shell
# sudo yum repolist
```

输出应该包含两个条目，如下所示：

```shell
2ndquadrant-dl-default-release-pg11/7/x86_64         2ndQuadrant packages (PG12) for 7 - x86_64               18
2ndquadrant-dl-default-release-pg11-debug/7/x86_64   2ndQuadrant packages (PG12) for 7 - x86_64 - Debug        8
```

yum安装repmgr，使用yum在线安装
```shell
# sudo yum install repmgr12
```

若要安装特定的包版本，请执行yum --showduplicates list关于所涉一揽子方案：

然后用连字符将适当的版本号附加到包名，例如：
```shell
# yum install repmgr12-5.2.0-1.rhel7
```



**【源码安装】**
源码包下载地址：https://repmgr.org/download/
解压下载的源码包，将解压目录修改属组

```shell
# tar -xzvf repmgr-5.3.1.tar.gz
# chown -R postrges:postgres repmgr-5.3.1/
```

切换为postgres用户安装，查询pg_config的执行位置，选择对应PostgreSQL版本pg_config所在的bin目录

```shell
# su – postgres
$ which pg_config
/software/pgsql13/bin/pg_config
```

进入repmgr软件包目录，指定PostgreSQL软件位置进行编译安装

```shell
$ ./configure --prefix=/software/pgsql13/
$ make && make install
```

查看是否安装成功

```shell
$ repmgr –version
repmgr 5.3.1
```



**【设置基本复制群集的先决条件】**
必须在这两台服务器上安装PostgreSQL和repmgr软件，以及需要两个服务器之间的无密码SSH连接。
配置postgres用户互信，主端服务器上生成秘钥

```shell
$ ssh-keygen -t rsa
```

将秘钥拷贝到远程机器

```shell
$ ssh-copy-id -i .ssh/id_rsa.pub postgres@node2
```

验证是否授权完成，不提示密码，直接返回日期说明配置正确

```shell
$ ssh node2 date
```

备端服务器上生成秘钥到用户主目录下的.ssh文件夹下

```shell
$ ssh-keygen -t rsa
```

将秘钥拷贝到远程机器

```shell
$ ssh-copy-id -i .ssh/id_rsa.pub postgres@node1
```

验证是否授权完成：不提示密码，直接返回日期说明配置正确

```shell
$ ssh node1 date
```

**【PostgreSQL配置】**
主库编辑配置文件postgresql.conf，并重启数据库

```shell
$ vi postgresql.conf

listen_addresses = '*'
wal_log_hints = on
max_wal_senders = 10
max_replication_slots = 10
wal_level = 'replica'
hot_standby = on
archive_mode = on
archive_command = 'test ! -f /postgres/product/archivedir/%f && cp %p /postgres/product/archivedir/%f'     #归档路径根据具体情况修改
shared_preload_libraries = 'repmgr'
```

**【创建repmgr用户和数据库】**
创建repmgr流复制用户、数据库以及repmgr扩展，并赋予用户superuser权限

```sql
$ psql -d postgres -U postgres
postgres# create user repmgr replication password 'repmgrforrepl';
postgres# alter user repmgr superuser;
postgres# create database repmgr owner repmgr;
postgres# \c repmgr repmgr
repmgr# ALTER USER repmgr SET search_path TO repmgr, "$user", public;
repmgr# alter user repmgr superuser ;
```

进入该数据库创建repmgr模式，将模式添加到search path中

```sql
repmgr# create schema repmgr ;
repmgr# ALTER USER repmgr SET search_path TO repmgr, "$user", public;
```

创建repmgr扩展

```sql
$ psql -d repmgr -U repmgr
repmgr# create extension repmgr;
```

**【配置pg_hba.conf的身份验证】**
配置pg_hba.conf白名单文件，允许repmgr有连接访问和复制的权限。

```
local   replication   repmgr                                trust
host    replication   repmgr      127.0.0.1/32            trust
host    replication   repmgr      192.168.22.0/24         md5

local   repmgr         repmgr                                trust
host    repmgr         repmgr      127.0.0.1/32            trust
host    repmgr         repmgr      192.168.22.0/24         md5
```

**【配置本地密码文件】**
在各节点postgres家目录下创建密码文件

```shell
$ vi ~/.pgpasss

192.168.1.4:5432:repmgr:repmgr:repmgrforrepl
192.168.1.5:5432:repmgr:repmgr:repmgrforrepl
192.168.1.5:5435:repmgr:repmgr:repmgrforrepl
192.168.1.4:5432:replication:repmgr:repmgrforrepl
192.168.1.5:5432:replication:repmgr:repmgrforrepl
192.168.1.5:5435:replication:repmgr:repmgrforrepl
```

**【配置repmgr】**
在/postgres/app/repmgr_config目录（目录可自定义创建）下编辑repmgr.conf，添加以下：

```shell
$ vi repmgr.conf

node_id=1
node_name='node1'
conninfo='host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2'
data_directory='/postgres/product/data'
pg_bindir='/postgres/app/bin'
failover=automatic
promote_command='/postgres/app/bin/repmgr standby promote -f /postgres/app/repmgr_config/repmgr.conf --log-to-file'
follow_command='/postgres/app/bin/repmgr standby follow -f /postgres/app/repmgr_config/repmgr.conf --log-to-file --upstream-node-i
d=%n'
log_file='/postgres/app/repmgr_log/repmgr.log'
```

**【注册主服务器】**
若要支持复制群集，必须将主节点注册到repmgr。这将安装repmgr扩展和元数据对象，并为主服务器添加元数据记录

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf standby register
INFO: connecting to primary database...
NOTICE: attempting to install extension "repmgr"
NOTICE: "repmgr" extension successfully installed
NOTICE: primary node record (id: 1) registered
```

验证集群状态

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show
 ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | primary | * running |          | default  | 100      | 11       | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
```

记录repmgr的元数据表

```sql
repmgr=# SELECT * FROM repmgr.nodes;
-[ RECORD 1 ]----+----------------------------------------------------------------------------------------------
node_id          | 1
upstream_node_id | 
active           | t
node_name        | node1
type             | primary
location         | default
priority         | 100
conninfo         | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
repluser         | repmgr
slot_name        | 
config_file      | /postgres/app/repmgr_config/repmgr.conf
```

**【克隆备用服务器】**
在node2节点上创建一个备用服务器上的repmgr.conf文件，添加以下内容： 

```shell
$ vi /postgres/app/repmgr_config/repmgr.conf

node_id=2
node_name='node2'
conninfo='host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2'
data_directory='/postgres/product/data'
pg_bindir='/postgres/app/bin'
failover=automatic
promote_command='/postgres/app/bin/repmgr standby promote -f /postgres/app/repmgr_config/repmgr.conf --log-to-file'
follow_command='/postgres/app/bin/repmgr standby follow -f /postgres/app/repmgr_config/repmgr.conf --log-to-file --upstream-node-i
d=%n'
log_file='/postgres/app/repmgr_log/repmgr.log'
```

使用如下命令查看克隆是否有问题

```shell
$ repmgr -h 192.168.1.4 -U repmgr -d repmgr -f /postgres/app/repmgr_config/repmgr.conf standby clone --dry-run

NOTICE: destination directory "/software/pgsql13/datarepl " provided
INFO: connecting to source node
DETAIL: connection string is: host=192.168.1.1 user=repmgr dbname=repmgr
DETAIL: current installation size is 31 MB
INFO: "repmgr" extension is installed in database "repmgr"
INFO: replication slot usage not requested;  no replication slot will be set up for this standby
INFO: parameter "max_wal_senders" set to 10
NOTICE: checking for available walsenders on the source node (2 required)
INFO: sufficient walsenders available on the source node
DETAIL: 2 required, 10 available
NOTICE: checking replication connections can be made to the source server (2 required)
INFO: required number of replication connections could be made to the source server
DETAIL: 2 replication connections required
NOTICE: standby will attach to upstream node 1
HINT: consider using the -c/--fast-checkpoint option
INFO: all prerequisites for "standby clone" are met
```

若没有问题去掉调试模式，直接执行

```shell
$ repmgr -h 192.168.22.128 -U repmgr -d repmgr -p 5432 -f /postgres/app/repmgr_config/repmgr.conf

NOTICE: destination directory "/postgres/product/data" provided
INFO: connecting to source node
DETAIL: connection string is: host=192.168.1.4 user=repmgr dbname=repmgr
DETAIL: current installation size is 31 MB
INFO: replication slot usage not requested;  no replication slot will be set up for this standby
NOTICE: checking for available walsenders on the source node (2 required)
NOTICE: checking replication connections can be made to the source server (2 required)
INFO: creating directory "/pgdata/dataano"...
NOTICE: starting backup (using pg_basebackup)...
HINT: this may take some time; consider using the -c/--fast-checkpoint option
INFO: executing:
  pg_basebackup -l "repmgr base backup"  -D /postgres/product/data -h 192.168.1.4 -p 5432 -U repmgr -p 5432 -X stream 
NOTICE: standby clone (using pg_basebackup) complete
NOTICE: you can now start your PostgreSQL server
HINT: for example: pg_ctl -D /postgres/product/data start
HINT: after starting the server, you need to register this standby with "repmgr standby register"
```

启动node2节点服务

```shell
$ pg_ctl -D /postgres/product/data start
```

注册node2 standby角色信息

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf standby register
```

主节点查看流复制状态正常，成功搭建

```sql
repmgr=# select * from pg_stat_replication ;
-[ RECORD 1 ]----+------------------------------
pid              | 24003
usesysid         | 16384
usename          | repmgr
application_name | node2
client_addr      | 192.168.1.5
client_hostname  | 
client_port      | 13360
backend_start    | 2022-03-10 16:06:17.005646+08
backend_xmin     | 
state            | streaming
sent_lsn         | 0/36002C78
write_lsn        | 0/36002C78
flush_lsn        | 0/36002C78
replay_lsn       | 0/36002C78
write_lag        | 00:00:00.000339
flush_lag        | 00:00:00.002684
replay_lag       | 00:00:00.002753
sync_priority    | 0
sync_state       | async
reply_time       | 2022-03-10 16:29:32.898743+08
```

**【配置自动故障转移】**
创建一个新节点witness（node3），建议部署在另一个单独的服务器上，本文档将此节点安装在node2节点上。
在node3节点的repmgr.conf中添加以下参数

```shell
$ vi repmgr.conf

node_id=3
node_name='node3'
conninfo='host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2'
data_directory='/postgres/app/witness/data'
pg_bindir='/postgres/app/bin'
failover=automatic
promote_command='/postgres/app/bin/repmgr standby promote -f /postgres/app/witness/conf/repmgr.conf --log-to-file'
follow_command='/postgres/app/bin/repmgr standby follow -f /postgres/app/witness/conf/repmgr.conf --log-to-file --upstream-node-id
=%n'
log_file='/postgres/app/repmgr_log/repmgr_witness.log'
```

创建一个新的PostgreSQL实例，将参数文件设置和白名单访问设置同node1、node2节点。（参数配置步骤略）

```shell
$ initdb -D /postgres/app/witness/data
```

将witness节点注册为witness角色

```shell
$ repmgr -h 192.168.1.4 -U repmgr -d repmgr -p5432 -f /postgres/app/witness/conf/repmgr.conf witness register
```

在node1上执行查看各节点状态

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show
 ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | primary | * running |          | default  | 100      | 11       | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 2  | node2 | standby |   running | node1    | default  | 100      | 11       | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 3  | node3 | witness | * running | node2    | default  | 0        | n/a      | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2
```

各节点启动repmgrd程序

```shell
node1:
$ repmgrd -f /postgres/app/repmgr_config/repmgr.conf --pid-file /tmp/repmgrd.pid

node2：
$ repmgrd -f /postgres/app/repmgr_config/repmgr.conf --pid-file /tmp/repmgrd.pid

node3（witness）:
$ repmgrd -f /postgres/app/witness/conf/repmgr.conf --pid-file /tmp/repmgrd_witness.pid
```

如果需要终止repmgrd程序，使用以下命令

```shell
$ kill `cat /tmp/repmgrd.pid
```

**【测试自动故障转移】**
node1上模拟测试关闭主库

```shell
$ pg_ctl stop
```

node2节点打开repmgr日志信息显示，输出如下则成功晋升为主节点

```shell
$ tail -30f /postgres/app/repmgr_log/repmgr.log
[2022-03-10 15:33:43] [NOTICE] promoting standby to primary
[2022-03-10 15:33:43] [DETAIL] promoting server "node2" (ID: 2) using pg_promote()
[2022-03-10 15:33:43] [NOTICE] waiting up to 60 seconds (parameter "promote_check_timeout") for promotion to complete
[2022-03-10 15:33:44] [NOTICE] STANDBY PROMOTE successful
[2022-03-10 15:33:44] [DETAIL] server "node2" (ID: 2) was successfully promoted to primary
[2022-03-10 15:33:44] [INFO] checking state of node 2, 1 of 6 attempts
[2022-03-10 15:33:44] [NOTICE] node 2 has recovered, reconnecting
[2022-03-10 15:33:44] [INFO] connection to node 2 succeeded
[2022-03-10 15:33:44] [INFO] original connection is still available
[2022-03-10 15:33:44] [INFO] 0 followers to notify
[2022-03-10 15:33:44] [INFO] switching to primary monitoring mode
[2022-03-10 15:33:44] [NOTICE] monitoring cluster primary "node2" (ID: 2)
[2022-03-10 15:33:44] [INFO] child node "node3" (ID: 3) is not yet attached
[2022-03-10 15:34:44] [NOTICE] new witness "node3" (ID: 3) has connected
```

查看备库是否晋升为主（f为主）

```sql
postgres=# select pg_is_in_recovery();

 pg_is_in_recovery 
-------------------
 f
(1 row)
```

node2上查看各节点状态，此时node2已经成为primary

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show
ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | primary | - failed  | ?        | default  | 100      |          | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 2  | node2 | primary | * running |          | default  | 100      | 12       | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 3  | node3 | witness | * running | node2    | default  | 0        | n/a      | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2
```

**【将原主库初始化为备库】**
确保node1原主库已经被关闭，并将其初始化为备库

```shell
$ repmgr -h 192.168.1.5 -U repmgr -d repmgr -f /postgres/app/repmgr_config/repmgr.conf standby clone -F
```

启动node1节点

```shell
$ pg_ctl start
```

将node1强制重新注册为standby

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf standby register -F
```

查看集群状态

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show
ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | standby |  running  | node2    | default  | 100      | 12         | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 2  | node2 | primary | * running |          | default  | 100      | 12       | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 3  | node3 | witness | * running | node2    | default  | 0        | n/a      | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2
```

**【手动切换主备节点】**
node1节点强制提升为主节点

```shell
$ repmgr standby switchover -f /postgres/app/repmgr_config/repmgr.conf --siblings-follow --always-promote
DETAIL: promoting server "node1" (ID: 1) using pg_promote()
NOTICE: waiting up to 60 seconds (parameter "promote_check_timeout") for promotion to complete
NOTICE: STANDBY PROMOTE successful
DETAIL: server "node1" (ID: 1) was successfully promoted to primary
ERROR: new primary diverges from former primary and --force-rewind not provided
HINT: the former primary will need to be restored manually, or use "repmgr node rejoin"
```

查看各节点状态

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show 
 ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | primary | * running |          | default  | 100      | 13        | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 2  | node2 | primary | - failed  | ?        | default  | 100      |          | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 3  | node3 | witness | * running | ? node2  | default  | 0        | n/a      | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2

WARNING: following issues were detected

  - unable to connect to node "node2" (ID: 2)
  - unable to connect to node "node3" (ID: 3)'s upstream node "node2" (ID: 2)
```

node2节点进行初始化克隆

```shell
$ repmgr -h 192.168.1.4 -U repmgr -d repmgr -f /postgres/app/repmgr_config/repmgr.conf standby clone -F
```

启动node2节点

```shell
$ pg_ctl start
```

重新注册为standby角色

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf standby register -F
```

查看各节点状态

```shell
$ repmgr -f /postgres/app/repmgr_config/repmgr.conf cluster show
 ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                                            
----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------------------------------------
 1  | node1 | primary | * running |          | default  | 100      | 13        | host=192.168.1.4 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 2  | node2 | standby |   running | node1    | default  | 100      | 13       | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5432 connect_timeout=2
 3  | node3 | witness | * running | node1    | default  | 0        | n/a      | host=192.168.1.5 user=repmgr dbname=repmgr password=repmgrforrepl port=5435 connect_timeout=2
```

**【集群维护】**
如果需要对PostgreSQL环境进行维护，例如配置修改、架构切换等，建议关闭各节点repmgrd自动故障转移进程。找到对应进程的pid文件或者pid执行关闭命令：

```shell
$ kill `cat /tmp/repmgrd.pid`
```



#### 3.4.4 patroni

**【关闭防火墙】**
关闭主机防火墙

```shell
# systemctl stop firewalld.service
# systemctl disable firewalld.service
```

**【部署PostgreSQL及流复制环境】**
此步骤见《基于Linux的异步流复制标准化实施文档》
**【部署etcd】**
在各个节点安装必要的依赖包及etcd软件

```shell
# yum install -y gcc python-devel epel-release
# yum install -y etcd
```

编辑配置文件（以下列出了需要修改的参数，并以主节点为例）
```shell
# vim /etc/etcd/etcd.conf

[Member]
ETCD_DATA_DIR="/var/lib/etcd/node1.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.22.128:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.22.128:2379,http://127.0.0.1:2379"
[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.22.128:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.22.128:2379"
ETCD_INITIAL_CLUSTER="node1=http://192.168.22.128:2380,node2=http://192.168.22.129:2380, node3=http://192.168.22.130:2380"
```

启动etcd集群，并设置开机自启动
```shell
# systemctl start etcd
# systemctl enable etcd
```

**【部署python3】**
在各个节点部署python3。需要使用高版本的python来使用patroni服务，一般的linux环境内置了2.7版本的python环境，因此我们需要升级python，这里采用源码编译安装方式安装

```shell
# wget -c https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tar.xz
# ./configure
# make
# make install
```

删除原2.7版本的软连接，添加新的软链接以使用python3
```shell
# rm -f /usr/bin/python
# ln -s /usr/local/bin/python3 /usr/bin/python
```

**【部署patroni】**
在各个节点上部署patroni。安装必要的依赖包和patroni软件

```shell
# pip3 install psycopg2-binary -i https://mirrors.aliyun.com/pypi/simple/
# pip3 install patroni -i https://mirrors.aliyun.com/pypi/simple/
```

修改patroni配置文件（以主节点为例）
```shell
# vim /etc/patroni.yml

scope: pgsql
namespace: /pgsql/
name: pgsql_node2

restapi:
  listen: 192.168.22.128:8008
  connect_address: 192.168.22.128:8008

etcd:
  host: 192.168.22.128:2379

bootstrap:

  # this section will be written into Etcd:/<namespace>/<scope>/config after initializing new cluster

  # and all other cluster members will use it as a `global configuration`

  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    master_start_timeout: 300
    synchronous_mode: false
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
        listen_addresses: "0.0.0.0"
        port: 5432
        wal_level: logical
        hot_standby: "on"
        wal_keep_segments: 100
        max_wal_senders: 10
        max_replication_slots: 10
        wal_log_hints: "on"

#        archive_mode: "on"
#        archive_timeout: 1800s
#        archive_command: gzip < %p > /data/backup/pgwalarchive/%f.gz
#      recovery_conf:
#        restore_command: gunzip < /data/backup/pgwalarchive/%f.gz > %p

postgresql:
  listen: 0.0.0.0:5432
  connect_address: 192.168.22.128:5432
  data_dir: /pgdata/patr2
  bin_dir: /usr/pgsql-12/bin

#  config_dir: /etc/postgresql/9.6/main

  authentication:
    replication:
      username: repl
      password: repl
    superuser:
      username: postgres
      password: postgres

#watchdog:
#  mode: automatic # Allowed values: off, automatic, required
#  device: /dev/watchdog
#  safety_margin: 5

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
```

配置patroni服务单元
```shell
# vim /etc/systemd/system/patroni.service 

[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Type=simple
User=postgres
Group=postgres
#StandardOutput=syslog
ExecStart=/usr/local/bin/patroni /etc/patroni.yml
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=process
TimeoutSec=30
Restart=no

[Install]
WantedBy=multi-user.target
```

启动patroni服务
```shell
# systemctl start patroni
```

当然地，我们也可以直接使用patroni命令来启动patroni服务，配置服务单元是为了更方便使用。

```shell
# /usr/local/bin/patroni /etc/patroni.yml > patroni.log 2>&1 &
```

**【信息查看】**
查看集群内节点信息

```shell
# patronictl -c /etc/patroni.yml list

Cluster: pgsql (6972099274779350082)+--------+---------+----+-----------+
|   Member    |        Host         |  Role  |  State  | TL | Lag in MB |
+-------------+---------------------+--------+---------+----+-----------+
| pgsql_node1 | 192.168.22.128:5432 | Leader | running | 3  |           |
| pgsql_node2 | 192.168.22.129:5432 |        | running | 3  |      0    |
| pgsql_node3 | 192.168.22.130:5432 |        | running | 3  |      0    |
+-------------+---------------------+--------+---------+----+-----------+
```

**【手动切换主备】**
选择某一可用的从节点，使其成为主节点角色

```shell
# patronictl -c /etc/patroni.yml switchover

Master [pgsql_node1]: pgsql_node1
Candidate ['pgsql_node2', 'pgsql_node3'] []: pgsql_node2
When should the switchover take place (e.g. 2021-06-20T11:42 )  [now]: now
```

查看集群状态
```shell
# patronictl -c /etc/patroni.yml list

Cluster: pgsql (6972099274779350082)+--------+---------+----+-----------+
|   Member    |        Host         |  Role  |  State  | TL | Lag in MB |
+-------------+---------------------+--------+---------+----+-----------+
| pgsql_node1 | 192.168.22.128:5432 |        | running | 3  |      0    |
| pgsql_node2 | 192.168.22.129:5432 | Leader | running | 3  |           |
| pgsql_node3 | 192.168.22.130:5432 |        | running | 3  |      0    |
+-------------+---------------------+--------+---------+----+-----------+
```

**【自动切换主备】**
重启node1节点所在主机。查看集群状态，node2自动提升为主，如果只是关闭节点实例，则patroni会再将数据库服务自动拉起。

```shell
# patronictl -c /etc/patroni.yml list

Cluster: pgsql (6972099274779350082)+--------+---------+----+-----------+
|   Member    |        Host         |  Role  |  State  | TL | Lag in MB |
+-------------+---------------------+--------+---------+----+-----------+
| pgsql_node2 | 192.168.22.129:5432 | Leader | running | 3  |           |
| pgsql_node3 | 192.168.22.130:5432 |        | running | 3  |      0    |
+-------------+---------------------+--------+---------+----+-----------+
```

**【初始化节点】**
当某一节点与主库不同步，或者节点异常运行时，可以使用此方法初始化节点信息以重新加入集群。

```shell
# patronictl -c /etc/patroni.yml reinit pgsql

Cluster: pgsql (6972099274779350082)+--------+---------+----+-----------+
|   Member    |        Host         |  Role  |  State  | TL | Lag in MB |
+-------------+---------------------+--------+---------+----+-----------+
| pgsql_node1 | 192.168.22.128:5432 |        | running | 3  |      0    |
| pgsql_node2 | 192.168.22.129:5432 | Leader | running | 3  |           |
| pgsql_node3 | 192.168.22.130:5432 |        | running | 3  |      0    |
+-------------+---------------------+--------+---------+----+-----------+
选择以下需要添加的节点名称：pgsql_node3
你确定要重新初始化成员 pgsql_node3？[y/N]：y
成功：为成员pgsql_node3执行初始化
```



#### 3.4.5 pgpool-II

**【下载安装】**
源码下载网址：https://www.pgpool.net/
解压安装源码包

```shell
$ tar -xzvf pgpool-II-4.2.7.tar.gz
```

创建对应的安装目录，并修改属组
```shell
# mkdir /SoftWare/pgpool
# chown postgres:postgres /SoftWare/pgpool
```

查找对应PostgreSQL版本pg_config的路径，对应bin所在的目录

```shell
$ which pg_config
/software/pgsql13/bin/pg_config
```

编译安装pgpool-II

```shell
$ cd pgpool-II-4.2.7/
$ ./configure --prefix=/SoftWare/pgpool --pgsql=/software/pgsql13/
$ make && make install
```

编译安装pgpool_recovery
在线恢复时，Pgpool-II需要pgpool_recovery、pgpool_remote_start和pgpool_switch_xlog函数。另外pgpoolAdmin的管理工具，停止，重启或重新加载一个PostgreSQL在屏幕上使用pgpool_pgctl。这些函数先安装在template1中，不需要安装在生产数据库中。

```shell
$ cd /software/medias/pgpool-II-4.2.7/src/sql/pgpool-recovery
$ make
$ make install
```

进入template1数据库

```shell
$ psql -c "create extension pgpool_recovery" template1
```

编译安装pgpool_regclass
PostgreSQL版本是9.4以上，跳过此操作；否则需要生产数据库安装

```shell
$ cd /software/medias/pgpool-II-4.2.7/src/sql/pgpool-regclass
$ make
$ make install
```

进入template1数据库; 其生产数据库也需要执行

```shell
$ psql -c "create extension pgpool_regclass" template1
```

**【复制模式】**
配置pcp.conf文件
pcp 工具的用户名、密码配置文件，假设配置的用户/密码为pcpadm/pgpool123
进入配置目录

```shell
[pgpool@node3 pgpool]$ cd /SoftWare/pgpool/etc
[pgpool@node	3 etc]$ cp pcp.conf.sample pcp.conf
```

在该文件中；用户/密码出现在每一行; # USERID:MD5PASSWD
pg_md5 生成配置的用户名密码是 pgpool123 

```shell
[pgpool@node3 etc]$ pg_md5 pgpool123
fa039bd52c3b2090d86b0904021a5e33
```

编辑pcp.conf；这里配置用户是 pcpadm

```shell
[pgpool@node3 etc]$ vi pcp.conf

# USERID:MD5PASSWD
pcpadm:fa039bd52c3b2090d86b0904021a5e33
```

配置pool_hba.conf文件
现客户端连接数据库；要经过连接池 pgpool 中转。对客户端来说，pgpool 就是数据库服务端，所以 pool_hba.conf 接管 pg_hba.conf 的作用。与PostgreSQL实例上的pg_hba.conf文件保持一致的配置。

```shell
[pgpool@node3 etc]$ cp pool_hba.conf.sample  pool_hba.conf
[pgpool@node3 etc]$ vi pool_hba.conf

# 增加
host	all  all	0.0.0.0/0	md5
```

配置pgpool.conf文件
拷贝一份配置文件的模板，并修改以下参数

```shell
$ cp /SoftWare/pgpool/etc/pgpool.conf.sample-replication /SoftWare/pgpool/etc/pgpool.conf
$ vi /SoftWare/pgpool/etc/pgpool.conf

backend_clustering_mode = 'native_replication'             #复制模式
listen_addresses = '*'
backend_hostname0 = '10.0.4.13'                          #填写需要复制的实例信息
backend_port0 = 5432
backend_weight0 = 1
backend_data_directory0 = '/SoftWare/pgpooltestpgdata/db1'
backend_flag0 = 'ALLOW_TO_FAILOVER'
backend_application_name0 = 'server0'
backend_hostname1 = '10.0.4.13'
backend_port1 = 5433
backend_weight1 = 1
backend_data_directory1 = '/SoftWare/pgpooltestpgdata/db2'
backend_flag1 = 'ALLOW_TO_FAILOVER'
backend_application_name1 = 'server1'
enable_pool_hba = on                       #启用pool_hba.conf中的用户认证
pool_passwd = 'pool_passwd'              #配置账户密码文件路径
logging_collector = on
log_directory = '/tmp/pgpool_logs'       #pgpool运行错误日志路径
pid_file_name = '/SoftWare/pgpool/etc/pgpool.pid'    #pgpool进程pid文件位置
replicate_select = off                     #是否复制select语句
insert_lock = on                            
load_balance_mode = on  #设置为 on，pgpool-II 将在数据库节点之间分发 SELECT 查询
failover_when_quorum_exists = off    #内置复制模式不支持该参数，置为off
```

配置pool_passwd文件
pgpool 密钥文件；通过 pgpool 访问需要用户验证；这里暂用数据库用户 pgpool，密码为pgpool，与下一步创建数据库用户对应。

```shell
[pgpool@node3 etc]$ pg_md5 --md5auth -u pgpool -p
password: 
```

为PostgreSQL实例安装insert_lock表
我们在各节点创建一个测试用户和业务库

```sql
postgres=# create user pgpool password 'pgpool';
postgres=# create database pgpool01 owner pgpool;
$ psql -p 5432 -f /software/medias/pgpool-II-4.2.7/src/sql/insert_lock.sql -d pgpool01 -U pgpool
```

启动pgpool
使用pgpool命令启动，并查看是否成功启动

```shell
$ pgpool
$ ps -ef | grep pgpool
postgres  7706     1  0 15:18 ?        00:00:00 pgpool
```

另外地也可以用如下几种方式启动pgpool

```shell
$ pgpool
```

然而，以上的命令不打印日志信息，因为 pgpool 脱离终端了。如果你想显示 pgpool 日志信息，你需要传递 -n 到 pgpool 命令。此时 pgpool-II 作为非守护进程模式运行，也就不会脱离终端了。

```shell
$ pgpool -n &
```

日志消息会打印到终端，所以推荐使用如下的选项。-d 选项启用调试信息生成。

```shell
$ pgpool -n -d > /tmp/pgpool.log 2>&1 &
```

测试复制模式
使用pgpool端口连接服务（pgpool作为连接池），创建测试表并插入数据

```sql
$ psql -p9999 -U pgpool -d pgpool01
pgpool01=> create table lottu01(id int, info text, regtime timestamp);
pgpool01=> insert into lottu01 values (1, 'pgpool native replication', now());
#连接到后台PostgreSQL实例查看是否成功插入
db1:
$ psql -p5432 -U pgpool -d pgpool01
pgpool01=> \dt
         List of relations
 Schema |  Name   | Type  | Owner  
--------+---------+-------+--------
 public | lottu01 | table | pgpool
(1 row)

pgpool01=> select * from lottu01 ;
 id |           info            |          regtime           
----+---------------------------+----------------------------
  1 | pgpool native replication | 2022-03-16 15:22:11.405787
(1 row)

db2:
$ psql -p5433 -U pgpool -d pgpool01
pgpool01=> \dt
         List of relations
 Schema |  Name   | Type  | Owner  
--------+---------+-------+--------
 public | lottu01 | table | pgpool
(1 row)

pgpool01=> select * from lottu01 ;
 id |           info            |          regtime           
----+---------------------------+----------------------------
  1 | pgpool native replication | 2022-03-16 15:22:11.405787
(1 row)
```

**【流复制模式】**
配置pcp.conf文件
pcp 工具的用户名、密码配置文件，假设配置的用户/密码为pcpadm/pgpool123
进入配置目录

```shell
[pgpool@node3 pgpool]$ cd $PGPOOLHOME/etc
[pgpool@node	3 etc]$ cp pcp.conf.sample pcp.conf
```

在该文件中；用户/密码出现在每一行; # USERID:MD5PASSWD
pg_md5 生成配置的用户名密码是 pgpool123 

```shell
[pgpool@node3 etc]$ pg_md5 pgpool123
fa039bd52c3b2090d86b0904021a5e33
```

编辑pcp.conf；这里配置用户是 pcpadm

```shell
[pgpool@node3 etc]$ vi pcp.conf

# USERID:MD5PASSWD
pcpadm:fa039bd52c3b2090d86b0904021a5e33
```

配置pool_hba.conf文件
现客户端连接数据库；要经过连接池 pgpool 中转。对客户端来说，pgpool 就是数据库服务端，所以 pool_hba.conf 接管 pg_hba.conf 的作用。与PostgreSQL实例上的pg_hba.conf文件保持一致的配置。

```shell
[pgpool@node3 etc]$ cp pool_hba.conf.sample  pool_hba.conf
[pgpool@node3 etc]$ vi pool_hba.conf

# 增加
host	all  all	0.0.0.0/0	md5
```

配置pgpool.conf文件
拷贝一份配置文件的模板，并修改以下参数

```shell
$ cp /SoftWare/pgpool/etc/pgpool.conf.sample-replication /SoftWare/pgpool/etc/pgpool.conf
$ vi /SoftWare/pgpool/etc/pgpool.conf

backend_clustering_mode = 'stream_replication'             #流复制模式
listen_addresses = '*'
backend_hostname0 = '10.0.4.13'                          #填写需要复制的实例信息
backend_port0 = 5432
backend_weight0 = 1
backend_data_directory0 = '/SoftWare/pgpooltestpgdata/db1'
backend_flag0 = 'ALLOW_TO_FAILOVER'
backend_application_name0 = 'server0'
backend_hostname1 = '10.0.4.13'
backend_port1 = 5433
backend_weight1 = 1
backend_data_directory1 = '/SoftWare/pgpooltestpgdata/db2'
backend_flag1 = 'ALLOW_TO_FAILOVER'
backend_application_name1 = 'server1'
enable_pool_hba = on                       #启用pool_hba.conf中的用户认证
pool_passwd = 'pool_passwd'              #配置账户密码文件路径
logging_collector = on
log_directory = '/tmp/pgpool_logs'       #pgpool运行错误日志路径
pid_file_name = '/SoftWare/pgpool/etc/pgpool.pid'    #pgpool进程pid文件位置
replicate_select = off                     #是否复制select语句
insert_lock = on                            
load_balance_mode = on  #设置为 on，pgpool-II 将在数据库节点之间分发 SELECT 查询
failover_when_quorum_exists = off    #内置复制模式不支持该参数，置为off
sr_check_period = 10       #指定检查流复制延迟的时间间隔
sr_check_user = 'pgpool'  #指定执行流式复制检查的PostgreSQL用户名。用户必须具有 LOGIN 权限并且存在于所有 PostgreSQL后端。
sr_check_password = 'pgpool'  #指定执行流式复制检查的PostgreSQL用户名
sr_check_password = '' #指定sr_check_user PostgreSQL用户的密码以执行流复制检查,如果使用md5加密的密码需要填写md5的形式
sr_check_database = 'postgres'  #指定数据库以执行流复制延迟检查
```

配置pool_passwd文件
pgpool 密钥文件；通过 pgpool 访问需要用户验证；这里暂用数据库用户 pgpool，密码为pgpool，与下一步创建数据库用户对应。

```shell
[pgpool@node3 etc]$ pg_md5 --md5auth -u pgpool -p
password: 
```

为PostgreSQL实例安装insert_lock表
我们在各节点创建一个测试用户和业务库

```sql
postgres=# create user pgpool password 'pgpool';
postgres=# create database pgpool01 owner pgpool;
```

```shell
$ psql -p 5432 -f /software/medias/pgpool-II-4.2.7/src/sql/insert_lock.sql -d pgpool01 -U pgpool
```

启动pgpool
使用pgpool命令启动，并查看是否成功启动

```shell
$ pgpool
$ ps -ef | grep pgpool
postgres  7706     1  0 15:18 ?        00:00:00 pgpool
```

另外地也可以用如下几种方式启动pgpool

```shell
$ pgpool
```

然而，以上的命令不打印日志信息，因为 pgpool 脱离终端了。如果你想显示 pgpool 日志信息，你需要传递 -n 到 pgpool 命令。此时 pgpool-II 作为非守护进程模式运行，也就不会脱离终端了。

```shell
$ pgpool -n &
```

日志消息会打印到终端，所以推荐使用如下的选项。-d 选项启用调试信息生成。

```shell
$ pgpool -n -d > /tmp/pgpool.log 2>&1 &
```

测试流复制模式
使用pgpool端口连接服务（pgpool作为连接池），创建测试表并插入数据

```sql
$ psql -p9999 -U pgpool -d pgpool01
pgpool01=> create table lottu02(id int, info text, regtime timestamp);
pgpool01=> insert into lottu02 values (1, 'pgpool stream replication', now());
#连接到后台PostgreSQL实例查看是否成功插入，备库是否同步
db1:
$ psql -p5432 -U pgpool -d pgpool01
pgpool01=> \dt
         List of relations
 Schema |  Name   | Type  | Owner  
--------+---------+-------+--------
 public | lottu02 | table | pgpool
(1 row)

pgpool01=> select * from lottu02 ;
 id |           info            |          regtime           
----+---------------------------+----------------------------
  1 | pgpool stream replication | 2022-03-16 17:16:46.475568
(1 row)

db2:
$ psql -p5433 -U pgpool -d pgpool01
pgpool01=> \dt
         List of relations
 Schema |  Name   | Type  | Owner  
--------+---------+-------+--------
 public | lottu02 | table | pgpool
(1 row)

pgpool01=> select * from lottu02 ;
 id |           info            |          regtime           
----+---------------------------+----------------------------
  1 | pgpool stream replication | 2022-03-16 17:16:46.475568
(1 row)
查看节点状态：
$ psql -p9999 -U pgpool -d pgpool01
pgpool01=> \x
Expanded display is on.
pgpool01=> show pool_nodes;
-[ RECORD 1 ]----------+--------------------
node_id                | 0
hostname               | 10.0.4.13
port                   | 5432
status                 | up
lb_weight              | 0.500000
role                   | primary
select_cnt             | 2
load_balance_node      | true
replication_delay      | 0
replication_state      | 
replication_sync_state | 
last_status_change     | 2022-03-16 17:04:04
-[ RECORD 2 ]----------+--------------------
node_id                | 1
hostname               | 10.0.4.13
port                   | 5433
status                 | up
lb_weight              | 0.500000
role                   | standby
select_cnt             | 0
load_balance_node      | false
replication_delay      | 0
replication_state      | 
replication_sync_state | 
last_status_change     | 2022-03-16 17:04:04
```



### 3.5 常用扩展

<u>扩展通用安装方式</u>

查询已安装的扩展

```sql
\dx
```

查看当前服务器可以安装的扩展

```sql
select name from pg_available_extensions;
```

删除扩展

```sql
drop extensions 扩展名
```

免编译安装其他扩展，在pg yum源中找对应版本的包
https://download.postgresql.org/pub/repos/yum/

下载并离线安装

```
rpm -ivh xxxx.rpm
直接登录psql，可以create extension xxxx
```

#### 3.5.1 dblink外部服务器

先执行dblink_connect保持连接 

```sql
SELECT dblink_connect('mycoon','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456');   
```

执行BEGIN命令 

```sql
SELECT dblink_exec('mycoon', 'BEGIN'); 
```

执行数据操作（update，insert，create等命令） 

```sql
SELECT dblink_exec('mycoon', 'insert into tb1 select generate_series(10,20),''hello'''); 
```

执行事务提交 

```sql
SELECT dblink_exec('mycoon', 'COMMIT'); 
```

解除连接 

```sql
SELECT dblink_disconnect('mycoon');
```



#### 3.5.2 fdw外部数据包装器

创建pg数据库连接扩展

```sql
postgres=# CREATE EXTENSION postgres_fdw;
CREATE EXTENSION
```

创建服务器连接

```sql
postgres=# CREATE SERVER foreign_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host '127.0.0.1', port '5432', dbname 'postgres');
```

创建数据库连接

```sql
postgres=# CREATE USER MAPPING FOR public
SERVER foreign_server
OPTIONS (user 'postgres', password 'postgres');
```

创建外部表映射远端服务器表

```sql
postgres=# CREATE FOREIGN TABLE foreign_table_test(id int,time timestamp with time zone)
SERVER foreign_server options(schema_name 'public',table_name 'test');
```

可以直接操作外部表

```sql
select * from foreign_table_test；
```

删除表

```sql
DROP FOREIGN TABLE foreign_table_test；
```

如果是普通用户使用 ·postgres_fdw 需要单独授权

```sql
grant usage on foreign data wrapper postgres_fdw to 用户名
```

*其他数据库连接扩展：oracle_fdw,mysql_fdw，tds_fdw，redis_fdw*



#### 3.5.3 orafce异构函数

下载到/tmp目录下

https://github.com/orafce/orafce

修改属组

```sql
chown -R postgres:postgres /tmp/orafce-3.13.4.zip
```

切换到postgres用户，将下载好的安装包解压
```shell
# su - postgres
# unzip orafce-3.13.4.zip
```

将解压的文件夹移动到share/extension目录下，该目录在环境变量中查找

```shell
$ cat ~/.bash_profile
export PATH=$PATH:$HOME/bin:/data/pg12.1/bin/
```

找到pg的bin目录路径(如上)，这里为/data/pg12.1/bin/。切换到bin的同级目录下，即cd /data/pg12.1
再进入目录 cd share/extension，将解压好的包拷贝到当前目录

```shell
mv /tmp/orafce-3.13.4/ ./
```

编译安装

```shell
$ cd orafce-3.13.4/
$ make && make install
```

创建扩展

```sql
psql
>create extension orafce
>完成
```

查看插件内容

```sql
psql
>\dx+ orafce
```



#### 3.5.4 pageinspect查看页面信息

<a href="dml误删除">见"dml数据误删除恢复流程"</a>





#### 3.5.5 pg_buffercache共享缓冲区

创建个测试数据库test,并且添加扩展。

```sql
create database test;
CREATE DATABASE

create extension pg_buffercache ;
CREATE EXTENSION
```

在缓存区中找到两个数据库的内容，带0的记录表示缓存区未使用。

```sql
psql -d test
test=# select distinct reldatabase from pg_buffercache ;
 reldatabase
-------------

       16394
       13322
           0
(4 rows)

test=# \! oid2name
All databases:
    Oid  Database Name  Tablespace
----------------------------------
  13322       postgres  pg_default
  13321      template0  pg_default
      1      template1  pg_default
  16394           test  pg_default
```


通过SQL更直观的来看一下：下面的为数据字典的内容

```sql
select
c.relname,
count(*) as buffers
from pg_class c
join pg_buffercache b
on b.relfilenode = c.relfilenode
inner join pg_database d
on (b.reldatabase = d.oid and d.datname = current_database())
group by c.relname
order by 2 desc;

              relname              | buffers

-----------------------------------+---------
 pg_operator                       |      14
 pg_depend_reference_index         |      12
 pg_depend                         |      10
 pg_rewrite                        |       6
 pg_description                    |       6
 pg_amop                           |       5
```

下面这个是除了数据字典的

```sql
select
c.relname,
count(*) as buffers
from pg_class c
join pg_buffercache b
on b.relfilenode = c.relfilenode
inner join pg_database d
on (b.reldatabase = d.oid and d.datname = current_database())
where c.relname not like 'pg%'
group by c.relname
order by 2 desc;

   relname    | buffers
--------------+---------
 lsang        |       1
 lsang_id_seq |       1
(2 rows)
```

创建表并插入数据，我们通过pg_buffercache能够查询到buffers。
我们来看看数据缓存区是否为脏的

```sql
select
c.relname,
b.isdirty
from pg_class c
join pg_buffercache b
on b.relfilenode = c.relfilenode
inner join pg_database d
on (b.reldatabase = d.oid and d.datname = current_database())
where c.relname not like 'pg%' ;
   relname    | isdirty
--------------+---------
 lsang_id_seq | f
 lsang        | f

test=# update lsang  set name = 'Michael.Sang';
UPDATE 1<br>
再次查询结果:
   relname    | isdirty
--------------+---------
 lsang_id_seq | f
 lsang        | t
```

结果告诉我们，缓存区是脏的，我们可以强制设置个检查点:

```sql
test=# checkpoint ;
CHECKPOINT
```

重复上面查询，缓存区就不再是脏的了:

```sql
 relname    | isdirty
--------------+---------
 lsang_id_seq | f
 lsang        | f
(2 rows)
```



#### 3.5.6 pg_freespacemap查看空闲空间映射

创建pg_freespacemap扩展

```sql
create extension pg_freespacemap;
```

查询空闲空间映射

```sql
postgres=# select count(1) as "number of pages",pg_size_pretty(cast(avg(avail) as bigint)) as "freespace size",round(100 * avg(avail)/8192,2)||'%' as "freespace tatio" from pg_freespace('t1');
 number of pages | freespace size | freespace tatio 
-----------------+----------------+-----------------
           10811 | 3712 bytes     | 45.31%
(1 row)
postgres=# 
postgres=# vacuum FULL t1;
VACUUM
postgres=# select count(1) as "number of pages",pg_size_pretty(cast(avg(avail) as bigint)) as "freespace size",round(100 * avg(avail)/8192,2)||'%' as "freespace tatio" from pg_freespace('t1');
 number of pages | freespace size | freespace tatio 
-----------------+----------------+-----------------
            5406 | 0 bytes        | 0.00%
(1 row)
```



#### 3.5.7 pg_prewarm预热插件

利用下面的语句可以创建此插件：

```sql
create EXTENSION pg_prewarm;
```

实际上，创建插件的过程只是用下面的语句创建了pg_prewarm函数。这个函数是此插件提供的唯一函数：

```sql
CREATE FUNCTION pg_prewarm(regclass,
mode text default buffer,
fork text default main,
first_block int8 default null,
last_block int8 default null)
RETURNS int8
AS MODULE_PATHNAME, pg_prewarm
LANGUAGE C
```

<u>含义如下：</u>

- regclass：要做prewarm的表名
- mode：prewarm模式。prefetch表示异步预取到os cache；read表示同步预取；buffer表示同步读入PG的shared buffer
- fork：relation fork的类型。一般用main，其他类型有visibilitymap和fsm
- first_block & last_block：开始和结束块号。表的first_block=0，last_block可通过pg_class的relpages字段获得
- RETURNS int8：函数返回pg_prewarm处理的block数目（整型）

再来看看prewarm性能上能达到多大效果。将PG的shared buffer设为2G，OS内存7G。然后创建个大小近1G的表test：

```sql
pgbench=#  SELECT pg_size_pretty(pg_total_relation_size(test));

pg_size_pretty
----------------

995 MB
```

1）不进行pg_prewarm

```sql
pgbench=# explain analyze select count(*) from test;

QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------

Aggregate  (cost=377389.91..377389.92 rows=1 width=0) (actual time=22270.304..22270.304 rows=1 loops=1)
->  Seq Scan on test  (cost=0.00..327389.73 rows=20000073 width=0) (actual time=0.699..18287.199 rows=20000002 loops=1)
Planning time: 0.134 ms
Execution time: 22270.383 ms
```

2）read模式prewarm（test表的数据被同步读入os cache）

```sql
pgbench=# select pg_prewarm(test, read, main);

pg_prewarm
------------

127389

pgbench=# explain analyze select count(*) from test;

QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------

Aggregate  (cost=377389.90..377389.91 rows=1 width=0) (actual time=8577.767..8577.767 rows=1 loops=1)
->  Seq Scan on test  (cost=0.00..327389.72 rows=20000072 width=0) (actual time=0.086..4716.444 rows=20000002 loops=1)
Planning time: 0.049 ms
Execution time: 8577.831 ms
```

3）buffer模式prewarm（同步读入PG的shared buffer）

```sql
pgbench=# select pg_prewarm(test, buffer, main);

pg_prewarm
------------

127389

pgbench=# explain analyze select count(*) from test;

QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------

Aggregate  (cost=377389.90..377389.91 rows=1 width=0) (actual time=8214.277..8214.277 rows=1 loops=1)
->  Seq Scan on test  (cost=0.00..327389.72 rows=20000072 width=0) (actual time=0.015..4250.300 rows=20000002 loops=1)
Planning time: 0.049 ms
Execution time: 8214.340 ms
```

比read模式时间略少，但相差不大。可见如果os cache够大，数据取到OS cache还是shared buffer对执行时间影响不大（在不考虑其他应用影响PG的情况下）。

4）prefetch模式

这里我们有意在pg_prewarm返回后，立即执行全表查询。这样在执行全表查询时，可能之前的预取还没完成，从而使全表查询和预取并发进行，缩短了总的响应时间。

```sql
explain analyze select pg_prewarm(test, prefetch, main);

QUERY PLAN
------------------------------------------------------------------------------------------
Result  (cost=0.00..0.01 rows=1 width=0) (actual time=1011.338..1011.339 rows=1 loops=1)
Planning time: 0.124 ms
Execution time: 1011.402 ms

explain analyze select count(*) from test;

QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------

Aggregate  (cost=377389.90..377389.91 rows=1 width=0) (actual time=8420.652..8420.652 rows=1 loops=1)
->  Seq Scan on test  (cost=0.00..327389.72 rows=20000072 width=0) (actual time=0.065..4583.200 rows=20000002 loops=1)
Planning time: 0.344 ms
Execution time: 8420.723 ms
```

可以看到，总的完成时间也是8秒多，使用pg_prewarm做预取大大缩短了总时间。因此在进行全表扫描前，做一次异步的prewarm，不失为一种优化全表查询的方法。



#### 3.5.8 pg_stat_statements跟踪SQL

<a href="#pg_stat_statements">见"我要学会怎么看——数据库日常查询——等待事件"</a>



#### 3.5.9 pgaudit审计

<u>各版本对应支持</u>：
pgAudit v1.5.X is intended to support PostgreSQL 13.
pgAudit v1.4.X is intended to support PostgreSQL 12.
pgAudit v1.3.X is intended to support PostgreSQL 11.
pgAudit v1.2.X is intended to support PostgreSQL 10
pgAudit v1.1.X is intended to support PostgreSQL 9.6.
pgAudit v1.0.X is intended to support PostgreSQL 9.5.

地址：https://github.com/pgaudit/pgaudit/tree/REL_13_STABLE

<u>安装步骤：</u>
解压到指定目录

```shell
$ unzip -d /home/postgres/ /software/medias/pgaudit-REL_13_STABLE.zip
```

进入解压目录并编译安装

```shell
$ cd /software/medias/pgaudit-REL_13_STABLE
$ make install USE_PGXS=1 PG_CONFIG=/software/pgsql13/bin/pg_config
```

将pgaudit添加到PostgreSQL共享库，并重启数据库生效

```shell
$ vi $PGDATA/postgresql.conf

shared_preload_libraries = 'pgaudit'
```

创建扩展

```sql
postgres=# create extension pgaudit;
```

各参数默认值：

```sql
postgres=# select name,setting from pg_settings where name like 'pgaudit%';
            name            | setting 
----------------------------+---------
 pgaudit.log                | none
 pgaudit.log_catalog        | on
 pgaudit.log_client         | off
 pgaudit.log_level          | log
 pgaudit.log_parameter      | off
 pgaudit.log_relation       | off
 pgaudit.log_statement_once | off
 pgaudit.role               | 
(8 rows)
```

<u>参数解释：</u>

pgaudit.log

指定会话审计日志将记录哪些类的语句。可能的值为：

- READ：当源是关系或查询时SELECT。COPY
- WRITE : INSERT, UPDATE, DELETE, TRUNCATE, 以及COPY当目标是关系时。
- FUNCTION：函数调用和DO块。
- ROLE：与角色和权限相关的语句：GRANT, REVOKE, CREATE/ALTER/DROP ROLE.
- DDL：所有DDL未包含在ROLE课程中的内容。
- MISC：杂项命令，例如DISCARD, FETCH, CHECKPOINT, VACUUM, SET.
- MISC_SET：其他SET命令，例如SET ROLE.
- ALL：包括以上所有内容。
- 可以使用逗号分隔的列表提供多个类，并且可以通过在类前加上-符号来减去类
- set pgaudit.log = 'all, -misc';
- 默认值为none

pgaudit.log_catalog
指定在语句中的所有关系都在 pg_catalog 中的情况下应启用会话日志记录。禁用此设置将减少来自 psql 和 PgAdmin 等工具大量查询目录的日志中的噪音。
默认值为on

pgaudit.log_client
指定日志消息是否对客户端进程（如 psql）可见。此设置通常应禁用，但可能对调试或其他目的有用。
请注意，pgaudit.log_level仅在pgaudit.log_clientis时启用on。
默认值为off.

pgaudit.log_level
指定将用于日志条目的日志级别（有关有效级别，请参阅消息严重级别），但请注意，ERROR不允许使用FATAL、 和）。PANIC此设置用于回归测试，也可能对最终用户用于测试或其他目的有用。
请注意，pgaudit.log_level仅在pgaudit.log_clientis时启用on；否则将使用默认值。

| **严重性**        | **用法**                                               | **系统日志** | **事件日志** |
| ----------------- | ------------------------------------------------------ | ------------ | ------------ |
| DEBUG1  .. DEBUG5 | 提供更详细的信息供开发人员使用。                       | DEBUG        | INFORMATION  |
| INFO              | 提供用户隐式请求的信息，例如来自VACUUM  VERBOSE.       | INFO         | INFORMATION  |
| NOTICE            | 提供可能对用户有帮助的信息，例如，长标识符的截断通知。 | NOTICE       | INFORMATION  |
| WARNING           | 提供可能问题的警告，例如，COMMIT在事务块之外。         | NOTICE       | WARNING      |
| ERROR             | 报告导致当前命令中止的错误。                           | WARNING      | ERROR        |
| LOG               | 向管理员报告感兴趣的信息，例如检查点活动。             | INFO         | INFORMATION  |
| FATAL             | 报告导致当前会话中止的错误。                           | ERR          | ERROR        |
| PANIC             | 报告导致所有数据库会话中止的错误。                     | CRIT         | ERROR        |

默认值为log.

pgaudit.log_parameter
指定审计日志记录应包括与语句一起传递的参数。当参数存在时，它们将包含在CSV语句文本之后的格式中。
默认值为off.

pgaudit.log_relation
指定会话审计日志记录是否应为or语句中引用的每个关系（ TABLE、VIEW等）创建单独的日志条目。这是在不使用对象审计日志的情况下进行详尽日志记录的有用快捷方式，记录查询对象的类型。SELECT DML
默认值为off.

pgaudit.log_statement_once
指定日志记录是否将语句文本和参数包含在语句/子语句组合的第一个日志条目中或每个条目中。禁用此设置将减少详细的日志记录，但可能会使确定生成日志条目的语句变得更加困难，尽管语句/子语句对以及进程 ID 应该足以识别与先前条目记录的语句文本。
默认值为off.

pgaudit.role
指定用于对象审计日志记录的主角色。可以通过将多个审计角色授予主角色来定义它们。这允许多个组负责审计日志记录的不同方面。
没有默认值。

<u>参考设置：</u>

```
pgaudit.log = 'read,write'
pgaudit.log_catalog = 'off'
pgaudit.log_client = 'off'
pgaudit.log_level = 'log'
pgaudit.log_parameter = 'on'
pgaudit.log_relation = 'on'
pgaudit.log_statement_once = 'off'
pgaudit.role = 'will'
```



#### 3.5.10 session_exec会话访问

地址：https://github.com/okbob/session_exec

解压到指定目录

```shell
$ unzip -d /home/postgres/ session_exec-master.zip
```

进入解压目录并编译安装

```shell
$ make pg_config=/software/pgsql13/bin/pg_config
$ make pg_config=/software/pgsql13/bin/pg_config install
```

配置文件中修改添加并重启数据库服务

```shell
$ vi $PGDATA/postgresql.conf

logging_collector=on
log_destination='csvlog'
log_connections = on
session_preload_libraries='session_exec'
session_exec.login_name='public.login'
```

创建file_fdw

```sql
postgres=# create extension file_fdw;
```

创建外部表

```sql
postgres=# CREATE SERVER pglog FOREIGN DATA WRAPPER file_fdw;

postgres=# 
CREATE FOREIGN TABLE public.postgres_log(
log_time timestamp(3) with time zone,
user_name text,
database_name text,
process_id integer,
connection_from text,
session_id text,
session_line_num bigint,
command_tag text,
session_start_time timestamp with time zone,
virtual_transaction_id text,
transaction_id bigint,
error_severity text,
sql_state_code text,
message text,
detail text,
hint text,
internal_query text,
internal_query_pos integer,
context text,
query text,
query_pos integer,
location text,
application_name text,
backend_type text
) SERVER pglog
OPTIONS ( program 'find /software/pgsql13/data/log -type f -name "*.csv" -mtime -1 -exec cat {} \;', format 'csv' );
```

授权表查询权限

```sql
postgres=# grant SELECT on postgres_log to PUBLIC ;
```

创建函数

```sql
postgres=#
create or replace function public.login() returns void as $$
declare
res record;
failed_login_times int = 5;
failed_login int = 0;
begin
--获取数据库中所有可连接数据库的用户
for res in select rolname from pg_catalog.pg_roles where rolcanlogin= 't' and rolname !='postgres'
loop
  raise notice 'user: %!',res.rolname;
  --获取当前用户最近连续登录失败次数
  select count(*)
  from (select log_time,user_name,error_severity,message,detail from public.postgres_log where command_tag = 'authentication' and user_name = res.rolname and (detail is null or detail not like 'Role % does not exist.%') order by log_time desc limit failed_login_times) A
  WHERE A.error_severity='FATAL'
  into  failed_login ;
  raise notice 'failed_login_times: %! failed_login: %!',failed_login_times,failed_login;
  --用户最近密码输入错误次数达到5次或以上
  if failed_login >= failed_login_times then
    --锁定用户
    EXECUTE format('alter user %I nologin',res.rolname);
    raise notice 'Account % is locked!',res.rolname;
  end if;
end loop;
end;
$$ language plpgsql strict security definer set search_path to 'public';
```

查询日志记录表

```sql
postgres=# select log_time,user_name,error_severity,message,detail from public.postgres_log where command_tag = 'authentication'  order by log_time desc limit 10 offset 0;
```

解锁账户

```sql
postgres=# alter user will login ;
```



#### 3.5.11 walminer日志挖掘







### 3.6 开源工具

#### 3.6.1 pgbouncer连接池

下载地址

http://www.pgbouncer.org/downloads/

上传到服务器目录下并解压

```shell
# tar xzvf pgbouncer-1.17.0.tar.gz
```

编译安装

```shell
./configure --prefix=/usr/local --with-libevent=libevent-prefix
make && make install
```

如果出现No package 'libevent' found

![checking for library containing gethostbyname.  . none required  checking for library containing hstrerror..,  none required  checking for Istat.  yes  checking for LIBEVENT.  configure: error: package requirements (libevent) were not met:  NC acka e I Ibevent' found  Consider adjusting the PKG CONFIG PATH envi ronment variable if you  installed software In a non -standard prefix.  Alternatively. you may set the environment variables LIBEVENT CFL AGS  and LIBÉVÉNT LISS to avoid the need to call pkg-config. ](data:image/png;base64,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)

解决办法，下载安装libevent：

http://libevent.org/

上传解压编译安装

```shell
# tar xzvf libevent-2.1.12-stable.tar.gz
# cd libevent-2.1.12-stable/
# ./configure
# make && make install
```

 查看是否安装成功

```shell
# ls -al /usr/local/lib |grep libevent
```

加载环境变量

```shell
# export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```

重新编译安装

```shell
# ./configure --prefix=/usr/local --with-libevent=libevent-prefix
# make && make install
```

添加环境变量

```shell
$ vi ~/.bash_profile
export LD_LIBRARY_PATH=/software/pgsql13/lib:$LD_LIBRARY_PATH:/usr/local/lib
```

查看版本信息

```shell
$ pgbouncer -V
PgBouncer 1.17.0
libevent 2.1.12-stable
adns: evdns2
tls: OpenSSL 1.0.2k-fips  26 Jan 2017
```

使用postgres用户操作，创建一个pgbouncer文件夹

```shell
$ mkdir /home/postgres/pgbouncer
$ cd /home/postgres/pgbouncer
```

创建pgbouncer.ini

```
[databases]
willdb = host=10.0.4.13 port=5432 dbname=postgres connect_query='select 1'

[pgbouncer]
logfile = /home/postgres/pgbouncer/pgbouncer.log                            # 日志文件位置
pidfile = /home/postgres/pgbouncer/pgbouncer.pid                            # pid文件位置
listen_addr = 127.0.0.1                                                     # 监听的地址，如果全地址可连接，则使用*，如果多个地址，以逗号隔开
listen_port = 6432                                                          # 监听的端口
auth_type = md5                                                             # 认证方式
auth_file = /home/postgres/pgbouncer/userlist.txt                           # 认证文件
admin_users = postgres                                                      # 管理员用户名
stats_users = stats, postgres                                               # 状态用户 stats和postgres
pool_mode = session                                                         # 池的模式，默认session级别
server_reset_query = DISCARD ALL                                            # 连接回到池后会被清理，不会影响新的链接
max_client_conn = 100                                                       # 最大连接用户数，客户端到pgbouncer的链接数量
default_pool_size = 20                                                      # 默认池大小，表示建立多少个pgbouncer到数据库的连接
```

创建userlist.txt

```sql
postgres=# copy (select '"'||usename||'" "'||passwd||'"' from pg_shadow order by 1) to '/home/postgres/pgbouncer/userlist.txt';
COPY 10
```

启动pgbouncer

```shell
$ pgbouncer -d pgbouncer.ini
```

如果出现以下报错，注意用户名和密码都需要加引号，虽然也能正常启动，但是登陆会显示用户不存在

<img src="C:\Users\will\AppData\Roaming\Typora\typora-user-images\image-20220720155156618.png" alt="image-20220720155156618" style="zoom:150%;" />

连接测试（以pgbouncer端口登录，密码不是用md5输入，正常输入即可）

```sql
$ psql -p6432 -dwilldb -Upostgres
```

停止pgbouncer

```sql
$ psql -p 6432  -U postgres pgbouncer
Password for user postgres: 
psql (13.4, server 1.17.0/bouncer)
Type "help" for help.

pgbouncer=# shutdown;
server closed the connection unexpectedly
	This probably means the server terminated abnormally
	before or while processing the request.
The connection to the server was lost. Attempting reset: Failed.
!?> \q
```

也可以通过kill方式，但是这种方式需要手动清理掉pgbouncer.pid文件以及/tmp下的socket文件

```shell
$ cat /home/psotgres/pgbouncer/pgbouncer.pid | xargs kill -9
```

常用命令

| **命令**       | **作用**                                                     |
| -------------- | ------------------------------------------------------------ |
| show config    | 查看配置                                                     |
| show databases | 查看[database]列表中每一行的连接情况（即便2行是同一个数据库也会分开显示） |
| show stats     | 查看每个数据库总的连接情况每隔一个stats_period(60s)更新一次  |
| show clients   | 显示所有的连接信息，  addr客户端的ip,local_addr  服务端的IP，ptr连接的UniqueID |
| show pools     | 见下方                                                       |

```sql
pgbouncer=# show pools;
-[ RECORD 2 ]-----------
database   | ttt1
user       | xhz_login
cl_active  | 2                      ####客户端连接的数量，有两个正在连接
cl_waiting | 1                      ####客户端等待数量，因为我的poolsize设置为1，所以有一个再等待
sv_active  | 1                      ####postgres进程的active的数量，此处表示只有一个。
sv_idle    | 0
sv_used    | 0
sv_tested  | 0
sv_login   | 0
maxwait    | 10                     ####等待的时间，单位s，等待结束后清0
maxwait_us | 411432
pool_mode  | transaction
```

其它参考

https://developer.aliyun.com/article/873913



#### 3.6.2 keepalived

环境介绍

OS Version：CentOS Linux release 7.7.1908 (Core)  

Keepalived Version：Keepalived v1.3.5

POSTGRES Version：Postgres12.5

OS Environment：

| IP             | PORT |
| -------------- | ---- |
| 192.168.22.128 | 5432 |
| 192.168.22.129 | 5432 |

（1）安装基础环境

安装keepalived

```shell
yum install keepalived
```

（2）修改软件基础设置

为了让keepalived的日志记录不与系统日志混淆，该操作皆在设置单独的keepalived的日志记录

修改keepalived系统配置文件

```shell
vim /etc/sysconfig/keepalived
将KEEPALIVED_OPTIONS="-D"改为KEEPALIVED_OPTIONS="-D -d -S 0"
```

在/etc/rsyslog.conf 末尾添加

```shell
[root@node1 /]# vim /etc/rsyslog.conf 
local0.*                                                /var/log/keepalived.log
```

重启日志记录服务

```shell
[root@node1 /]# systemctl restart rsyslog
```

重启keepalived服务

```shell
[root@node1 /]#systemctl restart keepalived
或者
[root@node1 /]#ps -ef|grep keepalived|awk '{print $2}'|xargs kill -9
[root@node1 /]#systemctl start keepalived
```

（3）主库软件配置

主库配置keepalived

```shell
vim /etc/keepalived/keepalived.conf

! Configuration File for keepalived

global_defs {
   notification_email {
     huwenhao@mchz.com.cn
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.22.128
   smtp_connect_timeout 30
   router_id pg_28
   vrrp_skip_check_adv_addr
   #vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
   script_user root
   enable_script_security
}
#以上为邮箱设置
#此项相关健康检查脚本配置信息
vrrp_script check_pg_alived {
   script "/etc/keepalived/scripts/check_pg.sh"
   interval 2
   weight -5
   fall 2
   rise 1
}

vrrp_instance VI_1 {
state BACKUP
    interface ens33
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
        track_script {
        check_pg_alived
     }
    #设置vip
    virtual_ipaddress {
        192.168.22.130
    }
}
```

（4）从库软件配置

从库配置keepalived

```shell
vim /etc/keepalived/keepalived.conf

! Configuration File for keepalived

global_defs {
   notification_email {
     huwenhao@mchz.com.cn
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.22.129
   smtp_connect_timeout 30
   router_id pg_29
   vrrp_skip_check_adv_addr
   #vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
   script_user root
   enable_script_security
}
#以上为邮箱设置
#此项相关健康检查脚本配置信息
vrrp_script check_pg_alived {
   script "/etc/keepalived/scripts/check_pg.sh"
   interval 2
   weight -5
   fall 2
   rise 1
}

vrrp_instance VI_1 {
        state BACKUP
    interface ens33
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
        track_script {
        check_pg_alived
     }
    #设置vip
    virtual_ipaddress {
        192.168.22.130
    }
}
```

（5）添加健康检查脚本

主备库在目录/etc/keepalived/scripts/下添加check_pg.sh脚本

```shell
vi check_pg.sh

#!/bin/bash
#判断pg是否活着
A=`ps -C postgres --no-header | wc -l`

#判断vip浮到哪里
B=`ip a | grep 192.168.22.130 | wc -l`

#判断是否是从库处于等待的状态
C=`ps -ef | grep postgres | grep 'startup' | wc -l`

#判断从库链接主库是否正常
D=`ps -ef | grep postgres | grep 'receiver' | wc -l`

#判断主库连接从库是否正常
E=`ps -ef | grep postgres | grep 'sender' | wc -l`

#如果pg死了，将消息写入日记并且关闭keepalived
if [ $A -eq 0 ];then
        echo "`date "+%Y-%m-%d--%H:%M:%S"` postgresql stop so vip stop " >> /etc/keepalived/log/check_pg.log
        systemctl stop keepalived
        ps -ef|grep keepalived|awk '{print $2}'|xargs kill -9
else
        #判断出主ku挂了，vip漂移到了从，提升从的地位让他可读写
        if [ $B -eq 1 -a $C -ne 0 -a $D -eq 0 ];then
                su - postgres -c "pg_ctl promote -D /pgdata/data/"   #重新加载pgsql使其可写
                echo "`date "+%Y-%m-%d--%H:%M:%S"` standby promote " >> /etc/keepalived/log/check_pg.log
        fi
        #判断出自己是主并且和从失去联系
        if [ $B -eq 1 -a $C -eq 0 -a $D -eq 0 -a $E -eq 0 ];then
                echo "`date "+%Y-%m-%d--%H:%M:%S"` can't find standby " >> /etc/keepalived/log/check_pg.log
        fi
fi
```

修改脚本执行权限

```shell
chmod 744 /etc/keepalived/scripts/check_pg.sh
```

（6）启动服务

启动主备库

```shell
pg_ctl start -D /pgdata/data/ -l logfile
```

启动keepalived服务

```shell
systemctl start keepalived 
```

查看keepalived服务状态

```shell
systemctl status keepalived
```

（7）模拟操作

模拟主库宕机或者关停主库

```shell
ps -ef|grep postgres|awk '{print $2}'|xargs kill -9
```

此时发现vip节点漂移至备库且备库晋升为主库

*注意事项*
*脚本的执行权限必须修改，否则会报错脚本执行被禁用，并且，需要在keepalived.conf的配置文件中global_defs参数加上script_user root及enable_script_security，才能允许脚本的正常执行*







## （四）我要学会怎么修

### 4.1 连接问题

#### 4.1.1 无法连接template0库

报错信息：

```
FATAL: database "template0" is not currently accepting connections
```

解决方法：

```sql
--修改template0权限可以连接
update pg_database set datallowconn = TRUE where datname = 'template0';

--修改template0权限拒绝连接
update pg_database set datallowconn = FALSE where datname = 'template0';
```



#### 4.1.2 连接数不够用

报错信息：

```shell
$ psql -Uwill -dwill
psql: error: FATAL:  remaining connection slots are reserved for non-replication superuser connections
```

解决方法：

修改最大可用连接数max_connections，普通用户最多可用的连接数为

```
max_connections(默认100) - superuser_reserved_connections(默认3)
```



4.1.3 



### 4.2 LD_LIBRARY_PATH动态共享库

#### 4.2.1 socket文件指向不正确

报错信息：

```shell
[postgres@node1 tmp]$ psql
psql: error: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?
```

解决方法：

postgresql.conf修改参数

```
unix_socket_directories = '/var/run/postgresql/'
```

或者检查

```shell
export LD_LIBRARY_PATH=/data/pg12.1/lib/:/ogg19c/lib:/home/postgres/libevent/lib:$LD_LIBRARY_PATH
```



#### 4.2.2 PQsetErrorContextVisibility

报错信息：

```shell
/data/pgdata/bin/psql: symbol lookup error: /data/pgdata/bin/psql: undefined symbol: PQsetErrorContextVisibility
```

解决方法：

配置动态库变量

```shell
export LD_LIBRARY_PATH=/data/pgdata/lib
```



#### 4.2.3 libpq.so.5缺失

报错信息：

```
Error while loading shared libraries: libpq.so.5: cannot open shared object file
```

解决方法：

```
在~/.bashrc中加入：
export LD_LIBRARY_PATH=/usr/local/postgresql/lib

路径视自己的安装路径情况而定，然后source ~/.bashrc
```




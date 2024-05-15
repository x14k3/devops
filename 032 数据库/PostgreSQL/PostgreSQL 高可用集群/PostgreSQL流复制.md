# PostgreSQL流复制

简单介绍一些基础概念与原理，首先我们做主从同步的目的就是实现db服务的高可用性，通常是一台主数据库提供读写，然后把数据同步到另一台从库，然后从库不断apply从主库接收到的数据，从库不提供写服务，只提供读服务。在postgresql中提供读写全功能的服务器称为primary  database或master database，在接收主库同步数据的同时又能提供读服务的从库服务器称为hot standby server。

PostgreSQL在数据目录下的pg_xlog子目录中维护了一个WAL日志文件，该文件用于记录数据库文件的每次改变，这种日志文件机制提供了一种数据库热备份的方案，即：在把数据库使用文件系统的方式备份出来的同时也把相应的WAL日志进行备份，即使备份出来的数据块不一致，也可以重放WAL日志把备份的内容推到一致状态。这也就是基于时间点的备份（Point-in-Time  Recovery），简称PITR。而把WAL日志传送到另一台服务器有两种方式，分别是：

1. WAL日志归档（base-file）
2. 流复制（streaming replication）

第一种是写完一个WAL日志后，才把WAL日志文件拷贝到standby数据库中，简言之就是通过cp命令实现远程备份，这样通常备库会落后主库一个WAL日志文件。而第二种流复制是postgresql9.x之后才提供的新的传递WAL日志的方法，它的好处是只要master库一产生日志，就会马上传递到standby库，同第一种相比有更低的同步延迟，所以我们肯定也会选择流复制的方式。

在实际操作之前还有一点需要说明就是standby的搭建中最关键的一步——在standby中生成master的基础备份。postgresql9.1之后提供了一个很方便的工具——  pg_basebackup，关于它的详细介绍和参数说明可以在官网中查看（pg_basebackup  tool），下面在搭建过程中再做相关具体说明，关于一些基础概念和原理先介绍到这里。

‍

## 环境准备

首先根据 PostgreSQL 安装部署 在两台机器上部署pg, 备库不需要初始化数据库数据目录

primary  192.168.133.11  Centos7.9  psql (PostgreSQL) 12.15

standby  192.168.133.12  Centos7.9  psql (PostgreSQL) 12.15

‍

## 配置primary库

### 初始化数据库

备库不需要初始化数据库数据目录，以下参数的修改均在主库执行：

```bash
/data/pgsql/bin/initdb -D /data/pgsql/data/ -U postgres -W -A peer -E UTF8
```

### 创建同步用户

启动primary上的数据库 `pg_ctl restart`​

使用超级用户postgres登录到数据库创建流复制用户repuser，流复制用户需要有replication和login权限，该部分建议新建流复制专用用户而不是使用超级用户：

```sql
create user replica replication login connection limit 5 encrypted password 'replica';
```

### 修改主库配置文件postgresql.conf

​`vim /data/pgsql/data/postgresql.conf`​ 开启归档和流复制

```bash
wal_level = replica    # 该参数控制WAL日志信息的输出级别，有minimal， replica， logical三种模式，修改该参数需要重启。
                       # minimal记录的日志最少，只记录数据库异常关闭需要恢复时的WAL信息。
                       # replica记录的WAL信息比minimal信息多些，会记录支持WAL归档、复制和备库中启用只读查询等操作所需的WAL信息。
                       # logical记录的日志最多，包含了支持逻辑解析所需的WAL，
                       # 开启流复制至少需要设置为replica级别。

archive_mode = on      # 开启归档模式，修改该参数需要重启数据库。
archive_command = 'test ! -f /data/pgsql/archive/%f && cp %p /data/pgsql/archive/%f'  # 归档日志保存路径
#archive_command = 'copy "%p" "C:\\server\\archivedir\\%f"'  # Windows
max_connections = 100     # 最大连接数，必须不大于从库的配置
max_wal_senders = 10      # 最大流复制连接，一般和从服务相等
wal_sender_timeout = 60s  # 流复制超时时间
wal_keep_segments = 512   # 该参数设置主库pg_wal （10版本以前是pg—xlog）目录保留的最小WAL日志文件数，
                          # 以便备库落后主库时可以通过主库保留的WAL进行追回，默认情况下每个WAL文件为16MB（编译时可通l过-with-wal-segsize设置WAL文件大小)
```

### 修改主库配置文件pg_hba.conf

​`vim /data/pgsql/data/pg_hba.conf`​ 开启备库的连接权限

```bash
#replication privilege
hots   replication     replica 192.168.133.11/32  md5
hots   replication     replica 192.168.133.22/32  md5
```

修改完配置后重启主库

```bash
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  stop
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  start
```

‍

## 配置standby库

### 备份数据

在standby以pg_basebackup命令部署流复制：

```sql
pg_basebackup -D /data/pgsql/data -Fp -Xs -v -P -h 192.168.133.11 -p 5432 -U replica
--pg_basebackup命令执行的操作为 将主库的数据目录同步到备节点，保证主备数据目录保持一致。
```

**pg_basebackup命令中的参数说明：**   
  -h 指定连接的数据库的主机名或IP地址，这里就是主库的ip  
  -U 指定连接的用户名，此处是我们刚才创建的专门负责流复制的repl用户  
  -F 指定生成备份的数据格式，支持p（plain原样输出）或者t（tar格式输出）  
  -X 表示备份开始后，启动另一个流复制连接从主库接收WAL日志，有 f(fetch)和s (stream）两种方式，建议使用s方式  
  -P 表示显示数据文件、表空间传输的近似百分比 允许在备份过程中实时的打印备份的进度  
  -v 表示启用verbose模式，命令执行过程中会打印各阶段日志，建议启用  
  -R 表示会在备份结束后~~自动生成recovery.conf文件，~~ 自动生成了standby.signal文件，这样也就避免了手动创建  
  -D 指定把备份写到哪个目录，这里尤其要注意一点就是做基础备份之前从库的数据目录（/data/postgresql/data）目录需要手动清空  
  -l 表示指定个备份的标识，运行命令后可以看到进度提示

‍

### 修改从库配置文件postgresql.conf

```bash
wal_level = replica     # 决定多少信息写入WAL，此处为replica模式
max_connections = 300   # 最大连接数，必须不小于主库的配置

max_standby_streaming_delay = 30s   # 流备份的最大延迟时间
wal_receiver_status_interval = 10s  # 向主服务器汇报本机状态的间隔时间
hot_standby_feedback = on  # 是否向主服务器反馈错误的数据复制

recovery_target_timeline = 'latest'
primary_conninfo = 'host=192.168.133.11 port=5432 user=replica password=replica'
hot_standby = on          # "no"表示只读备机
```

‍

如果是早于V12版本的postgresql 则需要recovery.conf文件

​`vim /data/pgsql/data/recovery.conf`​

```bash
recovery_target_timeline = 'latest'
standby_mode = on
primary_conninfo = 'host=192.168.133.11 port=5432 user=replica password=replica'

#-------------------------------------------------------------------------------------
#recovery_target_timeline  # 设置恢复的时间线（timeline），默认情况下是恢复到基准备份生成时的时间线，设置成latest表示 从备份中恢复到最近的时间线，通常流复制环境设置此参数为latest，复杂的恢复场景可将此参数设置成其他值
#standby_mode              # 设置是否启用数据库为备库，如果设置为on，备库会不停的从主库上获取WAL日志流，直到获取主库上最新的WAL日志流。primary_conninfo                # 参数设置主库的连接信息，设置了主库IP、端口、用户名信息，但没有配置明文密码，在连接串中给出数据库密码不是好习惯，建议将密码配置在隐藏文件~/.pgpass 中。
#$ touch ~/.pgpass
#$ chmod 0600 ~/.pgpass
#.pgpass文件内容分为五部分，分别为：
#IP:端口号:数据库名:用户名:密码
#192.168.133.11:5432:replication:replica:replica
#192.168.133.22:5432:replication:replica:replica
```

### 创建standby.signal

创建 standby.signal 文件，声明从库。该文件只是一个标识文件，它的存在就是告诉数据库，当我们执行pg_ctl start启动的时候，当前库的角色是standby，不是primary角色。

```text
# vim $PGDATA/standby.signal
#------------------------------
# 写入# 声明从库
# standby_mode = on
#------------------------------
touch $PGDATA/standby.signal
```

修改完配置后重启从库

```bash
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  stop
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  start
```

‍

### 确认同步效果

```bash
# 在主库执行
psql -xc "select * from pg_stat_replication"

#sync_state字段：
async  异步流复制
sync   同步流复制
```

---

## 将异步转为同步

### **修改从库配置文件postgresql.conf**

在 primary_conninfo 字段信息加上 application_name=slave ，其 中 slave 是为从库起的应用名称

```bash
primary_conninfo = 'application_name=slave host=192.168.133.11 port=5432 user=replica password=replica'
```

修改完配置后重启从库

```bash
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  stop
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  start
```

### 修改主库配置文件postgresql.conf

配置  synchronous_standby_names = 'slave' 属性，其中 slave 与上述从库配置中  primary_conninfo 的 application_name 一致即可。也可以使用 '*' 代替具体应用名  称，设置所有从库为同步模式。

```text
vim $PGDATA/postgresql.conf
# 添加下面语句
synchronous_standby_names = 'slave'
```

修改完配置后重启主库

```bash
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  stop
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/pg.log  start
```

### 同步流复制的问题

同步流复制模式中，由于主库提交事务时需等待至少一个备库接收WAL并返回确认信息后主库才向客户端返回成功，一方面保障了数据的完整性，另一方面对于一主一备的同步流复制环境存在一个典型的问题，具体表现为如果备库宕机，主库上的写操作将处于等待状态。

将备库停掉模拟备库故障，在主库上查询数据不受影响：

```sql
postgres=#SELECT * FROM test_sr LIMIT 1;
id
--------
1
(1 row)
```

在主库上尝试插入一条记录，命令被阻塞：

```sql
postgres=# INSERT INTO test_sr (id)VALUES (5);
```

这时主库上的INSERT语句一直处于等待状态，也就是说同步备库宕机后，主库上的读操作不受影响，写操作将处于阻塞状态，因为主库上的事务需收到至少一个备库接收WAL后的返回信息才会向客户端返回成功，而此时备库已经停掉了，主库上收不到备库发来的确认信息。

通常一主一备的情况下不会采用同步复制方式，因为备库宕机后同样对生产系统造成严重影响。

解决方案：

* 一主多备，提高系统可用性  
  PostgreSQL支持一主多从的流复制架构，比如一主两从，将其中一个备库设为同步备库，另一个备库设为异步备库，当同步备库宕机后异步备库升级为同步备库，同时主库上的读写操作不受影响。
* 出现这个问题后，改同步为异步。

  ```sql
  -- 将参数synchronous_standby_names = 'slave' 的值设置为空字符串
  synchronous_standby_names = ' '
  -- 重新加载pg
  -- 这个操作不会影响连接的客户端。主库继续进行事务处理
  -- 会保持客户端与相应的后端进程之间的所有会话。
  pg_ctl reload
  ```

---

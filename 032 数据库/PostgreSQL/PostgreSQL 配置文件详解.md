# PostgreSQL 配置文件详解

　　Pg的两个主要的配置文件：

* postgresql.conf --该文件包含内存分配、日志文件未知、监听端口、监听地址、数据库数据目录等一些数据库通用配置.
* pg_hba.conf

　　‍

# 一、[pg_settings]()

　　该视图用于访问服务器用到的一些参数，是show和set 命令的代替接口，有些show命令查看不了的也可以用该视图来查看。

|名字|类型|描述|
| ------------| ---------| ---------------------------------------------------------------------------------------------------------------------------------|
|name|text|运行时配置参数名|
|setting|text|参数的当前值|
|unit|text|参数的隐含单元|
|category|text|参数的逻辑组|
|short_desc|text|参数的一个简短的描述|
|extra_desc|text|有关参数的额外的，更详细的描述|
|context|text|设置这个参数的值要求的环境（见下文）|
|vartype|text|参数类型(bool,enum,integer,real,string)|
|source|text|当前参数值的来源|
|min_val|text|该参数允许的最小值(非数字值为 null)|
|max_val|text|这个参数允许的最大的数值(非数字值为 null)|
|enumvals|text[]|枚举参数允许的值（非枚举值为null）|
|boot_val|text|如果参数没有设置则为服务器启动时假设的参数值|
|reset_val|text|RESET在当前会话中将重设的参数值|
|sourcefile|text|设置当前值的配置文件（从源码而不是配置文件设置值或当通过非超级用户检查时为null）；  当在配置文件中使用include指令时是有帮助的。|
|sourceline|integer|设置当前值的配置文件中的行编码  （从源码而不是配置文件设置值或当通过非超级用户检查时为null）|

```pgsql
--通过pg_setting ，我们可以看到postgresql主要有下面三个配置文件
postgres=# select name, setting,source,short_desc from pg_settings where source='override' ;
          name          |              setting               |  source  |                               short_desc                            
------------------------+------------------------------------+----------+-------------------------------------------------------------------------
 config_file            | /data/pgsql/pgdata/postgresql.conf | override | 设置服务器的主配置文件
 data_checksums         | off                                | override | 显示当前簇是否开启数据校验和.
 data_directory         | /data/pgsql/pgdata                 | override | 设置服务器的数据目录
 hba_file               | /data/pgsql/pgdata/pg_hba.conf     | override | 设置服务器的 "hba" 配置文件
 ident_file             | /data/pgsql/pgdata/pg_ident.conf   | override | 设置服务器的 "ident" 配置文件
 lc_collate             | zh_CN.UTF-8                        | override | 显示排序规则顺序的语言环境
 lc_ctype               | zh_CN.UTF-8                        | override | 显示字符分类和按条件转换的语言环境.
 server_encoding        | UTF8                               | override | 设置服务器 (数据库) 字符编码.
 transaction_deferrable | off                                | override | 是否要延期执行一个只读可串行化事务，直到执行时不会出现任何可串行化失败.
 transaction_isolation  | read committed                     | override | 设置当前事物的隔离级别.
 transaction_read_only  | off                                | override | 设置当前事务的只读状态.
 wal_buffers            | 512                                | override | 为 WAL 设置共享内存中磁盘页缓冲区的个数.
 wal_segment_size       | 16777216                           | override | 显示预写日志段的大小.
(13 行记录)
```

　　‍

　　‍

# 二、数据库相关配置 postgresql.conf

　　该文件包含内存分配、监听端口、监听地址、数据库数据目录、日志文件位置等一些数据库通用配置。

　　通过pg_setting查看参数的值:

```pgsql
postgres=# select name, context, unit, setting, boot_val, reset_val from pg_settings where name in ('listen_address','max_connetctons','shared_buffers','effective_cache_size','work_mem','maintenance_work_mem') order by context, name;
         name         |  context   | unit | setting | boot_val | reset_val 
----------------------+------------+------+---------+----------+-----------
 shared_buffers       | postmaster | 8kB  | 16384   | 1024     | 16384
 effective_cache_size | user       | 8kB  | 524288  | 524288   | 524288
 maintenance_work_mem | user       | kB   | 65536   | 65536    | 65536
 work_mem             | user       | kB   | 4096    | 4096     | 4096
(4 行记录)

--● 字段说明:
--  context: 设置为postmaster，更改此形参后需要重启PostgreSQL服务才能生效；设置为user，那么只需要执行一次重新加载即可全局生效。重启数据库服务会终止活动连接，但重新加载不会。
--  unit : 字段表示这些设置的单位;
--  setting:是指当前设置；
--  boot_val:是指默认设置；
--  reset_val:是指重新启动服务器或重新加载设置之后的新设置;
-- 在postgresql.conf中修改了设置后，一定记得查看一下setting和reset_val并确保二者是一致，否则说明设置并未生效，需要重新启动服务器或者重新加载设置
```

```bash
# 此文件由以下几行组成:
#
# name = value
# ("="是可选的.)可以使用空格.注释是在一行的任何地方用"#"开头.参数名和允许值的完整列表可以在PostgreSQL文档中找到.

# 该文件中显示的注释化设置表示默认值.重新注释设置不足以将其还原为默认值;您需要重新加载服务器.
#
# 此文件在服务器启动时以及服务器接收到SIGHUP信号时读取.如果您在一个正在运行的系统上编辑文件,您必须检查服务器以使
# 更改生效,运行"pg_ctl reload"，或者执行"SELECT pg_reload_conf()".下面标记的一些参数需要服务器关闭并重新启动才能
# 生效.
#
# 任何参数也可以作为服务器的命令行选项,例如,"postgres -c log_connections=on".有些参数可以在运行时使用"SET"SQL命令
# 进行更改.
#
# Memory units(内存单元): kB = kilobytes        Time units(时间单元):  ms  = milliseconds
#                MB = megabytes(兆字节)            s    = seconds(秒)
#                GB = gigabytes(千兆字节)          min  = minutes(分钟)
#                TB = terabytes(兆兆字节)          h    = hours{时}
#                                                  d    = days(天)
```

　　‍

## <span data-type="text" style="color: var(--b3-font-color7);" parent-style="color: var(--b3-font-color3);">2.1 文件位置(FILE LOCATION)</span>

```bash
# 这些变量的默认值由-D命令行选项或PGDATA环境变量驱动,这里表示为ConfigDir.
#data_directory = 'ConfigDir'			# 使用其他目录中的数据(更改需要重新启动PG数据库)							
#hba_file 	= 'ConfigDir/pg_hba.conf'	# 基于主机的认证文件(更改需要重新启动PG数据库)
#ident_file 	= 'ConfigDir/pg_ident.conf'	# 标识配置文件(更改需要重新启动PG数据库)

# 如果未显式设置外部PID文件,则不会写入额外的PID文件.
#external_pid_file = ''				# 写一个额外的PID文件(更改需要重新启动PG数据库)
```

　　查看参数配置

```pgsql
show data_directory
select name,setting from pg_setting where name='data_directory'
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.2 连接和验证（CONNECTIONS AND AUTHENTICATION）</span>

　　**连接设置（Connection Settings）** 

```bash
#默认情况下,只允许登录了数据库的用户执行本地连接. 若想要任何远程的安装程序进行连接.则需要修改listen_addresses配置参数. 修改为='*',表示允许并接受任何地方传入的连接请求.
listen_addresses = '*'		# 监听哪个IP地址;以逗号分隔的地址列表.默认监听"localhost",(更改需要重新启动PG数据库)			
port = 5678			# PG服务监听端口号-默认端口5432.(更改需要重新启动PG数据库)
#每个客户端连接都会占用很小一部分的"共享内存",系统有限的共享内存默认是不允许过多的连接的. 该参数不能设置得过大,会浪费"共享内存".
max_connections = 100		# 最大连接数(更改需要重新启动PG数据库)
#superuser_reserved_connections = 3	#(更改需要重新启动PG数据库)
#unix_socket_directories = '/tmp'	#逗号分隔的目录列表(更改需要重新启动PG数据库)
		
#unix_socket_group = ''			# (更改需要重新启动PG数据库)
#unix_socket_permissions = 0777		# 从0开始使用八进制记数法(更改需要重新启动PG数据库)			
#bonjour = off				# 通过Bonjour发布服务器(更改需要重新启动PG数据库)							
#bonjour_name = ''			# 默认为计算机名(更改需要重新启动PG数据库)
	
# - TCP Keepalives -
# see "man 7 tcp" for details
#tcp_keepalives_idle 	= 0		# TCP_KEEPIDLE, in seconds(秒); 0-选择系统默认值						
#tcp_keepalives_interval= 0		# TCP_KEEPINTVL, in seconds(秒);0-选择系统默认值			
#tcp_keepalives_count  	= 0		# TCP_KEEPCNT;0-选择系统默认值

```

　　**认证（Authentication）** 

```bash
#authentication_timeout 	= 1min		# 1s-600s
#password_encryption 		= md5		# md5 or scram-sha-256
#db_user_namespace = off

# GSSAPI using Kerberos(使用kerberos的gssapi)
#krb_server_keyfile = ''
#krb_caseins_users = off
```

　　**SSL**

```bash
#ssl = off
#ssl_ca_file = ''
#ssl_cert_file = 'server.crt'
#ssl_crl_file = ''
#ssl_key_file = 'server.key'
#ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL' # allowed SSL ciphers
#ssl_prefer_server_ciphers = on
#ssl_ecdh_curve = 'prime256v1'
#ssl_dh_params_file = ''
#ssl_passphrase_command = ''
#ssl_passphrase_command_supports_reload = off
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.3 资源使用（RESOURCE USAGE (except WAL)）</span>

　　**内存（Memory）** 

```bash
# 共享内存,服务器使用共享内存的主要部分是分配给缓存块的大型块.用于读取或是写入数据库.
shared_buffers = 128MB		# 最小128kB(更改需要重新启动PG数据库)
#huge_pages = try		# on, off, or try(更改需要重新启动PG数据库)
#temp_buffers = 8MB		# 最小800kB
#max_prepared_transactions= 0	# 0-表示禁用该功能(更改需要重新启动PG数据库);注意:不建议将max_prepared_transactions设置为非零,	除非你打算用已经准备好的事务
#work_mem = 4MB			# 最小64kB.可以限制用于排序内存的大小,该值在客户端连接之后可以增加,该类型分配使用的是"非共享内存"
#maintenance_work_mem 	= 64MB	# 最小1MB
#autovacuum_work_mem 	= -1	# 最小1MB, or -1 to use maintenance_work_mem
#max_stack_depth 	= 2MB	# 最小100kB
dynamic_shared_memory_type = posix	#默认值是操作系统支持的第一个选项:posix,sysv,windows,mmap;使用none禁用动态共享内存

```

　　**磁盘（Disk）** 

```bash
#temp_file_limit = -1     # 每个进程的临时文件空间限制(以KB为单位).如果没有限制,则为-1
```

　　**内核资源（Kernel Resources）** 

```bash
#max_files_per_process = 1000   # 最小25(更改需要重新启动PG数据库)
```

　　**基于成本的真空延迟（ Cost-Based Vacuum Delay）** 

```bash
#vacuum_cost_delay = 0        # 0-100 milliseconds
#vacuum_cost_page_hit = 1     # 0-10000 credits
#vacuum_cost_page_miss = 10   # 0-10000 credits
#vacuum_cost_page_dirty = 20  # 0-10000 credits
#vacuum_cost_limit = 200      # 1-10000 credits
```

　　**后台写入（Background Writer）** 

```bash
#bgwriter_delay = 200ms        # 10-10000ms between rounds
#bgwriter_lru_maxpages = 100   # max buffers written/round, 0 disables
#bgwriter_lru_multiplier = 2.0 # 0-10.0 multiplier on buffers scanned/round
#bgwriter_flush_after = 512kB  # 以页计算,0-禁用
```

　　**异步行为（Asynchronous Behavior）** 

```bash
#effective_io_concurrency = 1         # 1-1000; 0-禁用预取
#max_worker_processes = 8             # (更改需要重新启动PG数据库生效)
#max_parallel_maintenance_workers = 2 # 取自max_parallel_workers
#max_parallel_workers_per_gather = 2  # 取自max_parallel_workers
#parallel_leader_participation = on
#max_parallel_workers = 8             # 可以在并行操作中使用的max_worker_processes的最大数量
#old_snapshot_threshold = -1          # 1min-60d; -1:禁用 0:立刻(更改需要重新启动PG数据库生效)   
#backend_flush_after = 0              # 以页为单位测量,0-禁用

```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.4 预写日志（WRITE-AHEAD LOG）</span>

　　**设置（Settings）** 

```bash
wal_level = replica    # 该参数控制WAL日志信息的输出级别，有minimal， replica， logical三种模式，修改该参数需要重启。
                       # minimal记录的日志最少，只记录数据库异常关闭需要恢复时的WAL信息。
                       # replica记录的WAL信息比minimal信息多些，会记录支持WAL归档、复制和备库中启用只读查询等操作所需的WAL信息。
fsync = on             # 将数据刷新到磁盘以确保崩溃安全(关闭此功能可能导致不可恢复的数据损坏)
synchronous_commit = on    # 同步等级: off, local, remote_write, remote_apply, or on
wal_sync_method = fsync    # 默认是操作系统支持的第一个选项:open_datasync, fdatasync (Linux默认),fsync,fsync_writethrough,open_sync
  
full_page_writes = on      # 从部分页面写恢复
wal_compression = off      # 启用整页写的压缩
wal_log_hints = off        # 也做整个页写的非关键的更新(更改需要重新启动PG数据库生效)

#用于控制缓存预写式日志数据的内存大小
wal_buffers = -1           # 最小32kB, -1:基于shared_buffers的设置(更改需要重新启动PG数据库生效)   

wal_writer_delay = 200ms     # 1-10000 milliseconds
wal_writer_flush_after = 1MB # 以页计算, 0-禁用 
commit_delay = 0             # range 0-100000, 以微妙为单位
commit_siblings = 5          # range 1-1000

```

　　**检查点（Checkpoints）** 

```bash
/*
 *若用户的系统速度赶不上写数据的速度,则可以适当提高该值.默认为5分钟。
*/
#checkpoint_timeout = 5min     # range 30s-1d
max_wal_size = 1GB             # 两个检查点（checkpoint）之间，WAL可增长的最大大小，即：自动WAL checkpoint允许WAL增长的最大值。该值缺省是1GB。如果提高该参数值会提升性能，但也是会消耗更多空间、同时会延长崩溃恢复所需要的时间。
min_wal_size = 80MB
#checkpoint_completion_target = 0.5 # 检查点目标持续时间, 0.0 - 1.0
#checkpoint_flush_after = 256kB     # 以页计算, 0-禁用 
#checkpoint_warning = 30s           # 0-禁用

```

　　‍

　　**存档（Archiving）** 

```bash
#archive_mode = off       # 启用存档-enables;关闭-off,打开-on 或始终-always (更改需要重新启动PG数据库生效)
#archive_command = ''     # 用于存档日志文件段占位符的命令:%p =文件路径到存档;%f =文件名.e.g. 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'
#archive_timeout = 0      # 在此秒数后强制执行日志文件段切换;0-禁用
#archive_cleanup_command  # archive_cleanup_command = 'pg_archivecleanup archivelocation %r' 自动清理归档日志

```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.5 复制（REPLICATION）</span>

　　**发送服务器（Sending Servers）** 

```bash
# 将它们设置在主服务器和任何将发送复制数据的备用服务器上.
#max_wal_senders = 10         # 最大walsender进程数.(更改需要重新启动PG数据库生效)
#wal_keep_segments = 0        # 在日志文件段中;0-禁用
#wal_sender_timeout = 60s     # 以毫秒为单位;0-禁用
#max_replication_slots = 10   # 复制槽的最大数目(更改需要重新启动PG数据库生效)
#track_commit_timestamp = off # 收集事务提交的时间戳(更改需要重新启动PG数据库生效)
```

　　**主服务器（Master Server）** 

```bash
# 这些设置在备用服务器上被忽略.
#synchronous_standby_names = '' # 提供sync rep方法的备用服务器,用于选择同步备用服务器,同步备用服务器的数量和备用服务器中的application_name的逗号分隔列表;‘*’=all
#vacuum_defer_cleanup_age = 0 # 延迟清理的xact数
```

　　**备用服务器（Standby Servers）** 

```bash
# 在主服务器上忽略这些设置.
#hot_standby = on                   # "off"不允许在恢复期间进行查询(更改需要重新启动PG数据库生效)
#max_standby_archive_delay = 30s    # 从存档读取wal时取消查询之前的最大延迟;-1允许无限延迟
#max_standby_streaming_delay = 30s  # 读取流wal时取消查询之前的最大延迟;-1允许无限延迟
#wal_receiver_status_interval = 10s # 至少要经常回复 0-禁用
#hot_standby_feedback = off         # 从备用服务器发送信息以防止查询冲突
#wal_receiver_timeout = 60s         # 接收方等待主方通信的时间(毫秒);0-禁用
#wal_retrieve_retry_interval = 5s   # 在尝试失败后重新尝试检索WAL之前，需要等待的时间
```

　　**订阅者（Subscribers）** 

```bash
# 在发布服务器上这些设置将被忽略
#max_logical_replication_workers = 4    # 取自max_worker_processes(更改需要重新启动PG数据库生效)
#max_sync_workers_per_subscription = 2  # 取自max_logical_replication_workers
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.6 查询调优（QUERY TUNING）</span>

　　**计划方法配置（Planner Method Configuration）** 

```bash
#enable_bitmapscan = on
#enable_hashagg = on
#enable_hashjoin = on
#enable_indexscan = on
#enable_indexonlyscan = on
#enable_material = on
#enable_mergejoin = on
#enable_nestloop = on
#enable_parallel_append = on
#enable_seqscan = on
#enable_sort = on
#enable_tidscan = on
#enable_partitionwise_join = off
#enable_partitionwise_aggregate = off
#enable_parallel_hash = on
#enable_partition_pruning = on
```

　　**计划成本常量（Planner Cost Constants）** 

```bash
#seq_page_cost = 1.0            # 在任意比例上测量
#random_page_cost = 4.0         # 同上量表
#cpu_tuple_cost = 0.01          # 同上量表
#cpu_index_tuple_cost = 0.005   # 同上量表
#cpu_operator_cost = 0.0025     # 同上量表
#parallel_tuple_cost = 0.1      # 同上量表
#parallel_setup_cost = 1000.0   # 同上量表
#jit_above_cost = 100000    #如果可用,执行JIT编译并查询比这更昂贵的开销.-1:禁用
#jit_inline_above_cost = 500000   # 如果查询的开销大于此值,则内联小函数.-1:将禁用
#jit_optimize_above_cost = 500000 # 如果查询的开销大于此值,则使用昂贵的JIT优化;-1将禁用
#min_parallel_table_scan_size = 8MB
#min_parallel_index_scan_size = 512kB
#effective_cache_size = 4GB
```

　　**查询优化器（Genetic Query Optimizer）** 

```bash
#geqo = on
#geqo_threshold = 12
#geqo_effort = 5        # range 1-10
#geqo_pool_size = 0       # selects default based on effort
#geqo_generations = 0     # selects default based on effort
#geqo_selection_bias = 2.0    # range 1.5-2.0
#geqo_seed = 0.0        # range 0.0-1.0
```

　　**其他计划选项（Other Planner Options）** 

```bash
/* 备注：为了注释的属性简洁,这里的注释用了C/C++中的注释语法，若是postgresql.conf文件中，则应该用"#"号
 * PostgreSQL根据数据库中每个表的统计情况来决定如何执行查询.这些信息通过“ANALYZE”或是“autovacuum”等
 * 步骤来获得,任一情况下，在分析任务期间所获得的信息量由default_statistics_target设置. 加大该值会延长
 * 分析时间.
 */
#default_statistics_target = 100  # range 1-10000


#constraint_exclusion = partition # on, off, or partition
#cursor_tuple_fraction = 0.1      # range 0.0-1.0
#from_collapse_limit = 8
#join_collapse_limit = 8          # 1:禁用显式联接子句的折叠
#force_parallel_mode = off
#jit = off

```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.7 报告和记录（REPORTING AND LOGGING）</span>

　　**记录位置（Where to Log）** 

```bash
#log_destination = 'stderr'   # 1有效值是stderr、csvlog、syslog和eventlog的组合,具体取决于平台.
#csvlog要求日志采集器处于打开状态.

# 这在登录到stderr时使用
#logging_collector = off     # 日志收集器，它是一个捕捉被发送到stderr的日志消息的后台进程，并且它会将这些消息重定向到日志文件中，默认是OFF。

# 这些仅在logging_collector为on状态时候使用.
#log_directory = 'log'       # 写入日志文件的目录,可以是绝对的,也可以是相对于PGDATA的
#log_filename = 'postgresql-%Y-%m-%d.log'  # 日志文件名
#log_file_mode = 0600        # 默认的权限是0600,设置权限-linux,windows可以忽略
#log_truncate_on_rotation = off # 默认为off，设置为on的话，如果新建了一个同名的日志文件，则会清空原来的文件，再写入日志，而不是在后面追加。


#log_rotation_age = 1d      # 1天后创建新的日志文件。0-禁用
#log_rotation_size = 10MB   # 日志文件达到10MB后创建新的日志文件.0-禁用

# These are relevant when logging to syslog:(登录到syslog时,这些都是相关的)
#syslog_facility = 'LOCAL0'
#syslog_ident = 'postgres'
#syslog_sequence_numbers = on
#syslog_split_messages = on

#:这仅在登录到eventlog(win32)时才相关(更改需要重新启动PG数据库生效)
#event_source = 'PostgreSQL'
```

　　**何时记录（When to Log）** 

```bash
#log_min_messages = warning   # 按细节降序排列的值:
          #   debug5
          #   debug4
          #   debug3
          #   debug2
          #   debug1
          #   info
          #   notice
          #   warning
          #   error
          #   log
          #   fatal
          #   panic

#log_min_error_statement = error  # 按细节降序排列的值:
          #   debug5
          #   debug4
          #   debug3
          #   debug2
          #   debug1
          #   info
          #   notice
          #   warning
          #   error
          #   log
          #   fatal
          #   panic (effectively off)

#log_min_duration_statement = -1  # -1被禁用,0记录所有语句及其持续时间,>0只记录至少运行此毫秒数的语句
```

　　**记录什么（What to Log）** 

```bash
#debug_print_parse = off
#debug_print_rewritten = off
#debug_print_plan = off
#debug_pretty_print = on
#log_checkpoints = off
#log_connections = off
#log_disconnections = off
#log_duration = off
#log_error_verbosity = default    # terse, default, or verbose messages(简洁、默认或详细的消息)
#log_hostname = off
#log_line_prefix = '%m [%p] '   # 特素值:
          #   %a = application name-应用程序名称
          #   %u = user name-用户名
          #   %d = database name-数据库名称
          #   %r = remote host and port-远程主机和端口
          #   %h = remote host-远程主机
          #   %p = process ID-进程ID
          #   %t = timestamp without milliseconds-不带毫秒的时间戳
          #   %m = timestamp with milliseconds-毫秒时间戳
          #   %n = timestamp with milliseconds (as a Unix epoch)-时间戳(以毫秒计)(作为Unix纪元)
          #   %i = command tag-命令标记
          #   %e = SQL state-SQL状态
          #   %c = session ID-会话ID
          #   %l = session line number-会话行号
          #   %s = session start timestamp-会话开始时间戳
          #   %v = virtual transaction ID-虚拟事务ID
          #   %x = transaction ID (0 if none)-事务ID(如果没有，则为0)
          #   %q = stop here in non-session-processes -在非会话进程中此处停止
          #   %% = '%'
          # e.g. '<%u%%%d> '
#log_lock_waits = off     # 日志锁等待 >= deadlock_timeout


# log_statement可选值范围:none(不记录任何语句级的日志信息), ddl(只记录数据定义语言语句,如:CREATE,DROP), 
# mod(记录修改了值的语句), all(记录每一条语句,不要轻易使用该选项,日志的写操作会对系统带来巨大的开销)
#log_statement = 'none'     # none, ddl, mod, all


#log_replication_commands = off
#log_temp_files = -1      # 日志临时文件等于或大于指定的大小(以千字节为单位);-1禁用，0记录所有临时文件
log_timezone = 'PRC'
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.8 流程标题（PROCESS TITLE）</span>

```bash
#cluster_name = ''      # 如果非空，则添加到进程标题(更改需要重新启动PG数据库生效)
#update_process_title = on
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.9 统计数据（STATISTICS）</span>

　　**查询和索引统计信息收集器（Query and Index Statistics Collector）** 

```bash
#track_activities = on
#track_counts = on
#track_io_timing = off
#track_functions = none     # none, pl, all
#track_activity_query_size = 1024 # (change requires restart)
#stats_temp_directory = 'pg_stat_tmp'
```

　　**监控（Monitoring）** 

```bash
#log_parser_stats = off
#log_planner_stats = off
#log_executor_stats = off
#log_statement_stats = off
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.10 自动清理（AUTOVACUUM）</span>

　　从PostgreSQL 8.1开始,便提供了autovacuum守护进程,在后台执行日志的自动清理功能.

```bash
#autovacuum = on      # 
#log_autovacuum_min_duration = -1  # 将该参数设置为0会记录所有的自动清理动作。 -1（默认值）将禁用对自动清理动作的记录。 如果指定值时没有单位，则以毫秒为单位。 例如，如果你将它设置为250ms，则所有运行250ms或更长时间的 自动清理和分析将被记录。此外，当该参数被设置为除-1外的任何值时， 如果一个自动清理动作由于一个锁冲突或者被并发删除的关系而被跳过，将会为此记录一个消息。 开启这个参数对于追踪自动清理活动非常有用。
#autovacuum_max_workers = 3             # 指定能同时运行的自动清理进程（除了自动清理启动器之外）的最大数量。默认值为3。该参数只能在服务器启动时设置。
#autovacuum_naptime = 1min              # time between autovacuum runs
#autovacuum_vacuum_threshold = 50       # 清理前的最小行更新数量
#autovacuum_analyze_threshold = 50      # 分析前的最小行更新数
#autovacuum_vacuum_scale_factor = 0.2   # fraction of table size before vacuum
#autovacuum_analyze_scale_factor = 0.1  # fraction of table size before analyze
#autovacuum_freeze_max_age = 200000000  # maximum XID age before forced vacuum
          # (change requires restart)
#autovacuum_multixact_freeze_max_age = 400000000  # maximum multixact age
          # before forced vacuum
          # (change requires restart)
#autovacuum_vacuum_cost_delay = 20ms  # default vacuum cost delay for
          # autovacuum, in milliseconds;
          # -1 means use vacuum_cost_delay
#autovacuum_vacuum_cost_limit = -1  # default vacuum cost limit for
          # autovacuum, -1 means use
          # vacuum_cost_limit
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.11 客户端连接默认值（CLIENT CONNECTION DEFAULTS）</span>

　　**声明行为（Statement Behavior）** 

```bash
#client_min_messages = notice   # 按细节降序排列的值:
          #   debug5
          #   debug4
          #   debug3
          #   debug2
          #   debug1
          #   log
          #   notice
          #   warning
          #   error
#search_path = '"$user", public'  # schema names
#row_security = on
#default_tablespace = ''    # a tablespace name, '' uses the default
#temp_tablespaces = ''      # a list of tablespace names, '' uses
          # only default tablespace
#check_function_bodies = on
#default_transaction_isolation = 'read committed'
#default_transaction_read_only = off
#default_transaction_deferrable = off
#session_replication_role = 'origin'
#statement_timeout = 0      # in milliseconds, 0 is disabled
#lock_timeout = 0     # in milliseconds, 0 is disabled
#idle_in_transaction_session_timeout = 0  # in milliseconds, 0 is disabled
#vacuum_freeze_min_age = 50000000
#vacuum_freeze_table_age = 150000000
#vacuum_multixact_freeze_min_age = 5000000
#vacuum_multixact_freeze_table_age = 150000000
#vacuum_cleanup_index_scale_factor = 0.1  # fraction of total number of tuples
            # before index cleanup, 0 always performs
            # index cleanup
#bytea_output = 'hex'     # hex, escape
#xmlbinary = 'base64'
#xmloption = 'content'
#gin_fuzzy_search_limit = 0
#gin_pending_list_limit = 4MB
```

　　**语言环境和格式（Locale and Formatting）** 

```bash
datestyle = 'iso, ymd'
#intervalstyle = 'postgres'
timezone = 'PRC'
#timezone_abbreviations = 'Default'     # Select the set of available time zone
          # abbreviations.  Currently, there are
          #   Default
          #   Australia (historical usage)
          #   India
          # You can create your own file in
          # share/timezonesets/.
#extra_float_digits = 0     # min -15, max 3
#client_encoding = sql_ascii    # actually, defaults to database
          # encoding

# These settings are initialized by initdb, but they can be changed.
lc_messages = 'zh_CN.UTF-8'     # locale for system error message
          # strings
lc_monetary = 'zh_CN.UTF-8'     # locale for monetary formatting
lc_numeric = 'zh_CN.UTF-8'      # locale for number formatting
lc_time = 'zh_CN.UTF-8'       # locale for time formatting

# default configuration for text search
default_text_search_config = 'pg_catalog.simple'
```

　　**共享库预加载（Shared Library Preloading）** 

```bash
#shared_preload_libraries = ''  # (change requires restart)
#local_preload_libraries = ''
#session_preload_libraries = ''
#jit_provider = 'llvmjit'   # JIT library to use
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.12 其他默认值（Other Defaults ）</span>

```bash
#dynamic_library_path = '$libdir'
```

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.13 锁管理（LOCK MANAGEMENT）</span>

```bash
#deadlock_timeout = 1s
#max_locks_per_transaction = 64     # min 10(更改需要重新启动PG数据库生效)
#max_pred_locks_per_transaction = 64  # min 10(更改需要重新启动PG数据库生效)
#max_pred_locks_per_relation = -2   # 负值平均值(max_pred_locks_per_transaction / -max_pred_locks_per_relation) - 1
#max_pred_locks_per_page = 2            # min 0
```

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.14 版本和平台兼容性（VERSION AND PLATFORM COMPATIBILITY）</span>

　　**以前的PostgreSQL版本（Previous PostgreSQL Versions）** 

```bash
#array_nulls = on
#backslash_quote = safe_encoding  # on, off, or safe_encoding
#default_with_oids = off
#escape_string_warning = on
#lo_compat_privileges = off
#operator_precedence_warning = off
#quote_all_identifiers = off
#standard_conforming_strings = on
#synchronize_seqscans = on
```

　　**其他平台和客户（Other Platforms and Client）** 

```bash
#transform_null_equals = off
```

　　‍

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.15 错误处理（ERROR HANDLING）</span>

```bash
#exit_on_error = off        # 出现任何错误时终止会话？
#restart_after_crash = on   # 后端崩溃后重新初始化？
#data_sync_retry = off      # fsync数据失败时重试或死机？(更改需要重新启动PG数据库生效)
```

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.16 配置文件包括（CONFIG FILE INCLUDES）</span>

```bash
# 这些选项允许从默认postgresql.conf以外的文件加载设置.
#include_dir = ''     # 包括目录中以".conf"结尾的文件,例如"conf.d"
#include_if_exists = ''   # 仅在存在时才包含文件
#include = ''       # 包含文件
```

## <span data-type="text" parent-style="color: var(--b3-font-color3);" style="color: var(--b3-font-color7);">2.17 自定义选项</span>

```bash
# Add settings for extensions here(在此处添加扩展设置)
```

　　‍

# 三、客户端认证配置文件 pg_hba.conf

```bash
cat /data/pgsql/pgdata/pg_hba.conf

# TYPE  DATABASE        USER          ADDRESS             METHOD

# "local" is for Unix domain socket connections only
local   all             all                               peer
# IPv4 local connections:
host    all             all          127.0.0.1/32         ident
# IPv6 local connections:
host    all             all          ::1/128              ident
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                               peer
host    replication     all          127.0.0.1/32         ident
host    replication     all          ::1/128              ident
```

　　从内容可以看出，`pg_hba.conf`​​ 是以行为单位来配置的，每一行包含了以下内容：

* ​`TYPE`​​ 连接类型，表示允许用哪些方式连接数据库，它允许以下几个值：

  * ​`local`​​ 通过 Unix socket 的方式连接。
  * ​`host`​​ 通过 TCP/IP 的方式连接，它能匹配 SSL 和 non-SSL 连接。
  * ​`hostssl`​​ 只允许 SSL 连接。
  * ​`hostnossl`​​ 只允许 non-SSL 连接。
* ​`DATABASE`​​ 可连接的数据库，它有以下几个特殊值：

  * ​`all`​​ 匹配所有数据库。
  * ​`sameuser`​​ 可连接和用户名相同的数据库。
  * ​`samerole`​​ 可连接和角色名相同的数据库。
  * ​`replication`​​ 允许复制连接，用于集群环境下的数据库同步。 除了上面这些特殊值之外，我们可以写特定的数据库，可以用逗号 (,) 来分割多个数据库。
* ​`USER`​​ 可连接数据库的用户，值有三种写法：

  * ​`all`​​ 匹配所有用户。
  * 特定数据库用户名。
  * 特定数据库用户组，需要在前面加上 `+`​​ (如：`+admin`​​)。
* ​`ADDRESS`​​ 可连接数据库的地址，有以下几种形式：

  * ​`all`​​ 匹配所有 IP 地址。
  * ​`samehost`​​ 匹配该服务器的 IP 地址。
  * ​`samenet`​​ 匹配该服务器子网下的 IP 地址。
  * ipaddress/netmask (如：172.20.143.89/32)，支持 IPv4 与 IPv6。
  * 如果上面几种形式都匹配不上，就会被当成是 hostname。 **注意: 只有 host, hostssl, hostnossl 会应用个字段。**
* ​`METHOD`​​ 连接数据库时的认证方式，常见的有几个特殊值：

  * ​`trust`​​ 无条件通过认证。
  * ​`reject`​​ 无条件拒绝认证。
  * ​`md5`​​ 用 md5 加密密码进行认证。
  * ​`password`​​ 用明文密码进行认证，不建议在不信任的网络中使用。
  * ​`ident`​​ 从一个 ident 服务器 (RFC1413) 获得客户端的操作系统用户名并且用它作为被允许的数据库用户名来认证，只能用在 TCP/IP 的类型中 (即 host, hostssl, hostnossl)。
  * ​`peer`​​ 从内核获得客户端的操作系统用户名并把它用作被允许的数据库用户名来认证，只能用于本地连接 (即 local)。
  * 其他特殊值可以在 [官方文档](https://www.postgresql.org/docs/9.6/static/auth-pg-hba-conf.html) 中查阅。 **简单来说，ident 和 peer 都要求客户端操作系统中存在对应的用户。注意: 上面列举的只有 md5 和 password 是需要密码的，其他方式都不需要输入密码认证。**

　　‍

## **ident 和 peer 的区别**

* 都是基于操作系统用户认证，通过操作系统用户映射数据库用户进行认证，
* peer方式数据库访问客户端与数据库服务器必须在同一台操作系统上，ident方式则不是；
* peer使用unix socket会话；
* ident使用tcp会话，psql访问时指定 -h 127.0.0.1

　　安装oidentd服务

```bash
# 安装且启动oidentd服务，关闭防火墙，防火墙可能会拦截数据库对113端口请求的数据包。
yum install -y oidentd
systemctl start oidentd
systemctl status oidentd
```

## peer认证pg_hba.conf文件配置

```
# TYPE  DATABASE        USER          ADDRESS             METHOD
# IPv4 local connections:
host    all             all          0.0.0.0/0         peer
```

## ident认证pg_hba.conf文件配置

　　ident 认证方法通过从一个 ident 服务器获得客户端的操作系统用户名并且用它作为被允许的数据库用户名（和可选的用户名映射【参数map】）来工作。它只在 TCP/IP 连接上支持。

```
cat /data/pgsql/pgdata/pg_hba.conf

# TYPE  DATABASE        USER          ADDRESS             METHOD
# IPv4 local connections:
host    all             all          0.0.0.0/0           ident # 后面不跟参数表示：以当前系统用户登录（类似）
host    all             all          0.0.0.0/0           ident map=test
# Allow replication connections from localhost, by a user with the

-------------------------------------------
cat /data/pgsql/pgdata/pg_ident.conf
# pg_ident.conf就是为pg_hba.conf中ident认证方式而存在的。

#mapping name      os user name      db user name
test                test             postgres   # 表示系统用户test 可以以postgres数据库用户登录
test 		    test1	     postgres   # 表示系统用户test1可以以postgres数据库用户登录
```

　　下列被支持的配置选项用于ident：

* map  
  允许系统和数据库用户名之间的映射。详见Section 20.2。“Identification Protocol（标识协议）”在 RFC 1413 中描述。实际上每个类 Unix 操作系统都带着一个默认监听 TCP 113 端口的 ident 服务器。ident 服务器的基本功能是回答类似这样的问题：“哪个用户从你的端口X发起了连接并且连到了我的端口Y？” 。因为当一个物理连接被建立后，PostgreSQL既知道X也知道Y， 所以它可以询问尝试连接的客户端主机上的 ident 服务器并且在理论上可以判断任意给定连接的操作系统用户。

  这个过程的缺点是它依赖于客户端的完整性：如果客户端机器不可信或者被攻破，攻击者可能在 113 端口上运行任何程序并且返回他们选择的任何用户。因此这种认证方法只		适用于封闭的网络， 这样的网络中的每台客户端机器都处于严密的控制下并且数据库和操作系统管理员操作时可以方便地联系。换句话说，你必须信任运行 ident 服务器的机器。注意这样的警告：

  标识协议的本意不是作为一种认证或访问控制协议。—RFC 1413有些 ident 服务器有一个非标准的选项，它导致返回的用户名是被加密的，使用的是只有原机器管理员知道的一个密钥。当与PostgreSQL配合使用 ident 服务器时，一定不要使用这个选项，因为PostgreSQL没有任何方法对返回的字符串进行解密以获取实际的用户名。

---

　　‍

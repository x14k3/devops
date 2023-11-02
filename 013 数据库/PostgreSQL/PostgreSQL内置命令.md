# PostgreSQL内置命令

‍

## pg_ctl

pg_ctl是一个用于初始化PostgreSQL数据库集簇，启动、停止或重启PostgreSQL数据库服务器，或者显示一个正在运行服务器的状态的工具。

|命令格式|解释|
| ----------------------------------------------------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**pg_ctl init[db]**  [-D DATADIR] [-s] [-o OPTIONS]|​`init`​或`initdb`​模式会创建一个新的PostgreSQL数据库集簇，也就是将由一个单一服务器实例管理的数据库集合。这个模式会调用`initdb`​命令|
|**pg_ctl start** [-D datadir] [-l filename] [-W] [-t seconds] [-s]||
|[-o options] [-p path] [-c]|​`start`​模式启动一个新的服务器。该服务器被启动在后台，并且它的标准输出被附加到`/dev/null`​|
|**pg_ctl stop** [-D datadir] [-m s[mart]|f[ast]|
|[-t seconds] [-s]|​`stop`​模式关闭运行在指定数据目录中的服务器。|
|**pg_ctl restart** [-D datadir] [-m s[mart]|f[ast]|
|[-t seconds] [-s] [-o options] [-c]|​`restart`​模式实际上会先执行一个停止操作然后紧接着执行一个启动操作|
|**pg_ctl reload** [-D datadir] [-s]|​`reload`​模式会向`postgres`​服务器进程发送一个SIGHUP信号，使它重新读取配置文件(`postgresql.conf`​等) 使配置生效，而无需重启服务器|
|**pg_ctl status** [-D datadir]|​`status`​模式检查一个服务器是否运行在指定的数据目录中。如果有一个服务器正在运行，其PID和用来调用它的命令行选项将被显示。如果服务器没有在运行，pg_ctl将返回退出状态 3。如果没有指定一个可以访问的数据目录，pg_ctl将返回退出状态 4。|
|**pg_ctl promote** [-D datadir] [-W] [-t seconds] [-s]|将备库提升为主库|
|**pg_ctl logrotate** [-D datadir] [-s]|​`logrotate`​模式轮换服务器日志文件|
|**pg_ctl kill** signal_name process_id|​`kill`​模式向一个指定进程发送一个信号|

> **option：**
>
> *  **-D, --pgdata=DATADIR：**  指定数据库配置文件的文件系统位置。如果这个选项被忽略，将使用环境变量`PGDATA`​
> *  **-s, --silent：**  只打印错误，不打印信息性的消息
> *  **-t, --timeout=SECS：**  指定等待一个操作完成时要等待的最大秒数（见选项`-w`​）。默认为`PGCTLTIMEOUT`​环境变量的值，如果该环境变量没有设置则默认为60秒
> *  **-V, --version ：**  打印pg_ctl版本并退出。
> * **-w, --wait ：**  等待操作完成。模式`start`​、`stop`​、`restart`​、`promote`​以及`register`​支持这个选项，并且对那些模式 是默认的。
>
>   * 在等待时，`pg_ctl`​会一遍又一遍地检查服务器的PID文件，在两次检查之间会休眠一小段时间。当PID文件指示该服务器已经做好准备接受连接时，启动操作被认为完成。当服务器移除PID文件时，关闭操作被认为完成。`pg_ctl`​会基于启动或关闭的成功与否返回一个退出代码。
>   * 如果操作在超时时间（见选项`-t`​）内未能完成，则`pg_ctl`​会以一个非零退出状态退出。但是注意该操作可能会在后台继续进行并且最终取得成功
> * **-W, --no-wait ：**  不等待操作完成，该选项与-w相反
>
>   * 如果禁用等待，所请求的动作会被触发，但是不会有关于其成功与否的反馈。在这种情况下，可能必须用服务器日志文件或外部监控系统来检查该操作的进度以及成功与否。
>   * 在9.4以前版本的PostgreSQL中，这是除`stop`​模式之外的模式的默认选项。
> *  **-?, --help ：**  显示有关pg_ctl命令行参数的帮助并退出
> *  **-c, --core-files：**  在可行的平台上尝试允许服务器崩溃产生核心文件，方法是提升在核心文件上的任何软性资源限制。这通过允许从一个失败的服务器进程中获得一个栈跟踪而有助于调试或诊断问题
> *  **-l, --log=FILENAME：**  追加服务器日志输出到*`filename`*​ *。如果该文件不存在，它会被创建。umask被设置成 077，这样默认情况下不允许其他用户访问该日志文件*。如果该文件不存在，它会被创建。umask被设置成 077，这样默认情况下不允许其他用户访问该日志文件
> *  ***-o, --options=OPTIONS ： *** 指定被直接传递给命令的选项。`-o`​可以被指定多次，这些选项应该通常被单引号或双引号包围来确保它们被作为一个组传递
> *  **-p PATH-TO-POSTGRES ：**  指定`postgres`​可执行程序的位置。默认情况下，`postgres`​可执行程序可以从`pg_ctl`​相同的目录得到
> * **-m, --mode=MODE：**​`mode`​可以是`smart`​ ***`、`*** ​、`fast`​或`immediate`​，或者这三者之一的第一个字母。如果这个选项被忽略，则`fast`​是默认值
>
>   * “Smart”模式不允许新连接，然后等待所有现有的客户端断开连接以及任何在线备份结束
>   * “Fast”模式（默认）不会等待客户端断开连接并且将终止进行中的在线备份。所有活动事务都被回滚并且客户端被强制断开连接
>   * “Immediate”模式将立刻中止所有服务器进程，而不是做一次干净的关闭，这种选择将导致下一次重启时进行一次崩溃恢复

|使用实例|解释|
| ------------------------------------| ------------------------------------|
|​***`pg_ctl promote -D /data/pg`***​pg_ctl promote -D /data/pg|将备库提升为主库|
|​***`pg_ctl -o "-F -p 5433" restart`***​pg_ctl -o "-F -p 5433" restart|使用端口 5433 重启并在重启时禁用`fsync`​|

‍

## initdb

initdb会创建一个新的PostgreSQL数据库集簇。一个数据库集簇是由一个单一服务器实例管理的数据库的集合。
       一个数据库集簇的创建包括创建存放数据库数据的目录、生成共享目录表（属于整个集簇而不是任何特定数据库的表）并且创建`template1`​和`postgres`​数据库。当你后来创建一个新的数据库时，任何在`template1`​数据库中的东西都会被复制（因此，任何已安装在`template1`​中的东西都会被自动地复制到后来创建的每一个数据库中）。postgres数据库是便于用户、工具和第三方应用使用的默认数据库。
       由于安全原因，由`initdb`​创建的新集簇默认将只能由集簇拥有者访问。`--allow-group-access`​选项允许与集簇拥有者同组的任何用户读取集簇中的文件。这对非特权用户执行备份很有用。
       initdb可以通过`pg_ctl initdb`​被调用。
**命令格式：** 
initdb [option...] [--pgdata | -D] directory

> **option：**
>
> * **-A , --auth=METHOD**：这个选项为本地用户指定在`pg_hba.conf`​中使用的默认认证方法（`host`​和`local`​行）。`initdb`​将使用指定的认证方法为非复制连接以及复制连接填充`pg_hba.conf`​项
>
>   * --auth-host=METHOD：这个选项为通过 TCP/IP 连接的本地用户指定在`pg_hba.conf`​中使用的认证方法（`host`​行）
>   * --auth-local=METHOD：这个选项为通过 Unix 域套接字连接的本地用户指定在`pg_hba.conf`​中使用的认证方法（`local`​行）
> *  **[-D, --pgdata=]DATADIR**：指定数据库集簇应该存放的目录，可通过设置`PGDATA`​环境变量来生效
> *  **-E, --encoding=ENCODING** ：选择模板数据库的编码。这也将是后来创建的任何数据库的默认编码
> * **-g, --allow-group-access**： 允许与集簇拥有者同组的用户读取`initdb`​创建的所有集簇文件
>
>   * --locale=LOCALE：为数据库集簇设置默认区域
>   * --lc-collate=, --lc-ctype=, --lc-messages=LOCALE
>   * --lc-monetary=, --lc-numeric=, --lc-time=LOCALE
>   * --no-locale：等效于`--locale=C`​
>   * --pwfile=FILE：让`initdb`​从一个文件读取数据库超级用户的口令
> *  **-T, --text-search-config=CFG**：设置默认的文本搜索配置
> *  **-U, --username=NAME**：选择数据库超级用户的用户名
> *  **-W, --pwprompt**：提示输入新超级管理员的密码
> * **-X, --waldir=WALDIR**：这个选项指定预写式日志会被存储在哪个目录中
>
>   * --wal-segsize=SIZE：设置_WAL段尺寸_，以兆字节为单位。这是WAL日志中每个文件的尺寸。默认的尺寸为16兆字节
>
> **Less commonly used options:**
>
> *  **-d, --debug**：调试输出
> *  **-k, --data-checksums**：在数据页面上使用校验码来帮助检测 I/O 系统造成的损坏。启用校验码将会引起显著的性能惩罚。如果设置，则为所有对象计算校验和，在整个数据库中。 所有校验和失败都将报告在`pg_stat_database`​视图
> *  **-L DIRECTORY**：指定`initdb`​应从哪里寻找它的输入文件来初始化数据库集簇
> *  **-n, --no-clean**：initdb失败时，不清理之前创建的文件
> *  **-N, --no-sync** ：默认情况下，`initdb`​将等待所有文件被安全地写到磁盘。这个选项会导致`initdb`​不等待就返回
> *  **-s, --show** ：显示内部设置
> *  **-S, --sync-only**：安全地把所有数据库文件写入到磁盘并退出
> *  **-V, --version**：打印initdb版本并退出。
> *  **-?, --help** ：显示有关initdb命令行参数的帮助并退出。

​**`initdb -D $PG_DATA`**​ ** 初始化过程**

```
1.从参数中获取到PGDATA的路径(也可以从环境变量中获取PG_DATA的环境变量获取)
2.初始化如果str_wal_segment_size_mb未设置，则设置为16mb，如果设置了必须是是2的整数倍，并且检验wal segment的大小最大是1G，最小是1Mb
3.通过initdb 程序查找 postgres的主程序，并且校验它的正确性
4.如果没有指定用户，则获取当前执行命令的用户，作为create cluster的主用户(pg中用户不能以pg_开头，否则会初始化失败)。
5.设置pg版本号以及设置初始化需要的资源 ($pg_installtion/share/postgres.bki,postgresql.conf.sample)
6.设置postgresql编码,并且依据pg_enc校验编码是否正确
7.创建pg_data和pg_data/pg_wal目录
8.遍历获取sundirs下所有的目录，并且父目录都是pg_data开始创建目录，并且检查目录的有限性
9.把postgresql版本写入pg_data/PG_VERSION文件并且创建postgresql.conf文件，并写入默认配置模板
10.读取postgres.bki 文件，替换PostgreSQL/NAMEDATALEN/SIZEOF_POINTER/ALIGNOF_POINTER/POSTGRES/ENCODING 等等，其中 NAMEDATALEN 设置了表名/列名/函数名的长度硬编码为64个字符。并创建系统template1数据库,并在pg_data/base/1中写入postgresql的主版本
11. 打开 /home/perrynzhou/Database/pgsql/bin/postgres\ --single -F -O -j -c search_path=pg_catalog -c exit_on_error=true template1 >/dev/null 命令，等待执行命令
12.通过postgres主程序执行 REVOKE ALL on pg_authid FROM public 给 template1授权
13.往系统表pg_xxx插入默认的数据
14.在template1中执行system_views.sql 语句
15.初始化系统表xxx_description和pg_collation
16.执行snowball_create.sql语句，初始化授权相关的表
18.初始化information_schema表、plsql初始化
19.依据template1克隆tempalte0以及最后的创建postgres的数据库
```

‍

## psql

psql是PostgreSQL的交互式终端，可以通过psql工具交互式的键入查询。
**命令格式：** 
psql [option...] [dbname[username]]

> **Input and output options:**
>
> *  **-a, --echo-all** ：显示脚本中的所有输入参数，这等效于把变量`ECHO`​设置为`all`​
> *  **-b, --echo-errors** ：把失败的 SQL 命令打印到标准错误输出。这等效于把变量`ECHO`​设置为`errors`​
> *  **-e, --echo-queries** ：把发送到服务器的所有 SQL 命令复制到标准输出。这等效于把变量`ECHO`​设置为`queries`​
> *  **-E, --echo-hidden** ：回显`\d`​以及其他反斜线命令生成的实际查询。可以用它来学习psql的内部操作。这等效于把变量`ECHO_HIDDEN`​设置为on
> *  **-L, --log-file=FILENAME**：将会话日志发送到文件
> *  **-n, --no-readline**：不使用Readline做行编辑并且不使用命令历史
> *  **-o, --output=FILENAME** ：将查询结果发送到文件
> *  **-q, --quiet** ：不输出任何信息方式来运行
> *  **-s, --single-step** ：运行在单步模式中。这意味着在每个命令被发送给服务器之前都会提示用户一个可以取消执行的选项。使用这个选项可以调试脚本
> *  **-S, --single-line** ：运行在单行模式中，其中新行会终止一个 SQL 命令，就像分号的作用一样。
>
> **Output format options:**
>
> * **-A, --no-align** ：切换到非对齐输出模式（默认输出模式是`对齐`​的）。这等效于`\pset format unaligned`​
>
>   * --csv ：切换到CSV（逗号分隔值）输出模式。 这相当于`\pset format csv`​
> *  **-F, --field-separator=STRING**：未对齐输出的字段分隔符（默认值：“|”）
> *  **-H, --html** ：HTML表格输出模式
> *  **-P, --pset=VAR[=ARG]**  ：以`\pset`​的形式指定打印选项。注意，这里你必须用一个等号而不是空格来分隔名称和值。例如，要设置输出格式为LaTeX，应该写成`-P format=latex`​
> *  **-R, --record-separator=STRING**：未对齐输出的记录分隔符（默认值：换行）
> *  **-t, --tuples-only** ：关闭打印列名和结果行计数页脚等。这等效于`\t`​或者`\pset tuples_only`​命令
> *  **-T, --table-attr=TEXT**：指定要替换HTML`table`​标签的选项。详见`\pset tableattr`​
> *  **-x, --expanded** ：打开扩展表格式模式。这等效于`\x`​或者`\pset expanded`​命令
> *  **-z, --field-separator-zero**：设置非对齐输出的域分隔符为零字节。这等效于`\pset fieldsep_zero`​
> *  **-0, --record-separator-zero**：设置非对齐输出的记录分隔符为零字节。例如，这对与`xargs -0`​配合有关。这等效于`\pset recordsep_zero`​。
>
> **General options:**
>
> *  **-c, --command=COMMAND** ：指定psql执行一个给定的命令字符串*`command`*​ *。这个选项可以重复多次并且以任何顺序与*。这个选项可以重复多次并且以任何顺序与 `*-f选项组合在一起。当*`​选项组合在一起。当`-c`​*`或者`*​或者`-f`​*`被指定时，psql不会从标准输入读取命令，直到它处理完序列中所有的`*​被指定时，psql不会从标准输入读取命令，直到它处理完序列中所有的`-c`​*`和`*​和`-f`​*`选项之后终止`*​选项之后终止
> * ​ *`**-d, --dbname=DBNAME**`*​：指定要连接的数据库名，默认是postgres
> *  **-f, --file=FILENAME**：从文件中读取sql命令执行
> *  **-l, --list**：列出所有可用的数据库
> *  **-v, --set=, --variable=NAME=VALUE**：执行一次变量赋值，和`\set`​元命令相似。注意你必须在命令行上用等号分隔名字和值（如果有）。要重置一个变量，去掉等号就行。要把一个变量置为空值，使用等号但是去掉值。
> *  **-V, --version**：输出pgsql版本
> *  **-X, --no-psqlrc** ：不读取启动文件（要么是系统范围的`psqlrc`​文件，要么是用户的`~/.psqlrc`​文件）
> *  **-1 (&quot;one&quot;), --single-transaction**：作为单个事务执行，这个选项只能被用于与一个或者多个`-c`​以及/或者`-f`​选项组合。它会让psql在第一个上述选项之前发出一条`BEGIN`​命令并且在最后一个上述选项之后发出一条`COMMIT`​命令，这样就把所有的命令都包裹在一个事务中。
> * **-?, --help[=options]**​ *`** **`* ​ ：显示有关psql的帮助并且退出
>
>   * --help=commands ：列出反斜杠命令
>   * --help=variables：列出特殊变量
>
> **Connection options:**
>
> *  **-h, --host=HOSTNAME**：指定运行服务器的机器的主机名
> *  **-p, --port=PORT**：指定数据库运行端口，默认是5432
> *  **-U, --username=USERNAME**： 指定数据库用户名，默认是postgres
> *  **-w, --no-password**：不提示输入密码
> *  **-W, --password**：强制密码提示

|使用实例|解析|
| -----------------------------------------| ------------------------------------------------|
|psql -h localhost -p 5432 test postgres|指定主机名、端口、数据库名和用户名进入该数据库|

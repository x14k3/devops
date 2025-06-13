

有三种不同的基本方法来备份PostgreSQL数据：

‍

- 「SQL转储」，用pg_dump或pgdump_all进行备份，也是一种逻辑备份的方法，这种方法很容易操作，但是缺点就是一旦数据库太大，导入导出文件的效率就会降低。但是有了并行备份恢复和split拆分，也可以在这方面稍微优化。另一个缺点是无法恢复到故障发生的时刻。例如，你使用crontab定时任务在凌晨3点进行备份，结果12点就出故障，如果进行恢复，就会损失9小时的数据。

- 「文件系统级备份」，可以在数据目录中执行"一致性快照"，然后将快照复制到备份服务器上。这样就可以在异机进行恢复。

- 「连续归档和时间点恢复(PRIP)」  。要了解PITR，首先必须了解什么是wal，wal代表预写日志文件，基本上对数据库每次插入、更新、删除在实际应用之前，就写入了日志中。这样就算数据库突然出现了crash，在重新启动的过程中，PostgreSQL能够查看wal文件进行恢复并将数据库还原到可用的状态。

‍

# SQL转储

在Postgresql中提供了pg_dump， pg_dumpall工具进行数据库的逻辑备份。pg_dumpall是备份全库，而pg_dump可以选择一个数据库或部分表进行备份。

## pg_dump

- ​`pg_dump`​ 不会阻塞正常的数据库读写，可以在数据库处于使用状态时进行完整的一致的备份,备份可以简单看作是pg_dump开始运行时的数据库的快照。
- ​`pg_dump`​的备份文件可以是SQL脚本，也可以是归档文件。用psql执行SQL脚本文件可以重建该数据库，甚至不依赖特定的基础设施(例如操作系统，)，脚本修改后甚至可以恢复到非postgres数据库。但是如果是归档文件，则只能用pg_restore来重建数据库。
- ​`pg_dump`​和`pg_restore`​可以选择性的备份或恢复部分表或数据库对象。
- ​`pg_dumpall`​ 对db cluster中的每个数据库调用pg_dump来完成该工作,还会还转储对所有数据库公用的全局对象（pg_dump不保存这些对象）。 目前这包括适数据库用户和组、表空间以及适合所有数据库的访问权限等属性。注意pg_dumpall只能导出脚本文件。

```pgsql
--逻辑备份
--pg_dump -U [用户名] -h [ip地址] -p 5432 [数据库名] > 输出文件
pg_dump -U jy2web -h 192.168.2.222 -p 5432 jy2db> jy2db.sql
--恢复
psql -h 192.168.2.222 -U jy2web -d jy2db< jy2db.sql

--二进制格式的备份只能使用 pg_restore 来还原, 可以指定还原的表
pg_restore -d dbname bakfile

--########################################################################################
----一般选项:  
-f, --file=FILENAME  # 基于目录备份格式时，此参数必填，且指定的是目标目录而不是文件。
-F, --format=c|d|t|p # 输出文件格式
	# p即plain： 输出脚本文件（默认）.
	# c即custom：输出适合作为pg_restore输入的自定义格式存档文件。默认情况下，此格式的存档文件是压缩文件。
	# d即directory：输出适合作为pg_restore输入的目录格式的存档文件。默认情况下，此格式的存档文件是压缩文件，并且支持并行备份。
	# t即tar：输出适合作为pg_restore输入的tar格式的存档文件。tar格式的存档文件不支持压缩。另外，当使用tar格式时，在恢复数据期间无法更改表数据项的相对顺序。
-j, --jobs=NUM       # 通过同时备份njobs个表来并行运行备份。需要将此选项与目录格式结合使用。 
-v, --verbose        # 详细模式  
-V, --version        # 输出版本信息，然后退出  
-Z, --compress=0-9   # 被压缩格式的压缩级别  
--lock-wait-timeout=TIMEOUT # 在等待表锁超时后操作失败  
-?, --help           # 显示此帮助, 然后退出

--控制输出内容选项:  
-a, --data-only      # 只转储数据,不包括模式  
-b, --blobs          # 在转储中包括大对象 
-B, --no-blobs       # 排除转储中的大对象。
-c, --clean          # 在重新创建之前，先清除（删除）数据库对象  
-C, --create         # 在转储中包括命令,以便创建数据库  
-E, --encoding=ENCODING # 转储以ENCODING形式编码的数据  
-n, --schema=SCHEMA  # 只转储指定名称的模式  
-N, --exclude-schema=SCHEMA # 不转储已命名的模式  
-o, --oids           # 备份对象标识符（OID）作为每个表数据的一部分。如果您的应用程序以某种方式引用OID列（例如在一个外键约束中引用OID列），请使用此选项。否则，不使用此选项。 
-O, --no-owner       # 在明文格式中, 忽略恢复对象所属者
-s, --schema-only    # 只备份对象模式，不备份数据。
-S, --superuser=NAME # 禁用触发器时使用的超级用户名。仅在使用--disable-triggers时才使用该选项。
-t, --table=TABLE    # 只转储指定名称的表  
-T, --exclude-table=TABLE # 不转储指定名称的表  
-x, --no-privileges  # 不要转储权限 (grant/revoke)  
--binary-upgrade     # 只能由升级工具使用  
--column-inserts     # 以带有列名的INSERT命令形式转储数据  
--disable-dollar-quoting # 取消美元 (符号) 引号, 使用 SQL 标准引号  
--disable-triggers   # 在只恢复数据的过程中禁用触发器  
--enable-row-security # 启用行安全性（只转储用户能够访问的内容）  
--exclude-table-data=TABLE # 不转储指定名称的表中的数据  
--if-exists          # 当删除对象时使用IF EXISTS  
--inserts            # 将数据备份为INSERT命令。**重要** 使用此选项后，如果在恢复数据时对数据进行重新排序可能会执行失败。建议使用--column-inserts 。
--no-comments        # 表示不备份注释。
--no-security-labels # 不转储安全标签的分配  
--no-synchronized-snapshots # 在并行工作集中不使用同步快照  
--no-tablespaces     # 不转储表空间分配信息  
--no-unlogged-table-data # 不转储没有日志的表数据  
--quote-all-identifiers  # 所有标识符加引号，即使不是关键字  
--section=SECTION    # 备份命名的节 (数据前, 数据, 及 数据后)  
--serializable-deferrable # 等到备份可以无异常运行  
--snapshot=SNAPSHOT  # 表示在备份数据库时使用指定的同步快照。
--strict-names       # 要求每个表和/或schema包括模式以匹配至少一个实体  
--use-set-session-authorization  # 使用 SESSION AUTHORIZATION 命令代替 ALTER OWNER 命令来设置所有权

--联接选项:  
-d, --dbname=数据库名    # 对数据库 DBNAME备份  
-h, --host=主机名       # 数据库服务器的主机名或套接字目录  
-p, --port=端口号       # 数据库服务器的端口号  
-U, --username=名字     # 以指定的数据库用户联接  
-w, --no-password      # 永远不提示输入口令  
-W, --password         # 强制口令提示 (自动)  
--role=ROLENAME        # 指定用于创建备份的角色名。
```

‍

## copy

‍

postgresql提供了copy命令用于表与文件(和标准输出，标准输入)之间的相互拷贝，copy to由表至文件，copy from由文件至表。

- copy 必须使用超级用户;
- copy .. to file ,copy file to ..中的文件都是数据库服务器所在的服务器上的文件。
- \copy 一般用户即可执行
- \copy 保存或者读取的文件是在客户端所在的服务器

比如

当使用192.168.17.53连上192.168.17.52的数据库,使用 copy tb1 to ‘/home/postgres/aa.txt’,该文件是存放在192.168.17.52上；  
当使用192.168.17.53连上192.168.17.52的数据库,使用\copy tb1 to ‘/home/postgres/aa.sql’,该文件是存放在192.168.17.53上；

‍

语法：

```pgsql
-- copy to 复制数据到文件中
COPY { tablename [ ( column [, ...] ) ] | ( query ) }
    TO { 'filename' | STDOUT }
    [ [ WITH ] 
          [ BINARY ]
          [ OIDS ]
          [ DELIMITER [ AS ] 'delimiter' ]
          [ NULL [ AS ] 'null string' ]
          [ CSV [ HEADER ]
                [ QUOTE [ AS ] 'quote' ] 
                [ ESCAPE [ AS ] 'escape' ]
                [ FORCE QUOTE column [, ...] ]
-- copy from 复制文件内容到数据表中
COPY tablename [ ( column [, ...] ) ]
    FROM { 'filename' | STDIN }
    [ [ WITH ] 
          [ BINARY ]
          [ OIDS ]
          [ DELIMITER [ AS ] 'delimiter' ]
          [ NULL [ AS ] 'null string' ]
          [ CSV [ HEADER ]
                [ QUOTE [ AS ] 'quote' ] 
                [ ESCAPE [ AS ] 'escape' ]
                [ FORCE NOT NULL column [, ...] ]

tablename      -- 现存表的名字(可以有模式修饰)
column         -- 可选的待拷贝字段列表。如果没有声明字段列表，那么将使用所有字段。
query          -- 一个必须用圆括弧包围的 SELECT 或 VALUES 命令，其结果将被拷贝。复制一个 SELECT 查询的结果到一个文件。
filename       -- 输入或输出文件的绝对路径。Windows 用户可能需要使用 E'' 字符串和双反斜线作为路径分割符。
STDIN          -- 从标准输入导入
STDOUT         -- 拷贝至标准输出

BINARY         -- 使用二进制格式存储和读取，而不是以文本的方式。在二进制模式下，不能声明 DELIMITER, NULL, CSV 选项。
OIDS           -- 声明为每行拷贝内部对象标识(OID)。如果为一个 query 拷贝或者没有 OID 的表声明了 OIDS 选项，则抛出一个错误。
delimiter      -- 在文件中分隔各个字段的单个字符。在文本模式下，缺省是水平制表符，在 CSV 模式下是一个逗号。
null string    -- 这是一个代表 NULL 值的字符串。在文本模式下缺省是 \N ，在 CSV 模式下是一个没有引号的 NULL 。如果你不想区分 NULL 和空字符串，那么即使在文本模式下你可能也会使用一个空字符串。
--【注意】在使用 COPY FROM 的时候，任何匹配这个字符串的字符串将被存储为 NULL 值，所以你应该确保你用的字符串和 COPY TO 相同。
CSV            -- 打开逗号分隔变量(CSV)模式
HEADER         -- 声明文件包含一个标题头行，包含文件中每个字段的名字。输出时，第一行包含表的字段名；输入时，第一行被忽略。
quote          -- 声明 CSV 模式里的引号字符。缺省是双引号。
escape         -- 声明在 CSV 模式下应该出现在数据里 QUOTE 字符值前面的字符。缺省是 QUOTE 值(通常是双引号)。
FORCE QUOTE    -- 在 CSV COPY TO 模式下，强制在每个声明的字段周围对所有非 NULL 值都使用引号包围。NULL 输出从不会被引号包围。
FORCE NOT NULL -- 在 CSV COPY FROM 模式下，把声明的每个字段都当作它们有引号包围来处理，因此就没有 NULL 值。对于在 CSV 模式下的缺省空字符串('')，这样导致一个缺失的数值当作一个零长字符串输入。
```

‍

**copy命令可以操作的文件类型有：txt、sql、csv、压缩文件、二进制格式**

```pgsql
-- 示例1.将整张表拷贝至标准输出
\copy tbl_test1 to stdout;
\copy tbl_test1 to '/tmp/test1.txt';
-- 示例2.将表的部分字段拷贝至标准输出，并输出字段名称，字段间使用','分隔
\copy tbl_test1(a,b) to stdout delimiter ',' csv header;
-- 示例3.将查询结果拷贝至标准输出
\copy (select a,b from tbl_test1 except select e,f from tbl_test2 ) to stdout delimiter ',' quote '"' csv header;
-- 示例4.将表拷贝至csv文件中
\copy tbl_test1 to '/tmp/tbl_test1.csv' delimiter ',' csv header;
-- 示例5. 将表以GBK编码拷贝至csv文件中
\copy tbl_test1 to '/tmp/tbl_test1.csv' delimiter ',' csv header encoding 'GBK';
-- 示例9.将刚才导出的文件再次拷贝至表中，使用GBK编码
\copy tbl_test1(a,b,c) from '/tmp/tbl_test1.csv' delimiter ',' csv header encoding 'GBK';
```

‍

‍

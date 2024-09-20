# WalMiner

　　[XLogMiner-walminer_3.0_stable.zip](assets/XLogMiner-walminer_3.0_stable-20240909141019-pb0empg.zip)

　　WalMiner是从PostgreSQL的WAL(write ahead logs)日志的解析工具，旨在挖掘wal日志所有的有用信息，从而提供PG的数据恢复支持。目前主要有如下功能：

* 从waL日志中解析出SQL，包括DML和少量DDL

  解析出执行的SQL语句的工具，并能生成对应的undo SQL语句。与传统的logical decode插件相比，walminer不要求logical日志级别且解析方式较为灵活。
* 数据页挽回

  当数据库被执行了TRUNCATE等不被wal记录的数据清除操作，或者发生磁盘页损坏，可以使用此功能从wal日志中搜索数据，以期尽量挽回数据。

## PG版本支持

* walminer3.0支持PostgreSQL 10及其以上版本。（此版本放弃对9.x的支持）

## 编译安装

　　**编译一：PG源码编译**  
如果你从编译pg数据库开始

1. 将walminer目录放置到编译通过的PG工程的"../contrib/"目录下
2. 进入walminer目录
3. 执行命令

    ```bash
    make && make install
    ```

　　**编译二：依据PG安装编译**  
如果你使用yum或者pg安装包安装了pg

1. 配置pg的bin路径至环境变量

    ```bash
    export PATH=/h2/pg_install/bin:$PATH
    ```
2. 进入walminer代码路径
3. 执行编译安装

    ```bash
    USE_PGXS=1 MAJORVERSION=12 make
    #MAJORVERSION支持‘10’,‘11’,‘12’,‘13’,‘14’,‘15’,‘16’
    USE_PGXS=1 MAJORVERSION=12 make install
    ```

## 使用方法-SQL解析

### 场景一：从WAL日志产生的数据库中直接执行解析

#### 0. 首先切换到需要解析的数据库

```bash
-bash-4.2$ psql -p 58083
psql (12.7)
Type "help" for help.

postgres=# \l
                             List of databases
   Name    |  Owner   | Encoding  | Collate | Ctype |   Access privileges   
-----------+----------+-----------+---------+-------+-----------------------
 i2soft    | i2soft   | UTF8      | C       | C     | 
 postgres  | postgres | SQL_ASCII | C       | C     | 
 template0 | postgres | SQL_ASCII | C       | C     | =c/postgres          +
           |          |           |         |       | postgres=CTc/postgres
 template1 | postgres | SQL_ASCII | C       | C     | =c/postgres          +
           |          |           |         |       | postgres=CTc/postgres
(4 rows)

postgres=# \c i2soft
You are now connected to database "i2soft" as user "postgres".
i2soft=#
```

#### 1. 创建walminer的extension

```bash
create extension walminer;
```

　　‍

#### 2. 添加要解析的wal日志文件

```sql
-- 添加wal文件：
select walminer_wal_add('/usr/cntlcenter/archivedir');
-- 注：参数可以为目录或者文件

-- 移除wal文件：
select walminer_wal_remove('/opt/test/wal');
-- 注：参数可以为目录或者文件
```

#### 3. List wal日志文件

```sql
-- 列出wal文件：
select walminer_wal_list();
```

#### 4. 执行解析

　　	4.1 普通解析

```sql
--解析add的全部wal日志
select walminer_all();
或 select wal2sql();

--在add的wal日志中查找对应时间范围的wal记录
--可以参照walminer_time.sql回归测试中的使用用例
--时间解析模式的解析结果可能比预期的解析结果要多,详情参照[walminer_decode.c]代码中的注释
select walminer_by_time(starttime, endtime);
或 select wal2sql(starttime, endtime);

--在add的wal日志中查找对应lsn范围的wal记录
--可以参照walminer_lsn.sql回归测试中的使用用例
select walminer_by_lsn(startlsn, endlsn);
或 select wal2sql(startlsn, endlsn);

--在add的wal日志中查找对应xid的wal记录
--可以参照walminer_xid.sql回归测试中的使用用例
--前一个walminer版本对xid的支持是范围解析，但是xid的提交是不连续的
--会导致各种问题，所以这个版本只支持单xid解析
select walminer_by_xid(xid);
或 select wal2sql(xid);1
```

　　	4.2 精确解析

```sql
--在add的wal日志中查找对应时间范围的wal记录
select walminer_by_time(starttime, endtime,'true'); 
或 select wal2sql(starttime, endtime,'true');
--在add的wal日志中查找对应lsn范围的wal记录
select walminer_by_lsn(startlsn, endlsn,'true'); 
或 select wal2sql(startlsn, endlsn,'true');
--在add的wal日志中查找对应xid的wal记录
select walminer_by_xid(xid,'true'); 
或 select wal2sql(xid,'true');
```

　　walminer的构建基础是，checkpoint之后对每一个page的更改会产生全页写(FPW),因此一个checkpoint之后的所有wal日志可以完美解析。*注意checkpoint是指checkpoint开始的点，而不是checkpoint的wal记录的点，*​*[参照说明](https://my.oschina.net/lcc1990/blog/3027718)*

　　普通解析会直接解析给定范围内的wal日志，因为可能没有找到之前的checkpoint点，所以会出现有些记录解析不全导致出现空的解析结果。

　　精确解析是指walminer程序会界定需要解析的wal范围，并在给定的wal范围之前探索一个checkpoint开始点c1，从c1点开始记录FPI，然后就可以完美解析指定的wal范围。如果在给定的wal段内没有找到c1点，那么此次解析会报错停止。

　　	4.3 单表解析

```sql
--在add的wal日志中查找对应时间范围的wal记录
select walminer_by_time(starttime, endtime,'false',reloid); 
或 select wal2sql(starttime, endtime,'true',reloid);
--在add的wal日志中查找对应lsn范围的wal记录
select walminer_by_lsn(startlsn, endlsn,'true',reloid); 
或 select wal2sql(startlsn, endlsn,'false',reloid);
--在add的wal日志中查找对应xid的wal记录
select walminer_by_xid(xid,'true',reloid);
或 select wal2sql(xid,'true',reloid);
```

　　	'true'和‘false’代表是否为精确解析模式，reloid为目标表的oid(注意**不是**relfilenode)

　　  4.4 快捷解析

　　	场景1中的加载数据字典和加载wal日志步骤可以省略，默认直接加载当前数据字典和当前wal路径下的所有wal文件。这个解析模式只在学习本工具时使用，在生产数据库中，可能会因为wal段切换而导致解析失败。

　　 4.5 替身解析

　　	如果一个表被drop或者被truncate等操作，导致新产生的数据字典不包含旧的数据库中所包含的relfilenode，那么使用新的数据字典无法解析出旧的wal日志中包含的的某些内容。在知晓旧表的表结构的前提下，可以使用替身解析模式。替身模式目前只适用于[场景一]。

```sql
-- 假设表t1被执行了vacuum full，执行vacuum full前的relfilenode为16384
-- 新建表t1的替身表
create table t1_avatar(i int);
-- 执行替身映射
select walminer_table_avatar(avatar_table_name, missed_relfilenode);
-- 执行解析
select wal2sql();
-- 查看解析结果时，会发现，对t1表的数据都以t1_avatar表的形式展现在输出结果中
```

#### 5. 解析结果查看

```sql
select * from walminer_contents;
```

```sql
-- 表walminer_contents 
(
 sqlno int, 		--本条sql在其事务内的序号
 xid bigint,		--事务ID
 topxid bigint,		--如果为子事务，这是是其父事务；否则为0
 sqlkind int,		--sql类型1->insert;2->update;3->delete(待优化项目)
 minerd bool,		--解析结果是否完整(缺失checkpoint情况下可能无法解析出正确结果)
 timestamp timestampTz, --这个SQL所在事务提交的时间
 op_text text,		--sql
 undo_text text,	--undo sql
 complete bool,		--如果为false，说明有可能这个sql所在的事务是不完整解析的
 schema text,		--目标表所在的模式
 relation text,		--目标表表名
 start_lsn pg_lsn,	--这个记录的开始LSN
 commit_lsn pg_lsn	--这个事务的提交LSN
)
```

　　⚠️ **注意**：walminer_contents是walminer自动生成的unlogged表(之前是临时表，由于临时表在清理上有问题，引起工具使用不便，所以改为unlogged表)，在一次解析开始会首先创建或truncate walminer_contents表。

#### 6. 结束walminer操作

　　该函数作用为释放内存，结束日志分析，该函数没有参数。

```sql
select walminer_stop();
```

### 场景二：从非WAL产生的数据库中执行WAL日志解析

　　⚠️ 要求执行解析的PostgreSQL数据库和被解析的为同一版本

#### 于生产数据库

##### 1.创建walminer的extension

```sql
create extension walminer;
```

##### 2.生成数据字典

```sql
select walminer_build_dictionary('/opt/proc/store_dictionary');
-- 注：参数可以为目录或者文件
```

#### 于测试数据库

##### 1. 创建5walminer的extension

```sql
create extension walminer;
```

##### 2. load数据字典

```sql
select walminer_load_dictionary('/opt/test/store_dictionary');
-- 注：参数可以为目录或者文件
```

##### 3. add wal日志文件

```sql
-- 增加wal文件：
select walminer_wal_add('/opt/test/wal');
-- 注：参数可以为目录或者文件
```

##### 4. remove wal日志文件

```sql
-- 移除wal文件：
select walminer_wal_remove('/opt/test/wal');
-- 注：参数可以为目录或者文件
```

##### 5. list wal日志文件

```sql
-- 列出wal文件：
select walminer_wal_list();
-- 注：参数可以为目录或者文件
```

##### 6. 执行解析

　　同上

##### 7. 解析结果查看

```sql
select * from walminer_contents;
```

##### 8.结束walminer操作,该函数作用为释放内存，结束日志分析，该函数没有参数。

```sql
select walminer_stop();
```

　　⚠️ **注意**：walminer_contents是walminer自动生成的unlogged表(之前是临时表，由于临时表在清理上有问题，引起工具使用不便，所以改为unlogged表)，在一次解析开始会首先创建或truncate walminer_contents表。

### 场景三：自apply解析（开发中的功能,慎用）

　　场景一和场景二中的解析结果是放到结果表中的，场景三可以将解析结果直接apply到解析数据库中。命令执行的流程与场景一和场景二相同。

```sql
-- 参数意义参考walminer_by_lsn()接口
select walminer_apply(startlsn, endlsn,'true', reloid);
```

#### 此功能可以处理主备切换延迟数据

　　当主库A发生故障，从库B切换为主库之后。

1. B库将A库未通过流复制apply的wal日志拷贝到B库可以获取的路径（这一步目前需要DBA自行处理，尚未纳入本功能）
2. 在B库加载wal日志，执行walminer_apply()解析，其中：

    startlsn选取未能apply到B库的lsn的开始值

    endlsn参数写NULL

    'true'这里最好填写‘true’，就不要写‘false’了

    reloid是可选参数
3. walminer_apply()完成后,可以看到延迟的数据已经写到B库了

#### 自apply解析功能说明

1. 目前处于coding中，后续会添加严格的txid限制，避免错误修改数据，现在是尝鲜测试版
2. 对于有冲突的项目，会把冲突sql存放到`$PGDATA/pg_walminer/wm_analyselog/apply_failure`​文件中，供DBA自行判断处理
3. 保持事务性，同一个事务中的一条SQLapply失败后，整个事务都会apply失败
4. 看大家需求，后续可能考虑增加远程apply功能

### 场景四：DDL解析

　　**系统表变化解析**

　　目前walminer支持解析系统表的变化。也就是说如果在PG执行了DDL语句，walminer可以分析出DDL语句引起的系统表的变化。

```sql
-- 在执行解析之前，先执行如下语句，即可开启系统表解析功能
select wal2sql_with_catalog();
```

　　**DDL解析**

```sql
-- 在执行解析之前，先执行如下语句，即可开启DDL解析功能
select wal2sql_with_ddl();
```

　　⚠️`系统表变化解析`​和`DDL解析`​不共存，总是接受最新确定的状态。

　　⚠️walminer对DML数据的解析是要求没有系统表变化的，因此存在DDL变化时，可能导致DML解析不出来的情况。

### 使用限制

1. 本版本解析DML语句。DDL语句解析功能正在不断开发。
2. 只能解析与数据字典时间线一致的wal文件
3. 当前walminer无法处理数据字典不一致问题，walminer始终以给定的数据字典为准，

    对于无法处理的relfilenode，那么会丢弃这一条wal记录(会有一个notice在解析结果中没有体现)
4. complete属性只有在wallevel大于minimal时有效
5. xid解析模式不支持子事务
6. 同时只能有一个walminer解析进程，否则会出现解析混乱

## 使用方法-数据页挽回(坏块修复)

#### 1. 环境搭建

　　创建extension，创建数据地点，加载wal日志的方法与[SQL解析]中描述的方法一致。

#### 2. 执行数据挽回

```sql
select page_collect(relfilenode, reloid, pages)
```

　　relfilenode：需要解析的wal日志中的relfilenode

　　reloid：解析库中存在的表的OID，此命令将会将从wal中找到的page覆盖到reloid制定的表中

　　pages：是字符串类型，制定想要挽回的目标page。格式为'0,1,2,7'或者'all'。

　　具体使用方法可以从pc_base.sql测试用例文件中获取。

　　**此功能持续开发中，后续会添加基于基础备份的数据页挽回**

### 使用限制

　　1.将部分page恢复到其他表后，查询时可能会出现报错的情况。这是因为恢复后的page可能依赖其他page数据，而其依赖的page没有恢复到这个表中。

　　2.执行此命令后请立即备份，因为此命令对数据的操作不会记录在wal中。

## 联系我

　　发现bug或者有好的建议可以通过邮箱（lchch1990@sina.cn）联系我。

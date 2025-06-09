# ORACLE数据字典

## 一、Oracle数据字典

数据字典是`Oracle`​存放有关数据库信息的地方，其用途是用来描述数据。比如一个表的创建者信息，创建时间信息，所属表空间信息，用户访问权限信息等。当用户在对数据库中的数据进行操作时遇到困难就可以访问数据字典来查看详细的信息。
　　`Oracle`​中的数据字典有静态和动态之分。静态数据字典主要是在用户访问数据字典时不会发生改变的，但动态数据字典是依赖数据库运行性能，反映数据库运行的一些内在信息，所以在访问这类数据字典时往往不是一成不变的。以下分别就这两类数据字典来论述。

### 1.1 静态数据字典

这类数据字典主要是由表和视图组成，应该注意的是，数据字典中的表是不能直接被访问的，但是可以访问数据字典中的视图。静态数据字典中的视图分为三类，它们分别由三个前缀够成：`user_*`​、 `all_*`​、 `dba_*`​。

> - ​`user_*`​ :该视图存储了关于当前用户所拥有的对象的信息。（即所有在该用户模式下的对象）
> - ​`all_*`​: 该试图存储了当前用户能够访问的对象的信息。（与`user_*`​相比，`all_*`​ 并不需要拥有该对象，只需要具有访问该对象的权限即可）
> - ​`dba_*`​: 该视图存储了数据库中所有对象的信息。（前提是当前用户具有访问这些数据库的权限，一般来说必须具有管理员权限）

从上面的描述可以看出，三者之间存储的数据肯定会有重叠，其实它们除了访问范围的不同以外（因为权限不一样，所以访问对象的范围不一样），其他均具有一致性。具体来说，由于数据字典视图是由`SYS`​（系统用户）所拥有的，所以在缺省情况下，只有SYS和拥有DBA系统权限的用户可以看到所有的视图。没有DBA权限的用户只能看到`user_*`​和`all_*`​视图。如果没有被授予相关的`SELECT`​权限的话，他们是不能看到 `dba_*`​视图的。

由于三者具有相似性，下面以`user_`​为例介绍几个常用的静态视图

- ​`user_users`​视图：主要描述当前用户的信息，主要包括当前用户名、帐户id、帐户状态、表空间名、创建时间等。例如执行下列命令即可返回这些信息。

```sql
select * from user_users
```

- ​`user_tables`​视图：主要描述当前用户拥有的所有表的信息，主要包括表名、表空间名、簇名等。通过此视图可以清楚了解当前用户可以操作的表有哪些。执行命令为：`select * from user_tables`​
- ​`user_objects`​视图：主要描述当前用户拥有的所有对象的信息，对象包括表、视图、存储过程、触发器、包、索引、序列等。该视图比`user_tables`​视图更加全面。例如, 需要获取一个名为“package1”的对象类型和其状态的信息，可以执行下面命令：
  `select object_type,status from user_objects where object_name=upper(‘package1’);`​

注意：upper的使用，数据字典里的所有对象均为大写形式，而PL/SQL里不是大小写敏感的，所以在实际操作中一定要注意大小写匹配。

- ​`user_tab_privs`​视图：该视图主要是存储当前用户下对所有表的权限信息。比如，为了了解当前用户对table1的权限信息，可以执行如下命令：

```sql
select * from user_tab_privs where table_name=upper('table1')
```

了解了当前用户对该表的权限之后就可以清楚的知道，哪些操作可以执行，哪些操作不能执行。

前面的视图均为user\_开头的，其实all\_开头的也完全是一样的，只是列出来的信息是当前用户可以访问的对象而不是当前用户拥有的对象。对于dba\_开头的需要管理员权限，其他用法也完全一样，这里就不再赘述了。

### 1.2 动态数据字典

Oracle包含了一些潜在的由系统管理员如SYS维护的表和视图，由于当数据库运行的时候它们会不断进行更新，所以称它们为动态数据字典（或者是动态性能视图）。这些视图提供了关于内存和磁盘的运行情况，所以我们只能对其进行只读访问而不能修改它们。

Oracle中这些动态性能视图都是以`v$`​开头的视图，比如`v$access`​。下面就几个主要的动态性能视图进行介绍。

- ​`v$access`​：该视图显示数据库中锁定的数据库对象以及访问这些对象的会话对象（session对象）。

运行如下命令：

```sql
select * from v$access
```

结果如下：（因记录较多，故这里只是节选了部分记录）

```sql
SID OWNER OBJECT TYPE 27 DKH V$ACCESS CURSOR 27 PUBLIC V$ACCESS SYNONYM 27 SYS DBMS_APPLICATION_INFO PACKAGE 27 SYS GV$ACCESS VIEW
```

- ​`v$session`​：该视图列出当前会话的详细信息。由于该视图字段较多，这里就不列详细字段，为了解详细信息，可以直接在sql\*plus命令行下键入：`desc v$session`​即可。
- ​`v$active_instance`​：该视图主要描述当前数据库下的活动的实例的信息。依然可以使用select语句来观察该信息。
- ​`v$context`​：该视图列出当前会话的属性信息。比如命名空间、属性值等。

### 1.3 小结

以上是Oracle的数据字典方面的基本内容，还有很多有用视图因为篇幅原因这里不能一一讲解，希望大家在平时使用中多留心。总之，运用好数据字典技术，可以让数据库开发人员能够更好的了解数据库的全貌，这样对于数据库优化、管理等有极大的帮助。

## 二、Oracle 中常用数据字典

下面列出的这些数据字典，均在 Oracle 11g R1 上，通过 Oracle Sql Developer 进行过测试的，全部通过。其中很多的数据字典都必须以 system 或者是 sysdba 用户登录才能够使用的。

```sql
---数据库实例的基本信息 
desc v$instance; 
select * from v$instance;

--数据文件的基本信息 
desc v$datafile; 
select * from v$datafile; 
desc dba_data_files; 
select file_name,file_id,tablespace_name,bytes,blocks, tatus,online_status from dba_data_files;

--临时文件的基本信息 
desc dba_temp_files; 
select file_name,file_id,tablespace_name,status, from dba_temp_files;

--控制文件的基本信息 
desc v$controlfile; 
select name,status,is_recovery_dest_file, block_size,file_size_blks from v$controlfile;

--日志文件的基本信息 
desc v$logfile; 
select group#,status,type,member,is_recovery_dest_file from v$logfile;

--数据库的基本信息 
desc v$database; 
select * from v$database; 
select dbid,name,created，resetlogs_time,log_mode, open_mode,checkpoint_change#,archive_change#, 
       controlfile_created,controlfile_type, 
       controlfile_sequence#,controlfile_change#, 
       controlfile_time,protection_mode,database_role 
from v$database;

--日志文件参数信息 
show parameter log_archive_dest;

--访问参数文件 
desc v$parameter; 
select num,name,type,value,display_value, isdefault,isses_modifiable, issys_modifiable,isinstance_modifiable     
from v$parameter; 
select * from v$parameter; 
select name,value,description from v$parameter;

--后台进程信息 
desc v$bgprocess; 
select paddr,pserial#,name,description,error from v$bgprocess;

--DBA 用户的所有的表的基本信息 
desc dba_tables; 
desc dba_tab_columns; 
select owner,table_name,column_name,data_type,data_length, global_stats,data_upgraded,histogram from dba_tab_columns;

--DBA 用户的所有的视图的基本信息 
desc dba_views; 
select owner,view_name,read_only from dba_views;

--DBA 用户的所有的同义词的基本信息 
desc dba_synonyms; 
select owner,synonym_name,table_owner, table_name,db_link from dba_synonyms;

--DBA 用户的所有的序列的信息 
desc dba_sequences; 
select sequence_owner,sequence_name,min_value,max_value, cycle_flag from dba_sequences;

--DBA 用户的所有的约束的信息 
desc dba_constraints; 
select owner,constraint_name,constraint_type, table_name,status from dba_constraints;

--DBA 用户的所有的索引的基本信息 
desc dba_indexes; 
select owner,index_name,index_type,table_owner,table_name, table_type,uniqueness,compression,logging,status from dba_indexes;

--DBA 用户的所有的触发器的基本信息 
desc dba_triggers; 
select owner,trigger_name,trigger_type, table_owner,table_name,column_name from dba_triggers;

--DBA 用户的所有的存储过程的基本信息 
desc dba_source; 
select owner,name,type,line,text from dba_source;

--DBA 用户的所有的段的基本信息 
desc dba_segments; 
select owner,segment_name,segment_type, tablespace_name,blocks,extents from dba_segments;

--DBA 用户的所有的区的基本信息 
desc dba_extents 
select owner,segment_name,segment_type, tablespace_name,extent_id,file_id,blocks from dba_extents;

--DBA 用户的所有的对象的基本信息 
desc dba_objects; 
select owner,object_name,subobject_name, object_id,data_object_id,object_type, created,status,namespace from dba_objects;

--当前用户可以访问的所有的基表 
desc cat; 
select table_name from cat;

--当前用户可以访问的所有的基表，视图，同义词 
desc system.tab; 
select tname,tabtype,clusterid from system.tab;

--构成数据字典的所有的表信息 
desc dict; 
select table_name,comments from dict;

-- 查询关于表空间的一些基本的数据字典 
desc dba_tablespaces; 
select tablespace_name,block_size,status, logging,extent_management from dba_tablespaces;

desc dba_free_space; 
select tablespace_name,file_id,block_id, blocks,relative_fno from dba_free_space;

--归档状态的一些基本信息 
desc v$archived_log; 
select name,dest_id,blocks,block_size, archived,status,backup_count from v$archived_log;

--关于内存结构的一些信息 
desc v$sga; 
select name,value/1024/1024 大小MB from v$sga;

desc v$sgastat; 
select pool,name,bytes from v$sgastat;

desc v$db_object_cache; 
select owner,name,db_link,type,namespace,locks from v$db_object_cache;

desc v$sql; 
select sql_text,sql_id,cpu_time from v$sql;

```

‍

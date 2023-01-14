#database/oracle 

使用OMF (Oracle Managed Files )可以简化Oracle 数据库的管理，通过OMF，可以指定filesystem 目录，之后就可以在这个目录下创建和管理数据库。 比如创建表空间时，不需要指定datafile的名称，默认会将数据文件创建到这个目录下面。在初始化参数里指定特殊类型文件的文件系统目录，这样就可以保证文件的唯一性。

1.  开启该功能会简化DBA的日常操作
2.  开启后Oracle会按照规则自动生成唯一的文件名
3.  当文件不再需要时Oracle会自动删除
4.  数据库可对如下数据库结构启用该功能
    -   表空间(Tablespaces)
    -   重做日志(Redo log files)
    -   控制文件(Control files)
    -   归档日志文件(Archived logs)
    -   块变更跟踪文件(Block change tracking files)
    -   闪回日志文件(Flashback logs)
    -   RMAN备份文件(RMAN backups)

**使用的好处**

1.  简化DBA工作
2.  减少由于人为指定错误文件导致的错误
3.  减少建立测试和开发环境耗费的时间
4.  会自动删除不需要的文件而不用担心删除错误，减少服务器空间的浪费


*启动OMF的初始化参数如下表:*

| 初始化参数                  | 描述                                                                                                                                                                                                                                                                      |
| --------------------------- | -------------------------------------------------------------------------------------------------- |
| DB_CREATE_FILE_DEST         | 用于确定创建datafiles,tempfiles文件缺省路径，如果未指定 DB_CREATE_ONLINE_LOG_DEST_n，也用作重做日志和控制文件的默认位置。    |
| DB_CREATE_ONLINE_LOG_DEST_n | 用于确定创建重做日志和控制文件缺省路径。 通过更改 n，您可以多次使用此初始化参数，您最多可以指定五个多路复用副本。   |
| DB_RECOVERY_FILE_DEST       | 指定闪回恢复区路径，在数据库未使用格式选项时创建RMAN备份、归档日志、以及闪回日志。 如果未指定 DB_CREATE_ONLINE_LOG_DEST_n，也用作重做日志和控制文件 | 



```sql
-- 设置DB_CREATE_FILE_DEST
ALTER SYSTEM SET DB_CREATE_FILE_DEST = '/data/oradata';
-- 设置DB_CREATE_ONLINE_LOG_DEST_n
ALTER SYSTEM SET DB_CREATE_ONLINE_LOG_DEST_1 = '/data/redolog';
--设置DB_RECOVERY_FILE_DEST
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 10G;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/data/recover';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 = 'LOCATION=USE_DB_RECOVERY_FILE_DEST';
```

使用 OMF 参数之后，会存放在默认生成的文件路径下。

**格式为：**

-   数据文件：`OMF路径/ORACLE_SID/datafile/`
-   日志文件：`OMF路径/ORACLE_SID/onlinelog/`

## 使用OMF为表空间创建数据文件

1）如果指定了*DB_CREATE_FILE_DEST*初始化参数，那么Oracle管理的数据文件将创建在参数指定的位置中。

```sql
-- 查询
show parameter DB_CREATE_FILE_DEST;

-- 设置DB_CREATE_FILE_DEST
ALTER SYSTEM SET DB_CREATE_FILE_DEST = '/data/oradata';

-------------------------------------------------------
create tablespace JY2WE;
-- 默认分配大小为100M
-rw-r----- 1 oracle oinstall 104865792 12月  4 20:45 o1_mf_jy2we_krs5lqvl_.dbf



-- 也可以指定数据文件大小
create tablespace JY2GM DATAFILE size 200m autoextend on next 100m maxsize unlimited;
-rw-r----- 1 oracle oinstall 209723392 12月  4 20:51 o1_mf_jy2gm_krs5xqc1_.dbf
-rw-r----- 1 oracle oinstall 104865792 12月  4 20:50 o1_mf_jy2we_krs5lqvl_.dbf

-- ## 使用OMF创建undo表空间示例
CREATE UNDO TABLESPACE undotbs_1;
-- ## 使用OMF更改表空间示例
ALTER TABLESPACE undotbs_1 ADD DATAFILE AUTOEXTEND ON MAXSIZE 800M;

-- 如果使用drop tablespace {_tablespace_name}_; 删除表空间，OMF管理的会将物理文件也一同删除

```


## 使用OMF创建redo日志文件

使用语句ALTER DATABASE ADD LOGFILE可以在后来增加新组到当前的redo日志中。
如果使用OMF，ADD LOGFILE子语句中的文件名是可选的。如果没有提供文件名称，redo日志文件创建在缺省的日志文件目的地。

```sql
-- 查询
show parameter DB_CREATE_ONLINE_LOG_DEST;

ALTER DATABASE ADD LOGFILE;
ALTER DATABASE ADD LOGFILE SIZE 200m;
```

## 使用OMF创建归档日志

```sql
-- 查询
show parameter DB_RECOVERY_FILE_DEST;

--设置DB_RECOVERY_FILE_DEST
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 10G;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/data/orarecover';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 = 'LOCATION=USE_DB_RECOVERY_FILE_DEST';
shutdown immediate
startup mount
alter database archivelog;
alter database open;
-- 手动归档
alter system archive log current;
```

```bash
[root@fmr data]# tree orarecover/
orarecover/
└── FMSDB
    ├── archivelog  # 日志归档目录
    │   └── 2022_12_06
    ├── autobackup  # 自动备份目录（控制文件）
    │   └── 2022_12_06
    │       ├── o1_mf_s_1122751968_kryb3091_.bkp
    │       ├── o1_mf_s_1122752006_kryb46w2_.bkp
    │       └── o1_mf_s_1122752194_krybb27m_.bkp
    └── backupset  # 备份集（annn:归档日志 nnnd0:数据文件 nnsnf:spfile 文件）
        └── 2022_12_06
            ├── o1_mf_annnn_TAG20221206T193246_kryb2y29_.bkp
            ├── o1_mf_annnn_TAG20221206T193258_kryb3bb7_.bkp
            ├── o1_mf_annnn_TAG20221206T193324_kryb44of_.bkp
            ├── o1_mf_annnn_TAG20221206T193605_kryb95jx_.bkp
            ├── o1_mf_annnn_TAG20221206T193631_kryb9zwx_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193220_kryb24wf_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193220_kryb24wy_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193259_kryb3cjq_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193259_kryb3ck5_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193606_kryb96qb_.bkp
            ├── o1_mf_nnnd0_TAG20221206T193606_kryb96qs_.bkp
            └── o1_mf_nnsnf_TAG20221206T193633_krybb13w_.bkp

7 directories, 15 files
[root@fmr data]# 
```
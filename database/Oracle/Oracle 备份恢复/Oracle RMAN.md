#oracle

DBA生存之四大守则的第一条就是：备份重于一切

## 一、RMAN架构与核心概念

1. **RMAN客户端 (RMAN Client)**：用户交互的命令行界面 (`rman target /`)
2. **目标数据库 (Target Database)**：需要备份或恢复的数据库。
3. **RMAN服务器进程 (Server Processes)**：目标数据库上执行备份/恢复操作的进程。`通道 (Channel)`代表一个到特定设备（磁盘/Disk或磁带/SBT）的数据流，是RMAN与I/O设备交互的途径。通道分配 (`ALLOCATE CHANNEL` 或 `CONFIGURE CHANNEL`) 是关键步骤。
4. **恢复目录 (Recovery Catalog - 可选)**：一个独立的Oracle数据库（Schema），用于存储目标数据库的元数据（备份信息、归档日志、RMAN脚本等），提供更强大的管理、报告和点时间恢复能力。使用 `rman target / catalog rman_user/password@catdb` 连接。
5. **控制文件 (Control File)**：当不使用Catalog时，目标数据库的控制文件是RMAN元数据的默认存储位置（存储有限时间）。
6. **备份集 (Backup Set)**：RMAN备份的**默认格式**。一个备份集包含一个或多个物理数据库文件（数据文件、控制文件、归档日志等）的备份块。备份集由`备份片 (Backup Piece)`组成（物理文件）。
7. **镜像副本 (Image Copy)**：数据库文件的**精确副本**（类似操作系统 `cp` 或 `dd`），可以直接用于恢复（无需RMAN特殊处理）。恢复速度快，但占用空间与源文件相同。
8. **快照控制文件 (Snapshot Control File)**：RMAN操作期间使用的控制文件临时副本，保证操作一致性。

## 二、常用RMAN命令分类与详细解析

### 1. 连接与环境命令

**CONNECT**：连接到目标数据库和/或恢复目录
```r
CONNECT TARGET /                          --操作系统认证连接目标库
CONNECT CATALOG rman_user/password@catdb  --连接恢复目录
```

**SHOW**：显示RMAN配置参数
```r
SHOW ALL;                                 --显示所有当前配置
SHOW RETENTION POLICY;                    --显示备份保留策略
SHOW DEFAULT DEVICE TYPE;                 --显示默认备份设备
SHOW CONTROLFILE AUTOBACKUP;              --显示控制文件自动备份设置
```

**CONFIGURE**：永久修改RMAN配置参数（存储在控制文件或Catalog中）
```r
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;     --设置保留策略为恢复7天内任意时间点
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;                  --设置保留至少3份完整备份
CONFIGURE DEFAULT DEVICE TYPE TO DISK;                       --设置默认备份到磁盘
CONFIGURE DEFAULT DEVICE TYPE TO 'SBT_TAPE';                 --设置默认备份到磁带库
CONFIGURE CONTROLFILE AUTOBACKUP ON;                         --启用控制文件自动备份,强烈推荐！
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/backup/%F';     --设置控制文件自动备份路径格式
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/backup/%U';                           --配置磁盘通道的备份片格式
CONFIGURE CHANNEL DEVICE TYPE 'SBT_TAPE' PARMS 'ENV=(NB_ORA_SERV=backup_server)'; --配置磁带通道参数
CONFIGURE BACKUP OPTIMIZATION ON;                            --启用备份优化，跳过相同内容文件
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK;                --配置归档日志删除策略：备份到磁盘1次后即可删除
```

**REPORT**：生成备份和数据库结构的报告
```r
REPORT NEED BACKUP;                 --报告需要备份的文件, 根据保留策略
REPORT OBSOLETE;                    --报告已过期的备份, 根据保留策略可删除
REPORT SCHEMA;                      --报告目标数据库的表空间和数据文件结构
REPORT UNRECOVERABLE;               --报告自上次备份以来包含不可恢复操作的数据文件
```

**LIST**：列出存储在Repository（控制文件或Catalog）中的备份和副本信息
```r
LIST BACKUP;                        --列出所有备份集和备份片
LIST BACKUP SUMMARY;                --列出备份摘要
LIST BACKUP OF DATABASE;            --列出数据库备份
LIST BACKUP OF TABLESPACE USERS;    --列出表空间USERS的备份
LIST BACKUP OF ARCHIVELOG ALL;      --列出所有归档日志备份
LIST COPY;                          --列出所有镜像副本
LIST FAILURE;                       --列出Data Recovery Advisor检测到的故障,需要诊断数据

```

**CROSSCHECK**：检查Repository中记录的备份或副本是否实际存在于磁盘或磁带上。**维护关键命令！
```r
CROSSCHECK BACKUP;                  --检查所有备份
CROSSCHECK COPY;                    --检查所有镜像副本
CROSSCHECK BACKUPSET <primary_key>; --检查特定备份集
CROSSCHECK ARCHIVELOG ALL;          --检查所有归档日志记录

```

**DELETE**：删除物理备份文件/副本，并更新Repository记录。通常先执行 `CROSSCHECK` 和 `REPORT OBSOLETE`
```r
DELETE OBSOLETE;                    --删除所有根据保留策略已过期的备份
DELETE EXPIRED BACKUP;              --删除那些 `CROSSCHECK` 标记为 `EXPIRED` 的备份记录及其物理文件
DELETE BACKUPSET <primary_key>;     --删除特定备份集
DELETE ARCHIVELOG ALL BACKED UP 1 TIMES TO DISK;  --删除所有已备份到磁盘1次的归档日志 - 谨慎操作！
```

**VALIDATE**：验证备份是否可恢复或数据库文件是否有物理损坏
```r
VALIDATE BACKUPSET <primary_key>;   --验证特定备份集是否可读且完整
VALIDATE DATAFILE 1;                --验证数据文件1是否有物理块损坏
VALIDATE DATABASE;                  --验证整个数据库文件是否有物理块损坏
VALIDATE CHECK LOGICAL DATABASE;    --验证数据库文件是否有逻辑和物理块损坏 - 资源消耗大
```



### 2. 备份命令

BACKUP：执行备份操作的核心命令
**备份整个数据库 (Backup Sets):**
```r
BACKUP AS BACKUPSET DATABASE;                                  -- 使用默认配置备份整个数据库到默认设备
BACKUP AS BACKUPSET DATABASE PLUS ARCHIVELOG;                  -- 备份数据库+当前所有归档日志(并切换日志)
BACKUP AS BACKUPSET DATABASE PLUS ARCHIVELOG DELETE ALL INPUT; -- 备份数据库+归档日志，并在成功后删除已备份的归档日志文件
BACKUP AS COMPRESSED BACKUPSET DATABASE;                       -- 使用压缩备份整个数据库 (节省空间)
BACKUP AS BACKUPSET INCREMENTAL LEVEL 0 DATABASE;              -- 0级增量备份（全备基础）
BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE;              -- 1级增量备份（基于最近0级或1级）
BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;   -- 累积增量备份（基于最近0级）

```

**备份表空间:**
```r
BACKUP AS BACKUPSET TABLESPACE users, tools;
BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 TABLESPACE users;
```

**备份数据文件:**
```r
BACKUP AS BACKUPSET DATAFILE 1, '/oradata/users02.dbf';
```

**备份归档日志:**
```r
BACKUP AS BACKUPSET ARCHIVELOG ALL;                    -- 备份所有未备份的归档日志
BACKUP AS BACKUPSET ARCHIVELOG FROM TIME 'SYSDATE-1';  -- 备份过去24小时生成的归档日志
BACKUP AS BACKUPSET ARCHIVELOG SEQUENCE BETWEEN 1000 AND 2000 THREAD 1; -- 备份特定序列号范围的归档日志
BACKUP AS BACKUPSET ARCHIVELOG ALL DELETE ALL INPUT;   -- 备份所有归档日志并删除物理文件(谨慎！)
```

**备份控制文件/SPFILE:**
```r
BACKUP AS BACKUPSET CURRENT CONTROLFILE;               -- 备份当前控制文件(到备份集)
BACKUP AS BACKUPSET SPFILE;                            -- 备份服务器参数文件
```

**创建镜像副本 (Image Copies):**
```r
BACKUP AS COPY DATABASE;                                           -- 创建整个数据库的镜像副本(空间消耗大)
BACKUP AS COPY DATAFILE 1 FORMAT '/backup/users01.dbf';            -- 创建指定数据文件的镜像副本
BACKUP AS COPY CURRENT CONTROLFILE FORMAT '/backup/control01.ctl'; -- 创建控制文件的镜像副本
```

**标签和格式:**
```r
BACKUP AS BACKUPSET DATABASE TAG 'FULL_DB_20231027';
BACKUP AS BACKUPSET DATABASE FORMAT '/backup/%d_%T_%s_%p.bkp';     -- 使用格式指定文件名 (%d=数据库名, %T=时间戳, %s=备份集号, %p=备份片号)
```

**使用特定通道:**
```r
RUN {
    ALLOCATE CHANNEL ch1 DEVICE TYPE DISK FORMAT '/backup1/%U';
    ALLOCATE CHANNEL ch2 DEVICE TYPE DISK FORMAT '/backup2/%U';
    BACKUP DATABASE;    -- 使用两个通道并行备份
    }
```


### 3. 恢复与恢复命令
**`RESTORE`**：从备份集或镜像副本中提取物理文件
```r
RESTORE DATABASE;                     --恢复整个数据库
RESTORE TABLESPACE users;             --恢复指定表空间
RESTORE DATAFILE 1;                   --恢复指定数据文件
RESTORE CONTROLFILE FROM AUTOBACKUP;  --恢复控制文件 - 关键！通常需要先启动到 `NOMOUNT` 状态
RESTORE SPFILE FROM AUTOBACKUP;       --恢复SPFILE
RESTORE ARCHIVELOG SEQUENCE BETWEEN 1000 AND 2000 THREAD 1; --恢复特定归档日志序列
RESTORE DATABASE PREVIEW;             --预览恢复操作需要哪些备份，不实际执行
RESTORE DATABASE VALIDATE;            --验证恢复所需的备份是否可用且完整，不实际恢复
```

**`RECOVER`**：应用归档日志和在线重做日志，将数据库或文件前滚到指定时间点（或最新）。**必须在 `RESTORE` 之后执行**
```r
RECOVER DATABASE;                     --恢复整个数据库到最新状态 - 需要所有归档和在线日志
RECOVER TABLESPACE users;             --恢复指定表空间到最新
RECOVER DATAFILE 1;`                  --恢复指定数据文件到最新
RECOVER DATABASE UNTIL TIME '2023-10-27:14:00:00'; --不完全恢复到指定时间点
RECOVER DATABASE UNTIL SCN 123456;                 --不完全恢复到指定SCN
RECOVER DATABASE UNTIL SEQUENCE 1000 THREAD 1;     --不完全恢复**到指定日志序列号
RECOVER COPY OF DATABASE WITH TAG 'gold_copy' UNTIL TIME 'SYSDATE-1'; --使用镜像副本恢复数据库到昨天
```

**数据库打开:**
```r
ALTER DATABASE OPEN;                  --在完全恢复后打开数据库
ALTER DATABASE OPEN RESETLOGS;        --在不完全恢复后必须使用RESETLOGS选项打开数据库 - 创建新的数据库化身)
```

**恢复示例 (完全恢复):**
```r
-- 数据文件损坏场景
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;            -- 启动到Mount状态
RESTORE DATAFILE 1;       -- 恢复损坏的数据文件
RECOVER DATAFILE 1;       -- 应用日志恢复该文件
ALTER DATABASE OPEN;      -- 打开数据库
```


### 4. 实用命令与脚本

**`RUN`**：将多个RMAN命令组合成一个块执行（常用于需要显式分配通道的复杂操作）
```r
RUN {
    ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
    BACKUP DATABASE PLUS ARCHIVELOG;
    BACKUP CURRENT CONTROLFILE;
    RELEASE CHANNEL c1;
    } 
```

**`SQL`**：在RMAN会话中执行SQL语句
```r
SQL 'ALTER TABLESPACE users BEGIN BACKUP'; -- (通常不建议在RMAN中使用BEGIN BACKUP)
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
SQL "CREATE TABLESPACE ...";
```

**`HOST`** / **`!`**：在RMAN中执行操作系统命令
```r
HOST 'ls -l /backup';
! rm /backup/old_file.bak;
```

**`PRINT SCRIPT`**：显示存储脚本的内容。
**`EXECUTE SCRIPT`**：执行存储的RMAN脚本。
**`REPLACE SCRIPT`** / **`DELETE SCRIPT`**：创建/修改或删除存储脚本（需Catalog）。
```r
REPLACE SCRIPT full_backup {
    BACKUP AS BACKUPSET DATABASE PLUS ARCHIVELOG DELETE INPUT;
    BACKUP CURRENT CONTROLFILE;
    }
EXECUTE SCRIPT full_backup;
```
**`SHUTDOWN`** / **`STARTUP`**：在RMAN中关闭或启动目标数据库（等同于SQL*Plus命令）。
```r
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
```

## 三、关键提示与最佳实践

1. **启用控制文件自动备份 (`CONFIGURE CONTROLFILE AUTOBACKUP ON;`)：** 这是灾难恢复的生命线！确保每次备份结构变化（如备份、添加数据文件）时都自动备份控制文件和SPFILE。
2. **理解保留策略 (`CONFIGURE RETENTION POLICY ...`)：** 明确你的RPO（恢复点目标），使用 `RECOVERY WINDOW` 或 `REDUNDANCY` 策略管理备份生命周期。
3. **定期维护：** 使用 `CROSSCHECK` 验证备份是否存在，使用 `DELETE EXPIRED` 和 `DELETE OBSOLETE` 清理过期和无效备份记录及物理文件。
4. **测试恢复：** 定期进行恢复演练 (`RESTORE VALIDATE`, `RESTORE PREVIEW`, 实际恢复测试) 是验证备份有效性的唯一方法！
5. **监控与日志：** 仔细查看RMAN输出日志，结合 `LIST`, `REPORT` 命令监控备份状态。将RMAN输出记录到日志文件 (`rman target / log /path/to/rman.log`).
6. **使用恢复目录 (Recovery Catalog)：** 对于生产环境，尤其是管理多个数据库时，强烈建议使用恢复目录。它提供更长的历史记录、集中管理、存储脚本等强大功能。
7. **增量备份策略：** 结合Level 0 (基础全备) 和Level 1 (差异或累积增量) 减少备份时间和存储空间。`CUMULATIVE` 增量恢复更快（只需一个增量备份），但备份量较大；`DIFFERENTIAL` 增量备份量小，但恢复可能需要多个增量备份。
8. **归档日志管理：** 确保归档日志能成功备份并被RMAN管理 (`BACKUP ARCHIVELOG ... DELETE INPUT` 结合配置的删除策略)。防止归档日志占满磁盘。
9. **通道配置与并行度：** 根据I/O能力合理配置通道数量和类型 (`DISK`/`SBT_TAPE`)，利用并行备份提高速度。

## 四、进阶特性 (版本依赖)

- **活动数据库复制 (Active Database Duplication - 11g+)：** 通过网络直接从运行中的源库创建副本库 (`DUPLICATE ... FROM ACTIVE DATABASE`)。
- **基于备份的数据库复制 (Backup-based Duplication)：** 使用现有备份创建副本库 (`DUPLICATE DATABASE ...`)。
- **表级时间点恢复 (Tablespace Point-in-Time Recovery - TSPITR)：** 恢复单个表空间到与数据库其他部分不同的时间点。
- **块介质恢复 (Block Media Recovery - BMR)：** 仅恢复损坏的数据块 (`RECOVER ... BLOCK`)，避免恢复整个文件，大幅减少停机时间。
- **加密备份 (Backup Encryption)：** 使用透明加密 (`TDE`) 或密码加密保护备份数据安全 (`SET ENCRYPTION ...` / `CONFIGURE ENCRYPTION ...`)。
- **压缩备份 (Backup Compression)：** 使用 `AS COMPRESSED BACKUPSET` 或配置默认压缩 (`CONFIGURE COMPRESSION ALGORITHM ...`) 节省存储空间和网络带宽（需许可）。
- **多段备份 (Multisection Backups - 11g+)：** 并行备份超大文件 (`SECTION SIZE ...`)。
- **归档备份 (Archival Backups - 11g+)：** 创建长期保留的只读备份 (`BACKUP ... KEEP {FOREVER | UNTIL TIME ...} RESTORE POINT ...`)。

## 总结

掌握RMAN是Oracle DBA的核心技能。理解其架构、核心概念（备份集、镜像副本、通道、Catalog）是基础。熟练运用 `CONFIGURE`, `BACKUP`, `RESTORE`, `RECOVER`, `LIST`, `REPORT`, `CROSSCHECK`, `DELETE` 等命令是关键。务必遵循最佳实践（尤其是控制文件自动备份、测试恢复、维护）。随着版本演进，不断学习其高级特性（如复制、TSPITR、BMR）能显著提升数据库运维效率和恢复能力。

要了解某个命令的非常具体的细节或特定场景的用法，请参考对应版本的Oracle官方文档《Backup and Recovery User's Guide》。实践出真知，务必在测试环境多加练习！是否有某个特定命令或场景你想深入了解？


---

# 附：rman几种恢复方式

1、丢失数据文件，进行完全恢复

```bash

RMAN>startup mount;
RMAN>restore database;
RMAN>recover database;
RMAn>sql 'alter database open';
```

2、丢失重做日志文件，进行不完全恢复

```bash
SQL>startup mount;
SQL>recover database until cancel;
SQL>alter database open resetlogs;
```

3、丢失数据文件、控制文件和重做日志文件，进行不完全恢复

```bash
RMAN>startup nomount;
RMAN>restore controfile from autobackup;
RMAN>alter database mount;
RMAN>restore database;
SQL>recover database using backup controlfile until cancel;
SQL>alter database open resetlogs;
```

4、丢失初始化文件、控制文件数据文件和重做日志文件，进行不完全恢复

```bash

SQL>startup nomount pfile='D:\oracle\product\10.2.0\db_1\admin\orcl\pfile\init.ora.27201414210'; #pfile的路径
RMAN>restore spfile from autobackup;
SQL>shutdown immediate;
SQL>startup nomount;
RMAN>restore controlfile from autobackup;
RMAN>alter database mount;
RMAN>restore database;
SQL>recover database using backup controlfile until cancel;
SQL>alter database open resetlogs;
```

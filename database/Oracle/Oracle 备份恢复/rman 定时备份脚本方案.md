
## 单机备份

首先配置备份策略 
```sql
--1.保留三次备份
--2.备份自动压缩
--3.自动备份控制文件和spfile 以及指定备份的目录
rman target /
CONFIGURE RETENTION POLICY TO REDUNDANCY 7;
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO COMPRESSED BACKUPSET;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO  '/data/oraback/fmsdb/ctl_%F.bak';
```

编写备份脚本
```bash
#!/bin/bash
#1.指定数据文件备份路径，plus archivelog 归档日志备份目录， delete all input 删除备份后的归档日志
source /home/oracle/.bash_profile
rman target / <<ORMF
run {
backup spfile format '/data/oraback/fmsdb/spfile_%d_%T_%U'; 
backup current controlfile format '/data/oraback/fmsdb/ctl_%d_%T_%U';
backup incremental level 0 database  format '/data/oraback/fmsdb/data_%d_%T_%U' plus archivelog format '/data/oraback/fmsdb/arch_%d_%T_%U' delete all input;
delete noprompt obsolete;
}
ORMF
```

创建定时任务
crontab : `10 01 * * * /data/script/rmanbackup.sh >> /tmp/rmanback.log 2>&1`

---
## 单机备份（OFM）

首先配置备份策略 
```sql
--1.保留三次备份
--2.备份自动压缩
--3.自动备份控制文件（控制文件中包含spfile）
rman target /
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO COMPRESSED BACKUPSET;
```

编写备份脚本
```bash
#!/bin/bash
#1.备份数据文件，plus archivelog 归档日志备份， delete all input 删除备份后的归档日志
source /home/oracle/.bash_profile
rman target / <<ORMF
run {
backup incremental level 0 database plus archivelog delete all input;
backup spfile;
delete noprompt obsolete;
}
ORMF
```

创建定时任务
crontab : `10 01 * * * /data/script/rmanbackup.sh >> /tmp/rmanback.log 2>&1`

---


## rac 备份

首先配置备份策略 
```sql
-- 1. 配置备份保留策略 (7天恢复窗口)
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
-- 2. 配置控制文件自动备份 (重要!)
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '+RECO/%F';
-- 3. 配置归档日志删除策略 (备份后自动删除)
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK;
-- 4. 配置并行备份 (根据 CPU 核心数调整)
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO COMPRESSED BACKUPSET;
-- 5. 配置备份优化
CONFIGURE BACKUP OPTIMIZATION ON;
-- 6. 设置默认备份路径到 FRA (ASM 磁盘组)
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '+FRA';
```

> **关键配置说明**：
> - 使用 ASM 磁盘组 `+FRA` 作为备份位置（确保所有节点可访问）
> - 启用压缩备份减少空间占用
> - 控制文件自动备份防止单点故障
> - 归档日志备份后自动删除释放空间


RMAN 备份脚本-全量备份脚本 rman_full_backup.sh
```bash
#!/bin/bash
source /home/oracle/.bash_profile
rman target / <<EOF
RUN {
  BACKUP AS COMPRESSED BACKUPSET 
    DATABASE 
    INCLUDE CURRENT CONTROLFILE
    PLUS ARCHIVELOG DELETE ALL INPUT;
  BACKUP CURRENT CONTROLFILE;
  BACKUP SPFILE;
  CROSSCHECK BACKUP;
  DELETE NOPROMPT EXPIRED BACKUP;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF
```

RMAN 备份脚本-增量备份脚本 rman_incr_backup.sh
```bash
#!/bin/bash
source /home/oracle/.bash_profile
rman target / <<EOF
RUN {
  BACKUP AS COMPRESSED BACKUPSET 
    INCREMENTAL LEVEL 1 
    DATABASE
    PLUS ARCHIVELOG DELETE ALL INPUT;
  BACKUP CURRENT CONTROLFILE;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF
```

RMAN 备份脚本-归档日志备份脚本 rman_arch_backup.sh
```bash
#!/bin/bash
source /home/oracle/.bash_profile
rman target / <<EOF
RUN {
  BACKUP ARCHIVELOG ALL DELETE ALL INPUT;
}
EXIT;
EOF
```

定时任务配置
```bash
# 编辑 crontab (节点1执行)
crontab -e

# 添加以下任务 (根据实际路径调整)
0 0 * * 0 /scripts/rman_full_backup.sh > /logs/rman_full_$(date +\%Y\%m\%d).log 2>&1  # 每周日全备
0 0 * * 1-6 /scripts/rman_incr_backup.sh > /logs/rman_incr_$(date +\%Y\%m\%d).log 2>&1  # 周一至周六增量
0 */1 * * * /scripts/rman_arch_backup.sh > /logs/rman_arch_$(date +\%Y\%m\%d_\%H).log 2>&1  # 每小时归档备份
```
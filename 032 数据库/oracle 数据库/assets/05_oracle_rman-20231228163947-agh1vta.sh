#!/bin/bash

source /etc/locale.conf
source /tmp/setenv.sh

mkdir -p ${ORACLE_SCRIPT_PATH}
chown -R oracle:oinstall ${ORACLE_SCRIPT_PATH}

oracle_script(){
cat <<SORM > ${ORACLE_SCRIPT_PATH}/rmanbackup.sh
#!/bin/bash
#指定数据文件备份路径，plus archivelog 归档日志备份目录， delete all input 删除备份后的归档日志
source /home/oracle/.bash_profile
rman target / <<ORMF
run {
backup incremental level 0 database plus archivelog delete all input;
backup spfile;
delete noprompt obsolete;
}
ORMF
SORM
echo "10 0 * * * sh ${ORACLE_SCRIPT_PATH}/rmanbackup.sh >> /tmp/rmanbackup.log 2>&1" >> /var/spool/cron/oracle
chmod 600 /var/spool/cron/oracle
chown oracle:oinstall /var/spool/cron/oracle ${ORACLE_SCRIPT_PATH}/rmanbackup.sh
}

oracle_rman(){

su - oracle <<EOF
#Oracle Rman 备份
rman target / <<ORMAN > /dev/null
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO COMPRESSED BACKUPSET;
EXIT;
ORMAN

EOF
}
oracle_script
oracle_rman

cat <<EOF
## 备份策略已生成：
包括数据文件、控制文件、日志归档、spfile文件
每天0点10分执行备份任务，备份日志 /tmp/rmanbackup.log
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO COMPRESSED BACKUPSET;

run {
backup incremental level 0 database plus archivelog delete all input;
backup spfile;
delete noprompt obsolete;
}
EOF

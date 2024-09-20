# mysql数据库备份脚本

　　‍

　　‍

```bash
#!/bin/bash
DB_DATE=`date "+%Y-%m-%d"`
THREEDAYSAGO=`date -d "-3 days" +%Y-%m-%d`

DB_PASSWD="Ninestar@2021"
DB_BACKPATH="/data/dbbackup"

DB_NAME1="jy2web"
DB_NAME2="jy2bps"
DB_NAME3="jy2bpc"
DB_NAME4="jy2app"
DB_NAME5="jy2gm"

mkdir -p ${DB_BACKPATH}

mysql -uroot -p${DB_PASSWD} <<EOF
grant select on mysql.proc to '${DB_NAME1}';
grant select on mysql.proc to '${DB_NAME2}';
grant select on mysql.proc to '${DB_NAME3}';
grant select on mysql.proc to '${DB_NAME4}';
grant select on mysql.proc to '${DB_NAME5}';
flush privileges;
EOF

mysqldump --events --routines --triggers --set-gtid-purged=OFF -u${DB_NAME1} -p${DB_PASSWD} ${DB_NAME1} > ${DB_BACKPATH}/${DB_NAME1}_${DB_DATE}.sql

mysqldump --events --routines --triggers --set-gtid-purged=OFF -u${DB_NAME2} -p${DB_PASSWD} ${DB_NAME2} > ${DB_BACKPATH}/${DB_NAME2}_${DB_DATE}.sql

mysqldump --events --routines --triggers --set-gtid-purged=OFF -u${DB_NAME3} -p${DB_PASSWD} ${DB_NAME3} > ${DB_BACKPATH}/${DB_NAME3}_${DB_DATE}.sql

mysqldump --events --routines --triggers --set-gtid-purged=OFF -u${DB_NAME4} -p${DB_PASSWD} ${DB_NAME4} > ${DB_BACKPATH}/${DB_NAME4}_${DB_DATE}.sql

mysqldump --events --routines --triggers --set-gtid-purged=OFF -u${DB_NAME5} -p${DB_PASSWD} ${DB_NAME5} > ${DB_BACKPATH}/${DB_NAME5}_${DB_DATE}.sql

cd ${DB_BACKPATH}

zip -rm ${DB_NAME1}_${DB_DATE}.sql.zip ${DB_NAME1}_${DB_DATE}.sql
zip -rm ${DB_NAME2}_${DB_DATE}.sql.zip ${DB_NAME2}_${DB_DATE}.sql
zip -rm ${DB_NAME3}_${DB_DATE}.sql.zip ${DB_NAME3}_${DB_DATE}.sql
zip -rm ${DB_NAME4}_${DB_DATE}.sql.zip ${DB_NAME4}_${DB_DATE}.sql
zip -rm ${DB_NAME5}_${DB_DATE}.sql.zip ${DB_NAME5}_${DB_DATE}.sql

/usr/bin/find ${DB_BACKPATH} -name "*.zip" -type f -mtime +3 -exec rm -rf {} \;
```

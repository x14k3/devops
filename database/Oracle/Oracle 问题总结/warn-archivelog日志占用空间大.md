

```sql
-- 1.手动删除archivelog日志

-- 2.手动将当前在线日志归档
sqlplus / as sysdba
alter system archive log current;

-- 3.检查日志归档文件和实际物理文件的差别
rman target /
crosscheck archivelog all;

-- 4.执行rman逻辑上删除过期日志
delete noprompt expired archivelog all;
```

‍

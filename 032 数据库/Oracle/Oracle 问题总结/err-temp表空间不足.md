# err-temp表空间不足

ora-01652:无法通过128(在表空间space中)扩展temp段解决办法

这种情况一看是当前用户所在的表空间达到32G大小上限，需要增加一个新的表空间

**解决方法**

```sql
–-1.为用户追加第1个表空间
alter tablespace ttteesst add datafile '/data/oradata/orcl/test_extend1.dbf'
size 1000m autoextend on next 500m maxsize unlimited;

–-2.关联新表空间
alter tablespace ttteesst online;

–-3.检查表空间数据文件
select name from v$datafile;
```

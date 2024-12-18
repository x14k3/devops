# other-Oracle表空间使用情况脚本

　　个人一直使用下面这个脚本查看、分析Oracle数据库表空间的使用情况，这个脚本经过我不断的调整、完善，已经接近完美了。已经很长时间没有改动过了，个人累积的脚本名为get\_tablespace\_used\_v2.sql

```sql
SET PAGESIZE 9999 LINESIZE 180;
TTI 'Tablespace Usage Status'
COL TABLESPACE_NAME FOR A20;
COL TBS_MAX_SIZE FOR 99999.99;
COL TABLESPACE_SIZE FOR 99999.99;
COL TBS_AVABLE_SIZE FOR 999999.99;
COL "USED_RATE(%)" FOR A16;
COL "ACT_USED_RATE(%)" FOR A16;
COL "FREE_SIZE(GB)" FOR 99999999.99;

SELECT  UPPER(F.TABLESPACE_NAME)                           AS "TABLESPACE_NAME",
        ROUND(D.MAX_BYTES,2)                               AS "TBS_MAX_SIZE" ,
        ROUND(D.AVAILB_BYTES ,2)                           AS "ACT_TABLESPACE_SIZE",
        ROUND((D.AVAILB_BYTES - F.USED_BYTES),2)           AS "TBS_USED_SIZE",
        ROUND(F.USED_BYTES, 2)                             AS "FREE_SIZE(GB)",
        TO_CHAR(ROUND((D.AVAILB_BYTES - F.USED_BYTES) / D.AVAILB_BYTES * 100,
                     2),
               '999.99')                                   AS "USED_RATE(%)",
        TO_CHAR(ROUND((D.AVAILB_BYTES - F.USED_BYTES)/D.MAX_BYTES*100,
                     2),
               '999.99')                                   AS "ACT_USED_RATE(%)",
        ROUND(D.MAX_BYTES - D.AVAILB_BYTES +USED_BYTES,2)  AS "TBS_AVABLE_SIZE"
  FROM (SELECT TABLESPACE_NAME,
               ROUND(SUM(BYTES) / (1024 * 1024 * 1024), 6) USED_BYTES,
               ROUND(MAX(BYTES) / (1024 * 1024 * 1024), 6) MAX_BYTES
          FROM SYS.DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) F,
       (SELECT DD.TABLESPACE_NAME,
               ROUND(SUM(DD.BYTES) / (1024 * 1024 * 1024), 6)  AVAILB_BYTES,
               ROUND(SUM(DECODE(DD.MAXBYTES, 0, DD.BYTES, DD.MAXBYTES))/(1024*1024*1024),6)   MAX_BYTES
          FROM SYS.DBA_DATA_FILES DD
         GROUP BY DD.TABLESPACE_NAME) D
WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME
ORDER BY "ACT_USED_RATE(%)" DESC;
```

　　但是今天在看一篇英文博文时，看到了一个更加完善的脚本，个人对其做了一些调整和修改，将其命名为get\_tablespace\_used\_v3.sql，它主要是加入了表空间类型，以及临时表空间的数据等。以及自动扩展的数据文件和非自动扩展数据文件的数量。

```sql
set pagesize 1000 linesize 180
tti 'Tablespace Usage Status'
col "TOTAL(GB)" for 99,999,999.999
col "USAGE(GB)" for 99,999,999.999
col "FREE(GB)" for 99,999,999.999 
col "EXTENSIBLE(GB)" for 99,999,999.999
col "MAX_SIZE(GB)" for 99,999,999.999
col "FREE PCT %" for 999.99
col "USED PCT OF MAX %" for 999.99
col "NO_AXF_NUM" for 9999
col "AXF_NUM" for 999
select d.tablespace_name "TBS_NAME"
      ,d.contents "TYPE"
      ,nvl(a.bytes /1024/1024/1024,0) "TOTAL(GB)"
      ,nvl(a.bytes - nvl(f.bytes,0),0)/1024/1024/1024 "USAGE(GB)"
      ,nvl(f.bytes,0)/1024/1024/1024 "FREE(GB)"
      ,nvl((a.bytes - nvl(f.bytes,0))/a.bytes * 100,0) "FREE PCT %"
      ,nvl(a.ARTACAK,0)/1024/1024/1024 "EXTENSIBLE(GB)"
      ,nvl(a.MAX_BYTES,0)/1024/1024/1024 "MAX_SIZE(GB)"
      ,nvl((a.bytes - nvl(f.bytes,0))/ (a.bytes + nvl(a.ARTACAK,0)) * 100,0) "USED PCT OF MAX %"
      ,a.NO_AXF_NUM
      ,a.AXF_NUM
from sys.dba_tablespaces d,
(select tablespace_name
       ,sum(bytes) bytes
       ,sum(decode(autoextensible,'YES',maxbytes - bytes,0 )) ARTACAK
       ,count(decode(autoextensible,'NO',0))  NO_AXF_NUM
       ,count(decode(autoextensible,'YES',0)) AXF_NUM
       ,sum(decode(maxbytes, 0, BYTES, maxbytes))   MAX_BYTES
from dba_data_files
group by tablespace_name
) a,
(select tablespace_name
       ,sum(bytes) bytes
from dba_free_space
group by tablespace_name
) f
where d.tablespace_name = a.tablespace_name(+)
  and d.tablespace_name = f.tablespace_name(+)
  and not (d.extent_management like 'LOCAL'and d.contents like 'TEMPORARY')
union all
select d.tablespace_name "TBS_NAME"
      ,d.contents "TYPE"
      ,nvl(a.bytes /1024/1024/1024,0) "TOTAL(GB)"
      ,nvl(t.bytes,0)/1024/1024/1024 "USAGE(GB)"
      ,nvl(a.bytes - nvl(t.bytes,0),0)/1024/1024/1024 "FREE(GB)"
      ,nvl(t.bytes/a.bytes * 100,0) "FREE PCT %"
      ,nvl(a.ARTACAK,0)/1024/1024/1024 "EXTENSIBLE(GB)"
      ,nvl(a.MAX_BYTES,0)/1024/1024/1024 "MAX_SIZE(GB)"
      ,nvl(t.bytes/(a.bytes + nvl(a.ARTACAK,0)) * 100,0) "USED PCT OF MAX %"
      ,a.NO_AXF_NUM
      ,a.AXF_NUM
from sys.dba_tablespaces d,
(select tablespace_name
       ,sum(bytes) bytes
       ,sum(decode(autoextensible,'YES',MAXbytes - bytes,0 )) ARTACAK
       ,count(decode(autoextensible,'NO',0)) NO_AXF_NUM
       ,count(decode(autoextensible,'YES',0)) AXF_NUM
       ,sum(decode(maxbytes, 0, BYTES, maxbytes))   MAX_BYTES
from dba_temp_files
group by tablespace_name
) a,
(select tablespace_name
      , sum(bytes_used) bytes 
from v$temp_extent_pool
group by tablespace_name
) t
where d.tablespace_name = a.tablespace_name(+)
  and d.tablespace_name = t.tablespace_name(+)
  and d.extent_management like 'LOCAL'
  and d.contents like 'TEMPORARY%'
order by 3 desc;
```

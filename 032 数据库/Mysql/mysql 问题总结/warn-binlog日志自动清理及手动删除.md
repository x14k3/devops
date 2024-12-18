# warn-binlog日志自动清理及手动删除

　　‍

　　**开启mysql主从时，设置expire_logs_days**

```bash
vim /etc/my.cnf         # 修改expire_logs_days,x是自动删除的天数，一般将x设置为短点，如10
--------------------------------------------------------------------------
expire_logs_days = x    # 二进制日志自动删除的天数。默认值为0,表示“没有自动删除”

#以上操作完之后记得重启数据库，当然也可以不重启mysql,开启mysql主从，直接在mysql里设置expire_logs_days
show binary logs; 
show variables like '%log%';
set global expire_logs_days = 10;
```

　　**登陆mysql，执行以下SQL语句手动清除binlog文件**

```bash
PURGE MASTER LOGS TO 'MySQL-bin.010';             # 清除MySQL-bin.010日志
PURGE MASTER LOGS BEFORE '2008-06-22 13:00:00';   # 清除2008-06-22 13:00:00前binlog日志
PURGE MASTER LOGS BEFORE DATE_SUB( NOW( ), INTERVAL 3 DAY); # 清除3天前binlog日志BEFORE，变量的date自变量可以为’YYYY-MM-DD hh:mm:ss’格式。
```

　　‍

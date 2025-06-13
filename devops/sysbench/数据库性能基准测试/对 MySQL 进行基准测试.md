

```bash
sysbench --threads=1000 --time=60 --report-interval=5 --db-driver=mysql --mysql-user=mycat --mysql-password=123456 --mysql-port=8066 --mysql-host=172.19.195.213 --mysql-db=db_mysqlslap oltp_insert prepare
sysbench --threads=5000 --time=60 --report-interval=5 --db-driver=mysql --mysql-user=mycat --mysql-password=123456 --mysql-port=8066 --mysql-host=172.19.195.213 --mysql-db=db_mysqlslap oltp_insert run
sysbench --threads=1000 --time=60 --report-interval=5 --db-driver=mysql --mysql-user=mycat --mysql-password=123456 --mysql-port=8066 --mysql-host=172.19.195.213 --mysql-db=db_mysqlslap oltp_insert cleanup

#参数说明：
--threads         并发数，这里模拟的是1000个客户端；
--time            测试时间，单位为秒；
--report-interval 每隔几秒输出一次详细结果；
--db-driver       测试的数据库，可以是mysql，postgresql等，
--mysql-user      数据库用户（因为这里测试入口是mycat，所以也创建也mycat用户）；
--mysql-password  数据库密码；
--mysql-port      数据库端口号；
--mysql-host      数据库ip地址；
--mysql-db        针对哪个库进行测试（这里我新建了一个库，用于测试）；
oltp_insert       测试的sql语句类型，因为场景为高并发写入，肯定是insert语句，所以选择oltp_insert；
```

# 生成SQL测试数据

postgresql:

```bash
create user hess superuser  password 'hess@123';  
create database hess with owner=hess;
create table table1 (id int, crt_Time timestamp, info text, c1 int); 
insert into table1 select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
```

‍

# 生成SQL测试数据

postgresql:

```bash
create user hess superuser  password 'hess@123';  
create database hess with owner=hess;
create table table1 (id int, crt_Time timestamp, info text, c1 int); 
insert into table1 select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
```

```bash
create table test(
first_name varchar(45) not null,
last_name varchar(45) not null,
primary key(first_name)
);

insert into test(first_name,last_name) values('Daniel Davis','Ronald Thompson');
insert into test(first_name,last_name) values('dgsdfsd','sdgsdgsg');
insert into test(first_name,last_name) values('sdsaaaagsdgsg','sdsaaaagsdgsg');
insert into test(first_name,last_name) values('fsfbdfh','fsfbdfh');
insert into test(first_name,last_name) values('sdgnfgnbfgbsdgsg','sdgnfgnbfgbsdgsg');
insert into test(first_name,last_name) values('sdgstrhrthdgsg','sdgstrhrthdgsg');
insert into test(first_name,last_name) values('sdfsd','sdfsd');
insert into test(first_name,last_name) values('dgsdfsd','sdfwegterher');
insert into test(first_name,last_name) values('rwerewsdcds','xcvxcvx');
insert into test(first_name,last_name) values('dgsdfsd','jgku');
insert into test(first_name,last_name) values('dgsdfsd','rtgert');
insert into test(first_name,last_name) values('jhgngfbgdf','nfgnthr');
insert into test(first_name,last_name) values('dgsdfsd','dbfdfbvc');
insert into test(first_name,last_name) values('ssss323r23','ssdsdvs');
insert into test(first_name,last_name) values('etrhertbfdx','cxvsdfs');
insert into test(first_name,last_name) values('xcvgerge','ewrwewgvfd');
insert into test(first_name,last_name) values('sdgssdsgrhrdgsg','fherherthe');
```

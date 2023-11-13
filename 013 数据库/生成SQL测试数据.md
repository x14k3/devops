# 生成SQL测试数据

## postgresql

```bash
create user hess superuser  password 'hess@123';  
create database hess with owner=hess;
create table test (id int, crt_Time timestamp, info text, c1 int); 
insert into test select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
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

## oracle

```bash
sqlplus jy2web/Ninestar123

create table test as 
select rownum as id,
to_char(sysdate + rownum/24/3600, 'yyyy-mm-dd hh24:mi:ss') as inc_datetime,
trunc(dbms_random.value(0, 100)) as random_id,
dbms_random.string('x', 20) random_string from dual connect by level <= 1000;
```

```sql
CREATE TABLE student(
    s_id number,
    s_name VARCHAR2(20) NOT NULL,
    s_sex VARCHAR2(10) DEFAULT 'man',
    s_age NUMBER NOT NULL,
    CONSTRAINT pk_sid PRIMARY KEY (s_id)
);

CREATE TABLE course(
    c_id NUMBER,
    c_name VARCHAR2(20) NOT NULL,
    c_time NUMBER,
    CONSTRAINT pk_cid PRIMARY KEY (c_id),
    CONSTRAINT uk_cname UNIQUE (c_name)
);

CREATE TABLE sc(
    s_id NUMBER,
    c_id NUMBER,
    grade NUMBER,
    CONSTRAINT pk_scid PRIMARY KEY (s_id, c_id),
    CONSTRAINT fk_sid FOREIGN KEY (s_id) REFERENCES student(s_id),
    CONSTRAINT fk_cid FOREIGN KEY (c_id) REFERENCES course(c_id)
);

--如下命令向 course 表插入了 7 条数据，向 student 和 sc 表中插入了十万条随机数据：
BEGIN
  INSERT INTO course VALUES(1, 'java', 13);
  INSERT INTO course VALUES(2, 'python', 12);
  INSERT INTO course VALUES(3, 'c', 10);
  INSERT INTO course VALUES(4, 'spark', 15);
  INSERT INTO course VALUES(5, 'php', 20);
  INSERT INTO course VALUES(6, 'hadoop', 11);
  INSERT INTO course VALUES(7, 'oracle', 22);
  FOR i IN 1..100000 LOOP
    INSERT INTO /*+ append */ student VALUES(i,'syl'||i,DECODE(TRUNC(DBMS_RANDOM.VALUE(0,2)),0,'man',1,'female'),TRUNC(DBMS_RANDOM.VALUE(12,80)));
    INSERT INTO /*+ append */ sc VALUES(i,TRUNC(DBMS_RANDOM.VALUE(1,8)),TRUNC(DBMS_RANDOM.VALUE(0,101)));
    IF MOD(i,5000)=0 THEN
           COMMIT;
    END IF;
  END LOOP;
END;
/

--提示：数据量巨大，需要等待一段时间。语句中的/*+ append */代表采用直接路径插入，使插入更快，每 5000 行提交一次也是为了提高速度。

--接下来看看是否都插入成功了：
SQL> select count(*) from student;

  COUNT(*)
----------
    100000

SQL> select count(*) from course;

  COUNT(*)
----------
     7

SQL> select count(*) from sc;

  COUNT(*)
----------
    100000
```

‍

‍

## Mysql

```bash
```

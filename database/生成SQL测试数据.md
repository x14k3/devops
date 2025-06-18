

## postgresql

```bash
create user zhixuan superuser  password 'zhixuan@2024';  
create database zhixuan with owner=zhixuan;
create table test (id int, crt_Time timestamp, info text, c1 int); 
insert into test select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
```

## oracle

```sql
--创建一个表，并同时添加1000000条数据
create table t1 as 
select rownum as id,
               to_char(sysdate + rownum/24/3600, 'yyyy-mm-dd hh24:mi:ss') as inc_datetime,
               trunc(dbms_random.value(0, 100)) as random_id,
               dbms_random.string('x', 20) random_string
          from dual
        connect by level <= 1000;

--在创建表后，原来表的基础上追加记录，比如在方法一创建的TestTable表中追加1000000条数据
insert into test
  (ID, INC_DATETIME,RANDOM_ID,RANDOM_STRING)
  select rownum as id,
         to_char(sysdate + rownum / 24 / 3600, 'yyyy-mm-dd hh24:mi:ss') as inc_datetime,
         trunc(dbms_random.value(0, 100)) as random_id,
         dbms_random.string('x', 20) random_string
    from dual
  connect by level <= 1000;


```


```sql
-- 创建学生表
CREATE TABLE student (
    id NUMBER PRIMARY KEY,          -- 学生ID（主键）
    name VARCHAR2(50) NOT NULL,     -- 姓名
    age NUMBER(3) CHECK (age BETWEEN 15 AND 30),  -- 年龄（15-30岁）
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female')),  -- 性别
    enrollment_date DATE DEFAULT SYSDATE  -- 入学日期（默认当天）
);

-- 创建序列用于ID自增
CREATE SEQUENCE student_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 创建触发器实现ID自动插入
CREATE OR REPLACE TRIGGER student_bir
BEFORE INSERT ON student
FOR EACH ROW
BEGIN
    SELECT student_seq.NEXTVAL INTO :new.id FROM dual;
END;
/

BEGIN
  FOR i IN 1..1000 LOOP
    INSERT INTO student (name, age, gender, enrollment_date)
    VALUES (
      'Student_' || TO_CHAR(i, 'FM0000'),  -- 生成唯一姓名
      TRUNC(DBMS_RANDOM.VALUE(15, 30)),    -- 随机年龄（15-29）
      CASE MOD(i, 2)                       -- 交替性别
          WHEN 0 THEN 'Female'
          ELSE 'Male'
       END,
      SYSDATE - DBMS_RANDOM.VALUE(0, 365*3) -- 随机入学日期（近3年内）
    );
  END LOOP;
  COMMIT;
END;
/
```


## Mysql

```sql
-------------- create database
create database test default character set utf8mb4;

-------------- create table
use test;
CREATE TABLE `app_user`(
    `id` INT  NOT NULL AUTO_INCREMENT COMMENT '主键',
	`id_` VARCHAR(100) NOT NULL COMMENT '主键2',
    `name` VARCHAR(50) DEFAULT '' COMMENT '用户名称',
    `email` VARCHAR(50) NOT NULL COMMENT '邮箱',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '手机号',
    `gender` TINYINT DEFAULT '0' COMMENT '性别（0-男  ： 1-女）',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `age` TINYINT DEFAULT '0' COMMENT '年龄',
    `create_time` DATETIME DEFAULT NOW(),
    `update_time` DATETIME DEFAULT NOW(),
    PRIMARY KEY (`id`,`id_`) 
)ENGINE = INNODB DEFAULT CHARSET = utf8 COMMENT='app用户表';

-------------- create function - insert data
SET GLOBAL log_bin_trust_function_creators=TRUE; -- 创建函数一定要写这个
DELIMITER $$   -- 写函数之前必须要写，该标志

CREATE FUNCTION insert_data()          -- 创建函数（方法）
RETURNS INT                            -- 返回类型
BEGIN                                  -- 函数方法体开始
    DECLARE num INT DEFAULT 1000000;   -- 定义一个变量num为int类型。默认值为100 0000
    DECLARE i INT DEFAULT 0; 

    WHILE i < num DO                   -- 循环条件
         INSERT INTO app_user(`id_`,`name`,`email`,`phone`,`gender`,`password`,`age`) 
         VALUES(UUID(),CONCAT('用户',i),'2548928007qq.com',CONCAT('18',FLOOR(RAND() * ((999999999 - 100000000) + 1000000000))),FLOOR(RAND()  *  2),UUID(),FLOOR(RAND()  *  100));
        SET i =  i + 1;    -- i自增  
    END WHILE;             -- 循环结束
    RETURN i;
END;                       -- 函数方法体结束
$$
DELIMITER ;                -- 写函数之前必须要写，该标志




-------------- create function - insert data 2

SET GLOBAL log_bin_trust_function_creators=TRUE; -- 创建函数一定要写这个
DELIMITER $$   -- 写函数之前必须要写，该标志

CREATE FUNCTION insert2_data()         -- 创建函数（方法）
RETURNS INT                            -- 返回类型
BEGIN                                  -- 函数方法体开始
    DECLARE num INT DEFAULT 1000000;   -- 定义一个变量num为int类型。默认值为100 0000
    DECLARE i INT DEFAULT 0; 

    WHILE i < num DO                   -- 循环条件
         INSERT INTO app_user(`id_`,`complete`,`name`,`email`,`phone`,`gender`,`password`,`age`) 
         VALUES(UUID(),i,CONCAT('用户',i),'2548928007qq.com',CONCAT('18',FLOOR(RAND() * ((999999999 - 100000000) + 1000000000))),FLOOR(RAND()  *  2),UUID(),FLOOR(RAND()  *  100));
        SET i =  i + 1;    -- i自增  
    END WHILE;             -- 循环结束
    RETURN 1;
END;                       -- 函数方法体结束
$$
DELIMITER ;                -- 写函数之前必须要写，该标志



-------------- run function  
SELECT insert_data();        -- 调用函数
ALTER TABLE app_user ADD COLUMN complete DECIMAL(2,1) NULL AFTER id_;
ALTER TABLE app_user ADD COLUMN addtest int NULL AFTER id_;
select insert2_data();
ALTER TABLE app_user drop COLUMN complete;
```



## postgresql

```bash
create user zhixuan superuser  password 'zhixuan@2024';  
create database zhixuan with owner=zhixuan;
create table test (id int, crt_Time timestamp, info text, c1 int); 
insert into test select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
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


## oracle

```sql

[oracle@rac-01 ~]$ sqlplus test_user/Ninestar123@192.168.10.161:1521/pdb1



-- 2. 在 TEST_DATA 表空间中创建测试表
CREATE TABLE test_data (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    email VARCHAR2(100),
    created_date DATE,
    value NUMBER(15,2),
    description VARCHAR2(500)
)
TABLESPACE test_data
STORAGE (INITIAL 100M NEXT 50M);


DECLARE
    batch_size NUMBER := 50; -- 每批插入量
    total_rows NUMBER := 1000; -- 总行数
    start_id NUMBER := 1;
BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL DML PARALLEL 8';
    
    
    FOR i IN 1..CEIL(total_rows/batch_size) LOOP
        INSERT /*+ APPEND PARALLEL(8) */ INTO test_data
        SELECT
            rownum + start_id - 1 AS id,
            'User_' || TO_CHAR(rownum + start_id - 1) AS name,
            'user' || TO_CHAR(rownum + start_id - 1) || '@example.com' AS email,
            SYSDATE - DBMS_RANDOM.VALUE(0, 3650) AS created_date,
            ROUND(DBMS_RANDOM.VALUE(1, 10000), 2) AS value,
            RPAD('Desc_', 500, DBMS_RANDOM.STRING('X', 495)) AS description
        FROM dual
        CONNECT BY LEVEL <= batch_size;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Inserted: ' || (i * batch_size) || ' rows');

        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
        
        start_id := start_id + batch_size;
    END LOOP;
    

    EXECUTE IMMEDIATE 'ALTER TABLE test_data LOGGING';
    DBMS_OUTPUT.PUT_LINE('Total inserted: ' || total_rows || ' rows');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 4. 创建索引
ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL QUERY;

CREATE INDEX idx_test_data_date ON test_data(created_date) 
  TABLESPACE test_data;


#####################################################################


-- 1. 禁用外键约束（如果有）
BEGIN
    FOR cons IN (SELECT constraint_name 
                 FROM user_constraints 
                 WHERE table_name = 'TEST_DATA' 
                 AND constraint_type = 'R') 
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE test_data DISABLE CONSTRAINT ' || cons.constraint_name;
    END LOOP;
END;
/

-- 2. 高效删除数据（保留表结构）
TRUNCATE TABLE test_data REUSE STORAGE;


-- 3. 删除表空间及其所有内容（彻底删除）
-- 注意：此操作不可逆，将永久删除所有数据文件！
DROP TABLESPACE test_data INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;

-- 4. 如果只需删除数据保留表空间，使用：
-- TRUNCATE TABLE test_data DROP STORAGE;
-- ALTER TABLESPACE test_data SHRINK SPACE KEEP 100M;

-- 5. 重建表空间（可选，用于后续测试）
-- CREATE TABLESPACE test_data ... （同创建脚本）

```
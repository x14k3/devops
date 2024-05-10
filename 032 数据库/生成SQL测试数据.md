# 生成SQL测试数据

## postgresql

```bash
create user hess superuser  password 'hess@123';  
create database hess with owner=hess;
create table test (id int, crt_Time timestamp, info text, c1 int); 
insert into test select generate_series(1,100), clock_timestamp(), md5(random()::text), random()*1000;  
```

## oracle

```bash
sqlplus jy2web/Ninestar123

create table test as 
select rownum as id,
to_char(sysdate + rownum/24/3600, 'yyyy-mm-dd hh24:mi:ss') as inc_datetime,
trunc(dbms_random.value(0, 100000)) as random_id,
dbms_random.string('x', 20) random_string from dual connect by level <= 100000;
```

## Mysql

```bash

CREATE TABLE `app_user`(
    `id` INT  NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name` VARCHAR(50) DEFAULT '' COMMENT '用户名称',
    `email` VARCHAR(50) NOT NULL COMMENT '邮箱',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '手机号',
    `gender` TINYINT DEFAULT '0' COMMENT '性别（0-男  ： 1-女）',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `age` TINYINT DEFAULT '0' COMMENT '年龄',
    `create_time` DATETIME DEFAULT NOW(),
    `update_time` DATETIME DEFAULT NOW(),
    PRIMARY KEY (`id`) 
)ENGINE = INNODB DEFAULT CHARSET = utf8 COMMENT='app用户表'


SET GLOBAL log_bin_trust_function_creators=TRUE; -- 创建函数一定要写这个
DELIMITER $$   -- 写函数之前必须要写，该标志

CREATE FUNCTION mock_data()            -- 创建函数（方法）
RETURNS INT                            -- 返回类型
BEGIN                                  -- 函数方法体开始
    DECLARE num INT DEFAULT 100;   -- 定义一个变量num为int类型。默认值为100 0000
    DECLARE i INT DEFAULT 0; 

    WHILE i < num DO                   -- 循环条件
         INSERT INTO app_user(`name`,`email`,`phone`,`gender`,`password`,`age`) 
         VALUES(CONCAT('用户',i),'2548928007qq.com',CONCAT('18',FLOOR(RAND() * ((999999999 - 100000000) + 1000000000))),FLOOR(RAND()  *  2),UUID(),FLOOR(RAND()  *  100));
        SET i =  i + 1;    -- i自增  
    END WHILE;             -- 循环结束
    RETURN i;
END;                       -- 函数方法体结束
$$
DELIMITER ;                -- 写函数之前必须要写，该标志

SELECT mock_data();        -- 调用函数
```

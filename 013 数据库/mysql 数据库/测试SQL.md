# 测试SQL

## MySQL 生成百万条数据超详细步骤

本篇文章是关于 MySQL 生成百万条数据的全部过程，每一步都有具体的 sql，并且每一步都有具体的注释，详细步骤如下：

### 1、创建数据库

```sql
CREATE DATABASE `test_bai` -- 创建数据库
USE `test_bai` -- 切换对应的数据库
```

### 2、创建表

```sql
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
```

### 3、书写新增 100 万条数据的函数

```sql
SET GLOBAL log_bin_trust_function_creators=TRUE; -- 创建函数一定要写这个
DELIMITER $$   -- 写函数之前必须要写，该标志

CREATE FUNCTION mock_data()        -- 创建函数（方法）
RETURNS INT                         -- 返回类型
BEGIN                                -- 函数方法体开始
    DECLARE num INT DEFAULT 1000000;         -- 定义一个变量num为int类型。默认值为100 0000
    DECLARE i INT DEFAULT 0; 

    WHILE i < num DO                 -- 循环条件
         INSERT INTO app_user(`name`,`email`,`phone`,`gender`,`password`,`age`) 
         VALUES(CONCAT('用户',i),'2548928007qq.com',CONCAT('18',FLOOR(RAND() * ((999999999 - 100000000) + 1000000000))),FLOOR(RAND()  *  2),UUID(),FLOOR(RAND()  *  100));
        SET i =  i + 1;    -- i自增  
    END WHILE;        -- 循环结束
    RETURN i;
END;                                 -- 函数方法体结束
```

### 4、调用函数

```sql
SELECT mock_data(); -- 调用函数
```

<br />这个时候数据库就有了 100 万条数据了！！！

‍

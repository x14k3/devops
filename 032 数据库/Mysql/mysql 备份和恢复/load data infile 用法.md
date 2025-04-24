# load data infile 用法

load data infile语句从一个文本文件中以很高的速度读入一个表中。

## 1. 命令load data local infile的设置

应当在/etc/mysql/my.cnf中添加这样的设置:

```bash
#服务端配置
[mysqld]
local-infle = 1

#客户端配置
[mysql]
local-infile = 1
```

否则，mysql服务会提示错误:  
​`ERROR 1148 (42000): The used command is not allowed with this MySQL version.`​

客户端和服务端都需要开启：对于客户端也可以在执行命中加上`--local-infile=1`​ 参数

‍

## 语法

```bash
LOAD DATA [LOW_PRIORITY] [LOCAL] INFILE 'file_name.txt' [REPLACE | IGNORE]
    INTO TABLE tbl_name
    [FIELDS
        [TERMINATED BY '\t']
        [OPTIONALLY] ENCLOSED BY '']
        [ESCAPED BY '\\' ]]
    [LINES TERMINATED BY '\n']
    [IGNORE number LINES]
    [(col_name,...)]
```

‍

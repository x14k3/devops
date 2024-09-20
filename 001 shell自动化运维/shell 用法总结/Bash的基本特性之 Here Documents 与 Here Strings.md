# Bash的基本特性之 Here Documents 与 Here Strings

# Here Documents

　　Here Documents 作为重定向的一种方式，指的是 shell 从源文件的当前位置开始读取输出，直到遇到只包含一个单词的文本行时结束。在该过程中读到的所有文本行都将作为某一个命令的标准输入而使用。

　　Here Documents 的使用形式：

```bash
command <<[-] limit_string
	msg_body
limit_string
```

　　对于 `cat`​ 命令在使用 Here Documents 时默认的标准输入是从键盘的输入读进来的，默认的输出是屏幕

```bash
[user1@study ~]$ cat << EOF
> 1234
> 431
> 321
> eof
> EOF
1234
431
321
eof
[user1@study ~]$
```

　　在行尾使用转义符 `\`​ 其实是对换行符 `\n`​ 进行了转义，意思是此处不进行换行

```bash
[user1@study ~]$ cat << EOF
> abc\
> def
> EOF
abcdef
[user1@study ~]$
```

　　如果用 `<<`​ 而不是 `<<-`​，则最后面的 `limit_string`​ 必须位于行首，否则如果 Here Documents 用在函数内部，则会报语法错误；

```bash
[user1@study ~]$ cat test.sh  
#!/bin/bash

func1(){
        cat << EOF
        a
        b
        c
        EOF

}

func1
[user1@study ~]$ 
[user1@study ~]$ bash test.sh 
test.sh: line 12: warning: here-document at line 4 delimited by end-of-file (wanted `EOF')
test.sh: line 13: syntax error: unexpected end of file
[user1@study ~]$
```

　　将后面的 `EOF`​放到行首，再次执行虽然没有报错，但是发现前面带了函数中用来缩进的的 `Tab`​ 制表符

```bash
[user1@study ~]$ cat test.sh  
#!/bin/bash

func1(){
        cat << EOF
        a
        b
        c
EOF

}

func1
[user1@study ~]$ bash test.sh 
        a
        b
        c
[user1@study ~]$
```

　　如果重定向操作符是 `<<-`​, 则 `msg_body`​ 和 `limit_string`​ 行中的所有开头的 `Tab`​ 制表字符都将被忽略（但空格不会被忽略）。这样源代码中的 Here Documents 就可以按照优雅的读入方式进行对齐。

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

func1(){
        cat <<- EOF
        a
        b
        c
EOF

}

func1
[user1@study ~]$ bash test.sh 
a
b
c
[user1@study ~]$
```

　　用在函数外面，第一个 `limit_string`​ 后面的所有内容均会被当做 Here Documents 的内容。

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

func1(){
        echo hello

}

func1

cat <<- EOF
a
b
c
EOF
[user1@study ~]$ bash test.sh 
hello
a
b
c
[user1@study ~]$
```

　　如果用双引号 `""`​ 或单引号 `''`​ 将 `limit_string`​ 引起来或用转义符 `\`​ 将其转义，则 Here Documents 中的文本将不被扩展，即参数替换被禁用。请注意，下面的例子对 `cat`​ 的标准输出做了覆盖重定向，读入的内容会覆盖到指定的文件而不会再是默认输出到屏幕

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

# create a shell script

cat > hello.sh <<- 'EOF'
#!/bin/bash

today="$(date +'%F %T')"

echo ${today}

EOF
[user1@study ~]$ bash test.sh 
[user1@study ~]$ cat hello.sh 
#!/bin/bash

today="$(date +'%F %T')"

echo ${today}

[user1@study ~]$ bash hello.sh 
2015-07-14 22:10:27
[user1@study ~]$
```

　　如果不使用引号或者转义符，则 Here Documents 中的所有文本都将进行常规的参数扩展、命令替换、表达式计算。

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

# create a shell script

# 注意这里的 EOF 没有使用引号或转义符 \
cat > hello.sh <<- EOF
#!/bin/bash

today="$(date +'%F %T')"

echo ${today}

EOF
[user1@study ~]$ bash test.sh 
[user1@study ~]$ cat hello.sh 
#!/bin/bash

today="2015-07-14 22:11:55"

echo 

[user1@study ~]$ bash hello.sh 

[user1@study ~]$
```

　　还可以使用 Here Documents 的方式将很多个内容赋值给一个变量

```bash
[user1@study ~]$ a=$(cat << EOF
> 10.0.0.0/8
> 100.64.0.0/10
> 172.16.0.0/12
> 192.168.0.0/16
> EOF
> )
[user1@study ~]$ echo $a
10.0.0.0/8 100.64.0.0/10 172.16.0.0/12 192.168.0.0/16
[user1@study ~]$
```

　　要提一句的是，`:`​ 在 shell 中的意思就是不做任何处理，类似于 Python 中的 `pass`​ 语句

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

if [ 1 -eq 1 ];then
    :
else
    echo "no"
fi
[user1@study ~]$ bash test.sh 
[user1@study ~]$
```

　　如果不想使用 `#`​ 对代码块进行多行注释，可以使用 Here Documents 配合 `:`​ 来处理

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

:<<EOF
if [ 1 -eq 1 ];then
    :
else
    echo "no"
fi
EOF

echo '12345'

[user1@study ~]$ bash test.sh 
12345
[user1@study ~]$
```

　　连接数据库，并执行 SQL 语句通常都是在键盘输入到命令行操作的

```bash
[root@study ~]# mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 5.5.60-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use mysql
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [mysql]> select * from user;
# 内容省略
6 rows in set (0.00 sec)

MariaDB [mysql]> exit
Bye
[root@study ~]#
```

　　有了 Here Documents 就可以在 shell 脚本中用到了。另外类似于这种用法在脚本中使用 `fdisk`​ 命令配合 Here Documents 就能自动完成分区操作，此处不再详述。

```bash
[root@study ~]# cat test.sh 
#!/bin/bash

mysql -u root << EOF
use mysql;
select * from user;
exit
EOF
[root@study ~]# bash test.sh
```

# Here Strings

　　Here Strings 也叫 Here word，指的是从字符中读入数据作为标准输入。

　　使用格式

```bash
command <<< word
```

　　这里的 `word`​ 建议最好使用引号括起来，因为有空格的情况会出现错误

```bash
[user1@study ~]$ grep yes <<< 'yess'
yess
[user1@study ~]$ grep -o -i yes <<< 'fyessYes'
yes
Yes
[user1@study ~]$ grep -o -i yes <<< fye ssYes
grep: ssYes: No such file or directory
[user1@study ~]$
```

　　并不是必须是纯字符才能作为输入，使用有输出的命令替换也是可以的

```bash
[user1@study ~]$ grep -i 'world' <<< "$(cat file.txt)"
Hello world ! Wed May 1 15:00:10 CST 2019
[user1@study ~]$
```

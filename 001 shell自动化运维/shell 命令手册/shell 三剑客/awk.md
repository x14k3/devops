# awk

　　AWK是一种强大的文本处理工具，其处理文本的效率极高，其输出可以来自标注输入、其他命令的输出或一个或多个文件，熟练使用awk将会对工作效率有很大的提升。

## awk调用方式

　　awk调用方式包括三种：

#### 一、命令行调用

```bash
awk [-F seperator] 'commond' input-file
```

　　commond的组成又可以包括多个模式和动作的组合，即命令行调用又可以写为：

```bash
akw [-F seperator] 'parrtern1 {Action1} pattern2 {Action2}' input-file
```

* seperator:分隔符。分隔符为可选参数，可以为任意字符串,若不指定，默认分隔符为空格。
* commond:awk命令
* input\_file: 待处理的文本文件

#### 二、脚本调用

```bash
awk -f awk-script-file input-file
```

　　将awk命令写入一个文件中，然后使用-f参数指定该文件运行

#### 三、shell脚本插入awk命令

　　在shell中插入awk命令对文件进行处理,直接执行shell命令。

## 模式与动作

```
任何awk语句都由**模式**和**动作**组成，**模式部分决定Action语句何时触发以及触发事件，动作决定对当前被匹配的数据进行的操作**，Action中由多个awk处理语句组成。
```

```bash
awk [-F seperator] 'parrtern1 {Action1} pattern2 {Action2}' input-file
```

　　**注意问题**：

* awk语句必须被单引号或双引号包含，防止awk语句被当做shell命令解析。
* 确保awk命令中所有引号都成对出现
* 确保用花括号括起来动作语句，用圆括号括起来条件语句
* 模式与动作**一一对应**，只有pattern匹配成功，对应的action(用{}括起来表示一个action)才会执行。
* 模式可以为任何**条件语句**或**复合语句**或**正则表达式**，也可以为awk保留字BEGIN，END
* 模式尽量**不要加双引号**，否则某些情况下可能会失效，如”\$1\>30”。
* action一定要**用{}括起来**，一个{}括起来的动作属于一个action，不同{}括起来的动作属于不同action,其对应不同的pattern。
* BEGIN和END为特殊的模式，**BEGIN模式使用在任何文本浏览之前**，常用来做一些初始化设置或打印头部信息等，**END模式使用在完成文本浏览动作之后**，常用来处理一些收尾打印等工作。注意**BEGIN和END语句都仅且执行一次**

## awk基本用法

　　假定一下为一个学校中抽样的几个学生的成绩(score.txt)，下面四列分别为学号，名字，年级，分数：

```bash
13331264 tom   grade4 94
13342010 marry grade4 90
13315012 jemmy grade1 85
13323089 jane  grade2 80
```

#### 域标识

> awk从输入文件中**每次读取一行**，当遇到分割符时将其分割为域，这些域被标记为\$1，\$2,\$3...，直到读到文件结尾或文件不存在,$0表示当前记录（即当前行）。

　　示例：

```bash
# 不加pattern
awk '{print $1,$4}' score.txt
输出结果：
13331264 94
13342010 90
13315012 85
13323089 80
# pattern为$4>=90,过滤分数超过90分的用户才处理
awk '$4>=90 {print $1,$4}' score.txt
输出结果：
13331264 94
13342010 90
# 命令有两个parttern action组，第一个pattern为BEGIN,第二个patter为$4>=90
awk 'BEGIN {print "学号     成绩"} $4>=90 {print $1,$4}' score.txt
输出结果：
学号     成绩
13331264 94
13342010 90
```

#### 条件控制语句

　　**关系与正则运算符**：

|符号|描述|
| ------------| --------------------------------------------------------------------------------------------|
|\<|小于|
|\<\=|小于等于|
|\>|大于|
|\>\=|大于等于|
|\=\=|等于|
|\~|匹配正则表达式（二元 符号前面为被匹配的字符串，后面为模式串，一般模式传用/pattern/括起来）|
|!\~|不匹配正则表达式|

　　**逻辑运算符**

　　逻辑运算符与C语言中完全一致。

|符号|描述|||
| -------| ----------------------------| --| ------------------------------|
|&&|且，两个条件同时满足才为真|||
|\\|\\||或，只要有一个条件为真即为真|
|!|将结果取反（一元运算符）|||

　　**关键字**

|关键字|描述|
| ----------| --------------------------------------------------------------------------------------|
|break|用于while或for循环，退出循环|
|continue|终止当前循环，执行下一个循环|
|next|导致读入下一个输入行，并返回到脚本的顶部。这可以避免对当前输入行执行其他的操作过程。|
|exit|退出执行，直接跳转到END执行，若没有END,终止脚本|

```bash
# 过滤学号中有1333字符串的成绩记录
awk '{if($1~/1333/) print $0}' score.txt
输出：
13331264 tom   grade4 94
# 过滤学号中不含1333字符串的成绩记录
awk '{if($1!~/1333/) print $0}' score.txt
输出：
13342010 marry grade4 90
13315012 jemmy grade1 85
13323089 jane  grade2 80
# 过滤成绩大于85分的成绩记录
awk '{if($4>85) print $0}' score.txt
输出：
13331264 tom   grade4 94
13342010 marry grade4 90
# 过滤成绩大于90小于100的成绩记录
awk '{if($4>90&&$4<100) print $0}' score.txt
输出：
13331264 tom   grade4 94
```

　　**if条件控制语句**

> 在awk中使用if判断条件时，必须将if后面的条件用()括起来，与C语言类似。

　　当然我们使用模式代替if条件判断，这个可以达到相同的效果

```bash
# 使用条件语句
awk '{if($4>85) print $0}' score.txt
# 使用模式过滤行
awk '$4>85 {print $0}' score.txt
```

#### for循环控制语句

　　**语法**

```bash
# 格式一：
for (变量 in 数组)
{
    do_something;
}
# 格式二（与C语言相同）
for (变量;条件;表达式)
{
    do_something;
}
```

　　**使用示例**

```bash

# ENVIRON为awk内置的环境变量，下面会说到。其为一个数组，该作用为打印环境变量中的所有键值对
awk 'BEGIN {for(k in ENVIRON) {print k"="ENVIRON[k];}}'
# 打印0-9
awk 'BEGIN {for(i=0;i<10;i++) {print i}}'
```

#### while循环控制语句

　　**语法：**

```bash

while (条件表达式)
{
    do_something;
}
```

　　**使用示例**

```bash
# 打印0-9
awk 'BEGIN {i=0; while (i<10){print i;i++}}'
```

#### do while循环控制语句

　　**语法:**

```bash
do
{
    do_something
}
while (条件表达式)
```

　　**使用示例**

```bash
#打印0-9
awk 'BEGIN {i=0;do{print i; i++;} while (i<10)}'
```

#### awk运算

　　**算术运算符**

|符号|描述|
| ----------------| ------------------------------|
|+ - \*  / %|加/减/乘/除/取余|
|++|自增1|
|–|自减1|
|+|一元加操作符，将操作数乘以1|
|-|一元减操作符，将操作数乘以-1|
|\^|求幂。如2\^2\=4|

　　**赋值运算符**

|符号|描述|
| --------------------------------------------------------| -----------------------------------------------------------------|
|\=|赋值|
|+\=、-\=、\*\=、/\=、%\=、\^\=|将左右操作数进行对应操作，然后赋值给左操作数（与C语言完全一致）|

　　**其他运算符**

|符号|描述|
| -------| ----------------------------|
|\$|字段引用（引用域）|
|? :|条件表达式（与C语言一致）|
|空格|字符串连接符|
|in|判断数组中是否存在某个键值|

　　**运算符优先级：**   
​![crc1](https://langzi989.github.io/images/算术优先级.gif)​

#### awk数组

> awk数组是一种关联数组，其下标既可以是数字，也可以是字符串。

* 无需定义，数组在使用时被定义
* 数组元素的初始值为0或者空字符串
* 数组可以自动扩展

　　使用示例：

```bash
# 数组可直接使用，且无需定义
awk 'BEGIN {a["123"]=2;print a["123"]}'
输出：
2
# 可使用for循环对数组中的元素进行循环读取
awk 'BEGIN {a[1]=2;a[2]=3;a[3]=4; for(k in a) print k"="a[k];}'
输出：
1=2
2=3
3=4
# 可以通过if 判断某个key是否在数组中
awk 'BEGIN {a[1]=2;a[2]=3;a[3]=4; print 5 in a; print 1 in a}'
输出：
0
1
# 删除数组中的元素，使用delete arr['key']
awk 'BEGIN {a[1]=2;a[2]=3;a[3]=4; delete a[1];for(k in a) print k"="a[k];}'
输出：
2=3
3=4
# 多维数组的下标分隔符默认为“\034”，可通过设定SUBSEP修改多为数组的下标分隔符
awk 'BEGIN {a[1,2]=10; for(k in a) print k"="a[k];}'
输出：
12=10
awk 'BEGIN {SUBSEP=":";a[1,2]=10; for(k in a) print k"="a[k];}'
输出：
1:2=10
```

#### awk内置变量

|变量|描述|
| ----------| ----------------------------------------------------------------------------------------|
|ARGC|命令行参数个数,awk后参数个数|
|ARGV|命令行参数数组，数组下标从0开始|
|ENVIRON|系统环境变量数组|
|FILENAME|输入文件的名字|
|FNR|浏览文件的记录数（文件中的记录数，若多个文件不会累加）|
|NR|已读记录数（已读的记录数，若多文件会离家）|
|NF|浏览记录域的个数（即每行分割的域的最大值）|
|FS|设置域分割符，常用于BEGIN中设置域分割符|
|RS|设置记录分隔符，原记录分隔符默认为换行，即一行一行读取，可使用该参数控制其不按照行读取|
|OFS|设置**输出域分隔符**，原域默认分隔符为空格，可使用此分隔符修改|
|ORS|设置输出记录分隔符。原记录默认分隔符为换行，可使用此参数修改|

　　**使用示例：**

```bash

# ARGC测试
awk 'BEGIN {print ARGC}' score.txt
输出:
2
# ARGV测试
awk 'BEGIN {print ARGC; print ARGV[0];print ARGV[1]}' score.txt
输出：
2
awk
score.txt
# ENVIRON测试
awk 'BEGIN {for(k in ENVIRON) {print k"="ENVIRON[k];}}'
# FILENAME测试
 awk 'BEGIN {i=0} {if(i==0){print FILENAME;i++}}' score.txt
输出：
score.txt
# FNR测试
awk ' END {print FNR}' score.txt
输出：
1
2
3
4
#NR 测试
awk '{print NR}' score.txt  
输出：
1
2
3
4
# NF测试
awk ' END {print NF}' score.txt
# FS测试(以下两种方式效果一致)
awk 'BEGIN {FS="\t"} {print NR}' score.txt
awk -F'\t' '{print NR}' score.txt
# OFS测试
awk 'BEGIN {OFS="|"} {print $1,$2}' score.txt
输出：
13331264|tom
13342010|marry
13315012|jemmy
13323089|jane
# ORS测试
awk 'BEGIN {ORS="|"} {print $1,$2}' score.txt
输出：
13331264 tom|13342010 marry|13315012 jemmy|13323089 jane|
# RS测试
awk 'BEGIN {RS="1333"} {print $1,$2}' score.txt
输出：
1264 tom
```

　　**FNR与NR区别**

```bash
cat a.txt
111
222
111
333
444
cat b.txt
111
555
666
awk '{print FNR}' a.txt b.txt
1
2
3
4
5
1
2
3
awk '{print NR}' a.txt b.txt
1
2
3
4
5
6
7
8
```

#### awk内置函数

　　**计算相关函数：**

|函数|描述|
| ------------| ------------------------|
|cos(expr)|计算余弦值，参数为弧度|
|sin(expr)|计算正弦值，参数为弧度|
|int(expr)|取整|
|log(expr)|计算expr的自然对数|
|sqrt(expr)|计算expr的平方根|

```bash
# 测试cos
awk 'BEGIN {print cos(60*3.1415936/180)}'
输出：
0.5
# 测试int
awk 'BEGIN {print int(20.5)}'
输出：
20
# 测试log
awk 'BEGIN {print log(10)}'
输出：
2.30259
```

　　**注意：awk字符串下标从1开始不是从0开始**

　　**字符串相关函数：**

|函数|描述|
| -----------------------| -------------------------------------------------------------------|
|sub(src,des)|将0中src第一次出现的子串替换为des|
|sub(src,des,str)|将字符串str中第一次出现的src替换为des。|
|gsub(src,des)|将0中的src全部替换为des，若0中包含src,则返回1否则返回0|
|gsub(src,des,str)|将字符串str中的所有src替换为des,|
|index(str,substr)|返回str中字符串substr首次出现的位置，位置从1开始，若未找到则返回0|
|length（str）|返回str的长度|
|match(str, substr)|测试str中是否存在子串substr|
|split(str,result,sep)|将str以sep为分割符分割为数组，并存到result中|
|printf(format,…)|格式化输出，与C语言类似|
|substr(str,start)|返回从start开始一直到最后的子字符串,与C++类似|
|substr(str,start,n)|返回从start开始长度为n的子字符串，与C++类似|

　　**常用printf format**

|format|说明|
| --------| --------------------|
|%c|ascii字符|
|%d|整数|
|%e|浮点数，科学计数法|
|%f|浮点数(如1.234)|
|%o|八进制数|
|%x|十六进制数|
|%s|字符串|

　　‍

```bash
#sub测试
awk 'BEGIN {s="aaabbbaaaccc";sub("aaa","1",s);print s}'
输出：
1bbbaaaccc
# gsub(r,s)测试
awk '{gsub("t","s");print $0}' ./score.txt
输出：
13331264 som   grade4 94
13342010 marry grade4 90
13315012 jemmy grade1 85
13323089 jane  grade2 80
# gsub(r,s,t)测试
awk '{gsub("133", "45",$1);print $0}' ./score.txt  
输出：
4531264 tom grade4 94
4542010 marry grade4 90
4515012 jemmy grade1 85
4523089 jane grade2 80
# index(s,t)测试
awk '{r = index($2,"m");print r}' ./score.txt
输出：
3
1
3
0
# 测试length
awk '{print length($2)}' ./score.txt
输出：
3
5
5
4
# 测试match
awk '{print match($2,"to")}' ./score.txt
输出：
1
0
0
0
# split测试
awk 'BEGIN {print split("this is a test",result, " "); for(k in result) {print k":"result[k]}}'
# substr测试
awk 'BEGIN {s="aaabbbccc";print substr(s,2)}'
输出：
aabbbccc
```

## AWK几个例子

#### 文件去重并统计相同记录出现次数(保留记录原来的顺序)

```bash
test.txt
111
222
111
333
444
# !的优先级高于++,读到一条记录，首先判断记录是否存在于arr中，若不存在，添加到数组中并将该记录数出现次数+1，否则打印
awk '!arr[$0]++' test.txt
# 统计每条记录出现的次数
awk '{!arr[$0]++} END {for (k in arr) print k,arr[k]}' test.txt
```

#### 文件内容合并

```bash
test.txt.1
111
555
666
awk '{if(!arr[$0]) {print $0; arr[$0]++}}' test.txt test.txt.1
```

#### 找出文件A中存在且文件B中不存在的记录

```bash
A:
111
222
333
444
B:
333
444
#计算a.txt-(a.txt并a.txt)
awk 'NR==FNR {a[$0]=1} NR>FNR {if (!a[$0]) print $0}' b.txt a.txt
输出：
111
222
```

### 使用eval命令直接赋值多个变量

　　例如现在需要将下面的文本内容每行都转换为 json 格式，好传递给接口写入数据。

```
[root@imzcy ~]# cat example.txt
db001 order 50000
db001 logistics 50000
db001 sms 60000
db002 pay 10000
db002 history 300000
[root@imzcy ~]#
```

　　转换后样子

```
{"database":"db001","table":"order","line":50000}
```

#### 传统定义多行变量

　　常规的方法就是使用while循环每次读取一行后，多行定义多个变量每次赋值一个。

```bash
#!/bin/bash
# auther: sds

data_file="/root/example.txt"

while read data
do

    database=$(echo "${data}" |awk '{print $1}')
    table=$(echo "${data}" |awk '{print $2}')
    line=$(echo "${data}" |awk '{print $3}')

    echo '{"database":"'"${database}"'","table":"'"${table}"'","line":'"${line}"'}'

done <${data_file}
```

　　执行输出

```
[root@imzcy ~]# sh test-01.sh
{"database":"db001","table":"order","line":50000}
{"database":"db001","table":"logistics","line":50000}
{"database":"db001","table":"sms","line":60000}
{"database":"db002","table":"pay","line":10000}
{"database":"db002","table":"history","line":300000}
[root@imzcy ~]#
```

　　‍

#### 使用eval命令直接赋值多个变量

　　使用一行 eval 命令实现上面多行的效果

```bash
#!/bin/bash
# auther: sds

data_file="/root/example.txt"

while read data
do

    eval $(echo "${data}" |awk '{printf("database=%s; table=%s; line=%s",$1,$2,$3)}')

    echo '{"database":"'"${database}"'","table":"'"${table}"'","line":'"${line}"'}'

done <${data_file}

```

　　执行输出

```
[root@imzcy ~]# sh test-02.sh
{"database":"db001","table":"order","line":50000}
{"database":"db001","table":"logistics","line":50000}
{"database":"db001","table":"sms","line":60000}
{"database":"db002","table":"pay","line":10000}
{"database":"db002","table":"history","line":300000}
[root@imzcy ~]#
```

　　‍

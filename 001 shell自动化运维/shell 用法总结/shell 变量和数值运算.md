# shell 变量和数值运算

## 1.变量的定义、赋值

### 将命令输出赋值变量

```
var=`shell命令`  # `是反引号
var=$(shell命令) 
var='
line 1
line 2
line 3
'
```

### 读取标准输入赋值给变量

```
read -p "请输入一个字符： " key
echo $key
```

## 2.变量的引用

### 基础引用

```
$var
${var}
${var:defaultvalue}
```

### 变量的引用默认值

|表达式|含义|
| -----------------| -----------------------------------------------------------|
|${var_DEFAULT}|如果var没有被声明, 那么就以$DEFAULT作为其值|
|${var=DEFAULT}|如果var没有被声明, 那么就以$DEFAULT作为其值|
|${var:-DEFAULT}|如果var没有被声明, 或者其值为空, 那么就以$DEFAULT作为其值|
|${var:=DEFAULT}|如果var没有被声明, 或者其值为空, 那么就以$DEFAULT作为其值|
|${var+OTHER}|如果var声明了, 那么其值就是$OTHER, 否则就为null字符串|
|${var:+OTHER}|如 果var被设置了, 那么其值就是$OTHER, 否则就为null字符串|
|${var?ERR_MSG}|如果var没 被声明, 那么就打印$ERR_MSG|
|${var:?ERR_MSG}|如果var没 被设置, 那么就打印$ERR_MSG|
|${!varprefix*}|匹配之前所有以varprefix开头进行声明的变量|
|${!varprefix@}|匹配之前所有以varprefix开头进行声明的变量|

### 用变量值作为新变量名

```
$ name=test
$ test_p=123
$ echo `eval echo '$'"$name""_p"`
123
```

或者

```
$ var="world"
$ declare "hello_$var=value"
$ echo $hello_world
value
```

或者（ `bash`​ 4.3+）

```
$ hello_world="value"
$ var="world"
$ declare -n ref=hello_$var
$ echo $ref
value
```

或者

```
$ hello_world="value"
$ var="world"
$ ref="hello_$var"
$ echo ${!ref}
value
```

```
name_1=aa
name_2=bbb
for i in ${!name_@} ;do  #  ${!name_@}仅限在sh、 bash中使用
    echo "\$i为当前变量名：" $i
    echo "\${!i}当前变量名的值：" ${!i}
    echo "\${i/name/name_var}可替换当前变量名中的name为name_var: " ${i/name/name_var}
done
```

## 3.变量的数值运算

### 加减乘除

```
#样本数据
a=120
b=110

((c=$a+$b))    #结果：230
((d=$a-$b))    #结果：10
((e=$a*$b))    #结果：13200
((f=$a/$b))    #结果：1

c=$((a+b))     #结果：220
d=$((a-b))     #结果：20
e=$((a*b))     #结果：12000
f=$((a/b))     #结果：1

c=`expr a+b`        #结果：220
d=`expr $a - $b`    #结果：20
e=`expr $a \* $b`   #结果：12000
f=`expr $a / $b`    #结果：1
```

### 自增

```
a=1

#第一种整型变量自增方式
a=$(($a+1))
echo $a

#第二种整型变量自增方式
a=$[$a+1]
echo $a

#第三种整型变量自增方式
a=`expr $a + 1`
echo $a

#第四种整型变量自增方式
let a++
echo $a

#第五种整型变量自增方式
let a+=1
echo $a

#第六种整型变量自增方式
((a++))
echo $a
```

## 4.数值变量的判断

```
-gt    大于，如[ $a -gt $b ]
-lt    小于，如[ $a -lt $b ]
-eq    等于，如[ $a -eq $b ]
-ne    不等于，如[ $a -ne $b ]
-ge    大于等于，如[ $a -ge $b ]
le     小于等于 ，如 [ $a -le $b ]
<      小于(需要双括号),如:(($a < $b))
<=     小于等于(需要双括号),如:(($a <= $b))
>      大于(需要双括号),如:(($a > $b))
>=     大于等于(需要双括号),如:(($a >= $b))
```

## 5.变量的处理

### 变量输出多行变一行并追加字符

```
$ echo $a

1

2

3

$ echo $a | tr '\n' ',’

1,2,3,
```

### 位数截取

```
a=1110418197875

# 截去后三位,要求只取"1110418197875"

# 方式1: 数值运算
b=$((a/1000))

# 方式2：字符截取（将数值变量当成字符串来处理）
c=${a:0:-3}
```

## 6.多行文本变量

### 定义赋值、引用、输出

```
tests='a1a
b2b
c3c
'

echo $tests 
# a1a b2b c3c

echo "$tests"
# a1a
# b2b
# c3c

# 总共是有四行的输出，最后一个是空行
```

### 遍历循环

```
# zsh中的方法
for test in ${(f)tests}; do
  echo "测试: "$test
done

# bash中的方法
for test in ${tests}; do
  echo "测试: $test"
done
```

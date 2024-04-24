# shell 选择和判断

面向过程的语句结构：

* 顺序结构：逐条运行
* 选择结构：两个或以上的,满足条件时只会执行其中一个满足条件的分支
* 循环结构：某循环体需要执行多次

‍

# If语句分支

## if单分支

```bash
if [[ condition1 ]] ; then
    # statements1
    # statements2
    # ...........
fi
```

## if双分支

```bash
if [[ condition1 ]] ; then
    # statements1
    # statements2
else 
    # statements3
	# ..........
fi
```

## if多分支

```bash
if [[ condition1 ]] ; then
    # statements1
    # statements2
elif [[ condition2 ]] ; then
    # statements3
elif [[ condition3 ]] ; then
    # statements4
else 
    # statements5
	# ..........
fi
```

## if 常用判断条件

```bash
[ -a FILE ] #如果 FILE 存在则为真
[ -d FILE ] #如果 FILE 存在且是一个目录则返回为真
[ -e FILE ] #如果 指定的文件或目录存在时返回为真
[ -f FILE ] #如果 FILE 存在且是一个普通文件则返回为真
[ -r FILE ] #如果 FILE 存在且是可读的则返回为真
[ -w FILE ] #如果 FILE 存在且是可写的则返回为真（一个目录为了它的内容被访问必然是可执行的）
[ -x FILE ] #如果 FILE 存在且是可执行的则返回为真

[ -b FILE ] #如果 FILE 存在且是一个块文件则返回为真
[ -c FILE ] #如果 FILE 存在且是一个字符文件则返回为真
[ -g FILE ] #如果 FILE 存在且设置了SGID则返回为真
[ -h FILE ] #如果 FILE 存在且是一个符号符号链接文件则返回为真（该选项在一些老系统上无效）
[ -k FILE ] #如果 FILE 存在且已经设置了冒险位则返回为真
[ -p FILE ] #如果 FILE 存并且是命令管道时返回为真
[ -s FILE ] #如果 FILE 存在且大小非0时为真则返回为真
[ -u FILE ] #如果 FILE 存在且设置了SUID位时返回为真
[ -O FILE ] #如果 FILE 存在且属有效用户ID则返回为真
[ -G FILE ] #如果 FILE 存在且默认组为当前组则返回为真（只检查系统默认组）
[ -L FILE ] #如果 FILE 存在且是一个符号连接则返回为真
[ -N FILE ] #如果 FILE 存在 and has been mod如果ied since it was last read则返回为真
[ -S FILE ] #如果 FILE 存在且是一个套接字则返回为真
[ FILE1 -nt FILE2 ] #如果 FILE1 比 FILE2 新, 或者 FILE1 存在但是 FILE2 不存在则返回为真
[ FILE1 -ot FILE2 ] #如果 FILE1 比 FILE2 老, 或者 FILE2 存在但是 FILE1 不存在则返回为真
[ FILE1 -ef FILE2 ] #如果 FILE1 和 FILE2 指向相同的设备和节点号则返回为真

######################### 字符串判断 #########################
[[ -z STRING ]] #如果STRING的长度为零则返回为真，即空是真
[[ -n STRING ]] #如果STRING的长度非零则返回为真，即非空是真
[[ STRING1 ]]　 #如果字符串不为空则返回为真,与-n类似
[[ STRING1 == STRING2 ]] #如果两个字符串相同则返回为真
[[ STRING1 != STRING2 ]] #如果字符串不相同则返回为真
[[ STRING1 < STRING2 ]]  #如果 “STRING1”字典排序在“STRING2”前面则返回为真
[[ STRING1 > STRING2 ]]  #如果 “STRING1”字典排序在“STRING2”后面则返回为真

######################### 数值判断 #########################
[ INT1 -eq INT2 ] #INT1和INT2两数相等返回为真 ,=
[ INT1 -ne INT2 ] #INT1和INT2两数不等返回为真 ,<>
[ INT1 -gt INT2 ] #INT1大于INT2返回为真 ,>
[ INT1 -ge INT2 ] #INT1大于等于INT2返回为真,>=
[ INT1 -lt INT2 ] #INT1小于INT2返回为真 ,<
[ INT1 -le INT2 ] #INT1小于等于INT2返回为真,<=

######################### 逻辑判断 #########################
[ ! EXPR ] #逻辑非，如果 EXPR 是false则返回为真
[ EXPR1 -a EXPR2 ] #逻辑与，如果 EXPR1 and EXPR2 全真则返回为真
[ EXPR1 -o EXPR2 ] #逻辑或，如果 EXPR1 或者 EXPR2 为真则返回为真
[ ] || [ ] #用OR来合并两个条件
[ ] && [ ] #用AND来合并两个条件

```

* Test 和 [ ] ：是bash 的内部命令，可用的比较运算符只有==和!=，两者都是用于字符串比较的，不可用于整数比较，整数比较只能使用-eq，-gt这种形式。无论是字符串比较还是整数比较都不支持大于号小于号。

* [[ ：是 bash 程序语言的关键字。并不是一个命令，[[ ]] 结构比[ ]结构更加通用，能够防止脚本中的许多逻辑错误。比如，&&、||、<和> 操作符能够正常存在于[[ ]]条件判断结构中，

* 单小括号 ()：

  命令组，括号中的命令将会新开一个子shell顺序执行，所以括号中的变量不能够被脚本余下的部分使用。括号中多个命令之间用分    号隔开  
  命令替换，等同于cmd，shell扫描一遍命令行，发现了$(cmd)结构，便将$(cmd)中的cmd执行一次，得到其标准输出，再将此输  出放到原来命令。  
  用于初始化数组，如：array=(a b c d)

* 双小括号 (( ))：

  整数扩展。这种扩展计算是整数型的计算，不支持浮点型。  
  只要括号中的运算符、表达式符合C语言运算规则，都可用在$((exp))中，甚至是三目运算符。  
  单纯用 (( )) 也可重定义变量值，比如 a=5; ((a++)) 可将 $a 重定义为6  
  常用于算术运算比较，双括号中的变量可以不使用$符号前缀。

‍

‍

# select语句分支

​`select`​ 表达式是 bash 的一种扩展应用，擅长于交互式场合。用户可以从一组不同的值中进行选择

语法格式

```bash
select varname in "string1" "string2" ; do
    # statements1
    # statements2
    # .....
done
```

示例

```bash
#!/bin/bash
echo "What is your favourite OS?"
select var in "Linux" "Gnu Hurd" "Free BSD" "Other" ; do
	break ;
done
echo "You have selected $var"
```

运行结果

```bash
What is your favourite OS?
1) Linux
2) Gnu Hurd
3) Free BSD
4) Other
#? 1
You have selected Linux
```

# case语句分支

语法格式

```
case $1 in
    pattern1)
        # statements1
        ;;
    pattern2)
        # statements2
        ;;
    	   # ..........
    patternN)
        # statementsN
        ;;
esac
```

* case支持的globbing

  ```bash
  *    # 任意长度的任意字符	
  ?    # 任意单个字符
  []   # 指定范围内的单个字符
  a|b  # a或者b
  ```

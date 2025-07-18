

# 条件测试语句

- 语法格式

  - 格式1     `test expression`​
  - 格式2    `[ expression ]`​
  - 格式3     `[[ expression ]]`​

​`[`​ 是一条命令，它与 `test`​ 是等价的。在其中的表达式应是它的命令行参数，所以字符串比较操作符  `>`​ 与 `<`​ 必须转义，否则就变成 重定向向操作符了

```bash
[user1@study ~]$ [ 3 \> 2 ] && echo yes || echo no
yes
[user1@study ~]$ [ 1 \> 2 ] && echo yes || echo no 
no
[user1@study ~]$
```

​`[[]]`​ 是是扩展的 `test`​ 命令，用 `[[]]`​ 测试结构比用 `[]`​ 更能防止脚本里的许多逻辑错误。`&&`​ 、`||`​、 `<`​、`>`​  操作符能够正常存在于 `[[ ]]`​ 中，但不能在  `[]`​ 中出现。

```bash
[user1@study ~]$ [[ "2" = "2" && "3" = "3" ]] && echo yes || echo no
yes
[user1@study ~]$ [[ "2" = "2" && "3" = "5" ]] && echo yes || echo no 
no
[user1@study ~]$ [ "2" = "2" && "3" = "5" ] && echo yes || echo no  
-bash: [: missing `]'
no
[user1@study ~]$ 
[user1@study ~]$ [[ 3 > 2 ]] && echo yes || echo no
yes
[user1@study ~]$
```

在 `[[]]`​ 中可以使用通配符进行模式匹配

```bash
[user1@study ~]$ [[ abc123 = abc* ]] && echo yes || echo no
yes
[user1@study ~]$ [[ ac123 = abc* ]] && echo yes || echo no 
no
[user1@study ~]$
```

在 `[[]]`​ 中使用 `=~`​ 时支持 shell 的正则表达式

```bash
[user1@study ~]$ [[ '12345' =~ [0-9]{5} ]] && echo yes || echo no
yes
[user1@study ~]$ [[ '123afsa' =~ [0-9]{5} ]] && echo yes || echo no  
no
[user1@study ~]$
```

需要注意，不管是 `[[]]`​ 还是 `[]`​ ，最里面的中括号旁边都必须保留一个空格，否则是语法错误

# 算术运算符

|运算符|说明||
| --------| -----------------------------------------| ------------------------|
|+|加法|​`expr b`​|
|-|减法|​`expr b`​|
|*|乘法|​`expr b`​|
|/|除法|​`expr b`​|
|%|取余|​`expr b`​|
|=|赋值|a=$b 将变量b的值赋给 a|
|==|相等。用于比较两个整数，相同则返回 true|[ $a ==$b ] 返回 false。|
|!=|不等。用于比较两个整数，不同则返回 true|[ $a !=$b ] 返回 true。|

# 算术运算

要对整数进行关系运算可以下面几种方式实现

​`let`​ 算术运算表达式

```bash
[user1@study ~]$ a=1; b=2      
[user1@study ~]$ let c=${a}+${b}; echo $c
3
[user1@study ~]$ let c+=1; echo $c
4
[user1@study ~]$ let c=c+b; echo $c  # 等同于 ((c=c+b))，但后者效率更高
6
[user1@study ~]$
```

​`$[算术运算表达式]`​

```bash
[user1@study ~]$ a=1; b=2
[user1@study ~]$ c=$[$a+$b]
[user1@study ~]$ echo $c
3
[user1@study ~]$
```

​`$((算术运算表达式))`​

```bash
[user1@study ~]$ a=1; b=2
[user1@study ~]$ c=$(($a+$b))
[user1@study ~]$ echo $c
3
[user1@study ~]$
```

​`expr`​ 算术运算表达式，要注意 `expr`​ 的表达式中各操作符及运算符之间要有空格，且要使用命令替换

```bash
[user1@study ~]$ a=1; b=2
[user1@study ~]$ c=$(expr $a + $b)
[user1@study ~]$ echo $c
3
[user1@study ~]$
```

也可以使用 shell 的算术运算符 `(())`​ 进行计算，事实上 `(())`​ 比 `let`​、`expr`​ 会更高效，最建议使用这种方式

```bash
[user1@study ~]$ a=1; b=2   
[user1@study ~]$ (( sum=a+b ))
[user1@study ~]$ echo ${sum}
3
[user1@study ~]$
```

# 关系运算符

关系运算符只支持整数，不支持字符串，除非字符串的值是整数

|运算符|说明|举例|
| --------| -----------------------------------------------------| -------|
|-eq|测试两个整数是否相等，相等返回 true|[ $a -eq$b ]|
|-ne|测试两个整数是否相等，不相等返回 true|[ $a -ne$b ]|
|-gt|测试左边的整数是否大于右边的，如果是，则返回 true|[ $a -gt$b ]|
|-lt|测试左边的整数是否小于右边的，如果是，则返回 true|[ $a -lt$b ]|
|-ge|测试左边的整数是否大等于右边的，如果是，则返回 true|[ $a -ge$b ]|
|-le|测试左边的数是否小于等于右边的，如果是，则返回 true|[ $a -le$b ]|

# 逻辑运算符

|运算符|说明|举例|
| --------| ---------------------------------------------------| ------------------------|
|!|非运算，表达式为 true 则返回 false，否则返回 true|[ ! 0 -ne 0 ] 返回true|
|-o|或运算，有一个表达式为 true 则返回 true|[ $a -lt 20 -o$b -gt 100 ]|
|-a|与运算，两个表达式都为 true 才返回 true|[ $a -lt 20 -a$b -gt 100 ]|

​`[ expression1 ] && [ expression2 ]`​  等价于 `[ expression1 -a expression2 ]`​

```bash
[user1@study ~]$ [ "abc" = "abc" -a "bcd" = "efg" ] && echo yes || echo no
no
[user1@study ~]$ [ "abc" = "abc" ] && [ "bcd" = "efg" ] && echo yes || echo no   
no
[user1@study ~]$
```

# 字符串运算符

|运算符|说明|举例|
| --------| ----------------------------------------------| -------------------------|
|>|测试前面字符串的ASCII码比后面的大|[[ “abc” > “ABC” ]]|
|<|测试前面字符串的ASCII码比后面的小|[[ “abc” < “ABC” ]]|
|=|检测两个字符串是否相等，也可使用==|[ “$a” = “$b” ]|
|!=|检测两个字符串是否相等，不相等返回 true|[ “$a” != “$b” ]|
|=~|左侧的字符串是否能被右侧的正则表达式模式匹配|“$char” =~ pattern|
|-z|检测字符串长度是否为0，为0返回 true|[ -z “$a” ] 或 test -z “$a”|
|-n|检测字符串长度是否为0，不为0返回 true|[ -n “$a” ] 或 test -n “$a”|
|str|检测字符串是否不为空，不为空返回 true|[ “$a” ] 或 test “$a”|

从 Bash 3.2 版本开始，正则表达式和globbing表达式都不能用引号包裹。若表达式里有空格，则可以把它存储到一个变量里：

```bash
a="a b+"
[[ "a bbb" =~ $a ]] 	# true (regex比较)
```

做个练习，比较一下不同的运算符及其作用

```bash
a="abc123"
[ "$a" == abc* ]        # false (字面比较)
[ "$a" == "abc*" ]	# false (字面比较)
[[ "$a" == abc* ]]	# true (globbing比较)
[[ "$a" == "abc*" ]] 	# false (字面比较)
[[ "$a" =~ [abc]+[123]+ ]] # true (regex比较)
[[ "$a" =~ "abc*" ]]	# false (字面比较)
```

# 文件测试运算符

|运算符|说明|举例|
| -----------| --------------------------------------------------------| -----------------|
|-a file|测试文件（包括目录）是否存在；同-e；-a处于弃用状态|[ -a $file ]|
|-b file|测试文件是否是块设备文件|[ -b $file ]|
|-c file|测试文件是否是字符设备文件；|[ -b $file ]|
|-d file|测试文件是否是目录；|[ -d $file ]|
|-e file|测试文件（包括目录）是否存在；|[ -e $file ]|
|-f file|测试文件是否是普通文件（既不是目录，也不是设备文件）；|[ -f $file ]|
|-g file|测试文件是否设置了 SGID 位；|[ -g $file ]|
|-G file|文件的group-id是否与你的相同|[ -G $file ]|
|-h file|测试文件是否是符号链接文件；同-L；|[ -h /bin/awk ]|
|-k file|测试文件是否设置了粘着位(Sticky Bit)；|[ -k $file ]|
|-L file|测试文件是否是符号链接文件；同-h；|[ -h /bin/awk ]|
|-N file|测试文件从文件上一次被读取到现在为止，是否被修改过|[ -N $file ]|
|-O file|测试文件的owner是否为当前用户|[ -O $file]|
|-p file|测试文件是否是管道文件；|[ -p $file ]|
|-r file|测试文件是否可读；|[ -r $file ]|
|-s file|测试文件是否存在且不为空（文件大小是否大于0）。|[ -s $file ]|
|-u file|测试文件是否设置了 SUID 位；|[ -u $file ]|
|-w file|测试文件是否可写；|[ -w $file ]|
|-x file|测试文件是否可执行；|[ -x $file ]|
|f1 -nt f2|测试文件f1是否比文件f2新||
|f1 -ot f2|测试文件f1是否比文件f2旧||
|f1 -ef f2|测试文件f1和文件f2是否是相同文件的硬链接||

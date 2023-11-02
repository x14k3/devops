# shell 三剑客

# grep

grep 命令用于查找文件里符合条件的字符串的一行打印出来。

grep命令家族有 grep、egrep、fgrep 三个子命令，适用于不通的场景，具体如下：

```bash
1.grep  原生的grep命令，使用“标准正则表达式”作为匹配标准
2.egrep 扩展的grep命令，相当于 $(grep -E) ，使用“扩展正则表达式”作为匹配标准
3.fgrep 简化版的grep命令，不支持正则表达式，但搜索速度快，系统资源使用率低
```

## 参数说明

```bash
##########  OPTIONS 部分  ##########
-v  # 显示没有被匹配到的行   [ps -ef|grep frps | grep -v grep]
-i  # 忽略大小写     [grep 'tEst' test.txt ]
-n  # 显示匹配的行号 [grep -n 'test' test.txt ]
-c  # 统计匹配的行数 [grep -c 'test' test.txt ]
-q  # 静默模式，不输出任何信息
-e  # 实现多个选项间的逻辑or关系
-w  # 只显示全字符合的列。
-f  # 指定范本文件，其内容有一个或多个范本样式，让grep查找符合范本条件的文件内容，格式为每一列的范本样式。
-o  # 只输出文件中匹配到的部分。
-E  # 使用扩展的正则表达式，egrep = grep -E
-A  # 显示被匹配到的行和后面的几行 [ cat test.txt |grep  ' ' -A 1]
-B  # 显示被匹配到的行和前面的几行 [ cat test.txt |grep  ' ' -A 1]
-C  # 显示被匹配到的前后各几行
```

## 案例

```bash
# 显示paswwd文件除root用户的所有行
cat /etc/passwd|grep -v root
```

---

# sed

主要用来自动编辑一个或多个文件、简化对文件的反复操作、编写转换程序等。**它一次处理一行内容**。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”（pattern space），接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。然后读入下行，执行下一个循环。

**基本语法**
`sed [option]  'script'  [input file] ...`

## 参数说明

```bash
-n  # 使用安静`silent`模式。在一般`sed`的用法中，所有来自`stdin`的内容一般都会被列出到屏幕上。但如果加上`-n`参数后，则只有经过`sed`特殊处理的那一行(或者动作)才会被列出来  
-e  # 直接在指令列模式上进行 `sed` 的动作编辑 
-f  # 直接将 `sed` 的动作写在一个文件内，`-f filename`则可以执行`filename`内的`sed`命令  
-r  # 让`sed`命令支持扩展的正则表达式(默认是基础正则表达式)
-i  # 直接修改读取的文件内容，而不是由屏幕输出
--version-V # 显示版本信息
```

## 指令说明

```bash
##### 地址定位
n   # 指定的第n行
^   # 行首
$   # 行尾
/pattern/  # 被此模式所能够匹配到的每一行
n,m   # 定位从第n行开始至第m行（都是闭区间）
n,+k  # 定位从第n行开始，包括往后的k行
n,/pattern/   # 定位从第n行开始，至指定模式匹配到的那一行
/pattern1/,/pattern2/   # 定位从 pattern1 模式匹配开始，直到 pattern2 模式匹配之间的范围


##### 动作
a\  # 追加行(行后新增一行)，`a\`的后面跟上字符串`s`(多行字符串可以用`\n`分隔)，则会在当前选择的行的后面都加上字符串`s`  
c\  # 替换行，`c\`后面跟上字符串`s`(多行字符串可以用`\n`分隔)，则会将当前选中的行替换成字符串`s`   
i\  # 插入行(行前插入一行)，`i\`后面跟上字符串`s`(多行字符串可以用`\n`分隔)，则会在当前选中的行的前面都插入字符串`s`  
d   # 删除行`delete`，该命令会将当前选中的行删除 
p   # 打印`print`，该命令会打印当前选择的行到屏幕上  
y   # 替换字符，通常`y`命令的用法是这样的：`y/Source-chars/Dest-chars/`，分割字符`/`可以用任意单字符代替，用`Dest-chars`中对应位置的字符替换掉`Soutce-chars`中对应位置的字符  
s   # 替换字符串，通常`s`命令的用法是这样的：`1,$s/Regexp/Replacement/Flags`，分隔字符`/`可以用其他任意单字符代替，用`Replacement`替换掉匹配字符串

```

## 案例

```bash
# 最后一行新增一行字符串
sed '$a\google' test.txt 
# 每行行尾新增字符串
sed 's/$/google/' test.txt 
# 每行行首增加字符串
sed 's/^/google/' test.txt 
# 第一行前新增一行字符串
sed '1i\google' test.txt 
# 删除特定行-SET开头的所有行
sed -i '/^SET/d' test.txt 
# 删除所有空行
sed '/^\s*$/d' test.txt 
```

---

# awk

awk是一种编程语言，用于在linux/unix下对文本和数据进行处理。数据可以来自标准输入(stdin)、一个或多个文件，或其它命令的输出。它支持用户自定义函数和动态正则表达式等先进功能，它在命令行中使用，但更多是作为脚本来使用。

**基本语法**
`awk [选项参数] 'script' var=value file(s)`

## 参数说明

```bash
-F   # 指明输入字段的分隔符
-v   # 赋值一个用户定义变量  var=value
-f   # scripfile 从脚本文件中读取awk命令
```

## 语法结构

`awk '{pattern + action}' {filenames}`

awk是由_pattern_和_action_组成， pattern 表示 AWK 在数据中查找的内容，而 action 是在找到匹配内容时所执行的一系列命令.

pattern 可以是如下几种或者什么都没有（全部匹配）：

- /正则表达式/：使用通配符的扩展集。
- 关系表达式：使用运算符进行操作，可以是字符串或数字的比较测试。
- 模式匹配表达式：用运算符~（匹配）和~!（不匹配）。
- BEGIN语句块、pattern语句块、END语句块：参见awk的工作原理

action 由一个或多个命令、函数、表达式组成，之间由换行符或分号隔开，并位于大括号内，可以是如下几种，或者什么都没有（print）

- 变量或数组赋值
- 输出命令 print
- 内置函数
- 控制流语句

## awk常见应用和工作原理

`awk 'BEGIN{ commands } pattern{ commands } END{ commands }'`

- 首先执行 `BEGIN {commands}` 内的语句块，注意这只会执行一次，经常用于变量初始化，头行打印一些表头信息，只会执行一次，在通过stdin读入数据前就被执行；
- 从文件内容中读取一行，注意**awk是以行为单位处理的，每读取一行使用** **`pattern{commands}`**  **循环处理** 可以理解成一个for循环，这也是最重要的部分；
- 最后执行 `END{ commands }` ,也是执行一次，在所有行处理完后执行，一帮用于打印一些统计结果。

```bash
[root@192 ~]# awk -F : 'BEGIN {print "username,shell"} {print $1","$7} END {print "test"}' /etc/passwd
username,shell
root,/bin/bash
bin,/sbin/nologin
daemon,/sbin/nologin
shutdown,/sbin/shutdown
mail,/sbin/nologin
nobody,/sbin/nologin
sshd,/sbin/nologin
test
[root@192 ~]# 
```

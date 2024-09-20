# sed

#### 语法

```bash
sed [options] ‘{command}[flags]’ [filename]
# 中括号内容必有 大括号内容可有可无
```

#### 参数

```bash
命令选项
-e script 将脚本中指定的命令添加到处理输入时执行的命令中 多条件，一行中要有多个操作
-f script 将文件中指定的命令添加到处理输入时执行的命令中
-n 抑制自动输出
-i 编辑文件内容
-i.bak 修改时同时创建.bak备份文件。
-r 使用扩展的正则表达式
! 取反 （跟在模式条件后与shell有所区别）

sed常用内部命令
a 在匹配后面添加
i 在匹配前面添加
p 打印
d 删除
s 查找替换
c 更改
y 转换 N D P

flags
数字 表示新文本替换的模式
g： 表示用新文本替换现有文本的全部实例
p： 表示打印原始的内容
w filename: 将替换的结果写入文件
```

#### [sed](https://so.csdn.net/so/search?q=sed&spm=1001.2101.3001.7020)结合正则使用

> sed 选项 ‘[sed命令](https://so.csdn.net/so/search?q=sed%E5%91%BD%E4%BB%A4&spm=1001.2101.3001.7020)或者正则表达式或者地址定位’ 文件名

* 定址用于决定对哪些行进行编辑。地址的形式可以是数字、正则表达式、或二者的结合。
* 如果没有指定地址，sed将处理输入文件的所有行。

|正则|说明|备注|
| ---------------| -------------------------------------------------------------| ---------------------------------|
|/key/|查询包含关键字的行|sed -n '/root/p' 1.txt|
|/key1/,/key2/|匹配包含两个关键字之间的行|sed -n '/^adm/,/^mysql/p' 1.txt|
|/key/,x|从匹配关键字的行开始到文件第x行之间的行（包含关键字所在行）|sed -n '/^ftp/,7p'|
|x,/key/|从文件的第x行开始到与关键字的匹配行之间的行||
|x,y!|不包含x到y行||
|/key/!|不包括关键字的行|sed -n '/bash$/!p' 1.txt|

#### 使用实例

　　对sed命令大家要注意，sed所做的修改并不会直接改变文件的内容，而是把修改结果只显示到屏幕上，除非使用“-i”选项才会直接修改文件。

　　提取行数据

　　我们举几个例子来看看sed命令到底是干嘛的。假设我想查看下student.txt的第二行，那么就可以利用“p”动作了:

```bash
[root@localhost ~]$ sed '2p' student.txt

ID Name php Linux MySQL Average
1 AAA 66 66 66 66
2 BBB 77 77 77 77
3 CCC 88 88 88 88
```

　　指定输出某行，使用-n选项

```bash
[root@localhost ~]$ sed -n '2p' student.txt
1 AAA 66 66 66 66
```

　　删除行数据

```baash
sed '2,4d' student.txt
```

　　追加插入行数据

```bash
sed '2a hello' student.txt
```

　　“a”会在指定行后面追加入数据，如果想要在指定行前面插入数据，则需要使用“i”动作:

```ruby
sed '2i hello world' student.txt
```

　　如果是想追加或插入多行数据，除最后一行外，每行的末尾都要加入“\\”代表数据未完结。再来看看“-n”选项的作用:

```ruby
[root@localhost ~]$ sed -n '2i hello world' student.txt
```

　　替换行数据

　　“-n”只查看sed命令操作的数据，而不是查看所有数据。
再来看看如何实现行数据替换，假设AAA的成绩太好了，我实在是不想看到他的成绩刺激我，那就可以使用"c"动作:

```csharp
[root@localhost ~]$ cat student.txt | sed '2c No such person'
```

　　sed命令默认情况是不会修改文件内容的，如果我确定需要让 sed命令直接处理文件的内容，可以使用“-i”选项。不过要小心啊，这样非常容易误操作，在操作系统文件时请小心谨慎。可以使用
这样的命令:

```ruby
[root@localhost ~]$ sed -i '2c No such person' student.txt
```

　　字符串替换

　　“c”动作是进行整行替换的，如果仅仅想替换行中的部分数据，就要使用“s”动作了。g 使得 sed 对文件中所有符合的字符串都被替换, 修改后内容会到标准输出，不会修改原文件。

```ruby
[root@localhost ~]$ sed 's/旧字串/新字串/g' 文件名

[root@localhost ~]$ sed '行范围s/旧字串/新字串/g' 文件名
```

　　替换的格式和vim非常类似，假设我觉得我自己的PHP成绩太低了，想作弊给他改高点，就可以这样来做:

```ruby
[root@localhost ~]$ sed '3s/74/99/g' student.txt
```

　　这样看起来就比较爽了吧。如果我想把AAA老师的成绩注释掉，让他不再生效。可以这样做:

```ruby
[root@localhost ~]$ sed '2s/^/#/g' student.txt
```

　　在sed中只能指定行范围，所以很遗憾我在他们两个的中间，不能只把他们两个注释掉，那么我们可以这样:

```ruby
[root@localhost ~]$ sed -e 's/AAA//g ; s/BBB//g' student.txt
```

　　“-e”选项可以同时执行多个sed动作，当然如果只是执行一个动作也可以使用“-e”选项，但是这时没有什么意义。还要注意，多个动作之间要用“;”号或回车分割，例如上一个命令也可以这样写:

```swift
[root@localhost ~]$ sed -e 's/Liming

>s/Tg
```

#### 其他实例

```cobol
1、正则表达式必须以”/“前后规范间隔

例如：sed '/root/d' file

例如：sed '/^root/d' file

2、如果匹配的是扩展正则表达式，需要使用-r选来扩展sed

grep -E

sed -r

+ ? () {n,m} | \d

注意：

在正则表达式中如果出现特殊字符(^$.*/[]),需要以前导 "\" 号做转义

eg：sed '/\$foo/p' file

3、逗号分隔符

例如：sed '5,7d' file 删除5到7行

例如：sed '/root/,/ftp/d' file

删除第一个匹配字符串"root"到第一个匹配字符串"ftp"的所有行本行不找 循环执行

4、组合方式

例如：sed '1,/foo/d' file 删除第一行到第一个匹配字符串"foo"的所有行

例如：sed '/foo/,+4d' file 删除从匹配字符串”foo“开始到其后四行为止的行

例如：sed '/foo/,~3d' file 删除从匹配字符串”foo“开始删除到3的倍数行（文件中）

例如：sed '1~5d' file 从第一行开始删每五行删除一行

例如：sed -nr '/foo|bar/p' file 显示配置字符串"foo"或"bar"的行

例如：sed -n '/foo/,/bar/p' file 显示匹配从foo到bar的行

例如：sed '1~2d' file 删除奇数行

例如：sed '0-2d' file 删除偶数行 sed '1~2!d' file

5、特殊情况

例如：sed '$d' file 删除最后一行

例如：sed '1d' file 删除第一行

6、其他：

sed 's/.//' a.txt 删除每一行中的第一个字符

sed 's/.//2' a.txt 删除每一行中的第二个字符

sed 's/.//N' a.txt 从文件中第N行开始，删除每行中第N个字符（N>2）

sed 's/.$//' a.txt 删除每一行中的最后一个字符
```

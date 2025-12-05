

有个软件叫`HLAreporter`​，它真的搞人，基本上就是shell脚本联合起来的，关键是居然还有各种小问题，其中之一就是关于文件名和目录名这个，导致程序只能在软件本身的目录运行，然后各种bug，于是我就修改了一部分，里面对文件名和目录名进行了处理。通常的操作是由路径中提取出文件名，从路径中提取出目录名，提取文件后缀名，相对路径转换为绝对路径等等。

下面介绍几种方法进行相关的操作，这些我都使用过的。 首先假设我的文件全称：`/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh`​.

## 获取文件名

### 使用`${}`​，`${str##*/}`​

这个命令的作用就是去掉变量`str`​从左边算起的最后一个`/`​字符及其左边的内容，返回的值是从左边算起的最后一个`/`​（不含该字符）的右边的所有内容，例子很简单：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
file=${str##*/}
echo $file
HLAreporter.sh ## 运行结果
```

### 使用awk语句

因为在ubuntu下面，路径都是以`/`​为隔开的，那么我们就以`/`​为分隔符，然后把最后部分打印，赋值，例子如下：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
file=`echo $str | awk -F "/" '{print $NF}'`
echo $file
HLAreporter.sh
```

### 使用官方函数`basename`​

​`bash shell`​本身提供了`basename`​命令，可以直接获取路径名最后的文件名，实现代码如下：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
file=$(basename $str)
echo $file
HLAreporter.sh
```

## 后缀和文件名分开

### 使用`${}`​

在这里分别使用`/`​和`.`​作为分隔符来进行处理，代码如下：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
file=${str##*/}
filename=${file%.*}
suffix=${file##*.}
echo $file, $filename, $suffix
HLAreporter.sh, HLAreporter, sh

str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103.tar.gz
file=${str##*/}
filename=${file%%.*}
suffix=${file#*.}
echo $file, $filename, $suffix
HLAreporter.v103.tar.gz, HLAreporter, v103.tar.gz
```

用的是Shell的参数扩展(Parameter Extension)功能，解释如下：

```
${str##*/}: 从左边开始删除str中最大匹配(longest matching pattern) */ 的字符串
${str%/*}：从右边开始删除str中最小匹配(shortest matching pattern) /* 的字符串
${file##*.}：从左边开始删除file中最大匹配(longest matching pattern) *. 的字符串
${file%.*}：从右边开始删除file中最小匹配(shortest matching pattern) .* 的字符串
${file%%.*}：从右边开始删除file中最大匹配(longest matching pattern) .* 的字符串
${file#*.}：从左边开始删除file中小匹配(shortest matching pattern) *. 的字符串
#：表示从左边算起第一个
%：表示从右边算起第一个
##：表示从左边算起最后一个
%%：表示从右边算起最后一个
换句话来说，＃总是表示左边算起，％总是表示右边算起。
```

参数扩展有多种形式，在shell编程中可以用作参数的拼接，字符串的替换，参数列表截取，变量初值等操作，这里不再详述，请参考右边的功能列表和[官方文档](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html).

#### 参数扩展功能列表

|**参数形式**|**扩展后**|
| --------------------------| ---------------------------------------------------------------------|
|x{y,z}|xy xz|
|${x}{y, z}|${x}y${x}z|
|${x}{y,$z}|${x}y${x}${z}|
|${param#pattern}|从param前面删除pattern的最小匹配|
|${param##pattern}|从param前面删除pattern的最大匹配|
|${param%pattern}|从param后面删除pattern的最小匹配|
|${param%%pattern}|从param后面删除pattern的最大匹配|
|${param/pattern/string}|从param中用string替换pattern的第一次匹配，string可为空|
|${param//pattern/string}|从param中用string替换pattern的所有匹配，string可为空|
|${param:3:2}|截取$param中索引3开始的2个字符|
|${param:3}|截取$param中索引3至末尾的字符|
|${@:3:2}|截取参数列表$@中第3个开始的2个参数|
|${param:-word}|若$param为空或未设置，则参数式返回word，$param不变|
|${param:+word}|若$param为非空，则参数式返回word，$param不变|
|${param:=word}|若$param为空或为设置，则参数式返回word，同时$param设置为word|
|${param:?message}|若$param为空或为设置，则输出错误信息message，若包含空白符，则需引号|

## 获取路径名

### 使用`${}`​，`${str%/*}`​

去掉变量var从右边算起的第一个’/’字符及其右边的内容，返回从右边算起的第一个’/’（不含该字符）的左边的内容。使用例子及结果如下：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
path=${str%/*}
echo $path
/home/luna/Desktop/Software/softHLA/HLAreporter.v103
```

### 使用`awk`​语句

分隔符，混合正则表达式：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
path=`echo $str | awk -F '/[^/]*$' '{print $1}'`
echo $path
/home/luna/Desktop/Software/softHLA/HLAreporter.v103
## 或者使用for循环
path=`echo $str | awk 'BEGIN{res=""; FS="/";}{ for(i=2;i<=NF-1;i++) res=(res"/"$i);} END{print res}'`
/home/luna/Desktop/Software/softHLA/HLAreporter.v103
```

### 使用官方函数`dirname`​

​`bash shell`​本身提供了`basename`​命令，可以直接获取路径名最后的文件名，实现代码如下：

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
path=$(dirname $str)
echo $path
/home/luna/Desktop/Software/softHLA/HLAreporter.v103
```

## 获取文件夹下的文件名

```
str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103
if [ -d "$str" ]; then
	for file in $(ls $str/)
	do
		echo $file
	done
fi
HLAfreq.sh
HLAreporter.README
HLAreporter.sh
HLAreporter_manual
Hydra-Version-0.5.3
Init.sh
bam2fastq-1.1.0
bin
database
docs
freq
mytest
qualityprofile
results
samtools
ssake_v3-8-tar
temp
```

## 相对路径转换为绝对路径

对于 Linux 系统，绝对路径和相对路径的判断十分简单：是否以斜线开头；绝对路径以 / 开头；相对路径不以 / 开头；

```
script=../../../HLAreporter.sh
dir=$(cd $(dirname $script); pwd)
or
dir=`cd $(dirname $script); pwd`
or
dir=echo `cd $(dirname $script); pwd`
echo $dir
/home/luna/Desktop/Software/softHLA/HLAreporter.v103
```

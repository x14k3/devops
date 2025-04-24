# fmt

在日常使用`fmt`​包的过程中，各种眼花缭乱的`print`​是否让你莫名的不知所措呢,更让你茫然的是各种格式化的占位符。。简直就是噩梦。今天就让我们来征服格式化输出，做一个会输出的Goer。

‍

## fmt.Print

​`fmt.Print`​有几个变种：

```go
Print:   输出到控制台,不接受任何格式化操作
Println: 输出到控制台并换行
Printf : 只可以打印出格式化的字符串。只可以直接输出字符串类型的变量（不可以输出别的类型）
Sprintf：格式化并返回一个字符串而不带任何输出
Fprintf：来格式化并输出到 io.Writers 而不是 os.Stdout
```

### 1\. 通用的占位符[#](https://www.cnblogs.com/rickiyang/p/11074171.html#312217765)

```go
%v     值的默认格式。
%+v   类似%v，但输出结构体时会添加字段名
%#v　 相应值的Go语法表示 
%T    相应值的类型的Go语法表示 
%%    百分号,字面上的%,非占位符含义
```

默认格式`%v`​下，对于不同的数据类型，底层会去调用默认的格式化方式：

```perl
bool:                    %t 
int, int8 etc.:          %d 
uint, uint8 etc.:        %d, %x if printed with %#v
float32, complex64, etc: %g
string:                  %s
chan:                    %p 
pointer:                 %p
```

如果是复杂对象的话,按照如下规则进行打印：

```css
struct:            {field0 field1 ...} 
array, slice:      [elem0 elem1 ...] 
maps:              map[key1:value1 key2:value2] 
pointer to above:  &{}, &[], &map[]
```

示例:

```go
package main

import (
	"fmt"
	"strconv"
)

type User struct {
	Name string
	Age  int
}

func (User) GetUser(user User) string{
	return user.Name + " " + strconv.Itoa(user.Age)
}

func main() {
	user := User{"xiaoming", 13}
	//Go默认形式
	fmt.Printf("%v",user)
	fmt.Println()
	//类型+值对象
	fmt.Printf("%#v",user)
	fmt.Println()
	//输出字段名和字段值形式
	fmt.Printf("%+v",user)
	fmt.Println()
	//值类型的Go语法表示形式
	fmt.Printf("%T",user)
	fmt.Println()
	fmt.Printf("%%")
}

输出：
{xiaoming 13}
main.User{Name:"xiaoming", Age:13}
{Name:xiaoming Age:13}
main.User
%
```

### 2\. 常用类型[#](https://www.cnblogs.com/rickiyang/p/11074171.html#1380685215)

#### 2.1 整数类型：

```perl

%b     二进制表示 
%c     相应Unicode码点所表示的字符 
%d     十进制表示 
%o     八进制表示 
%q     单引号围绕的字符字面值，由Go语法安全地转义 
%x     十六进制表示，字母形式为小写 a-f 
%X     十六进制表示，字母形式为大写 A-F 
%U     Unicode格式：123，等同于 "U+007B"
```

示例：

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Printf("%b",123)
	fmt.Println()
	fmt.Printf("%c",123)
	fmt.Println()
	fmt.Printf("%d",123)
	fmt.Println()
	fmt.Printf("%0",123)
	fmt.Println()
	fmt.Printf("%q",123)
	fmt.Println()
	fmt.Printf("%x",123)
	fmt.Println()
	fmt.Printf("%X",123)
	fmt.Println()
	fmt.Printf("%U",123)
	fmt.Println()
}

输出：
1111011
{
123
%!(NOVERB)%!(EXTRA int=123)
'{'
7b
7B
U+007B
```

#### 2.2 浮点数

```perl
%b    无小数部分、二进制指数的科学计数法，如-123456p-78；
	  参见strconv.FormatFloat %e    科学计数法，如-1234.456e+78 %E  
	  科学计数法，如-1234.456E+78 %f  
	  有小数部分但无指数部分，如123.456 %F    等价于%f %g  
	  根据实际情况采用%e或%f格式（以获得更简洁、准确的输出）
	  
%e     科学计数法，例如 -1234.456e+78 
%E     科学计数法，例如 -1234.456E+78 
%f     有小数点而无指数，例如 123.456 
%g     根据情况选择 %e 或 %f 以产生更紧凑的（无末尾的0）输出 
%G     根据情况选择 %E 或 %f 以产生更紧凑的（无末尾的0）输出
```

示例：

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Printf("%b",12675757563.5345432567)
	fmt.Println()
	fmt.Printf("%e",12675757563.5345432567)
	fmt.Println()
	fmt.Printf("%E",12675757563.5345432567)
	fmt.Println()
	fmt.Printf("%f",12675757563.5345432567)
	fmt.Println()
	fmt.Printf("%g",12675757563.5345432567)
	fmt.Println()
	fmt.Printf("%G",12675757563.5345432567)
	fmt.Println()
}

输出：
6645747581470399p-19
1.267576e+10
1.267576E+10
12675757563.534544
1.2675757563534544e+10
1.2675757563534544E+10

```

#### 2.3 布尔型

```shell
%t true 或 false
```

#### 2.4 字符串

```perl
%s     字符串或切片的无解译字节 
%q     双引号围绕的字符串，由Go语法安全地转义 
%x     十六进制，小写字母，每字节两个字符 
%X     十六进制，大写字母，每字节两个字符
```

示例：

```go
package main

import (
	"fmt"
)


func main() {
	//user := User{"xiaoming", 13}
	fmt.Printf("%s","I'm a girl")
	fmt.Println()
	fmt.Printf("%q","I'm a girl")
	fmt.Println()
	fmt.Printf("%x","I'm a girl")
	fmt.Println()
	fmt.Printf("%X","I'm a girl")
	fmt.Println()
}
输出：
I'm a girl
"I'm a girl"
49276d2061206769726c
49276D2061206769726C
```

#### 2.5 指针

```css
%p 十六进制表示，前缀 0x
```

示例：

```go
package main

import (
	"fmt"
)

func main() {
	a := 1
	b := &a
	fmt.Printf("%p",b)
}

输出：
0xc00000c0a8
指针的地址
```

#### 2.6 其他标志

```smalltalk
+     总打印数值的正负号；对于%q（%+q）保证只输出ASCII编码的字符。 
-     左对齐 
#     备用格式：为八进制添加前导 0（%#o），为十六进制添加前导 0x（%#x）或0X（%#X），为 %p（%#p）去掉前导 0x；对于 %q，若 strconv.CanBackquote 返回 true，就会打印原始（即反引号围绕的）字符串；如果是可打印字符，%U（%#U）会写出该字符的Unicode编码形式（如字符 x 会被打印成 U+0078 'x'）。 
' '  （空格）为数值中省略的正负号留出空白（% d）；以十六进制（% x, % X）打印字符串或切片时，在字节之间用空格隔开 
0     填充前导的0而非空格；对于数字，这会将填充移到正负号之后
```

示例：

```go
func main() {
	str := `duduud
		ffff
				nnnnn`
	fmt.Printf("%d",323)
	fmt.Println()
	fmt.Printf("%s",str)
	fmt.Println()
	fmt.Printf("%s    %d","aaaa",10)
	fmt.Println()
	fmt.Printf("%s\n%d","aaaa",10)

}

输出：
323
duduud
		ffff
				nnnnn
aaaa    10
aaaa
10
```

#### 2.7 格式化错误的提示

格式化错误．所有的错误都始于“%!”，有时紧跟着单个字符（占位符），并以小括号括住的描述结尾。

```go
func main() {
	fmt.Printf("%s",2) //%%!s(int=2)
}
```

‍

‍

## ftm.scan

在go语言中如果想获取用户输入，会用到Scan方法。scan在go语言中有很多中，今天介绍一下他们的使用方法和不同点。

和print类似，scan也分为三大类：

* Scan、Scanf和Scanln:    从标准输入os.Stdin读取文本(从终端获取数据)
* Fscan、Fscanf、Fscanln: 从指定的io.Reader接口读取文本(通用)
* Sscan、Sscanf、Sscanln:  从一个参数字符串读取文本(从字符串string获取数据)

本文介绍了Go语言中`fmt`​包中从标准输入获取数据的的`Scan`​系列函数、从`io.Reader`​中获取数据的`Fscan`​系列函数以及从字符串中获取数据的`Sscan`​系列函数的用法。

### fmt.Scan

**语法**

```go
func Scan(a ...interface{}) (n int, err error)
```

* Scan从标准输入扫描文本，读取由空白符分隔的值保存到传递给本函数的参数中，换行符视为空白符。
* 本函数返回成功扫描的数据个数和遇到的任何错误。如果读取的数据个数比提供的参数少，会返回一个错误报告原因。

**代码示例**

```go
func main() {
    var (
        name    string
        age     int
        married bool
    )
    fmt.Scan(&name, &age, &married)
    fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

‍

将上面的代码编译后在终端执行，在终端依次输入`小明`​、`18`​和`false`​使用空格分隔。

```go
$ ./scan_demo 
小明 18 false
扫描结果 name:小明 age:18 married:false 
```

​`fmt.Scan`​从标准输入中扫描用户输入的数据，将以空白符分隔的数据分别存入指定的参数。

### fmt.Scanf

**语法**

```
func Scanf(format string, a ...interface{}) (n int, err error)
```

* Scanf从标准输入扫描文本，根据format参数指定的格式去读取由空白符分隔的值保存到传递给本函数的参数中。
* 本函数返回成功扫描的数据个数和遇到的任何错误。

**代码示例**

```go
func main() {
    var (
        name    string
        age     int
        married bool
    )
    fmt.Scanf("1:%s 2:%d 3:%t", &name, &age, &married)
    fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

将上面的代码编译后在终端执行，在终端按照指定的格式依次输入小明、`18`​和`false。`​

```
$ ./scan_demo 
1:小明 2:18 3:false
扫描结果 name:小明 age:18 married:false 
```

​`fmt.Scanf`​不同于`fmt.Scan`​简单的以空格作为输入数据的分隔符，`fmt.Scanf`​为输入数据指定了具体的输入内容格式，只有按照格式输入数据才会被扫描并存入对应变量。

例如，我们还是按照上个示例中以空格分隔的方式输入，`fmt.Scanf`​就不能正确扫描到输入的数据。

```
$ ./scan_demo 
小明 18 false
扫描结果 name: age:0 married:false 
```

### fmt.Scanln

**语法**

```
func Scanln(a ...interface{}) (n int, err error)
```

* Scanln类似Scan，它在遇到换行时才停止扫描。最后一个数据后面必须有换行或者到达结束位置。
* 本函数返回成功扫描的数据个数和遇到的任何错误。

**代码示例**

‍

```go
func main() {
    var (
        name    string
        age     int
        married bool
    )
    fmt.Scanln(&name, &age, &married)
    fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

‍

将上面的代码编译后在终端执行，在终端依次输入`小明`​、`18`​和`false`​使用空格分隔。

```bash
$ ./scan_demo 
小明 18 false
扫描结果 name:小明 age:18 married:false 
```

​`fmt.Scanln`​遇到回车就结束扫描了，这个比较常用。

### Fscan系列

```go
func Fscan(r io.Reader, a ...interface{}) (n int, err error)
func Fscanln(r io.Reader, a ...interface{}) (n int, err error)
func Fscanf(r io.Reader, format string, a ...interface{}) (n int, err error)
```

这几个函数功能分别类似于`fmt.Scan`​、`fmt.Scanf`​、`fmt.Scanln`​三个函数，只不过它们不是从标准输入中读取数据而是从`io.Reader`​中读取数据。

### Sscan系列

```go
func Sscan(str string, a ...interface{}) (n int, err error)
func Sscanln(str string, a ...interface{}) (n int, err error)
func Sscanf(str string, format string, a ...interface{}) (n int, err error)
```

这几个函数功能分别类似于`fmt.Scan`​、`fmt.Scanf`​、`fmt.Scanln`​三个函数，只不过它们不是从标准输入中读取数据而是从指定字符串中读取数据。

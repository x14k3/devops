# 条件语句switch

## switch 语句基本结构

```go
switch 条件表达式 {
case 常量表达式1:
    语句 1
case 常量表达式2:
    语句 2
    .
    .
    .
case 常量表达式n:
    语句 n
default:
    语句 n+1
}
```

**执行流程**

（1）计算条件表达式的值value

（2）如果value满足某条case语句，则执行该语句，执行完跳出switch语句

（3）如果value不满足所有的case语句：

 （3.1）如果有default，则执行该语句，执行完跳出switch语句

 （3.2）如果没有default，则直接跳出switch语句

**注意事项**

（1）条件表达式可以是任意Go语言支持的数据类型

（3）不需要break语句

（4）default分支为可选项，但最多只能有一个default分支

（5）如果有两个以上的case分支的常量表达式取得相同的值，则编译会出错

## 多case语句

有时在一条case语句中可以对多个条件值进行测试，任意一个条件满足都会执行case语句体

```go
func main() {
	var test string
	fmt.Print("请输入一个字符串：")
	fmt.Scan(&test)
	switch test {
	case "c":
		fmt.Println("c")
	case "java":
		fmt.Println("java")
	case "go", "golang":
		fmt.Println("hello golang")
	default:
		fmt.Println("python")
	}
}
// 请输入一个字符串：go
// hello golang

// 请输入一个字符串：golang
// hello golang
```

## fallthrough语句

通常情况下，switch语句检测到符合条件的第一个case语句，就会执行该分支的代码，执行完会直接跳出switch语句。使用 `fallthrough`​ 语句，可以在执行完该case语句后，不跳出，继续执行下一个case语句。

```go
func main() {
	var test string
	fmt.Print("请输入一个字符串：")
	fmt.Scan(&test)
	switch test {
	case "go":
		fmt.Println("hello go")
	case "golang":
		fmt.Println("hello golang")
		fallthrough
	case "gopher":
		fmt.Println("hello gopher")
	case "java":
		fmt.Println("java")
	}
}
// 请输入一个字符串：go
// hello go

// 请输入一个字符串：golang
// hello golang
// hello gopher
```

## 无条件表达式switch语句

如果switch关键字后面没有条件表达式，则必须在case语句中进行条件判断，即类似于 `if else if`​ 语句

```go
func main() {
	var score int
	fmt.Print("请输入成绩：")
	fmt.Scan(&score)
	switch {
	case score >= 90:
		fmt.Println("good")
	case score >= 80 && score < 90:
		fmt.Println("well")
	case score < 80:
		fmt.Println("ok")
	}
}
// 请输入成绩：60
// ok

// 请输入成绩：85
// well
```

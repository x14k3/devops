# 循环控制Goto、Break、Continue

## continue

　　continue语句用于结束本次循环，继续执行下一次循环

　　continue语句出现在多层嵌套的循环语句体中时，可以通过标签指明要跳过的是哪一层循环，和break标签的使用规则一样

　　continue只能用在循环中，在go中只能用在for循环中，他可以终止本次循环，进行下一次循环。 在continue语句后添加标签时，表示开始标签对应的循环。

```go
package main
import "fmt"
func f(){
    for i := 0; i < 10; i++ {
        if i%2 == 0 {
            fmt.Printf("i: %v\n, i)
        } else {
            continue
        }
    }
}
func main(){
    f()
}

```

　　运行结果

```go
i: 0
i: 2
i: 4
i: 6
i: 8
```

## break

　　break 语句可以结束 for、switch 和 select 的代码块。Break在没有使用标签的时候break只是跳出了一层for循环。break 语句还可以在语句后面添加标签，表示退出某个标签对应的代码块，标签要求必须定义在对应的 for、switch 和 select 的代码块上。

```go
func main() {
OuterLoop:
	for i := 0; i < 2; i++ {
		for j := 0; j < 5; j++ {
			switch j {
			case 2:
				fmt.Println(i, j)
				break OuterLoop
			case 3:
				fmt.Println(i, j)
				break OuterLoop
			}
		}
	}
}
```

## continue和break的区别

　　在Go语言中，`continue`​和`break`​是两个用于控制循环的关键字。

1. ​`continue`​：用于终止当前循环的迭代，并进入下一次迭代。当程序执行到`continue`​语句时，会跳过当前循环体中剩余的代码，直接进入下一次循环的迭代。例如：

```go
for i := 0; i < 5; i++ {
    if i == 2 {
        continue // 当i等于2时，跳过本次循环迭代，进入下一次迭代
    }
    fmt.Println(i)
}
```

　　输出结果为：

```
0
1
3
4
```

　　在上面的例子中，当`i`​等于2时，`continue`​语句被执行，跳过了`i`​等于2时的输出语句，直接进入下一次循环迭代。

2. ​`break`​：用于立即终止当前的循环或开关语句，并跳出循环体或开关语句。当程序执行到`break`​语句时，会立即跳出当前的循环或开关语句，不再执行循环体或开关语句后面的代码。例如：

```go
for i := 0; i < 5; i++ {
    if i == 2 {
        break // 当i等于2时，立即跳出循环
    }
    fmt.Println(i)
}

```

　　输出结果为：

```
0
1
```

　　在上面的例子中，当`i`​等于2时，`break`​语句被执行，立即跳出了循环，不再执行后面的循环迭代。

　　​`continue`​和`break`​语句可以帮助我们在循环中控制程序的流程，根据需要选择跳过当前迭代或者立即终止循环。

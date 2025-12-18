
使用 `os.Args`：
```go
package main

import (
	"fmt"
	"os"
)

func main() {
	// 获取所有命令行参数
	args := os.Args

	// 打印程序名
	fmt.Println("Program name:", args[0])

	// 打印其他参数
	if len(args) > 1 {
		fmt.Println("Other arguments:")
		for i := 1; i < len(args); i++ {
			fmt.Printf("  %s\n", args[i])
		}
	}
}

```

使用 `flag` 包：
```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	// 定义命令行参数
	name := flag.String("name", "world", "your name")
	age := flag.Int("age", 30, "your age")
    isTrue := flag.Bool("istrue", false, "a boolean flag")

	// 解析命令行参数
	flag.Parse()

	// 访问参数值
	fmt.Printf("Hello, %s!\n", *name)
	fmt.Printf("Your age is: %d\n", *age)
    fmt.Printf("The boolean value is: %t\n", *isTrue)

	// 获取非 flag 类型的参数
	if flag.NArg() > 0 {
		fmt.Println("Non-flag arguments:")
		for i := 0; i < flag.NArg(); i++ {
			fmt.Printf("  %s\n", flag.Arg(i))
		}
	}
}

```
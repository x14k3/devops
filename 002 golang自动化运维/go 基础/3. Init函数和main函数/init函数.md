# init函数

## 1\. 引言

　　在Go语言中，`init()`​函数是一种特殊的函数，用于在程序启动时自动执行一次。它的存在为我们提供了一种机制，可以在程序启动时进行一些必要的初始化操作，为程序的正常运行做好准备。

　　在这篇文章中，我们将详细探讨`init()`​函数的特点、用途和注意事项，希望能帮助你更好地理解和使用这个重要的Go语言特性。

## 2\. init 函数的特点

### 2.1 自动执行

　　​`init()`​函数的一个重要特点，便是其无需手动调用，它会在程序启动时自动执行。当程序开始运行时，Go运行时系统会自动调用每个包中的`init()`​函数。下面是一个示例代码，演示了`init()`​函数在程序启动时自动执行的特点：

```go
package main

import "fmt"

func init() {
    fmt.Println("Init function executed")
}

func main() {
    fmt.Println("Main function executed")
}
```

　　在这个示例代码中，我们定义了一个`init()`​函数和一个`main()`​函数。`init()`​函数会在程序启动时自动执行，而`main()`​函数则是程序的入口函数，会在`init()`​函数执行完毕后执行。

　　当我们运行这段代码时，输出结果如下：

```bash
Init function executed
Main function executed
```

　　可以看到，`init()`​函数在程序启动时自动执行，并且在`main()`​函数之前被调用。这证明了`init()`​函数在程序启动时会自动执行，可以用于在程序启动前进行一些必要的初始化操作。

### 2.2 在包级别变量初始化后执行

　　当一个包被引入或使用时，其中会先初始化包级别常量和变量。然后，按照`init()`​函数在代码中的声明顺序，其会被自动执行。下面是一个简单代码的说明:

```go
package main

import "fmt"

var (
        Var1 = "Variable 1"
        Var2 = "Variable 2"
)

func init() {
        fmt.Println("Init function executed")
        fmt.Println("Var1:", Var1)
        fmt.Println("Var2:", Var2)
}

func main() {
        fmt.Println("Main function executed")
}
```

　　在这个示例代码中，我们声明了包级别的常量，并在`init()`​函数中打印它们的值。在`main()`​函数中，我们打印了一条信息。当我们运行这段代码时，输出结果如下：

```bash
Init function executed
Var1: Variable 1
Var2: Variable 2
Main function executed
```

　　可以看到，`init()`​函数在包的初始化阶段被自动执行，并且在包级别常量和变量被初始化之后执行。这验证了`init()`​函数的执行顺序。因为包级别常量和变量的初始化是在`init()`​函数执行之前进行的。因此，在`init()`​函数中可以安全地使用这些常量和变量。

### 2.3 执行顺序不确定

　　在一个包中，如果存在多个`init()`​函数，它们的执行顺序是按照在代码中出现的顺序确定的。先出现的`init()`​函数会先执行，后出现的`init()`​函数会后执行。

　　具体来说，按照代码中的顺序定义了`init()`​函数的先后顺序。如果在同一个源文件中定义了多个`init()`​函数，它们的顺序将按照在源代码中的出现顺序来执行。下面通过一个示例代码来说明：

```go
package main

import "fmt"

func init() {
        fmt.Println("First init function")
}

func init() {
        fmt.Println("Second init function")
}

func main() {
        fmt.Println("Main function executed")
}
```

　　在这个示例中，我们在同一个包中定义了两个`init()`​函数。它们按照在源代码中的出现顺序进行执行。当我们运行这段代码时，输出结果为：

```bash
First init function
Second init function
Main function executed
```

　　可以看到，先出现的`init()`​函数先执行，后出现的`init()`​函数后执行。

　　但是重点在于，如果多个`init()`​函数分别位于不同的源文件中，它们之间的执行顺序是不确定的。这是因为编译器在编译时可能会以不同的顺序处理这些源文件，从而导致`init()`​函数的执行顺序不确定。

　　总结起来，同一个源文件中定义的多个`init()`​函数会按照在代码中的出现顺序执行，但多个源文件中的`init()`​函数执行顺序是不确定的。

## 3\. init 函数的用途

### 3.1 初始化全局变量

　　在大多数情况下，我们可以直接在定义全局变量或常量时赋初值，而不需要使用 `init()`​ 函数来进行初始化。直接在定义时赋值的方式更为简洁和直观。

　　然而，有时候我们可能需要更复杂的逻辑来初始化全局变量或常量。这些逻辑可能需要运行时计算、读取配置文件、进行网络请求等操作，无法在定义时直接赋值。在这种情况下，我们可以使用 `init()`​ 函数来实现这些复杂的初始化逻辑。

```go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
)

// json配置文件结构体
type MonParam struct {
	IpAddress   string   `json:"ipAddress"`
	AppName     []string `json:"appName"`
	ServiceName []string `json:"serviceName"`
	PortNum     []string `json:"portNum"`
	AlarmUrl    string   `json:"alarmUrl"`
}

var Param MonParam

func init() {
	//读取配置json配置文件
	content, err := os.ReadFile("./config.json")
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}

	//将json文件解析为结构体
	err = json.Unmarshal(content, &Param)
	if err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}
}

// 检查windows进程
func checkProcess(appName string) bool {

	buf := bytes.Buffer{}
	cmd := exec.Command("wmic", "process", "get", "name,executablepath")
	cmd.Stdout = &buf
	cmd.Run()

	cmd2 := exec.Command("findstr", appName)
	cmd2.Stdin = &buf
	data, _ := cmd2.CombinedOutput()
	if len(data) == 0 {
		return false
	} else {
		return true
	}
}

func main() {
	for _, elem := range Param.AppName {
		if checkProcess(elem) {
			fmt.Println("true")
		} else {
			log.Println("false")
		}
	}

```

## 4\. init 函数的注意事项

### 4.1 init 函数不能被显式调用

　　当我们定义一个 `init()`​ 函数时，它会在程序启动时自动执行，而无法被显式调用。下面通过一个示例代码来简单说明：

```go
package main

import "fmt"

func init() {
        fmt.Println("This is the init() function.")
}

func main() {
        fmt.Println("This is the main() function.")

        // 无法显式调用 init() 函数
        // init() // 这行代码会导致编译错误
}
```

　　在这个示例中，我们定义了一个 `init()`​ 函数，并在其中打印一条消息。然后，在 `main()`​ 函数中打印另一条消息。在 `main()`​ 函数中，我们尝试显式调用 `init()`​ 函数，但是会导致编译错误。这是因为 `init()`​ 函数是在程序启动时自动调用的，无法在代码中进行显式调用。

　　如果我们尝试去调用 `init()`​ 函数，编译器会报错，提示 `undefined: init`​，因为它不是一个可调用的函数。它的执行是由编译器在程序启动时自动触发的，无法通过函数调用来控制。

### 4.2 init 函数只执行一次

　　​`init()`​ 函数在应用程序运行期间只会执行一次。它在程序启动时被调用，并且仅被调用一次。当一个包被导入时，其中定义的 `init()`​ 函数会被自动执行。

　　同时，即使同一个包被导入了多次，其中的 `init()`​ 函数也只会被执行一次。这是因为 Go 编译器和运行时系统会确保在整个应用程序中只执行一次每个包的 `init()`​ 函数。下面通过一个代码来进行说明:

　　首先，我们创建一个名为`util`​的包，其中包含一个全局变量`counter`​和一个`init()`​函数，它会将`counter`​的值增加1。

```go
// util.go
package util

import "fmt"

var counter int

func init() {
        counter++
        fmt.Println("init() function in util package executed. Counter:", counter)
}

func GetCounter() int {
        return counter
}
```

　　接下来，我们创建两个独立的包，分别为`package1`​和`package2`​。这两个包都会同时导入`util`​包。

```go
// package1.go
package package1

import (
        "fmt"
        "util"
)

func init() {
        fmt.Println("init() function in package1 executed. Counter:", util.GetCounter())
}
```

```go
// package2.go
package package2

import (
        "fmt"
        "util"
)

func init() {
        fmt.Println("init() function in package2 executed. Counter:", util.GetCounter())
}
```

　　最后，我们创建一个名为`main.go`​的程序，导入`package1`​和`package2`​。

```go
// main.go
package main

import (
        "fmt"
        "package1"
        "package2"
)

func main() {
        fmt.Println("Main function")
}
```

　　运行上述程序，我们可以得到以下输出：

```bash
init() function in util package executed. Counter: 1
init() function in package1 executed. Counter: 1
init() function in package2 executed. Counter: 1
Main function
```

　　从输出可以看出，`util`​包中的`init()`​函数只会执行一次，并且在`package1`​和`package2`​的`init()`​函数中都能获取到相同的计数器值。这表明，当多个包同时导入另一个包时，该包中的`init()`​函数只会被执行一次。

### 4.3 避免在 init 函数中执行耗时操作

　　当在 `init()`​ 函数中执行耗时操作时，会影响应用程序的启动时间。这是因为 `init()`​ 函数在程序启动时自动调用，而且在其他代码执行之前执行。如果在 `init()`​ 函数中执行耗时操作，会导致应用程序启动变慢。下面是一个例子来说明这一点：

```go
package main

import (
        "fmt"
        "time"
)

func init() {
        fmt.Println("Executing init() function...")
        time.Sleep(3 * time.Second) // 模拟耗时操作，睡眠 3 秒钟
        fmt.Println("Init() function execution completed.")
}

func main() {
        fmt.Println("Executing main() function...")
}
```

　　在这个例子中，我们在 `init()`​ 函数中使用 `time.Sleep()`​ 函数模拟了一个耗时操作，睡眠了 3 秒钟。然后，在 `main()`​ 函数中输出一条消息。当我们运行这个程序时，会发现在启动时会有 3 秒钟的延迟，因为 `init()`​ 函数中的耗时操作会在程序启动时执行，而 `main()`​ 函数会在 `init()`​ 函数执行完成后才开始执行。

　　通过这个例子，我们可以看到在 `init()`​ 函数中执行耗时操作会影响应用程序的启动时间。如果有必要执行耗时操作，最好将其移至 `main()`​ 函数或其他合适的地方，在应用程序启动后再执行，以避免启动阶段的延迟。

　　总之，为了保持应用程序的启动性能，应避免在 `init()`​ 函数中执行耗时操作，尽量将其放在需要时再执行，以避免不必要的启动延迟。

## 5\. 总结

　　本文介绍了Go语言中的`init()`​函数的特点，用途和注意事项。

　　在文章中，我们首先讲述了`init()`​函数的特点，包含`init`​函数的自动执行，以及其执行时机的内容，接着详细讲解了`init()`​函数的几个常见用途，包括初始化全局变量以及执行一些必要的校验操作。接着我们提到了`init()`​函数的一些注意事项，如`init`​函数不能被显式调用等。

　　基于以上内容，完成了对`init()`​函数的介绍，希望能帮助你更好地理解和使用这个重要的Go语言特性。

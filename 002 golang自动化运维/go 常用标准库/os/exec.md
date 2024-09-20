# exec

## 创建命令

### exec.Command()

　　首先，我们调用exec.Command传入命令名，创建一个命令对象exec.Cmd。接着调用该命令对象的Run()方法运行它。

```go
cmd := exec.Command("ls", "-la")
```

#### **使用exec.Command执行带管道的命令**

```
```

　　‍

## 运行命令

### exec.Run()​

```go
cmd := exec.Command("ls", "-la")
err := cmd.Run()
if err != nil {
    log.Fatalf("cmd.Run() failed with %s\n", err)
}
```

　　请注意，使用 `exec.Command()`​ 创建的命令默认不会有任何输出。如果我们想获取命令的标准输出，我们可以使用 `Output()`​ 或 `CombinedOutput()`​ 方法。如果我们想获取命令的标准错误输出，我们需要单独设置 `Cmd.Stderr`​ 字段。

　　‍

## 显示输出

　　​`exec.Cmd`​对象有两个字段`Stdout`​和`Stderr`​，类型皆为`io.Writer`​。我们可以将任意实现了`io.Writer`​接口的类型实例赋给这两个字段，继而实现标准输出和标准错误的重定向。`io.Writer`​接口在 Go 标准库和第三方库中随处可见，例如`*os.File`​、`*bytes.Buffer`​、`net.Conn`​。所以我们可以将命令的输出重定向到文件、内存缓存甚至发送到网络中。

### 显示到标准输出

　　将`exec.Cmd`​对象的`Stdout`​和`Stderr`​这两个字段都设置为`os.Stdout`​，那么输出内容都将显示到标准输出：

```go
func main() {
	cmd := exec.Command("ls", "-al")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed: %v\n", err)
	}
}
```

　　‍

### 输出到文件

　　打开或创建文件，然后将文件句柄赋给`exec.Cmd`​对象的`Stdout`​和`Stderr`​这两个字段即可实现输出到文件的功能。

```go
func main() {
	f, err := os.OpenFile("out.txt", os.O_WRONLY|os.O_CREATE, os.ModePerm)
	if err != nil {
		log.Fatalf("os.OpenFile() failed: %v\n", err)
	}

	cmd := exec.Command("ls", "-al")
	cmd.Stdout = f
	cmd.Stderr = f
	err = cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed: %v\n", err)
	}
}

```

　　​`os.OpenFile`​打开一个文件，指定`os.O_CREATE`​标志让操作系统在文件不存在时自动创建一个，返回该文件对象`*os.File`​。`*os.File`​实现了`io.Writer`​接口。

　　‍

### 保存到内存对象中

　　​`*bytes.Buffer`​同样也实现了`io.Writer`​接口，故如果我们创建一个`*bytes.Buffer`​对象，并将其赋给`exec.Cmd`​的`Stdout`​和`Stderr`​这两个字段，那么命令执行之后，该`*bytes.Buffer`​对象中保存的就是命令的输出。

```go
func main() {
	buf := bytes.NewBuffer(nil)
	cmd := exec.Command("ls", "-al")
	cmd.Stdout = buf
	cmd.Stderr = buf
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed: %v\n", err)
	}

	fmt.Println(buf.String())
}
```

　　运行命令，然后得到输出的字符串或字节切片这种模式是如此的普遍，并且使用便利，`os/exec`​包提供了一个便捷方法：`CombinedOutput`​。

### 输出到多个目的地

　　有时，我们希望能输出到文件和内存对象。使用go提供的`io.MultiWriter`​可以很容易实现这个需求。`io.MultiWriter`​很方便地将多个`io.Writer`​转为一个`io.Writer`​。

```go
func main() {
	f, _ := os.OpenFile("out.txt", os.O_CREATE|os.O_WRONLY, os.ModePerm)
	buf := bytes.NewBuffer(nil)
	mw := io.MultiWriter(f, buf)
	cmd := exec.Command("ls", "-al")
	cmd.Stdout = mw
	cmd.Stderr = mw

	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed: %v\n", err)
	}

	fmt.Println(buf.String())
}

```

## 运行命令，获取输出

### exec.Output()

　　​`exec.Output()`​ 是 `*exec.Cmd`​ 的一个方法，它用于获取命令的标准输出。当命令执行成功时，错误将被设置为 `nil`​。当命令执行失败时，返回的错误将是一个 `*exec.ExitError`​ 类型，它包含了命令的退出状态码以及命令的标准错误输出。

　　以下是一个简单的例子：

```go
package main

import (
	"fmt"
	"os/exec"
)

func main() {
	cmd := exec.Command("ls", "-la")
	out, err := cmd.Output()
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("out: ", string(out))
}
```

　　在这个例子中，我们使用 `exec.Command()`​ 创建了一个执行 `ls -la`​ 命令的 `*exec.Cmd`​，然后使用 `Output()`​ 方法获取了命令的输出。

### exec.CombinedOutput()

　　​`exec.CombinedOutput()`​ 是 `*exec.Cmd`​ 的一个方法，用于获取命令的标准输出和标准错误输出的组合。如果命令执行成功，错误将被设置为 `nil`​。如果命令执行失败，返回的错误将是一个 `*exec.ExitError`​ 类型，它只包含了命令的退出状态码，标准错误输出已经和标准输出一起返回了。

　　以下是一个简单的例子：

```go
package main

import (
	"fmt"
	"os/exec"
)

func main() {
	cmd := exec.Command("ls", "-la")
	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("out: ", string(out))
}
```

　　在这个例子中，我们使用 `exec.Command()`​ 创建了一个执行 `ls -la`​ 命令的 `*exec.Cmd`​，然后使用 `CombinedOutput()`​ 方法获取了命令的输出。

### 对比和适用场景

　　虽然 `exec.Output()`​ 和 `exec.CombinedOutput()`​ 都用于获取命令的执行结果，但是在处理命令的输出时它们存在一些关键的差别：

* ​`exec.Output()`​ 只返回命令的标准输出。如果我们只关心命令的标准输出，或者我们想要分别处理命令的标准输出和标准错误输出，我们应该使用 `exec.Output()`​。
* ​`exec.CombinedOutput()`​ 返回命令的标准输出和标准错误输出的组合。如果我们不关心标准输出和标准错误输出之间的区别，或者我们想要一次获取所有的输出，我们应该使用 `exec.CombinedOutput()`​。

## 分别获取标准输出和标准错误

　　创建两个`*bytes.Buffer`​对象，分别赋给`exec.Cmd`​对象的`Stdout`​和`Stderr`​这两个字段，然后运行命令即可分别获取标准输出和标准错误。

```go
func main() {
	cmd := exec.Command("ls", "-lh")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed: %v\n", err)
	}

	fmt.Printf("output:\n%s\nerror:\n%s\n", stdout.String(), stderr.String())
}

```

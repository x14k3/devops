#go 

Go 的工具确实很棒，这也是我爱上 Go 的原因。在我们安装 Go 的时候，会默认安装很多重要的有用的工具。除此之外，你也可以自行安装一些你需要的其他工具，例如：golint，errcheck 等等。

### go get

安装 Go 软件包最常用的命令就是 `go get`​ 。如果你想指定和管理软件的版本号，可以使用 [dep](https://github.com/golang/dep) 。`go get`​ 可以下载指定的软件包及其依赖，同时会像 `go install`​ 命令一样安装下载好的软件包。

```bash
go get github.com/golang/lint/golint
```

该命令还有一些很有帮助的可选项标志：  
`-u`​ 强制软件包版本为最新版本。

`-d`​ 可以跳过编译和安装的步骤，只将存储库克隆到 GOPATH 工作区。

### go build / go install

这两个命令是用来编译包和依赖项的。`go install`​ 和 `go build`​ 在没有附加参数的情况下运行时都将编译当前目录下的包。如果包是 `package main`​，那么 `go build`​ 将把生成的可执行文件放在当前目录中。`go install`​ 将把它放在 `$GOPATH/bin`​ （如果有多个参数将使用 `$GOPATH`​ 的第一个参数）下。另外，`go install`​ 将在 `$GOPATH/pkg`​ 中安装已编译的依赖项。要达到与 `go build`​ 相同的效果，可以使用 `go build -i`​。如果包不是 main 包，`go install`​ 将会编译包，并安装在 `$GOPATH/pkg`​ 中。

注意：在 1.13 以上版本中要使用 `go build`​ 在目录中直接编译 main 包内容的话需要 go 的配置项是 `GO111MODULE=off`​ 或者 `GO111MODULE=auto`​，默认是 `auto`​。

​`go build`​ 命令允许您在自己的平台上为 Go 支持的任何目标平台构建可执行文件。这意味着您可以测试、发布和分发应用程序，而不必在希望使用的目标平台上构建那些可执行程序。

```bash
GOOS=windows GOARCH=amd64 go build github.com/mholt/caddy/caddy
```

如果您对 Go 工具链感到好奇，或者使用跨 C 编译器，并且对传递给外部编译器的标志感到好奇，或者对链接器 bug 感到怀疑，那么可以使用 `-x`​ 来查看所有调用。

```bash
go build -x
WORK=/var/folders/2g/_fnx086940v6k_yt88fdtqw80000gn/T/go-build614085896
mkdir -p $WORK/github.com/plutov/go-snake-telnet/_obj/
mkdir -p $WORK/github.com/plutov/go-snake-telnet/_obj/exe/
...
```

在构建 Go 程序时，我经常使用 `-ldflags`​ 选项：-  [优化 Go 二进制大小](https://pliutau.com/optimize-go-binary-size/) - 在构建过程中设置变量值。

```bash
go build -ldflags="-X main.Version 1.0.0"
```

​`go build -gcflags`​ 用于将标志传递给 Go 编译器。`go tool compile -help`​ 列出了所有可以传递给编译器的标志。

### go test

这个命令有许多选项，但是我经常用的是：

- ​`-race`​ 运行 [Go race detector](https://blog.golang.org/race-detector)。
- ​`-run`​ 来过滤要由 regex 和 -run 标志运行的测试: `go test -run=FunctionName`​。
- ​`-bench`​ 去运行基准测试。 - `-cpuprofile cpu.out`​ 退出前将 CPU 配置文件写入指定的文件。
- ​`-memprofile mem.out`​ 在所有测试通过后，将内存配置文件写入文件。
- 我总是用 `-v`​. 它打印测试名称、状态 (失败或通过)、运行测试需要多少时间、测试用例中的任何日志等等。
- ​`-cover`​ 度量在运行一组测试时执行的代码行的百分比。

### go list

它列出了由导入路径命名的包，每行一个。

### go env

打印 Go 环境变量信息：

```bash
go env
GOARCH="amd64"
GOBIN="/Users/pltvs/go/bin"
...
```

### go fmt

对我来说最有用的工具，因为他是在保存文件时运行的。它会根据 Go 的标准重新格式化你的代码。

还有基于 `gofmt`​ 的 `goimports`​，它会更新你的 Go 导入行，添加缺失的行，删除未引用的行。

### go vet

我也在保存时运行它， `go vet`​ 检查 Go 源代码并报告可疑的构造，如参数与格式字符串不一致的 `Printf`​ 调用。

### go generate

​`go generate`​ 命令是在 Go 1.4 版本加入的，是「在编译前自动运行生成源代码的工具」。

Go 工具会扫描与当前包相关的文件，寻找带有表单 `//go:generate command arguments`​「魔力注释」的行。此命令不需要执行任何与 Go 或代码生成相关的操作。例如：

```bash
package project

//go:generate echo Hello, Go Generate!

func Add(x, y int) int {
    return x + y
}

```

‍

```bash
go generate
Hello, Go Generate!
```

‍

### 阅读代码的工具

阅读代码比编写代码花费更多的时间，因此，帮助我们阅读代码的工具是任何优秀 Go 开发者都需要掌握的重要工具。

### go doc / godoc

这听起来很像 javadoc 和其他类似的工具，但是 Go 文档没有任何额外的格式化规则。所有内容都是纯文本。

例如，我们可以获得关于 json 的信息。编码器通过运行:

```bash
go doc json.Encoder
package json // import "encoding/json"

type Encoder struct {
        // Has unexported fields.
}
...

```

如果 `godoc`​ 能够向我们提供关于我们的 GOPATH 中的任何标识符的信息，`godoc`​ 能够以文本形式为包提供完整的文档：

```bash
godoc errors
use 'godoc cmd/errors' for documentation on the errors command

PACKAGE DOCUMENTATION

package errors
...
```

### 非标准 Go 工具

让我们看看社区创建了什么工具来让 Go 开发者高兴。

### golint

我也是在保存文件时运行它。

```bash
go get -u github.com/golang/lint/golint
```

### errcheck

```bash
go get github.com/kisielk/errcheck
```

此工具检测何时以静默方式忽略错误。这意味着对于一个至少返回一个错误的函数，我们要忽略检查返回的值。

给定一个 `foo() error`​ 函数，我们会说：

- ​`foo()`​ 是静默的忽略错误，而
- ​`_ = foo()`​ 是显式地忽略了错误。

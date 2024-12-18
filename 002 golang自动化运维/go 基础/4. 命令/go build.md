# go build

## 不同系统可执行文件编译命令

> Mac下编译Linux, Windows平台的64位可执行程序

```golang
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
```

> Linux下编译Mac, Windows平台的64位可执行程序

```golang
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
```

> Windows下编译Mac, Linux平台的64位可执行程序

```golang
SET CGO_ENABLED=0SET GOOS=darwin3 SET GOARCH=amd64 go build main.go
SET CGO_ENABLED=0 SET GOOS=linux SET GOARCH=amd64 go build  main.go
```

## build 详解

```golang
go help build
```

> 构建编译由导入路径命名的包，以及它们的依赖关系，但它不会安装结果

### 使用

```golang
go build [-o 输出名] [-i] [编译标记] [包名]
```

* 如果参数为\*\*\*.go文件或文件列表，则编译为一个个单独的包。
* 当编译单个main包（文件），则生成可执行文件。
* 当编译单个或多个包非主包时，只构建编译包，但丢弃生成的对象（.a），仅用作检查包可以构建。
* 当编译包时，会自动忽略’\_test.go’的测试文件。

### 特定参数

|名称|描述|
| ------| --------------------------------------------------------|
|-o|output 指定编译输出的名称，代替默认的包名。|
|-i|install 安装作为目标的依赖关系的包(用于增量编译提速)。|

### 以下 build 参数可用在 build, clean, get, install, list, run, test

|名称|描述|
| --------------------------| -------------------------------------------------------------------------------------------------------------------------|
|-a|完全编译，不理会-i产生的.a文件(文件会比不带-a的编译出来要大？)|
|-n|仅打印输出build需要的命令，不执行build动作（少用）。|
|-p n|开多少核cpu来并行编译，默认为本机CPU核数（少用）。|
|-race|同时检测数据竞争状态，只支持 linux/amd64, freebsd/amd64, darwin/amd64 和 windows/amd64.|
|-msan|启用与内存消毒器的互操作。仅支持linux / amd64，并且只用Clang / LLVM作为主机C编译器（少用）。|
|-v|打印出被编译的包名（少用）.|
|-work|打印临时工作目录的名称，并在退出时不删除它（少用）。|
|-x|同时打印输出执行的命令名（-n）（少用）.|
|-asmflags ‘flag list’|传递每个go工具asm调用的参数（少用）|
|-buildmode mode|编译模式（少用）‘go help buildmode’|
|-compiler name|使用的编译器 \=\= runtime.Compiler (gccgo or gc)（少用）.|
|-gccgoflags ‘arg list’|gccgo 编译/链接器参数（少用）|
|-gcflags ‘arg list’|垃圾回收参数（少用）.|
|-ldflags ‘flag list’|‘-s -w’: 压缩编译后的体积; -s: 去掉符号表; -w:去掉调试信息，不能gdb调试了;|
|-linkshared|链接到以前使用创建的共享库 -buildmode\=shared.|
|-pkgdir dir|从指定位置，而不是通常的位置安装和加载所有软件包。例如，当使用非标准配置构建时，使用-pkgdir将生成的包保留在单独的位置。|
|-tags ‘tag list’|构建出带tag的版本.|

> 以上命令，单引号/双引号均可。

* 对包的操作’go help packages’
* 对路径的描述’go help gopath’

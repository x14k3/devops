#go
## 1\. 跨平台交叉编译

Go语言支持交叉编译，在一个平台上生成另一个平台的可执行程序，最近使用了一下，非常好用，这里备忘一下。

需要注意的是我发现golang在支持cgo的时候是没法交叉编译的

**Mac 下编译 Linux 和 Windows 64位可执行程序**

```go
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build
```

**Linux 下编译 Mac 和 Windows 64位可执行程序**

```go
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build
```

**Windows 下编译 Mac 和 Linux 64位可执行程序**

```go
SET CGO_ENABLED=0
SET GOOS=darwin
SET GOARCH=amd64
go build

SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
go build
```

- GOOS：目标平台的操作系统 darwin、freebsd、linux、windows
- GOARCH：目标平台的体系架构 386、amd64、arm
- 交叉编译不支持 CGO 所以要禁用它

‍

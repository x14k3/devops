#go 

### 问题

默认 GOSUMDB 的值为：

```golang
sum.golang.org
```

使用 go get 或者 go install 命令时，即使我们设置了 GOPROXY 加速镜像，偶尔还是会遇到：

```golang
dlv: failed to install dlv(github.com/go-delve/delve/cmd/dlv@latest): Error: Command failed: /usr/local/bin/go install -v github.com/go-delve/delve/cmd/dlv@latest
go: downloading github.com/go-delve/delve v1.8.2
go: github.com/go-delve/delve/cmd/dlv@latest: github.com/go-delve/delve@v1.8.2: verifying module: github.com/go-delve/delve@v1.8.2: Get "https://sum.golang.org/lookup/github.com/go-delve/delve@v1.8.2": dial tcp 142.251.43.17:443: i/o timeout
```

### 原因

首先需要弄懂，执行以上提到的两个命令时，除了会从 GOPROXY 下载压缩包，还会调用 GOSUMDB 来检测文件哈希是否正确。此乃 Go Module 提供的安全机制，能有效防止代码被篡改。

因国内访问外网不稳定 sum.golang.org 连接超时了，导致无法完成整个下载流程。

#### 解决

解决方法同修改 GOPROXY 一样，我们设置一个国内能访问到的 GOSUMDB 即可。

Mac 或者 Linux 下：

```golang
go env -w GOSUMDB=sum.golang.google.cn
```

Windows 下：

```golang
$env:GOPROXY="sum.golang.google.cn"
```

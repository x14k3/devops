# 获取http状态码

```go
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// 定义命令行参数，接收要请求的 URL 和输出文件名
	url := flag.String("url", "http://example.com", "HTTP URL to request.")
	outputFile := flag.String("output", "result.txt", "Output file to store the results.")
	flag.Parse()

	// 发送 GET 请求
	resp, err := http.Get(*url)
	if err != nil {
		log.Fatalf("请求错误: %v", err)
	}
	defer resp.Body.Close() // 确保在函数结束时关闭响应体

	// 创建或打开指定的输出文件
	file, err := os.OpenFile(*outputFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("打开文件错误: %v", err)
	}
	defer file.Close() // 确保在程序结束时关闭文件

	// 输出到文件
	result := fmt.Sprintf("请求 URL: %s\nHTTP 状态码: %d\n", *url, resp.StatusCode)
	if _, err := file.WriteString(result); err != nil {
		log.Fatalf("写入文件错误: %v", err)
	}

	fmt.Println("结果已写入到文件:", *outputFile)
}

```

```go
go run main.go -url "http://www.google.com" -output "result.txt"
```

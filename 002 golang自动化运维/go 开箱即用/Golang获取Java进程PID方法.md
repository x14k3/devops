# Golang获取Java进程PID方法

项目背景：dbjd 客户使用cmd启动java服务，运行起来是cmd窗口，多个服务就是多个cmd，无法通过任务管理器（tasklist）查找指定服务的进程pid

‍

步骤说明：

1. **安装依赖库**：

* ```go
  go get github.com/shirou/gopsutil/v3/process
  ```
* **代码逻辑**：

  * **获取进程列表**：使用`gopsutil`​的`process.Processes()`​获取所有进程。
  * **筛选Java进程**：检查进程名称是否为`java.exe`​（不区分大小写）。
  * **匹配JAR名称**：通过进程命令行参数（`Cmdline()`​）判断是否包含目标JAR包名称。
  * **返回PID列表**：收集所有符合条件的Java进程PID。

‍

‍

```go
package main

import (
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v3/process"
)

// 初始化日志配置
func initLogger(logFile string) (*os.File, error) {
	// 创建/打开日志文件（追加模式）
	file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		return nil, err
	}

	// 设置日志输出：同时输出到文件和控制台
	log.SetOutput(os.Stdout) // 默认输出到控制台
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)

	// 创建多目标写入器
	multiWriter := &multiWriter{
		file:    file,
		console: os.Stdout,
	}
	log.SetOutput(multiWriter)

	return file, nil
}

// 自定义多目标写入器
type multiWriter struct {
	file    *os.File
	console *os.File
}

func (mw *multiWriter) Write(p []byte) (n int, err error) {
	// 写入控制台
	_, _ = mw.console.Write(p)
	// 写入文件（带时间戳前缀）
	fileLine := fmt.Sprintf("[%s] %s", time.Now().Format("2006-01-02 15:04:05"), p)
	return mw.file.WriteString(fileLine)
}

// 查找Java进程PID（带日志记录）
func findJavaPIDByJarName(jarName string) ([]int32, error) {
	log.Printf("===> Start searching for Java processes containing JAR name '%s' ", jarName)

	processes, err := process.Processes()
	if err != nil {
		log.Printf("Error: Failed to get process list - %v", err)
		return nil, fmt.Errorf("Failed to get the process list: %v", err)
	}
	log.Printf("A total of %d processes were found", len(processes))

	var pids []int32
	for idx, p := range processes {
		// 记录进度
		if idx%50 == 0 {
		}

		// 获取进程名称
		name, err := p.Name()
		if err != nil {
			continue
		}

		// 过滤Java进程
		if strings.ToLower(name) != "java.exe" {
			continue
		}
		//log.Printf("发现Java进程 PID=%d", p.Pid)

		// 获取命令行参数
		cmdline, err := p.Cmdline()
		if err != nil {
			//log.Printf("警告：无法获取PID %d 的命令行 - %v", p.Pid, err)
			continue
		}
		log.Printf("PID %d Command line: %s", p.Pid, cmdline)

		// 匹配JAR名称
		if strings.Contains(cmdline, jarName) {
			log.Printf("Matching successful PID=%d", p.Pid)
			pids = append(pids, p.Pid)
		}
	}

	if len(pids) == 0 {
		log.Printf("Error: No Java process found containing '%s'", jarName)
		return nil, fmt.Errorf("No Java process found containing JAR package name '%s'", jarName)
	}

	log.Printf("Found %d matching processes: %v", len(pids), pids)
	return pids, nil
}

func main() {
	// 读取命令行参数
	if len(os.Args) < 2 {
		fmt.Printf("Usage: %s <JAR name>\n", os.Args[0])
		fmt.Println("demo: pidfinder.exe myapp.jar")
		os.Exit(1)
	}
	jarName := os.Args[1]

	// 初始化日志（日志文件路径可配置）
	const logFile = "process_scanner.log"
	file, err := initLogger(logFile)
	if err != nil {
		log.Fatalf("Unable to initialize log file: %v", err)
	}
	defer file.Close()

	log.Println("================= Start Process Scan ================")
	defer log.Println("================= Scan End =================")

	// 执行查找
	pids, err := findJavaPIDByJarName(jarName)
	if err != nil {
		log.Printf("Execution failed: %v", err)
		return
	}

	// 输出结果
	log.Printf("The final found PID list: %v", pids)

}

```

‍

```go
go build -o pidfinder.exe
```

‍

```go
# 基本用法
./pidfinder.exe your-app.jar

# 带空格的JAR名称（使用引号包裹）
./pidfinder.exe "my application.jar"
```

‍

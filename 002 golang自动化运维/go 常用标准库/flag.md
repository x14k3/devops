# flag

　　‍

```bash
import (
	"encoding/binary"
	"flag"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"time"
)

// Config 结构体用于解析配置
type Config struct {
	ServerAddress string `json:"server_address"`
	WatchDir      string `json:"watch_dir"`
}

func main() {
	// 定义命令行参数
	serverAddress := flag.String("ip", "127.0.0.1:9981", "Server IP address and port (e.g., localhost:9981).")
	watchDir := flag.String("watch", "/opt/test/fileClient", "Directory to watch for files.")
	flag.Parse()

	// 创建配置
	config := Config{
		ServerAddress: *serverAddress,
		WatchDir:      *watchDir,
	}

	for {
		// 处理目录中的所有内容，包括子目录
		processDirectory(config.WatchDir, config.ServerAddress)

		// 每2秒检查一次
		time.Sleep(2 * time.Second)
	}
}
```

　　​`./fileClient_linux_x86_64 -ip=127.0.0.1:9981 -watch=/path/test`​

　　‍

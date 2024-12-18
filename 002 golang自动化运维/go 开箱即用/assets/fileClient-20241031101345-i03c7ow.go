package main

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
	serverAddress := flag.String("ip", "localhost:8080", "Server IP address and port (e.g., localhost:8080).")
	watchDir := flag.String("watch", "/path/to/watch", "Directory to watch for files.")
	flag.Parse()

	// 创建配置
	config := Config{
		ServerAddress: *serverAddress,
		WatchDir:      *watchDir,
	}

	for {
		// 获取目录下的所有文件
		files, err := os.ReadDir(config.WatchDir)
		if err != nil {
			fmt.Println("Error reading directory:", err)
			continue
		}

		for _, file := range files {
			if !file.IsDir() {
				// 调用发送文件的函数
				err := sendFile(filepath.Join(config.WatchDir, file.Name()), config.ServerAddress)
				if err != nil {
					fmt.Println("Error sending file:", err)
					continue
				}
				// 发送完成后删除本地文件
				err = os.Remove(filepath.Join(config.WatchDir, file.Name()))
				if err != nil {
					fmt.Println("Error deleting file:", err)
				}
			}
		}

		// 每2秒检查一次
		time.Sleep(2 * time.Second)
	}
}

// 读取配置文件的功能已移除，直接使用命令行参数创建配置
// 发送文件的函数保持不变
func sendFile(filePath string, serverAddress string) error {
	conn, err := net.DialTimeout("tcp", serverAddress, 5*time.Second)
	if err != nil {
		return fmt.Errorf("Error connecting to server: %v", err)
	}
	defer conn.Close()

	fileName := filepath.Base(filePath)
	nameLength := int32(len(fileName))
	if err := binary.Write(conn, binary.LittleEndian, nameLength); err != nil {
		return fmt.Errorf("Error sending filename length: %v", err)
	}

	if err := binary.Write(conn, binary.LittleEndian, []byte(fileName)); err != nil {
		return fmt.Errorf("Error sending filename: %v", err)
	}

	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("Error opening file: %v", err)
	}
	defer file.Close()

	_, err = io.Copy(conn, file)
	if err != nil {
		return fmt.Errorf("Error sending file: %v", err)
	}

	fmt.Println("Sent file:", fileName)
	return nil
}

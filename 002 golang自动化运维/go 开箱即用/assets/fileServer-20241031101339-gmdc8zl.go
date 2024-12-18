package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"os"
)

const (
	port      = "9981"
	outputDir = "/opt/test/fileServer"
)

func main() {
	// 创建接收文件的目录
	os.MkdirAll(outputDir, os.ModePerm)

	// 启动TCP服务器
	listener, err := net.Listen("tcp", ":"+port)
	if err != nil {
		fmt.Println("Error starting server:", err)
		return
	}
	defer listener.Close()
	fmt.Println("Server is listening on port:", port)

	for {
		// 等待客户端连接
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Error accepting connection:", err)
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	// 读取文件名长度
	var nameLength int32
	if err := binary.Read(conn, binary.LittleEndian, &nameLength); err != nil {
		fmt.Println("Error reading filename length:", err)
		return
	}

	// 读取文件名
	fileName := make([]byte, nameLength)
	if err := binary.Read(conn, binary.LittleEndian, &fileName); err != nil {
		fmt.Println("Error reading filename:", err)
		return
	}

	// 创建文件用于保存接收到的内容
	outFile, err := os.Create(string(fileName))
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer outFile.Close()

	// 读文件内容并写入到文件
	_, err = io.Copy(outFile, conn) // 从连接读取数据并写入文件
	if err != nil {
		fmt.Println("Error receiving file content:", err)
		return
	}

	fmt.Println("Received file:", string(fileName))
}

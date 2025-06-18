#go 

需求：

在windows server 2012 r2 环境下获取指定jar包的java进程的pid

计算pid占用的cpu、内存、端口等资源信息

```golang
package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

// 配置文件结构体
type Config struct {
	IP      string `json:"ip"`
	AppName string `json:"appName"`
	AppId   string `json:"appId"`
	AppType string `json:"appType"`
	Disk    string `json:"disk"`
	JarName string `json:"jarName"`
	ApiUrl  string `json:"apiUrl"`
}

// 上报数据结构体
type Metrics struct {
	IP      string `json:"ip"`
	AppName string `json:"appName"`
	AppId   string `json:"appId"`
	AppType string `json:"appType"`
	Pid     string `json:"pid"`
	Status  string `json:"status"`
	Cpu     string `json:"cpu"`
	Memory  string `json:"mem"`
	Ports   string `json:"ports"`
	Disk    string `json:"disk"`
}

// 设置tcp长连接
var HTTPTransport = &http.Transport{
	DialContext: (&net.Dialer{
		Timeout:   5 * time.Second,
		KeepAlive: 60 * time.Second,
	}).DialContext,
	MaxIdleConns:          500,
	IdleConnTimeout:       60 * time.Second,
	ExpectContinueTimeout: 10 * time.Second,
	MaxIdleConnsPerHost:   100,
	TLSClientConfig:       &tls.Config{InsecureSkipVerify: true},
}

func main() {
	// 1. 读取配置文件
	config, err := loadConfig("config.json")
	if err != nil {
		log.Fatalf("加载配置文件失败: %v", err)
	}

	// 2. 获取Java进程PID
	pid, status, err := getJavaPID(config.JarName)
	if err != nil {
		log.Fatalf("获取进程PID失败: %v", err)
	}
	if pid == "" {
		log.Println("未找到运行的Java进程")
		//	return
	}

	// 采集资源
	cpuUsage, err := getCPUUsage(pid)
	if err != nil {
		log.Printf("获取CPU使用率失败: %v%", err)
	}

	processMem, totalMem, err := getMemoryInfo(pid)
	if err != nil {
		log.Printf("获取内存信息失败: %v", err)
	} else {
		log.Printf("进程内存: %.2f MB, 总内存: %.2f MB\n", processMem, totalMem)
	}

	ports, err := getPorts(pid)
	if err != nil {
		log.Printf("获取端口失败: %v", err)
	}

	// 格式化内存信息为 "进程内存/总内存"
	memoryInfo := fmt.Sprintf("%.0fMB/%.0fMB", processMem, totalMem)

	// 准备上报数据
	metrics := Metrics{
		IP:      config.IP,
		AppName: config.AppName,
		AppId:   config.AppId,
		AppType: config.AppType,
		Pid:     pid,
		Status:  status,
		Cpu:     cpuUsage,
		Memory:  memoryInfo,
		Disk:    config.Disk,
		Ports:   ports,
	}

	// 打印上报JSON数据
	jsonData, err := json.MarshalIndent(metrics, "", "  ")
	if err != nil {
		log.Printf("JSON格式化失败: %v", err)
	} else {
		log.Println("准备上报的数据:")
		fmt.Println(string(jsonData))
	}
	// 上报数据
	err = reportMetrics(config.ApiUrl, metrics)
	if err != nil {
		log.Printf("上报数据失败: %v", err)
	} else {
		log.Println("数据上报成功")
	}
}

// 加载配置文件
func loadConfig(filename string) (*Config, error) {
	file, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	config := &Config{}
	err = json.Unmarshal(file, config)
	if err != nil {
		return nil, err
	}

	return config, nil
}

// 获取Java进程PID
func getJavaPID(jarName string) (string, string, error) {
	cmd := exec.Command("wmic", "process", "where",
		"name='java.exe'", "get", "processid,commandline")

	output, err := cmd.Output()
	if err != nil {
		return "", "dead", fmt.Errorf("执行WMIC命令失败: %w", err)
	}

	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		if strings.Contains(line, "ProcessId") || strings.TrimSpace(line) == "" {
			continue
		}

		if strings.Contains(line, jarName) {
			fields := strings.Fields(line)
			if len(fields) > 0 {
				pid := fields[len(fields)-1]
				return pid, "running", nil
			}
		}
	}

	return "", "dead", nil
}

// 获取CPU使用率
func getCPUUsage(pid string) (string, error) {
	if pid == "" {
		return "0", nil
	}
	cmd := exec.Command("wmic", "path", "Win32_PerfFormattedData_PerfProc_Process", "where",
		fmt.Sprintf("IDProcess='%s'", pid), "get", "PercentProcessorTime")
	output, err := cmd.Output()
	if err != nil {
		return "0", err
	}

	lines := strings.Split(string(output), "\n")
	if len(lines) > 1 {
		value := strings.TrimSpace(lines[1])
		if value != "" {
			// 转换为百分比字符串
			return value, nil
		}
	}
	return "0", nil
}

// 获取内存信息：返回进程内存和总内存（单位MB）
func getMemoryInfo(pid string) (processMem float64, totalMem float64, err error) {

	// 获取进程内存
	processMem, err = getProcessMemory(pid)
	if err != nil {
		return 0, 0, err
	}

	// 获取系统总内存
	totalMem, err = getTotalMemory()
	if err != nil {
		return processMem, 0, err
	}

	return processMem, totalMem, nil
}

// 获取进程内存使用（MB）
func getProcessMemory(pid string) (float64, error) {
	if pid == "" {
		return 0, nil
	}
	cmd := exec.Command("wmic", "process", "where",
		fmt.Sprintf("ProcessId='%s'", pid), "get", "WorkingSetSize")

	output, err := cmd.Output()
	if err != nil {
		return 0, err
	}

	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" && line != "WorkingSetSize" {
			memBytes, err := strconv.ParseUint(line, 10, 64)
			if err != nil {
				return 0, err
			}
			return float64(memBytes) / (1024 * 1024), nil
		}
	}
	return 0, nil
}

// 获取系统总内存（MB）
func getTotalMemory() (float64, error) {
	cmd := exec.Command("wmic", "ComputerSystem", "get", "TotalPhysicalMemory")
	output, err := cmd.Output()
	if err != nil {
		return 0, err
	}

	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" && line != "TotalPhysicalMemory" {
			totalBytes, err := strconv.ParseUint(line, 10, 64)
			if err != nil {
				return 0, err
			}
			return float64(totalBytes) / (1024 * 1024), nil
		}
	}
	return 0, nil
}

func getPorts(pid string) (string, error) {
	if pid == "" {
		return "", nil
	}
	cmd := exec.Command("netstat", "-ano")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	var ports []string
	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		// 只处理 LISTENING 状态的连接
		if strings.Contains(line, "LISTENING") && strings.Contains(line, " "+pid) {
			fields := strings.Fields(line)
			if len(fields) > 2 {
				addr := fields[1]
				parts := strings.Split(addr, ":")
				if len(parts) > 1 {
					port := parts[len(parts)-1]
					ports = append(ports, port)
				}
			}
		}
	}

	// 去重
	portMap := make(map[string]bool)
	for _, port := range ports {
		portMap[port] = true
	}

	var uniquePorts []string
	for port := range portMap {
		uniquePorts = append(uniquePorts, port)
	}

	return strings.Join(uniquePorts, ","), nil
}

// 上报数据
func reportMetrics(apiUrl string, metrics Metrics) error {
	jsonData, err := json.Marshal(metrics)
	if err != nil {
		return err
	}

	// client := &http.Client{Timeout: 10 * time.Second}
	// 优化tcp
	client := http.Client{Transport: HTTPTransport}
	resp, err := client.Post(apiUrl, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("API返回错误状态码: %d", resp.StatusCode)
	}
	return nil
}

```

‍

```
{
"ip": "192.168.123.123",
"appName": "tssingle",
"appId": "tssingle-192.168.123.123",
"appType": "tssingle",
"disk": "500M/200G", 
"jarName": "helloworld.jar",
"apiUrl": "http://192.168.133.102:49101/monitor/drm/reportClusterStatus"
}
```


更新 20250618
```golang

```
#go




```bash
package main

import (
	"log"
	"net"
	"net/netip"

	"github.com/mdlayher/arp"
	"github.com/mdlayher/ethernet"
)

func main() {
	// 替换为你的网络接口名、MAC地址和IP地址
	ifaceName := "wlan0"
	srcMAC, _ := net.ParseMAC("28:7f:cf:23:fa:14")
	srcIP := netip.MustParseAddr("192.168.1.5")

	// 获取网络接口
	iface, err := net.InterfaceByName(ifaceName)
	if err != nil {
		log.Fatalf("无法获取接口: %v", err)
	}

	// 创建ARP客户端
	client, err := arp.Dial(iface)
	if err != nil {
		log.Fatalf("创建ARP客户端失败: %v", err)
	}
	defer client.Close()

	// 构造GARP请求（操作码1表示请求）
	packet := &arp.Packet{
		HardwareType:       1, // 以太网
		Operation:          arp.OperationRequest,
		SenderHardwareAddr: srcMAC,
		SenderIP:           srcIP,
		TargetHardwareAddr: ethernet.Broadcast, // 广播MAC地址
		TargetIP:           srcIP,              // 目标IP与源IP相同
	}

	// 发送GARP包（可能需要root权限）
	if err := client.WriteTo(packet, ethernet.Broadcast); err != nil {
		log.Fatalf("发送失败: %v", err)
	}

	log.Println("GARP包已发送！")
}

```

更新：
> 使用配置文件

```go
package main

import (
	"encoding/json"
	"log"
	"net"
	"net/netip"
	"os"

	"github.com/mdlayher/arp"
	"github.com/mdlayher/ethernet"
)

// Config 结构体用于解析JSON配置文件
type Config struct {
	IP        string `json:"ip"`
	MAC       string `json:"mac"`
	Interface string `json:"interface"`
}

func main() {
	// 加载配置文件
	config, err := loadConfig("config.json")
	if err != nil {
		log.Fatalf("加载配置文件失败: %v", err)
	}

	ifaceName := config.Interface
	srcMAC, _ := net.ParseMAC(config.MAC)
	srcIP := netip.MustParseAddr(config.IP)

	// 获取网络接口
	iface, err := net.InterfaceByName(ifaceName)
	if err != nil {
		log.Fatalf("无法获取接口: %v", err)
	}

	// 创建ARP客户端
	client, err := arp.Dial(iface)
	if err != nil {
		log.Fatalf("创建ARP客户端失败: %v", err)
	}
	defer client.Close()

	// 构造GARP请求（操作码1表示请求）
	packet := &arp.Packet{
		HardwareType:       1, // 以太网
		Operation:          arp.OperationRequest,
		SenderHardwareAddr: net.HardwareAddr(srcMAC),
		SenderIP:           srcIP,
		TargetHardwareAddr: ethernet.Broadcast, // 广播MAC地址
		TargetIP:           srcIP,              // 目标IP与源IP相同
	}

	// 发送GARP包（可能需要root权限）
	if err := client.WriteTo(packet, ethernet.Broadcast); err != nil {
		log.Fatalf("发送失败: %v", err)
	}

	log.Println("GARP包已发送！")
}

// loadConfig 从JSON文件加载配置
func loadConfig(path string) (*Config, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var config Config
	if err := json.NewDecoder(file).Decode(&config); err != nil {
		return nil, err
	}

	return &config, nil
}

```

```go
# cat config.json 

{
"ip":"192.168.1.31",
"mac":"28:7f:cf:23:fa:14",
"interface":"wlan0"
}

```

更新
> 使用命令行传参

```go
package main
import (
"flag"
"fmt"
"log"
"net"
"net/netip"

"github.com/mdlayher/arp"
"github.com/mdlayher/ethernet"

)


func main() {

// 定义命令行参数
ifaceName := flag.String("i", "", "网络接口名 (如 eth0)")
macStr := flag.String("m", "", "源MAC地址 (如 00:11:22:33:44:55)")
ipStr := flag.String("ip", "", "源IP地址 (如 192.168.1.100)")

flag.Parse()

// 验证必需参数
if *ifaceName == "" || *macStr == "" || *ipStr == "" {
fmt.Println("错误：缺少必需参数")
fmt.Println("用法示例:")
flag.PrintDefaults()
log.Fatalln("退出：参数不完整")

}

// 解析MAC地址
srcMAC, err := net.ParseMAC(*macStr)
if err != nil {
log.Fatalf("MAC地址解析失败: %v", err)
}

// 解析IP地址
srcIP, err := netip.ParseAddr(*ipStr)
if err != nil {
log.Fatalf("IP地址解析失败: %v", err)
}

// 获取网络接口
iface, err := net.InterfaceByName(*ifaceName)
if err != nil {
log.Fatalf("无法获取接口: %v", err)
}

// 创建ARP客户端
client, err := arp.Dial(iface)
if err != nil {
log.Fatalf("创建ARP客户端失败: %v", err)
}

defer client.Close()

// 构造GARP请求
packet := &arp.Packet{
HardwareType: 1, // 以太网
Operation: arp.OperationRequest,
SenderHardwareAddr: srcMAC,
SenderIP: srcIP,
TargetHardwareAddr: ethernet.Broadcast, // 广播地址
TargetIP: srcIP, // 目标IP与源IP相同

}

// 发送GARP包
if err := client.WriteTo(packet, ethernet.Broadcast); err != nil {
log.Fatalf("发送失败: %v", err)
}

log.Printf("GARP包已通过接口 %s 发送! 源IP: %s, 源MAC: %s\n", *ifaceName, srcIP, srcMAC)

}
```

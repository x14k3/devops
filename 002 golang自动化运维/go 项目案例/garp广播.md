# garp广播

需求：vip漂移后，局域网中的其他机器无法ping通vip，参考garp（[无偿ARP的作用与原理](013%20计算机网络/网络协议/虚拟IP与ARP协议/无偿ARP的作用与原理.md)），发送广播

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

- 使用配置文件

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
note:/home/sds/work/GOPATH/ztools # cat config.json 

{
"ip":"192.168.1.31",
"mac":"28:7f:cf:23:fa:14",
"interface":"wlan0"
}

```

# json

* 序列化：将结构体转为string
* 反序列化：将string转为结构体

　　后端多机数据交换时为字符串，需要将数据转化为字符串的形式，类似xml、html等，Go语言中发送方只要把结构体数据转化为字符串，接收方收到解码就可得到原始数据格式。

## 主要的json库

* go语言自带的encoding/json：

  * 使用简单、速度感人
* easyjson：

  * 第三方开源库
  * 使用时要先生成对应结构体的操作代码，使用起来比较麻烦
  * 速度快
* sonic

  * 字节跳动技术团队开源
  * 据说一些场景下比easyjson还快很多
  * 使用方便与官网库无缝衔接，0学习成本

　　‍

# encoding/json

## 解析为结构体

### json.Unmarshal

```go
package main

import (
	"encoding/json"
	"log"
	"os"
)

type MonParam struct {
	IpAddress   string   `json:"ipAddress"`
	AppName     []string `json:"appName"`
	ServiceName []string `json:"serviceName"`
	AlarmUrl    string   `json:"alarmUrl"`
}

func main() {
	content, err := os.ReadFile("./config.json")
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}
	var param MonParam
	err = json.Unmarshal(content, &param)
	if err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}

	log.Println(param.IpAddress)
	log.Println(param.AppName)
	log.Println(param.ServiceName)
	log.Println(param.AlarmUrl)

}

```

```go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
)

// json配置文件结构体
type MonParam struct {
	IpAddress   string   `json:"ipAddress"`
	AppName     []string `json:"appName"`
	ServiceName []string `json:"serviceName"`
	PortNum     []string `json:"portNum"`
	AlarmUrl    string   `json:"alarmUrl"`
}

var Param MonParam

func init() {
	//读取配置json配置文件
	content, err := os.ReadFile("./config.json")
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}

	//将json文件解析为结构体
	err = json.Unmarshal(content, &Param)
	if err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}
}

// 检查windows进程
func checkProcess(appName string) bool {

	buf := bytes.Buffer{}
	cmd := exec.Command("wmic", "process", "get", "name,executablepath")
	cmd.Stdout = &buf
	cmd.Run()

	cmd2 := exec.Command("findstr", appName)
	cmd2.Stdin = &buf
	data, _ := cmd2.CombinedOutput()
	if len(data) == 0 {
		return false
	} else {
		return true
	}
}

func main() {
	for _, elem := range Param.AppName {
		if checkProcess(elem) {
			fmt.Println("true")
		} else {
			log.Println("false")
		}
	}
```

　　‍

　　‍

### json.NewDecoder

```bash
package main

import (
	"encoding/json"
	"log"
	"os"
)

type MonParam struct {
	IpAddress   string   `json:"ipAddress"`
	AppName     []string `json:"appName"`
	ServiceName []string `json:"serviceName"`
	AlarmUrl    string   `json:"alarmUrl"`
}

func main() {
	file, err := os.Open("./config.json")
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}
	var param MonParam
	err = json.NewDecoder(file).Decode(&param)
	if err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}

	log.Println(param.IpAddress)
	log.Println(param.AppName)
	log.Println(param.ServiceName)
	log.Println(param.AlarmUrl)

}

```

　　‍

　　‍

　　区别：

　　 1、json.NewDecoder是从一个`流`​里面直接进行解码，代码精干；  
 2、json.Unmarshal是从已存在与内存中的json进行解码；  
 3、相对于解码，json.NewEncoder进行大JSON的编码比json.marshal性能高，因为内部使用pool。

　　场景应用：

　　 1、json.NewDecoder用于http连接与socket连接的读取与写入，或者文件读取；  
 2、json.Unmarshal用于直接是byte的输入。

　　‍

　　‍

# easyjson

　　[easyjson](https://github.com/mailru/easyjson)是提供高效快速且易用的结构体structs\<--\>json转换包。easyjson并没有使用反射方式实现，所以性能比其他的json包该4-5倍，比golang 自带的json包快2-3倍。 

　　安装

```go
go get -u github.com/mailru/easyjson/
go install  github.com/mailru/easyjson/easyjson
#or
go build -o easyjson github.com/mailru/easyjson/easyjson  # 会在当前目录下生成easyjson二进制文件
```

　　使用步骤：

　　1、定义结构体，每个结构体注释里标注 //easyjson:json或者 //ffjson: skip；  
2、使用 easyjson或者ffjson命令将指定目录的go结构体文件生成带有Marshal、Unmarshal方法的新文件；  
3、代码里如果需要进行生成JSON或者解析JSON，调用生成文件的 Marshal、Unmarshal方法即可。

　　**定义结构体：**   
记得在需要使用easyjson的结构体上加上//easyjson:json。 如下：

```go
//easyjson:json
type Telnet struct {
	logpath string		`json:"logpath"`
	telnet string		`json:"telnet"`
	address string      `json:"address"`
}

```

　　**在结构体包下执行**  
​`easyjson -all 车此刻——interface.go`​  # golang文件名  
此时在该目录下出现一个新的文件：check_interface_easyjson.go，该文件给结构体增加了MarshalJSON、UnmarshalJSON等方法。

　　**使用**

```go
package main
 
import (
    "studygo/easyjson"
    "time"
    "fmt"
)
 
func main(){
    s:=easyjson.Student{
        Id: 11,
        Name:"qq",
        School:easyjson.School{
            Name:"CUMT",
            Addr:"xz",
        },
        Birthday:time.Now(),
    }
    bt,err:=s.MarshalJSON()
    fmt.Println(string(bt),err)
  
    json:=`{"id":11,"s_name":"qq","s_chool":{"name":"CUMT","addr":"xz"},"birthday":"2017-08-04T20:58:07.9894603+08:00"}`
    ss:=easyjson.Student{}
    ss.UnmarshalJSON([]byte(json))
    fmt.Println(ss)
}
```

　　**运行结果：**

```go
{"id":11,"s_name":"qq","s_chool":{"name":"CUMT","addr":"xz"},"birthday":"2017-08-04T20:58:07.9894603+08:00"} 
```

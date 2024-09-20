# 获取http状态码

```bash
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/go-resty/resty/v2"
)

// json配置文件结构体
type Param struct {
	Logpath string `json:"logpath"`
	Website string `json:"Website"`
}

var param Param

func init() {
	//读取配置json配置文件
	content, err := os.ReadFile("./config.json")
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}

	//将json文件解析为结构体
	err = json.Unmarshal(content, &param)
	if err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}
}

func main() {
	Logfile, _ := os.Create(param.Logpath)
	client := resty.New()

	resp, err := client.R().Get(param.Website)

	if err != nil {
		log.Fatal(err)
	}

	if resp.StatusCode() == 200 {
		fmt.Fprint(Logfile, "true")
	} else {
		fmt.Fprint(Logfile, "false")
	}
}

```

```bash

{
"logpath": "/data/application/golang/goProject/src/hess-monitor/test/test.log",
"Website": "http://www.baidu.com"
}
```

# resty

​[`resty`](https://github.com/go-resty/resty)​是 Go 语言的一个 HTTP client 库。`resty`​功能强大，特性丰富。它支持几乎所有的 HTTP 方法（GET/POST/PUT/DELETE/OPTION/HEAD/PATCH等），并提供了简单易用的 API。

创建目录并初始化：

```bash
mkdir resty && cd resty
go mod init github.com/darjun/go-daily-lib/resty
```

安装`resty`​库：

```cmd
go get -u github.com/go-resty/resty/v2
```

下面我们来获取百度首页信息：

```golang
package main

import (
  "fmt"
  "log"

  "github.com/go-resty/resty/v2"
)

func main() {
  client := resty.New()

  resp, err := client.R().Get("https://baidu.com")

  if err != nil {
    log.Fatal(err)
  }

  fmt.Println("Response Info:")
  fmt.Println("Status Code:", resp.StatusCode())
  fmt.Println("Status:", resp.Status())
  fmt.Println("Proto:", resp.Proto())
  fmt.Println("Time:", resp.Time())
  fmt.Println("Received At:", resp.ReceivedAt())
  fmt.Println("Size:", resp.Size())
  fmt.Println("Headers:")
  for key, value := range resp.Header() {
    fmt.Println(key, "=", value)
  }
  fmt.Println("Cookies:")
  for i, cookie := range resp.Cookies() {
    fmt.Printf("cookie%d: name:%s value:%s\n", i, cookie.Name, cookie.Value)
  }
}
```

​`resty`​使用比较简单。

- 首先，调用一个`resty.New()`​创建一个`client`​对象；
- 调用`client`​对象的`R()`​方法创建一个请求对象；
- 调用请求对象的`Get()/Post()`​等方法，传入参数 URL，就可以向对应的 URL 发送 HTTP 请求了。返回一个响应对象；
- 响应对象提供很多方法可以检查响应的状态，首部，Cookie 等信息。

上面程序中我们获取了：

- ​`StatusCode()`​：状态码，如 200；
- ​`Status()`​：状态码和状态信息，如 200 OK；
- ​`Proto()`​：协议，如 HTTP/1.1；
- ​`Time()`​：从发送请求到收到响应的时间；
- ​`ReceivedAt()`​：接收到响应的时刻；
- ​`Size()`​：响应大小；
- ​`Header()`​：响应首部信息，以`http.Header`​类型返回，即`map[string][]string`​；
- ​`Cookies()`​：服务器通过`Set-Cookie`​首部设置的 cookie 信息。

运行程序输出的响应基本信息：

```golang
Response Info:
Status Code: 200
Status: 200 OK
Proto: HTTP/1.1
Time: 415.774352ms
Received At: 2021-06-26 11:42:45.307157 +0800 CST m=+0.416547795
Size: 302456
```

首部信息：

```golang
Headers:
Server = [BWS/1.1]
Date = [Sat, 26 Jun 2021 03:42:45 GMT]
Connection = [keep-alive]
Bdpagetype = [1]
Bdqid = [0xf5a61d240003b218]
Vary = [Accept-Encoding Accept-Encoding]
Content-Type = [text/html;charset=utf-8]
Set-Cookie = [BAIDUID=BF2EE47AAAF7A20C6971F1E897ABDD43:FG=1; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com BIDUPSID=BF2EE47AAAF7A20C6971F1E897ABDD43; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com PSTM=1624678965; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com BAIDUID=BF2EE47AAAF7A20C716E90B86906D6B0:FG=1; max-age=31536000; expires=Sun, 26-Jun-22 03:42:45 GMT; domain=.baidu.com; path=/; version=1; comment=bd BDSVRTM=0; path=/ BD_HOME=1; path=/ H_PS_PSSID=34099_31253_34133_34072_33607_34135_26350; path=/; domain=.baidu.com]
Traceid = [1624678965045126810617700867425882583576]
P3p = [CP=" OTI DSP COR IVA OUR IND COM " CP=" OTI DSP COR IVA OUR IND COM "]
X-Ua-Compatible = [IE=Edge,chrome=1]
```

注意其中有一个`Set-Cookie`​首部，这部分内容会出现在 Cookie 部分：

```golang
Cookies:
cookie0: name:BAIDUID value:BF2EE47AAAF7A20C6971F1E897ABDD43:FG=1
cookie1: name:BIDUPSID value:BF2EE47AAAF7A20C6971F1E897ABDD43
cookie2: name:PSTM value:1624678965
cookie3: name:BAIDUID value:BF2EE47AAAF7A20C716E90B86906D6B0:FG=1
cookie4: name:BDSVRTM value:0
cookie5: name:BD_HOME value:1
cookie6: name:H_PS_PSSID value:34099_31253_34133_34072_33607_34135_26350
```

[获取http状态码](002%20golang自动化运维/go%20项目案例/获取http状态码.md)

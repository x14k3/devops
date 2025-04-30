# http

Golang提供了官方的http包，对于http操作非常的方便和简洁。

## get 请求

get请求有好几种方式

#### 直接使用`net/http`​包内的函数请求

```go
import "net/http"
...
resp, err := http.Get("http://wwww.baidu.com")
```

#### 利用http.client结构体来请求

```go
import "net/http"
...
clt := http.Client{}
resp, err := clt.Get("http://wwww.baidu.com")
```

#### 最本质的请求方式

如果稍微看一下源码，就会发现以上两种方式都是用了一下这种最本质的请求方式，使用`http.NewRequest`​函数

```go
req, err := http.NewRequest("GET", "http://www.baidu.com", nil)

//然后http.client 结构体的 Do 方法
//http.DefaultClient可以换为另外一个http.client
resp, err := http.DefaultClient.Do(req)
```

Go的get请求面上有好几种请求方式，实则只有一种：

1、使用`http.NewRequest`​函数获得`request`​实体

2、利用`http.client`​结构体的`Do`​方法，将`request`​实体传入`Do`​方法中。

```go
func check_heartbeat() {
	data := url.Values{"ip": {viper.GetString("ip")}, "appName": {viper.GetString("app")}, "status": {"heartbeat"}}
	req, err := http.NewRequest("POST", viper.GetString("alarm"), strings.NewReader(data.Encode()))
	if err != nil {
		fmt.Println("创建POST请求失败:", err)
		return
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("发送POST请求失败:", err)
		return
	}
	defer resp.Body.Close()
	_, err = io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("读取响应内容失败:", err)
		return
	}
	fmt.Println("heartbeatPost... ok")
	return
}

```

## post请求

和get请求类似，post请求也有多种方法，但本质还是使用了`http.NewRequest`​函数和`http.client`​的`Do`​方法。

#### 使用`net/http`​包带的post方法

```go
import (
"net/http"
"net/url"
)
...
data := url.Values{"start":{"0"}, "offset":{"xxxx"}}
body := strings.NewReader(data.Encode())
resp, err := http.Post("xxxxxxx", "application/x-www-form-urlencoded", body)
```

或者还可以

```go
import (
"net/http"
"net/url"
)
...
var r http.Request
r.ParseForm()
r.Form.Add("xxx", "xxx")
body := strings.NewReader(r.Form.Encode())
http.Post("xxxx", "application/x-www-form-urlencoded", body)
```

要是还是觉得复杂，还可以：

```go
import (
"net/http"
"net/url"
)
...
data := url.Values{"start":{"0"}, "offset":{"xxxx"}}
http.PostForm("xxxx", data)
```

#### 使用实例化的http client的post方法

其实本质上直接使用包的函数和实例化的http client是一样的，包的函数底层也仅仅是实例化了一个`DefaultClient`​，然后调用的`DefaultClient`​的方法。下面给出使用实例化的http client的post方法：

```go
import (
"net/http"
"net/url"
)
...
data := url.Values{"start":{"0"}, "offset":{"xxxx"}}
body := strings.NewReader(data.Encode())
clt := http.Client{}
resp, err := clt.Post("xxxxxxx", "application/x-www-form-urlencoded", body)
```

还有

```go
import (
"net/http"
"net/url"
)
...
var r http.Request
r.ParseForm()
r.Form.Add("xxx", "xxx")
body := strings.NewReader(r.Form.Encode())
clt := http.Client{}
clt.Post("xxxx", "application/x-www-form-urlencoded", body)
```

简单的，但仅限于form表单

```go
import (
"net/http"
"net/url"
)
...
data := url.Values{"start":{"0"}, "offset":{"xxxx"}}
clt := http.Client{}
clt.PostForm("xxxx", data)
```

#### 使用`net/http`​包的`NewRequest`​函数

其实不管是get方法也好，post方法也好，所有的get、post的的http 请求形式，最终都是会调用`net/http`​包的`NewRequest`​函数，多种多样的请求形式，也仅仅是封装的不同而已。

```go
import (
"net/http"
"net/url"
)
...

data := url.Values{"start":{"0"}, "offset":{"xxxx"}}
body := strings.NewReader(data.Encode())

req, err := http.NewRequest("POST", "xxxxx", body)
req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

clt := http.Client{}
clt.Do(req)
```

​`net/http`​包没有封装直接使用请求带header的get或者post方法，所以，要想请求中带header，只能使用`NewRequest`​方法。

```go
import (
"net/http"

)
...

req, err := http.NewRequest("POST", "xxxxx", body)
//此处还可以写req.Header.Set("User-Agent", "myClient")
req.Header.Add("User-Agent", "myClient")

clt := http.Client{}
clt.Do(req)
```

有一点需要注意：在添加header操作的时候，`req.Header.Add`​和`req.Header.Set`​都可以，但是在修改操作的时候，只能使用`req.Header.Set`​。
这俩方法是有区别的，Golang底层Header的实现是一个`map[string][]string`​，`req.Header.Set`​方法如果原来Header中没有值，那么是没问题的，如果又值，会将原来的值替换掉。而`req.Header.Add`​的话，是在原来值的基础上，再`append`​一个值，例如，原来header的值是“s”，我后`req.Header.Add`​一个”a”的话，变成了`[s a]`​。但是，获取header值的方法`req.Header.Get`​确只取第一个，所以，如果原来有值，重新`req.Header.Add`​一个新值的话，`req.Header.Get`​得到的值不变。

## 打印response响应

Golang打印response没有PHP那么爽，哎，编译型语言就是麻烦。

```go
import (
	"net/http"
	"net/url"
	"io/ioutil"
)
...
content, err := ioutil.ReadAll(resp.Body)
respBody := string(content)
```

## 使用cookie

Golang提供了cookie的包`net/http/cookiejar`​

```go
...

url, err := url.Parse("https://www.wukong.com/")
jar, err := cookiejar.New(nil)
jar.SetCookies(url, cookies)//这里的cookies是[]*http.Cookie
wukongClt := http.Client{Transport:nil, Jar:jar}

wukongClt.Get("xxxxx")
```

文中的`cookies`​类型是`[] *http.cookie`​可以自己实例化，有时候也可以从`response`​中直接使用`resp.Cookies()`​直接拿到。

Golang的cookie是和`http.client`​联系在一起的，作为`http.client`​的一个属性存在。因此，要想在Golang中使用cookie，就必须想办法构造`http.client`​

## 使用代理

在Golang中使用http proxy，也必须构造自己的`http.client`​，需要将`http.client`​结构体的一个属性`Transport`​自己实例化好。

#### 当使用环境变量$http\_proxy或$HTTP\_PROXY作为代理时

```go
//从环境变量$http_proxy或$HTTP_PROXY中获取HTTP代理地址
func GetTransportFromEnvironment() (transport *http.Transport) {
	transport = &http.Transport{Proxy : http.ProxyFromEnvironment}
	return
}
```

#### 当使用自己搭建http代理时

参数`proxy_addr`​即代理服务器IP端口号，例如：”[http://xxx.xxx.xxx.xxx:6000“，注意，必须加上&quot;http&quot;](https://i6448038.github.io/2017/11/11/httpAndGolang//http://xxx.xxx.xxx.xxx:6000“，注意，必须加上)

```go
func GetTransportFieldURL(proxy_addr *string) (transport *http.Transport) {
	url_i := url.URL{}
	url_proxy, error := url_i.Parse(*proxy_addr)
	if error != nil{
		fmt.Println(error.Error())
	}
	transport = &http.Transport{Proxy : http.ProxyURL(url_proxy)}
	return
}
```

使用的时候，首先调用函数，拿到对应的`transport`​，即使用`GetTransportFieldURL`​或者`GetTransportFieldURL`​函数，然后构建自定义的`http.client`​ :

```go
ProxyUrl := "http://xxx.xxx.xxx.xxx:6000"
transport := GetTransportFieldURL(&ProxyUrl)
clt := http.Client{Transport:transport}

clt.Get("http://www.baidu.com")
```

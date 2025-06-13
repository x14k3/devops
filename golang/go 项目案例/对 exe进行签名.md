#go

在 Windows 上为 Go 编译的 EXE 文件进行数字签名是确保软件可信度和安全性的重要步骤。以下是完整的签名流程：

### 准备工作

1. **获取代码签名证书**：

    - 从受信任的证书颁发机构（CA）如 DigiCert、Sectigo、GlobalSign 购买
    - 或使用企业内部证书颁发机构（用于内部分发）
2. **安装签名工具**：

    - 安装 Windows SDK（包含 signtool.exe）
    - 或使用跨平台工具 [osslsigncode](https://github.com/mtrojnar/osslsigncode)

---

### 方法一：使用 signtool.exe（Windows 原生）

powershell

```
# 编译 Go 程序
go build -o myapp.exe main.go

# 签名命令
signtool sign ^
  /f "C:\path\to\certificate.pfx" ^
  /p "证书密码" ^
  /fd sha256 ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  "myapp.exe"
```

#### 参数说明：

- ​`/f`​：PFX 证书文件路径
- ​`/p`​：证书密码
- ​`/fd`​：文件摘要算法（推荐 SHA256）
- ​`/tr`​：时间戳服务器 URL（防止证书过期后签名失效）
- ​`/td`​：时间戳摘要算法

#### 常用时间戳服务器：

- DigiCert：`http://timestamp.digicert.com`​
- Sectigo：`http://timestamp.sectigo.com`​
- GlobalSign：`http://timestamp.globalsign.com/scripts/timstamp.dll`​

#### 验证签名：

powershell

```
signtool verify /v /pa myapp.exe
```

---

### 方法二：使用 osslsigncode（跨平台方案）

适用于 Linux/macOS 环境下签名 Windows EXE

1. **安装 osslsigncode**：  
    bash

    ```
    # Ubuntu/Debian
    sudo apt install osslsigncode

    # macOS
    brew install osslsigncode
    ```
2. **签名命令**：  
    bash

    ```
    osslsigncode sign \
      -pkcs12 "/path/to/certificate.pfx" \
      -pass "证书密码" \
      -n "应用名称" \
      -i "https://yourwebsite.com" \
      -ts http://timestamp.digicert.com \
      -h sha256 \
      -in myapp.exe \
      -out myapp-signed.exe
    ```

---

### 方法三：Go 代码内集成签名（高级）

使用 Go 调用签名工具（需提前安装依赖）：

go

```
package main

import (
	"os"
	"os/exec"
)

func signExe(exePath string) error {
	cmd := exec.Command(
		"signtool", "sign",
		"/f", "C:\\certs\\mycert.pfx",
		"/p", os.Getenv("CERT_PASSWORD"),
		"/tr", "http://timestamp.digicert.com",
		"/td", "sha256",
		exePath,
	)
	return cmd.Run()
}

func main() {
	// 编译后自动签名
	if os.Getenv("GOOS") == "windows" {
		if err := signExe("myapp.exe"); err != nil {
			panic("签名失败: " + err.Error())
		}
	}
}
```

---

### 自动化签名方案（推荐）

创建 `sign.bat`​ 脚本：

batch

```
@echo off
setlocal

set "CERT_PATH=C:\certs\your_cert.pfx"
set "CERT_PASS=your_password"
set "TIMESTAMP_URL=http://timestamp.digicert.com"

echo 正在签名 %1 ...
signtool sign /f "%CERT_PATH%" /p %CERT_PASS% /fd sha256 /tr %TIMESTAMP_URL% /td sha256 %1

echo 验证签名...
signtool verify /v /pa %1

endlocal
```

使用方式：

bash

```
go build -o app.exe
sign.bat app.exe
```

---

### 重要注意事项

1. **证书类型**：

    - 个人开发者：OV（组织验证）或 EV（扩展验证）代码签名证书
    - 企业用户：最好使用 EV 证书（立即获得微软 SmartScreen 信任）
2. **签名时效**：

    - 必须添加时间戳，否则证书过期后签名将失效
    - SHA-256 签名兼容 Windows 10/11 和现代操作系统
3. **安全实践**：

    - 永远不要将证书密码硬编码在源码中
    - 使用环境变量或密钥管理系统存储密码
    - CI/CD 系统中使用临时证书副本
4. **签名验证**：

    - 右键 EXE 文件 \> 属性 \> 数字签名
    - 使用 `signtool verify /v /pa filename.exe`​
5. **驱动签名**：

    - 内核驱动需使用交叉证书签名（流程不同）
    - 推荐使用 [https://github.com/mitchellh/gon](https://github.com/mitchellh/gon) 简化流程

遵循这些步骤可确保你的 Go 应用程序获得操作系统和杀毒软件的信任，减少安全警告，提升用户安装率。

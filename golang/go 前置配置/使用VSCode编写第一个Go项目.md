#go

## 1. 准备工作

[Linux下配置VSCode的Go开发环境](Go%20语言环境安装/Linux下配置VSCode的Go开发环境.md)

[Windows下配置VSCode的Go开发环境](Go%20语言环境安装/Windows下配置VSCode的Go开发环境.md)

确保你已经完成：

- 安装Go语言环境（`go version`​能正确显示版本）
- 安装VSCode及Go扩展
- 安装必要的Go工具（gopls、dlv等）

## 2. 创建项目目录

1. 打开终端（VSCode中按Ctrl+\`）
2. 创建项目目录：

    ```
    mkdir -p ~/go/src/hello-world
    cd ~/go/src/hello-world
    ```

## 3. 初始化Go模块

1. 在终端中运行：

    ```
    go mod init hello-world
    ```

    这将创建`go.mod`​文件，用于管理项目依赖

## 4. 创建主程序文件

1. 在VSCode中：

    - 点击"文件" → "打开文件夹"，选择刚才创建的`hello-world`​目录
    - 点击"新建文件"按钮，创建`main.go`​
2. 在`main.go`​中输入以下代码：

    ```go
    package main

    import "fmt"

    func main() {
    	fmt.Println("Hello, World!")
    	fmt.Println("这是我的第一个Go程序！")

    	// 计算并显示两个数字的和
    	a, b := 5, 7
    	sum := a + b
    	fmt.Printf("%d + %d = %d\n", a, b, sum)
    }
    ```

## 5. 运行程序

有几种方式可以运行你的第一个Go程序：

### 方法1：使用VSCode运行

1. 确保`main.go`​文件是打开状态
2. 按F5键开始调试运行
3. 或点击右上角的"Run"三角按钮

### 方法2：使用终端命令

```
go run .
```

### 方法3：构建后运行

```
go build -o hello
./hello
```

## 6. 添加更多功能

让我们扩展这个程序，添加一个简单的函数：

1. 修改`main.go`​：

    ```
    package main

    import (
        "fmt"
        "math/rand"
        "time"
    )

    // 生成随机数函数
    func generateRandomNumber(max int) int {
        rand.Seed(time.Now().UnixNano())
        return rand.Intn(max)
    }

    func main() {
        fmt.Println("欢迎来到我的第一个Go程序！")

        // 调用随机数函数
        randomNum := generateRandomNumber(100)
        fmt.Printf("随机数(0-99): %d\n", randomNum)

        // 条件判断
        if randomNum > 50 {
            fmt.Println("这个数大于50")
        } else {
            fmt.Println("这个数小于等于50")
        }
    }
    ```
2. 再次运行程序查看效果

## 7. 调试程序

VSCode提供了强大的调试功能：

1. 在代码行号左侧点击设置断点（红色圆点）
2. 按F5启动调试
3. 使用调试工具栏：

    - 继续(F5)
    - 单步跳过(F10)
    - 单步进入(F11)
    - 查看变量值

## 8. 添加测试

1. 新建文件`main_test.go`​：

    ```
    package main

    import "testing"

    func TestGenerateRandomNumber(t *testing.T) {
        num := generateRandomNumber(100)
        if num < 0 || num >= 100 {
            t.Errorf("生成的随机数%d不在0-99范围内", num)
        }
    }
    ```
2. 运行测试：

    - 右键测试文件选择"Run Test"
    - 或在终端中：

      ```
      go test -v
      ```

## 9. 项目结构

你的第一个项目现在应该有以下结构：

```
hello-world/
├── go.mod       # 模块定义文件
├── main.go      # 主程序文件
└── main_test.go # 测试文件
```

## 10. 常用快捷键

- 格式化代码：Shift+Alt+F
- 快速修复：Ctrl+.
- 转到定义：F12
- 查看引用：Shift+F12
- 重命名符号：F2
- 触发建议：Ctrl+Space

## 下一步建议

1. 学习Go基础语法
2. 尝试添加更多功能：

    - 从用户输入获取数据
    - 读写文件
    - 调用网络请求
3. 探索更多VSCode功能：

    - 代码片段
    - 任务配置
    - 版本控制集成

恭喜你完成了第一个Go项目！现在你可以继续探索Go语言的更多功能了。

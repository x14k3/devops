# 循环语句range

# Go 语言 Range 范围迭代

Go 语言提供了一种经典`for`​循环以外的集合数据迭代方式：Range 范围迭代，使用关键字`range`​表示，其等同于其他程序设计语言中的`forEach`​迭代。范围迭代`range`​可应用于多种 Go 内置数据结构：字符串、数组、切片、哈希表、通道。

## 数组 / 切片

Go 范围迭代`range`​应用于数组/切片时，可以获取数组/切片的索引与对应元素值。以下代码示例展示了使用`range`​范围迭代遍历数组/切片时的几种使用方式：

- 不关心索引与元素
- 遍历获取索引
- 遍历获取索引与对应元素

```go
package main

import "fmt"

func main() {
    s := []int{1, 2, 3,}
    for range s {
        fmt.Println(s)
    }
    for idx := range s {
        fmt.Println("idx:", idx)
    }
    for idx, elem := range s {
        fmt.Println("idx:", idx, "elem:", elem)
    }
}
```

‍

## 字符串

Go 字符串类型可以看作不可变 UTF-8 字节数组，字符串的`range`​范围迭代与数组/切片类似，可以获取字符串当前字符的起始字节索引与 Unicode 码点（`rune`​类型）。

```
package main

import "fmt"

func main() {
    s := "Golang"
    for range s {
        fmt.Println(s)
    }
    for idx := range s {
        fmt.Println("idx:", idx)
    }
    for idx, r := range s {
        fmt.Println("idx:", idx, "rune:", r)
    }
}
```

‍

## 哈希表

Go 哈希表`map`​是最为常用的容器类型，哈希表遍历操作也是最为基本的操作之一。可以使用`range`​遍历哈希表，并获取当前遍历的键值对。

- 不关心键与值
- 遍历获取键
- 遍历获取键与对应值

需要注意的是，Go 哈希表遍历是**无序**的，Go 团队在设计哈希表的遍历操作时特意引入了随机数以保证遍历的随机性，也是为了告诉 Go 程序员，程序不应依赖于哈希表的有序遍历。

```go
package main

import "fmt"

func main() {
    m := map[string]string{
        "k1": "v1",
        "k2": "v2",
        "k3": "v3",
    }
    for range m {
        fmt.Println(m)
    }
    for k := range m {
        fmt.Println("key:", k)
    }
    for k, v := range m {
        fmt.Println("key:", k, "value", v)
    }
}
```

## 通道

使用`range`​迭代遍历通道（Channel）也是 Go 中较为常见的写法，通道范围迭代语句`for v := range ch {}`​最终会被编译器转换为等价三段`for`​循环的形式：使用`<-ch`​阻塞通道并获值，根据返回的布尔值`hb`​判断当前通道是否被关闭，如果未关闭则赋值`hv`​并执行循环体，而后重新陷入阻塞等待新数据。

```
// for v := range ch {}
for hv, hb := <-ch; hb; hv, hb = <-ch {
    // ...
}
```

## Go 范围迭代注意事项

使用 Go 范围迭代`range`​时有一些事项需要特别注意。

- 迭代变量均为**值拷贝**。
- 数组/切片的范围迭代在**编译时刻**就已确定。
- 迭代时修改迭代对象会发生**不可预期行为**。

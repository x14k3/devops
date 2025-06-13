#go 
‍

## Go 语言 tag 标签的基础介绍是什么？

在 Go 语言中，标签（Tag）是附加到结构体字段的元信息，它是以字符串的形式存储的。这些标签可以通过反射（reflection）机制来获取，并可以被用于各种目的。例如，一些库会使用标签来控制序列化和反序列化，如 JSON 或 XML 库；还有一些库可能会使用标签来进行数据验证或进行数据库到结构体的映射。

以下是在 Go 中定义结构体并添加标签的示例：

```php
type User struct {
 Name    string `json:"name"`
 Email   string `json:"email"`
 Age     int    `json:"age"`
}Copy
```

在这个例子中，`Name`​、`Email`​和`Age`​这三个字段都有一个`json`​标签，这些标签可以被 JSON 库使用，以控制如何将结构体字段编码为 JSON，或者如何从 JSON 解码到这些字段。例如，当你将一个 User 结构体实例编码为 JSON 时，字段的名称会使用标签中指定的名称，而不是结构体中的字段名称。

需要注意的是，标签只有在程序运行时才能通过反射机制来访问，它们不会影响程序的运行性能。此外，标签的解析和使用完全取决于你使用的库或你自己的代码。

## 如何在 Go 语言中定义 tag 标签？[#](https://learnku.com/articles/78000#5ae332)

在 Go 语言中，你可以在定义结构体的时候给字段添加标签（Tag）。标签是一个字符串，它的内容可以被编写成由多个 “键：值” 对组成的格式，每个键值对都用空格分隔。你可以定义自己的键值对，也可以使用一些常见的键，如`json`​，`xml`​等，这些键的含义由相应的库定义。

以下是一个具有多个标签的示例

```php
type Person struct {
 Name    string `json:"name" xml:"name"`
 Email   string `json:"email" xml:"email"`
 Age     int    `json:"age,omitempty" xml:"age,omitempty"`
}Copy
```

在这个例子中，`Name`​，`Email`​，`Age`​这三个字段都有`json`​和`xml`​标签，这些标签可以分别被 JSON 库和 XML 库使用。

当 JSON 库将`Person`​实例编码为 JSON 时，字段的名称会被替换为标签中定义的名称。例如，`Name`​字段在 JSON 中的键名将会是`"name"`​，而不是`"Name"`​。对于`Age`​字段，`omitempty`​选项表示如果该字段的值为空（对于`int`​类型，就是 0），那么在编码为 JSON 时，这个字段将会被忽略。

XML 库对标签的处理与 JSON 库类似。

注意，如果你想在反射时获取标签，你需要导入`reflect`​包，并使用`Type.Field(i).Tag.Get(key)`​方法，其中，`Type`​是一个结构体的类型，`i`​是字段的索引，`key`​是你想获取的标签的键。

例如：

```php
package main

import (
  "fmt"
  "reflect"
)

type Person struct {
  Name    string `json:"name" xml:"name"`
  Email   string `json:"email" xml:"email"`
  Age     int    `json:"age,omitempty" xml:"age,omitempty"`
}

func main() {
  t := reflect.TypeOf(Person{})
  field, _ := t.FieldByName("Name")
  fmt.Println(field.Tag.Get("json"))
}Copy
```

这个例子将会输出：”name”。

## 如何在 Go 语言中使用 tag 标签？[#](https://learnku.com/articles/78000#8d1eb1)

Go 语言中的标签（tag）主要通过反射（reflection）机制在运行时被获取和使用。然而，标签的具体使用方式取决于它们所用于的库或者你自己的代码。在实践中，标签经常被用于序列化和反序列化（如 JSON、XML），数据验证，数据库 ORM 映射等场景。

以下是使用 Go 标准库的`encoding/json`​包进行序列化和反序列化操作的例子：

```php
package main

import (
  "encoding/json"
  "fmt"
)

type User struct {
  Name string `json:"name"`
  Age  int    `json:"age"`
}

func main() {
  // 序列化
  user := User{Name: "Alice", Age: 20}
  data, _ := json.Marshal(user)
  fmt.Println(string(data)) // 输出: {"name":"Alice","age":20}

  // 反序列化
  var user2 User
  json.Unmarshal(data, &user2)
  fmt.Println(user2) // 输出: {Alice 20}
}Copy
```

在这个例子中，`User`​结构体中的字段定义了`json`​标签，这些标签决定了在序列化和反序列化时对应的 JSON 对象的键名称。

另一个例子是使用`reflect`​包来读取标签：

```php
package main

import (
  "fmt"
  "reflect"
)

type User struct {
  Name string `json:"name" myTag:"MyName"`
  Age  int    `json:"age" myTag:"MyAge"`
}

func main() {
  userType := reflect.TypeOf(User{})
  for i := 0; i < userType.NumField(); i++ {
  field := userType.Field(i)
  fmt.Println(field.Name, field.Tag.Get("myTag"), field.Tag.Get("json"))
  }
}Copy
```

在这个例子中，我们定义了自己的`myTag`​标签，并通过反射获取这些标签。

以上就是如何在 Go 语言中使用 tag 标签的基本方式。你可以根据具体的需求和所使用的库来选择合适的方式。

## tag 标签在 Go 语言中的常见用途是什么？[#](https://learnku.com/articles/78000#b01cb3)

在 Go 语言中，标签（Tag）主要用于以下几个方面：

1. **序列化和反序列化：**  标签常被用于控制结构体的序列化和反序列化。例如，在 Go 的`encoding/json`​和`encoding/xml`​包中，你可以使用标签来指定字段在 JSON 或 XML 中的名称，或者在编码时是否忽略某个字段。这可以让你有更大的灵活性来定义和控制序列化和反序列化的过程。
2. **数据验证：**  一些库允许你使用标签来为结构体的字段添加验证规则。例如，你可以使用`valid`​标签来指定一个字段必须是邮件地址格式，或者使用`range`​标签来指定一个整数字段的值必须在某个范围内。这些库通常提供了一套简洁的 DSL（领域特定语言）让你可以在标签中定义复杂的验证规则。
3. **数据库 ORM 映射：**  有些数据库 ORM（对象关系映射）库允许你使用标签来定义数据库表和结构体之间的映射关系。例如，你可以使用`sql`​标签来指定字段对应的数据库列的名称，或者一个字段是否可以为 null。
4. **HTTP 路由和处理：**  在某些 Web 框架中，标签可以被用来定义 HTTP 路由规则或者请求处理逻辑。例如，你可以使用`route`​标签来指定一个方法处理哪个 URL 路径的请求，或者使用`method`​标签来指定一个方法处理哪种 HTTP 方法的请求。

以上是标签在 Go 语言中的常见用途。请注意，标签的具体含义和使用方式取决于它们所用于的库或者你自己的代码。当你使用一个新的库时，你应该查阅其文档来了解它如何使用标签。

## 如何使用反射 (reflection) 来读取和解析 tag 标签？[#](https://learnku.com/articles/78000#e52681)

在 Go 中，你可以使用`reflect`​包来读取和解析标签。下面是一个例子：

```php
package main

import (
  "fmt"
  "reflect"
)

type User struct {
  Name string `json:"name" mytag:"myName"`
  Age  int    `json:"age" mytag:"myAge"`
}

func main() {
  user := User{"Bob", 30}
  t := reflect.TypeOf(user)

  for i := 0; i < t.NumField(); i++ {
  field := t.Field(i)

  fmt.Println(field.Name, field.Tag.Get("json"), field.Tag.Get("mytag"))
  }
}Copy
```

在这个例子中，`User`​结构体中的`Name`​和`Age`​字段都有`json`​和`mytag`​标签。在 main 函数中，我们通过`reflect.TypeOf`​获取`User`​类型，然后使用`NumField`​和`Field`​方法遍历所有的字段。每个字段都是一个`reflect.StructField`​类型的值，它有一个`Tag`​字段包含了标签的内容。最后，我们使用`Tag.Get`​方法获取`json`​和`mytag`​的值。

注意，如果标签中没有指定的键，`Tag.Get`​方法会返回一个空字符串。如果你想获取所有的键和值，你可以直接打印`field.Tag`​，它会返回所有的键值对。

如果你想解析复杂的标签，如多个由空格分隔的键值对，你可能需要写更复杂的代码，或者使用一些库来帮助你解析标签。

## 如何自定义 Go 语言的 tag 标签？[#](https://learnku.com/articles/78000#d27b20)

在 Go 语言中，你可以很容易地自定义结构体字段的标签。每个标签都是一个由多个键值对组成的字符串，你可以定义任意的键和值。下面是一个例子：

```php
type User struct {
  Name string `myTag:"MyName" anotherTag:"AnotherName"`
  Age  int    `myTag:"MyAge"`
}Copy
```

在这个例子中，`User`​结构体中的`Name`​字段有两个标签：`myTag`​和`anotherTag`​，而`Age`​字段只有`myTag`​标签。

然后，你可以通过`reflect`​包来获取和解析你自定义的标签：

```php
user := User{"Bob", 30}
t := reflect.TypeOf(user)

for i := 0; i < t.NumField(); i++ {
  field := t.Field(i)

  fmt.Println(field.Name, field.Tag.Get("myTag"), field.Tag.Get("anotherTag"))
}Copy
```

注意，虽然你可以自定义任意的标签，但如果你想让其他的库或者代码来读取和解析你的标签，你需要确保它们能够理解你的标签。如果你自定义的标签只是用于你自己的代码，那么你可以自由地定义任何你需要的格式和语义。

此外，标签的解析通常需要使用到`strings`​包的功能，例如`strings.Split`​函数可以用来分割键值对，而`strings.TrimSpace`​函数可以用来去除空格等。

## tag 标签在 Go 语言的 json 编解码中有什么作用？[#](https://learnku.com/articles/78000#9943de)

在 Go 语言中，标签（Tag）在 json 编解码过程中起着重要的作用。具体来说，当我们使用`encoding/json`​包进行 json 编码（序列化）和解码（反序列化）时，结构体字段的标签可以被用来控制如何处理该字段。

以下是在 Go 中定义结构体并添加 json 标签的示例：

```php
type User struct {
 Name    string `json:"name"`
 Email   string `json:"email"`
 Age     int    `json:"age,omitempty"`
}Copy
```

在这个例子中，`Name`​、`Email`​和`Age`​这三个字段都有一个`json`​标签。这些标签可以被`encoding/json`​库使用，以控制如何将结构体字段编码为 json，或者如何从 json 解码到这个字段。具体来说：

1. **字段命名：**  标签可以指定该字段在 json 中的键名。例如，虽然结构体中的字段名是`Name`​（首字母大写），但在 json 中，对应的键名却是`name`​（全部小写）。
2. **omitempty 选项：**  这个选项可以控制如果字段的值为空（零值），那么在编码为 json 时，这个字段是否会被忽略。例如，`Age`​字段的标签是`json:"age,omitempty"`​，这表示如果`Age`​的值是 0（int 类型的零值），那么在编码为 json 时，`"age"`​键将不会出现。
3.  **“-“选项：**  如果你不想让某个字段在 json 中出现，你可以使用`-`​选项。例如，如果你将`Email`​字段的标签改为`json:"-"`​，那么无论`Email`​的值是什么，在编码为 json 时，`"email"`​键都不会出现。

这些标签使得你能够更精细地控制如何将结构体编码为 json，或者如何从 json 解码到结构体。

## Go 语言中的 tag 标签可以做哪些数据验证？[#](https://learnku.com/articles/78000#5ed13e)

在 Go 语言中，你可以使用结构体字段的标签来进行数据验证。然而，Go 语言标准库并未提供内建的数据验证功能。你需要使用第三方的数据验证库，如 go-playground/validator，它使用结构体标签来进行数据验证。

go-playground/validator 支持多种验证器，你可以在标签中定义这些验证器。以下是一些常见的验证器：

1. ​`required`​：字段必须有值，不能是零值。
2. ​`email`​：字段必须是有效的电子邮件地址格式。
3. ​`url`​：字段必须是有效的 URL 格式。
4. ​`len`​：字段的长度必须等于给定的值。对于字符串，长度是字符串的字符数；对于数组、切片、Map，长度是它的元素数。
5. ​`min`​、`max`​：对于数字，它们表示最小值和最大值；对于字符串，数组、切片、Map，它们表示长度的最小值和最大值。
6. ​`eq`​、`ne`​：字段的值必须等于或不等于给定的值。

以下是使用 go-playground/validator 的例子：

```php
package main

import (
  "fmt"
  "github.com/go-playground/validator/v10"
)

type User struct {
  Email string `validate:"required,email"`
  Age   int    `validate:"gte=0,lte=130"`
}

func main() {
  validate := validator.New()

  user := &User{
  Email: "bad-email",
  Age:   150,
  }

  err := validate.Struct(user)
  if err != nil {
  fmt.Println(err)
  }
}Copy
```

在这个例子中，`User`​结构体中的`Email`​字段必须是非空的且必须是有效的电子邮件地址，`Age`​字段的值必须在 0 和 130 之间。在 main 函数中，我们使用`validator.New`​创建一个验证器，然后使用`validate.Struct`​来验证`user`​实例。如果`user`​的字段不满足标签中定义的验证规则，`validate.Struct`​将返回一个错误。

注意，使用 go-playground/validator 需要导入`github.com/go-playground/validator/v10`​包。如果你的项目还没有这个包，你需要使用`go get`​命令来安装它：

go get github.com/go-playground/validator/v10

## 如何使用 tag 标签实现 Go 语言的 ORM（对象关系映射）？[#](https://learnku.com/articles/78000#5db421)

Go 语言中没有内建的 ORM（对象关系映射）支持，但是有很多第三方的 ORM 库可以使用，如 GORM, SQLBoiler 等。这些库通常使用结构体的标签来定义数据库表和结构体之间的映射关系。

以下是一个使用 GORM 的例子：

```php
package main

import (
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/sqlite"
)

type User struct {
  gorm.Model
  Name  string `gorm:"type:varchar(100);unique_index"`
  Email string `gorm:"type:varchar(100);unique_index"`
  Age   int    `gorm:"default:0"`
}

func main() {
  db, err := gorm.Open("sqlite3", "test.db")
  if err != nil {
  panic("failed to connect database")
  }
  defer db.Close()

  db.AutoMigrate(&User{})
}Copy
```

在这个例子中，`User`​结构体中的字段都有一个`gorm`​标签，这些标签定义了字段在数据库表中的数据类型、索引、默认值等属性。`gorm.Model`​是 GORM 的基础模型，它包含了四个字段：ID, CreatedAt, UpdatedAt, DeletedAt，适合用于大多数场景。

然后，在 main 函数中，我们使用`gorm.Open`​连接数据库，然后使用`db.AutoMigrate`​创建对应的数据库表。如果表已经存在，`AutoMigrate`​会更新表的结构以匹配`User`​结构体。

注意，GORM 支持多种数据库，包括 MySQL, PostgreSQL, SQLite 等。在这个例子中，我们使用的是 SQLite 数据库。如果你想使用其他的数据库，你需要更改`gorm.Open`​的参数，并导入对应的数据库驱动。

此外，使用 GORM 需要导入`github.com/jinzhu/gorm`​包。如果你的项目还没有这个包，你需要使用`go get`​命令来安装它：

go get github.com/jinzhu/gorm

同时，也需要安装对应的数据库驱动，例如在这个例子中我们使用了 SQLite：

go get github.com/jinzhu/gorm/dialects/sqlite

## Go 语言的 tag 标签有哪些常见的第三方库支持？[#](https://learnku.com/articles/78000#a12fb5)

在 Go 语言中，有很多第三方库会使用结构体字段的标签。这些库通常使用标签来提供一些声明式的功能，例如数据验证、编码 / 解码、ORM 映射等。以下是一些常见的第三方库：

1. **encoding/json：**  这是 Go 语言的标准库，它使用标签来控制如何将结构体编码为 JSON 或从 JSON 解码到结构体。
2. **encoding/xml：**  同样是 Go 语言的标准库，它使用标签来控制如何将结构体编码为 XML 或从 XML 解码到结构体。
3. **gorm：**  这是一个流行的 Go 语言 ORM 库，它使用标签来定义数据库表和结构体之间的映射关系。
4. **validator：**  这是一个用于数据验证的库，它使用标签来定义验证规则。
5. **protobuf：**  这是 Google 的 Protocol Buffers 的 Go 语言实现，它使用标签来定义 Protobuf 消息和结构体之间的映射关系。
6. **bson：**  这是 MongoDB 官方的 Go 驱动使用的，它使用标签来控制如何将结构体编码为 BSON 或从 BSON 解码到结构体。
7. **mapstructure：**  这是一个用于将通用的 map 转换为结构体的库，它使用标签来定义 map 的键和结构体字段之间的映射关系。

以上是一些常见的支持标签的库，不过这并不是一个完整的列表。如果你正在使用一个库，并且你想知道它是否支持标签，你应该查阅它的文档。

> 本作品采用[《CC 协议》](https://learnku.com/docs/guide/cc4.0/6589)，转载必须注明作者和本文链接

# shuf

​`shuf`​ 命令用于在类 Unix 操作系统中生成随机排列。使用 `shuf`​ 命令，我们可以随机打乱给定输入文件的行。`shuf`​ 命令是 GNU Coreutils 的一部分，因此你不必担心安装问题。在这个简短的教程中，让我向你展示一些 `shuf`​ 命令的例子。

## 主要用途

* 将输入的内容随机排列并输出。
* 当没有文件或文件为`-`​时，读取标准输入。

## 选项

```shell
-e, --echo                  将每个ARG视为输入行。
-i, --input-range=LO-HI     将数字范围LO（最低）到HI（最高）之间的作为输入行。
-n, --head-count=COUNT      只输出前COUNT行。
-o, --output=FILE           将结果写入到文件而不是标准输出。
    --random-source=FILE    将FILE中内容作为随机数据源。
-r, --repeat                输出行可以重复。
-z, --zero-terminated       行终止符为NUL（空字符）而不是默认的换行符。
--help                      显示帮助信息并退出。
--version                   显示版本信息并退出。
```

‍

## 实例

我有一个名为 `ostechnix.txt`​ 的文件，内容如下：

```
$ cat ostechnix.txt
    line1
    line2
    line3
    line4
    line5
    line6
    line7
    line8
    line9
    line10
```

现在让我们以随机顺序显示上面的行。为此，请运行：

```
$ shuf ostechnix.txt
    line2
    line8
    line5
    line10
    line7
    line1
    line4
    line6
    line9
    line3
```

看到了吗？上面的命令将名为 `ostechnix.txt`​ 中的行随机排列并输出了结果。

你可能想将输出写入另一个文件。例如，我想将输出保存到 `output.txt`​ 中。为此，请先创建 `output.txt`​然后，像下面使用 `-o`​ 标志将输出写入该文件：

```
touch output.txt && shuf ostechnix.txt -o output.txt
```

我只想显示文件中的任意一行。我该怎么做？很简单！

```
shuf -n 1 ostechnix.txt
```

同样，我们可以选择前 “n” 个随机条目。以下命令将只显示前五个随机条目：

```
shuf -n 5 ostechnix.txt
```

如下所示，我们可以直接使用 `-e`​ 标志传入输入，而不是从文件中读取行：

```
shuf -e line1 line2 line3 line4 line5
```

你也可以传入数字：

```
shuf -e 1 2 3 4 5
```

我们也可以在特定范围内生成随机数。例如，要显示 1 到 10 之间的随机数，只需使用：

```
shuf -i 1-10
```

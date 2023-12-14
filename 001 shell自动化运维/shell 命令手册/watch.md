# watch

watch命令能够将其他命令的输出定时输出到终端，从而实现监听的能力，在我们要对一些命令状态进行实时监听的场景中，有非常好的应用场景。

## [#](https://wiki.eryajf.net/pages/5279.html#%E5%8F%82%E6%95%B0) 参数

```
$watch -h

Usage:
 watch [options] command

Options:
  -b, --beep             如果命令具有非零退出，则发出蜂鸣音
  -c, --color            解释ANSI颜色和样式序列
  -d, --differences[=<permanent>]
                         高亮显示两次更新之间的变化
  -e, --errexit          如果命令有非零退出，则退出
  -g, --chgexit          当命令的输出发生变化时退出
  -n, --interval <secs>  两次更新之间的等待秒数
  -p, --precise          尝试以精确的时间间隔运行命令
  -t, --no-title         关闭watch命令在顶部的时间间隔,命令，当前时间的输出
  -x, --exec             将命令传递给exec，而不是 "sh -c"

 -h, --help     display this help and exit
 -v, --version  output version information and exit

For more details see watch(1).
```

## [#](https://wiki.eryajf.net/pages/5279.html#%E5%B8%B8%E7%94%A8%E4%BE%8B%E5%AD%90) 常用例子

比较常用的参数有 `-n`​ `-d`​。

监听当前目录下文件变化：

```bash
watch -n1 -d ls
```

监听系统中TCP连接状态的变化：

```
watch -n1 -d "netstat -an  | awk '/tcp/ {print \$6}'| sort | uniq -c"
```

> * watch后边如果带有管道符，则用双引号将后边的命令包裹成一个整体。
> * 另外，当awk的print被双引号包裹之后，需要在$符号前边加个转义符。

​​

‍

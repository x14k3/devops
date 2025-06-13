# base64

​`base64`​ 命令用于对文件或者标准输入进行编码和解码。

## [#](https://wiki.eryajf.net/pages/5279.html#_1-%E7%94%A8%E6%B3%95) 1，用法

```
$ base64 --help
用法：base64 [选项]... [文件]
使用 Base64 编码/解码文件或标准输入输出。

如果没有指定文件，或者文件为"-"，则从标准输入读取。

必选参数对长短选项同时适用。
  -d, --decode          解码数据
  -i, --ignore-garbag   解码时忽略非字母字符
  -w, --wrap=字符数     在指定的字符数后自动换行(默认为76)，0 为禁用自动换行

      --help            显示此帮助信息并退出
      --version         显示版本信息并退出

数据以 RFC 4648 规定的 base64 字母格式进行编码。
解码时，输入数据（编码流）可能包含一些非有效 base64 字符的换行符。
可以尝试用 --ignore-garbage 选项来绕过编码流中的无效字符。

GNU coreutils 在线帮助：<https://www.gnu.org/software/coreutils/>
请向 <http://translationproject.org/team/zh_CN.html> 报告 base64 的翻译错误
完整文档请见：<https://www.gnu.org/software/coreutils/base64>
或者在本地使用：info '(coreutils) base64 invocation'
```

​​

## [#](https://wiki.eryajf.net/pages/5279.html#_2-%E5%AE%9E%E8%B7%B5) 2，实践

### [#](https://wiki.eryajf.net/pages/5279.html#_1-%E7%BC%96%E7%A0%81) 1，编码

- 直接执行

  ```
  $ echo 'hello' | base64
  aGVsbG8K
  ```
- 基于文件

  ```
  $ echo 'hello' > test.txt && base64 test.txt
  aGVsbG8K
  ```
- 记得用-w参数

  有时候内容可能比较长，那么默认的换行结果会多一个换行符，可以用如下方式：

  ```
  $ curl https://wiki.eryajf.net | base64 -w 0
  ...内容略...
  ```

### [#](https://wiki.eryajf.net/pages/5279.html#_2-%E8%A7%A3%E7%A0%81) 2，解码

- 直接执行

  ```
  $ echo 'aGVsbG8K' | base64 -d
  hello
  ```
- 基于文件

  ```
  $ echo 'aGVsbG8K' > test.txt && base64 -d test.txt
  hello
  ```

​`在一些场景中，如果传参会受制于一些特殊符号，或者换行的时候，就可以通过base64做一层简单的编解码即可解决这种问题。`​

‍

# column

- 将单列数据整理为多列显示，每行宽度可以指定，超出的部分自动换行。
- 将多列数据进行快速整理，对齐每列的字符。

‍

```shell
column [options] [file ...]
```

‍

## 选项

```shell
-c, --columns <width> 输出宽度（以字符数表示） 
-t, --table 创建一个表格（每列字符会对齐） 
-s, --separator <string> 指定识别表格的分隔符 
-o, --output-separator <string> 输出表格的列分隔符，默认为两个空格 
-x, --fillrows 在列之前填充行 
-h, --help 显示此帮助 
-V, --version 输出版本信息
```

## 示例

- 整理单列数据

```shell
# 生成 26 个英文字母， 每列一个
$ for a in {a..z}; do echo $a; done > test

# 每行最大 60 个字符
$ cat test | column -c 60
a       e       i       m       q       u       y
b       f       j       n       r       v       z
c       g       k       o       s       w
d       h       l       p       t       x

# 在上面的基础上，进一步整理，每列之间宽度默认两个空白符
$ cat test | column -c 60 | column -t
a  e  i  m  q  u  y
b  f  j  n  r  v  z
c  g  k  o  s  w
d  h  l  p  t  x

# 指定每列之间用 ', ' 拼接
$ cat test | column -c 60 | column -t -o ', '
a, e, i, m, q, u, y
b, f, j, n, r, v, z
c, g, k, o, s, w
d, h, l, p, t, x
```

- 整理多列数据

```shell
# 现有如下内容较为凌乱的文本文件 test
$ cat test
Address[0] Metal3,pin 133.175:159.92
Address[1] Metal3,pin 112.38:159.92
Address[2] Metal3,pin 70.775:159.92
Address[3] Metal3,pin 41.655:159.92
DataIn[0] Metal3,pin 66.615:159.92
DataIn[1] Metal3,pin 37.495:159.92
DataIn[2] Metal3,pin 122.88:159.92
DataIn[3] Metal3,pin 95.74:159.92
DataOut[0] Metal3,pin 45.815:159.92
DataOut[1] Metal3,pin 79.095:159.92
DataOut[2] Metal3,pin 104.055:159.92
DataOut[3] Metal3,pin 62.46:159.92
MemReq Metal3,pin 108.215:159.92
RdWrBar Metal3,pin 87.415:159.92
clock Metal3,pin 74.935:159.92

# 列对齐
$ cat test | column -t
Address[0]  Metal3,pin  133.175:159.92
Address[1]  Metal3,pin  112.38:159.92
Address[2]  Metal3,pin  70.775:159.92
Address[3]  Metal3,pin  41.655:159.92
DataIn[0]   Metal3,pin  66.615:159.92
DataIn[1]   Metal3,pin  37.495:159.92
DataIn[2]   Metal3,pin  122.88:159.92
DataIn[3]   Metal3,pin  95.74:159.92
DataOut[0]  Metal3,pin  45.815:159.92
DataOut[1]  Metal3,pin  79.095:159.92
DataOut[2]  Metal3,pin  104.055:159.92
DataOut[3]  Metal3,pin  62.46:159.92
MemReq      Metal3,pin  108.215:159.92
RdWrBar     Metal3,pin  87.415:159.92
clock       Metal3,pin  74.935:159.92

# 将 ',' 和 ':' 也识别为分隔符
$ cat test | column -t -s ',: '
Address[0]  Metal3  pin  133.175  159.92
Address[1]  Metal3  pin  112.38   159.92
Address[2]  Metal3  pin  70.775   159.92
Address[3]  Metal3  pin  41.655   159.92
DataIn[0]   Metal3  pin  66.615   159.92
DataIn[1]   Metal3  pin  37.495   159.92
DataIn[2]   Metal3  pin  122.88   159.92
DataIn[3]   Metal3  pin  95.74    159.92
DataOut[0]  Metal3  pin  45.815   159.92
DataOut[1]  Metal3  pin  79.095   159.92
DataOut[2]  Metal3  pin  104.055  159.92
DataOut[3]  Metal3  pin  62.46    159.92
MemReq      Metal3  pin  108.215  159.92
RdWrBar     Metal3  pin  87.415   159.92
clock       Metal3  pin  74.935   159.92

```

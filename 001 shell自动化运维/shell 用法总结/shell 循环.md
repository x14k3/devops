# shell 循环

## 1.IF 判断

```bash
if [ command ]; then
    符合该条件执行的语句
fi


if [ command ]; then
    command执行返回状态为0要执行的语句
else
    command执行返回状态为1要执行的语句
fi


if [ command1 ]; then
    command1执行返回状态为0要执行的语句
elif [ command2 ]; then
    command2执行返回状态为0要执行的语句
else
    command1和command2执行返回状态都为1要执行的语句
fi
```

## 2.for循环

### 数字性循环

```bash
#!/bin/bash
for((i=1;i<=10;i++));
do
    echo $(expr $i \* 3 + 1);
done
```

```bash
#!/bin/bash
for i in $(seq 1 10)
do
    echo $(expr $i \* 3 + 1);
done
```

```bash
#!/bin/bash
for i in {1..10}
do
    echo $(expr $i \* 3 + 1);
done
```

```bash
#!/bin/bash
awk 'BEGIN{for(i=1; i<=10; i++) print i}'
```

### 字符性循环

```bash
#!/bin/bash
for i in `ls`;
do
    echo $i is file name\! ;
done
```

```bash
#!/bin/bash
for i in $* ;
do
    echo $i is input chart\! ;
done
```

```bash
#!/bin/bash
for i in f1 f2 f3 ;
do
    echo $i is appoint ;
done
```

```bash
#!/bin/bash
list="rootfs usr data data2"

for i in $list;
do
    echo $i is appoint ;
done
```

### 路径查找

```bash
#!/bin/bash
for file in /proc/*;
do
    echo $file is file path \! ;
done
```

```bash
#!/bin/bash
for file in $(ls *.sh)
do
    echo $file is file path \! ;
done
```

## 3.While循环

```bash
while condition ; do
    statements ...
done
```

　　​**​`Note:`​** ​ 和if一样，condition可以有一系列的statements组成，值是最后的statment的exit status

## 4.Util循环

```bash
until [condition-is-true] ; do 
  statements ... 
done
```

　　​**​`Note:`​** ​ 执行statements，直至command正确运行。在循环的顶部判断条件,并且如果条件一直为false那就一直循环下去

　　‍

　　‍

## 5.跳出循环

* **break n**

  n 表示跳出循环的层数，如果省略 n，则表示跳出当前的整个循环。break 关键字通常和 if 语句一起使用，即满足条件时便跳出循环。

* **continue n**

  n 表示循环的层数：

  如果省略 n，则表示 continue 只对当前层次的循环语句有效，遇到 continue 会跳过本次循环，忽略本次循环的剩余代码，直接进入下一次循环。

  如果带上 n，比如 n 的值为 2，那么 continue 对内层和外层循环语句都有效，不但内层会跳过本次循环，外层也会跳过本次循环，其效果相当于内层循环和外层循环同时执行了不带 n 的 continue。这么说可能有点难以理解，稍后我们通过代码来演示。

* exit：退出shell程序，并返回n值

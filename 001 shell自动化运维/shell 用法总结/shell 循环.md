# shell 循环

## 1.IF 判断

```
if [ command ]; then
    符合该条件执行的语句
fi
```

```
if [ command ]; then
    command执行返回状态为0要执行的语句
else
    command执行返回状态为1要执行的语句
fi
```

```
if [ command1 ]; then
    command1执行返回状态为0要执行的语句
elif [ command2 ]; then
    command2执行返回状态为0要执行的语句
else
    command1和command2执行返回状态都为1要执行的语句
fi
```

​**`PS`**​: [ command ]，command前后要有空格

## 2.for循环

### 数字性循环

```
#!/bin/bash
for((i=1;i<=10;i++));
do
    echo $(expr $i \* 3 + 1);
done
```

```
#!/bin/bash
for i in $(seq 1 10)
do
    echo $(expr $i \* 3 + 1);
done
```

```
#!/bin/bash
for i in {1..10}
do
    echo $(expr $i \* 3 + 1);
done
```

```
#!/bin/bash
awk 'BEGIN{for(i=1; i<=10; i++) print i}'
```

### 字符性循环

```
#!/bin/bash
for i in `ls`;
do
    echo $i is file name\! ;
done
```

```
#!/bin/bash
for i in $* ;
do
    echo $i is input chart\! ;
done
```

```
#!/bin/bash
for i in f1 f2 f3 ;
do
    echo $i is appoint ;
done
```

```
#!/bin/bash
list="rootfs usr data data2"

for i in $list;
do
    echo $i is appoint ;
done
```

### 路径查找

```
#!/bin/bash
for file in /proc/*;
do
    echo $file is file path \! ;
done
```

```
#!/bin/bash
for file in $(ls *.sh)
do
    echo $file is file path \! ;
done
```

## 3.While循环

```
while condition ; do
    statements ...
done
```

​**`Note:`** ​ 和if一样，condition可以有一系列的statements组成，值是最后的statment的exit status

## 4.Util循环

```
until [condition-is-true] ; do 
  statements ... 
done
```

​**`Note:`** ​ 执行statements，直至command正确运行。在循环的顶部判断条件,并且如果条件一直为false那就一直循环下去

‍

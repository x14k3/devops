# read

从键盘读取变量的值，通常用在shell脚本中与用户进行交互的场合。该命令可以一次读取多个变量的值，变量和输入的值都需要使用空格隔开。在read命令后面，如果没有指定变量名，读取的数据将被自动赋值给特定的变量REPLY

### 语法

```shell
read(选项)(参数)
```

### 选项

```shell
-a 后跟一个变量，该变量会被认为是个数组，然后给其赋值，默认是以空格为分割符。
-d 后面跟一个标志符，其实只有其后的第一个字符有用，作为结束的标志。
-p 后面跟提示信息，即在输入前打印提示信息。
-e 在输入的时候可以时候命令补全功能。
-n 后跟一个数字，定义输入文本的长度。
-r 屏蔽，如果没有该选项，则作为一个转义字符，有的话就是个正常的字符。
-s 安静模式，在输入字符时不再屏幕上显示，例如login时输入密码。
-t 后面跟秒数，定义输入字符的等待时间。
-u 后面跟fd，从文件描述符中读入，该文件描述符可以是exec新开启的。
```

### 参数

变量：指定读取值的变量名。

**使用示例**

```bash
#!/bin/bash 
read -t 30 -p "Please input your name: " name 
# 提示“请输入姓名”并等待30秒，把用户的输入保存入变量name中 
echo "Name is $name" 
 
read -s -t 30 -p "Please enter your age: " age 
# 年龄是隐私，所以我们用“-s”选项隐藏输入 
echo -e "\n" 
echo "Age is $age" 
 
read -n 1 -t 30 -p "Please select your gender[M/F]: " gender 
# 使用“-n 1”选项只接收一个输入字符就会执行（都不用输入回车） 
echo -e "\n" 
echo "Sex is $gender"


read -p "`echo -e "\n\e[1;36m  Please enter the server host name [oracle] : \e[0m"`" TMP_ORACLE_HOSTNAME
```

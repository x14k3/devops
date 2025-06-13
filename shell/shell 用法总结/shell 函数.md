# shell 函数 

# 函数

函数可将一个复杂功能划分成若干模块，让程序结构更加清晰，代码重复利用率更高。

在 shell 中必须先定义函数，然后使用，而且不能独立运行，需要调用执行。函数可出现在任何位置，在代码执行时，都会被自动替换为函数代码。函数命名不应该为命令名，否则会发生冲突。

# 函数的定义方式

定义方式一

```bash
function function_name {
    list of commands
    [ return value ]
}
```

定义方式二

```bash
function_name () {
    list of commands
    [ return value ]
}
```

# 函数的生命周期

每次被调用时创建，返回时终止。在 RedHat 系列的系统中的 `/etc/init.d/functions`​ 文件中有很多系统原生的函数，可以用来参考学习。

# 调用函数

调用函数时直接写函数名即可调用该函数。

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

choice(){
    read -p "Do you want to continue? [yes/no] " yourchoice
  
    case "${yourchoice}" in
        y|Y|[yY][eE]|[yY][eE][sS])
            echo "OK, you can continue"
            ;;
        n|N|[nN][oO])
            echo "NO"
            ;;
        *)
            echo "Usage: { yes | no }"
            exit 5
            ;;
    esac
}

choice

[user1@study ~]$ bash test.sh 
Do you want to continue? [yes/no] yes
OK, you can continue
[user1@study ~]$ bash test.sh 
Do you want to continue? [yes/no] n
NO
[user1@study ~]$ bash test.sh
Do you want to continue? [yes/no] test   
Usage: { yes | no }
[user1@study ~]$
```

# 函数的返回值

- 函数的返回值，可以使用 `return`​ 语句；如果不加，则将最后一条命令运行结果作为返回值。
- Shell 函数返回值只能是整数，一般用来表示函数执行成功与否，0表示成功，其他值表示失败。
- 如果 return 其他数据，比如一个字符串，往往会得到错误提示：“numeric argument required”

# 函数中参数的传递

在函数体中当中，可以使用  `2，....$n`​、`$@`​、`$#`​、`$*`​ 等引用传递给函数的位置变量；在调用函数时，在函数名后面以空白符分隔给定参数列表即可

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

action=$1
# 传递给脚本的第一个参数
me=$(basename $0)


servicectl(){
    case "$1" in
    # 这里的 $1 是针对当前函数来说的，不是脚本的 $1
        start)
            echo "${me} ${action}"
            ;;
        stop)
            echo "${me} ${action}"
            ;;
        reload)
            echo "${me} ${action}"
            ;;
        restart)
            echo "${me} ${action}"
            ;;
        *)
            echo "Usage: ${me} { start | stop | reload | restart }"
            ;;
    esac
}

servicectl ${action}
# 通过 action 变量将传递给脚本的第一个参数再传递给函数
[user1@study ~]$ bash test.sh 
Usage: test.sh { start | stop | reload | restart }
[user1@study ~]$ bash test.sh start
test.sh start
[user1@study ~]$ bash test.sh restart
test.sh restart
[user1@study ~]$
```

# 局部变量及作用域

使用 `local VARIABLE=VALUE`​ 的方式来定义一个局部变量，并且 `local`​ 关键字可以省略。局部变量的作用域是当前函数，不能被函数体外面的语句调用，在函数结束时被自动销毁。

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

name="Jerry"

afunc(){
    local name="Tom"
    echo ${name}
}

echo ${name}

afunc

[user1@study ~]$ bash test.sh 
Jerry
Tom
[user1@study ~]$
```

# 递归函数

能够调用自身的函数成为递归函数。经典的 fork 炸弹

```
.(){.|.&};.
```

说明

```bash
. () 
# 定义一个名叫 . 的函数，无可选参数
{
# 函数体开始
.|.&
# 递归调用函数本身，然后利用管道再次调函数本身并将其放到后台执行
};
# 函数体结束
.
# 调用函数
```

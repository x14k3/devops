# BEGIN和END语句块

　　awk的所有代码(目前这么认为)都是写在语句块中的。

　　例如：

```
awk '{print $0}' a.txt
awk '{print $0}{print $0;print $0}' a.txt
```

　　每个语句块前面可以有pattern，所以格式为：

```
pattern1{statement1}pattern2{statement3;statement4;...}
```

　　语句块可分为3类：BEGIN语句块、END语句块和main语句块。其中BEGIN语句块和END语句块都是的格式分别为`BEGIN{...}`​和`END{...}`​，而main语句块是一种统称，它的pattern部分没有固定格式，也可以省略，main代码块是在读取文件的每一行的时候都执行的代码块。

　　分析下面三个awk命令的执行结果：

```
awk 'BEGIN{print "我在前面"}{print $0}' a.txt
awk 'END{print "我在后面"}{print $0}' a.txt
awk 'BEGIN{print "我在前面"}{print $0}END{print "我在后面"}' a.txt
```

　　根据上面3行命令的执行结果，可总结出如下有关于BEGIN、END和main代码块的特性：

　　BEGIN代码块：

* 在读取文件之前执行，且执行一次
* 在BEGIN代码块中，无法使用`$0`​或其它一些特殊变量

　　main代码块：

* 读取文件时循环执行，(默认情况)每读取一行，就执行一次main代码块
* main代码块可有多个

　　END代码块：

* 在读取文件完成之后执行，且执行一次
* 有END代码块，必有要读取的数据(可以是标准输入)
* END代码块中可以使用`$0`​等一些特殊变量，只不过这些特殊变量保存的是最后一轮awk循环的数据

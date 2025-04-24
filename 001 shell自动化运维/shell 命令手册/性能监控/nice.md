# nice

进程调度是linux中非常重要的概念。linux内核有一套高效复杂的调度机制，能使效率极大化，但有时为了实现特定的要求，需要一定的人工干预。比如，你希望操作系统能分配更多的CPU资源给浏览器进程，让浏览速度更快、更流畅，操作体验更好。那具体应该怎么做呢？尽管linux的进程调度算法十分复杂，但都是以进程的优先级为基础的。因此，只需要改变进程的优先级即可。

在linux中，`nice`​命令用于改变进程的优先级。

​`nice`​命令？什么鬼？哪有命令直接说自己“nice”的？咋一看，这个名字确实很“nice”，只是这里的“nice”是指“niceness”，即友善度、谦让度。用于进程中，表示进程的优先级，也即进程的友善度。niceness值为负时，表示高优先级，能提前执行和获得更多的资源，对应低友善度；反之，则表示低优先级，高友善度。

### 语法

```shell
nice [选项] [命令 [参数]...]
```

### 选项

```shell
-n：指定nice值（整数，-20（最高）~19（最低））。
```

### 参数

指令及选项：需要运行的指令及其他选项。

### 实例

新建一个进程并设置优先级，将当前目录下的documents目录打包，但不希望tar占用太多CPU：

```shell
nice -19 tar zcf pack.tar.gz documents
```

方法非常简单，即在原命令前加上`nice -19`​。很多人可能有疑问了，最低优先级不是19么？那是因为这个“-19”中的“-”仅表示参数前缀；所以，如果希望将当前目录下的documents目录打包，并且赋予tar进程最高的优先级就应该加上`nice --20`​：

```shell
nice --20 tar zcf pack.tar.gz documents
```

可以通过`ps -l`​查看进程的niceness值。

```bash
xie@xie-VirtualBox:~$ ps -l
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY  TIME CMD
0 S  1000  1635  1634  0  80   0 -  2178 wait   pts/13   00:00:00 bash
0 T  1000  1677  1635  0  90  10 -  1767 signal pts/13   00:00:00 vi
0 R  1000  1678  1635  0  80   0 -  1606 -  pts/13   00:00:00 ps

```

NI列即表示进程的niceness值。vi进程对应的NI值正好为刚设置的10。那PRI列又是什么呢？PRI表示进程当前的总优先级，值越小表示优先级越高，由进程默认的PRI加上NI得到，即PRI(new) \= PRI(old) + NI。由上程序，进程默认的PRI是80，所以加上值为10的NI后，vi进程的PRI为90。  
所以，需要注意的是，NI即niceness的值只是进程优先级的一部分，不能完全决定进程的优先级，但niceness值的绝对值越大，效果越显著。

## renice命令

以上讨论的都是为即将运行的进程设置niceness值，而`renice`​用于改变正在运行的进程的niceness值。

​`renice`​，字面意思即重新设置niceness值，进程启动时默认的niceness值为0，可以用renice更新。

​`renice`​语法：

```bash
renice [优先等级] [-g<程序群组名称>...] [-p<程序识别码>...] [-u <用户名称>...]
```

```bash
renice -5 -p 5200   #将PID为5200的进程的niceness设为-5
renice -5 -u xie    #将属于用户xie的进程的niceness设为-5
renice -5 -g group1 #将属于group1组的程序的niceness设为5
```

‍

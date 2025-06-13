# shell的语法调试 

# 使用bash选项

​`-n`​ 检查脚本语法格式是否有错

```bash
bash -n script.sh
```

​`-v`​ 选项将跟踪脚本中每个命令的执行

```bash
bash -v script.sh
```

​`-x`​ 选项会使脚本单步执行，将整个脚本每一步解释和执行过程显示出来

```bash
user1@study ~]$ cat script.sh 
#!/bin/bash

if [[ '2' = '3' ]];then
    echo yes
else
    echo no
fi

echo "123" | grep 2 && echo yes || echo no
[user1@study ~]$ bash -x script.sh
+ [[ 2 = \3 ]]
+ echo no
no
+ echo 123
+ grep 2
123
+ echo yes
yes
[user1@study ~]$
```

# 使用set命令

```bash
set -x # 在执行时候显示参数和命令。
set +x # 禁止调式。
set -v # 当命令进入读取时候显示输入。
set +v #  禁止打印输入
```

仅在 `-x`​ 和 `+x`​ 区域显示调试信息

```bash
[user1@study ~]$ cat test.sh 
#!/bin/bash

for i in {1..5} ; do
    set -x
    echo $i
    set +x
done
[user1@study ~]$ bash test.sh
+ echo 1
1
+ set +x
+ echo 2
2
+ set +x
+ echo 3
3
+ set +x
+ echo 4
4
+ set +x
+ echo 5
5
+ set +x
[user1@study ~]$
```

# 使用 `_DEBUG`​ 环境变量

若需要自定义格式显示调式信息可通过 `_DEBUG`​ 环境变量来建立。将需要调式的行前加上 `DEBUG`​，运行脚本前没有加 `_DEBUG=on`​ 就不会显示任何信息，脚本中 `:`​ 告诉shell不进行任何操作。

```bash
#!/bin/bash
DEBUG () {
    [ "$_DEBUG" = "on" ] && $@ || :
}

for i in {1..5} ; do
    DEBUG echo $i
done
[user1@study ~]$ bash test.sh
[user1@study ~]$
```

将调试功能设置为“on”来运行脚本：

```bash
[user1@study ~]$ _DEBUG=on bash test.sh 
1
2
3
4
5
[user1@study ~]$
```

# 使用shellbang

把 shebang 从 `#!/bin/bash`​ 修改成 `#!/bin/bash -xv`​ 即可

# 静态检查工具 shellcheck

为了从制度上保证脚本的质量，我们最简单的想法大概就是搞一个静态检查工具，通过引入工具来弥补开发者可能存在的知识盲点。

[shellcheck](https://www.shellcheck.net)这个工具的对不同平台的支持力度都很大，他至少支持 `Debian`​，`Arch`​，`Gentoo`​，`EPEL`​，`Fedora`​，`OS X`​,，`openSUSE`​ 等等各种的平台的主流包管理工具。

使用 epel 的 yum 源即可安装。它的 Github 地址为 [https://github.com/koalaman/shellcheck](https://github.com/koalaman/shellcheck)

```bash
yum -y install epel-release
yum install ShellCheck
```

shellcheck 提供了一个非常非常强大的 wiki。在这个 wiki 里，我们可以找到这个工具所有判断的依据，每一个检测到的问题都可以在  wiki 里找到对应的问题单号，他不仅告诉我们” 这样写不好”，而且告诉我们” 为什么这样写不好”，”  我们应当怎么写才好”，非常适合刨根问底党进一步研究。

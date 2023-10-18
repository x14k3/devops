# shell 脚本命令

## date

```bash
# 1、获取当前日期: 
TODAY=`date "+%Y-%m-%d"`
# 2、获取7天前的日期
PASTDAY=$(date -d '10 day ago' "+%Y%m%d")
PASTDAY=$(date -d '1 month ago' "+%Y%m%d")
```

‍

## if

```bash
######################### 基本语法: #########################
if [ command ]; then   
	# 符合该条件执行的语句
fi

######################### 扩展语法：#########################
if [ command ];then   
	# 符合该条件执行的语句
elif [ command ];then   
	# 符合该条件执行的语句
else 
	# 符合该条件执行的语句
fi


######################### 常用的：#########################
[ -a FILE ] #如果 FILE 存在则为真
[ -d FILE ] #如果 FILE 存在且是一个目录则返回为真
[ -e FILE ] #如果 指定的文件或目录存在时返回为真
[ -f FILE ] #如果 FILE 存在且是一个普通文件则返回为真
[ -r FILE ] #如果 FILE 存在且是可读的则返回为真
[ -w FILE ] #如果 FILE 存在且是可写的则返回为真（一个目录为了它的内容被访问必然是可执行的）
[ -x FILE ] #如果 FILE 存在且是可执行的则返回为真
 
######################### 不常用的：#########################
[ -b FILE ] #如果 FILE 存在且是一个块文件则返回为真
[ -c FILE ] #如果 FILE 存在且是一个字符文件则返回为真
[ -g FILE ] #如果 FILE 存在且设置了SGID则返回为真
[ -h FILE ] #如果 FILE 存在且是一个符号符号链接文件则返回为真（该选项在一些老系统上无效）
[ -k FILE ] #如果 FILE 存在且已经设置了冒险位则返回为真
[ -p FILE ] #如果 FILE 存并且是命令管道时返回为真
[ -s FILE ] #如果 FILE 存在且大小非0时为真则返回为真
[ -u FILE ] #如果 FILE 存在且设置了SUID位时返回为真
[ -O FILE ] #如果 FILE 存在且属有效用户ID则返回为真
[ -G FILE ] #如果 FILE 存在且默认组为当前组则返回为真（只检查系统默认组）
[ -L FILE ] #如果 FILE 存在且是一个符号连接则返回为真
[ -N FILE ] #如果 FILE 存在 and has been mod如果ied since it was last read则返回为真
[ -S FILE ] #如果 FILE 存在且是一个套接字则返回为真
[ FILE1 -nt FILE2 ] #如果 FILE1 比 FILE2 新, 或者 FILE1 存在但是 FILE2 不存在则返回为真
[ FILE1 -ot FILE2 ] #如果 FILE1 比 FILE2 老, 或者 FILE2 存在但是 FILE1 不存在则返回为真
[ FILE1 -ef FILE2 ] #如果 FILE1 和 FILE2 指向相同的设备和节点号则返回为真

######################### 字符串判断 #########################
[[ -z STRING ]] #如果STRING的长度为零则返回为真，即空是真
[[ -n STRING ]] #如果STRING的长度非零则返回为真，即非空是真
[[ STRING1 ]]　 #如果字符串不为空则返回为真,与-n类似
[[ STRING1 == STRING2 ]] #如果两个字符串相同则返回为真
[[ STRING1 != STRING2 ]] #如果字符串不相同则返回为真
[[ STRING1 < STRING2 ]]  #如果 “STRING1”字典排序在“STRING2”前面则返回为真
[[ STRING1 > STRING2 ]]  #如果 “STRING1”字典排序在“STRING2”后面则返回为真

######################### 数值判断 #########################
[ INT1 -eq INT2 ] #INT1和INT2两数相等返回为真 ,=
[ INT1 -ne INT2 ] #INT1和INT2两数不等返回为真 ,<>
[ INT1 -gt INT2 ] #INT1大于INT2返回为真 ,>
[ INT1 -ge INT2 ] #INT1大于等于INT2返回为真,>=
[ INT1 -lt INT2 ] #INT1小于INT2返回为真 ,<
[ INT1 -le INT2 ] #INT1小于等于INT2返回为真,<=

######################### 逻辑判断 #########################
[ ! EXPR ] #逻辑非，如果 EXPR 是false则返回为真
[ EXPR1 -a EXPR2 ] #逻辑与，如果 EXPR1 and EXPR2 全真则返回为真
[ EXPR1 -o EXPR2 ] #逻辑或，如果 EXPR1 或者 EXPR2 为真则返回为真
[ ] || [ ] #用OR来合并两个条件
[ ] && [ ] #用AND来合并两个条件

```

* Test 和 [ ] ：是bash 的内部命令，可用的比较运算符只有==和!=，两者都是用于字符串比较的，不可用于整数比较，整数比较只能使用-eq，-gt这种形式。无论是字符串比较还是整数比较都不支持大于号小于号。

* [[ ：是 bash 程序语言的关键字。并不是一个命令，[[ ]] 结构比[ ]结构更加通用，能够防止脚本中的许多逻辑错误。比如，&&、||、<和> 操作符能够正常存在于[[ ]]条件判断结构中，

* 单小括号 ()：

      命令组，括号中的命令将会新开一个子shell顺序执行，所以括号中的变量不能够被脚本余下的部分使用。括号中多个命令之间用分    号隔开  
      命令替换，等同于cmd，shell扫描一遍命令行，发现了$(cmd)结构，便将$(cmd)中的cmd执行一次，得到其标准输出，再将此输  出放到原来命令。  
      用于初始化数组，如：array=(a b c d)

* 双小括号 (( ))：

       整数扩展。这种扩展计算是整数型的计算，不支持浮点型。  
      只要括号中的运算符、表达式符合C语言运算规则，都可用在$((exp))中，甚至是三目运算符。  
      单纯用 (( )) 也可重定义变量值，比如 a=5; ((a++)) 可将 $a 重定义为6  
      常用于算术运算比较，双括号中的变量可以不使用$符号前缀。

‍

## while & for

```bash
while (true)
do

# continue命令用于中止本次循环，重新判断循环条件，开始下一次循环。
# break命令用于跳出循环，使用break可以跳出任何类型的循环
done
  
===================================
for package in  bc binutils compat-libcap1 compat-libstdc++ 
do
  
done
====================================
array=("bc" "binutils" "compat-libcap1" "compat-libstdc++")
for package in ${array[@]}
```

‍

## read

功能：默认接受键盘的输入，回车符代表输入结束
应用场景：人机交互
命令选项

```bash
#-p  打印信息
#-t  限定时间
#-s  不回显
#-n  输入字符个数

read -p "$(echo -e "\n\e[1;33m 请输入数据库服务器ip地址: \e[0m")" MY_ENTER_SRV_IP
```

## nohub

```bash
nohup ./startWebLogic.sh > out.log 2>&1 &
# nohup+最后面的& 是让命令在后台执行
# > out.log 是将信息输出到out.log日志中
# 2>&1 是将标准错误信息转变成标准输出，这样就可以将错误信息输出到out.log 日志里面来
```

## find

```bash
-option：
  -name   filename  # 查找名为filename的文件
  -perm             # 按执行权限来查找
  -user   username  # 按文件属主来查找
  -group  groupname # 按组来查找
  -mtime  -n +n     # 按文件更改时间，-n指n天以内，+n指n天以前
  -atime  -n +n     # 按文件访问时间，-n指n天以内，+n指n天以前
  -ctime  -n +n     # 按文件创建时间，-n指n天以内，+n指n天以前
  -maxdepth <number># number 指定搜索深度.注意使用该参数时，放在最前面
  -type b/d/c/p/l/f # 查是块设备、目录、字符设备、管道、符号链接、普通文件
  -size   n[c]      # 查长度为n块[或n字节]的文件
  -mount            # 查文件时不跨越文件系统mount点
  -nogroup          # 查无有效属组的文件，即文件的属组在/etc/groups中不存在
  -nouser           # 查无有效属主的文件，即文件的属主在/etc/passwd中不存
  -follow           # 如果遇到符号链接文件，就跟踪链接所指的文件
  -prune            # 忽略某个目录
find ./ -type d | sed -n '2,$p' | xargs rm -rf {}  # 只删除目录
find ./ -type f -ctime +30 | xargs rm -rf {}       # 删除30天前创建的文件
========================================================
```

## | xargs & exec

```bash
管道|  # 用来将前一个命令的标准输出传递到下一个命令的标准输入
xargs  # 将前一个命令的标准输出传递给下一个命令，作为它的参数,而不是标准输入。
exec   # 所有匹配到的文件一起传递给exec执行,xargs命令每次只获取一部分文件而不是全部
--------------------------------------------------------------------
#例如
echo "password"|passwd --stdin user
find /data/log -mtime +7 -name *.log |xargs rm -rf
```

## echo

```bash
# 字颜色：30—–37
echo -e "\033[30m 黑色字 \033[0m"
echo -e "\033[31m 红色字 \033[0m" 
echo -e "\033[32m 绿色字 \033[0m" 
echo -e "\033[33m 黄色字 \033[0m" 
echo -e "\033[34m 蓝色字 \033[0m" 
echo -e "\033[35m 紫色字 \033[0m" 
echo -e "\033[36m 天蓝字 \033[0m" 
echo -e "\033[37m 白色字 \033[0m"

#字背景颜色范围：40—–47 
echo -e "\033[40;37m 黑底白字 \033[0m"
echo -e "\033[41;37m 红底白字 \033[0m" 
echo -e "\033[42;37m 绿底白字 \033[0m" 
echo -e "\033[43;37m 黄底白字 \033[0m" 
echo -e "\033[44;37m 蓝底白字 \033[0m" 
echo -e "\033[45;37m 紫底白字 \033[0m" 
echo -e "\033[46;37m 天蓝底白字 \033[0m" 
echo -e "\033[47;30m 白底黑字 \033[0m"

# 控制选项说明 
\33[0m   关闭所有属性 
\33[1m   设置高亮度 
\33[4m   下划线 
\33[5m   闪烁 
\33[7m   反显 
\33[8m   消隐 
\33[30m — \33[37m 设置前景色 
\33[40m — \33[47m 设置背景色 
\33[nA   光标上移n行 
\33[nB   光标下移n行 
\33[nC   光标右移n行 
\33[nD   光标左移n行 
\33[y;xH  设置光标位置 
\33[2J   清屏 
\33[K    清除从光标到行尾的内容 
\33[s    保存光标位置 
\33[u    恢复光标位置 
\33[?25l 隐藏光标 
\33[?25h 显示光标
```

## expect

```bash
# expect是一个自动化交互套件，主要应用于执行命令和程序时，系统以交互形式要求输入指定字符串，实现交互通信。
# expect自动交互流程：spawn启动指定进程---expect获取指定关键字---send向指定程序发送指定字符---执行完成退出.
# 安装expect
yum install -y expect

expect <<EOF
set timeout 1
spawn mysql_secure_installation
expect "Enter password for user root:"
send "xhfusew_23@sdg\n"
expect "New password:"
send "Ninestar@2021\n"
EOF
```

## sort & uniq

```bash
uniq   #用于检查及删除文本文件中重复出现的行列，一般与 sort 命令结合使用
  -c 在每列旁边显示该行重复出现的次数
  -d 仅显示重复出现的行列
  -u 仅显示出一次的行列
sort  #排序
例:lastb | awk '{print $3}' | sort | uniq -c  #查看ssh登陆失败ip次数
```

## envsubst

```bash
# 主要用来替换配置文件的值 应用场景：docker run 自动修改jdbc配置文件
# 1.现在命令行中设定环境变量
export MY_NAME=sds
# 2.模块文件config.template
--------------------------
user_name="${MY_NAME}"
--------------------------
# 3.执行命令
envsubst < config.template > config.yaml
# 4.则会生成文件config.yaml
--------------------------------
user_name=sds
--------------------------------
```

## flock

```bash
# flock即文件锁，是建议性锁，需要各进程主动去获取与释放。
# flock适合进程间通信，不适合用作线程间互斥。
# 主要应用在解决文件读写冲突上。

flock -xn /approutine.lock -c /app/mon.sh

#例如在crontab定时执行脚本时，若执行周期为5min，但是该脚本执行了10min，导致重复无意义的执行，可能会出问题。
#我们给min.sh脚本上锁，只有这个脚本进程结束后才可以再次执行。

flock [options] <file|directory> -c <command>

选项：
  -s --shared获得共享锁
  -x --exclusive获取一个排他锁（默认）
  -u --unlock删除锁
  -n --nonblock失败而不是等待
  -w --timeout <secs>等待有限的时间
  -E --conflict-exit-code <number>冲突或超时后的退出代码
  -o --close在运行命令之前关闭文件描述符
  -c --command <命令>通过新开shell运行单个命令
  -h，--help显示此帮助并退出
  -V，--version输出版本信息并退出
```

## $？

```bash
$$   # Shell本身的PID
$!   # Shell最后运行的后台Process的PID
$?   # 最后运行的命令的结束代码（返回值） 0表示没有错误，其他任何值表明有错误)
$-   # 显示shell使用的当前选项，与set命令功能相同
$*   # 所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数
$@   # 所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
$@   # 跟$*类似，但是可以当作数组用
$#   # 添加到Shell的参数个数
$0   # Shell本身的文件名
$1～$n  # 添加到Shell的各参数值。$1是第1参数、$2是第2参数…。
```

## #\%

```bash
" ## "   表示最后一个该字符及其左边的部分  
" #  "   表示第一个该字符及其左边的部分  
" %  "   表示最后一个该字符及其右边的部分  
" %% "   表示第一个该字符及其右边的部分

# 例如：
root@devops Mysql-8.0-Binary-Install $ package=mysql-8.0.26-linux-glibc2.12-x86_64.tar.xz
root@devops Mysql-8.0-Binary-Install $ echo ${package%%-*}
mysql
root@devops Mysql-8.0-Binary-Install $ echo ${package%.*}
mysql-8.0.26-linux-glibc2.12-x86_64.tar
root@devops Mysql-8.0-Binary-Install $ 
root@devops Mysql-8.0-Binary-Install $ echo ${package%.*.*}
mysql-8.0.26-linux-glibc2.12-x86_64
root@devops Mysql-8.0-Binary-Install $
```

# shell 数组

# 什么是数组

- 存储多个元素的连续的内存空间。数组只有一个名字，索引号从0开始。
- 关联数组的索引号可以自定义，bash4及以后版本支持关联数组。
- Bash 支持一维数组（不支持多维数组），并且没有限定数组的大小。
- 获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于0。

# 如何定义一个数组

用括号表示数组，数组元素用 “空格” 符号分割开

使用 `declare -a ips`​ 定义一个名为 ips 的索引数组

```bash
[user1@study ~]$ declare -a ips  # 一般可以省略这条语句，直接使用下面的方法定义即可
[user1@study ~]$ ips=(10.0.0.0/8 172.16.0.0/12 192.168.0.0/16)
[user1@study ~]$ echo ${ips[0]}
10.0.0.0/8
[user1@study ~]$ echo ${ips[1]}
172.16.0.0/12
[user1@study ~]$ echo ${ips[2]}
192.168.0.0/16
[user1@study ~]$ echo ${ips[*]}
10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
[user1@study ~]$ echo ${ips[@]}
10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

```

使用 `declare -A IPS`​ 定义一个名为 IPS 的关联数组

```bash
[user1@study ~]$ declare -A IPS
[user1@study ~]$ IPS=([ip1]='10.0.0.0/8' [ip2]='172.16.0.0/12' [ip3]='192.168.0.0/16')
[user1@study ~]$ echo ${IPS[ip1]}
10.0.0.0/8
[user1@study ~]$ echo ${IPS[ip2]}
172.16.0.0/12
[user1@study ~]$ echo ${IPS[ip3]}
192.168.0.0/16
[user1@study ~]$
```

# 元素赋值

单个元素赋值，直接通过 `数组名[下标]`​ 就可以对其进行引用赋值，如果下标不存在，自动添加新一个数组元素

```bash
[user1@study ~]$ ips=(2222 55555)   # 全部元素赋值
[user1@study ~]$ ips[0]='100.64.0.0/10'  # 单个元素赋值
[user1@study ~]$ ips[2]='8.8.8.8'  
[user1@study ~]$ ips[9]='8.8.8.8'
[user1@study ~]$ echo ${ips[0]} ${ips[1]} ${ips[2]} ${ips[9]}          
100.64.0.0/10 55555 8.8.8.8 8.8.8.8
[user1@study ~]$
```

特定元素赋值

```bash
[user1@study ~]$ abc=([0]='123' [1]='456')
[user1@study ~]$ echo ${abc[0]} ${abc[1]}
123 456
[user1@study ~]$
```

使用命令替换赋值

```bash
[user1@study ~]$ abc=( $(seq 10) )
[user1@study ~]$ echo ${abc[3]}
4
[user1@study ~]$
```

交互式赋值，直接在提示符中写，写后回车即可

```bash
[user1@study ~]$ read -a array_name
Tom Jerry   
[user1@study ~]$ echo ${array_name[0]}
Tom
[user1@study ~]$ echo ${array_name[1]}
Jerry
[user1@study ~]$ read -a array_name <<< "Tom Jerry yes no"   # 和上面的方法完全一样
[user1@study ~]$ echo ${array_name[2]} 
yes
[user1@study ~]$
```

关联数组赋值，直接给定下标名

```bash
[user1@study ~]$ declare -A world
[user1@study ~]$ world[us]="america"
[user1@study ~]$ world[uk]="United kingdom"
[user1@study ~]$ echo ${world[us]}
america
[user1@study ~]$
```

# 元素值引用

引用时只给数组名，表示引用为下标为 0 的元素

```bash
[user1@study ~]$ read -a array_name <<< "Tom Jerry yes no"
[user1@study ~]$ echo ${array_name}
Tom
[user1@study ~]$ echo ${array_name[3]}
no
[user1@study ~]$
```

使用 `${arrar_name[@]}`​ 或  `${array_name[*]}`​ 可以获取数组中的所有元素，区别是 `*`​ 是作为一个整体字符串，而 `@`​ 是把每个位置变量都分别作为独立的字符串

```bash
[user1@study ~]$ array_name=( $(seq 10) )
[user1@study ~]$ echo ${array_name[*]} 
1 2 3 4 5 6 7 8 9 10
[user1@study ~]$ echo ${array_name[@]}  
1 2 3 4 5 6 7 8 9 10
[user1@study ~]$ 
[user1@study ~]$ for i in "${array_name[*]}";do echo ${i};done
1 2 3 4 5 6 7 8 9 10
[user1@study ~]$ for i in "${array_name[@]}";do echo ${i};done 
1
2
3
4
5
6
7
8
9
10
[user1@study ~]$
```

# 数组长度引用

取得数组元素的个数

```bash
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
```

取得数组第一个元素的长度

```bash
lengthn=${#array_name}
```

取得数组单个元素的长度

```bash
lengthn=${#array_name[n]}
```

# 元素值提取

```bash
[user1@study ~]$ a=(net.nf_conntrack_max=====131072 net.ipv4.ip_forward===1 c====5)
[user1@study ~]$ echo ${a[1]#*=}  # 删掉数组 a 中第 2 个元素中第一个=及其左边的字符串
==1
[user1@study ~]$ echo ${a[1]##*=} # 删掉数组 a 中第 2 个元素中最后一个=及其左边的字符串
1
[user1@study ~]$ echo ${a[1]%=*}  # 删掉数组 a 中第 2 个元素中最后一个=及其右边的字符串
net.ipv4.ip_forward==
[user1@study ~]$ echo ${a[1]%%=*} # 删掉数组 a 中第 2 个元素中第一个=及其右边的字符串
net.ipv4.ip_forward
[user1@study ~]$
```

# 获取元素下标

```bash
[user1@study ~]$ array=(a b c d e f g)
[user1@study ~]$ echo ${array[0]}  # 数组的第一个元素
a
[user1@study ~]$ echo ${!array[@]}  # 数组所有的下标
0 1 2 3 4 5 6
[user1@study ~]$ for i in ${!array[@]};do echo ${array[i]} ;done  # 在数组里的所有元素
a
b
c
d
e
f
g
[user1@study ~]$
```

# 删除元素

直接通过：`unset 数组[下标]`​ 可以清除相应的元素；不带下标，清除整个数据

```bash
[user1@study ~]$ a=( $(seq 10) )
[user1@study ~]$ echo ${a[2]}
3
[user1@study ~]$ unset a[2]
[user1@study ~]$ echo ${a[2]} 

[user1@study ~]$ echo ${a[*]}
1 2 4 5 6 7 8 9 10
[user1@study ~]$ unset a
[user1@study ~]$ echo ${a[*]}

[user1@study ~]$
```

# 元素切片

使用 `${array_name[@]:offset:number}`​ 的格式来实现数组中元素的切片， 其中 `offset`​ 指的是要跳过元素的个数， `number`​ 指的是要取出元素的个数，省略 `number`​ 时，表示取偏移量之后的所有元素

对数组切片后返回的是字符串，中间用空格分开，因此如果切片后的结果加上 `()`​，将得到切片数组

```bash
[user1@study ~]$ a=(1 2 3 4 5)
[user1@study ~]$ echo ${a[@]:0:3}
1 2 3
[user1@study ~]$ echo ${a[@]:1:4} 
2 3 4 5
[user1@study ~]$ c=(${a[@]:1:4})
[user1@study ~]$ echo ${#c[@]}
4
[user1@study ~]$ echo ${c[*]} 
2 3 4 5
[user1@study ~]$
```

# 元素值替换

使用 `${array_name[@或*]/searchstr/replacestr}`​ 的格式可以实现元素值的查找替换，其中 `searchstr`​ 指的是要查找的字符串， `replacestr`​ 指的是要替换成什么样的字符串

```bash
[user1@study ~]$  a=(1 2 3 4 5)
[user1@study ~]$ echo ${a[@]/3/100}
1 2 100 4 5
[user1@study ~]$ echo ${a[@]}
1 2 3 4 5
[user1@study ~]$ a=(${a[@]/3/100})
[user1@study ~]$ echo ${a[@]}
1 2 100 4 5
[user1@study ~]$ A=(100 101 102 103 104);B=".txt"
[user1@study ~]$ echo ${A[@]/%/$B}
100.txt 101.txt 102.txt 103.txt 104.txt
[user1@study ~]$
```

元素值替换操作不会改变原先数组的内容，如果需要修改则需要重新定义数据。

# 应用示例

设置内核参数

```
#!/bin/bash

args_of_kernel=(net.ipv4.ip_forward=1
    net.ipv4.route.max_size=131072 
    net.nf_conntrack_max=131072 
    net.netfilter.nf_conntrack_tcp_timeout_established=1800 
    net.netfilter.nf_conntrack_tcp_timeout_time_wait=30 
    net.netfilter.nf_conntrack_tcp_timeout_syn_sent=40 
    net.ipv4.conf.default.rp_filter=0 
    net.ipv4.conf.all.rp_filter=0 
    net.ipv4.conf.default.accept_source_route=0 
    net.ipv4.conf.all.arp_ignore=1 
    net.ipv4.conf.all.arp_announce=2)
config_of_kernel='/etc/sysctl.conf'

cp ${config_of_kernel}{,.bak}

for i in ${!args_of_kernel[@]};do
    if /bin/egrep -q ${args_of_kernel[$i]%%=*} $config_of_kernel;then
        /bin/sed -ri "s/(^${args_of_kernel[$i]%%=*} = ).*/\1${args_of_kernel[$i]##*=}/" $config_of_kernel
    else
        if [ $i -eq 0 ] ;then 
            fgrep -qs forwarding ${kernel_cnf} || echo  -e '\n# Controls IP packet forwarding' >> $config_of_kernel
            line_n=`/bin/gawk '/forwarding/{print NR}' $config_of_kernel`
        else
            line_n=`/bin/gawk '/'"${args_of_kernel[$((i-1))]%%=*}"'/{print NR}' $config_of_kernel`
        fi
        /bin/sed -ri "${line_n}a${args_of_kernel[$i]%%=*} = ${args_of_kernel[$i]##*=}" $config_of_kernel
    fi
done
unset i line_n config_of_kernel args_of_kernel
```

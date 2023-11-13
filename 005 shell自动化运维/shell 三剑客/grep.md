# grep

grep 命令用于查找文件里符合条件的字符串的一行打印出来。

grep命令家族有 grep、egrep、fgrep 三个子命令，适用于不通的场景，具体如下：

```bash
1.grep  原生的grep命令，使用“标准正则表达式”作为匹配标准
2.egrep 扩展的grep命令，相当于 $(grep -E) ，使用“扩展正则表达式”作为匹配标准
3.fgrep 简化版的grep命令，不支持正则表达式，但搜索速度快，系统资源使用率低
```

## 参数说明

```bash
##########  OPTIONS 部分  ##########
-v  # 显示没有被匹配到的行   [ps -ef|grep frps | grep -v grep]
-i  # 忽略大小写     [grep 'tEst' test.txt ]
-n  # 显示匹配的行号 [grep -n 'test' test.txt ]
-c  # 统计匹配的行数 [grep -c 'test' test.txt ]
-q  # 静默模式，不输出任何信息
-e  # 实现多个选项间的逻辑or关系
-w  # 只显示全字符合的列。
-f  # 指定范本文件，其内容有一个或多个范本样式，让grep查找符合范本条件的文件内容，格式为每一列的范本样式。
-o  # 只输出文件中匹配到的部分。
-E  # 使用扩展的正则表达式，egrep = grep -E
-A  # 显示被匹配到的行和后面的几行 [ cat test.txt |grep  ' ' -A 1]
-B  # 显示被匹配到的行和前面的几行 [ cat test.txt |grep  ' ' -A 1]
-C  # 显示被匹配到的前后各几行
```

## 案例

```bash
# 显示paswwd文件除root用户的所有行
cat /etc/passwd|grep -v root
```

‍

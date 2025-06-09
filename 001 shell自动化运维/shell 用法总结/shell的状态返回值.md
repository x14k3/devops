# shell的状态返回值 

在 shell 中，每个命令都会返回一个状态返回值。成功的命令返回 `0`​，而不成功的命令返回非零值。非零值通常都被解释成一个错误码。

在 shell 中`$?`​ 是一个特殊变量，它所引用的值就是上一条命令的执行状态返回值。

- 在 shell 的函数执行后，`$?`​ 返回的是函数执行的最后一条命令的状态返回值
- 在 shell 脚本执行之后，`$?`​ 返回的是脚本执行的最后一条命令的状态返回值

在脚本中，`exit n`​ 命令将会把 `n`​ 退出状态码传递给父 shell 并结束整个脚本。`n`​ 必须是十进制数, 范围是`0 - 255`​。以下是常见的状态码及意义

- 0 运行成功
- 2 权限拒绝
- 1~125 表示运行失败，脚本命令、系统命令错误或参数传递错误
- 126 找到命令了，但是无法执行
- 127 要运行的命令不存在
- 128 命令被系统强制结束

```bash
[user1@study ~]$ cat exitstatus.sh
#! /bin/bash

echo -e "Successful execution"
echo -e "====================="
echo "hello world"
# Exit status returns 0, because the above command is a success.
echo "Exit status" $? 

echo -e "Incorrect usage"
echo -e "====================="
ls --option
# Incorrect usage, so exit status will be 2.
echo "Exit status" $? 

echo -e "Command Not found"
echo -e "====================="
bashscript
# Exit status returns 127, because bashscript command not found
echo "Exit status" $? 

echo -e "Command is not an executable"
echo -e "============================="
> execution.sh
ls -l execution.sh
./execution.sh
# Exit status returns 126, because its not an executable.
echo "Exit status" $?
```

执行上面的 `exitstatus.sh`​ 查看各种退出状态

```bash
[user1@study ~]$ bash exitstatus.sh
Successful execution
=====================
hello world
Exit status 0
Incorrect usage
=====================
ls: unrecognized option '--option'
Try 'ls --help' for more information.
Exit status 2
Command Not found
=====================
exitstatus.sh: line 17: bashscript: command not found
Exit status 127
Command is not an executable
=============================
-rw-rw-r-- 1 user1 user1 0 Jul 15 23:33 execution.sh
exitstatus.sh: line 24: ./execution.sh: Permission denied
Exit status 126
[user1@study ~]$
```

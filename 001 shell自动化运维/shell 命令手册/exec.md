# exec

调用并执行指定的命令

## 补充说明

**exec命令** 用于调用并执行指令的命令。exec命令通常用在shell脚本程序中，可以调用其他的命令。如果在当前终端中使用命令，则当指定的命令执行完毕后会立即退出终端。

### 语法

```
exec(选项)(参数)
```

### 选项

```
-c：在空环境中执行指定的命令。
```

### 参数

指令：要执行的指令和相应的参数。

### 实例

```bash
[root@localhost tmp]# cat test_exec.sh 
#!/bin/bash
echo "1"
echo "2"
exec echo "exec 3"
echo "4"
echo "5"
[root@localhost tmp]# /bin/bash test_exec.sh 
1
2
exec 3
[root@localhost tmp]# 
```

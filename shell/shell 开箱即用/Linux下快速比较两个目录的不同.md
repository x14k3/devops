# Linux下快速比较两个目录的不同

## 使用rsync

```bash
rsync  -avnic  --delete /directory1/ root@192.168.141.102:/directory2/ | sed -n '2,/^$/{/^$/!p}'
# 注意：/directory1/路径后面一定要加 “/”
#-n 它表示dry run，也就是试着进行rsync同步，但不会真的同步。
#-i 列出源目录与目标目录中有差异的文件，并给出差异信息，具体差异信息的解释参考 rsync 手册页。
#-c 打开校验开关，强制对文件传输进行校验。
#--delete directory2有，directory1没有的列出来
```

脚本

```bash
#!/bin/bash

read -p "`echo -e "\n\e[1;36m  Please enter the target IP address : \e[0m"`" IpAddress
read -p "`echo -e "\n\e[1;36m  Please enter the directory you want to compare : \e[0m"`" Directory

rsync  -avnic  --delete ${Directory}/ root@${IpAddress}:${Directory}/ | sed -n '2,/^$/{/^$/!p}'
```

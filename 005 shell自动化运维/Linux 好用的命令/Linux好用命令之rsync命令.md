# Linux好用命令之rsync命令

针对实战使用进行讲解分析，不简简单单罗列命令参数了事。

## [#](https://wiki.eryajf.net/pages/5279.html#_1-%E6%9E%84%E5%BB%BA%E4%BD%BF%E7%94%A8%E3%80%82) 1，构建使用。

静态文件部署，一般会用到此命令，完整命令如下：

```
rsync -avz --progress -e 'ssh -p 34222' --exclude='Jenkinsfile' --delete ${WORKSPACE}/  root@192.168.0.1:/data/test/
```

* ​`-a`​：--archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
* ​`-v`​：输出详细过程
* ​`-z`​：对正在备份的文件进行压缩处理
* ​`-r`​：对子目录以递归模式处理
* ​`-l`​：保留软连接
* ​`-p`​：保持文件权限
* ​`-t`​：保持文件时间信息
* ​`-g`​：保持文件属组信息
* ​`-o`​：保持文件属主信息
* ​`-D`​：保持设备文件信息
* ​`-e`​： –rsh=command 指定使用rsh、ssh方式进行数据同步，一般使用ssh
* ​`exclude`​: 排除某文件的同步，可以多个。
* ​`--delete`​：删除那些DST中SRC没有的文件。
* ​`--progress`​：显示每个文件传输的进度。知道是否有大型文件正在备份可能是有用的。

​​

## [#](https://wiki.eryajf.net/pages/5279.html#_2-%E5%85%B6%E4%BB%96%E6%B3%A8%E6%84%8F%E3%80%82) 2，其他注意。

* **将dirA的所有文件同步到dirB内，并删除dirB内多余的文件**

  ```
  $ rsync -avz --delete dirA/ dirB/ 
  ```
  ​`源目录和目标目录结构一定要一致！！不能是dirA/* dirB/ 或者dirA/ dirB/* 或者 dirA/* dirB/*，如果不遵守，那么就不会删除。`​
* **将dirA的所有文件同步到dirB，但是在dirB内除了fileB3.txt这个文件不删之外，其他的都删除**

  ```
  $ rsync -avz --delete --exclude "fileB3.txt" dirA/ dirB/
  ```
* **将dirA目录内的fileA1.txt和fileA2.txt不同步到dirB目录内**

  ```
  $ rsync -avz --exclude="fileA1.txt" --exclude="fileA2.txt" dirA/ dirB/
  ```
* **将dirA目录内的fileA1.txt和fileA2.txt不同步到dirB目录内，并且在dirB目录内删除多余的文件**

  ```
  $ rsync -avz --exclude="fileA1.txt" --exclude="fileA2.txt" --delete dirA/ dirB/
  ```
* **将dirA目录内的fileA1.txt和fileA2.txt不同步到dirB目录内，并且在dirB目录内删除多余的文件，同时，如果dirB内有fileA2.txt和fileA1.txt这两个被排除同步的文件，仍然将其删除**

  ```
  $ rsync -avz --exclude="fileA1.txt" --exclude="fileA2.txt" --delete-excluded dirA/ dirB/
  ```

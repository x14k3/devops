

```bash
# 连接ftp服务器
ftp 192.168.0.100  # 服务器会询问你用户名和密码
ftp username:password@127.0.0.1:21
# 下载文件
get [remote-file] [local-path]
mget [remote-file]  # mget可以使用通配符批量下载到当前目录
# 上传文件
put local-file [remote-file]
mput local-files
# 断开连接
bye


```

## 参数

```shell
ftp> ascii  # 设定以ASCII方式传送文件(缺省值) 
ftp> bell   # 每完成一次文件传送,报警提示. 
ftp> binary # 设定以二进制方式传送文件. 
ftp> bye    # 终止主机FTP进程,并退出FTP管理方式. 
ftp> case   # 当为ON时,用MGET命令拷贝的文件名到本地机器中,全部转换为小写字母. 
ftp> cd     # 同UNIX的CD命令. 
ftp> cdup   # 返回上一级目录. 
ftp> chmod  # 改变远端主机的文件权限. 
ftp> close  # 终止远端的FTP进程,返回到FTP命令状态, 所有的宏定义都被删除. 
ftp> delete # 删除远端主机中的文件. 
ftp> dir [remote-directory] [local-file] # 列出当前远端主机目录中的文件.如果有本地文件,就将结果写至本地文件. 
ftp> get [remote-file] [local-file] # 从远端主机中传送至本地主机中. 
ftp> help [command] # 输出命令的解释. 
ftp> lcd # 改变当前本地主机的工作目录,如果缺省,就转到当前用户的HOME目录. 
ftp> ls [remote-directory] [local-file] # 同DIR. 
ftp> macdef                 # 定义宏命令. 
ftp> mdelete [remote-files] # 删除一批文件. 
ftp> mget [remote-files]    # 从远端主机接收一批文件至本地主机. 
ftp> mkdir directory-name   # 在远端主机中建立目录. 
ftp> mput local-files # 将本地主机中一批文件传送至远端主机. 
ftp> open host [port] # 重新建立一个新的连接. 
ftp> prompt           # 交互提示模式. 
ftp> put local-file [remote-file] # 将本地一个文件传送至远端主机中. 
ftp> pwd  # 列出当前远端主机目录. 
ftp> quit # 同BYE. 
ftp> recv remote-file [local-file] # 同GET. 
ftp> rename [from] [to]     # 改变远端主机中的文件名. 
ftp> rmdir directory-name   # 删除远端主机中的目录. 
ftp> send local-file [remote-file] # 同PUT. 
ftp> status   # 显示当前FTP的状态. 
ftp> system   # 显示远端主机系统类型. 
ftp> user user-name [password] [account] # 重新以别的用户名登录远端主机. 
ftp> ? [command] # 同HELP. [command]指定需要帮助的命令名称。如果没有指定 command，ftp 将显示全部命令的列表。
ftp> ! # 从 ftp 子系统退出到外壳。
```

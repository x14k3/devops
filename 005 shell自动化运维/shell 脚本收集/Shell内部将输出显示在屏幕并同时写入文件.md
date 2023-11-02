# Shell内部将输出显示在屏幕并同时写入文件

‍

```bash
#输出日志文件
logfile=/tmp/Install_MySQL.log
shellout=/tmp/Install_MySQL.out
mkfifo $shellout
cat $shellout|tee $logfile &
exec > $shellout 2>&1
.......

.......
printf "\015"
rm -rf $shellout
```

‍

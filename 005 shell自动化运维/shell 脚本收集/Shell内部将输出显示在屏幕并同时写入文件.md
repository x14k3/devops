# Shell内部将输出显示在屏幕并同时写入文件

‍

```bash
#输出日志文件
logfile=/tmp/Install_MySQL.log
fifofile=/tmp/Install_MySQL.fifo
mkfifo $fifofile
cat $fifofile |tee $logfile &
exec >$fifofile 2>&1
.......

.......
printf "\015"
rm -rf $fifofile
```

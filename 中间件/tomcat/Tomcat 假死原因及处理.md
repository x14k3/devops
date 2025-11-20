
1. 应用本身程序的问题，造成死锁
2. load 太高，已经超出服务的极限
3. jvm GC时间过长，导致应用暂停 
    因为出错项目里面没有打出GC的处理情况，所以不确定此原因是否也是我项目tomcat假死的原因之一。
4. 大量 tcp 连接 CLOSE_WAIT 
    `netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'` 
# Sentinel单机部署

```bash
## 创建文件夹
mkdir -p /application

## 下载 Sentinel
wget https://github.com/alibaba/Sentinel/releases/download/1.8.2/sentinel-dashboard-1.8.2.jar

# 拷贝 sentinel-dashboard-1.8.2.jar 到 /application 目录
mv sentinel-dashboard-1.8.2.jar /application/sentinel-dashboard-1.8.2.jar

## 创建配置文件后启动 Sentinel
#---------------------------------------------------------------
# /application/sentinel/sentinel.properties 配置
project.name = sentinel
csp.sentinel.metric.file.single.size=100
csp.sentinel.log.dir=/data/sentinel/logs
csp.sentinel.log.use.pid=true
csp.sentinel.dashboard.server=10.2.9.152:8170
#---------------------------------------------------------------

# 启动
java -Dcsp.sentinel.config.file=/application/sentinel/sentinel.properties -jar /application/sentinel-dashboard-1.7.2.jar


```

配置日志自动清理

```bash
#!/bin/bash

# 初始化
LOGS_PATH=/data/sentinel/logs

for file in $LOGS_PATH/*
do
    if test -f $file
    then
        echo $file
        #find $file -mtime +15 -name '*[0-9]*-[0-9]*-[0-9]*' | xargs rm -f
    else
        find $file -mtime +15 -name '*[0-9]*-[0-9]*-[0-9]*' | xargs rm -f
    fi
done

exit 0
```

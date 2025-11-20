
Java OOM（OutOfMemoryError）是Java应用中常见的问题，处理需要系统化的方法。以下是完整的Java OOM处理方案：

## 1. 立即应急处理

### 快速确认OOM类型

```bash
# 查看应用日志，识别OOM类型
tail -f /path/to/application.log | grep -i "outofmemory"

# 常见的OOM错误类型：
# - Java heap space
# - GC overhead limit exceeded
# - PermGen space / Metaspace
# - Unable to create new native thread
# - Requested array size exceeds VM limit
```

### 紧急重启和内存释放

```bash
# 1. 优雅重启应用
./bin/shutdown.sh && ./bin/startup.sh

# 2. 强制重启（如果优雅重启失败）
kill -9 <java_pid>
./bin/startup.sh

# 3. 清理临时文件
rm -rf /tmp/hsperfdata_*
```


## 2. JVM参数调优（预防和缓解）

### 基础内存参数

```bash
# 启动参数示例
java -Xms2g -Xmx4g \
     -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
     -Xss512k \
     -jar your-application.jar
```

### 详细的JVM调优参数

```bash
java -Xms4g -Xmx4g \                    # 堆内存初始和最大
     -XX:NewSize=2g -XX:MaxNewSize=2g \ # 年轻代大小
     -XX:SurvivorRatio=8 \              # Eden:Survivor比例
     -XX:MetaspaceSize=256m \           # 元空间初始
     -XX:MaxMetaspaceSize=512m \        # 元空间最大
     -Xss512k \                         # 线程栈大小
     -XX:+UseG1GC \                     # 使用G1垃圾收集器
     -XX:MaxGCPauseMillis=200 \         # 最大GC停顿时间
     -XX:ParallelGCThreads=4 \          # 并行GC线程数
     -XX:ConcGCThreads=2 \              # 并发GC线程数
     -XX:+HeapDumpOnOutOfMemoryError \  # OOM时生成堆转储
     -XX:HeapDumpPath=/path/to/dumps/ \ # 堆转储路径
     -XX:OnOutOfMemoryError="restart.sh" \ # OOM时执行脚本
     -jar your-app.jar
```

## 3. 堆转储分析

### 生成堆转储文件

```bash
# 1. OOM时自动生成（推荐）
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path/to/dumps/

# 2. 手动生成堆转储
jmap -dump:live,format=b,file=heap.hprof <pid>

# 3. 使用jcmd生成
jcmd <pid> GC.heap_dump /path/to/heap.hprof
```

### 分析堆转储工具

#### 使用Eclipse MAT（Memory Analyzer Tool）

```bash
# 下载MAT：https://www.eclipse.org/mat/
# 分析步骤：
1. 打开MAT，加载heap.hprof文件
2. 查看Leak Suspects Report（泄漏嫌疑报告）
3. 分析Dominator Tree（支配树）
4. 查看Histogram（直方图）
```

#### 使用JVisualVM

```bash
jvisualvm
# 步骤：
# 1. 安装Visual GC插件
# 2. 加载堆转储文件
# 3. 分析对象实例和引用链
```

#### 使用命令行工具快速分析

```bash
# 查看堆内存摘要
jmap -heap <pid>

# 查看对象统计
jmap -histo:live <pid> | head -20

# 分析类加载器
jmap -clstats <pid>
```

## 内存监控和诊断

### JVM内置监控

```bash
# 监控GC情况
jstat -gc <pid> 1s

# 监控类加载
jstat -class <pid> 1s

# 监控JIT编译
jstat -compiler <pid> 1s
```

### 编写监控脚本

```bash
#!/bin/bash
# monitor_jvm.sh

PID=$1
INTERVAL=5

while true; do
    echo "=== $(date) ==="
    
    # 堆内存使用
    jstat -gc $PID | tail -1 | awk '{print "Old: "$4"K, Eden: "$3"K, S0: "$5"K, S1: "$6"K"}'
    
    # 线程数
    thread_count=$(jstack $PID | grep 'java.lang.Thread.State' | wc -l)
    echo "Thread count: $thread_count"
    
    # 类加载数
    jstat -class $PID | tail -1 | awk '{print "Loaded: "$1", Unloaded: "$2"}'
    
    sleep $INTERVAL
done
```


## 自动化处理脚本

### OOM自动重启和报警

```bash
#!/bin/bash
# oom_watcher.sh

APP_PID_FILE="/var/run/app.pid"
LOG_FILE="/var/log/app/application.log"
RESTART_SCRIPT="/opt/app/restart.sh"

while true; do
    if [ ! -f "$APP_PID_FILE" ]; then
        echo "PID file not found, waiting..."
        sleep 10
        continue
    fi
    
    PID=$(cat "$APP_PID_FILE")
    
    # 检查进程是否存在
    if ! kill -0 $PID 2>/dev/null; then
        echo "Process $PID not running, checking for OOM..."
        
        # 检查日志中的OOM错误
        if tail -100 "$LOG_FILE" | grep -q "OutOfMemoryError"; then
            echo "OOM detected, restarting application..."
            
            # 发送报警
            echo "Application OOM, restarting..." | mail -s "OOM Alert" admin@example.com
            
            # 执行重启
            $RESTART_SCRIPT
            
            # 生成堆转储分析报告
            if command -v jmap &> /dev/null; then
                jmap -histo:live $PID > /tmp/oom_analysis_$(date +%Y%m%d_%H%M%S).txt
            fi
        fi
    fi
    
    sleep 30
done
```


## 预防措施

### 压力测试和内存分析

```bash
# 使用JMeter进行压力测试
jmeter -n -t test_plan.jmx -l result.jtl

# 使用jstat监控测试过程
jstat -gc <pid> 1s 1000 > gc.log
```


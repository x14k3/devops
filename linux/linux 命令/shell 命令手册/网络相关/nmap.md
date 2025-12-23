## 一、主机发现参数详解

### 1. Ping扫描参数

```bash
# 基础参数
-sn: Ping扫描（不扫描端口）
-Pn: 跳过主机发现，假设所有主机在线
-PS <portlist>: TCP SYN Ping
-PA <portlist>: TCP ACK Ping
-PU <portlist>: UDP Ping
-PY <portlist>: SCTP INIT Ping
-PE: ICMP Echo Ping
-PP: ICMP Timestamp Ping
-PM: ICMP Netmask Ping
-PO <protocol list>: IP协议Ping

# 示例
nmap -PE -PS22,80 -PA21,443 -PU53 192.168.1.0/24
```

### 2. 主机发现超时控制

```bash
--max-hostgroup <size>: 并行扫描的最大主机数
--min-hostgroup <size>: 并行扫描的最小主机数
--max-parallelism <num>: 最大并行探测数
--min-parallelism <num>: 最小并行探测数
--max-rtt-timeout <time>: 最大往返时间
--min-rtt-timeout <time>: 最小往返时间
--initial-rtt-timeout <time>: 初始往返时间
--max-retries <tries>: 最大重试次数
--host-timeout <time>: 放弃超时的主机

# 示例
nmap -T4 --min-hostgroup 64 --max-rtt-timeout 1000ms 192.168.1.0/24
```

## 二、端口扫描参数详解

### 1. 扫描类型参数

```bash
# TCP扫描
-sS: TCP SYN扫描（半开放扫描）
-sT: TCP Connect扫描（全连接扫描）
-sA: TCP ACK扫描
-sW: TCP窗口扫描
-sM: TCP Maimon扫描

# UDP扫描
-sU: UDP扫描

# 特殊扫描
-sN: TCP Null扫描
-sF: TCP FIN扫描
-sX: TCP Xmas扫描

# 协议扫描
-sO: IP协议扫描

# 空闲扫描
-sI <zombie host[:probeport]>: 空闲扫描

# 示例
sudo nmap -sS -sU -p 1-1000 192.168.1.1
```

### 2. 端口规范参数

```bash
-p <port ranges>: 只扫描指定端口
-p U:<ports>: 指定UDP端口
-p T:<ports>: 指定TCP端口
-p-: 扫描所有端口(1-65535)
-p 1-1024: 扫描1-1024端口
-p http,https: 扫描服务名称对应的端口
-p 22,80,443: 扫描指定端口

-F: 快速扫描（扫描100个常用端口）
-r: 按顺序扫描端口（不随机）
--top-ports <number>: 扫描最常用的端口

# 示例
nmap -p 22,80,443,8080-8090 192.168.1.1
nmap -p U:53,67,68,T:21,22,23 192.168.1.1
```

## 三、服务/版本检测参数

### 1. 版本检测参数

```bash
-sV: 探测服务/版本信息
--version-intensity <level>: 设置版本扫描强度(0-9)
--version-light: 轻量级版本扫描（强度2）
--version-all: 尝试每个探测（强度9）
--version-trace: 显示详细的版本扫描活动

# 示例
nmap -sV --version-intensity 7 192.168.1.1
nmap -sV --version-light 192.168.1.0/24
```

### 2. 服务探测控制

```bash
-A: 启用OS检测、版本检测、脚本扫描和traceroute
--allports: 不为版本探测排除任何端口
--script-args: 为脚本提供参数
--osscan-limit: 仅对确定的主机进行OS检测
--osscan-guess: 推测操作系统检测结果

# 示例
nmap -A -T4 192.168.1.1
```

## 四、NSE脚本参数详解

### 1. 脚本选择参数

```bash
-sC: 使用默认脚本（等价于 --script=default）
--script <script/category>: 使用指定脚本或类别
--script-args <args>: 为脚本提供参数
--script-args-file <filename>: 从文件读取脚本参数
--script-trace: 显示所有发送和接收的数据
--script-updatedb: 更新脚本数据库
--script-help <script/category>: 显示脚本帮助

# 示例
nmap --script=http-title,http-headers 192.168.1.1
nmap --script vuln --script-args unsafe=1 192.168.1.1
```

### 2. 常用脚本类别

```bash
--script auth: 处理身份认证
--script broadcast: 局域网广播
--script brute: 暴力破解
--script default: 默认脚本
--script discovery: 网络发现
--script dos: 拒绝服务检测
--script exploit: 漏洞利用
--script external: 外部脚本
--script fuzzer: 模糊测试
--script intrusive: 侵入式脚本
--script malware: 恶意软件检测
--script safe: 安全脚本
--script version: 版本检测增强
--script vuln: 漏洞检测

# 示例
nmap --script safe 192.168.1.1
nmap --script discovery 192.168.1.0/24
```

## 五、操作系统检测参数

### 1. OS检测参数

```bash
-O: 启用操作系统检测
--osscan-limit: 只对确定的主机进行OS检测
--osscan-guess: 推测匹配的操作系统
--max-os-tries: 设置OS检测的最大尝试次数

# 示例
nmap -O --osscan-guess 192.168.1.1
```

## 六、时间和性能参数

### 1. 时间模板

```bash
-T0: 偏执（非常慢，用于IDS规避）
-T1: 鬼祟（慢，减少带宽消耗）
-T2: 文雅（较慢，减少对目标的影响）
-T3: 正常（默认，动态调整）
-T4: 快速（假设网络可靠）
-T5: 急速（可能丢失数据包）

# 示例
nmap -T4 --min-rate=1000 192.168.1.0/24
```

### 2. 性能控制

```bash
--min-hostgroup <size>: 最小并行主机组大小
--max-hostgroup <size>: 最大并行主机组大小
--min-parallelism <num>: 最小并行探测数
--max-parallelism <num>: 最大并行探测数
--min-rtt-timeout <time>: 最小往返时间
--max-rtt-timeout <time>: 最大往返时间
--initial-rtt-timeout <time>: 初始往返时间
--max-retries <tries>: 最大重试次数
--host-timeout <time>: 放弃超时主机

# 示例
nmap --min-parallelism 10 --max-parallelism 100 192.168.1.0/24
```

## 七、输出格式参数

### 1. 输出文件类型

```bash
-oN <file>: 标准输出
-oX <file>: XML输出
-oS <file>: ScRipT KIdd|3输出
-oG <file>: Grepable输出
-oA <basename>: 输出所有格式
-v: 增加详细程度
-d: 增加调试级别
--reason: 显示端口状态原因
--stats-every <time>: 定期打印扫描时间统计
--packet-trace: 显示所有发送和接收的数据包

# 示例
nmap -oA myscan -v --reason 192.168.1.1
```

### 2. 输出控制

```bash
--append-output: 追加到文件而非覆盖
--resume <filename>: 恢复中断的扫描
--stylesheet <path/URL>: 为XML输出关联XSL样式表
--webxml: 使用Nmap.org的样式表
--no-stylesheet: 避免在XML输出中关联XSL样式表

# 示例
nmap -oX scan.xml --stylesheet=nmap.xsl 192.168.1.1
```

## 八、防火墙/IDS规避参数

### 1. 数据包分片

```bash
-f: 使用微小的分片IP数据包
--mtu <val>: 使用指定的MTU大小
-D <decoy1,decoy2[,ME],...>: 使用诱饵隐藏扫描
-S <IP_Address>: 欺骗源地址
-e <iface>: 使用指定接口
--source-port <portnum>: 使用指定源端口
--data-length <num>: 附加随机数据
--ip-options <options>: 使用指定的IP选项
--ttl <val>: 设置IP生存时间字段
--spoof-mac <mac address/prefix/vendor name>: 欺骗MAC地址
--badsum: 发送带有错误校验和的数据包

# 示例
nmap -f -D RND:10 --data-length 200 192.168.1.1
nmap --spoof-mac 0 -S 192.168.1.99 -e eth0 192.168.1.1
```

## 九、常用实例

### 1. 基础网络发现

```bash
# 发现本地网络中的所有活动主机
nmap -sn 192.168.1.0/24
# 扫描指定范围
nmap -sn 192.168.1.1-100

# 带详细信息的网络发现
nmap -sn -v 192.168.1.0/24 | grep "Nmap scan"

# 快速导出在线主机列表
nmap -sn 192.168.1.0/24 | grep "report for" | awk '{print $NF}' | tr -d '()' > hosts.txt
```

### 2. 完整主机扫描

```bash
# 综合扫描（最常用）
nmap -A -T4 192.168.1.1

# 详细解释：
# -A: 启用OS检测、版本检测、脚本扫描和traceroute
# -T4: 快速扫描模式
```

### 3. 端口扫描示例

```bash
# 快速扫描常用端口
nmap -F 192.168.1.1

# 扫描所有端口
nmap -p- 192.168.1.1

# 扫描特定端口范围和服务
nmap -p 1-1000,3306,3389,8080,9000 192.168.1.1

# TCP和UDP混合扫描
sudo nmap -sS -sU -p T:1-1000,U:53,67,68,69,161 192.168.1.1
```

### 4. 服务版本检测

```bash
# 基本服务检测
nmap -sV 192.168.1.1

# 深度服务检测
nmap -sV --version-intensity 9 --allports 192.168.1.1

# 轻量级服务检测
nmap -sV --version-light 192.168.1.0/24
```

### 5. 操作系统检测

```bash
# 操作系统检测
nmap -O 192.168.1.1

# 操作系统检测（含猜测）
nmap -O --osscan-guess 192.168.1.1
```

### 6. 脚本扫描示例

```bash
# 使用默认脚本扫描
nmap -sC 192.168.1.1

# 漏洞扫描
nmap --script vuln 192.168.1.1

# Web应用扫描
nmap -p 80,443,8080,8443 --script=http-* 192.168.1.1

# 数据库扫描
nmap -p 1433,1521,3306,5432 --script=db-* 192.168.1.1

# SMB扫描（Windows网络）
nmap -p 139,445 --script=smb-* 192.168.1.1
```

### 7. 性能优化扫描

```bash
# 快速扫描整个网段
nmap -T4 -F --min-rate=1000 192.168.1.0/24

# 并行扫描优化
nmap -T4 --min-hostgroup 64 --max-hostgroup 256 --min-parallelism 64 192.168.1.0/24
```

### 8. 绕过防火墙扫描

```bash
# 使用诱饵
nmap -D RND:10 192.168.1.1

# 分段扫描
nmap -f 192.168.1.1

# 源端口欺骗
nmap --source-port 53 192.168.1.1

# MAC地址欺骗
nmap --spoof-mac 0 192.168.1.1
```

### 9. 输出和报告

```bash
# 保存多种格式的报告
nmap -oA scan_report 192.168.1.1

# 详细扫描并保存XML格式
nmap -v -A -oX scan.xml 192.168.1.1

# 实时显示统计信息
nmap --stats-every 10s 192.168.1.0/24
```

### 10. 实用组合命令

```bash
# 1. 完整安全扫描
nmap -sS -sV -sC -O -p- -T4 -A -v --reason -oA full_scan 192.168.1.1

# 2. 快速网络发现和端口扫描
nmap -sn 192.168.1.0/24 | grep "report for" | awk '{print $5}' | xargs -I {} nmap -F {}

# 3. 批量扫描并生成报告
for ip in 192.168.1.{1..10}; do
    nmap -oN "scan_${ip}.txt" $ip
done

# 4. 监控端口变化
nmap -oX baseline.xml 192.168.1.0/24
# 稍后...
nmap -oX current.xml 192.168.1.0/24
ndiff baseline.xml current.xml

# 5. Web服务器信息收集
nmap -p 80,443,8080,8443 --script=http-title,http-headers,http-methods,http-enum 192.168.1.1
```

### 11. 高级脚本使用

```bash
# SSH相关扫描
nmap -p 22 --script=ssh-auth-methods,ssh-hostkey,ssh2-enum-algos 192.168.1.1

# SSL/TLS扫描
nmap -p 443,8443 --script=ssl-enum-ciphers,ssl-cert,ssl-dh-params 192.168.1.1

# DNS信息收集
nmap -sU -p 53 --script=dns-recursion,dns-cache-snoop,dns-service-discovery 192.168.1.1

# FTP扫描
nmap -p 21 --script=ftp-anon,ftp-bounce,ftp-syst 192.168.1.1
```

### 12. 网络拓扑发现

```bash
# 追踪路由
nmap --traceroute 192.168.1.1

# 发现网络拓扑
nmap -sn --traceroute 192.168.1.0/24

# 识别路由器/防火墙
nmap -p 1-1000 --script=router-os-discovery,firewall-bypass 192.168.1.1
```

## 十、实用脚本和自动化

### 1. 批量扫描脚本

```bash
#!/bin/bash
# 批量扫描脚本
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="scan_results_$TIMESTAMP"
mkdir -p $OUTPUT_DIR

echo "开始扫描网络 192.168.1.0/24"
nmap -sn 192.168.1.0/24 -oN $OUTPUT_DIR/host_discovery.txt

echo "提取在线主机..."
grep "Nmap scan" $OUTPUT_DIR/host_discovery.txt | awk '{print $NF}' | tr -d '()' > $OUTPUT_DIR/live_hosts.txt

echo "开始端口扫描..."
while read host; do
    echo "扫描 $host..."
    nmap -sV -sC -T4 -oN "$OUTPUT_DIR/scan_$host.txt" $host
done < $OUTPUT_DIR/live_hosts.txt

echo "扫描完成！结果保存在 $OUTPUT_DIR 目录"
```

### 2. 监控脚本

```bash
#!/bin/bash
# 网络变化监控脚本
BASELINE="baseline_scan.xml"
CURRENT="current_scan.xml"

# 首次扫描建立基线
if [ ! -f "$BASELINE" ]; then
    echo "创建基线扫描..."
    nmap -oX $BASELINE 192.168.1.0/24
    echo "基线已保存到 $BASELINE"
    exit 0
fi

# 执行当前扫描
echo "执行当前扫描..."
nmap -oX $CURRENT 192.168.1.0/24

# 比较差异
echo "比较变化..."
ndiff $BASELINE $CURRENT > changes.txt

if [ -s changes.txt ]; then
    echo "检测到网络变化！"
    cat changes.txt
    # 可以添加邮件通知等
    # mail -s "网络变化检测" admin@example.com < changes.txt
else
    echo "无网络变化"
fi

# 更新基线
mv $CURRENT $BASELINE
```

## 十一、注意事项和最佳实践

1. **合法性** ：始终确保有扫描权限
2. **影响最小化** ：避免在业务高峰时段扫描
3. **速率控制** ：适当使用-T参数控制扫描速度
4. **结果验证** ：重要发现需要手动验证
5. **文档记录** ：保存扫描结果和参数设置
6. **定期更新** ：保持Nmap和脚本库最新



## 十二、帮助和文档

```bash
# 获取帮助
nmap -h
man nmap
nmap --help

# 查看脚本帮助
nmap --script-help http-title
nmap --script-help vuln

# 查看NSE脚本
ls /usr/share/nmap/scripts/

# 在线文档
# https://nmap.org/book/man.html
```

这些参数和实例涵盖了Nmap的大多数使用场景，可以根据具体需求进行组合和调整。

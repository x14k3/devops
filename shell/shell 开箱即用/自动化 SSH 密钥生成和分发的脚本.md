
```bash
#!/bin/bash
# 自动 SSH 密钥生成与分发脚本
# 支持单服务器和多服务器配置
# 用法： 
#   单服务器：./ssh-auto-setup.sh user@remote-host [port]
#   多服务器：./ssh-auto-setup.sh -f server-list.txt

# 配置参数
KEY_TYPE="ed25519"        # 密钥类型：ed25519(推荐) 或 rsa
KEY_COMMENT="auto-gen"    # 密钥注释
SSH_TIMEOUT=10            # SSH 连接超时（秒）
LOG_FILE="ssh-setup.log"  # 日志文件

# 初始化日志
echo "===== SSH 自动配置脚本启动 $(date) =====" > "$LOG_FILE"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查依赖项
check_dependencies() {
    local missing=()
    for cmd in ssh ssh-keygen ssh-copy-id; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "错误：缺少必要依赖 - ${missing[*]}"
        exit 1
    fi
}

# 生成 SSH 密钥
generate_ssh_key() {
    local key_path="$HOME/.ssh/id_$KEY_TYPE"
    
    if [ -f "${key_path}" ]; then
        log "检测到现有密钥: ${key_path}"
        return 0
    fi
    
    log "生成新的 SSH 密钥 ($KEY_TYPE)..."
    ssh-keygen -t "$KEY_TYPE" -C "$KEY_COMMENT" -N "" -f "${key_path}" <<< y &>> "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log "密钥生成失败!"
        exit 1
    fi
    
    log "密钥已生成: ${key_path}"
    return 0
}

# 分发密钥到单台服务器
copy_to_single() {
    local target="$1"
    local port="${2:-22}"
    local user_host="${target%@*}"
    local host="${target#*@}"
    
    # 验证目标格式
    if [[ ! "$target" =~ @ ]] || [ -z "$host" ]; then
        log "错误：无效的目标格式。请使用 user@host"
        return 1
    fi
    
    log "分发密钥到: ${target} (端口: ${port})"
    
    # 测试 SSH 连接
    if ! ssh -p "$port" -o ConnectTimeout=$SSH_TIMEOUT -o StrictHostKeyChecking=no "$target" exit &>> "$LOG_FILE"; then
        log "错误：无法连接到 ${target}"
        return 1
    fi
    
    # 复制密钥
    if ssh-copy-id -p "$port" -o StrictHostKeyChecking=no -i "$HOME/.ssh/id_$KEY_TYPE.pub" "$target" &>> "$LOG_FILE"; then
        log "成功：密钥已添加到 ${target}"
        return 0
    else
        log "错误：密钥分发到 ${target} 失败"
        return 1
    fi
}

# 从文件读取多台服务器
copy_from_file() {
    local file="$1"
    local total=0 success=0
    
    if [ ! -f "$file" ]; then
        log "错误：服务器列表文件不存在: $file"
        return 1
    fi
    
    # 过滤有效行
    grep -Ev '^\s*(#|$)' "$file" > "${file}.valid"
    
    while IFS= read -r line; do
        ((total++))
        
        # 解析行格式: [user@]host[:port]
        if [[ "$line" =~ : ]]; then
            local host="${line%:*}"
            local port="${line##*:}"
        else
            local host="$line"
            local port="22"
        fi
        
        if [[ ! "$host" =~ @ ]]; then
            host="${USER}@${host}"
        fi
        
        if copy_to_single "$host" "$port"; then
            ((success++))
        fi
        
    done < "${file}.valid"
    rm "${file}.valid"
    
    log "批量分发完成! 成功: ${success}/${total}"
    return $((success == total ? 0 : 1))
}

# 主函数
main() {
    check_dependencies
    generate_ssh_key
    
    case "$1" in
        -f|--file)
            if [ -z "$2" ]; then
                log "错误：请指定服务器列表文件"
                exit 1
            fi
            copy_from_file "$2"
            ;;
        "")
            log "错误：缺少参数\n用法：\n  单服务器: $0 user@host [port]\n  多服务器: $0 -f server-list.txt"
            exit 1
            ;;
        *)
            copy_to_single "$1" "$2"
            ;;
    esac
    
    # 安全设置
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
    
    log "脚本执行完成!"
    exit $?
}

# 执行主函数
main "$@"
```


### 使用说明

#### 1. 单服务器配置
```
./ssh-auto-setup.sh username@remote-server
# 指定端口：
./ssh-auto-setup.sh username@remote-server 2222
```

#### 2. 多服务器配置

创建服务器列表文件`servers.txt`：

```
# 格式: [user@]host[:port]
admin@server1.example.com
dev@server2.example.com:2222
192.168.1.100           # 使用当前用户和默认端口
backup@db-server:2222
```

执行批量分发：

```
./ssh-auto-setup.sh -f servers.txt
```



Lsyncd (Live Syncing Daemon) 是一个基于 `inotify`​ 和 `rsync`​ 的轻量级实时文件同步工具，用于将本地目录实时同步到远程服务器。以下是一个基本的配置指南：

### **1. 安装 Lsyncd**

在 Ubuntu/Debian 系统上：

```
sudo apt update
sudo apt install lsyncd
```

在 CentOS/RHEL 系统上：

```
sudo yum install epel-release
sudo yum install lsyncd
```

---

### **2. 配置文件结构**

Lsyncd 的主配置文件通常位于 `/etc/lsyncd.conf`​ 或 `/etc/lsyncd/lsyncd.conf.lua`​（具体路径取决于系统）。配置使用 Lua 语法。

#### **基本配置示例：**

```
settings {
    logfile = "/var/log/lsyncd.log",  -- 日志文件路径
    statusFile = "/var/log/lsyncd-status.log",  -- 状态文件路径
    statusInterval = 10,  -- 状态更新间隔（秒）
    maxProcesses = 4,     -- 最大并行进程数
}

sync {
    default.rsync,
    source = "/path/to/local/source",  -- 本地源目录
    target = "user@remote_host:/path/to/remote/target",  -- 远程目标目录
    exclude = { "*.tmp", ".git/" },  -- 排除文件/目录
    delay = 1,  -- 事件触发后的延迟时间（秒）
    rsync = {
        archive = true,        -- 归档模式（保留权限、属性等）
        compress = true,       -- 压缩传输
        verbose = true,        -- 显示详细信息
        password_file = "/path/to/password_file",  -- 如果需要密码
        rsh = "ssh -p 22 -i /path/to/private_key"  -- SSH 参数
    }
}
```

---

### **3. 关键配置参数说明**

- ​**​`source`​**​: 本地需要同步的目录。
- ​**​`target`​**​: 远程目标目录，格式为 `user@host:/path`​。
- ​**​`exclude`​**​: 排除的文件或目录（支持通配符）。
- ​**​`delay`​**​: 事件触发后等待的秒数（避免频繁同步）。
- ​**​`rsync`​**​: 传递给 rsync 的参数：

  - ​`archive`​: 保留文件属性。
  - ​`delete`​: 同步时删除目标多余文件（谨慎使用！）。
  - ​`compress`​: 压缩传输数据。
  - ​`rsh`​: 指定 SSH 连接参数（如端口、密钥）。

---

### **4. SSH 免密登录配置**

若使用 SSH 同步，需配置密钥认证：

```
# 本地生成密钥（如果尚未生成）
ssh-keygen -t rsa

# 将公钥复制到远程服务器
ssh-copy-id -i ~/.ssh/id_rsa.pub user@remote_host
```

---

### **5. 启动与管理 Lsyncd**

```
# 启动服务
sudo systemctl start lsyncd

# 开机自启
sudo systemctl enable lsyncd

# 查看状态
sudo systemctl status lsyncd

# 重启服务
sudo systemctl restart lsyncd
```

---

### **6. 高级配置示例（多目录同步）**

```
settings {
    logfile = "/var/log/lsyncd.log",
    statusInterval = 10,
}

-- 同步目录1
sync {
    default.rsync,
    source = "/var/www/site1",
    target = "user@host1:/var/www/site1_backup",
    rsync = {
        archive = true,
        compress = true,
        rsh = "ssh -i /path/to/key"
    }
}

-- 同步目录2
sync {
    default.rsync,
    source = "/home/user/data",
    target = "user@host2:/backup/data",
    exclude = { "*.log", "tmp/" },
    delay = 5,
    rsync = {
        archive = true,
        delete = true  -- 删除目标端多余文件
    }
}
```

---

### **7. 常见问题排查**

1. **权限问题**：确保本地和远程目录有读写权限。
2. **SSH 连接失败**：检查密钥认证和防火墙设置。
3. **日志分析**：查看 `/var/log/lsyncd.log`​ 定位错误。
4. **inotify 限制**：若同步大量文件，可能需要调整内核参数：  

    ```
    echo "fs.inotify.max_user_watches=65536" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    ```

---

通过以上配置，你可以实现本地到远程的实时文件同步。根据实际需求调整参数，并确保测试后再应用到生产环境。

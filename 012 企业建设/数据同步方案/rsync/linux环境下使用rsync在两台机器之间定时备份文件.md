# linux环境下使用rsync在两台机器之间定时备份文件

‍

在Linux环境下使用`rsync`​结合`cron`​实现两台机器之间的定时备份，具体步骤如下：

---

### **1. 配置SSH免密登录（关键步骤）**

避免每次传输需手动输入密码，需配置SSH密钥对。

#### 1.1 生成密钥对（在源机器执行）

```
ssh-keygen -t rsa -b 4096  # 默认保存路径为 ~/.ssh/id_rsa，回车跳过密码（重要：定时任务需无密码）
```

#### 1.2 将公钥复制到目标机器

```
ssh-copy-id -i ~/.ssh/id_rsa.pub 用户名@目标机器IP
# 输入目标机器密码后，后续SSH连接将不再需要密码
```

---

### **2. 测试rsync命令**

#### 2.1 基础同步命令（本地 → 远程）

```
rsync -avz --delete -e ssh /本地/目录/ 用户名@远程IP:/远程/目录/
```

参数

```
-a			归档模式（保留权限、时间等）
-v			显示详细过程
-z			压缩传输
--delete	删除远程多余文件（谨慎使用）
-e ssh		指定使用SSH协议
```

‍

#### 2.2 反向同步（远程 → 本地）

```
rsync -avz --delete -e ssh 用户名@远程IP:/远程/目录/ /本地/目录/
```

#### 2.3 排除特定文件/目录

```
rsync -avz --exclude 'temp/' --exclude '*.log' -e ssh /本地/目录/ 用户名@远程IP:/远程/目录/
```

---

### **3. 创建备份脚本**

将命令写入脚本，方便管理和添加日志。

#### 示例脚本 `/opt/scripts/backup.sh`​

```
#!/bin/bash
# 备份日志记录
LOG_FILE="/var/log/rsync_backup.log"
echo "===== 备份开始：$(date) =====" >> $LOG_FILE

# 执行rsync命令
/usr/bin/rsync -avz --delete -e ssh /本地/目录/ 用户名@远程IP:/远程/目录/ >> $LOG_FILE 2>&1

# 检查是否成功
if [ $? -eq 0 ]; then
    echo "备份成功：$(date)" >> $LOG_FILE
else
    echo "备份失败：$(date)" >> $LOG_FILE
    # 发送错误通知（需配置邮件服务）
    # echo "rsync备份失败" | mail -s "备份警报" admin@example.com
fi
```

#### 赋予脚本执行权限

```
chmod +x /opt/scripts/backup.sh
```

---

### **4. 设置cron定时任务**

使用`crontab`​配置定时任务。

#### 4.1 编辑当前用户的cron表

```
crontab -e
```

#### 4.2 添加定时任务示例

```
# 每天凌晨2点执行备份
0 2 * * * /opt/scripts/backup.sh

# 每30分钟同步一次
*/30 * * * * /opt/scripts/backup.sh
```

---

### **5. 日志与错误处理**

* **查看日志**：`tail -f /var/log/rsync_backup.log`​
* **检查cron执行记录**：`grep CRON /var/log/syslog`​（Ubuntu/Debian）或 `journalctl -u cron`​（Systemd系统）

---

### **常见问题排查**

1. **权限不足**：确保目标目录可写，且SSH密钥权限正确：  

    ```
    chmod 600 ~/.ssh/id_rsa
    chmod 700 ~/.ssh
    ```
2. **路径错误**：在脚本中使用绝对路径。
3. **防火墙/端口**：确保目标机器的SSH端口（默认22）开放。
4. **环境变量问题**：在脚本中设置`PATH`​变量，或在cron中指定完整路径。

‍

### **注意事项**

* 源路径结尾的 `/`​ 会影响行为：

  * ​`/source/`​ 同步目录内容到目标。
  * ​`/source`​ 同步目录本身到目标。
* 使用 `--delete`​ 前建议先 `--dry-run`​ 确认操作。
* 远程同步需确保 SSH 免密登录或密码正确。

通过灵活组合参数，`rsync`​ 可以适应多种文件同步场景，是备份和部署的利器！

---

### **高级选项**

* **增量备份**：使用`--link-dest`​参数创建硬链接备份（需结合时间戳目录）。
* **带宽限制**：添加`--bwlimit=1000`​（单位KB/s）限制传输速度。
* **日志轮转**：使用`logrotate`​管理日志文件大小。

通过以上步骤，您已实现了一个安全、自动化的跨机器文件备份方案。

‍

### **常用参数分类**

#### **1. 基础操作**

* ​`-v, --verbose`​  
  显示详细输出，可叠加使用（如 `-vv`​ 更详细）。
* ​`-q, --quiet`​  
  静默模式，抑制非错误信息。
* ​`-P`​  
  等价于 `--partial --progress`​：

  * ​`--partial`​：保留部分传输的文件（便于断点续传）。
  * ​`--progress`​：显示传输进度。
* ​`-n, --dry-run`​  
  模拟运行，显示哪些文件会被同步但不实际执行。
* ​`--delete`​  
  删除目标端源端不存在的文件（保持严格同步）。
* ​`--ignore-existing`​  
  跳过目标端已存在的文件（不覆盖）。

---

#### **2. 文件属性与权限**

* ​`-a, --archive`​  
  归档模式，保留文件属性（权限、时间戳等），等价于 `-rlptgoD`​：

  * ​`-r`​：递归目录。
  * ​`-l`​：保留符号链接。
  * ​`-p`​：保留权限。
  * ​`-t`​：保留修改时间。
  * ​`-g`​：保留属组。
  * ​`-o`​：保留属主。
  * ​`-D`​：保留设备文件和特殊文件。
* ​`-z, --compress`​  
  传输时压缩数据（节省带宽，但消耗CPU）。
* ​`--chmod=CHMOD`​  
  修改目标文件权限（如 `--chmod=755`​）。
* ​`--exclude=PATTERN`​  
  排除匹配的文件/目录（支持通配符 `*`​）。

  * 示例：`--exclude="*.tmp"`​ 排除所有 `.tmp`​ 文件。
* ​`--exclude-from=FILE`​  
  从指定文件读取排除规则（每行一个模式）。

---

#### **3. 目录控制**

* ​`-R, --relative`​  
  使用相对路径（保持源目录结构）。  
  示例：同步 `/foo/bar`​ 到 `/backup/`​ 会生成 `/backup/foo/bar`​。
* ​`-b, --backup`​  
  对目标端已存在的文件创建备份（默认后缀 `~`​）。

  * ​`--backup-dir=DIR`​：指定备份文件存放目录。
* ​`--remove-source-files`​  
  同步后删除源端文件（非目录）。

---

#### **4. 远程同步**

* ​`-e, --rsh=COMMAND`​  
  指定远程 Shell（如 SSH）：  
  bash

  ```
  rsync -avz -e "ssh -p 2222" /local/path user@remote:/remote/path
  ```
* ​`--rsync-path=PROGRAM`​  
  指定远程端的 `rsync`​ 路径（用于非默认安装位置）。

---

#### **5. 性能优化**

* ​`--bwlimit=KBPS`​  
  限制带宽使用（单位：KB/s）。  
  示例：`--bwlimit=1000`​ 限制为 1MB/s。
* ​`--max-size=SIZE`​  
  限制同步文件的最大大小（如 `--max-size=10M`​）。
* ​`--min-size=SIZE`​  
  限制同步文件的最小大小。
* ​`-W, --whole-file`​  
  禁用增量传输（适用于本地同步或高速网络）。

---

#### **6. 高级选项**

* ​`--link-dest=DIR`​  
  硬链接未更改的文件到指定目录（用于增量备份）。
* ​`--checksum`​  
  基于文件校验和（而非时间和大小）决定是否同步。
* ​`--timeout=SECONDS`​  
  设置 I/O 超时时间（默认无限制）。

---

### **常用示例**

1. **本地同步**（保留所有属性）：  

    ```
    rsync -av /source/ /destination/
    ```
2. **同步到远程服务器**（通过 SSH）：  

    ```
    rsync -avz -e ssh /local/path user@remote:/remote/path
    ```
3. **从远程同步到本地**：  

    ```
    rsync -avz user@remote:/remote/path /local/path
    ```
4. **删除目标端多余文件**（严格同步）：  

    ```
    rsync -av --delete /source/ /destination/
    ```
5. **限速同步**（避免占用带宽）：  

    ```
    rsync -avz --bwlimit=1000 /source/ user@remote:/destination/
    ```
6. **增量备份**（结合硬链接）：  

    ```
    rsync -a --link-dest=/previous/backup /source/ /new/backup/
    ```

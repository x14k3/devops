

### **一、**​**​`sudo`​**​ **命令基础**

#### 1. 基本用法

```
sudo [选项] 命令
```

‍

#### 2. 常用选项

|选项|说明|
| ------| --------------------------------------------|
|​`-u <用户>`​|以指定用户身份执行命令（默认为 `root`​）|
|​`-l`​|列出当前用户的 `sudo`​ 权限|
|​`-i`​|切换到 `root`​ 用户的 shell 环境（类似 `su -`​）|
|​`-s`​|启动 `root`​ 的 shell，但保留当前环境变量|
|​`-k`​|清除缓存的密码验证（强制下次重新输入密码）|

---

### **二、配置文件**  **​`/etc/sudoers`​**​

​`sudo`​ 的权限规则由 `/etc/sudoers`​ 文件控制。**不要直接编辑此文件**，应使用 `visudo`​ 命令（自动检查语法错误）：

```
sudo visudo
```

---

### **三、配置文件语法详解**

#### 1. 用户/用户组定义

- **用户**：`username`​
- **用户组**：`%groupname`​
- **别名**：使用 `User_Alias`​、`Runas_Alias`​ 等定义别名组。

#### 2. 主机/主机组定义

- **主机**：`hostname`​
- **主机组**：`Host_Alias`​

#### 3. 命令/命令路径

- **命令路径**：必须使用绝对路径（如 `/usr/bin/apt`​）。
- **命令别名**：使用 `Cmnd_Alias`​ 定义一组命令。

#### 4. 权限规则格式

```
用户/用户组 主机=(目标用户) [NOPASSWD:] 命令/命令别名
```

- **字段说明**：

  - **用户/用户组**：谁可以使用 `sudo`​。
  - **主机**：在哪些主机上生效。
  - **目标用户**：以哪个用户的身份执行命令（默认为 `root`​）。
  - **NOPASSWD**：执行时无需输入密码。
  - **命令**：允许执行的命令（支持通配符 `*`​，但需谨慎使用）。

---

### **四、配置示例**

#### 1. 允许用户 `john`​ 执行所有命令

```
john ALL=(ALL) ALL
```

#### 2. 允许用户组 `admins`​ 无需密码执行 `/usr/bin/apt`​

```
%admins ALL=(ALL) NOPASSWD: /usr/bin/apt
```

#### 3. 定义别名并限制权限

```
# 定义用户别名
User_Alias WEBADMINS = alice, bob

# 定义命令别名
Cmnd_Alias WEB_COMMANDS = /usr/sbin/nginx, /usr/bin/systemctl restart nginx

# 规则：WEBADMINS 组可以管理 Nginx
WEBADMINS ALL=(root) WEB_COMMANDS
```

---

### **五、高级配置**

#### 1. 禁止特定命令

在命令前加 `!`​ 表示禁止：

```
user1 ALL=(ALL) ALL, !/usr/bin/passwd root  # 允许所有命令，但禁止修改 root 密码
```

#### 2. 环境变量保留

通过 `env_keep`​ 保留用户的环境变量：

```
Defaults env_keep += "HTTP_PROXY HTTPS_PROXY"
```

#### 3. 日志记录

启用 `sudo`​ 日志审计（需配合 `syslog`​）：

```
Defaults logfile="/var/log/sudo.log"
```

---

### **六、常见问题**

#### 1. 用户无权限时提示

```
user1 is not in the sudoers file. This incident will be reported.
```

#### 2. 恢复损坏的 `sudoers`​ 文件

若配置错误导致 `sudo`​ 无法使用：

1. 重启系统，进入单用户模式（或 Recovery Mode）。
2. 挂载文件系统为可写：  

    ```
    mount -o remount,rw /
    ```
3. 修复文件：  

    ```
    visudo
    ```

---

### **七、安全建议**

1. **最小权限原则**：仅授予必要权限。
2. **避免通配符滥用**：如 `ALL`​ 或 `*`​ 可能导致权限过高。
3. **定期审计**：检查 `/var/log/auth.log`​ 或 `sudo`​ 日志。

通过合理配置 `sudo`​，可以显著提升系统的安全性和管理灵活性。

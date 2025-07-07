

## 签发证书

```bash
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.7/EasyRSA-3.1.7.tgz
tar -zxvf EasyRSA-3.1.7.tgz 
cd EasyRSA-3.1.7/
echo '
#公司信息，根据情况自定义
set_var EASYRSA_REQ_COUNTRY     "CN"
set_var EASYRSA_REQ_PROVINCE    "Bei Jing"
set_var EASYRSA_REQ_CITY        "Bei Jing"
set_var EASYRSA_REQ_ORG         "Copyleft Certificate Co"
set_var EASYRSA_REQ_EMAIL       "me@example.net"
set_var EASYRSA_REQ_OU          "My Organizational Unit"
#证书有效期
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     3650 ' >> vars


## 创建证书
./easyrsa init-pki   			     	   #1、初始化，在当前目录创建PKI目录，用于存储整数
./easyrsa build-ca  			      	   #2、创建根证书，会提示设置密码，用于ca对之后生成的server和client证书签名时使用，其他提示内容直接回车即可
./easyrsa gen-req server-key nopass   	   #3、创建server端证书和私钥文件，nopass表示不加密私钥文件，提示内容直接回车即可
./easyrsa sign server server-key     	   #4、给server端证书签名，提示内容需要输入yes和创建ca根证书时候的密码
./easyrsa gen-dh   				      	   #5、创建Diffie-Hellman文件，密钥交换时的Diffie-Hellman算法
./easyrsa gen-req client-desktop nopass    #6、创建client端的证书和私钥文件，nopass表示不加密私钥文件，提示内容直接回车即可
./easyrsa sign client client-desktop       #7、给client端证书前面，提示内容输入yes和创建ca根证书时候的密码
openvpn --genkey --secret ta.key      	   #8、生成 ta.key 文件 这一步是可选操作，生成的ta.key主要用于防御DoS、UDP淹没等恶意攻击。
```


## 吊销证书

```bash
cd /path/to/easyrsa             # 替换为你的 EasyRSA 安装路径
./easyrsa revoke "CLIENT_NAME"  # 将 CLIENT_NAME 替换为客户端证书名称（如 client1）

#系统会要求输入 CA 密码（创建 CA 时设置的密码）。
#吊销成功后，会提示 `Revocation was successful`。

./easyrsa gen-crl               # 生成的 CRL 文件默认在 `pki/crl.pem`。

### 配置 OpenVPN 服务器使用 CRL，修改配置文件，添加以下参数
crl-verify crl.pem

### 重启 OpenVPN 服务
systemctl restart openvpn-server@server  # 根据实际服务名调整（如 openvpn@server）
 
### 验证吊销结果
cat pki/index.txt
#被吊销的证书状态会标记为 `R`（如 `R 250408124310Z 230327124310Z 1001 unknown /CN=client1`）。
```


## 证书过期

当OpenVPN客户端证书过期时，若不更换源证书（CA证书），可通过**重新签发客户端证书**解决。以下是具体步骤：

解决方案步骤：

1. **登录OpenVPN服务器**  
    访问存放CA证书和EasyRSA工具的服务器（通常位于`/etc/openvpn/server/`​或`/etc/openvpn/easy-rsa/`​）。
2. **进入EasyRSA目录**

    ```
    cd /etc/openvpn/easy-rsa/  # 路径可能因安装方式而异
    ```
3. **初始化环境（若需）**

    ```
    source ./vars  # 加载环境变量
    ./easyrsa init-pki  # 初始化PKI（若已存在可跳过）
    ```
4. **签发新客户端证书**

    ```
    ./easyrsa build-client-full <新客户端名称> nopass
    ```

    - ​ **​`<新客户端名称>`​** ​：自定义名称（如 `client2`​），与原客户端区分。
    - ​**​`nopass`​**​：生成无密码的证书（若需密码保护则移除此参数）。
5. **获取新客户端文件**  
    生成的证书文件位于：

    - **证书**：`pki/issued/<新客户端名称>.crt`​
    - **私钥**：`pki/private/<新客户端名称>.key`​
6. **分发文件到客户端**  
    将新证书和私钥文件安全传输到客户端设备，替换原文件（通常与`.ovpn`​配置文件同目录）。
7. **更新客户端配置**  
    修改客户端的`.ovpn`​配置文件，指向新证书和私钥：  
    conf

    ```
    cert /path/to/<新客户端名称>.crt
    key /path/to/<新客户端名称>.key
    ```
8. **重启OpenVPN客户端**  
    重新连接VPN即可生效。

‍

---

在不更换客户端证书的情况下解决OpenVPN证书过期问题，需通过**服务器端调整**或**客户端临时措施**实现。以下是具体方案：

‍

方案一：服务器端忽略证书有效期（需控制权限）

**适用场景**：您能修改OpenVPN服务器配置  
**原理**：在服务器配置中跳过证书过期验证  
**步骤**：

1. **修改服务器配置文件**（如 `server.conf`​）

    ```
    # 添加以下两行
    disable-occ  # 关闭选项协商（部分版本需要）
    verify-client-cert none  # 跳过客户端证书验证（仅限OpenVPN 2.4+）
    ```
2. **启用自定义验证脚本**（兼容旧版）

    ```
    # 创建验证脚本
    echo '#!/bin/sh
    [ "$1" -eq 1 ] && exit 0  # 深度1（客户端证书）直接通过
    exit 1' > /etc/openvpn/allow-expired.sh
    chmod +x /etc/openvpn/allow-expired.sh
    ```

    在配置中添加：

    ```
    script-security 2
    tls-verify "/etc/openvpn/allow-expired.sh"
    ```
3. **重启OpenVPN服务**

    ```
    systemctl restart openvpn-server@server
    ```

---

‍

方案二：客户端时间回溯（临时应急）

**适用场景**：快速临时连接  
**原理**：修改客户端系统时间至证书有效期内  
**步骤**：

1. **关闭时间同步服务**

    ```
    sudo timedatectl set-ntp off  # Linux
    ```

    Windows：`Win+R`​ → `services.msc`​ → 停止 "Windows Time" 服务
2. **修改系统时间**

    ```
    sudo date -s "2023-01-01 12:00:00"  # 设为证书有效期内时间
    ```

    Windows：控制面板 → 日期和时间 → 手动设置日期
3. **连接VPN后恢复时间**

    ```
    sudo timedatectl set-ntp on  # 连接成功后恢复同步
    ```

---

‍

方案三：证书有效期延展（无需重签）

**适用场景**：可访问CA但不想重新签发  
**原理**：直接延长原证书有效期  
**步骤**：

1. **备份原证书**

    ```
    cp client.crt client.crt.bak
    cp client.key client.key.bak
    ```
2. **延长证书有效期**

    ```
    openssl x509 -in client.crt -signkey client.key \
    -days 3650 -out new_client.crt  # 延长10年
    ```
3. **更新客户端配置**

    ```
    cert /path/to/new_client.crt
    key /path/to/client.key  # 使用原私钥
    ```

---

‍

‍

风险说明

|方案|安全性风险|推荐场景|
| --------------| ---------------------------------------| --------------|
|服务器端忽略|⚠️ 极大降低安全性（中间人攻击风险）|封闭测试环境|
|时间回溯|⚠️ 影响其他时间敏感服务|紧急单次连接|
|证书延展|🔐 相对安全（保持密钥不变）|长期解决方案|

oracle使用iscsi 在redhat环境下搭建共享存储步骤
### **一、Target 服务器配置（提供存储）**

**安装必要软件包**
```bash
sudo yum install -y targetcli iscsi-initiator-utils
```

**启动服务并设置开机自启**
```bash
sudo systemctl start target
sudo systemctl enable target
```

**配置防火墙（开放iSCSI端口）**
  ```bash
sudo firewall-cmd --permanent --add-port=3260/tcp
sudo firewall-cmd --reload
```

**创建后端存储**

- **选项1：使用本地文件（示例创建1GB文件）**
```bash
sudo dd if=/dev/zero of=/var/lib/iscsi_disks/disk1.img bs=1M count=1024
```

- **选项2：使用LVM卷（推荐生产环境）**
```bash
sudo pvcreate /dev/sdb           # 初始化物理卷
sudo vgcreate vg_iscsi /dev/sdb  # 创建卷组
sudo lvcreate -L 100G -n lv_shared vg_iscsi  # 创建逻辑卷
```

**配置iSCSI Target**
```bash
sudo targetcli
console

# 创建后端存储
/> backstores/block create ocr1 /dev/sdb
/> backstores/block create ocr2 /dev/sdc
/> backstores/block create ocr3 /dev/sdd
/> backstores/block create data /dev/sdf

# 创建Target IQN（唯一标识）
/> iscsi/ create iqn.2025-06.com.oracle:rac.storage

# 绑定存储到LUN
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr1
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr2
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr3
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/luns create /backstores/block/data

# 允许两个节点访问
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/acls create iqn.2025-06.com.oracle:node1
/> iscsi/iqn.2025-06.com.oracle:rac.storage/tpg1/acls create iqn.2025-06.com.oracle:node2

# 设置监听IP (建议绑定到专用存储网络)
/> portals/ create 192.168.100.10

# 保存配置并退出
/> saveconfig
/> exit
```

启用多路径访问
```bash
targetcli
set global auto_add_mapped_luns=true
set global auto_add_default_portal=false
saveconfig
exit
```

---

### **二、Initiator 客户端配置（连接存储）**

#### 节点 1 配置 (192.168.100.101)

**设置 Initiator 名称**
```bash
echo "InitiatorName=iqn.2025-06.com.oracle:node1" > /etc/iscsi/initiatorname.iscsi
```


**配置多路径 (安装并配置 device-mapper-multipath)**
```bash
yum install -y device-mapper-multipath 
mpathconf --enable --with_multipathd y

cat > /etc/multipath.conf <<EOF
defaults {
    user_friendly_names yes
    path_grouping_policy multibus
    failback immediate
    no_path_retry fail
}
blacklist {
    devnode "^sd[a-z]$"
}
EOF

systemctl start multipathd
```

**连接存储**
```bash
iscsiadm -m discovery -t st -p 192.168.10.135
iscsiadm -m node -T iqn.2025-06.com.oracle:rac.storage -p 192.168.10.135 -l
```

**配置 UDEV 规则**
```bash
cat > /etc/udev/rules.d/99-oracle-asm.rules <<EOF
KERNEL=="dm-*", ENV{DM_UUID}=="mpath-*", OWNER="grid", GROUP="asmadmin", MODE="0660"
EOF

udevadm control --reload-rules
partprobe
```



#### 节点 2 配置 (192.168.100.102)

**设置唯一 Initiator 名称**
```bash
echo "InitiatorName=iqn.2023-08.com.oracle:node2" > /etc/iscsi/initiatorname.iscsi
```


**重复节点1的配置步骤（多路径、连接存储、UDEV规则）**

---

### **三、双节点共享磁盘验证**

**在两个节点上检查磁盘**
```bash
multipath -ll
ls -l /dev/mapper/
```

**确认两个节点看到相同的磁盘标识**
```bash
# 在所有节点上执行：
for disk in $(multipath -l -v1); do 
  echo -n "$disk: "
  scsi_id -g -u /dev/mapper/$disk 
done
```

**输出应显示相同的WWID**

---

### **四、Oracle RAC 特定配置**

**安装 ASMLib 或使用 ASMFD**
```bash
# 安装 ASMLib
yum install -y kmod-oracleasm oracleasm-support

# 配置 ASMLib
oracleasm configure -i
oracleasm init

# 创建 ASM 磁盘
oracleasm createdisk OCR1 /dev/mapper/mpatha
oracleasm createdisk OCR2 /dev/mapper/mpathb
oracleasm createdisk OCR3 /dev/mapper/mpathc
oracleasm createdisk DATA /dev/mapper/mpathd
```


**在另一个节点扫描磁盘**
```bash
oracleasm scandisks
oracleasm listdisks
```



---

### **五、配置 Oracle Grid Infrastructure**

1.***在安装过程中选择 ASM 存储**

- OCR 位置: 选择三个 OCR 磁盘
- DATA 位置: 选择数据磁盘

2.**验证集群配置**
```bash
crsctl check cluster -all
```




---


### 六、常用的 `iscsiadm` 命令
```bash
#发现iSCSI 目标
iscsiadm -m discovery -t st -p <IP地址>
#查看已发现的iSCSI 目标
iscsiadm -m node
#登录iSCSI 目标
iscsiadm -m node -T <目标名称> -p <IP地址> -l
#注销iSCSI 目标
iscsiadm -m node -T <目标名称> -p <IP地址> -u
#删除发现记录
iscsiadm -m node -o delete -T <目标名称> -p <IP地址>
```

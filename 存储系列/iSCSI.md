oracle使用iscsi 在redhat环境下搭建共享存储步骤
### **一、Target 服务器配置（提供存储）**

**安装必要软件包**
```bash
yum install -y targetcli iscsi-initiator-utils
```

**启动服务并设置开机自启**
```bash
systemctl start target
systemctl enable target
```


**创建后端存储**

- **选项1：使用本地文件（示例创建1GB文件）**
```bash
dd if=/dev/zero of=/var/lib/iscsi_disks/disk1.img bs=1M count=1024
```

- **选项2：使用LVM卷（推荐生产环境）**
```bash
pvcreate /dev/sdb           # 初始化物理卷
vgcreate vg_iscsi /dev/sdb  # 创建卷组
lvcreate -L 100G -n lv_shared vg_iscsi  # 创建逻辑卷
```

**配置iSCSI Target**
```bash
targetcli

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

# 当新的Initiator（客户端）添加到 SCST 时，自动为其分配所有已映射的 LUN（逻辑单元）,启用此参数可大幅简化配置，减少重复操作。
/> set global auto_add_mapped_luns=true
/> set global auto_add_default_portal=false

# 保存配置并退出
/> saveconfig
/> exit
```


---

### **二、Initiator 客户端配置（连接存储）**

#### 节点 1 配置 (192.168.100.101)

**设置 Initiator 名称**
```bash
yum install -y iscsi-initiator-utils device-mapper-multipath

echo "InitiatorName=iqn.2025-06.com.oracle:node1" > /etc/iscsi/initiatorname.iscsi
```


**配置多路径 (安装并配置 device-mapper-multipath)**
```bash
mpathconf --enable --with_multipathd y

echo '
defaults {
    user_friendly_names yes
    path_grouping_policy multibus
    failback immediate
    no_path_retry fail
}
blacklist {
    devnode "^sd[a-z]$"
} '> /etc/multipath.conf

systemctl start multipathd
```

**连接存储**
```bash
iscsiadm -m discovery -t st -p 192.168.10.135
iscsiadm -m node -T iqn.2025-06.com.oracle:rac.storage -p 192.168.10.135 -l
```

**配置持久化设备命名 (每台主机)**

- **目的：** 确保即使磁盘设备名 (`/dev/sdX`) 在重启后发生变化，操作系统也能通过唯一标识符（如 WWID）找到同一个物理磁盘。多路径友好名 (`/dev/mapper/mpathX`) 通常是持久的，但为了给 ASM 使用，最好再创建一层基于 WWID 的 udev 规则或使用 ASMLib。
    
- **推荐方法 1: 使用 `udev` 规则**

编辑/etc/scsi_id.config文件，2个节点都要编辑

```bash
echo "options=--whitelisted --replace-whitespace"  >> /etc/scsi_id.config
```

将磁盘wwid信息写入99-oracle-asmdevices.rules文件，2个节点都要编辑

```bash
# 根据lsblk修改盘符
[root@rac-02 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk 
sdb      8:16   0   10G  0 disk 
sdc      8:32   0   10G  0 disk 
sdd      8:48   0   20G  0 disk 
sde      8:64   0   20G  0 disk 
sdf      8:80   0   20G  0 disk 
sr0     11:0    1 1024M  0 rom  
vda    253:0    0   50G  0 disk 
├─vda1 253:1    0    1G  0 part /boot
├─vda2 253:2    0    5G  0 part [SWAP]
└─vda3 253:3    0   44G  0 part /
[root@rac-02 ~]# 

### 以下脚本适用于Centos7.0 根据/sdX 修改for循环中的a b c d ...

### !!!!!!!!!!!!! 一定要先创建用户 !!!!!!!!!!! ##################
### !!!!!!!!!!!!! 一定要先创建用户 !!!!!!!!!!! ##################
### !!!!!!!!!!!!! 一定要先创建用户 !!!!!!!!!!! ##################
for i in  b c d e ;
do 
echo "KERNEL==\"sd*\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$name\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sd${i}`\",SYMLINK+=\"asm-sd$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracle-asmdevices.rules
done
```

查看99-oracle-asmdevices.rules文件，2个节点都要查看

```bash
cat /etc/udev/rules.d/99-oracle-asmdevices.rules 
```

启动设备，2个节点都要执行

```bash
udevadm control --reload  
udevadm trigger
```


#### 节点 2 配置 (192.168.100.102)

**设置唯一 Initiator 名称**
```bash
echo "InitiatorName=iqn.2025-06.com.oracle:node2" > /etc/iscsi/initiatorname.iscsi
```


**重复节点1的配置步骤（多路径、连接存储）**

---


### 三、常用的 `iscsiadm` 命令
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


完全重置 iSCSI 配置：
```bash
[root@localhost ~]# systemctl stop iscsid

Warning: Stopping iscsid.service, but it can still be activated by:

  iscsid.socket

[root@localhost ~]# 

[root@localhost ~]# # 清除所有配置

[root@localhost ~]# rm -rf /var/lib/iscsi/nodes/*

[root@localhost ~]# rm -rf /var/lib/iscsi/send_targets/*

[root@localhost ~]# 

[root@localhost ~]# vim /etc/iscsi/initiatorname.iscsi 

[root@localhost ~]# echo "InitiatorName=iqn.$(date +%Y-%m).com.example:$(hostname)" > /etc/iscsi/initiatorname.iscsi

[root@localhost ~]# vim /etc/iscsi/initiatorname.iscsi 

[root@localhost ~]# iscsiadm -m discovery -t st -p 192.168.10.135

192.168.10.135:3260,1 iqn.2025-06.com.oracle:rac.cluster01

[root@localhost ~]# iscsiadm -m node -T iqn.2025-06.com.oracle:rac.cluster01 -p 192.168.10.135 -l

Logging in to [iface: default, target: iqn.2025-06.com.oracle:rac.cluster01, portal: 192.168.10.135,3260] (multiple)

Login to [iface: default, target: iqn.2025-06.com.oracle:rac.cluster01, portal: 192.168.10.135,3260] successful.

[root@localhost ~]#
```
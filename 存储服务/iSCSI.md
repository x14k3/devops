oracle使用iscsi 在redhat环境下搭建共享存储步骤
## Target 服务器配置

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
pvcreate /dev/vdb                       # 初始化物理卷
vgcreate vg_iscsi /dev/vdb              # 创建卷组
lvcreate -L 100G -n lv_shared vg_iscsi  # 创建逻辑卷
```

**配置iSCSI Target**
```bash
[root@rac-data ~]# 
[root@rac-data ~]# 
[root@rac-data ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0     11:0    1 1024M  0 rom  
vda    253:0    0   60G  0 disk 
├─vda1 253:1    0    1G  0 part /boot
├─vda2 253:2    0  3.9G  0 part [SWAP]
├─vda3 253:3    0   37G  0 part /
├─vda4 253:4    0    1K  0 part 
└─vda5 253:5    0 18.1G  0 part /home
vdb    253:16   0   50G  0 disk 
vdc    253:32   0   20G  0 disk 
vdd    253:48   0   10G  0 disk 
vde    253:64   0   10G  0 disk 
vdf    253:80   0   10G  0 disk 
[root@rac-data ~]# 

[root@rac-data ~]# 
[root@rac-data ~]# targetcli
targetcli shell version 2.1.53
Copyright 2011-2013 by Datera, Inc and others.
For help on commands, type 'help'.
  
# 创建后端存储
/> backstores/block create data /dev/vdb
Created block storage object data using /dev/vdb.
/> backstores/block create arch /dev/vdc
Created block storage object arch using /dev/vdc.
/> backstores/block create ocr1 /dev/vdd
Created block storage object ocr1 using /dev/vdd.
/> backstores/block create ocr2 /dev/vde
Created block storage object ocr2 using /dev/vde.
/> backstores/block create ocr3 /dev/vdf
Created block storage object ocr3 using /dev/vdf.
/> 

# 创建Target IQN（唯一标识）
/> iscsi/ create iqn.2025-07.com.oracle:rac.storage
Created target iqn.2025-07.com.oracle:rac.storage.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
/> 

# 绑定存储到LUN
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/luns create /backstores/block/data 
Created LUN 0.
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/luns create /backstores/block/arch 
Created LUN 1.
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr1
Created LUN 2.
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr2
Created LUN 3.
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/luns create /backstores/block/ocr3
Created LUN 4.
/> 

# 允许两个节点访问
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/acls create iqn.2025-07.com.oracle:rac01
Created Node ACL for iqn.2025-07.com.oracle:rac01
Created mapped LUN 4.
Created mapped LUN 3.
Created mapped LUN 2.
Created mapped LUN 1.
Created mapped LUN 0.
/> 
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/acls create iqn.2025-07.com.oracle:rac02
Created Node ACL for iqn.2025-07.com.oracle:rac02
Created mapped LUN 4.
Created mapped LUN 3.
Created mapped LUN 2.
Created mapped LUN 1.
Created mapped LUN 0.
/> 
/> iscsi/iqn.2025-07.com.oracle:rac.storage/tpg1/portals create 192.168.10.135 3260

/> saveconfig 
Last 10 configs saved in /etc/target/backup/.
Configuration saved to /etc/target/saveconfig.json

/> exit
Global pref auto_save_on_exit=true
Last 10 configs saved in /etc/target/backup/.
Configuration saved to /etc/target/saveconfig.json
[root@rac-data ~]#
```


---

## Initiator 客户端配置

### 节点 1 配置

#### 设置 Initiator 名称
```bash
yum install -y iscsi-initiator-utils device-mapper-multipath

echo "InitiatorName=iqn.2025-07.com.oracle:rac01" > /etc/iscsi/initiatorname.iscsi
```


#### 配置多路径
```bash
# 生成Multipath而配置文件
mpathconf --enable --with_multipathd y
# 修改/etc/multipath.conf配置文件
echo '
defaults {
    user_friendly_names yes
    find_multipaths yes
    path_grouping_policy multibus
    failback immediate
    rr_weight priorities
    no_path_retry fail
}
blacklist {
    devnode "^sd[a-z]$"  
} '> /etc/multipath.conf

systemctl start multipathd

# user_friendly_names    使用友好名称（如mpatha, mpathb）而不是WWID来命名设备
# path_grouping_policy   将所有路径合并到一个路径组（负载均衡）
# failback               当出现更好的路径时，立即切换回该路径
# no_path_retry          当所有路径都失效时，立即报告I/O错误（不重试）
# devnode                黑名单：排除所有形如sda, sdb, ..., sdz的本地磁盘
```

#### **连接存储**
```bash
iscsiadm -m discovery -t st -p 192.168.133.203
iscsiadm -m node -T iqn.2025-07.com.oracle:rac.storage -p 192.168.133.203 -l
```

#### 使用 `udev` 规则配置持久化设备命名 (每台主机)

编辑/etc/scsi_id.config文件，2个节点都要编辑

```bash
echo "options=--whitelisted --replace-whitespace"  >> /etc/scsi_id.config
```

将磁盘wwid信息写入99-oracle-asmdevices.rules文件，2个节点都要编辑

```bash
### !!!!!!!!!!!!! 一定要先创建用户 !!!!!!!!!!! ##################
for i in a b c d e ;
do 
echo "KERNEL==\"sd*\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$name\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sd${i}`\",SYMLINK+=\"asm-sd${i}\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracle-asmdevices.rules
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


### 节点 2 配置 

#### 设置唯一 Initiator 名称
```bash
echo "InitiatorName=iqn.2025-07.com.oracle:rac02" > /etc/iscsi/initiatorname.iscsi
```

#### 重复节点1的配置步骤（多路径、连接存储）

---


## 常用的 `iscsiadm` 命令
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
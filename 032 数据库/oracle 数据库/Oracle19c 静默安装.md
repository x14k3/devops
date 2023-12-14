# Oracle19c 静默安装

## 一、环境准备

1. 下载地址：  
   [https://edelivery.oracle.com/osdc/faces/SoftwareDelivery](https://edelivery.oracle.com/osdc/faces/SoftwareDelivery)
2. 官方文档：  
   [https://docs.oracle.com/en/database/oracle/oracle-database/19/haovw/index.html](https://docs.oracle.com/en/database/oracle/oracle-database/19/haovw/index.html)

```bash
#修改主机名
hostnamectl set-hostname oracle

# hosts文件（将主机名和ip对应）
sed -i "\$a 192.168.101.222  Orcle" /etc/hosts

#修改Linux字符集为zh_CN.utf8
echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf  
source /etc/locale.conf
# opensuse
echo "LANG="zh_CN.UTF-8"" > /etc/profile.local
source /etc/profile

# SELinux 主要作用就是最大限度地减小系统中服务进程可访问的资源，建议关闭
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#opensuse 默认不启用selinux

# firewalld防火墙取代了iptables防火墙
systemctl stop firewalld && systemctl disable firewalld

# 查看是否启用了  Transparent Hugepages
cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never  # 启用状态

# 永久禁用THP(Transparent HugePages )--直接执行立即生效
vim /etc/rc.d/rc.local
------------------------------------------------------
echo never > /sys/kernel/mm/transparent_hugepage/enabled 
echo never > /sys/kernel/mm/transparent_hugepage/defrag

#创建数据库用户&组
groupadd -g 200 oinstall
groupadd -g 201 dba
groupadd -g 202 oper
groupadd -g 203 backupdba
groupadd -g 204 dgdba
groupadd -g 205 kmdba
groupadd -g 206 racdba
useradd -u 200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle && echo Ninestar123 | passwd --stdin oracle
#useradd -u 200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle && echo "oracle:Ninestar123" | chpasswd 

#创建目录
mkdir -p /data/u01/app/oracle/product/19.3.0/db_1
chmod -R 755 /data/u01/
mkdir -p /data/u01/app/oraInventory/
mkdir -p /data/oradata/
chown -R oracle:oinstall /data/u01/
chown -R oracle:oinstall /data/oradata/

#内核优化sysctl.conf
cat >>/etc/sysctl.conf <<EOF

#/系统级别最大可以打开文件句柄的数量
fs.file-max = 6815744
#共享内存总量
kernel.shmall = 1073741824
#单个共享内存段的最大值
kernel.shmmax = 4398046511104
#共享内存段的最大数量
kernel.shmmni = 4096
#semaphores，进程间通信信号量
kernel.sem = 250 32000 100 128
#接收套接字缓冲区大小的默认值(以字节为单位)。
net.core.rmem_default = 262144
#接收套接字缓冲区大小的最大值(以字节为单位)。
net.core.rmem_max = 4194304
#发送套接字缓冲区大小的默认值(以字节为单位)。
net.core.wmem_default = 262144
#发送套接字缓冲区大小的最大值(以字节为单位)。
net.core.wmem_max = 1048576
#同时可以拥有的的异步IO请求数目
fs.aio-max-nr = 1048576
#配置向外连接端口范围
net.ipv4.ip_local_port_range = 9000 65500
EOF

sysctl -p


#linux资源限制配置文件是/etc/security/limits.conf；限制用户进程的数量对于linux系统的稳定性非常重要。
cat  >> /etc/security/limits.conf <<EOF
#soft是一个警告值，而hard则是一个真正意义的阀值，超过就会报错
#用户可以打开的最大进程数
#查看系统中可创建的进程数实际值 cat /proc/sys/kernel/pid_max
oracle soft nproc 65536
oracle hard nproc 65536
#用户可以打开的最大的文件描述符数量,默认1024，这里的数值会限制tcp连接
#查看系统最大文件描述符 cat /proc/sys/fs/file-max
oracle soft nofile 65536
oracle hard nofile 65536
#最大栈大小(kb)
oracle soft stack 16384
oracle hard stack 32768
oracle hard memlock 134217728
oracle soft memlock 134217728
EOF

cp /etc/pam.d/login{,.orainstallbak}   #备份原始文件
echo "session    required     pam_limits.so" >> /etc/pam.d/login

# 环境变量配置
cat  >>/etc/profile.local <<EOF
if [ $USER = "oracle" ]; then
   if [ $SHELL = "/bin/ksh" ]; then
       ulimit -p 16384
       ulimit -n 65536
    else
       ulimit -u 16384 -n 65536
   fi
fi
EOF

#cat  >> /home/oracle/.profile <<EOF  #opensuse
cat  >> /home/oracle/.bash_profile <<EOF
export EDITOR=vi
export ORACLE_SID=orcl
export ORACLE_BASE=/data/u01/app/oracle
export ORACLE_HOME=/data/u01/app/oracle/product/19.3.0/db_1
export LD_LIBRARY_PATH=/data/u01/app/oracle/product/19.3.0/db_1/lib
export PATH=/data/u01/app/oracle/product/19.3.0/db_1/bin:$PATH
export ORACLE_TERM=xterm
export TEMP=/tmp
export TMPDIR=/tmp
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
export DMPDIR=$ORACLE_BASE/admin/$ORACLE_SID/dpdump
#export CV_ASSUME_DISTID=RHEL7.6 # Centos8或opensuse安装oracle需要打开注释
export LANG="zh_CN.UTF-8"
EOF

source /etc/profile
source /home/oracle/.bash_profile

# 安装oracle所需依赖
# Centos7.x
yum install -y  vim make gcc gcc-c++ unzip zip net-tools libnsl bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel unixODBC-devel ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb  nfs-utils targetcli smartmontools sysstat

# OpenSuSE15.3
zypper in -y vim unzip net-tools gcc bc binutils glibc glibc-devel insserv-compat libaio-devel libaio1 libX11-6 libXau6 libXext-devel libXext6 libXi-devel libXi6 libXrender-devel libXrender1 libXtst6 libcap-ng-utils libcap-ng0 libcap-progs libcap1 libcap2 libelf1 libgcc_s1 libjpeg8 libpcap1 libpcre1 libpcre16-0 libpng16-16 libstdc++6 libtiff5 libgfortran4 mksh make pixz rdma-core rdma-core-devel smartmontools sysstat xorg-x11-libs xz compat-libpthread-nonshared readline-devel


## opensuse挂载系统镜像源
## 1.上传opensuse镜像至/opt
## 2.挂载到/mnt     mount -o loop /opt/opensuse.xxx.iso  /mnt/
## 3.配置zypper源   zypper ar -f /mnt/ opensuse
## 4.刷新 zypper lr ; zypper clean;
```

---

## 二、安装数据库

### 1. 解压安装包

```bash
# 解压oracle安装包到 ORACLE_HOME 目录
unzip -d /data/u01/app/oracle/product/19.3.0/db_1/  /opt/Silence_193000_Linux-x86-64.zip
```

### 2. 静默安装oracle数据库

参数详解 见 db_install.rsp参数

```bash
chown -R oracle:oinstall /data/u01/   #修改目录拥有者
su - oracle                           #切换到oracle用户
source /home/oracle/.bash_profile     #导入环境变量
# 执行静默安装数据库软件
/data/u01/app/oracle/product/19.3.0/db_1/runInstaller -ignorePreReqs -silent \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=/data/u01/app/oraInventory \
SELECTED_LANGUAGES=en,zh_CN \
ORACLE_HOME=/data/u01/app/oracle/product/19.3.0/db_1 \
ORACLE_BASE=/data/u01/app/oracle \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=oper \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
oracle.install.db.config.starterdb.installExampleSchemas=false \
oracle.install.db.rootconfig.executeRootScript=false

exit;  #切换回root用户
/data/u01/app/oraInventory/orainstRoot.sh
/data/u01/app/oracle/product/19.3.0/db_1/root.sh
```

### 3. 静默创建数据库实例

参数详解 见 dbca.rsp参数

- 创建FS存储方式非CDB数据库：
  当指定FS时，数据库文件由操作系统的文件系统管理。

```bash
# 创建数据目录和日志归档目录
mkdir -p /data/oradata/ data/archivelog/fmsdb
chown -R oracle.oinstall /data/oradata/ data/archivelog/fmsdb
# 切换到oracle用户
su - oracle
# 静默创建数据库
dbca -silent -ignorePreReqs -ignorePrereqFailure -createDatabase \
-responseFile NO_VALUE \
-templateName General_Purpose.dbc \
-gdbname fmsdb -sid fmsdb \
-sysPassword Ninestar2022 -systemPassword Ninestar2022 -dbsnmpPassword Ninestar2022 \
-datafileDestination '/data/oradata' \
-characterset ZHS16GBK \
-enableArchive true \
-archiveLogDest '/data/archivelog/fmsdb' \
-totalMemory 8192

# 日志路径：
tail -f $ORACLE_BASE/cfgtoollogs/dbca
# 删除数据库实例
# dbca -silent -deleteDatabase -sourceDB fmsdb -sid fmsdb -sysDBAUserName sys -sysDBAPassword Ninestar2022 -forceArchiveLogDeletion
```

- 创建FS存储方式CDB数据库：[Oracle CDB PDB](Oracle%20CDB%20PDB.md)

```bash
dbca -silent -ignorePreReqs -ignorePrereqFailure -createDatabase \
-responseFile NO_VALUE \
-templateName General_Purpose.dbc \
-createAsContainerDatabase true \
-gdbname orcl -sid orcl \
-sysPassword Ninestar2022 -systemPassword Ninestar2022 -dbsnmpPassword Ninestar2022 \
-datafileDestination '/data/oradata' -recoveryAreaDestination '/data/oraback' \
-characterset ZHS16GBK \
-totalMemory 8192
```

- 创建FS存储方式CDB数据库(含一个PDB)：

```bash
dbca -silent -ignorePreReqs -ignorePrereqFailure -createDatabase \
-responseFile NO_VALUE \
-templateName General_Purpose.dbc \
-createAsContainerDatabase true \
-numberOfPDBs 1 \
-pdbName pdb1 \
-pdbAdminPassword Ninestar2022 \
-gdbname orcl -sid orcl \
-sysPassword Ninestar2022 -systemPassword Ninestar2022 -dbsnmpPassword Ninestar2022 \
-datafileDestination '/data/oradata' -recoveryAreaDestination '/data/oraback' \
-characterset ZHS16GBK \
-totalMemory 8192
```

- 创建存储为磁盘组的CDB单实例数据库：
  当ASM被指定时，您的数据库文件被放在Oracle ASM磁盘组中。Oracle数据库自动管理数据库文件的放置和命名。datafileDestination 磁盘组名，例如：'DATA'

```bash
dbca -silent -ignorePreReqs  -ignorePrereqFailure  -createDatabase \
 -responseFile NO_VALUE \
-templateName General_Purpose.dbc \
-gdbname orcl  -sid orcl \
-createAsContainerDatabase true \
-sysPassword Ninestar2022 -systemPassword Ninestar2022 \
-pdbAdminPassword Ninestar2022 -dbsnmpPassword Ninestar2022 \
-datafileDestination '+DATA' -recoveryAreaDestination '+FRA' \
-redoLogFileSize 50 \
-storageType ASM \
-characterset AL32UTF8 \
-totalMemory 8192 
```

- 创建rac类型的CDB数据库：

```bash
dbca -silent -ignorePreReqs  -ignorePrereqFailure  -createDatabase \
-responseFile NO_VALUE \
-templateName General_Purpose.dbc \
-gdbname rac19c  -sid rac19c \
-createAsContainerDatabase TRUE \
-sysPassword Ninestar2022 -systemPassword Ninestar2022 \
-pdbAdminPassword Ninestar2022 -dbsnmpPassword Ninestar2022 \
-datafileDestination '+DATA' -recoveryAreaDestination '+FRA' \
-redoLogFileSize 50 \
-storageType ASM \
-characterset AL32UTF8 \
-totalMemory 1024 \
-nodeinfo raclhr-19c-n1,raclhr-19c-n2
```

- 每个参数的含义如下所示

```bash
-gdbname #全局数据库名
-sid     # 数据库SID，sid和gdbname保持一致
-sysPassword    # 数据库sys密码
-systemPassword # 数据库system密码
-sysmanPassword # 数据库sysman密码
-createAsContainerDatabase # 是否创建CDB，true为创建CDB 
-numberOfPDBs   # 创建PDB的数量 
-pdbName   # PDB名字，如果创建多个PDB，该名字为前缀名 
-pdbAdminPassword # PDB管理员密码
-datafileDestination # 数据库数据文件的位置，若是磁盘组则写磁盘组名，例如：'**DATA/**'，若是文件系统就写具体路径，例如：'/u01/app/oracle'，需要注意的是，由于数据文件路径会自动加上数据库名，所以，这里不用加数据库名
-recoveryAreaDestination # 闪回恢复区的位置，该值一般和datafileDestination保持一致
-redoLogFileSize # 数据库Redo文件的大小
-enableArchive   # 是否启用归档 
-archiveLogDest  # 归档路径
-characterset    # 数据库字符集，一般为AL32UTF8或ZHS16GBK
-nationalCharacterSet # 国家字符集，一般为AL16UTF16
-storageType     #  存储类型：FS为文件系统，ASM为ASM磁盘形式，如果使用ASM存储，还需要指定-diskGroupName，-recoveryGroupName
-diskGroupName   # 存放数据库文件的磁盘组名称，注意此处不加“+”
-nodeinfo        # 安装数据库的节点信息，若是RAC库则必须使用该参数，该参数的值为主机名列表，中间用逗号隔开
-emConfiguration # 数据库管理方式，是本地管理还是使用Grid Control进行管理，一般设置为NONE
-automaticMemoryManagement # 是否启动AMM，true代表启动AMM,false代表启动ASMM
-totalMemory      # 指定实例占用内存大小，PGA和SGA会自动分配
-memoryPercentage # 代表数据库占用OS内存大小的百分比
-sampleSchema     # 是否安装用于学习实验的示例数据，测试库选择true，生产库选择false
```

## 三、配置静态监听

### 1. 修改 listener.ora

配置详解 见 listener.ora 详解

```bash
#- listener.ora是oracle监听程序，里面有oracle服务器端的socket监听地址和端口,使局域网中的其他人能够访问oracle
# 编辑listener.ora文件
vim $ORACLE_HOME/network/admin/listener.ora
#============================================================================
## 添加如下内容

SID_LIST_LISTENER=
  (SID_LIST=
    (SID_DESC=
      (GLOBAL_DBNAME = fmsdb)   --db_unique_name
      (SID_NAME = fmsdb)        --instance_name
      (ORACLE_HOME = /data/u01/app/oracle/product/19.3.0/db_1)
    )
    (SID_DESC=
      (GLOBAL_DBNAME = pdb1)    --pdb_name
      (SID_NAME = fmsdb)        --instance_name
      (ORACLE_HOME = /data/u01/app/oracle/product/19.3.0/db_1)
    )
  )

LISTENER=
  (DESCRIPTION=
    (ADDRESS_LIST=
      (ADDRESS=(PROTOCOL = tcp)(HOST = 192.168.0.203)(PORT = 1521))
      (ADDRESS=(PROTOCOL = ipc)(KEY = extproc))
    )
  )

ADR_BASE_LISTENER = /data/u01/app/oracle

#===========================================================================
```

### 2. 修改 tnsnames.ora

配置详解 见 tnsnames.ora 详解

```bash
## 编辑 tnsnames.ora文件
vim $ORACLE_HOME/network/admin/tnsnames.ora
#============================================================================#

fmsdb =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.203)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = fmsdb)
      (SERVER = DEDICATED)
    )
  )
  
pdb1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.203)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = pdb1)   --pdb_name
      (SERVER = DEDICATED)
    )
  )
#==============================================================================
```

### 3. 启动监听

```bash
su - oracle    # 切换到oracle用户
lsnrctl start   # 启动监听
```

## 四、自动化安装脚本

[01_env_prepararion.sh](assets/01_env_prepararion-20231107114608-1xnomig.sh)

[02_Install_oracle_soft.sh](assets/02_Install_oracle_soft-20231107114608-trizzaq.sh)

[03_oracle_dbca.sh](assets/03_oracle_dbca-20231107114608-rmxdc9s.sh)

[04_oracle_create_tablespace_user.sh](assets/04_oracle_create_tablespace_user-20231107114608-ls2rzr4.sh)

[05_oracle_rman.sh](assets/05_oracle_rman-20231107114608-ta6p1mk.sh)

[readme.txt](assets/readme-20231107114608-0axcf9z.txt)

‍

# Oracle11g 静默安装

## 

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
mkdir -p /data/u01/app/oracle/product/11.2.0/db_1
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
export ORACLE_HOME=/data/u01/app/oracle/product/11.2.0/db_1
export LD_LIBRARY_PATH=/data/u01/app/oracle/product/11.2.0/db_1/lib
export PATH=/data/u01/app/oracle/product/11.2.0/db_1/bin:$PATH
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
yum install -y  vim make gcc gcc-c++ unzip zip net-tools libnsl bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel unixODBC-devel ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb  nfs-utils targetcli smartmontools sysstat compat-libcap1


## opensuse挂载系统镜像源
## 1.上传opensuse镜像至/opt
## 2.挂载到/mnt     mount -o loop /opt/opensuse.xxx.iso  /mnt/
## 3.配置zypper源   zypper ar -f /mnt/ opensuse
## 4.刷新 zypper lr ; zypper clean;
```

## 二、安装数据库

### 1. 解压安装包

```bash
# 将安装包上传到/opt目录
cd /opt
unzip  V17530-01_1of2.zip
unzip  V17530-01_2of2.zip
chown -R oracle.oinstall database
```

### 2.静默安装数据库

修改db_install.rsp

​`vim /opt/database/response/db_install.rsp`​

```bash
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=oracle
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/data/u01/app/oraInventory
SELECTED_LANGUAGES=en,zh_CN
ORACLE_HOME=/data/u01/app/oracle/product/11.2.0/db_1
ORACLE_BASE=/data/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.isCustomInstall=false
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
DECLINE_SECURITY_UPDATES=true

```

执行安装脚本

```shell
su - oracle
[oracle@oracledb-01 ~]$ cd /data/database/
./runInstaller -silent -responseFile /data/etc/db_install.rsp -ignorePrereq
```

按照上述提示进行操作，使用`root`​用户运行脚本

```bash
su - root
sh /data/u01/app/oraInventory/orainstRoot.sh
sh /data/u01/app/oracle/product/11.2.0/db_1/root.sh

```

### 3.静默创建数据库

编辑应答文`/data/u01/app/oracle/product/11.2.0/db_1/assistants/dbca/dbca.rsp`​

```bash
[GENERAL]
RESPONSEFILE_VERSION = "11.2.0"
OPERATION_TYPE = "createDatabase"
[CREATEDATABASE]
GDBNAME = "orcl"
SID = "orcl"
TEMPLATENAME = "General_Purpose.dbc"
SYSPASSWORD = "8ql6,yhY"
SYSTEMPASSWORD = "8ql6,yhY"
SYSMANPASSWORD = "8ql6,yhY"
DBSNMPPASSWORD = "8ql6,yhY"
DATAFILEDESTINATION = /data/app/oracle/oradata
RECOVERYAREADESTINATION=/data/app/oracle/fast_recovery_area
CHARACTERSET = "AL32UTF8"  # 字符集，根据需求设置，建议前期确定好需要什么字符集，后期不建议更改
TOTALMEMORY = "102400"  # 分配给Oracle的内存总量，根据服务器内存总量进行分配
```

执行静默建库

```bash
su - oracle
dbca -silent -responseFile /data/u01/app/oracle/product/11.2.0/db_1/assistants/dbca/dbca.rsp

# 删除数据库实例
# dbca -silent -deleteDatabase -sourceDB fmsdb -sid fmsdb -sysDBAUserName sys -sysDBAPassword Ninestar2022 -forceArchiveLogDeletion
```

## 三、配置静态监听

### 1. 修改 listener.ora

配置详解 见 listener.ora 详解

```bash
#- listener.ora是oracle监听程序，里面有oracle服务器端的socket监听地址和端口,使局域网中的其他人能够访问oracle
# 编辑listener.ora文件
vim $ORACLE_HOME/network/admin/listener.ora
#============================================================================
SID_LIST_LISTENER=
  (SID_LIST=
    (SID_DESC=
      (GLOBAL_DBNAME = orcl)
      (SID_NAME = orcl)
      (ORACLE_HOME = /data/u01/app/oracle/product/11.2.0/db_1)
    )
  )

LISTENER=
  (DESCRIPTION=
    (ADDRESS_LIST=
      (ADDRESS=(PROTOCOL = tcp)(HOST = 10.10.0.42)(PORT = 1521))
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

‍

## 四、自动化部署脚本

###

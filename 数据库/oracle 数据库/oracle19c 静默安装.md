#database/oracle


## 一、环境准备
1. 下载地址：
https://edelivery.oracle.com/osdc/faces/SoftwareDelivery
2. 官方文档：
https://docs.oracle.com/en/database/oracle/oracle-database/19/haovw/index.html


```bash
#修改主机名
hostnamectl set-hostname Orcle

# hosts文件（将主机名和ip对应）
sed -i "\$a 192.168.101.222  Orcle" /etc/hosts

#修改Linux字符集为zh_CN.utf8
echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf  
source /etc/locale.conf

# SELinux 主要作用就是最大限度地减小系统中服务进程可访问的资源，建议关闭
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

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
useradd -u 200 -g oinstall -G dba,oper oracle
echo Ninestar2021 | passwd --stdin oracle

#创建目录
mkdir -p /data/u01/app/oracle/product/19.3.0/db_1
chmod -R 755 /data/u01/
mkdir -p /data/u01/app/oraInventory/
mkdir -p /data/oradata/
chown -R oracle:oinstall /data/u01/
chown -R oracle:oinstall /data/oradata/

#内核优化sysctl.conf
cat >>/etc/sysctl.conf <<EOF
#同时可以拥有的的异步IO请求数目
fs.aio-max-nr = 1048576
#指定了可以打开文件的最大数量
fs.file-max = 6815744
#允许使用的共享内存大小
kernel.shmall = 7549740
#定义单个共享内存段的最大值
kernel.shmmax = 17179869184
#用于设置系统范围内共享内存段的最大数量
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
#接收套接字缓冲区大小的默认值(以字节为单位)。
net.core.rmem_default = 262144
#接收套接字缓冲区大小的最大值(以字节为单位)。
net.core.rmem_max = 4194304
#发送套接字缓冲区大小的默认值(以字节为单位)。
net.core.wmem_default = 262144
#发送套接字缓冲区大小的最大值(以字节为单位)。
net.core.wmem_max = 1048576
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
cat  >>/etc/profile <<EOF
if [ $USER = "oracle" ]; then
   if [ $SHELL = "/bin/ksh" ]; then
       ulimit -p 16384
       ulimit -n 65536
    else
       ulimit -u 16384 -n 65536
   fi
fi
EOF

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
#export CV_ASSUME_DISTID=RHEL7.6 # Centos8安装oracle需要打开注释
export LANG="zh_CN.UTF-8"
EOF

source /etc/profile
source /home/oracle/.bash_profile

# 安装oracle所需依赖
# Centos7.x
yum install -y  vim make gcc gcc-c++ unzip zip net-tools libnsl bc binutils  \
elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel unixODBC-devel\
ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel \
libgcc libstdc++ libstdc++-devel libxcb  nfs-utils targetcli smartmontools sysstat

# OpenSuSE15.3
zypper in -y vim make gcc gcc-c++ unzip zip net-tools bc binutils glibc glibc-devel insserv-compat libaio-devel libaio1 \
libX11-6 libXau6 libXext-devel libXext6 libXi-devel libXi6 libXrender-devel libXrender1 \
libXtst6 libcap-ng-utils libcap-ng0 libcap-progs libcap1 libcap2 libelf1 libgcc_s1 libjpeg8 \
libpcap1 libpcre1 libpcre16-0 libpng16-16 libstdc++6 libtiff5 libgfortran4 mksh make pixz rdma-core \
rdma-core-devel smartmontools sysstat xorg-x11-libs xz compat-libpthread-nonshared readline-devel
## opensuse挂载系统镜像源
## 1.上传opensuse镜像至/opt
## 2.挂载到/mnt     mount -o loop /opt/opensuse.xxx.iso  /mnt/
## 3.配置zypper源   zypper ar -f /mnt/ opensuse
## 4.刷新 zypper lr ; zypper clean;
```

***

## 二、安装数据库

### 1.解压安装包

```bash
# 通过xftp 上传oracle19c.zip安装包至 /opt/目录下
# 解压oracle安装包
cd /opt
unzip -d /data/u01/app/oracle/product/19.3.0/db_1/ oracle19c.zip

```

### 2.配置db\_install.rsp文件

```bash
# oracle数据库静默安装使用的配置文件
cd /data/u01/app/oracle/product/19.3.0/db_1/install/response/
sed -i "/^oracle.install.option=/coracle.install.option=INSTALL_DB_SWONLY" db_install.rsp
sed -i "/^UNIX_GROUP_NAME=/cUNIX_GROUP_NAME=oinstall" db_install.rsp
sed -i "/^INVENTORY_LOCATION=/cINVENTORY_LOCATION=/data/u01/app/oraInventory" db_install.rsp
sed -i "/^SELECTED_LANGUAGES=/cSELECTED_LANGUAGES=en,zh_CN" db_install.rsp
sed -i "/^ORACLE_HOME=/cORACLE_HOME=/data/u01/app/oracle/product/19.3.0/db_1" db_install.rsp
sed -i "/^ORACLE_BASE=/cORACLE_BASE=/data/u01/app/oracle" db_install.rsp
sed -i "/^oracle.install.db.InstallEdition=/coracle.install.db.InstallEdition=EE" db_install.rsp
sed -i "/^oracle.install.db.OSDBA_GROUP=/coracle.install.db.OSDBA_GROUP=dba" db_install.rsp
sed -i "/^oracle.install.db.OSBACKUPDBA_GROUP=/coracle.install.db.OSBACKUPDBA_GROUP=dba" db_install.rsp
sed -i "/^oracle.install.db.OSDGDBA_GROUP=/coracle.install.db.OSDGDBA_GROUP=dba" db_install.rsp
sed -i "/^oracle.install.db.OSKMDBA_GROUP=/coracle.install.db.OSKMDBA_GROUP=dba" db_install.rsp
sed -i "/^oracle.install.db.OSRACDBA_GROUP=/coracle.install.db.OSRACDBA_GROUP=dba" db_install.rsp
sed -i "/^oracle.install.db.OSOPER_GROUP=/coracle.install.db.OSOPER_GROUP=oper" db_install.rsp
sed -i "/^oracle.install.db.config.starterdb.installExampleSchemas=/coracle.install.db.config.starterdb.installExampleSchemas=false" db_install.rsp
sed -i "/^oracle.install.db.rootconfig.executeRootScript=/coracle.install.db.rootconfig.executeRootScript=false" db_install.rsp


```

### 3.执行静默安装

```bash
# 切换到oracle用户下执行静默安装
chown -R oracle:oinstall /data/u01/   #修改目录拥有者
su - oracle                           #切换到oracle用户
source /home/oracle/.bash_profile     #导入环境变量
# 执行静默安装2
==================================================================================
/data/u01/app/oracle/product/19.3.0/db_1/runInstaller -silent -responseFile \
/data/u01/app/oracle/product/19.3.0/db_1/install/response/db_install.rsp
==================================================================================

# 此过程大概持续5分钟
```

### 4.配置 cadb.rsp

```bash
# oracle数据库创建实例使用的配置文件
vim /data/u01/app/oracle/product/19.3.0/db_1/assistants/dbca/dbca.rsp
===================================================================
# 数据库名
sed -i "/^gdbName=/cgdbName=orcl" dbca.rsp
sed -i "/^sid=/csid=orcl" dbca.rsp
sed -i "/^sysPassword=/csysPassword=Ninestar2021" dbca.rsp
sed -i "/^systemPassword=/csystemPassword=Ninestar2021" dbca.rsp
sed -i "/^databaseConfigType=/cdatabaseConfigType=SI" dbca.rsp
sed -i "/^templateName=/ctemplateName=General_Purpose.dbc" dbca.rsp
sed -i "/^datafileDestination=/cdatafileDestination=/data/oradata" dbca.rsp
sed -i "/^characterSet=/ccharacterSet=ZHS16GBK" dbca.rsp
sed -i "/^automaticMemoryManagement=/cautomaticMemoryManagement=false" dbca.rsp
sed -i "/^totalMemory=/ctotalMemory=4096" dbca.rsp

# 是否启用PDB
sed -i "/^createAsContainerDatabase=/ccreateAsContainerDatabase=true" dbca.rsp
sed -i "/^numberOfPDBs=/cnumberOfPDBs=1" dbca.rsp
sed -i "/^pdbName=/cpdbName=OPDB" dbca.rsp
sed -i "/^pdbAdminPassword=/cpdbAdminPassword=Ninestar2021" dbca.rsp

```

### 5.创建数据库实例

```bash
exit;  #切换回root用户
/data/u01/app/oraInventory/orainstRoot.sh
/data/u01/app/oracle/product/19.3.0/db_1/root.sh

su - oracle #切换到oracle用户
dbca -silent -createDatabase -responseFile /data/u01/app/oracle/product/19.3.0/db_1/assistants/dbca/dbca.rsp
# 删除数据库实例
#dbca -silent -deleteDatabase -sourceDB orcl -sid orcl -sysDBAUserName oracle -sysDBAPassword Ninestar2021
# 此过程大概30分钟

```

## 三、配置监听

### 1.修改 listener.ora

```bash
#- listener.ora是oracle监听程序，里面有oracle服务器端的socket监听地址和端口,使局域网中的其他人能够访问oracle
# 编辑listener.ora文件
vim /data/u01/app/oracle/product/19.3.0/db_1/network/admin/listener.ora
#============================================================================
## 添加如下内容

SID_LIST_LISTENER=
  (SID_LIST=
    (SID_DESC=
    (GLOBAL_DBNAME = ORCL)           #CDB
      (SID_NAME = ORCL)
      (ORACLE_HOME = /data/u01/app/oracle/product/19.3.0/db_1)
    )
  
    (SID_DESC=
    (GLOBAL_DBNAME = OPDB)           #PDB
      (SID_NAME = ORCL)
      (ORACLE_HOME = /data/u01/app/oracle/product/19.3.0/db_1)
    )
  )

LISTENER=
  (DESCRIPTION=
    (ADDRESS_LIST=
      (ADDRESS=(PROTOCOL = tcp)(HOST = jydb)(PORT = 1521))
    )
  )

ADR_BASE_LISTENER = /data/u01/app/oracle

#===========================================================================
```

### 2.修改 tnsnames.ora

```bash
## 编辑listener.ora文件
vim /data/u01/app/oracle/product/19.3.0/db_1/network/admin/tnsnames.ora
#============================================================================#

ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = jydb)(PORT = 1521))
    (CONNECT_DATA =
    (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )
  
OPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = jydb)(PORT = 1521))
    (CONNECT_DATA =
    (SERVER = DEDICATED)
      (SERVICE_NAME = OPDB)
    )
  ))

#==============================================================================
```

### 3.启动监听

```bash
su - oracle    # 切换到oracle用户
lsnrctl start   # 启动监听

```

# 四、其他

## 1.数据库字符集

NLS_LANG这个参数由三个组成部分，分别是【语言\_区域.字符集】

```bash
# windows添加环境变量
NLS_LANG SIMPLIFIED CHINESE_CHINA.ZHS16GBK

# linux配置   
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"    # 终端字符集使用utf-8
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".ZHS16GBK  # 终端字符集使用gbk

```




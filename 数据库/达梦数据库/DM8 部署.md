#database/dm8

# 达梦数据库服务端安装

达梦数据库下载地址：
https://www.dameng.com/list_103.html

## 一、环境准备
原则建议分 3 块盘符，分别是 dmdata 实例盘、dmbak 备份盘和 dmarch 归档盘。

```bash
### 1.修改主机名
hostnamectl set-hostname dmdb
# 在hosts文件中添加ip和主机名的映射
sed -i "\$a 192.168.10.150 dmdb"  /etc/hosts 

### 2.修系统字符集
echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf
source /etc/locale.conf

### 3.关闭selinux和firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl stop firewalld && systemctl disable firewalld 

### 4.关闭 Transparent Hugepages
#透明大页 缩写 THP ，这个是 RHEL 6 开始引入的一个功能，在 Linux6 上透明大页是默认启用的。  
#标准大页是从 Linux Kernel 2.6 后被引入的，目的是通过使用大页[内存](https://so.csdn.net/so/search?q=%E5%86%85%E5%AD%98&spm=1001.2101.3001.7020)来取代传统的 4kb 内存页面， 以适应越来越大的系统内存，让操作系统可以支持现代硬件架构的大页面容量功能。  

#标准大页有两种格式大小： 2MB 和 1GB ， 2MB 页块大小适合用于 GB 大小的内存， 1GB 页块大小适合用于 TB 级别的内存； 2MB 是默认的页大小。  
#由于 标准大页 很难手动管理，而且通常需要对代码进行重大的更改才能有效的使用，因此 RHEL 6 开始引入了 透明大页 （ THP ）， THP 是一个抽象层，能够自动创建、管理和使用传统大页。  
#THP 为系统管理员和开发人员减少了很多使用传统大页的复杂性 , 因为 THP 的目标是改进性能 , 因此其它开发人员 ( 来自社区和红帽 ) 已在各种系统、配置、应用程序和负载中对 THP 进行了测试和优化。这样可让 THP 的默认设置改进大多数系统配置性能。但是 , 不建议对数据库工作负载使用 THP 。  
#这两者最大的区别在于 : 标准大页管理是预分配的方式，而透明大页管理则是动态分配的方式。

# 查看是否启用了  Transparent Hugepages
cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never  # 启用状态

# 永久禁用THP(Transparent HugePages )--直接执行立即生效
vim /etc/rc.d/rc.local
------------------------------------------------------
echo never > /sys/kernel/mm/transparent_hugepage/enabled 
echo never > /sys/kernel/mm/transparent_hugepage/defrag

### 5.新建 dmdba 用户和组
groupadd dinstall
useradd -g dinstall -m  -s /bin/bash dmdba
echo Ninestar2022 | passwd --stdin dmdba

### 6.资源限制
# 限制用户进程的数量对于linux系统的稳定性非常重要。
cat >> /etc/security/limits.conf  << EOF
#soft是一个警告值，而hard则是一个真正意义的阀值，超过就会报错
#用户可以打开的最大进程数
#查看系统中可创建的进程数实际值 cat /proc/sys/kernel/pid_max
dmdba soft nproc 65536
dmdba hard nproc 65536
#用户可以打开的最大的文件描述符数量,默认1024，这里的数值会限制tcp连接
#查看系统最大文件描述符 cat /proc/sys/fs/file-max
dmdba soft nofile 65536
dmdba hard nofile 65536
#最大栈大小(kb)
dmdba soft stack 16384
dmdba hard stack 32768
EOF

# 检查是否生效 
su - dmdba 
ulimit -a

### 7.挂载DM数据库iso安装包
mount -o loop /opt/dm8_20220902_x86_rh6_64_ent_8.1.2.138.iso /mnt


### 8.创建安装目录
mkdir -p /data/{dmapp,dmdata}
chown -R dmdba:dinstall /data/{dmapp,dmdata}
```




## 二、数据库安装

_命令行安装_
```bash
su - dmdba
-------------------------------------------------
### 1. -i 静默安装
/mnt/DMInstall.bin -i

#步骤1：选择安装语言
#步骤2：验证key文件
#步骤3：输入时区
#步骤4：选择安装类型
#步骤5：选择安装路径
#步骤6：安装小结
#步骤7：安装
#步骤8：安装并启动数据库备份插件（DmAPService）



### 2.配置环境变量
su - dmdba
cat  >> .bash_profile <<EOF
export DM_HOME=/data/dmapp
export PATH=\$PATH:\$DM_HOME/bin:\$DM_HOME/tool
EOF
source .bash_profile
```


## 三、创建数据库实例

使用`dminit help` 命令查看创建实例参数

```bash
dminit PATH=/data/dmdata \
CASE_SENSITIVE=1 \
CHARSET=1 \
LOG_SIZE=2048 \
DB_NAME=fmsdb \
SYSDBA_PWD=Ninestar123 \
INSTANCE_NAME=fmsdb 

#实际环境中，簇大小建议选择 16，页大小选择 32K，日志大小选择 2048，字符集和大小写敏感需要和应用厂商对接后，再进行选择。
-----------------------------------------------------------
#EXTENT_SIZE        簇是进行存储空间分配的基本单位。一个簇是由一系列逻辑上连续的数据页组成的逻辑存储结构【默认16页】
#PAGE_SIZE            数据文件使用的页大小，可以为 4 KB、8 KB、16 KB 或 32 KB 之一，选择的页大小越大，则 DM 支持的元组长度也越大，但同时空间利用率可能下降，【默认8 KB】
#CASE_SENSITIVE  标识符大小写敏感，默认值为 Y 。取值 Y、1，N、0 
#CHARSET            字符集选项。0 代表 GB18030；1 代表 UTF-8；2 代表韩文字符集 EUC-KR；取值 0、1 或 2 之一。默认值为 0。
```


## 四、注册服务

注册数据库服务、守护服务、监控服务等
**注册服务需使用 *root* 用户进行注册**。使用 root 用户进入数据库安装目录的 `~/script/root` 下:

```bash
cd /data/dmapp/script/root
./dm_service_installer.sh -t dmserver -dm_ini /data/dmdata/fmsdb/dm.ini -p fmsdb
```

## 五、启动数据库

```bash
/data/dmapp/bin/DmServiceFMSDB start
----------------------------------------------------------------
# 命令行连接
#disql SYSDBA/Ninestar123@192.168.10.150:8001
#创建表空间
create tablespace jy2web datafile '/data/dmdata/fmsdb/JY2WEB01.DBF' size 1024 autoextend on next 1024 maxsize unlimited;
create tablespace jy2gm datafile '/data/dmdata/fmsdb/JY2GM01.DBF' size 1024 autoextend on next 1024 maxsize unlimited;
#创建用户JY2WEB并指定默认的表空间及默认的索引表空间。
create user jy2web identified by Ninestar2022 default tablespace jy2web;
create user jy2gm  identified by Ninestar2022 default tablespace jy2gm;
# 授权
grant resource,dba to jy2web;
grant resource,dba to jy2gm;

----------------------------------------------------------------
disql jy2web/Ninestar2022

```

## 六、其他配置

### Linux(Unix)下License的安装

**操作方法如下**：

首先，找到DM服务器所在的目录，方法是以root用户或安装用户登录到Linux系统，启动终端，执行以下命令即可进入DM服务器程序安装的目录：

```bash
# 关闭达梦数据库
/data/dmdbms/bin/DmServicejyv2g  stop
# 再将dm.key文件拷贝到该目录，替换原有的dm.key即可
# 更新拥有者权限
chown dmdba.dinstall dm.key
```



# 达梦数据库客户端安装

达梦数据库下载地址：
https://www.dameng.com/list_103.html

1. 解压后双击setup.exe 安装向导
2. 选择语言和时区（时区和服务端一样）
   `select sysdate;`
3. *验证key文件
4. 选择安装组件：客户端安装
5. 选择安装目录
6. 安装确认
7. 打开【开始菜单】使用DM管理工具连接数据库
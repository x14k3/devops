#!/bin/bash

#This is for Oracle 19C Install
#############################################################
#定义常量
SYSCTL="/etc/sysctl.conf"
LIMITS="/etc/security/limits.conf"
PAM="/etc/pam.d/login"
ETC_PROFILE="/etc/profile"
ORACLE_PROFILE="/home/oracle/.bash_profile"
LANG="zh_CN.UTF-8"
#setenv.sh文件路径
SETENVPATH=/tmp/setenv.sh
#获取服务器ip
TMP_SYSIP=`ip a|grep inet|grep global|grep brd|head -n 1|awk '{printf $2}'|cut -d "/" -f1`
#############################################################
#循环变量
#i=1

#定义显示颜色
#颜色定义 信息(33黄色) 警示(31红色) 过程(36浅蓝)

############################################################

# 环境检查
oscheck(){
echo ""
# 判断是否为root用户
if [ $USER != "root" ];then
  echo -e "\n\e[1;31m  Please use root user \e[0m"
  exit 4
else
  printf "%-28s %-4s\n" USER root
fi
#修改系统字符集
echo "LANG=\"${LANG}\"" > /etc/locale.conf
source /etc/locale.conf
printf "%-28s %-4s\n" LANG ${LANG}

#关闭系统防火墙IPTABLES
systemctl stop firewalld.service
systemctl disable firewalld.service > /dev/null
printf "%-28s %-4s\n" firewalld disabled

#关闭SELINUX
setenforce 0 >> /dev/null 2>&1;
cp /etc/selinux/config{,.orabak}
sed -i '/SELINUX/s/enforcing/disabled/;/SELINUX/s/permissive/disabled/' /etc/selinux/config
printf "%-28s %-4s\n" selinux disabled


}


############################################################
#定义环境变量
definEnVar(){
cat <<EOF > ${SETENVPATH}
#!/bin/bash

# 实例名
export ORACLE_SID=orcl
# oracle数据库服务器ip
export ORACLE_SYSIP=${TMP_SYSIP}
export ORACLE_PORT=1521
export ORACLE_HOSTNAME=oracle
# oracle数据库密码
export ORACLE_PASS_ALL=Manager2023
# 安装目录
export ORACLE_INSTALL_DIR=/data
export ORACLE_DATAFILE=\${ORACLE_INSTALL_DIR}/oradata
export ORACLE_RECOVER_PATH=\${ORACLE_INSTALL_DIR}/orabackup
export ORACLE_PATH=\${ORACLE_INSTALL_DIR}/u01
export ORACLE_BASE=\${ORACLE_PATH}/app/oracle
export ORACLE_HOME=\${ORACLE_BASE}/product/19.3.0/db_1
export ORACLE_VENT=\${ORACLE_PATH}/app/oraInventory
export ORACLE_SOFT_PATH="/opt/Silence_Oracle19c"
export ORACLE_SOFT_NAME="Silence_193000_Linux-x86-64.zip"
export ORACLE_SCRIPT_PATH="\${ORACLE_INSTALL_DIR}/script"
# 数据库字符集
export CHARACTERSET=AL32UTF8
#内存限制
export ORACLE_MEMLIT=16384
EOF


echo -e "\n\e[1;33m  Please enter the Oracle installation parameters [default value, you can directly press Enter to continue] \e[0m"
read -p "`echo -e "\n\e[1;36m  Please enter the server host name [oracle] : \e[0m"`" TMP_ORACLE_HOSTNAME
read -p "`echo -e "\n\e[1;36m  Please enter the server IP address[${TMP_SYSIP}] : \e[0m"`" TMP_ORACLE_SYSIP
read -p "`echo -e "\n\e[1;36m  Please enter the oracle installation directory [/data] : \e[0m"`" TMP_ORACLE_INSTALL_DIR
read -p "`echo -e "\n\e[1;36m  Please enter database SID [orcl] : \e[0m"`" TMP_ORACLE_SID
read -p "`echo -e "\n\e[1;36m  Please enter database password [Manager2023] : \e[0m"`" TMP_ORACLE_PASSWD
read -p "`echo -e "\n\e[1;36m  Please enter the database character set [AL32UTF8] : \e[0m"`" TMP_ORACLE_INSTALL_CHARACTERSET
read -p "`echo -e "\n\e[1;36m  Please enter the database memory size [16384] : \e[0m"`" TMP_ORACLE_MEMLIT
echo ""
echo "----------------------------------------------"

if [[ -n ${TMP_ORACLE_SID} ]];then
  sed -i "/^export ORACLE_SID=/cexport ORACLE_SID=${TMP_ORACLE_SID}"                          ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_SYSIP} ]];then
  sed -i "/^export ORACLE_SYSIP=/cexport ORACLE_SYSIP=${TMP_ORACLE_SYSIP}"                    ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_INSTALL_DIR} ]];then
  sed -i "/^export ORACLE_INSTALL_DIR=/cexport ORACLE_INSTALL_DIR=${TMP_ORACLE_INSTALL_DIR}"  ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_HOSTNAME} ]];then
  sed -i "/^export ORACLE_HOSTNAME=/cexport ORACLE_HOSTNAME=${TMP_ORACLE_HOSTNAME}"           ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_PASSWD} ]];then
  sed -i "/^export ORACLE_PASS_ALL=/cexport ORACLE_PASS_ALL=${TMP_ORACLE_PASSWD}"             ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_INSTALL_CHARACTERSET} ]];then
  sed -i "/^export CHARACTERSET=/cexport CHARACTERSET=${TMP_ORACLE_INSTALL_CHARACTERSET}"     ${SETENVPATH}
fi
if [[ -n ${TMP_ORACLE_MEMLIT} ]];then
  sed -i "/^export ORACLE_MEMLIT=/cexport ORACLE_MEMLIT=${TMP_ORACLE_MEMLIT}"                 ${SETENVPATH}
fi

cat ${SETENVPATH}

echo "----------------------------------------------"
read -p "`echo -e "\n\e[1;36m  Please confirm the above information and enter yes : \e[0m"`" MY_TRUE
if [[ ${MY_TRUE} == "Y" ]] || [[ ${MY_TRUE} == "y" ]] || [[ ${MY_TRUE} == "YES" ]] || [[ ${MY_TRUE} == "yes" ]]; then
	if [[ `cat /proc/meminfo | grep MemTotal | awk '{print $2}'` -lt $((${TMP_ORACLE_MEMLIT}*1024 )) ]];then
        echo -e "\n\e[1;31m  Please check the memory, there is insufficient physical memory ${TMP_ORACLE_MEMLIT} \e[0m"
        exit 1
	fi

source ${SETENVPATH}

#修改主机名
echo "$ORACLE_HOSTNAME" > /etc/hostname
hostnamectl set-hostname ${ORACLE_HOSTNAME}
echo "$ORACLE_SYSIP  $ORACLE_HOSTNAME " >> /etc/hosts

else
  echo -e "\n\e[1;31m  Cancel installation！ \e[0m"
  exit 1
fi

}

############################################################
#检查oracle所需软件包并安装
packagecheck(){
echo ""
echo -e "\e[1;36m  Start installing dependency packages... \e[0m"
for package in vim make gcc gcc-c++ unzip zip net-tools libnsl bc binutils  \
elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel unixODBC-devel \
ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel \
libgcc libstdc++ libstdc++-devel libxcb  nfs-utils targetcli smartmontools sysstat
do
rpm -q $package > /dev/null 2>&1 
if [[ $? != 0 ]];then
	yum install -y $package > /dev/null 2>&1
	if [[ $? == 0 ]];then
		printf "%-30s %-10s %-10s\n" $package Installation completed
		sleep 1
	else
		printf "%-30s %-10s %-10s\n" $package Installation failed
	  sleep 1
	fi
else
	printf "%-30s %-10s\n" $package Installed
	sleep 1
fi
done
}



#############################################################
#挂在光盘到/media目录下
#mount_cdrom()
#{
#echo -e "\n\e[1;31m please insert CentOS 7 to CDROM,press any key ...\e[0m"
##read -n -1
#if [ -d /media ];then
#	mount -t auto -o ro /dev/sr0 /media
#else
#	mkdir -p /media
#	mount -t auto -o ro /dev/sr0 /media
#fi
#if [ $? -eq 0 ];then
#	echo -e "\n\e[1;36m CDROM mount on /mnt/cdrom ... OK! \e[0m"
#fi
#}

#############################################################
#配置Yum本地光盘源
#mkdir -p /etc/yum.repos.d/bak ; mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/ ; cp -a /etc/yum.repos.d/bak/CentOS-Media.repo /etc/yum.repos.d/
#03_yum_repo()
#{
#cat <<EOF >> /etc/yum.repos.d/CentOS-Media.repo 
#[c7-media]
#name=CentOS-Media
#baseurl=file:///media/
#gpgcheck=0
#enabled=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#EOF
#if [ $? -eq 0 ];then
#	echo -e "\n\e[1;36m /etc/yum.repos.d/CentOS-Media.repo ... OK! \e[0m"
#fi
#}


#############################################################
#OS USER ADD 
#添加oracle用户，添加oracle用户所属组oinstall及附加组dba
osuseradd()
{
if [[ `grep "oracle" /etc/passwd` != "" ]];then
	userdel -r oracle
fi

if [[ `grep "oinstall" /etc/group` = "" ]];then
	groupadd -g 200 oinstall
fi

if [[ `grep "dba" /etc/group` = "" ]];then
	groupadd -g 201 dba
fi

if [[ `grep "oper" /etc/group` = "" ]];then
	groupadd -g 202 oper
fi

if [[ `grep "backupdba" /etc/group` = "" ]];then
	groupadd -g 203 backupdba
fi

if [[ `grep "dgdba" /etc/group` = "" ]];then
	groupadd -g 204 dgdba
fi

if [[ `grep "kmdba" /etc/group` = "" ]];then
	groupadd -g 205 kmdba
fi

if [[ `grep "racdba" /etc/group` = "" ]];then
	groupadd -g 206 racdba
fi

echo ""
useradd -u 200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle && echo "Ninestar123" |passwd --stdin oracle
if [ $? -eq 0 ];then
  echo -e "\n\e[1;36m  Oracle user and password configuration completed \e[0m"
  else
    echo -e "\n\e[1;31m  Oracle user and password configuration failed！\e[0m"
	exit 1
fi
}

#############################################################
# 设置sysctl.conf参数
kernelset()
{
cp $SYSCTL{,.orabak} && cat <<EOF >>$SYSCTL
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF
if [ $? -eq 0 ];then
	echo -e "\e[1;36m  ${SYSCTL} ...  ok \e[0m"
fi
sysctl -p > /dev/null
}


############################################################
# 设置limits.conf参数
oralimit()
{
cp $LIMITS{,.orabak} && cat <<EOF >>$LIMITS
oracle soft nofile 10240
oracle hard nofile 65536
oracle soft nproc 16384
oracle hard nproc 16384
oracle soft stack 10240
oracle hard stack 32768
oracle hard memlock 134217728
oracle soft memlock 134217728
EOF
if [ $? -eq 0 ];then
	echo -e "\e[1;36m  ${LIMITS} ...  ok \e[0m"
fi
}


############################################################
# 设置PAM_login参数
setlogin()
{
cp $PAM{,.orabak} && cat <<EOF >>$PAM
session required pam_limits.so
EOF
if [ $? -eq 0 ];then
	echo -e "\e[1;36m  ${PAM} ...  ok \e[0m"
fi
}

# 设置etcProfile参数,sqlplus就是用Korn Shell的
etcprofile()
{
cp $ETC_PROFILE{,.orabak} && cat <<EOF >>$ETC_PROFILE
if [ $USER = "oracle" ]; then
if [ $SHELL = "/bin/ksh" ]; then
  ulimit -p 16384
  ulimit -n 65536
 else
  ulimit -u 16384 -n 65536
 fi
fi
EOF
source ${ETC_PROFILE}
echo -e "\e[1;36m  ${ETC_PROFILE} ...  ok \e[0m"
}


############################################################
# 设置OracleProfile参数
oracle_profile()
{
cp $ORACLE_PROFILE{,.orabak} && cat <<EOF >>$ORACLE_PROFILE
export EDITOR=vi
export ORACLE_SID=${ORACLE_SID}
export ORACLE_BASE=${ORACLE_BASE}
export ORACLE_HOME=${ORACLE_HOME}
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export PATH=${ORACLE_HOME}/bin:$PATH
export ORACLE_TERM=xterm
export TEMP=/tmp
export TMPDIR=/tmp
export LANG=${LANG}
export NLS_LANG=AMERICAN_AMERICA.${CHARACTERSET}
#export CV_ASSUME_DISTID=RHEL7.6 # Centos8安装oracle需要打开注释
export DMPDIR=$ORACLE_BASE/admin/$ORACLE_SID/dpdump
EOF

echo -e "\e[1;36m  ${ORACLE_PROFILE} ...  ok \e[0m"
cp -a ${SETENVPATH} ${ORACLE_SOFT_PATH}/
echo -e "\n\e[1;36m  The database installation environment is ready！ \e[0m"
}


oscheck
definEnVar
packagecheck
osuseradd
kernelset
oralimit
setlogin
etcprofile 
oracle_profile


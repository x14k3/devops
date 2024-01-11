#!/bin/bash

source /etc/locale.conf
source /tmp/setenv.sh

read -p "`echo -e "\n\e[1;36m Please enter the tablespace name  : \e[0m"`" TMP_TABLESPACE
read -p "`echo -e "\n\e[1;36m Please enter the user name [Default is tablespace name]  : \e[0m"`" TMP_USER
read -p "`echo -e "\n\e[1;36m Please enter the password  : \e[0m"`" TMP_PASSWD

if [[ -n ${TMP_TABLESPACE} ]];then
  ORA_TABLESPACE=${TMP_TABLESPACE}
  else
  echo -e "\n\e[1;31m  Tablespace is empty！ \e[0m"
  exit 1
fi

if [[ -n ${TMP_USER} ]];then
  ORA_USER=${TMP_USER}
  else
  ORA_USER=${TMP_TABLESPACE}
fi


if [[ -n ${TMP_PASSWD} ]];then
  ORA_PASSWD="${TMP_PASSWD}"
  else
  echo -e "\n\e[1;31m  Password is empty！ \e[0m"
  exit 1
fi




function ora_Cnamescpace(){
su - oracle <<EOF
source /home/oracle/.bash_profile

sqlplus -S / as sysdba <<PWUNLI
set heading off
set feedback off
set pagesize 0
set verify off
set echo off

create tablespace ${ORA_TABLESPACE} datafile size 100m autoextend on next 50m maxsize unlimited;
create user ${ORA_USER} identified by "${ORA_PASSWD}" default tablespace ${ORA_TABLESPACE};
grant connect,resource,dba to ${ORA_USER};

exit
PWUNLI
EOF
}
echo -e "\n\e[1;36mTablespace creation completed \e[0m"
ora_Cnamescpace


#!/bin/bash


source /etc/locale.conf
source /tmp/setenv.sh

# 创建目录
makedir(){
mkdir -p ${ORACLE_BASE}  ${ORACLE_HOME} ${ORACLE_VENT}
chown -R oracle:oinstall ${ORACLE_BASE} ${ORACLE_HOME} ${ORACLE_VENT} ${ORACLE_PATH}
}

#解压
unpackage(){
if [[ -f ${ORACLE_SOFT_PATH}/${ORACLE_SOFT_NAME}  ]];then
	echo -e "\n\e[1;33mUnzipping the Oracle database installation package... \e[0m"
	unzip -qd ${ORACLE_HOME} ${ORACLE_SOFT_PATH}/${ORACLE_SOFT_NAME} 
	chown -R oracle:oinstall ${ORACLE_BASE}
else
	echo -e "\n\e[1;31mThe installation package does not exist, exit the installation. \e[0m"
fi
}

#安装数据库软件
install_oracle_soft(){

su - oracle <<EOF
source /home/oracle/.bash_profile
echo -e "\n\e[1;33mPerforming silent installation... \e[0m"
echo ""
${ORACLE_HOME}/runInstaller -ignorePrereqFailure -silent \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
SELECTED_LANGUAGES=en,zh_CN \
INVENTORY_LOCATION=${ORACLE_VENT} \
ORACLE_HOME=${ORACLE_HOME} \
ORACLE_BASE=${ORACLE_BASE} \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=oper \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
oracle.install.db.config.starterdb.installExampleSchemas=false \
oracle.install.db.rootconfig.executeRootScript=false

EOF
}

makedir
unpackage
install_oracle_soft
${ORACLE_VENT}/orainstRoot.sh
${ORACLE_HOME}/root.sh
echo -e "\n\e[1;36m  Database software installation completed！ \e[0m"
echo ""

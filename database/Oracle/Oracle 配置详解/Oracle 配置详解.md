#oracle

## 1. 客户端字符集配置

NLS_LANG这个参数由三个组成部分，分别是【语言\_区域.字符集】

```bash
# 数据库字符集如果使用ZHS16GBK
# 则：
### windows添加环境变量
NLS_LANG SIMPLIFIED CHINESE_CHINA.ZHS16GBK

### linux配置   
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"    # 终端字符集使用utf-8
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".ZHS16GBK  # 终端字符集使用gbk

# 数据库字符集如果使用AL32UTF8
### linux配置   
export NLS_LANG="AMERICAN_AMERICA.AL32UTF8"    # 终端字符集使用utf-8
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".AL32UTF8# 终端字符集使用gbk

```

## <span id="20231110105237-1aq8824" style="display: none;"></span>2. [listener.ora 详解](listener.ora%20详解.md)

文件位置：`$ORACLE_HOME/network/admin`​

## <span id="20231110105237-x105gp1" style="display: none;"></span>3. [tnsnames.ora 详解](tnsnames.ora%20详解.md)

文件位置：`$ORACLE_HOME/network/admin`​

## 4. [sqlnet.ora 详解](sqlnet.ora%20详解.md)

文件位置：`$ORACLE_HOME/network/admin`​

## <span id="20231110105237-edzdbuk" style="display: none;"></span>5. db_install.rsp参数

```bash
####################################################################
## Copyright(c) Oracle Corporation 1998,2019. All rights reserved.##
##                                                                ##
## Specify values for the variables listed below to customize     ##
## your installation.                                             ##
##                                                                ##
## Each variable is associated with a comment. The comment        ##
## can help to populate the variables with the appropriate        ##
## values.                                                        ##
##                                                                ##
## IMPORTANT NOTE: This file contains plain text passwords and    ##
## should be secured to have read permission only by oracle user  ##
## or db administrator who owns this installation.                ##
##                                                                ##
####################################################################


#------------------------------------------------------------------------------
# Do not change the following system generated value. 
#------------------------------------------------------------------------------
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0

#-------------------------------------------------------------------------------
# Specify the installation option.
# It can be one of the following:
#   - INSTALL_DB_SWONLY
#   - INSTALL_DB_AND_CONFIG
#-------------------------------------------------------------------------------
oracle.install.option=

#-------------------------------------------------------------------------------
# Specify the Unix group to be set for the inventory directory.  
#-------------------------------------------------------------------------------
UNIX_GROUP_NAME=

#-------------------------------------------------------------------------------
# Specify the location which holds the inventory files.
# This is an optional parameter if installing on
# Windows based Operating System.
#-------------------------------------------------------------------------------
INVENTORY_LOCATION=
#-------------------------------------------------------------------------------
# Specify the complete path of the Oracle Home. 
#-------------------------------------------------------------------------------
ORACLE_HOME=

#-------------------------------------------------------------------------------
# Specify the complete path of the Oracle Base. 
#-------------------------------------------------------------------------------
ORACLE_BASE=

#-------------------------------------------------------------------------------
# Specify the installation edition of the component.                   
#                                                           
# The value should contain only one of these choices.  
#   - EE     : Enterprise Edition 
#   - SE2     : Standard Edition 2


#-------------------------------------------------------------------------------

oracle.install.db.InstallEdition=
###############################################################################
#                                                                             #
# PRIVILEGED OPERATING SYSTEM GROUPS                                          #
# ------------------------------------------                                  #
# Provide values for the OS groups to which SYSDBA and SYSOPER privileges     #
# needs to be granted. If the install is being performed as a member of the   #
# group "dba", then that will be used unless specified otherwise below.       #
#                                                                             #
# The value to be specified for OSDBA and OSOPER group is only for UNIX based #
# Operating System.                                                           #
#                                                                             #
###############################################################################

#------------------------------------------------------------------------------
# The OSDBA_GROUP is the OS group which is to be granted SYSDBA privileges.
#-------------------------------------------------------------------------------
oracle.install.db.OSDBA_GROUP=

#------------------------------------------------------------------------------
# The OSOPER_GROUP is the OS group which is to be granted SYSOPER privileges.
# The value to be specified for OSOPER group is optional.
#------------------------------------------------------------------------------
oracle.install.db.OSOPER_GROUP=

#------------------------------------------------------------------------------
# The OSBACKUPDBA_GROUP is the OS group which is to be granted SYSBACKUP privileges.
#------------------------------------------------------------------------------
oracle.install.db.OSBACKUPDBA_GROUP=

#------------------------------------------------------------------------------
# The OSDGDBA_GROUP is the OS group which is to be granted SYSDG privileges.
#------------------------------------------------------------------------------
oracle.install.db.OSDGDBA_GROUP=

#------------------------------------------------------------------------------
# The OSKMDBA_GROUP is the OS group which is to be granted SYSKM privileges.
#------------------------------------------------------------------------------
oracle.install.db.OSKMDBA_GROUP=

#------------------------------------------------------------------------------
# The OSRACDBA_GROUP is the OS group which is to be granted SYSRAC privileges.
#------------------------------------------------------------------------------
oracle.install.db.OSRACDBA_GROUP=
################################################################################
#                                                                              #
#                      Root script execution configuration                     #
#                                                                              #
################################################################################

#-------------------------------------------------------------------------------------------------------
# Specify the root script execution mode.
#
#   - true  : To execute the root script automatically by using the appropriate configuration methods.
#   - false : To execute the root script manually.
#
# If this option is selected, password should be specified on the console.
#-------------------------------------------------------------------------------------------------------
oracle.install.db.rootconfig.executeRootScript=

#--------------------------------------------------------------------------------------
# Specify the configuration method to be used for automatic root script execution.
#
# Following are the possible choices:
#   - ROOT
#   - SUDO
#--------------------------------------------------------------------------------------
oracle.install.db.rootconfig.configMethod=
#--------------------------------------------------------------------------------------
# Specify the absolute path of the sudo program.
#
# Applicable only when SUDO configuration method was chosen.
#--------------------------------------------------------------------------------------
oracle.install.db.rootconfig.sudoPath=

#--------------------------------------------------------------------------------------
# Specify the name of the user who is in the sudoers list. 
# Applicable only when SUDO configuration method was chosen.
# Note:For Single Instance database installations,the sudo user name must be the username of the user installing the database.
#--------------------------------------------------------------------------------------
oracle.install.db.rootconfig.sudoUserName=

###############################################################################
#                                                                             #
#                               Grid Options                                  #
#                                                                             #
###############################################################################

#------------------------------------------------------------------------------
# Value is required only if the specified install option is INSTALL_DB_SWONLY
# 
# Specify the cluster node names selected during the installation.
# 
# Example : oracle.install.db.CLUSTER_NODES=node1,node2
#------------------------------------------------------------------------------
oracle.install.db.CLUSTER_NODES=

###############################################################################
#                                                                             #
#                        Database Configuration Options                       #
#                                                                             #
###############################################################################

#-------------------------------------------------------------------------------
# Specify the type of database to create.
# It can be one of the following:
#   - GENERAL_PURPOSE                     
#   - DATA_WAREHOUSE 
# GENERAL_PURPOSE: A starter database designed for general purpose use or transaction-heavy applications.
# DATA_WAREHOUSE : A starter database optimized for data warehousing applications.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.type=

#-------------------------------------------------------------------------------
# Specify the Starter Database Global Database Name. 
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.globalDBName=

#-------------------------------------------------------------------------------
# Specify the Starter Database SID.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.SID=

#-------------------------------------------------------------------------------
# Specify whether the database should be configured as a Container database.
# The value can be either "true" or "false". If left blank it will be assumed
# to be "false".
#-------------------------------------------------------------------------------
oracle.install.db.ConfigureAsContainerDB=

#-------------------------------------------------------------------------------
# Specify the  Pluggable Database name for the pluggable database in Container Database.
#-------------------------------------------------------------------------------
oracle.install.db.config.PDBName=

#-------------------------------------------------------------------------------
# Specify the Starter Database character set.
#                                             
#  One of the following
#  AL32UTF8, WE8ISO8859P15, WE8MSWIN1252, EE8ISO8859P2,
#  EE8MSWIN1250, NE8ISO8859P10, NEE8ISO8859P4, BLT8MSWIN1257,
#  BLT8ISO8859P13, CL8ISO8859P5, CL8MSWIN1251, AR8ISO8859P6,
#  AR8MSWIN1256, EL8ISO8859P7, EL8MSWIN1253, IW8ISO8859P8,
#  IW8MSWIN1255, JA16EUC, JA16EUCTILDE, JA16SJIS, JA16SJISTILDE,
#  KO16MSWIN949, ZHS16GBK, TH8TISASCII, ZHT32EUC, ZHT16MSWIN950,
#  ZHT16HKSCS, WE8ISO8859P9, TR8MSWIN1254, VN8MSWIN1258
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.characterSet=

#------------------------------------------------------------------------------
# This variable should be set to true if Automatic Memory Management 
# in Database is desired.
# If Automatic Memory Management is not desired, and memory allocation
# is to be done manually, then set it to false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryOption=

#-------------------------------------------------------------------------------
# Specify the total memory allocation for the database. Value(in MB) should be
# at least 256 MB, and should not exceed the total physical memory available 
# on the system.
# Example: oracle.install.db.config.starterdb.memoryLimit=512
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryLimit=

#-------------------------------------------------------------------------------
# This variable controls whether to load Example Schemas onto
# the starter database or not.
# The value can be either "true" or "false". If left blank it will be assumed
# to be "false".
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.installExampleSchemas=

###############################################################################
#                                                                             #
# Passwords can be supplied for the following four schemas in the	      #
# starter database:      						      #
#   SYS                                                                       #
#   SYSTEM                                                                    #
#   DBSNMP (used by Enterprise Manager)                                       #
#                                                                             #
# Same password can be used for all accounts (not recommended) 		      #
# or different passwords for each account can be provided (recommended)       #
#                                                                             #
###############################################################################

#------------------------------------------------------------------------------
# This variable holds the password that is to be used for all schemas in the
# starter database.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.ALL=

#-------------------------------------------------------------------------------
# Specify the SYS password for the starter database.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.SYS=

#-------------------------------------------------------------------------------
# Specify the SYSTEM password for the starter database.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.SYSTEM=

#-------------------------------------------------------------------------------
# Specify the DBSNMP password for the starter database.
# Applicable only when oracle.install.db.config.starterdb.managementOption=CLOUD_CONTROL
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.DBSNMP=

#-------------------------------------------------------------------------------
# Specify the PDBADMIN password required for creation of Pluggable Database in the Container Database.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.PDBADMIN=

#-------------------------------------------------------------------------------
# Specify the management option to use for managing the database.
# Options are:
# 1. CLOUD_CONTROL - If you want to manage your database with Enterprise Manager Cloud Control along with Database Express.
# 2. DEFAULT   -If you want to manage your database using the default Database Express option.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.managementOption=

#-------------------------------------------------------------------------------
# Specify the OMS host to connect to Cloud Control.
# Applicable only when oracle.install.db.config.starterdb.managementOption=CLOUD_CONTROL
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.omsHost=

#-------------------------------------------------------------------------------
# Specify the OMS port to connect to Cloud Control.
# Applicable only when oracle.install.db.config.starterdb.managementOption=CLOUD_CONTROL
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.omsPort=

#-------------------------------------------------------------------------------
# Specify the EM Admin user name to use to connect to Cloud Control.
# Applicable only when oracle.install.db.config.starterdb.managementOption=CLOUD_CONTROL
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.emAdminUser=

#-------------------------------------------------------------------------------
# Specify the EM Admin password to use to connect to Cloud Control.
# Applicable only when oracle.install.db.config.starterdb.managementOption=CLOUD_CONTROL
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.emAdminPassword=

###############################################################################
#                                                                             #
# SPECIFY RECOVERY OPTIONS                                 	              #
# ------------------------------------		                              #
# Recovery options for the database can be mentioned using the entries below  #
#                                                                             #
###############################################################################

#------------------------------------------------------------------------------
# This variable is to be set to false if database recovery is not required. Else 
# this can be set to true.
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.enableRecovery=

#-------------------------------------------------------------------------------
# Specify the type of storage to use for the database.
# It can be one of the following:
#   - FILE_SYSTEM_STORAGE
#   - ASM_STORAGE
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.storageType=

#-------------------------------------------------------------------------------
# Specify the database file location which is a directory for datafiles, control
# files, redo logs.       
#
# Applicable only when oracle.install.db.config.starterdb.storage=FILE_SYSTEM_STORAGE 
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=

#-------------------------------------------------------------------------------
# Specify the recovery location.
#
# Applicable only when oracle.install.db.config.starterdb.storage=FILE_SYSTEM_STORAGE 
#-------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=

#-------------------------------------------------------------------------------
# Specify the existing ASM disk groups to be used for storage.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=ASM_STORAGE
#-------------------------------------------------------------------------------
oracle.install.db.config.asm.diskGroup=

#-------------------------------------------------------------------------------
# Specify the password for ASMSNMP user of the ASM instance.               
#
# Applicable only when oracle.install.db.config.starterdb.storage=ASM_STORAGE 
#-------------------------------------------------------------------------------
oracle.install.db.config.asm.ASMSNMPPassword=

```

## <span id="20231110105237-1aczygr" style="display: none;"></span>6. dbca.rsp参数

```bash
##############################################################################
##                                                                          ##
##                            DBCA response file                            ##
##                            ------------------                            ##
## Copyright(c) Oracle Corporation 1998,2019. All rights reserved.         ##
##                                                                          ##
## Specify values for the variables listed below to customize 			    ##
## your installation.                                         			    ##
##                                                            			    ##
## Each variable is associated with a comment. The comment    			    ##
## can help to populate the variables with the appropriate   			    ##
## values.                                                  			    ##
##                                                               			##
## IMPORTANT NOTE: This file contains plain text passwords and   			##
## should be secured to have read permission only by oracle user 			##
## or db administrator who owns this installation.               			##
##############################################################################
#-------------------------------------------------------------------------------
# Do not change the following system generated value. 
#-------------------------------------------------------------------------------
responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v19.0.0

#-----------------------------------------------------------------------------
# Name          : gdbName
# Datatype      : String
# Description   : Global database name of the database
# Valid values  : <db_name>.<db_domain> - when database domain isn't NULL
#                 <db_name>             - when database domain is NULL
# Default value : None
# Mandatory     : Yes
#-----------------------------------------------------------------------------
gdbName=

#-----------------------------------------------------------------------------
# Name          : sid
# Datatype      : String
# Description   : System identifier (SID) of the database
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : <db_name> specified in GDBNAME
# Mandatory     : No
#-----------------------------------------------------------------------------
sid=

#-----------------------------------------------------------------------------
# Name          : databaseConfigType
# Datatype      : String
# Description   : database conf type as Single Instance, Real Application Cluster or Real Application Cluster One Nodes database
# Valid values  : SI\RAC\RACONENODE
# Default value : SI
# Mandatory     : No
#-----------------------------------------------------------------------------
databaseConfigType=

#-----------------------------------------------------------------------------
# Name          : RACOneNodeServiceName
# Datatype      : String
# Description   : Service is required by application to connect to RAC One 
#		  Node Database
# Valid values  : Service Name
# Default value : None
# Mandatory     : No [required in case DATABASECONFTYPE is set to RACONENODE ]
#-----------------------------------------------------------------------------
RACOneNodeServiceName=

#-----------------------------------------------------------------------------
# Name          : policyManaged
# Datatype      : Boolean
# Description   : Set to true if Database is policy managed and 
#		  set to false if  Database is admin managed
# Valid values  : TRUE\FALSE
# Default value : FALSE
# Mandatory     : No
#-----------------------------------------------------------------------------
policyManaged=


#-----------------------------------------------------------------------------
# Name          : createServerPool
# Datatype      : Boolean
# Description   : Set to true if new server pool need to be created for database 
#		  if this option is specified then the newly created database 
#		  will use this newly created serverpool. 
#		  Multiple serverpoolname can not be specified for database
# Valid values  : TRUE\FALSE
# Default value : FALSE
# Mandatory     : No
#-----------------------------------------------------------------------------
createServerPool=

#-----------------------------------------------------------------------------
# Name          : serverPoolName
# Datatype      : String
# Description   : Only one serverpool name need to be specified 
#		   if Create Server Pool option is specified. 
#		   Comma-separated list of Serverpool names if db need to use
#		   multiple Server pool
# Valid values  : ServerPool name

# Default value : None
# Mandatory     : No [required in case of RAC service centric database]
#-----------------------------------------------------------------------------
serverPoolName=

#-----------------------------------------------------------------------------
# Name          : cardinality
# Datatype      : Number
# Description   : Specify Cardinality for create server pool operation

# Valid values  : any positive Integer value
# Default value : Number of qualified nodes on cluster
# Mandatory     : No [Required when a new serverpool need to be created]
#-----------------------------------------------------------------------------
cardinality=

#-----------------------------------------------------------------------------
# Name          : force
# Datatype      : Boolean
# Description   : Set to true if new server pool need to be created by force 
#		  if this option is specified then the newly created serverpool
#		  will be assigned server even if no free servers are available.
#		  This may affect already running database.
#		  This flag can be specified for Admin managed as well as policy managed db.
# Valid values  : TRUE\FALSE
# Default value : FALSE
# Mandatory     : No
#-----------------------------------------------------------------------------
force=

#-----------------------------------------------------------------------------
# Name          : pqPoolName
# Datatype      : String
# Description   : Only one serverpool name needs to be specified 
#		   if create server pool option is specified. 
#		   Comma-separated list of serverpool names if use
#		   server pool. This is required to 
#                  create Parallel Query (PQ) database. Applicable to Big Cluster
# Valid values  :  Parallel Query (PQ) pool name
# Default value : None
# Mandatory     : No [required in case of RAC service centric database]
#-----------------------------------------------------------------------------
pqPoolName=

#-----------------------------------------------------------------------------
# Name          : pqCardinality
# Datatype      : Number
# Description   : Specify Cardinality for create server pool operation.
#                 Applicable to Big Cluster 
# Valid values  : any positive Integer value
# Default value : Number of qualified nodes on cluster
# Mandatory     : No [Required when a new serverpool need to be created]
#-----------------------------------------------------------------------------
pqCardinality=

#-----------------------------------------------------------------------------
# Name          : createAsContainerDatabase 
# Datatype      : boolean
# Description   : flag to create database as container database 
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : false
# Mandatory     : No
#-----------------------------------------------------------------------------
createAsContainerDatabase=

#-----------------------------------------------------------------------------
# Name          : numberOfPDBs
# Datatype      : Number
# Description   : Specify the number of pdb to be created
# Valid values  : 0 to 4094
# Default value : 0
# Mandatory     : No
#-----------------------------------------------------------------------------
numberOfPDBs=

#-----------------------------------------------------------------------------
# Name          : pdbName 
# Datatype      : String
# Description   : Specify the pdbname/pdbanme prefix if one or more pdb need to be created
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------
pdbName=

#-----------------------------------------------------------------------------
# Name          : useLocalUndoForPDBs 
# Datatype      : boolean
# Description   : Flag to create local undo tablespace for all PDB's.
# Valid values  : TRUE\FALSE
# Default value : TRUE
# Mandatory     : No
#-----------------------------------------------------------------------------
useLocalUndoForPDBs=

#-----------------------------------------------------------------------------
# Name          : pdbAdminPassword
# Datatype      : String
# Description   : PDB Administrator user password
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------

pdbAdminPassword=

#-----------------------------------------------------------------------------
# Name          : nodelist
# Datatype      : String
# Description   : Comma-separated list of cluster nodes
# Valid values  : Cluster node names
# Default value : None
# Mandatory     : No (Yes for RAC database-centric database )
#-----------------------------------------------------------------------------
nodelist=

#-----------------------------------------------------------------------------
# Name          : templateName
# Datatype      : String
# Description   : Name of the template
# Valid values  : Template file name
# Default value : None
# Mandatory     : Yes
#-----------------------------------------------------------------------------
templateName=

#-----------------------------------------------------------------------------
# Name          : sysPassword
# Datatype      : String
# Description   : Password for SYS user
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : Yes
#-----------------------------------------------------------------------------
sysPassword=

#-----------------------------------------------------------------------------
# Name          : systemPassword
# Datatype      : String
# Description   : Password for SYSTEM user
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : Yes
#-----------------------------------------------------------------------------
systemPassword= 

#-----------------------------------------------------------------------------
# Name          : oracleHomeUserPassword
# Datatype      : String
# Description   : Password for Windows Service user
# Default value : None
# Mandatory     : If Oracle home is installed with windows service user
#-----------------------------------------------------------------------------
oracleHomeUserPassword=

#-----------------------------------------------------------------------------
# Name          : emConfiguration
# Datatype      : String
# Description   : Enterprise Manager Configuration Type
# Valid values  : CENTRAL|DBEXPRESS|BOTH|NONE
# Default value : NONE
# Mandatory     : No
#-----------------------------------------------------------------------------
emConfiguration=

#-----------------------------------------------------------------------------
# Name          : emExpressPort
# Datatype      : Number
# Description   : Enterprise Manager Configuration Type
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : NONE
# Mandatory     : No, will be picked up from DBEXPRESS_HTTPS_PORT env variable
#                 or auto generates a free port between 5500 and 5599
#-----------------------------------------------------------------------------
emExpressPort=5500

#-----------------------------------------------------------------------------
# Name          : runCVUChecks
# Datatype      : Boolean
# Description   : Specify whether to run Cluster Verification Utility checks
#                 periodically in Cluster environment
# Valid values  : TRUE\FALSE
# Default value : FALSE
# Mandatory     : No
#-----------------------------------------------------------------------------
runCVUChecks=

#-----------------------------------------------------------------------------
# Name          : dbsnmpPassword
# Datatype      : String
# Description   : Password for DBSNMP user
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : Yes, if emConfiguration is specified or
#                 the value of runCVUChecks is TRUE
#-----------------------------------------------------------------------------
dbsnmpPassword=

#-----------------------------------------------------------------------------
# Name          : omsHost
# Datatype      : String
# Description   : EM management server host name
# Default value : None
# Mandatory     : Yes, if CENTRAL is specified for emConfiguration
#-----------------------------------------------------------------------------
omsHost=

#-----------------------------------------------------------------------------
# Name          : omsPort
# Datatype      : Number
# Description   : EM management server port number
# Default value : None
# Mandatory     : Yes, if CENTRAL is specified for emConfiguration
#-----------------------------------------------------------------------------
omsPort=

#-----------------------------------------------------------------------------
# Name          : emUser
# Datatype      : String
# Description   : EM Admin username to add or modify targets
# Default value : None
# Mandatory     : Yes, if CENTRAL is specified for emConfiguration
#-----------------------------------------------------------------------------
emUser=

#-----------------------------------------------------------------------------
# Name          : emPassword
# Datatype      : String
# Description   : EM Admin user password
# Default value : None
# Mandatory     : Yes, if CENTRAL is specified for emConfiguration
#-----------------------------------------------------------------------------
emPassword=

#-----------------------------------------------------------------------------
# Name          : dvConfiguration
# Datatype      : Boolean
# Description   : Specify "True" to configure and enable Oracle Database vault
# Valid values  : True/False
# Default value : False
# Mandatory     : No
#-----------------------------------------------------------------------------
dvConfiguration=

#-----------------------------------------------------------------------------
# Name          : dvUserName
# Datatype      : String
# Description   : DataVault Owner
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : Yes, if DataVault option is chosen
#-----------------------------------------------------------------------------
dvUserName=

#-----------------------------------------------------------------------------
# Name          : dvUserPassword
# Datatype      : String
# Description   : Password for DataVault Owner
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : Yes, if DataVault option is chosen
#-----------------------------------------------------------------------------
dvUserPassword=

#-----------------------------------------------------------------------------
# Name          : dvAccountManagerName
# Datatype      : String
# Description   : DataVault Account Manager
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------
dvAccountManagerName=

#-----------------------------------------------------------------------------
# Name          : dvAccountManagerPassword
# Datatype      : String
# Description   : Password for  DataVault Account Manager
# Valid values  : Check Oracle19c Administrator's Guide
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------
dvAccountManagerPassword=

#-----------------------------------------------------------------------------
# Name          : olsConfiguration
# Datatype      : Boolean
# Description   : Specify "True" to configure and enable Oracle Label Security
# Valid values  : True/False
# Default value : False
# Mandatory     : No
#-----------------------------------------------------------------------------
olsConfiguration=

#-----------------------------------------------------------------------------
# Name          : datafileJarLocation 
# Datatype      : String
# Description   : Location of the data file jar 
# Valid values  : Directory containing compressed datafile jar
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------
datafileJarLocation=

#-----------------------------------------------------------------------------
# Name          : datafileDestination 
# Datatype      : String
# Description   : Location of the data file's
# Valid values  : Directory for all the database files
# Default value : $ORACLE_BASE/oradata
# Mandatory     : No
#-----------------------------------------------------------------------------
datafileDestination=

#-----------------------------------------------------------------------------
# Name          : recoveryAreaDestination
# Datatype      : String
# Description   : Location of the data file's
# Valid values  : Recovery Area location
# Default value : $ORACLE_BASE/flash_recovery_area
# Mandatory     : No
#-----------------------------------------------------------------------------
recoveryAreaDestination=

#-----------------------------------------------------------------------------
# Name          : storageType
# Datatype      : String
# Description   : Specifies the storage on which the database is to be created
# Valid values  : FS (CFS for RAC), ASM
# Default value : FS
# Mandatory     : No
#-----------------------------------------------------------------------------
storageType=

#-----------------------------------------------------------------------------
# Name          : diskGroupName
# Datatype      : String
# Description   : Specifies the disk group name for the storage
# Default value : DATA
# Mandatory     : No
#-----------------------------------------------------------------------------
diskGroupName=

#-----------------------------------------------------------------------------
# Name          : asmsnmpPassword
# Datatype      : String
# Description   : Password for ASM Monitoring
# Default value : None
# Mandatory     : No
#-----------------------------------------------------------------------------
asmsnmpPassword=

#-----------------------------------------------------------------------------
# Name          : recoveryGroupName
# Datatype      : String
# Description   : Specifies the disk group name for the recovery area
# Default value : RECOVERY
# Mandatory     : No
#-----------------------------------------------------------------------------
recoveryGroupName=

#-----------------------------------------------------------------------------
# Name          : characterSet
# Datatype      : String
# Description   : Character set of the database
# Valid values  : Check Oracle19c National Language Support Guide
# Default value : "US7ASCII"
# Mandatory     : NO
#-----------------------------------------------------------------------------
characterSet=

#-----------------------------------------------------------------------------
# Name          : nationalCharacterSet
# Datatype      : String
# Description   : National Character set of the database
# Valid values  : "UTF8" or "AL16UTF16". For details, check Oracle19c National Language Support Guide
# Default value : "AL16UTF16"
# Mandatory     : No
#-----------------------------------------------------------------------------
nationalCharacterSet=

#-----------------------------------------------------------------------------
# Name          : registerWithDirService
# Datatype      : Boolean
# Description   : Specifies whether to register with Directory Service.
# Valid values  : TRUE \ FALSE
# Default value : FALSE
# Mandatory     : No
#-----------------------------------------------------------------------------
registerWithDirService=


#-----------------------------------------------------------------------------
# Name          : dirServiceUserName
# Datatype      : String
# Description   : Specifies the name of the directory service user
# Mandatory     : YES, if the value of registerWithDirService is TRUE
#-----------------------------------------------------------------------------
dirServiceUserName=

#-----------------------------------------------------------------------------
# Name          : dirServicePassword
# Datatype      : String
# Description   : The password of the directory service user.
#		  You can also specify the password at the command prompt instead of here.
# Mandatory     : YES, if the value of registerWithDirService is TRUE
#-----------------------------------------------------------------------------
dirServicePassword=

#-----------------------------------------------------------------------------
# Name          : walletPassword
# Datatype      : String
# Description   : The password for wallet to created or modified.
#		  You can also specify the password at the command prompt instead of here.
# Mandatory     : YES, if the value of registerWithDirService is TRUE
#-----------------------------------------------------------------------------
walletPassword=

#-----------------------------------------------------------------------------
# Name          : listeners
# Datatype      : String
# Description   : Specifies list of listeners to register the database with.
#		  By default the database is configured for all the listeners specified in the 
#		  $ORACLE_HOME/network/admin/listener.ora 
# Valid values  : The list should be comma separated like "listener1,listener2".
# Mandatory     : NO
#-----------------------------------------------------------------------------
listeners=

#-----------------------------------------------------------------------------
# Name          : variablesFile 
# Datatype      : String
# Description   : Location of the file containing variable value pair
# Valid values  : A valid file-system file. The variable value pair format in this file 
#		  is <variable>=<value>. Each pair should be in a new line.
# Default value : None
# Mandatory     : NO
#-----------------------------------------------------------------------------
variablesFile=

#-----------------------------------------------------------------------------
# Name          : variables
# Datatype      : String
# Description   : comma separated list of name=value pairs. Overrides variables defined in variablefile and templates
# Default value : None
# Mandatory     : NO
#-----------------------------------------------------------------------------
variables=

#-----------------------------------------------------------------------------
# Name          : initParams
# Datatype      : String
# Description   : comma separated list of name=value pairs. Overrides initialization parameters defined in templates
# Default value : None
# Mandatory     : NO
#-----------------------------------------------------------------------------
initParams=

#-----------------------------------------------------------------------------
# Name          : sampleSchema
# Datatype      : Boolean
# Description   : Specifies whether or not to add the Sample Schemas to your database
# Valid values  : TRUE \ FALSE
# Default value : FASLE
# Mandatory     : No
#-----------------------------------------------------------------------------
sampleSchema=

#-----------------------------------------------------------------------------
# Name          : memoryPercentage
# Datatype      : String
# Description   : percentage of physical memory for Oracle
# Default value : None
# Mandatory     : NO
#-----------------------------------------------------------------------------
memoryPercentage=

#-----------------------------------------------------------------------------
# Name          : databaseType
# Datatype      : String
# Description   : used for memory distribution when memoryPercentage specified
# Valid values  : MULTIPURPOSE|DATA_WAREHOUSING|OLTP
# Default value : MULTIPURPOSE
# Mandatory     : NO
#-----------------------------------------------------------------------------
databaseType=

#-----------------------------------------------------------------------------
# Name          : automaticMemoryManagement
# Datatype      : Boolean
# Description   : flag to indicate Automatic Memory Management is used
# Valid values  : TRUE/FALSE
# Default value : TRUE
# Mandatory     : NO
#-----------------------------------------------------------------------------
automaticMemoryManagement=

#-----------------------------------------------------------------------------
# Name          : totalMemory
# Datatype      : String
# Description   : total memory in MB to allocate to Oracle
# Valid values  : 
# Default value : 
# Mandatory     : NO
#-----------------------------------------------------------------------------
totalMemory=

```

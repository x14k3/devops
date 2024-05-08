# tuxedo部署

## 安装jdk 

## 下载tuxedo

## 准备安装

安装包地址:[https://www.oracle.com/middleware/technologies/tuxedo-downloads.html](https://www.oracle.com/middleware/technologies/tuxedo-downloads.html)  
安装用户：`tuxedo`​  
安装目录：`/home/tuxedo`​

```bash
# 创建用户
useradd tuxedo
echo "Ninestar123" | passwd --stdin tuxedo
#安装所需依赖
yum install libnsl unzip -y
#上传安装包
cd /home/tuxedo
chown -R tuxedo:tuxedo /home/tuxedo
chmod 777 tuxedo12110_64_linux_5_x86.bin 
```

‍

下面介绍tuxedo安装的三种方式：  
 静默安装、命令行窗口安装、图形界面安装，可根据实际场景使用合适的方式安装。

## 静默安装

以下部分请使用普通用户进行执行，请勿在 root 用户下进行执行。

```bash
su - tuxedo
# 创建安装文件,设定FULL安装，不需要LDAP
vi /home/tuxedo/installer.properties
----------------------------------------------
INSTALLER_UI=silent
USER_LOCAL=en
ORACLEHOME=/home/tuxedo
USER_INSTALL_DIR=/home/tuxedo/tuxedo12gR1
TLISTEN_PASSWORD=1234qwer
CHOSEN_INSTALL_SET=Full
INSTALL_SAMPLES=No

# 以tuxedo用户运行安装程序
/home/tuxedo/tuxedo12110_64_linux_5_x86.bin  -f /home/tuxedo/installer.properties

Preparing to install...
Extracting the JRE from the installer archive...
Unpacking the JRE...
Extracting the installation resources from the installer archive...
Configuring the installer for this system's environment...
strings: '/lib/libc.so.6': No such file
Launching installer...

Preparing SILENT Mode Installation...

============================================================================
Tuxedo 11.1.1.2.0                 (created with InstallAnywhere by Macrovision)
-------------------------------------------------------------------------------
============================================================================
Installing...
-------------
 [==================|==================|==================|==================]
 [------------------|------------------|------------------|------------------]
Installation Complete.

```

‍

## 命令行窗口安装

```bash

su - tuxedo
/home/tuxedo/tuxedo12110_64_linux_5_x86.bin -i console

Choose Locale...
----------------
  ->1- English
CHOOSE LOCALE BY NUMBER: 1
Choose Install Set
------------------
Please choose the Install Set to be installed by this installer.
  ->1- Full Install
    2- Server Install
    3- Full Client Install
    4- Jolt Client Install
    5- ATMI Client Install
    6- CORBA Client Install
    7- Customize...
ENTER THE NUMBER FOR THE INSTALL SET, OR PRESS <ENTER> TO ACCEPT THE DEFAULT : 1
Choose Oracle Home
------------------
    1- Create new Oracle Home
    2- Use existing Oracle Home
Enter a number: 1
Specify a new Oracle Home directory: /u01/tuxedo
Choose Product Directory
------------------------
    1- Modify Current Selection (/u01/tuxedo/tuxedo11gR1)
    2- Use Current Selection (/u01/tuxedo/tuxedo11gR1)

Enter a number: 2
Install Samples (Y/N): n
Would you like to install SSL Support?
  ->1- Yes
    2- No
ENTER THE NUMBER FOR YOUR CHOICE, OR PRESS <ENTER> TO ACCEPT THE DEFAULT:  2  

```

‍

## 图形界面安装

```bash
su - tuxedo
/home/tuxedo/tuxedo12110_64_linux_5_x86.bin
```

‍

‍

## Tuxedo 12c 演示

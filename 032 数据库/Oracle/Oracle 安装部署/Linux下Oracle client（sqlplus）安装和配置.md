# Linux下Oracle client（sqlplus）安装和配置

#### 1、下载rpm包

　　[https://www.oracle.com/hk/database/technologies/instant-client/linux-x86-64-downloads.html](https://www.oracle.com/hk/database/technologies/instant-client/linux-x86-64-downloads.html)      (搜索：Oracle Instant Client Downloads for Linux x86-64 (64-bit))

```
[root@node1 ~]# ls
oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm  
oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm  
oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm  
...
```

#### 2、安装

```
[root@node1 ~]# rpm -ivh oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
   1:oracle-instantclient11.2-basic-11################################# [100%]
[root@node1 ~]# rpm -ivh oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
   1:oracle-instantclient11.2-sqlplus-################################# [100%]
[root@node1 ~]# rpm -ivh oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
   1:oracle-instantclient11.2-devel-11################################# [100%]
[root@node1 ~]#
```

#### 3、配置

```
[root@node1 ~]# mkdir -p /usr/lib/oracle/11.2/client64/network/admin
```

```
[root@node1 ~]# vim /usr/lib/oracle/11.2/client64/network/admin/tnsnames.ora
```

```
[root@node1 ~]# cat /usr/lib/oracle/11.2/client64/network/admin/tnsnames.ora
TPADCTEST =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.81)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = TPADC)
    )
  )
[root@node1 ~]# 
```

```
[root@node1 ~]# vi ~/.bashrc
```

　　 增加几行

```
export  ORACLE_HOME=/usr/lib/oracle/11.2/client64
export  TNS_ADMIN=$ORACLE_HOME/network/admin
export  LD_LIBRARY_PATH=$ORACLE_HOME/lib 
export  PATH=$ORACLE_HOME/bin:$PATH
export  NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
```

```
[root@node1 ~]# source ~/.bashrc
```

#### 4、运行SQLPlus

```
[root@node1 ~]# sqlplus

SQL*Plus: Release 11.2.0.4.0 Production on Tue May 22 14:45:50 2018

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

Enter user-name: 
```

```
[root@node1 ~]# sqlplus test/test@//192.168.1.81:1521/TPADC

SQL*Plus: Release 11.2.0.4.0 Production on Tue May 22 14:46:21 2018

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL>
```

#### 5、Linux环境下Oracle SqlPlus中方向键问题的解决方法

　　 （1）问题

```
SQL> ^[[A^[[A^[[B 
```

　　 （2）下载rlwrap

```
wget https://mirrors.aliyun.com/epel/7/x86_64/Packages/r/rlwrap-0.45.2-2.el7.x86_64.rpm    # centos7.x
yum install readline-devel rlwrap-0.45.2-2.el7.x86_64.rpm

```

　　 （3）运行sqlplus

```
rlwrap sqlplus test/test@//192.168.1.81:1521/TPADC
```

```
alias sqlplus=’rlwrap sqlplus’ 
alias rman=’rlwrap rman
```

　　‍

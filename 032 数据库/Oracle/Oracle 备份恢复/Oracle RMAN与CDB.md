# Oracle RMAN与CDB

## 备份

### rman只备份cdb

只备份CDB数据库需要具有SYSDBA或SYSBACKUP权限用户连接到CDB的root环境下，执行backupdatabase root命令即可完成对CDB的备份，方法如下：

​`RMAN> backup database root;`​

注：执行backup database root不给数据文件保存位置时，备份文件默认存放在快速恢复区中。

```
[oracle@jydb1 ~]$ rman target /

恢复管理器: Release 12.2.0.1.0 - Production on 星期五 11月 9 14:52:04 2018

Copyright (c) 1982, 2017, Oracle and/or its affiliates.  All rights reserved.

已连接到目标数据库: ORCL (DBID=1508459345)

RMAN> backup database root;

从位于 09-11月-18 的 backup 开始
使用目标数据库控制文件替代恢复目录
分配的通道: ORA_DISK_1
通道 ORA_DISK_1: SID=91 实例 = racdb11 设备类型 = DISK
通道 ORA_DISK_1: 正在启动全部数据文件备份集
通道 ORA_DISK_1: 正在指定备份集内的数据文件
输入数据文件, 文件号 = 00007 名称 = +DATA/ORCL/DATAFILE/undotbs2.268.980678727
输入数据文件, 文件号 = 00005 名称 = +DATA/ORCL/DATAFILE/undotbs1.264.980678657
输入数据文件, 文件号 = 00003 名称 = +DATA/ORCL/DATAFILE/sysaux.262.980678649
输入数据文件, 文件号 = 00001 名称 = +DATA/ORCL/DATAFILE/system.260.980678629
输入数据文件, 文件号 = 00008 名称 = +DATA/ORCL/DATAFILE/users.269.980678729
通道 ORA_DISK_1: 正于 09-11月-18 启动段 1
通道 ORA_DISK_1: 完成了于 09-11月-18 启动段 1
片段句柄 = +FRA/ORCL/BACKUPSET/2018_11_09/nnndf0_tag20181109t145316_0.289.991752797 标记 = TAG20181109T145316 注释 = NONE
通道 ORA_DISK_1: 备份集完成, 用时: 00:01:36
在 09-11月-18 完成了 backup

从位于 09-11月-18 的 Control File and SPFILE Autobackup 开始
片段句柄 = +FRA/ORCL/AUTOBACKUP/2018_11_09/s_991752892.291.991752895 注释 = NONE
在 09-11月-18 完成了 Control File and SPFILE Autobackup
```

查看备份

​`RMAN> list backupset;`​

```bash
RMAN> list backupset;


备份集列表
===================


BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
10      Full    2.44G      DISK        00:01:28     09-11月-18
        BP 关键字: 10   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T145316
段名:+FRA/ORCL/BACKUPSET/2018_11_09/nnndf0_tag20181109t145316_0.289.991752797
  备份集 10 中的数据文件列表
  File LV Type Ckp SCN    Ckp 时间 Abs Fuz SCN Sparse Name
  ---- -- ---- ---------- ---------- ----------- ------ ----
  1       Full 14790568   09-11月-18              NO    +DATA/ORCL/DATAFILE/system.260.980678629
  3       Full 14790568   09-11月-18              NO    +DATA/ORCL/DATAFILE/sysaux.262.980678649
  5       Full 14790568   09-11月-18              NO    +DATA/ORCL/DATAFILE/undotbs1.264.980678657
  7       Full 14790568   09-11月-18              NO    +DATA/ORCL/DATAFILE/undotbs2.268.980678727
  8       Full 14790568   09-11月-18              NO    +DATA/ORCL/DATAFILE/users.269.980678729

BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
11      Full    19.09M     DISK        00:00:02     09-11月-18
        BP 关键字: 11   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T145452
段名:+FRA/ORCL/AUTOBACKUP/2018_11_09/s_991752892.291.991752895
  包含的 SPFILE: 修改时间: 09-11月-18
  SPFILE db_unique_name: ORCL
  包括的控制文件: Ckp SCN: 14790655     Ckp 时间: 09-11月-18
```

### rman备份cdb及所有pdb

备份整个CDB数据库及其下面的所有PDB类似于非CDB数据库方法相同，使用具有SYSDBA或SYSBACKUP权限用户连接到CDB的root环境下面，然后执行backupdatabase命令即可完成整个CDB的备份，方法如下：

​`RMAN> backup database;`​

```
RMAN> backup database;

从位于 09-11月-18 的 backup 开始
使用通道 ORA_DISK_1
通道 ORA_DISK_1: 正在启动全部数据文件备份集
通道 ORA_DISK_1: 正在指定备份集内的数据文件
输入数据文件, 文件号 = 00007 名称 = +DATA/ORCL/DATAFILE/undotbs2.268.980678727
输入数据文件, 文件号 = 00005 名称 = +DATA/ORCL/DATAFILE/undotbs1.264.980678657
输入数据文件, 文件号 = 00003 名称 = +DATA/ORCL/DATAFILE/sysaux.262.980678649
输入数据文件, 文件号 = 00001 名称 = +DATA/ORCL/DATAFILE/system.260.980678629
输入数据文件, 文件号 = 00008 名称 = +DATA/ORCL/DATAFILE/users.269.980678729
通道 ORA_DISK_1: 正于 09-11月-18 启动段 1
通道 ORA_DISK_1: 完成了于 09-11月-18 启动段 1
片段句柄 = +FRA/ORCL/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.291.991754787 标记 = TAG20181109T152625 注释 = NONE
通道 ORA_DISK_1: 备份集完成, 用时: 00:01:25
通道 ORA_DISK_1: 正在启动全部数据文件备份集
通道 ORA_DISK_1: 正在指定备份集内的数据文件
输入数据文件, 文件号 = 00011 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undotbs1.275.980687407
输入数据文件, 文件号 = 00010 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/sysaux.273.980687407
输入数据文件, 文件号 = 00009 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/system.274.980687407
输入数据文件, 文件号 = 00012 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undo_2.277.980687461
输入数据文件, 文件号 = 00013 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/users.278.980687465
通道 ORA_DISK_1: 正于 09-11月-18 启动段 1
通道 ORA_DISK_1: 完成了于 09-11月-18 启动段 1
片段句柄 = +FRA/ORCL/703A8F7652857A64E053600CA8C00EED/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.289.991754873 标记 = TAG20181109T152625 注释 = NONE
通道 ORA_DISK_1: 备份集完成, 用时: 00:00:35
通道 ORA_DISK_1: 正在启动全部数据文件备份集
通道 ORA_DISK_1: 正在指定备份集内的数据文件
输入数据文件, 文件号 = 00002 名称 = +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/system.261.980678637
输入数据文件, 文件号 = 00006 名称 = +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/undotbs1.265.980678659
输入数据文件, 文件号 = 00004 名称 = +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/sysaux.263.980678653
通道 ORA_DISK_1: 正于 09-11月-18 启动段 1
通道 ORA_DISK_1: 完成了于 09-11月-18 启动段 1
片段句柄 = +FRA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.337.991754909 标记 = TAG20181109T152625 注释 = NONE
通道 ORA_DISK_1: 备份集完成, 用时: 00:00:15
在 09-11月-18 完成了 backup

从位于 09-11月-18 的 Control File and SPFILE Autobackup 开始
片段句柄 = +FRA/ORCL/AUTOBACKUP/2018_11_09/s_991754923.338.991754925 注释 = NONE
在 09-11月-18 完成了 Control File and SPFILE Autobackup
```

 查看备份结果

```
RMAN> list backupset;


备份集列表
===================


BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
12      Full    2.44G      DISK        00:01:21     09-11月-18
        BP 关键字: 12   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T152625
段名:+FRA/ORCL/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.291.991754787
  备份集 12 中的数据文件列表
  File LV Type Ckp SCN    Ckp 时间 Abs Fuz SCN Sparse Name
  ---- -- ---- ---------- ---------- ----------- ------ ----
  1       Full 14791547   09-11月-18              NO    +DATA/ORCL/DATAFILE/system.260.980678629
  3       Full 14791547   09-11月-18              NO    +DATA/ORCL/DATAFILE/sysaux.262.980678649
  5       Full 14791547   09-11月-18              NO    +DATA/ORCL/DATAFILE/undotbs1.264.980678657
  7       Full 14791547   09-11月-18              NO    +DATA/ORCL/DATAFILE/undotbs2.268.980678727
  8       Full 14791547   09-11月-18              NO    +DATA/ORCL/DATAFILE/users.269.980678729

BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
13      Full    1.20G      DISK        00:00:32     09-11月-18
        BP 关键字: 13   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T152625
段名:+FRA/ORCL/703A8F7652857A64E053600CA8C00EED/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.289.991754873
  备份集 13 中的数据文件列表
  容器 ID: 3, PDB 名称: RACDB1PDB
  File LV Type Ckp SCN    Ckp 时间 Abs Fuz SCN Sparse Name
  ---- -- ---- ---------- ---------- ----------- ------ ----
  9       Full 12043854   10-9月 -18              NO    +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/system.274.980687407
  10      Full 12043854   10-9月 -18              NO    +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/sysaux.273.980687407
  11      Full 12043854   10-9月 -18              NO    +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undotbs1.275.980687407
  12      Full 12043854   10-9月 -18              NO    +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undo_2.277.980687461
  13      Full 12043854   10-9月 -18              NO    +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/users.278.980687465

BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
14      Full    393.13M    DISK        00:00:11     09-11月-18
        BP 关键字: 14   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T152625
段名:+FRA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/BACKUPSET/2018_11_09/nnndf0_tag20181109t152625_0.337.991754909
  备份集 14 中的数据文件列表
  容器 ID: 2, PDB 名称: PDB$SEED
  File LV Type Ckp SCN    Ckp 时间 Abs Fuz SCN Sparse Name
  ---- -- ---- ---------- ---------- ----------- ------ ----
  2       Full 1103469    05-7月 -18              NO    +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/system.261.980678637
  4       Full 1103469    05-7月 -18              NO    +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/sysaux.263.980678653
  6       Full 1103469    05-7月 -18              NO    +DATA/ORCL/70388319BB1D8FD3E0535F0CA8C0BAB2/DATAFILE/undotbs1.265.980678659

BS 关键字  类型 LV 大小       设备类型 经过时间 完成时间
------- ---- -- ---------- ----------- ------------ ----------
15      Full    19.09M     DISK        00:00:02     09-11月-18
        BP 关键字: 15   状态: AVAILABLE  已压缩: NO  标记: TAG20181109T152843
段名:+FRA/ORCL/AUTOBACKUP/2018_11_09/s_991754923.338.991754925
  包含的 SPFILE: 修改时间: 09-11月-18
  SPFILE db_unique_name: ORCL
  包括的控制文件: Ckp SCN: 14791608     Ckp 时间: 09-11月-18
```

### 备份单个或多个pdb

1、在CDB根（root）使用BACKUP PLUGGABLE DATABASE命令备份一个或多个PDB数据库。

```
RMAN> backuppluggable database pdb1;   //备份多个的话可以pdb1，pdb2这种形式。
```

2、在PDB中使用BACKUP DATABASE备份当前连接的PDB数据库，前提条件是需要配置好TNSNAMES.ORA文件。

```
[oracle@jydb1 ~]$ rman target sys/******@jydb1/RACDB1PDB

恢复管理器: Release 12.2.0.1.0 - Production on 星期六 11月 10 11:25:49 2018

Copyright (c) 1982, 2017, Oracle and/or its affiliates.  All rights reserved.

已连接到目标数据库: ORCL:RACDB1PDB (DBID=415676852, 未打开)

RMAN> backup database;

从位于 10-11月-18 的 backup 开始
使用目标数据库控制文件替代恢复目录
分配的通道: ORA_DISK_1
通道 ORA_DISK_1: SID=117 实例 = racdb11 设备类型 = DISK
通道 ORA_DISK_1: 正在启动全部数据文件备份集
通道 ORA_DISK_1: 正在指定备份集内的数据文件
输入数据文件, 文件号 = 00011 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undotbs1.275.980687407
输入数据文件, 文件号 = 00010 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/sysaux.273.980687407
输入数据文件, 文件号 = 00009 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/system.274.980687407
输入数据文件, 文件号 = 00012 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/undo_2.277.980687461
输入数据文件, 文件号 = 00013 名称 = +DATA/ORCL/703A8F7652857A64E053600CA8C00EED/DATAFILE/users.278.980687465
通道 ORA_DISK_1: 正于 10-11月-18 启动段 1
通道 ORA_DISK_1: 完成了于 10-11月-18 启动段 1
片段句柄 = +FRA/ORCL/703A8F7652857A64E053600CA8C00EED/BACKUPSET/2018_11_10/nnndf0_tag20181110t112759_0.289.991826881 标记 = TAG20181110T112759 注释 = NONE
通道 ORA_DISK_1: 备份集完成, 用时: 00:00:45
在 10-11月-18 完成了 backup
```

## 恢复

### 整体数据库恢复（cdb和所有pdb）

12C数据库加强了RMAN恢复的功能，恢复的方式基本同以前的模式一样，如果是在一个全新的异地进行恢复

操作步骤

1、首先准备同版本系统和数据库软件，仅安装数据库软件；

2、备份完将所有备份介质传到异地服务器B(如果两台机器是内连网络，可以考虑结合NFS服务从一开始就备份到服务器B上)。

3、通过RMAN命令或者拷贝原始库的控制文件到新库上，修改参数文件、创建数据文件路径等，启动CDB数据库到mount状态，声明恢复目录

4、restore还原数据文件

5、recover恢复到故障时间点

6、其他调整

‍

### 单个pdb数据库恢复

 恢复单个PDB的前提是CDB已经能够正常启动，在CDB启动的情况下在RMAN中采用restore pluggable database pdb名称指定单个PDB数据库进行恢复，如下

```
RMAN>restore pluggable database orcl;
...
RMAN>recover pluggable database orcl;
...
最后，使用restlogs方式打开数据库
SQL>alter pluggable database pdb1 orcl resetlogs;
```

### 恢复pdb数据文件

数据库在open的时候，会对当前的数据的所有数据文件进行检查。如果数据文件出现异常，则从报错中获取数据文件id，到rman下进行还原和恢复后方能正常启动数据库。（还原的前提是你有数据库的rman备份数据，包括：数据文件备份、归档日志备份、还可能用到redo文件）

当cdb在打开的时候，数据库不会检查pdb中的数据文件。

```
RMAN>restore datafile datafile_id;
...
RMAN>recover datafile datafile_id;
...
最后，再次打开数据库
SQL>alter  database open;
```

‍



Oracle OFA (Optimal Flexible Architecture) [最佳灵活体系结构（OFA）](https://www.modb.pro/db/608084)是==一种Oracle推荐的数据库架构标准，用于提高数据库的效率和可维护性，并简化数据库的安装、管理和升级==。其主要原则包括将相似用途的段集中存储，遵循标准设计，为异常预留空间，减少表空间冲突等。﻿

OFA标准的主要内容：

- **统一的目录结构:** OFA定义了数据库文件（例如数据文件、控制文件、归档日志、日志文件等）的统一存储位置和组织结构。﻿
- **灵活的架构:** 允许不同版本的Oracle数据库共存，方便管理。﻿
- **简化数据库管理:** 通过标准化存储结构，简化了数据库的备份、恢复、升级等管理操作。﻿
- **提高性能:** 将相似用途的段集中存储，减少了磁盘I/O，提高了性能。﻿
- **易于维护:** 清晰的目录结构使得数据库维护和故障诊断更加便捷。﻿

‍

OFA标准中主要的目录：

- Oracle清单目录
- Oracle基础目录（ORACLE\_BASE）
- Oracle主目录（ORACLE\_HOME）
- Oracle网络文件目录（TNS\_ADMIN）
- 自动诊断库目录（ADR\_HOME)

‍

## Oracle清单目录

Oracle清单目录用于存储在服务器上安装的Oracle软件的清单。该目录是必须创建的，一台服务器上安装的所有Oracle软件都共用该目录。第一次安装Oracle时，安装程序会检查是否存在/u[01-09]/app格式的符合OFA标准的目录结构。如果该目录存在，那么安装程序就会创建一个Oracle清单目录，如：/u01/app/oraInventory

如果已经为操作系统用户oracle定义了ORACLE\_BASE变量，那么安装程序就会为Oracle清单创建一个目录，如：`ORACLE_BASE/../oraInventory`​

例如：ORACLE\_BASE 定义为`/ora01/app/oracle`​，那么安装程序就会将Oracle清单目录定义为：`/ora01/app/oraInventory`​

如果安装程序没有找到可识别的符合OFA标准的目录结构或ORACLE\_BASE变量，那么Oracle清单目录就会被创建在用户oracle的主目录中。例如，如果主目录为/home/oracle，那么Oracle清单目录就会为：`/home/oracle/oraInventory`​

‍

‍

## Oracle基础目录

Oracle基础目录是安装Oracle软件的最顶层目录。可以在该目录中安装Oracle的一个或多个版本。

Oracle基础目录的OFA标准：

​`/<mount_point>/app/<software_owner>`​

挂载点的典型名称包括/u01、/ora01、/oracle和/oracle01。也可以根据自己的环境的标准来命名挂载点。

软件所有者通常会被命名为oracle。例如下面的Oracle基础目录路径：

​`/u01/app/oralce`​

‍

‍

## Oracle主目录

Oracle主目录定义了特定的产品的安装位置，如Oracle Database 12c或Oracle Database 11g。必须将不同产品或某个产品的不同版本安装到单独的Oracle主目录中。

推荐的符合OFA标准的Oracle主目录：

​`ORACLE_BASE/product/<version>/<install_name>`​

version为数据库的版本，如：12.1.0.1

install\_name可以使用的值包括db\_1、devdb1、test2和prod1。

例如：下面是12.1版本数据库的Oracle主目录名

​`/u01/app/oracle/product/12.1.0.1/db\_1`​

‍

‍

## Oracle网络文件目录

某些Oracle实用程序使用TNS\_ADMIN定位网络配置文件。该目录被定义为`ORACLE\_HOME/network/admin`​。其中通常含有Oracle Net文件tnsnames.ora和listener.ora。

提示：有时候DBA会设置TNS\_ADMIN指向一个中心目录位置（如`/etc`​

或`/var/opt/oracle`​）。这使他们能够维护一组Oracle网络文件（而不是

维护每个 ORACLE\_HOME 目录中的网络文件）。在数据库升级有可能

更改 ORACLE\_HOME 目录的位置时，该方法还有无需复制或移动文件

的好处。

‍

‍

# 自动诊断信息库

从Oracle Database 11g开始，ADR\_HOME目录就指定了Oracle相关诊断文件的位置。对于解决Oracle数据库的问题诊断来说，这些文件及其重要。该目录被定义为`Oracle_BASE/diag/rdbms/lower(db_unique_name)/instance_name`​。可以查看 `v$PARAMETER视图`​，获得db\_unique\_name和instance\_name的值。

‍

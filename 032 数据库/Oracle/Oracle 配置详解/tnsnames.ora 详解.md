# tnsnames.ora 详解

文件位置：`$ORACLE_HOME/network/admin`​

tnsnames.ora 用在oracle client端，用户配置连接数据库的别名参数,就像系统中的hosts文件一样。提供了客户端连接某个数据库的详细信息，主机地址，端口，数据库实例名等。

​`vim $ORACLE_HOME/network/admin/tnsnames.ora`​

```bash
fmsdb =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.203)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = fmsdb)
      (SERVER = DEDICATED)
    )
  )
  
pdb1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.203)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = pdb1)   --pdb_name
      (SERVER = DEDICATED)
    )
  )
```

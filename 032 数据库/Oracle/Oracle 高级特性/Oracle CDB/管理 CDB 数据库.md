# 管理 CDB 数据库

‍

## 1. 开启和关闭所有的PDB

```sql
alter pluggable database all open;   -- 打开PDB
alter pluggable database pdb2 open instances=all;
-- 切换到PDB和CDB 
alter session set container=schooldb;  -- 切换到schooldb数据库
alter session set container=cdb$root;  -- 切换到CDB

show con_name;  -- 查看当前所在容器位置
show pdbs;      -- 查看所有的PDB
```

## 2. 连接CDB和PDB

```sql
-- 方式1：通过alter session set container切换到PDB
SQL> alter session set container=pdb1;

--方式2：通过EASY CONNECT，指定"/"跟着PDB名称，就可登录PDB，
sqlplus test/"8ql6,yhY"@192.168.0.203:1521/pdb1

--方式3：如果是18c、19c以上，设置ORACLE_PDB_SID环境变量的值
export ORACLE_PDB_SID="pdb1"
sqlplus / as sysdba

--方式4：通过设置tnsnames.ora
--参考 [oracle19c 静默安装]

--方式5.：通过JDBC程序的连接
--如果是连接PDB，用"/"跟着PDB名称，  
jdbc:oracle:thin:@ip:port/pdb_name
--如果连接CDB、12c以下的，不用"/"，用":"
jdbc:oracle:thin:@ip:port:SID(/SERVICE_NAME)
```

## 3. 创建删除PDB

```sql
-- 创建
CREATE PLUGGABLE DATABASE pdb2 ADMIN USER pdb2 IDENTIFIED BY Ninestar123
roles=(connect,resource,dba)
STORAGE (MAXSIZE 2G)
DATAFILE '/data/oradata/ORCL/pdb2/pdb201.dbf' SIZE 100M AUTOEXTEND ON
PATH_PREFIX = '/data/oradata/ORCL/pdb2'
FILE_NAME_CONVERT = ('/data/oradata/ORCL/pdbseed','/data/oradata/ORCL/pdb2');


--ADMIN USER     	   用于执行管理任务的本地用户
--STORAGE (MAXSIZE 2G) 指定了PDB可用的最大空间
--PATH_PREFIX          用来限制directory objects/Oracle XML/Create pfile/Oracle wallets所在的目录
--FILE_NAME_CONVERT    设置子容器和数据文件副本的位置
```

OMF下创建pdb

```sqlplus
CREATE PLUGGABLE DATABASE pdb2 ADMIN USER pdb2 IDENTIFIED BY Ninestar123 
roles=(connect,resource,dba) 
STORAGE (MAXSIZE 2G) 
FILE_NAME_CONVERT = ('/home/ora/oradata/ORCL/pdbseed','/home/ora/oradata/ORCL/pdb2');
```

‍

## 4. 查看默认创建的表空间的对应的数据文件

```sqlplus
SQL> select name from v$datafile;

NAME
--------------------------------------------------------------------------------
/home/ora/oradata/ORCL/system01.dbf
/home/ora/oradata/ORCL/sysaux01.dbf
/home/ora/oradata/ORCL/undotbs01.dbf
/home/ora/oradata/ORCL/pdbseed/system01.dbf
/home/ora/oradata/ORCL/pdbseed/sysaux01.dbf
/home/ora/oradata/ORCL/users01.dbf
/home/ora/oradata/ORCL/pdbseed/undotbs01.dbf
/home/ora/oradata/ORCL/pdb1/system01.dbf
/home/ora/oradata/ORCL/pdb1/sysaux01.dbf
/home/ora/oradata/ORCL/pdb1/undotbs01.dbf
/home/ora/oradata/ORCL/pdb1/users01.dbf

11 rows selected.

SQL> 

```

‍

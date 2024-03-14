# 管理 CDP 数据库

‍

## 1. 开启和关闭所有的PDB

```sql
alter pluggable database all open;   -- 打开PDB
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
sqlplus sys/password@192.168.0.203:1521/pdb1

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
CREATE PLUGGABLE DATABASE pdb2 ADMIN USER pdb2 IDENTIFIED BY Ninestar2022
roles=(connect,resource,dba)
STORAGE (MAXSIZE 2G)      -- 指定了PDB可用的最大空间
DATAFILE '/data/oradata/FMSDB/pdb2/pdb201.dbf' SIZE 100M AUTOEXTEND ON
PATH_PREFIX = '/data/oradata/FMSDB/pdb2' --用来限制directory objects/Oracle XML/Create pfile/Oracle wallets所在的目录
FILE_NAME_CONVERT = ('/data/oradata/FMSDB/pdbseed',  --设置子容器和数据文件副本的位置
'/data/oradata/FMSDB/pdb2');
```

‍

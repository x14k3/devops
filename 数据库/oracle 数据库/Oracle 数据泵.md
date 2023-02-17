#database/oracle
 
## 数据泵备份

*   **EXP和IMP是客户端工具**程序,它们既可以在可以客户端使用,也可以在服务端使用。

*   **EXPDP和IMPDP是服务端的工具**程序,他们只能在ORACLE服务端使用,**不能在客户端使用**。

*   IMP只适用于EXP导出文件,不适用于EXPDP导出文件;IMPDP只适用于EXPDP导出文件,而不适用于EXP导出文件。

## 服务端expdp/impdp

```bash
# 登录数据库
sqlplus sys/ as sysdba
# 查看逻辑目录
select DIRECTORY_NAME,DIRECTORY_PATH from dba_directories; 
#默认/data/app/oracle/admin/SID/dpdump/

## 创建逻辑目录
## create directory data_dir as '/u01/app/oracle/admin/orcl/dpdump/jy2';

## 授权读写逻辑目录
## grant read,write on directory DATA_PUMP_DIR to jy2web;

#################### 导出 #################
# 导出整个数据库(所有数据库)，执行用户需要dba权限
expdp system/passwd directory=data_pump_dir dumpfile=all.dmpdp full=y
# 按表空间导出
expdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp  tablespaces=user logfile=tablespaceName.log
# 按用户导出
expdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp  schemas=user logfile=user.log
# 按表名导出
expdp user/passwd TABLES=tableName1,tableName2 DUMPFILE=expdp.dmpdp DIRECTORY=DATA_PUMP_DIR logfile=tablename.log
# 导出视图（oracle11g）
expdp user/passwd include=view:"in('xxxxxx')"  DIRECTORY=DATA_PUMP_DIR DUMPFILE=view_xxx.dmpdp logfile=view_xxxx.log

# 导出视图（oracle12c以上）
expdp user/passwd views_as_tables=xxxx DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp logfile=views.log

#################### 导入 #################
#导入到原先用户(与导出的用户名相同)
impdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp schemas=user logfile=user.log;
#导入到其他用户(与导出的用户名不同)
impdp user/passwd DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp.dmpdp remap_schema=user1:user2 remap_tablespace=user1:user2;

* remap_schema       # 当你从A用户导出的数据，想要导入到B用户中去，就使用这个：remap_schema=A:B
* remap_tablespace  # 转移对象到其他表空间 ，将所有tbs_a中的对象都会建在tbs_b表空间中。
* version=11.2          # 当从高版本导出，并导入到低版本数据库时，需要在导出时指定version=低版本号
* TRANSFORM=segment_attributes:n # 去掉存储和表空间相关参数（参数会导致remap_tablespace参数失效）impdp报ORA-39112
* transform=oid:n    # Imp的时候，新创建的表或者type会赋予同样的OID，如果是位于同一个数据库上的不同schema，那就会造成OID冲突的问题
* table_exists_action 参数值有四种，解释如下：
1. skip       # 默认操作
2. replace    # 先drop表，然后创建表，最后插入数据
3. append     # 在原来数据的基础上增加数据
4. truncate   # 清空了表后导入数据
```

并行导出：使用一个以上的线程来显著地加速作业

```sql
expdp xxx/xxx directory=DATA_PUMP_DIR dumpfile=xxxx_%U.dmpdp parallel=3
impdp xxx/xxx directory=DATA_PUMP_DIR dumpfile=xxxx_01.dmpdp,xxxx_02.dmpdp,xxxx_03.dmpdp

```

## 客户端exp/imp

```bash
# 导出用户全部数据(所有数据库),执行用户需要有dba权限
exp system/Ninestar2022 file=/tmp/all_20220510.dmp  full=y  log=/tmp/imp.log
# 导出指定用户的数据
exp jy2web/Ninestar2022 file=/tmp/all_20220510.dmp log=/tmp/imp.log
exp system/Ninestar2022 file=/tmp/jy2web_20220510.dmp owner=jy2web log=/tmp/imp.log
exp jy2web/Ninestar2022 file=/tmp/jy2web_20220510.dmp direct=y log=/tmp/imp.log
#####  其他参数
# direct    定义了导出是使用直接路径方式(DIRECT=Y),提示导出效率
# fromuser  从哪一个用户导出的
# touser    导入到哪个用户
# ignore=y buffer=100000000; 修改缓冲区大小，有时sql语句过长，会造成缓冲区空间不足
```

**exp客户端远程导出oracle数据库**

```bash
# 下载4个rpm工具包
https://www.oracle.com/cn/database/technologies/instant-client/linux-x86-64-downloads.html
rpm -ivh oracle-instantclient19.15-basic-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-sqlplus-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-devel-19.15.0.0.0-1.x86_64.rpm
rpm -ivh oracle-instantclient19.15-tools-19.15.0.0.0-1.x86_64.rpm

# 配置环境变量
export ORACLE_HOME=/usr/lib/oracle/19.15/client64
export LD_LIBRARY_PATH=:$ORACLE_HOME/lib:/usr/local/lib:$LD_LIBRARY_PATH:.
export TNS_ADMIN=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME/bin:
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
export LANG=zh_CN.UTF-8

# oracle11g 可能需要以下操作
yum -y install glibc libaio
## 从oracle服务端拷贝exp imp 到客户端 ORACLE_HOME/bin 目录下
## 从oracle服务端拷贝expus.msb impus.msb 到客户端 ORACLE_HOME/rdbms/mesg/ 目录下(需要创建目录)
# 远程登录
sqlplus jy2web/Ninestar2022@192.168.10.150:1521/orcl
# 远程导出
exp jy2web/Ninestar2022@192.168.10.150:1521/orcl file=/tmp/jy2web_20220510.dmp

```

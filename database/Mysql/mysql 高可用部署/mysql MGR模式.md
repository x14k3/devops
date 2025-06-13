

> MGR是一个MySQL插件，它以现有的MySQL复制架构为基础，利用二进制日志、基于行的日志记录和全局事务标识符（GTID）等功能。

MGR全称MySQL Group Replication（Mysql组复制），是MySQL官方于2016年12月推出的一个全新的高可用与高扩展的解决方案。MGR提供了高可用、高扩展、高可靠的MySQL集群服务。在MGR出现之前，用户常见的MySQL高可用方式，无论怎么变化架构，本质就是Master-Slave架构。MySQL 5.7版本开始支持无损半同步复制（lossless semi-syncreplication），从而进一步提示数据复制的强一致性。

MySQL Group Replication（MGR）是MySQL官方在5.7.17版本引进的一个数据库高可用与高扩展的解决方案，以插件形式提供。MGR基于分布式paxos协议，实现组复制，保证数据一致性。内置故障检测和自动选主功能，只要不是集群中的大多数节点都宕机，就可以继续正常工作。提供单主模式与多主模式，多主模式支持多点写入。

***MGR原理：*** 

参考 [全同步复制](mysql%20同步复制.md#20231110105237-8huy0id)

**优点：**   
1.基本无延迟，延迟比异步的小很多  
2.支持多写模式，但是目前还不是很成熟  
3.数据的强一致性，可以保证数据事务不丢失

**缺点(MGR要求):**   
1.必须适用innodb存储引擎  
2.创建的业务表，必须要有主键  
3.MGR必须适用IPv4网络，不支持IPv6  
4.MGR复制网络必须和业务网络隔离  
5.binlog日志格式必须为row模式  
6.关闭二进制日志校验和，设置--binlog-checksum=NONE  
7.小写 table 格名称. 在所有组成员上将--lower-case-table-names设置为相同的值  
8.隔离级别设置为RC

**MGR限制：**

1.MGR不支持SERIALIZABLE 隔离级别  
2.MGR集群节点不能超过9  
3.MGR不支持大事务，事务大小最好不超过143MB，当事务过大，无法在5 秒的时间内通过网络在组成员之间复制消息，则可能会怀疑成员失败了，然后将其驱逐出局。  
4.并发 DDL 与 DML 操作. 当使用多主模式时，不支持针对同一对象但在不同服务器上执行的并发数据定义语句和数据操作语句。  
5.对表的级联约束的外键支持不好，不建议适用。

‍

## mysql MGR部署

修改主机名

```bash
hostnamectl set-hostname test01
hostnamectl set-hostname test02
hostnamectl set-hostname test03
# 设置hosts 必须！
cat << EOF >> /etc/hosts
192.168.2.172 test01
192.168.2.183 test02
192.168.2.244 test03
EOF
```

分别在3台主机部署单机mysql ((20231110105237-g69az0l '二进制安装')) [192.168.2.172、192.168.2.183、192.168.2.244\]

### 1. 修改配置文件

```bash
[client]
#连接端口号，默认 3306
port=3306
# 用于本地连接的 socket 套接字
socket="/data/mysql/mysql.sock"
[mysql]
# 设置默认字符编码
default_character_set=utf8mb4

[mysqld]
# 每个节点要求不一样
server_id=1
basedir="/data/mysql"
datadir="/data/mysql/data"
socket="/data/mysql/mysql.sock"
log-error="/data/mysql/error.log"
pid-file="/data/mysql/mysql.pid"
character-set-server=utf8mb4
# 是否支持符号链接:否
symbolic-links=0
# 控制是否可以信任存储函数创建者
log_bin_trust_function_creators=1
lower_case_table_names=1
default_authentication_plugin=mysql_native_password
# 最大连接数
max_connections=2000
#innodb_buffer_pool_size=1g
max_allowed_packet = 16M
default-time_zone = '+8:00'
#######innodb settings########

innodb_flush_log_at_trx_commit =1 ##设置为1立即写入日志文件并刷新，安全。设置为2性能好
innodb_buffer_pool_size=512M


########replication复制配置#########
##MGR使用的GTID##
gtid_mode = on
enforce_gtid_consistency = ON
log_bin=mysql-bin
#从服务器将从主服务器上接收到的更新写入到本地的二进制文件中
log_slave_updates=ON
##为了保证安全，将主从复制信息放到表中，MySQL 8.0默认放在TABLE###
#master_info_repository=TABLE
#relay_log_info_repository=TABLE
relay-log=master-relay-bin
#sync_binlog改成1，更安全
#默认，sync_binlog=0，表示MySQL不控制binlog的刷新，由文件系统自己控制它的缓存的刷新。这时候的性能是最好的，但是风险也是最大的。因为一旦系统Crash，在binlog_cache中的所有binlog信息都会被丢失。
#最安全的就是sync_binlog=1了，表示每次事务提交，MySQL都会把binlog刷下去，是最安全但是性能损耗最大的设置。
sync_binlog=1
#MGR使用乐观锁，官网建议的隔离级别是RC，减少锁粒度##
transaction_isolation = READ-COMMITTED
#MGR设置binlog格式为row###
binlog_format = row
#binlog检验规则，MGR要求是NONE##
binlog-checksum = NONE
#ssl mysql8.0以上的mgr需要打开
group_replication_recovery_get_public_key=ON

# 启动加载组复制插件
plugin_dir = "/data/mysql/lib/plugin"
plugin_load = 'group_replication.so'
# 集群唯一ID,组的名字可以随便起,但不能用主机的GTID! 所有节点的这个组名必须保持一致！
loose-group_replication_group_name="8d3cebd8-b132-11eb-8529-0242ac130003"
#重启MySQL时，组复制不自动开启 建议值:off
loose-group_replication_start_on_boot=off
# 是否自动引导组。此选项只能在一个server实例上使用，通常是首次引导组时(或在整组成员关闭的情况下)，如果多次引导，可能出现脑裂。
loose_group_replication_bootstrap_group=off
#本机IP地址或者映射，33061用于接收来自其他组成员的传入连接
loose_group_replication_local_address= "192.168.2.172:33061"
# 当前主机成员需要加入组时，Server先访问这些种子成员中的一个，然后它请求重新配置以允许它加入组
# 需要注意的是，此参数不需要列出所有组成员，只需列出当前节点加入组需要访问的节点即可。
loose_group_replication_group_seeds= "192.168.2.172:33061,192.168.2.183:33061,192.16.2.244:33061"
# 设置白名单,同网段可以不涉及
loose-group_replication_ip_whitelist="192.168.2.172,192.168.2.183,192.168.2.244"
#此参数是在server收集写集合的同时以便将其记录到二进制日志。写集合基于每行的主键，并且是行更改后的唯一标识此标识将用于检测冲突。
transaction_write_set_extraction=XXHASH64

##false为多主模式，true为单主
#loose-group_replication_single_primary_mode = false
##多主模式，强制每一个实例进行冲突检测，不是多主可以关闭
#loose-group_replication_enforce_update_everywhere_checks = true

```

‍

第二个节点修改内容如下：

```bash
server_id=2
relay-log=slave-relay-bin
loose-group_replication_local_address= "node1:33061"
```

第三个节点修改内容如下：

```bash
server_id=3
relay-log=slave-relay-bin
loose-group_replication_local_address= "node2:33061"
```

**三个节点添加完配置信息之后，分别重启MySQL服务，以使配置生效**

```bash
/data/mysql/support-files/mysql.server restart
```

‍

### 2. 创建复制账号（三个节点均需配置）

```sql
SET SQL_LOG_BIN=0;
CREATE USER mgruser@'%' IDENTIFIED BY 'Ninestar@123';
GRANT REPLICATION SLAVE ON *.* TO mgruser@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='mgruser', MASTER_PASSWORD='Ninestar@123' FOR CHANNEL 'group_replication_recovery';
```

‍

### 3. 启动MGR单主模式

**在主节点（当前主节点为：192.168.2.172）启动MGR，执行如下命令**

```sql
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
--查看MGR组信息
SELECT * FROM performance_schema.replication_group_members;
```

**从节点加入MGR，在从库（192.168.2.183，192.168.2.244）上执行如下命令**

```sql
START GROUP_REPLICATION;
-- 在从节点上查看MGR组信息
SELECT * FROM performance_schema.replication_group_members;
```

![image](image-20230725094624-6vpxeao.png)

**报错1**

```bash
023-07-24T09:35:59.679537Z 0 [ERROR] [MY-011516] [Repl] Plugin group_replication reported: 'There is already a member with server_uuid 185c91bd-29fd-11ee-98d2-525400091009. The member will now exit the group.'
#因为安装使用二进制安装mysql后复制到其他服务器，其中/data/mysql/data/auto.cnf的server-uuid重复导致；
```

### 4. 同步验证

1. 主库进行数据写入，查看从库是否同步

    ```sql
    DROP DATABASE IF EXISTS employees;
    CREATE DATABASE IF NOT EXISTS employees;
    USE employees;

    SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

    DROP TABLE IF EXISTS dept_emp,
                         dept_manager,
                         titles,
                         salaries, 
                         employees, 
                         departments;

    /*!50503 set default_storage_engine = InnoDB */;
    /*!50503 select CONCAT('storage engine: ', @@default_storage_engine) as INFO */;

    CREATE TABLE employees (
        emp_no      INT             NOT NULL,
        birth_date  DATE            NOT NULL,
        first_name  VARCHAR(14)     NOT NULL,
        last_name   VARCHAR(16)     NOT NULL,
        gender      ENUM ('M','F')  NOT NULL,  
        hire_date   DATE            NOT NULL,
        PRIMARY KEY (emp_no)
    );

    INSERT INTO `employees` VALUES (10001,'1953-09-02','Georgi','Facello','M','1986-06-26');
    INSERT INTO `employees` VALUES (27927,'1955-11-29','Behnaam','Zultner','F','1993-06-22');
    INSERT INTO `employees` VALUES (45848,'1962-01-06','JiYoung','Sherertz','M','1998-08-23');
    INSERT INTO `employees` VALUES (63784,'1960-09-25','Rosita','Zyda','M','1988-08-12');
    INSERT INTO `employees` VALUES (81713,'1964-08-16','Ravishankar','Cooley','M','1988-03-09');
    INSERT INTO `employees` VALUES (99644,'1958-01-05','Bojan','Zaccaria','M','1989-01-12');
    INSERT INTO `employees` VALUES (207251,'1963-10-12','Fox','Sewelson','F','1989-07-09');
    INSERT INTO `employees` VALUES (224875,'1954-08-07','Yongmao','Gewali','F','1985-10-22');
    INSERT INTO `employees` VALUES (242497,'1961-04-08','Zhonghui','Radwan','M','1995-03-09');
    INSERT INTO `employees` VALUES (260133,'1963-02-20','Shao','Cangellaris','F','1990-08-09');
    INSERT INTO `employees` VALUES (277765,'1953-01-12','Moheb','Gewali','F','1995-07-20');
    INSERT INTO `employees` VALUES (295385,'1954-12-16','Shakhar','Fontan','M','1989-08-08');
    INSERT INTO `employees` VALUES (413009,'1954-12-29','Ranga','Hasenauer','M','1996-02-22');
    INSERT INTO `employees` VALUES (430639,'1960-03-24','Piyush','Leaver','F','1990-09-07');
    INSERT INTO `employees` VALUES (448264,'1962-12-08','Takanari','Bugrara','M','1986-01-24');
    INSERT INTO `employees` VALUES (465898,'1955-05-26','Toshimi','Laurillard','M','1995-01-24');

    --从库查询
    select * from employees;

    --在从节点测试写入，验证不支持写入操作
    mysql> INSERT INTO `employees` VALUES (999999,'1955-05-16','Toshmi','Lauillard','M','1995-01-24');
    ERROR 1290 (HY000): The MySQL server is running with the --super-read-only option so it cannot execute this statement
    ```

‍

2. 主、从服务器停掉，查看从服务器变化

    ```sql
    -- 1、将从库节点test03上从mgr组中去除
    mysql> stop group_replication;
    -- 2、在主库节点master或从库节点test02查看，发现仅剩2个节点
    mysql> SELECT * FROM performance_schema.replication_group_members;
    -- 3、在主库节点master插入数据, 进行写操作，此时查看从库节点test03数据库并没有进行数据同步
    -- 4、将从库节点test03加入mgr组，之后再次查看从库节点test03数据库，发现数据库信息已同步
    mysql> start group_replication;
    mysql> SELECT * FROM performance_schema.replication_group_members;
    +---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
    | CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
    | group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091009 | test01      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
    | group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091010 | test02      |        3306 | ONLINE       | PRIMARY         | 8.0.32         | XCom                       |
    | group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091011 | test03      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
    +---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
    3 rows in set (0.00 sec)
    -- 5、主库节点master移除mgr组之后，会在从库节点test02、test03中按照配置选择对应的从库节点作为主库节点
    ```

‍

### 5. 主节点切换

顺便提一下，在MySQL 5.7版本中，只能通过重启以实现主节点的自动切换，不能手动切换。从这个角度来说，如果想要使用MGR，最好是选择MySQL 8.0版本，而不要使用5.7版本。

在命令行模式下，可以调用 `group_replication_switch_to_single_primary_mode()`​ 和 `group_replication_switch_to_multi_primary_mode()`​ 来切换单主/多主模式。

```sql
mysql> SELECT * FROM performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091009 | test01      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091010 | test02      |        3306 | ONLINE       | PRIMARY         | 8.0.32         | XCom                       |
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091011 | test03      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)

--切换成单主模式时可以指定某个节点的 server_uuid，如果不指定则会根据规则自动选择一个新的主节点
mysql> select group_replication_set_as_primary('185c91bd-29fd-11ee-98d2-525400091009');
+--------------------------------------------------------------------------+
| group_replication_set_as_primary('185c91bd-29fd-11ee-98d2-525400091009') |
+--------------------------------------------------------------------------+
| Primary server switched to: 185c91bd-29fd-11ee-98d2-525400091009         |
+--------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091009 | test01      |        3306 | ONLINE       | PRIMARY         | 8.0.32         | XCom                       |
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091010 | test02      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
| group_replication_applier | 185c91bd-29fd-11ee-98d2-525400091011 | test03      |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)

mysql> 
```

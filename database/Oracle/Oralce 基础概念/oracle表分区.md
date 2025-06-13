

Oracle作为一款成熟的数据库软件产品，就提供了多种数据表存储结构。我们最常见的就是三种，**分别为堆表（Heap Table）、索引组织表（Index Organization Table，简称为IOT）和聚簇表（Cluster Table）** 。其他类型的表：分区表、临时表、压缩表等

## <span data-type="text" style="background-color: var(--b3-card-success-background); color: var(--b3-card-success-color);">1.Heap Table</span>

是我们在Oracle中最常使用的数据表，也是Oracle的默认数据表存储结构。在Heap Table中，数据行是按照“随机存取”的方式进行管理。从段头块之后，一直到高水位线以下的空间，Oracle都是按照随机的方式进行“粗放式”管理。当一条数据需要插入到数据表中时，默认情况下，Oracle会在高水位线以下寻找有没有空闲的地方，能够容纳这个新数据行。如果可以找到这样的地方，Oracle就将这行数据放在空位上。注意，这个空位选择完全依“能放下”的原则，这个空位可能是被删除数据行的覆盖位。

如果Heap Table段的HWM下没有找到合适的位置，Oracle堆表才去向上推高水位线。在数据行存储上，Heap Table的数据行是完全没有次序之分的。我们称之为“随机存取”特征。

 对Heap Table，索引独立段的添加一般可以有效的缓解由于随机存取带来的检索压力。Index叶子节点上记录的数据行键值和Rowid取值，可以让Server Process直接定位到数据行的块位置。

## <span data-type="text" style="background-color: var(--b3-card-success-background); color: var(--b3-card-success-color);">2. 聚簇（Cluster Table）</span>

是一种合并段存储的情况。Oracle认为，如果一些数据表更新频率不高，但是经常和另外一个数据表进行连接查询（Join）显示，就可以将其组织在一个存储结构中，这样可以最大限度的提升性能效率。对聚簇表而言，多个数据表按照连接键的顺序保存在一起。

通常系统环境下，我们使用Cluster Table的情况不太多。Oracle中的数据字典大量的使用聚簇。相比是各种关联的基表之间固定连接检索的场景较多，从而确定的方案。

IOT（Index Organization Table）同Cluster Table一样，IOT是在Oracle数据表策略的一种“非主流”，应用的场景比较窄。但是一些情况下使用它，往往可以起到非常好的效果。

简单的说，IOT区别于堆表的最大特点，就在于数据行的组织并不是随机的，而是依据数据表主键，按照索引树进行保存。从段segment结构上看，IOT索引段就包括了所有数据行列，不存在单独的数据表段。

## <span data-type="text" style="background-color: var(--b3-card-success-background); color: var(--b3-card-success-color);">3. 分区表</span>

随着表中行数的增多，管理和性能影响也将随之增加。备份、恢复、对整个数据表的查询将花费更多时间。通过把一个表中的行分为几个部分，可以减少大型表的管理和性能问题，以这种方式划分表数据的方法称为对表的分区。

分区表的优势:

- (1). 改善查询性能：对分区对象的查询可以仅搜索自己关心的分区，提高检索速度;
- (2). 方便数据管理：因为分区表的数据存储在多个部分中，所以按分区加载和删除数据比在大表中加载和删除数据更容易；
- (3). 方便备份恢复：因为分区比被分区的表要小，所以针对分区的备份和恢复方法要比备份和恢复整个表的方法多。

‍

## 一、分区表的概念

分区表：

当表中的数据量不断增大，查询数据的速度就会变慢，应用程序的性能就会下降，这时就应该考虑对表进行分区。表进行分区后，逻辑上表仍然是一张完整的表，只是将表中的数据在物理上存放到多个“表空间”(物理文件上)，这样查询数据时，不至于每次都扫描整张表而只是从当前的分区查到所要的数据大大提高了数据查询的速度。

### 分区表的具体作用

Oracle的表分区功能通过改善可管理性、性能和可用性，从而为各式应用程序带来了极大的好处。通常，分区可以使某些查询以及维护操作的性能大大提高。此外,分区还可以极大简化常见的管理任务，分区是构建千兆字节数据系统或超高可用性系统的关键工具。 分区功能能够将表、索引或索引组织表进一步细分为段，这些数据库对象的段叫做分区。每个分区有自己的名称，还可以选择自己的存储特性。从数据库管理员的角度来看，一个分区后的对象具有多个段，这些段既可进行集体管理，也可单独管理，这就使数据库管理员在管理分区后的对象时有相当大的灵活性。但是，从应用程序的角度来看，分区后的表与非分区表完全相同，使用 SQL DML 命令访问分区后的表时，无需任何修改。

### 分区表使用场景

1、表的大小超过2GB。  
2、表中包含历史数据，新的数据被增加到新的分区中。

### 分区表的优缺点

优点：  
1、改善查询性能：对分区对象的查询可以仅搜索自己关心的分区，提高检索速度。  
2、增强可用性：如果表的某个分区出现故障，表在其他分区的数据仍然可用；  
3、维护方便：如果表的某个分区出现故障，需要修复数据，只修复该分区即可；  
4、均衡I/O：可以把不同的分区映射到不同磁盘以平衡I/O，改善整个系统性能。

缺点：

分区表相关：已经存在的表没有方法可以直接转化为分区表。不过 Oracle 提供了在线重定义表的功能。

‍

## 二、分区表相关视图

```sql
显示分区表信息
DBA_PART_TABLES

显示表分区信息 显示数据库所有分区表的详细分区信息﹕

DBA_TAB_PARTITIONS

显示子分区信息 显示数据库所有组合分区表的子分区信息﹕

DBA_TAB_SUBPARTITIONS

显示分区列 显示数据库所有分区表的分区列信息﹕

DBA_PART_KEY_COLUMNS

显示子分区列 显示数据库所有分区表的子分区列信息﹕

DBA_SUBPART_KEY_COLUMNS
```

## 三、分区表分类

```sql
1、范围分区表
2、列表分区表
3、哈希分区表
4、引用分区表
5、组合分区表
```

### 1、RANGE分区表

说明：针对记录字段的值在某个范围。  
规则：  
（1）、每一个分区都必须有一个VALUES LESS THEN子句，它指定了一个不包括在该分区中的上限值。  
分区键的任何值等于或者大于这个上限值的记录都会被加入到下一个高一些的分区中。  
（2）、所有分区，除了第一个，都会有一个隐式的下限值，这个值就是此分区的前一个分区的上限值。  
（3）、在最高的分区中，MAXVALUE被定义。MAXVALUE代表了一个不确定的值。这个值高于其它分区中的任何分区键的值，  
也可以理解为高于任何分区中指定的VALUE LESS THEN的值，同时包括空值。若不添加maxvalue的分区插入数值一旦超过设置的最大上限会报错。

分区表分区处于同一表空间

```sql
create table part_range_t1(
id number,
name varchar2(20),
birthday date)
partition by range(birthday)(
        partition p1 values less than(to_date('2001-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
        partition p2 values less than(to_date('2002-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
        partition p3 values less than(to_date('2003-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'))
)
/

SCOTT@TNS_PDB01>select table_owner,table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T1';

TABLE_OWNE TABLE_NAME	   PARTITION_ TABLESPACE
---------- --------------- ---------- ----------
SCOTT	   PART_RANGE_T1   P1	      USERS
SCOTT	   PART_RANGE_T1   P2	      USERS
SCOTT	   PART_RANGE_T1   P3	      USERS

SCOTT@TNS_PDB01>select * from dba_part_key_columns where name = 'PART_RANGE_T1';

OWNER	   NAME 	   OBJEC COLUMN_NAM COLUMN_POSITION COLLATED_COLUMN_ID
---------- --------------- ----- ---------- --------------- ------------------
SCOTT	   PART_RANGE_T1   TABLE BIRTHDAY		  1

SCOTT@TNS_PDB01>select table_name,partitioning_type from dba_part_tables where table_name = 'PART_RANGE_T1';

TABLE_NAME		       PARTITION
------------------------------ ---------
PART_RANGE_T1		       RANGE
```

使用数字列做为分区列

```sql
create table p_t3(
n number,
name varchar2(20))
partition by range(n)(
partition p1 values less than(1000),
partition p2 values less than(10000),
partition p3 values less than(maxvalue))

```

分区表分区处于不同表空间

```sql
create table part_range_t3(
id number,
name varchar2(20),
birthday date)
partition by range(birthday)(
partition p1 values less than(to_date('2001-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) tablespace tbs1,
partition p2 values less than(to_date('2010-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) tablespace tbs2,
partition p3 values less than(maxvalue) tablespace users)
/

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T3';

TABLE_NAME		       PARTITION_ TABLESPACE
------------------------------ ---------- ----------
PART_RANGE_T3		       P1	  TBS1
PART_RANGE_T3		       P2	  TBS2
PART_RANGE_T3		       P3	  USERS


SCOTT@TNS_PDB01>select * from dba_part_key_columns where name = 'PART_RANGE_T3';

OWNER	   NAME 	   OBJEC COLUMN_NAM COLUMN_POSITION COLLATED_COLUMN_ID
---------- --------------- ----- ---------- --------------- ------------------
SCOTT	   PART_RANGE_T3   TABLE BIRTHDAY		  1

SCOTT@TNS_PDB01>select table_name,partitioning_type from dba_part_tables where table_name = 'PART_RANGE_T3';

TABLE_NAME		       PARTITION
------------------------------ ---------
PART_RANGE_T3		       RANGE

```

‍

‍

### 2、LIST分区表

说明：该分区的特点是某列的值只有有限个值，基于这样的特点我们可以采用列表分区。 规则：默认分区为DEFAULT，若不添加DEFAULT的分区插入数值不属于所设置的分区会报错。 在定义范围分区时，每个分区定义必须使用 values（'value01','value02'....）子句。表示该分区存储包含相关value值的数据行。 在定义范围分区时，最后一个分区可以是values（DEFAULT）。表示该分区存储未在其他分区定义的数据行。

```sql
create table part_list_t1(
id number,
name varchar2(20),
sex char(1))
partition by list(sex)(
partition male values('M') tablespace tbs1,
partition female values('F') tablespace tbs2)

SCOTT@TNS_PDB01>select table_owner,table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_OWNE TABLE_NAME			  PARTITION_ TABLESPACE
---------- ------------------------------ ---------- ----------
SCOTT	   PART_LIST_T1 		  FEMALE     TBS2
SCOTT	   PART_LIST_T1 		  MALE	     TBS1

SCOTT@TNS_PDB01>select table_name,partitioning_type from dba_part_tables where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION
------------------------------ ---------
PART_LIST_T1		       LIST

SCOTT@TNS_PDB01>select * from dba_part_key_columns where name = 'PART_LIST_T1';

OWNER	   NAME 	   OBJEC COLUMN_NAM COLUMN_POSITION COLLATED_COLUMN_ID
---------- --------------- ----- ---------- --------------- ------------------
SCOTT	   PART_LIST_T1    TABLE SEX			  1

create table part_list_t2(
id number,
name varchar2(20),
age number)
partition by list(age)(
partition p1 values(10) tablespace tbs1,
partition p2 values(20) tablespace tbs2,
partition p3 values(default) tablespace users)
/

default --存储age列上除了10、20外的其他值
```

指定多个值

```sql
create table part_list_t2(
id number,
name varchar2(20),
age int)
partition by list(age)(
partition age_10_20 values(10,20),
partition age_30 values(30),
partition age_40_50 values(40,50),
partition age_default values(default))
/

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T2';

TABLE_NAME		       PARTITION_NAME		      TABLESPACE HIGH_VALUE
------------------------------ ------------------------------ ---------- ------------------------------
PART_LIST_T2		       AGE_10_20		      USERS	 10, 20
PART_LIST_T2		       AGE_30			      USERS	 30
PART_LIST_T2		       AGE_40_50		      USERS	 40, 50
PART_LIST_T2		       AGE_DEFAULT		      USERS	 default
```

‍

‍

### 3、HASH 散列分区表

说明：这类分区是在列值上使用散列算法，以确定将行放入哪个分区中。 规则：当列的值没有合适的条件，没有范围的规律，也没有固定的值，建议使用散列分区。 散列分区为通过指定分区编号来均匀分布数据的一种分区类型，因为通过在I/O设备上进行散列分区， 使得这些分区大小一致。建议分区的数量采用2的n次方，这样可以使得各个分区间数据分布更加均匀。 Example: 创建hash分区有两种方法：一种方法是指定分区的名字，另一种方法是指定分区数量。

例一、常规方法指定分区名字

```sql
create table part_hash_t1(id number,name varchar2(20),age int)
partition by hash(age)(
partition p1 tablespace tbs1,
partition p2 tablespace tbs2)
/

```

例二、指定分区数量

```sql
create table part_hash_t2(id number,name varchar2(20),age int)
partition by hash(age) partitions 2 store in(tbs1,tbs2)
/

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_HASH_T2';

TABLE_NAME		       PARTITION_ TABLESPACE
------------------------------ ---------- ----------
PART_HASH_T2		       SYS_P388   TBS1
PART_HASH_T2		       SYS_P389   TBS2

SCOTT@TNS_PDB01>select table_name,partitioning_type from dba_part_tables where table_name = 'PART_HASH_T2';

TABLE_NAME		       PARTITION
------------------------------ ---------
PART_HASH_T2		       HASH

SCOTT@TNS_PDB01>select * from dba_part_key_columns where name = 'PART_HASH_T2';

OWNER	   NAME 	   OBJEC COLUMN_NAM COLUMN_POSITION COLLATED_COLUMN_ID
---------- --------------- ----- ---------- --------------- ------------------
SCOTT	   PART_HASH_T2    TABLE AGE			 


--往往我们不需要知道bash分区的名字，因为数据放在哪个分区是oracle根据bash算法存放的，并不是用户指定，所以当用户插入一条记录，并不能确定放在哪个分区，这个不同于range和list
```

‍

### 4、引用分区表

如果父表是分区表，子表想要按照父表的方式进行分区。  
父表中被引用的主键列不一定要是分区键。

父表：

```sql
create table part_range_t4(
id number primary key,
name varchar2(20),
time date,
age int)
partition by range(time)(
partition p1 values less than(to_date('2001-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
partition p2 values less than(to_date('2010-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
partition p3 values less than(maxvalue))
/
```

子表：

```sql
create table part_ref_t4(
pid number,
id number not null,
constraint fk_t4 foreign key(id) references part_range_t4(id))
partition by reference(fk_t4);

Table created.

SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_REF_T4';

TABLE_NAME		       PARTITION_
------------------------------ ----------
PART_REF_T4		       P1
PART_REF_T4		       P2
PART_REF_T4		       P3

SCOTT@TNS_PDB01>select * from dba_part_key_columns where name = 'PART_REF_T4';

OWNER	   NAME 	   OBJEC COLUMN_NAM COLUMN_POSITION COLLATED_COLUMN_ID
---------- --------------- ----- ---------- --------------- -----------
SCOTT	   PART_REF_T4	   TABLE ID			  1

SCOTT@TNS_PDB01>select table_name,partitioning_type from dba_part_tables where table_name = 'PART_REF_T4';

TABLE_NAME		       PARTITION
------------------------------ ---------
PART_REF_T4		       REFERENCE
```

‍

‍

‍

### 5、组合分区表

组合分区中，主要通过在不同列上，使用“范围分区”、“列表分区”以及“HASH分区”不同组合方式，进而实现组合分区。 组合分区中，分区本身没有相应的segment，可以认为是一个逻辑容器，只有子分区拥有实际的segment，用于存放数据。 在11g以后，组合分区新增了四种组合方式：“RANGE\-RANGE”、“LIST\-RANGE”、“LIST\-HASH”以及“LIST\-LIST”。 Example: 以LIST\-LIST的组合方式为例，创建组合分区

```sql
CREATE TABLE "EMPLOYEE_LIST_LIST_PART"
( "EMPNO" NUMBER(4,0),
"ENAME" VARCHAR2(10),
"JOB" VARCHAR2(9),
"MGR" NUMBER(4,0),
"HIREDATE" DATE,
"SAL" NUMBER(7,2),
"COMM" NUMBER(7,2),
"DEPTNO" NUMBER(2,0)
)
PARTITION BY LIST (DEPTNO) --LIST-LIST的组合方式,先分区DEPTNO再分区JOB
SUBPARTITION BY LIST (JOB)
(
PARTITION EMPLOYEE_DEPTNO_10 VALUES (10) TABLESPACE test_tbs_01
( SUBPARTITION EMPLOYEE_10_JOB_MAGAGER VALUES ('MANAGER'),
SUBPARTITION EMPLOYEE_10_JOB_DEFAULT VALUES (DEFAULT)
),
PARTITION EMPLOYEE_DEPTNO_20 VALUES (20) TABLESPACE test_tbs_02
( SUBPARTITION EMPLOYEE_20_JOB_MAGAGER VALUES ('MANAGER'),
SUBPARTITION EMPLOYEE_20_JOB_DEFAULT VALUES (DEFAULT)
),
PARTITION EMPLOYEE_DEPTNO_OTHERS VALUES (DEFAULT) TABLESPACE test_tbs_03
( SUBPARTITION EMPLOYEE_30_JOB_MAGAGER VALUES ('MANAGER'),
SUBPARTITION EMPLOYEE_30_JOB_DEFAULT VALUES (DEFAULT)
)
);



create table t1(
id number,
name varchar2(10))
partition by list(id)
subpartition by list(name)(
partition p_id_1 values(10) tablespace pdb01_tbs01
(subpartition p_id_1_name1 values('aaa'),
subpartition p_id_1_name2 values(default)),
partition p_id_2 values(20) tablespace pdb01_tbs02
(
subpartition p_id_2_name1 values('aaa'),
subpartition p_id_2_name2 values(default)))



create table part_list_list_t1(
empno number,
ename varchar2(20),
job varchar2(20),
sal number,
deptno number)
partition by list(deptno)
subpartition by list(job)(
partition deptno_10 values(10) tablespace tbs1(
subpartition deptno_10_job_manager values('MANAGER'),
subpartition deptno_10_job_default values(default)),
partition deptno_20 values(20) tablespace tbs2(
subpartition deptno_20_job_manager values('MANAGER'),
subpartition deptno_20_job_default values(default)),
partition deptno_default values(default) tablespace users(
subpartition dept_default_job_manager values('MANAGER'),
subpartition dept_default_job_default values(default)))
/


SCOTT@TNS_PDB01>select table_name,partition_name,subpartition_name from dba_tab_subpartitions where table_name = 'PART_LIST_LIST_T1';

TABLE_NAME		       PARTITION_NAME		      SUBPARTITION_NAME
------------------------------ ------------------------------ ---------
PART_LIST_LIST_T1	       DEPTNO_DEFAULT		      DEPT_DEFAULT_JOB_MANAGER
PART_LIST_LIST_T1	       DEPTNO_DEFAULT		      DEPT_DEFAULT_JOB_DEFAULT
PART_LIST_LIST_T1	       DEPTNO_10		      DEPTNO_10_JOB_MANAGER
PART_LIST_LIST_T1	       DEPTNO_10		      DEPTNO_10_JOB_DEFAULT
PART_LIST_LIST_T1	       DEPTNO_20		      DEPTNO_20_JOB_MANAGER
PART_LIST_LIST_T1	       DEPTNO_20		      DEPTNO_20_JOB_DEFAULT

SCOTT@TNS_PDB01>select table_name,partitioning_type,subpartitioning_type from dba_part_tables where table_name = 'PART_LIST_LIST_T1';

TABLE_NAME		       PARTITION SUBPARTIT
------------------------------ --------- ---------
PART_LIST_LIST_T1	       LIST	 LIST
```

‍

## 四、分区表管理

### 1、增加分区

#### 增加RANGE分区

```sql
ALTER TABLE range_example ADD PARTITION part04 VALUES LESS THAN (TO_DATE('2008-10-1 00:00:00','yyyy-mm-dd hh24:mi:ss'));

create table part_range_t1(
id number,
name varchar2(20),
birthday date)
partition by range(birthday)(
partition p1 values less than(to_date('2001-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
partition p2 values less than(to_date('2010-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')),
partition p_maxvalue values less than(maxvalue))
/

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T1' and table_owner = 'SCOTT';

TABLE_NAME		       PARTITION_NAME		      TABLESPACE
------------------------------ ------------------------------ ---------
PART_RANGE_T1		       P1			      USERS
PART_RANGE_T1		       P2			      USERS
PART_RANGE_T1		       P_MAXVALUE		      USERS

SCOTT@TNS_PDB01>alter table part_range_t1 add partition p3 values less than(to_date('2014-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'));
alter table part_range_t1 add partition p3 values less than(to_date('2014-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'))
```

增加的分区必须比最后一个分区更高级

```sql
ERROR at line 1:
ORA-14074: partition bound must collate higher than that of the last partition

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T1' and table_owner = 'SCOTT';

TABLE_NAME		       PARTITION_NAME		      TABLESPACE
------------------------------ ------------------------------ ---------
PART_RANGE_T1		       P1			      USERS
PART_RANGE_T1		       P2			      USERS
PART_RANGE_T1		       P_MAXVALUE		      USERS

```

删除分区

```sql
SCOTT@TNS_PDB01>alter table part_range_t1 drop partition p_maxvalue;

Table altered.

SCOTT@TNS_PDB01>alter table part_range_t1 add partition p3 values less than(to_date('2014-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'));

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T1' and table_owner = 'SCOTT';

TABLE_NAME		       PARTITION_NAME		      TABLESPACE
------------------------------ ------------------------------ ---------
PART_RANGE_T1		       P1			      USERS
PART_RANGE_T1		       P2			      USERS
PART_RANGE_T1		       P3			      USERS

SCOTT@TNS_PDB01>alter table part_range_t1 add partition p_maxvalue values less than(maxvalue);

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,tablespace_name from dba_tab_partitions where table_name = 'PART_RANGE_T1' and table_owner = 'SCOTT';

TABLE_NAME		       PARTITION_NAME		      TABLESPACE
------------------------------ ------------------------------ ---------
PART_RANGE_T1		       P1			      USERS
PART_RANGE_T1		       P2			      USERS
PART_RANGE_T1		       P3			      USERS
PART_RANGE_T1		       P_MAXVALUE		      USERS
```

#### 增加List分区

```sql
create table part_list_t1(
id number,
name varchar2(20),
age int)
partition by list(age)(
partition age_10 values(10) tablespace tbs1,
partition age_20 values(20) tablespace tbs2,
partition age_default values(default) tablespace users)
/

SCOTT@TNS_PDB01>alter table part_list_t1 add partition age_30 values(30);
alter table part_list_t1 add partition age_30 values(30)
            *
ERROR at line 1:
ORA-14323: cannot add partition when DEFAULT partition exists

SCOTT@TNS_PDB01>alter table part_list_t1 drop partition age_default;

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_LIST_T1		       AGE_10
PART_LIST_T1		       AGE_20

SCOTT@TNS_PDB01>alter table part_list_t1 add partition age_30 values(30);

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_LIST_T1		       AGE_10
PART_LIST_T1		       AGE_20
PART_LIST_T1		       AGE_30

SCOTT@TNS_PDB01>alter table part_list_t1 add partition age_default values(default);

Table altered.


SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_LIST_T1		       AGE_10
PART_LIST_T1		       AGE_20
PART_LIST_T1		       AGE_30
PART_LIST_T1		       AGE_DEFAULT

SCOTT@TNS_PDB01>alter table part_list_t1 modify partition age_20 add values(40);

Table altered.

SCOTT@TNS_PDB01>alter table part_list_t1 modify partition age_20 drop values(20);

Table altered.
```

LIST分区增加多个值

```sql
SCOTT@TNS_PDB01>alter table part_list_t1 modify partition age_20 add values(20,50,60);

Table altered.


SCOTT@TNS_PDB01>insert into part_list_t1 values(1,'xiao zhang',50);

1 row created.

SCOTT@TNS_PDB01>insert into part_list_t1 values(2,'xiao long',100);

1 row created.

SCOTT@TNS_PDB01>insert into part_list_t1 values(3,'lissen',20);

1 row created.

SCOTT@TNS_PDB01>insert into part_list_t1 values(4,'xiao hong',13);

1 row created.

SCOTT@TNS_PDB01>commit;

Commit complete.

SCOTT@TNS_PDB01>select * from part_list_t1;

ID NAME		   AGE
--- --------------- ----------
  1 xiao zhang		    50
  3 lissen		    20
  2 xiao long		   100
  4 xiao hong		    13

SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_LIST_T1		       AGE_10			      10
PART_LIST_T1		       AGE_20			      40, 20, 50, 60
PART_LIST_T1		       AGE_30			      30
PART_LIST_T1		       AGE_DEFAULT		      default

--Adding Values for a List Partition
ALTER TABLE list_example MODIFY PARTITION part04 ADD VALUES('MIS');
--Dropping Values from a List Partition
ALTER TABLE list_example MODIFY PARTITION part04 DROP VALUES('MIS');
--hash partitioned table

```

#### 增加HASH分区

```sql
create table part_hash_t1(
id number,
name varchar2(20),
age int)
partition by hash(age)(
partition age_1,
partition age_2)
/

SCOTT@TNS_PDB01>alter table part_hash_t1 add partition age_3;

Table altered.

ALTER TABLE hash_example ADD PARTITION part03;
--hash partitioned table 新增partition时，现有表的中所有data都有重新计算hash值，然后重新分配到分区中。
--所以被重新分配的分区的 indexes需要rebuild
 
```

#### 增加子分区

```sql
create table part_composit_t1(
empno number,
ename varchar2(20),
job varchar2(20),
deptno number)
partition by list(deptno)
subpartition by list(job)(
partition dept_10 values(10) tablespace tbs1(
subpartition dept_10_job_manager values('MANAGER'),
subpartition dept_10_job_salesman values('SALESMAN')),
partition dept_20 values(20) tablespace tbs2(
subpartition dept_20_job_manager values('MANAGER'),
subpartition dept_20_job_salesman values('SALESMAN')))
/


SCOTT@TNS_PDB01>select table_name,partition_name,subpartition_name from dba_tab_subpartitions where table_name = 'PART_COMPOSIT_T1';

TABLE_NAME		       PARTITION_NAME		      SUBPARTITION_NAME
------------------------------ ------------------------------ ------------------------------
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_MANAGER
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_SALESMAN
PART_COMPOSIT_T1	       DEPT_20			      DEPT_20_JOB_MANAGER
PART_COMPOSIT_T1	       DEPT_20			      DEPT_20_JOB_SALESMAN


SCOTT@TNS_PDB01>alter table part_composit_t1 modify partition dept_20 add subpartition dept_20_job_analyst values('ANALYST');

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,subpartition_name from dba_tab_subpartitions where table_name = 'PART_COMPOSIT_T1';

TABLE_NAME		       PARTITION_NAME		      SUBPARTITION_NAME
------------------------------ ------------------------------ ------------------------------
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_MANAGER
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_SALESMAN
PART_COMPOSIT_T1	       DEPT_20			      DEPT_20_JOB_MANAGER
PART_COMPOSIT_T1	       DEPT_20			      DEPT_20_JOB_SALESMAN
PART_COMPOSIT_T1	       DEPT_20			      DEPT_20_JOB_ANALYST

ALTER TABLE range_hash_example MODIFY PARTITION part_1 ADD SUBPARTITION part_1_sub_4; --注意复合分区这里是MODIFY
```

‍

‍

### 2、删除分区

对range分区表删除分区

```sql
ALTER TABLE PART_TAB_SALE_RANGE_LIST DROP PARTITION P3; 
```

对range分区表list子分区删除子分区

```sql
ALTER TABLE PART_TAB_SALE_RANGE_LIST DROP SUBPARTITION P4SUB1;
```

对于哈希分区表,哈希复合分区表,range\-hash分区表

```sql
-- 减少hash 分区的个数，一次减少一个。不能指定减少partition的名称。
ALTER TABLE hash_example COALESCE PARTITION ;

SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_HASH_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_HASH_T1		       AGE_1
PART_HASH_T1		       AGE_2
PART_HASH_T1		       AGE_3

SCOTT@TNS_PDB01>alter table part_hash_t1 coalesce partition;

Table altered.


SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_HASH_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_HASH_T1		       AGE_1
PART_HASH_T1		       AGE_2

SCOTT@TNS_PDB01>alter table part_hash_t1 coalesce partition;

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name from dba_tab_partitions where table_name = 'PART_HASH_T1';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
PART_HASH_T1		       AGE_1

--subpartition 的语法对于如下
ALTER TABLE diving MODIFY PARTITION us_locations
COALESCE SUBPARTITION;

SCOTT@TNS_PDB01>alter table part_composit_t1 drop partition dept_20;

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,subpartition_name from dba_tab_subpartitions where table_name = 'PART_COMPOSIT_T1';

TABLE_NAME		       PARTITION_NAME		      SUBPARTITION_NAME
------------------------------ ------------------------------ ------------------------------
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_MANAGER
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_SALESMAN

SCOTT@TNS_PDB01>alter table part_composit_t1 drop subpartition dept_10_job_salesman;

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,subpartition_name from dba_tab_subpartitions where table_name = 'PART_COMPOSIT_T1';

TABLE_NAME		       PARTITION_NAME		      SUBPARTITION_NAME
------------------------------ ------------------------------ ------------------------------
PART_COMPOSIT_T1	       DEPT_10			      DEPT_10_JOB_MANAGER

```

‍

‍

### 3、合并分区

```sql
ALTER TABLE range_example
MERGE PARTITIONS part01_1,part01_2 INTO PARTITION part01
UPDATE INDEXES;
--如果省略update indexes子句的话，必须重建受影响的分区的index 。
ALTER TABLE range_example MODIFY PARTITION part02 REBUILD UNUSABLE LOCAL INDEXES;
```

‍

```sql
SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ---------
PART_LIST_T1		       AGE_10			      10
PART_LIST_T1		       AGE_20			      40, 20, 50, 60
PART_LIST_T1		       AGE_30			      30
PART_LIST_T1		       AGE_DEFAULT		      default

SCOTT@TNS_PDB01>alter table part_list_t1 merge partitions age_10,age_20 into partition age_10_20 [update indexes];

Table altered.

SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T1';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ---------PART_LIST_T1		       AGE_10_20		      10, 40, 20, 50, 60
PART_LIST_T1		       AGE_30			      30
PART_LIST_T1		       AGE_DEFAULT		      default

SCOTT@TNS_PDB01>alter table part_list_t1 modify partition age_10_20 rebuild unusable local indexes;
Table altered.
```

‍

### 4、分割分区

#### range类型分区的分割

```sql
ALTER TABLE range_example
SPLIT PARTITION part01
AT (TO_DATE('2008-06-01 00:00:00','yyyy-mm-dd hh24:mi:ss'))
INTO ( PARTITION part01_1,PARTITION part01_2
);
一个分区一次性只能分割成两个分区，at关键字后面指定的值为第一个分区的range范围，默认为less than 。
```

```sql
SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_RANGE_T1';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_RANGE_T1		       P1			      TO_DATE(' 2001-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P2			      TO_DATE(' 2010-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P3			      TO_DATE(' 2014-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P_MAXVALUE		      MAXVALUE

SCOTT@TNS_PDB01>alter table part_range_t1 split partition p2 at(to_date('2005-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) into (partition p2_1,partition p2_2);

Table altered.


SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_RANGE_T1';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_RANGE_T1		       P1			      TO_DATE(' 2001-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P2_1			      TO_DATE(' 2005-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P2_2			      TO_DATE(' 2010-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P3			      TO_DATE(' 2014-01-01 00:00:00'
							      , 'SYYYY-MM-DD HH24:MI:SS', 'N
							      LS_CALENDAR=GREGORIAN')

PART_RANGE_T1		       P_MAXVALUE		      MAXVALUE
```

#### list类型分区的分割

```sql
ALTER TABLE list_example
SPLIT PARTITION part01 VALUES('ME','PE')
INTO ( PARTITION part01_1, PARTITION part01_2
);
```

```sql
SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T2';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_LIST_T2		       AGE_10_20		      10, 20
PART_LIST_T2		       AGE_30			      30
PART_LIST_T2		       AGE_40_50		      40, 50
PART_LIST_T2		       AGE_DEFAULT		      default


--values后指定的是分区后的第一个分区的LIST值

SCOTT@TNS_PDB01>alter table part_list_t2 split partition age_10_20 values(10) into (partition age_10,partition age_20);

Table altered.


SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_LIST_T2';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_LIST_T2		       AGE_10			      10
PART_LIST_T2		       AGE_20			      20
PART_LIST_T2		       AGE_30			      30
PART_LIST_T2		       AGE_40_50		      40, 50
PART_LIST_T2		       AGE_DEFAULT		      default
```

‍

‍

#### Range\_Hash类型分区的分割

新分区会对原有分区的subpartition做rehash的动作。如果在分割是指定subpartition的个数，则按新规则rehash subpartition，如果没有指定则保留原有subpartition的个数不变。

```sql
ALTER TABLE range_hash_example SPLIT PARTITION part_1
AT (TO_DATE('2008-07-01 00:00:00','yyyy-mm-dd hh24:mi:ss')) INTO (
PARTITION part_1_1 SUBPARTITIONS 2 STORE IN (tbs01,tbs02),
PARTITION part_1_2
);
subpartitions 2 -- 指定新分区的subpartition的个数，store in 子句指定subpartition存储的tablespace
```

```sql
SCOTT@TNS_PDB01>insert into part_hash_t3 values(1,'xiao zhang',10);

1 row created.

SCOTT@TNS_PDB01>insert into part_hash_t3 values(2,'xiao wang',20);

1 row created.

SCOTT@TNS_PDB01>insert into part_hash_t3 values(3,'xiao long',30);

1 row created.

SCOTT@TNS_PDB01>insert into part_hash_t3 values(4,'xiao xin',40);

1 row created.

SCOTT@TNS_PDB01>commit;

Commit complete.


SCOTT@TNS_PDB01>select * from part_hash_t3 order by id;

 ID NAME		   AGE
--- --------------- ----------
  1 xiao zhang		    10
  2 xiao wang		    20
  3 xiao long		    30
  4 xiao xin		    40

SCOTT@TNS_PDB01>select table_name,partition_name,high_value from dba_tab_partitions where table_name = 'PART_HASH_T3';

TABLE_NAME		       PARTITION_NAME		      HIGH_VALUE
------------------------------ ------------------------------ ------------------------------
PART_HASH_T3		       AGE_1
PART_HASH_T3		       AGE_2
```

查询分区数据

```sql
SCOTT@TNS_PDB01>select * from part_hash_t3 partition(age_1);

 ID NAME		   AGE
--- --------------- ----------
  2 xiao wang		    20
  3 xiao long		    30
  4 xiao xin		    40

SCOTT@TNS_PDB01>select * from part_hash_t3 partition(age_2);

 ID NAME		   AGE
--- --------------- ----------
  1 xiao zhang		    10
```

重命名分区

​`alter table part_range_t1 rename partition p2_1 to p2;`​

‍

## 五、分区索引

#### 普通索引

```sql
SCOTT@TNS_PDB01>create index idx_part_range_t1_birthday on part_range_t1(birthday);

Index created.
```

‍

‍

#### 本地索引

```sql
SCOTT@TNS_PDB01>create index idx_part_range_t1_birthday_local on part_range_t1(birthday) local;

Index created.
```

‍

‍

#### 全局索引

```sql
SCOTT@TNS_PDB01>create index idx_global_part_range_t1_id on part_range_t1(id)
  2  global partition by range(id)(
  3  partition part_id_1 values less than(1000),
  4  partition part_id_max values less than(maxvalue));

Index created.
```

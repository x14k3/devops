
## 一. 视图的定义

视图(view)，也称虚表, 不占用物理空间，这个也是相对概念，因为视图本身的定义语句还是要存储在数据字典里的。视图只有逻辑定义。每次使用的时候,只是重新执行SQL。

视图是从一个或多个实际表中获得的，这些表的数据存放在数据库中。那些用于产生视图的表叫做该视图的基表。一个视图也可以从另一个视图中产生。

视图的定义存在数据库中，与此定义相关的数据并没有再存一份于数据库中。通过视图看到的数据存放在基表中。

视图看上去非常象数据库的物理表，对它的操作同任何其它的表一样。当通过视图修改数据时，实际上是在改变基表中的数据；相反地，基表数据的改变也会自动反映在由基表产生的视图中。由于逻辑上的原因，有些Oracle视图可以修改对应的基表，有些则不能（仅仅能查询）。

还有一种视图：物化视图（`MATERIALIZED VIEW`​ ），也称实体化视图，快照 （8i 以前的说法） ，它是含有数据的，占用存储空间。

**tips**: 查询视图没有什么限制, 插入/更新/删除视图的操作会受到一定的限制; 所有针对视图的操作都会影响到视图的基表; 为了防止用户通过视图间接修改基表的数据, 可以将视图创建为只读视图(带上with read only选项)

## 二. 视图的作用

1. 提供各种数据表现形式, 可以使用各种不同的方式将基表的数据展现在用户面前, 以便符合用户的使用习惯(主要手段: 使用别名)；
2. 隐藏数据的逻辑复杂性并简化查询语句, 多表查询语句一般是比较复杂的, 而且用户需要了解表之间的关系, 否则容易写错; 如果基于这样的查询语句创建一个视图, 用户就可以直接对这个视图进行"简单查询"而获得结果. 这样就隐藏了数据的复杂性并简化了查询语句.这也是oracle提供各种"数据字典视图"的原因之一,`all_constraints`​就是一个含有2个子查询并连接了9个表的视图(在`catalog.sql`​中定义)；
3. 执行某些必须使用视图的查询. 某些查询必须借助视图的帮助才能完成. 比如, 有些查询需要连接一个分组统计后的表和另一表, 这时就可以先基于分组统计的结果创建一个视图, 然后在查询中连接这个视图和另一个表就可以了；
4. 提供某些安全性保证. 视图提供了一种可以控制的方式, 即可以让不同的用户看见不同的列, 而不允许访问那些敏感的列, 这样就可以保证敏感数据不被用户看见；
5. 简化用户权限的管理. 可以将视图的权限授予用户, 而不必将基表中某些列的权限授予用户, 这样就简化了用户权限的定义。

## 三 创建视图

## 权限:

要在当前方案中创建视图, 用户必须具有`create view`​系统权限; 要在其他方案中创建视图, 用户必须具有`create any view`​系统权限.视图的功能取决于视图拥有者的权限.

## 语法:

```javascript
create [ or replace ] [ force ] view [schema.]view_name
```

```javascript
[ (column1,column2,...) ] as select ... [ with check option ] [ constraint constraint_name ] [ with read only ]
```

tips:

- 1 `or replace`​: 如果存在同名的视图, 则使用新视图"替代"已有的视图
- 2 `force`​: "强制"创建视图,不考虑基表是否存在,也不考虑是否具有使用基表的权限
- 3 column1,column2,…：视图的列名, 列名的个数必须与`select`​查询中列的个数相同;如果`select`​查询包含函数或表达式, 则必须为其定义列名.此时, 既可以用column1, column2指定列名,也可以在select查询中指定列名.
- 4 `with check option`​:
  指定对视图执行的dml操作必须满足“视图子查询”的条件即,对通过视图进行的增删改操作进行"检查",要求增删改操作的数据,必须是select查询所能查询到的数据,否则不允许操作并返回错误提示. 默认情况下,在增删改之前"并不会检查"这些行是否能被select查询检索到.
- 5 `with read only`​：创建的视图只能用于查询数据, 而不能用于更改数据.

### 3.1 创建简单视图

简单视图定义：是指基于单个表建立的，不包含任何函数、表达式和分组数据的视图。

```javascript
create view vw_emp as select empno,ename,job,hiredate,deptno from emp;
```

  对简单视图进行DML操作

```javascript
insert into vw_emp values(1,'a','aa','05-JUN-88',10); update vw_emp set ename='cc' where ename='KING'; delete vw_emp where ename='cc'; select * from vw_emp where deptno=10;
```

基表也发生了相应的更改

### 3.2 创建只读视图

```javascript
create view vw_emp_readonly as select empno,ename,job,hiredate,deptno from emp with read only; select * from vw_emp_readonly where deptno=10;
```

只能查询，无法进行更改

```javascript
delete vw_emp_readonly where empno=1
```

```javascript
ERROR at line 1: ORA-42399: cannot perform a DML operation on a read-only view
```

更新基表，只读视图也发生了相应的更改

```javascript
update emp set empno=2 where ename='a';
```

### 3.3 创建检查约束视图with check option

```javascript
create view vw_emp_check as select empno,ename,job,hiredate,deptno from emp where deptno=10 with check option;
```

```javascript
insert into vw_emp_check values('3','d','dd','02-JAN-65',20)
```

```javascript
ERROR at line 1: ORA-01402: view WITH CHECK OPTION where-clause violation
```

创建检查视图：对通过视图进行的增删改操作进行检查，要求增删改操作的数据必须是`select`​查询所能查询到的数据
20号部门不在查询范围内，违反检查约束,所以无法插入；

```javascript
delete vw_emp_check where empno=2;
```

1 row deleted.
\--------所删除的数据在查询范围内，不违反检查约束

### 3.4 连接视图

#### 3.4.1 连接视图定义

基于多个表所创建的视图，即，定义视图的查询是一个连接查询。 主要目的是为了简化连接查询；

#### 3.4.2 创建连接视图

示例1： 查询部门编号为10和30的部门及雇员信息

```javascript
create view vw_dept_emp as select a.deptno,a.dname,a.loc,b.empno,b.ename,b.sal from dept a,emp b where a.deptno=b.deptno and a.deptno in(10,30);
```

```javascript
select * from vw_dept_emp;
```

#### 3.4.3 连接视图上的DML操作

```javascript
insert into vw_dept_emp values(10,'aaa','aaaa',22,'a',5000)
```

```javascript
ERROR at line 1: ORA-01779: cannot modify a column which maps to a non key-preserved table
```

在视图上进行的所有DML操作，最终都会在基表上完成；
select 视图没有什么限制，但insert/delete/update有一些限制；

#### 3.4.4键值保存表

如果连接视图中的一个“基表的键”(主键、唯一键)在它的视图中仍然存在，并且“基表的键”仍然是“连接视图中的键”(主键、唯一键)；即，某列在基表中是主键|唯一键，在视图中仍然是主键|唯一键，则称这个基表为“键值保存表”。
一般地，由主外键关系的2个表组成的连接视图，外键表就是键值保存表，而主键表不是。

#### 3.4.5 连接视图的更新准则

一：一般准则

- 任何DML操作，只能对视图中的键值保存表进行更新, 即，“不能通过连接视图修改多个基表”;
- 在DML操作中，“只能使用连接视图定义过的列”;
- “自连接视图”的所有列都是可更新(增删改)的

二：insert准则

- 在insert语句中不能使用“非键值保存表”中的列(包括“连接列”)；
- 执行insert操作的视图，至少应该“包含”键值保存表中所有设置了约束的列；
- 如果在定义连接视图时使用了WITH CHECK OPTION 选项，则“不能”针对连接视图执行insert操作;

三：update准则

- 键值保存表中的列是可以更新的；
- 如果在定义连接视图时使用了`WITH CHECK OPTION`​选项，则连接视图中的连接列(一般就是“共有列”)和基表中的“其他共有列”是“不可”更新的，连接列和共有列之外的 其他列是“可以”更新的;

四：delete准则

- 如果在定义连接视图时使用了`WITH CHECK OPTION`​ 选项，依然“可以”针对连接视图执行`delete`​操作;

#### 3.4.6 可更新连接视图

如果创建连接视图的select查询“不包含”如下结构，并且遵守连接视图的“更新准则”，则这样的连接视图是“可更新”的：

- 集合运算符(union,intersect,minus)
- ​`DISTINCT`​关键字
- ​`GROUP BY`​，`ORDER BY`​，`CONNECT BY`​或`START WITH`​子句
- 子查询
- 分组函数
- 需要更新的列不是由“列表达式”定义的
- 基表中所有`NOT NULL`​列均属于该视图

### 3.5 创建复杂视图

复杂视图定义：是指包含函数、表达式、或分组数据的视图。主要目的是为了简化查询。主要用于执行查询操作，并不用于执行DML操作。
注意：当视图的select查询中包含函数或表达式时，必须为其定义列别名。
示例1：查询目前每个岗位的平均工资、工资总和、最高工资和最低工资。

```javascript
create view vw_emp_job_sal(job,avgsal,sumsal,maxsal,minsal) as select job,avg(sal),sum(sal),max(sal),min(sal) from emp group by job; select * from vw_emp_job_sal;
```

### 3.6 强制创建视图

强制视图定义：正常情况下，如果基表不存在，创建视图就会失败。但是可以使用force选项强制创建视图(前提：创建视图的语句没有语法错误！)，此时该视图处于失效状态。

```javascript
create force view vw_test_tab as select c1,c2 from test_tab;
```

```javascript
Warning: View created with compilation errors. 警告: 创建的视图带有编译错误。
```

```javascript
select * from vw_test_tab
```

```javascript
ERROR at line 1: ORA-04063: view "SCOTT.VW_TEST_TAB" has errors
```

## 四 更改视图

在对视图进行更改(或重定义)之前，需要考虑如下几个问题：

- 由于视图只是一个虚表，其中没有数据，所以更改视图只是改变数据字典中对该视图的定义信息，视图的所有基础对象都不会受到任何影响。
- 更改视图之后，依赖于该视图的所有视图和PL/SQL程序都将变为`INVALID`​(失效)状态。
- 如果以前的视图中具有`with check option`​选项，但是重定义时没有使用该选项，则以前的此选项将自动删除。

### 4.1更改视图的定义

方法——执行`create or replace view`​语句。这种方法代替了先删除(“权限也将随之删除”)后创建的方法，会保留视图上的权限，但与该视图相关的存储过程和视图会失效。
示例1：
将视图改为改为只读

```javascript
create or replace view vw_emp as select empno,ename,job,hiredate,deptno from emp with read only;
```

### 4.2视图的重新编译

语法：`alter view 视图名 compile;`​

作用：当视图依赖的基表改变后，视图会“失效”。为了确保这种改变“不影响”视图和依赖于该视图的其他对象，应该使用alter view 语句“明确的重新编译”该视图，从而在运行视图前发现重新编译的错误。视图被重新编译后，若发现错误，则依赖该视图的对象也会失效；若没有错误，视图会变为“有效”。

权限：为了重新编译其他模式中的视图，必须拥有alter any table系统权限。
**注意**：当访问基表改变后的视图时，oracle会“自动重新编译”这些视图。
示例1：

```javascript
select last_ddl_time,object_name,status from user_objects where object_name='VW_TEST_TAB';
```

思考：若上述代码修改的不是列长，而是表名，结果又会如何？
<警告：更改的视图带有编译错误；视图状态：失效>

## 五 删除视图

可以删除当前模式中的任何视图；
如果要删除其他模式中的视图，必须拥有DROP ANY VIEW系统权限；
视图被删除后，该视图的定义会从词典中被删除，并且在该视图上授予的“权限”也将被删除。
视图被删除后，其他引用该视图的视图及存储过程等都会失效。
示例1：`drop view vw_test_tab;`​

## 六 查看视图

使用数据字典视图

- ​`dba_views`​——DBA视图描述数据库中的所有视图
- ​`all_views`​——ALL视图描述用户“可访问的”视图
- ​`user_views`​——USER视图描述“用户拥有的”视图
- ​`dba_tab_columns`​——DBA视图描述数据库中的所有视图的列(或表的列)
- ​`all_tab_columns`​——ALL视图描述用户“可访问的”视图的列(或表的列)
- ​`user_tab_columns`​——USER视图描述“用户拥有的”视图的列(或表的列)
  示例1：查询当前方案中所有视图的信息

```javascript
select view_name,text from user_views;
```

示例2：查询当前方案中指定视图(或表)的列名信息

```javascript
select * from user_tab_columns where table_name='VW_DEPT';
```

## 七 在视图上执行DML操作的步骤和原理

- 第一步：将针对视图的SQL语句与视图的定义语句(保存在数据字典中)“合并”成一条SQL语句；
- 第二步：在内存结构的共享SQL区中“解析”(并优化)合并后的SQL语句；
- 第三步：“执行”SQL语句；

示例：假设视图v\_emp的定义语句如下：

```javascript
create view v_emp as select empno,ename,loc from employees emp,departments dept where emp.deptno=dept.deptno and dept.deptno=10;
```

当用户执行如下查询语句时：

```javascript
select ename from v_emp where empno=9876;
```

oracle将把这条SQL语句与视图定义语句“合并”成如下查询语句：

```javascript
select ename from employees emp,departments dept where emp.deptno=dept.deptno and dept.deptno=10 and empno=9876;
```

然后，解析(并优化)合并后的查询语句，并执行查询语句;

### 7.1查询视图“可更新”(包括“增删改”)的列

使用数据字典视图

- ​`dba_updatable_columns`​——显示数据库所有视图中的所有列的可更新状态
- ​`all_updatable_columns`​——显示用户可访问的视图中的所有列的可更新状态
- ​`user_updatable_columns`​——显示用户拥有的视图中的所有列的可更新状态

示例1：

```javascript
select table_name,column_name,insertable,updatable,deletable from user_updatable_columns;
```

‍

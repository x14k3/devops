# postgreSQL视图与触发器

视图（View）本质上是一个存储在数据库中的查询语句。视图本身不包含数据，也被称为虚拟表。 我们在创建视图时给它指定了一个名称，然后可以像表一样对其进行查询。

**优势**

* 不保存数据，节省空间。
* 减少频繁调用 sql 的重复书写。
* 可控制数据访问，隐藏不想对外展示的数据。

**劣势**

* 可能增加数据库压力，严重时会妨碍整个数据库的运行。（常见于复杂视图）

## 语法

‍

### 创建视图

```pgsql
CREATE [ OR REPLACE ] [ TEMP | TEMPORARY ] [ RECURSIVE ] VIEW name [ ( column_name [, ...] ) ]
    [ WITH ( view_option_name [= view_option_value] [, ... ] ) ]
    AS query
    [ WITH [ CASCADED | LOCAL ] CHECK OPTION ]

---------------------------------------------------------------------------------------------------
CREATE VIEW             -- 定义一个查询的视图。

CREATE OR REPLACE VIEW  -- 如果已经存在一个同名视图，该视图会被替换（限制：只能在原视图基础上增加字段，不能减少字段,且增加字段顺序只能排在最后）。 

TEMPORARY|TEMP          -- 视图被创建为一个临时视图。在当前会话结束时会自动删掉。当临时视图存在时，具有相同名称的已有永久视图对当前会话不可见，除非用模式限定的名称引用它们。如果视图引用的任何表是临时的，视图将被创建为临时视图（不管有没有指定TEMPORARY）。  
RECURSIVE               -- 创建一个递归视图。

name                    -- 要创建的视图的名字（可以是模式限定的）。

column_name             -- 要用于视图列的名称列表，可选。如果没有给出，列名会根据查询推导。 

WITH ( view_option_name [= view_option_value] [, ... ] ) 该子句为视图指定选项参数；支持下列参数：
  check_option (string)      这个参数可以是local或cascaded，相当于声明了 WITH [ CASCADED | LOCAL ] CHECK OPTION（见下文）。 可以使用ALTER VIEW在现有的视图中改变这个选项。
  security_barrier (string)  如果视图打算提供行级别的安全就应该使用这个选项。参阅 第 38.5 节获取全部信息。

query                   -- 提供视图的行和列的一个 SELECT 或者 VALUES 命令。  

WITH [ CASCADED | LOCAL ] CHECK OPTION -- 这个选项控制自动可更新视图的行为。这个选项被指定时，将检查该视图上的 INSERT 和UPDATE 命令以确保新行满足视图的定义条件（也就是，将检查新行来确保通过视图能看到它们）。如果新行不满足条件，更新将被拒绝。如果没有指定 CHECK OPTION，会允许该视图上的 INSERT 和 UPDATE 命令创建通过该视图不可见的行。支持下列检查选项：
  LOCAL     --只根据直接定义在该视图本身的条件检查新行。任何定义在底层基视图上的 条件都不会被检查（除非它们也指定了CHECK OPTION）。
  CASCADED  --会根据该视图和所有底层基视图上的条件检查新行。如果 CHECK OPTION 被指定，并且没有指定 LOCAL 和 CASCADED，则会假定为 CASCADED。 CHECK OPTION 不应该和 [RECURSIVE]视图一起使用。注意，只有在自动可更新的、没有 NSTEAD OF 触发器或者 INSTEAD 规则的视图上才支持 CHECK OPTION。 如果一个自动可更新的视图被定义在一个具有 INSTEAD OF 触发器的基视图之上，那么 LOCAL CHECK OPTION 可以被用来检查该自动可更新的视图之上的条件，但具有 INSTEAD OF 触发器的基视图上的条件不会被检查（一个级联检查选项将不会级联到一个 触发器可更新的视图，并且任何直接定义在一个触发器可更新视图上的检查 选项将被忽略）。如果该视图或者任何基础关系具有导致 INSERT 或 UPDATE 命令被重写的 INSTEAD 规则，那么在被重写的查询中将忽略所有检查选项，包括任何来自于定义在带有 INSTEAD 规则的关系之上的自动可更新视图的检查。
```

‍

### 修改视图

```pgsql
ALTER VIEW [ IF EXISTS ] name ALTER [ COLUMN ] column_name SET DEFAULT expression
ALTER VIEW [ IF EXISTS ] name ALTER [ COLUMN ] column_name DROP DEFAULT
ALTER VIEW [ IF EXISTS ] name OWNER TO { new_owner | CURRENT_USER | SESSION_USER }
ALTER VIEW [ IF EXISTS ] name RENAME TO new_name
ALTER VIEW [ IF EXISTS ] name SET SCHEMA new_schema
ALTER VIEW [ IF EXISTS ] name SET ( view_option_name [= view_option_value] [, ... ] )
ALTER VIEW [ IF EXISTS ] name RESET ( view_option_name [, ... ] )

name             -- 一个现有视图的名称（可以是模式限定的）
column_name      -- 现有列的名称
new_column_name  -- 现有列的新名称
IF EXISTS        -- 该视图不存在时不要抛出一个错误。这种情况下会发出一个提示
SET/DROP DEFAULT -- 这些形式为一个列设置或者移除默认值。对于任何在该视图上的 INSERT 或者 UPDATE 命令，一个视图列的默认值会在引用该视图的任何规则或触发器之前被替换进来。因此，该视图的默认值将会优先于来自底层关系的任何默认值。

new_owner --该视图的新拥有者的用户名
new_name  --该视图的新名称 
new_schema--该视图的新模式
 
SET ( view_option_name [= view_option_value] [, … ] )/RESET ( view_option_name [, … ] ) --设置或者重置一个视图选项。当前支持的选项有： 
  check_option (enum) --更改该视图的检查选项。值必须是 local 或者 cascaded。  
  security_barrier (boolean) --更改该视图的安全屏障属性。值必须是一个布尔值，如 true 或者 false。
```

‍

### 删除视图

```pgsql
DROP VIEW [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]

IF EXISTS  -- 如果该视图不存在则不要抛出一个错误，而是发出一个提示。
name       -- 要移除的视图的名称（可以是模式限定的）。
CASCADE    -- 自动删除依赖于该视图的对象（例如其他视图），然后删除所有依赖于那些对象的对象。
RESTRICT   -- 如果有任何对象依赖于该视图，则拒绝删除它。这是默认值。
```

## 实例

```pgsql
--用下列三张基表构建包含员工姓名，工作，部门，隐藏薪资的视图
postgres=# select * from emp;
 employee_id | first_name | last_name |  email   | phone_number | hire_date  |   job_id   |  salary  | commission_pct | manager_id | department_id
-------------+------------+-----------+----------+--------------+------------+------------+----------+----------------+------------+---------------
         100 | Steven     | King      | SKING    | 515.123.4567 | 2003-06-17 | AD_PRES    | 24000.00 |                |            |            90
         101 | Neena      | Kochhar   | NKOCHHAR | 515.123.4568 | 2005-09-21 | AD_VP      | 17000.00 |                |        100 |            90
         102 | Lex        | De Haan   | LDEHAAN  | 515.123.4569 | 2001-01-13 | AD_VP      | 17000.00 |                |        100 |            90
         103 | Alexander  | Hunold    | AHUNOLD  | 590.423.4567 | 2006-01-03 | IT_PROG    |  9000.00 |                |        102 |            60
         104 | Bruce      | Ernst     | BERNST   | 590.423.4568 | 2007-05-21 | IT_PROG    |  6000.00 |                |        103 |            60
         105 | David      | Austin    | DAUSTIN  | 590.423.4569 | 2005-06-25 | IT_PROG    |  4800.00 |                |        103 |            60
         106 | Valli      | Pataballa | VPATABAL | 590.423.4560 | 2006-02-05 | IT_PROG    |  4800.00 |                |        103 |            60
         107 | Diana      | Lorentz   | DLORENTZ | 590.423.5567 | 2007-02-07 | IT_PROG    |  4200.00 |                |        103 |            60
         108 | Nancy      | Greenberg | NGREENBE | 515.124.4569 | 2002-08-17 | FI_MGR     | 12008.00 |                |        101 |           100
         109 | Daniel     | Faviet    | DFAVIET  | 515.124.4169 | 2002-08-16 | FI_ACCOUNT |  9000.00 |                |        108 |           100
(10 rows)

postgres=# select * from jobs;
   job_id   |            job_title            | min_salary | max_salary
------------+---------------------------------+------------+------------
 AD_PRES    | President                       |      20080 |      40000
 AD_VP      | Administration Vice President   |      15000 |      30000
 AD_ASST    | Administration Assistant        |       3000 |       6000
 FI_MGR     | Finance Manager                 |       8200 |      16000
 FI_ACCOUNT | Accountant                      |       4200 |       9000
 AC_MGR     | Accounting Manager              |       8200 |      16000
 AC_ACCOUNT | Public Accountant               |       4200 |       9000
 SA_MAN     | Sales Manager                   |      10000 |      20080
 SA_REP     | Sales Representative            |       6000 |      12008
 PU_MAN     | Purchasing Manager              |       8000 |      15000
 PU_CLERK   | Purchasing Clerk                |       2500 |       5500
 ST_MAN     | Stock Manager                   |       5500 |       8500
 ST_CLERK   | Stock Clerk                     |       2008 |       5000
 SH_CLERK   | Shipping Clerk                  |       2500 |       5500
 IT_PROG    | Programmer                      |       4000 |      10000
 MK_MAN     | Marketing Manager               |       9000 |      15000
 MK_REP     | Marketing Representative        |       4000 |       9000
 HR_REP     | Human Resources Representative  |       4000 |       9000
 PR_REP     | Public Relations Representative |       4500 |      10500
(19 rows)

postgres=# select * from dept;
 department_id | department_name
---------------+-----------------
             1 | Adminstration
             2 | Marketing
            30 | Purchasing
(3 rows)


--构建视图
postgres=# create or replace view emp_details_view
postgres-# as select
postgres-# e.employee_id,
postgres-# e.job_id,
postgres-# e.department_id,
postgres-# e.first_name,
postgres-# e.last_name,
postgres-# d.department_name,
postgres-# j.job_title
postgres-# from emp e
postgres-# join departments d on (e.department_id = d.department_id)
postgres-# join jobs j on (j.job_id = e.job_id);
CREATE VIEW
postgres=# select * from emp_details_view;
 employee_id |   job_id   | department_id | first_name | last_name | department_name |           job_title
-------------+------------+---------------+------------+-----------+-----------------+-------------------------------
         100 | AD_PRES    |            90 | Steven     | King      | Executive       | President
         101 | AD_VP      |            90 | Neena      | Kochhar   | Executive       | Administration Vice President
         102 | AD_VP      |            90 | Lex        | De Haan   | Executive       | Administration Vice President
         103 | IT_PROG    |            60 | Alexander  | Hunold    | IT              | Programmer
         104 | IT_PROG    |            60 | Bruce      | Ernst     | IT              | Programmer
         105 | IT_PROG    |            60 | David      | Austin    | IT              | Programmer
         106 | IT_PROG    |            60 | Valli      | Pataballa | IT              | Programmer
         107 | IT_PROG    |            60 | Diana      | Lorentz   | IT              | Programmer
         108 | FI_MGR     |           100 | Nancy      | Greenberg | Finance         | Finance Manager
         109 | FI_ACCOUNT |           100 | Daniel     | Faviet    | Finance         | Accountant
(10 rows)

--增加入职时间字段（字段顺序只能排在原视图末尾。其他修改原视图字段的操作，只能删除视图重新创建）
postgres=# create or replace view emp_details_view
postgres-# as select
postgres-# e.employee_id,
postgres-# e.job_id,
postgres-# e.department_id,
postgres-# e.first_name,
postgres-# e.last_name,
postgres-# d.department_name,
postgres-# j.job_title,
postgres-# e.hire_date
postgres-# from emp e
postgres-# join departments d on (e.department_id = d.department_id)
postgres-# join jobs j on (j.job_id = e.job_id);
CREATE VIEW
postgres=# select * from emp_details_view;
 employee_id |   job_id   | department_id | first_name | last_name | department_name |           job_title           | hire_date
-------------+------------+---------------+------------+-----------+-----------------+-------------------------------+------------
         100 | AD_PRES    |            90 | Steven     | King      | Executive       | President                     | 2003-06-17
         101 | AD_VP      |            90 | Neena      | Kochhar   | Executive       | Administration Vice President | 2005-09-21
         102 | AD_VP      |            90 | Lex        | De Haan   | Executive       | Administration Vice President | 2001-01-13
         103 | IT_PROG    |            60 | Alexander  | Hunold    | IT              | Programmer                    | 2006-01-03
         104 | IT_PROG    |            60 | Bruce      | Ernst     | IT              | Programmer                    | 2007-05-21
         105 | IT_PROG    |            60 | David      | Austin    | IT              | Programmer                    | 2005-06-25
         106 | IT_PROG    |            60 | Valli      | Pataballa | IT              | Programmer                    | 2006-02-05
         107 | IT_PROG    |            60 | Diana      | Lorentz   | IT              | Programmer                    | 2007-02-07
         108 | FI_MGR     |           100 | Nancy      | Greenberg | Finance         | Finance Manager               | 2002-08-17
         109 | FI_ACCOUNT |           100 | Daniel     | Faviet    | Finance         | Accountant                    | 2002-08-16
(10 rows)

--修改视图名
postgres=# \dv
              List of relations
 Schema |       Name       | Type |  Owner
--------+------------------+------+----------
 public | emp_details_view | view | postgres
(1 row)

postgres=# alter view if exists emp_details_view rename to emp_view;
ALTER VIEW
postgres=# \dv
          List of relations
 Schema |   Name   | Type |  Owner
--------+----------+------+----------
 public | emp_view | view | postgres
(1 row)

--由于历史原因，ALTER TABLE 也可以用于视图
postgres=# alter table if exists emp_view rename to emp_view2;
ALTER TABLE
postgres=# \dv
          List of relations
 Schema |   Name    | Type |  Owner
--------+-----------+------+----------
 public | emp_view2 | view | postgres
(1 row)

--删除视图
postgres=# drop view emp_view2;
DROP VIEW
```

## 一、视图的概念

1. **虚拟表：** 视图本质上是一个**基于 SQL 查询结果集**的**虚拟表**。
2. **不存储数据：** 视图本身**不存储任何实际的数据行**。它只存储定义它的 **`SELECT` 语句**。
3. **逻辑表示：** 当你查询一个视图时，Oracle 数据库会**动态地**执行视图定义中存储的 `SELECT` 语句，并返回该查询的实时结果。因此，视图展示的数据始终**反映其基表（Base Table）的最新状态**。
4. **命名查询：** 你可以把视图看作是一个**被命名、保存起来的 SQL 查询**。通过给这个查询结果集起一个名字（视图名），你可以像使用真实表一样方便地查询它。
5. **基于基表：** 视图的数据来源于一个或多个**基表**（真实的表）或其他视图。
6. **模式对象：** 视图是存储在数据库模式（Schema）中的对象，就像表、索引、序列一样。它属于创建它的用户（模式）。

**简单比喻：** 想象你有一张复杂的电路板设计图（基表数据）。视图就像是在这张设计图上放置一个定制的**模板**或**滤镜**（视图定义）。这个模板只允许你看到特定的线路（某些列），或者只展示符合特定条件的部分（过滤行），或者将几个不同区域的线路组合起来展示（连接表）。当你透过这个模板看时，你看到的是一个简化或定制的视图，但模板本身并不包含任何新的线路（不存储数据），它只是改变了你看原始设计图的方式。

## 二、视图的作用

视图在数据库设计和管理中扮演着至关重要的角色，其主要作用包括：

1. **数据安全性与访问控制：**
    - **隐藏敏感数据：** 你可以创建一个视图，只包含基表中允许特定用户或角色查看的列。例如，`employees` 表有 `salary` 列，你可以创建一个不包含 `salary` 列的视图 `v_emp_public` 给普通用户查询。
    - **行级安全：** 通过在视图定义的 `SELECT` 语句中加入 `WHERE` 子句，可以只暴露满足特定条件的行。例如，创建一个视图 `v_my_department_emps`，只显示当前登录用户所在部门的员工信息 (`WHERE department_id = :USER_DEPT_ID`)。
    - **简化权限管理：** 与其在基表的各个列上为不同用户组设置复杂的权限，不如创建几个具有不同访问级别的视图，然后只需授予用户查询特定视图的权限 (`GRANT SELECT ON v_emp_hr TO hr_role;`)。

2. **简化复杂查询：**
    - **封装复杂性：** 如果一个查询涉及多表连接（`JOIN`）、聚合函数（`SUM`, `AVG`, `COUNT`）、子查询、`UNION` 等操作，变得非常冗长和复杂，你可以将这个复杂的查询定义为一个视图。
    - **提高易用性：** 用户（包括应用程序开发人员或报表工具）只需像查询简单表一样 `SELECT * FROM complex_view;` 即可获得结果，无需理解或重复编写底层复杂的 SQL 逻辑。这降低了出错率和学习成本。

3. **提供逻辑数据独立性：**
    - **屏蔽底层变化：** 如果基表的结构发生了变化（例如，添加、删除、重命名列，或者拆分表），只要视图所依赖的列逻辑关系依然能够满足（或者稍作修改），**依赖该视图的应用程序或查询可以保持不变**。应用程序访问的是视图这个抽象层，而不是直接访问物理表结构。
    - **简化重构：** 这使得数据库管理员在调整底层物理模型时，对上层应用的影响降到最低。

4. **呈现定制化的数据表示：**
    - **重命名列：** 视图可以为基表的列提供更具业务含义或更友好的别名 (`SELECT employee_id AS "工号", first_name || ' ' || last_name AS "姓名" FROM employees;`)。
    - **计算列：** 可以在视图中创建基于基表列计算得出的派生列 (`SELECT product_id, unit_price, quantity, unit_price * quantity AS "总价" FROM order_items;`)。
    - **聚合数据：** 创建预聚合数据的视图，用于报表或仪表盘 (`SELECT department_id, AVG(salary) AS avg_sal FROM employees GROUP BY department_id;`)。
    - **合并异构数据：** 使用 `UNION` 或 `UNION ALL` 将结构相似但存储在不同表（甚至不同数据源，通过数据库链接）的数据组合在一个视图中呈现。

5. **确保一致的业务规则：**
    - 通过在视图定义中嵌入特定的过滤条件 (`WHERE status = 'ACTIVE'`)、计算逻辑或连接条件，可以确保所有通过该视图访问数据的用户都应用了相同的业务规则。

## 三、视图的更新限制

- 虽然视图本身不存储数据，但**某些视图允许执行 `INSERT`, `UPDATE`, `DELETE` 操作**（称为“可更新视图”）。
- 然而，**可更新性有严格限制**：
    - 视图通常只能基于**单个基表**（某些特定情况下的连接视图也可能可更新，但规则复杂）。
    - 视图定义不能包含：`DISTINCT`, 聚合函数 (`GROUP BY`, `HAVING`), 集合操作 (`UNION`, `INTERSECT`, `MINUS`), 某些子查询, `ROWNUM` 伪列等。
    - 视图必须包含基表的所有 `NOT NULL` 列（或这些列有默认值）。
    - 使用 `WITH CHECK OPTION` 可以确保通过视图修改的数据，在修改后依然满足视图定义的 `WHERE` 子句条件。
- **实际操作：** 对可更新视图的 DML 操作会被 Oracle **透明地转换**为对**基表**的相应操作。

## 总结

|特性|说明|
|---|---|
|**本质**|基于 SQL 查询的**虚拟表**，**不存储数据**。|
|**核心作用**|**提供数据的安全抽象层、简化复杂查询、保证逻辑独立性、定制数据视图**|
|**数据来源**|一个或多个**基表**或其他视图。|
|**数据实时性**|查询视图时**动态生成**，反映基表最新状态。|
|**存储内容**|存储的是定义视图的 **`SELECT` 语句**。|
|**所属对象**|存储在**模式（Schema）**中。|
|**DML 操作**|**有限支持**（可更新视图），需满足特定条件，操作最终作用在**基表**上。|

**核心价值：** 视图是 Oracle 数据库提供的一种强大的**逻辑抽象机制**。它通过在物理数据（基表）和用户/应用之间建立一个**中间层**，极大地增强了数据安全性、简化了数据访问复杂性、提高了应用的稳定性和灵活性，是构建健壮、易维护数据库应用的关键组件之一。


# Oracle 创建视图详解

在 Oracle 数据库中，创建视图使用 `CREATE VIEW` 语句。视图是基于一个或多个表的查询结果集的虚拟表，它不存储实际数据，而是存储查询定义。

## 基本语法

```sql
CREATE [OR REPLACE] [FORCE|NOFORCE] VIEW [schema.]view_name
[(column_name [, column_name]...)]
AS subquery
[WITH CHECK OPTION [CONSTRAINT constraint_name]]
[WITH READ ONLY];
```
## 参数说明

1. **OR REPLACE**：如果视图已存在，则替换它
2. **FORCE/NOFORCE**：
    - `FORCE`：即使基表不存在也创建视图
    - `NOFORCE`（默认）：只有基表存在时才创建视图
3. **schema**：视图所属的模式（用户名）
4. **view_name**：视图名称
5. **column_name**：为视图列指定别名（可选）
6. **subquery**：定义视图的 SELECT 语句
7. **WITH CHECK OPTION**：确保通过视图执行的DML操作符合视图定义的条件
8. **WITH READ ONLY**：创建只读视图

## 创建简单视图

```sql
-- 创建显示员工基本信息的视图
CREATE VIEW emp_basic_view AS
SELECT employee_id, first_name, last_name, email, hire_date, job_id
FROM employees;
```

## 创建带别名的视图

```sql
-- 为视图列指定别名
CREATE VIEW emp_sal_view (emp_id, name, job, salary) AS
SELECT employee_id, first_name || ' ' || last_name, job_id, salary
FROM employees;
```

## 创建连接多个表的视图

```sql
```

-- 创建显示员工及其部门信息的视图
CREATE VIEW emp_dept_view AS
SELECT e.employee_id, e.first_name, e.last_name, 
       d.department_name, d.location_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

## 创建带条件的视图

sql

-- 只显示IT部门的员工
CREATE VIEW it_employees AS
SELECT employee_id, first_name, last_name, email, phone_number
FROM employees
WHERE department_id = 60;

## 创建只读视图

```sql
-- 创建不允许修改的只读视图
CREATE VIEW emp_readonly_view AS
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WITH READ ONLY;
```

## 创建带WITH CHECK OPTION的视图

```sql
-- 创建限制DML操作的视图
CREATE VIEW high_salary_emp AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > 10000
WITH CHECK OPTION CONSTRAINT high_salary_chk;

```

## 创建FORCE视图（基表不存在时）

```sql
-- 即使基表不存在也强制创建视图
CREATE FORCE VIEW future_view AS
SELECT * FROM future_table;
```

## 替换现有视图

```sql
-- 修改或替换现有视图定义
CREATE OR REPLACE VIEW emp_basic_view AS
SELECT employee_id, first_name, last_name, email, 
       hire_date, job_id, department_id
FROM employees;
```

## 注意事项

1. 视图查询不能包含ORDER BY子句（除非使用Oracle 12c及以上版本）
2. 视图可以嵌套（基于其他视图创建视图）
3. 可更新视图必须满足特定条件（通常基于单个表，不包含聚合函数等）
4. 视图可以提高安全性，隐藏敏感数据
5. 视图可以简化复杂查询

## 查看视图定义

```sql
-- 查看视图定义
SELECT text FROM user_views WHERE view_name = 'EMP_BASIC_VIEW';
```

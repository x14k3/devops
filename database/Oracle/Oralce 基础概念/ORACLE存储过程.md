
## 一、定义

所谓**存储过程**(Stored Procedure)，就是一组用于完成特定数据库功能的SQL语句集，该SQL语句集经过编译后存储在数据库系统中。在使用时候，用户通过指定已经定义的存储过程名字并给出相应的存储过程参数来调用并执行它，从而完成一个或一系列的数据库操作。

## 二、存储过程创建

​`Oracle`​存储过程包含三部分：过程声明，执行过程部分，存储过程异常。

### 2.1 无参存储过程语法

```sql
create or replace procedure NoParPro  
 as  //声明  
 ;  
 begin // 执行  
 ;  
 exception//存储过程异常  
 ;  
 end;
```

### 2.2 带参存储过程实例

```sql
create or replace procedure queryempname(sfindno emp.empno%type)   
as  
   sName emp.ename%type;  
   sjob emp.job%type;  
begin  
       ....  
exception  
       ....  
end; 
```

### 2.3 带参数存储过程含赋值方式

```sql
create or replace procedure runbyparmeters  
    (isal in emp.sal%type,   
     sname out varchar,  
     sjob in out varchar)  
 as   
    icount number;  
 begin  
      select count(*) into icount from emp where sal>isal and job=sjob;  
      if icount=1 then  
        ....  
      else  
       ....  
     end if;  
exception  
     when too_many_rows then  
     DBMS_OUTPUT.PUT_LINE('返回值多于1行');  
     when others then  
     DBMS_OUTPUT.PUT_LINE('在RUNBYPARMETERS过程中出错！');  
end;  
```

其中参数IN表示输入参数，是参数的默认模式。
`OUT`​表示返回值参数，类型可以使用任意Oracle中的合法类型。
**OUT模式定义的参数只能在过程体内部赋值，表示该参数可以将某个值传递回调用他的过程**
`IN OUT`​表示该参数可以向该过程中传递值，也可以将某个值传出去。

### 2.4 存储过程中游标定义使用

```sql
as //定义(游标一个可以遍历的结果集)   
CURSOR cur_1 IS   
  SELECT area_code,CMCODE,SUM(rmb_amt)/10000 rmb_amt_sn,  
         SUM(usd_amt)/10000 usd_amt_sn   
  FROM BGD_AREA_CM_M_BASE_T   
  WHERE ym >= vs_ym_sn_beg   
       AND ym <= vs_ym_sn_end   
  GROUP BY area_code,CMCODE;   
    
begin //执行（常用For语句遍历游标）     
FOR rec IN cur_1 LOOP   
  UPDATE xxxxxxxxxxx_T   
   SET rmb_amt_sn = rec.rmb_amt_sn,usd_amt_sn = rec.usd_amt_sn   
   WHERE area_code = rec.area_code   
   AND CMCODE = rec.CMCODE   
   AND ym = is_ym;   
END LOOP;  
```

### 2.5 游标的定义

```sql
--显示cursor的处理
declare  
---声明cursor,创建和命名一个sql工作区
cursor cursor_name is  
    select real_name from account_hcz;
    v_realname varchar2(20);
begin 
    open cursor_name;---打开cursor,执行sql语句产生的结果集
    fetch cursor_name into v_realname;--提取cursor,提取结果集中的记录
    dbms_output.put_line(v_realname);
    close cursor_name;--关闭cursor
end;

```

## 三、调用存储过程

### 3.1 过程调用方式一

```sql
declare  
      realsal emp.sal%type;  
      realname varchar(40);  
      realjob varchar(40);  
begin   //过程调用开始  
      realsal:=1100;  
      realname:='';  
      realjob:='CLERK';  
      runbyparmeters(realsal,realname,realjob);－－必须按顺序  
      DBMS_OUTPUT.PUT_LINE(REALNAME||'   '||REALJOB);  
END;  //过程调用结束 

```

### 3.2 过程调用方式二

```sql
declare  
     realsal emp.sal%type;  
     realname varchar(40);  
     realjob varchar(40);  
begin    //过程调用开始  
     realsal:=1100;  
     realname:='';  
     realjob:='CLERK';  
     －－指定值对应变量顺序可变  
     runbyparmeters(sname=>realname,isal=>realsal,sjob=>realjob);         
    DBMS_OUTPUT.PUT_LINE(REALNAME||'   '||REALJOB);  
END;  //过程调用结束

```

### 3.3 过程调用方式三（SQL命令行方式下）

```sql
SQL>exec proc_emp('参数1','参数2');//无返回值过程调用 
```

```sql
SQL>var vsal number SQL> exec proc_emp ('参数1',:vsal);// 有返回值过程调用 
```

或者：

```sql
call proc_emp ('参数1',:vsal);// 有返回值过程调用 
```

## 四、存储过程创建语法

```sql
create [or replace] procedure 存储过程名（param1 in type，param2 out type）
as
变量1 类型（值范围）;
变量2 类型（值范围）;
Begin
    Select count(*) into 变量1 from 表A where列名=param1；

    If (判断条件) then
       Select 列名 into 变量2 from 表A where列名=param1；
       Dbms_output.Put_line(‘打印信息’);
    Elsif (判断条件) then
       Dbms_output.Put_line(‘打印信息’);
    Else
       Raise 异常名（NO_DATA_FOUND）;
    End if;
Exception
    When others then
       Rollback;
End;

```

## 五、注意事项

> 1. 存储过程参数不带取值范围，`in`​表示传入，`out`​表示输出;
> 2. 变量带取值范围，后面接分号;
> 3. 在判断语句前最好先用`count(*)`​函数判断是否存在该条操作记录;
> 4. 用`select … into …`​ 给变量赋值;
> 5. 在代码中抛异常用 `raise`​+异常名;

### 5.1 已命名的异常

命名的系统异常 产生原因

---

- ​`ACCESS_INTO_NULL`​ 未定义对象
- ​`CASE_NOT_FOUND`​ CASE 中若未包含相应的 WHEN ，并且没有设置ELSE 时
- ​`COLLECTION_IS_NULL`​ 集合元素未初始化
- ​`CURSER_ALREADY_OPEN`​ 游标已经打开
- ​`DUP_VAL_ON_INDEX`​ 唯一索引对应的列上有重复的值
- ​`INVALID_CURSOR`​ 在不合法的游标上进行操作
- ​`INVALID_NUMBER`​ 内嵌的 SQL 语句不能将字符转换为数字
- ​`NO_DATA_FOUND`​ 使用 select into 未返回行，或应用索引表未初始化的
- ​`TOO_MANY_ROWS`​ 执行 select into 时，结果集超过一行
- ​`ZERO_DIVIDE`​ 除数为 0
- ​`SUBSCRIPT_BEYOND_COUNT`​ 元素下标超过嵌套表或 VARRAY 的最大值
- ​`SUBSCRIPT_OUTSIDE_LIMIT`​ 使用嵌套表或 VARRAY 时，将下标指定为负数
- ​`VALUE_ERROR`​ 赋值时，变量长度不足以容纳实际数据
- ​`LOGIN_DENIED`​ PL/SQL 应用程序连接到 oracle 数据库时，提供了不正确的用户名或密码
- ​`NOT_LOGGED_ON`​ PL/SQL 应用程序在没有连接 oralce 数据库的情况下访问数据
- ​`PROGRAM_ERROR`​ PL/SQL 内部问题，可能需要重装数据字典＆ pl./SQL系统包
- ​`ROWTYPE_MISMATCH`​ 宿主游标变量与 PL/SQL 游标变量的返回类型不兼容
- ​`SELF_IS_NULL`​ 使用对象类型时，在 null 对象上调用对象方法
- ​`STORAGE_ERROR`​ 运行 PL/SQL 时，超出内存空间
- ​`SYS_INVALID_ID`​ 无效的 ROWID 字符串
- ​`TIMEOUT_ON_RESOURCE`​ Oracle 在等待资源时超时

## 六、基本语法

### 6.1 基本结构

```sql
CREATE OR REPLACE PROCEDURE 存储过程名字
(
    参数1 IN NUMBER,
    参数2 IN NUMBER
) IS
变量1 INTEGER :=0;
变量2 DATE;
BEGIN
    --执行体
END 存储过程名字;

```

### 6.2 SELECT INTO STATEMENT

将select查询的结果存入到变量中，可以同时将多个列存储多个变量中，必须有一条记录，否则抛出异常(如果没有记录抛出`NO_DATA_FOUND`​)
例子：

```sql
  BEGIN
  SELECT col1,col2 into 变量1,变量2 FROM typestruct where xxx;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      xxxx;
  END;

```

### 6.3 IF 判断

```sql
 IF V_TEST = 1 THEN
    BEGIN 
       do something
    END;
  END IF;
```

### 6.4 while 循环

```sql
  WHILE V_TEST=1 LOOP
  BEGIN
    XXXX
  END;
  END LOOP;
```

### 6.5 变量赋值

```sql
V_TEST := 123;
```

### 6.6 用for in 使用cursor

```sql
  IS
  CURSOR cur IS SELECT * FROM xxx;
  BEGIN
 FOR cur_result in cur LOOP
  BEGIN
   V_SUM :=cur_result.列名1+cur_result.列名2
  END;
 END LOOP;
  END;
```

### 6.7 带参数的cursor

```sql
  CURSOR C_USER(C_ID NUMBER) IS SELECT NAME FROM USER WHERE TYPEID=C_ID;
  OPEN C_USER(变量值);
FETCH C_USER INTO V_NAME;
  EXIT WHEN FETCH C_USER%NOTFOUND;
CLOSE C_USER;
```

### 6.8 用pl/sql developer debug

连接数据库后建立一个Test WINDOW,在窗口输入调用SP的代码,F9开始debug,CTRL+N单步调试

## 七、关于oracle存储过程的若干问题备忘

1. 在oracle中，数据表别名不能加as，如：

    ```sql
    select a.appname from appinfo a;-- 正确
    select a.appname from appinfo as a;-- 错误

    ```
2. 在存储过程中，select某一字段时，后面必须紧跟into，如果select整个记录，利用游标的话就另当别论了。

    ```sql
    select af.keynode into kn from APPFOUNDATION af 
       where af.appid=aid and af.foundationid=fid;-- 有into，正确编译
    select af.keynode from APPFOUNDATION af 
     where af.appid=aid and af.foundationid=fid;-- 没有into，编译报错，提示：Compilation Error: PLS-00428: an INTO clause is expected in this SELECT statement

    ```
3. 在利用select…into…语法时，必须先确保数据库中有该条记录，否则会报出”no data found”异常。
    可以在该语法之前，先利用select count(\*) from 查看数据库中是否存在该记录，如果存在，再利用select…into…
4. 在存储过程中，别名不能和字段名称相同，否则虽然编译可以通过，但在运行阶段会报错

    ```sql
     --正确
    select keynode into kn from APPFOUNDATION where appid=aid and foundationid=fid;
    --错误
    select af.keynode into kn from APPFOUNDATION af 
     where af.appid=appid and af.foundationid=foundationid;
    -- 运行阶段报错，提示ORA-01422:exact fetch returns more than requested number of rows
    ```
5. 在存储过程中，关于出现null的问题
    假设有一个表A，定义如下：

    ```sql
    create table A(
    id varchar2(50) primary key not null,
    vcount number(8) not null,
    bid varchar2(50) not null -- 外键 
    );

    ```

    如果在存储过程中，使用如下语句：

    ```sql
    select sum(vcount) into fcount from A where bid='xxxxxx';

    ```

    如果A表中不存在bid=”xxxxxx”的记录，则fcount=null(即使fcount定义时设置了默认值，如：fcount number(8):=0依然无效，fcount还是会变成null)，这样以后使用fcount时就可能有问题，所以在这里最好先判断一下：

    ```sql
    if fcount is null then
        fcount:=0;
    end if;

    ```
6. ​`Hibernate`​调用oracle存储过程

    ```java
    this.pnumberManager.getHibernateTemplate().execute(
       new HibernateCallback() {
           public Object doInHibernate(Session session)
                   throws HibernateException, SQLException {
               CallableStatement cs = session
                       .connection()
                       .prepareCall("{call modifyapppnumber_remain(?)}");
               cs.setString(1, foundationid);
               cs.execute();
               return null;
           }
       });

    ```

‍

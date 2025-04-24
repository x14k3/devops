# other-ORACLE数据库中ORACLE_SID与INSTANCE_NAME的差异

‍

ORACLE数据库中ORACLE\_SID与INSTANCE\_NAME在概念和意义上有什么异同呢？下面简单来总结概况一下，很多时候，不少人都搞不清楚两者的异同，甚至认为两者是等价的。

### ORACLE\_SID与INSTANCE\_NAME的异同

ORACLE\_SID参数是操作系统的环境变量，用于和操作系统进行交互。也用于定义一些数据库参数文件的名称。

例如 init<ORACLE\_SID>.ora ，spfile<ORACLE\_SID>.ora等。

有些目录名称也跟ORACLE\_SID有关。例如参数core\_dump\_dest对应的目录中会包含ORACLE\_SID名称的文件夹（mydb）。

```sql
SQL> show parameter core_dump_dest

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
core_dump_dest                       string      /opt/oracle19c/diag/rdbms/mydb
                                                 /mydb/cdump
SQL> 
```

另外，ORACLE\_SID其实主要用于本地连接，例如，一台服务器上有多个Oracle实例，我们必须使用ORACLE\_SID来识别区分。它的值一般位于/etc/oratab,~/.bash\_profile中，不同操作系统可能有所不同。后面我们会详细讲述。

INSTNACE\_NAME是参数文件（pfile&spfile）中的一个初始化参数，它用来标识数据库实例的名称，其缺省值就是ORACLE\_SID，所以很多时候我们认为实例名就是ORACLE\_SID， 不同的实例可以拥有相同的INSTANCE\_NAME。官方文档的解释如下：

> Note: The SID identifies the instance's shared memory on a host, but may not uniquely distinguish this instance from other instances.

‍

**实例的SID**

注：数据库实例的SID标识主机上实例的共享内存，但不能将此实例与其他实例区分开来。

总统来说，INSTANCE\_NAME是Oracle数据库参数。而ORACLE\_SID是操作系统的环境变量。 默认情况下，INSTANCE\_NAME和在环境变量里面配置的ORACLE\_SID是同样的名称。（注：正是由于这个原因，网上有些资料说SID就是INSTANCE\_NAME，但是需要注意的是，实际上INSTANCE\_NAME不等于ORACLE\_SID。前者是数据库层面的概念，后者是操作系统中环境变量的设置。）

> ORACLE\_SID is used to distinguish this instance from other Oracle Database instances that you may create later and run concurrently on the same host computer. The maximum number of characters for ORACLE\_SID is 12, and only letters and numeric digits are permitted. On some platforms, the SID is case-sensitive.

INSTANCE\_NAME与ORACLE\_SID默认情况下是相同的。其实ORACLE\_SID与INSTANCE\_NAME本来没有什么关系。当操作系统与数据库交互时，用的是ORACLE\_SID，而当外部连接于数据库进行交互时用的是INSTANCE\_NAME。当同一台服务器安装了多个数据库时，操作系统利用ORACLE\_SID来区分不同实例的进程，而当我们与这台服务器的不同的数据库进行连接时，用INSTANCE\_NAME来决定具体连接哪个数据库：在监听器动态注册时还会用于向监听器注册

另外，需要注意的是v$instance下instance\_name与参数instance\_name的区别，v$thread中instance与instance\_name的区别，下面我们来演示一下：

```sql
$ echo $ORACLE_SID
mydb
$ env |grep ORACLE_SID
ORACLE_SID=mydb

SQL> set linesize 640;
SQL> select instance_name from v$instance;

INSTANCE_NAME
----------------
mydb

1 row selected.

SQL> select instance from v$thread;

INSTANCE
------------------------------------------------------------------
mydb

1 row selected.

SQL> show parameter instance_name;

NAME                                 TYPE        VALUE
------------------------------------ ----------- -----------------
instance_name                        string      mydb
SQL>
```

然后我们修改一下参数instance\_name的值:

```
SQL> alter system set instance_name=kerry_test scope=spfile;
```

重启数据库实例后，我们再验证确认一下啊。如下所示：

```sql
SQL> set linesize 640;
SQL> select instance_name from v$instance;

INSTANCE_NAME
----------------
mydb

1 row selected.

SQL> select instance from v$thread;

INSTANCE
--------------------------------------------------------------------
mydb

1 row selected.

SQL> show parameter instance_name;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
instance_name                        string      KERRY_TEST
SQL>
SQL> col value for a30;
SQL> select value from v$parameter where name='instance_name';

VALUE
------------------------------
KERRY_TEST

1 row selected.

SQL>
```

如上所示，v$instance中的instance\_name的值其实是ORACLE\_SID的值,v$thread中的instance值也是ORACLE\_SID的值，而不是参数instance\_name的值。

### 查看ORACLE\_SID的值

#### Window平台

方法1：注册表查看

HKEY\_LOCAL\_MACHINE > SOFTWARE > ORACLE> KEY\_xxxxx

例子：

HKEY\_LOCAL\_MACHINE\\SOFTWARE\\ORACLE\\KEY\_OraDB19Home1 下查看ORACLE\_SID

方法2：

```
echo %ORACLE_SID%
```

如果没有设置环境变量的话，这个方法是无效的。一般我们需要通过注册表来查看。如果没有设置环境变量，我们可以使用命令设置当前窗口的ORACLE\_SID值

```
set ORACLE_SID=gsp
```

方法3：

```
select instance from v$thread;
```

方法4：

```
select instance_name from v$instance;
```

#### Linux/Unix平台

方法1：echo $ORACLE\_SID

例子：

```
$ echo $ORACLE_SID
gsp
```

方法2：

```
ps -ef | grep ora_pmon_ | grep -v grep
```

例子：

如下所示，这个HP-UX上有两个实例，你如果用方法1，只能看到当前的ORACLE\_SID

```
$ ps -ef | grep ora_pmon_ | grep -v grep
oracle    5732     1  0 Sep06 ?        00:05:14 ora_pmon_hsfa
oracle   14458     1  0 Aug18 ?        00:05:55 ora_pmon_ctest
```

在多实例中切换，可以使用下面命令：

```
export $ORACLE_SID=ctest
```

例子：当前环境的ORACLE\_SID为mydb

```
$ ps -ef | grep ora_pmon_ | grep -v grep
oracle   32272     1  0 17:07 ?        00:00:01 ora_pmon_mydb
```

方法3：

```
/etc/oratab
```

注意，从配置文件/etc/oratab查询ORACLE\_SID，只能说可以，并不一定就能准确找出，例如，多实例的环境。这个只是仅供参考的方法。

方法4：

```
select instance from v$thread;
```

方法5

```
select instance_name from v$instance;
```

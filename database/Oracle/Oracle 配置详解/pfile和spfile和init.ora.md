#oracle

当一个oracle实例启动的时候,这个实例的特性是通过初始化参数文件(initialization parameter file)中指定的参数获得的。初始化参数存储在文本格式的pfile或者二进制格式的spfile中，oracle 9i或更高的版本使用spfile,而之前的版本使用pfile。

**spflie比pfile有很多优点：**

- 可以用RMAN来备份spfile,但是不能备份pfile
- 减少了人为的错误。spfile由服务器来管理，任何参数改变被接受前都会经过严格的检查
- 消除了配置问题，如果远程启动oracle服务器，不再需要一个本地的pfile

**spfile与pfile的不用点**

pfile是一个静态的客户端文本文件，可以使用标准的文本编辑器如vim或emacs来编辑。这个文件通常是保存在服务器上的，然而如果你想远程启动oracle服务器，则你需要pfile的一个本地拷贝，DBA通常称此文件为INIT.ORA文件。

然而spfile(Server Parameter File)是一直存在于服务器端的二进制文件，只能使用“ALTER SYSTEM SET”命令来修改。使用spfile,不再需要一个pfile的本地拷贝来远程启动数据库。试图编辑spfile会使其损坏，从而使数据库无法启动。

**如何知道数据库使用spfile还是pfile**

1、执行以下查询  
SQL\> SELECT DECODE(value, NULL, ‘PFILE’, ‘SPFILE’) “Init File Type”  
FROM sys.v\_\$parameter WHERE name \= ‘spfile’;

2、查看spfile参数值  
SQL\>show parameters spfile

如果有值说明使用spfile启动，反之pfile

3、还可以使用V\$SPPARAMETER视图来确定使用的是spfile还是pfile,如果所有参数的value列都是null,那么使用的是pfile,否则是spfile。

**查看参数设置**

可以使用以下方法查看参数设置,无论参数是通过pfile或者spfile来设置的

- 从sqlplus里面使用”SHOW PARAMETERS”命令,比如SQL\>show parameter sga\_target;
- 通过V\$PARAMETER视图查看当前实际的参数值
- 通过V\$PARAMETER2视图查看当前实际的参数值,”List Values”多行显示
- 通过V\$SPPARAMETER视图，查看server parameter file的当前值

**使用spfile或pfile启动数据库**

oracle按以下顺序搜索合适的初始化参数文件：

- 尝试使用\$ORACLE\_HOME/dbs (Unix) or ORACLE\_HOME/database (Windows)路径下的spfile\${ORACLE\_SID}.ora文件
- 尝试使用\$ORACLE\_HOME/dbs (Unix) or ORACLE\_HOME/database (Windows)路径下的spfile.ora文件
- 尝试使用\$ORACLE\_HOME/dbs (Unix) or ORACLE\_HOME/database (Windows)路径下的init\${ORACLE\_SID}.ora文件

前两个是spfile，最后一个是pfile,\${ORACLE\_SID}部分一定要大写。

也可以为startup命令的pfile语句指定一个pfile来替代默认的初始化参数文件  
SQL\> STARTUP PFILE\=’/path/to/pfile’

注意并没有”STARTUP SPFILE\=”这样一个命令，也就是并不能直接指定一个spfile来启动数据库，但可以通过以下方法来使用非默认的spfile启动数据库：

1、创建一个只有一行的pfile,这一行用来指定spfile参数,参数的值即为一个非默认的spfile，比如创建一个pfile /u01/oracle/dbs/spf\_init.ora只包含下面的行  
SPFILE \= /u01/oracle/dbs/test\_spfile.ora

2、用上一步创建的初始化参数文件启动实例  
STARTUP PFILE \= /u01/oracle/dbs/spf\_init.ora

这样就可以间接的用非默认的spfile来启动实例了，这个spfile必须位于数据库服务器上。这样也不需要客户机器维护一个客户端的初始化参数文件，当客户端机器发现初始化参数文件包含一个spfile参数，它就会告诉服务器指定的spfile从哪里读取。

**在pfile和spfile之间转换**

可以很容易的在pfile和spfile之间进行转行，以SYSDBA或SYSOPER角色执行一下命令：  
SQL\> CREATE PFILE FROM SPFILE;  
SQL\> CREATE SPFILE FROM PFILE;

也可以指定非缺省的pfile或spfile位置，可以二者都指定非缺省的位置，比如：  
SQL\> CREATE SPFILE\=’/oradata/spfileORCL.ora’ from PFILE\=’/oradata/initORCL.ora’;

**参数文件备份**

如果设置”CONFIGURE CONTROLFILE AUTOBACKUP”为”ON”（该参数默认值为”OFF”）,RMAN会在备份控制文件的同时备份参数文件，RMAN不能备份pfile,比如

RMAN\> CONFIGURE CONTROLFILE AUTOBACKUP ON;

使用如下的命令恢复参数文件：  
RMAN\> RESTORE CONTROLFILE FROM AUTOBACKUP;

**改变spfile参数值**

pfile可以用任何文本编辑器进行编辑，spfile是二进制文件，可以使用”ALTER SYSTEM SET”和”ALTER SYSTEM RESET”命令来改变spfile参数值，格式如下  
SQL\> ALTER SYSTEM SET parameter\_name\=value SCOPE\=MEMORY SPFILE BOTH;

SCOPE参数值的含义如下：  
MEMORY - 只设置当前实例。如果使用pfile启动数据库，这是默认的行为。  
SPFILE - 更新spfile,参数值将会在数据库下一次启动后生效。  
BOTH - 设置当前实例，并更新spfile。如果使用spfile启动数据库，这是默认的行为。

另一种改变spfile参数的方法是将spfile转换到pfile,用文本编辑器编辑参数，然后再转换回spfile启动数据库，步骤如下：  
1、导出spfile到pfile。  
SQL\>CREATE PFILE\=’pfilename’ FROM SPFILE \=’spfilename’;

2、使用文本编辑器编辑导出的pfile

3、关闭然后使用pfile启动数据库  
SQL\> STARTUP PFILE\=pfile\_name;

4、重新创建spfile  
SQL\>CREATE SPFILE\=’spfilename’ FROM PFILE\=’pfilename’;

5、关闭然后不使用参数启动数据库  
SQL\>STARTUP

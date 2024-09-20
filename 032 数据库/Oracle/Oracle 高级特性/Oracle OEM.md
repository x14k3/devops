# Oracle OEM

　　Oracle OEM（Oracle Enterprise  Manager）是Oracle公司提供的一款用于管理和维护Oracle数据库的工具，它可以帮助用户轻松地掌控服务器实例，本文将详细介绍如何使用Oracle OEM管理命令来监控和管理Oracle数据库。

　　‍

　　安装完数据库后自动启动EM，也可通过如下命令启停和查看

　　19c

```sql
--启动
exec DBMS_XDB_CONFIG.SETHTTPSPORT(5500);

--停止
exec DBMS_XDB_CONFIG.SETHTTPSPORT(0);

--检查
SELECTdbms_xdb_config.gethttpsport FROM DUAL;
```

　　‍

　　访问地址：

　　https://10.10.133.1:5500/em/     #输入Username和Password，不用输入Container Name

　　‍

　　从Oracle Database 19c开始，Oracle不再推荐Flash-base的Enterprise Manager Express(EM Express)，缺省采用Java JET技术。也可通过如下命令切换：

```sql
--切换为Flash-based的EM Express
SQL> @?/rdbms/admin/execemx emx

--切换为Java JET的EM Express
SQL> @?/rdbms/admin/execemx omx
```

　　另外由于配置DG BROKER修改了tnsnames.ora文件，数据库中local\_listener参数不正确，修改后正常。

　　部分截图如下：

​![截图 2024-07-26 15-45-24](assets/截图%202024-07-26%2015-45-24-20240726154534-wuu50tf.png)​

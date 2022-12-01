#database/dm8 

### 达梦数据库修改最大连接数
```sql
--查看最大连接数
select SF_GET_PARA_VALUE(2,'MAX_SESSIONS');
--查询当前用户连接数
select count(*) from v$sessions where state='ACTIVE';
--修改最大连接数
--1.使用SQL命令
ALTER SYSTEM SET 'MAX_SESSIONS' =1000 spfile; 
commit;

--2.修改配置文件
--修改`dm.ini`文件中配置`MAX_SESSIONS`
#database
MAX_SESSIONS   = 1000
```

### 会话信息
```sql
--包括连接信息、会话信息；涉及的动态视图有V$CONNECT、V$STMTS、V$SESSIONS等。
--例如查看会话信息。
SELECT SESS_ID,SQL_TEXT,STATE,CREATE_TIME,CLNT_HOST FROM V$SESSIONS;
```

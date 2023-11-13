# Oracle 优化 & 安全配置

## 最大连接数优化

```sql
-- 1、查看当前的数据库进程连接数
select count(*) from v$process;
-- 2、查看当前的数据库会话连接数
select count(*) from v$session;
-- 3、数据库允许的最大连接数
select value from v$parameter where name ='processes';
-- 4、修改数据库最大连接数
alter system set processes = 1000 scope = spfile;
-- 5、关闭/重启数据库
shutdown immediate;
startup;
-- 6.另外可以查看并发连接数
select count() from v$session where status='ACTIVE';
```

## 密码相关

```sql
-- 密码有效期(无期)
-- Oracle数据库密码期限是180，把它改成无限制
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

-- 查看锁定用户的密码最大输入错误次数
select * from dba_profiles where resource_name = 'FAILED_LOGIN_ATTEMPTS';
-- 设置最大失败次数 
alter profile default limit FAILED_LOGIN_ATTEMPTS 30; 
-- 设置无限失败次数 
alter profile default limit FAILED_LOGIN_ATTEMPTS unlimited;
-- 帐号被锁定后，只要超过了1小时，帐号自动解锁
alter profile default limit password_lock_time 1/24;
 -- 用户解锁
alter user root account unlock;
-- 修改密码
alter user 用户名 identified by 原密码;

```

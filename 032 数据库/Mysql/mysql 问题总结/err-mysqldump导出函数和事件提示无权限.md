# err-mysqldump导出函数和事件提示无权限

　　无权限提示为：

```sql
mysqldump: 你的mysql备份用户名 has insufficent privileges to SHOW CREATE FUNCTION!
```

　　解决：

```bash
# 使用root用户增加一个授权
GRANT SELECT ON mysql.proc to '你的mysql备份用户名';
```

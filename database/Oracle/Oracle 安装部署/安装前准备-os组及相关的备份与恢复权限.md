
‍

|OS组|数据库系统权限|可执行的操作|引用位置|
| -------------------------| ---------------------------| --------------------------------------------------------------| --------------------------------------------------------------------------------------------------|
|oinstall|无|安装和升级Oracle程序|oraInst.loc文件中的insta_group变量；还可以在应答文件中使用UNIX_GROUP_NAME变量定义|
|dba|sysdba|数据库中的一切操作|应答文件中的DBA_GROUP|
|oper|sysoper|启动、关闭和修改数据库，切换日志归档模式，备份与恢复数据库|应答文件中的OPER_GROUP|
|asmdba|Sysdba的自动存储管理权限|管理Oracle自动存储管理（ASM）实例|无|
|asmoper|Sysoper的自动存储管理权限|启动和停止Oracle ASM 实例|无|
|asmadmin|sysasm|挂载和卸载磁盘组与管理其他存储设备|无|
|backupdba|sysbackup|这是Oracle 12c中引入的新功能，启动、关闭和执行所有备份与恢复|应答文件中的BACKUPDBA_GROUP|
|dgdba|sysdg|这是Oracle 12c中引入的新功能，管理Data Guard 环境的相关操作|应答文件中的DGDBA_GROUP|
|kmdba|syskm|这是Oracle 12c中引入的新功能，加密管理的相关操作<br />|应答文件中的KMDBA_GROUP|

‍

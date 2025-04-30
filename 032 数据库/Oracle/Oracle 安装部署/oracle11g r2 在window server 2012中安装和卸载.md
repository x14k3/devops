# oracle11g r2 在window server 2012中安装和卸载

无法安装.net framework 3.5

* ((20230904114337-x5mdkqf '离线安装.NET Framework 3.5'))

Oracle11完全卸载bai方法

1. 在oracle11G以前du卸载oracle会存在卸载不干净，导致再次安装失败的zhi情况，在运行services.msc打开服dao务，停止Oracle的所有服务。

2. oracle11G自带一个卸载批处理\app\Administrator\product\11.2.0\dbhome_1\deinstall\deinstall.bat运行该批处理程序将自动完成oracle卸载工作，最后手动删除\app文件夹（可能需要重启才能删除）  
    运行过程中可能需要填写如下项：  
    指定要取消配置的所有单实例监听程序[LISTENER]:LISTENER  
    指定在此 Oracle 主目录中配置的数据库名的列表 [MYDATA,ORCL]: MYDATA,ORCL  
    是否仍要修改 MYDATA,ORCL 数据库的详细资料? [n]: n  
    CCR check is finished  
    是否继续 (y - 是, n - 否)? [n]: y

3. 运行regedit命令，打开注册表。删除注册表中与Oracle相关内容，具体下：  
    删除HKEY_LOCAL_MACHINE/SOFTWARE/ORACLE目录。  
    删除HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services中所有以oracle或OraWeb为开头的键。  
    删除HKEY_LOCAL_MACHINE/SYSETM/CurrentControlSet/Services/Eventlog/application中所有以oracle开头的键。  
    删除HKEY_CLASSES_ROOT目录下所有以Ora、Oracle、Orcl或EnumOra为前缀的键。  
    删除HKEY_CURRENT_USER/SOFTWARE/Microsoft/windows/CurrentVersion/Explorer/MenuOrder/Start Menu/Programs中所有以oracle 开头的键。  
    删除HKDY_LOCAL_MACHINE/SOFTWARE/ODBC/ODBCINST.INI中除Microsoft ODBC for Oracle注册表键以外的所有含有Oracle的键。  
    删除环境变量中的PATHT CLASSPATH中包含Oracle的值。  
    删除“开始”/“程序”中所有Oracle的组和图标。  
    删除所有与Oracle相关的目录，包括：（1）、c:\Program file\Oracle目录。 （2）、ORACLE_BASE目录。（3）、c:\Documents and Settings\系统用户名、LocalSettings\Temp目录下的临时文件。

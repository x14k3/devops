# WMIC

## WMIC命令使用帮助文档

```
[global switches] <command>

以下全局开关可用：

/NAMESPACE                  别名操作的命名空间的路径。
/ROLE                       包含别名定义的角色的路径。
/NODE                       别名将对其进行操作的服务器。
/IMPLEVEL                   客户端模拟级别。
/AUTHLEVEL                  客户端身份验证级别。
/LOCALE                     客户端应使用的语言ID。
/PRIVILEGES                 启用或禁用所有权限。
/TRACE                      将调试信息输出到stderr。
/RECORD                     记录所有输入命令和输出。
/INTERACTIVE                设置或重置交互模式。
/FAILFAST                   设置或重置FailFast模式。
/USER                       在会话期间使用的用户。
/PASSWORD                   用于会话登录的密码。
/OUTPUT                     指定输出重定向的模式。
/APPEND                     指定输出重定向的模式。
/AGGREGATE                  设置或重置聚合模式。
/AUTHORITY                  指定连接的<authority type>。
/?[：<BRIEF | FULL>]        使用信息。

有关特定全局开关的更多信息，请键入：switch-name /？

当前角色中提供了以下别名/ es：

ALIAS                        - 访问本地系统上可用的别名
BASEBOARD                    - 基板（也称为主板或系统板）管理。
BIOS                         - 基本输入/输出服务（BIOS）管理。
BOOTCONFIG                   - 引导配置管理。
CDROM                        - CD-ROM管理。
COMPUTERSYSTEM               - 计算机系统管理。
CPU                          - CPU管理。
CSPRODUCT                    - 来自SMBIOS的计算机系统产品信息。
DATAFILE                     - DataFile管理。
DCOMAPP                      - DCOM应用程序管理。
DESKTOP                      - 用户的桌面管理。
DESKTOPMONITOR               - 桌面监视器管理。
DEVICEMEMORYADDRESS          - 设备内存地址管理。
DISKDRIVE                    - 物理磁盘驱动器管理。
DISKQUOTA                    - NTFS卷的磁盘空间使用情况。
DMACHANNEL                   - 直接内存访问（DMA）通道管理。
ENVIRONMENT                  - 系统环境设置管理。
FSDIR                        - 文件系统目录条目管理。
GROUP                        - 集团账户管理。
IDECONTROLLER                - IDE控制器管理。
IRQ                          - 中断请求线（IRQ）管理。
JOB                          - 提供对使用计划服务计划的作业的访问。

LOADORDER                   - 管理定义执行依赖性的系统服务。
LOGICALDISK                 - 本地存储设备管理。
LOGON                       - 登录会话。
MEMCACHE                    - 缓存内存管理。
MEMORYCHIP                  - 存储芯片信息。
MEMPHYSICAL                 - 计算机系统的物理内存管理。
NETCLIENT                   - 网络客户端管理。
NETLOGIN                    - （特定用户的）网络登录信息管理。
NETPROTOCOL                 - 协议（及其网络特征）管理。
NETUSE                      - 主动网络连接管理。
NIC                         - 网络接口控制器（NIC）管理。
NICCONFIG                   - 网络适配器管理。
NTDOMAIN                    - NT域管理。
NTEVENT                     - NT事件日志中的条目。
NTEVENTLOG                  - NT事件日志文件管理。
ONBOARDDEVICE               - 管理主板（系统板）内置的通用适配器设备。

OS                          - 已安装的操作系统/管理。
PAGEFILE                    - 虚拟内存文件交换管理。
PAGEFILESET                 - 页面文件设置管理。
PARTITION                   - 管理物理磁盘的分区区域。
PORT                        - I / O端口管理。
PORTCONNECTOR               - 物理连接端口管理。
PRINTER                     - 打印机设备管理。
PRINTERCONFIG               - 打印机设备配置管理。
PRINTJOB                    - 打印作业管理。
PROCESS                     - 进程管理。
PRODUCT                     - 安装包任务管理。
QFE                         - 快速修复工程。
QUOTASETTING                - 设置卷上磁盘配额的信息。
RDACCOUNT                   - 远程桌面连接权限管理。
RDNIC                       - 特定网络适配器上的远程桌面连接管理。
RDPERMISSIONS               - 特定远程桌面连接的权限。
RDTOGGLE                    - 远程打开或关闭远程桌面监听器。
RECOVEROS                   - 操作系统出现故障时将从内存中收集的信息。
REGISTRY                    - 计算机系统注册表管理.
SCSICONTROLLER           - SCSI 控制器管理。
SERVER                   - 服务器信息管理。
SERVICE                  - 服务程序管理。
SHARE                    - 共享资源管理。
SOFTWAREELEMENT          - 安装在系统上的软件产品元素的管理。
SOFTWAREFEATURE          - SoftwareElement 的软件产品组件的管理。
SOUNDDEV                 - 声音设备管理。
STARTUP                  - 用户登录到计算机系统时自动运行命令的管理。
SYSACCOUNT               - 系统帐户管理。
SYSDRIVER                - 基本服务的系统驱动程序管理。
SYSTEMENCLOSURE          - 物理系统封闭管理。
SYSTEMSLOT               - 包括端口、插口、附件和主要连接点的物理连接点管理。
TAPEDRIVE                - 磁带驱动器管理。
TEMPERATURE              - 温度感应器的数据管理 (电子温度表)。
TIMEZONE                 - 时间区域数据管理。
UPS                      - 不可中断的电源供应 (UPS) 管理。
USERACCOUNT              - 用户帐户管理。
VOLTAGE                  - 电压感应器 (电子电量计) 数据管理。
VOLUMEQUOTASETTING       - 将某一磁盘卷与磁盘配额设置关联。
WMISET                   - WMI 服务操作参数管理。

 

有关CLASS / PATH / CONTEXT的更多信息，请键入：（CLASS | PATH | CONTEXT）/？
```

### 配置ip地址

```bat
rem 配置或更新IP地址：
wmic nicconfig where index=0 call enablestatic ("192.168.1.5"),("255.255.255.0")
rem index=0说明是配置网络接口1

rem 配置网关（默认路由）：
wmic nicconfig where index=0 call setgateways("192.168.1.1"),(1)


rem 获取已连接网卡的名字、速率
wmic NIC where NetEnabled=true get Name, Speed
wmic NIC where NetEnabled=true get guid

rem 获取已IP地址网卡的index、caption
wmic nicconfig where IPEnabled="true" get Index, Caption
```

‍

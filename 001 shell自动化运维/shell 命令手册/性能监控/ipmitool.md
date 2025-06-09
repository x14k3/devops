# ipmitool

# 1. ipmitool使用

ipmitool这个程序能够使你通过一个kernel设备驱动或者一个远程系统，利用IPMI v1.5或IPMIv2.0来管理本地系统的任何一个智能平台管理接口（IPMI)功能。 这些功能包括打印FRU（现场可替换装置）信息、LAN配置、传感器读数、以及远程机架电源控制。  一个本地系统接口的IPMI管理功能需要一个兼容IPMI的kernel驱动程序被安装以及配置。在linux中，这个驱动叫做OpenIPMI，他被包括在了标准化分配中。在Solaris系统中，这个驱动叫做BMC，他被包括在了Solaris 10中。远程控制的管理需要授权以及配置IPMI-over-LAN接口。根据每个系统独特的需要，它可以通过系统接口来使LAN接口使用  ipmitool。

## 1.1. 获取帮助信息

```bash
yum install ipmitool
#安装完成后需要加载模块
#modprobe ipmi_watchdog
#modprobe ipmi_poweroff
#modprobe ipmi_devintf
#modprobe ipmi_si  
#modprobe ipmi_msghandler 

ipmitool help
#ipmitool chassis help
Chassis Commands:  status, power, identify, policy, restart_cause, poh, bootdev, bootparam, selftest
```

## 1.2. 带外接口

访问带外时需要指定访问接口类型，默认是本地openIPMI接口。 常用的主要有open/lan/lanplus这三种

|接口种类||
| -----------------| -------------------------------------------------------------------------|
|open|Linux OpenIPMI 接口 [默认的接口]|
|imb|Intel IMB 接口|
|lan|IPMI v1.5 LAN 接口,最大密码长度为16个字符。超过16字符的密码部分将被去掉|
|lanplus|IPMI v2.0 RMCP+ LAN 接口,最大密码长度为20个字符;较长的密码将被截断|
|serial-terminal|串行接口, 终端模式|
|serial-basic|串行接口, 基础模式|
|usb|IPMI USB 接口(OEM 接口 for AMI 设备)|

## 1.3. 传感器信息(sensor)

### 1.3.1. 获取传感器所有数据

```
Ipmitool sensor list
```

获取传感器中的各种监测值和该值的监测阈值，包括（CPU温度，电压，风扇转速，电源调制模块温度，电源电压等信息）

### 1.3.2. 获取传感器指定值

```
Ipmitool sensor get "CPU0Temp"
```

获取ID为CPU0Temp监测值，CPU0Temp是sensor的ID，服务器不同，ID表示也不同

### 1.3.3. 传感器阀值

```
Ipmitool –I open sensor thresh 
```

设置ID值等于id的监测项的各种限制值

## 1.4. 系统事件日志管理 (sel)

### 1.4.1. ipmitool sel help

```
#ipmitool sel help
SEL Commands:  info clear delete list elist get add time save readraw writeraw interpret
```

|ipmitool sel [命令]|描述|
| ---------------------| ----------------------|
|info|查看SEL信息|
|clear|清除系统事件日志|
|delete||
|list|查看系统时间日志列表|
|get||
|add||
|time||
|save||
|time||
|save||
|readraw||
|writeraw||
|interpret||

如果系统事件日志量较大，会导致带外存储不足，在获取信息时会卡住。如果确认日志不需要可以清除系统日志

## 1.5. 电源管理(power)

### 1.5.1. ipmitool power help

```
#ipmitool power help
chassis power Commands: status, on, off, cycle, reset, diag, soft
```

|ipmitool power [命令]|描述|
| -----------------------| --------------------|
|status|查看电源状态|
|on|服务器上电|
|off|服务器下电|
|cycle|-|
|reset|关闭电源并重启机器|
|diag|-|
|soft|-|

## 1.6. 磁盘管理

查看底盘状态，其中包括了底盘电源信息，底盘工作状态等

### 1.6.1. ipmitool chassis help

```
#ipmitool chassis help
Chassis Commands:  status, power, identify, policy, restart_cause, poh, bootdev, bootparam, selftest
```

|ipmitool chassis [命令]|描述|
| -------------------------| ------------------------------------------------------|
|status|查看底盘状态，其中包括了底盘电源信息，底盘工作状态等|
|power||
|identify|控制前面板标识灯。默认值是 15。使用 0 关闭。|
|policy||
|policy list|查看支持的底盘电源相关策略|
|restart\_cause|查看上次系统重启的原因|
|poh||
|bootdev|pxe/disk/cdrom 设置下次开机引导方式|
|bootparam||
|selftest||

|bootdev 引导方式设置||
| ----------------------| -----------------------------|
|pxe|设置下次启动为 网络pxe引导|
|disk|设置下次启动为 本地磁盘引导|
|cdrom|设置下次启动为 为光盘引导|

## 1.7. MC芯片管理(mc/bmc)

### 1.7.1. #ipmitool bmc help

```
#ipmitool bmc help
MC Commands:
  reset <warm|cold>
  guid
  info
  watchdog <get|reset|off>
  selftest
  getenables
  setenables <option=on|off> ...
    recv_msg_intr         接收消息队列中断
    event_msg_intr        事件消息缓冲区满中断
    event_msg             事件消息缓冲区
    system_event_log      系统事件日志记录
    oem0                  oem定义选项#0 
    oem1                  oem定义选项#1 
    oem2                  oem定义选项#2
```

|ipmitool bmc [命令]|描述|
| ---------------------| -----------------------------------------------------------------------------------------|
|reset|指示BMC执行一个warm或cold得复位重启|
|guid||
|info|显示BMC硬件的信息，包括了设备版本、固件版本、IPMI版本支持、制造商id、额外设备支持的信息|
|watchdog||
|selftest||
|getenables|列出BMC所有允许的选项|
|setenables|设置bmc相应的允许/禁止选项|

## 1.8. 通道管理 (channel)

```
#ipmitool channel  help
Channel Commands: authcap   <channel number> <max privilege>
                  getaccess <channel number> [user id]
                  setaccess <channel number> <user id> [callin=on|off] [ipmi=on|off] [link=on|off] [privilege=level]
                  info      [channel number]
                  getciphers <ipmi | sol> [channel]

                  setkg hex|plain <key> [channel]

Possible privilege levels are:
   1   Callback level
   2   User level
   3   Operator level
   4   Administrator level
   5   OEM Proprietary level
  15   No access
```

|ipmitool channel [命令]|描述|
| -------------------------| --------------------------------------------------------|
|authcap|显示有关选定的信息通道的身份验证功能，在指定的权限级别|
|||
|||
|||
|||

## 1.9. 用户管理

说明：[ChannelNo] 字段是可选的，ChannoNo为1或者8；BMC默认有2个用户：user id为1的匿名用户，user id为2的ADMIN用户；<>字段为必选内容；<privilege level>：2为user权限，3为Operator权限，4为Administrator权限；

```bash
#1. 查看用户信息：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) user list [ChannelNo]
#2. 增加用户：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) user set name <user id> <username>
#3. 设置密码：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) user set password <user id> <password>
#4. 设置用户权限：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) user priv <user id> <privilege level> [ChannelNo]
#5. 启用/禁用用户：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) user enable/disable <user id>
```

## 1.10. 远程登录

```
ipmitool -I lanplus -H $host -U $username -P $pwd chassis status
```

远程登录带外并执行命令

- -I : 接口类型
- -H : 带外IP地址
- -U : 带外登录用户名
- -P : 带外登录密码

## 1.11. 带外网络管理

### 1.11.1. 查看带外网络

```
ipmitool lan print
```

|lan print 输出解释|||
| --------------------| ---------------| ----------------------|
|IP Address Source|DHCP Address|带外IP配置的方式DHCP|
|IP Address|172.31.79.92|带外IP地址|
|Default Gateway IP|172.31.79.247|带外网关|

### 1.11.2. 设置带外网络

说明：[ChannelNo] 字段是可选的，ChannoNo为1(Share Nic网络)或者8（BMC独立管理网络）；设置网络参数，必须首先设置IP为静态，然后再进行其他设置；

```bash
#1. 查看网络信息：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) lan print [ChannelNo]
#2. 修改IP为静态还是DHCP模式：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) lan set <ChannelNo> ipsrc <static/dhcp>
#3. 修改IP地址：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) lan set <ChannelNo> ipaddr <IPAddress>
#4. 修改子网掩码：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) lan set <ChannelNo> netmask <NetMask>
#5. 修改默认网关：
ipmitool –H (BMC的管理IP地址) –I lanplus –U (BMC登录用户名) –P (BMC 登录用户名的密码) lan set <ChannelNo> defgw ipaddr <默认网关>
```

## 1.12. ipmitool帮助信息

```
#ipmitool  -h   
ipmitool version 1.8.11

usage: ipmitool [options...] <command>

       -h             This help
       -V             Show version information
       -v             Verbose (can use multiple times)
       -c             Display output in comma separated format
       -d N           Specify a /dev/ipmiN device to use (default=0)
       -I intf        Interface to use
       -H hostname    Remote host name for LAN interface
       -p port        Remote RMCP port [default=623]
       -U username    Remote session username
       -f file        Read remote session password from file
       -S sdr         Use local file for remote SDR cache
       -a             Prompt for remote password
       -Y             Prompt for the Kg key for IPMIv2 authentication
       -e char        Set SOL escape character
       -C ciphersuite Cipher suite to be used by lanplus interface
       -k key         Use Kg key for IPMIv2 authentication
       -y hex_key     Use hexadecimal-encoded Kg key for IPMIv2 authentication
       -L level       Remote session privilege level [default=ADMINISTRATOR]
                      Append a '+' to use name/privilege lookup in RAKP1
       -A authtype    Force use of auth type NONE, PASSWORD, MD2, MD5 or OEM
       -P password    Remote session password
       -E             Read password from IPMI_PASSWORD environment variable
       -K             Read kgkey from IPMI_KGKEY environment variable
       -m address     Set local IPMB address
       -b channel     Set destination channel for bridged request
       -t address     Bridge request to remote target address
       -B channel     Set transit channel for bridged request (dual bridge)
       -T address     Set transit address for bridge request (dual bridge)
       -l lun         Set destination lun for raw commands
       -o oemtype     Setup for OEM (use 'list' to see available OEM types)
       -O seloem      Use file for OEM SEL event descriptions

Interfaces:
    open          Linux OpenIPMI Interface [default]
    imb           Intel IMB Interface 
    lan           IPMI v1.5 LAN Interface 
    lanplus       IPMI v2.0 RMCP+ LAN Interface 

Commands:
    raw           Send a RAW IPMI request and print response
    raw           发送一个原始的IPMI请求，并且打印回复信息 
    i2c           Send an I2C Master Write-Read command and print response
    spd           Print SPD info from remote I2C device
    lan           Configure LAN Channels
    lan           配置网络（lan）信道(channel) 
    chassis       Get chassis status and set power state
    chassis       查看磁盘的状态和设置电源 
    power         Shortcut to chassis power commands
    event         Send pre-defined events to MC
    event         向BMC发送一个已经定义的事件（event），可用于测试配置的SNMP是否成功 
    mc            Management Controller status and global enables
    mc            查看MC（Management Contollor）状态和各种允许的项 
    sdr           Print Sensor Data Repository entries and readings
    sdr           打印传感器仓库中的所有监控项和从传感器读取到的值
    sensor        Print detailed sensor information
    sensor        打印详细的传感器信息 
    fru           Print built-in FRU and scan SDR for FRU locators
    fru           输出内嵌的FRU（现场可替换装置）和扫描FRU 定位器的SDR（系统定义记录） 
    gendev        Read/Write Device associated with Generic Device locators sdr
    sel           Print System Event Log (SEL)
    sel           打印 System Event Log (SEL) 
    pef           Configure Platform Event Filtering (PEF)
    pef           设置PEF，事件过滤平台用于在监控系统发现有event时候，用PEF中的策略进行事件过滤，然后看是否需要报警 
    sol           Configure and connect IPMIv2.0 Serial-over-LAN
    sol           用于配置通过串口的Lan进行监控,配置IPMIv2.0 Serial-over-LAN 
    tsol          Configure and connect with Tyan IPMIv1.5 Serial-over-LAN
    isol          Configure IPMIv1.5 Serial-over-LAN
    isol          用于配置通过串口的Lan进行监控 ,配置IPMIv1.5 Serial-over-LAN
    user          Configure Management Controller users
    user          设置BMC中用户的信息 
    channel       Configure Management Controller channels
    channel       配置管理控制器通道
    session       Print session information
    session       打印session信息 
    sunoem        OEM Commands for Sun servers
    kontronoem    OEM Commands for Kontron devices
    picmg         Run a PICMG/ATCA extended cmd
    fwum          Update IPMC using Kontron OEM Firmware Update Manager
    firewall      Configure Firmware Firewall
    delloem       OEM Commands for Dell systems
    shell         Launch interactive IPMI shell
    exec          Run list of commands from file
    exec          从文件中运行一系列的命令 
    set           Set runtime variable for shell and exec
    set           为shell和exec设置运行变量 
    hpm           Update HPM components using PICMG HPM.1 file
    ekanalyzer    run FRU-Ekeying analyzer using FRU files
```

‍

‍

```bash
# 电源管理
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4 power status  # 电源状态
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4 power on      # 开机
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4 power off     # 关机

# LED灯设置
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r chassis identify 0  # 系统 ID LED 设置,关闭闪烁
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r chassis identify 15 # 开启闪烁，每15s

# cpu温度
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r sensor get "Temp"

# 日志查看
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r sel list

# 用户管理
#1. 查看用户信息：
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r user list 
#2. 增加用户：
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r user set name <user id> <username>
#3. 设置密码：
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r user set password <user id> <password>
#4. 设置用户权限：
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r user priv <user id> <privilege level> 
#5. 启用/禁用用户：
ipmitool -I lanplus -H 10.10.128.222 -U root -P 1q2w3e4r user enable/disable <user id>
```

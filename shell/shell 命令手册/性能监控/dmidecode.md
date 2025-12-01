
**dmidecode命令** 可以让你在Linux系统下获取有关硬件方面的信息。dmidecode的作用是将DMI数据库中的信息解码，以可读的文本方式显示。由于DMI信息可以人为修改，因此里面的信息不一定是系统准确的信息。dmidecode遵循SMBIOS/DMI标准，其输出的信息包括BIOS、系统、主板、处理器、内存、缓存等等。

DMI（Desktop Management Interface,DMI）就是帮助收集电脑系统信息的管理系统，DMI信息的收集必须在严格遵照SMBIOS规范的前提下进行。SMBIOS（System Management BIOS）是主板或系统制造者以标准格式显示产品管理信息所需遵循的统一规范。SMBIOS和DMI是由行业指导机构Desktop Management Task Force(DMTF)起草的开放性的技术标准，其中DMI设计适用于任何的平台和操作系统。

DMI充当了管理工具和系统层之间接口的角色。它建立了标准的可管理系统更加方便了电脑厂商和用户对系统的了解。DMI的主要组成部分是Management Information Format(MIF)数据库。这个数据库包括了所有有关电脑系统和配件的信息。通过DMI，用户可以获取序列号、电脑厂商、串口信息以及其它系统配件信息。

### 语法

```
dmidecode [选项]
```

### 选项

```
-d：(default:/dev/mem)从设备文件读取信息，输出内容与不加参数标准输出相同。
-h：显示帮助信息。
-s：只显示指定DMI字符串的信息。(string)
-t：只显示指定条目的信息。(type)
-u：显示未解码的原始条目内容。
--dump-bin file：将DMI数据转储到一个二进制文件中。
--from-dump FILE：从一个二进制文件读取DMI数据。
-V：显示版本信息。
```

### 实例

```bash

# 需要sudo权限
sudo dmidecode -t 1    # 系统信息（System Information）
sudo dmidecode -t 2    # 基本主板信息（Base Board Information）
sudo dmidecode -t 4    # CPU信息（Processor Information）
sudo dmidecode -t 11   # 查看OEM信息 
sudo dmidecode -t 16   # 查询内存信息
sudo dmidecode -t 17   # 查看内存条数

sudo dmidecode -t processor # CPU信息
sudo dmidecode -t memory    # 查看内存信息
# 查看内存的插槽数，已经使用多少插槽。每条内存多大。
sudo dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v Range
# 查看内存支持的最大内存容量
sudo dmidecode|grep -P 'Maximum\s+Capacity'
# 查看内存的频率（查看内存信息的看Speed 项）
sudo dmidecode|grep -A16 "Memory Device"|grep 'Speed'

dmidecode |grep 'Product Name'  # 查看服务器型号 
dmidecode |grep 'Serial Number' # 查看主板的序列号 

cat /proc/scsi/scsi # 查看服务器硬盘信息
```

查看内存的插槽数，已经使用多少插槽。每条内存多大，已使用内存多大

```
dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v Range 

#   Size: 2048 MB
#   Size: 2048 MB
#   Size: 4096 MB
#   Size: No Module Installed
```

查看内存支持的最大内存容量

```
dmidecode|grep -P 'Maximum\s+Capacity'

#  Maximum Capacity: 16 GB
```

查看内存的频率

```
dmidecode|grep -A16 "Memory Device"

#   Memory Device
#     Array Handle: 0x1000
#     Error Information Handle: Not Provided
#     Total Width: 72 bits
#     Data Width: 64 bits
#     Size: 2048 MB
#     Form Factor: DIMM
#     Set: 1
#     Locator: DIMM_A1
#     Bank Locator: Not Specified
#     Type: DDR3
#     Type Detail: Synchronous Unbuffered (Unregistered)
#     Speed: 1333 MHz
#     Manufacturer: 00CE000080CE
#     Serial Number: 4830F3E1
#     Asset Tag: 01093200
#     Part Number: M391B5673EH1-CH9
#   --
#   Memory Device
#     Array Handle: 0x1000
#     Error Information Handle: Not Provided
#     Total Width: 72 bits
#     Data Width: 64 bits
#     Size: 2048 MB
#     Form Factor: DIMM
#     Set: 1
#     Locator: DIMM_A2
#     Bank Locator: Not Specified
#     Type: DDR3
#     Type Detail: Synchronous Unbuffered (Unregistered)
#     Speed: 1333 MHz
#     Manufacturer: 00AD000080AD
#     Serial Number: 1BA1F0B5
#     Asset Tag: 01110900
#     Part Number: HMT325U7BFR8C-H9
#   --

dmidecode|grep -A16 "Memory Device"|grep 'Speed'

#  Speed: 1333 MHz
#  Speed: 1333 MHz
#  Speed: 1333 MHz
#  Speed: Unknown

```

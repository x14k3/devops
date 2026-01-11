
对注册表项中的注册表子项信息和值执行操作。

某些操作使你能够查看或配置本地或远程计算机上的注册表项，而其他操作则允许你仅配置本地计算机。 使用 reg 配置远程计算机的注册表会限制在某些操作中可以使用的参数。 检查每个操作的语法和参数，以验证它们是否可以在远程计算机上使用。

> 除非别无选择，否则不要直接编辑注册表。 注册表编辑器会忽略标准的安全措施，从而使得这些设置可能降低性能、破坏系统，甚至要求用户重新安装  Windows。 可以使用控制面板或 Microsoft 管理控制台 (MMC) 中的程序安全地更改大多数注册表设置。  如果必须直接编辑注册表，请先进行备份。

‍

|参数|说明|
| ------| ------------------------------------------------------------------------|
|[reg add](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-add)|将新的子项或项添加到注册表中。|
|[reg compare](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-compare)|比较指定的注册表子项或项。|
|[reg copy](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-copy)|将注册表项复制到本地或远程计算机上的指定位置。|
|[reg delete](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-delete)|从注册表中删除子项或条目。|
|[reg export](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-export)|将本地计算机的指定子项、项和值复制到文件，以便传输到其他服务器。|
|[reg import](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-import)|将包含导出的注册表子项、条目和值的文件内容复制到本地计算机的注册表中。|
|[reg load](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-load)|将保存的子项和项写入注册表中的不同子项。|
|[reg query](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-query)|返回位于注册表中指定子项下的下一层子项和条目的列表。|
|[reg restore](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-restore)|将保存的子项和项写回到注册表。|
|[reg save](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-save)|将注册表的指定子项、项和值的副本保存在指定的文件中。|
|[reg unload](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/reg-unload)|删除使用 reg load 操作加载的注册表部分。|

‍

## reg add

```
reg add <keyname> [/v valuename | /ve] [/t datatype] [/s separator] [/d data] [/f] [/reg:32 | /reg:64]
```

### 参数

|参数|描述|
| ---------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定要添加的子项或条目的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|/v`<Valuename>`​|指定添加注册表项的名称。|
|/ve|指定添加的注册表项具有 null 值。|
|/t`<Type>`​|指定注册表项的类型。 Type 必须是下列值中的一个：* REG_SZ* REG_MULTI_SZ* REG_DWORD_BIG_ENDIAN* REG_DWORD* REG_BINARY* REG_DWORD_LITTLE_ENDIAN* REG_LINK* REG_FULL_RESOURCE_DESCRIPTOR* REG_EXPAND_SZ|
|/s`<Separator>`​|在指定 REG_MULTI_SZ 数据类型并列出多个项的情况下，指定用于分隔多个数据实例的字符。 如果未指定，则默认分隔符为 \0。|
|/d`<Data>`​|指定新注册表项的数据。|
|/f|在不提示确认的情况下添加注册表项。|
|/reg:32|指定应使用 32 位注册表视图访问密钥。|
|/reg:64|指定应使用 64 位注册表视图访问密钥。|
|/?|在命令提示符下显示帮助。|

#### 注解

- 此操作无法添加子树。 此版本的 reg 在添加子键时不会要求确认。
- reg add 操作的返回值为：

  |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

- 对于 REG_EXPAND_SZ 项类型，请在 /d 参数内将插入符号 ( **^** ) 与  **%**  结合使用。

### 示例

要在远程计算机 ABC 上添加 HKLM\Software\MyCo 项，请键入：

```
reg add \\ABC\HKLM\Software\MyCo
```

要将名为 DATA 的值、类型为 REG_BINARY 且数据为 fe340ead 的注册表项添加到 HKLM\Software\MyCo，请键入：

```
reg add HKLM\Software\MyCo /v Data /t REG_BINARY /d fe340ead
```

要将值名称为 MRU、类型 REG_MULTI_SZ 以及数据为 fax\0mail\0 的多值注册表项添加到 HKLM\SOFTWARE\MyCo 中，请键入：

```
reg add HKLM\Software\MyCo /v MRU /t REG_MULTI_SZ /d fax\0mail\0
```

要将值为 Path、类型为 REG_EXPAND_SZ 且数据为 %systemroot% 的扩展注册表项添加到 HKLM\Software\MyCo ，其，请键入：

```
reg add HKLM\Software\MyCo /v Path /t REG_EXPAND_SZ /d ^%systemroot^%
```

‍

‍

## reg compare

```
reg compare <keyname1> <keyname2> [{/v Valuename | /ve}] [{/oa | /od | /os | on}] [/s]
```

### 参数

|参数|描述|
| ------| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname1>`​|指定要添加的子项或条目的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|​`<keyname2>`​|指定要比较的第二个子项的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 仅在 keyname2 中指定计算机名称会导致操作使用 keyname1 中指定的子项的路径。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|/v`<Valuename>`​|指定要在子项下比较的值名称。|
|/ve|指定仅比较值名称为 null 的项。|
|/oa|指定显示所有差异和匹配结果。 默认情况下，仅列出差异。|
|/od|指定仅显示差异。 此选项为默认行为。|
|/os|指定仅显示匹配结果。 默认情况下，仅列出差异。|
|/on|指定不显示任何内容。 默认情况下，仅列出差异。|
|/s|以递归方式比较所有子项和项。|
|/?|在命令提示符下显示帮助。|

#### 备注

- reg compare 操作的返回值为：
- |值|说明|
  | ----| ------------------------|
  |0|比较成功，且结果一致。|
  |1|比较失败。|
  |2|比较成功，并发现差异。|
- 结果显示以下符号：

  - |符号|说明|
    | ------| -------------------------------------|
    |=|KeyName1 数据等同于 KeyName2 数据。|
    |<|KeyName1 数据小于 KeyName2 数据。|
    |>|KeyName1 数据大于 KeyName2 数据。|

### 示例

若要比较密钥 MyApp 下的所有值与密钥 SaveMyApp 下的所有值，请键入：

‍

```
reg compare HKLM\Software\MyCo\MyApp HKLM\Software\MyCo\SaveMyApp
```

若要将密钥 MyCo 下的 Version 的值与密钥 MyCo1 下的 Version 值比较，请键入：

‍

```
reg compare HKLM\Software\MyCo HKLM\Software\MyCo1 /v Version
```

若要将名为 ZODIAC 的计算机上的 HKLM\Software\MyCo 下的所有子项和值与本地计算机上 HKLM\Software\MyCo 下的所有子项和值进行比较，请键入：

```
reg compare \\ZODIAC\HKLM\Software\MyCo \\. /s
```

‍

## reg copy

‍

‍

## reg delete

```
reg delete <keyname> [{/v valuename | /ve | /va}] [/f]
```

### 参数

|参数|描述|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname1>`​|指定要删除的子项或条目的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|/v`<valuename>`​|删除子项下的特定条目。 如果未指定条目，则会删除该子项下的所有条目和子项。|
|/ve|指定仅删除没有值的条目。|
|/va|删除指定项中的所有条目。 不会删除驻留在指定项中的子项条目。|
|/f|删除现有的注册表子项或条目，且不要求确认。|
|/?|在命令提示符下显示帮助。|

#### 注解

- reg delete 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要删除注册表项 Timeout 及其所有子项和值，请键入：

```
reg delete HKLM\Software\MyCo\MyApp\Timeout
```

若要删除名为 ZODIAC 的计算机上 HKLM\Software\MyCo 下的注册表值 MTU，请键入：

```
reg delete \\ZODIAC\HKLM\Software\MyCo /v MTU
```

‍

## reg export

```
reg export <keyname> <filename> [/y]
```

### 参数

|参数|描述|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定子密钥的完整路径。 导出操作仅适用于本地计算机。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果注册表项名称包含空格，请将项名称括在引号中。|
|​`<filename>`​|指定要在操作过程中创建的文件的名称和路径。 该文件的扩展名必须是 .reg。|
|/y|覆盖任何名称为 filename 的现有文件，不提示确认。|
|/?|在命令提示符下显示帮助。|

#### 备注

- reg export 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要将键 MyApp 的所有子项和值的内容导出到文件 AppBkUp.reg，请键入：

```
reg export HKLM\Software\MyCo\MyApp AppBkUp.reg
```

‍

## reg import

```
reg import <filename>
```

### 参数

|参数|描述|
| ------| -----------------------------------------------------------------------------------------------------------|
|​`<filename>`​|指定文件的名称和路径，该文件包含要复制到本地计算机的注册表中的内容。 必须使用 reg export 提前创建该文件。|
|​`/reg:32`​|指定应使用 32 位注册表视图访问密钥。|
|​`/reg:64`​|指定应使用 64 位注册表视图访问密钥。|
|/?|在命令提示符下显示帮助。|

#### 注解

- reg import 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要从名为 AppBkUp.reg 的文件导入注册表条目，请键入：

```
reg import AppBkUp.reg
```

‍

## reg load

```
reg load <keyname> <filename>
```

### 参数

|参数|说明|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定要加载的子项的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|​`<filename>`​|指定要加载的文件的名称和路径。 必须使用 reg save 命令提前创建此文件，且此文件必须具有 .hiv 扩展名。|
|/?|在命令提示符下显示帮助。|

#### 备注

- reg load 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要将名为 TempHive.hiv 的文件加载到项 HKLM\TempHive，请键入：

```
reg load HKLM\TempHive TempHive.hiv
```

‍

## reg query

```
reg query <keyname> [{/v <valuename> | /ve}] [/s] [/se <separator>] [/f <data>] [{/k | /d}] [/c] [/e] [/t <Type>] [/z] [/reg:32] [/reg:64]
```

### 参数

|参数|描述|
| ---------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定子密钥的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|/v`<valuename>`​|指定要查询的注册表值名称。 如果省略，则返回 keyname 的所有值名称。 如果还使用 /f 选项，则此参数的 Valuename 是可选的。|
|/ve|针对空白的值名称运行查询。|
|/s|指定以递归方式查询所有子项和值名称。|
|/se`<separator>`​|指定要在值名称类型 REG_MULTI_SZ 中搜索的单值分隔符。 如果未指定分隔符，则使用 \0。|
|/f`<data>`​|指定要搜索的数据或模式。 如果字符串包含空格，请使用双引号。 如果未指定，则使用通配符 ( ***** ) 作为搜索模式。|
|/k|指定仅搜索密钥名称。 必须与 /f 一起使用。|
|/d|指定仅搜索数据。|
|/c|指定查询区分大小写。 默认情况下，查询不区分大小写。|
|/e|指定仅返回完全匹配项。 默认情况下，将返回所有匹配项。|
|/t`<Type>`​|指定要搜索的注册表类型。 有效类型为：REG_SZ、REG_MULTI_SZ、REG_EXPAND_SZ、REG_DWORD、REG_BINARY、REG_NONE。 如果未指定，则搜索所有类型。|
|/z|指定在搜索结果中包含注册表类型的等效数值。|
|/reg:32|指定应使用 32 位注册表视图访问密钥。|
|/reg:64|指定应使用 64 位注册表视图访问密钥。|
|/?|在命令提示符下显示帮助。|

#### 注解

- reg query 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

要显示 HKLM\Software\Microsoft\ResKit 中名称值 Version 的值，请键入：

```
reg query HKLM\Software\Microsoft\ResKit /v Version
```

要显示名为 ABC 的远程计算机上 HKLM\Software\Microsoft\Reskit\NT\Setup 项下的所有子项和值，请键入：

```
reg query \\ABC\HKLM\Software\Microsoft\ResKit\Nt\Setup /s
```

若要使用  **#**  作为分隔符显示 REG_MULTI_SZ 类型的所有子项和值，请键入：

```
reg query HKLM\Software\Microsoft\ResKit\Nt\Setup /se #
```

要显示数据类型 REG_SZ 的 HKLM 根目录下与 SYSTEM 精确匹配（区分大小写）的项、值和数据，请键入以下内容：

```
reg query HKLM /f SYSTEM /t REG_SZ /c /e
```

要显示 HKCU 根密钥下与 0F 匹配且数据类型为 REG_BINARY 的项、值和数据，请键入：

```
reg query HKCU /f 0F /d /t REG_BINARY
```

要显示 HKLM\Software\Microsoft 项以及所有子项下面与 asp.net 匹配的项、值和数据，请键入：

```
reg query HKLM\SOFTWARE\Microsoft /s /f asp.net
```

要仅显示 HKLM\Software\Microsoft 项以及所有子项下面与 asp.net 匹配的项，请键入：

```
reg query HKLM\SOFTWARE\Microsoft /s /f asp.net /k
```

要显示 HKLM\SOFTWARE 下值名称为 null（默认值）的值和数据，请键入：

```
reg query HKLM\SOFTWARE /ve
```

‍

## reg restore

```
reg restore <keyname> <filename>
```

### 参数

|参数|说明|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定要还原的子项的完整路径。 还原操作仅适用于本地计算机。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果注册表项名称包含空格，请将项名称括在引号中。|
|​`<filename>`​|指定其内容要写入注册表的文件的名称和路径。 必须使用 reg save 命令提前创建此文件，且此文件必须具有 .hiv 扩展名。|
|/?|在命令提示符下显示帮助。|

#### 注解

- 在编辑任何注册表项之前，必须使用 reg save 命令保存父子项。 如果编辑失败，可以使用 reg restore 操作还原原始子项。
- reg restore 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要将名为 NTRKBkUp.hiv 的文件还原到密钥 HKLM\Software\Microsoft\ResKit 并覆盖密钥的现有内容，请键入：

```
reg restore HKLM\Software\Microsoft\ResKit NTRKBkUp.hiv
```

‍

## reg save

```
reg save <keyname> <filename> [/y]
```

### 参数

|参数|描述|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定子密钥的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|​`<filename>`​|指定所创建文件的名称和路径。 如果未指定路径，则使用当前路径。|
|/y|覆盖名称为 filename 的现有文件，而不提示确认。|
|/?|在命令提示符下显示帮助。|

#### 备注

- 在编辑任何注册表项之前，必须使用 reg save 命令保存父子项。 如果编辑失败，可以使用 reg restore 操作还原原始子项。
- reg save 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

若要将配置单元 MyApp 以名为 AppBkUp.hiv 的文件保存到当前文件夹中，请键入：

```
reg save HKLM\Software\MyCo\MyApp AppBkUp.hiv
```

## reg unload

```
reg unload <keyname>
```

### 参数

|参数|描述|
| ------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|​`<keyname>`​|指定子密钥的完整路径。 若要指定远程计算机，请将计算机名（格式为`\\<computername>\`​）包含为 keyname 的一部分。 如果省略`\\<computername>\`​，则默认会对本地计算机执行该操作。 keyname 必须包含有效的根项。 本地计算机的有效根项是：HKLM、HKCU、HKCR、HKU 和 HKCC。 如果指定了远程计算机，则有效的根项为：HKLM 和 HKU。 如果注册表项名称包含空格，请将项名称括在引号中。|
|/?|在命令提示符下显示帮助。|

#### 注解

- reg unload 操作的返回值为：
- |值|说明|
  | ----| ------|
  |0|成功|
  |1|失败|

### 示例

要卸载文件 HKLM 中的配置单元 TempHive，请键入：

```
reg unload HKLM\TempHive
```

 注意

除非别无选择，否则不要直接编辑注册表。 注册表编辑器会忽略标准的安全措施，从而使得这些设置可能降低性能、破坏系统，甚至要求用户重新安装  Windows。 可以使用控制面板或 Microsoft 管理控制台 (MMC) 中的程序安全地更改大多数注册表设置。  如果必须直接编辑注册表，请先进行备份。

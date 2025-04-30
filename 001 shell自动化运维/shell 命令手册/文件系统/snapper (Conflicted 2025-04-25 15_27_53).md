# snapper (Conflicted 2025-04-25 15:27:53)

Snapper 是一个 Linux 命令行工具，用于创建和管理文件系统的快照。

使用 snapper 命令，您可以创建只读快照。您可以在任何灾难情况下使用这些快照来恢复特定文件或所有文件。

您还可以使用它来比较多个快照并恢复到特定的旧快照。

Snapper 仅在 btrfs（B-tree 文件系统写入时复制）、ext4 文件系统和基于精简配置的 LVM 逻辑卷上受支持。

使用 snapper 命令拍摄快照时，它将驻留在同一文件系统中，因此应该有足够的可用空间，并且可能需要定期清理 FS。

如果您对使用基于 rsync 的快照感兴趣，您还应该查看我们之前讨论过的rsnapshot 实用程序。

### 安装 Snapper 实用程序

您可以下载各种发行版的snapper 二进制文件并安装它，或者下载源代码并自行编译。

例如，您可以从SUSE SLES11 SP2 存储库下载 snapper rpm 。

```javascript
# rpm -ivh snapper-0.1.6-2.1.x86_64.rpm
```

以下是 snapper 包的依赖项。当您使用 yum 或其他包管理工具时，所有依赖项都会自动安装。

* libsnapper-devel-0.1.6-2.1.x86_64.rpm
* pam_snapper-0.1.6-2.1.x86_64.rpm
* snapper-debuginfo-0.1.6-2.1.x86_64.rpm
* snapper-debugsource-0.1.6-2.1.x86_64.rpm

### 创建 btrfs 文件系统

由于从 SLES11 SP2 开始支持 btrfs 文件系统，您可以使用 btrfs 创建逻辑卷或使用 btrfs-convert 命令将现有的 ext3 文件系统转换为 btrfs。

执行以下命令创建一个新的 btrfs 文件系统，如果您没有安装 btrfs 程序，则使用 zypper install btrfsprogs 安装它。

```javascript
# lvcreate -L 8G -n snapvol vglocal
Logical volume "snapvol" created

# mkfs.btrfs /dev/vglocal/snapvol

# mount /dev/vglocal/snapvol /snapmount
```

### 创建精简配置的 LVM

If you want to create a thin-provisioned LVM, use the lvcreate command to do the following.

```javascript
# lvcreate --thin vglocal/vgthinpool --size 20G
  Rounding up size to full physical extent 32.00 MiB
  Logical volume "vgthinpool" create

# lvcreate --thin vglocal/vgthinpool --virtualsize 8G --name lvthin_snap
  Logical volume "lvthin_snap" created

# lvs
  LV          VG        Attr      LSize   Pool       Origin Data%  Move Log Copy%  Convert
  opt         vglocal -wi-ao---   2.73g
  tmp         vglocal -wi-ao---   2.73g
  usr_local   vglocal -wi-ao---   2.73g
  var         vglocal -wi-ao---   2.73g
  lvthin_snap vglocal  Vwi-a-tz-   8.00g vgthinpool          0.00
  vgthinpool  vglocal  twi-a-tz-  20.00g                     0.00

# mkfs.ext3 /dev/vglocal/lvthin_snap

# mkdir /snapmount

# mount /dev/vglocal/lvthin_snap /snapmount
```

### 创建 Snapper 配置文件

要使用 snapper 命令创建配置文件，请使用“snapper -c”命令，如下所示。

btrfs 的语法：

```javascript
snapper –c  create-config
```

在 btrfs 上，您只需指定配置文件名和挂载点，如下所示。

```javascript
snapper -c snapconfig create-config /snapmount
```

精简配置 LVM 的语法：

```javascript
snapper –c create-config --fstype="lvm(xfs)"
```

在精简配置的 LVM 上，除了指定配置文件名和挂载点外，您还应该使用 –fstype 指定文件系统类型，如下所示：

```javascript
snapper -c snapconfig1 create-config --fstype="lvm(xfs)" /snapmount1
```

### 查看和删除 Snapper 配置文件

创建配置文件后，您将看到在 /snapmount 目录下创建的 .snapshots 目录。

您还会注意到配置文件是在 /etc/snapper/configs/snapconfig 下创建的。有关为快照配置的所有子卷的信息将存储在此文件中。

用于故障排除的日志文件位于 /var/log/snapper.log 下

要查看所有配置文件，请执行以下 snapper 命令：

```javascript
# snapper list-configs
Config      	| 	Subvolume
------------+------------
snapconfig  	| 	/snapmount         ? btrfs filesystem
snapconfig1 	| 	/snapmount1       ? Thin provisioned filesystem
```

要删除配置文件，请使用以下语法：

```javascript
snapper –c  delete-config
```

例如，以下命令删除 /etc/snapper/configs 目录下的配置文件 snapconfig。

```javascript
# snapper -c snapconfig delete-config
```

### 使用 Snapper 创建快照

为了创建文件系统的快照，请使用以下 snapper 命令语法：

```javascript
snapper –config  create –description "description of the snapshot"
```

例如，以下将拍摄一个新快照。

```javascript
# snapper --config snapconfig create --description "Snapshot taken on 02-24-0354"
```

拍摄快照后，查看快照信息，如下所示：

```javascript
# snapper --config snapconfig list
Type   | # | Pre # | Date                     | User | Cleanup | Description                  | Userdata
-------+---+-------+--------------------------+------+---------+------------------------------+---------
single | 0 |       |                          | root |         | current                      |
single | 1 |       | Mon Feb 24 15:57:00 2014 | root |         | Snapshot taken on 02-24-0354 |
```

### 拍摄第二张快照进行比较

出于测试目的，我取消了 /snapmount 目录下的 testfile1。

```javascript
# cat /dev/null > testfile1

# ls -ltr
-rw-r--r-- 1 root root 11 Feb 24 11:28 testfile2
-rw-r--r-- 1 root root 43 Feb 24 11:28 testfile3
drwxr-x--- 1 root root  2 Feb 24 15:57 .snapshots
-rw-r--r-- 1 root root  0 Feb 24 16:25 testfile1
```

在上述更改之后，让我们再拍一张快照。

```javascript
# snapper --config snapconfig create --description "Snapshot taken on 02-24-0427"
```

如下所示，现在我们有两个快照。

```javascript
# snapper --config snapconfig list
Type   | # | Pre # | Date                     | User | Cleanup | Description                  | Userdata
-------+---+-------+--------------------------+------+---------+------------------------------+---------
single | 0 |       |                          | root |         | current                      |
single | 1 |       | Mon Feb 24 15:57:00 2014 | root |         | Snapshot taken on 02-24-0354 |
single | 2 |       | Mon Feb 24 16:27:48 2014 | root |         | Snapshot taken on 02-24-0427 |
```

### 比较第一个和第二个快照

现在，让我们比较两个快照。

以下命令将快照​2 进行比较。

```javascript
# snapper -c snapconfig status 1..2
c.... /snapmount/testfile1
```

在输出中：

* 输出中的“c”表示内容已被修改。
* “+”表示将newl文件添加到目录中。
* “-”表示有文件被删除。

### 拍摄多个快照并比较输出

我创建了多个测试快照，添加的文件很少，删除的文件很少，内容更改也很少。

```javascript
# snapper --config snapconfig list
Type   | # | Pre # | Date                     | User | Cleanup | Description                  | Userdata
-------+---+-------+--------------------------+------+---------+------------------------------+---------
single | 0 |       |                          | root |         | current                      |
single | 1 |       | Mon Feb 24 15:57:00 2014 | root |         | Snapshot taken on 02-24-0354 |
single | 2 |       | Mon Feb 24 16:27:48 2014 | root |         | Snapshot taken on 02-24-0427 |
single | 3 |       | Mon Feb 24 16:37:53 2014 | root |         | Snapshot taken on 02-24-0437 |
single | 4 |       | Mon Feb 24 16:38:17 2014 | root |         | Snapshot taken on 02-24-0440 |
```

以下输出列出了添加、修改和删除的文件。

```javascript
# snapper -c snapconfig status 4..1
-.... /snapmount/a
-.... /snapmount/b
-.... /snapmount/c
c.... /snapmount/testfile1
+.... /snapmount/testfile2
```

### 查看快照之间的差异

现在要查看snapshot​4在文件中的具体内容差异，可以使用以下命令。

```javascript
# snapper -c snapconfig diff 4..1 /snapmount/testfile1
--- /snapmount/.snapshots/4/snapshot/testfile1  2014-02-24 16:25:44.416490642 -0500
+++ /snapmount/.snapshots/1/snapshot/testfile1  2014-02-24 11:27:35.000000000 -0500
@@ -0,0 +1 @@
+This is a test file
```

输出采用 diff 命令输出的典型格式。

### 从快照恢复特定文件

一旦您看到了快照之间的差异，并且您知道要恢复哪个特定文件，您就可以按照此处的说明恢复它。

在恢复之前，我们在这个列表中没有 testfile2。

```javascript
# ls -ltr
-rw-r--r-- 1 root root 43 Feb 24 11:28 testfile3
-rw-r--r-- 1 root root  0 Feb 24 16:25 testfile1
drwxr-x--- 1 root root 10 Feb 24 16:45 .snapshots
```

例如，要从快照恢复单个文件，即从快照#1 恢复单个文件，即 /snapmount/testfile2（已删除的文件），请使用以下命令：

```javascript
# snapper -c snapconfig -v undochange 1..4 /snapmount/testfile2
create:1 modify:0 delete:0
creating /snapmount/testfile2
```

还原后，我们在列表中看到了 testfile2。

```javascript
# ls -ltr
-rw-r--r-- 1 root root 43 Feb 24 11:28 testfile3
-rw-r--r-- 1 root root  0 Feb 24 16:25 testfile1
drwxr-x--- 1 root root 10 Feb 24 16:45 .snapshots
-rw-r--r-- 1 root root 11 Feb 24 16:55 testfile2
```

### 从快照恢复所有文件

要从快照恢复所有文件，请执行以下操作：

现在，让我们从特定快照恢复所有文件。注意这是如何删除几个文件、创建一个文件和修改一个文件。

```javascript
# snapper -c snapconfig -v undochange 1..4
create:1 modify:1 delete:3
deleting /snapmount/c
deleting /snapmount/b
deleting /snapmount/a
modifying /snapmount/testfile1
creating /snapmount/testfile2
```

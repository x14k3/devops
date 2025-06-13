

​Restic 是一款 GO 语言开发的开源免费且快速、高效和安全的跨平台备份工具。Restic 使用加密技术来保证你的数据安全性和完整性，可以将本地数据加密后传输到指定的存储。  
Restic 同样支持增量备份，可随时备份和恢复备份。Restic 支持大多数主流操作系统，比如：Linux、macOS、Windows 以及一些较小众的操作系统 FreeBSD 和 OpenBSD 等。  

- [Restic - 官方仓库地址](https://github.com/restic/restic)
- [Restic - 官方文档地址](https://restic.readthedocs.io/en/stable/index.html)
- [restic-backup-docker - 官方推荐的第三方容器](https://github.com/Lobaro/restic-backup-docker)

‍

# 一、 restic简介

## 1.1 restic 支持类型

- 本地存储
- SFTP
- REST Server
- Amazon S3
- Minio Server
- OpenStack Swift
- Backblaze B2
- Microsoft Azure Blob Storage
- Google Cloud Storage
- 通过 Rclone 挂载的存储 (比如：Google Drive、OneDrive 等)

## 1.2 **Restic 与 Rclone** 区别

### 1.2.1 相同点

- 两者都是基于命令行的开源文件同步和备份工具。
- 两者都支持将文件备份到本地、远程服务器或对象存储。

### 1.2.2 异同

- Rclone 面向的是文件同步，即保证两端文件的一致，也可以增量备份。
- Restic 面向的是文件备份和加密，文件先加密再传输备份，而且是增量备份，即每次只备份变化的部分。
- Rclone 仓库配置保存在本地，备份的文件会保持原样的同步于存储仓库中。
- Restic 配置信息直接写在仓库，只要有仓库密码，在任何安装了 Restic 的计算机上都可以操作仓库。
- Rclone 不记录文件版本，无法根据某一次备份找回特定时间点上的文件。
- Restic 每次备份都会生成一个快照，记录当前时间点的文件结构，可以找回特定时间点的文件。
- Rclone 可以在配置的多个存储端之间传输文件。

总的来说，Rclone 和 Restic 各有所长，要根据不同的业务需求选择使用。比如：网站数据的增量备份，用 Resitc 就比较合适。而常规文件的远程备份归档，用 Rclone 就很合适。

## 1.3 Restic设计原则

Restic 是一个可以正确进行备份的程序，其设计遵循以下原则：

- 简单：备份应该是一个顺畅的过程，否则您可能会想跳过它。 Restic 应该易于配置和使用，以便在数据丢失的情况下，您可以直接恢复它。同样，恢复数据不应该很复杂。
- 快速：用restic备份你的数据应该只受你的网络或硬盘带宽的限制，这样你就可以每天备份你的文件。如果需要太多时间，没有人会进行备份。恢复备份应该只传输要恢复的文件所需的数据，这样这个过程也很快。
- 可验证：比备份更重要的是恢复，因此restic使您可以轻松验证所有数据是否可以恢复。
- 安全：Restic 使用加密技术来保证您数据的机密性和完整性。假设存储备份数据的位置不是受信任的环境（例如，系统管理员等其他人能够访问您的备份的共享空间）。 Restic 旨在保护您的数据免受此类攻击者的侵害。
- 高效：随着数据的增长，额外的快照应该只占用实际增量的存储。更重要的是，在将重复数据实际写入存储后端之前，应该对其进行去重，以节省宝贵的备份空间。

‍

# 二、工具的安装方式

> **该工具提供多种平台的对应安装包！**

```bash
#### macOS
# brew
$ brew install restic
# macprots
$ sudo port install restic

# apt
$ apt-get install restic

# yum
$ yum install yum-plugin-copr
$ yum copr enable copart/restic
$ yum install restic

# docker
$ docker pull restic/restic

# 二进制安装
# clone
$ git clone https://github.com/restic/restic
# run
$ cd restic && go run build.go
# build
$ go run build.go --goos linux --goarch arm --goarm 6


$ restic version
```

‍

# 三、可配置的存储库

安装好了 `Restic`​ 后，还需要配置下存储方式，也就是你想备份到本地还是远程服务器上。以下配置过程中都会要你输入密码，千万不能忘了，不然数据就找不回来了。

这里需要说的是，`Rclone`​ 这种方式，其可以挂载 `OneDrive`​ 或者 `Google`​ 网盘，具体的使用和配置情况可以参考官方文档进行操作。当然不仅限于我下面列举出来的这些，更多的存储库支持请查看官方文档。

### **Local - 设置本地存储**

```bash
# 备份到本地/data/restic-repo文件夹
$ restic init --repo /data/restic-repo
enter password for new repository:
enter password again:
created restic repository a879a2dad9 at /data/restic-repo
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
```

### **SFTP - 设置远程备份**

使用前需要设置无密码登录(免密登录)

```bash
# 生成~/.ssh/id_rsa.pub公钥和对应私钥
$ cd ~ && ssh-keygen -t rsa
# [方法一] 复制服务器A中的id_rsa.pub值到服务器B
$ echo 'xxxxxxx' >> ~/.ssh/authorized_keys
# [方法二] 当然可以使用如下命令自动完成免密登录
$ ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.100.2
# 测试免密登录
$ ssh -vv root@192.168.100.2
```

```bash
# 初始化仓库
# 需要注意使用的sftp协议需要加//符号
# 需要注意远程服务器的路径默认是当前用户的家目录未开始的，如果需要从根目录要在前面加/来指定
$ restic -r sftp://user@host:port/data/restic-repo init
$ restic --repo sftp://user@host:port/data/restic-repo init
enter password for new repository:
enter password again:
created restic repository f1c6108821 at sftp:user@host:/data/restic-repo
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.

# 同步数据
$ restic -r sftp://root@192.168.100.100:22//data/restic_backup --path /data/app/data_cache
```

### **REST Server - 设置远程备份**

```bash
# http
$ restic -r rest:http://host:8000/

# https
$ restic -r rest:https://host:8000/
$ restic -r rest:https://user:pass@host:8000/
$ restic -r rest:https://user:pass@host:8000/my_backup_repo/
```

### **Amazon S3 - 设置远程备份**

```bash
# 设置AWS秘钥
$ export AWS_ACCESS_KEY_ID=<MY_ACCESS_KEY>
$ export AWS_SECRET_ACCESS_KEY=<MY_SECRET_ACCESS_KEY>

# 初始化AWS作为后端的存储库
$ restic -r s3:s3.amazonaws.com/bucket_name init
enter password for new repository:
enter password again:
created restic repository eefee03bbd at s3:s3.amazonaws.com/bucket_name
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.

# 设置同步时间时区
$ restic -r s3:s3.amazonaws.com/bucket_name init -o s3.region="us-east-1"

```

### **Minio Server - 设置远程备份**

```bash
# 设置Minio秘钥
$ export AWS_ACCESS_KEY_ID=<MY_ACCESS_KEY>
$ export AWS_SECRET_ACCESS_KEY=<MY_SECRET_ACCESS_KEY>

# 初始化Minio作为后端的存储库
$ ./restic -r s3:http://localhost:9000/restic init
enter password for new repository:
enter password again:
created restic repository 6ad29560f5 at s3:http://localhost:9000/restic1
Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is irrecoverably lost.
```

# 四、开始备份

> **以下均将/data/im-data 文件夹的文件备份到/data/restic-repo 存储文件夹**

现在我们准备备份一些数据，目录中特定时间点的内容在 `Restic`​ 中称为  **“快照”** 。运行以下命令，然后再次输入上方选择的存储库密码，即可开始你的第一次文件备份。

**我们这里以本地备份为例进行演示说明**

- 执行之后 `Restic`​ 创建了目录的备份(速度非常快)
- 完成之后创建了一个名为 `40dc1520`​ 的快照(十六进制字符)
- 这里 `--verbose`​ 可以让备份输出更多信息

```bash
# 第一次备份数据
$ restic -r /data/restic-repo --verbose backup /data/im-data
open repository
enter password for repository:  # 需要输入密码
password is correct
lock repository
load index files
start scan
start backup
scan finished in 1.837s
processed 1.720 GiB in 0:12  # 处理了1.7G数据(即/data/im-data目录大小)
Files:  5307 new,  0 changed,  0 unmodified
Dirs:   1867 new,  0 changed,  0 unmodified
Added:  1.200 GiB            # 仅将1.2G添加到了存储库中(意味着数据有重复)
snapshot 40dc1520 saved      # 在远程仓库中生成的快照版本

```

```bash
# 再次运行backup命令，Retic将创建数据的另一个快照
# 这一次并没有向存储库添加新数据，因为所有数据已经存在了
$ restic -r /data/restic-repo --verbose backup /data/im-data
open repository
enter password for repository:
password is correct
lock repository
load index files
using parent snapshot d875ae93
start scan
start backup
scan finished in 1.881s
processed 1.720 GiB in 0:03
Files:  0 new,  0 changed,  5307 unmodified
Dirs:   0 new,  0 changed,  1867 unmodified
Added:  0 B
snapshot 79766175 saved

```

```bash
# 可以备份同一个存储库中的单个文件
$ echo 'more data foo bar' >> ~/work.txt

# 再一次执行同步单文件操作
$ restic -r /data/restic-repo --verbose backup /data/im-data/work.txt
open repository
enter password for repository:
password is correct
lock repository
load index files
using parent snapshot f3f8d56b
start scan
start backup
scan finished in 2.115s
modified  /home/user/work.txt, saved in 0.007s (22 B added)
modified  /home/user/, saved in 0.008s (0 B added, 378 B metadata)
modified  /home/, saved in 0.009s (0 B added, 375 B metadata)
processed 22 B in 0:02
Files:  0 new,  1 changed,  0 unmodified
Dirs:   0 new,  2 changed,  0 unmodified
Data Blobs:  1 new
Tree Blobs:  3 new
Added:  1.116 KiB
snapshot 8dc503fc saved

```

### **文件变化检测**

当使用 `Restic`​ 备份数据的时候，如果遇到已经备份过的文件，无论是在当前备份数据中还是在先前备份数据中，它都可以确保文件的内容在存储库中仅存储一次。为此，通常会扫描每个文件的全部内容才可以。因为这种方式非常耗时，所以 `Restic`​ 还可以使用基于 **文件元数据** 的检测方式来确定文件自上次备份以来是否存在变动。如果是，则不会再次扫描文件。

|编号|参数|对应含义解释|
| ------| ------| ----------------------------------------------------|
|1|​ **​`--force`​**​|关闭更改检测并重新扫描所有文件|
|2|​ **​`--ignore-ctime`​**​|要求 mtime 匹配，但允许 ctime 不同|
|3|​ **​`--ignore-inode`​**​|要求 mtime 匹配，但允许 inode number 和 ctime 不同|

```bash
# 可以这样使用
$ restic -r /data/restic-repo backup --force /data/im-data
$ restic -r /data/restic-repo backup --ignore-ctime /data/im-data
$ restic -r /data/restic-repo backup --ignore-inode /data/im-data
```

### **排除文件或目录**

|编号|参数|对应含义解释|
| ------| ------| -----------------------------------------------------|
|1|​ **​`--exclude`​**​|指定一次或多次排除一个或多个项|
|2|​ **​`--iexclude`​**​|与 exclude 相同，但忽略路径的情况|
|3|​ **​`--exclude-caches`​**​|指定一次排除包含特殊文件的文件夹|
|4|​ **​`--exclude-file`​**​|指定一次排除包含特殊文件的文件夹|
|5|​ **​`--iexclude-file`​**​|与 exclude-file 相同，但忽略路径的情况|
|6|​ **​`--exclude-if-present foo`​**​|排除文件夹包含名为 foo 的文件，不支持文件名的通配符|
|7|​ **​`--exclude-larger-than size`​**​|指定一次以排除大于给定大小的文件|

‍

```bash
$ cat excludes.txt
# excludes.txt
excludes.txt
# exclude go-files
*.go
# exclude foo/x/y/z/bar foo/x/bar foo/bar
foo/**/bar
--------------------------------------

# 可以这样使用
$ restic -r /srv/restic-repo backup ~/work --exclude="*.c" --exclude-file=excludes.txt

# 在执行备份时，它将防止restic跨越文件系统边界
$ restic -r /srv/restic-repo backup --one-file-system /
$ restic -r /srv/restic-repo backup --one-file-system / /media/usb
$ restic -r /srv/restic-repo backup ~/work --exclude-larger-than 1M

```

### **包含文件或目录**

‍

```bash

 # print0
$ find /tmp/somefiles -regex PATTERN -print0 > /tmp/files_to_backup

# backup
$ restic -r /srv/restic-repo backup --files-from-raw /tmp/files_to_backup

# more file
$ restic backup --files-from /tmp/files_to_backup /tmp/some_additional_file
$ restic backup --files-from /tmp/glob-pattern --files-from-raw /tmp/generated-list /tmp/some_additional_file

```

### **比较版本快照 - 使用**​**​`diff`​**​**命令**

它显示两个快照之间的差异，并显示一个统计信息，只需向命令传递两个快照 `id`​

```bash

$ restic -r /data/restic-repo diff 5845b002 2ab627a6
password is correct
comparing snapshot ea657ce5 to 2ab627a6:

 C   /restic/cmd_diff.go
+    /restic/foo
 C   /restic/restic

Files:           0 new,     0 removed,     2 changed
Dirs:            1 new,     0 removed
Others:          0 new,     0 removed
Data Blobs:     14 new,    15 removed
Tree Blobs:      2 new,     1 removed
  Added:   16.403 MiB
  Removed: 16.402 MiB
```

### **从标准输出来保存数据**

有时直接保存程序的输出会很好，例如 `mysqldump`​ 以便稍后恢复 `SQL`​

```bash
# 程序在非零退出时返回非零退出代码
$ set -o pipefail

# 介绍mysqldump的使用示例
$ mysqldump [...] | restic -r /data/restic-repo backup --stdin
$ mysqldump [...] | restic -r /data/restic-repo backup --stdin --stdin-filename production.sql

```

### **退出状态码**

|编号|状态码|状态码含义解释|
| ------| --------| ----------------------------------------|
|1|​**​`0`​**​|备份成功|
|2|​**​`1`​**​|致命错误；没有创建快照|
|3|​**​`2`​**​|无法读取源文件；不完整的快照与剩余文件|

---

## 五、操作使用存储库

**介绍操作本地或存储库的方法和常用命令！**

### **列出所有快照**

```bash
# 列出存储在存储库中的所有快照
$ restic -r /data/restic-repo snapshots
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
40dc1520  2021-05-08 21:38:30  kasimir        /home/user/work
79766175  2021-05-08 21:40:19  kasimir        /home/user/work
bdbd3439  2021-05-08 21:45:17  luigi          /home/art
590c8fc8  2021-05-08 21:47:38  kazik          /srv
9f0bc19e  2021-05-08 21:46:11  luigi          /srv

```

```bash
# 可以通过目录路径筛选列表
$ restic -r /data/restic-repo snapshots --path="/srv"
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
590c8fc8  2021-05-08 21:47:38  kazik          /srv
9f0bc19e  2021-05-08 21:46:11  luigi          /srv

# 或者按主机过滤
$ restic -r /srv/restic-repo snapshots --host luigi
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
bdbd3439  2021-05-08 21:45:17  luigi          /home/art
9f0bc19e  2021-05-08 21:46:11  luigi          /srv

# 组合过滤器也是可能的
$ restic -r /srv/restic-repo snapshots --group-by host
enter password for repository:
snapshots for (host [kasimir])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
40dc1520  2021-05-08 21:38:30  kasimir        /home/user/work
79766175  2021-05-08 21:40:19  kasimir        /home/user/work
2 snapshots

snapshots for (host [luigi])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
bdbd3439  2021-05-08 21:45:17  luigi          /home/art
9f0bc19e  2021-05-08 21:46:11  luigi          /srv
2 snapshots

snapshots for (host [kazik])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
590c8fc8  2021-05-08 21:47:38  kazik          /srv
1 snapshots

```

### **在存储库之间复制快照**

```bash
# 需要在两个存储库之间传输快照
# 使用copy命令从本地存储库到远程存储库
$ restic -r /data/restic-repo copy --repo2 /data/restic-repo-copy
repository d6504c63 opened successfully, password is correct
repository 3dd0878c opened successfully, password is correct

snapshot 410b18a2 of [/home/user/work] at 2020-06-09 23:15:57.305305 +0200 CEST)
  copy started, this may take a while...
snapshot 7a746a07 saved

snapshot 4e5d5487 of [/home/user/work] at 2020-05-01 22:44:07.012113 +0200 CEST)
skipping snapshot 4e5d5487, was already copied to snapshot 50eb62b7

```

```bash
# 可以通过host/path/tag来进行筛选
$ restic -r /data/restic-repo copy \
    --repo2 /data/restic-repo-copy \
    --host luigi --path /srv --tag foo,bar

# 还可以显式指定要复制的快照列表
$ restic -r /data/restic-repo copy \
    --repo2 /data/restic-repo-copy \
    410b18a2 4e5d5487 latest

```

### **快照拷贝后删除重复数据**

- 即使存储库之间可以传输快照，但存储库之间重复的快照数据可能无法正常删除掉
- 为了确保重复的数据可以正确的删除，需将存储库使用相同的参数将大文件分割成较小的块

```bash
# 使用chunk参数创建新的存储库
# 注意chunker参数不可能更改现有存储库
$ restic -r /data/restic-repo-copy init \
    --repo2 /data/restic-repo --copy-chunker-params
```

### **检查完整性和一致性**

假设存储库所在的服务器发生故障，或者受到黑客攻击并修改存储库中的文件，目的是让我们恢复恶意数据，达到攻击的目的。为了避免此问题的发生，最好定期使用 `check`​ 命令来测试存储库是否一致和数据是否完整。

```bash
# 黑客修改数据
$ echo "boom" > /data/restic-repo/index/de30...b139628

```

```bash
# 尝试恢复如下所示修改过的快照将会产生错误
$ restic -r /data/restic-repo --no-cache \
    restore c23e491f --target /tmp/restore-work
Fatal: unable to load index de30f323: load <index/de30f3231c>: invalid data returned

```

```bash
# 检查存储库一致性 - 存在异常
$ restic -r /data/restic-repo check
...
load indexes
error: error loading index de30f323: load <index/de30f3231c>: invalid data returned
Fatal: LoadIndex returned errors

# 检查存储库一致性 - 数据正常
$ restic -r /src/restic-repo check
...
load indexes
check all packs
check snapshots, trees and blobs
no errors were found

```

```bash
# 默认情况下不检测数据库磁盘上文件是否被修改
# 可以使用restic命令也验证存储库中包文件的完整性
$ restic -r /data/restic-repo check --read-data
...
load indexes
check all packs
check snapshots, trees and blobs
read all data
[0:00] 100.00%  3 / 3 items
duration: 0:00
no errors were found

# 因为比较花费时间，所以可以使用子集验证方式
$ restic -r /data/restic-repo check --read-data-subset=1/5
$ restic -r /data/restic-repo check --read-data-subset=2/5
$ restic -r /data/restic-repo check --read-data-subset=3/5
$ restic -r /data/restic-repo check --read-data-subset=4/5
$ restic -r /data/restic-repo check --read-data-subset=5/5
$ restic -r /srv/restic-repo check --read-data-subset=2.5%
$ restic -r /srv/restic-repo check --read-data-subset=100%

```

# 六、从备份恢复数据

**介绍如何从备份数据库中恢复数据！**

### **从快照中恢复数据**

```bash
# 只需使用以下命令就可以将最新快照的内容恢复
$ restic -r /data/restic-repo \
    restore 79766175 --target /tmp/restore-work
enter password for repository:
restoring <Snapshot of [/home/user/work] at 2021-05-08 21:40:19.884408621 +0200 CEST> to /tmp/restore-work

# 恢复也可以使用组合参数进行选择
$ restic -r /data/restic-repo \
    restore latest --target /tmp/restore-art \
    --path "/home/art" --host luigi
enter password for repository:
restoring <Snapshot of [/home/art] at 2021-05-08 21:45:17.884408621 +0200 CEST> to /tmp/restore-art

# 也可以使用参数来恢复单个文件
$ restic -r /data/restic-repo \
    restore 79766175 --target /tmp/restore-work \
    --include /work/foo --exclude /home/art
enter password for repository:
restoring <Snapshot of [/home/user/work] at 2021-05-08 21:40:19.884408621 +0200 CEST> to /tmp/restore-work

# 使用如下命令查看存储库库列表，从而指定exclude参数
$ restic ls latest
$ restic find foo

```

### **使用挂载来恢复数据**

将备份文件作为常规文件系统浏览和挂载

```bash
# 创建一个挂载点(/mnt/restic)
$ mkdir /mnt/restic

# 使用FUSE为存储库提供服务
$ restic -r /data/restic-repo mount /mnt/restic
enter password for repository:
Now serving /data/restic-repo at /mnt/restic
When finished, quit with Ctrl-c or umount the mountpoint.

```

### **输出文件内容到标准输出**

将文件打印到标准输出，可以让其他工具直接读取数据

```bash
# dump
$ restic -r /srv/restic-repo dump latest production.sql | mysql

```

```bash
# 查看对应文件的快照版本
$ restic -r /srv/restic-repo snapshots
ID        Date                 Host        Tags        Directory
----------------------------------------------------------------------
562bfc5e  2020-07-14 20:18:01  mopped                  /home/user/file1
bbacb625  2020-07-14 20:18:07  mopped                  /home/other/work
e922c858  2020-07-14 20:18:10  mopped                  /home/other/work
098db9d5  2020-07-14 20:18:13  mopped                  /production.sql
b62f46ec  2020-07-14 20:18:16  mopped                  /home/user/file1
1541acae  2020-07-14 20:18:18  mopped                  /home/other/work
----------------------------------------------------------------------

# 使用retic命令到1541acae这个快照版本
$ restic -r /srv/restic-repo \
    dump 098db9d5 production.sql | mysql

# 也可以给restic传递一个路径，该路径用于选择最新的快照
$ restic -r /srv/restic-repo \
    dump --path /production.sql latest production.sql | mysql

# 也可以将整个文件夹结构的内容转储到标准输出
$ restic -r /srv/restic-repo \
    dump latest /home/other/work > restore.tar
$ restic -r /srv/restic-repo \
    dump -a zip latest /home/other/work > restore.zip

```

# 七、删除备份的快照

**快照多的话，有时也是需要删除的！**

备份空间总是有限的，所以 `Restic`​ 也允许删除旧的快照数据。这可以手动完成(通过指定要删除的快照 ID)，也可以使用参数描述要忘记哪些快照的策略。对于快照的删除操作，可以使调用这两个命令，一是 `forget`​ 命令，二是 `prune`​ 命令，从存储库中实际删除快照引用的数据。

删除快照的数据，有可能是一个耗时的操作过程，这取决于需要处理的快照和数据的数量。在删除操作期间，存储库处于锁定状态，无法完成备份。同时，建议在执行之前先运行 `restic check`​ 命令，以确保在存储库的完整和一致。

### **删除单个快照**

```bash
# 列出存储库中的所有快照
$ restic -r /srv/restic-repo snapshots
enter password for repository:
ID        Date                 Host      Tags  Directory
----------------------------------------------------------------------
40dc1520  2021-05-08 21:38:30  kasimir         /home/user/work
79766175  2021-05-08 21:40:19  kasimir         /home/user/work
bdbd3439  2021-05-08 21:45:17  luigi           /home/art
590c8fc8  2021-05-08 21:47:38  kazik           /srv
9f0bc19e  2021-05-08 21:46:11  luigi           /srv

# 指定快照ID来删除快照
$ restic -r /srv/restic-repo forget bdbd3439
enter password for repository:
removed snapshot d3f01f63

# 虽然上述命令将快照删除了，但文件引用的数据仍然存储在存储库中
# 要清除未引用的数据，必须运行prune命令(之后存储库就变小了)
$ restic -r /data/restic-repo prune
enter password for repository:
repository 33002c5e opened successfully, password is correct
......

```

```bash
# 使用--prune命令将两步化为一步
$ restic forget --keep-last 1 --prune
snapshots for host mopped, directories /home/user/work:
......

```

### **根据策略删除快照**

- 手动删除费时费力，则 `restic`​ 允许根据策略指定应该自动删除哪些快照
- 可以指定保留多少小时/每日/每周/每月和每年快照，以及删除多少其他快照
- 可以使用 `--dry-run`​ 参数来测试需要删除的文件和目录列表

|编号|参数|参数含义解释|
| ------| ------| -----------------------------------------------------|
|1|​ **​`--keep-last n`​**​|不删除最近的 n 个快照|
|2|​ **​`--keep-hourly n`​**​|不删除快照的最后 n 个小时；每小时只保留最后一个快照|
|3|​ **​`--keep-daily n`​**​|不删除快照的最后 n 个天；每小时只保留最后一个快照|
|4|​ **​`--keep-weekly n`​**​|不删除快照的最后 n 个周；每小时只保留最后一个快照|
|5|​ **​`--keep-monthly n`​**​|不删除快照的最后 n 个月；每小时只保留最后一个快照|
|6|​ **​`--keep-yearly n`​**​|不删除快照的最后 n 个年；每小时只保留最后一个快照|
|7|​ **​`--keep-tag`​**​|保留所有由此选项指定的标签的快照；可多次指定|
|8|​ **​`--keep-within duration`​**​|保留在最新快照持续时间内创建的所有快照|

```bash
# 将删除快照限制为具有特定主机名/标记的快照
# 删除所有带有标记foo的快照的所有快照，除了最新的快照
$ restic forget --tag foo --keep-last 1

# 删除所有快照中除了最后一个快照之外的所有设置了foo或bar标记的快照
$ restic forget --tag foo --tag bar --keep-last 1

# 只保留带有foo和bar标记的所有快照的最后一个快照
$ restic forget --tag foo,bar --keep-last 1

# 不删除存储库中的所有快照
$ restic forget --keep-last 0

```

```bash
# 假设我们每个星期天都做一次备份
# 下面命令可以保留最后四个星期日的最后四个快照，但删除其余的
$ restic forget --keep-daily 4 --dry-run
repository f00c6e2a opened successfully, password is correct
Applying Policy: keep the last 4 daily snapshots
keep 4 snapshots:
ID        Time                 Host        Tags        Reasons         Paths
-------------------------------------------------------------------------------
8f8018c0  2019-10-27 11:00:00  mopped                  daily snapshot  /home/user/work
59403279  2019-11-03 11:00:00  mopped                  daily snapshot  /home/user/work
dfee9fb4  2019-11-10 11:00:00  mopped                  daily snapshot  /home/user/work
e1ae2f40  2019-11-17 11:00:00  mopped                  daily snapshot  /home/user/work
-------------------------------------------------------------------------------
4 snapshots

remove 8 snapshots:
ID        Time                 Host        Tags        Paths
---------------------------------------------------------------
0a1f9759  2019-09-01 11:00:00  mopped                  /home/user/work
46cfe4d5  2019-09-08 11:00:00  mopped                  /home/user/work
f6b1f037  2019-09-15 11:00:00  mopped                  /home/user/work
eb430a5d  2019-09-22 11:00:00  mopped                  /home/user/work
8cf1cb9a  2019-09-29 11:00:00  mopped                  /home/user/work
5d33b116  2019-10-06 11:00:00  mopped                  /home/user/work
b9553125  2019-10-13 11:00:00  mopped                  /home/user/work
e1a7b58b  2019-10-20 11:00:00  mopped                  /home/user/work
---------------------------------------------------------------
8 snapshots

# 可以加多个参数
$ restic forget --keep-daily 7 \
    --keep-weekly 5 --keep-monthly 12 --keep-yearly 75

```

### **定制快照删除策略**

为了理解自定义选项，需要先解释删除策略的过程是如何工作的：

1. 扫描所有快照和快照中的目录，以确定哪些数据仍在使用。
2. 对于存储库中的所有文件，`restic`​ 会查明该文件是完全使用、部分使用还是完全未使用。
3. 完全未使用的文件被标记为删除，保存充分使用的文件。根据用户的选择，保留或标记部分使用的文件以便重新打包。
4. 在决定要做什么之后，`prune`​ 将实际执行重新打包，根据更改修改索引，并删除过时的文件。

​`prune`​ 命令接受以下选项：

- ​`--max-unused limit`​

  - 允许存储库中未使用的数据达到指定的上限
  - 指定存储大小，比如 `200M`​，设置为 `0`​ 表示不限制
  - 指定存储百分比，比如 `10%`​，设置为 `0`​ 表示不限制
  - 指定 `unlimited`​ 表示对部分未使用的文件没有限制
- ​`--max-repack-size size`​

  - 设置了限制要重新打包的文件的总大小
- ​`--repack-cacheable-only`​

  - 只有包含元数据并将被存储在缓存中的文件才会被重新打包
- ​`--dry-run`​

  - 只显示 `prune`​ 操作要处理的文件列表

```bash
# --dry-run
$ restic forget --prune --dry-run

# --max-unused
$ restic forget --max-unused 200M --keep-last 1 --prune

```

# 八、管理仓库的钥匙

> **介绍管理仓库的钥匙和密码等信息！**

​`key`​ 命令允许我们为每个存储库设置多个访问密钥或密码。实际上，我们还可以使用 `list`​、`add`​、`remove`​ 和 `passwd`​(更改密码)子命令来精确地管理这些密钥。

```bash
$ restic -r /srv/restic-repo key list
enter password for repository:
 ID          User        Host        Created
----------------------------------------------------------------------
*eb78040b    username    kasimir   2015-08-12 13:29:57

$ restic -r /srv/restic-repo key add
enter password for repository:
enter password for new key:
enter password again:
saved new key as <Key of username@kasimir, created on 2015-08-12 13:35:05.316831933 +0200 CEST>

$ restic -r /srv/restic-repo key list
enter password for repository:
 ID          User        Host        Created
----------------------------------------------------------------------
 5c657874    username    kasimir   2015-08-12 13:35:05
*eb78040b    username    kasimir   2015-08-12 13:29:57

```

# 九、命令参数的列表

```bash
$ ./restic --help

restic is a backup program which allows saving multiple revisions of files and
directories in an encrypted repository stored on different backends.

Usage:
  restic [command]

Available Commands:
  backup        Create a new backup of files and/or directories
  cache         Operate on local cache directories
  cat           Print internal objects to stdout
  check         Check the repository for errors
  copy          Copy snapshots from one repository to another
  diff          Show differences between two snapshots
  dump          Print a backed-up file to stdout
  find          Find a file, a directory or restic IDs
  forget        Remove snapshots from the repository
  generate      Generate manual pages and auto-completion files (bash, zsh)
  help          Help about any command
  init          Initialize a new repository
  key           Manage keys (passwords)
  list          List objects in the repository
  ls            List files in a snapshot
  migrate       Apply migrations
  mount         Mount the repository
  prune         Remove unneeded data from the repository
  rebuild-index Build a new index
  recover       Recover data from the repository
  restore       Extract the data from a snapshot
  self-update   Update the restic binary
  snapshots     List all snapshots
  stats         Scan the repository and show basic statistics
  tag           Modify tags on snapshots
  unlock        Remove locks other processes created
  version       Print version information

Flags:
      --cacert file                file to load root certificates from (default: use system certificates)
      --cache-dir directory        set the cache directory. (default: use system default cache directory)
      --cleanup-cache              auto remove old cache directories
  -h, --help                       help for restic
      --json                       set output mode to JSON for commands that support it
      --key-hint key               key ID of key to try decrypting first (default: $RESTIC_KEY_HINT)
      --limit-download int         limits downloads to a maximum rate in KiB/s. (default: unlimited)
      --limit-upload int           limits uploads to a maximum rate in KiB/s. (default: unlimited)
      --no-cache                   do not use a local cache
      --no-lock                    do not lock the repository, this allows some operations on read-only repositories
  -o, --option key=value           set extended option (key=value, can be specified multiple times)
      --password-command command   shell command to obtain the repository password from (default: $RESTIC_PASSWORD_COMMAND)
  -p, --password-file file         file to read the repository password from (default: $RESTIC_PASSWORD_FILE)
  -q, --quiet                      do not output comprehensive progress report
  -r, --repo repository            repository to backup to or restore from (default: $RESTIC_REPOSITORY)
      --repository-file file       file to read the repository location from (default: $RESTIC_REPOSITORY_FILE)
      --tls-client-cert file       path to a file containing PEM encoded TLS client certificate and private key
  -v, --verbose n                  be verbose (specify multiple times or a level using --verbose=n, max level/times is 3)

Use "restic [command] --help" for more information about a command.

```

‍

‍

```bash
$ ./restic backup --help

The "backup" command creates a new snapshot and saves the files and directories
given as the arguments.

EXIT STATUS
===========

Exit status is 0 if the command was successful.
Exit status is 1 if there was a fatal error (no snapshot created).
Exit status is 3 if some source data could not be read (incomplete snapshot created).

Usage:
  restic backup [flags] FILE/DIR [FILE/DIR] ...

Flags:
  -e, --exclude pattern                        exclude a pattern (can be specified multiple times)
      --exclude-caches                         excludes cache directories that are marked with a CACHEDIR.TAG file. See https://bford.info/cachedir/ for the Cache Directory Tagging Standard
      --exclude-file file                      read exclude patterns from a file (can be specified multiple times)
      --exclude-if-present filename[:header]   takes filename[:header], exclude contents of directories containing filename (except filename itself) if header of that file is as provided (can be specified multiple times)
      --exclude-larger-than size               max size of the files to be backed up (allowed suffixes: k/K, m/M, g/G, t/T)
      --files-from file                        read the files to backup from file (can be combined with file args; can be specified multiple times)
      --files-from-raw file                    read the files to backup from file (can be combined with file args; can be specified multiple times)
      --files-from-verbatim file               read the files to backup from file (can be combined with file args; can be specified multiple times)
  -f, --force                                  force re-reading the target files/directories (overrides the "parent" flag)
  -h, --help                                   help for backup
  -H, --host hostname                          set the hostname for the snapshot manually. To prevent an expensive rescan use the "parent" flag
      --iexclude pattern                       same as --exclude pattern but ignores the casing of filenames
      --iexclude-file file                     same as --exclude-file but ignores casing of filenames in patterns
      --ignore-inode                           ignore inode number changes when checking for modified files
  -x, --one-file-system                        exclude other file systems
      --parent snapshot                        use this parent snapshot (default: last snapshot in the repo that has the same target files/directories)
      --stdin                                  read backup from stdin
      --stdin-filename filename                filename to use when reading from stdin (default "stdin")
      --tag tags                               add tags for the new snapshot in the format `tag[,tag,...]` (can be specified multiple times) (default [])
      --time time                              time of the backup (ex. '2012-11-01 22:08:41') (default: now)
      --use-fs-snapshot                        use filesystem snapshot where possible (currently only Windows VSS)
      --with-atime                             store the atime for all files and directories

Global Flags:
      --cacert file                file to load root certificates from (default: use system certificates)
      --cache-dir directory        set the cache directory. (default: use system default cache directory)
      --cleanup-cache              auto remove old cache directories
      --json                       set output mode to JSON for commands that support it
      --key-hint key               key ID of key to try decrypting first (default: $RESTIC_KEY_HINT)
      --limit-download int         limits downloads to a maximum rate in KiB/s. (default: unlimited)
      --limit-upload int           limits uploads to a maximum rate in KiB/s. (default: unlimited)
      --no-cache                   do not use a local cache
      --no-lock                    do not lock the repository, this allows some operations on read-only repositories
  -o, --option key=value           set extended option (key=value, can be specified multiple times)
      --password-command command   shell command to obtain the repository password from (default: $RESTIC_PASSWORD_COMMAND)
  -p, --password-file file         file to read the repository password from (default: $RESTIC_PASSWORD_FILE)
  -q, --quiet                      do not output comprehensive progress report
  -r, --repo repository            repository to backup to or restore from (default: $RESTIC_REPOSITORY)
      --repository-file file       file to read the repository location from (default: $RESTIC_REPOSITORY_FILE)
      --tls-client-cert file       path to a file containing PEM encoded TLS client certificate and private key
  -v, --verbose n                  be verbose (specify multiple times or a level using --verbose=n, max level/times is 3)

```

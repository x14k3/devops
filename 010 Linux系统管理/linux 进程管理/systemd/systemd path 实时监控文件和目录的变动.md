# systemd path 实时监控文件和目录的变动

systemd path工具提供了监控文件、目录变化并触发执行指定操作的功能。

有时候这种监控功能是非常实用的，比如监控到`/etc/nginx/nginx.conf`​或`/etc/nginx/conf.d/`​发生变化后，立即reload nginx。虽然，用户也可以使用inotify类的工具来监控，但远不如systemd path更方便、更简单且更易于观察监控效果和调试。

其实，systemd path的底层使用的是inotify，所以受限于inotify的缺陷，systemd path只能监控本地文件系统，而无法监控网络文件系统。

## systemd path能监控哪些操作

systemd path暴露的监控功能并不多，它能监控的动作包括：

* PathExists：指定路径是否存在，当发现它存在时，执行指定操作
* PathExistsGlob：是否存在至少一个与模式匹配的路径，当发现存在时，执行指定操作
* PathModified：类似于PathChanged-
  man文档（man systemd.path）中说它们有区别，但我没测试出区别。如果你测出了不同之处，还请告知于我，感谢
* DirectoryNotEmpty：指定的目录是否非空，如果非空，执行指定操作

这些指令监控的路径必须是绝对路径。

可以多次使用这些指令，且同一个指令也可以使用多次，这样就能够同时监控多个文件或目录，它们将共用事件触发后执行的操作。如果想要对不同监控目录执行不同操作，那只能定义多个systemd path的监控实例。

如果监控某路径时发现权限不足，则一直等待，直到有权监控。

如果在启动Path Unit时(systemctl start  xxx.path)，指定的路径已经存在(对于PathExists与PathExistsGlob来说)或者指定的目录非空(对于DirectoryNotEmpty来说)，将会立即触发并执行对应操作。不过，对于PathChanged与PathModified来说，并不遵守这个规则。

## systemd path使用示例

要使用systemd path的功能，需至少编写两个文件，一个`.path`​文件和一个`.service`​文件，这两个文件的前缀名称通常保持一致，但并非必须。这两个文件可以位于以下路径：

* /usr/lib/systemd/system/
* /etc/systemd/system/
* ~/.config/systemd/user/：用户级监控，只在该用户登录后才监控，该用户所有会话都退出后停止监控

例如：

```bash
/usr/lib/systemd/system/test.path
/usr/lib/systemd/system/test.service

/etc/systemd/system/test.path
/etc/systemd/system/test.service

~/.config/systemd/user/test.path
~/.config/systemd/user/test.service

```

例如，有以下监控需求：

1. 监控/tmp/foo目录下的所有文件修改、创建、删除等操作
2. 如果被监控目录/tmp/foo不存在，则创建
3. 监控/tmp/a.log文件的更改
4. 监控/tmp/file.lock锁文件是否存在

为了简化，这些监控触发的事件都执行同一个操作：向/tmp/path.log中写入一行信息。

此处将path_test.path文件和path_test.service文件放在/etc/systemd/system/目录下。

path_test.path内容如下：

```bash
$ cat /etc/systemd/system/path_test.path
[Unit]
Description = monitor some files

[Path]
PathChanged = /tmp/foo
PathModified = /tmp/a.log
PathExists = /tmp/file.lock
MakeDirectory = yes
Unit = path_test.service

# 如果不需要开机后就自动启动监控的话，可省略下面这段
# 如果开机就监控，则加上这段，并执行systemctl enable path_test.path
[Install]
WantedBy = multi-user.target

```

其中MakeDirectory指令默认为no，当设置为yes时表示如果监控的目录不存在，则自动创建目录，但该指令对PathExists指令无效。

Unit指令表示该sysmted path实例监控到符合条件的事件时启动的服务单元，即要执行的对应操作。通常省略该指令，这时启动的服务名称和path实例的名称一致(除了后缀)，例如`path_test.path`​默认启动的是`path_test.service`​服务。

path_test.service内容如下：

```bash
$ cat /etc/systemd/system/path_test.service
[Unit]
Description = path_test.service

[Service]
ExecStart = /bin/bash -c 'echo file changed >>/tmp/path.log'

```

然后执行如下操作启动该systemd path实例：

```bash
systemctl daemon-reload
systemctl start path_test.path

```

使用如下命令可以列出当前已启动的所有systemd path实例：

```bash
$ systemctl --type=path list-units --no-pager
UNIT                               LOAD   ACTIVE SUB     DESCRIPTION                            
systemd-ask-password-console.path  loaded active waiting Dispatch Password Requests to Console
systemd-ask-password-wall.path     loaded active waiting Forward Password Requests to Wall Dir
path_test.path                     loaded active waiting monitor some files

```

然后测试该systemd path能否如愿工作。

```bash
$ touch /tmp/foo/a
$ touch /tmp/foo/a
$ touch /tmp/a.log
$ echo 'hello world' >>/tmp/a.log
$ rm -rf /tmp/a.log
...

```

如果想观察触发情况，可使用journalctl。例如：

```bash
$ journalctl -u path_test.service
Jul 05 16:09:43 junmajinlong.com systemd[1]: Started path_test.service.
Jul 05 16:09:45 junmajinlong.com systemd[1]: Started path_test.service.
Jul 05 16:09:47 junmajinlong.com systemd[1]: Started path_test.service.
Jul 05 16:09:49 junmajinlong.com systemd[1]: Started path_test.service.
Jul 05 16:09:51 junmajinlong.com systemd[1]: Started path_test.service.
Jul 05 16:09:55 junmajinlong.com systemd[1]: Started path_test.service.

```

## systemd path临时监控

使用systemd-run命令可以临时监控路径。

```bash
$ systemd-run --path-property=PathModified=/tmp/b.log echo 'file changed'
Running path as unit: run-rb6f67e732fb243c7b530673cac867582.path
Will run service as unit: run-rb6f67e732fb243c7b530673cac867582.service

```

可以查看当前已启动的systemd path实例，包括临时监控实例：

```bash
$ systemctl --type=path list-units --no-pager

```

如果需要停止，使用run-xxxxxx名称即可：

```bash
systemctl stop run-rb6f67e732fb243c7b530673cac867582.path

```

## systemd path资源控制

systemd path触发的任务可能会消耗大量资源，比如执行rsync的定时任务、执行数据库备份的定时任务，等等，它们可能会消耗网络带宽，消耗IO带宽，消耗CPU等资源。

想要控制这些定时任务的资源使用量也非常简单，因为真正执行任务的是`.service`​，而Service配置文件中可以轻松地配置一些资源控制指令或直接使用Slice定义的CGroup。这些资源控制类的指令可参考`man systemd.resource-control`​。

例如，直接在`[Service]`​中定义资源控制指令：

```bash
[Service]
Type=simple
MemoryLimit=20M
ExecStart=/usr/bin/backup.sh

```

又或者让Service使用定义好的Slice：

```bash
[Service]
ExecStart=/usr/bin/backup.sh
Slice=backup.slice

```

其中backup.slice的内容为：

```bash
$ cat /usr/lib/systemd/system/backup.slice
[Unit]
Description=Limited resources Slice
DefaultDependencies=no
Before=slices.target

[Slice]
CPUQuota=50%
MemoryLimit=20M

```

## systemd path的『Bug』

systemd path监控路径上所产生的事件是需要时间的，如果两个事件发生时的时间间隔太短，systemd path可能会丢失第二个甚至后续第三个第四个等等事件。

例如，使用`PathChanged`​或`PathModified`​监控路径/tmp/foo目录时，执行以下操作触发事件：

```bash
$ touch /tmp/foo/a && rm -rf /tmp/foo/a

```

期待的是systemd path能够捕获这两个事件并执行两次对应的操作，但实际上只会执行一次对应操作。换句话说，systemd path丢失了一次事件。

之所以会丢失事件，是因为touch产生的事件被systemd path捕获，systemd path立即启动对应`.service`​服务做出对应操作，在本次操作还未执行完时，rm又立即产生了新的事件，于是systemd path再次启动服务，但此时服务尚未退出，所以本次启动服务实际上什么事也不做。

所以，从结果上看去就像是systemd path丢失了事件，但实际上是因为服务尚未退出的情况下再次启动服务不会做任何事情。

可以加上一点休眠时间来耽搁一会：

```bash
$ touch /tmp/foo/a && sleep 0.1 && rm -rf /tmp/foo/a

```

上面的命令会成功执行两次对应操作。

再比如，将`.service`​文件中的ExecStart设置为`/usr/bin/sleep 5`​，那么在5秒内的所有操作，除了第一次触发的事件外，其它都会丢失。

systemd path的这个『bug』也有好处，因为可以让**瞬间产生的多个有关联关系的事件只执行单次任务**，从而避免了中间过程产生的事件也重复触发相关操作。

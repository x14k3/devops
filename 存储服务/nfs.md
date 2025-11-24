

NFS：Network File System 网络文件系统，基于内核的文件系统。Sun 公司开发，通过使用 NFS，用户和程序可以像访问本地文件一样访问远端系统上的文件，基于RPC（Remote Procedure Call Protocol 远程过程调用）实现。

**NFS优势**

可以把服务器上的文件像本地一样的操作，节省本地的存储空间
nfs配置简单，而且服务本身对系统资源占用较少
nfs服务可以支持很多其它的服务，如kickstart，配合在一起，可以实现更多功能

**工作原理**

NFS体系有两个主要部分：

NFS服务端机器：通过NFS协议将文件共享到网络。
NFS客户端机器：通过网络挂载NFS共享目录到本地。

NFS服务器与客户端在进行数据传输时，需要先确定端口，而这个端口的确定需要借助RPC(Remote Procedure Call,远程过程调用)协议的协助。RPC最主要的功能就是在指定每个NFS服务所对应的端口号，并且告知客户端，让客户端可以连接到正确的端口上去。当我们启动NFS服务时会随机取用数个端口，并主动向RPC注册，因此RPC可以知道每个端口对应的NFS，而RPC又是固定使用 port 111监听客户端的需求并且能够准确的告知客户端正确的端口。

1.客户端向服务器的111端口发送nfs请求
2.RPC找到对应的nfs端口并告知客户端
3.客户端知道正确的端口后，直接与nfs server端建立连接

**相关文件**

```bash
/etc/exports        # 共享配置文件，用来设置共享
/etc/nfs.conf       # nfs服务的配置文件，可以设置端口和超时时间等，大多数时候不需要修改
/etc/sysconfig/nfs  # 端口设置文件，重启服务后系统会自动调整nfs.conf内容
/var/lib/nfs/etab   # 记录nfs共享的完整权限设定值
```

## nfs-server 部署

```bash
# nfs-utils依赖于rpc-bind，所以该步骤也会自动安装依赖rpc-bind
yum install -y rpcbind nfs-utils

# 创建共享目录
mkdir /data ; chown -R nfs.nfs /data

# 存储目录信息  允许哪些主机进行数据存储(权限参数)
vim /etc/exports
---------------------------------
/data/nfs 192.168.0.0/24(rw,sync,no_subtree_check)
/data   *(rw,sync,no_subtree_check)
---------------------------------

# 启动nfs-server
systemctl daemon-reload
systemctl start  nfs-server
systemctl status nfs-server
```

# nfs-client 部署

```bash
yum -y install nfs-utils

# 把server的/data 目录挂载到 client主机的/data 目录
sudo mount -t nfs 192.168.93.30:/data /data

# 测试

# 开机自动挂载
cat >> /etc/fstab <<EOF
192.168.93.30:/data /data nfs rw,tcp,intr 0 1
EOF
```

# 配置说明

`/etc/exports`

```bash
# 格式：
#共享目录    客户端(权限1，权限2）

#共享目录：在本地的位置（绝对路径）
#客户端：一台主机，一群主机（IP地址、网段、主机名、域名）
#权限：
ro         # 只读访问（默认） 
rw         # 读写访问  
sync       # 将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性；（默认）  
async      # 将数据先保存在内存缓冲区中，必要时才写入磁盘；
secure     # 客户端只能使用小于1024的端口连接（默认）  
insecure   # 允许客户端使用大于1024的端口连接  
wdelay     # 检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率（默认）；
no_wdelay  # 若有写操作则立即执行，应与sync配合使用；
hide       # 在NFS共享目录中不共享其子目录（默认）  
no_hide    # 共享NFS目录的子目录  
subtree_check     # 如果共享目录是子目录时，强制NFS检查父目录的权限（默认）  
no_subtree_check  # 和上面相对，不检查父目录权限  
all_squash        # 共享文件的UID和GID映射匿名用户anonymous，适合公用目录。  
no_all_squash     # 保留共享文件的UID和GID（默认）  
root_squash       # root用户的所有请求映射成如anonymous用户一样的权限（默认）  
no_root_squash    # root用户具有根目录的完全管理访问权限  
anonuid=xxx       # 指定NFS服务器/etc/passwd文件中匿名用户的UID  
anongid=xxx       # 指定NFS服务器/etc/passwd文件中匿名用户的GID
```

# 相关命令

exportfs - 管理NFS共享文件系统列表

```bash
-a     # 发布获取消所有目录共享。
-r     # 重新挂载/etc/exports里面的共享目录,同时更新/etc/exports 和/var/lib/nfs/xtab的内容
-u     # 取消一个或多个目录的共享。
-v     # 输出详细信息。
-o     # 指定一系列共享选项(如rw,async,root_squash)
-i     # 忽略/etc/exports和/etc/exports.d目录下文件。此时只有命令行中给定选项和默认选项会生效。


例如：
#exportfs   -rv	  //重新挂载共享目录，并且显示。
#exportfs   -au	  //卸载所有共享目录。
```

showmount	可以在server/client上使用此命令来查看server

```bash
#showmount	[-ae]	hostname/ip
-a或--all
    以 host:dir 这样的格式来显示客户主机名和挂载点目录。
-d或--directories
    仅显示被客户挂载的目录名。
-e或--exports

[root@zutuanxue ~]# showmount -e
Export list for manage01:
/opt *

```

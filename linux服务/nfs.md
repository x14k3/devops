#system

1.概述  
NFS：Network File System 网络文件系统，基于内核的文件系统。Sun 公司开发，通过使用 NFS，用户和程序可以像访问本地文件一样访问远端系统上的文件，基于RPC（Remote Procedure Call Protocol 远程过程调用）实现。

NFS优势：节省本地存储空间，将常用的数据,如：/home目录，存放在NFS服务器上且可以通过网络访问，本地终端将可减少自身存储空间的使用

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



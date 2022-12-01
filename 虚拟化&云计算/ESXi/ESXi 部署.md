#virtual/esxi 

## 1.下载地址

下载VMware-VMvisor-Installer-xxx.iso和VMware-vCenter-Server-Appliance-xxx.iso

<https://customerconnect.vmware.com/cn/downloads/#all_products>

## 2.修改静态ip

![](assets/ESXi%20部署/image-20221127212130509.png)

# 安装vCenter Server

VMware-VCSA-all-7.0.0-15952498.iso文件，用虚拟光驱挂载或者解压运行，本地系统以win10拟光驱挂载为例，运行vcsa-ui-installer/win32/installer.exe

登陆账号(管理员+oss域名)：<administrator@vsphere.local> &#x20;

# vCenter添加ESXi

## 1.新建数据中心

## 2.添加主机（ESXi）



**VMware虚拟机磁盘有厚置备、精简置备两种格式。精简置备磁盘按需增长，厚置备磁盘立刻分配所需空间。**
厚置备磁盘较之精简置备磁盘有较好的性能，但初始置备浪费的空间较多。
如果频繁增加、删除、修改数据，精简置备磁盘实际占用的空间会超过为其分配的空间。例如某个VMware Workstation或VMware ESXi的虚拟机，为虚拟硬盘分配了40GB的空间（精简置备）。如果这台虚拟机反复添加、删除数据，在虚拟机中看到硬盘剩余空间只能还有很多，例如剩余一半，但这个虚拟硬盘所占用的物理空间可能已经超过了40GB，如果是厚置备磁盘则不会存在这个问题。
实际的生产环境中，虚拟机选择厚置备磁盘还是精简置备磁盘，要根据实际情况选择。如果虚拟机强调性能、并且数据量不大，则选择“厚置备立刻置零”，这将获得最好的性能。如果数据量持续增长、但变动不大，只是持续的增加，则可以选择“精简置备”磁盘。


# QEMU-KVM 虚拟机克隆

‍

注意事项：被克隆的机器最好先做成模板机，否者很多唯一性的东西还得手动删除，就是制作模板机的那些删除数据。

## 自动克隆

```bash
#查看所有虚拟机
virsh list --all  

# 开始科隆
virt-clone --auto-clone -o template -n test_02
#-o 原始虚拟机
#-n 克隆后的新虚拟机
#--auto-clone 自动克隆
```

## 手动克隆

1. 复制一个磁盘镜像文件

    ```
    cp /var/lib/libvirt/images/rhel8.qcow2   /var/lib/libvirt/images/rhel8_clone1.qcow2
    ```

2. 复制一个虚拟机的xml文件

    ```
    [root@zutuanxue ~]# virsh dumpxml --domain rhel8 > /etc/libvirt/qemu/rhel8_clone1.xml
    ```

3. 修改xml文件 将原始机器的唯一性配置删除

    * 修改虚拟机名字
    * 删除UUID
    * 删除mac地址
    * 修改磁盘路径

4. 导入虚拟机

    ```
    根据xml文件导入机器
    [root@zutuanxue ~]# virsh define --file /etc/libvirt/qemu/rhel8_clone1.xml 
    定义域 rhel8_clone1（从 /etc/libvirt/qemu/rhel8_clone1.xml）
    ```

## 链接克隆

- 创建一个链接克隆磁盘，必须是qcow2格式磁盘
- 生成一个xml文件
- 修改xml文件
- 导入xml文件

a、 创建一个链接克隆磁盘，必须是qcow2格式磁盘

```
[root@zutuanxue ~]# qemu-img create -b /var/lib/libvirt/images/rhel8.qcow2 -f qcow2 /var/lib/libvirt/images/rhel8_clone2.qcow2
Formatting '/var/lib/libvirt/images/rhel8_clone2.qcow2', fmt=qcow2 size=10737418240 backing_file=/var/lib/libvirt/images/rhel8.qcow2 cluster_size=65536 lazy_refcounts=off refcount_bits=16

查看
[root@zutuanxue ~]# ll -h /var/lib/libvirt/images/rhel8_clone2.qcow2 
-rw-r--r-- 1 root root 193K 3月  24 00:49 /var/lib/libvirt/images/rhel8_clone2.qcow2

显示仅有193K，ok


[root@zutuanxue ~]# qemu-img info /var/lib/libvirt/images/rhel8_clone2.qcow2 
image: /var/lib/libvirt/images/rhel8_clone2.qcow2
file format: qcow2
virtual size: 10G (10737418240 bytes)
disk size: 196K
cluster_size: 65536
backing file: /var/lib/libvirt/images/rhel8.qcow2  #显示链接后端磁盘
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

b、生成一个xml文件

```
[root@zutuanxue ~]# virsh dumpxml --domain rhel8 > /etc/libvirt/qemu/rhel8_clone2.xml
```

c、修改xml

```
修改虚拟机名字
删除UUID
删除mac地址
修改磁盘路径
```

d、导入虚拟机

```
[root@zutuanxue ~]# virsh define /etc/libvirt/qemu/rhel8_clone2.xml
定义域 rhel8_clone2（从 /etc/libvirt/qemu/rhel8_clone2.xml）

[root@zutuanxue ~]# virsh list --all
 Id    名称                         状态
----------------------------------------------------
 6     rhel8-clone                    running
 -     centos8-3                      关闭
 -     centos8-4                      关闭
 -     rhel8                          关闭
 -     rhel8-2                        关闭
 -     rhel8_clone2                   关闭
 -     win10                          关闭
```

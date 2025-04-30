# 将OVA格式的虚拟机导入KVM

首先，用file命令查看OVA文件，即可看到OVA文件实际就是tar文件：

```shell
$file Hortonworks+Sandbox+2.0+VirtualBox.ova 
Hortonworks+Sandbox+2.0+VirtualBox.ova: POSIX tar archive (GNU)
```

使用tar命令可以看到，其中包含了两个文件：

```shell
$tar tf Hortonworks+Sandbox+2.0+VirtualBox.ova 
Hortonworks Sandbox 2.0 VirtualBox.ovf
Hortonworks Sandbox 2.0 VirtualBox-disk1.vmdk
```

用tar解压：

```shell
$tar xvf Hortonworks+Sandbox+2.0+VirtualBox.ova 
Hortonworks Sandbox 2.0 VirtualBox.ovf
Hortonworks Sandbox 2.0 VirtualBox-disk1.vmdk
```

ovf文件保存的是配置信息，没法直接导入；但是一般能导入vmdk格式的镜像就可以了。 把vmdk格式的镜像转化为qcow2格式的：

```shell
$qemu-img convert -O qcow2 \
  'Hortonworks Sandbox 2.0 VirtualBox-disk1.vmdk' \
  'Hortonworks Sandbox 2.0 VirtualBox-disk1.qcow2'
```

转换完成后，用 `Hortonworks Sandbox 2.0 VirtualBox-disk1.qcow2`​ 文件创建虚拟机即可。

‍

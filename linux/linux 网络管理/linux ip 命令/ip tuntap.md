

输入 `ip tuntap help`​ 查看详细使用命令：

```dockerfile
[root@localhost ~]# ip tuntap help
Usage: ip tuntap { add | del } [ dev PHYS_DEV ]
          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]
          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]

Where: USER  := { STRING | NUMBER }
       GROUP := { STRING | NUMBER }
```

## ip tuntap add

创建 tap/tun 设备：

```csharp
ip tuntap add dev tap0 mod tap # 创建 tap 
ip tuntap add dev tun0 mod tun # 创建 tun
```

## ip tuntap del

删除 tap/tun 设备：

```python
ip tuntap del dev tap0 mod tap # 删除 tap 
ip tuntap del dev tun0 mod tun # 删除 tun
```

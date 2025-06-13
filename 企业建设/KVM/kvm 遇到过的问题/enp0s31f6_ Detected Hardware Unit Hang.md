# enp0s31f6: Detected Hardware Unit Hang

参考：

[https://ovear.info/post/356](https://ovear.info/post/356)

[https://github.com/g199209/BlogMarkdown/blob/master/PVE上部署OpenWRT发生网络中断的解决方法.md](https://github.com/g199209/BlogMarkdown/blob/master/PVE%E4%B8%8A%E9%83%A8%E7%BD%B2OpenWRT%E5%8F%91%E7%94%9F%E7%BD%91%E7%BB%9C%E4%B8%AD%E6%96%AD%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95.md)

基本所有文章都提到此问题与`TCP checksum offload`​特性有关，解决方案就是关掉`checksum offload`​。具体方法是使用`ethtool`​工具：

```shell
ethtool -K enp0s31f6 tx off rx off
```

如果要重启后永久生效的话将此命令写入`/etc/network/if-up.d/ethtool2`​文件中并为此文件加上`x`​权限即可：

```bash
#!/bin/sh
ethtool -K enp0s31f6 tx off rx off
```

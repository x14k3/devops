# netsh

‍

windwos 通过命令添加辅助ip和网关

```bash
# 首先set ip 临时有效
netsh interface ip set address source=static name="本地连接" addr=192.168.1.10 mask=255.255.255.0 gateway=192.168.1.1 gwmetric=1 store=active
# 再 add 管理ip 永久有效
netsh interface ip set address name="本地连接" addr=10.10.1.10 mask=255.255.255.0 gateway=10.101.1 gwmetric=1  store=persistent skipassource=true
```

‍

‍


Download: [https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2022.10.3.tgz](https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2022.10.3.tgz)

```bash
# 解压

# 编译安装
./configure 
make && make install
# 挂载
ntfs-3g /dev/sdb1 /mnt/usb
```
# zypper

#### zypper常用命令

```bash
#存储库管理：
repos, lr      列出所有定义的存储库。
addrepo, ar    添加新存储库。
removerepo, rr 删除指定的存储库。
renamerepo, nr 重命名指定的存储库。
modifyrepo, mr 修改指定的存储库。
refresh,ref    刷新所有存储库。
clean, cc      清理本地缓存。

#安装包操作
search,se      #查询安装包
install,ain    #安装软件包 zypper install package_name=version #安装某个版本的软件包
remove,re      #卸载软件
update,up      #更新软件
download       #将命令行上指定的 rpm 下载到本地目录
purge-kernels  #删除旧内核。

#列出所有已安装的包
zypper se -i -t package
```

## opensuse 修改阿里源

```
# 禁用所有软件源
sudo zypper mr -da
#查看系统对应的版本 openSUSE Leap 15.5
cat /etc/os-release 
#添加阿里OpenSUSE镜像源
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/distribution/leap/15.5/repo/oss openSUSE-Aliyun-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/distribution/leap/15.5/repo/non-oss openSUSE-Aliyun-NON-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/update/leap/15.5/oss openSUSE-Aliyun-UPDATE-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/update/leap/15.5/non-oss openSUSE-Aliyun-UPDATE-NON-OSS

#刷新软件源
sudo zypper ref
#更新
sudo zypper update
```

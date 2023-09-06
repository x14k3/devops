# opensuse zypper

#### zypper常用命令

```bash
#安装源操作：zypper+ 参数

repos, lr       #列出所有定义的安装源
addrepo, ar     #添加一个新的安装源
removerepo, rr  #删除指定的安装源
renamerepo, nr  #重命名指定的安装源
modifyrepo, mr  #修改指定的安装源
refresh, ref    #刷新所有安装源
clean           #清除本地缓存

#安装某个软件包
zypper install package_name
#安装某个版本的软件包
zypper install package_name=version
#卸载某个软件包
zypper remove package_name
```

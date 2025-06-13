# zypper

#### zypper常用命令

```bash
#存储库管理：
repos, lr      # 列出所有定义的存储库。
addrepo, ar    # 添加新存储库。
removerepo, rr # 删除指定的存储库。
renamerepo, nr # 重命名指定的存储库。
modifyrepo, mr # 修改指定的存储库。 [-e -d -f]
refresh,ref    # 刷新所有存储库。
clean, cc      # 清理本地缓存。

#安装包操作
search,se      # 查询安装包
install,ain    # 安装软件包 zypper install package_name=version #安装某个版本的软件包
remove,re      # 卸载软件
update,up      # 更新软件
download       # 将命令行上指定的 rpm 下载到本地目录
purge-kernels  # 删除旧内核。

#列出所有已安装的包
zypper se -i -t package
```

一些基本命令选项（以mr为例）

```bash
-n, --name 为软件源设置一个描述性名称。
-e, --enable 启用已禁用的软件源。
-d, --disable 禁用但不移除软件源。
-f, --refresh 启用软件源的自动刷新。
-F, --no-refresh 禁用软件源的自动刷新。
-p, --priority 设置软件源的优先级。
-k, --keep-packages 启用 RPM 文件缓存。
-K, --no-keep-packages 禁用 RPM 文件缓存。
-g, --gpgcheck 对此软件源启用 GPG 密钥检查。
–gpgcheck-strict 为此软件源启用严格的 GPG 密钥检查。
–gpgcheck-allow-unsigned
‘–gpgcheck-allow-unsigned-repo
–gpgcheck-allow-unsigned-package’ 的缩写。
–gpgcheck-allow-unsigned-repo
启用 GPG 密钥检查但允许未签名的软件源元数据。
–gpgcheck-allow-unsigned-package
启用 GPG 检查但允许从此软件源安装未签名的软件包。
-G, --no-gpgcheck 对此软件源禁用 GPG 密钥检查。
–default-gpgcheck 使用定义在 /etc/zypp/zypp.conf 中的全局 GPG
检查设置。这是默认选项。
-a, --all 应用修改到全部软件源。
-l, --local 应用修改到全部本地软件源。
-t, --remote 应用修改到全部远程软件源。
-m, --medium-type 应用修改到指定类型的软件源。
```

‍

‍

## opensuse 修改阿里源

```bash
# 禁用所有软件源
sudo zypper mr -da
# 查看系统对应的版本 openSUSE Leap 15.5
cat /etc/os-release 
# 添加阿里OpenSUSE镜像源
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/distribution/leap/15.6/repo/oss openSUSE-Aliyun-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/distribution/leap/15.6/repo/non-oss openSUSE-Aliyun-NON-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/update/leap/15.6/oss openSUSE-Aliyun-UPDATE-OSS
sudo zypper ar -fc https://mirrors.aliyun.com/opensuse/update/leap/15.6/non-oss openSUSE-Aliyun-UPDATE-NON-OSS

#刷新软件源
sudo zypper ref
#更新
sudo zypper update
```
